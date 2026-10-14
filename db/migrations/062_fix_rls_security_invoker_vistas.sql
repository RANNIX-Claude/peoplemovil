-- ============================================================================
-- Migración 062 — FIX DE SEGURIDAD CRÍTICO: fuga de datos entre tenants a
-- través de TODAS las vistas analíticas (`v_*`), confirmada en vivo 2026-10-14
-- al construir el tablero "Resumen" de People Analytics: el Headcount
-- mostraba 184 (los 4 tenants juntos) en vez de 93 (solo el tenant real de
-- la sesión, "eventos"), usando la cuenta real `admin.demo01`.
--
-- Causa raíz confirmada (no supuesta -- investigada con pg_class/pg_roles
-- antes de escribir el fix): en PostgreSQL, una vista SIN `security_invoker`
-- (default hasta PG14, sigue siendo el default en PG15+ salvo que se pida
-- explícito) evalúa el acceso a sus tablas base usando los privilegios del
-- DUEÑO de la vista, no de quien la consulta. Las 51 vistas `v_*` de este
-- proyecto son propiedad de `postgres` (se crearon todas vía apply_migration/
-- Management API), y el rol `postgres` tiene `rolbypassrls = true` -- por lo
-- tanto, CUALQUIER vista que dependa de la RLS implícita de su tabla base
-- (`dw_hecho_*`/`dw_dim_*` con política `tenant_id = current_tenant_id()`,
-- sin filtro propio en la vista) nunca aplicaba esa política en absoluto,
-- sin importar qué tenant real estuviera conectado -- exponía TODOS los
-- tenants a CUALQUIER usuario autenticado desde que existe el Data Warehouse
-- (Migración 030, 2026-10-10). No es un bug nuevo de esta sesión: estaba
-- presente desde el origen del DW, nunca se había notado porque ninguna
-- verificación anterior comparó el conteo mostrado contra el conteo real
-- por tenant (las pruebas de login documentadas en CLAUDE.md §15 probaron
-- las pantallas OPERATIVAS, que consultan tablas base directo vía PostgREST
-- -- ahí la RLS sí corre con el rol real de la sesión, nunca con el dueño
-- de una vista -- no el Data Warehouse).
--
-- Confirmado que las vistas del portal freelance (`v_publicaciones_para_
-- freelance`, `v_agenda_freelance`, `v_vacantes_publicas`, `v_grupos_citas_
-- disponibles`) NO estaban afectadas: su propio cuerpo llama a
-- `mi_empleado_id()`/filtra explícito, no dependen de la RLS implícita de la
-- tabla base -- se les aplica el mismo fix de todos modos, sin cambiar su
-- comportamiento, por consistencia y defensa en profundidad.
--
-- Fix: `ALTER VIEW ... SET (security_invoker = true)` (Postgres 15+, este
-- proyecto corre 17.6) en las 51 vistas del esquema `public` -- hace que
-- cada vista evalúe el acceso a sus tablas base con los privilegios de QUIEN
-- la consulta, no del dueño, por lo que la RLS de las tablas base
-- (`tenant_id = current_tenant_id()`) vuelve a aplicar siempre.
--
-- Verificado tras aplicar (ver CLAUDE.md §7 fila 062 para el detalle): el
-- mismo Headcount pasó de 184 a 93 con la misma sesión `admin.demo01`, sin
-- tocar ninguna definición de vista.
-- ============================================================================

ALTER VIEW v_agenda_freelance SET (security_invoker = true);
ALTER VIEW v_asistencia_por_anio SET (security_invoker = true);
ALTER VIEW v_asistencia_por_mes SET (security_invoker = true);
ALTER VIEW v_asistencia_por_semana SET (security_invoker = true);
ALTER VIEW v_asistencia_por_trimestre SET (security_invoker = true);
ALTER VIEW v_ausentismo_por_anio SET (security_invoker = true);
ALTER VIEW v_ausentismo_por_mes SET (security_invoker = true);
ALTER VIEW v_ausentismo_por_trimestre SET (security_invoker = true);
ALTER VIEW v_capacitacion_por_anio SET (security_invoker = true);
ALTER VIEW v_capacitacion_por_mes SET (security_invoker = true);
ALTER VIEW v_capacitacion_por_trimestre SET (security_invoker = true);
ALTER VIEW v_cobertura_por_sitio_anio SET (security_invoker = true);
ALTER VIEW v_cobertura_por_sitio_mes SET (security_invoker = true);
ALTER VIEW v_cobertura_por_sitio_semana SET (security_invoker = true);
ALTER VIEW v_cobertura_por_sitio_trimestre SET (security_invoker = true);
ALTER VIEW v_desempeno_por_anio SET (security_invoker = true);
ALTER VIEW v_desempeno_por_mes SET (security_invoker = true);
ALTER VIEW v_desempeno_por_trimestre SET (security_invoker = true);
ALTER VIEW v_empleados_detalle SET (security_invoker = true);
ALTER VIEW v_facturas_por_cliente_anio SET (security_invoker = true);
ALTER VIEW v_facturas_por_cliente_mes SET (security_invoker = true);
ALTER VIEW v_facturas_por_cliente_semana SET (security_invoker = true);
ALTER VIEW v_facturas_por_cliente_trimestre SET (security_invoker = true);
ALTER VIEW v_grupos_citas_disponibles SET (security_invoker = true);
ALTER VIEW v_margen_por_puesto_anio SET (security_invoker = true);
ALTER VIEW v_margen_por_puesto_mes SET (security_invoker = true);
ALTER VIEW v_margen_por_puesto_semana SET (security_invoker = true);
ALTER VIEW v_margen_por_puesto_trimestre SET (security_invoker = true);
ALTER VIEW v_pagos_honorarios SET (security_invoker = true);
ALTER VIEW v_pagos_por_regimen_anio SET (security_invoker = true);
ALTER VIEW v_pagos_por_regimen_mes SET (security_invoker = true);
ALTER VIEW v_pagos_por_regimen_semana SET (security_invoker = true);
ALTER VIEW v_pagos_por_regimen_trimestre SET (security_invoker = true);
ALTER VIEW v_publicaciones_para_freelance SET (security_invoker = true);
ALTER VIEW v_reclutamiento_por_anio SET (security_invoker = true);
ALTER VIEW v_reclutamiento_por_mes SET (security_invoker = true);
ALTER VIEW v_reclutamiento_por_trimestre SET (security_invoker = true);
ALTER VIEW v_reservaciones_sueldo_plaza SET (security_invoker = true);
ALTER VIEW v_riesgo_rotacion_empleado SET (security_invoker = true);
ALTER VIEW v_rotacion_por_anio SET (security_invoker = true);
ALTER VIEW v_rotacion_por_mes SET (security_invoker = true);
ALTER VIEW v_rotacion_por_trimestre SET (security_invoker = true);
ALTER VIEW v_top_empleados_puntualidad SET (security_invoker = true);
ALTER VIEW v_top_empleados_puntualidad_anio SET (security_invoker = true);
ALTER VIEW v_top_empleados_puntualidad_semana SET (security_invoker = true);
ALTER VIEW v_top_empleados_puntualidad_trimestre SET (security_invoker = true);
ALTER VIEW v_vacaciones_por_anio SET (security_invoker = true);
ALTER VIEW v_vacaciones_por_mes SET (security_invoker = true);
ALTER VIEW v_vacaciones_por_trimestre SET (security_invoker = true);
ALTER VIEW v_vacantes_publicas SET (security_invoker = true);
