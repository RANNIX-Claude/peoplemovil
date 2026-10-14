-- ============================================================================
-- Migración 059 — People Analytics Fase 2a: ausentismo granular (permisos e
-- incapacidades, hoy solo existían vacaciones -- te_vacaciones_periodos). Sin
-- precedente en el legado OCESA, mismo patrón deliberado que D14 (vacaciones/
-- capacitación/evaluaciones/beneficios): se alinea a categorías reales de la
-- LFT/IMSS (enfermedad general, maternidad, riesgo de trabajo, permiso con/
-- sin goce), no se inventa nada fuera de esas categorías estándar.
--
-- Incluye: tabla operativa + captura en ExpedienteEmpleado.jsx (tab nueva
-- "Permisos/Incapecidades", ya implementada en el frontend) + hecho nuevo en
-- el Data Warehouse + vistas por mes/trimestre/año, mismo patrón que la
-- Migración 058.
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE tipo_permiso_enum AS ENUM (
    'incapacidad_enfermedad_general', 'incapacidad_maternidad', 'incapacidad_riesgo_trabajo',
    'permiso_con_goce', 'permiso_sin_goce', 'otro'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE estado_permiso_enum AS ENUM ('solicitado', 'autorizado', 'rechazado', 'cancelado');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS te_permisos_empleado (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id     uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  tipo            tipo_permiso_enum NOT NULL,
  fecha_inicio    date NOT NULL,
  fecha_fin       date NOT NULL,
  dias            numeric(5,2) NOT NULL CHECK (dias > 0),
  goce_sueldo     boolean NOT NULL DEFAULT true,
  folio_imss      text,
  autorizado_por  uuid REFERENCES te_usuarios(id),
  estado          estado_permiso_enum NOT NULL DEFAULT 'solicitado',
  observaciones   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (fecha_fin >= fecha_inicio)
);
CREATE INDEX IF NOT EXISTS ix_permemp_emp ON te_permisos_empleado(tenant_id, empleado_id, fecha_inicio);
DROP TRIGGER IF EXISTS tg_aud_permemp ON te_permisos_empleado;
CREATE TRIGGER tg_aud_permemp BEFORE INSERT OR UPDATE ON te_permisos_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

ALTER TABLE te_permisos_empleado ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_te_permisos_empleado_sel ON te_permisos_empleado;
DROP POLICY IF EXISTS p_te_permisos_empleado_ins ON te_permisos_empleado;
DROP POLICY IF EXISTS p_te_permisos_empleado_upd ON te_permisos_empleado;
DROP POLICY IF EXISTS p_te_permisos_empleado_del ON te_permisos_empleado;
CREATE POLICY p_te_permisos_empleado_sel ON te_permisos_empleado FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_permisos_empleado_ins ON te_permisos_empleado FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY p_te_permisos_empleado_upd ON te_permisos_empleado FOR UPDATE USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_permisos_empleado_del ON te_permisos_empleado FOR DELETE USING (tenant_id = current_tenant_id());

-- ---------------------------------------------------------------------------
-- Data Warehouse: nuevo hecho + RLS + grant, igual patrón que Migración 058.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw_hecho_permisos (
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  fecha         date NOT NULL REFERENCES dw_dim_tiempo_dia(fecha),
  empleado_id   uuid NOT NULL REFERENCES dw_dim_empleado(id),
  tipo          text,
  dias          numeric(5,2),
  goce_sueldo   boolean,
  estado        text
);
CREATE INDEX IF NOT EXISTS ix_dwhperm_tf ON dw_hecho_permisos(tenant_id, fecha);

ALTER TABLE dw_hecho_permisos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_dw_hecho_permisos_sel ON dw_hecho_permisos;
CREATE POLICY p_dw_hecho_permisos_sel ON dw_hecho_permisos FOR SELECT USING (tenant_id = current_tenant_id());
GRANT ALL ON dw_hecho_permisos TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- refrescar_dw_todo() ampliada otra vez -- se reescribe completa (incluye
-- todo lo de la Migración 030 + Migración 058) agregando el DELETE+INSERT de
-- dw_hecho_permisos al final.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION refrescar_dw_todo() RETURNS jsonb AS $$
DECLARE
  n_tenant int; n_geo int; n_emp int; n_pue int; n_sit int; n_cli int;
  n_asis int; n_cob int; n_res int; n_pag int; n_fac int;
  n_mov_alta int; n_mov_baja int; n_cap int; n_eval int; n_vac int; n_vte int; n_perm int;
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

  -- ---- Hecho nuevo de Fase 2a (Migración 059) ----
  DELETE FROM dw_hecho_permisos;
  INSERT INTO dw_hecho_permisos (id, tenant_id, fecha, empleado_id, tipo, dias, goce_sueldo, estado)
    SELECT id, tenant_id, fecha_inicio, empleado_id, tipo::text, dias, goce_sueldo, estado::text
    FROM te_permisos_empleado
    WHERE fecha_inicio BETWEEN '2020-01-01' AND '2030-12-31';
  GET DIAGNOSTICS n_perm = ROW_COUNT;

  RETURN jsonb_build_object(
    'refrescado_en', now(),
    'dim_tenant', n_tenant, 'dim_geografia', n_geo, 'dim_empleado', n_emp, 'dim_puesto', n_pue,
    'dim_sitio', n_sit, 'dim_cliente', n_cli,
    'hecho_asistencia_diaria', n_asis, 'hecho_cobertura_sitio_dia', n_cob, 'hecho_reservaciones', n_res,
    'hecho_pagos_dispersados', n_pag, 'hecho_facturas_cliente', n_fac,
    'hecho_movimiento_empleado', n_mov_alta + n_mov_baja, 'hecho_capacitacion', n_cap,
    'hecho_evaluacion_desempeno', n_eval, 'hecho_vacaciones', n_vac, 'hecho_vacante', n_vte,
    'hecho_permisos', n_perm
  );
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION refrescar_dw_todo() TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Vistas por mes/trimestre/año. "Ausentismo" aquí es permisos+incapacidades
-- NO-vacacionales -- las vacaciones ya tienen su propia familia de vistas
-- (v_vacaciones_por_*, Migración 058) y conceptualmente no son "ausentismo"
-- en el sentido de interrupción no planeada del trabajo.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ausentismo_por_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo,
  count(*) AS permisos, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales,
  sum(h.dias) FILTER (WHERE h.tipo LIKE 'incapacidad%') AS dias_incapacidad,
  sum(h.dias) FILTER (WHERE h.tipo IN ('permiso_con_goce','permiso_sin_goce')) AS dias_permiso,
  sum(h.dias) FILTER (WHERE NOT h.goce_sueldo) AS dias_sin_goce
FROM dw_hecho_permisos h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes;

CREATE OR REPLACE VIEW v_ausentismo_por_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo,
  count(*) AS permisos, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales,
  sum(h.dias) FILTER (WHERE h.tipo LIKE 'incapacidad%') AS dias_incapacidad,
  sum(h.dias) FILTER (WHERE h.tipo IN ('permiso_con_goce','permiso_sin_goce')) AS dias_permiso,
  sum(h.dias) FILTER (WHERE NOT h.goce_sueldo) AS dias_sin_goce
FROM dw_hecho_permisos h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre;

CREATE OR REPLACE VIEW v_ausentismo_por_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo,
  count(*) AS permisos, count(DISTINCT h.empleado_id) AS empleados,
  sum(h.dias) AS dias_totales,
  sum(h.dias) FILTER (WHERE h.tipo LIKE 'incapacidad%') AS dias_incapacidad,
  sum(h.dias) FILTER (WHERE h.tipo IN ('permiso_con_goce','permiso_sin_goce')) AS dias_permiso,
  sum(h.dias) FILTER (WHERE NOT h.goce_sueldo) AS dias_sin_goce
FROM dw_hecho_permisos h JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio;

GRANT SELECT ON v_ausentismo_por_mes, v_ausentismo_por_trimestre, v_ausentismo_por_anio TO anon, authenticated, service_role;
