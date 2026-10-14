-- ============================================================================
-- Migración 058 — People Analytics (Fase 1): conecta al Data Warehouse los
-- módulos de RRHH que ya existían en el esquema (rotación, desempeño,
-- capacitación, vacaciones, reclutamiento) pero nunca se habían cableado a
-- ningún dw_dim/dw_hecho. Pedido del usuario 2026-10-14: "un módulo de people
-- analytics que nos permita tener todos los datos y hacer los estudios o los
-- análisis adecuados". Ningún dato se inventa: todo sale de columnas/tablas
-- que ya existían (te_empleados.fecha_alta/fecha_baja, te_capacitaciones_
-- empleado, te_evaluaciones_empleado, te_vacaciones_periodos, te_candidatos/
-- te_vacantes/tr_postulacion_candidato_vacante).
--
-- Decisión de diseño: "Seniority" (Junior/Mid/Senior) y "Generación"
-- (Boomers/Gen X/...) que aparecen en el tablero de referencia "Agile HR
-- Analytics" (carpeta pEOPLEaNALITYCS) NO existen como dato real en nuestro
-- esquema -- no se inventa un campo de negocio sin evidencia (mismo criterio
-- que D12/D16 de CLAUDE.md). En su lugar se exponen Rango de Edad y Rango de
-- Antigüedad, calculados a partir de fecha_nacimiento/fecha_alta (dato real).
--
-- tipo_baja (voluntaria/involuntaria) se agrega como columna NUEVA y NULA --
-- no se infiere de motivo_baja (texto libre) por heurística, para no
-- clasificar con un criterio no confirmado por el usuario. Las bajas
-- históricas quedan "sin clasificar" hasta que se capture el dato real desde
-- la UI (pendiente de Fase 2: agregar el campo a ExpedienteEmpleado.jsx).
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE baja_tipo_enum AS ENUM ('voluntaria', 'involuntaria');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE te_empleados ADD COLUMN IF NOT EXISTS tipo_baja baja_tipo_enum;

-- ---------------------------------------------------------------------------
-- 1. Ampliar dw_dim_empleado con los atributos demográficos/de ciclo de vida
--    que ya existían en te_empleados pero nunca se copiaron al DW.
-- ---------------------------------------------------------------------------
ALTER TABLE dw_dim_empleado
  ADD COLUMN IF NOT EXISTS sexo                sexo_enum,
  ADD COLUMN IF NOT EXISTS fecha_nacimiento     date,
  ADD COLUMN IF NOT EXISTS fecha_alta           date,
  ADD COLUMN IF NOT EXISTS fecha_baja           date,
  ADD COLUMN IF NOT EXISTS tipo_baja            baja_tipo_enum,
  ADD COLUMN IF NOT EXISTS sitio_principal_id   uuid REFERENCES dw_dim_sitio(id);

-- ---------------------------------------------------------------------------
-- 2. Nuevos hechos
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw_hecho_movimiento_empleado (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha           date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  empleado_id     uuid NOT NULL REFERENCES dw_dim_empleado(id),
  puesto_id       uuid REFERENCES dw_dim_puesto(id),
  sitio_id        uuid REFERENCES dw_dim_sitio(id),
  tipo_movimiento text NOT NULL CHECK (tipo_movimiento IN ('alta','baja')),
  tipo_baja       baja_tipo_enum,
  motivo_baja     text,
  UNIQUE (tenant_id, empleado_id, tipo_movimiento)
);
CREATE INDEX IF NOT EXISTS ix_dwhme_tf ON dw_hecho_movimiento_empleado(tenant_id, fecha);

CREATE TABLE IF NOT EXISTS dw_hecho_capacitacion (
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha         date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  empleado_id   uuid NOT NULL REFERENCES dw_dim_empleado(id),
  tipo          text,
  horas         numeric(6,1),
  institucion   text
);
CREATE INDEX IF NOT EXISTS ix_dwhcap_tf ON dw_hecho_capacitacion(tenant_id, fecha);

CREATE TABLE IF NOT EXISTS dw_hecho_evaluacion_desempeno (
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha         date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  empleado_id   uuid NOT NULL REFERENCES dw_dim_empleado(id),
  periodo       text,
  calificacion  numeric(4,1)
);
CREATE INDEX IF NOT EXISTS ix_dwheval_tf ON dw_hecho_evaluacion_desempeno(tenant_id, fecha);

CREATE TABLE IF NOT EXISTS dw_hecho_vacaciones (
  id                uuid PRIMARY KEY,
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha             date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  empleado_id       uuid NOT NULL REFERENCES dw_dim_empleado(id),
  dias              numeric(5,2),
  prima_vacacional  numeric(12,2),
  estado            text
);
CREATE INDEX IF NOT EXISTS ix_dwhvac_tf ON dw_hecho_vacaciones(tenant_id, fecha);

CREATE TABLE IF NOT EXISTS dw_hecho_vacante (
  id                      uuid PRIMARY KEY,
  tenant_id               uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha                   date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  puesto_id               uuid REFERENCES dw_dim_puesto(id),
  sitio_id                uuid REFERENCES dw_dim_sitio(id),
  cliente_id              uuid REFERENCES dw_dim_cliente(id),
  vacantes_cnt            int,
  estado                  text,
  dias_abierta            int,
  candidatos_postulados   int,
  candidatos_contratados  int
);
CREATE INDEX IF NOT EXISTS ix_dwhvte_tf ON dw_hecho_vacante(tenant_id, fecha);

-- ---------------------------------------------------------------------------
-- 3. RLS -- mismo patrón que el resto del DW (Migración 030)
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'dw_hecho_movimiento_empleado','dw_hecho_capacitacion','dw_hecho_evaluacion_desempeno',
    'dw_hecho_vacaciones','dw_hecho_vacante'
  ] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_sel ON %1$s', t);
    EXECUTE format('CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id())', t);
  END LOOP;
END $$;

GRANT ALL ON
  dw_hecho_movimiento_empleado, dw_hecho_capacitacion, dw_hecho_evaluacion_desempeno,
  dw_hecho_vacaciones, dw_hecho_vacante
TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. refrescar_dw_todo() ampliado -- mismas 6 dimensiones/5 hechos originales
--    (Migración 030) + dim_empleado con los campos nuevos + 5 hechos nuevos.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION refrescar_dw_todo() RETURNS jsonb AS $$
DECLARE
  n_tenant int; n_geo int; n_emp int; n_pue int; n_sit int; n_cli int;
  n_asis int; n_cob int; n_res int; n_pag int; n_fac int;
  n_mov_alta int; n_mov_baja int; n_cap int; n_eval int; n_vac int; n_vte int;
BEGIN
  INSERT INTO dw_dim_tenant (id, razon_social, vertical)
    SELECT id, razon_social, vertical FROM te_tenants
    ON CONFLICT (id) DO UPDATE SET razon_social = excluded.razon_social, vertical = excluded.vertical;
  GET DIAGNOSTICS n_tenant = ROW_COUNT;

  INSERT INTO dw_dim_geografia (tenant_id, estado_id, estado_nombre, region)
    SELECT DISTINCT s.tenant_id, e.id, e.nombre, dw_region_de_estado(e.nombre)
    FROM tc_sitios s JOIN tc_estados_mx e ON e.id = s.id_estado
    ON CONFLICT (tenant_id, estado_id) DO UPDATE SET estado_nombre = excluded.estado_nombre, region = excluded.region;
  GET DIAGNOSTICS n_geo = ROW_COUNT;

  INSERT INTO dw_dim_empleado (id, tenant_id, folio, nombre_completo, regimen_pago, tipo_empleado, activo, puesto_principal_id,
                                sexo, fecha_nacimiento, fecha_alta, fecha_baja, tipo_baja, sitio_principal_id)
    SELECT id, tenant_id, folio, trim(nombres || ' ' || apellido_paterno || ' ' || coalesce(apellido_materno, '')),
           regimen_pago, tipo_empleado, activo, id_puesto_principal,
           sexo, fecha_nacimiento, fecha_alta, fecha_baja, tipo_baja, id_sitio_principal
    FROM te_empleados
    ON CONFLICT (id) DO UPDATE SET nombre_completo = excluded.nombre_completo, activo = excluded.activo,
      regimen_pago = excluded.regimen_pago, tipo_empleado = excluded.tipo_empleado, puesto_principal_id = excluded.puesto_principal_id,
      sexo = excluded.sexo, fecha_nacimiento = excluded.fecha_nacimiento, fecha_alta = excluded.fecha_alta,
      fecha_baja = excluded.fecha_baja, tipo_baja = excluded.tipo_baja, sitio_principal_id = excluded.sitio_principal_id;
  GET DIAGNOSTICS n_emp = ROW_COUNT;

  INSERT INTO dw_dim_puesto (id, tenant_id, titulo, unidad_negocio, pago_default, regimen_pago)
    SELECT p.id, p.tenant_id, p.titulo, un.titulo, p.pago_default, p.regimen_pago
    FROM tc_puestos p LEFT JOIN tc_unidades_negocio un ON un.id = p.id_unidad_negocio
    ON CONFLICT (id) DO UPDATE SET titulo = excluded.titulo, unidad_negocio = excluded.unidad_negocio,
      pago_default = excluded.pago_default, regimen_pago = excluded.regimen_pago;
  GET DIAGNOSTICS n_pue = ROW_COUNT;

  INSERT INTO dw_dim_sitio (id, tenant_id, titulo, tipo_sitio, geografia_id, latitud, longitud, codigo_postal)
    SELECT s.id, s.tenant_id, s.titulo, s.tipo_sitio, g.id, s.latitud, s.longitud, s.codigo_postal
    FROM tc_sitios s LEFT JOIN dw_dim_geografia g ON g.tenant_id = s.tenant_id AND g.estado_id = s.id_estado
    ON CONFLICT (id) DO UPDATE SET titulo = excluded.titulo, tipo_sitio = excluded.tipo_sitio,
      geografia_id = excluded.geografia_id, latitud = excluded.latitud, longitud = excluded.longitud, codigo_postal = excluded.codigo_postal;
  GET DIAGNOSTICS n_sit = ROW_COUNT;

  INSERT INTO dw_dim_cliente (id, tenant_id, razon_social, rfc)
    SELECT id, tenant_id, razon_social, rfc FROM tc_clientes
    ON CONFLICT (id) DO UPDATE SET razon_social = excluded.razon_social, rfc = excluded.rfc;
  GET DIAGNOSTICS n_cli = ROW_COUNT;

  DELETE FROM dw_hecho_asistencia_diaria;
  INSERT INTO dw_hecho_asistencia_diaria
    (tenant_id, fecha, empleado_id, puesto_id, sitio_id, turnos_programados, turnos_asistidos,
     turnos_falta, turnos_retardo, horas_trabajadas, pct_puntualidad_promedio, penalizacion_dias, penalizacion_sueldo)
  SELECT
    r.tenant_id, r.cita_inicio::date, r.empleado_id,
    (array_agg(r.puesto_id ORDER BY r.cita_inicio))[1],
    (array_agg(r.sitio_id ORDER BY r.cita_inicio))[1],
    count(*) FILTER (WHERE r.estado NOT IN ('cancelado','disponible')),
    count(*) FILTER (WHERE r.estado_asistencia = 'asistencia'),
    count(*) FILTER (WHERE r.estado_asistencia = 'falta'),
    count(*) FILTER (WHERE r.estado_asistencia = 'retardo'),
    round(coalesce(sum(EXTRACT(epoch FROM (r.hora_salida_real - r.hora_entrada_real)) / 3600.0)
      FILTER (WHERE r.hora_entrada_real IS NOT NULL AND r.hora_salida_real IS NOT NULL), 0)::numeric, 2),
    round((avg(r.porcentaje_puntualidad) FILTER (WHERE r.porcentaje_puntualidad IS NOT NULL) * 100)::numeric, 2),
    coalesce(sum(r.penalizacion_dias), 0),
    coalesce(sum(r.penalizacion_sueldo), 0)
  FROM te_reservaciones r
  WHERE r.empleado_id IS NOT NULL AND r.cita_inicio::date BETWEEN '2020-01-01' AND '2030-12-31'
  GROUP BY r.tenant_id, r.cita_inicio::date, r.empleado_id;
  GET DIAGNOSTICS n_asis = ROW_COUNT;

  DELETE FROM dw_hecho_cobertura_sitio_dia;
  INSERT INTO dw_hecho_cobertura_sitio_dia
    (tenant_id, fecha, sitio_id, puestos_requeridos, puestos_cubiertos, puestos_confirmados, puestos_preasignados, pct_cobertura)
  SELECT
    p.tenant_id, coalesce(pd.fecha_cita, p.fecha_evento), p.sitio_id,
    sum(pd.cantidad),
    sum((SELECT count(*) FROM te_reservaciones r WHERE r.pedido_detalle_id = pd.id AND r.estado <> 'cancelado')),
    sum((SELECT count(*) FROM te_reservaciones r WHERE r.pedido_detalle_id = pd.id AND r.estado IN ('confirmado_voluntario','confirmado_opcional','forzada','procesado'))),
    sum((SELECT count(*) FROM te_reservaciones r WHERE r.pedido_detalle_id = pd.id AND r.estado = 'preasignado')),
    round((sum((SELECT count(*) FROM te_reservaciones r WHERE r.pedido_detalle_id = pd.id AND r.estado <> 'cancelado'))::numeric
           / NULLIF(sum(pd.cantidad), 0)) * 100, 2)
  FROM te_pedidos_detalle pd
  JOIN te_pedidos p ON p.id = pd.pedido_id
  WHERE coalesce(pd.fecha_cita, p.fecha_evento) BETWEEN '2020-01-01' AND '2030-12-31'
  GROUP BY p.tenant_id, coalesce(pd.fecha_cita, p.fecha_evento), p.sitio_id;
  GET DIAGNOSTICS n_cob = ROW_COUNT;

  DELETE FROM dw_hecho_reservaciones;
  INSERT INTO dw_hecho_reservaciones
    (id, tenant_id, fecha, empleado_id, puesto_id, sitio_id, estado, estado_asistencia,
     duracion_en_turnos, costo_unit, porcentaje_puntualidad, penalizacion_dias, penalizacion_sueldo)
  SELECT r.id, r.tenant_id, r.cita_inicio::date, r.empleado_id, r.puesto_id, r.sitio_id,
         r.estado, r.estado_asistencia, r.duracion_en_turnos, pd.costo_unit,
         r.porcentaje_puntualidad, r.penalizacion_dias, r.penalizacion_sueldo
  FROM te_reservaciones r
  LEFT JOIN te_pedidos_detalle pd ON pd.id = r.pedido_detalle_id
  WHERE r.cita_inicio::date BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_res = ROW_COUNT;

  DELETE FROM dw_hecho_pagos_dispersados;
  INSERT INTO dw_hecho_pagos_dispersados
    (id, tenant_id, fecha, empleado_id, monto, monto_bruto, monto_neto, penalizaciones, regimen_pago, status)
  SELECT d.id, d.tenant_id, coalesce(d.dispersado_en::date, d.creado_en::date), d.empleado_id,
         d.monto, nd.monto_bruto, nd.monto_neto, nd.penalizaciones_aplicadas, nd.regimen_pago, d.status
  FROM te_pagos_dispersion d
  LEFT JOIN te_nomina_detalle nd ON nd.id = d.nomina_detalle_id
  WHERE coalesce(d.dispersado_en::date, d.creado_en::date) BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_pag = ROW_COUNT;

  DELETE FROM dw_hecho_facturas_cliente;
  INSERT INTO dw_hecho_facturas_cliente (id, tenant_id, fecha, cliente_id, subtotal, iva, total, status)
    SELECT id, tenant_id, fecha_emision, cliente_id, subtotal, iva, total, status
    FROM te_facturas_enc
    WHERE fecha_emision BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_fac = ROW_COUNT;

  -- ---- Hechos nuevos de People Analytics (Migración 058) ----

  DELETE FROM dw_hecho_movimiento_empleado;
  INSERT INTO dw_hecho_movimiento_empleado (tenant_id, fecha, empleado_id, puesto_id, sitio_id, tipo_movimiento)
    SELECT tenant_id, fecha_alta, id, id_puesto_principal, id_sitio_principal, 'alta'
    FROM te_empleados
    WHERE fecha_alta BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_mov_alta = ROW_COUNT;

  INSERT INTO dw_hecho_movimiento_empleado (tenant_id, fecha, empleado_id, puesto_id, sitio_id, tipo_movimiento, tipo_baja, motivo_baja)
    SELECT tenant_id, fecha_baja, id, id_puesto_principal, id_sitio_principal, 'baja', tipo_baja, motivo_baja
    FROM te_empleados
    WHERE fecha_baja IS NOT NULL AND fecha_baja BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_mov_baja = ROW_COUNT;

  DELETE FROM dw_hecho_capacitacion;
  INSERT INTO dw_hecho_capacitacion (id, tenant_id, fecha, empleado_id, tipo, horas, institucion)
    SELECT id, tenant_id, fecha_inicio, empleado_id, tipo, horas, institucion
    FROM te_capacitaciones_empleado
    WHERE fecha_inicio BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_cap = ROW_COUNT;

  DELETE FROM dw_hecho_evaluacion_desempeno;
  INSERT INTO dw_hecho_evaluacion_desempeno (id, tenant_id, fecha, empleado_id, periodo, calificacion)
    SELECT id, tenant_id, fecha_evaluacion, empleado_id, periodo, calificacion
    FROM te_evaluaciones_empleado
    WHERE fecha_evaluacion BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_eval = ROW_COUNT;

  DELETE FROM dw_hecho_vacaciones;
  INSERT INTO dw_hecho_vacaciones (id, tenant_id, fecha, empleado_id, dias, prima_vacacional, estado)
    SELECT id, tenant_id, fecha_inicio, empleado_id, dias, prima_vacacional, estado
    FROM te_vacaciones_periodos
    WHERE fecha_inicio BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_vac = ROW_COUNT;

  DELETE FROM dw_hecho_vacante;
  INSERT INTO dw_hecho_vacante (id, tenant_id, fecha, puesto_id, sitio_id, cliente_id, vacantes_cnt, estado,
                                 dias_abierta, candidatos_postulados, candidatos_contratados)
    SELECT v.id, v.tenant_id, v.publicada_en::date, v.puesto_id, v.sitio_id, v.cliente_id, v.vacantes_cnt, v.estado::text,
      CASE WHEN v.cierra_en IS NOT NULL THEN (v.cierra_en::date - v.publicada_en::date) END,
      (SELECT count(*) FROM tr_postulacion_candidato_vacante p WHERE p.vacante_id = v.id),
      (SELECT count(*) FROM tr_postulacion_candidato_vacante p WHERE p.vacante_id = v.id AND p.estado = 'contratada')
    FROM te_vacantes v
    WHERE v.publicada_en IS NOT NULL AND v.publicada_en::date BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_vte = ROW_COUNT;

  RETURN jsonb_build_object(
    'refrescado_en', now(),
    'dim_tenant', n_tenant, 'dim_geografia', n_geo, 'dim_empleado', n_emp, 'dim_puesto', n_pue,
    'dim_sitio', n_sit, 'dim_cliente', n_cli,
    'hecho_asistencia_diaria', n_asis, 'hecho_cobertura_sitio_dia', n_cob, 'hecho_reservaciones', n_res,
    'hecho_pagos_dispersados', n_pag, 'hecho_facturas_cliente', n_fac,
    'hecho_movimiento_empleado', n_mov_alta + n_mov_baja, 'hecho_capacitacion', n_cap,
    'hecho_evaluacion_desempeno', n_eval, 'hecho_vacaciones', n_vac, 'hecho_vacante', n_vte
  );
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION refrescar_dw_todo() TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. Vista "snapshot" de empleados con rangos calculados (edad, antigüedad)
--    para Diversidad/Resumen -- no depende del refresh de hechos, se
--    recalcula en vivo sobre dw_dim_empleado.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_empleados_detalle AS
SELECT
  e.id, e.tenant_id, e.folio, e.nombre_completo, e.sexo, e.activo,
  e.puesto_principal_id, p.titulo AS puesto, p.unidad_negocio,
  e.sitio_principal_id, s.titulo AS sitio,
  e.fecha_nacimiento, e.fecha_alta, e.fecha_baja, e.tipo_baja,
  date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento))::int AS edad,
  CASE
    WHEN e.fecha_nacimiento IS NULL THEN NULL
    WHEN date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento)) < 20 THEN '20-'
    WHEN date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento)) < 30 THEN '20-30'
    WHEN date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento)) < 40 THEN '30-40'
    WHEN date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento)) < 50 THEN '40-50'
    WHEN date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_nacimiento)) < 60 THEN '50-60'
    ELSE '60+'
  END AS rango_edad,
  round((date_part('year', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_alta)) +
        date_part('month', age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_alta)) / 12.0)::numeric, 1) AS antiguedad_anios,
  CASE
    WHEN e.fecha_alta IS NULL THEN NULL
    WHEN age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_alta) < interval '3 years' THEN '1-3 años'
    WHEN age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_alta) < interval '5 years' THEN '3-5 años'
    WHEN age(coalesce(e.fecha_baja, CURRENT_DATE), e.fecha_alta) < interval '10 years' THEN '5-10 años'
    ELSE '10+ años'
  END AS rango_antiguedad
FROM dw_dim_empleado e
LEFT JOIN dw_dim_puesto p ON p.id = e.puesto_principal_id
LEFT JOIN dw_dim_sitio s ON s.id = e.sitio_principal_id;

-- ---------------------------------------------------------------------------
-- 6. Vistas agregadas por mes/trimestre/año -- mismo patrón que Migración 030
--    (JOIN contra dw_dim_tiempo_dia, GROUP BY tenant+periodo). Se omite el
--    corte "semana" para estos 5 hechos -- a diferencia de asistencia/
--    cobertura, el reporteo de RRHH (rotación, capacitación, desempeño,
--    vacaciones, reclutamiento) no se consume semanalmente en ningún
--    tablero de referencia revisado.
-- ---------------------------------------------------------------------------

-- Rotación: altas, bajas (voluntaria/involuntaria/sin_clasificar)
CREATE OR REPLACE VIEW v_rotacion_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) FILTER (WHERE h.tipo_movimiento = 'alta') AS altas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja') AS bajas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'voluntaria') AS bajas_voluntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'involuntaria') AS bajas_involuntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja IS NULL) AS bajas_sin_clasificar
FROM dw_hecho_movimiento_empleado h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_rotacion_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) FILTER (WHERE h.tipo_movimiento = 'alta') AS altas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja') AS bajas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'voluntaria') AS bajas_voluntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'involuntaria') AS bajas_involuntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja IS NULL) AS bajas_sin_clasificar
FROM dw_hecho_movimiento_empleado h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_rotacion_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) FILTER (WHERE h.tipo_movimiento = 'alta') AS altas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja') AS bajas,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'voluntaria') AS bajas_voluntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja = 'involuntaria') AS bajas_involuntarias,
  count(*) FILTER (WHERE h.tipo_movimiento = 'baja' AND h.tipo_baja IS NULL) AS bajas_sin_clasificar
FROM dw_hecho_movimiento_empleado h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio;

-- Capacitación
CREATE OR REPLACE VIEW v_capacitacion_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) AS capacitaciones, count(DISTINCT h.empleado_id) AS empleados_capacitados,
  sum(h.horas) AS horas_totales, round(avg(h.horas), 2) AS horas_promedio
FROM dw_hecho_capacitacion h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_capacitacion_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) AS capacitaciones, count(DISTINCT h.empleado_id) AS empleados_capacitados,
  sum(h.horas) AS horas_totales, round(avg(h.horas), 2) AS horas_promedio
FROM dw_hecho_capacitacion h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_capacitacion_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) AS capacitaciones, count(DISTINCT h.empleado_id) AS empleados_capacitados,
  sum(h.horas) AS horas_totales, round(avg(h.horas), 2) AS horas_promedio
FROM dw_hecho_capacitacion h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio;

-- Desempeño
CREATE OR REPLACE VIEW v_desempeno_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) AS evaluaciones, count(DISTINCT h.empleado_id) AS empleados_evaluados,
  round(avg(h.calificacion), 2) AS calificacion_promedio
FROM dw_hecho_evaluacion_desempeno h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_desempeno_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) AS evaluaciones, count(DISTINCT h.empleado_id) AS empleados_evaluados,
  round(avg(h.calificacion), 2) AS calificacion_promedio
FROM dw_hecho_evaluacion_desempeno h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_desempeno_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) AS evaluaciones, count(DISTINCT h.empleado_id) AS empleados_evaluados,
  round(avg(h.calificacion), 2) AS calificacion_promedio
FROM dw_hecho_evaluacion_desempeno h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio;

-- Vacaciones
CREATE OR REPLACE VIEW v_vacaciones_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) AS periodos_tomados, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales, sum(h.prima_vacacional) AS prima_total
FROM dw_hecho_vacaciones h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelada'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_vacaciones_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) AS periodos_tomados, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales, sum(h.prima_vacacional) AS prima_total
FROM dw_hecho_vacaciones h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelada'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_vacaciones_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) AS periodos_tomados, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales, sum(h.prima_vacacional) AS prima_total
FROM dw_hecho_vacaciones h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelada'
GROUP BY h.tenant_id, dt.anio;

-- Reclutamiento (grano: vacante publicada en el periodo)
CREATE OR REPLACE VIEW v_reclutamiento_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) AS vacantes_publicadas, sum(h.vacantes_cnt) AS plazas_solicitadas,
  count(*) FILTER (WHERE h.estado = 'cerrada') AS vacantes_cerradas,
  round(avg(h.dias_abierta) FILTER (WHERE h.dias_abierta IS NOT NULL), 1) AS dias_promedio_para_cubrir,
  sum(h.candidatos_postulados) AS candidatos_postulados, sum(h.candidatos_contratados) AS candidatos_contratados
FROM dw_hecho_vacante h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_reclutamiento_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) AS vacantes_publicadas, sum(h.vacantes_cnt) AS plazas_solicitadas,
  count(*) FILTER (WHERE h.estado = 'cerrada') AS vacantes_cerradas,
  round(avg(h.dias_abierta) FILTER (WHERE h.dias_abierta IS NOT NULL), 1) AS dias_promedio_para_cubrir,
  sum(h.candidatos_postulados) AS candidatos_postulados, sum(h.candidatos_contratados) AS candidatos_contratados
FROM dw_hecho_vacante h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_reclutamiento_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) AS vacantes_publicadas, sum(h.vacantes_cnt) AS plazas_solicitadas,
  count(*) FILTER (WHERE h.estado = 'cerrada') AS vacantes_cerradas,
  round(avg(h.dias_abierta) FILTER (WHERE h.dias_abierta IS NOT NULL), 1) AS dias_promedio_para_cubrir,
  sum(h.candidatos_postulados) AS candidatos_postulados, sum(h.candidatos_contratados) AS candidatos_contratados
FROM dw_hecho_vacante h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
GROUP BY h.tenant_id, dt.anio;

GRANT SELECT ON
  v_empleados_detalle,
  v_rotacion_por_mes, v_rotacion_por_trimestre, v_rotacion_por_anio,
  v_capacitacion_por_mes, v_capacitacion_por_trimestre, v_capacitacion_por_anio,
  v_desempeno_por_mes, v_desempeno_por_trimestre, v_desempeno_por_anio,
  v_vacaciones_por_mes, v_vacaciones_por_trimestre, v_vacaciones_por_anio,
  v_reclutamiento_por_mes, v_reclutamiento_por_trimestre, v_reclutamiento_por_anio
TO anon, authenticated, service_role;
