-- ============================================================================
-- Migration 003b — Reclutamiento completo (portal público + funnel RRHH)
-- ============================================================================

-- Enums
DO $$ BEGIN
  CREATE TYPE estado_postulacion_full_enum AS ENUM (
    'postulado', 'recepcion_pendiente', 'recepcion_ok', 'entrevista_grupal_agendada',
    'entrevista_individual', 'aceptado', 'rechazado', 'en_curso_induccion',
    'en_evento_prueba', 'listo_alta', 'promovido', 'desistio'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE resultado_postulacion_enum AS ENUM (
    'en_proceso', 'aceptado_curso', 'aceptado_evento_prueba', 'promovido_empleado',
    'rechazado_perfil', 'rechazado_documentacion', 'rechazado_evaluacion', 'desistio_candidato'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 1. te_vacantes → separar en plantilla + publicación
-- ---------------------------------------------------------------------------

-- Plantilla reutilizable de vacante
CREATE TABLE IF NOT EXISTS te_vacante_plantilla (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  codigo            text,
  titulo            text NOT NULL,
  descripcion       text,
  puesto_id         uuid NOT NULL REFERENCES tc_puestos(id),
  requiere_ingles   boolean NOT NULL DEFAULT false,
  requiere_experiencia boolean NOT NULL DEFAULT false,
  funciones         text,
  requisitos        text,
  sexo_requerido    sexo_enum,
  edad_minima       int,
  edad_maxima       int,
  salario_base      numeric(12,2),
  activa            boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, codigo)
);
DROP TRIGGER IF EXISTS tg_aud_vplant ON te_vacante_plantilla;
CREATE TRIGGER tg_aud_vplant BEFORE INSERT OR UPDATE ON te_vacante_plantilla
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Ligar te_vacantes existentes (publicaciones) a plantilla
ALTER TABLE te_vacantes
  ADD COLUMN IF NOT EXISTS plantilla_id     uuid REFERENCES te_vacante_plantilla(id),
  ADD COLUMN IF NOT EXISTS fecha_publicacion date,
  ADD COLUMN IF NOT EXISTS fecha_termino     date,
  ADD COLUMN IF NOT EXISTS cupo_maximo       int,
  ADD COLUMN IF NOT EXISTS postulados_actual int NOT NULL DEFAULT 0;

-- ---------------------------------------------------------------------------
-- 2. Grupos de citas + relación N:N candidato-grupo
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_grupos_citas (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  vacante_publicacion_id uuid REFERENCES te_vacantes(id) ON DELETE CASCADE,
  fecha_cita            date NOT NULL,
  hora_inicio           time NOT NULL,
  hora_fin              time,
  sitio_id              uuid REFERENCES tc_sitios(id),
  cupo_maximo           int NOT NULL DEFAULT 20,
  cupo_actual           int NOT NULL DEFAULT 0,
  estatus               text NOT NULL DEFAULT 'vigente',    -- vigente | cancelado | terminado
  responsable_id        uuid REFERENCES tc_responsables(id),
  observaciones         text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_gc_fecha ON te_grupos_citas(tenant_id, fecha_cita);
DROP TRIGGER IF EXISTS tg_aud_gc ON te_grupos_citas;
CREATE TRIGGER tg_aud_gc BEFORE INSERT OR UPDATE ON te_grupos_citas
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tr_cita_grupo_candidato (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  grupo_cita_id   uuid NOT NULL REFERENCES te_grupos_citas(id) ON DELETE CASCADE,
  candidato_id    uuid NOT NULL REFERENCES te_candidatos(id) ON DELETE CASCADE,
  asistio         boolean NOT NULL DEFAULT false,
  doc_completa    boolean NOT NULL DEFAULT false,
  continua_proceso boolean NOT NULL DEFAULT true,
  observaciones   text,
  agendado_en     timestamptz NOT NULL DEFAULT now(),
  confirmado_en   timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, grupo_cita_id, candidato_id)
);
DROP TRIGGER IF EXISTS tg_aud_trcgc ON tr_cita_grupo_candidato;
CREATE TRIGGER tg_aud_trcgc BEFORE INSERT OR UPDATE ON tr_cita_grupo_candidato
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 3. Eventos prueba (separados de eventos operativos)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_eventos_prueba (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo                text NOT NULL,
  fecha                 date NOT NULL,
  hora_cita             time,
  sitio_id              uuid REFERENCES tc_sitios(id),
  puesto_id             uuid REFERENCES tc_puestos(id),
  cupo_maximo           int NOT NULL DEFAULT 15,
  responsable_id        uuid REFERENCES tc_responsables(id),
  observaciones         text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
DROP TRIGGER IF EXISTS tg_aud_evprb ON te_eventos_prueba;
CREATE TRIGGER tg_aud_evprb BEFORE INSERT OR UPDATE ON te_eventos_prueba
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 4. Intentos de acceso al portal público (rate-limit anti-bot)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_intentos_acceso_portal (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  candidato_id  uuid REFERENCES te_candidatos(id),
  ip            inet,
  user_agent    text,
  accion        text NOT NULL,    -- 've_vacantes','postularse','agenda_cita','completa_perfil'
  exito         boolean NOT NULL DEFAULT true,
  registro_en   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_iap_ip_ts ON te_intentos_acceso_portal(ip, registro_en DESC);
CREATE INDEX IF NOT EXISTS ix_iap_cand ON te_intentos_acceso_portal(candidato_id, registro_en DESC);

-- ---------------------------------------------------------------------------
-- 5. Refactor tr_postulacion_candidato_vacante — de jsonb a campos discretos
-- ---------------------------------------------------------------------------
-- Agregamos campos discretos manteniendo evaluacion jsonb para compatibilidad
ALTER TABLE tr_postulacion_candidato_vacante
  ADD COLUMN IF NOT EXISTS estatus_full             estado_postulacion_full_enum NOT NULL DEFAULT 'postulado',
  ADD COLUMN IF NOT EXISTS resultado                resultado_postulacion_enum NOT NULL DEFAULT 'en_proceso',
  ADD COLUMN IF NOT EXISTS asis_recepcion           boolean,
  ADD COLUMN IF NOT EXISTS doc_completa             boolean,
  ADD COLUMN IF NOT EXISTS continua                 boolean,
  ADD COLUMN IF NOT EXISTS continua_obs             text,
  ADD COLUMN IF NOT EXISTS doc_psicometrico_url     text,
  ADD COLUMN IF NOT EXISTS psicometrico_obs         text,
  ADD COLUMN IF NOT EXISTS entrevista_obs           text,
  ADD COLUMN IF NOT EXISTS curso_induccion_id       uuid REFERENCES te_cursos_induccion(id),
  ADD COLUMN IF NOT EXISTS asis_curso_induccion     boolean,
  ADD COLUMN IF NOT EXISTS calif_curso_induccion    numeric(4,1),
  ADD COLUMN IF NOT EXISTS obs_curso_induccion      text,
  ADD COLUMN IF NOT EXISTS evento_prueba_id         uuid REFERENCES te_eventos_prueba(id),
  ADD COLUMN IF NOT EXISTS asis_evento_prueba       boolean,
  ADD COLUMN IF NOT EXISTS calif_evento_prueba      numeric(4,1),
  ADD COLUMN IF NOT EXISTS obs_evento_prueba        text,
  ADD COLUMN IF NOT EXISTS fecha_registro           timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS fecha_cierre             timestamptz;

-- ---------------------------------------------------------------------------
-- 6. Función: postular candidato (portal público)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION postular_a_vacante(
  p_tenant uuid,
  p_vacante_publicacion uuid,
  p_nombres text, p_apellido_paterno text, p_apellido_materno text,
  p_rfc text, p_curp text, p_correo text, p_telefono text,
  p_ip inet DEFAULT NULL, p_user_agent text DEFAULT NULL
) RETURNS uuid AS $$
DECLARE cand_id uuid; postul_id uuid; existente uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM te_vacantes v
    WHERE v.id = p_vacante_publicacion AND v.tenant_id = p_tenant
      AND v.estado = 'publicada'
      AND (v.fecha_termino IS NULL OR v.fecha_termino >= CURRENT_DATE))
  THEN RAISE EXCEPTION 'Vacante no disponible.'; END IF;

  SELECT id INTO existente FROM te_candidatos WHERE tenant_id = p_tenant AND (rfc = p_rfc OR curp = p_curp) LIMIT 1;
  IF existente IS NOT NULL THEN
    cand_id := existente;
  ELSE
    INSERT INTO te_candidatos (tenant_id, nombres, apellido_paterno, apellido_materno,
                               rfc, curp, correo, telefono)
    VALUES (p_tenant, p_nombres, p_apellido_paterno, p_apellido_materno,
            p_rfc, p_curp, p_correo, p_telefono)
    RETURNING id INTO cand_id;
  END IF;

  INSERT INTO tr_postulacion_candidato_vacante
    (tenant_id, vacante_id, candidato_id, estado, estatus_full, resultado)
  VALUES (p_tenant, p_vacante_publicacion, cand_id, 'recibida', 'postulado', 'en_proceso')
  ON CONFLICT (tenant_id, vacante_id, candidato_id) DO NOTHING
  RETURNING id INTO postul_id;

  UPDATE te_vacantes SET postulados_actual = postulados_actual + 1 WHERE id = p_vacante_publicacion;

  INSERT INTO te_intentos_acceso_portal (tenant_id, candidato_id, ip, user_agent, accion, exito)
    VALUES (p_tenant, cand_id, p_ip, p_user_agent, 'postularse', true);
  RETURN COALESCE(postul_id, cand_id);
END $$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION postular_a_vacante(uuid,uuid,text,text,text,text,text,text,text,inet,text) TO anon, authenticated;

-- Función: agendar entrevista grupal (después de postularse)
CREATE OR REPLACE FUNCTION agendar_entrevista_grupal(
  p_tenant uuid, p_candidato uuid, p_grupo_cita uuid
) RETURNS uuid AS $$
DECLARE cupo_max int; cupo_act int; nuevo uuid;
BEGIN
  SELECT cupo_maximo, cupo_actual INTO cupo_max, cupo_act FROM te_grupos_citas WHERE id = p_grupo_cita AND tenant_id = p_tenant;
  IF cupo_max IS NULL THEN RAISE EXCEPTION 'Grupo cita no existe.'; END IF;
  IF cupo_act >= cupo_max THEN RAISE EXCEPTION 'Grupo cita lleno (%/%)', cupo_act, cupo_max; END IF;
  INSERT INTO tr_cita_grupo_candidato (tenant_id, grupo_cita_id, candidato_id)
    VALUES (p_tenant, p_grupo_cita, p_candidato)
    ON CONFLICT DO NOTHING
    RETURNING id INTO nuevo;
  IF nuevo IS NULL THEN RAISE EXCEPTION 'El candidato ya está agendado en este grupo.'; END IF;
  UPDATE te_grupos_citas SET cupo_actual = cupo_actual + 1 WHERE id = p_grupo_cita;
  UPDATE tr_postulacion_candidato_vacante
    SET estatus_full = 'entrevista_grupal_agendada'
    WHERE candidato_id = p_candidato AND tenant_id = p_tenant AND estatus_full = 'postulado';
  RETURN nuevo;
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION agendar_entrevista_grupal(uuid,uuid,uuid) TO anon, authenticated;

-- ---------------------------------------------------------------------------
-- 7. GRANTS + RLS para las nuevas
-- ---------------------------------------------------------------------------
ALTER TABLE te_vacante_plantilla         ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_grupos_citas              ENABLE ROW LEVEL SECURITY;
ALTER TABLE tr_cita_grupo_candidato      ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_eventos_prueba            ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_intentos_acceso_portal    ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_vacante_plantilla','te_grupos_citas','tr_cita_grupo_candidato',
                            'te_eventos_prueba','te_intentos_acceso_portal'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_sel ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_ins ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_upd ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_del ON %1$s', t);
    EXECUTE format('CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id());
                     CREATE POLICY p_%1$s_ins ON %1$s FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
                     CREATE POLICY p_%1$s_upd ON %1$s FOR UPDATE USING (tenant_id = current_tenant_id());
                     CREATE POLICY p_%1$s_del ON %1$s FOR DELETE USING (tenant_id = current_tenant_id());', t);
  END LOOP;
END $$;

GRANT ALL ON te_vacante_plantilla, te_grupos_citas, tr_cita_grupo_candidato,
             te_eventos_prueba, te_intentos_acceso_portal
  TO anon, authenticated, service_role;

-- Portal público: permitir SELECT anónimo en vacantes publicadas vigentes
CREATE OR REPLACE VIEW v_vacantes_publicas AS
SELECT
  v.id, v.tenant_id, v.titulo, v.descripcion, v.fecha_publicacion, v.fecha_termino,
  v.vacantes_cnt, v.cupo_maximo, v.postulados_actual,
  p.titulo AS puesto,
  s.titulo AS sitio,
  c.razon_social AS cliente
FROM te_vacantes v
LEFT JOIN tc_puestos p ON p.id = v.puesto_id
LEFT JOIN tc_sitios s  ON s.id = v.sitio_id
LEFT JOIN tc_clientes c ON c.id = v.cliente_id
WHERE v.estado = 'publicada'
  AND (v.fecha_termino IS NULL OR v.fecha_termino >= CURRENT_DATE)
  AND (v.cupo_maximo IS NULL OR v.postulados_actual < v.cupo_maximo);
GRANT SELECT ON v_vacantes_publicas TO anon, authenticated;

-- Grupos de citas disponibles para una vacante
CREATE OR REPLACE VIEW v_grupos_citas_disponibles AS
SELECT gc.*, (gc.cupo_maximo - gc.cupo_actual) AS lugares_libres
FROM te_grupos_citas gc
WHERE gc.estatus = 'vigente'
  AND gc.fecha_cita >= CURRENT_DATE
  AND gc.cupo_actual < gc.cupo_maximo;
GRANT SELECT ON v_grupos_citas_disponibles TO anon, authenticated;
