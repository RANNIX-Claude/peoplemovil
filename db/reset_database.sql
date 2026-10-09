-- ============================================================================
-- PeopleMovil 2.0 — Reset Database (v2 con nomenclatura tc/te/tp/tr)
-- ============================================================================
-- Motor: Postgres 15+ (Supabase compatible).
--
-- CONVENCIÓN DE NOMBRES (heredada del sistema Lobo/AppSCPF en GeneXus)
--   tc_*   Tabla de Catálogo         (bancos, puestos, sitios, uniformes)
--   te_*   Tabla de Entidad/Negocio  (candidatos, empleados, pedidos, reservaciones)
--   tp_*   Tabla de Parámetros       (periodos, precios, folios, parámetros globales)
--   tr_*   Tabla de Relación N:N     (empleado ↔ plaza, candidato ↔ curso)
--
-- Reservado para etapa DW: dw_dim_* (dimensiones), dw_hecho_* (hechos).
--
-- PRINCIPIOS QUE SIGUE
--   * Cero parámetros de negocio hardcodeados — todo en catálogos y tp_*.
--   * Append-only en te_eventos_biometricos, te_consentimientos, te_reservacion_bitacora.
--   * Timestamp de servidor forzado por trigger.
--   * Multi-tenant real con RLS por tenant_id en TODAS las tablas.
--   * Auditoría (creado_en/por, modificado_en/por, tenant_id) en TODAS.
--   * Verificación de plan del tenant por trigger, no por frontend.
--   * Cada rechazo automático deja constancia en `regla_aplicada`.
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
  'Nomina', 'Honorarios Normales', 'Honorarios Asimilables'
);
CREATE TYPE ciclo_pago_enum AS ENUM ('Semanal', 'Quincenal', 'Mensual');
CREATE TYPE tipo_sitio_enum AS ENUM (
  'sucursal','tienda','obra','foro','oficina','evento','otro'
);
CREATE TYPE tipo_dispositivo_enum AS ENUM ('fijo','movil');
CREATE TYPE medio_asistencia_enum AS ENUM ('biometrico','manual','geolocalizacion');
CREATE TYPE estado_reservacion_enum AS ENUM (
  'disponible','preasignado','confirmado_opcional','confirmado_voluntario',
  'forzada','procesado','cancelado'
);
CREATE TYPE estado_asistencia_enum AS ENUM ('pendiente','asistencia','retardo','falta');
CREATE TYPE estatus_pago_enum AS ENUM ('pendiente','calculado','dispersado','pagado','cancelado');
CREATE TYPE sexo_enum AS ENUM ('M','F','X');
CREATE TYPE plan_codigo_enum AS ENUM ('FREE','PRO');
CREATE TYPE fase_evento_enum AS ENUM ('montaje','evento','desmontaje','otro');
CREATE TYPE estado_vacante_enum AS ENUM ('borrador','publicada','pausada','cerrada');
CREATE TYPE estado_postulacion_enum AS ENUM ('recibida','evaluando','aceptada','rechazada','contratada');

-- ---------------------------------------------------------------------------
-- 2. Helpers de sesión y auditoría
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS uuid AS $$
DECLARE h_tenant text;
BEGIN
  BEGIN
    h_tenant := current_setting('request.headers', true)::json->>'x-tenant-id';
  EXCEPTION WHEN OTHERS THEN
    h_tenant := NULL;
  END;
  RETURN COALESCE(
    NULLIF(current_setting('app.current_tenant', true), '')::uuid,
    h_tenant::uuid,
    NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
  );
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

CREATE OR REPLACE FUNCTION tg_auditoria() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.creado_en      := now();
    NEW.creado_por     := COALESCE(NEW.creado_por, current_user_id());
    NEW.modificado_en  := now();
    NEW.modificado_por := COALESCE(NEW.modificado_por, current_user_id());
    IF NEW.tenant_id IS NULL THEN
      NEW.tenant_id := current_tenant_id();
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.creado_en      := OLD.creado_en;
    NEW.creado_por     := OLD.creado_por;
    NEW.tenant_id      := OLD.tenant_id;
    NEW.modificado_en  := now();
    NEW.modificado_por := COALESCE(current_user_id(), OLD.modificado_por);
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tg_deny_mutations() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Tabla append-only: % no permitido en %', TG_OP, TG_TABLE_NAME
    USING ERRCODE = 'insufficient_privilege';
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 3. Tenants + suscripciones + parámetros por tenant
-- ---------------------------------------------------------------------------

CREATE TABLE te_tenants (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  razon_social  text NOT NULL,
  rfc           text,
  vertical      text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en     timestamptz NOT NULL DEFAULT now(),
  creado_por    uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por uuid
);

CREATE TABLE tc_planes_suscripcion (
  codigo                 plan_codigo_enum PRIMARY KEY,
  titulo                 text NOT NULL,
  descripcion            text,
  max_sitios             int,
  max_empleados_activos  int,
  incluye_checador_fijo  boolean NOT NULL DEFAULT true,
  incluye_checador_movil boolean NOT NULL DEFAULT false,
  incluye_asignacion     boolean NOT NULL DEFAULT false,
  incluye_certeza        boolean NOT NULL DEFAULT false,
  incluye_nomina         boolean NOT NULL DEFAULT false,
  incluye_repse          boolean NOT NULL DEFAULT false,
  precio_mensual_mxn     numeric(10,2),
  creado_en              timestamptz NOT NULL DEFAULT now(),
  modificado_en          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE te_suscripciones (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  plan_codigo    plan_codigo_enum NOT NULL REFERENCES tc_planes_suscripcion(codigo),
  vigente_desde  timestamptz NOT NULL DEFAULT now(),
  vigente_hasta  timestamptz,
  activa         boolean NOT NULL DEFAULT true,
  creado_en      timestamptz NOT NULL DEFAULT now(),
  creado_por     uuid,
  modificado_en  timestamptz NOT NULL DEFAULT now(),
  modificado_por uuid
);
CREATE INDEX ix_susc_tenant_activa ON te_suscripciones(tenant_id) WHERE activa;
CREATE TRIGGER tg_aud_susc BEFORE INSERT OR UPDATE ON te_suscripciones
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tp_parametros_globales (
  tenant_id                     uuid PRIMARY KEY REFERENCES te_tenants(id) ON DELETE CASCADE,
  horas_lookahead_autocancel    int NOT NULL DEFAULT 72,
  horas_gracia_confirmacion     int NOT NULL DEFAULT 8,
  retencion_registros_dias      int NOT NULL DEFAULT 1825,
  certeza_inicial_default       numeric(4,3) NOT NULL DEFAULT 1.000,
  aviso_privacidad_version      text NOT NULL DEFAULT 'v1.0',
  creado_en                     timestamptz NOT NULL DEFAULT now(),
  creado_por                    uuid,
  modificado_en                 timestamptz NOT NULL DEFAULT now(),
  modificado_por                uuid
);

CREATE OR REPLACE FUNCTION plan_activo(p_tenant uuid)
RETURNS tc_planes_suscripcion AS $$
DECLARE r tc_planes_suscripcion;
BEGIN
  SELECT p.* INTO r
  FROM te_suscripciones s
  JOIN tc_planes_suscripcion p ON p.codigo = s.plan_codigo
  WHERE s.tenant_id = p_tenant AND s.activa
    AND (s.vigente_hasta IS NULL OR s.vigente_hasta > now())
  ORDER BY s.vigente_desde DESC LIMIT 1;
  IF NOT FOUND THEN SELECT * INTO r FROM tc_planes_suscripcion WHERE codigo='FREE'; END IF;
  RETURN r;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION verificar_limite(p_tenant uuid, p_recurso text)
RETURNS void AS $$
DECLARE p tc_planes_suscripcion; usados int;
BEGIN
  p := plan_activo(p_tenant);
  IF p_recurso = 'sitios' THEN
    IF p.max_sitios IS NULL THEN RETURN; END IF;
    SELECT count(*) INTO usados FROM tc_sitios WHERE tenant_id=p_tenant AND activo;
    IF usados >= p.max_sitios THEN
      RAISE EXCEPTION 'Plan % permite máx % sitios; ya tiene %', p.codigo, p.max_sitios, usados
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'empleados' THEN
    IF p.max_empleados_activos IS NULL THEN RETURN; END IF;
    SELECT count(*) INTO usados FROM te_empleados WHERE tenant_id=p_tenant AND activo;
    IF usados >= p.max_empleados_activos THEN
      RAISE EXCEPTION 'Plan % permite máx % empleados; ya tiene %', p.codigo, p.max_empleados_activos, usados
        USING ERRCODE = 'insufficient_privilege';
    END IF;
  ELSIF p_recurso = 'checador_movil' AND NOT p.incluye_checador_movil THEN
    RAISE EXCEPTION 'Plan % no incluye checador móvil (upgrade a PRO)', p.codigo USING ERRCODE='insufficient_privilege';
  ELSIF p_recurso = 'asignacion' AND NOT p.incluye_asignacion THEN
    RAISE EXCEPTION 'Plan % no incluye módulo de asignación/pedidos', p.codigo USING ERRCODE='insufficient_privilege';
  ELSIF p_recurso = 'nomina' AND NOT p.incluye_nomina THEN
    RAISE EXCEPTION 'Plan % no incluye módulo de nómina', p.codigo USING ERRCODE='insufficient_privilege';
  ELSIF p_recurso = 'repse' AND NOT p.incluye_repse THEN
    RAISE EXCEPTION 'Plan % no incluye módulo REPSE', p.codigo USING ERRCODE='insufficient_privilege';
  END IF;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 4. Catálogos maestros (tc_*)
-- ---------------------------------------------------------------------------

CREATE TABLE tc_estados_mx (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave_ine    text,
  nombre       text NOT NULL,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, nombre)
);
CREATE TRIGGER tg_aud_est BEFORE INSERT OR UPDATE ON tc_estados_mx FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_bancos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  nombre        text NOT NULL,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_aud_bancos BEFORE INSERT OR UPDATE ON tc_bancos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_sociedades_pagadoras (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy                   int,
  titulo                      text NOT NULL,
  id_empresa_pagadora_legacy  int,
  numero_sociedad             int,
  activo                      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_socpag BEFORE INSERT OR UPDATE ON tc_sociedades_pagadoras FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_sociedades_propias (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy                   int,
  titulo                      text NOT NULL,
  razon_social                text,
  vigente                     boolean NOT NULL DEFAULT true,
  genera_factura              boolean NOT NULL DEFAULT true,
  genera_orden_servicio       boolean NOT NULL DEFAULT false,
  id_sociedad_pagadora_legacy int,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_socpro BEFORE INSERT OR UPDATE ON tc_sociedades_propias FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_unidades_negocio (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy  int,
  titulo     text NOT NULL,
  activo     boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, titulo)
);
CREATE TRIGGER tg_aud_un BEFORE INSERT OR UPDATE ON tc_unidades_negocio FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_sitios (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy             int,
  titulo                text NOT NULL,
  tipo_sitio            tipo_sitio_enum NOT NULL DEFAULT 'sucursal',
  direccion             text,
  direccion_abreviada   text,
  telefonos             text,
  latitud               numeric(9,6),
  longitud              numeric(9,6),
  activo                boolean NOT NULL DEFAULT true,
  id_unidad_negocio     uuid REFERENCES tc_unidades_negocio(id),
  id_estado             uuid REFERENCES tc_estados_mx(id),
  codigo_postal         text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_sitios_tenant ON tc_sitios(tenant_id) WHERE activo;
CREATE TRIGGER tg_aud_sitios BEFORE INSERT OR UPDATE ON tc_sitios FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
CREATE OR REPLACE FUNCTION tg_check_sitios_limite() RETURNS trigger AS $$
BEGIN IF NEW.activo THEN PERFORM verificar_limite(NEW.tenant_id,'sitios'); END IF; RETURN NEW; END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_sitios_limite BEFORE INSERT ON tc_sitios FOR EACH ROW EXECUTE FUNCTION tg_check_sitios_limite();

CREATE TABLE tc_puestos (
  id                            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy                     int,
  titulo                        text NOT NULL,
  pago_default                  numeric(12,2) NOT NULL DEFAULT 0,
  id_unidad_negocio             uuid REFERENCES tc_unidades_negocio(id),
  id_unidad_negocio_legacy      int,
  duracion_turno_horas          numeric(5,2) NOT NULL DEFAULT 8,
  horas_entre_turnos            numeric(5,2) NOT NULL DEFAULT 0,
  horas_antes_cancelar          numeric(6,2) NOT NULL DEFAULT 72,
  porcentaje_certeza_inicial    numeric(4,3) NOT NULL DEFAULT 1.0,
  porcentaje_minimo             numeric(4,3) NOT NULL DEFAULT 0.6,
  dias_sin_confirmar            int NOT NULL DEFAULT 30,
  requiere_biometrico           boolean NOT NULL DEFAULT true,
  tipo_registro_asistencia      text NOT NULL DEFAULT 'Requiere Entrada y Salida',
  penalizacion_retardo          numeric(6,3) NOT NULL DEFAULT -0.5,
  penalizacion_falta            numeric(6,3) NOT NULL DEFAULT -1.0,
  ciclo_pago                    ciclo_pago_enum NOT NULL DEFAULT 'Semanal',
  regimen_pago                  regimen_pago_enum NOT NULL DEFAULT 'Honorarios Normales',
  sexo_requerido                sexo_enum,
  id_empresa_pagadora_legacy    int,
  activo                        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_puestos_tenant ON tc_puestos(tenant_id) WHERE activo;
CREATE TRIGGER tg_aud_puestos BEFORE INSERT OR UPDATE ON tc_puestos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_turnos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo        text NOT NULL,
  hora_inicio   time NOT NULL,
  hora_fin      time NOT NULL,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, titulo)
);
CREATE TRIGGER tg_aud_turnos BEFORE INSERT OR UPDATE ON tc_turnos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_tipos_personal (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  descripcion   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_aud_tipp BEFORE INSERT OR UPDATE ON tc_tipos_personal FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_responsables (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  nombre        text NOT NULL,
  correo        text,
  telefono      text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_resp BEFORE INSERT OR UPDATE ON tc_responsables FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_fases_evento (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         fase_evento_enum NOT NULL,
  titulo        text NOT NULL,
  orden         int NOT NULL DEFAULT 0,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_aud_fases BEFORE INSERT OR UPDATE ON tc_fases_evento FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_causas_aclaracion (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  descripcion   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_aud_cca BEFORE INSERT OR UPDATE ON tc_causas_aclaracion FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_tipos_documento (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave         text NOT NULL,
  titulo        text NOT NULL,
  requerido_alta boolean NOT NULL DEFAULT false,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
CREATE TRIGGER tg_aud_tdoc BEFORE INSERT OR UPDATE ON tc_tipos_documento FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_uniformes (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                 uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy                 int,
  titulo                    text NOT NULL,
  titulo_abreviado          text,
  id_unidad_negocio_legacy  int,
  id_uniforme_a             int,
  id_uniforme_b             int,
  id_uniforme_c             int,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_unif BEFORE INSERT OR UPDATE ON tc_uniformes FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_clientes (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy     int,
  razon_social  text NOT NULL,
  abreviacion   text,
  rfc           text,
  correo        text,
  telefono      text,
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_cli BEFORE INSERT OR UPDATE ON tc_clientes FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_productos (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  id_legacy      int,
  titulo         text NOT NULL,
  subcategoria   text,
  id_puesto      uuid REFERENCES tc_puestos(id),
  vigente        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_prod BEFORE INSERT OR UPDATE ON tc_productos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_repse_registros (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  numero_repse   text NOT NULL,
  vigencia_desde date,
  vigencia_hasta date,
  cliente_id     uuid REFERENCES tc_clientes(id),
  activo         boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_repse BEFORE INSERT OR UPDATE ON tc_repse_registros FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_estaciones (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  sitio_id      uuid NOT NULL REFERENCES tc_sitios(id) ON DELETE CASCADE,
  nombre        text NOT NULL,
  activa        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_est2 BEFORE INSERT OR UPDATE ON tc_estaciones FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tc_dispositivos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  numero_serie  text NOT NULL,
  modelo        text,
  tipo          tipo_dispositivo_enum NOT NULL DEFAULT 'fijo',
  estacion_id   uuid REFERENCES tc_estaciones(id),
  activo        boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, numero_serie)
);
CREATE TRIGGER tg_aud_disp BEFORE INSERT OR UPDATE ON tc_dispositivos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 5. Parámetros versionables (tp_*)
-- ---------------------------------------------------------------------------

CREATE TABLE tp_folios (
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  tipo_entidad    text NOT NULL,
  ultimo_folio    int NOT NULL DEFAULT 0,
  creado_en       timestamptz NOT NULL DEFAULT now(),
  modificado_en   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, tipo_entidad)
);

CREATE OR REPLACE FUNCTION siguiente_folio(p_tenant uuid, p_tipo text)
RETURNS int AS $$
DECLARE nuevo int;
BEGIN
  INSERT INTO tp_folios (tenant_id, tipo_entidad, ultimo_folio) VALUES (p_tenant, p_tipo, 1)
  ON CONFLICT (tenant_id, tipo_entidad) DO UPDATE SET ultimo_folio = tp_folios.ultimo_folio + 1,
    modificado_en = now()
  RETURNING ultimo_folio INTO nuevo;
  RETURN nuevo;
END $$ LANGUAGE plpgsql;

CREATE TABLE tp_avisos_privacidad (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  version       text NOT NULL,
  texto         text NOT NULL,
  vigente_desde timestamptz NOT NULL DEFAULT now(),
  vigente_hasta timestamptz,
  creado_en     timestamptz NOT NULL DEFAULT now(),
  creado_por    uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por uuid,
  UNIQUE (tenant_id, version)
);
CREATE TRIGGER tg_aud_avp BEFORE INSERT OR UPDATE ON tp_avisos_privacidad FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tp_terminos_condiciones (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  version       text NOT NULL,
  texto         text NOT NULL,
  vigente_desde timestamptz NOT NULL DEFAULT now(),
  vigente_hasta timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, version)
);
CREATE TRIGGER tg_aud_tc BEFORE INSERT OR UPDATE ON tp_terminos_condiciones FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tp_precios_producto (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  producto_id    uuid NOT NULL REFERENCES tc_productos(id) ON DELETE CASCADE,
  puesto_id      uuid REFERENCES tc_puestos(id),
  cliente_id     uuid REFERENCES tc_clientes(id),
  precio_unit    numeric(12,2) NOT NULL,
  moneda         text NOT NULL DEFAULT 'MXN',
  vigente_desde  date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta  date,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_tp_pp ON tp_precios_producto(tenant_id, producto_id);
CREATE TRIGGER tg_aud_tpp BEFORE INSERT OR UPDATE ON tp_precios_producto FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 6. Personas (te_*)
-- ---------------------------------------------------------------------------

CREATE TABLE te_candidatos (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
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
  fuente_reclutamiento  text,
  paso_induccion        boolean NOT NULL DEFAULT false,
  paso_evento_prueba    boolean NOT NULL DEFAULT false,
  promovido_a_empleado  boolean NOT NULL DEFAULT false,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, rfc),
  UNIQUE (tenant_id, curp)
);
CREATE TRIGGER tg_aud_cand BEFORE INSERT OR UPDATE ON te_candidatos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE OR REPLACE FUNCTION valida_rfc_curp(p_tenant uuid, p_rfc text, p_curp text)
RETURNS boolean AS $$
DECLARE existe boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM te_candidatos WHERE tenant_id=p_tenant
      AND ((p_rfc IS NOT NULL AND rfc=p_rfc) OR (p_curp IS NOT NULL AND curp=p_curp))
  ) INTO existe;
  RETURN NOT existe;
END $$ LANGUAGE plpgsql STABLE;

CREATE TABLE te_empleados (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  folio                  int NOT NULL,
  candidato_origen_id    uuid REFERENCES te_candidatos(id),
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
  id_banco               uuid REFERENCES tc_bancos(id),
  cuenta_bancaria        text,
  clabe                  text,
  id_sociedad_pagadora   uuid REFERENCES tc_sociedades_pagadoras(id),
  id_puesto_principal    uuid REFERENCES tc_puestos(id),
  id_sitio_principal     uuid REFERENCES tc_sitios(id),
  id_tipo_personal       uuid REFERENCES tc_tipos_personal(id),
  regimen_pago           regimen_pago_enum NOT NULL DEFAULT 'Honorarios Normales',
  ciclo_pago             ciclo_pago_enum NOT NULL DEFAULT 'Semanal',
  consentimiento_id      uuid,
  activo                 boolean NOT NULL DEFAULT true,
  fecha_alta             date NOT NULL DEFAULT CURRENT_DATE,
  fecha_baja             date,
  motivo_baja            text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, folio),
  UNIQUE (tenant_id, rfc),
  UNIQUE (tenant_id, curp)
);
CREATE INDEX ix_emp_tenant_activo ON te_empleados(tenant_id) WHERE activo;
CREATE TRIGGER tg_aud_emp BEFORE INSERT OR UPDATE ON te_empleados FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
CREATE OR REPLACE FUNCTION tg_check_empleados_limite() RETURNS trigger AS $$
BEGIN IF NEW.activo THEN PERFORM verificar_limite(NEW.tenant_id,'empleados'); END IF; RETURN NEW; END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_emp_limite BEFORE INSERT ON te_empleados FOR EACH ROW EXECUTE FUNCTION tg_check_empleados_limite();

-- Pensiones alimenticias (después de te_empleados)
CREATE TABLE tp_pensiones_alimenticias (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id    uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  expediente     text,
  juzgado        text,
  porcentaje     numeric(5,2),
  monto_fijo     numeric(12,2),
  vigente_desde  date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta  date,
  beneficiario   text,
  clabe_pago     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (porcentaje IS NOT NULL OR monto_fijo IS NOT NULL)
);
CREATE TRIGGER tg_aud_pen BEFORE INSERT OR UPDATE ON tp_pensiones_alimenticias FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tr_empleado_plaza (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id            uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  puesto_id              uuid NOT NULL REFERENCES tc_puestos(id),
  porcentaje_puntualidad numeric(4,3),
  activo                 boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, empleado_id, puesto_id)
);
CREATE TRIGGER tg_aud_ep BEFORE INSERT OR UPDATE ON tr_empleado_plaza FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_consentimientos (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id           uuid REFERENCES te_empleados(id),
  candidato_id          uuid REFERENCES te_candidatos(id),
  aviso_privacidad_id   uuid NOT NULL REFERENCES tp_avisos_privacidad(id),
  acepta                boolean NOT NULL,
  revoca_id             uuid REFERENCES te_consentimientos(id),
  firmado_en            timestamptz NOT NULL DEFAULT now(),
  ip_firma              inet,
  user_agent            text,
  creado_en             timestamptz NOT NULL DEFAULT now(),
  creado_por            uuid,
  CHECK (empleado_id IS NOT NULL OR candidato_id IS NOT NULL)
);
CREATE INDEX ix_consent_emp ON te_consentimientos(tenant_id, empleado_id);
CREATE TRIGGER tg_consent_no_mut BEFORE UPDATE OR DELETE ON te_consentimientos
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

ALTER TABLE te_empleados
  ADD CONSTRAINT fk_emp_consent FOREIGN KEY (consentimiento_id) REFERENCES te_consentimientos(id);

CREATE OR REPLACE FUNCTION consentimiento_vigente(p_empleado uuid)
RETURNS uuid AS $$
DECLARE r uuid;
BEGIN
  SELECT c.id INTO r FROM te_consentimientos c
  WHERE c.empleado_id = p_empleado AND c.acepta = true
    AND NOT EXISTS (SELECT 1 FROM te_consentimientos rv WHERE rv.revoca_id = c.id)
  ORDER BY c.firmado_en DESC LIMIT 1;
  RETURN r;
END $$ LANGUAGE plpgsql STABLE;

CREATE TABLE te_documentos_candidato (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  candidato_id      uuid NOT NULL REFERENCES te_candidatos(id) ON DELETE CASCADE,
  tipo_documento_id uuid NOT NULL REFERENCES tc_tipos_documento(id),
  url_almacen       text NOT NULL,
  hash_sha256       text,
  vigencia_hasta    date,
  observaciones     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_docc BEFORE INSERT OR UPDATE ON te_documentos_candidato FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_documentos_empleado (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id       uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  tipo_documento_id uuid NOT NULL REFERENCES tc_tipos_documento(id),
  url_almacen       text NOT NULL,
  hash_sha256       text,
  vigencia_hasta    date,
  observaciones     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_doce BEFORE INSERT OR UPDATE ON te_documentos_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_movimientos_empleado (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id    uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  tipo_movimiento text NOT NULL,
  fecha_efectiva date NOT NULL DEFAULT CURRENT_DATE,
  campo          text,
  valor_anterior text,
  valor_nuevo    text,
  motivo         text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_move ON te_movimientos_empleado(tenant_id, empleado_id, fecha_efectiva DESC);
CREATE TRIGGER tg_aud_move BEFORE INSERT OR UPDATE ON te_movimientos_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_agenda_freelance (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id     uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  disponible_desde timestamptz NOT NULL,
  disponible_hasta timestamptz NOT NULL,
  puesto_id       uuid REFERENCES tc_puestos(id),
  sitio_id        uuid REFERENCES tc_sitios(id),
  notas           text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (disponible_hasta > disponible_desde)
);
CREATE INDEX ix_ag_emp ON te_agenda_freelance(tenant_id, empleado_id, disponible_desde);
CREATE TRIGGER tg_aud_ag BEFORE INSERT OR UPDATE ON te_agenda_freelance FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_cursos_induccion (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo        text NOT NULL,
  fecha         date NOT NULL,
  hora_inicio   time,
  duracion_horas numeric(4,1),
  instructor    text,
  sitio_id      uuid REFERENCES tc_sitios(id),
  cupo_maximo   int,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_curs BEFORE INSERT OR UPDATE ON te_cursos_induccion FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tr_asistencia_curso (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  curso_id        uuid NOT NULL REFERENCES te_cursos_induccion(id) ON DELETE CASCADE,
  candidato_id    uuid NOT NULL REFERENCES te_candidatos(id) ON DELETE CASCADE,
  asistio         boolean NOT NULL DEFAULT false,
  calificacion    numeric(4,1),
  observaciones   text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, curso_id, candidato_id)
);
CREATE TRIGGER tg_aud_asc BEFORE INSERT OR UPDATE ON tr_asistencia_curso FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_vacantes (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo            text NOT NULL,
  descripcion       text,
  puesto_id         uuid NOT NULL REFERENCES tc_puestos(id),
  sitio_id          uuid REFERENCES tc_sitios(id),
  cliente_id        uuid REFERENCES tc_clientes(id),
  vacantes_cnt      int NOT NULL DEFAULT 1,
  estado            estado_vacante_enum NOT NULL DEFAULT 'borrador',
  publicada_en      timestamptz,
  cierra_en         timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_vac BEFORE INSERT OR UPDATE ON te_vacantes FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tr_postulacion_candidato_vacante (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  vacante_id     uuid NOT NULL REFERENCES te_vacantes(id) ON DELETE CASCADE,
  candidato_id   uuid NOT NULL REFERENCES te_candidatos(id) ON DELETE CASCADE,
  estado         estado_postulacion_enum NOT NULL DEFAULT 'recibida',
  postulado_en   timestamptz NOT NULL DEFAULT now(),
  evaluacion     jsonb,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, vacante_id, candidato_id)
);
CREATE TRIGGER tg_aud_post BEFORE INSERT OR UPDATE ON tr_postulacion_candidato_vacante FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 7. Operativo: pedidos, reservaciones, eventos biométricos
-- ---------------------------------------------------------------------------

CREATE TABLE te_pedidos (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  folio                int NOT NULL,
  titulo               text NOT NULL,
  sitio_id             uuid NOT NULL REFERENCES tc_sitios(id),
  cliente_id           uuid REFERENCES tc_clientes(id),
  id_sociedad_propia   uuid REFERENCES tc_sociedades_propias(id),
  unidad_negocio_id    uuid REFERENCES tc_unidades_negocio(id),
  responsable_id       uuid REFERENCES tc_responsables(id),
  fase_evento_id       uuid REFERENCES tc_fases_evento(id),
  fecha_evento         date NOT NULL,
  hora_inicio          timetz,
  hora_fin             timetz,
  status               text NOT NULL DEFAULT 'borrador',
  costo_estimado       numeric(14,2),
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, folio)
);
CREATE INDEX ix_ped_fecha ON te_pedidos(tenant_id, fecha_evento);
CREATE TRIGGER tg_aud_ped BEFORE INSERT OR UPDATE ON te_pedidos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();
CREATE OR REPLACE FUNCTION tg_pedidos_plan() RETURNS trigger AS $$
BEGIN PERFORM verificar_limite(NEW.tenant_id,'asignacion'); RETURN NEW; END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_ped_plan BEFORE INSERT ON te_pedidos FOR EACH ROW EXECUTE FUNCTION tg_pedidos_plan();

CREATE TABLE te_pedidos_detalle (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  pedido_id     uuid NOT NULL REFERENCES te_pedidos(id) ON DELETE CASCADE,
  puesto_id     uuid NOT NULL REFERENCES tc_puestos(id),
  turno_id      uuid REFERENCES tc_turnos(id),
  cantidad      int NOT NULL CHECK (cantidad > 0),
  costo_unit    numeric(12,2),
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_peddet BEFORE INSERT OR UPDATE ON te_pedidos_detalle FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_reservaciones (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  pedido_id                uuid NOT NULL REFERENCES te_pedidos(id),
  pedido_detalle_id        uuid REFERENCES te_pedidos_detalle(id),
  empleado_id              uuid NOT NULL REFERENCES te_empleados(id),
  puesto_id                uuid NOT NULL REFERENCES tc_puestos(id),
  sitio_id                 uuid NOT NULL REFERENCES tc_sitios(id),
  estado                   estado_reservacion_enum NOT NULL DEFAULT 'preasignado',
  cita_inicio              timestamptz NOT NULL,
  cita_fin                 timestamptz NOT NULL,
  duracion_en_turnos       numeric(4,2) NOT NULL DEFAULT 1,
  estado_asistencia        estado_asistencia_enum NOT NULL DEFAULT 'pendiente',
  hora_entrada_real        timestamptz,
  hora_salida_real         timestamptz,
  estacion_entrada_id      uuid REFERENCES tc_estaciones(id),
  estacion_salida_id       uuid REFERENCES tc_estaciones(id),
  medio_asistencia         medio_asistencia_enum,
  dispositivo_entrada_id   uuid REFERENCES tc_dispositivos(id),
  dispositivo_salida_id    uuid REFERENCES tc_dispositivos(id),
  consentimiento_id        uuid REFERENCES te_consentimientos(id),
  porcentaje_puntualidad   numeric(4,3),
  penalizacion_dias        numeric(6,3) DEFAULT 0,
  penalizacion_sueldo      numeric(12,2) DEFAULT 0,
  estatus_pago             estatus_pago_enum NOT NULL DEFAULT 'pendiente',
  folio_honorarios         int,
  saldo_vencido            numeric(12,2) DEFAULT 0,
  regla_aplicada           text,
  repse_registro_id        uuid REFERENCES tc_repse_registros(id),
  geolocalizacion_lat      numeric(9,6),
  geolocalizacion_lng      numeric(9,6),
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (cita_fin > cita_inicio)
);
CREATE INDEX ix_res_emp_fecha ON te_reservaciones(tenant_id, empleado_id, cita_inicio);
CREATE INDEX ix_res_pedido    ON te_reservaciones(pedido_id);
CREATE INDEX ix_res_estado    ON te_reservaciones(tenant_id, estado);
CREATE TRIGGER tg_aud_res BEFORE INSERT OR UPDATE ON te_reservaciones FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_eventos_biometricos (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id         uuid NOT NULL REFERENCES te_empleados(id),
  reservacion_id      uuid REFERENCES te_reservaciones(id),
  tipo_marcaje        text NOT NULL CHECK (tipo_marcaje IN ('entrada','salida')),
  ts_servidor         timestamptz NOT NULL DEFAULT now(),
  medio_asistencia    medio_asistencia_enum NOT NULL,
  dispositivo_id      uuid REFERENCES tc_dispositivos(id),
  estacion_id         uuid REFERENCES tc_estaciones(id),
  consentimiento_id   uuid NOT NULL REFERENCES te_consentimientos(id),
  latitud             numeric(9,6),
  longitud            numeric(9,6),
  hash_muestra        text,
  corrige_id          uuid REFERENCES te_eventos_biometricos(id),
  regla_aplicada      text,
  creado_en           timestamptz NOT NULL DEFAULT now(),
  creado_por          uuid
);
CREATE INDEX ix_evbio_emp ON te_eventos_biometricos(tenant_id, empleado_id, ts_servidor);

CREATE OR REPLACE FUNCTION tg_evbio_force_ts() RETURNS trigger AS $$
BEGIN NEW.ts_servidor := now(); NEW.creado_en := now(); RETURN NEW; END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_evbio_ts BEFORE INSERT ON te_eventos_biometricos FOR EACH ROW EXECUTE FUNCTION tg_evbio_force_ts();

CREATE OR REPLACE FUNCTION tg_evbio_valida_pre() RETURNS trigger AS $$
DECLARE cvig uuid;
BEGIN
  cvig := consentimiento_vigente(NEW.empleado_id);
  IF cvig IS NULL THEN RAISE EXCEPTION 'Empleado % sin consentimiento vigente', NEW.empleado_id; END IF;
  IF NEW.consentimiento_id IS DISTINCT FROM cvig THEN NEW.consentimiento_id := cvig; END IF;
  IF NEW.medio_asistencia = 'geolocalizacion' THEN
    PERFORM verificar_limite(NEW.tenant_id, 'checador_movil');
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_evbio_val BEFORE INSERT ON te_eventos_biometricos FOR EACH ROW EXECUTE FUNCTION tg_evbio_valida_pre();

CREATE TRIGGER tg_evbio_no_mut BEFORE UPDATE OR DELETE ON te_eventos_biometricos
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

CREATE TABLE te_reservacion_bitacora (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  reservacion_id  uuid NOT NULL REFERENCES te_reservaciones(id) ON DELETE CASCADE,
  ts              timestamptz NOT NULL DEFAULT now(),
  actor_user_id   uuid,
  accion          text NOT NULL,
  estado_antes    text,
  estado_despues  text,
  regla_aplicada  text,
  detalles        jsonb
);
CREATE INDEX ix_bit_res ON te_reservacion_bitacora(reservacion_id);
CREATE TRIGGER tg_bit_no_mut BEFORE UPDATE OR DELETE ON te_reservacion_bitacora
  FOR EACH ROW EXECUTE FUNCTION tg_deny_mutations();

CREATE TABLE te_comunicados (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo        text NOT NULL,
  cuerpo        text NOT NULL,
  publicado_en  timestamptz,
  publicado_por uuid,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_com BEFORE INSERT OR UPDATE ON te_comunicados FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE tr_comunicado_destinatario (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  comunicado_id   uuid NOT NULL REFERENCES te_comunicados(id) ON DELETE CASCADE,
  empleado_id     uuid REFERENCES te_empleados(id),
  candidato_id    uuid REFERENCES te_candidatos(id),
  enviado_en      timestamptz,
  leido_en        timestamptz,
  canal           text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (empleado_id IS NOT NULL OR candidato_id IS NOT NULL)
);
CREATE TRIGGER tg_aud_comd BEFORE INSERT OR UPDATE ON tr_comunicado_destinatario FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 8. Fiscal (facturas, pagos, nómina, extras, aclaraciones)
-- ---------------------------------------------------------------------------

CREATE TABLE te_nominas_periodo (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  ciclo_pago         ciclo_pago_enum NOT NULL,
  fecha_desde        date NOT NULL,
  fecha_hasta        date NOT NULL,
  cerrada            boolean NOT NULL DEFAULT false,
  fecha_cierre       timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (fecha_hasta >= fecha_desde)
);
CREATE TRIGGER tg_aud_nom BEFORE INSERT OR UPDATE ON te_nominas_periodo FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_nomina_detalle (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  nomina_id                uuid NOT NULL REFERENCES te_nominas_periodo(id) ON DELETE CASCADE,
  empleado_id              uuid NOT NULL REFERENCES te_empleados(id),
  reservaciones_cnt        int NOT NULL DEFAULT 0,
  monto_bruto              numeric(14,2) NOT NULL DEFAULT 0,
  penalizaciones_aplicadas numeric(14,2) NOT NULL DEFAULT 0,
  extras_aplicados         numeric(14,2) NOT NULL DEFAULT 0,
  pension_aplicada         numeric(14,2) NOT NULL DEFAULT 0,
  monto_neto               numeric(14,2) NOT NULL DEFAULT 0,
  salario_diario_promedio  numeric(12,2) NOT NULL DEFAULT 0,
  regimen_pago             regimen_pago_enum NOT NULL,
  folio_pago               int,
  estatus_pago             estatus_pago_enum NOT NULL DEFAULT 'pendiente',
  precauciones             jsonb,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_nomdet ON te_nomina_detalle(tenant_id, nomina_id);
CREATE TRIGGER tg_aud_nomdet BEFORE INSERT OR UPDATE ON te_nomina_detalle FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_extras_nomina (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id     uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  nomina_id       uuid REFERENCES te_nominas_periodo(id),
  concepto        text NOT NULL,
  tipo            text NOT NULL CHECK (tipo IN ('bono','deduccion','ajuste')),
  monto           numeric(12,2) NOT NULL,
  aplicado        boolean NOT NULL DEFAULT false,
  autorizado_por  uuid,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_ext_emp ON te_extras_nomina(tenant_id, empleado_id);
CREATE TRIGGER tg_aud_ext BEFORE INSERT OR UPDATE ON te_extras_nomina FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_facturas_enc (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  folio                int NOT NULL,
  serie                text,
  cliente_id           uuid REFERENCES tc_clientes(id),
  sociedad_propia_id   uuid REFERENCES tc_sociedades_propias(id),
  fecha_emision        date NOT NULL DEFAULT CURRENT_DATE,
  subtotal             numeric(14,2) NOT NULL DEFAULT 0,
  iva                  numeric(14,2) NOT NULL DEFAULT 0,
  total                numeric(14,2) NOT NULL DEFAULT 0,
  uuid_sat             text,
  status               text NOT NULL DEFAULT 'borrador',
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, serie, folio)
);
CREATE TRIGGER tg_aud_facenc BEFORE INSERT OR UPDATE ON te_facturas_enc FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_facturas_det (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  factura_id     uuid NOT NULL REFERENCES te_facturas_enc(id) ON DELETE CASCADE,
  reservacion_id uuid REFERENCES te_reservaciones(id),
  concepto       text NOT NULL,
  cantidad       numeric(12,3) NOT NULL DEFAULT 1,
  precio_unit    numeric(14,2) NOT NULL,
  importe        numeric(14,2) NOT NULL,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE TRIGGER tg_aud_facdet BEFORE INSERT OR UPDATE ON te_facturas_det FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_pagos_dispersion (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id           uuid NOT NULL REFERENCES te_empleados(id),
  nomina_detalle_id     uuid REFERENCES te_nomina_detalle(id),
  monto                 numeric(14,2) NOT NULL,
  banco_id              uuid REFERENCES tc_bancos(id),
  clabe                 text,
  referencia_bancaria   text,
  status                estatus_pago_enum NOT NULL DEFAULT 'pendiente',
  dispersado_en         timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_disp_emp ON te_pagos_dispersion(tenant_id, empleado_id, dispersado_en DESC);
CREATE TRIGGER tg_aud_disp2 BEFORE INSERT OR UPDATE ON te_pagos_dispersion FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE te_aclaraciones (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id          uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  reservacion_id       uuid REFERENCES te_reservaciones(id),
  pago_id              uuid REFERENCES te_pagos_dispersion(id),
  causa_id             uuid NOT NULL REFERENCES tc_causas_aclaracion(id),
  descripcion          text NOT NULL,
  estado               text NOT NULL DEFAULT 'abierta',
  resuelta_en          timestamptz,
  resuelta_por         uuid,
  monto_ajuste         numeric(12,2),
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX ix_acl_emp ON te_aclaraciones(tenant_id, empleado_id);
CREATE TRIGGER tg_aud_acl BEFORE INSERT OR UPDATE ON te_aclaraciones FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 9. Reglas de negocio (traducciones PRC_*)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION obtener_certeza_puesto(p_empleado uuid, p_puesto uuid)
RETURNS numeric AS $$
DECLARE cert numeric; ini numeric;
BEGIN
  SELECT porcentaje_puntualidad INTO cert FROM tr_empleado_plaza
    WHERE empleado_id=p_empleado AND puesto_id=p_puesto AND activo;
  IF cert IS NOT NULL THEN RETURN cert; END IF;
  SELECT porcentaje_certeza_inicial INTO ini FROM tc_puestos WHERE id=p_puesto;
  RETURN COALESCE(ini, 1.0);
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION valida_emp_puesto(p_empleado uuid, p_puesto uuid)
RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE cert numeric; minimo numeric; sexo_req sexo_enum; sexo_emp sexo_enum;
BEGIN
  SELECT porcentaje_minimo, sexo_requerido INTO minimo, sexo_req FROM tc_puestos WHERE id=p_puesto;
  SELECT sexo INTO sexo_emp FROM te_empleados WHERE id=p_empleado;
  IF sexo_req IS NOT NULL AND sexo_emp IS DISTINCT FROM sexo_req THEN
    RETURN QUERY SELECT false, format('sexo requerido %s, empleado %s', sexo_req, sexo_emp); RETURN;
  END IF;
  cert := obtener_certeza_puesto(p_empleado, p_puesto);
  IF cert < minimo THEN
    RETURN QUERY SELECT false, format('certeza %s < mínimo %s', cert, minimo); RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION valida_no_empalme(
  p_empleado uuid, p_puesto uuid, p_cita_inicio timestamptz, p_cita_fin timestamptz,
  p_ignorar_reservacion uuid DEFAULT NULL
) RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE margen_h numeric; ventana_inicio timestamptz; ventana_fin timestamptz; conflicto record;
BEGIN
  SELECT horas_entre_turnos INTO margen_h FROM tc_puestos WHERE id=p_puesto;
  ventana_inicio := p_cita_inicio - (margen_h || ' hours')::interval;
  ventana_fin    := p_cita_fin    + (margen_h || ' hours')::interval;
  SELECT r.id, r.cita_inicio, r.cita_fin INTO conflicto FROM te_reservaciones r
    WHERE r.empleado_id=p_empleado AND r.estado NOT IN ('cancelado','procesado')
      AND (p_ignorar_reservacion IS NULL OR r.id <> p_ignorar_reservacion)
      AND tstzrange(r.cita_inicio, r.cita_fin, '[)') && tstzrange(ventana_inicio, ventana_fin, '[)')
    LIMIT 1;
  IF FOUND THEN
    RETURN QUERY SELECT false, format('traslape con reservación %s, margen %s h', conflicto.id, margen_h);
    RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION valida_cancelacion(p_reservacion uuid)
RETURNS TABLE (valido boolean, motivo text) AS $$
DECLARE r te_reservaciones; min_h numeric; faltan_h numeric;
BEGIN
  SELECT * INTO r FROM te_reservaciones WHERE id=p_reservacion;
  IF r.estado='forzada' THEN RETURN QUERY SELECT true, 'forzada'::text; RETURN; END IF;
  SELECT horas_antes_cancelar INTO min_h FROM tc_puestos WHERE id=r.puesto_id;
  faltan_h := EXTRACT(EPOCH FROM (r.cita_inicio - now()))/3600;
  IF faltan_h < min_h THEN
    RETURN QUERY SELECT false, format('faltan %.1f h; mínimo %s h', faltan_h, min_h); RETURN;
  END IF;
  RETURN QUERY SELECT true, ''::text;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION tg_reservacion_valida() RETURNS trigger AS $$
DECLARE v record;
BEGIN
  PERFORM verificar_limite(NEW.tenant_id,'asignacion');
  SELECT * INTO v FROM valida_emp_puesto(NEW.empleado_id, NEW.puesto_id);
  IF NOT v.valido THEN NEW.regla_aplicada := 'PRC_ValidaEmpPuesto: '||v.motivo;
    RAISE EXCEPTION 'Empleado no califica: %', v.motivo; END IF;
  SELECT * INTO v FROM valida_no_empalme(NEW.empleado_id, NEW.puesto_id, NEW.cita_inicio, NEW.cita_fin);
  IF NOT v.valido THEN NEW.regla_aplicada := 'PRC_Noempalmereservacion: '||v.motivo;
    RAISE EXCEPTION 'Traslape: %', v.motivo; END IF;
  NEW.regla_aplicada := 'reservacion_creada_ok';
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER tg_res_valida BEFORE INSERT ON te_reservaciones FOR EACH ROW EXECUTE FUNCTION tg_reservacion_valida();

CREATE OR REPLACE FUNCTION cancelacion_automatica_preasignados()
RETURNS int AS $$
DECLARE n int := 0; p tp_parametros_globales;
BEGIN
  FOR p IN SELECT * FROM tp_parametros_globales LOOP
    WITH cancelaciones AS (
      UPDATE te_reservaciones SET estado='cancelado', regla_aplicada='PRC_CancelacionAutomaticaPreasignados'
      WHERE tenant_id=p.tenant_id AND estado='confirmado_opcional'
        AND (cita_inicio - now()) < (p.horas_lookahead_autocancel||' hours')::interval
        AND (now() - creado_en) > (p.horas_gracia_confirmacion||' hours')::interval
      RETURNING id
    ) SELECT n + count(*) INTO n FROM cancelaciones;
  END LOOP;
  RETURN n;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calcular_nomina_periodo(p_nomina uuid)
RETURNS int AS $$
DECLARE n int := 0; npe te_nominas_periodo;
BEGIN
  SELECT * INTO npe FROM te_nominas_periodo WHERE id=p_nomina;
  DELETE FROM te_nomina_detalle WHERE nomina_id=p_nomina;
  INSERT INTO te_nomina_detalle (
    tenant_id, nomina_id, empleado_id, reservaciones_cnt, monto_bruto,
    penalizaciones_aplicadas, monto_neto, salario_diario_promedio, regimen_pago, precauciones
  )
  SELECT npe.tenant_id, npe.id, r.empleado_id, count(*)::int,
    COALESCE(sum(pd.costo_unit * r.duracion_en_turnos), 0),
    COALESCE(sum(r.penalizacion_sueldo), 0),
    COALESCE(sum(pd.costo_unit * r.duracion_en_turnos + r.penalizacion_sueldo), 0),
    CASE WHEN count(*) > 0
      THEN COALESCE(sum(pd.costo_unit * r.duracion_en_turnos + r.penalizacion_sueldo),0)/count(*)
      ELSE 0 END,
    e.regimen_pago,
    jsonb_build_object(
      'sin_banco', bool_or(e.id_banco IS NULL),
      'sin_pagadora', bool_or(e.id_sociedad_pagadora IS NULL),
      'sin_clabe', bool_or(e.clabe IS NULL OR e.clabe='')
    )
  FROM te_reservaciones r
  JOIN te_empleados e ON e.id = r.empleado_id
  LEFT JOIN te_pedidos_detalle pd ON pd.id = r.pedido_detalle_id
  WHERE r.tenant_id=npe.tenant_id AND r.estado='procesado'
    AND r.estado_asistencia IN ('asistencia','retardo','falta')
    AND r.cita_inicio::date BETWEEN npe.fecha_desde AND npe.fecha_hasta
  GROUP BY r.empleado_id, e.regimen_pago;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reporte_precauciones_nomina(p_tenant uuid)
RETURNS TABLE (empleado_id uuid, nombre text, motivos text[]) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.nombres||' '||e.apellido_paterno,
    ARRAY_REMOVE(ARRAY[
      CASE WHEN e.id_banco IS NULL THEN 'sin banco' END,
      CASE WHEN e.clabe IS NULL OR e.clabe='' THEN 'sin CLABE' END,
      CASE WHEN e.id_sociedad_pagadora IS NULL THEN 'sin pagadora' END,
      CASE WHEN e.regimen_pago IS NULL THEN 'sin régimen' END
    ], NULL)
  FROM te_empleados e
  WHERE e.tenant_id=p_tenant AND e.activo
    AND (e.id_banco IS NULL OR e.clabe IS NULL OR e.clabe=''
      OR e.id_sociedad_pagadora IS NULL OR e.regimen_pago IS NULL);
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION promover_candidato_a_empleado(p_candidato uuid)
RETURNS uuid AS $$
DECLARE c te_candidatos; nuevo_folio int; nuevo_id uuid;
BEGIN
  SELECT * INTO c FROM te_candidatos WHERE id=p_candidato;
  IF c.id IS NULL THEN RAISE EXCEPTION 'candidato no existe'; END IF;
  IF NOT c.paso_induccion THEN RAISE EXCEPTION 'candidato sin inducción'; END IF;
  nuevo_folio := siguiente_folio(c.tenant_id,'empleado');
  INSERT INTO te_empleados (
    tenant_id, folio, candidato_origen_id, nombres, apellido_paterno, apellido_materno,
    rfc, curp, fecha_nacimiento, sexo, telefono, correo, direccion
  ) VALUES (
    c.tenant_id, nuevo_folio, c.id, c.nombres, c.apellido_paterno, c.apellido_materno,
    c.rfc, c.curp, c.fecha_nacimiento, c.sexo, c.telefono, c.correo, c.direccion
  ) RETURNING id INTO nuevo_id;
  UPDATE te_candidatos SET promovido_a_empleado=true WHERE id=c.id;
  RETURN nuevo_id;
END $$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- 10. RLS por tenant
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text; tables text[] := ARRAY[
  'te_tenants','te_suscripciones','tp_parametros_globales',
  'tc_estados_mx','tc_bancos','tc_sociedades_pagadoras','tc_sociedades_propias',
  'tc_unidades_negocio','tc_sitios','tc_puestos','tc_turnos','tc_tipos_personal',
  'tc_responsables','tc_fases_evento','tc_causas_aclaracion','tc_tipos_documento',
  'tc_uniformes','tc_clientes','tc_productos','tc_repse_registros',
  'tc_estaciones','tc_dispositivos',
  'tp_folios','tp_avisos_privacidad','tp_terminos_condiciones','tp_precios_producto','tp_pensiones_alimenticias',
  'te_candidatos','te_empleados','tr_empleado_plaza','te_consentimientos',
  'te_documentos_candidato','te_documentos_empleado','te_movimientos_empleado','te_agenda_freelance',
  'te_cursos_induccion','tr_asistencia_curso','te_vacantes','tr_postulacion_candidato_vacante',
  'te_pedidos','te_pedidos_detalle','te_reservaciones','te_eventos_biometricos','te_reservacion_bitacora',
  'te_comunicados','tr_comunicado_destinatario',
  'te_nominas_periodo','te_nomina_detalle','te_extras_nomina',
  'te_facturas_enc','te_facturas_det','te_pagos_dispersion','te_aclaraciones'
];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    IF t = 'te_tenants' THEN
      EXECUTE format('CREATE POLICY p_%1$s_all ON %1$s USING (id = current_tenant_id()) WITH CHECK (id = current_tenant_id())', t);
    ELSE
      EXECUTE format(
        'CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_ins ON %1$s FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_upd ON %1$s FOR UPDATE USING (tenant_id = current_tenant_id());
         CREATE POLICY p_%1$s_del ON %1$s FOR DELETE USING (tenant_id = current_tenant_id());', t);
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 11. Grants para roles Supabase
-- ---------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES    IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES    TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 12. Semillas
-- ---------------------------------------------------------------------------

INSERT INTO tc_planes_suscripcion (codigo, titulo, descripcion, max_sitios, max_empleados_activos,
  incluye_checador_fijo, incluye_checador_movil, incluye_asignacion, incluye_certeza,
  incluye_nomina, incluye_repse, precio_mensual_mxn)
VALUES
  ('FREE','PeopleMovil FREE / Piloto','Un sitio, hasta 15 trabajadores, solo checador fijo.',
    1, 15, true, false, false, false, false, false, 0),
  ('PRO','PeopleMovil PRO','Sitios y trabajadores ilimitados, motor completo.',
    NULL, NULL, true, true, true, true, true, true, 1499.00);

INSERT INTO te_tenants (id, razon_social, rfc, vertical)
VALUES ('00000000-0000-0000-0000-000000000001','Demo PeopleMovil, S.A. de C.V.','DPM260101000','eventos');

INSERT INTO te_suscripciones (tenant_id, plan_codigo)
VALUES ('00000000-0000-0000-0000-000000000001','PRO');

INSERT INTO tp_parametros_globales (tenant_id) VALUES ('00000000-0000-0000-0000-000000000001');

INSERT INTO tp_avisos_privacidad (tenant_id, version, texto) VALUES (
  '00000000-0000-0000-0000-000000000001','v1.0',
  'Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. Revocable en cualquier momento.'
);

INSERT INTO tc_fases_evento (tenant_id, clave, titulo, orden) VALUES
  ('00000000-0000-0000-0000-000000000001','montaje','Montaje',1),
  ('00000000-0000-0000-0000-000000000001','evento','Evento en vivo',2),
  ('00000000-0000-0000-0000-000000000001','desmontaje','Desmontaje',3);

INSERT INTO tc_tipos_personal (tenant_id, clave, descripcion) VALUES
  ('00000000-0000-0000-0000-000000000001','freelance','Personal freelance / eventual'),
  ('00000000-0000-0000-0000-000000000001','staff','Personal de planta'),
  ('00000000-0000-0000-0000-000000000001','interno','Personal interno de oficina');

INSERT INTO tc_tipos_documento (tenant_id, clave, titulo, requerido_alta) VALUES
  ('00000000-0000-0000-0000-000000000001','ine','INE / IFE vigente', true),
  ('00000000-0000-0000-0000-000000000001','curp','CURP', true),
  ('00000000-0000-0000-0000-000000000001','rfc_const','Constancia de situación fiscal', false),
  ('00000000-0000-0000-0000-000000000001','comp_dom','Comprobante de domicilio', true),
  ('00000000-0000-0000-0000-000000000001','cv','Currículum vitae', false),
  ('00000000-0000-0000-0000-000000000001','contrato','Contrato firmado', false);

INSERT INTO tc_causas_aclaracion (tenant_id, clave, descripcion) VALUES
  ('00000000-0000-0000-0000-000000000001','monto_incorrecto','Monto de pago incorrecto'),
  ('00000000-0000-0000-0000-000000000001','no_recibi','No recibí el pago'),
  ('00000000-0000-0000-0000-000000000001','asistencia_no_registrada','Mi asistencia no quedó registrada'),
  ('00000000-0000-0000-0000-000000000001','penalizacion_incorrecta','Penalización mal aplicada'),
  ('00000000-0000-0000-0000-000000000001','extra_faltante','Bono o extra no aplicado');

INSERT INTO tc_turnos (tenant_id, titulo, hora_inicio, hora_fin) VALUES
  ('00000000-0000-0000-0000-000000000001','Turno mañana','07:00','15:00'),
  ('00000000-0000-0000-0000-000000000001','Turno tarde','15:00','23:00'),
  ('00000000-0000-0000-0000-000000000001','Turno noche','23:00','07:00'),
  ('00000000-0000-0000-0000-000000000001','Turno evento 12h','12:00','23:59');

SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';


-- ---- SEMILLAS AUTOGENERADAS DESDE .xlsx REALES (nomenclatura tc_*) ----
-- Sociedades Pagadoras (19 reales, del sistema Lobo)
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'As Deporte, S.A. de C.V.', 22135, 194);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 20, 'Car Sport Racing SA de CV', 50420, 189);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 17, 'ETK Boletos, S.A. DE C.V.', 46187, 219);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 7, 'Grupo Automovilstico Nacional y Deportivo, S. De R.L. de C.V.', 20939, 140);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 19, 'ICESA', 48941, 12);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 22, 'Make Pro, S.A. de C.V.', 20775, 10);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Ocesa Anfiteatro, S.A. de C.V.', 20617, 11);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 14, 'Ocesa Comercial, S.A. de C.V.', 21808, 193);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 21, 'Ocesa Presenta, S.A. de C.V.', 51412, 214);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 10, 'Ocesa Promotora, S. A. de C.V.', 44396, 165);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Operadora de Centros de Espectculos, S.A. de C.V.', 20619, 9);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Promotodo Mxico, S.A. de C.V.', 20849, 42);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Promotora de Espectculos de Occidente, S.A. de C.V.', 23410, 199);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Servicios Administrativos del Entretenimiento S.A. de C.V', 20984, 148);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 6, 'Servicios de Proteccin Privada Lobo, S.A. de C.V.', 20589, 85);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 13, 'Servicios Especializados Para la Venta Automatizada de Boletos, S.A. de C.V.', 25065, 203);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 18, 'SOLO ELE-MENTUM SA DE CV', 42047, 214);
INSERT INTO tc_sociedades_pagadoras (tenant_id, id_legacy, titulo, id_empresa_pagadora_legacy, numero_sociedad) VALUES ('00000000-0000-0000-0000-000000000001', 23, 'Venta de Boletos Por Computadora, S.A. de C.V.', 20642, 7);

-- Sociedades Propias (6 reales)
INSERT INTO tc_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 1, '085-Lobo', 'Servicios de Proteccin Privada Lobo, SA de CV', true, true, false, 6);
INSERT INTO tc_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 2, '145-Corhum', 'Coordinacin de Recursos Humanos, SA de CV', true, true, false, NULL);
INSERT INTO tc_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'OCTR-Ocesa Corhum', 'Operadora de Centros de Espectaculos SA de CV - Corhum', true, true, true, NULL);
INSERT INTO tc_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Ocesa RH', 'Operadora de Centros de Espectculos', true, true, true, NULL);
INSERT INTO tc_sociedades_propias (tenant_id, id_legacy, titulo, razon_social, vigente, genera_factura, genera_orden_servicio, id_sociedad_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'As Deporte', 'As Deporte, S.A. De C.V.', false, true, true, NULL);

-- Uniformes (29 reales)
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 41, 'Pantaln Negro de Vestir, Playera Lobo y Chamarra Lobo', 'Seguridad ', 1, 57, 56, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 20, 'De Civil', 'De Civil', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 36, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 8, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 38, 'Pantaln Negro de Vestir, Playera Azul y Chamarra Azul', 'Control Accesos', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 39, 'Pantaln Negro de Vestir, Playera Naranja y Chamarra Naranja', 'Anfitriones', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 15, 'Pantaln Negro de Vestir, Playera Negro-Rojo y Chamarra Negro-Rojo', 'Seguridad', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 37, 'Pantanln negro de vestir y playera guinda', 'Pant Negro Playera Guinda', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 1, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 17, 'De Civil', 'De Civil', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 35, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 23, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 1, 'Pantaln Negro de Vestir, Playera Azul y Chamarra Azul', 'Control Accesos', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 13, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 5, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 16, 'De Civil', 'De Civil', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 34, 'Pantaln Mezclilla Azul, Camisa Blanca y Zapatos Negros', 'Mezclilla Azul Camisa Blanca Zap Negros', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 24, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Pantaln Negro de Vestir, Playera Naranja y Chamarra Naranja', 'Anfitriones', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 3, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 21, 'De Civil', 'De Civil', 2, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 14, 'Pantaln Negro de Vestir y Camisa Azul', 'Pant Negro Camisa Azul', 2, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Pantaln Negro de Vestir y Camisa Blanca', 'Pant Negro Camisa Blanca', 2, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 32, 'Pantaln Negro de Vestir y Playera Crema', 'Pant Negro Playera Crema', 2, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 25, 'Pantaln Negro de Vestir y Playera Gris', 'Pant Negro Playera Gris', 2, NULL, NULL, NULL);
INSERT INTO tc_uniformes (tenant_id, id_legacy, titulo, titulo_abreviado, id_unidad_negocio_legacy, id_uniforme_a, id_uniforme_b, id_uniforme_c) VALUES ('00000000-0000-0000-0000-000000000001', 29, 'Traje Negro y Camisa Blanca', 'Traje Negro Camisa Blanca', 2, NULL, NULL, NULL);

-- Puestos (30 representativos de 984 reales, todos los parámetros de negocio)
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 46, 'Tecnico Audio', 0, 9, 12, 0, 72, 1, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 47, 'Encargado de Generador', 600, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 48, 'Productor B', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 49, 'Productor C', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 50, 'Stage Manager B', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 51, 'Stage Manager C', 0, 9, 24, 0, 72, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 52, 'Asistente de Produccion B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 53, 'Asistente de Produccion C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 54, 'Asistente de Produccion D', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 55, 'Asistente de Produccion E', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 56, 'Logistica B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 57, 'Logistica C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 58, 'Logistica D', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 59, 'Logistica E', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 60, 'Diseo de Iluminacion A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 61, 'Diseo de Iluminacion B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 62, 'Diseo de Iluminacion C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 63, 'Ingeniero de Audio A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 64, 'Ingeniero de Audio B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 65, 'Ingeniero de Audio C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 66, 'Ingeniero de Luces A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 67, 'Ingeniero de Luces B', 0, 9, 24, 0, 24, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 68, 'Ingeniero de Luces C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 69, 'Pre produccion y atencion audio / luz A', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 70, 'Pre produccion y atencion audio / luz B', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 71, 'Pre produccion y atencion audio / luz C', 0, 9, 24, 0, 0, 1, 0.75, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 72, 'Runner con coche', 0, 9, 21, 0, 72, 1, 0.75, 90, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 73, 'Runner sin coche', 0, 9, 21, 0, 0, 1, 0.75, 90, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 74, 'Coordinador Asistente', 600, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Normales', 7);
INSERT INTO tc_puestos (tenant_id, id_legacy, titulo, pago_default, id_unidad_negocio_legacy, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, penalizacion_retardo, penalizacion_falta, ciclo_pago, regimen_pago, id_empresa_pagadora_legacy) VALUES ('00000000-0000-0000-0000-000000000001', 75, 'Climber', 900, 9, 12, 0, 72, 0.9, 0.9, 120, true, 'Requiere Entrada y Salida', -0.5, -1, 'Semanal', 'Honorarios Asimilables', 8);

-- Lugares de Cita (15 reales representativos)
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 1, 'Palacio de los Deportes ', 'foro', 'Ro Churubusco Esquina con Ail, Colonia Granjas Mxico  ', 'Ro Churubusco Esquina con Ail Puerta 1', '237 99 99', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 2, 'Foro Sol', 'foro', 'Viaducto ro piedad, metro ciudad deportiva Acceso D de Foro Sol, Colonia Granjas Mxico, Delegacin Iztacalco, Distrito Federal', 'Viaducto ro piedad, metro ciudad deportiva Acceso D', '764 84 46', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 3, 'Gimnasio Juan de la Barrera', 'foro', 'Rio churubusco Esquina con divisin del norte, Distrito Federal', 'Rio churubusco Esquina con divisin del norte', NULL, true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 4, 'Centro de Exposiciones del World Trade Center', 'foro', 'Filadelfia Sin Nmero entre insurgentes y dakota, Colonia Npoles, Delegacin Benito Jurez, Ciudad Mxico, Estado Distrito Federal', NULL, '628 83 66   628 83 64   628 83 02', false);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 5, 'Auditorio Nacional', 'foro', 'Paseo de la reforma 50, Colonia Bosque de Chapultepc, Delegacin Miguel Hidalgo, Ciudad Mxico, Distrito Federal, Cdigo Postal 11560', 'Paseo de la reforma 50, Colonia Bosque de Chapultepc', '280 74 76', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 6, 'Teatro Metroplitan', 'foro', 'Independencia 90, Colonia Centro, Distrito Federal', 'Independencia 90, Colonia Centro', '510 39 79', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 7, 'Teatro Ofen', 'foro', 'Luis Moya 40 Esquina con Independencia, Colonia Centro, Ciudad Mxico, Estado Distrito Federal', NULL, '512 60 39   512 62 71', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 8, 'Hard Rock Caf', 'foro', 'Campos Elseos 290 Esquina con Reforma, Colonia Polanco, Delegacin Miguel Hidalgo, Distrito Federal, Cdigo Postal 11560', 'Campos Elseos 290 Esquina con Reforma, Colonia Polanco', '5327-7101,  Fax. 5327-7106', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 9, 'Estadio Azul Puerta 5', 'foro', 'Holbein Puerta nmero 5 Esquina con Indiana, Colonia Ciudad de los Deportes, Delegacin Benito Jurez, Distrito Federal', 'Holbein Esquina con Indiana Puerta 5', NULL, true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 10, 'Estadio Azteca', 'foro', 'Calzada de Tllpan 3465 Puerta 1, Colonia Santa Ursula, Delegacin Tlalpan, Distrito Federal, Cdigo Postal 04650', 'Calzada de Tllpan 3465 Puerta 1', '5617-8080', true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 11, 'Oficinas de Recursos Humanos', 'foro', 'Dakota 85-6 entre Yosemite y Altadena, Colonia Npoles, Delegacin Benito Juarez, Ciudad Mxico, Estado Distrito Federal, CP 03810', NULL, '5682 85 48', false);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 12, 'Caf Casino', 'foro', 'Dakota 85 Esquina con Yosemite, Colonia Npoles, Delegacin Benito Juarez, Distrito Federal, Cdigo Postal 03810', 'Dakota 85 Esquina con Yosemite, Colonia Npoles', '5687 57 73', false);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 25, 'World Trade Center', 'foro', 'Montecito 38 Esquina Dakota, cita en  puerta parablica., Colonia Npoles, Delegacin Benito Juarez, Estado Distrito Federal, CP 03810', NULL, NULL, true);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 26, 'Allegro Restaurante Bar', 'foro', NULL, NULL, NULL, false);
INSERT INTO tc_sitios (tenant_id, id_legacy, titulo, tipo_sitio, direccion, direccion_abreviada, telefonos, activo) VALUES ('00000000-0000-0000-0000-000000000001', 30, 'Six Flags', 'foro', 'Carretera Picacho Ajusco kilometro 1.5, Colonia Hroes de Padierna., Delegacin Tlalpan, Ciudad Mxico D.F., Estado Distrito Federal, CP 14200', NULL, '57 28 72 00   56 45 77 90', true);

-- Bancos (semilla estándar México)
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '002', 'BANAMEX');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '012', 'BBVA');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '014', 'SANTANDER');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '021', 'HSBC');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '030', 'BAJIO');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '036', 'INBURSA');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '037', 'INTERACCIONES');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '042', 'MIFEL');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '044', 'SCOTIABANK');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '058', 'BANREGIO');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '059', 'INVEX');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '072', 'BANORTE');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '102', 'ABC CAPITAL');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '103', 'AMERICAN EXPRESS');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '106', 'BANK OF AMERICA');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '127', 'AZTECA');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '128', 'AUTOFIN');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '132', 'BMULTIVA');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '137', 'BANCOPPEL');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '143', 'CIBANCO');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '147', 'BANKAOOL');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '166', 'BANSEFI');
INSERT INTO tc_bancos (tenant_id, clave, nombre) VALUES ('00000000-0000-0000-0000-000000000001', '646', 'STP');
-- fin ---


-- ============================================================================
-- Bloque agregado por migración 001 (bitácora de accesos + RPC log_bitacora)
-- ============================================================================
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


-- ============================================================================
-- Bloque agregado por migración 002 (portales freelance + público)
-- ============================================================================
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

-- ============================================================================
-- Migración 003a_modelo_comercial
-- ============================================================================
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

-- ============================================================================
-- Migración 003b_reclutamiento_completo
-- ============================================================================
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

-- ============================================================================
-- Migración 003c_fiscal_completo
-- ============================================================================
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

-- ============================================================================
-- Migración 003d_personal_logs_misc
-- ============================================================================
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

-- ============================================================================
-- Migración 005 — Usuarios internos, Roles y Permisos (equivalente a GAM)
-- ============================================================================
-- Contexto: el sistema legado (Lobo/AppSCPF) usaba GAM (GeneXus Access Manager)
-- con 5 roles reales -- Unknown, Administrador, Lobo, Operacion, Candidato -- y
-- permisos granulares por pantalla+acción (Insert/Update/Delete/Execute/
-- FullControl), confirmado en las capturas reales de gamwwroles.aspx y
-- gamwwrolepermissions.aspx. Ver Dev/documentacion-referencia/MENU_Y_ROLES.md.
--
-- Decisión de diseño: el rol "Candidato" de GAM NO necesita fila en
-- te_usuarios/tc_roles -- su alcance siempre es "solo sus propios datos", no
-- permisos por módulo. Es gente del público general que se registra desde el
-- sitio web para aplicar a una vacante publicada: alto volumen (haxta ~4000
-- candidatos vigentes simultáneos para cubrir eventos), bajísima fricción, y
-- la mayoría NUNCA avanza en el proceso (aplican y no vuelven a entrar). Por
-- eso su acceso NO es una cuenta con password sino te_magic_links (tokens de
-- un solo uso con propósito: completar_perfil/subir_docs/ver_postulacion),
-- apuntando a te_candidatos -- ver migración 002. Solo cuando un candidato
-- pasa inducción y es promovido (promover_candidato_a_empleado()) obtiene
-- fila en te_empleados y AHÍ SÍ empieza a usar te_empleados.auth_user_id
-- (login real con NIP, portal freelance) para agenda/checador/confirmaciones.
-- te_usuarios/tc_roles cubre únicamente al personal INTERNO (Administrador,
-- Lobo, Operación) que sí necesita permisos por módulo.
-- El rol "Unknown" de GAM (default cuando no hay rol asignado) no se materializa
-- como fila -- un usuario sin filas en tr_usuario_rol simplemente no tiene permisos.
--
-- Cambios:
--   1. te_usuarios     -- cuenta interna ligada a auth.users de Supabase
--   2. tc_roles        -- catálogo de roles por tenant (seed: Administrador, Lobo, Operación)
--   3. tr_usuario_rol  -- asignación de roles a usuarios (N:N)
--   4. tc_permisos     -- catálogo global de permisos granulares por módulo+acción
--   5. tr_rol_permiso  -- asignación de permisos a roles (N:N)
--   6. Función tiene_permiso(auth_uid, codigo_permiso)
--   7. Nota sobre creado_por/modificado_por/actor_id/autorizado_por (sin FK duro)
--   8. RLS + GRANTS
--   9. Semillas: roles + catálogo de permisos + asignación por defecto
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. te_usuarios
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_usuarios (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id              uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  auth_user_id           uuid NOT NULL UNIQUE,   -- FK lógica a auth.users.id de Supabase
  nombre_usuario         text NOT NULL,
  correo                 text NOT NULL,
  nombre                 text,
  apellido_paterno       text,
  apellido_materno       text,
  activo                 boolean NOT NULL DEFAULT true,
  bloqueado              boolean NOT NULL DEFAULT false,
  debe_cambiar_password  boolean NOT NULL DEFAULT false,
  password_nunca_expira  boolean NOT NULL DEFAULT false,
  ultimo_login_en        timestamptz,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, nombre_usuario)
);
CREATE INDEX IF NOT EXISTS ix_usuarios_tenant ON te_usuarios(tenant_id);
DROP TRIGGER IF EXISTS tg_aud_usuarios ON te_usuarios;
CREATE TRIGGER tg_aud_usuarios BEFORE INSERT OR UPDATE ON te_usuarios
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. tc_roles
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_roles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  codigo      text NOT NULL,                   -- slug estable, ej. 'administrador'
  nombre      text NOT NULL,
  descripcion text,
  es_sistema  boolean NOT NULL DEFAULT false,   -- true = heredado del legado GAM, no se puede borrar
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, codigo)
);
CREATE INDEX IF NOT EXISTS ix_roles_tenant ON tc_roles(tenant_id);
DROP TRIGGER IF EXISTS tg_aud_roles ON tc_roles;
CREATE TRIGGER tg_aud_roles BEFORE INSERT OR UPDATE ON tc_roles
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 3. tr_usuario_rol
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tr_usuario_rol (
  tenant_id  uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  usuario_id uuid NOT NULL REFERENCES te_usuarios(id) ON DELETE CASCADE,
  rol_id     uuid NOT NULL REFERENCES tc_roles(id) ON DELETE CASCADE,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  PRIMARY KEY (usuario_id, rol_id)
);
CREATE INDEX IF NOT EXISTS ix_usuario_rol_tenant ON tr_usuario_rol(tenant_id);

-- ---------------------------------------------------------------------------
-- 4. tc_permisos (catálogo global de capacidades de la aplicación)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_permisos (
  codigo      text PRIMARY KEY,     -- ej. 'pedidos.crear'
  modulo      text NOT NULL,        -- ej. 'pedidos'
  accion      text NOT NULL,        -- ver | crear | editar | eliminar | aprobar | exportar | administrar
  descripcion text NOT NULL,
  activo      boolean NOT NULL DEFAULT true
);

-- ---------------------------------------------------------------------------
-- 5. tr_rol_permiso
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tr_rol_permiso (
  tenant_id      uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  rol_id         uuid NOT NULL REFERENCES tc_roles(id) ON DELETE CASCADE,
  permiso_codigo text NOT NULL REFERENCES tc_permisos(codigo) ON DELETE CASCADE,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  PRIMARY KEY (rol_id, permiso_codigo)
);
CREATE INDEX IF NOT EXISTS ix_rol_permiso_tenant ON tr_rol_permiso(tenant_id);

-- ---------------------------------------------------------------------------
-- 6. Función: tiene_permiso
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION tiene_permiso(p_auth_user_id uuid, p_codigo_permiso text)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1
    FROM te_usuarios u
    JOIN tr_usuario_rol ur ON ur.usuario_id = u.id
    JOIN tr_rol_permiso rp ON rp.rol_id = ur.rol_id AND rp.permiso_codigo = p_codigo_permiso
    WHERE u.auth_user_id = p_auth_user_id
      AND u.activo AND NOT u.bloqueado
  );
$$ LANGUAGE sql STABLE;

-- ---------------------------------------------------------------------------
-- 7. Nota sobre creado_por/modificado_por/actor_id/autorizado_por
-- ---------------------------------------------------------------------------
-- Estas columnas (presentes en casi todas las tablas) NO llevan FK duro a
-- propósito, igual que te_empleados.auth_user_id (ver migración 002): son una
-- referencia lógica a auth.users.id de Supabase, que es la ÚNICA identidad
-- universal del sistema.
--
-- Importante: auth.users.id puede corresponder a DOS poblaciones distintas
-- según la tabla/contexto:
--   (a) personal interno -> fila correspondiente en te_usuarios.auth_user_id
--   (b) freelancer/candidato en el portal propio -> fila correspondiente en
--       te_empleados.auth_user_id (ver tg_res_valida_cupo_y_plaza, que ya
--       distingue auto-inscripción de personal vs. alta por staff interno)
-- Un FK duro hacia una sola tabla rompería la otra población (ej. un
-- freelancer autoinscribiéndose en te_reservaciones no tiene fila en
-- te_usuarios). Si se requiere validar en el futuro, usar un trigger que
-- verifique pertenencia a cualquiera de las dos tablas, no un FK simple.

-- ---------------------------------------------------------------------------
-- 8. RLS + GRANTS
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_usuarios','tc_roles','tr_usuario_rol','tr_rol_permiso'] LOOP
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

-- tc_permisos es catálogo global (sin tenant_id), igual que tc_planes_suscripcion: sin RLS, lectura abierta.
GRANT ALL ON te_usuarios, tc_roles, tr_usuario_rol, tc_permisos, tr_rol_permiso
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 9. Semillas: roles + catálogo de permisos + asignación por defecto
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

INSERT INTO tc_roles (tenant_id, codigo, nombre, descripcion, es_sistema) VALUES
  ('00000000-0000-0000-0000-000000000001', 'administrador', 'Administrador', 'Control total del sistema (heredado del rol GAM "Administrador")', true),
  ('00000000-0000-0000-0000-000000000001', 'lobo',          'Lobo',          'Staff interno con acceso operativo amplio (heredado del rol GAM "Lobo")', true),
  ('00000000-0000-0000-0000-000000000001', 'operacion',     'Operación',     'Gestión día a día: pedidos, asignación, checador (heredado del rol GAM "Operacion")', true)
ON CONFLICT DO NOTHING;

-- Catálogo de permisos por módulo+acción (ver, crear, editar, eliminar, aprobar, exportar, administrar)
INSERT INTO tc_permisos (codigo, modulo, accion, descripcion) VALUES
  ('candidatos.ver',       'candidatos',   'ver',        'Ver candidatos'),
  ('candidatos.crear',     'candidatos',   'crear',      'Alta de candidatos'),
  ('candidatos.editar',    'candidatos',   'editar',     'Editar candidatos'),
  ('candidatos.eliminar',  'candidatos',   'eliminar',   'Eliminar candidatos'),
  ('vacantes.ver',         'vacantes',     'ver',        'Ver vacantes y postulaciones'),
  ('vacantes.crear',       'vacantes',     'crear',      'Publicar vacantes'),
  ('vacantes.editar',      'vacantes',     'editar',     'Editar vacantes'),
  ('vacantes.eliminar',    'vacantes',     'eliminar',   'Eliminar/cerrar vacantes'),
  ('requisiciones.ver',    'requisiciones','ver',        'Ver requisiciones de personal'),
  ('requisiciones.crear',  'requisiciones','crear',      'Crear requisiciones de personal'),
  ('requisiciones.editar', 'requisiciones','editar',     'Editar requisiciones de personal'),
  ('pedidos.ver',          'pedidos',      'ver',        'Ver pedidos'),
  ('pedidos.crear',        'pedidos',      'crear',      'Crear pedidos'),
  ('pedidos.editar',       'pedidos',      'editar',     'Editar pedidos'),
  ('pedidos.eliminar',     'pedidos',      'eliminar',   'Cancelar pedidos'),
  ('pedidos.aprobar',      'pedidos',      'aprobar',    'Liberar/aprobar pedidos'),
  ('reservaciones.ver',    'reservaciones','ver',        'Ver reservaciones/asignación de personal'),
  ('reservaciones.crear',  'reservaciones','crear',      'Preasignar/confirmar personal'),
  ('reservaciones.eliminar','reservaciones','eliminar',  'Cancelar reservaciones'),
  ('empleados.ver',        'empleados',    'ver',        'Ver empleados'),
  ('empleados.crear',      'empleados',    'crear',      'Alta de empleados'),
  ('empleados.editar',     'empleados',    'editar',     'Editar empleados'),
  ('empleados.eliminar',   'empleados',    'eliminar',   'Baja de empleados'),
  ('checador.ver',         'checador',     'ver',        'Ver registros de asistencia'),
  ('checador.crear',       'checador',     'crear',      'Captura manual de asistencia'),
  ('nomina.ver',           'nomina',       'ver',        'Ver nómina/honorarios'),
  ('nomina.crear',         'nomina',       'crear',      'Capturar extras/precauciones de nómina'),
  ('nomina.aprobar',       'nomina',       'aprobar',    'Calcular y cerrar periodo de nómina'),
  ('facturacion.ver',      'facturacion',  'ver',        'Ver facturas'),
  ('facturacion.crear',    'facturacion',  'crear',      'Generar facturas'),
  ('facturacion.aprobar',  'facturacion',  'aprobar',    'Aprobar/timbrar facturas'),
  ('catalogos.ver',        'catalogos',    'ver',        'Ver catálogos del sistema'),
  ('catalogos.editar',     'catalogos',    'editar',     'Administrar catálogos del sistema'),
  ('reportes.ver',         'reportes',     'ver',        'Ver reportes y tableros'),
  ('reportes.exportar',    'reportes',     'exportar',   'Exportar reportes'),
  ('usuarios.administrar', 'usuarios',     'administrar','Administrar usuarios, roles y permisos')
ON CONFLICT DO NOTHING;

-- Asignación por defecto: Administrador = todos los permisos
INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT '00000000-0000-0000-0000-000000000001', r.id, p.codigo
FROM tc_roles r, tc_permisos p
WHERE r.tenant_id = '00000000-0000-0000-0000-000000000001' AND r.codigo = 'administrador'
ON CONFLICT DO NOTHING;

-- Lobo: todo excepto administración de usuarios
INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT '00000000-0000-0000-0000-000000000001', r.id, p.codigo
FROM tc_roles r, tc_permisos p
WHERE r.tenant_id = '00000000-0000-0000-0000-000000000001' AND r.codigo = 'lobo'
  AND p.codigo <> 'usuarios.administrar'
ON CONFLICT DO NOTHING;

-- Operación: módulos operativos del día a día, sin aprobar nómina/facturación ni administrar usuarios/catálogos
INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT '00000000-0000-0000-0000-000000000001', r.id, p.codigo
FROM tc_roles r, tc_permisos p
WHERE r.tenant_id = '00000000-0000-0000-0000-000000000001' AND r.codigo = 'operacion'
  AND p.modulo IN ('candidatos','vacantes','requisiciones','pedidos','reservaciones','empleados','checador','reportes')
  AND p.accion <> 'aprobar'
ON CONFLICT DO NOTHING;
-- Operación también puede consultar catálogos (solo lectura)
INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT '00000000-0000-0000-0000-000000000001', r.id, 'catalogos.ver'
FROM tc_roles r WHERE r.tenant_id = '00000000-0000-0000-0000-000000000001' AND r.codigo = 'operacion'
ON CONFLICT DO NOTHING;

-- Nota: no se crea fila de ejemplo en te_usuarios/tr_usuario_rol porque requiere
-- un auth_user_id real de Supabase Auth -- se crea desde la app cuando alguien
-- se registra/es invitado, y el backend hace el INSERT en te_usuarios.

-- ============================================================================
-- Migración 006 — Campos reales confirmados contra Ocesa03_j_m.accdb (backend real)
-- ============================================================================
-- Fuente: Dev/freelance/Ocesa03_j_m.accdb, backend SQL Server real (datos
-- anonimizados, estructura real) revisado por ODBC. Ver
-- documentacion-referencia/HALLAZGOS_ACCDB_DATOS_REALES.md para el detalle.
--
-- Antes de escribir esto se recalculó el esquema EFECTIVO de te_pedidos,
-- te_pedidos_detalle y te_nomina_detalle (CREATE TABLE + todos los ALTER TABLE
-- posteriores en este mismo archivo) para no duplicar nada: la Migración de
-- "Expandir te_pedidos/te_pedidos_detalle con los campos del Lobo" (sección
-- más arriba) YA cubre casi todo lo que aparece en dbo_Pedidos / dbo_Pedidos
-- Detalle del Access real. ANALISIS_BRECHAS_MANUALES_VS_MODELO.md quedó
-- desactualizado en ese punto -- auditó solo el CREATE TABLE inicial, no los
-- ALTER TABLE que ya lo resolvieron. Esta migración cierra lo que sí seguía
-- faltando, confirmado campo por campo contra los datos reales:
--
--   1. te_pedidos: sociedad_pagadora_id (puede diferir de id_sociedad_propia,
--      regla de negocio ya documentada), evento_id (catálogo Eventos/Shows que
--      agrupa varios pedidos -- IdEvento/Titulo Evento en el Access real),
--      lugar_cita_id (catálogo Lugar de Cita, distinto de tc_sitios),
--      y FK real para contacto_id (existía la columna pero sin FK).
--   2. te_pedidos_detalle: presentacion_id (tc_presentaciones_producto ya
--      existía como catálogo pero nunca se conectó desde el detalle).
--   3. te_nomina_detalle: desglose fiscal completo del recibo de honorarios
--      (dbo_Pagos Honorarios real: IM/CF/SA/CG/ID/IT/IVA/RIVA/RISR) -- esto
--      era el hallazgo "crítico" del análisis de brechas, ahora resuelto con
--      los nombres y significados reales en vez de adivinados.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Catálogos nuevos: Eventos/Shows, Lugar de Cita, Contactos de cliente
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_eventos (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  cliente_id  uuid REFERENCES tc_clientes(id),
  titulo      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_eventos_tenant ON tc_eventos(tenant_id);
DROP TRIGGER IF EXISTS tg_aud_eventos ON tc_eventos;
CREATE TRIGGER tg_aud_eventos BEFORE INSERT OR UPDATE ON tc_eventos
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_lugares_cita (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo                text NOT NULL,
  direccion             text,
  direccion_abreviada   text,
  telefonos             text,
  activo                boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_lugcita_tenant ON tc_lugares_cita(tenant_id);
DROP TRIGGER IF EXISTS tg_aud_lugcita ON tc_lugares_cita;
CREATE TRIGGER tg_aud_lugcita BEFORE INSERT OR UPDATE ON tc_lugares_cita
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS tc_contactos_cliente (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  cliente_id  uuid REFERENCES tc_clientes(id) ON DELETE CASCADE,
  nombre      text NOT NULL,
  telefono    text,
  correo      text,
  puesto      text,
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_contcli_tenant ON tc_contactos_cliente(tenant_id, cliente_id);
DROP TRIGGER IF EXISTS tg_aud_contcli ON tc_contactos_cliente;
CREATE TRIGGER tg_aud_contcli BEFORE INSERT OR UPDATE ON tc_contactos_cliente
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. te_pedidos: sociedad pagadora, evento, lugar de cita, FK real de contacto
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos
  ADD COLUMN IF NOT EXISTS sociedad_pagadora_id     uuid REFERENCES tc_sociedades_pagadoras(id),
  ADD COLUMN IF NOT EXISTS evento_id                uuid REFERENCES tc_eventos(id),
  ADD COLUMN IF NOT EXISTS lugar_cita_id             uuid REFERENCES tc_lugares_cita(id),
  ADD COLUMN IF NOT EXISTS direccion_lugar_cita_snap text;

-- contacto_id ya existía (migración anterior) pero sin FK -- se agrega ahora
-- que existe la tabla destino. Guardado con IF NOT EXISTS vía catálogo de
-- constraints porque Postgres no soporta "ADD CONSTRAINT IF NOT EXISTS".
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_pedidos_contacto_cliente'
  ) THEN
    ALTER TABLE te_pedidos
      ADD CONSTRAINT fk_pedidos_contacto_cliente FOREIGN KEY (contacto_id) REFERENCES tc_contactos_cliente(id);
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3. te_pedidos_detalle: conectar con el catálogo de presentaciones de producto
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos_detalle
  ADD COLUMN IF NOT EXISTS presentacion_id uuid REFERENCES tc_presentaciones_producto(id);

-- ---------------------------------------------------------------------------
-- 4. te_nomina_detalle: desglose fiscal del recibo de honorarios (dbo_Pagos Honorarios real)
-- ---------------------------------------------------------------------------
ALTER TABLE te_nomina_detalle
  ADD COLUMN IF NOT EXISTS impuesto_marginal      numeric(12,2) NOT NULL DEFAULT 0,  -- IM
  ADD COLUMN IF NOT EXISTS cuota_fija             numeric(12,2) NOT NULL DEFAULT 0,  -- CF
  ADD COLUMN IF NOT EXISTS subsidio_acreditable   numeric(12,2) NOT NULL DEFAULT 0,  -- SA
  ADD COLUMN IF NOT EXISTS credito_general        numeric(12,2) NOT NULL DEFAULT 0,  -- CG
  ADD COLUMN IF NOT EXISTS impuesto_diario        numeric(12,2) NOT NULL DEFAULT 0,  -- ID
  ADD COLUMN IF NOT EXISTS impuesto_total         numeric(12,2) NOT NULL DEFAULT 0,  -- IT
  ADD COLUMN IF NOT EXISTS iva                    numeric(12,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS retencion_iva          numeric(12,2) NOT NULL DEFAULT 0,  -- RIVA
  ADD COLUMN IF NOT EXISTS retencion_isr          numeric(12,2) NOT NULL DEFAULT 0,  -- RISR
  ADD COLUMN IF NOT EXISTS dias_laborados         int,
  ADD COLUMN IF NOT EXISTS cumple_regla_cuenta_banco               boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cumple_regla_ultimo_pago_reciente       boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cumple_regla_recibe_pago_periodo_actual boolean NOT NULL DEFAULT false;

-- ---------------------------------------------------------------------------
-- 5. RLS + GRANTS para los catálogos nuevos
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['tc_eventos','tc_lugares_cita','tc_contactos_cliente'] LOOP
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

GRANT ALL ON tc_eventos, tc_lugares_cita, tc_contactos_cliente TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. Semillas: lugares de cita reales vistos en el Access (nombres/direcciones públicas, no son PII)
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

INSERT INTO tc_lugares_cita (tenant_id, titulo, direccion, direccion_abreviada, telefonos) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Palacio de los Deportes', 'Río Churubusco Esquina con Añil, Colonia Granjas México', 'Río Churubusco Esquina con Añil Puerta 1', '237 99 99'),
  ('00000000-0000-0000-0000-000000000001', 'Foro Sol', 'Viaducto río piedad, metro ciudad deportiva Acceso D de Foro Sol, Colonia Granjas México, Delegación Iztacalco', 'Viaducto río piedad, metro ciudad deportiva Acceso D', '764 84 46'),
  ('00000000-0000-0000-0000-000000000001', 'Auditorio Nacional', 'Paseo de la reforma 50, Colonia Bosque de Chapultepéc, Delegación Miguel Hidalgo, Código Postal 11560', 'Paseo de la reforma 50, Colonia Bosque de Chapultepéc', '280 74 76')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Migración 007 — Seguimiento de candidato + tasas fiscales de honorarios asimilables
-- ============================================================================
-- Cierra los dos gaps reales confirmados en la revisión manual de
-- CRUCE_TABLAS_XPZ_VS_SCHEMA.md (sección 0) contra TC_SegMovCan/TE_SegCan y
-- TP_ImpHonoAsim del XPZ real.
--
--   1. tc_tipos_movimiento_candidato + te_seguimiento_candidato -- bitácora de
--      candidato (no existía ningún equivalente a te_movimientos_empleado
--      pero para candidatos). Confirma lo que ya decía
--      ANALISIS_BRECHAS_MANUALES_VS_MODELO.md.
--   2. tp_tasas_honorarios_asimilables -- tabla de tasas/rangos fiscales
--      (límite inferior/superior, cuota fija, % marginal, vigencia) que
--      alimenta el cálculo de impuesto_marginal/cuota_fija/etc. agregados a
--      te_nomina_detalle en la Migración 006. Sin esta tabla, esos campos se
--      calcularían con constantes en código -- viola "cero parámetros de
--      negocio hardcodeados".
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Seguimiento de candidato
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_tipos_movimiento_candidato (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave       text NOT NULL,
  titulo      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_tipomovcand ON tc_tipos_movimiento_candidato;
CREATE TRIGGER tg_aud_tipomovcand BEFORE INSERT OR UPDATE ON tc_tipos_movimiento_candidato
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS te_seguimiento_candidato (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  candidato_id         uuid NOT NULL REFERENCES te_candidatos(id) ON DELETE CASCADE,
  tipo_movimiento_id   uuid REFERENCES tc_tipos_movimiento_candidato(id),
  fecha                timestamptz NOT NULL DEFAULT now(),
  observaciones        text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_segcand_candidato ON te_seguimiento_candidato(tenant_id, candidato_id, fecha);
DROP TRIGGER IF EXISTS tg_aud_segcand ON te_seguimiento_candidato;
CREATE TRIGGER tg_aud_segcand BEFORE INSERT OR UPDATE ON te_seguimiento_candidato
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. Tasas fiscales de honorarios asimilables (alimenta te_nomina_detalle)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tp_tasas_honorarios_asimilables (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  tipo               text NOT NULL DEFAULT 'ISR',
  limite_inferior    numeric(14,2) NOT NULL,
  limite_superior    numeric(14,2),
  cuota_fija         numeric(12,2) NOT NULL DEFAULT 0,
  tasa_porcentaje    numeric(7,4) NOT NULL DEFAULT 0,
  vigente_desde      date NOT NULL,
  vigente_hasta      date,
  activo             boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (limite_superior IS NULL OR limite_superior > limite_inferior)
);
CREATE INDEX IF NOT EXISTS ix_tasashono_vigencia ON tp_tasas_honorarios_asimilables(tenant_id, vigente_desde, vigente_hasta);
DROP TRIGGER IF EXISTS tg_aud_tasashono ON tp_tasas_honorarios_asimilables;
CREATE TRIGGER tg_aud_tasashono BEFORE INSERT OR UPDATE ON tp_tasas_honorarios_asimilables
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 3. RLS + GRANTS
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['tc_tipos_movimiento_candidato','te_seguimiento_candidato','tp_tasas_honorarios_asimilables'] LOOP
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

GRANT ALL ON tc_tipos_movimiento_candidato, te_seguimiento_candidato, tp_tasas_honorarios_asimilables
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. Semillas
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

INSERT INTO tc_tipos_movimiento_candidato (tenant_id, clave, titulo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'registrado',        'Registrado'),
  ('00000000-0000-0000-0000-000000000001', 'citado_entrevista', 'Citado a entrevista'),
  ('00000000-0000-0000-0000-000000000001', 'curso_induccion',   'Citado a curso de inducción'),
  ('00000000-0000-0000-0000-000000000001', 'evento_prueba',     'Citado a evento de prueba'),
  ('00000000-0000-0000-0000-000000000001', 'aceptado',          'Aceptado'),
  ('00000000-0000-0000-0000-000000000001', 'rechazado',         'Rechazado'),
  ('00000000-0000-0000-0000-000000000001', 'promovido_empleado','Promovido a empleado')
ON CONFLICT DO NOTHING;

-- Tasas ISR honorarios asimilables (tabla mensual vigente, valores de referencia -- ajustar con el usuario)
INSERT INTO tp_tasas_honorarios_asimilables (tenant_id, tipo, limite_inferior, limite_superior, cuota_fija, tasa_porcentaje, vigente_desde) VALUES
  ('00000000-0000-0000-0000-000000000001', 'ISR', 0.01,      746.04,    0.00,   1.92,  '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 746.05,    6332.05,   14.32,  6.40,  '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 6332.06,   11128.01,  371.83, 10.88, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 11128.02,  12935.82,  893.63, 16.00, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 12935.83,  15487.71,  1182.88,17.92, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 15487.72,  31236.49,  1640.18,21.36, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 31236.50,  49233.00,  5004.12,23.52, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 49233.01,  93993.90,  9236.89,30.00, '2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 93993.91,  125325.20, 22665.17,32.00,'2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 125325.21, 375975.61, 32691.18,34.00,'2026-01-01'),
  ('00000000-0000-0000-0000-000000000001', 'ISR', 375975.62, NULL,      117912.32,35.00,'2026-01-01')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Migración 008 — Reconciliación te_pedidos/te_pedidos_detalle contra SQL Server real
-- ============================================================================
-- Fuente: conexión directa al SQL Server real (sql5063.site4now.net,
-- db_a81e28_appscpfv2) -- se comparó columna por columna TE_Pedido (40 cols)
-- y TE_Peddet (67 cols), las tablas TRANSACCIONALES reales (con FKs
-- declarados en el motor), contra nuestro te_pedidos/te_pedidos_detalle.
--
-- Nota importante descubierta en este cruce: `Pedidos`/`Pedidos2`/`Pedidos22`
-- (que coinciden con dbo_Pedidos del Access y con lo que veníamos usando como
-- referencia) NO son la tabla transaccional real -- son una tabla plana sin
-- ningún FK declarado, casi seguro una tabla de reporte/exportación. La
-- fuente de verdad real es TE_Pedido + TE_Peddet (coincide con las URLs
-- reales vistas en capturas: te_pedidoww.aspx, wp_pedidodetalle.aspx).
--
-- Columnas agregadas abajo, solo las confirmadas como gap real (hay más
-- columnas en el SQL Server real que son snapshots denormalizados --
-- Titulo_Sucursal, Titulo_Sociedad, etc. -- esas se resuelven con JOIN, no
-- se replican). Varias de estas columnas YA habían sido detectadas de forma
-- independiente por el análisis visual de capturas (ver RADIOGRAFIA_FUNCIONAL_
-- PANTALLAS.md) -- confirmación cruzada entre dos fuentes distintas.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Catálogo nuevo: Sucursales (organizacional -- CDMX/Guadalajara/Monterrey/
--    Querétaro/Otra -- distinto de tc_sitios, que es el inmueble físico)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_sucursales (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, titulo)
);
DROP TRIGGER IF EXISTS tg_aud_sucursales ON tc_sucursales;
CREATE TRIGGER tg_aud_sucursales BEFORE INSERT OR UPDATE ON tc_sucursales
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Catálogo de referencia de estatus real de pedido (TC_EstatusAut en SQL
-- Server) -- se agrega como catálogo documental + columna nueva en paralelo;
-- NO se reemplaza `te_pedidos.status` (texto libre) porque ya hay lógica de
-- aplicación (React, funciones) que depende de sus valores actuales
-- ('borrador','liberado','procesado','cancelado'). Decisión pendiente del
-- equipo: migrar status -> estatus_id en una fase posterior.
CREATE TABLE IF NOT EXISTS tc_estatus_pedido (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  clave       text NOT NULL,
  titulo      text NOT NULL,
  activo      boolean NOT NULL DEFAULT true,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  UNIQUE (tenant_id, clave)
);
DROP TRIGGER IF EXISTS tg_aud_estpedido ON tc_estatus_pedido;
CREATE TRIGGER tg_aud_estpedido BEFORE INSERT OR UPDATE ON tc_estatus_pedido
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. te_pedidos: columnas confirmadas por TC_SucursalID/TC_SucursalPagId/
--    TE_PedidoLugOtro(Dire)/TC_EstatusAutID del SQL Server real
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos
  ADD COLUMN IF NOT EXISTS sucursal_id            uuid REFERENCES tc_sucursales(id),
  ADD COLUMN IF NOT EXISTS sucursal_pagadora_id    uuid REFERENCES tc_sucursales(id),
  ADD COLUMN IF NOT EXISTS estatus_id              uuid REFERENCES tc_estatus_pedido(id),
  ADD COLUMN IF NOT EXISTS lugar_otro              boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS lugar_otro_direccion    text;

-- ---------------------------------------------------------------------------
-- 3. te_pedidos_detalle: columnas confirmadas por TE_pedDetTitu/ST_LugarId/
--    TE_pedDetOtro(Des)/TC_FaseEventoID/TE_PeddetFechafinal.../
--    TE_PeddetFechafincitaoculta/TE_PeddetCompleto(ConPreasigna)/
--    TE_pedDetBloque del SQL Server real
-- ---------------------------------------------------------------------------
ALTER TABLE te_pedidos_detalle
  ADD COLUMN IF NOT EXISTS titulo                  text,
  ADD COLUMN IF NOT EXISTS lugar_cita_id            uuid REFERENCES tc_lugares_cita(id),
  ADD COLUMN IF NOT EXISTS lugar_otro               boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS lugar_otro_descripcion   text,
  ADD COLUMN IF NOT EXISTS fase_evento_id           uuid REFERENCES tc_fases_evento(id),
  ADD COLUMN IF NOT EXISTS fecha_final_cita         timestamptz,
  ADD COLUMN IF NOT EXISTS fecha_fin_cita_oculta    timestamptz,
  ADD COLUMN IF NOT EXISTS completo                 boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS completo_con_preasignados boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS bloque                   boolean NOT NULL DEFAULT false;

-- Mantener completo/completo_con_preasignados sincronizados con los
-- porcentajes ya calculados por recalcular_cobertura_detalle()
CREATE OR REPLACE FUNCTION tg_sync_detalle_completo() RETURNS trigger AS $$
BEGIN
  NEW.completo := NEW.porcentaje_completo >= 100;
  NEW.completo_con_preasignados := NEW.porcentaje_completo_con_pre >= 100;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_detalle_completo_sync ON te_pedidos_detalle;
CREATE TRIGGER tg_detalle_completo_sync BEFORE INSERT OR UPDATE ON te_pedidos_detalle
  FOR EACH ROW EXECUTE FUNCTION tg_sync_detalle_completo();

-- ---------------------------------------------------------------------------
-- 4. RLS + GRANTS para los catálogos nuevos
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['tc_sucursales','tc_estatus_pedido'] LOOP
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

GRANT ALL ON tc_sucursales, tc_estatus_pedido TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. Semillas: sucursales y estatus de pedido reales (confirmados por capturas Y por el SQL Server real)
-- ---------------------------------------------------------------------------
SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

INSERT INTO tc_sucursales (tenant_id, titulo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'CDMX'),
  ('00000000-0000-0000-0000-000000000001', 'Guadalajara'),
  ('00000000-0000-0000-0000-000000000001', 'Monterrey'),
  ('00000000-0000-0000-0000-000000000001', 'Querétaro'),
  ('00000000-0000-0000-0000-000000000001', 'Otra')
ON CONFLICT DO NOTHING;

INSERT INTO tc_estatus_pedido (tenant_id, clave, titulo) VALUES
  ('00000000-0000-0000-0000-000000000001', 'vigente',   'Vigente'),
  ('00000000-0000-0000-0000-000000000001', 'liberado',  'Liberado'),
  ('00000000-0000-0000-0000-000000000001', 'cancelado', 'Cancelado'),
  ('00000000-0000-0000-0000-000000000001', 'procesado', 'Procesado'),
  ('00000000-0000-0000-0000-000000000001', 'normal',    'Normal')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Migración 009 — Función para la Matriz de Puestos (pivote fecha × bloque/producto)
-- ============================================================================
-- Contexto: TE_Puente (SQL Server real) resultó ser una tabla pivote
-- hardcodeada de GeneXus -- 50 pares columna/valor (TE_PuenteC1..C50 +
-- TE_PuenteNp1..Np50) por Bloque+Producto+Pedido, usada para renderizar la
-- "Matriz de Puestos" que confirmaron varios agentes de capturas (fechas
-- como columnas, Bloque+Producto como filas, celda = "Cantidad - T Turnos").
-- Toda esa información ya existe en te_pedidos_detalle (una fila por fecha);
-- no hace falta replicar TE_Puente -- lo que falta es la función que arma
-- el pivote en formato "largo" para que el frontend lo pivotee a columnas
-- dinámicas (no se intenta pivotear dentro de SQL porque el número de
-- fechas/columnas varía por pedido -- eso se resuelve mejor en JS).
-- ============================================================================

CREATE OR REPLACE FUNCTION matriz_puestos_pedido(p_pedido_id uuid)
RETURNS TABLE (
  pedido_detalle_id          uuid,
  bloque_num                 int,
  producto_id                uuid,
  producto_titulo            text,
  puesto_id                  uuid,
  puesto_titulo               text,
  fecha_cita                 date,
  hora_cita_inicio            time,
  hora_cita_fin               time,
  cantidad                    int,
  turnos                      numeric,
  cantidad_reservados_real    int,
  cantidad_reservados_con_pre int,
  porcentaje_completo         numeric,
  status_detalle               estado_detalle_pedido_enum,
  costo_unit                   numeric,
  precio                       numeric
) AS $$
  SELECT
    d.id, d.bloque_num, d.producto_id, p.titulo, d.puesto_id, pu.titulo,
    d.fecha_cita, d.hora_cita_inicio, d.hora_cita_fin,
    d.cantidad, d.turnos, d.cantidad_reservados_real, d.cantidad_reservados_con_pre,
    d.porcentaje_completo, d.status_detalle, d.costo_unit, d.precio
  FROM te_pedidos_detalle d
  LEFT JOIN tc_productos p ON p.id = d.producto_id
  LEFT JOIN tc_puestos pu ON pu.id = d.puesto_id
  WHERE d.pedido_id = p_pedido_id
  ORDER BY d.bloque_num NULLS LAST, p.titulo NULLS LAST, d.fecha_cita, d.hora_cita_inicio;
$$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION matriz_puestos_pedido IS
  'Formato largo (una fila por fecha/detalle) para que el frontend arme la Matriz de Puestos como tabla pivote (fechas como columnas, Bloque+Producto como filas) -- equivalente funcional a TE_Puente del sistema legado, sin su límite fijo de 50 columnas.';

-- ============================================================================
-- Migración 010 — tc_eventos (proyecto) + te_requisicion_personal_detalle
-- ============================================================================
-- Fuente: XPZ real de GeneXus (export del KB, más completo que el SQL Server
-- en vivo -- esa instancia nunca se desplegó con el esquema final).
--
-- TE_Evento (XPZ): TE_EventoID, TE_EventoDes, TE_EventoFecIni, TE_EventoHora,
-- TE_EventoMinutos, TE_EventoIMG, TE_EventoFeinicial, TE_EventoFeTer,
-- TE_EventoFechaVigencia, TC_InmuebleID/Des. Confirma que el Evento real SÍ
-- tiene rango de fechas (inicio/fin) -- coincide con la explicación del
-- usuario de que un "Evento" (ej. Fórmula 1) es en realidad un PROYECTO que
-- puede durar 2-3 meses, del cual cuelgan varios Pedidos por etapa/fase.
--
-- TC_Inmueble (XPZ): catálogo usado por TE_Evento, TC_EstacionNACS (estación
-- biométrica) y TE_RegistroBiometrico -- es el mismo concepto que ya
-- modelamos como tc_sitios (el inmueble físico donde ocurre el trabajo y
-- donde viven las estaciones de checado). NO se crea una tabla nueva --
-- tc_eventos.sitio_id referencia tc_sitios directamente.
--
-- Nota verificada y descartada: la frase "el sector, la Entidad Federativa,
-- el promotor" del manual "Funcionalidad desarrollada 2.01.docx" es texto de
-- intención/planeación -- no existe como columna real en TE_Pedido, TE_Evento
-- ni dbo_Pedidos. No se agrega al esquema.
--
-- TE_ReqPer (XPZ, Requisición de personal -- NO existe en el SQL Server en
-- vivo ni en el Access, solo en el XPZ -- confirma que este módulo se diseñó
-- pero la instancia que tenemos nunca llegó a tener esta tabla desplegada):
-- cada fila real de TE_ReqPer YA es una línea por puesto (TC_PuestosId +
-- TE_ReqPerCantElem), con un perfil detallado por línea (edad, sexo,
-- escolaridad, idiomas, viajar, licencia, experiencia, conocimientos
-- técnicos, objetivo y actividades del puesto). Aquí se modela como tabla de
-- detalle separada (te_requisicion_personal_detalle), consistente con el
-- patrón ya usado en te_pedidos/te_pedidos_detalle, en vez de replicar el
-- renglón plano de GeneXus -- decisión de normalización, no de omisión: TODOS
-- los campos reales de TE_ReqPer quedan representados.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. tc_eventos: rango de fechas real + inmueble (confirmado por TE_Evento)
-- ---------------------------------------------------------------------------
ALTER TABLE tc_eventos
  ADD COLUMN IF NOT EXISTS descripcion     text,
  ADD COLUMN IF NOT EXISTS fecha_inicio    date,
  ADD COLUMN IF NOT EXISTS fecha_fin       date,
  ADD COLUMN IF NOT EXISTS hora_inicio     time,
  ADD COLUMN IF NOT EXISTS sitio_id        uuid REFERENCES tc_sitios(id),
  ADD COLUMN IF NOT EXISTS imagen_url      text;

-- ---------------------------------------------------------------------------
-- 2. te_requisicion_personal_detalle: una línea por Puesto solicitado, con
--    el perfil completo real de TE_ReqPer
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_requisicion_personal_detalle (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id                 uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  requisicion_id            uuid NOT NULL REFERENCES te_requisicion_personal(id) ON DELETE CASCADE,
  puesto_id                 uuid REFERENCES tc_puestos(id),
  cantidad                  int NOT NULL DEFAULT 1,
  -- Perfil solicitado (TE_ReqPerDesPuesto* en el real)
  requiere_descripcion_perfil boolean NOT NULL DEFAULT false,
  edad_requerida             text,
  sexo_requerido              sexo_enum,
  escolaridad_requerida       text,
  idiomas_requeridos          text,
  requiere_viajar             boolean,
  requiere_licencia_conducir  boolean,
  requiere_experiencia        boolean,
  conocimientos_tecnicos      text,
  objetivo_puesto             text,
  actividades_puesto          text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
DROP TRIGGER IF EXISTS tg_aud_reqperdet ON te_requisicion_personal_detalle;
CREATE TRIGGER tg_aud_reqperdet BEFORE INSERT OR UPDATE ON te_requisicion_personal_detalle
  FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Área/depto/jefe inmediato solicitante -- confirmados en TE_ReqPer
-- (TE_ReqPerArea, TE_ReqPerDepto, TE_ReqPerNomjefeInm) y no estaban en
-- te_requisicion_personal
ALTER TABLE te_requisicion_personal
  ADD COLUMN IF NOT EXISTS area              text,
  ADD COLUMN IF NOT EXISTS departamento      text,
  ADD COLUMN IF NOT EXISTS jefe_inmediato    text,
  ADD COLUMN IF NOT EXISTS unidad_negocio_id uuid REFERENCES tc_unidades_negocio(id),
  ADD COLUMN IF NOT EXISTS responsable_id    uuid REFERENCES tc_responsables(id);

-- ---------------------------------------------------------------------------
-- 3. RLS + GRANTS
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_requisicion_personal_detalle'] LOOP
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

GRANT ALL ON te_requisicion_personal_detalle TO anon, authenticated, service_role;

-- ============================================================================

-- ============================================================================
-- Migración 011 — Corrección tc_fases_evento (confirmado intencional por el usuario)
-- ============================================================================
-- El dropdown real "Fase del Evento" en el sistema 2017 (antecesor, apoyo.rh.ocesa.mx)
-- tenía 8 valores (incluyendo desglose Fase 1-4 por día de show). El sistema 2018
-- (GeneXus, el que se construyó) lo simplificó A PROPÓSITO a 5 valores -- confirmado
-- explícitamente por el usuario (autor original de ambos sistemas), no es un gap a
-- corregir sino el diseño correcto a replicar tal cual en PeopleMovil.
--
-- tc_fases_evento tenía solo 3 filas (Montaje/Evento en vivo/Desmontaje) usando el
-- enum legado fase_evento_enum (montaje,evento,desmontaje,otro). Se completa a los 5
-- valores reales confirmados: No aplica, Preparación, Montaje, Show, Desmontaje.
-- ============================================================================

ALTER TYPE fase_evento_enum ADD VALUE IF NOT EXISTS 'no_aplica';
ALTER TYPE fase_evento_enum ADD VALUE IF NOT EXISTS 'preparacion';
ALTER TYPE fase_evento_enum ADD VALUE IF NOT EXISTS 'show';

SET LOCAL app.current_tenant = '00000000-0000-0000-0000-000000000001';

-- Reordenar/renombrar las 3 filas existentes y agregar las 2 que faltaban
UPDATE tc_fases_evento SET clave = 'montaje', titulo = 'Montaje', orden = 2
  WHERE clave = 'montaje';
UPDATE tc_fases_evento SET clave = 'show', titulo = 'Show', orden = 3
  WHERE clave = 'evento';
UPDATE tc_fases_evento SET clave = 'desmontaje', titulo = 'Desmontaje', orden = 4
  WHERE clave = 'desmontaje';

INSERT INTO tc_fases_evento (tenant_id, clave, titulo, orden) VALUES
  ('00000000-0000-0000-0000-000000000001', 'no_aplica', 'No aplica', 0),
  ('00000000-0000-0000-0000-000000000001', 'preparacion', 'Preparación', 1)
ON CONFLICT DO NOTHING;

-- ============================================================================

-- ============================================================================
-- Migración 012 — Portal freelance (bolsa de freelance + reservación)
-- ============================================================================
-- Contexto: SitiosAsignacion.jsx (admin) ya cubre Pedido+Detalle+Matriz. El lado
-- freelance (pages/freelance/Publicaciones.jsx, MisEventos.jsx) YA EXISTÍA en el
-- código de una fase anterior, igual que inscribirme_a_publicacion() y las vistas
-- v_publicaciones_para_freelance / v_agenda_freelance -- pero con brechas reales:
--
-- 1. BUG DE PRIVACIDAD CONFIRMADO: ninguna de las 2 vistas filtraba por el
--    empleado que hace la consulta -- solo por tenant_id (RLS de
--    te_reservaciones/tr_empleado_plaza también es solo por tenant). Cualquier
--    freelance autenticado podía ver la agenda y las oportunidades calculadas
--    para CUALQUIER OTRO empleado del tenant, no solo las propias.
-- 2. Elegibilidad real confirmada en capturas (RADIOGRAFIA_FUNCIONAL_PANTALLAS.md
--    sección 2, "Elegibilidad para ver el pedido en el portal freelance"):
--    Puesto + Certeza + Vigencia de plaza + no Lista Negra (por sitio) + Sucursal
--    empleado = Sucursal pedido. La vista ya filtraba puesto+vigencia(activo), le
--    faltaban certeza, lista negra y sucursal.
-- 3. `tr_empleado_plaza` solo tenía `porcentaje_puntualidad` (métrica de
--    asistencia histórica) -- le faltaba `certeza` (score de confiabilidad de
--    confirmación, 0.00-1.00, distinto concepto, confirmado en capturas y ya
--    usado en `tc_puestos.porcentaje_certeza_inicial/porcentaje_minimo`).
-- 4. `te_lista_negra_empleados` ya estaba señalada como gap en el análisis de
--    brechas (prioridad Alta, nunca resuelta): hoy es global, el real es por
--    sitio (+ "Todos") y con fecha de expiración ("Hasta").
-- 5. `te_empleados` no tenía `sucursal_id` -- necesario para la regla confirmada
--    en Escenario 10 (un freelance de Querétaro no veía pedidos de CDMX).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Columnas nuevas
-- ---------------------------------------------------------------------------
ALTER TABLE te_empleados
  ADD COLUMN IF NOT EXISTS sucursal_id uuid REFERENCES tc_sucursales(id);

ALTER TABLE tr_empleado_plaza
  ADD COLUMN IF NOT EXISTS certeza numeric(5,3) NOT NULL DEFAULT 1.000;

ALTER TABLE te_lista_negra_empleados
  ADD COLUMN IF NOT EXISTS sitio_id uuid REFERENCES tc_sitios(id),
  ADD COLUMN IF NOT EXISTS fecha_expiracion date;

COMMENT ON COLUMN te_lista_negra_empleados.sitio_id IS
  'NULL = vetado en todos los sitios. Con valor = vetado solo para ese sitio (confirmado en capturas: checkbox "Todos" vs sitio específico).';
COMMENT ON COLUMN tr_empleado_plaza.certeza IS
  'Score de confiabilidad de confirmación (0.000-1.000), distinto de porcentaje_puntualidad (asistencia histórica). Se compara contra tc_puestos.porcentaje_minimo para elegibilidad en el portal freelance.';

-- ---------------------------------------------------------------------------
-- 2. v_publicaciones_para_freelance -- agrega empleado_id=mi_empleado_id(),
--    certeza >= porcentaje_minimo del puesto, exclusión de lista negra por
--    sitio+vigencia, y match de sucursal (solo si ambos lados la tienen
--    capturada, para no ocultar todo mientras el dato no esté sembrado)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_publicaciones_para_freelance AS
SELECT
  pd.id AS pedido_detalle_id,
  p.id AS pedido_id,
  p.folio,
  p.titulo,
  p.sitio_id,
  s.titulo AS sitio,
  cl.razon_social AS cliente,
  pd.puesto_id,
  pu.titulo AS puesto,
  pd.turno_id,
  t.titulo AS turno,
  t.hora_inicio AS turno_hora_inicio,
  t.hora_fin AS turno_hora_fin,
  pf.fecha,
  pf.hora_inicio,
  pf.hora_fin,
  fe.titulo AS fase,
  pd.costo_unit,
  pd.cantidad AS cupo_total,
  (SELECT count(*) FROM te_reservaciones r
     WHERE r.pedido_detalle_id = pd.id AND r.estado <> 'cancelado'::estado_reservacion_enum) AS cupo_ocupado,
  pd.cierra_en,
  pd.publicado_en,
  ep.empleado_id,
  ep.porcentaje_puntualidad,
  ep.certeza
FROM te_pedidos_detalle pd
JOIN te_pedidos p ON p.id = pd.pedido_id
LEFT JOIN te_pedido_fechas pf ON pf.id = pd.pedido_fecha_id
LEFT JOIN tc_sitios s ON s.id = p.sitio_id
LEFT JOIN tc_clientes cl ON cl.id = p.cliente_id
LEFT JOIN tc_puestos pu ON pu.id = pd.puesto_id
LEFT JOIN tc_turnos t ON t.id = pd.turno_id
LEFT JOIN tc_fases_evento fe ON fe.id = pf.fase_evento_id
JOIN tr_empleado_plaza ep ON ep.puesto_id = pd.puesto_id AND ep.activo
JOIN te_empleados emp ON emp.id = ep.empleado_id
WHERE pd.publicado = true
  AND ep.empleado_id = mi_empleado_id()
  AND (pf.fecha IS NULL OR pf.fecha >= CURRENT_DATE)
  AND (pd.cierra_en IS NULL OR pd.cierra_en > now())
  AND (SELECT count(*) FROM te_reservaciones r
         WHERE r.pedido_detalle_id = pd.id AND r.estado <> 'cancelado'::estado_reservacion_enum) < pd.cantidad
  AND NOT EXISTS (SELECT 1 FROM te_reservaciones r
         WHERE r.pedido_detalle_id = pd.id AND r.empleado_id = ep.empleado_id AND r.estado <> 'cancelado'::estado_reservacion_enum)
  AND ep.certeza >= COALESCE(pu.porcentaje_minimo, 0)
  AND (emp.sucursal_id IS NULL OR p.sucursal_id IS NULL OR emp.sucursal_id = p.sucursal_id)
  AND NOT EXISTS (
    SELECT 1 FROM te_lista_negra_empleados ln
    WHERE ln.tenant_id = emp.tenant_id AND ln.activo
      AND (ln.sitio_id IS NULL OR ln.sitio_id = p.sitio_id)
      AND (ln.fecha_expiracion IS NULL OR ln.fecha_expiracion > CURRENT_DATE)
      AND ((ln.rfc IS NOT NULL AND ln.rfc = emp.rfc) OR (ln.curp IS NOT NULL AND ln.curp = emp.curp))
  );

-- ---------------------------------------------------------------------------
-- 3. v_agenda_freelance -- agrega el filtro por empleado que faltaba (bug de
--    privacidad: sin esto cualquier freelance veía la agenda de cualquier otro)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_agenda_freelance AS
SELECT
  r.id, r.empleado_id, r.pedido_id, r.pedido_detalle_id, r.puesto_id,
  r.estado, r.estado_asistencia, r.cita_inicio, r.cita_fin,
  p.folio AS pedido_folio, p.titulo AS pedido_titulo,
  s.titulo AS sitio, pu.titulo AS puesto, r.tenant_id
FROM te_reservaciones r
JOIN te_pedidos p ON p.id = r.pedido_id
LEFT JOIN tc_sitios s ON s.id = r.sitio_id
LEFT JOIN tc_puestos pu ON pu.id = r.puesto_id
WHERE r.empleado_id = mi_empleado_id();

-- ============================================================================

-- ============================================================================
-- Migración 013 — Fix real: current_user_id()/current_tenant_id() no leían el
-- JWT en esta instancia de PostgREST
-- ============================================================================
-- Causa raíz encontrada probando el portal freelance en vivo con una cuenta real
-- (no era config de Supabase -- las JWT Signing Keys del proyecto están correctas,
-- se verificó en el dashboard): PostgREST en este proyecto expone el claim
-- agregado `request.jwt.claims` (JSON completo) pero YA NO expone cada claim
-- individual como `request.jwt.claim.<nombre>` (formato que ambas funciones
-- usaban). Por eso `current_user_id()` siempre devolvía NULL para cualquier
-- usuario autenticado -> `mi_empleado_id()` siempre NULL -> el portal freelance
-- (Publicaciones, Mis eventos) se veía vacío para TODOS los usuarios reales,
-- aunque el login funcionara perfecto y la vista/RLS estuvieran bien.
-- Fix: leer primero el JSON agregado (->>'sub'), con fallback al formato viejo
-- por si alguna vez se vuelve a exponer así.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.current_user_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
BEGIN
  RETURN COALESCE(
    NULLIF(current_setting('app.current_user', true), '')::uuid,
    NULLIF(current_setting('request.jwt.claims', true)::json->>'sub', '')::uuid,
    NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
  );
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END $function$;

CREATE OR REPLACE FUNCTION public.current_tenant_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE h_tenant text;
BEGIN
  BEGIN
    h_tenant := current_setting('request.headers', true)::json->>'x-tenant-id';
  EXCEPTION WHEN OTHERS THEN
    h_tenant := NULL;
  END;
  RETURN COALESCE(
    NULLIF(current_setting('app.current_tenant', true), '')::uuid,
    h_tenant::uuid,
    NULLIF(current_setting('request.jwt.claims', true)::json->>'sub', '')::uuid,
    NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
  );
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END $function$;

-- ============================================================================

-- ============================================================================
-- Migración 014 — Fix real: inscribirme_a_publicacion() fallaba en el camino de
-- respaldo (pedido sin fecha explícita en te_pedido_fechas)
-- ============================================================================
-- Encontrado probando el portal freelance en vivo (clic real en "Inscribirme"):
-- "cannot cast type time with time zone to interval". La rama de respaldo hacía
-- `hora_inicio::interval` sobre una columna `time with time zone` -- cast
-- inválido en Postgres. `date + timetz` ya produce `timestamptz` directamente,
-- no hace falta el cast a interval.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.inscribirme_a_publicacion(p_detalle uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
    SELECT (fecha_evento + hora_inicio), (fecha_evento + hora_fin)
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
END $function$;

-- ============================================================================

-- ============================================================================
-- Migración 015 — Fix real: inscribirme_a_publicacion() usaba fecha/hora del
-- PEDIDO (encabezado) en el fallback, no de la LÍNEA (detalle) -- causaba
-- traslapes falsos entre líneas de distintos pedidos sin fecha explícita en
-- te_pedido_fechas, porque te_pedidos.hora_inicio/hora_fin casi siempre están
-- NULL (el horario real vive por línea en te_pedidos_detalle, confirmado toda
-- la sesión: Pedido = encabezado, Detalle = matriz de puestos con su propia
-- fecha_cita/hora_cita_inicio/hora_cita_fin).
-- Encontrado probando "Inscribirme" en vivo dos veces seguidas: la 2a.
-- inscripción se rechazó por "Traslape" contra la 1a., aunque eran pedidos y
-- fechas distintas -- porque ambas colapsaban a NULL/NULL en el fallback viejo.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.inscribirme_a_publicacion(p_detalle uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  det te_pedidos_detalle;
  fe  te_pedido_fechas;
  pu  tc_puestos;
  emp uuid;
  nueva uuid;
  cita_i timestamptz; cita_f timestamptz;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado (auth_user_id).'; END IF;
  SELECT * INTO det FROM te_pedidos_detalle WHERE id = p_detalle;
  IF det.id IS NULL THEN RAISE EXCEPTION 'Detalle no existe.'; END IF;
  SELECT * INTO pu FROM tc_puestos WHERE id = det.puesto_id;
  SELECT * INTO fe FROM te_pedido_fechas WHERE id = det.pedido_fecha_id;
  IF fe.id IS NOT NULL THEN
    cita_i := (fe.fecha || ' ' || fe.hora_inicio)::timestamptz;
    cita_f := (fe.fecha || ' ' || fe.hora_fin)::timestamptz;
    IF cita_f <= cita_i THEN cita_f := cita_f + interval '1 day'; END IF;
  ELSIF det.fecha_cita IS NOT NULL THEN
    -- Fallback 1: fecha/hora de la LÍNEA (te_pedidos_detalle), no del pedido
    cita_i := det.fecha_cita + COALESCE(det.hora_cita_inicio, '00:00'::time);
    cita_f := det.fecha_cita + COALESCE(det.hora_cita_fin,
                COALESCE(det.hora_cita_inicio, '00:00'::time) + make_interval(hours => COALESCE(pu.duracion_turno_horas, 12)::int));
    IF cita_f <= cita_i THEN cita_f := cita_f + interval '1 day'; END IF;
  ELSE
    -- Fallback 2: último recurso, fecha/hora del pedido (encabezado)
    SELECT (fecha_evento + hora_inicio), (fecha_evento + hora_fin)
      INTO cita_i, cita_f
      FROM te_pedidos WHERE id = det.pedido_id;
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
END $function$;

-- ============================================================================

-- ============================================================================
-- Migración 016 — Backend para login admin + enforcement de permisos en React
-- ============================================================================
-- mi_usuario(): datos del usuario interno logueado (análogo a mi_empleado_id())
-- mis_permisos(): set de códigos de permiso del usuario logueado, para cachear
-- en el frontend y no llamar tiene_permiso() una por una.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.mi_usuario()
 RETURNS TABLE (id uuid, nombre_usuario text, correo text, nombre text, apellido_paterno text, rol_codigo text, rol_nombre text)
 LANGUAGE sql
 STABLE
AS $function$
  SELECT u.id, u.nombre_usuario, u.correo, u.nombre, u.apellido_paterno, r.codigo, r.nombre
  FROM te_usuarios u
  JOIN tr_usuario_rol ur ON ur.usuario_id = u.id
  JOIN tc_roles r ON r.id = ur.rol_id
  WHERE u.auth_user_id = current_user_id()
    AND u.tenant_id = current_tenant_id()
    AND u.activo AND NOT u.bloqueado
  LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.mis_permisos()
 RETURNS text[]
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(array_agg(DISTINCT rp.permiso_codigo), ARRAY[]::text[])
  FROM te_usuarios u
  JOIN tr_usuario_rol ur ON ur.usuario_id = u.id
  JOIN tr_rol_permiso rp ON rp.rol_id = ur.rol_id
  WHERE u.auth_user_id = current_user_id()
    AND u.tenant_id = current_tenant_id()
    AND u.activo AND NOT u.bloqueado;
$function$;

GRANT EXECUTE ON FUNCTION mi_usuario() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION mis_permisos() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION tiene_permiso(uuid, text) TO anon, authenticated;

-- ============================================================================

-- ============================================================================
-- Migración 017 — Tenants demo multi-vertical: Construcción, Seguridad
-- privada y BTL/Activaciones. Objetivo: demostrar que el modelo multi-tenant
-- por columna (tenant_id + RLS, ver D6) soporta verticales distintas a
-- eventos/OCESA SIN tocar esquema -- mismos catálogos
-- tc_sitios/tc_puestos/tc_turnos/tc_clientes/tc_unidades_negocio, mismas
-- tablas te_empleados/te_pedidos/te_pedidos_detalle, solo datos distintos
-- por tenant_id. No se agregó ni una columna nueva para esta migración.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Tenants, suscripción, parámetros, aviso de privacidad, tipos de personal
-- ---------------------------------------------------------------------------
INSERT INTO te_tenants (id, razon_social, rfc, vertical) VALUES
  ('00000000-0000-0000-0000-000000000002','Edifica Talento Obra Civil, S.A. de C.V.','ETO260102AB1','construccion'),
  ('00000000-0000-0000-0000-000000000003','Guardia Total Seguridad Privada, S.A. de C.V.','GTS260103CD2','seguridad_privada'),
  ('00000000-0000-0000-0000-000000000004','Impacto BTL Promotoras y Activaciones, S.A. de C.V.','IBP260104EF3','btl_activaciones');

INSERT INTO te_suscripciones (tenant_id, plan_codigo) VALUES
  ('00000000-0000-0000-0000-000000000002','PRO'),
  ('00000000-0000-0000-0000-000000000003','PRO'),
  ('00000000-0000-0000-0000-000000000004','PRO');

INSERT INTO tp_parametros_globales (tenant_id) VALUES
  ('00000000-0000-0000-0000-000000000002'),
  ('00000000-0000-0000-0000-000000000003'),
  ('00000000-0000-0000-0000-000000000004');

INSERT INTO tp_avisos_privacidad (tenant_id, version, texto) VALUES
  ('00000000-0000-0000-0000-000000000002','v1.0','Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. Revocable en cualquier momento.'),
  ('00000000-0000-0000-0000-000000000003','v1.0','Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. Revocable en cualquier momento.'),
  ('00000000-0000-0000-0000-000000000004','v1.0','Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. Revocable en cualquier momento.');

INSERT INTO tc_tipos_personal (tenant_id, clave, descripcion) VALUES
  ('00000000-0000-0000-0000-000000000002','freelance','Personal freelance / eventual'),
  ('00000000-0000-0000-0000-000000000002','staff','Personal de planta'),
  ('00000000-0000-0000-0000-000000000003','freelance','Personal freelance / eventual'),
  ('00000000-0000-0000-0000-000000000003','staff','Personal de planta'),
  ('00000000-0000-0000-0000-000000000004','freelance','Personal freelance / eventual'),
  ('00000000-0000-0000-0000-000000000004','staff','Personal de planta');

INSERT INTO tc_tipos_documento (tenant_id, clave, titulo, requerido_alta) VALUES
  ('00000000-0000-0000-0000-000000000002','ine','INE / IFE vigente', true),
  ('00000000-0000-0000-0000-000000000002','curp','CURP', true),
  ('00000000-0000-0000-0000-000000000003','ine','INE / IFE vigente', true),
  ('00000000-0000-0000-0000-000000000003','curp','CURP', true),
  ('00000000-0000-0000-0000-000000000004','ine','INE / IFE vigente', true),
  ('00000000-0000-0000-0000-000000000004','curp','CURP', true);

-- ---------------------------------------------------------------------------
-- 2. Unidades de negocio, turnos y clientes por tenant
-- ---------------------------------------------------------------------------
INSERT INTO tc_unidades_negocio (tenant_id, titulo) VALUES
  ('00000000-0000-0000-0000-000000000002','Obra Civil'),
  ('00000000-0000-0000-0000-000000000002','Acabados e Instalaciones'),
  ('00000000-0000-0000-0000-000000000003','Vigilancia Comercial'),
  ('00000000-0000-0000-0000-000000000003','Vigilancia Bancaria'),
  ('00000000-0000-0000-0000-000000000003','Vigilancia Gubernamental'),
  ('00000000-0000-0000-0000-000000000004','Activaciones Retail'),
  ('00000000-0000-0000-0000-000000000004','Eventos Especiales');

INSERT INTO tc_turnos (tenant_id, titulo, hora_inicio, hora_fin) VALUES
  ('00000000-0000-0000-0000-000000000002','Jornada diurna obra','07:00','17:00'),
  ('00000000-0000-0000-0000-000000000002','Turno colado nocturno','20:00','04:00'),
  ('00000000-0000-0000-0000-000000000003','Matutino 06-14','06:00','14:00'),
  ('00000000-0000-0000-0000-000000000003','Vespertino 14-22','14:00','22:00'),
  ('00000000-0000-0000-0000-000000000003','Nocturno 22-06','22:00','06:00'),
  ('00000000-0000-0000-0000-000000000003','Turno 24x24','08:00','08:00'),
  ('00000000-0000-0000-0000-000000000004','Fin de semana AM','10:00','16:00'),
  ('00000000-0000-0000-0000-000000000004','Fin de semana PM','16:00','21:00'),
  ('00000000-0000-0000-0000-000000000004','Evento premium','18:00','23:00');

INSERT INTO tc_clientes (tenant_id, razon_social, abreviacion) VALUES
  ('00000000-0000-0000-0000-000000000002','Grupo Inmobiliario Horizonte, S.A. de C.V.','Horizonte'),
  ('00000000-0000-0000-0000-000000000002','Constructora Vallarta Residencial','Vallarta'),
  ('00000000-0000-0000-0000-000000000002','Desarrollos Urbanos del Bajío','DUB'),
  ('00000000-0000-0000-0000-000000000003','Autoservicios Walmart de México','Walmart'),
  ('00000000-0000-0000-0000-000000000003','Banregio Grupo Financiero — Sucursales','Banregio'),
  ('00000000-0000-0000-0000-000000000003','Gobierno del Estado — Oficinas Centrales','Gob. Edo.'),
  ('00000000-0000-0000-0000-000000000004','Colgate-Palmolive México','Colgate'),
  ('00000000-0000-0000-0000-000000000004','Grupo Modelo','Modelo'),
  ('00000000-0000-0000-0000-000000000004','Joyería Diamante & Platino','Diamante & Platino');

-- ---------------------------------------------------------------------------
-- 3. Sitios por tenant (reutiliza tipo_sitio_enum existente: obra/sucursal/
--    tienda/oficina/otro -- no requiere valores nuevos de enum)
-- ---------------------------------------------------------------------------
INSERT INTO tc_sitios (tenant_id, titulo, tipo_sitio, direccion) VALUES
  ('00000000-0000-0000-0000-000000000002','Residencial Las Lomas — Torre A','obra','Blvd. Las Lomas 450, Zapopan, Jalisco'),
  ('00000000-0000-0000-0000-000000000002','Plaza Comercial Norte — Fase 1','obra','Av. Industrias 1200, Querétaro, Querétaro'),
  ('00000000-0000-0000-0000-000000000002','Nave Industrial Querétaro','obra','Parque Industrial Balvanera, Corregidora, Querétaro'),
  ('00000000-0000-0000-0000-000000000003','Walmart Satélite','sucursal','Circuito Centro Comercial 2251, Cd. Satélite, Edo. de México'),
  ('00000000-0000-0000-0000-000000000003','Walmart Universidad','sucursal','Av. Universidad 1000, Cd. de México'),
  ('00000000-0000-0000-0000-000000000003','CEDIS Walmart Cuautitlán','otro','Parque Industrial Cuamatla, Cuautitlán Izcalli, Edo. de México'),
  ('00000000-0000-0000-0000-000000000003','Banregio Sucursal Polanco','sucursal','Av. Presidente Masaryk 111, Polanco, Cd. de México'),
  ('00000000-0000-0000-0000-000000000003','Gobierno Edo. Méx — Oficinas Centrales','oficina','Av. Ignacio Comonfort 1600, Toluca, Edo. de México'),
  ('00000000-0000-0000-0000-000000000004','Walmart Félix Cuevas','tienda','Av. Félix Cuevas 95, Del Valle, Cd. de México'),
  ('00000000-0000-0000-0000-000000000004','Walmart Universidad','tienda','Av. Universidad 1000, Cd. de México'),
  ('00000000-0000-0000-0000-000000000004','Chedraui Toreo','tienda','Av. Toreo, Naucalpan, Edo. de México'),
  ('00000000-0000-0000-0000-000000000004','La Comer Del Valle','tienda','Av. Coyoacán 1600, Del Valle, Cd. de México'),
  ('00000000-0000-0000-0000-000000000004','Salón Diamante Polanco','evento','Calle Anatole France 120, Polanco, Cd. de México');

-- ---------------------------------------------------------------------------
-- 4. Puestos por tenant (sexo_requerido ya existía en tc_puestos -- se usa
--    aquí tal cual para los puestos de "Modelo", igual que el legado Lobo
--    traía "Modelo Star 1-5" como puestos con sexo definido; ver pendiente
--    de tc_productos.id_puesto en CLAUDE.md §11, mismo mecanismo)
-- ---------------------------------------------------------------------------
INSERT INTO tc_puestos (tenant_id, titulo, pago_default, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, ciclo_pago, regimen_pago) VALUES
  ('00000000-0000-0000-0000-000000000002','Albañil', 450, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Ayudante de albañil (Chalán)', 320, 10, 0, 24, 1, 0.70, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Plomero', 500, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Electricista de obra', 520, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Carpintero de obra (cimbra)', 480, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Herrero / Armador', 480, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Pintor de obra', 420, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Yesero / Aplanador', 430, 10, 0, 24, 1, 0.75, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Operador de maquinaria pesada', 700, 10, 0, 24, 1, 0.85, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Soldador', 550, 10, 0, 24, 1, 0.80, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Topógrafo', 600, 10, 0, 24, 1, 0.80, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Normales'),
  ('00000000-0000-0000-0000-000000000002','Supervisor de obra', 900, 10, 0, 48, 1, 0.85, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Residente de obra', 1200, 10, 0, 48, 1, 0.90, 90, true, 'Requiere Entrada y Salida', 'Quincenal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000002','Prevencionista de seguridad e higiene', 650, 10, 0, 24, 1, 0.80, 90, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Normales'),

  ('00000000-0000-0000-0000-000000000003','Vigilante de acceso', 280, 8, 0, 24, 1, 0.80, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Vigilante de piso de ventas', 280, 8, 0, 24, 1, 0.80, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Guardia de CEDIS / Almacén 24x24', 600, 24, 24, 24, 1, 0.85, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Monitorista CCTV', 320, 8, 0, 24, 1, 0.80, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Supervisor de turno', 500, 8, 0, 48, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Jefe de zona/plaza', 800, 8, 0, 48, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Quincenal', 'Nomina'),
  ('00000000-0000-0000-0000-000000000003','Escolta de valores', 450, 8, 0, 24, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Normales'),

  ('00000000-0000-0000-0000-000000000004','Promotora / Impulsadora', 450, 6, 0, 48, 1, 0.75, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Asimilables'),
  ('00000000-0000-0000-0000-000000000004','Demostrador(a) de producto', 450, 6, 0, 48, 1, 0.75, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Asimilables'),
  ('00000000-0000-0000-0000-000000000004','Edecán', 500, 5, 0, 48, 1, 0.80, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Asimilables'),
  ('00000000-0000-0000-0000-000000000004','Supervisor de piso', 700, 6, 0, 48, 1, 0.85, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Normales'),
  ('00000000-0000-0000-0000-000000000004','Coordinador de activación', 900, 8, 0, 48, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Normales')
;

-- Puestos de "Modelo" con sexo_requerido explícito (mismo mecanismo que el
-- legado Lobo usaba para "Modelo Star 1-5"; aquí se usa correctamente desde
-- el catálogo en vez de texto libre)
INSERT INTO tc_puestos (tenant_id, titulo, pago_default, duracion_turno_horas, horas_entre_turnos, horas_antes_cancelar, porcentaje_certeza_inicial, porcentaje_minimo, dias_sin_confirmar, requiere_biometrico, tipo_registro_asistencia, ciclo_pago, regimen_pago, sexo_requerido) VALUES
  ('00000000-0000-0000-0000-000000000004','Modelo Evento Premium Femenino', 1800, 5, 0, 72, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Asimilables', 'F'),
  ('00000000-0000-0000-0000-000000000004','Modelo Evento Premium Masculino', 1800, 5, 0, 72, 1, 0.90, 60, true, 'Requiere Entrada y Salida', 'Semanal', 'Honorarios Asimilables', 'M');

-- ---------------------------------------------------------------------------
-- 5. Roles + permisos por tenant (mismo catálogo global tc_permisos, mismo
--    criterio de asignación que el tenant demo original)
-- ---------------------------------------------------------------------------
INSERT INTO tc_roles (tenant_id, codigo, nombre, descripcion, es_sistema)
SELECT t, 'administrador', 'Administrador', 'Control total del sistema', true FROM (VALUES
  ('00000000-0000-0000-0000-000000000002'::uuid),
  ('00000000-0000-0000-0000-000000000003'::uuid),
  ('00000000-0000-0000-0000-000000000004'::uuid)) AS v(t)
UNION ALL
SELECT t, 'operacion', 'Operación', 'Gestión día a día: pedidos, asignación, checador', true FROM (VALUES
  ('00000000-0000-0000-0000-000000000002'::uuid),
  ('00000000-0000-0000-0000-000000000003'::uuid),
  ('00000000-0000-0000-0000-000000000004'::uuid)) AS v(t);

INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT r.tenant_id, r.id, p.codigo
FROM tc_roles r, tc_permisos p
WHERE r.tenant_id IN ('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000004')
  AND r.codigo = 'administrador';

INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT r.tenant_id, r.id, p.codigo
FROM tc_roles r, tc_permisos p
WHERE r.tenant_id IN ('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000004')
  AND r.codigo = 'operacion'
  AND p.modulo IN ('candidatos','vacantes','requisiciones','pedidos','reservaciones','empleados','checador','reportes')
  AND p.accion <> 'aprobar';
INSERT INTO tr_rol_permiso (tenant_id, rol_id, permiso_codigo)
SELECT r.tenant_id, r.id, 'catalogos.ver'
FROM tc_roles r
WHERE r.tenant_id IN ('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000004')
  AND r.codigo = 'operacion';

-- Nota: igual que en el tenant demo original, NO se crea fila en te_usuarios
-- aquí (requiere auth_user_id real de Supabase Auth). Las cuentas de prueba
-- para "brincar" entre estos 3 tenants se dan de alta con el script aparte
-- db/seed_demo_usuarios_multiempresa.sql (mismo mecanismo que las cuentas de
-- §10 del CLAUDE.md: INSERT directo en auth.users, dominio @peoplemovil.demo).

-- ---------------------------------------------------------------------------
-- 6. Empleados demo por tenant (folio consecutivo por tenant_id, igual que
--    el tenant original). rfc/curp/telefono/correo se dejan NULL a propósito
--    -- son datos ficticios de demo, no hace falta inventar identificadores
--    que parezcan reales. foto_url usa avatares sintéticos (DiceBear, API
--    pública determinista por seed) para poblar el campo sin subir fotos de
--    personas reales ni generar rostros fotorrealistas falsos.
-- ---------------------------------------------------------------------------

-- Tenant 2 — Construcción: 10 albañiles, 2 plomeros, 3 carpinteros + soporte
-- (el ejemplo exacto que se pidió: "10 albañiles, 2 plomeros, 3 carpinteros")
INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, id_puesto_principal, id_sitio_principal, regimen_pago, ciclo_pago, foto_url)
SELECT '00000000-0000-0000-0000-000000000002', v.folio, v.nombres, v.ap, v.am, v.sexo::sexo_enum,
       (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo=v.puesto),
       (SELECT id FROM tc_sitios  WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo='Residencial Las Lomas — Torre A'),
       'Nomina','Semanal',
       'https://api.dicebear.com/9.x/personas/svg?seed=pm-t2-' || v.folio
FROM (VALUES
  (1,'Jorge','Hernández','Pérez','M','Albañil'),
  (2,'Martín','Gómez','Luna','M','Albañil'),
  (3,'Rafael','Torres','Ibarra','M','Albañil'),
  (4,'Salvador','Reyes','Campos','M','Albañil'),
  (5,'Eduardo','Vargas','Soto','M','Albañil'),
  (6,'Francisco','Jiménez','Ruiz','M','Albañil'),
  (7,'Alberto','Morales','Cruz','M','Albañil'),
  (8,'Ricardo','Flores','Medina','M','Albañil'),
  (9,'Juan Carlos','Ramírez','Ortiz','M','Albañil'),
  (10,'Pedro','Sánchez','Nava','M','Albañil'),
  (11,'Luis Ángel','Castillo','Mora','M','Plomero'),
  (12,'Miguel Ángel','Rosales','Vega','M','Plomero'),
  (13,'Daniel','Herrera','Paredes','M','Carpintero de obra (cimbra)'),
  (14,'Ignacio','Domínguez','Rivas','M','Carpintero de obra (cimbra)'),
  (15,'Hugo','Benítez','Salas','M','Carpintero de obra (cimbra)'),
  (16,'Carlos Eduardo','Lemus','Prado','M','Electricista de obra'),
  (17,'Oscar','Villanueva','Cano','M','Operador de maquinaria pesada'),
  (18,'Mario Alberto','Zúñiga','Peña','M','Prevencionista de seguridad e higiene'),
  (19,'Patricia','Luna','Esquivel','F','Supervisor de obra'),
  (20,'Roberto','Cantú','Elizondo','M','Residente de obra')
) AS v(folio,nombres,ap,am,sexo,puesto);

INSERT INTO tr_empleado_plaza (tenant_id, empleado_id, puesto_id, porcentaje_puntualidad)
SELECT '00000000-0000-0000-0000-000000000002', e.id, e.id_puesto_principal, 0.95
FROM te_empleados e WHERE e.tenant_id='00000000-0000-0000-0000-000000000002';

-- Tenant 3 — Seguridad privada
INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, id_puesto_principal, id_sitio_principal, regimen_pago, ciclo_pago, foto_url)
SELECT '00000000-0000-0000-0000-000000000003', v.folio, v.nombres, v.ap, v.am, v.sexo::sexo_enum,
       (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.puesto),
       (SELECT id FROM tc_sitios  WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.sitio),
       'Nomina','Semanal',
       'https://api.dicebear.com/9.x/personas/svg?seed=pm-t3-' || v.folio
FROM (VALUES
  (1,'José Luis','Aguilar','Mendoza','M','Vigilante de acceso','Walmart Satélite'),
  (2,'Marcos Antonio','Pineda','Ríos','M','Vigilante de acceso','Walmart Satélite'),
  (3,'Felipe de Jesús','Gutiérrez','Mata','M','Vigilante de acceso','Walmart Satélite'),
  (4,'Erika Patricia','Núñez','Soria','F','Vigilante de piso de ventas','Walmart Universidad'),
  (5,'Brenda Carolina','Reséndiz','León','F','Vigilante de piso de ventas','Walmart Universidad'),
  (6,'Omar Alejandro','Cedillo','Bravo','M','Vigilante de piso de ventas','Walmart Universidad'),
  (7,'Víctor Manuel','Solano','Pacheco','M','Guardia de CEDIS / Almacén 24x24','CEDIS Walmart Cuautitlán'),
  (8,'Lizbeth Guadalupe','Marín','Ochoa','F','Monitorista CCTV','CEDIS Walmart Cuautitlán'),
  (9,'Sergio Iván','Palacios','Guzmán','M','Supervisor de turno','Walmart Satélite'),
  (10,'Rodrigo Esteban','Varela','Montes','M','Jefe de zona/plaza','Walmart Satélite')
) AS v(folio,nombres,ap,am,sexo,puesto,sitio);

INSERT INTO tr_empleado_plaza (tenant_id, empleado_id, puesto_id, porcentaje_puntualidad)
SELECT '00000000-0000-0000-0000-000000000003', e.id, e.id_puesto_principal, 0.95
FROM te_empleados e WHERE e.tenant_id='00000000-0000-0000-0000-000000000003';

-- Tenant 4 — BTL / Promotoras y Activaciones
INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, id_puesto_principal, id_sitio_principal, regimen_pago, ciclo_pago, foto_url)
SELECT '00000000-0000-0000-0000-000000000004', v.folio, v.nombres, v.ap, v.am, v.sexo::sexo_enum,
       (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.puesto),
       (SELECT id FROM tc_sitios  WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.sitio),
       'Honorarios Asimilables','Semanal',
       'https://api.dicebear.com/9.x/personas/svg?seed=pm-t4-' || v.folio
FROM (VALUES
  (1,'Daniela Fernanda','Ruiz','Contreras','F','Promotora / Impulsadora','Walmart Félix Cuevas'),
  (2,'Ana Paola','Sandoval','Rico','F','Promotora / Impulsadora','Chedraui Toreo'),
  (3,'Montserrat','Avilés','Guerrero','F','Promotora / Impulsadora','Walmart Félix Cuevas'),
  (4,'Jessica Alejandra','Correa','Nieto','F','Promotora / Impulsadora','Chedraui Toreo'),
  (5,'Karla Michelle','Barrera','Soto','F','Demostrador(a) de producto','La Comer Del Valle'),
  (6,'Fernando Iván','Cervantes','Lara','M','Demostrador(a) de producto','Walmart Universidad'),
  (7,'Diana Laura','Prieto','Valencia','F','Edecán','Salón Diamante Polanco'),
  (8,'Paulina Itzel','Marroquín','Osorio','F','Edecán','Salón Diamante Polanco'),
  (9,'Gerardo Emmanuel','Tapia','Robles','M','Supervisor de piso','Walmart Félix Cuevas'),
  (10,'Lucía Fernanda','Calderón','Ibarra','F','Coordinador de activación','Salón Diamante Polanco'),
  (11,'Alexa Sofía','Montaño','Delgado','F','Modelo Evento Premium Femenino','Salón Diamante Polanco'),
  (12,'Christian Eduardo','Lozano','Beltrán','M','Modelo Evento Premium Masculino','Salón Diamante Polanco')
) AS v(folio,nombres,ap,am,sexo,puesto,sitio);

INSERT INTO tr_empleado_plaza (tenant_id, empleado_id, puesto_id, porcentaje_puntualidad)
SELECT '00000000-0000-0000-0000-000000000004', e.id, e.id_puesto_principal, 0.95
FROM te_empleados e WHERE e.tenant_id='00000000-0000-0000-0000-000000000004';

-- ---------------------------------------------------------------------------
-- 7. Pedidos de ejemplo por tenant -- casos exactos descritos en la sesión:
--    construcción (10 albañiles/2 plomeros/3 carpinteros en una obra),
--    seguridad (relevos de 8h cubriendo 24h, y turno único 24x24 en CEDIS),
--    BTL (activación de fin de semana para Colgate, evento premium con
--    modelos para una marca de lujo).
-- ---------------------------------------------------------------------------

-- Tenant 2 — Construcción
INSERT INTO te_pedidos (tenant_id, folio, titulo, sitio_id, cliente_id, fecha_evento, status)
VALUES (
  '00000000-0000-0000-0000-000000000002', 1,
  'Dotación de personal — Residencial Las Lomas Torre A (semana 1)',
  (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo='Residencial Las Lomas — Torre A'),
  (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND razon_social='Grupo Inmobiliario Horizonte, S.A. de C.V.'),
  '2026-10-12','liberado'
);

INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle)
SELECT '00000000-0000-0000-0000-000000000002',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND folio=1),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo=v.puesto),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo='Jornada diurna obra'),
  v.cantidad, v.costo, '2026-10-12','07:00','17:00','liberado'
FROM (VALUES
  ('Albañil',10,450),
  ('Plomero',2,500),
  ('Carpintero de obra (cimbra)',3,480)
) AS v(puesto,cantidad,costo);

-- Tenant 3 — Seguridad privada
INSERT INTO te_pedidos (tenant_id, folio, titulo, sitio_id, cliente_id, fecha_evento, status) VALUES
  ('00000000-0000-0000-0000-000000000003', 1, 'Vigilancia Walmart Satélite — Octubre 2026',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Walmart Satélite'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND razon_social='Autoservicios Walmart de México'),
   '2026-10-01','liberado'),
  ('00000000-0000-0000-0000-000000000003', 2, 'Vigilancia CEDIS Cuautitlán — Octubre 2026',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='CEDIS Walmart Cuautitlán'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND razon_social='Autoservicios Walmart de México'),
   '2026-10-01','liberado'),
  ('00000000-0000-0000-0000-000000000003', 3, 'Vigilancia Banregio Sucursal Polanco',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Banregio Sucursal Polanco'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND razon_social='Banregio Grupo Financiero — Sucursales'),
   '2026-10-01','liberado'),
  ('00000000-0000-0000-0000-000000000003', 4, 'Vigilancia Oficinas Gobierno Edo. Méx.',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Gobierno Edo. Méx — Oficinas Centrales'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND razon_social='Gobierno del Estado — Oficinas Centrales'),
   '2026-10-01','liberado');

-- Walmart Satélite: 3 relevos de 8h cubren las 24h (como se describió: uno en la mañana, otro en la tarde, otro en la noche)
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle)
SELECT '00000000-0000-0000-0000-000000000003',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND folio=1),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Vigilante de acceso'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.turno),
  1, 280, '2026-10-01', v.hi::time, v.hf::time, 'liberado'
FROM (VALUES ('Matutino 06-14','06:00','14:00'),('Vespertino 14-22','14:00','22:00'),('Nocturno 22-06','22:00','06:00')) AS v(turno,hi,hf);

-- CEDIS Cuautitlán: un solo vigilante en turno 24x24 (como se describió)
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle)
VALUES (
  '00000000-0000-0000-0000-000000000003',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND folio=2),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Guardia de CEDIS / Almacén 24x24'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Turno 24x24'),
  1, 600, '2026-10-01', '08:00', '08:00', 'liberado'
);

-- Banregio Polanco: solo horario bancario (matutino + vespertino, sin nocturno)
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle)
SELECT '00000000-0000-0000-0000-000000000003',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND folio=3),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Vigilante de acceso'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.turno),
  1, 280, '2026-10-01', v.hi::time, v.hf::time, 'liberado'
FROM (VALUES ('Matutino 06-14','06:00','14:00'),('Vespertino 14-22','14:00','22:00')) AS v(turno,hi,hf);

-- Gobierno Edo. Méx: mismo esquema que el banco
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle)
SELECT '00000000-0000-0000-0000-000000000003',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND folio=4),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo='Vigilante de acceso'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.turno),
  1, 280, '2026-10-01', v.hi::time, v.hf::time, 'liberado'
FROM (VALUES ('Matutino 06-14','06:00','14:00'),('Vespertino 14-22','14:00','22:00')) AS v(turno,hi,hf);

-- Tenant 4 — BTL / Promotoras
INSERT INTO te_pedidos (tenant_id, folio, titulo, sitio_id, cliente_id, fecha_evento, status) VALUES
  ('00000000-0000-0000-0000-000000000004', 1, 'Activación Colgate — Walmart Félix Cuevas (fines de semana de octubre)',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Walmart Félix Cuevas'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND razon_social='Colgate-Palmolive México'),
   '2026-10-10','liberado'),
  ('00000000-0000-0000-0000-000000000004', 2, 'Activación Colgate — Chedraui Toreo (fines de semana de octubre)',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Chedraui Toreo'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND razon_social='Colgate-Palmolive México'),
   '2026-10-10','liberado'),
  ('00000000-0000-0000-0000-000000000004', 3, 'Lanzamiento Colección Diamante — Salón Diamante Polanco',
   (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Salón Diamante Polanco'),
   (SELECT id FROM tc_clientes WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND razon_social='Joyería Diamante & Platino'),
   '2026-11-13','liberado');

-- Colgate solo sábado y domingo (como se describió: "¿oye dónde están de lunes a viernes?")
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle, indicaciones_especiales)
SELECT '00000000-0000-0000-0000-000000000004',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND folio=1),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Promotora / Impulsadora'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.turno),
  2, 450, '2026-10-10', v.hi::time, v.hf::time, 'liberado',
  'Cobertura SOLO sábado y domingo (no entre semana); exhibir e impulsar línea de cuidado bucal Colgate.'
FROM (VALUES ('Fin de semana AM','10:00','16:00'),('Fin de semana PM','16:00','21:00')) AS v(turno,hi,hf);

INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle, indicaciones_especiales)
SELECT '00000000-0000-0000-0000-000000000004',
  (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND folio=2),
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Promotora / Impulsadora'),
  (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.turno),
  1, 450, '2026-10-10', v.hi::time, v.hf::time, 'liberado',
  'Cobertura SOLO sábado y domingo (no entre semana); exhibir e impulsar línea de cuidado bucal Colgate.'
FROM (VALUES ('Fin de semana AM','10:00','16:00'),('Fin de semana PM','16:00','21:00')) AS v(turno,hi,hf);

-- Evento de lujo: requiere modelos profesionales, no impulsadoras genéricas,
-- mezcla de hombres y mujeres con características específicas (como se
-- describió en la sesión) -- el requisito ad-hoc va en indicaciones_especiales
-- del detalle, NO como columna nueva de esquema; el sexo estructural del
-- puesto ya viene de tc_puestos.sexo_requerido (ver sección 4).
INSERT INTO te_pedidos_detalle (tenant_id, pedido_id, puesto_id, turno_id, cantidad, costo_unit, fecha_cita, hora_cita_inicio, hora_cita_fin, status_detalle, indicaciones_especiales) VALUES
  ('00000000-0000-0000-0000-000000000004',
   (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND folio=3),
   (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Modelo Evento Premium Femenino'),
   (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Evento premium'),
   2, 1800, '2026-11-13', '18:00','23:00', 'liberado',
   'Evento de lujo: requiere modelos profesionales con experiencia en pasarela, imagen cuidada, altura mínima 1.70m. No impulsadoras genéricas.'),
  ('00000000-0000-0000-0000-000000000004',
   (SELECT id FROM te_pedidos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND folio=3),
   (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Modelo Evento Premium Masculino'),
   (SELECT id FROM tc_turnos  WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo='Evento premium'),
   2, 1800, '2026-11-13', '18:00','23:00', 'liberado',
   'Evento de lujo: requiere modelos profesionales con experiencia en pasarela, imagen cuidada, altura mínima 1.80m. No impulsadoras genéricas.');

-- ============================================================================
-- Migración 018 -- Expedientes completos + ampliación a 30 empleados por
-- tenant demo multi-vertical (pedido del usuario 2026-10-08: "que tengan
-- expedientes completos... más empleados... que se vea más carnita"). Suma
-- 10 (construcción), 20 (seguridad privada) y 18 (BTL) empleados nuevos para
-- llegar a 30 por tenant, cada uno con RFC/CURP/fecha de nacimiento/domicilio
-- completo/banco+cuenta+CLABE/contacto de emergencia/tipo de sangre/grado de
-- estudios -- todos datos ficticios (RFC/CURP son aproximaciones de formato,
-- no checksums válidos; no corresponden a personas reales). Fotos: mismo
-- esquema DiceBear de la Migración 017 (D13), nunca rostros realistas.
-- Generado con scratchpad/gen_empleados_018.py (no versionado) y revisado a
-- mano antes de aplicar (se corrigieron teléfonos a 10 dígitos y
-- parentesco/sexo del contacto de emergencia antes de esta versión final).
-- ============================================================================

INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, rfc, curp, fecha_nacimiento, telefono, correo, calle, numero_exterior, colonia, codigo_postal, delegacion_municipio, estado_provincia, estado_nacimiento, estado_civil, estatura, talla, grado_estudios, contacto_emergencia, tipo_sangre, id_puesto_principal, id_sitio_principal, id_banco, cuenta_bancaria, clabe, regimen_pago, ciclo_pago, foto_url, fecha_alta)
SELECT '00000000-0000-0000-0000-000000000002', v.folio::int, v.nombres, v.ap, v.am, v.sexo::sexo_enum, v.rfc, v.curp, v.fecha_nacimiento::date, v.telefono, v.correo,
  v.calle, v.numero_exterior, v.colonia, v.codigo_postal, v.delegacion_municipio, v.estado_provincia, v.estado_nacimiento,
  v.estado_civil, v.estatura::numeric, v.talla, v.grado_estudios, v.contacto_emergencia, v.tipo_sangre,
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo=v.puesto),
  (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000002' AND titulo=v.sitio),
  (SELECT id FROM tc_bancos WHERE nombre=v.banco),
  v.cuenta_bancaria, v.clabe, 'Nomina', 'Semanal',
  'https://api.dicebear.com/9.x/personas/svg?seed=pm-t2-' || v.folio,
  v.fecha_alta::date
FROM (VALUES
  ('21','Gilberto','Macías','Saldaña','M','MASG780420V13','MASG780420HQTCSS17','1978-04-20','4428056747','gilberto.macias21@personal.peoplemovil.demo','Av. Corregidora','267','Colonia El Pueblito','76900','Corregidora','Querétaro','Querétaro','Soltero(a)',1.78,'XG','Bachillerato trunco','Viridiana Delgadillo Espinosa (madre) - 4422645033','A+','Soldador','Nave Industrial Querétaro','BANAMEX','2021112046','022002177367326817','2026-04-13'),
  ('22','Octavio','Nájera','Orozco','M','NAOO761211W26','NAOO761211HQTJRR24','1976-12-11','4425900991','octavio.najera22@personal.peoplemovil.demo','Av. Constituyentes','417','Colonia Carretas','76050','Querétaro','Querétaro','Querétaro','Unión libre',1.68,'M','Secundaria','Yesenia Quintero Palafox (esposa) - 4427690306','O+','Topógrafo','Plaza Comercial Norte — Fase 1','HSBC','2022681381','022002266334714956','2025-10-16'),
  ('23','Ulises','Jáuregui','Palafox','M','JAPU020917X39','JAPU020917HJCRGP31','2002-09-17','3387244482','ulises.jauregui23@personal.peoplemovil.demo','Av. Patria','490','Colonia Chapalita','45040','Zapopan','Jalisco','Jalisco','Soltero(a)',1.66,'M','Primaria','Viridiana Palafox Rendón (esposa) - 3374708126','AB+','Ayudante de albañil (Chalán)','Residencial Las Lomas — Torre A','BANORTE','2023990900','022002326689904531','2026-08-22'),
  ('24','Heriberto','Jáuregui','Treviño','M','JATH971110Y42','JATH971110HJCRGT48','1997-11-10','3363948553','heriberto.jauregui24@personal.peoplemovil.demo','Calle Mariano Otero','533','Colonia Santa Margarita','45030','Zapopan','Jalisco','Jalisco','Soltero(a)',1.71,'G','Secundaria','Rocío Yáñez Velázquez (madre) - 3380180947','O+','Ayudante de albañil (Chalán)','Residencial Las Lomas — Torre A','BANAMEX','2024477420','022002439727657897','2025-08-15'),
  ('25','Teodoro','Palafox','Treviño','M','PATT740511Z55','PATT740511HQTLFX55','1974-05-11','4422650441','teodoro.palafox25@personal.peoplemovil.demo','Calle 5 de Febrero','10','Colonia Centro Sur','76090','Querétaro','Querétaro','Querétaro','Divorciado(a)',1.71,'G','Bachillerato trunco','Adriana Delgadillo Yáñez (madre) - 4429362112','A+','Herrero / Armador','Nave Industrial Querétaro','SANTANDER','2025201358','022002569513803922','2025-01-03'),
  ('26','Agustín','Urbina','Treviño','M','UITA771026A68','UITA771026HQTRBN62','1977-10-26','4425158025','agustin.urbina26@personal.peoplemovil.demo','Av. Constituyentes','144','Colonia Carretas','76050','Querétaro','Querétaro','Querétaro','Unión libre',1.64,'CH','Secundaria','Rocío Zavala Macías (hermana) - 4429254204','AB+','Pintor de obra','Plaza Comercial Norte — Fase 1','BANCOPPEL','2026855470','022002631206459284','2025-08-19'),
  ('27','Emmanuel','Carrasco','Saldaña','M','CASE900214B71','CASE900214HQTRRS79','1990-02-14','4423686393','emmanuel.carrasco27@personal.peoplemovil.demo','Av. Corregidora','532','Colonia El Pueblito','76900','Corregidora','Querétaro','Querétaro','Casado(a)',1.81,'G','Bachillerato trunco','Esmeralda Hinojosa Orozco (esposa) - 4422780632','B+','Yesero / Aplanador','Plaza Comercial Norte — Fase 1','BANAMEX','2027177000','022002797389776196','2025-01-01'),
  ('28','Teodoro','Macías','Zúñiga','M','MAZT910811C84','MAZT910811HQTCSZ86','1991-08-11','4429347833','teodoro.macias28@personal.peoplemovil.demo','Av. Constituyentes','187','Colonia Carretas','76050','Querétaro','Querétaro','Querétaro','Casado(a)',1.81,'M','Secundaria','Itzel Velázquez Macías (madre) - 4424914569','A-','Albañil','Nave Industrial Querétaro','BANCOPPEL','2028845414','022002883312980647','2025-04-21'),
  ('29','Jesús','Yáñez','Treviño','M','YATJ750828D97','YATJ750828HQTNZT93','1975-08-28','4424162996','jesus.yanez29@personal.peoplemovil.demo','Av. Corregidora','322','Colonia El Pueblito','76900','Corregidora','Querétaro','Querétaro','Casado(a)',1.72,'CH','Secundaria','Esmeralda Figueroa Galindo (hermana) - 4424120649','AB+','Albañil','Plaza Comercial Norte — Fase 1','BANAMEX','2029386058','022002984841326735','2025-02-13'),
  ('30','Armando','Nájera','Galindo','M','NAGA880816E00','NAGA880816HQTJRG00','1988-08-16','4425826306','armando.najera30@personal.peoplemovil.demo','Calle 5 de Febrero','568','Colonia Centro Sur','76090','Querétaro','Querétaro','Querétaro','Soltero(a)',1.71,'G','Bachillerato trunco','Esmeralda Saldaña Jáuregui (esposa) - 4424595877','B+','Plomero','Nave Industrial Querétaro','BANORTE','2030105144','022003022685932734','2026-06-14')
) AS v(folio,nombres,ap,am,sexo,rfc,curp,fecha_nacimiento,telefono,correo,calle,numero_exterior,colonia,codigo_postal,delegacion_municipio,estado_provincia,estado_nacimiento,estado_civil,estatura,talla,grado_estudios,contacto_emergencia,tipo_sangre,puesto,sitio,banco,cuenta_bancaria,clabe,fecha_alta);

INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, rfc, curp, fecha_nacimiento, telefono, correo, calle, numero_exterior, colonia, codigo_postal, delegacion_municipio, estado_provincia, estado_nacimiento, estado_civil, estatura, talla, grado_estudios, contacto_emergencia, tipo_sangre, id_puesto_principal, id_sitio_principal, id_banco, cuenta_bancaria, clabe, regimen_pago, ciclo_pago, foto_url, fecha_alta)
SELECT '00000000-0000-0000-0000-000000000003', v.folio::int, v.nombres, v.ap, v.am, v.sexo::sexo_enum, v.rfc, v.curp, v.fecha_nacimiento::date, v.telefono, v.correo,
  v.calle, v.numero_exterior, v.colonia, v.codigo_postal, v.delegacion_municipio, v.estado_provincia, v.estado_nacimiento,
  v.estado_civil, v.estatura::numeric, v.talla, v.grado_estudios, v.contacto_emergencia, v.tipo_sangre,
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.puesto),
  (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000003' AND titulo=v.sitio),
  (SELECT id FROM tc_bancos WHERE nombre=v.banco),
  v.cuenta_bancaria, v.clabe, 'Nomina', 'Semanal',
  'https://api.dicebear.com/9.x/personas/svg?seed=pm-t3-' || v.folio,
  v.fecha_alta::date
FROM (VALUES
  ('11','Armando','Zavala','Nájera','M','ZANA820618L13','ZANA820618HDFVLN17','1982-06-18','5524722812','armando.zavala11@personal.peoplemovil.demo','Calle Pilares','710','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Unión libre',1.79,'G','Técnico','Teresa Jáuregui Zúñiga (hermana) - 5527799708','A-','Vigilante de acceso','Banregio Sucursal Polanco','BBVA','3011919504','032001124017539399','2026-03-04'),
  ('12','Araceli','Nájera','Dávalos','F','NADA831121M26','NADA831121MDFJRD24','1983-11-21','5577998284','araceli.najera12@personal.peoplemovil.demo','Av. Universidad','250','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.73,'CH','Licenciatura trunca','Efraín Jáuregui Delgadillo (esposo) - 5565249698','O-','Vigilante de acceso','Banregio Sucursal Polanco','SCOTIABANK','3012914512','032001266938561968','2026-01-04'),
  ('13','Antonio','Lozano','Espinosa','M','LOEA781118N39','LOEA781118HMCZNS31','1978-11-18','5552275152','antonio.lozano13@personal.peoplemovil.demo','Calle Parque Industrial','308','Colonia Cuamatla','54730','Cuautitlán Izcalli','Estado de México','Estado de México','Casado(a)',1.81,'CH','Licenciatura','Viridiana Quintero Palafox (hermana) - 5526030999','O-','Vigilante de acceso','Gobierno Edo. Méx — Oficinas Centrales','BANCOPPEL','3013492321','032001382418735390','2026-05-13'),
  ('14','Octavio','Cortés','Dávalos','M','CODO990110O42','CODO990110HMCRTS48','1999-01-10','5548863507','octavio.cortes14@personal.peoplemovil.demo','Calle Parque Industrial','138','Colonia Cuamatla','54730','Cuautitlán Izcalli','Estado de México','Estado de México','Unión libre',1.8,'CH','Licenciatura trunca','Teresa Zavala Treviño (madre) - 5536501061','B+','Vigilante de acceso','Gobierno Edo. Méx — Oficinas Centrales','HSBC','3014158872','032001431958439512','2026-02-02'),
  ('15','Ulises','Nájera','Velázquez','M','NAVU910114P55','NAVU910114HDFJRV55','1991-01-14','5557777679','ulises.najera15@personal.peoplemovil.demo','Calle Pilares','161','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.75,'XG','Técnico','Rocío Galindo Treviño (esposa) - 5598793440','B+','Escolta de valores','Banregio Sucursal Polanco','BANCOPPEL','3015667626','032001585951137096','2025-05-26'),
  ('16','Concepción','Zavala','Zavala','F','ZAZC890916Q68','ZAZC890916MMCVLZ62','1989-09-16','5545408799','concepcion.zavala16@personal.peoplemovil.demo','Calle Lago Chapala','258','Colonia Valle Dorado','54020','Tlalnepantla','Estado de México','Estado de México','Soltero(a)',1.84,'M','Bachillerato','Ulises Jáuregui Macías (hermano) - 5579853472','A+','Monitorista CCTV','Walmart Satélite','SCOTIABANK','3016879188','032001615658610579','2026-01-21'),
  ('17','Teodoro','Cortés','Ibarra','M','COIT811228R71','COIT811228HDFRTS79','1981-12-28','5558309143','teodoro.cortes17@personal.peoplemovil.demo','Calle Río Churubusco','167','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Casado(a)',1.84,'M','Licenciatura trunca','Yesenia Nájera Quintero (hermana) - 5571412691','O-','Monitorista CCTV','Walmart Universidad','HSBC','3017950853','032001751148276485','2025-11-14'),
  ('18','Teodoro','Zavala','Nájera','M','ZANT980121S84','ZANT980121HDFVLN86','1998-01-21','5521302114','teodoro.zavala18@personal.peoplemovil.demo','Calle Pilares','669','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Soltero(a)',1.73,'G','Técnico','Guadalupe Treviño Hinojosa (hermana) - 5588166830','AB+','Supervisor de turno','Walmart Universidad','SANTANDER','3018700445','032001863228715242','2025-09-26'),
  ('19','Armando','Saldaña','Espinosa','M','SAEA770324T97','SAEA770324HDFLDN93','1977-03-24','5554776368','armando.saldana19@personal.peoplemovil.demo','Calle Río Churubusco','19','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Casado(a)',1.77,'G','Bachillerato','Leticia Lozano Lozano (hermana) - 5548329736','AB+','Jefe de zona/plaza','Walmart Universidad','SANTANDER','3019240514','032001965717554590','2025-12-21'),
  ('20','Emmanuel','Yáñez','Rendón','M','YARE990626U00','YARE990626HMCNZR00','1999-06-26','5579281900','emmanuel.yanez20@personal.peoplemovil.demo','Av. Lerdo de Tejada','554','Colonia Reforma','50070','Toluca','Estado de México','Estado de México','Soltero(a)',1.69,'G','Técnico','Beatriz Saldaña Zúñiga (hermana) - 5596356336','A+','Guardia de CEDIS / Almacén 24x24','CEDIS Walmart Cuautitlán','SCOTIABANK','3020102089','032002060860629220','2025-05-07'),
  ('21','Noé','Velázquez','Velázquez','M','VEVN870304V13','VEVN870304HMCLZQ17','1987-03-04','5575037186','noe.velazquez21@personal.peoplemovil.demo','Calle Lago Chapala','80','Colonia Valle Dorado','54020','Tlalnepantla','Estado de México','Estado de México','Unión libre',1.7,'CH','Licenciatura','Beatriz Nájera Rendón (madre) - 5526232107','O-','Vigilante de piso de ventas','Walmart Satélite','HSBC','3021644154','032002173631145113','2026-06-03'),
  ('22','Yolanda','Rendón','Lozano','F','RELY881108W26','RELY881108MDFNDN24','1988-11-08','5553621033','yolanda.rendon22@personal.peoplemovil.demo','Calle Pilares','861','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Divorciado(a)',1.75,'G','Licenciatura trunca','Baltazar Macías Galindo (esposo) - 5572143747','AB+','Vigilante de piso de ventas','Walmart Universidad','BANORTE','3022822637','032002261194898063','2026-06-14'),
  ('23','Sergio','Orozco','Hinojosa','M','OOHS810824X39','OOHS810824HMCRZC31','1981-08-24','5598159747','sergio.orozco23@personal.peoplemovil.demo','Av. López Portillo','800','Colonia Fuentes de Satélite','53100','Cd. Satélite','Estado de México','Estado de México','Soltero(a)',1.81,'XG','Licenciatura trunca','Nadia Jáuregui Quintero (madre) - 5529510197','O-','Vigilante de acceso','Walmart Satélite','HSBC','3023757327','032002341216582053','2025-03-18'),
  ('24','Gilberto','Jáuregui','Lozano','M','JALG011113Y42','JALG011113HMCRGL48','2001-11-13','5512915317','gilberto.jauregui24@personal.peoplemovil.demo','Calle Lago Chapala','751','Colonia Valle Dorado','54020','Tlalnepantla','Estado de México','Estado de México','Soltero(a)',1.77,'G','Licenciatura','Adriana Zúñiga Yáñez (hermana) - 5583338071','O-','Vigilante de acceso','Walmart Satélite','HSBC','3024320109','032002459067580462','2026-01-13'),
  ('25','Leticia','Zavala','Jáuregui','F','ZAJL880311Z55','ZAJL880311MMCVLJ55','1988-03-11','5596485433','leticia.zavala25@personal.peoplemovil.demo','Av. López Portillo','293','Colonia Fuentes de Satélite','53100','Cd. Satélite','Estado de México','Estado de México','Soltero(a)',1.78,'XG','Licenciatura','Jesús Ibarra Yáñez (esposo) - 5598674504','O-','Vigilante de piso de ventas','Walmart Satélite','SCOTIABANK','3025381693','032002511402795050','2026-08-17'),
  ('26','Viridiana','Yáñez','Nájera','F','YANV770923A68','YANV770923MDFNZN62','1977-09-23','5582338150','viridiana.yanez26@personal.peoplemovil.demo','Calle Pilares','613','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.81,'CH','Técnico','Agustín Hinojosa Velázquez (hermano) - 5532921388','O-','Vigilante de piso de ventas','Walmart Universidad','BANCOPPEL','3026424479','032002687671400530','2025-09-22'),
  ('27','Heriberto','Figueroa','Espinosa','M','FIEH730514B71','FIEH730514HMCGRS79','1973-05-14','5534864932','heriberto.figueroa27@personal.peoplemovil.demo','Av. Lerdo de Tejada','511','Colonia Reforma','50070','Toluca','Estado de México','Estado de México','Unión libre',1.77,'M','Licenciatura','Nadia Nájera Macías (hermana) - 5574383227','AB+','Escolta de valores','Gobierno Edo. Méx — Oficinas Centrales','SANTANDER','3027612036','032002756743247284','2026-01-21'),
  ('28','Noé','Zavala','Rendón','M','ZARN950527C84','ZARN950527HMCVLR86','1995-05-27','5536673639','noe.zavala28@personal.peoplemovil.demo','Calle Parque Industrial','641','Colonia Cuamatla','54730','Cuautitlán Izcalli','Estado de México','Estado de México','Soltero(a)',1.74,'XG','Licenciatura trunca','Itzel Delgadillo Dávalos (hermana) - 5596631593','A+','Monitorista CCTV','CEDIS Walmart Cuautitlán','BANCOPPEL','3028633684','032002885943854522','2026-05-16'),
  ('29','Fernando','Saldaña','Saldaña','M','SASF920811D97','SASF920811HMCLDN93','1992-08-11','5558329025','fernando.saldana29@personal.peoplemovil.demo','Calle Parque Industrial','226','Colonia Cuamatla','54730','Cuautitlán Izcalli','Estado de México','Estado de México','Divorciado(a)',1.71,'M','Licenciatura trunca','Beatriz Velázquez Hinojosa (esposa) - 5572251448','A-','Vigilante de acceso','CEDIS Walmart Cuautitlán','BANORTE','3029319855','032002980561966500','2026-03-17'),
  ('30','Efraín','Carrasco','Rendón','M','CARE800922E00','CARE800922HMCRRS00','1980-09-22','5558821127','efrain.carrasco30@personal.peoplemovil.demo','Calle Lago Chapala','193','Colonia Valle Dorado','54020','Tlalnepantla','Estado de México','Estado de México','Casado(a)',1.85,'XG','Técnico','Rocío Figueroa Zúñiga (hermana) - 5518197733','A+','Supervisor de turno','Walmart Satélite','SCOTIABANK','3030799026','032003018011918452','2025-05-27')
) AS v(folio,nombres,ap,am,sexo,rfc,curp,fecha_nacimiento,telefono,correo,calle,numero_exterior,colonia,codigo_postal,delegacion_municipio,estado_provincia,estado_nacimiento,estado_civil,estatura,talla,grado_estudios,contacto_emergencia,tipo_sangre,puesto,sitio,banco,cuenta_bancaria,clabe,fecha_alta);

INSERT INTO te_empleados (tenant_id, folio, nombres, apellido_paterno, apellido_materno, sexo, rfc, curp, fecha_nacimiento, telefono, correo, calle, numero_exterior, colonia, codigo_postal, delegacion_municipio, estado_provincia, estado_nacimiento, estado_civil, estatura, talla, grado_estudios, contacto_emergencia, tipo_sangre, id_puesto_principal, id_sitio_principal, id_banco, cuenta_bancaria, clabe, regimen_pago, ciclo_pago, foto_url, fecha_alta)
SELECT '00000000-0000-0000-0000-000000000004', v.folio::int, v.nombres, v.ap, v.am, v.sexo::sexo_enum, v.rfc, v.curp, v.fecha_nacimiento::date, v.telefono, v.correo,
  v.calle, v.numero_exterior, v.colonia, v.codigo_postal, v.delegacion_municipio, v.estado_provincia, v.estado_nacimiento,
  v.estado_civil, v.estatura::numeric, v.talla, v.grado_estudios, v.contacto_emergencia, v.tipo_sangre,
  (SELECT id FROM tc_puestos WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.puesto),
  (SELECT id FROM tc_sitios WHERE tenant_id='00000000-0000-0000-0000-000000000004' AND titulo=v.sitio),
  (SELECT id FROM tc_bancos WHERE nombre=v.banco),
  v.cuenta_bancaria, v.clabe, 'Honorarios Asimilables', 'Semanal',
  'https://api.dicebear.com/9.x/personas/svg?seed=pm-t4-' || v.folio,
  v.fecha_alta::date
FROM (VALUES
  ('13','Rocío','Jáuregui','Treviño','F','JATR940315N39','JATR940315MDFRGT31','1994-03-15','5535041278','rocio.jauregui13@personal.peoplemovil.demo','Calle Pilares','931','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Divorciado(a)',1.71,'M','Técnico','Heriberto Zavala Lozano (esposo) - 5579065416','B+','Promotora / Impulsadora','La Comer Del Valle','SANTANDER','4013669110','042001370524632292','2026-07-05'),
  ('14','Nadia','Figueroa','Carrasco','F','FICN740801O42','FICN740801MDFGRC48','1974-08-01','5522704519','nadia.figueroa14@personal.peoplemovil.demo','Av. Universidad','391','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.63,'G','Licenciatura trunca','Ulises Hinojosa Delgadillo (padre) - 5599039934','O+','Promotora / Impulsadora','Walmart Universidad','BANAMEX','4014309123','042001440797789282','2025-08-07'),
  ('15','Leticia','Treviño','Palafox','F','TEPL990828P55','TEPL990828MDFRVN55','1999-08-28','5538075808','leticia.trevino15@personal.peoplemovil.demo','Av. Horacio','931','Colonia Polanco','11560','Miguel Hidalgo','Ciudad de México','Ciudad de México','Casado(a)',1.77,'XG','Licenciatura','Cuauhtémoc Espinosa Delgadillo (padre) - 5593508297','O+','Demostrador(a) de producto','Walmart Félix Cuevas','BANCOPPEL','4015265744','042001531969389162','2025-07-07'),
  ('16','Wilfrido','Zavala','Treviño','M','ZATW811121Q68','ZATW811121HDFVLT62','1981-11-21','5548536141','wilfrido.zavala16@personal.peoplemovil.demo','Av. Horacio','633','Colonia Polanco','11560','Miguel Hidalgo','Ciudad de México','Ciudad de México','Divorciado(a)',1.72,'XG','Bachillerato','Elsa Nájera Rendón (esposa) - 5524423415','B+','Demostrador(a) de producto','Chedraui Toreo','SCOTIABANK','4016250986','042001642468435499','2026-08-13'),
  ('17','Teresa','Cortés','Carrasco','F','COCT920522R71','COCT920522MDFRTS79','1992-05-22','5571872785','teresa.cortes17@personal.peoplemovil.demo','Av. Universidad','500','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Soltero(a)',1.66,'CH','Licenciatura trunca','Fernando Urbina Cortés (esposo) - 5580818310','O-','Edecán','Walmart Félix Cuevas','BANAMEX','4017691793','042001762006888143','2026-08-20'),
  ('18','Heriberto','Zavala','Figueroa','M','ZAFH920301S84','ZAFH920301HDFVLF86','1992-03-01','5562591575','heriberto.zavala18@personal.peoplemovil.demo','Av. Universidad','258','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Soltero(a)',1.57,'G','Bachillerato','Viridiana Saldaña Espinosa (hermana) - 5554951322','O+','Supervisor de piso','Chedraui Toreo','BANCOPPEL','4018260676','042001842086759568','2025-08-23'),
  ('19','Dulce','Ibarra','Saldaña','F','IASD920702T97','IASD920702MDFBRR93','1992-07-02','5543449924','dulce.ibarra19@personal.peoplemovil.demo','Calle Río Churubusco','256','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Divorciado(a)',1.69,'XG','Técnico','Sergio Orozco Rendón (hermano) - 5512194371','O+','Coordinador de activación','Walmart Félix Cuevas','BANAMEX','4019329182','042001978865685352','2025-03-10'),
  ('20','Esmeralda','Macías','Jáuregui','F','MAJE991219U00','MAJE991219MDFCSJ00','1999-12-19','5557441910','esmeralda.macias20@personal.peoplemovil.demo','Av. Universidad','15','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Unión libre',1.75,'M','Bachillerato','Cuauhtémoc Urbina Delgadillo (hermano) - 5532825434','A-','Modelo Evento Premium Femenino','Salón Diamante Polanco','BANAMEX','4020525093','042002026354166127','2026-07-13'),
  ('21','Rubén','Hinojosa','Cortés','M','HICR880317V13','HICR880317HDFNJS17','1988-03-17','5560229449','ruben.hinojosa21@personal.peoplemovil.demo','Av. Horacio','676','Colonia Polanco','11560','Miguel Hidalgo','Ciudad de México','Ciudad de México','Soltero(a)',1.81,'M','Bachillerato','Cecilia Treviño Zúñiga (esposa) - 5557737074','A+','Modelo Evento Premium Masculino','Salón Diamante Polanco','BANCOPPEL','4021589660','042002198113353680','2026-04-21'),
  ('22','Adriana','Cortés','Lozano','F','COLA770321W26','COLA770321MDFRTS24','1977-03-21','5547463204','adriana.cortes22@personal.peoplemovil.demo','Av. Universidad','64','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Unión libre',1.6,'G','Bachillerato','Fernando Carrasco Dávalos (hermano) - 5532494389','B+','Promotora / Impulsadora','Walmart Félix Cuevas','HSBC','4022766570','042002289528591606','2025-08-27'),
  ('23','Gabriela','Nájera','Ibarra','F','NAIG970803X39','NAIG970803MDFJRB31','1997-08-03','5514220299','gabriela.najera23@personal.peoplemovil.demo','Calle Pilares','182','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.55,'XG','Bachillerato','Armando Ibarra Galindo (hermano) - 5536758096','B+','Promotora / Impulsadora','Chedraui Toreo','HSBC','4023893061','042002362987406499','2025-11-21'),
  ('24','Cecilia','Delgadillo','Zavala','F','DEZC940224Y42','DEZC940224MDFLGD48','1994-02-24','5586086876','cecilia.delgadillo24@personal.peoplemovil.demo','Calle Pilares','654','Colonia Del Valle Centro','03100','Benito Juárez','Ciudad de México','Ciudad de México','Casado(a)',1.75,'M','Licenciatura','Leonardo Galindo Rendón (hermano) - 5525484722','AB+','Demostrador(a) de producto','La Comer Del Valle','BANORTE','4024101580','042002465037454465','2025-12-16'),
  ('25','Wilfrido','Zúñiga','Urbina','M','ZUUW930912Z55','ZUUW930912HDFNGR55','1993-09-12','5589357622','wilfrido.zuniga25@personal.peoplemovil.demo','Av. Universidad','360','Colonia Del Valle','03100','Benito Juárez','Ciudad de México','Ciudad de México','Divorciado(a)',1.55,'G','Técnico','Concepción Lozano Velázquez (hermana) - 5587343175','O+','Demostrador(a) de producto','Walmart Universidad','BANCOPPEL','4025693947','042002549426252463','2026-01-01'),
  ('26','Leticia','Carrasco','Quintero','F','CAQL780422A68','CAQL780422MDFRRS62','1978-04-22','5531359146','leticia.carrasco26@personal.peoplemovil.demo','Calle Río Churubusco','658','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Casado(a)',1.69,'XG','Bachillerato','Antonio Velázquez Saldaña (padre) - 5529815022','O+','Edecán','La Comer Del Valle','BANAMEX','4026364296','042002670216685486','2026-03-13'),
  ('27','Antonio','Quintero','Urbina','M','QUUA790208B71','QUUA790208HDFNTR79','1979-02-08','5569571428','antonio.quintero27@personal.peoplemovil.demo','Av. Horacio','228','Colonia Polanco','11560','Miguel Hidalgo','Ciudad de México','Ciudad de México','Divorciado(a)',1.74,'XG','Licenciatura trunca','Mireya Jáuregui Quintero (hermana) - 5593490816','B+','Supervisor de piso','Walmart Universidad','BANAMEX','4027592306','042002723607109709','2026-01-07'),
  ('28','Mireya','Carrasco','Orozco','F','CAOM861222C84','CAOM861222MDFRRS86','1986-12-22','5532263680','mireya.carrasco28@personal.peoplemovil.demo','Av. Horacio','189','Colonia Polanco','11560','Miguel Hidalgo','Ciudad de México','Ciudad de México','Unión libre',1.73,'M','Licenciatura','Heriberto Orozco Hinojosa (hermano) - 5583696064','A+','Coordinador de activación','Chedraui Toreo','SANTANDER','4028669302','042002858377033472','2026-08-08'),
  ('29','Esmeralda','Lozano','Cortés','F','LOCE840506D97','LOCE840506MDFZNC93','1984-05-06','5599944578','esmeralda.lozano29@personal.peoplemovil.demo','Calle Río Churubusco','717','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Divorciado(a)',1.68,'XG','Licenciatura','Jesús Velázquez Lozano (hermano) - 5514853558','AB+','Promotora / Impulsadora','Salón Diamante Polanco','SCOTIABANK','4029725607','042002955156592947','2025-07-08'),
  ('30','Gabriela','Saldaña','Lozano','F','SALG940625E00','SALG940625MDFLDN00','1994-06-25','5580565645','gabriela.saldana30@personal.peoplemovil.demo','Calle Río Churubusco','642','Colonia Country Club','04220','Coyoacán','Ciudad de México','Ciudad de México','Unión libre',1.72,'XG','Licenciatura','Rubén Treviño Urbina (padre) - 5557812118','B+','Modelo Evento Premium Femenino','Salón Diamante Polanco','SCOTIABANK','4030879188','042003023010046408','2025-03-16')
) AS v(folio,nombres,ap,am,sexo,rfc,curp,fecha_nacimiento,telefono,correo,calle,numero_exterior,colonia,codigo_postal,delegacion_municipio,estado_provincia,estado_nacimiento,estado_civil,estatura,talla,grado_estudios,contacto_emergencia,tipo_sangre,puesto,sitio,banco,cuenta_bancaria,clabe,fecha_alta);


INSERT INTO tr_empleado_plaza (tenant_id, empleado_id, puesto_id, porcentaje_puntualidad)
SELECT e.tenant_id, e.id, e.id_puesto_principal, 0.95
FROM te_empleados e
WHERE e.tenant_id IN ('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000004')
  AND NOT EXISTS (SELECT 1 FROM tr_empleado_plaza p WHERE p.empleado_id = e.id);

-- ============================================================================
-- Migración 019 — Acciones de reclutamiento: grupo de entrevista, firma de
-- contrato + curso de inducción, confirmación de asistencia a curso + alta
-- automática. El funnel (tr_postulacion_candidato_vacante / FunnelReclutamiento.jsx)
-- ya tenía el schema y las columnas desde la Migración 003b, pero no existía
-- ninguna función que las mueva de una etapa a la siguiente -- analizado contra
-- el video "Ciclo completo" del legado (ver NOTIFICACIONES_RECLUTAMIENTO.md):
-- en el legado estas son 3 pantallas de acción separadas (Asistencia por
-- Grupos, Firma de contratos, Cursos de inducción), cada una con su propio
-- modal "Sí/No" de confirmación por lote. Las 2 funciones intermedias también
-- son el punto donde el legado dispara sus 2 únicos correos de reclutamiento
-- (el envío en sí queda del lado del frontend/Netlify Function, estas RPCs
-- solo devuelven los datos que ese correo necesita).
-- ============================================================================

-- 1) Asistencia por Grupos: confirma ¿Asistió? + ¿Documentos completos? de un
--    grupo de entrevista completo, en lote. Avanza la postulación a
--    'entrevista_individual' solo si asistió Y trae documentos completos.
CREATE OR REPLACE FUNCTION confirmar_asistencia_grupo(
  p_grupo_cita_id uuid,
  p_candidatos jsonb  -- [{"candidato_id":"...", "asistio":true, "doc_completa":true}, ...]
) RETURNS int AS $$
DECLARE
  v_vacante uuid;
  item jsonb;
  n int := 0;
BEGIN
  SELECT vacante_publicacion_id INTO v_vacante FROM te_grupos_citas WHERE id = p_grupo_cita_id;
  IF v_vacante IS NULL THEN RAISE EXCEPTION 'grupo de cita no existe'; END IF;

  FOR item IN SELECT * FROM jsonb_array_elements(p_candidatos) LOOP
    UPDATE tr_cita_grupo_candidato
      SET asistio = (item->>'asistio')::boolean,
          doc_completa = (item->>'doc_completa')::boolean,
          confirmado_en = now()
      WHERE grupo_cita_id = p_grupo_cita_id AND candidato_id = (item->>'candidato_id')::uuid;

    UPDATE tr_postulacion_candidato_vacante
      SET asis_recepcion = (item->>'asistio')::boolean,
          doc_completa   = (item->>'doc_completa')::boolean,
          estatus_full   = CASE WHEN (item->>'asistio')::boolean AND (item->>'doc_completa')::boolean
                                 THEN 'entrevista_individual'::estado_postulacion_full_enum
                                 ELSE estatus_full END
      WHERE vacante_id = v_vacante AND candidato_id = (item->>'candidato_id')::uuid;
    n := n + 1;
  END LOOP;
  RETURN n;
END $$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION confirmar_asistencia_grupo(uuid, jsonb) TO authenticated;

-- 2) Firma de contratos: captura Resultado por candidato y, si es
--    'aceptado_curso', asigna el curso de inducción (equivalente al selector
--    de cabecera que propaga a todas las filas en el legado) y pre-inscribe
--    en tr_asistencia_curso. Devuelve los datos para el correo de
--    confirmación de curso -- uno por candidato, personalizado (confirmado
--    por captura de Outlook: "Estimado(a): <nombre>", no es un correo grupal).
CREATE OR REPLACE FUNCTION registrar_firma_contrato(
  p_candidatos uuid[],
  p_resultado resultado_postulacion_enum,
  p_curso_induccion_id uuid DEFAULT NULL
) RETURNS TABLE (
  candidato_id uuid, nombres text, apellido_paterno text, apellido_materno text,
  correo text, curso_titulo text, curso_fecha date, curso_hora time, curso_lugar text
) AS $$
DECLARE cid uuid;
BEGIN
  IF p_resultado = 'aceptado_curso' AND p_curso_induccion_id IS NULL THEN
    RAISE EXCEPTION 'Falta asignar el curso de inducción para aceptar candidatos';
  END IF;

  FOREACH cid IN ARRAY p_candidatos LOOP
    IF p_resultado = 'aceptado_curso' THEN
      UPDATE tr_postulacion_candidato_vacante
        SET resultado = p_resultado, estatus_full = 'en_curso_induccion', curso_induccion_id = p_curso_induccion_id
        WHERE tr_postulacion_candidato_vacante.candidato_id = cid
          AND estatus_full NOT IN ('en_curso_induccion','en_evento_prueba','listo_alta','promovido');

      INSERT INTO tr_asistencia_curso (tenant_id, curso_id, candidato_id)
        SELECT tenant_id, p_curso_induccion_id, cid FROM te_candidatos WHERE id = cid
        ON CONFLICT (tenant_id, curso_id, candidato_id) DO NOTHING;
    ELSE
      UPDATE tr_postulacion_candidato_vacante
        SET resultado = p_resultado, estatus_full = 'rechazado'
        WHERE tr_postulacion_candidato_vacante.candidato_id = cid;
    END IF;
  END LOOP;

  RETURN QUERY
    SELECT c.id, c.nombres, c.apellido_paterno, c.apellido_materno, c.correo,
           ci.titulo, ci.fecha, ci.hora_inicio, s.direccion
    FROM te_candidatos c
    LEFT JOIN te_cursos_induccion ci ON ci.id = p_curso_induccion_id
    LEFT JOIN tc_sitios s ON s.id = ci.sitio_id
    WHERE c.id = ANY(p_candidatos) AND p_resultado = 'aceptado_curso';
END $$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION registrar_firma_contrato(uuid[], resultado_postulacion_enum, uuid) TO authenticated;

-- 3) Cursos de inducción: confirma ¿Asistió? por candidato y, si asistió,
--    marca te_candidatos.paso_induccion y llama automáticamente a
--    promover_candidato_a_empleado() en la misma operación -- en el legado,
--    confirmar asistencia al curso es lo que dispara el alta sin botón
--    aparte (hoy en PeopleMovil ese alta era un botón manual separado en
--    Personal.jsx/AltaMasivaEmpleados.jsx). Devuelve una fila por candidato
--    con el resultado de la promoción, para armar el correo-lote a RH con el
--    PDF de altas (puede repetirse varias veces al día, una vez por cada
--    lote confirmado -- confirmado contra la bandeja de Outlook del legado).
CREATE OR REPLACE FUNCTION confirmar_asistencia_curso(
  p_curso_induccion_id uuid,
  p_candidatos jsonb  -- [{"candidato_id":"...", "asistio":true, "evento_prueba_id":null}, ...]
) RETURNS TABLE (
  candidato_id uuid, empleado_id uuid, folio int, nombres text, apellido_paterno text,
  apellido_materno text, puesto text, ok boolean, mensaje text
) AS $$
DECLARE item jsonb; cid uuid; asis boolean; evid uuid; nuevo_emp uuid;
BEGIN
  FOR item IN SELECT * FROM jsonb_array_elements(p_candidatos) LOOP
    cid  := (item->>'candidato_id')::uuid;
    asis := (item->>'asistio')::boolean;
    evid := NULLIF(item->>'evento_prueba_id','')::uuid;
    nuevo_emp := NULL;

    UPDATE tr_asistencia_curso SET asistio = asis
      WHERE curso_id = p_curso_induccion_id AND tr_asistencia_curso.candidato_id = cid;

    UPDATE tr_postulacion_candidato_vacante
      SET asis_curso_induccion = asis,
          evento_prueba_id = COALESCE(evid, evento_prueba_id),
          estatus_full = CASE WHEN asis THEN 'listo_alta'::estado_postulacion_full_enum ELSE estatus_full END
      WHERE tr_postulacion_candidato_vacante.candidato_id = cid
        AND curso_induccion_id = p_curso_induccion_id;

    IF asis THEN
      UPDATE te_candidatos SET paso_induccion = true WHERE id = cid;
      BEGIN
        nuevo_emp := promover_candidato_a_empleado(cid);
      EXCEPTION WHEN OTHERS THEN
        nuevo_emp := NULL;
      END;
    END IF;

    RETURN QUERY
      SELECT c.id, e.id, e.folio, c.nombres, c.apellido_paterno, c.apellido_materno,
             pu.titulo,
             (nuevo_emp IS NOT NULL OR NOT asis),
             CASE WHEN NOT asis THEN 'sin asistencia'
                  WHEN nuevo_emp IS NOT NULL THEN 'alta ok'
                  ELSE 'error al promover a empleado' END
      FROM te_candidatos c
      LEFT JOIN te_empleados e ON e.id = nuevo_emp
      LEFT JOIN tr_postulacion_candidato_vacante p ON p.candidato_id = c.id AND p.curso_induccion_id = p_curso_induccion_id
      LEFT JOIN te_vacantes vac ON vac.id = p.vacante_id
      LEFT JOIN tc_puestos pu ON pu.id = vac.puesto_id
      WHERE c.id = cid;
  END LOOP;
END $$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION confirmar_asistencia_curso(uuid, jsonb) TO authenticated;

-- ============================================================================
-- Migración 020 — Productos similares en Confirmación Forzada/Preasignada
-- (Escenario 12 del QA legado, ver documentacion-referencia/SCREENSHOTS_ESCENARIO12.md)
-- ============================================================================
-- Hallazgo: `te_pedidos_detalle.completar_productos_similares`,
-- `tr_producto_puesto` y `tr_productos_similares`/`tr_puestos_similares` ya
-- existían en el schema (Migración 003b y vecinas) pero NADA los leía. El
-- trigger `tg_reservacion_valida` validaba certeza/sexo contra el puesto
-- exacto del detalle, pero `obtener_certeza_puesto()` cae a
-- `tc_puestos.porcentaje_certeza_inicial` cuando el empleado no tiene esa
-- plaza -- es decir, en la práctica NO bloqueaba a un empleado de puesto
-- distinto (el problema real no era "bloquea de más", era "no bloquea nada").
--
-- Esta migración agrega la cadena de resolución que describe el QA:
-- puesto exacto del detalle -> catálogo producto->puestos aceptados
-- (tr_producto_puesto) -> si "completar_productos_similares"=SÍ ->
-- puesto similar directo (tr_puestos_similares) o producto similar ->
-- sus puestos aceptados (tr_productos_similares + tr_producto_puesto).
-- Si ninguna rama aplica, bloquea con el mensaje EXACTO observado en el
-- video legado: "El empleado no cumple con el perfil requerido".
--
-- Probado end-to-end en vivo (2026-10-08): pedido #193 "Escenario 12 -
-- Productos similares", bloqueado con similares=NO, permitido con
-- similares=SÍ, usando un empleado freelance con plaza única "Control de
-- Accesos" sobre un detalle de producto "Seguridad" -- queda como dato de
-- ejemplo en la base, no se borró.
-- ============================================================================

CREATE OR REPLACE FUNCTION puesto_aceptado_por_detalle(p_pedido_detalle_id uuid, p_puesto_empleado uuid)
RETURNS boolean AS $$
DECLARE d te_pedidos_detalle;
BEGIN
  SELECT * INTO d FROM te_pedidos_detalle WHERE id = p_pedido_detalle_id;
  IF d.id IS NULL THEN RETURN false; END IF;

  -- match exacto contra el puesto requerido por el detalle
  IF p_puesto_empleado = d.puesto_id THEN RETURN true; END IF;

  -- catálogo: puestos aceptados directos del producto del detalle (sin necesidad de "similares")
  IF d.producto_id IS NOT NULL AND EXISTS (
    SELECT 1 FROM tr_producto_puesto WHERE producto_id = d.producto_id AND puesto_id = p_puesto_empleado
  ) THEN RETURN true; END IF;

  IF NOT d.completar_productos_similares THEN RETURN false; END IF;

  -- puesto similar directo (respeta el flag bidireccional de cada fila)
  IF EXISTS (
    SELECT 1 FROM tr_puestos_similares
    WHERE (puesto_id = d.puesto_id AND puesto_similar_id = p_puesto_empleado)
       OR (puesto_similar_id = d.puesto_id AND puesto_id = p_puesto_empleado AND bidireccional)
  ) THEN RETURN true; END IF;

  -- producto similar -> sus puestos aceptados vía tr_producto_puesto
  IF d.producto_id IS NOT NULL AND EXISTS (
    SELECT 1 FROM tr_productos_similares ps
    JOIN tr_producto_puesto pp ON pp.puesto_id = p_puesto_empleado
    WHERE (ps.producto_id = d.producto_id AND ps.producto_similar_id = pp.producto_id)
       OR (ps.producto_similar_id = d.producto_id AND ps.producto_id = pp.producto_id AND ps.bidireccional)
  ) THEN RETURN true; END IF;

  RETURN false;
END $$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION tg_reservacion_valida() RETURNS trigger AS $$
DECLARE v record; v_puesto_check uuid;
BEGIN
  PERFORM verificar_limite(NEW.tenant_id,'asignacion');

  v_puesto_check := NEW.puesto_id;

  IF NEW.pedido_detalle_id IS NOT NULL THEN
    SELECT ep.puesto_id INTO v_puesto_check
    FROM tr_empleado_plaza ep
    WHERE ep.empleado_id = NEW.empleado_id AND ep.activo
      AND puesto_aceptado_por_detalle(NEW.pedido_detalle_id, ep.puesto_id)
    ORDER BY (ep.puesto_id = NEW.puesto_id) DESC
    LIMIT 1;

    IF v_puesto_check IS NULL THEN
      NEW.regla_aplicada := 'PRC_ProductosSimilares: perfil no requerido';
      RAISE EXCEPTION 'El empleado no cumple con el perfil requerido';
    END IF;
  END IF;

  SELECT * INTO v FROM valida_emp_puesto(NEW.empleado_id, v_puesto_check);
  IF NOT v.valido THEN NEW.regla_aplicada := 'PRC_ValidaEmpPuesto: '||v.motivo;
    RAISE EXCEPTION 'Empleado no califica: %', v.motivo; END IF;
  SELECT * INTO v FROM valida_no_empalme(NEW.empleado_id, NEW.puesto_id, NEW.cita_inicio, NEW.cita_fin);
  IF NOT v.valido THEN NEW.regla_aplicada := 'PRC_Noempalmereservacion: '||v.motivo;
    RAISE EXCEPTION 'Traslape: %', v.motivo; END IF;
  NEW.regla_aplicada := 'reservacion_creada_ok';
  RETURN NEW;
END $$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Catálogo: completa tr_producto_puesto desde tc_productos.id_puesto ya
-- existente (es_principal=true), para todos los tenants -- dato real de
-- catálogo, no solo fixture de prueba.
-- ----------------------------------------------------------------------------
INSERT INTO tr_producto_puesto (tenant_id, producto_id, puesto_id, es_principal)
SELECT tenant_id, id, id_puesto, true
FROM tc_productos
WHERE id_puesto IS NOT NULL
ON CONFLICT (tenant_id, producto_id, puesto_id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Catálogo: "Control de Accesos" como producto similar de "Seguridad" en el
-- tenant demo de eventos -- es el par exacto que demuestra el video del
-- Escenario 12 (empleado 58172 "Oscar Fernández Plata" con plaza única
-- Control de Accesos, aceptado en un detalle de producto Seguridad-IN solo
-- cuando "Completar con similares"=SÍ).
-- ----------------------------------------------------------------------------
INSERT INTO tr_productos_similares (tenant_id, producto_id, producto_similar_id, bidireccional)
SELECT '00000000-0000-0000-0000-000000000001', seg.id, cda.id, true
FROM tc_productos seg, tc_productos cda
WHERE seg.tenant_id = '00000000-0000-0000-0000-000000000001' AND seg.titulo = 'Seguridad' AND seg.subcategoria = 'Masculino'
  AND cda.tenant_id = '00000000-0000-0000-0000-000000000001' AND cda.titulo = 'Control de Accesos' AND cda.subcategoria = 'Masculino'
ON CONFLICT (tenant_id, producto_id, producto_similar_id) DO NOTHING;

INSERT INTO tr_productos_similares (tenant_id, producto_id, producto_similar_id, bidireccional)
SELECT '00000000-0000-0000-0000-000000000001', seg.id, cda.id, true
FROM tc_productos seg, tc_productos cda
WHERE seg.tenant_id = '00000000-0000-0000-0000-000000000001' AND seg.titulo = 'Seguridad' AND seg.subcategoria = 'Femenino'
  AND cda.tenant_id = '00000000-0000-0000-0000-000000000001' AND cda.titulo = 'Control de Accesos' AND cda.subcategoria = 'Femenino'
ON CONFLICT (tenant_id, producto_id, producto_similar_id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- Migración 021 (2026-10-08): siembra representativa de tp_duraciones_evento
-- y tp_sueldos_matriciales -- ver documentacion-referencia/
-- REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md. Grounded en datos reales del QA
-- legado (Escenario 29: Auditorio Nacional 3 días -> 100%-50%-50%) y en el
-- patrón "Fase 1 (1-4 días)/Quinto/Sexto/Séptimo día en adelante" visto en
-- producción real (Access Ocesa03_j_m.accdb). Puestos matriciales elegidos
-- porque ya tenían pago_default=0 (sin tarifa plana) y aparecen en los
-- escenarios de prueba QA reales (Productor, Stage Manager, Runner).
-- ----------------------------------------------------------------------------
UPDATE tc_puestos SET matricial = true
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
  AND id IN (
    'be86586d-e8af-4030-a461-5402c95f2cf7', -- Productor A
    'd446afb2-1a6c-4165-906f-9722f6bf7cac', -- Productor B
    '9dc60613-0b51-47b3-b81d-6306cc8a7c43', -- Productor C
    'c53cf64c-36e3-44b8-b031-b2ab671c1468', -- Stage Manager A
    'bd1abb68-fa90-4187-9eff-cc13c175c605', -- Stage Manager B
    '4f5edafb-4ec5-4772-a65c-2fa591d91003', -- Stage Manager C
    '675816cf-46bd-4f6c-8580-398dcc7b36fc', -- Runner
    'ab93943e-0967-4082-9354-cd2efe36eb9e', -- Runner con coche
    '0334a343-dd36-408c-acc4-75954501f9b4'  -- Runner sin coche
  );

INSERT INTO tp_duraciones_evento (tenant_id, tipo_duracion_id, id_tipo_complejidad, dias_desde, dias_hasta, factor_sueldo, observaciones) VALUES
('00000000-0000-0000-0000-000000000001','0356fd52-1c65-4b51-9d45-4a92dd1074f9', NULL, 1, 1, 1.000, 'Día único, tarifa completa'),
('00000000-0000-0000-0000-000000000001','279954c3-8606-40c0-815a-875e7f60991b', NULL, 1, 2, 1.000, 'Dos días, tarifa completa'),
('00000000-0000-0000-0000-000000000001','799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', NULL, 1, 3, 1.000, 'Fin de semana, tarifa completa (genérico)'),
('00000000-0000-0000-0000-000000000001','e83e528a-b5d9-4434-a880-3d57ba09324e', NULL, 1, 4, 1.000, 'Días 1-4, tarifa completa (equivalente a "Fase 1" legado)'),
('00000000-0000-0000-0000-000000000001','e83e528a-b5d9-4434-a880-3d57ba09324e', NULL, 5, 5, 0.750, 'Quinto día (equivalente a "Fase 2" legado)'),
('00000000-0000-0000-0000-000000000001','e83e528a-b5d9-4434-a880-3d57ba09324e', NULL, 6, 6, 0.600, 'Sexto día (equivalente a "Fase 3" legado)'),
('00000000-0000-0000-0000-000000000001','e83e528a-b5d9-4434-a880-3d57ba09324e', NULL, 7, 7, 0.500, 'Séptimo día en adelante (equivalente a "Fase 4" legado)'),
('00000000-0000-0000-0000-000000000001','5b77ed5e-2433-4299-a4e3-121b9f686fba', NULL, 1, 4, 1.000, 'Días 1-4, tarifa completa'),
('00000000-0000-0000-0000-000000000001','5b77ed5e-2433-4299-a4e3-121b9f686fba', NULL, 5, 5, 0.750, 'Quinto día'),
('00000000-0000-0000-0000-000000000001','5b77ed5e-2433-4299-a4e3-121b9f686fba', NULL, 6, 6, 0.600, 'Sexto día'),
('00000000-0000-0000-0000-000000000001','5b77ed5e-2433-4299-a4e3-121b9f686fba', NULL, 7, 15, 0.500, 'Séptimo día en adelante, sostenido hasta fin de quincena'),
('00000000-0000-0000-0000-000000000001','44045ae2-762c-4791-a279-eb5dea6f5cc6', NULL, 1, 4, 1.000, 'Días 1-4, tarifa completa'),
('00000000-0000-0000-0000-000000000001','44045ae2-762c-4791-a279-eb5dea6f5cc6', NULL, 5, 5, 0.750, 'Quinto día'),
('00000000-0000-0000-0000-000000000001','44045ae2-762c-4791-a279-eb5dea6f5cc6', NULL, 6, 6, 0.600, 'Sexto día'),
('00000000-0000-0000-0000-000000000001','44045ae2-762c-4791-a279-eb5dea6f5cc6', NULL, 7, 31, 0.500, 'Séptimo día en adelante, sostenido hasta fin de mes'),
('00000000-0000-0000-0000-000000000001','799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 'b81657d7-41b5-46bb-a693-7831e02cfc98', 1, 1, 1.000, 'Auditorio Nacional día 1: 100% (Escenario 29 QA real)'),
('00000000-0000-0000-0000-000000000001','799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 'b81657d7-41b5-46bb-a693-7831e02cfc98', 2, 3, 0.500, 'Auditorio Nacional días 2-3: 50% (Escenario 29 QA real)');

INSERT INTO tp_sueldos_matriciales (tenant_id, puesto_id, tipo_complejidad_id, tipo_duracion_id, turnos, sueldo_base, factor, vigente_desde) VALUES
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1800.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1800.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1800.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1710.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 1620.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 1530.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1330.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 1260.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 1190.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1200.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1200.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1200.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1140.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 1080.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','9dc60613-0b51-47b3-b81d-6306cc8a7c43', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 1020.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1600.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1600.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1600.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1520.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 1440.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','c53cf64c-36e3-44b8-b031-b2ab671c1468', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 1360.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1300.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1300.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1300.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1235.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 1170.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','bd1abb68-fa90-4187-9eff-cc13c175c605', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 1105.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 1100.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 1100.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 1100.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 1045.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 990.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','4f5edafb-4ec5-4772-a65c-2fa591d91003', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 935.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 450.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 450.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 450.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 427.50, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 405.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 382.50, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 650.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 650.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 650.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 617.50, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 585.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 552.50, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, '0356fd52-1c65-4b51-9d45-4a92dd1074f9', 1, 400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, '279954c3-8606-40c0-815a-875e7f60991b', 1, 400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, '799f7cc7-2bf3-43a9-bc07-ec02ca20df7c', 1, 400.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, 'e83e528a-b5d9-4434-a880-3d57ba09324e', 1, 380.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, '5b77ed5e-2433-4299-a4e3-121b9f686fba', 1, 360.00, 1.000, CURRENT_DATE),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, '44045ae2-762c-4791-a279-eb5dea6f5cc6', 1, 340.00, 1.000, CURRENT_DATE);

-- ----------------------------------------------------------------------------
-- Migración 022 (2026-10-09): corrige la Migración 021 con datos REALES del
-- legado ("Catalogos Sueldos Matriciales.xlsx": hojas Puestos, Sueldos
-- Matriciales, Tipos de Complejidad en Eventos, Sueldos Matriciales Duracion,
-- Sueldos Mat Duracion Detalle) en vez de los valores representativos
-- inventados. Ver documentacion-referencia/REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md.
-- También corrige un gap real en cancelacion_automatica_preasignados(): la
-- regla de negocio real dice "Este proceso no aplica para las unidades de
-- negocio de Producción y PRG" (reglas de negocio_cancelaciones.docx) y la
-- función no tenía esa excepción.
-- ----------------------------------------------------------------------------
ALTER TABLE tp_sueldos_matriciales
  ADD COLUMN IF NOT EXISTS fase_evento_id  uuid REFERENCES tc_fases_evento(id),
  ADD COLUMN IF NOT EXISTS fase_evento_str text;

ALTER TABLE tp_duraciones_evento
  ADD COLUMN IF NOT EXISTS prorrateado      boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS divisor_prorrateo int;

DELETE FROM tp_sueldos_matriciales;
DELETE FROM tp_duraciones_evento;

UPDATE tc_tipos_complejidad SET clave='teatro_metropolitan', titulo='Teatro Metropolitan, Plaza Condesa y Plazas Similares' WHERE id='632d6ec3-0cac-4b57-a8bb-1049860ff05d';
UPDATE tc_tipos_complejidad SET clave='auditorio_nacional',  titulo='Auditorio Nacional, Auditorio Guadalajara y Plazas Similares' WHERE id='b81657d7-41b5-46bb-a693-7831e02cfc98';
UPDATE tc_tipos_complejidad SET clave='palacio_deportes',    titulo='Palacio de los Deportes, Arena VFG y Plazas Similares' WHERE id='e4e32332-5b79-4756-b5cf-3ba4c9d8f909';
UPDATE tc_tipos_complejidad SET clave='foro_sol_50k',        titulo='Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares' WHERE id='d7cd0fe7-8dba-452d-be8e-281c83b51f2f';
UPDATE tc_tipos_complejidad SET clave='estadios_extranjero', titulo='Estadios Foro y Plazas Similares en el Extranjero' WHERE id='ec81d9ea-1ea7-4319-9422-93f2008c35ab';
UPDATE tc_tipos_complejidad SET clave='festivales_50k_mas',  titulo='Festivales de mas de 50,000 asistentes' WHERE id='3e8553a0-82db-4d49-b269-39fdc507f7b5';

DELETE FROM tp_sueldos_matriciales WHERE tipo_duracion_id IN (SELECT id FROM tc_tipos_duracion_evento);
DELETE FROM tp_duraciones_evento WHERE tipo_duracion_id IN (SELECT id FROM tc_tipos_duracion_evento);
DELETE FROM tc_tipos_duracion_evento;

INSERT INTO tc_tipos_duracion_evento (id, tenant_id, clave, titulo, dias_minimos, dias_maximos) VALUES
('a1a1a1a1-0001-4001-8001-000000000001','00000000-0000-0000-0000-000000000001','shows_sueltos','Shows Sueltos',1,3),
('a1a1a1a1-0001-4001-8001-000000000002','00000000-0000-0000-0000-000000000001','tarifa_semana','Tarifa por Semana',4,29),
('a1a1a1a1-0001-4001-8001-000000000003','00000000-0000-0000-0000-000000000001','tarifa_mes','Tarifa por Mes',30,365);

INSERT INTO tp_duraciones_evento (tenant_id, tipo_duracion_id, id_tipo_complejidad, dias_desde, dias_hasta, factor_sueldo, prorrateado, divisor_prorrateo, observaciones) VALUES
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000001', NULL, 1, 1, 1.000, false, NULL, 'Shows Sueltos, día 1: 100%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000001', NULL, 2, 2, 0.500, false, NULL, 'Shows Sueltos, día 2: 50%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000001', NULL, 3, 3, 0.500, false, NULL, 'Shows Sueltos, día 3: 50%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000002', NULL, 4, 7, 1.000, false, NULL, 'Tarifa por Semana, días 4-7: 100%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000002', NULL, 8, 14, 0.500, false, NULL, 'Tarifa por Semana, días 8-14: 50%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000002', NULL, 15, 21, 0.500, false, NULL, 'Tarifa por Semana, días 15-21: 50%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000002', NULL, 22, 29, 0.500, false, NULL, 'Tarifa por Semana, días 22-29: 50%'),
('00000000-0000-0000-0000-000000000001','a1a1a1a1-0001-4001-8001-000000000003', NULL, 30, 365, 1.000, true, 30, 'Tarifa por Mes: prorrateado, sueldo_base / 30 × días del periodo (no usa factor_sueldo)');

INSERT INTO tp_sueldos_matriciales (tenant_id, puesto_id, tipo_complejidad_id, tipo_duracion_id, fase_evento_id, fase_evento_str, turnos, sueldo_base, factor, vigente_desde) VALUES
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7','b81657d7-41b5-46bb-a693-7831e02cfc98','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 30200.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7','e4e32332-5b79-4756-b5cf-3ba4c9d8f909','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 45500.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7','d7cd0fe7-8dba-452d-be8e-281c83b51f2f','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 91800.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7','ec81d9ea-1ea7-4319-9422-93f2008c35ab','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 102000.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','be86586d-e8af-4030-a461-5402c95f2cf7','3e8553a0-82db-4d49-b269-39fdc507f7b5','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 121000.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac','632d6ec3-0cac-4b57-a8bb-1049860ff05d','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 9700.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac','b81657d7-41b5-46bb-a693-7831e02cfc98','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 14500.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac','e4e32332-5b79-4756-b5cf-3ba4c9d8f909','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 21800.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','d446afb2-1a6c-4165-906f-9722f6bf7cac','d7cd0fe7-8dba-452d-be8e-281c83b51f2f','a1a1a1a1-0001-4001-8001-000000000001', NULL, NULL, 1, 44000.00, 1.000, '2018-01-01'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 1 Runner (Día 1)', 1, 1400.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 2 Runner (Día 2)', 1, 2800.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 3 Runner (Día 3)', 1, 4200.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 4 Runner (Día 4)', 1, 5600.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 5 Runner (Día 5)', 1, 6650.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 6 Runner (Día 6)', 1, 7350.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 7 Runner (Día 7)', 1, 7700.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 8 Runner (Día 8)', 1, 8048.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 9 Runner (Día 9)', 1, 8397.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 10 Runner (Día 10)', 1, 8750.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 11 Runner (Día 11)', 1, 9097.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 12 Runner (Día 12)', 1, 9444.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 13 Runner (Día 13)', 1, 9802.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 14 Runner (Día 14)', 1, 10150.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 15 Runner (Día 15)', 1, 10500.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 16 Runner (Día 16)', 1, 10848.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 17 Runner (Día 17)', 1, 11526.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 18 Runner (Día 18)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 19 Runner (Día 19)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 20 Runner (Día 20)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 21 Runner (Día 21)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 22 Runner (Día 22)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 23 Runner (Día 23)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 24 Runner (Día 24)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 25 Runner (Día 25)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 26 Runner (Día 26)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 27 Runner (Día 27)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 28 Runner (Día 28)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 29 Runner (Día 29)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','675816cf-46bd-4f6c-8580-398dcc7b36fc', NULL, NULL, NULL, 'Fase 30 Runner (Día 30)', 1, 12204.00, 1.000, '2018-02-12'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, NULL, 'Fase 1 (de 1 a 4 días)', 1, 1300.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, NULL, 'Fase 2 (Quinto Día)', 1, 975.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, NULL, 'Fase 3 (Sexto Día)', 1, 650.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, NULL, 'Fase 4 (Septimo Día en adelante)', 1, 325.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, '9a97d694-d449-4e4b-acdd-c53814003604', NULL, 1, 1300.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, '49cc39bc-565f-4a38-b0b5-c56fbafe8a93', NULL, 1, 865.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, 'e56ed52e-d62d-457c-a402-7be8d15796cc', NULL, 1, 865.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','ab93943e-0967-4082-9354-cd2efe36eb9e', NULL, NULL, 'bfdba95a-f3d4-45ae-b6b8-af4be2552fef', NULL, 1, 865.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, NULL, 'Fase 1 (de 1 a 4 días)', 1, 865.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, NULL, 'Fase 2 (Quinto Día)', 1, 650.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, NULL, 'Fase 3 (Sexto Día)', 1, 435.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, NULL, 'Fase 4 (Septimo Día en adelante)', 1, 220.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, '9a97d694-d449-4e4b-acdd-c53814003604', NULL, 1, 865.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, '49cc39bc-565f-4a38-b0b5-c56fbafe8a93', NULL, 1, 650.00, 1.000, '2008-08-22'),
('00000000-0000-0000-0000-000000000001','0334a343-dd36-408c-acc4-75954501f9b4', NULL, NULL, 'e56ed52e-d62d-457c-a402-7be8d15796cc', NULL, 1, 650.00, 1.000, '2008-08-22');

CREATE OR REPLACE FUNCTION cancelacion_automatica_preasignados()
RETURNS int AS $$
DECLARE n int := 0; p tp_parametros_globales;
BEGIN
  FOR p IN SELECT * FROM tp_parametros_globales LOOP
    WITH cancelaciones AS (
      UPDATE te_reservaciones r SET estado='cancelado', regla_aplicada='PRC_CancelacionAutomaticaPreasignados'
      WHERE r.tenant_id=p.tenant_id AND r.estado='confirmado_opcional'
        AND (r.cita_inicio - now()) < (p.horas_lookahead_autocancel||' hours')::interval
        AND (now() - r.creado_en) > (p.horas_gracia_confirmacion||' hours')::interval
        AND NOT EXISTS (
          SELECT 1 FROM tc_puestos pu
          JOIN tc_unidades_negocio un ON un.id = pu.id_unidad_negocio
          WHERE pu.id = r.puesto_id AND un.titulo IN ('Produccion','Producción','PRG')
        )
      RETURNING r.id
    ) SELECT n + count(*) INTO n FROM cancelaciones;
  END LOOP;
  RETURN n;
END $$ LANGUAGE plpgsql;

-- ============================================================================
-- Migración 023 -- Confirmar/Cancelar reservación desde el portal freelance
-- (pantalla "Mis eventos", equivalente a "Eventos Por Confirmar" / "Eventos
-- Confirmados" de Sistema Integra legado -- ver captura analizada 2026-10-09).
-- Hasta ahora v_agenda_freelance era de solo lectura: no existía ningún RPC
-- para que el propio freelance confirmara un "preasignado" o cancelara su
-- participación -- la única vía de escritura era inscribirme_a_publicacion().
-- Aplicada a la base real vía apply_migration.
-- ============================================================================

-- 1. v_agenda_freelance: agrega el detalle completo que pide la pantalla
--    (lugar de cita, dirección, indicaciones, turnos, folio, y si el pedido
--    permite cancelar confirmaciones -- te_pedidos_detalle.permitir_cancelar_
--    confirmaciones, columna que ya existía pero nada freelance-facing la leía).
--    DROP+CREATE (no CREATE OR REPLACE) porque se reordenan columnas.
DROP VIEW IF EXISTS v_agenda_freelance;
CREATE VIEW v_agenda_freelance AS
SELECT
  r.id, r.empleado_id, r.pedido_id, r.pedido_detalle_id, r.puesto_id,
  r.estado, r.estado_asistencia, r.cita_inicio, r.cita_fin, r.duracion_en_turnos,
  p.folio AS pedido_folio, p.titulo AS pedido_titulo,
  s.titulo AS sitio, pu.titulo AS puesto, r.tenant_id,
  CASE WHEN pd.lugar_otro THEN pd.lugar_otro_descripcion ELSE lc.titulo END AS lugar_cita,
  COALESCE(
    CASE WHEN pd.lugar_otro THEN NULL ELSE lc.direccion END,
    s.direccion
  ) AS direccion_cita,
  pd.indicaciones_especiales,
  COALESCE(pd.permitir_cancelar_confirmaciones, true) AS permitir_cancelar_confirmaciones
FROM te_reservaciones r
JOIN te_pedidos p ON p.id = r.pedido_id
LEFT JOIN tc_sitios s ON s.id = r.sitio_id
LEFT JOIN tc_puestos pu ON pu.id = r.puesto_id
LEFT JOIN te_pedidos_detalle pd ON pd.id = r.pedido_detalle_id
LEFT JOIN tc_lugares_cita lc ON lc.id = pd.lugar_cita_id
WHERE r.empleado_id = mi_empleado_id();

GRANT SELECT ON v_agenda_freelance TO anon, authenticated;

-- 2. confirmar_mi_reservacion -- pasa una reservación "preasignado" (la armó
--    el admin en Preasignación, o quedó así por el motor de asignación) a
--    "confirmado_voluntario". Solo el dueño de la reservación puede llamarla.
CREATE OR REPLACE FUNCTION confirmar_mi_reservacion(p_reservacion uuid)
RETURNS void AS $$
DECLARE r te_reservaciones; emp uuid;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado.'; END IF;
  SELECT * INTO r FROM te_reservaciones WHERE id = p_reservacion AND tenant_id = current_tenant_id();
  IF r.id IS NULL THEN RAISE EXCEPTION 'Reservación no existe.'; END IF;
  IF r.empleado_id <> emp THEN RAISE EXCEPTION 'Esta reservación no te pertenece.'; END IF;
  IF r.estado <> 'preasignado' THEN
    RAISE EXCEPTION 'Solo se puede confirmar una reservación preasignada (estado actual: %).', r.estado;
  END IF;

  UPDATE te_reservaciones
    SET estado = 'confirmado_voluntario', modificado_en = now(), modificado_por = current_user_id()
    WHERE id = p_reservacion;

  INSERT INTO te_reservacion_bitacora (tenant_id, reservacion_id, actor_user_id, accion, estado_antes, estado_despues, regla_aplicada)
    VALUES (r.tenant_id, r.id, current_user_id(), 'confirmar', r.estado, 'confirmado_voluntario', 'ConfirmacionFreelancePortal');
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION confirmar_mi_reservacion(uuid) TO authenticated;

-- 3. cancelar_mi_reservacion -- el freelance desiste de un "preasignado" (sin
--    restricción, nunca llegó a confirmar nada) o cancela algo que ya había
--    confirmado (bloqueado si el pedido_detalle tiene
--    permitir_cancelar_confirmaciones = false). NO aplica penalización ni
--    reglas de "horas antes de cancelar" todavía -- ver nota de pendiente en
--    CLAUDE.md §11: el propio diseño original (captura "Sistema Integra")
--    deja abierto si debe haber penalización y lista de espera; no se inventa
--    aquí, queda como deuda técnica documentada.
CREATE OR REPLACE FUNCTION cancelar_mi_reservacion(p_reservacion uuid)
RETURNS void AS $$
DECLARE r te_reservaciones; emp uuid; permitido boolean;
BEGIN
  emp := mi_empleado_id();
  IF emp IS NULL THEN RAISE EXCEPTION 'Sesión sin empleado ligado.'; END IF;
  SELECT * INTO r FROM te_reservaciones WHERE id = p_reservacion AND tenant_id = current_tenant_id();
  IF r.id IS NULL THEN RAISE EXCEPTION 'Reservación no existe.'; END IF;
  IF r.empleado_id <> emp THEN RAISE EXCEPTION 'Esta reservación no te pertenece.'; END IF;
  IF r.estado NOT IN ('preasignado','confirmado_voluntario','confirmado_opcional') THEN
    RAISE EXCEPTION 'Esta reservación ya no se puede cancelar (estado actual: %).', r.estado;
  END IF;

  IF r.estado IN ('confirmado_voluntario','confirmado_opcional') THEN
    SELECT COALESCE(pd.permitir_cancelar_confirmaciones, true) INTO permitido
      FROM te_pedidos_detalle pd WHERE pd.id = r.pedido_detalle_id;
    IF NOT COALESCE(permitido, true) THEN
      RAISE EXCEPTION 'Este evento ya no permite cancelar confirmaciones.';
    END IF;
  END IF;

  UPDATE te_reservaciones
    SET estado = 'cancelado', regla_aplicada = 'CancelacionVoluntariaFreelance',
        modificado_en = now(), modificado_por = current_user_id()
    WHERE id = p_reservacion;

  INSERT INTO te_reservacion_bitacora (tenant_id, reservacion_id, actor_user_id, accion, estado_antes, estado_despues, regla_aplicada)
    VALUES (r.tenant_id, r.id, current_user_id(), 'cancelar', r.estado, 'cancelado', 'CancelacionVoluntariaFreelance');
END $$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION cancelar_mi_reservacion(uuid) TO authenticated;

-- ============================================================================
-- Migración 024 — Vacaciones, Capacitación, Evaluaciones y Beneficios
-- (2026-10-09, pedido explícito del usuario tras revisar el expediente de
-- empleado de IRP/RANNIX): el legado OCESA (Lobo) NO tenía estos módulos —
-- "o cesa no les daba vacaciones" — pero el propio usuario pidió agregarlos
-- de cualquier forma porque el proyecto debe alinearse a las reformas
-- laborales mexicanas recientes (régimen de vacaciones dignas, LFT Art. 76
-- reformado en diciembre 2022 / vigente 2023). A diferencia del resto del
-- esquema, esto NO viene del legado — es una decisión deliberada documentada
-- aquí y en CLAUDE.md D14, no una invención silenciosa.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Vacaciones — función de días por ley (LFT Art. 76, reforma vigente 2023)
--    1°=12, 2°=14, 3°=16, 4°=18, 5°-9°=20, y +2 días cada 5 años a partir del
--    año 10 (10°-14°=22, 15°-19°=24, 20°-24°=26, 25°-29°=28, 30°+=30, ...).
--    El "año laboral" en sí NO se guarda — se deriva de te_empleados.fecha_alta
--    en el cliente (evita duplicar un dato derivable); solo se persisten los
--    períodos efectivamente tomados.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dias_vacaciones_lft(p_anio_laboral int)
RETURNS numeric AS $$
BEGIN
  IF p_anio_laboral IS NULL OR p_anio_laboral <= 0 THEN RETURN 0;
  ELSIF p_anio_laboral = 1 THEN RETURN 12;
  ELSIF p_anio_laboral = 2 THEN RETURN 14;
  ELSIF p_anio_laboral = 3 THEN RETURN 16;
  ELSIF p_anio_laboral = 4 THEN RETURN 18;
  ELSIF p_anio_laboral BETWEEN 5 AND 9 THEN RETURN 20;
  ELSE RETURN 20 + 2 * CEIL((p_anio_laboral - 9)::numeric / 5);
  END IF;
END $$ LANGUAGE plpgsql IMMUTABLE;

CREATE TABLE IF NOT EXISTS te_vacaciones_periodos (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id       uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  anio_laboral      int NOT NULL CHECK (anio_laboral > 0),
  fecha_inicio      date NOT NULL,
  fecha_fin         date NOT NULL,
  dias              numeric(5,2) NOT NULL CHECK (dias > 0),
  prima_vacacional  numeric(12,2) NOT NULL DEFAULT 0,   -- LFT Art. 80: mínimo 25% del salario de esos días
  autorizado_por    uuid REFERENCES te_usuarios(id),
  estado            text NOT NULL DEFAULT 'tomada' CHECK (estado IN ('tomada','autorizada','cancelada')),
  observaciones     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid,
  CHECK (fecha_fin >= fecha_inicio)
);
CREATE INDEX IF NOT EXISTS ix_vacper_emp ON te_vacaciones_periodos(tenant_id, empleado_id, anio_laboral);
DROP TRIGGER IF EXISTS tg_aud_vacper ON te_vacaciones_periodos;
CREATE TRIGGER tg_aud_vacper BEFORE INSERT OR UPDATE ON te_vacaciones_periodos FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. Capacitación — distinta del curso de inducción pre-contratación
--    (te_cursos_induccion/tr_asistencia_curso, ligado a candidato_id): esta
--    es capacitación continua del empleado YA activo.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_capacitaciones_empleado (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id       uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  titulo            text NOT NULL,
  institucion       text,
  tipo              text NOT NULL DEFAULT 'interna' CHECK (tipo IN ('interna','externa','certificacion')),
  horas             numeric(6,1),
  fecha_inicio      date NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin         date,
  vigencia_hasta    date,
  constancia_url    text,
  observaciones     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_capemp_emp ON te_capacitaciones_empleado(tenant_id, empleado_id);
DROP TRIGGER IF EXISTS tg_aud_capemp ON te_capacitaciones_empleado;
CREATE TRIGGER tg_aud_capemp BEFORE INSERT OR UPDATE ON te_capacitaciones_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 3. Evaluaciones de desempeño
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_evaluaciones_empleado (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id       uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  periodo           text NOT NULL,                 -- libre: "2026-T1", "Anual 2026"
  fecha_evaluacion  date NOT NULL DEFAULT CURRENT_DATE,
  evaluador_id      uuid REFERENCES te_usuarios(id),
  calificacion      numeric(4,1) CHECK (calificacion BETWEEN 0 AND 10),
  fortalezas        text,
  areas_oportunidad text,
  comentarios       text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_evalemp_emp ON te_evaluaciones_empleado(tenant_id, empleado_id);
DROP TRIGGER IF EXISTS tg_aud_evalemp ON te_evaluaciones_empleado;
CREATE TRIGGER tg_aud_evalemp BEFORE INSERT OR UPDATE ON te_evaluaciones_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 4. Beneficios y prestaciones (catálogo por tenant + asignación por empleado)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tc_tipos_beneficio (
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
DROP TRIGGER IF EXISTS tg_aud_tbenef ON tc_tipos_beneficio;
CREATE TRIGGER tg_aud_tbenef BEFORE INSERT OR UPDATE ON tc_tipos_beneficio FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

CREATE TABLE IF NOT EXISTS te_beneficios_empleado (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  empleado_id       uuid NOT NULL REFERENCES te_empleados(id) ON DELETE CASCADE,
  tipo_beneficio_id uuid NOT NULL REFERENCES tc_tipos_beneficio(id),
  fecha_inicio      date NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin         date,
  monto             numeric(12,2),
  activo            boolean NOT NULL DEFAULT true,
  observaciones     text,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_benemp_emp ON te_beneficios_empleado(tenant_id, empleado_id);
DROP TRIGGER IF EXISTS tg_aud_benemp ON te_beneficios_empleado;
CREATE TRIGGER tg_aud_benemp BEFORE INSERT OR UPDATE ON te_beneficios_empleado FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- Catálogo base de prestaciones comunes en México, por tenant (ajustable por el usuario después)
INSERT INTO tc_tipos_beneficio (tenant_id, clave, titulo, descripcion)
SELECT t.id, b.clave, b.titulo, b.descripcion
FROM te_tenants t
CROSS JOIN (VALUES
  ('gmm',        'Seguro de gastos médicos mayores', 'Cobertura médica privada adicional al IMSS'),
  ('vida',       'Seguro de vida',                    'Cobertura por fallecimiento o invalidez'),
  ('despensa',   'Vales de despensa',                 'Prestación mensual en vales o monedero electrónico'),
  ('ahorro',     'Fondo de ahorro',                    'Aportación empresa-empleado, retirable según política'),
  ('ptu',        'Reparto de utilidades (PTU)',        'Pago anual conforme a LFT Art. 117-131'),
  ('prima_dom',  'Prima dominical',                    'LFT Art. 71: 25% adicional por trabajar en domingo')
) AS b(clave, titulo, descripcion)
ON CONFLICT (tenant_id, clave) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. RLS — mismo patrón que el resto del esquema (tenant_id = current_tenant_id())
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_vacaciones_periodos','te_capacitaciones_empleado','te_evaluaciones_empleado','tc_tipos_beneficio','te_beneficios_empleado']
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_sel ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_ins ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_upd ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_del ON %1$s', t);
    EXECUTE format('CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_ins ON %1$s FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_upd ON %1$s FOR UPDATE USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_del ON %1$s FOR DELETE USING (tenant_id = current_tenant_id())', t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 6. Storage — bucket privado para expediente (fotos + documentos con datos
--    personales/identificación: INE, CURP, comprobante de domicilio). Privado
--    a propósito (no público): se sirve con signed URLs de corta duración
--    desde el frontend, mismo criterio de cuidado que ya aplicamos a los
--    datos biométricos del checador.
--    Convención de ruta: {tenant_id}/{empleado_id}/{archivo}
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('expedientes', 'expedientes', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS p_storage_expedientes_sel ON storage.objects;
DROP POLICY IF EXISTS p_storage_expedientes_ins ON storage.objects;
DROP POLICY IF EXISTS p_storage_expedientes_upd ON storage.objects;
DROP POLICY IF EXISTS p_storage_expedientes_del ON storage.objects;

CREATE POLICY p_storage_expedientes_sel ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'expedientes' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_expedientes_ins ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'expedientes' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_expedientes_upd ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'expedientes' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_expedientes_del ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'expedientes' AND (storage.foldername(name))[1] = current_tenant_id()::text);

-- ============================================================================
-- Migración 025 — Resolución segura de tenant por sesión (current_tenant_id)
-- ============================================================================
-- Problema encontrado probando en vivo las cuentas demo multi-vertical de la
-- Migración 017 (CLAUDE.md §15): current_tenant_id() resolvía SIEMPRE al
-- tenant fijo que manda el cliente en el header `x-tenant-id` (ver
-- src/lib/supabase.js, DEMO_TENANT_ID hardcodeado para TODO usuario, sin
-- importar su sesión real). Confirmado en vivo: login exitoso con
-- admin.construccion01@peoplemovil.demo -> "Tu cuenta no tiene un usuario
-- interno activo" (mi_usuario() busca tenant_id = current_tenant_id() =
-- tenant 1, pero la fila real de este usuario vive en tenant_id = tenant
-- Construcción). Dos problemas, no solo uno:
--   1. Correctitud: los 6 logins multi-tenant de la Migración 017 no podían
--      funcionar nunca con el header fijo.
--   2. Seguridad: cualquier request autenticado podía mandar CUALQUIER valor
--      de x-tenant-id y leer/escribir datos de un tenant ajeno, porque el
--      header nunca se validaba contra la membresía real del usuario (RLS
--      confiaba en current_tenant_id(), que confiaba ciegamente en el
--      header).
-- Fix: current_tenant_id() ahora resuelve el tenant de una sesión autenticada
-- a partir de la membresía real del usuario (te_usuarios.tenant_id para
-- personal interno, te_empleados.tenant_id para freelance), vía su
-- auth_user_id (current_user_id(), ya corregido en la Migración 013) --
-- ambas columnas son UNIQUE a nivel global, así que no hace falta (ni se
-- puede, sería circular) filtrar por tenant_id para encontrarlas. El header
-- x-tenant-id queda SOLO como fallback para accesos anónimos (portal público
-- de vacantes, demo sin login) -- nunca se usa si hay una sesión autenticada.
-- SECURITY DEFINER + search_path fijo: el SELECT interno a te_usuarios/
-- te_empleados debe correr sin pasar por las políticas RLS de esas tablas
-- (que a su vez dependen de current_tenant_id() -- sería recursivo/circular
-- si corriera como invoker).
-- Aplicada a la base real vía `apply_migration` (2026-10-09) y probada en
-- vivo en el navegador con 5 cuentas: admin.demo01 (tenant eventos, sigue
-- viendo sus 11 empleados -- sin regresión), admin.construccion01 (antes
-- mostraba "cuenta no vinculada", ahora dashboard con sus 3 sitios/30
-- empleados reales), admin.seguridad01 (5 sitios/30 empleados reales), y
-- freelance.construccion01 (portal freelance, camino te_empleados -- perfil
-- correcto: Jorge Hernández, folio 1, Albañil).
-- ============================================================================

CREATE OR REPLACE FUNCTION public.current_tenant_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE
 SECURITY DEFINER
 SET search_path = public, pg_temp
AS $function$
DECLARE
  h_tenant text;
  v_user   uuid;
  v_tenant uuid;
BEGIN
  -- 1. Contexto de servidor (SET LOCAL app.current_tenant desde una función
  --    interna o un script administrativo) -- máxima prioridad, explícito.
  v_tenant := NULLIF(current_setting('app.current_tenant', true), '')::uuid;
  IF v_tenant IS NOT NULL THEN
    RETURN v_tenant;
  END IF;

  -- 2. Sesión autenticada: el tenant real es el de la membresía del usuario,
  --    nunca el que mande el cliente.
  v_user := current_user_id();
  IF v_user IS NOT NULL THEN
    SELECT tenant_id INTO v_tenant FROM te_usuarios WHERE auth_user_id = v_user LIMIT 1;
    IF v_tenant IS NOT NULL THEN
      RETURN v_tenant;
    END IF;

    SELECT tenant_id INTO v_tenant FROM te_empleados WHERE auth_user_id = v_user LIMIT 1;
    IF v_tenant IS NOT NULL THEN
      RETURN v_tenant;
    END IF;
  END IF;

  -- 3. Sin sesión autenticada (anon) o autenticado pero sin cuenta ligada
  --    todavía: único caso donde se confía en el header, igual que antes.
  BEGIN
    h_tenant := current_setting('request.headers', true)::json->>'x-tenant-id';
  EXCEPTION WHEN OTHERS THEN
    h_tenant := NULL;
  END;
  RETURN NULLIF(h_tenant, '')::uuid;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END $function$;

-- ============================================================================
-- Migración 026 -- Fotos reales de personal en vez del ícono DiceBear (2026-10-09,
-- pedido explícito del usuario: usar las 60 fotografías tipo headshot provistas
-- en doc/fotos en vez del avatar sintético de la Migración 017/018 (D13). Se
-- repiten a propósito (60 fotos para ~165 empleados reales en la base) -- el
-- usuario confirmó que repetir no importa, lo que importa es "esa forma"
-- (headshot de oficina). Fotos copiadas y renumeradas a
-- peoplemovil-app/public/fotos-demo/foto-01.png..foto-60.png y servidas desde
-- el sitio en vivo (mismo patrón que las URLs públicas de DiceBear que
-- reemplazan: foto_url es una URL http(s) completa, sin pasar por el bucket
-- privado "expedientes" de la Migración 024 -- ver src/lib/storage.js,
-- resolverUrlArchivo ya soporta ambos casos). Asignación round-robin
-- determinista por (tenant_id, folio), no aleatoria, para que sea reproducible.
-- ============================================================================
WITH numerados AS (
  SELECT id, row_number() OVER (ORDER BY tenant_id, folio) AS rn
  FROM te_empleados
)
UPDATE te_empleados e
SET foto_url = 'https://peoplemovil00.netlify.app/fotos-demo/foto-'
  || lpad((((n.rn - 1) % 60) + 1)::text, 2, '0') || '.png'
FROM numerados n
WHERE n.id = e.id;

-- ============================================================================
-- Migración 027 -- Backlog de funcionalidad (2026-10-09, pedido explícito del
-- usuario tras ver el inventario hecho/pendiente por portal: "esto lo vamos a
-- dar seguimiento, agrégalo como una opción en el mismo menú... vamos a poder
-- tener identificado el problema, subir imágenes, una explicación, el estatus
-- va a ser pendiente/en proceso/atendido... asociarlos a grupos como Sprint 1,
-- 2, 3"). Mismo patrón tenant-scoped + RLS que el resto del esquema (D6) --
-- NO se trató como tabla global pese a ser una herramienta "interna de
-- desarrollo", a propósito: ver memoria de sesión sobre aislamiento
-- multi-tenant como prioridad de producto. Reutiliza tg_auditoria() (ya
-- resuelve tenant_id/creado_por/modificado_por solo) y el mismo patrón de
-- bucket privado con convención {tenant_id}/{item_id}/archivo que
-- "expedientes" (Migración 024).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Hallazgos de funcionalidad (uno por pantalla/función con pendiente)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_backlog_items (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  portal        text NOT NULL CHECK (portal IN ('admin','freelance','publico','backend')),
  grupo         text NOT NULL,     -- mismo agrupamiento que el menú real (Operación, Comercial, Reclutamiento...)
  titulo        text NOT NULL,
  ruta          text,              -- pantalla/archivo de referencia, p.ej. '/admin/checador'
  descripcion   text,              -- observaciones -- se va enriqueciendo con el tiempo, no es de una sola vez
  estado        text NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','en_proceso','atendido')),
  sprint        text,              -- libre ("Sprint 1"...); NULL = backlog general sin paquete asignado todavía
  orden         int NOT NULL DEFAULT 0,
  creado_en timestamptz NOT NULL DEFAULT now(), creado_por uuid,
  modificado_en timestamptz NOT NULL DEFAULT now(), modificado_por uuid
);
CREATE INDEX IF NOT EXISTS ix_backlog_tenant ON te_backlog_items(tenant_id, estado);
CREATE INDEX IF NOT EXISTS ix_backlog_sprint ON te_backlog_items(tenant_id, sprint);
DROP TRIGGER IF EXISTS tg_aud_backlog ON te_backlog_items;
CREATE TRIGGER tg_aud_backlog BEFORE INSERT OR UPDATE ON te_backlog_items FOR EACH ROW EXECUTE FUNCTION tg_auditoria();

-- ---------------------------------------------------------------------------
-- 2. Imágenes de evidencia por hallazgo (N por item, orden de subida)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS te_backlog_imagenes (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  item_id       uuid NOT NULL REFERENCES te_backlog_items(id) ON DELETE CASCADE,
  storage_path  text NOT NULL,
  subida_en timestamptz NOT NULL DEFAULT now(), subida_por uuid
);
CREATE INDEX IF NOT EXISTS ix_backlogimg_item ON te_backlog_imagenes(tenant_id, item_id);

-- ---------------------------------------------------------------------------
-- 3. RLS -- mismo patrón que el resto del esquema (tenant_id = current_tenant_id())
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['te_backlog_items','te_backlog_imagenes']
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_sel ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_ins ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_upd ON %1$s', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_del ON %1$s', t);
    EXECUTE format('CREATE POLICY p_%1$s_sel ON %1$s FOR SELECT USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_ins ON %1$s FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_upd ON %1$s FOR UPDATE USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY p_%1$s_del ON %1$s FOR DELETE USING (tenant_id = current_tenant_id())', t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 4. Storage -- bucket privado para evidencia (capturas de pantalla del
--    problema). Convención de ruta: {tenant_id}/{item_id}/{archivo}
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('backlog', 'backlog', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS p_storage_backlog_sel ON storage.objects;
DROP POLICY IF EXISTS p_storage_backlog_ins ON storage.objects;
DROP POLICY IF EXISTS p_storage_backlog_upd ON storage.objects;
DROP POLICY IF EXISTS p_storage_backlog_del ON storage.objects;

CREATE POLICY p_storage_backlog_sel ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'backlog' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_backlog_ins ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'backlog' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_backlog_upd ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'backlog' AND (storage.foldername(name))[1] = current_tenant_id()::text);
CREATE POLICY p_storage_backlog_del ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'backlog' AND (storage.foldername(name))[1] = current_tenant_id()::text);

-- ---------------------------------------------------------------------------
-- 5. Siembra -- los hallazgos ya identificados en el inventario de código del
--    2026-10-09 (portal por portal), para que el backlog no arranque vacío.
--    Todos en tenant eventos (DEMO_TENANT_ID), estado pendiente, sin sprint
--    asignado todavía -- el usuario los irá moviendo a paquetes de trabajo.
-- ---------------------------------------------------------------------------
INSERT INTO te_backlog_items (tenant_id, portal, grupo, titulo, ruta, descripcion, estado, orden)
SELECT '00000000-0000-0000-0000-000000000001', v.portal, v.grupo, v.titulo, v.ruta, v.descripcion, 'pendiente', v.orden
FROM (VALUES
  -- NOT EXISTS abajo: sembrar solo si la tabla está vacía (sin UNIQUE natural
  -- contra el cual hacer ON CONFLICT -- evita duplicar si esta migración se
  -- vuelve a aplicar por error sobre una base que ya tiene estos hallazgos,
  -- o items propios que el usuario ya haya agregado).
  ('admin', 'Operación',       'Dashboard: "Cobertura por sitio" nunca se llena',           '/admin/dashboard',           'El estado coberturas se declara pero ningún useEffect lo llena -- la sección siempre dice "Sin pedidos activos aún" aunque sí los haya.', 1),
  ('admin', 'Operación',       'Falta pantalla "Modificar detalle" de un pedido',           '/admin/sitios',               'No hay forma de editar un renglón ya creado (p.ej. "completar productos similares") desde la UI -- hoy se cambia por SQL directo.', 2),
  ('admin', 'Operación',       'Checador: consentimiento_id hardcodeado a UUID cero',       '/admin/checador',             'El checador manda siempre el UUID de ceros en vez de resolver el consentimiento vigente real del empleado. El trigger de base sí valida, pero el frontend no manda el dato correcto.', 3),
  ('admin', 'Comercial',       'Requisiciones: folio generado en el navegador',             '/admin/requisiciones',        'Usa Date.now() % 100000 en vez de una función de folios consecutivos del servidor -- riesgo de colisión entre dos altas simultáneas.', 4),
  ('admin', 'Comercial',       'Facturación es solo lectura',                               '/admin/facturacion',          'No hay alta de factura ni timbrado, pese a que existen los permisos facturacion.crear/aprobar -- nada los usa todavía.', 5),
  ('admin', 'Administración',  'Usuarios y roles: solo diagnóstico, sin alta real',         '/admin/usuarios',             'No hay forma de crear roles, asignar permisos ni vincular una cuenta a mano, pese al nombre "Administración de Usuarios, Roles y Perfiles". Pide el permiso usuarios.ver, que no existe en el catálogo tc_permisos real -- ningún rol puede cumplirlo nunca.', 6),
  ('admin', 'Administración',  'Mi suscripción es una simulación sin Stripe',               '/admin/suscripcion',          'El cambio de plan actualiza la base directo tras un confirm() del navegador -- no hay integración real con Stripe en esta pantalla todavía.', 7),
  ('admin', 'Administración',  'Pricing público es solo presentación',                      '/admin/pricing',              'Planes FREE/PRO hardcodeados, botones sin acción -- página de marketing sin ninguna función real.', 8),
  ('admin', 'Soporte / Dev',   'Utilerías pide un permiso que no existe',                   '/admin/utilerias',            'Pide usuarios.ver -- mismo problema que "Usuarios y roles": el código no está en tc_permisos.', 9),
  ('admin', 'Soporte / Dev',   'Bitácora pide un permiso que no existe',                    '/admin/bitacora',             'Mismo bug de usuarios.ver que Utilerías y Usuarios y roles.', 10),
  ('admin', 'Administración',  'RLS no valida permiso, solo tenant',                        null,                          'Un usuario autenticado puede, llamando la API de Supabase directo, escribir en cualquier tabla de su propio tenant aunque su rol no tenga el permiso correspondiente -- el gating de hasPermiso() es solo de interfaz.', 11),
  ('admin', 'Administración',  'La ruta /admin/* no valida permiso, solo el menú lo oculta','RequireAdminAuth.jsx',       'Cualquier cuenta admin válida puede navegar directo a una URL como /admin/nomina aunque su rol no tenga nomina.ver.', 12),
  ('admin', 'Administración',  'tc_permisos y tc_planes_suscripcion sin RLS',               null,                          'Ambas tablas quedan expuestas completas a cualquier cliente anon/authenticated. Reportado por el advisor de seguridad de Supabase, sin corregir -- requiere decidir las políticas antes de activar RLS.', 13),
  ('admin', 'Operación',       'Tarifas matriciales sembradas pero no cableadas',           '/admin/sitios',               'tp_duraciones_evento / tp_sueldos_matriciales ya tienen datos reales del tabulador legado, pero ni matriz_puestos_pedido() ni el "Presupuesto por día" los usan todavía.', 14),
  ('admin', 'Operación',       'tc_productos.id_puesto incompleto',                         '/admin/sitios',               '53 de 81 productos vinculados a su puesto. Sin ese vínculo, "Agregar detalle al pedido" falla con "Elegí un producto (define el puesto)".', 15),
  ('freelance', 'Portal freelance', 'Sin penalización ni lista de espera al cancelar',      '/portal/mis-eventos',         'cancelar_mi_reservacion() respeta el flag existente de "permitir cancelar", pero no penaliza cancelaciones voluntarias ni notifica a quien quedó en lista de espera cuando se libera un lugar. Pendiente de decidir las reglas.', 1),
  ('backend', 'Notificaciones', 'notificacion-resend depende de RESEND_API_KEY',            'netlify/functions/notificacion-resend.js', 'Pendiente confirmar que la key esté configurada en el sitio vigente de Netlify -- sin ella no sale ningún correo real.', 1),
  ('backend', 'Notificaciones', 'notificacion-whatsapp depende de credenciales Twilio',     'netlify/functions/notificacion-whatsapp.js', 'Sin TWILIO_* responde en modo "dry" -- no manda nada de verdad.', 2),
  ('backend', 'Notificaciones', 'digest-diario depende de las mismas keys',                 'netlify/functions/digest-diario.js', 'Mismo bloqueo que notificacion-resend/whatsapp -- sin esas keys el resumen diario no llega a nadie.', 3),
  ('backend', 'Notificaciones', 'notif-publicar-detalle depende de las mismas keys',        'netlify/functions/notif-publicar-detalle.js', 'Mismo bloqueo de credenciales de notificación.', 4),
  ('backend', 'Tenant y cobros', 'onboarding-tenant quedaría roto si se invoca',            'netlify/functions/onboarding-tenant.js', 'Usa nombres de tabla de un esquema anterior (tenants, suscripciones, cat_parametros_globales, avisos_privacidad) que ya no existen -- el esquema real usa te_tenants, te_suscripciones, tp_parametros_globales, tp_avisos_privacidad.', 5),
  ('backend', 'Tenant y cobros', 'payments sin STRIPE_SECRET_KEY',                          'netlify/functions/payments.js', 'La lógica de Stripe Checkout/webhook ya está escrita, pero sin la key real responde en modo "dry" sin cobrar nada.', 6)
) AS v(portal, grupo, titulo, ruta, descripcion, orden)
WHERE NOT EXISTS (SELECT 1 FROM te_backlog_items);

-- ============================================================================
-- Migración 028 -- Pantallas faltantes confirmadas contra el menú real del
-- legado (2026-10-09, pedido del usuario: "faltan muchas pantallas... cuando
-- das de alta trabajador, cuando lo cambias de sueldo... revisa el manual del
-- usuario"). Los manuales de documentacion-referencia/Manual Usuario (Sprint
-- 01-03) solo cubren reclutamiento/pedidos/catálogos y varios ni se
-- terminaron de escribir (ver MANUALES_OCESA_HALLAZGOS.md) -- por eso se
-- habían descartado antes como fuente de inventario de pantallas. La fuente
-- real para esto es `documentacion-referencia/ARBOL_MENU_COMPLETO.md` (menú
-- real del legado 2019, consolidado de 24 documentos de capturas de video:
-- Nómina 18 ítems, Operaciones 16 ítems, Catálogos 26 ítems), cruzado contra
-- el inventario de pantallas compiladas reales en `genexus/web` (624
-- transacciones/catálogos + 104 web panels, ver CLAUDE.md §14) para confirmar
-- que cada hallazgo corresponde a una pantalla real del sistema GeneXus
-- (wp_altaempleadoind, te_extras, te_extrasmasivos, tc_folios,
-- wp_asignacionfolios, te_facturaenc/te_facturadet, facturas_pagos,
-- facturas_servicios_internos, tp_sueldomatriciales), no a texto de
-- intención de un manual sin terminar.
-- ============================================================================
INSERT INTO te_backlog_items (tenant_id, portal, grupo, titulo, ruta, descripcion, estado, orden)
SELECT '00000000-0000-0000-0000-000000000001', v.portal, v.grupo, v.titulo, v.ruta, v.descripcion, 'pendiente', v.orden
FROM (VALUES
  ('admin', 'Nómina', 'Sin alta individual de empleado',                  null, 'El legado tiene una pantalla propia (wp_altaempleadoind) para dar de alta un trabajador directo. En PeopleMovil la única vía es candidato -> funnel de reclutamiento -> promoción -- no hay forma de dar de alta a un empleado que no pasó por ese proceso.', 20),
  ('admin', 'Nómina', 'Sin cambio de sueldo individual por empleado',     '/admin/catalogos', 'El sueldo vive en tc_puestos.pago_default (o en tp_sueldos_matriciales por complejidad/duración), compartido por TODOS los empleados de ese puesto -- cambiarlo en Catálogos afecta a todos a la vez. Falta confirmar si el legado (transacción te_empleado) tenía un sueldo individual por empleado o también dependía solo del puesto.', 21),
  ('admin', 'Nómina', 'Sueldos matriciales sin pantalla de catálogo',     '/admin/catalogos', 'tp_sueldos_matriciales ya tiene datos reales del tabulador legado (Migración 022) pero no aparece en Catálogos (HU 9.01) ni es editable desde ninguna pantalla -- el legado sí tenía esta pantalla (tp_sueldomatriciales).', 22),
  ('admin', 'Nómina', 'Extras (horas extra / bonos) sin captura',         null, 'El menú Nómina del legado tiene "Extras", "Alta Masiva extras" y "Autorización Extras" (te_extras/te_extrasmasivos) -- en PeopleMovil no existe ninguna pantalla para capturar, cargar en lote ni autorizar extras de un empleado.', 23),
  ('admin', 'Nómina', 'Asignación de folios sin mecanismo formal',        '/admin/requisiciones', 'El legado tiene un catálogo tc_folios + función de folios consecutivos del servidor (wp_asignacionfolios, prc_actfolios). PeopleMovil genera el folio de Requisiciones en el navegador con Date.now() -- riesgo de colisión, ya anotado por separado en este backlog -- y no hay equivalente a tc_folios en el esquema en absoluto.', 24),
  ('admin', 'Nómina', 'Dispersión de nómina sin pantalla admin',          '/admin/nomina', 'te_pagos_dispersion solo se lee de solo lectura desde el portal freelance (Mis pagos). No hay pantalla donde el admin genere o ejecute la dispersión de un periodo.', 25),
  ('admin', 'Nómina', 'Pago de honorarios sin captura individual',        '/admin/nomina', 'Nómina calcula y cierra por periodo, pero no se confirmó una pantalla para capturar/ajustar el pago de honorarios de un empleado puntual, como sí tenía el legado.', 26),
  ('admin', 'Nómina', 'Lista negra sin pantalla admin',                   null, 'te_lista_negra_empleados existe como tabla (usada para filtrar elegibilidad en el portal freelance) pero no tiene pantalla de administración dedicada -- no está en Catálogos (HU 9.01).', 27),
  ('admin', 'Nómina', 'Aclaraciones sin flujo de captura/resolución',     '/admin/catalogos', 'Solo existe el catálogo de causas de aclaración (tc_causas_aclaracion, sí en Catálogos). El legado tiene una pantalla "Aclaraciones" (te_aclaraciones) para capturar y resolver una aclaración real -- no existe en PeopleMovil.', 28),
  ('admin', 'Comercial', 'Facturación: faltan altas/edición reales y pagos', '/admin/facturacion', 'Confirmado contra el legado real: existen transacciones te_facturaenc/te_facturadet (alta/edición de factura) y una pantalla separada facturas_pagos (captura de pagos) -- PeopleMovil solo tiene consulta de solo lectura, sin ninguna de las dos.', 29),
  ('admin', 'Comercial', 'Facturación de "servicios internos" sin modelar', '/admin/facturacion', 'El legado tiene una pantalla separada facturas_servicios_internos -- un concepto de facturación interna distinto de la factura a cliente normal. te_pedidos.facturar_servicio_interno existe como flag, pero no hay tabla ni pantalla para el proceso completo.', 30),
  ('admin', 'Comercial', 'Sin carga masiva de PEPs / Centros de Costos',  '/admin/catalogos', 'El menú Operaciones del legado tiene "Carga masiva Peps", "Peps masivos" y "Peps y Centros de Costos" -- tc_partidas_presupuestales ya existe en Catálogos pero solo con alta uno por uno, sin carga masiva.', 31),
  ('admin', 'Operación', 'TimeScan por Empleado sin reporte',             '/admin/checador', 'El menú Operaciones del legado tiene un reporte dedicado "TimeScan por Empleado" (checadas consolidadas por persona) -- Checador.jsx solo lista los últimos 50 marcajes, sin ese reporte.', 32),
  ('admin', 'Operación', 'TimeScan por Detalle Pedido sin reporte',       '/admin/sitios', 'Mismo caso que TimeScan por Empleado, pero agrupado por renglón de pedido -- no existe en SitiosAsignacion.jsx.', 33)
) AS v(portal, grupo, titulo, ruta, descripcion, orden)
WHERE NOT EXISTS (SELECT 1 FROM te_backlog_items WHERE titulo = 'Sin alta individual de empleado');

-- ============================================================================
