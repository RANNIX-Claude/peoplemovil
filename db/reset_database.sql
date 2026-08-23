-- ============================================================================
-- PeopleMovil 2.0 — Reset Database
-- ============================================================================
-- Motor: Postgres 15+ (Supabase compatible).
-- Este script:
--   1. Elimina y recrea todo el schema `public` limpio.
--   2. Crea extensiones, enums, tablas, funciones, triggers y RLS.
--   3. Traduce con fidelidad los procedimientos PRC_* del sistema Lobo/AppSCPF
--      (GeneXus) a funciones/triggers de Postgres. Ver comentarios "PRC origen:".
--   4. Inserta semillas reales de los .xlsx del sistema original y crea un
--      tenant demo con plan PRO para pruebas.
--
-- Principios respetados:
--   * Ningún parámetro de negocio hardcodeado en código → todo en catálogos.
--   * Append-only en eventos_biometricos, consentimientos, reservacion_bitacora.
--   * Timestamp de servidor forzado por trigger.
--   * Multi-tenant con RLS por tenant_id en todas las tablas.
--   * Auditoría (created_at/by, updated_at/by, regla_aplicada).
--   * Verificación de plan del tenant a nivel trigger (no bypasseable por API).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0. Reset limpio
-- ---------------------------------------------------------------------------
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ---------------------------------------------------------------------------
-- 1. Enums de dominio
-- ---------------------------------------------------------------------------
CREATE TYPE regimen_pago_enum AS ENUM (
  'Nomina',
  'Honorarios Normales',
  'Honorarios Asimilables'
);

CREATE TYPE ciclo_pago_enum AS ENUM ('Semanal', 'Quincenal', 'Mensual');

CREATE TYPE tipo_sitio_enum AS ENUM (
  'sucursal', 'tienda', 'obra', 'foro', 'oficina', 'evento', 'otro'
);

CREATE TYPE tipo_dispositivo_enum AS ENUM ('fijo', 'movil');

CREATE TYPE medio_asistencia_enum AS ENUM ('biometrico', 'manual', 'geolocalizacion');

CREATE TYPE estado_reservacion_enum AS ENUM (
  'disponible',
  'preasignado',
  'confirmado_opcional',
  'confirmado_voluntario',
  'forzada',
  'procesado',
  'cancelado'
);

CREATE TYPE estado_asistencia_enum AS ENUM (
  'pendiente', 'asistencia', 'retardo', 'falta'
);

CREATE TYPE estatus_pago_enum AS ENUM (
  'pendiente', 'calculado', 'dispersado', 'pagado', 'cancelado'
);

CREATE TYPE sexo_enum AS ENUM ('M', 'F', 'X');

CREATE TYPE plan_codigo_enum AS ENUM ('FREE', 'PRO');

-- ---------------------------------------------------------------------------
-- 2. Helpers de sesión y auditoría
-- ---------------------------------------------------------------------------

-- Cada request de Supabase define app.current_tenant vía SET LOCAL o via JWT claim.
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS uuid AS $$
BEGIN
  RETURN NULLIF(current_setting('app.current_tenant', true), '')::uuid;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION current_user_id() RETURNS uuid AS $$
BEGIN
  RETURN COALESCE(
    NULLIF(current_setting('app.current_user', true), '')::uuid,
    NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
  );
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END $$ LANGUAGE plpgsql STABLE;

-- Trigger genérico de auditoría
CREATE OR REPLACE FUNCTION tg_touch_audit() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_at := now();
    NEW.created_by := COALESCE(NEW.created_by, current_user_id());
    NEW.updated_at := now();
    NEW.updated_by := COALESCE(NEW.updated_by, current_user_id());
    IF NEW.tenant_id IS NULL THEN
      NEW.tenant_id := current_tenant_id();
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.created_at := OLD.created_at;
    NEW.created_by := OLD.created_by;
    NEW.tenant_id  := OLD.tenant_id;
    NEW.updated_at := now();
    NEW.updated_by := COALESCE(current_user_id(), OLD.updated_by);
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;

-- Trigger que bloquea UPDATE/DELETE (para tablas append-only)
CREATE OR REPLACE FUNCTION tg_deny_mutations() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Tabla append-only: % no permitido en %', TG_OP, TG_TABLE_NAME
    USING ERRCODE = 'insufficient_privilege';
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 3. Tenants + planes de suscripción
-- ---------------------------------------------------------------------------

CREATE TABLE tenants (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  razon_social  text NOT NULL,
  rfc           text,
  vertical      text,   -- 'seguridad', 'eventos', 'construccion', 'retail', 'otro'
  activo        boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cat_plan_suscripcion (
  codigo                 plan_codigo_enum PRIMARY KEY,
  titulo                 text NOT NULL,
  descripcion            text,
  max_sitios             int,     -- NULL = ilimitado
  max_empleados_activos  int,     -- NULL = ilimitado
  incluye_checador_fijo  boolean NOT NULL DEFAULT true,
  incluye_checador_movil boolean NOT NULL DEFAULT false,
  incluye_asignacion     boolean NOT NULL DEFAULT false,
  incluye_certeza        boolean NOT NULL DEFAULT false,
  incluye_nomina         boolean NOT NULL DEFAULT false,
  incluye_repse          boolean NOT NULL DEFAULT false,
  precio_mensual_mxn     numeric(10,2)
);

CREATE TABLE suscripciones (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plan_codigo   plan_codigo_enum NOT NULL REFERENCES cat_plan_suscripcion(codigo),
  vigente_desde timestamptz NOT NULL DEFAULT now(),
  vigente_hasta timestamptz,   -- NULL = vigente indefinidamente
  activa        boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ix_suscripciones_tenant_activa ON suscripciones (tenant_id) WHERE activa;

-- Lee el plan activo del tenant (o FREE por default si no tiene ninguno).
CREATE OR REPLACE FUNCTION plan_activo(p_tenant uuid)
RETURNS cat_plan_suscripcion AS $$
DECLARE r cat_plan_suscripcion;
BEGIN
  SELECT p.* INTO r
  FROM suscripciones s
  JOIN cat_plan_suscripcion p ON p.codigo = s.plan_codigo
  WHERE s.tenant_id = p_tenant
    AND s.activa
    AND (s.vigente_hasta IS NULL OR s.vigente_hasta > now())
  ORDER BY s.vigente_desde DESC
  LIMIT 1;
  IF NOT FOUND THEN
    SELECT * INTO r FROM cat_plan_suscripcion WHERE codigo = 'FREE';
  END IF;
  RETURN r;
END $$ LANGUAGE plpgsql STABLE;

-- Chequea límite de una capacidad y lanza excepción si se rebasa.
CREATE OR REPLACE FUNCTION verificar_limite(p_tenant uuid, p_recurso text)
RETURNS void AS $$
DECLARE
  p cat_plan_suscripcion;
  usados int;
BEGIN
  p := plan_activo(p_tenant);
  IF p_recurso = 'sitios' THEN
    IF p.max_sitios IS NULL THEN RETURN; END IF;
    SELECT count(*) INTO usados FROM cat_sitios WHERE tenant_id = p_tenant AND activo;
    IF usados >= p.max_sitios THEN
      RAISE EXCEPTION 'Plan % permite máx % sitios; ya tiene %', p.codigo, p.max_sitios, usados
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'empleados' THEN
    IF p.max_empleados_activos IS NULL THEN RETURN; END IF;
    SELECT count(*) INTO usados FROM empleados WHERE tenant_id = p_tenant AND activo;
    IF usados >= p.max_empleados_activos THEN
      RAISE EXCEPTION 'Plan % permite máx % empleados; ya tiene %', p.codigo, p.max_empleados_activos, usados
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'checador_movil' THEN
    IF NOT p.incluye_checador_movil THEN
      RAISE EXCEPTION 'Plan % no incluye checador móvil (upgrade a PRO)', p.codigo
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'asignacion' THEN
    IF NOT p.incluye_asignacion THEN
      RAISE EXCEPTION 'Plan % no incluye módulo de asignación/pedidos', p.codigo
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'nomina' THEN
    IF NOT p.incluye_nomina THEN
      RAISE EXCEPTION 'Plan % no incluye módulo de nómina/honorarios', p.codigo
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'repse' THEN
    IF NOT p.incluye_repse THEN
      RAISE EXCEPTION 'Plan % no incluye módulo REPSE', p.codigo
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  END IF;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 4. Catálogos maestros
-- ---------------------------------------------------------------------------

-- Parámetros globales a nivel tenant — los únicos números que en el KB original
-- estaban hardcodeados (72h lookahead + 8h gracia en PRC_CancelacionAutomaticaPreasignados)
-- se mueven aquí para preservar el principio "cero parámetros de negocio en código".
CREATE TABLE cat_parametros_globales (
  tenant_id                    uuid PRIMARY KEY REFERENCES tenants(id) ON DELETE CASCADE,
  horas_lookahead_autocancel   int NOT NULL DEFAULT 72,
  horas_gracia_confirmacion    int NOT NULL DEFAULT 8,
  retencion_registros_dias     int NOT NULL DEFAULT 1825,  -- 5 años
  certeza_inicial_default      numeric(4,3) NOT NULL DEFAULT 1.000,
  aviso_privacidad_version     text NOT NULL DEFAULT 'v1.0',
  created_at                   timestamptz NOT NULL DEFAULT now(),
  updated_at                   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cat_bancos (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  clave       text NOT NULL,
  nombre      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now(),
  created_by  uuid,
  updated_at  timestamptz NOT NULL DEFAULT now(),
  updated_by  uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_audit_bancos BEFORE INSERT OR UPDATE ON cat_bancos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_sociedades_pagadoras (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy                   int,
  titulo                      text NOT NULL,
  id_empresa_pagadora_legacy  int,
  numero_sociedad             int,
  activo                      boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_soc_pag BEFORE INSERT OR UPDATE ON cat_sociedades_pagadoras
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_sociedades_propias (
  id                              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                       uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy                       int,
  titulo                          text NOT NULL,
  razon_social                    text,
  vigente                         boolean NOT NULL DEFAULT true,
  genera_factura                  boolean NOT NULL DEFAULT true,
  genera_orden_servicio           boolean NOT NULL DEFAULT false,
  id_sociedad_pagadora_legacy     int,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_soc_pro BEFORE INSERT OR UPDATE ON cat_sociedades_propias
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_unidades_negocio (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy   int,
  titulo      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, titulo)
);
CREATE TRIGGER tg_audit_un BEFORE INSERT OR UPDATE ON cat_unidades_negocio
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- SITIOS — generalización [G] de sucursal/foro/tienda/obra/oficina
CREATE TABLE cat_sitios (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy             int,
  titulo                text NOT NULL,
  tipo_sitio            tipo_sitio_enum NOT NULL DEFAULT 'sucursal',
  direccion             text,
  direccion_abreviada   text,
  telefonos             text,
  latitud               numeric(9,6),
  longitud              numeric(9,6),
  activo                boolean NOT NULL DEFAULT true,
  id_unidad_negocio     uuid REFERENCES cat_unidades_negocio(id),
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE INDEX ix_sitios_tenant ON cat_sitios(tenant_id) WHERE activo;
CREATE TRIGGER tg_audit_sitios BEFORE INSERT OR UPDATE ON cat_sitios
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- Trigger: verifica límite de sitios del plan al INSERT
CREATE OR REPLACE FUNCTION tg_check_sitios_limite() RETURNS trigger AS $$
BEGIN
  IF NEW.activo THEN
    PERFORM verificar_limite(NEW.tenant_id, 'sitios');
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_sitios_limite BEFORE INSERT ON cat_sitios
  FOR EACH ROW EXECUTE FUNCTION tg_check_sitios_limite();

-- PUESTOS — TODOS los parámetros de negocio viven aquí (heredado del principio
-- TC_Puestos* del sistema Lobo: certeza, márgenes, penalizaciones editables).
CREATE TABLE cat_puestos (
  id                            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                     uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy                     int,
  titulo                        text NOT NULL,
  pago_default                  numeric(12,2) NOT NULL DEFAULT 0,
  id_unidad_negocio_legacy      int,
  duracion_turno_horas          numeric(5,2) NOT NULL DEFAULT 8,
  horas_entre_turnos            numeric(5,2) NOT NULL DEFAULT 0,   -- margen [PRC_Noempalmereservacion]
  horas_antes_cancelar          numeric(6,2) NOT NULL DEFAULT 72,  -- [PRC_ValidacionesCancelarReservacion]
  porcentaje_certeza_inicial    numeric(4,3) NOT NULL DEFAULT 1.0, -- [PRC_ObtenerCertezaPuesto]
  porcentaje_minimo             numeric(4,3) NOT NULL DEFAULT 0.6, -- [PRC_ValidaEmpPuesto]
  dias_sin_confirmar            int NOT NULL DEFAULT 30,
  requiere_biometrico           boolean NOT NULL DEFAULT true,
  tipo_registro_asistencia      text NOT NULL DEFAULT 'Requiere Entrada y Salida',
  penalizacion_retardo          numeric(6,3) NOT NULL DEFAULT -0.5,
  penalizacion_falta            numeric(6,3) NOT NULL DEFAULT -1.0,
  ciclo_pago                    ciclo_pago_enum NOT NULL DEFAULT 'Semanal',
  regimen_pago                  regimen_pago_enum NOT NULL DEFAULT 'Honorarios Normales',
  sexo_requerido                sexo_enum,   -- NULL = cualquiera
  id_empresa_pagadora_legacy    int,
  activo                        boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE INDEX ix_puestos_tenant ON cat_puestos(tenant_id) WHERE activo;
CREATE TRIGGER tg_audit_puestos BEFORE INSERT OR UPDATE ON cat_puestos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_uniformes (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                 uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy                 int,
  titulo                    text NOT NULL,
  titulo_abreviado          text,
  id_unidad_negocio_legacy  int,
  id_uniforme_a             int,
  id_uniforme_b             int,
  id_uniforme_c             int,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_unif BEFORE INSERT OR UPDATE ON cat_uniformes
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_clientes (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy     int,
  razon_social  text NOT NULL,
  abreviacion   text,
  rfc           text,
  correo        text,
  telefono      text,
  activo        boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_cli BEFORE INSERT OR UPDATE ON cat_clientes
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE cat_productos (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  id_legacy      int,
  titulo         text NOT NULL,
  subcategoria   text,
  id_puesto      uuid REFERENCES cat_puestos(id),
  vigente        boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_prod BEFORE INSERT OR UPDATE ON cat_productos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- ---------------------------------------------------------------------------
-- 5. Personas
-- ---------------------------------------------------------------------------

CREATE TABLE candidatos (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nombres               text NOT NULL,
  apellido_paterno      text NOT NULL,
  apellido_materno      text,
  rfc                   text,
  curp                  text,
  fecha_nacimiento      date,
  sexo                  sexo_enum,
  telefono              text,
  correo                text,
  direccion             text,
  estatura_cm           int,
  talla                 text,
  ine                   text,
  paso_induccion        boolean NOT NULL DEFAULT false,
  paso_evento_prueba    boolean NOT NULL DEFAULT false,
  promovido_a_empleado  boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, rfc),
  UNIQUE (tenant_id, curp)
);
CREATE TRIGGER tg_audit_cand BEFORE INSERT OR UPDATE ON candidatos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- PRC_ValidaRfcCurp: la UNIQUE (tenant_id, rfc/curp) ya lo hace a nivel schema.
-- La función explícita permite chequeo previo desde app con mejor mensaje.
CREATE OR REPLACE FUNCTION valida_rfc_curp(p_tenant uuid, p_rfc text, p_curp text)
RETURNS boolean AS $$
DECLARE existe boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM candidatos
    WHERE tenant_id = p_tenant
      AND ((p_rfc IS NOT NULL AND rfc = p_rfc) OR (p_curp IS NOT NULL AND curp = p_curp))
  ) INTO existe;
  RETURN NOT existe;
END $$ LANGUAGE plpgsql STABLE;

CREATE TABLE empleados (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  folio                  int NOT NULL,
  candidato_origen_id    uuid REFERENCES candidatos(id),
  nombres                text NOT NULL,
  apellido_paterno       text NOT NULL,
  apellido_materno       text,
  rfc                    text,
  curp                   text,
  fecha_nacimiento       date,
  sexo                   sexo_enum,
  telefono               text,
  correo                 text,
  direccion              text,
  id_banco               uuid REFERENCES cat_bancos(id),
  cuenta_bancaria        text,
  clabe                  text,
  id_sociedad_pagadora   uuid REFERENCES cat_sociedades_pagadoras(id),
  id_puesto_principal    uuid REFERENCES cat_puestos(id),
  id_sitio_principal     uuid REFERENCES cat_sitios(id),
  regimen_pago           regimen_pago_enum NOT NULL DEFAULT 'Honorarios Normales',
  ciclo_pago             ciclo_pago_enum NOT NULL DEFAULT 'Semanal',
  consentimiento_id      uuid,   -- FK diferida (consentimientos definidos después)
  activo                 boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, folio),
  UNIQUE (tenant_id, rfc),
  UNIQUE (tenant_id, curp)
);
CREATE INDEX ix_empleados_tenant_activo ON empleados(tenant_id) WHERE activo;
CREATE TRIGGER tg_audit_emp BEFORE INSERT OR UPDATE ON empleados
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- Verifica límite de empleados del plan
CREATE OR REPLACE FUNCTION tg_check_empleados_limite() RETURNS trigger AS $$
BEGIN
  IF NEW.activo THEN
    PERFORM verificar_limite(NEW.tenant_id, 'empleados');
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_empleados_limite BEFORE INSERT ON empleados
  FOR EACH ROW EXECUTE FUNCTION tg_check_empleados_limite();

-- Relación N:N: un empleado puede tener múltiples plazas/puestos
CREATE TABLE empleados_plazas (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  empleado_id            uuid NOT NULL REFERENCES empleados(id) ON DELETE CASCADE,
  puesto_id              uuid NOT NULL REFERENCES cat_puestos(id),
  porcentaje_puntualidad numeric(4,3),  -- certeza acumulada POR PUESTO (PRC_ObtenerCertezaPuesto)
  activo                 boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, empleado_id, puesto_id)
);
CREATE TRIGGER tg_audit_epl BEFORE INSERT OR UPDATE ON empleados_plazas
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- Aviso de privacidad versionado (una fila por versión publicada)
CREATE TABLE avisos_privacidad (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  version      text NOT NULL,
  texto        text NOT NULL,
  vigente_desde timestamptz NOT NULL DEFAULT now(),
  vigente_hasta timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  created_by   uuid,
  UNIQUE (tenant_id, version)
);

-- CONSENTIMIENTOS — append-only.
-- Cada firma es un registro nuevo. Una revocación = nueva fila con revoca_id apuntando al original.
CREATE TABLE consentimientos (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  empleado_id           uuid REFERENCES empleados(id),
  candidato_id          uuid REFERENCES candidatos(id),
  aviso_privacidad_id   uuid NOT NULL REFERENCES avisos_privacidad(id),
  acepta                boolean NOT NULL,
  revoca_id             uuid REFERENCES consentimientos(id),  -- si != NULL, es la revocación
  firmado_en            timestamptz NOT NULL DEFAULT now(),
  ip_firma              inet,
  user_agent            text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  created_by            uuid,
  CHECK (empleado_id IS NOT NULL OR candidato_id IS NOT NULL)
);
CREATE INDEX ix_consent_emp ON consentimientos(tenant_id, empleado_id);
-- APPEND-ONLY: bloqueo de UPDATE/DELETE
CREATE TRIGGER tg_consent_ins BEFORE UPDATE OR DELETE ON consentimientos
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- FK diferida de empleados.consentimiento_id → consentimientos
ALTER TABLE empleados
  ADD CONSTRAINT fk_emp_consent FOREIGN KEY (consentimiento_id) REFERENCES consentimientos(id);

-- Devuelve el consentimiento vigente (no revocado) de un empleado
CREATE OR REPLACE FUNCTION consentimiento_vigente(p_empleado uuid)
RETURNS uuid AS $$
DECLARE r uuid;
BEGIN
  SELECT c.id INTO r
  FROM consentimientos c
  WHERE c.empleado_id = p_empleado
    AND c.acepta = true
    AND NOT EXISTS (
      SELECT 1 FROM consentimientos rv WHERE rv.revoca_id = c.id
    )
  ORDER BY c.firmado_en DESC
  LIMIT 1;
  RETURN r;
END $$ LANGUAGE plpgsql STABLE;

-- Estaciones físicas de checado
CREATE TABLE estaciones_checado (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  sitio_id     uuid NOT NULL REFERENCES cat_sitios(id) ON DELETE CASCADE,
  nombre       text NOT NULL,
  activa       boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_est BEFORE INSERT OR UPDATE ON estaciones_checado
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- Dispositivos biométricos (número de serie del lector es lo que da trazabilidad legal)
CREATE TABLE dispositivos_biometricos (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero_serie        text NOT NULL,
  modelo              text,
  tipo                tipo_dispositivo_enum NOT NULL DEFAULT 'fijo',
  estacion_id         uuid REFERENCES estaciones_checado(id),
  activo              boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, numero_serie)
);
CREATE TRIGGER tg_audit_disp BEFORE INSERT OR UPDATE ON dispositivos_biometricos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- ---------------------------------------------------------------------------
-- 6. Operativo: pedidos, reservaciones, eventos biométricos
-- ---------------------------------------------------------------------------

CREATE TABLE pedidos (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  folio                int NOT NULL,
  titulo               text NOT NULL,
  sitio_id             uuid NOT NULL REFERENCES cat_sitios(id),
  cliente_id           uuid REFERENCES cat_clientes(id),
  id_sociedad_propia   uuid REFERENCES cat_sociedades_propias(id),
  unidad_negocio_id    uuid REFERENCES cat_unidades_negocio(id),
  fecha_evento         date NOT NULL,
  hora_inicio          timetz,
  hora_fin             timetz,
  status               text NOT NULL DEFAULT 'borrador',
  costo_estimado       numeric(14,2),
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  UNIQUE (tenant_id, folio)
);
CREATE INDEX ix_pedidos_fecha ON pedidos(tenant_id, fecha_evento);
CREATE TRIGGER tg_audit_ped BEFORE INSERT OR UPDATE ON pedidos
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- Solo tenants con plan que incluya asignación pueden crear pedidos
CREATE OR REPLACE FUNCTION tg_check_asignacion_plan() RETURNS trigger AS $$
BEGIN
  PERFORM verificar_limite(NEW.tenant_id, 'asignacion');
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_pedidos_plan BEFORE INSERT ON pedidos
  FOR EACH ROW EXECUTE FUNCTION tg_check_asignacion_plan();

CREATE TABLE pedidos_detalle (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  pedido_id     uuid NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  puesto_id     uuid NOT NULL REFERENCES cat_puestos(id),
  cantidad      int NOT NULL CHECK (cantidad > 0),
  costo_unit    numeric(12,2),
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_ped_det BEFORE INSERT OR UPDATE ON pedidos_detalle
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- RESERVACIONES — tabla central (una persona × un turno)
CREATE TABLE reservaciones (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  pedido_id                uuid NOT NULL REFERENCES pedidos(id),
  pedido_detalle_id        uuid REFERENCES pedidos_detalle(id),
  empleado_id              uuid NOT NULL REFERENCES empleados(id),
  puesto_id                uuid NOT NULL REFERENCES cat_puestos(id),
  sitio_id                 uuid NOT NULL REFERENCES cat_sitios(id),
  estado                   estado_reservacion_enum NOT NULL DEFAULT 'preasignado',
  cita_inicio              timestamptz NOT NULL,
  cita_fin                 timestamptz NOT NULL,
  duracion_en_turnos       numeric(4,2) NOT NULL DEFAULT 1,
  estado_asistencia        estado_asistencia_enum NOT NULL DEFAULT 'pendiente',
  hora_entrada_real        timestamptz,
  hora_salida_real         timestamptz,
  estacion_entrada_id      uuid REFERENCES estaciones_checado(id),
  estacion_salida_id       uuid REFERENCES estaciones_checado(id),
  medio_asistencia         medio_asistencia_enum,
  dispositivo_entrada_id   uuid REFERENCES dispositivos_biometricos(id),
  dispositivo_salida_id    uuid REFERENCES dispositivos_biometricos(id),
  consentimiento_id        uuid REFERENCES consentimientos(id),
  porcentaje_puntualidad   numeric(4,3),
  penalizacion_dias        numeric(6,3) DEFAULT 0,
  penalizacion_sueldo      numeric(12,2) DEFAULT 0,
  estatus_pago             estatus_pago_enum NOT NULL DEFAULT 'pendiente',
  folio_honorarios         int,
  saldo_vencido            numeric(12,2) DEFAULT 0,
  regla_aplicada           text,   -- auditoría: qué validación decidió el último cambio
  repse_registro_id        uuid,   -- FK diferida a repse_registros
  geolocalizacion_lat      numeric(9,6),
  geolocalizacion_lng      numeric(9,6),
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  CHECK (cita_fin > cita_inicio)
);
CREATE INDEX ix_res_emp_fecha ON reservaciones(tenant_id, empleado_id, cita_inicio);
CREATE INDEX ix_res_pedido   ON reservaciones(pedido_id);
CREATE INDEX ix_res_estado   ON reservaciones(tenant_id, estado);
CREATE TRIGGER tg_audit_res BEFORE INSERT OR UPDATE ON reservaciones
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- EVENTOS BIOMÉTRICOS — append-only, timestamp de servidor forzado
CREATE TABLE eventos_biometricos (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  empleado_id         uuid NOT NULL REFERENCES empleados(id),
  reservacion_id      uuid REFERENCES reservaciones(id),
  tipo_marcaje        text NOT NULL CHECK (tipo_marcaje IN ('entrada','salida')),
  ts_servidor         timestamptz NOT NULL DEFAULT now(),
  medio_asistencia    medio_asistencia_enum NOT NULL,
  dispositivo_id      uuid REFERENCES dispositivos_biometricos(id),
  estacion_id         uuid REFERENCES estaciones_checado(id),
  consentimiento_id   uuid NOT NULL REFERENCES consentimientos(id),
  latitud             numeric(9,6),
  longitud            numeric(9,6),
  hash_muestra        text,
  corrige_id          uuid REFERENCES eventos_biometricos(id),  -- correcciones = nuevo registro
  regla_aplicada      text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid
);
CREATE INDEX ix_evbio_emp ON eventos_biometricos(tenant_id, empleado_id, ts_servidor);
-- Forzar timestamp de servidor sin importar lo que envíe el cliente
CREATE OR REPLACE FUNCTION tg_force_server_ts() RETURNS trigger AS $$
BEGIN
  NEW.ts_servidor := now();
  NEW.created_at  := now();
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_evbio_force_ts BEFORE INSERT ON eventos_biometricos
  FOR EACH ROW EXECUTE FUNCTION tg_force_server_ts();
-- Bloquear UPDATE/DELETE (append-only)
CREATE TRIGGER tg_evbio_no_mut BEFORE UPDATE OR DELETE ON eventos_biometricos
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- Validar consentimiento vigente + coherencia biométrico/plan
CREATE OR REPLACE FUNCTION tg_evbio_valida_pre() RETURNS trigger AS $$
DECLARE cvig uuid; p cat_plan_suscripcion;
BEGIN
  cvig := consentimiento_vigente(NEW.empleado_id);
  IF cvig IS NULL THEN
    RAISE EXCEPTION 'Empleado % sin consentimiento vigente — no puede registrar biométrico', NEW.empleado_id;
  END IF;
  IF NEW.consentimiento_id IS DISTINCT FROM cvig THEN
    NEW.consentimiento_id := cvig;
  END IF;
  IF NEW.medio_asistencia = 'geolocalizacion' THEN
    PERFORM verificar_limite(NEW.tenant_id, 'checador_movil');
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_evbio_valida BEFORE INSERT ON eventos_biometricos
  FOR EACH ROW EXECUTE FUNCTION tg_evbio_valida_pre();

-- BITÁCORA de reservaciones (append-only)
CREATE TABLE reservacion_bitacora (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  reservacion_id  uuid NOT NULL REFERENCES reservaciones(id) ON DELETE CASCADE,
  ts              timestamptz NOT NULL DEFAULT now(),
  actor_user_id   uuid,
  accion          text NOT NULL,
  estado_antes    text,
  estado_despues  text,
  regla_aplicada  text,
  detalles        jsonb
);
CREATE INDEX ix_bit_res ON reservacion_bitacora(reservacion_id);
CREATE TRIGGER tg_bit_no_mut BEFORE UPDATE OR DELETE ON reservacion_bitacora
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

-- ---------------------------------------------------------------------------
-- 7. Fiscal: folios, nómina, REPSE
-- ---------------------------------------------------------------------------

-- PRC_FoliosConsecutivos: contador consecutivo POR TIPO DE ENTIDAD, no global.
CREATE TABLE folios (
  tenant_id       uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  tipo_entidad    text NOT NULL,   -- 'empleado', 'factura_honorarios', 'pedido', ...
  ultimo_folio    int NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, tipo_entidad)
);

CREATE OR REPLACE FUNCTION siguiente_folio(p_tenant uuid, p_tipo text)
RETURNS int AS $$
DECLARE nuevo int;
BEGIN
  INSERT INTO folios (tenant_id, tipo_entidad, ultimo_folio) VALUES (p_tenant, p_tipo, 1)
  ON CONFLICT (tenant_id, tipo_entidad) DO UPDATE SET ultimo_folio = folios.ultimo_folio + 1
  RETURNING ultimo_folio INTO nuevo;
  RETURN nuevo;
END $$ LANGUAGE plpgsql;

CREATE TABLE repse_registros (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero_repse   text NOT NULL,
  vigencia_desde date,
  vigencia_hasta date,
  cliente_id     uuid REFERENCES cat_clientes(id),
  activo         boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE TRIGGER tg_audit_repse BEFORE INSERT OR UPDATE ON repse_registros
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();
ALTER TABLE reservaciones
  ADD CONSTRAINT fk_res_repse FOREIGN KEY (repse_registro_id) REFERENCES repse_registros(id);

CREATE TABLE nominas_periodo (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  ciclo_pago         ciclo_pago_enum NOT NULL,
  fecha_desde        date NOT NULL,
  fecha_hasta        date NOT NULL,
  cerrada            boolean NOT NULL DEFAULT false,
  fecha_cierre       timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid,
  CHECK (fecha_hasta >= fecha_desde)
);
CREATE TRIGGER tg_audit_nom BEFORE INSERT OR UPDATE ON nominas_periodo
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

CREATE TABLE nomina_detalle (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nomina_id                uuid NOT NULL REFERENCES nominas_periodo(id) ON DELETE CASCADE,
  empleado_id              uuid NOT NULL REFERENCES empleados(id),
  reservaciones_cnt        int NOT NULL DEFAULT 0,
  monto_bruto              numeric(14,2) NOT NULL DEFAULT 0,
  penalizaciones_aplicadas numeric(14,2) NOT NULL DEFAULT 0,
  monto_neto               numeric(14,2) NOT NULL DEFAULT 0,
  salario_diario_promedio  numeric(12,2) NOT NULL DEFAULT 0,
  regimen_pago             regimen_pago_enum NOT NULL,
  folio_pago               int,
  estatus_pago             estatus_pago_enum NOT NULL DEFAULT 'pendiente',
  precauciones             jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid,
  updated_at timestamptz NOT NULL DEFAULT now(), updated_by uuid
);
CREATE INDEX ix_nom_det ON nomina_detalle(tenant_id, nomina_id);
CREATE TRIGGER tg_audit_nom_det BEFORE INSERT OR UPDATE ON nomina_detalle
  FOR EACH ROW EXECUTE FUNCTION tg_touch_audit();

-- ---------------------------------------------------------------------------
-- 8. FUNCIONES DE REGLAS DE NEGOCIO
--    Traducciones fieles de los PRC_* del sistema Lobo/AppSCPF.
--    Cada función deja constancia en `regla_aplicada` cuando decide un rechazo.
-- ---------------------------------------------------------------------------

-- PRC_ObtenerCertezaPuesto: certeza actual del empleado en un puesto específico
CREATE OR REPLACE FUNCTION obtener_certeza_puesto(p_empleado uuid, p_puesto uuid)
RETURNS numeric AS $$
DECLARE cert numeric; ini numeric;
BEGIN
  SELECT porcentaje_puntualidad INTO cert
    FROM empleados_plazas WHERE empleado_id = p_empleado AND puesto_id = p_puesto AND activo;
  IF cert IS NOT NULL THEN RETURN cert; END IF;
  SELECT porcentaje_certeza_inicial INTO ini FROM cat_puestos WHERE id = p_puesto;
  RETURN COALESCE(ini, 1.0);
END $$ LANGUAGE plpgsql STABLE;

-- PRC_ValidaEmpPuesto: valida que el empleado califica para el puesto
CREATE OR REPLACE FUNCTION valida_emp_puesto(p_empleado uuid, p_puesto uuid)
RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE
  cert numeric;
  minimo numeric;
  sexo_req sexo_enum;
  sexo_emp sexo_enum;
BEGIN
  SELECT porcentaje_minimo, sexo_requerido INTO minimo, sexo_req FROM cat_puestos WHERE id = p_puesto;
  SELECT sexo INTO sexo_emp FROM empleados WHERE id = p_empleado;
  IF sexo_req IS NOT NULL AND sexo_emp IS DISTINCT FROM sexo_req THEN
    RETURN QUERY SELECT false, format('sexo requerido %s, empleado %s', sexo_req, sexo_emp);
    RETURN;
  END IF;
  cert := obtener_certeza_puesto(p_empleado, p_puesto);
  IF cert < minimo THEN
    RETURN QUERY SELECT false, format('certeza %s < mínimo %s', cert, minimo);
    RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

-- PRC_Noempalmereservacion: valida que no traslape con otras reservaciones activas
-- considerando el margen (horas_entre_turnos) del puesto.
CREATE OR REPLACE FUNCTION valida_no_empalme(
  p_empleado uuid,
  p_puesto uuid,
  p_cita_inicio timestamptz,
  p_cita_fin timestamptz,
  p_ignorar_reservacion uuid DEFAULT NULL
) RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE
  margen_h numeric;
  duracion_h numeric;
  ventana_inicio timestamptz;
  ventana_fin timestamptz;
  conflicto record;
BEGIN
  SELECT horas_entre_turnos, duracion_turno_horas INTO margen_h, duracion_h
    FROM cat_puestos WHERE id = p_puesto;
  ventana_inicio := p_cita_inicio - (margen_h || ' hours')::interval;
  ventana_fin    := p_cita_fin    + (margen_h || ' hours')::interval;
  SELECT r.id, r.cita_inicio, r.cita_fin INTO conflicto
    FROM reservaciones r
    WHERE r.empleado_id = p_empleado
      AND r.estado NOT IN ('cancelado', 'procesado')
      AND (p_ignorar_reservacion IS NULL OR r.id <> p_ignorar_reservacion)
      AND tstzrange(r.cita_inicio, r.cita_fin, '[)')
          && tstzrange(ventana_inicio, ventana_fin, '[)')
    LIMIT 1;
  IF FOUND THEN
    RETURN QUERY SELECT false, format(
      'traslape con reservación %s (%s → %s), margen requerido %s h',
      conflicto.id, conflicto.cita_inicio, conflicto.cita_fin, margen_h);
    RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

-- PRC_ValidacionesCancelarReservacion: ¿puede cancelarse ahora?
CREATE OR REPLACE FUNCTION valida_cancelacion(p_reservacion uuid)
RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE
  r reservaciones;
  min_h numeric;
  faltan_h numeric;
BEGIN
  SELECT * INTO r FROM reservaciones WHERE id = p_reservacion;
  IF r.estado = 'forzada' THEN
    RETURN QUERY SELECT true, 'forzada — cancelación permitida por excepción'::text;
    RETURN;
  END IF;
  SELECT horas_antes_cancelar INTO min_h FROM cat_puestos WHERE id = r.puesto_id;
  faltan_h := EXTRACT(EPOCH FROM (r.cita_inicio - now())) / 3600;
  IF faltan_h < min_h THEN
    RETURN QUERY SELECT false,
      format('faltan %.1f h; mínimo del puesto: %s h', faltan_h, min_h);
    RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

-- Trigger que ejecuta las validaciones al INSERT de reservación
CREATE OR REPLACE FUNCTION tg_reservacion_valida() RETURNS trigger AS $$
DECLARE v record; nr text;
BEGIN
  -- verifica plan permite asignación
  PERFORM verificar_limite(NEW.tenant_id, 'asignacion');
  -- valida empleado calificado
  SELECT * INTO v FROM valida_emp_puesto(NEW.empleado_id, NEW.puesto_id);
  IF NOT v.valido THEN
    NEW.regla_aplicada := 'PRC_ValidaEmpPuesto: ' || v.motivo;
    RAISE EXCEPTION 'Empleado no califica para puesto: %', v.motivo;
  END IF;
  -- valida no-empalme
  SELECT * INTO v FROM valida_no_empalme(NEW.empleado_id, NEW.puesto_id, NEW.cita_inicio, NEW.cita_fin);
  IF NOT v.valido THEN
    NEW.regla_aplicada := 'PRC_Noempalmereservacion: ' || v.motivo;
    RAISE EXCEPTION 'Traslape de turnos: %', v.motivo;
  END IF;
  NEW.regla_aplicada := 'reservacion_creada_ok';
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_res_valida BEFORE INSERT ON reservaciones
  FOR EACH ROW EXECUTE FUNCTION tg_reservacion_valida();

-- PRC_CancelacionAutomaticaPreasignados
-- Los "72" y "8" originales viven ahora en cat_parametros_globales por tenant.
CREATE OR REPLACE FUNCTION cancelacion_automatica_preasignados()
RETURNS int AS $$
DECLARE
  n int := 0;
  p cat_parametros_globales;
BEGIN
  FOR p IN SELECT * FROM cat_parametros_globales LOOP
    WITH cancelaciones AS (
      UPDATE reservaciones
      SET estado = 'cancelado',
          regla_aplicada = 'PRC_CancelacionAutomaticaPreasignados'
      WHERE tenant_id = p.tenant_id
        AND estado = 'confirmado_opcional'
        AND (cita_inicio - now()) < (p.horas_lookahead_autocancel || ' hours')::interval
        AND (now() - created_at) > (p.horas_gracia_confirmacion || ' hours')::interval
      RETURNING id
    )
    SELECT n + count(*) INTO n FROM cancelaciones;
  END LOOP;
  RETURN n;
END $$ LANGUAGE plpgsql;

-- PRC_CalculoNomina: cálculo por asistencia real (asistencia/retardo/falta)
CREATE OR REPLACE FUNCTION calcular_nomina_periodo(p_nomina uuid)
RETURNS int AS $$
DECLARE
  n int := 0;
  npe nominas_periodo;
  r record;
BEGIN
  SELECT * INTO npe FROM nominas_periodo WHERE id = p_nomina;
  DELETE FROM nomina_detalle WHERE nomina_id = p_nomina;
  INSERT INTO nomina_detalle (
    tenant_id, nomina_id, empleado_id, reservaciones_cnt,
    monto_bruto, penalizaciones_aplicadas, monto_neto, salario_diario_promedio,
    regimen_pago, precauciones
  )
  SELECT
    npe.tenant_id,
    npe.id,
    r.empleado_id,
    count(*)::int,
    COALESCE(sum(pd.costo_unit * r.duracion_en_turnos), 0),
    COALESCE(sum(r.penalizacion_sueldo), 0),
    COALESCE(sum(pd.costo_unit * r.duracion_en_turnos + r.penalizacion_sueldo), 0),
    CASE WHEN count(*) > 0
      THEN (COALESCE(sum(pd.costo_unit * r.duracion_en_turnos + r.penalizacion_sueldo), 0) / count(*))
      ELSE 0
    END,
    e.regimen_pago,
    jsonb_build_object(
      'sin_banco', bool_or(e.id_banco IS NULL),
      'sin_pagadora', bool_or(e.id_sociedad_pagadora IS NULL),
      'sin_clabe', bool_or(e.clabe IS NULL OR e.clabe = '')
    )
  FROM reservaciones r
  JOIN empleados e ON e.id = r.empleado_id
  LEFT JOIN pedidos_detalle pd ON pd.id = r.pedido_detalle_id
  WHERE r.tenant_id = npe.tenant_id
    AND r.estado = 'procesado'
    AND r.estado_asistencia IN ('asistencia', 'retardo', 'falta')
    AND r.cita_inicio::date BETWEEN npe.fecha_desde AND npe.fecha_hasta
  GROUP BY r.empleado_id, e.regimen_pago;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql;

-- Reporte de precauciones antes de cierre de nómina
CREATE OR REPLACE FUNCTION reporte_precauciones_nomina(p_tenant uuid)
RETURNS TABLE (empleado_id uuid, nombre text, motivos text[]) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.nombres || ' ' || e.apellido_paterno,
         ARRAY_REMOVE(ARRAY[
           CASE WHEN e.id_banco IS NULL THEN 'sin banco' END,
           CASE WHEN e.clabe IS NULL OR e.clabe = '' THEN 'sin CLABE' END,
           CASE WHEN e.id_sociedad_pagadora IS NULL THEN 'sin sociedad pagadora' END,
           CASE WHEN e.regimen_pago IS NULL THEN 'sin régimen de pago' END
         ], NULL)
  FROM empleados e
  WHERE e.tenant_id = p_tenant AND e.activo
    AND (e.id_banco IS NULL OR e.clabe IS NULL OR e.clabe = ''
      OR e.id_sociedad_pagadora IS NULL OR e.regimen_pago IS NULL);
END $$ LANGUAGE plpgsql STABLE;

-- PRC_AltaEmpleadosCursoInduccion: promueve candidato → empleado
CREATE OR REPLACE FUNCTION promover_candidato_a_empleado(p_candidato uuid)
RETURNS uuid AS $$
DECLARE c candidatos; nuevo_folio int; nuevo_id uuid;
BEGIN
  SELECT * INTO c FROM candidatos WHERE id = p_candidato;
  IF c.id IS NULL THEN RAISE EXCEPTION 'candidato no existe'; END IF;
  IF NOT c.paso_induccion THEN RAISE EXCEPTION 'candidato no ha pasado inducción'; END IF;
  nuevo_folio := siguiente_folio(c.tenant_id, 'empleado');
  INSERT INTO empleados (
    tenant_id, folio, candidato_origen_id, nombres, apellido_paterno, apellido_materno,
    rfc, curp, fecha_nacimiento, sexo, telefono, correo, direccion
  ) VALUES (
    c.tenant_id, nuevo_folio, c.id, c.nombres, c.apellido_paterno, c.apellido_materno,
    c.rfc, c.curp, c.fecha_nacimiento, c.sexo, c.telefono, c.correo, c.direccion
  ) RETURNING id INTO nuevo_id;
  UPDATE candidatos SET promovido_a_empleado = true WHERE id = c.id;
  RETURN nuevo_id;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 9. RLS por tenant
-- ---------------------------------------------------------------------------
ALTER TABLE tenants                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE suscripciones              ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_parametros_globales    ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_bancos                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_sociedades_pagadoras   ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_sociedades_propias     ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_unidades_negocio       ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_sitios                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_puestos                ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_uniformes              ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_clientes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE cat_productos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidatos                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE empleados                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE empleados_plazas           ENABLE ROW LEVEL SECURITY;
ALTER TABLE avisos_privacidad          ENABLE ROW LEVEL SECURITY;
ALTER TABLE consentimientos            ENABLE ROW LEVEL SECURITY;
ALTER TABLE estaciones_checado         ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispositivos_biometricos   ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos_detalle            ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservaciones              ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos_biometricos        ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservacion_bitacora       ENABLE ROW LEVEL SECURITY;
ALTER TABLE folios                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE repse_registros            ENABLE ROW LEVEL SECURITY;
ALTER TABLE nominas_periodo            ENABLE ROW LEVEL SECURITY;
ALTER TABLE nomina_detalle             ENABLE ROW LEVEL SECURITY;

-- Política estándar: SELECT/INSERT/UPDATE si tenant_id coincide con la sesión.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'tenants','suscripciones','cat_parametros_globales','cat_bancos',
    'cat_sociedades_pagadoras','cat_sociedades_propias','cat_unidades_negocio',
    'cat_sitios','cat_puestos','cat_uniformes','cat_clientes','cat_productos',
    'candidatos','empleados','empleados_plazas','avisos_privacidad','consentimientos',
    'estaciones_checado','dispositivos_biometricos','pedidos','pedidos_detalle',
    'reservaciones','eventos_biometricos','reservacion_bitacora','folios',
    'repse_registros','nominas_periodo','nomina_detalle'
  ] LOOP
    IF t = 'tenants' THEN
      EXECUTE format('CREATE POLICY p_%1$s_all ON %1$s USING (id = current_tenant_id())', t);
    ELSE
      EXECUTE format(
        'CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_ins ON %1$s FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_upd ON %1$s FOR UPDATE USING (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_del ON %1$s FOR DELETE USING (tenant_id = current_tenant_id());',
        t
      );
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 10. Semillas
-- ---------------------------------------------------------------------------

INSERT INTO cat_plan_suscripcion (codigo, titulo, descripcion, max_sitios, max_empleados_activos,
  incluye_checador_fijo, incluye_checador_movil, incluye_asignacion, incluye_certeza,
  incluye_nomina, incluye_repse, precio_mensual_mxn)
VALUES
  ('FREE', 'PeopleMovil FREE / Piloto',
    'Un sitio, hasta 15 trabajadores, solo checador fijo.',
    1, 15, true, false, false, false, false, false, 0),
  ('PRO', 'PeopleMovil PRO',
    'Sitios y trabajadores ilimitados, checador fijo+móvil, asignación, certeza, nómina y REPSE.',
    NULL, NULL, true, true, true, true, true, true, 1499.00);

-- Tenant demo
INSERT INTO tenants (id, razon_social, rfc, vertical)
VALUES ('00000000-0000-0000-0000-000000000001', 'Demo PeopleMovil, S.A. de C.V.', 'DPM260101000', 'eventos');

INSERT INTO suscripciones (tenant_id, plan_codigo)
VALUES ('00000000-0000-0000-0000-000000000001', 'PRO');

INSERT INTO cat_parametros_globales (tenant_id) VALUES ('00000000-0000-0000-0000-000000000001');

INSERT INTO avisos_privacidad (tenant_id, version, texto) VALUES (
  '00000000-0000-0000-0000-000000000001', 'v1.0',
  'Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. '
  'Se recabará huella dactilar y/o imagen facial únicamente para acreditar asistencia laboral. '
  'El titular puede revocar el consentimiento en cualquier momento.'
);

-- Setear tenant activo para las semillas
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

-- Semillas de los .xlsx (reales del sistema Lobo)
-- ↓↓↓ INSERT ↓↓↓ (ver db/seeds.sql para las inserciones detalladas)


-- ---- SEMILLAS AUTOGENERADAS DESDE .xlsx REALES ----
-- Sociedades Pagadoras (19 reales, del sistema Lobo)
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'As Deporte, S.A. de C.V.', 22135, 194);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 20, 'Car Sport Racing SA de CV', 50420, 189);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 17, 'ETK Boletos, S.A. DE C.V.', 46187, 219);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 7, 'Grupo Automovilstico Nacional y Deportivo, S. De R.L. de C.V.', 20939, 140);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 19, 'ICESA', 48941, 12);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 22, 'Make Pro, S.A. de C.V.', 20775, 10);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Ocesa Anfiteatro, S.A. de C.V.', 20617, 11);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 14, 'Ocesa Comercial, S.A. de C.V.', 21808, 193);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 21, 'Ocesa Presenta, S.A. de C.V.', 51412, 214);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 10, 'Ocesa Promotora, S. A. de C.V.', 44396, 165);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Operadora de Centros de Espectculos, S.A. de C.V.', 20619, 9);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Promotodo Mxico, S.A. de C.V.', 20849, 42);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Promotora de Espectculos de Occidente, S.A. de C.V.', 23410, 199);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Servicios Administrativos del Entretenimiento S.A. de C.V', 20984, 148);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 6, 'Servicios de Proteccin Privada Lobo, S.A. de C.V.', 20589, 85);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 13, 'Servicios Especializados Para la Venta Automatizada de Boletos, S.A. de C.V.', 25065, 203);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 18, 'SOLO ELE-MENTUM SA DE CV', 42047, 214);
INSERT INTO cat_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 23, 'Venta de Boletos Por Computadora, S.A. de C.V.', 20642, 7);

-- Sociedades Propias (6 reales)
INSERT INTO cat_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 1, '085-Lobo', 'Servicios de Proteccin Privada Lobo, SA de CV', true, true, false, 6);
INSERT INTO cat_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 2, '145-Corhum', 'Coordinacin de Recursos Humanos, SA de CV', true, true, false, NULL);
INSERT INTO cat_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'OCTR-Ocesa Corhum', 'Operadora de Centros de Espectaculos SA de CV - Corhum', true, true, true, NULL);
INSERT INTO cat_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Ocesa RH', 'Operadora de Centros de Espectculos', true, true, true, NULL);
INSERT INTO cat_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'As Deporte', 'As Deporte, S.A. De C.V.', false, true, true, NULL);

-- Uniformes (29 reales)
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 41, 'Pantaln Negro de Vestir, Playera Lobo y Chamarra Lobo', 'Seguridad ', 1, 57, 56, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 20, 'De Civil', 'De Civil', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 36, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 8, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 38, 'Pantaln Negro de Vestir, Playera Azul y Chamarra Azul', 'Control Accesos', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 39, 'Pantaln Negro de Vestir, Playera Naranja y Chamarra Naranja', 'Anfitriones', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 15, 'Pantaln Negro de Vestir, Playera Negro-Rojo y Chamarra Negro-Rojo', 'Seguridad', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 37, 'Pantanln negro de vestir y playera guinda', 'Pant Negro Playera Guinda', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 1, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 17, 'De Civil', 'De Civil', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 35, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 23, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 1, 'Pantaln Negro de Vestir, Playera Azul y Chamarra Azul', 'Control Accesos', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 13, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 5, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 16, 'De Civil', 'De Civil', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 34, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 24, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Pantaln Negro de Vestir, Playera Naranja y Chamarra Naranja', 'Anfitriones', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 3, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 21, 'De Civil', 'De Civil', 2, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 14, 'Pantaln Negro de Vestir y Camisa Azul', 'Pant Negro Camisa Azul', 2, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 2, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 32, 'Pantaln Negro de Vestir y Playera Crema', 'Pant Negro Playera Crema', 2, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 25, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 2, NULL, NULL, NULL);
INSERT INTO cat_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 29, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 2, NULL, NULL, NULL);

-- Puestos (30 representativos de 984 reales, todos los parámetros de negocio)
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 46, 'Tecnico Audio', 0, 9, 12, 0, 72, 1, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 47, 'Encargado de Generador', 600, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 48, 'Productor B', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 49, 'Productor C', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 50, 'Stage Manager B', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 51, 'Stage Manager C', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 52, 'Asistente de Produccion B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 53, 'Asistente de Produccion C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 54, 'Asistente de Produccion D', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 55, 'Asistente de Produccion E', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 56, 'Logistica B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 57, 'Logistica C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 58, 'Logistica D', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 59, 'Logistica E', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 60, 'Diseo de Iluminacion A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 61, 'Diseo de Iluminacion B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 62, 'Diseo de Iluminacion C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 63, 'Ingeniero de Audio A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 64, 'Ingeniero de Audio B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 65, 'Ingeniero de Audio C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 66, 'Ingeniero de Luces A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 67, 'Ingeniero de Luces B', 0, 9, 24, 0, 24, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 68, 'Ingeniero de Luces C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 69, 'Pre produccion y atencion audio / luz A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 70, 'Pre produccion y atencion audio / luz B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 71, 'Pre produccion y atencion audio / luz C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 72, 'Runner con coche', 0, 9, 21, 0, 72, 1, 0.75, 90, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 73, 'Runner sin coche', 0, 9, 21, 0, 0, 1, 0.75, 90, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 74, 'Coordinador Asistente', 600, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO cat_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 75, 'Climber', 900, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);

-- Lugares de Cita (15 reales representativos)
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 1, 'Palacio de los Deportes ', 'foro', 'Ro Churubusco Esquina con Ail, Colonia Granjas Mxico  ', 'Ro Churubusco Esquina con Ail Puerta 1', '237 99 99', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Foro Sol', 'foro', 'Viaducto ro piedad, metro ciudad deportiva Acceso D de Foro Sol, Colonia Granjas Mxico, Delegacin Iztacalco, Distrito Federal', 'Viaducto ro piedad, metro ciudad deportiva Acceso D', '764 84 46', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Gimnasio Juan de la Barrera', 'foro', 'Rio churubusco Esquina con divisin del norte, Distrito Federal', 'Rio churubusco Esquina con divisin del norte', NULL, true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Centro de Exposiciones del World Trade Center', 'foro', 'Filadelfia Sin Nmero entre insurgentes y dakota, Colonia Npoles, Delegacin Benito Jurez, Ciudad Mxico, Estado Distrito Federal', NULL, '628 83 66   628 83 64   628 83 02', false);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'Auditorio Nacional', 'foro', 'Paseo de la reforma 50, Colonia Bosque de Chapultepc, Delegacin Miguel Hidalgo, Ciudad Mxico, Distrito Federal, Cdigo Postal 11560', 'Paseo de la reforma 50, Colonia Bosque de Chapultepc', '280 74 76', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 6, 'Teatro Metroplitan', 'foro', 'Independencia 90, Colonia Centro, Distrito Federal', 'Independencia 90, Colonia Centro', '510 39 79', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 7, 'Teatro Ofen', 'foro', 'Luis Moya 40 Esquina con Independencia, Colonia Centro, Ciudad Mxico, Estado Distrito Federal', NULL, '512 60 39   512 62 71', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 8, 'Hard Rock Caf', 'foro', 'Campos Elseos 290 Esquina con Reforma, Colonia Polanco, Delegacin Miguel Hidalgo, Distrito Federal, Cdigo Postal 11560', 'Campos Elseos 290 Esquina con Reforma, Colonia Polanco', '5327-7101,  Fax. 5327-7106', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Estadio Azul Puerta 5', 'foro', 'Holbein Puerta nmero 5 Esquina con Indiana, Colonia Ciudad de los Deportes, Delegacin Benito Jurez, Distrito Federal', 'Holbein Esquina con Indiana Puerta 5', NULL, true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 10, 'Estadio Azteca', 'foro', 'Calzada de Tllpan 3465 Puerta 1, Colonia Santa Ursula, Delegacin Tlalpan, Distrito Federal, Cdigo Postal 04650', 'Calzada de Tllpan 3465 Puerta 1', '5617-8080', true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'Oficinas de Recursos Humanos', 'foro', 'Dakota 85-6 entre Yosemite y Altadena, Colonia Npoles, Delegacin Benito Juarez, Ciudad Mxico, Estado Distrito Federal, CP 03810', NULL, '5682 85 48', false);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Caf Casino', 'foro', 'Dakota 85 Esquina con Yosemite, Colonia Npoles, Delegacin Benito Juarez, Distrito Federal, Cdigo Postal 03810', 'Dakota 85 Esquina con Yosemite, Colonia Npoles', '5687 57 73', false);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 25, 'World Trade Center', 'foro', 'Montecito 38 Esquina Dakota, cita en  puerta parablica., Colonia Npoles, Delegacin Benito Juarez, Estado Distrito Federal, CP 03810', NULL, NULL, true);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 26, 'Allegro Restaurante Bar', 'foro', NULL, NULL, NULL, false);
INSERT INTO cat_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 30, 'Six Flags', 'foro', 'Carretera Picacho Ajusco kilometro 1.5, Colonia Hroes de Padierna., Delegacin Tlalpan, Ciudad Mxico D.F., Estado Distrito Federal, CP 14200', NULL, '57 28 72 00   56 45 77 90', true);

-- Bancos (semilla estándar México)
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '002', 'BANAMEX');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '012', 'BBVA');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '014', 'SANTANDER');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '021', 'HSBC');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '030', 'BAJIO');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '036', 'INBURSA');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '037', 'INTERACCIONES');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '042', 'MIFEL');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '044', 'SCOTIABANK');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '058', 'BANREGIO');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '059', 'INVEX');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '072', 'BANORTE');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '102', 'ABC CAPITAL');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '103', 'AMERICAN EXPRESS');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '106', 'BANK OF AMERICA');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '127', 'AZTECA');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '128', 'AUTOFIN');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '132', 'BMULTIVA');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '137', 'BANCOPPEL');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '143', 'CIBANCO');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '147', 'BANKAOOL');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '166', 'BANSEFI');
INSERT INTO cat_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '646', 'STP');

-- fin ---
