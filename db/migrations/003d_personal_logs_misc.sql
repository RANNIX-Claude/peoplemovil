-- ============================================================================
-- Migration 003d — Personal expandido, logs (TL_*), geo, misceláneos
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Expandir te_empleados con ~20 campos del sistema Lobo
-- ---------------------------------------------------------------------------
ALTER TABLE te_empleados
  ADD COLUMN IF NOT EXISTS tipo_empleado          text,           -- freelance | staff | interno | eventual
  ADD COLUMN IF NOT EXISTS porcentaje_puntualidad_global numeric(4,3),
  -- Dirección desestructurada
  ADD COLUMN IF NOT EXISTS calle                  text,
  ADD COLUMN IF NOT EXISTS numero_exterior        text,
  ADD COLUMN IF NOT EXISTS numero_interior        text,
  ADD COLUMN IF NOT EXISTS colonia                text,
  ADD COLUMN IF NOT EXISTS codigo_postal          text,
  ADD COLUMN IF NOT EXISTS delegacion_municipio   text,
  ADD COLUMN IF NOT EXISTS estado_provincia       text,
  ADD COLUMN IF NOT EXISTS estado_nacimiento      text,
  -- Documentos personales
  ADD COLUMN IF NOT EXISTS credencial_elector     text,
  ADD COLUMN IF NOT EXISTS cartilla               text,
  -- Personal
  ADD COLUMN IF NOT EXISTS estado_civil           text,
  ADD COLUMN IF NOT EXISTS estatura               numeric(4,2),
  ADD COLUMN IF NOT EXISTS talla                  text,
  -- Perfil académico
  ADD COLUMN IF NOT EXISTS grado_estudios         text,
  ADD COLUMN IF NOT EXISTS licenciatura_curso     text,
  ADD COLUMN IF NOT EXISTS idiomas                text,
  -- Emergencia + médico
  ADD COLUMN IF NOT EXISTS contacto_emergencia    text,
  ADD COLUMN IF NOT EXISTS datos_medicos          text,
  ADD COLUMN IF NOT EXISTS tipo_sangre            text,
  -- Trazabilidad
  ADD COLUMN IF NOT EXISTS recomendado_por        text,
  ADD COLUMN IF NOT EXISTS fecha_antiguedad       date,
  ADD COLUMN IF NOT EXISTS status_oculto          boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS requisicion_origen_id  uuid REFERENCES te_requisicion_personal(id);

-- ---------------------------------------------------------------------------
-- 2. Expandir tc_puestos
-- ---------------------------------------------------------------------------
ALTER TABLE tc_puestos
  ADD COLUMN IF NOT EXISTS confirmar_entre_seriados      boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS matricial                     boolean NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------------
-- 3. Reglas de asistencia TimeScan (extraer del puesto)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_reglas_asistencia_timescan (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo                 text NOT NULL,
  min_ant_entrada        int NOT NULL DEFAULT 15,
  min_retardo            int NOT NULL DEFAULT 10,
  min_ant_salida         int NOT NULL DEFAULT 15,
  min_desp_salida        int NOT NULL DEFAULT 30,
  activo                 boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, titulo)
);
DROP TRIGGER IF EXISTS tg_aud_rats ON tc_reglas_asistencia_timescan;
CREATE TRIGGER tg_aud_rats BEFORE INSERT OR UPDATE ON tc_reglas_asistencia_timescan
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

ALTER TABLE tc_puestos
  ADD COLUMN IF NOT EXISTS id_regla_asistencia_timescan  uuid REFERENCES tc_reglas_asistencia_timescan(id);

-- ---------------------------------------------------------------------------
-- 4. Personal — tablas nuevas
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_lista_negra_empleados (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  rfc             text,
  curp            text,
  nombre_completo text NOT NULL,
  motivo          text NOT NULL,
  autorizado_por  uuid,
  fecha_bloqueo   date NOT NULL DEFAULT CURRENT_DATE,
  activo          boolean NOT NULL DEFAULT true,
  observaciones   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (rfc IS NOT NULL OR curp IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_ln_rfc ON te_lista_negra_empleados(tenant_id, rfc) WHERE activo;
CREATE INDEX IF NOT EXISTS ix_ln_curp ON te_lista_negra_empleados(tenant_id, curp) WHERE activo;
DROP TRIGGER IF EXISTS tg_aud_ln ON te_lista_negra_empleados;
CREATE TRIGGER tg_aud_ln BEFORE INSERT OR UPDATE ON te_lista_negra_empleados
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS te_observaciones_empleado (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id     uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  tipo_registro   text NOT NULL,   -- 'RRHH','Operación','Nómina','Cliente'
  observacion     text NOT NULL,
  autor_id        uuid,
  fecha_obs       timestamptz NOT NULL DEFAULT now(),
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_obs_emp ON te_observaciones_empleado(tenant_id, empleado_id, fecha_obs DESC);
DROP TRIGGER IF EXISTS tg_aud_oe ON te_observaciones_empleado;
CREATE TRIGGER tg_aud_oe BEFORE INSERT OR UPDATE ON te_observaciones_empleado
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 5. Logs (TL_*) — renombrar y agregar
-- ---------------------------------------------------------------------------

-- Log de altas/bajas
CREATE TABLE IF NOT EXISTS tl_log_altas_bajas (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id     uuid REFERENCES te_empleados(id),
  candidato_id    uuid REFERENCES te_candidatos(id),
  nombre_persona  text,
  fecha           timestamptz NOT NULL DEFAULT now(),
  de_estado       text,
  a_estado        text NOT NULL,
  observaciones   text,
  actor_id        uuid,
  actor_nombre    text,
  CHECK (empleado_id IS NOT NULL OR candidato_id IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_lab_emp ON tl_log_altas_bajas(tenant_id, empleado_id, fecha DESC);
DROP TRIGGER IF EXISTS tg_lab_no_mut ON tl_log_altas_bajas;
CREATE TRIGGER tg_lab_no_mut BEFORE UPDATE OR DELETE ON tl_log_altas_bajas
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- Log de cierre de nómina
CREATE TABLE IF NOT EXISTS tl_log_cierre_nomina (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  periodo_id      uuid REFERENCES te_nominas_periodo(id),
  paso            text NOT NULL,
  descripcion     text,
  ts              timestamptz NOT NULL DEFAULT now(),
  actor_id        uuid,
  detalles        jsonb
);
CREATE INDEX IF NOT EXISTS ix_lcn ON tl_log_cierre_nomina(tenant_id, periodo_id, ts DESC);
DROP TRIGGER IF EXISTS tg_lcn_no_mut ON tl_log_cierre_nomina;
CREATE TRIGGER tg_lcn_no_mut BEFORE UPDATE OR DELETE ON tl_log_cierre_nomina
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- Log detalle de operación (fino)
CREATE TABLE IF NOT EXISTS tl_detalle_operacion (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  entidad         text NOT NULL,     -- 'pedido','reservacion','factura','pago',...
  entidad_id      uuid NOT NULL,
  operacion       text NOT NULL,     -- 'INSERT','UPDATE','DELETE','CANCEL','LIBERAR',...
  atributo        text,
  valor_anterior  text,
  valor_nuevo     text,
  actor_id        uuid,
  ts              timestamptz NOT NULL DEFAULT now(),
  detalles        jsonb
);
CREATE INDEX IF NOT EXISTS ix_ldo_ent ON tl_detalle_operacion(tenant_id, entidad, entidad_id, ts DESC);
DROP TRIGGER IF EXISTS tg_ldo_no_mut ON tl_detalle_operacion;
CREATE TRIGGER tg_ldo_no_mut BEFORE UPDATE OR DELETE ON tl_detalle_operacion
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- Movimientos de empleado (encabezado + detalle)
CREATE TABLE IF NOT EXISTS tl_movimientos_empleado_encabezado (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  tipo_batch      text NOT NULL,   -- 'alta_masiva','baja_masiva','cambio_puesto_masivo'
  descripcion     text,
  cnt_registros   int NOT NULL DEFAULT 0,
  actor_id        uuid,
  procesado_en    timestamptz NOT NULL DEFAULT now(),
  status          text NOT NULL DEFAULT 'procesado'
);
DROP TRIGGER IF EXISTS tg_lmee_no_mut ON tl_movimientos_empleado_encabezado;
CREATE TRIGGER tg_lmee_no_mut BEFORE UPDATE OR DELETE ON tl_movimientos_empleado_encabezado
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- Renombrar mi te_movimientos_empleado → tl_movimientos_empleado_det
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_schema='public' AND table_name='te_movimientos_empleado')
     AND NOT EXISTS (SELECT 1 FROM information_schema.tables
                     WHERE table_schema='public' AND table_name='tl_movimientos_empleado_det')
  THEN
    EXECUTE 'ALTER TABLE te_movimientos_empleado RENAME TO tl_movimientos_empleado_det';
  END IF;
END $$;
-- Agregar FK al encabezado
ALTER TABLE tl_movimientos_empleado_det
  ADD COLUMN IF NOT EXISTS encabezado_id uuid REFERENCES tl_movimientos_empleado_encabezado(id);

-- Renombrar te_bitacora_accesos → tl_registro_modulos + enriquecer
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_schema='public' AND table_name='te_bitacora_accesos')
     AND NOT EXISTS (SELECT 1 FROM information_schema.tables
                     WHERE table_schema='public' AND table_name='tl_registro_modulos')
  THEN
    EXECUTE 'ALTER TABLE te_bitacora_accesos RENAME TO tl_registro_modulos';
  END IF;
END $$;

ALTER TABLE tl_registro_modulos
  ADD COLUMN IF NOT EXISTS formulario     text,
  ADD COLUMN IF NOT EXISTS atributo       text,
  ADD COLUMN IF NOT EXISTS valor_anterior text,
  ADD COLUMN IF NOT EXISTS valor_nuevo    text;

-- Actualizar log_bitacora para escribir en tl_registro_modulos
CREATE OR REPLACE FUNCTION log_bitacora(p_modulo text, p_accion text, p_detalle text DEFAULT NULL)
RETURNS uuid AS $$
DECLARE nid uuid; t uuid;
BEGIN
  t := current_tenant_id();
  IF t IS NULL THEN
    RAISE EXCEPTION 'sin tenant activo — el header x-tenant-id no vino en la request';
  END IF;
  INSERT INTO tl_registro_modulos (tenant_id, actor_id, modulo, accion, detalle)
  VALUES (t, current_user_id(), p_modulo, p_accion, p_detalle)
  RETURNING id INTO nid;
  RETURN nid;
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION log_bitacora(text, text, text) TO anon, authenticated;

-- ---------------------------------------------------------------------------
-- 6. Catálogos geo (ciudades, códigos postales, colonias)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_ciudades (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  estado_id     uuid REFERENCES tc_estados_mx(id),
  nombre        text NOT NULL,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, estado_id, nombre)
);
DROP TRIGGER IF EXISTS tg_aud_ciu ON tc_ciudades;
CREATE TRIGGER tg_aud_ciu BEFORE INSERT OR UPDATE ON tc_ciudades
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_codigos_postales (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  cp            text NOT NULL,
  ciudad_id     uuid REFERENCES tc_ciudades(id),
  estado_id     uuid REFERENCES tc_estados_mx(id),
  municipio     text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, cp)
);
DROP TRIGGER IF EXISTS tg_aud_cp ON tc_codigos_postales;
CREATE TRIGGER tg_aud_cp BEFORE INSERT OR UPDATE ON tc_codigos_postales
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_colonias_cp (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  cp_id         uuid NOT NULL REFERENCES tc_codigos_postales(id) ON DELETE CASCADE,
  nombre        text NOT NULL,
  tipo          text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, cp_id, nombre)
);
DROP TRIGGER IF EXISTS tg_aud_col ON tc_colonias_cp;
CREATE TRIGGER tg_aud_col BEFORE INSERT OR UPDATE ON tc_colonias_cp
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 7. Catálogos menores
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_como_se_entero (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_cse ON tc_como_se_entero;
CREATE TRIGGER tg_aud_cse BEFORE INSERT OR UPDATE ON tc_como_se_entero
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_causas_baja_reingreso (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  tipo          text NOT NULL,     -- 'baja' | 'reingreso'
  descripcion   text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_cbr ON tc_causas_baja_reingreso;
CREATE TRIGGER tg_aud_cbr BEFORE INSERT OR UPDATE ON tc_causas_baja_reingreso
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_presentaciones_producto (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  descripcion   text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_pp ON tc_presentaciones_producto;
CREATE TRIGGER tg_aud_pp BEFORE INSERT OR UPDATE ON tc_presentaciones_producto
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 8. Relaciones N:N (tr_*)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tr_credencial_puesto (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  puesto_id     uuid NOT NULL REFERENCES tc_puestos(id) ON DELETE CASCADE,
  credencial    text NOT NULL,
  obligatoria   boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, puesto_id, credencial)
);
DROP TRIGGER IF EXISTS tg_aud_trcp ON tr_credencial_puesto;
CREATE TRIGGER tg_aud_trcp BEFORE INSERT OR UPDATE ON tr_credencial_puesto
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tr_productos_similares (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  producto_id         uuid NOT NULL REFERENCES tc_productos(id) ON DELETE CASCADE,
  producto_similar_id uuid NOT NULL REFERENCES tc_productos(id),
  bidireccional       boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, producto_id, producto_similar_id),
  CHECK (producto_id <> producto_similar_id)
);
DROP TRIGGER IF EXISTS tg_aud_trps ON tr_productos_similares;
CREATE TRIGGER tg_aud_trps BEFORE INSERT OR UPDATE ON tr_productos_similares
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tr_puestos_similares (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  puesto_id         uuid NOT NULL REFERENCES tc_puestos(id) ON DELETE CASCADE,
  puesto_similar_id uuid NOT NULL REFERENCES tc_puestos(id),
  bidireccional     boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, puesto_id, puesto_similar_id),
  CHECK (puesto_id <> puesto_similar_id)
);
DROP TRIGGER IF EXISTS tg_aud_trps2 ON tr_puestos_similares;
CREATE TRIGGER tg_aud_trps2 BEFORE INSERT OR UPDATE ON tr_puestos_similares
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tr_producto_puesto (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  producto_id   uuid NOT NULL REFERENCES tc_productos(id) ON DELETE CASCADE,
  puesto_id     uuid NOT NULL REFERENCES tc_puestos(id),
  es_principal  boolean NOT NULL DEFAULT false,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, producto_id, puesto_id)
);
DROP TRIGGER IF EXISTS tg_aud_trpp ON tr_producto_puesto;
CREATE TRIGGER tg_aud_trpp BEFORE INSERT OR UPDATE ON tr_producto_puesto
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 9. Máquina de estados del cierre de nómina
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_proceso_cierre_nomina (
  id                                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  periodo_id                            uuid NOT NULL REFERENCES te_nominas_periodo(id) ON DELETE CASCADE,
  paso_actual                           text NOT NULL DEFAULT 'inicial',
  ejecuta_precauciones_previas          boolean NOT NULL DEFAULT false,
  precauciones_previas_terminadas       boolean NOT NULL DEFAULT false,
  ejecuta_cierre_nomina                 boolean NOT NULL DEFAULT false,
  cierre_completo                       boolean NOT NULL DEFAULT false,
  observaciones                         text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
DROP TRIGGER IF EXISTS tg_aud_pcn ON te_proceso_cierre_nomina;
CREATE TRIGGER tg_aud_pcn BEFORE INSERT OR UPDATE ON te_proceso_cierre_nomina
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 10. Cola de listas manuales pendientes
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_procesar_lista_manual (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo                text NOT NULL,
  pedido_detalle_id     uuid REFERENCES te_pedidos_detalle(id),
  archivo_pdf_url       text,
  observaciones         text,
  status                text NOT NULL DEFAULT 'pendiente',    -- pendiente | procesando | procesado | error
  procesado_en          timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
DROP TRIGGER IF EXISTS tg_aud_plm ON te_procesar_lista_manual;
CREATE TRIGGER tg_aud_plm BEFORE INSERT OR UPDATE ON te_procesar_lista_manual
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 11. RLS + GRANTS para las nuevas
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'tc_reglas_asistencia_timescan','te_lista_negra_empleados','te_observaciones_empleado',
    'tl_log_altas_bajas','tl_log_cierre_nomina','tl_detalle_operacion',
    'tl_movimientos_empleado_encabezado',
    'tc_ciudades','tc_codigos_postales','tc_colonias_cp',
    'tc_como_se_entero','tc_causas_baja_reingreso','tc_presentaciones_producto',
    'tr_credencial_puesto','tr_productos_similares','tr_puestos_similares','tr_producto_puesto',
    'te_proceso_cierre_nomina','te_procesar_lista_manual'
  ] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
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

GRANT ALL ON tc_reglas_asistencia_timescan, te_lista_negra_empleados, te_observaciones_empleado,
             tl_log_altas_bajas, tl_log_cierre_nomina, tl_detalle_operacion,
             tl_movimientos_empleado_encabezado,
             tc_ciudades, tc_codigos_postales, tc_colonias_cp,
             tc_como_se_entero, tc_causas_baja_reingreso, tc_presentaciones_producto,
             tr_credencial_puesto, tr_productos_similares, tr_puestos_similares, tr_producto_puesto,
             te_proceso_cierre_nomina, te_procesar_lista_manual
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 12. Semillas
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

-- Regla asistencia default
INSERT INTO tc_reglas_asistencia_timescan (tenant_id, titulo, min_ant_entrada, min_retardo, min_ant_salida, min_desp_salida) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Regla estándar (15/10/15/30)', 15, 10, 15, 30),
  ('00000000-0000-0000-0000-000000000001', 'Estricta (5/5/5/15)', 5, 5, 5, 15),
  ('00000000-0000-0000-0000-000000000001', 'Flexible (30/20/30/60)', 30, 20, 30, 60)
ON CONFLICT DO NOTHING;

-- Cómo se enteró
INSERT INTO tc_como_se_entero (tenant_id, clave, titulo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'referido',    'Referido por empleado'),
  ('00000000-0000-0000-0000-000000000001', 'redes',       'Redes sociales'),
  ('00000000-0000-0000-0000-000000000001', 'bolsa',       'Bolsa de trabajo online'),
  ('00000000-0000-0000-0000-000000000001', 'volante',     'Volante impreso'),
  ('00000000-0000-0000-0000-000000000001', 'evento',      'Evento presencial'),
  ('00000000-0000-0000-0000-000000000001', 'otro',        'Otro')
ON CONFLICT DO NOTHING;

-- Causas de baja/reingreso
INSERT INTO tc_causas_baja_reingreso (tenant_id, clave, titulo, tipo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'baja_voluntaria',   'Baja voluntaria del empleado',        'baja'),
  ('00000000-0000-0000-0000-000000000001', 'baja_faltas',       'Baja por faltas injustificadas',       'baja'),
  ('00000000-0000-0000-0000-000000000001', 'baja_bajo_desemp',  'Baja por bajo desempeño',              'baja'),
  ('00000000-0000-0000-0000-000000000001', 'baja_conducta',     'Baja por conducta inapropiada',        'baja'),
  ('00000000-0000-0000-0000-000000000001', 'baja_medica',       'Baja por incapacidad médica',          'baja'),
  ('00000000-0000-0000-0000-000000000001', 'reingreso_est',     'Reingreso estándar',                   'reingreso'),
  ('00000000-0000-0000-0000-000000000001', 'reingreso_temp',    'Reingreso temporal (por evento)',      'reingreso')
ON CONFLICT DO NOTHING;

-- Estados MX básicos
INSERT INTO tc_estados_mx (tenant_id, clave_ine, nombre) VALUES
  ('00000000-0000-0000-0000-000000000001', 'CMX', 'Ciudad de México'),
  ('00000000-0000-0000-0000-000000000001', 'MEX', 'Estado de México'),
  ('00000000-0000-0000-0000-000000000001', 'JAL', 'Jalisco'),
  ('00000000-0000-0000-0000-000000000001', 'NLE', 'Nuevo León'),
  ('00000000-0000-0000-0000-000000000001', 'PUE', 'Puebla'),
  ('00000000-0000-0000-0000-000000000001', 'QRO', 'Querétaro')
ON CONFLICT DO NOTHING;
