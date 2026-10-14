-- ============================================================================
-- Migración 061 — People Analytics: score de riesgo de rotación (reemplaza
-- a "Attrition Prediction"/"Employee Attrition Prediction" del tablero de
-- referencia Agile HR Analytics). NO es un modelo de Machine Learning
-- entrenado -- es un score heurístico transparente y auditable (0-100%),
-- combinación ponderada de 5 factores reales (antigüedad, ausentismo,
-- desempeño, capacitación, compensación relativa al puesto), con pesos
-- configurables por tenant en tp_parametros_globales (Configuracion.jsx) --
-- "Cero parámetros de negocio en código" (principio #1 de este proyecto).
-- Se eligió este enfoque explícitamente sobre un modelo de ML real, que
-- requeriría una pipeline externa (Python/sklearn u otro servicio) fuera del
-- alcance de Supabase/Postgres solo (decisión confirmada con el usuario).
--
-- Cuando un empleado no tiene dato para un factor (ej. sin evaluación de
-- desempeño capturada), ese factor se excluye y el score se renormaliza
-- sobre los pesos de los factores que sí tienen dato -- no se asume 0 ni 1,
-- para no sesgar el score por falta de captura.
--
-- Nota real encontrada al investigar `tr_empleado_plaza` en la base viva
-- (antes de escribir esta vista): existen DOS pares de columnas de fecha
-- (`fecha_inicio`/`fecha_fin` y `fecha_inicio_plaza`/`fecha_fin_plaza`),
-- ninguno documentado en reset_database.sql (gap ya conocido, migraciones
-- 039-057). Se usa `fecha_inicio`/`fecha_fin` porque es el par que el
-- frontend (ExpedienteEmpleado.jsx) y `obtener_certeza_puesto()` ya usan en
-- producción -- no se adivina cuál es el vigente, se sigue el que ya está
-- cableado al resto del sistema.
-- ============================================================================

ALTER TABLE tp_parametros_globales
  ADD COLUMN IF NOT EXISTS peso_riesgo_antiguedad     numeric(4,3) NOT NULL DEFAULT 0.30,
  ADD COLUMN IF NOT EXISTS peso_riesgo_ausentismo      numeric(4,3) NOT NULL DEFAULT 0.25,
  ADD COLUMN IF NOT EXISTS peso_riesgo_desempeno       numeric(4,3) NOT NULL DEFAULT 0.20,
  ADD COLUMN IF NOT EXISTS peso_riesgo_capacitacion    numeric(4,3) NOT NULL DEFAULT 0.10,
  ADD COLUMN IF NOT EXISTS peso_riesgo_compensacion    numeric(4,3) NOT NULL DEFAULT 0.15,
  ADD COLUMN IF NOT EXISTS tope_antiguedad_riesgo_anios   numeric(5,2) NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS tope_ausentismo_riesgo_dias    numeric(5,2) NOT NULL DEFAULT 20,
  ADD COLUMN IF NOT EXISTS tope_capacitacion_riesgo_horas numeric(5,2) NOT NULL DEFAULT 20;

COMMENT ON COLUMN tp_parametros_globales.peso_riesgo_antiguedad IS
  'Peso del factor antigüedad en v_riesgo_rotacion_empleado (0 años = riesgo máximo, >= tope_antiguedad_riesgo_anios = riesgo 0).';
COMMENT ON COLUMN tp_parametros_globales.peso_riesgo_ausentismo IS
  'Peso del factor ausentismo (días de permiso/incapacidad en los últimos 12 meses, >= tope_ausentismo_riesgo_dias = riesgo máximo).';
COMMENT ON COLUMN tp_parametros_globales.peso_riesgo_desempeno IS
  'Peso del factor desempeño (última calificación 0-10; sin evaluación capturada, el factor se excluye del score).';
COMMENT ON COLUMN tp_parametros_globales.peso_riesgo_capacitacion IS
  'Peso del factor capacitación (horas en los últimos 12 meses; >= tope_capacitacion_riesgo_horas = riesgo 0).';
COMMENT ON COLUMN tp_parametros_globales.peso_riesgo_compensacion IS
  'Peso del factor compensación relativa (sueldo de la plaza vigente vs. promedio del mismo puesto en el tenant; sin plaza/sueldo capturado, el factor se excluye).';

CREATE OR REPLACE VIEW v_riesgo_rotacion_empleado AS
WITH factores AS (
  SELECT
    e.id AS empleado_id, e.tenant_id, e.folio,
    trim(e.nombres || ' ' || e.apellido_paterno || ' ' || coalesce(e.apellido_materno, '')) AS nombre_completo,
    e.id_puesto_principal AS puesto_id, pu.titulo AS puesto, un.titulo AS unidad_negocio,
    e.id_sitio_principal AS sitio_id, si.titulo AS sitio,
    round((date_part('year', age(CURRENT_DATE, e.fecha_alta))
      + date_part('month', age(CURRENT_DATE, e.fecha_alta)) / 12.0)::numeric, 1) AS antiguedad_anios,
    coalesce(a.dias_12m, 0) AS dias_ausentismo_12m,
    coalesce(c.horas_12m, 0) AS horas_capacitacion_12m,
    d.calificacion AS ultima_calificacion,
    pa.sueldo AS sueldo_actual,
    pp.sueldo_prom AS sueldo_promedio_puesto,
    greatest(0, least(1, 1 - (date_part('year', age(CURRENT_DATE, e.fecha_alta))
      + date_part('month', age(CURRENT_DATE, e.fecha_alta)) / 12.0) / nullif(pg.tope_antiguedad_riesgo_anios, 0)))::numeric AS factor_antiguedad,
    least(1, coalesce(a.dias_12m, 0) / nullif(pg.tope_ausentismo_riesgo_dias, 0))::numeric AS factor_ausentismo,
    CASE WHEN d.calificacion IS NULL THEN NULL
         ELSE greatest(0, least(1, (10 - d.calificacion) / 10.0))::numeric END AS factor_desempeno,
    greatest(0, least(1, 1 - coalesce(c.horas_12m, 0) / nullif(pg.tope_capacitacion_riesgo_horas, 0)))::numeric AS factor_capacitacion,
    CASE WHEN pa.sueldo IS NULL OR pp.sueldo_prom IS NULL OR pp.sueldo_prom = 0 THEN NULL
         ELSE greatest(0, least(1, 1 - pa.sueldo / pp.sueldo_prom))::numeric END AS factor_compensacion,
    pg.peso_riesgo_antiguedad, pg.peso_riesgo_ausentismo, pg.peso_riesgo_desempeno,
    pg.peso_riesgo_capacitacion, pg.peso_riesgo_compensacion
  FROM te_empleados e
  JOIN tp_parametros_globales pg ON pg.tenant_id = e.tenant_id
  LEFT JOIN tc_puestos pu ON pu.id = e.id_puesto_principal
  LEFT JOIN tc_unidades_negocio un ON un.id = pu.id_unidad_negocio
  LEFT JOIN tc_sitios si ON si.id = e.id_sitio_principal
  LEFT JOIN (
    SELECT empleado_id, sum(dias) AS dias_12m FROM te_permisos_empleado
    WHERE estado <> 'cancelado' AND fecha_inicio >= CURRENT_DATE - interval '12 months'
    GROUP BY empleado_id
  ) a ON a.empleado_id = e.id
  LEFT JOIN (
    SELECT empleado_id, sum(horas) AS horas_12m FROM te_capacitaciones_empleado
    WHERE fecha_inicio >= CURRENT_DATE - interval '12 months'
    GROUP BY empleado_id
  ) c ON c.empleado_id = e.id
  LEFT JOIN (
    SELECT DISTINCT ON (empleado_id) empleado_id, calificacion FROM te_evaluaciones_empleado
    ORDER BY empleado_id, fecha_evaluacion DESC
  ) d ON d.empleado_id = e.id
  LEFT JOIN (
    SELECT DISTINCT ON (empleado_id) empleado_id, puesto_id, sueldo FROM tr_empleado_plaza
    WHERE fecha_inicio <= CURRENT_DATE AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE) AND sueldo IS NOT NULL
    ORDER BY empleado_id, fecha_inicio DESC
  ) pa ON pa.empleado_id = e.id
  LEFT JOIN (
    SELECT puesto_id, avg(sueldo) AS sueldo_prom FROM tr_empleado_plaza
    WHERE sueldo > 0 GROUP BY puesto_id
  ) pp ON pp.puesto_id = pa.puesto_id
  WHERE e.activo
)
SELECT
  empleado_id, tenant_id, folio, nombre_completo, puesto_id, puesto, unidad_negocio, sitio_id, sitio,
  antiguedad_anios, dias_ausentismo_12m, horas_capacitacion_12m, ultima_calificacion,
  sueldo_actual, round(sueldo_promedio_puesto, 2) AS sueldo_promedio_puesto,
  round(factor_antiguedad * 100, 1) AS pct_antiguedad,
  round(factor_ausentismo * 100, 1) AS pct_ausentismo,
  round(factor_desempeno * 100, 1) AS pct_desempeno,
  round(factor_capacitacion * 100, 1) AS pct_capacitacion,
  round(factor_compensacion * 100, 1) AS pct_compensacion,
  round(100 * (
      peso_riesgo_antiguedad * factor_antiguedad
    + peso_riesgo_ausentismo * factor_ausentismo
    + coalesce(peso_riesgo_desempeno * factor_desempeno, 0)
    + peso_riesgo_capacitacion * factor_capacitacion
    + coalesce(peso_riesgo_compensacion * factor_compensacion, 0)
  ) / nullif(
      peso_riesgo_antiguedad + peso_riesgo_ausentismo + peso_riesgo_capacitacion
    + CASE WHEN factor_desempeno IS NULL THEN 0 ELSE peso_riesgo_desempeno END
    + CASE WHEN factor_compensacion IS NULL THEN 0 ELSE peso_riesgo_compensacion END
  , 0), 1) AS riesgo_pct
FROM factores;

GRANT SELECT ON v_riesgo_rotacion_empleado TO anon, authenticated, service_role;
