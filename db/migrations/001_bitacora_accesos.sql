-- ============================================================================
-- Migración 001 — Bitácora de accesos + RPC log_bitacora
-- Aplicable en Supabase existente sin tocar las 54 tablas.
-- ============================================================================

CREATE TABLE IF NOT EXISTS te_bitacora_accesos (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  ts_servidor  timestamptz NOT NULL DEFAULT now(),
  actor_id     uuid,
  modulo       text NOT NULL,
  accion       text NOT NULL,
  detalle      text
);
CREATE INDEX IF NOT EXISTS ix_bitacora_tenant_ts ON te_bitacora_accesos(tenant_id, ts_servidor DESC);
CREATE INDEX IF NOT EXISTS ix_bitacora_modulo    ON te_bitacora_accesos(tenant_id, modulo);

-- Append-only: bloquear UPDATE/DELETE
DROP TRIGGER IF EXISTS tg_bit_ac_no_mut ON te_bitacora_accesos;
CREATE TRIGGER tg_bit_ac_no_mut BEFORE UPDATE OR DELETE ON te_bitacora_accesos
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- RLS
ALTER TABLE te_bitacora_accesos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_te_bitacora_accesos_sel ON te_bitacora_accesos;
DROP POLICY IF EXISTS p_te_bitacora_accesos_ins ON te_bitacora_accesos;
CREATE POLICY p_te_bitacora_accesos_sel ON te_bitacora_accesos
  FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_bitacora_accesos_ins ON te_bitacora_accesos
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());

-- Grants Supabase
GRANT ALL ON te_bitacora_accesos TO anon, authenticated, service_role;

-- RPC: log_bitacora — llamable desde frontend, respeta RLS.
-- Fuerza tenant_id, ts_servidor y actor_id desde el server.
CREATE OR REPLACE FUNCTION log_bitacora(p_modulo text, p_accion text, p_detalle text DEFAULT NULL)
RETURNS uuid AS $$
DECLARE nid uuid; t uuid;
BEGIN
  t := current_tenant_id();
  IF t IS NULL THEN
    RAISE EXCEPTION 'sin tenant activo — el header x-tenant-id no vino en la request';
  END IF;
  INSERT INTO te_bitacora_accesos (tenant_id, actor_id, modulo, accion, detalle)
  VALUES (t, current_user_id(), p_modulo, p_accion, p_detalle)
  RETURNING id INTO nid;
  RETURN nid;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION log_bitacora(text, text, text) TO anon, authenticated;
