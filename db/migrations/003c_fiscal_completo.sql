-- ============================================================================
-- Migration 003c — Fiscal completo (facturación + pagos + honorarios + SAP)
-- ============================================================================

-- Enums
DO $$ BEGIN
  CREATE TYPE metodo_pago_enum AS ENUM ('efectivo','cheque','transferencia','tarjeta','otro');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE status_factura_enum AS ENUM ('borrador','emitida','pagada_parcial','pagada','cancelada');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 1. Cuentas bancarias múltiples por empleado (histórico)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_cuentas_bancarias_empleado (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id         uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  banco_id            uuid REFERENCES tc_bancos(id),
  numero_cuenta       text NOT NULL,
  clabe               text,
  tarjeta_debito      text,
  titular_nombre      text,
  es_principal        boolean NOT NULL DEFAULT false,
  vigente_desde       date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta       date,
  activo              boolean NOT NULL DEFAULT true,
  observaciones       text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_ctas_emp ON te_cuentas_bancarias_empleado(tenant_id, empleado_id, es_principal);
DROP TRIGGER IF EXISTS tg_aud_ctas ON te_cuentas_bancarias_empleado;
CREATE TRIGGER tg_aud_ctas BEFORE INSERT OR UPDATE ON te_cuentas_bancarias_empleado
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Request de cambio de cuenta (con aprobación)
CREATE TABLE IF NOT EXISTS te_cambio_cuenta_bancaria (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id         uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  banco_id_nuevo      uuid REFERENCES tc_bancos(id),
  numero_cuenta_nuevo text,
  clabe_nueva         text,
  motivo              text,
  status              text NOT NULL DEFAULT 'pendiente',    -- pendiente | aprobado | rechazado
  solicitado_en       timestamptz NOT NULL DEFAULT now(),
  aprobado_por        uuid,
  aprobado_en         timestamptz,
  observaciones       text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
DROP TRIGGER IF EXISTS tg_aud_ccb ON te_cambio_cuenta_bancaria;
CREATE TRIGGER tg_aud_ccb BEFORE INSERT OR UPDATE ON te_cambio_cuenta_bancaria
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. Series de folio de factura por sociedad propia
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_facturas_serie (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  sociedad_propia_id    uuid NOT NULL REFERENCES tc_sociedades_propias(id),
  tipo_movimiento_id    uuid REFERENCES tc_tipos_movimiento_pedido(id),
  serie                 text NOT NULL,
  ultimo_folio          int NOT NULL DEFAULT 0,
  prefijo_titulo        text,          -- ej: 'Lobo Factura No.'
  activo                boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, sociedad_propia_id, tipo_movimiento_id, serie)
);
DROP TRIGGER IF EXISTS tg_aud_fserie ON te_facturas_serie;
CREATE TRIGGER tg_aud_fserie BEFORE INSERT OR UPDATE ON te_facturas_serie
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Enriquecer te_facturas_enc con campos del sistema Lobo
ALTER TABLE te_facturas_enc
  ADD COLUMN IF NOT EXISTS serie_id            uuid REFERENCES te_facturas_serie(id),
  ADD COLUMN IF NOT EXISTS tipo_movimiento_id  uuid REFERENCES tc_tipos_movimiento_pedido(id),
  ADD COLUMN IF NOT EXISTS pedido_id           uuid REFERENCES te_pedidos(id),
  ADD COLUMN IF NOT EXISTS contacto_nombre     text,
  ADD COLUMN IF NOT EXISTS contacto_telefono   text,
  ADD COLUMN IF NOT EXISTS status_full         status_factura_enum NOT NULL DEFAULT 'borrador',
  ADD COLUMN IF NOT EXISTS numero_material_sap text,
  ADD COLUMN IF NOT EXISTS pep_id              uuid REFERENCES tc_partidas_presupuestales(id),
  ADD COLUMN IF NOT EXISTS lugar_cita_id       uuid REFERENCES tc_sitios(id),
  ADD COLUMN IF NOT EXISTS titulo_completo     text,
  ADD COLUMN IF NOT EXISTS enviada_sap_en      timestamptz;

-- Enriquecer te_facturas_det (partida)
ALTER TABLE te_facturas_det
  ADD COLUMN IF NOT EXISTS tipo_partida        text NOT NULL DEFAULT 'pedido_detalle',  -- pedido_detalle | texto_libre | agrupada
  ADD COLUMN IF NOT EXISTS producto_id         uuid REFERENCES tc_productos(id),
  ADD COLUMN IF NOT EXISTS turnos              numeric(5,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS iva                 numeric(14,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS agrupa_de_partidas  jsonb;   -- ids de partidas agrupadas

-- ---------------------------------------------------------------------------
-- 3. Pagos parciales de factura
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_pagos_factura (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  factura_id          uuid NOT NULL REFERENCES te_facturas_enc(id) ON DELETE CASCADE,
  monto               numeric(14,2) NOT NULL,
  metodo              metodo_pago_enum NOT NULL,
  referencia          text,           -- número de cheque o transferencia
  banco               text,
  fecha_pago          date NOT NULL DEFAULT CURRENT_DATE,
  observaciones       text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (monto > 0),
  CHECK (metodo IN ('efectivo','tarjeta','otro') OR (referencia IS NOT NULL AND length(referencia) > 0))
);
CREATE INDEX IF NOT EXISTS ix_pgfa ON te_pagos_factura(tenant_id, factura_id);
DROP TRIGGER IF EXISTS tg_aud_pgfa ON te_pagos_factura;
CREATE TRIGGER tg_aud_pgfa BEFORE INSERT OR UPDATE ON te_pagos_factura
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Trigger: cuando el pago acumulado ≥ total → status 'pagada'
CREATE OR REPLACE FUNCTION tg_pagofact_update_status() RETURNS trigger AS $$
DECLARE tot numeric; pagado numeric;
BEGIN
  SELECT total INTO tot FROM te_facturas_enc WHERE id = NEW.factura_id;
  SELECT COALESCE(sum(monto), 0) INTO pagado FROM te_pagos_factura WHERE factura_id = NEW.factura_id;
  IF pagado >= tot THEN
    UPDATE te_facturas_enc SET status_full = 'pagada', status = 'pagada' WHERE id = NEW.factura_id;
  ELSIF pagado > 0 THEN
    UPDATE te_facturas_enc SET status_full = 'pagada_parcial' WHERE id = NEW.factura_id;
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_pgfa_status ON te_pagos_factura;
CREATE TRIGGER tg_pgfa_status AFTER INSERT ON te_pagos_factura
  FOR EACH ROW EXECUTE FUNCTION tg_pagofact_update_status();

-- ---------------------------------------------------------------------------
-- 4. Export SAP por lote
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_export_sap_lote (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  sociedad_propia_id    uuid NOT NULL REFERENCES tc_sociedades_propias(id),
  folio_desde           int NOT NULL,
  folio_hasta           int NOT NULL,
  cnt_facturas          int NOT NULL DEFAULT 0,
  archivo_txt_url       text,
  enviado_a_email       text,
  enviado_en            timestamptz,
  status                text NOT NULL DEFAULT 'pendiente',   -- pendiente | generado | enviado | error
  error_msg             text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (folio_hasta >= folio_desde)
);
DROP TRIGGER IF EXISTS tg_aud_esap ON te_export_sap_lote;
CREATE TRIGGER tg_aud_esap BEFORE INSERT OR UPDATE ON te_export_sap_lote
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 5. Enriquecer te_pagos_dispersion (pagos honorarios) con conceptos fiscales
-- ---------------------------------------------------------------------------
ALTER TABLE te_pagos_dispersion
  ADD COLUMN IF NOT EXISTS regimen              regimen_pago_enum,
  ADD COLUMN IF NOT EXISTS periodo_id           uuid REFERENCES te_nominas_periodo(id),
  ADD COLUMN IF NOT EXISTS dias_laborados       numeric(5,2),
  ADD COLUMN IF NOT EXISTS pago_bruto           numeric(14,2),
  -- Conceptos fiscales (10) del sistema Lobo
  ADD COLUMN IF NOT EXISTS sdp                  numeric(14,2),   -- Salario Diario Promedio
  ADD COLUMN IF NOT EXISTS im                   numeric(14,2),
  ADD COLUMN IF NOT EXISTS cf                   numeric(14,2),
  ADD COLUMN IF NOT EXISTS sa                   numeric(14,2),
  ADD COLUMN IF NOT EXISTS cg                   numeric(14,2),
  ADD COLUMN IF NOT EXISTS impuesto_diario      numeric(14,2),
  ADD COLUMN IF NOT EXISTS it                   numeric(14,2),
  ADD COLUMN IF NOT EXISTS iva                  numeric(14,2),
  ADD COLUMN IF NOT EXISTS riva                 numeric(14,2),
  ADD COLUMN IF NOT EXISTS risr                 numeric(14,2),
  ADD COLUMN IF NOT EXISTS pago_neto            numeric(14,2),
  -- 4 validaciones "cumple regla"
  ADD COLUMN IF NOT EXISTS cumple_reglas               boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cumple_regla_banco          boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cumple_regla_ultimo_pago    boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cumple_regla_recibe_periodo boolean NOT NULL DEFAULT false,
  -- Auditoría fiscal
  ADD COLUMN IF NOT EXISTS empresa_pagadora_id  uuid REFERENCES tc_sociedades_pagadoras(id),
  ADD COLUMN IF NOT EXISTS puesto_principal_id  uuid REFERENCES tc_puestos(id),
  ADD COLUMN IF NOT EXISTS unidad_negocio_id    uuid REFERENCES tc_unidades_negocio(id),
  ADD COLUMN IF NOT EXISTS sociedad_propia_id   uuid REFERENCES tc_sociedades_propias(id),
  ADD COLUMN IF NOT EXISTS solicitud_pago       text,
  ADD COLUMN IF NOT EXISTS observaciones        text;

-- ---------------------------------------------------------------------------
-- 6. Sueldos matriciales (tabulador)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tp_sueldos_matriciales (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  puesto_id             uuid NOT NULL REFERENCES tc_puestos(id),
  tipo_complejidad_id   uuid REFERENCES tc_tipos_complejidad(id),
  tipo_duracion_id      uuid REFERENCES tc_tipos_duracion_evento(id),
  turnos                numeric(5,2) NOT NULL DEFAULT 1,
  sueldo_base           numeric(12,2) NOT NULL,
  factor                numeric(5,3) NOT NULL DEFAULT 1.0,
  vigente_desde         date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta         date,
  activo                boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_smx ON tp_sueldos_matriciales(tenant_id, puesto_id, vigente_desde);
DROP TRIGGER IF EXISTS tg_aud_smx ON tp_sueldos_matriciales;
CREATE TRIGGER tg_aud_smx BEFORE INSERT OR UPDATE ON tp_sueldos_matriciales
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 7. Catálogo estático de precauciones de nómina
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tp_nomina_precauciones_catalogo (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave             text NOT NULL,
  mensaje           text NOT NULL,
  responsable_area  text,
  activo            boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_prec ON tp_nomina_precauciones_catalogo;
CREATE TRIGGER tg_aud_prec BEFORE INSERT OR UPDATE ON tp_nomina_precauciones_catalogo
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 8. Función: obtener siguiente folio de factura por serie
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION siguiente_folio_factura(p_serie uuid) RETURNS int AS $$
DECLARE nuevo int;
BEGIN
  UPDATE te_facturas_serie SET ultimo_folio = ultimo_folio + 1, modificado_en = now()
    WHERE id = p_serie
    RETURNING ultimo_folio INTO nuevo;
  IF nuevo IS NULL THEN RAISE EXCEPTION 'Serie de factura no existe.'; END IF;
  RETURN nuevo;
END $$ LANGUAGE plpgsql;

-- Función: crear factura desde selección de pedidos_detalle facturables
CREATE OR REPLACE FUNCTION crear_factura_desde_detalles(
  p_tenant uuid,
  p_pedido uuid,
  p_sociedad_propia uuid,
  p_tipo_movimiento uuid,
  p_serie uuid,
  p_detalles_ids uuid[]
) RETURNS uuid AS $$
DECLARE
  cliente_id_var uuid; folio_nuevo int; nueva_fact uuid;
  fila record; precio_unit numeric; imp numeric;
  subt numeric := 0; ivt numeric := 0;
BEGIN
  SELECT cliente_id INTO cliente_id_var FROM te_pedidos WHERE id = p_pedido AND tenant_id = p_tenant;
  IF cliente_id_var IS NULL THEN RAISE EXCEPTION 'Pedido no existe o sin cliente.'; END IF;

  folio_nuevo := siguiente_folio_factura(p_serie);
  INSERT INTO te_facturas_enc (
    tenant_id, folio, serie_id, tipo_movimiento_id, pedido_id, cliente_id,
    sociedad_propia_id, fecha_emision, status_full, status
  ) VALUES (
    p_tenant, folio_nuevo, p_serie, p_tipo_movimiento, p_pedido, cliente_id_var,
    p_sociedad_propia, CURRENT_DATE, 'borrador', 'borrador'
  ) RETURNING id INTO nueva_fact;

  FOR fila IN
    SELECT pd.id, pd.producto_id, pd.cantidad, pd.turnos, pd.precio
    FROM te_pedidos_detalle pd
    WHERE pd.id = ANY(p_detalles_ids) AND pd.pedido_id = p_pedido AND pd.facturable = true
      AND pd.folio_factura IS NULL
  LOOP
    precio_unit := COALESCE(fila.precio,
      precio_efectivo(fila.producto_id, cliente_id_var, CURRENT_DATE));
    IF fila.turnos > 0 THEN
      imp := fila.cantidad * fila.turnos * precio_unit;
    ELSE
      imp := fila.cantidad * precio_unit;
    END IF;
    INSERT INTO te_facturas_det (
      tenant_id, factura_id, reservacion_id, tipo_partida, producto_id,
      concepto, cantidad, turnos, precio_unit, importe, iva
    ) VALUES (
      p_tenant, nueva_fact, NULL, 'pedido_detalle', fila.producto_id,
      'Detalle pedido #' || fila.id::text, fila.cantidad, fila.turnos,
      precio_unit, imp, imp * 0.16
    );
    subt := subt + imp;
    ivt := ivt + (imp * 0.16);
    -- marcar detalle como facturado
    UPDATE te_pedidos_detalle SET folio_factura = folio_nuevo, status_detalle = 'facturado'
      WHERE id = fila.id;
  END LOOP;

  UPDATE te_facturas_enc SET subtotal = subt, iva = ivt, total = subt + ivt WHERE id = nueva_fact;
  RETURN nueva_fact;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION siguiente_folio_factura(uuid),
                          crear_factura_desde_detalles(uuid,uuid,uuid,uuid,uuid,uuid[])
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 9. RLS + GRANTS
-- ---------------------------------------------------------------------------
ALTER TABLE te_cuentas_bancarias_empleado ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_cambio_cuenta_bancaria     ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_facturas_serie             ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_pagos_factura              ENABLE ROW LEVEL SECURITY;
ALTER TABLE te_export_sap_lote            ENABLE ROW LEVEL SECURITY;
ALTER TABLE tp_sueldos_matriciales        ENABLE ROW LEVEL SECURITY;
ALTER TABLE tp_nomina_precauciones_catalogo ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_cuentas_bancarias_empleado','te_cambio_cuenta_bancaria',
                           'te_facturas_serie','te_pagos_factura','te_export_sap_lote',
                           'tp_sueldos_matriciales','tp_nomina_precauciones_catalogo'] LOOP
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

GRANT ALL ON te_cuentas_bancarias_empleado, te_cambio_cuenta_bancaria,
             te_facturas_serie, te_pagos_factura, te_export_sap_lote,
             tp_sueldos_matriciales, tp_nomina_precauciones_catalogo
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 10. Semillas
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

-- Series de folio por sociedad (dummy — se completan cuando el tenant real las tenga)
INSERT INTO tp_nomina_precauciones_catalogo (tenant_id, clave, mensaje, responsable_area) VALUES
  ('00000000-0000-0000-0000-000000000001', 'sin_banco',     'Empleado sin banco asignado, no se puede dispersar.', 'RRHH'),
  ('00000000-0000-0000-0000-000000000001', 'sin_clabe',     'Empleado sin CLABE, no se puede dispersar por transferencia.', 'RRHH'),
  ('00000000-0000-0000-0000-000000000001', 'sin_regimen',   'Empleado sin régimen de pago capturado.', 'RRHH'),
  ('00000000-0000-0000-0000-000000000001', 'sin_pagadora',  'Empleado sin sociedad pagadora asignada.', 'RRHH'),
  ('00000000-0000-0000-0000-000000000001', 'ultimo_pago_hace_mucho', 'Empleado sin pagos en los últimos 3 periodos — validar si sigue activo.', 'Nómina'),
  ('00000000-0000-0000-0000-000000000001', 'reservacion_sin_procesar', 'Existen reservaciones del periodo sin procesar (falta asistencia).', 'Operación'),
  ('00000000-0000-0000-0000-000000000001', 'penalizacion_pendiente', 'Existen penalizaciones pendientes de aprobar/revertir.', 'Nómina')
ON CONFLICT DO NOTHING;
