-- ============================================================================
-- Migración 060 — People Analytics Fase 2b: costo real de nómina vía el
-- tabulador matricial, cableado al "margen por puesto" del Data Warehouse.
-- Pendiente documentado en CLAUDE.md §11: "margen por puesto" usaba
-- `tc_puestos.pago_default` como costo aproximado para TODOS los puestos,
-- incluso los matriciales (Shows Sueltos/Semana/Mes), que se tarifan por
-- `tp_sueldos_matriciales`, no por un pago fijo por turno.
--
-- `calcular_importe_matricial_reservacion(reservacion_id)` YA EXISTÍA en la
-- base real (sesión anterior, nunca documentada ni appendeada a este archivo
-- -- gap real confirmado por grep, cero resultados antes de esta migración).
-- Investigada en vivo (pg_get_functiondef) antes de usarla, no se adivinó su
-- comportamiento: hace fallback a NULL en cada paso si falta cualquier dato
-- (puesto no matricial, sin complejidad, sin tipo de duración que matchee,
-- sin fila vigente en tp_sueldos_matriciales) -- por eso el patrón
-- `coalesce(matricial, aproximado)` de abajo es seguro y no rompe nada para
-- puestos no matriciales. Se backfillea su definición aquí porque no estaba
-- en este archivo (mismo gap que ya documenta CLAUDE.md §11bis para 039-057;
-- esta es la primera función de ese rango que se recupera y se deja fija).
--
-- Ambigüedad real sin resolver (ver CLAUDE.md §11, "sigue pendiente" d):
-- `tp_duraciones_evento` para "Tarifa por Semana"/"Tarifa por Mes" con
-- prorrateo -- la función ya decide eso por su cuenta (suma día a día), este
-- bloque NO toca esa lógica, solo consume el resultado.
-- ============================================================================

CREATE OR REPLACE FUNCTION calcular_importe_matricial_reservacion(p_reservacion_id uuid)
RETURNS numeric
LANGUAGE plpgsql
STABLE
AS $function$
declare
  v_puesto_id uuid;
  v_turnos numeric;
  v_duracion_dias int;
  v_tipo_complejidad_id uuid;
  v_tipo_duracion_id uuid;
  v_factor_dias numeric;
  v_sueldo_base numeric;
  v_factor numeric;
begin
  select coalesce(r.puesto_id, d.puesto_id),
         coalesce(r.duracion_en_turnos, d.turnos),
         p.duracion_dias,
         p.tipo_complejidad_id
  into v_puesto_id, v_turnos, v_duracion_dias, v_tipo_complejidad_id
  from te_reservaciones r
  join te_pedidos_detalle d on d.id = r.pedido_detalle_id
  join te_pedidos p on p.id = d.pedido_id
  where r.id = p_reservacion_id;

  if v_puesto_id is null or v_tipo_complejidad_id is null or v_duracion_dias is null then
    return null;
  end if;

  select c.id into v_tipo_duracion_id
  from tc_tipos_duracion_evento c
  where v_duracion_dias between c.dias_minimos and c.dias_maximos
    and c.activo
  limit 1;

  if v_tipo_duracion_id is null then
    return null;
  end if;

  select sum(dv.factor_sueldo) into v_factor_dias
  from generate_series(1, v_duracion_dias) as dia
  join tp_duraciones_evento dv
    on dv.tipo_duracion_id = v_tipo_duracion_id
   and dia between dv.dias_desde and dv.dias_hasta;

  if v_factor_dias is null then
    return null;
  end if;

  select s.sueldo_base, s.factor into v_sueldo_base, v_factor
  from tp_sueldos_matriciales s
  where s.puesto_id = v_puesto_id
    and s.tipo_complejidad_id = v_tipo_complejidad_id
    and s.tipo_duracion_id = v_tipo_duracion_id
    and s.activo
    and current_date >= s.vigente_desde
    and (s.vigente_hasta is null or current_date <= s.vigente_hasta)
  order by s.vigente_desde desc
  limit 1;

  if v_sueldo_base is null then
    return null;
  end if;

  return round(v_sueldo_base * v_factor * v_factor_dias * coalesce(v_turnos, 1), 2);
end;
$function$;

-- ---------------------------------------------------------------------------
-- dw_hecho_reservaciones: nueva columna con el costo real matricial (NULL
-- cuando no aplica -- ver arriba).
-- ---------------------------------------------------------------------------
ALTER TABLE dw_hecho_reservaciones ADD COLUMN IF NOT EXISTS costo_matricial numeric;

-- ---------------------------------------------------------------------------
-- refrescar_dw_todo() -- se reescribe completa otra vez (Migración 030 +
-- 058 + 059) agregando `calcular_importe_matricial_reservacion(r.id)` al
-- INSERT de dw_hecho_reservaciones.
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
     duracion_en_turnos, costo_unit, porcentaje_puntualidad, penalizacion_dias, penalizacion_sueldo, costo_matricial)
  SELECT r.id, r.tenant_id, r.cita_inicio::date, r.empleado_id, r.puesto_id, r.sitio_id,
         r.estado, r.estado_asistencia, r.duracion_en_turnos, pd.costo_unit,
         r.porcentaje_puntualidad, r.penalizacion_dias, r.penalizacion_sueldo,
         calcular_importe_matricial_reservacion(r.id)
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
-- v_margen_por_puesto_* (4 vistas, Migración 030): costo_total ahora prefiere
-- el importe real del tabulador matricial (`costo_matricial`) y solo cae a
-- la aproximación `pago_default × turnos` cuando la función devolvió NULL
-- (puesto no matricial, o matricial sin fila vigente para esa complejidad/
-- duración -- gap real ya documentado en CLAUDE.md §11, no resuelto aquí).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_margen_por_puesto_semana AS
SELECT h.tenant_id, dt.anio_iso AS anio, dt.etiqueta_semana AS periodo, h.puesto_id, p.titulo AS puesto,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos) AS ingreso_total,
  sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS costo_total,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos)
    - sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS margen_total
FROM dw_hecho_reservaciones h
JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
LEFT JOIN dw_dim_puesto p ON p.id = h.puesto_id
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio_iso, dt.etiqueta_semana, h.puesto_id, p.titulo;

CREATE OR REPLACE VIEW v_margen_por_puesto_mes AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_mes AS periodo, h.puesto_id, p.titulo AS puesto,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos) AS ingreso_total,
  sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS costo_total,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos)
    - sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS margen_total
FROM dw_hecho_reservaciones h
JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
LEFT JOIN dw_dim_puesto p ON p.id = h.puesto_id
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_mes, h.puesto_id, p.titulo;

CREATE OR REPLACE VIEW v_margen_por_puesto_trimestre AS
SELECT h.tenant_id, dt.anio, dt.etiqueta_trimestre AS periodo, h.puesto_id, p.titulo AS puesto,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos) AS ingreso_total,
  sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS costo_total,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos)
    - sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS margen_total
FROM dw_hecho_reservaciones h
JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
LEFT JOIN dw_dim_puesto p ON p.id = h.puesto_id
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio, dt.etiqueta_trimestre, h.puesto_id, p.titulo;

CREATE OR REPLACE VIEW v_margen_por_puesto_anio AS
SELECT h.tenant_id, dt.anio, dt.anio::text AS periodo, h.puesto_id, p.titulo AS puesto,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos) AS ingreso_total,
  sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS costo_total,
  sum(coalesce(h.costo_unit, 0) * h.duracion_en_turnos)
    - sum(coalesce(h.costo_matricial, coalesce(p.pago_default, 0) * h.duracion_en_turnos)) AS margen_total
FROM dw_hecho_reservaciones h
JOIN dw_dim_tiempo_dia dt ON dt.fecha = h.fecha
LEFT JOIN dw_dim_puesto p ON p.id = h.puesto_id
WHERE h.estado <> 'cancelado'
GROUP BY h.tenant_id, dt.anio, h.puesto_id, p.titulo;
