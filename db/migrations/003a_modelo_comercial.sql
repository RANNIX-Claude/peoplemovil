-- ============================================================================
-- Migration 003a — Modelo comercial
-- Sistema Lobo/AppSCPF: refinamientos del ciclo Requisición → Pedido → Facturación
-- Aditivo — no rompe estructuras existentes
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Enum de estado del detalle de pedido (extrae 1=borrador, 4=liberado, ...)
-- ---------------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE estado_detalle_pedido_enum AS ENUM (
    'borrador', 'liberado', 'cancelado', 'procesado', 'facturado'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE tipo_movimiento_pedido_enum AS ENUM ('pedido', 'servicio_interno', 'orden_servicio');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_facturacion_enum AS ENUM (
    'no_facturable', 'pendiente', 'parcial', 'facturado', 'cancelado'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 2. Nuevos catálogos comerciales
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tc_tipos_movimiento_pedido (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         tipo_movimiento_pedido_enum NOT NULL,
  titulo        text NOT NULL,
  descripcion   text,
  se_factura    boolean NOT NULL DEFAULT true,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_tmp ON tc_tipos_movimiento_pedido;
CREATE TRIGGER tg_aud_tmp BEFORE INSERT OR UPDATE ON tc_tipos_movimiento_pedido
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_tipos_complejidad (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  descripcion   text,
  factor_costo  numeric(5,2) NOT NULL DEFAULT 1.00,
  id_unidad_negocio uuid REFERENCES tc_unidades_negocio(id),
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_tcplx ON tc_tipos_complejidad;
CREATE TRIGGER tg_aud_tcplx BEFORE INSERT OR UPDATE ON tc_tipos_complejidad
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_tipos_duracion_evento (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  dias_minimos  int,
  dias_maximos  int,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_tde ON tc_tipos_duracion_evento;
CREATE TRIGGER tg_aud_tde BEFORE INSERT OR UPDATE ON tc_tipos_duracion_evento
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Parametrización de duraciones ricas: encabezado + rangos matriciales
CREATE TABLE IF NOT EXISTS tp_duraciones_evento (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  tipo_duracion_id       uuid NOT NULL REFERENCES tc_tipos_duracion_evento(id) ON DELETE CASCADE,
  id_tipo_complejidad    uuid REFERENCES tc_tipos_complejidad(id),
  dias_desde             int NOT NULL,
  dias_hasta             int NOT NULL,
  factor_sueldo          numeric(5,3) NOT NULL DEFAULT 1.0,
  observaciones          text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (dias_hasta >= dias_desde)
);
CREATE INDEX IF NOT EXISTS ix_tp_dur ON tp_duraciones_evento(tenant_id, tipo_duracion_id, dias_desde);
DROP TRIGGER IF EXISTS tg_aud_tpdur ON tp_duraciones_evento;
CREATE TRIGGER tg_aud_tpdur BEFORE INSERT OR UPDATE ON tp_duraciones_evento
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Precios especiales por cliente (override de precio base por producto)
CREATE TABLE IF NOT EXISTS tp_precios_especiales_cliente (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  cliente_id     uuid NOT NULL REFERENCES tc_clientes(id) ON DELETE CASCADE,
  producto_id    uuid NOT NULL REFERENCES tc_productos(id) ON DELETE CASCADE,
  precio_unit    numeric(12,2) NOT NULL,
  moneda         text NOT NULL DEFAULT 'MXN',
  vigente_desde  date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta  date,
  activo         boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, cliente_id, producto_id, vigente_desde)
);
CREATE INDEX IF NOT EXISTS ix_tp_pec_cli ON tp_precios_especiales_cliente(tenant_id, cliente_id, producto_id);
DROP TRIGGER IF EXISTS tg_aud_tpec ON tp_precios_especiales_cliente;
CREATE TRIGGER tg_aud_tpec BEFORE INSERT OR UPDATE ON tp_precios_especiales_cliente
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 3. Nueva tabla: Requisición de personal (previa al pedido)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_requisicion_personal (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  folio               int NOT NULL,
  titulo              text NOT NULL,
  descripcion         text,
  cliente_id          uuid REFERENCES tc_clientes(id),
  solicitante_nombre  text,
  solicitante_correo  text,
  solicitante_telefono text,
  fecha_evento        date NOT NULL,
  fecha_solicitud     timestamptz NOT NULL DEFAULT now(),
  fecha_deseada       date,
  cantidad_estimada   int,
  estatus             text NOT NULL DEFAULT 'recibida',
  observaciones       text,
  pedido_generado_id  uuid REFERENCES te_pedidos(id),
  rechazada_motivo    text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, folio)
);
CREATE INDEX IF NOT EXISTS ix_reqper_fecha ON te_requisicion_personal(tenant_id, fecha_evento);
CREATE INDEX IF NOT EXISTS ix_reqper_est ON te_requisicion_personal(tenant_id, estatus);
DROP TRIGGER IF EXISTS tg_aud_reqper ON te_requisicion_personal;
CREATE TRIGGER tg_aud_reqper BEFORE INSERT OR UPDATE ON te_requisicion_personal
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

ALTER TABLE te_requisicion_personal ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_reqper_sel ON te_requisicion_personal;
DROP POLICY IF EXISTS p_reqper_ins ON te_requisicion_personal;
DROP POLICY IF EXISTS p_reqper_upd ON te_requisicion_personal;
DROP POLICY IF EXISTS p_reqper_del ON te_requisicion_personal;
CREATE POLICY p_reqper_sel ON te_requisicion_personal FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY p_reqper_ins ON te_requisicion_personal FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY p_reqper_upd ON te_requisicion_personal FOR UPDATE USING (tenant_id = current_tenant_id());
CREATE POLICY p_reqper_del ON te_requisicion_personal FOR DELETE USING (tenant_id = current_tenant_id());

-- ---------------------------------------------------------------------------
-- 4. Expandir te_pedidos con campos del sistema Lobo real
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos
  ADD COLUMN IF NOT EXISTS requisicion_id      uuid REFERENCES te_requisicion_personal(id),
  -- Snapshot cliente al momento del pedido (denormalización intencional)
  ADD COLUMN IF NOT EXISTS cliente_nombre_snap text,
  ADD COLUMN IF NOT EXISTS cliente_rfc_snap    text,
  ADD COLUMN IF NOT EXISTS cliente_direccion_snap text,
  ADD COLUMN IF NOT EXISTS cliente_telefono_snap  text,
  -- Contacto específico del cliente
  ADD COLUMN IF NOT EXISTS contacto_id         uuid,
  ADD COLUMN IF NOT EXISTS contacto_nombre     text,
  ADD COLUMN IF NOT EXISTS contacto_telefono   text,
  -- Estructura organizacional
  ADD COLUMN IF NOT EXISTS tipo_movimiento_id  uuid REFERENCES tc_tipos_movimiento_pedido(id),
  ADD COLUMN IF NOT EXISTS tipo_complejidad_id uuid REFERENCES tc_tipos_complejidad(id),
  ADD COLUMN IF NOT EXISTS tipo_duracion_id    uuid REFERENCES tc_tipos_duracion_evento(id),
  ADD COLUMN IF NOT EXISTS duracion_dias       int,
  -- Políticas del pedido
  ADD COLUMN IF NOT EXISTS permitir_cancelaciones boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS status_facturacion  status_facturacion_enum NOT NULL DEFAULT 'no_facturable',
  -- Financiero snapshot
  ADD COLUMN IF NOT EXISTS subtotal            numeric(14,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS iva                 numeric(14,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_con_iva       numeric(14,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS costo_por_nomina    numeric(14,2) DEFAULT 0,
  -- Versionado y auditoría
  ADD COLUMN IF NOT EXISTS version_vigente     boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS pedido_anterior_id  uuid REFERENCES te_pedidos(id);

-- ---------------------------------------------------------------------------
-- 5. Expandir te_pedidos_detalle con los ~25 campos del Lobo
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos_detalle
  -- Estado detallado (reemplaza el boolean publicado)
  ADD COLUMN IF NOT EXISTS status_detalle       estado_detalle_pedido_enum NOT NULL DEFAULT 'borrador',
  -- Fechas múltiples que tenía el original
  ADD COLUMN IF NOT EXISTS fecha_entrega        date,
  ADD COLUMN IF NOT EXISTS fecha_cita           date,
  ADD COLUMN IF NOT EXISTS hora_cita_inicio     time,
  ADD COLUMN IF NOT EXISTS hora_cita_fin        time,
  ADD COLUMN IF NOT EXISTS fecha_liberacion     timestamptz,
  ADD COLUMN IF NOT EXISTS fecha_vigencia_preasignados timestamptz,
  ADD COLUMN IF NOT EXISTS fecha_fin_bloque     timestamptz,
  -- Agrupación por bloques
  ADD COLUMN IF NOT EXISTS bloque_num           int,
  -- Tipo Staff/Operativo (originalmente TC_TipoPersonalID)
  ADD COLUMN IF NOT EXISTS id_tipo_personal     uuid REFERENCES tc_tipos_personal(id),
  ADD COLUMN IF NOT EXISTS producto_id          uuid REFERENCES tc_productos(id),
  -- Turnos y contadores paralelos
  ADD COLUMN IF NOT EXISTS turnos               numeric(5,2) DEFAULT 1,
  ADD COLUMN IF NOT EXISTS cantidad_reservados          int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cantidad_reservados_con_pre  int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cantidad_reservados_real     int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cantidad_que_asistieron      int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS porcentaje_completo          numeric(5,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS porcentaje_completo_con_pre  numeric(5,2) NOT NULL DEFAULT 0,
  -- Sitio de entrega específico (aparte del sitio del pedido)
  ADD COLUMN IF NOT EXISTS id_lugar_entrega     uuid REFERENCES tc_sitios(id),
  ADD COLUMN IF NOT EXISTS direccion_entrega    text,
  -- Fiscal
  ADD COLUMN IF NOT EXISTS facturable           boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS folio_factura        int,
  ADD COLUMN IF NOT EXISTS factura_servicio_interno text,
  ADD COLUMN IF NOT EXISTS precio               numeric(12,2),
  ADD COLUMN IF NOT EXISTS pago_especial        numeric(12,2),
  ADD COLUMN IF NOT EXISTS costo_por_nomina     numeric(12,2),
  ADD COLUMN IF NOT EXISTS periodo_pago         int,
  ADD COLUMN IF NOT EXISTS periodo_lista_asistencia int,
  -- Similares y presentación
  ADD COLUMN IF NOT EXISTS producto_matricial   boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS completar_productos_similares boolean DEFAULT false,
  -- SMS
  ADD COLUMN IF NOT EXISTS fecha_envio_sms      timestamptz,
  ADD COLUMN IF NOT EXISTS status_envio_sms     text,
  ADD COLUMN IF NOT EXISTS envio_sms_preasignados boolean NOT NULL DEFAULT false,
  -- Auditoría de correos automáticos
  ADD COLUMN IF NOT EXISTS correo_enviado_faltas       boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS correo_enviado_pep_temporal boolean NOT NULL DEFAULT false,
  -- Otras políticas
  ADD COLUMN IF NOT EXISTS permitir_cancelar_confirmaciones boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS indicaciones_especiales     text,
  ADD COLUMN IF NOT EXISTS fase_evento_str      text;   -- string libre (además del id enum)

-- Mantener consistencia con `publicado`: cuando status_detalle = 'liberado' → publicado=true
CREATE OR REPLACE FUNCTION tg_sync_detalle_publicado() RETURNS trigger AS $$
BEGIN
  IF NEW.status_detalle IN ('liberado','procesado','facturado') THEN
    NEW.publicado := true;
    IF NEW.publicado_en IS NULL THEN NEW.publicado_en := now(); END IF;
  ELSE
    NEW.publicado := false;
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_detalle_pub_sync ON te_pedidos_detalle;
CREATE TRIGGER tg_detalle_pub_sync BEFORE INSERT OR UPDATE ON te_pedidos_detalle
  FOR EACH ROW EXECUTE FUNCTION tg_sync_detalle_publicado();

-- ---------------------------------------------------------------------------
-- 6. Enriquecer tc_partidas_presupuestales (PEP) — ya tenía la base
-- ---------------------------------------------------------------------------
ALTER TABLE tc_partidas_presupuestales
  ADD COLUMN IF NOT EXISTS id_lugar_predeterminado uuid REFERENCES tc_sitios(id);
-- id_sociedad_propia, terceros, anio, id_unidad_negocio ya existen desde mig 002.

-- ---------------------------------------------------------------------------
-- 7. Funciones de negocio
-- ---------------------------------------------------------------------------

-- Libera un pedido: pasa todos sus detalles en borrador a liberado
-- (equivalente a PRC_liberarpedido del sistema Lobo)
CREATE OR REPLACE FUNCTION liberar_pedido(p_pedido uuid) RETURNS int AS $$
DECLARE n int := 0;
BEGIN
  UPDATE te_pedidos_detalle
    SET status_detalle = 'liberado',
        fecha_liberacion = now(),
        publicado = true,
        publicado_en = now()
    WHERE pedido_id = p_pedido AND status_detalle = 'borrador';
  GET DIAGNOSTICS n = ROW_COUNT;
  UPDATE te_pedidos SET status = 'liberado', modificado_en = now() WHERE id = p_pedido;
  RETURN n;
END $$ LANGUAGE plpgsql;

-- Convierte una requisición en pedido (transaccional)
CREATE OR REPLACE FUNCTION convertir_requisicion_a_pedido(
  p_requisicion uuid,
  p_titulo text,
  p_sitio_id uuid
) RETURNS uuid AS $$
DECLARE r te_requisicion_personal; nuevo_pedido_id uuid; nuevo_folio int;
BEGIN
  SELECT * INTO r FROM te_requisicion_personal WHERE id = p_requisicion;
  IF r.id IS NULL THEN RAISE EXCEPTION 'requisición no existe'; END IF;
  IF r.pedido_generado_id IS NOT NULL THEN
    RAISE EXCEPTION 'requisición % ya generó pedido %', p_requisicion, r.pedido_generado_id;
  END IF;
  nuevo_folio := siguiente_folio(r.tenant_id, 'pedido');
  INSERT INTO te_pedidos (
    tenant_id, folio, titulo, sitio_id, cliente_id, fecha_evento, requisicion_id
  ) VALUES (
    r.tenant_id, nuevo_folio, p_titulo, p_sitio_id, r.cliente_id, r.fecha_evento, r.id
  ) RETURNING id INTO nuevo_pedido_id;
  UPDATE te_requisicion_personal SET pedido_generado_id = nuevo_pedido_id, estatus = 'convertida'
    WHERE id = r.id;
  RETURN nuevo_pedido_id;
END $$ LANGUAGE plpgsql;

-- Recalcula porcentajes de cobertura del detalle (para semáforo verde/rojo)
CREATE OR REPLACE FUNCTION recalcular_cobertura_detalle(p_detalle uuid) RETURNS void AS $$
DECLARE cant int; res_real int; res_con_pre int;
BEGIN
  SELECT cantidad INTO cant FROM te_pedidos_detalle WHERE id = p_detalle;
  IF cant IS NULL OR cant <= 0 THEN RETURN; END IF;
  SELECT count(*) FILTER (WHERE estado NOT IN ('cancelado', 'preasignado', 'confirmado_opcional')) INTO res_real
    FROM te_reservaciones WHERE pedido_detalle_id = p_detalle;
  SELECT count(*) FILTER (WHERE estado NOT IN ('cancelado')) INTO res_con_pre
    FROM te_reservaciones WHERE pedido_detalle_id = p_detalle;
  UPDATE te_pedidos_detalle SET
    cantidad_reservados_real     = res_real,
    cantidad_reservados_con_pre  = res_con_pre,
    porcentaje_completo          = round(100.0 * res_real / cant, 2),
    porcentaje_completo_con_pre  = round(100.0 * res_con_pre / cant, 2)
  WHERE id = p_detalle;
END $$ LANGUAGE plpgsql;

-- Trigger: recalcular cobertura cuando cambia una reservación
CREATE OR REPLACE FUNCTION tg_reservacion_recalc_cobertura() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM recalcular_cobertura_detalle(OLD.pedido_detalle_id);
  ELSE
    PERFORM recalcular_cobertura_detalle(NEW.pedido_detalle_id);
  END IF;
  RETURN NULL;
END $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_res_recalc_cob ON te_reservaciones;
CREATE TRIGGER tg_res_recalc_cob AFTER INSERT OR UPDATE OF estado OR DELETE ON te_reservaciones
  FOR EACH ROW EXECUTE FUNCTION tg_reservacion_recalc_cobertura();

-- Precio efectivo: precio especial cliente si existe, sino precio base producto
CREATE OR REPLACE FUNCTION precio_efectivo(
  p_producto uuid, p_cliente uuid, p_fecha date DEFAULT CURRENT_DATE
) RETURNS numeric AS $$
DECLARE p numeric;
BEGIN
  SELECT precio_unit INTO p FROM tp_precios_especiales_cliente
    WHERE producto_id = p_producto AND cliente_id = p_cliente AND activo
      AND vigente_desde <= p_fecha AND (vigente_hasta IS NULL OR vigente_hasta >= p_fecha)
    ORDER BY vigente_desde DESC LIMIT 1;
  IF p IS NOT NULL THEN RETURN p; END IF;
  SELECT precio_unit INTO p FROM tp_precios_producto
    WHERE producto_id = p_producto AND (cliente_id IS NULL OR cliente_id = p_cliente)
      AND vigente_desde <= p_fecha AND (vigente_hasta IS NULL OR vigente_hasta >= p_fecha)
    ORDER BY vigente_desde DESC LIMIT 1;
  RETURN COALESCE(p, 0);
END $$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 8. GRANTS Supabase
-- ---------------------------------------------------------------------------
GRANT ALL ON tc_tipos_movimiento_pedido,
             tc_tipos_complejidad,
             tc_tipos_duracion_evento,
             tp_duraciones_evento,
             tp_precios_especiales_cliente,
             te_requisicion_personal
  TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION liberar_pedido(uuid),
                          convertir_requisicion_a_pedido(uuid,text,uuid),
                          recalcular_cobertura_detalle(uuid),
                          precio_efectivo(uuid,uuid,date)
  TO anon, authenticated, service_role;

-- RLS en las nuevas
ALTER TABLE tc_tipos_movimiento_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE tc_tipos_complejidad       ENABLE ROW LEVEL SECURITY;
ALTER TABLE tc_tipos_duracion_evento   ENABLE ROW LEVEL SECURITY;
ALTER TABLE tp_duraciones_evento       ENABLE ROW LEVEL SECURITY;
ALTER TABLE tp_precios_especiales_cliente ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['tc_tipos_movimiento_pedido','tc_tipos_complejidad',
                           'tc_tipos_duracion_evento','tp_duraciones_evento',
                           'tp_precios_especiales_cliente'] LOOP
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

-- ---------------------------------------------------------------------------
-- 9. Semillas para el tenant demo
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

INSERT INTO tc_tipos_movimiento_pedido (tenant_id, clave, titulo, se_factura) VALUES
  ('00000000-0000-0000-0000-000000000001', 'pedido', 'Pedido facturable a cliente', true),
  ('00000000-0000-0000-0000-000000000001', 'servicio_interno', 'Servicio interno (no factura)', false),
  ('00000000-0000-0000-0000-000000000001', 'orden_servicio', 'Orden de servicio', true)
ON CONFLICT DO NOTHING;

INSERT INTO tc_tipos_complejidad (tenant_id, clave, titulo, factor_costo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'foro_sol_1d', 'Foro Sol - 1 Día de Show', 1.00),
  ('00000000-0000-0000-0000-000000000001', 'foro_sol_2d', 'Foro Sol - 2 Días de Show', 1.20),
  ('00000000-0000-0000-0000-000000000001', 'palacio_1d',  'Palacio de los Deportes - 1 Día', 0.90),
  ('00000000-0000-0000-0000-000000000001', 'auditorio_1d','Auditorio Nacional - 1 Día', 0.85),
  ('00000000-0000-0000-0000-000000000001', 'teatro_1d',   'Teatro - 1 Día', 0.70),
  ('00000000-0000-0000-0000-000000000001', 'evento_gral', 'Evento genérico', 1.00)
ON CONFLICT DO NOTHING;

INSERT INTO tc_tipos_duracion_evento (tenant_id, clave, titulo, dias_minimos, dias_maximos) VALUES
  ('00000000-0000-0000-0000-000000000001', 'un_dia',      '1 Día',       1, 1),
  ('00000000-0000-0000-0000-000000000001', 'dos_dias',    '2 Días',      2, 2),
  ('00000000-0000-0000-0000-000000000001', 'fin_semana',  'Fin de semana', 2, 3),
  ('00000000-0000-0000-0000-000000000001', 'semana',      '1 Semana',    5, 7),
  ('00000000-0000-0000-0000-000000000001', 'quincena',    'Quincena',    10, 15),
  ('00000000-0000-0000-0000-000000000001', 'mes',         '1 Mes',       20, 31)
ON CONFLICT DO NOTHING;
