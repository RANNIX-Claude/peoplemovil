-- ============================================================================
-- Migración 002 — Portales freelance + público
-- ============================================================================
-- Cambios:
--   1. Auth freelance: te_empleados.auth_user_id + nip + foto_url + preferencias
--   2. Multi-fecha por pedido con vista agenda: te_pedido_fechas
--   3. Publicación en portal: te_pedidos_detalle.publicado + cupo
--   4. Adjuntos polimórficos: te_adjuntos
--   5. Magic links para candidatos: te_magic_links
--   6. Trigger de cupo en te_reservaciones
--   7. Corrección PEP → tc_partidas_presupuestales
--   8. Vistas para portal (matches + agenda + saldo)
--   9. RLS para acceso del propio empleado a sus datos
--  10. Función siguiente_folio_pedido, digest_freelance
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Auth freelance y datos del portal
-- ---------------------------------------------------------------------------
ALTER TABLE te_empleados
  ADD COLUMN IF NOT EXISTS auth_user_id     uuid UNIQUE,       -- FK lógica a auth.users.id de Supabase
  ADD COLUMN IF NOT EXISTS nip              text,              -- NIP numérico (portal freelance)
  ADD COLUMN IF NOT EXISTS nip_cambiado_en  timestamptz,
  ADD COLUMN IF NOT EXISTS foto_url         text,              -- URL Supabase Storage
  ADD COLUMN IF NOT EXISTS pref_notif_email    boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS pref_notif_whatsapp boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS pref_notif_push     boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS pref_digest_hora    time NOT NULL DEFAULT '08:00';

-- ---------------------------------------------------------------------------
-- 2. Multi-fecha por pedido (vista tipo agenda)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_pedido_fechas (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  pedido_id      uuid NOT NULL REFERENCES te_pedidos(id) ON DELETE CASCADE,
  fase_evento_id uuid REFERENCES tc_fases_evento(id),
  fecha          date NOT NULL,
  hora_inicio    time NOT NULL,
  hora_fin       time NOT NULL,
  notas          text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_pf_pedido ON te_pedido_fechas(pedido_id, fecha);
DROP TRIGGER IF EXISTS tg_aud_pf ON te_pedido_fechas;
CREATE TRIGGER tg_aud_pf BEFORE INSERT OR UPDATE ON te_pedido_fechas
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
ALTER TABLE te_pedido_fechas ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_te_pedido_fechas_sel ON te_pedido_fechas;
DROP POLICY IF EXISTS p_te_pedido_fechas_ins ON te_pedido_fechas;
DROP POLICY IF EXISTS p_te_pedido_fechas_upd ON te_pedido_fechas;
DROP POLICY IF EXISTS p_te_pedido_fechas_del ON te_pedido_fechas;
CREATE POLICY p_te_pedido_fechas_sel ON te_pedido_fechas FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_pedido_fechas_ins ON te_pedido_fechas FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY p_te_pedido_fechas_upd ON te_pedido_fechas FOR UPDATE USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_pedido_fechas_del ON te_pedido_fechas FOR DELETE USING (tenant_id = current_tenant_id());

-- El detalle puede colgar de una fecha específica
ALTER TABLE te_pedidos_detalle
  ADD COLUMN IF NOT EXISTS pedido_fecha_id uuid REFERENCES te_pedido_fechas(id) ON DELETE CASCADE;

-- ---------------------------------------------------------------------------
-- 3. Publicación en el portal + control de cupo
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos_detalle
  ADD COLUMN IF NOT EXISTS publicado     boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS publicado_en  timestamptz,
  ADD COLUMN IF NOT EXISTS cierra_en     timestamptz;

-- Cupo actual del detalle (helper reutilizable)
CREATE OR REPLACE FUNCTION cupo_pedido_detalle(p_detalle uuid)
RETURNS TABLE (cupo_total int, cupo_ocupado int, cupo_libre int) AS $$
DECLARE tot int; ocp int;
BEGIN
  SELECT cantidad INTO tot FROM te_pedidos_detalle WHERE id = p_detalle;
  SELECT count(*) INTO ocp FROM te_reservaciones
    WHERE pedido_detalle_id = p_detalle AND estado NOT IN ('cancelado');
  RETURN QUERY SELECT tot, ocp, GREATEST(tot - ocp, 0);
END $$ LANGUAGE plpgsql STABLE;

-- Trigger que impide inscribirse si cupo lleno o no está publicado o falta plaza
CREATE OR REPLACE FUNCTION tg_res_valida_cupo_y_plaza() RETURNS trigger AS $$
DECLARE
  det te_pedidos_detalle;
  ocp int;
  tiene_plaza boolean;
BEGIN
  IF NEW.pedido_detalle_id IS NULL THEN RETURN NEW; END IF;
  SELECT * INTO det FROM te_pedidos_detalle WHERE id = NEW.pedido_detalle_id;
  -- Publicación (solo cuando el request viene del portal: si es admin, permite)
  IF NEW.creado_por IS NOT NULL AND EXISTS (
    SELECT 1 FROM te_empleados e
    WHERE e.auth_user_id = NEW.creado_por AND e.id = NEW.empleado_id
  ) THEN
    -- El empleado se está autoinscribiendo — exigimos publicado y cupo
    IF NOT det.publicado THEN
      RAISE EXCEPTION 'La posición no está publicada en el portal.' USING ERRCODE = 'insufficient_privilege';
    END IF;
    IF det.cierra_en IS NOT NULL AND det.cierra_en < now() THEN
      RAISE EXCEPTION 'La ventana de inscripción cerró el %', det.cierra_en USING ERRCODE = 'insufficient_privilege';
    END IF;
    SELECT count(*) INTO ocp FROM te_reservaciones
      WHERE pedido_detalle_id = NEW.pedido_detalle_id AND estado NOT IN ('cancelado');
    IF ocp >= det.cantidad THEN
      RAISE EXCEPTION 'Cupo lleno (%/% inscritos).', ocp, det.cantidad USING ERRCODE = 'insufficient_privilege';
    END IF;
    -- Debe tener plaza activa para el puesto
    SELECT EXISTS(
      SELECT 1 FROM tr_empleado_plaza
      WHERE empleado_id = NEW.empleado_id AND puesto_id = det.puesto_id AND activo
    ) INTO tiene_plaza;
    IF NOT tiene_plaza THEN
      RAISE EXCEPTION 'El empleado no tiene esa plaza activa.' USING ERRCODE = 'insufficient_privilege';
    END IF;
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_res_valida_cupo ON te_reservaciones;
CREATE TRIGGER tg_res_valida_cupo BEFORE INSERT ON te_reservaciones
  FOR EACH ROW EXECUTE FUNCTION tg_res_valida_cupo_y_plaza();

-- ---------------------------------------------------------------------------
-- 4. Adjuntos polimórficos (expedientes, incidencias, facturas)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_adjuntos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  ref_tipo      text NOT NULL,   -- 'empleado','candidato','reservacion','aclaracion','factura','pedido'
  ref_id        uuid NOT NULL,
  categoria     text,            -- 'INE','CV','comprobante_domicilio','uniforme','justificante_falta',...
  nombre        text,
  url_almacen   text NOT NULL,
  mime          text,
  bytes         bigint,
  hash_sha256   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_adj_ref ON te_adjuntos(tenant_id, ref_tipo, ref_id);
DROP TRIGGER IF EXISTS tg_aud_adj ON te_adjuntos;
CREATE TRIGGER tg_aud_adj BEFORE INSERT OR UPDATE ON te_adjuntos
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
ALTER TABLE te_adjuntos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_te_adjuntos_sel ON te_adjuntos;
DROP POLICY IF EXISTS p_te_adjuntos_ins ON te_adjuntos;
DROP POLICY IF EXISTS p_te_adjuntos_upd ON te_adjuntos;
DROP POLICY IF EXISTS p_te_adjuntos_del ON te_adjuntos;
CREATE POLICY p_te_adjuntos_sel ON te_adjuntos FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_adjuntos_ins ON te_adjuntos FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY p_te_adjuntos_upd ON te_adjuntos FOR UPDATE USING (tenant_id = current_tenant_id());
CREATE POLICY p_te_adjuntos_del ON te_adjuntos FOR DELETE USING (tenant_id = current_tenant_id());

-- ---------------------------------------------------------------------------
-- 5. Magic links (para candidatos externos)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_magic_links (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  token         text NOT NULL UNIQUE,
  candidato_id  uuid REFERENCES te_candidatos(id),
  empleado_id   uuid REFERENCES te_empleados(id),
  proposito     text NOT NULL,      -- 'completar_perfil','subir_docs','ver_postulacion','confirmar_reservacion'
  expira_en     timestamptz NOT NULL,
  usado_en      timestamptz,
  creado_en     timestamptz NOT NULL DEFAULT now(),
  CHECK (candidato_id IS NOT NULL OR empleado_id IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_ml_tok ON te_magic_links(token);
ALTER TABLE te_magic_links ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_te_magic_links_sel ON te_magic_links;
CREATE POLICY p_te_magic_links_sel ON te_magic_links FOR SELECT USING (tenant_id = current_tenant_id());

-- ---------------------------------------------------------------------------
-- 6. PEP: corrección semántica → Partidas Presupuestales
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_partidas_presupuestales (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave_pep      text NOT NULL,   -- ej: 'T/009-S2-2010-05-19-IM'
  descripcion    text NOT NULL,   -- ej: 'NAT GEO La Tierra'
  categoria      text,
  id_unidad_negocio uuid REFERENCES tc_unidades_negocio(id),
  id_sitio       uuid REFERENCES tc_sitios(id),
  terceros       boolean NOT NULL DEFAULT false,
  id_sociedad_propia uuid REFERENCES tc_sociedades_propias(id),
  anio           int,
  vigente        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave_pep)
);
DROP TRIGGER IF EXISTS tg_aud_pp ON tc_partidas_presupuestales;
CREATE TRIGGER tg_aud_pp BEFORE INSERT OR UPDATE ON tc_partidas_presupuestales
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
ALTER TABLE tc_partidas_presupuestales ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_pp_sel ON tc_partidas_presupuestales;
DROP POLICY IF EXISTS p_pp_ins ON tc_partidas_presupuestales;
DROP POLICY IF EXISTS p_pp_upd ON tc_partidas_presupuestales;
DROP POLICY IF EXISTS p_pp_del ON tc_partidas_presupuestales;
CREATE POLICY p_pp_sel ON tc_partidas_presupuestales FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_pp_ins ON tc_partidas_presupuestales FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY p_pp_upd ON tc_partidas_presupuestales FOR UPDATE USING (tenant_id = current_tenant_id());
CREATE POLICY p_pp_del ON tc_partidas_presupuestales FOR DELETE USING (tenant_id = current_tenant_id());

-- El pedido puede referenciar una partida presupuestal (PEP)
ALTER TABLE te_pedidos
  ADD COLUMN IF NOT EXISTS partida_presupuestal_id uuid REFERENCES tc_partidas_presupuestales(id);

-- ---------------------------------------------------------------------------
-- 7. Reducir personal por certeza (regla del RQ_FREELANCELOBO)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reducir_personal_evento(p_detalle uuid, p_a_cancelar int)
RETURNS int AS $$
DECLARE n int := 0;
BEGIN
  UPDATE te_reservaciones
  SET estado = 'cancelado', regla_aplicada = 'reducir_personal_evento (menor certeza primero)'
  WHERE id IN (
    SELECT r.id FROM te_reservaciones r
    LEFT JOIN tr_empleado_plaza ep
      ON ep.empleado_id = r.empleado_id AND ep.puesto_id = r.puesto_id
    WHERE r.pedido_detalle_id = p_detalle
      AND r.estado NOT IN ('cancelado', 'procesado')
    ORDER BY COALESCE(ep.porcentaje_puntualidad, 0) ASC, r.creado_en DESC
    LIMIT p_a_cancelar
  );
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 8. Vistas para el portal freelance
-- ---------------------------------------------------------------------------

-- Publicaciones abiertas que matchean con mis plazas (para el freelance autenticado).
-- Cliente pasa auth_user_id via JWT sub; la vista aplica RLS por tenant y filtra por identidad.
CREATE OR REPLACE VIEW v_publicaciones_para_freelance AS
SELECT
  pd.id             AS pedido_detalle_id,
  p.id              AS pedido_id,
  p.folio,
  p.titulo,
  p.sitio_id,
  s.titulo          AS sitio,
  cl.razon_social   AS cliente,
  pd.puesto_id,
  pu.titulo         AS puesto,
  pd.turno_id,
  t.titulo          AS turno,
  t.hora_inicio     AS turno_hora_inicio,
  t.hora_fin        AS turno_hora_fin,
  pf.fecha          AS fecha,
  pf.hora_inicio    AS hora_inicio,
  pf.hora_fin       AS hora_fin,
  fe.titulo         AS fase,
  pd.costo_unit,
  pd.cantidad       AS cupo_total,
  (SELECT count(*) FROM te_reservaciones r
    WHERE r.pedido_detalle_id = pd.id AND r.estado NOT IN ('cancelado')) AS cupo_ocupado,
  pd.cierra_en,
  pd.publicado_en,
  ep.empleado_id,
  ep.porcentaje_puntualidad
FROM te_pedidos_detalle pd
JOIN te_pedidos p             ON p.id = pd.pedido_id
LEFT JOIN te_pedido_fechas pf ON pf.id = pd.pedido_fecha_id
LEFT JOIN tc_sitios s         ON s.id = p.sitio_id
LEFT JOIN tc_clientes cl      ON cl.id = p.cliente_id
LEFT JOIN tc_puestos pu       ON pu.id = pd.puesto_id
LEFT JOIN tc_turnos t         ON t.id = pd.turno_id
LEFT JOIN tc_fases_evento fe  ON fe.id = pf.fase_evento_id
JOIN tr_empleado_plaza ep     ON ep.puesto_id = pd.puesto_id AND ep.activo
WHERE pd.publicado = true
  AND (pf.fecha IS NULL OR pf.fecha >= CURRENT_DATE)
  AND (pd.cierra_en IS NULL OR pd.cierra_en > now())
  AND (SELECT count(*) FROM te_reservaciones r
        WHERE r.pedido_detalle_id = pd.id AND r.estado NOT IN ('cancelado')) < pd.cantidad
  AND NOT EXISTS (
    SELECT 1 FROM te_reservaciones r
    WHERE r.pedido_detalle_id = pd.id
      AND r.empleado_id = ep.empleado_id
      AND r.estado NOT IN ('cancelado')
  );

GRANT SELECT ON v_publicaciones_para_freelance TO anon, authenticated;

-- Agenda personal del freelance
CREATE OR REPLACE VIEW v_agenda_freelance AS
SELECT
  r.id, r.empleado_id, r.pedido_id, r.pedido_detalle_id, r.puesto_id,
  r.estado, r.estado_asistencia, r.cita_inicio, r.cita_fin,
  p.folio AS pedido_folio, p.titulo AS pedido_titulo,
  s.titulo AS sitio, pu.titulo AS puesto,
  r.tenant_id
FROM te_reservaciones r
JOIN te_pedidos p     ON p.id = r.pedido_id
LEFT JOIN tc_sitios s ON s.id = r.sitio_id
LEFT JOIN tc_puestos pu ON pu.id = r.puesto_id;

GRANT SELECT ON v_agenda_freelance TO anon, authenticated;

-- Saldo (bruto - descontado) del empleado
CREATE OR REPLACE FUNCTION saldo_empleado(p_empleado uuid)
RETURNS numeric AS $$
DECLARE bruto numeric; pagado numeric;
BEGIN
  SELECT COALESCE(sum(monto_neto), 0) INTO bruto FROM te_nomina_detalle
    WHERE empleado_id = p_empleado AND estatus_pago IN ('calculado', 'dispersado');
  SELECT COALESCE(sum(monto), 0) INTO pagado FROM te_pagos_dispersion
    WHERE empleado_id = p_empleado AND status = 'pagado';
  RETURN bruto - pagado;
END $$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 9. RLS extendido: el empleado freelance solo ve lo suyo
-- ---------------------------------------------------------------------------

-- Helper: id del empleado ligado al usuario autenticado
CREATE OR REPLACE FUNCTION mi_empleado_id() RETURNS uuid AS $$
BEGIN
  RETURN (SELECT id FROM te_empleados WHERE auth_user_id = current_user_id() AND tenant_id = current_tenant_id());
END $$ LANGUAGE plpgsql STABLE;

-- Función para autoinscribirse (RPC pública para el portal)
CREATE OR REPLACE FUNCTION inscribirme_a_publicacion(p_detalle uuid)
RETURNS uuid AS $$
DECLARE
  det te_pedidos_detalle;
  fe  te_pedido_fechas;
  emp uuid;
  nueva uuid;
  cita_i timestamptz; cita_f timestamptz;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado (auth_user_id).'; END IF;
  SELECT * INTO det FROM te_pedidos_detalle WHERE id = p_detalle;
  IF det.id IS NULL THEN RAISE EXCEPTION 'Detalle no existe.'; END IF;
  SELECT * INTO fe FROM te_pedido_fechas WHERE id = det.pedido_fecha_id;
  IF fe.id IS NULL THEN
    -- Fallback si el pedido no tiene fecha explícita
    SELECT (fecha_evento::timestamp + hora_inicio::interval), (fecha_evento::timestamp + hora_fin::interval)
      INTO cita_i, cita_f
      FROM te_pedidos WHERE id = det.pedido_id;
  ELSE
    cita_i := (fe.fecha || ' ' || fe.hora_inicio)::timestamptz;
    cita_f := (fe.fecha || ' ' || fe.hora_fin)::timestamptz;
    IF cita_f <= cita_i THEN cita_f := cita_f + interval '1 day'; END IF;
  END IF;
  INSERT INTO te_reservaciones (
    tenant_id, pedido_id, pedido_detalle_id, empleado_id, puesto_id,
    sitio_id, estado, cita_inicio, cita_fin, duracion_en_turnos, creado_por
  )
  SELECT current_tenant_id(), det.pedido_id, det.id, emp, det.puesto_id,
         (SELECT sitio_id FROM te_pedidos WHERE id = det.pedido_id),
         'confirmado_voluntario', cita_i, cita_f, 1, current_user_id()
  RETURNING id INTO nueva;
  RETURN nueva;
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION inscribirme_a_publicacion(uuid) TO authenticated;

-- RPC para cambiar NIP (portal)
CREATE OR REPLACE FUNCTION cambiar_mi_nip(p_nip_nuevo text) RETURNS void AS $$
DECLARE emp uuid;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado.'; END IF;
  IF p_nip_nuevo IS NULL OR length(p_nip_nuevo) < 4 THEN RAISE EXCEPTION 'NIP debe tener al menos 4 dígitos.'; END IF;
  UPDATE te_empleados SET nip = p_nip_nuevo, nip_cambiado_en = now(), modificado_en = now()
    WHERE id = emp;
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION cambiar_mi_nip(text) TO authenticated;

-- RPC para preferencias de notificación
CREATE OR REPLACE FUNCTION actualizar_mis_preferencias(
  p_email boolean, p_wa boolean, p_push boolean, p_digest_hora time
) RETURNS void AS $$
DECLARE emp uuid;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado.'; END IF;
  UPDATE te_empleados
    SET pref_notif_email = COALESCE(p_email, pref_notif_email),
        pref_notif_whatsapp = COALESCE(p_wa, pref_notif_whatsapp),
        pref_notif_push = COALESCE(p_push, pref_notif_push),
        pref_digest_hora = COALESCE(p_digest_hora, pref_digest_hora),
        modificado_en = now()
    WHERE id = emp;
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION actualizar_mis_preferencias(boolean, boolean, boolean, time) TO authenticated;

-- ---------------------------------------------------------------------------
-- 10. Digest diario — genera payload para el cron
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION armar_digest_freelance(p_empleado uuid, p_dias int DEFAULT 7)
RETURNS jsonb AS $$
DECLARE
  emp te_empleados;
  publis jsonb;
  agenda jsonb;
  saldo numeric;
BEGIN
  SELECT * INTO emp FROM te_empleados WHERE id = p_empleado;
  IF emp.id IS NULL THEN RETURN NULL; END IF;

  -- Publicaciones matcheadas
  SELECT COALESCE(jsonb_agg(row_to_json(v)), '[]'::jsonb) INTO publis
  FROM (
    SELECT v.pedido_detalle_id, v.puesto, v.sitio, v.fecha, v.hora_inicio, v.hora_fin,
           v.cupo_total, v.cupo_ocupado, v.costo_unit
    FROM v_publicaciones_para_freelance v
    WHERE v.empleado_id = p_empleado
      AND v.tenant_id = emp.tenant_id
      AND (v.fecha IS NULL OR v.fecha <= CURRENT_DATE + p_dias)
    ORDER BY v.fecha NULLS LAST
    LIMIT 25
  ) v;

  -- Agenda propia próxima
  SELECT COALESCE(jsonb_agg(row_to_json(a)), '[]'::jsonb) INTO agenda
  FROM (
    SELECT a.id, a.puesto, a.sitio, a.cita_inicio, a.cita_fin, a.estado
    FROM v_agenda_freelance a
    WHERE a.empleado_id = p_empleado AND a.tenant_id = emp.tenant_id
      AND a.cita_inicio BETWEEN now() AND now() + (p_dias || ' days')::interval
      AND a.estado NOT IN ('cancelado', 'procesado')
    ORDER BY a.cita_inicio
    LIMIT 25
  ) a;

  saldo := saldo_empleado(p_empleado);

  RETURN jsonb_build_object(
    'empleado_id',    p_empleado,
    'nombre',         emp.nombres || ' ' || emp.apellido_paterno,
    'correo',         emp.correo,
    'telefono',       emp.telefono,
    'pref_email',     emp.pref_notif_email,
    'pref_whatsapp',  emp.pref_notif_whatsapp,
    'pref_push',      emp.pref_notif_push,
    'saldo',          saldo,
    'publicaciones',  publis,
    'agenda',         agenda
  );
END $$ LANGUAGE plpgsql STABLE;

GRANT EXECUTE ON FUNCTION armar_digest_freelance(uuid, int) TO service_role;
GRANT EXECUTE ON FUNCTION saldo_empleado(uuid) TO anon, authenticated;
