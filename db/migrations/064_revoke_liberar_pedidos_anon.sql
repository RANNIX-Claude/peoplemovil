-- ============================================================================
-- Migración 064 — Fix menor de seguridad: liberar_pedidos_programados()
-- (SECURITY DEFINER, pensada para correr solo vía pg_cron) tenía EXECUTE
-- otorgado también a `anon` y `authenticated` -- cualquier visitante sin
-- sesión podía dispararla manualmente vía POST /rest/v1/rpc/... No expone
-- datos (solo regresa un contador) y no viola su propia regla de negocio
-- (libera únicamente lo que ya cumplió fecha_liberacion <= now()), pero no
-- debería ser invocable por nadie fuera del cron. Encontrado al auditar, a
-- pedido del usuario, el resto de funciones SECURITY DEFINER tras el fix de
-- la Migración 062.
-- ============================================================================
-- REVOKE ... FROM anon, authenticated no bastó: Postgres otorga EXECUTE a
-- PUBLIC por default en funciones nuevas, y anon/authenticated heredan ese
-- grant implícito aunque nunca se les haya otorgado a ellos directamente --
-- confirmado con has_function_privilege() antes y después del fix.
REVOKE EXECUTE ON FUNCTION liberar_pedidos_programados() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION liberar_pedidos_programados() TO postgres, service_role;
