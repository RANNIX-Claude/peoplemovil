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
