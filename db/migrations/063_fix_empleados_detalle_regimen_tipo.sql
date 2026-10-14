-- ============================================================================
-- Migración 063 — Fix: v_empleados_detalle (Migración 058) no exponía
-- `regimen_pago`/`tipo_empleado`, aunque ambas columnas ya existían en
-- dw_dim_empleado desde la Migración 030 -- se omitieron por descuido al
-- escribir el SELECT de la vista. Encontrado al probar en vivo el tablero
-- "Resumen" de People Analytics (Fase 3): "Headcount por tipo de contrato"
-- mostraba todo en "Sin dato". Se re-crea con `security_invoker = true`
-- (Migración 062) para no perder el fix de seguridad al reemplazar la vista.
-- ============================================================================
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
  END AS rango_antiguedad,
  e.regimen_pago, e.tipo_empleado
FROM dw_dim_empleado e
LEFT JOIN dw_dim_puesto p ON p.id = e.puesto_principal_id
LEFT JOIN dw_dim_sitio s ON s.id = e.sitio_principal_id;

ALTER VIEW v_empleados_detalle SET (security_invoker = true);
GRANT SELECT ON v_empleados_detalle TO anon, authenticated, service_role;
