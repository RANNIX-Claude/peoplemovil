-- ============================================================================
-- Migration 004 — Data Warehouse (schema dw)
-- Dimensiones + hechos + ETL idempotente + 6 vistas analíticas
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS dw;
GRANT USAGE ON SCHEMA dw TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 1. DIMENSIONES DE TIEMPO (2020-2030)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw.dim_tiempo_dia (
  llave_dia         int PRIMARY KEY,
  fecha             date UNIQUE NOT NULL,
  llave_mes         int NOT NULL,
  llave_trimestre   varchar(7) NOT NULL,
  llave_semestre    varchar(7) NOT NULL,
  llave_anio        int NOT NULL,
  anio              int NOT NULL,
  mes               int NOT NULL,
  mes_nombre        varchar(20) NOT NULL,
  dia               int NOT NULL,
  dia_semana        int NOT NULL,
  dia_semana_nombre varchar(20) NOT NULL,
  es_fin_semana     boolean NOT NULL DEFAULT false,
  es_feriado_mx     boolean NOT NULL DEFAULT false,
  mes_anio_etiqueta varchar(20),
  trimestre_etiqueta varchar(20)
);

CREATE TABLE IF NOT EXISTS dw.dim_tiempo_mes (
  llave_mes         int PRIMARY KEY,
  llave_trimestre   varchar(7) NOT NULL,
  llave_semestre    varchar(7) NOT NULL,
  llave_anio        int NOT NULL,
  anio              int NOT NULL,
  mes               int NOT NULL,
  mes_nombre        varchar(20) NOT NULL,
  fecha_inicio      date NOT NULL,
  fecha_fin         date NOT NULL,
  mes_anio_etiqueta varchar(20),
  dias_habiles      int
);

CREATE TABLE IF NOT EXISTS dw.dim_tiempo_trimestre (
  llave_trimestre  varchar(7) PRIMARY KEY,
  llave_semestre   varchar(7) NOT NULL,
  llave_anio       int NOT NULL,
  anio             int NOT NULL,
  trimestre        int NOT NULL,
  fecha_inicio     date NOT NULL,
  fecha_fin        date NOT NULL,
  etiqueta         varchar(20)
);

CREATE TABLE IF NOT EXISTS dw.dim_tiempo_anio (
  llave_anio    int PRIMARY KEY,
  anio          int NOT NULL,
  fecha_inicio  date NOT NULL,
  fecha_fin     date NOT NULL,
  dias_totales  int NOT NULL
);

-- Poblar dimensiones de tiempo (idempotente)
INSERT INTO dw.dim_tiempo_dia (
  llave_dia, fecha, llave_mes, llave_trimestre, llave_semestre, llave_anio,
  anio, mes, mes_nombre, dia, dia_semana, dia_semana_nombre, es_fin_semana,
  mes_anio_etiqueta, trimestre_etiqueta
)
SELECT
  to_char(d, 'YYYYMMDD')::int,
  d::date,
  to_char(d, 'YYYYMM')::int,
  extract(year FROM d)::text || 'T' || extract(quarter FROM d)::int::text,
  extract(year FROM d)::text || 'S' || (CASE WHEN extract(month FROM d) <= 6 THEN '1' ELSE '2' END),
  extract(year FROM d)::int,
  extract(year FROM d)::int,
  extract(month FROM d)::int,
  to_char(d, 'TMMonth'),
  extract(day FROM d)::int,
  extract(isodow FROM d)::int,
  to_char(d, 'TMDay'),
  extract(isodow FROM d) IN (6, 7),
  to_char(d, 'TMMon YYYY'),
  'T' || extract(quarter FROM d)::int::text || ' ' || extract(year FROM d)::int::text
FROM generate_series('2020-01-01'::date, '2030-12-31'::date, '1 day'::interval) d
ON CONFLICT DO NOTHING;

INSERT INTO dw.dim_tiempo_mes (
  llave_mes, llave_trimestre, llave_semestre, llave_anio, anio, mes, mes_nombre,
  fecha_inicio, fecha_fin, mes_anio_etiqueta
)
SELECT DISTINCT
  llave_mes, llave_trimestre, llave_semestre, llave_anio, anio, mes, mes_nombre,
  date_trunc('month', fecha)::date,
  (date_trunc('month', fecha) + interval '1 month' - interval '1 day')::date,
  mes_anio_etiqueta
FROM dw.dim_tiempo_dia
ON CONFLICT DO NOTHING;

INSERT INTO dw.dim_tiempo_trimestre (llave_trimestre, llave_semestre, llave_anio, anio, trimestre, fecha_inicio, fecha_fin, etiqueta)
SELECT DISTINCT
  llave_trimestre,
  llave_semestre,
  llave_anio,
  anio,
  extract(quarter FROM fecha)::int,
  date_trunc('quarter', fecha)::date,
  (date_trunc('quarter', fecha) + interval '3 months' - interval '1 day')::date,
  trimestre_etiqueta
FROM dw.dim_tiempo_dia
ON CONFLICT DO NOTHING;

INSERT INTO dw.dim_tiempo_anio (llave_anio, anio, fecha_inicio, fecha_fin, dias_totales)
SELECT DISTINCT
  llave_anio, anio,
  date_trunc('year', fecha)::date,
  (date_trunc('year', fecha) + interval '1 year' - interval '1 day')::date,
  CASE WHEN anio % 4 = 0 AND (anio % 100 <> 0 OR anio % 400 = 0) THEN 366 ELSE 365 END
FROM dw.dim_tiempo_dia
ON CONFLICT DO NOTHING;

-- Marcar feriados MX (fijos + móviles conocidos)
UPDATE dw.dim_tiempo_dia SET es_feriado_mx = true
WHERE (mes = 1 AND dia = 1)      -- Año Nuevo
   OR (mes = 2 AND dia = 5)      -- Día Constitución
   OR (mes = 3 AND dia = 21)     -- Natalicio Juárez
   OR (mes = 5 AND dia = 1)      -- Día del Trabajo
   OR (mes = 9 AND dia = 16)     -- Día Independencia
   OR (mes = 11 AND dia = 20)    -- Día Revolución
   OR (mes = 12 AND dia = 25);   -- Navidad

-- ---------------------------------------------------------------------------
-- 2. DIMENSIONES DE NEGOCIO
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dw.dim_tenant (
  llave_tenant      uuid PRIMARY KEY REFERENCES te_tenants(id) ON DELETE CASCADE,
  razon_social      text NOT NULL,
  rfc               text,
  vertical          text,
  fecha_alta        date,
  refrescado_en     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dw.dim_empleado (
  llave_empleado    uuid PRIMARY KEY REFERENCES te_empleados(id) ON DELETE CASCADE,
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  folio             int,
  nombre_completo   text NOT NULL,
  sexo              text,
  edad              int,
  regimen_pago      text,
  ciclo_pago        text,
  tipo_empleado     text,
  activo            boolean,
  fecha_alta        date,
  fecha_baja        date,
  refrescado_en     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dw.dim_puesto (
  llave_puesto      uuid PRIMARY KEY REFERENCES tc_puestos(id) ON DELETE CASCADE,
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo            text NOT NULL,
  regimen_pago      text,
  ciclo_pago        text,
  matricial         boolean,
  refrescado_en     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dw.dim_sitio (
  llave_sitio       uuid PRIMARY KEY REFERENCES tc_sitios(id) ON DELETE CASCADE,
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  titulo            text NOT NULL,
  tipo_sitio        text,
  ciudad            text,
  estado            text,
  refrescado_en     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dw.dim_cliente (
  llave_cliente     uuid PRIMARY KEY REFERENCES tc_clientes(id) ON DELETE CASCADE,
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  razon_social      text NOT NULL,
  rfc               text,
  refrescado_en     timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 3. TABLAS DE HECHOS
-- ---------------------------------------------------------------------------

-- Asistencia diaria por empleado
CREATE TABLE IF NOT EXISTS dw.hecho_asistencia_diaria (
  llave_dia         int NOT NULL REFERENCES dw.dim_tiempo_dia(llave_dia),
  tenant_id         uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  llave_empleado    uuid NOT NULL REFERENCES dw.dim_empleado(llave_empleado),
  llave_puesto      uuid REFERENCES dw.dim_puesto(llave_puesto),
  llave_sitio       uuid REFERENCES dw.dim_sitio(llave_sitio),
  cnt_asistencias   int NOT NULL DEFAULT 0,
  cnt_retardos      int NOT NULL DEFAULT 0,
  cnt_faltas        int NOT NULL DEFAULT 0,
  cnt_reservaciones int NOT NULL DEFAULT 0,
  porcentaje_puntualidad numeric(5,2),
  refrescado_en     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (llave_dia, llave_empleado)
);
CREATE INDEX IF NOT EXISTS ix_hasd_ten_dia ON dw.hecho_asistencia_diaria(tenant_id, llave_dia);

-- Cobertura por sitio y día
CREATE TABLE IF NOT EXISTS dw.hecho_cobertura_sitio_dia (
  llave_dia          int NOT NULL REFERENCES dw.dim_tiempo_dia(llave_dia),
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  llave_sitio        uuid NOT NULL REFERENCES dw.dim_sitio(llave_sitio),
  cnt_pedidos        int NOT NULL DEFAULT 0,
  cnt_puestos_req    int NOT NULL DEFAULT 0,
  cnt_reservaciones  int NOT NULL DEFAULT 0,
  cnt_asistencias    int NOT NULL DEFAULT 0,
  pct_cobertura      numeric(5,2),
  pct_asistencia     numeric(5,2),
  color_semaforo     varchar(1),     -- 'V', 'A', 'R'
  refrescado_en      timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (llave_dia, llave_sitio)
);
CREATE INDEX IF NOT EXISTS ix_hcs_ten_dia ON dw.hecho_cobertura_sitio_dia(tenant_id, llave_dia);

-- Reservaciones ejecutadas
CREATE TABLE IF NOT EXISTS dw.hecho_reservaciones (
  llave_reservacion  uuid PRIMARY KEY REFERENCES te_reservaciones(id) ON DELETE CASCADE,
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  llave_dia          int NOT NULL REFERENCES dw.dim_tiempo_dia(llave_dia),
  llave_empleado     uuid REFERENCES dw.dim_empleado(llave_empleado),
  llave_puesto       uuid REFERENCES dw.dim_puesto(llave_puesto),
  llave_sitio        uuid REFERENCES dw.dim_sitio(llave_sitio),
  duracion_horas     numeric(6,2),
  costo_nomina       numeric(12,2),
  precio_venta       numeric(12,2),
  margen             numeric(12,2),
  penalizacion       numeric(12,2),
  estado_asistencia  text,
  refrescado_en      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_hres_ten_dia ON dw.hecho_reservaciones(tenant_id, llave_dia);

-- Pagos dispersados
CREATE TABLE IF NOT EXISTS dw.hecho_pagos_dispersados (
  llave_pago         uuid PRIMARY KEY REFERENCES te_pagos_dispersion(id) ON DELETE CASCADE,
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  llave_dia          int NOT NULL REFERENCES dw.dim_tiempo_dia(llave_dia),
  llave_empleado     uuid REFERENCES dw.dim_empleado(llave_empleado),
  llave_puesto       uuid REFERENCES dw.dim_puesto(llave_puesto),
  monto              numeric(14,2) NOT NULL,
  regimen            text,
  status             text,
  metodo_pago        text,
  refrescado_en      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_hpd_ten_dia ON dw.hecho_pagos_dispersados(tenant_id, llave_dia);

-- Facturas a cliente
CREATE TABLE IF NOT EXISTS dw.hecho_facturas_cliente (
  llave_factura      uuid PRIMARY KEY REFERENCES te_facturas_enc(id) ON DELETE CASCADE,
  tenant_id          uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  llave_dia          int NOT NULL REFERENCES dw.dim_tiempo_dia(llave_dia),
  llave_cliente      uuid REFERENCES dw.dim_cliente(llave_cliente),
  subtotal           numeric(14,2),
  iva                numeric(14,2),
  total              numeric(14,2),
  pagado             numeric(14,2) NOT NULL DEFAULT 0,
  por_cobrar         numeric(14,2),
  status             text,
  refrescado_en      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_hfc_ten_dia ON dw.hecho_facturas_cliente(tenant_id, llave_dia);

-- ---------------------------------------------------------------------------
-- 4. ETL IDEMPOTENTE — refrescar_dw()
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dw.refrescar_dimensiones() RETURNS void AS $$
BEGIN
  -- Tenant
  INSERT INTO dw.dim_tenant (llave_tenant, razon_social, rfc, vertical, fecha_alta)
  SELECT id, razon_social, rfc, vertical, creado_en::date FROM te_tenants
  ON CONFLICT (llave_tenant) DO UPDATE SET
    razon_social = EXCLUDED.razon_social,
    rfc = EXCLUDED.rfc,
    vertical = EXCLUDED.vertical,
    refrescado_en = now();

  -- Empleado
  INSERT INTO dw.dim_empleado (
    llave_empleado, tenant_id, folio, nombre_completo, sexo, edad,
    regimen_pago, ciclo_pago, tipo_empleado, activo, fecha_alta, fecha_baja
  )
  SELECT
    e.id, e.tenant_id, e.folio,
    e.nombres || ' ' || e.apellido_paterno || COALESCE(' ' || e.apellido_materno, ''),
    e.sexo::text,
    CASE WHEN e.fecha_nacimiento IS NOT NULL THEN
      extract(year FROM age(e.fecha_nacimiento))::int
    END,
    e.regimen_pago::text, e.ciclo_pago::text, e.tipo_empleado, e.activo,
    e.fecha_alta, e.fecha_baja
  FROM te_empleados e
  ON CONFLICT (llave_empleado) DO UPDATE SET
    folio = EXCLUDED.folio,
    nombre_completo = EXCLUDED.nombre_completo,
    activo = EXCLUDED.activo,
    fecha_baja = EXCLUDED.fecha_baja,
    refrescado_en = now();

  -- Puesto
  INSERT INTO dw.dim_puesto (llave_puesto, tenant_id, titulo, regimen_pago, ciclo_pago, matricial)
  SELECT p.id, p.tenant_id, p.titulo, p.regimen_pago::text, p.ciclo_pago::text,
         COALESCE(p.matricial, false)
  FROM tc_puestos p
  ON CONFLICT (llave_puesto) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    refrescado_en = now();

  -- Sitio
  INSERT INTO dw.dim_sitio (llave_sitio, tenant_id, titulo, tipo_sitio, ciudad, estado)
  SELECT s.id, s.tenant_id, s.titulo, s.tipo_sitio::text, NULL, NULL
  FROM tc_sitios s
  ON CONFLICT (llave_sitio) DO UPDATE SET
    titulo = EXCLUDED.titulo, tipo_sitio = EXCLUDED.tipo_sitio,
    refrescado_en = now();

  -- Cliente
  INSERT INTO dw.dim_cliente (llave_cliente, tenant_id, razon_social, rfc)
  SELECT c.id, c.tenant_id, c.razon_social, c.rfc FROM tc_clientes c
  ON CONFLICT (llave_cliente) DO UPDATE SET
    razon_social = EXCLUDED.razon_social,
    refrescado_en = now();
END $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION dw.refrescar_hechos_reservaciones() RETURNS int AS $$
DECLARE n int;
BEGIN
  DELETE FROM dw.hecho_reservaciones;   -- rebuild full (simple, seguro para volúmenes < 1M)
  INSERT INTO dw.hecho_reservaciones (
    llave_reservacion, tenant_id, llave_dia, llave_empleado, llave_puesto, llave_sitio,
    duracion_horas, costo_nomina, precio_venta, margen, penalizacion, estado_asistencia
  )
  SELECT
    r.id, r.tenant_id,
    to_char(r.cita_inicio::date, 'YYYYMMDD')::int,
    r.empleado_id, r.puesto_id, r.sitio_id,
    extract(epoch FROM (r.cita_fin - r.cita_inicio))/3600,
    COALESCE(pd.costo_por_nomina, 0),
    COALESCE(pd.precio, 0),
    COALESCE(pd.precio, 0) - COALESCE(pd.costo_por_nomina, 0),
    COALESCE(r.penalizacion_sueldo, 0),
    r.estado_asistencia::text
  FROM te_reservaciones r
  LEFT JOIN te_pedidos_detalle pd ON pd.id = r.pedido_detalle_id;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION dw.refrescar_hechos_asistencia_diaria() RETURNS int AS $$
DECLARE n int;
BEGIN
  DELETE FROM dw.hecho_asistencia_diaria;
  INSERT INTO dw.hecho_asistencia_diaria (
    llave_dia, tenant_id, llave_empleado, llave_puesto, llave_sitio,
    cnt_asistencias, cnt_retardos, cnt_faltas, cnt_reservaciones, porcentaje_puntualidad
  )
  SELECT
    to_char(r.cita_inicio::date, 'YYYYMMDD')::int,
    r.tenant_id, r.empleado_id, r.puesto_id, r.sitio_id,
    count(*) FILTER (WHERE r.estado_asistencia = 'asistencia'),
    count(*) FILTER (WHERE r.estado_asistencia = 'retardo'),
    count(*) FILTER (WHERE r.estado_asistencia = 'falta'),
    count(*),
    CASE WHEN count(*) > 0 THEN
      round(100.0 * count(*) FILTER (WHERE r.estado_asistencia = 'asistencia') / count(*), 2)
    END
  FROM te_reservaciones r
  WHERE r.estado = 'procesado'
  GROUP BY 1, r.tenant_id, r.empleado_id, r.puesto_id, r.sitio_id
  ON CONFLICT (llave_dia, llave_empleado) DO UPDATE SET
    cnt_asistencias = EXCLUDED.cnt_asistencias,
    cnt_retardos = EXCLUDED.cnt_retardos,
    cnt_faltas = EXCLUDED.cnt_faltas,
    cnt_reservaciones = EXCLUDED.cnt_reservaciones,
    porcentaje_puntualidad = EXCLUDED.porcentaje_puntualidad,
    refrescado_en = now();
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION dw.refrescar_hechos_cobertura() RETURNS int AS $$
DECLARE n int;
BEGIN
  DELETE FROM dw.hecho_cobertura_sitio_dia;
  INSERT INTO dw.hecho_cobertura_sitio_dia (
    llave_dia, tenant_id, llave_sitio,
    cnt_pedidos, cnt_puestos_req, cnt_reservaciones, cnt_asistencias,
    pct_cobertura, pct_asistencia, color_semaforo
  )
  SELECT
    to_char(p.fecha_evento, 'YYYYMMDD')::int,
    p.tenant_id, p.sitio_id,
    count(DISTINCT p.id),
    COALESCE(sum(pd.cantidad), 0)::int,
    COALESCE(sum(pd.cantidad_reservados_real), 0)::int,
    COALESCE(sum(pd.cantidad_que_asistieron), 0)::int,
    CASE WHEN sum(pd.cantidad) > 0
      THEN round(100.0 * sum(pd.cantidad_reservados_real) / sum(pd.cantidad), 2)
    END,
    CASE WHEN sum(pd.cantidad) > 0
      THEN round(100.0 * sum(pd.cantidad_que_asistieron) / sum(pd.cantidad), 2)
    END,
    CASE
      WHEN sum(pd.cantidad) = 0 THEN 'A'
      WHEN 100.0 * sum(pd.cantidad_reservados_real) / sum(pd.cantidad) >= 80 THEN 'V'
      WHEN 100.0 * sum(pd.cantidad_reservados_real) / sum(pd.cantidad) >= 60 THEN 'A'
      ELSE 'R'
    END
  FROM te_pedidos p
  JOIN te_pedidos_detalle pd ON pd.pedido_id = p.id
  GROUP BY 1, p.tenant_id, p.sitio_id;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION dw.refrescar_hechos_pagos() RETURNS int AS $$
DECLARE n int;
BEGIN
  DELETE FROM dw.hecho_pagos_dispersados;
  INSERT INTO dw.hecho_pagos_dispersados (
    llave_pago, tenant_id, llave_dia, llave_empleado, llave_puesto,
    monto, regimen, status, metodo_pago
  )
  SELECT
    p.id, p.tenant_id,
    to_char(COALESCE(p.dispersado_en::date, p.creado_en::date), 'YYYYMMDD')::int,
    p.empleado_id, p.puesto_principal_id,
    p.monto, p.regimen::text, p.status::text, NULL
  FROM te_pagos_dispersion p;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION dw.refrescar_hechos_facturas() RETURNS int AS $$
DECLARE n int;
BEGIN
  DELETE FROM dw.hecho_facturas_cliente;
  INSERT INTO dw.hecho_facturas_cliente (
    llave_factura, tenant_id, llave_dia, llave_cliente,
    subtotal, iva, total, pagado, por_cobrar, status
  )
  SELECT
    f.id, f.tenant_id,
    to_char(f.fecha_emision, 'YYYYMMDD')::int,
    f.cliente_id, f.subtotal, f.iva, f.total,
    COALESCE(pag.total_pagado, 0),
    f.total - COALESCE(pag.total_pagado, 0),
    COALESCE(f.status_full::text, f.status)
  FROM te_facturas_enc f
  LEFT JOIN (
    SELECT factura_id, sum(monto) AS total_pagado
    FROM te_pagos_factura GROUP BY factura_id
  ) pag ON pag.factura_id = f.id;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

-- ETL master: corre todos los refresh en orden
CREATE OR REPLACE FUNCTION dw.refrescar_todo() RETURNS jsonb AS $$
DECLARE
  n_res int; n_asis int; n_cob int; n_pag int; n_fac int;
BEGIN
  PERFORM dw.refrescar_dimensiones();
  n_res  := dw.refrescar_hechos_reservaciones();
  n_asis := dw.refrescar_hechos_asistencia_diaria();
  n_cob  := dw.refrescar_hechos_cobertura();
  n_pag  := dw.refrescar_hechos_pagos();
  n_fac  := dw.refrescar_hechos_facturas();
  RETURN jsonb_build_object(
    'reservaciones', n_res,
    'asistencia_diaria', n_asis,
    'cobertura_sitio', n_cob,
    'pagos', n_pag,
    'facturas', n_fac,
    'refrescado_en', now()
  );
END $$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION
  dw.refrescar_dimensiones(),
  dw.refrescar_hechos_reservaciones(),
  dw.refrescar_hechos_asistencia_diaria(),
  dw.refrescar_hechos_cobertura(),
  dw.refrescar_hechos_pagos(),
  dw.refrescar_hechos_facturas(),
  dw.refrescar_todo()
TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. RLS por tenant + grants
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'dim_tenant','dim_empleado','dim_puesto','dim_sitio','dim_cliente',
    'hecho_asistencia_diaria','hecho_cobertura_sitio_dia','hecho_reservaciones',
    'hecho_pagos_dispersados','hecho_facturas_cliente'
  ] LOOP
    EXECUTE format('ALTER TABLE dw.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS p_%1$s_sel ON dw.%1$s', t);
    IF t IN ('dim_tenant') THEN
      EXECUTE format('CREATE POLICY p_%1$s_sel ON dw.%1$s FOR SELECT USING (llave_tenant = current_tenant_id())', t);
    ELSE
      EXECUTE format('CREATE POLICY p_%1$s_sel ON dw.%1$s FOR SELECT USING (tenant_id = current_tenant_id())', t);
    END IF;
  END LOOP;
END $$;

GRANT SELECT ON dw.dim_tiempo_dia, dw.dim_tiempo_mes, dw.dim_tiempo_trimestre, dw.dim_tiempo_anio,
              dw.dim_tenant, dw.dim_empleado, dw.dim_puesto, dw.dim_sitio, dw.dim_cliente,
              dw.hecho_asistencia_diaria, dw.hecho_cobertura_sitio_dia, dw.hecho_reservaciones,
              dw.hecho_pagos_dispersados, dw.hecho_facturas_cliente
  TO anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. 6 VISTAS ANALÍTICAS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW dw.v_asistencia_por_mes AS
SELECT
  h.tenant_id,
  t.llave_mes, t.mes_anio_etiqueta,
  sum(h.cnt_asistencias)  AS asistencias,
  sum(h.cnt_retardos)     AS retardos,
  sum(h.cnt_faltas)       AS faltas,
  sum(h.cnt_reservaciones) AS total_turnos,
  CASE WHEN sum(h.cnt_reservaciones) > 0
    THEN round(100.0 * sum(h.cnt_asistencias) / sum(h.cnt_reservaciones), 2)
  END AS pct_asistencia
FROM dw.hecho_asistencia_diaria h
JOIN dw.dim_tiempo_dia d ON d.llave_dia = h.llave_dia
JOIN dw.dim_tiempo_mes t ON t.llave_mes = d.llave_mes
GROUP BY h.tenant_id, t.llave_mes, t.mes_anio_etiqueta;
GRANT SELECT ON dw.v_asistencia_por_mes TO anon, authenticated;

CREATE OR REPLACE VIEW dw.v_cobertura_por_sitio_mes AS
SELECT
  h.tenant_id,
  s.titulo AS sitio,
  t.mes_anio_etiqueta,
  sum(h.cnt_puestos_req)    AS puestos_req,
  sum(h.cnt_reservaciones)  AS reservados,
  sum(h.cnt_asistencias)    AS asistidos,
  CASE WHEN sum(h.cnt_puestos_req) > 0
    THEN round(100.0 * sum(h.cnt_reservaciones) / sum(h.cnt_puestos_req), 2)
  END AS pct_cobertura,
  CASE WHEN sum(h.cnt_puestos_req) > 0
    THEN round(100.0 * sum(h.cnt_asistencias) / sum(h.cnt_puestos_req), 2)
  END AS pct_asistencia_final
FROM dw.hecho_cobertura_sitio_dia h
JOIN dw.dim_sitio s      ON s.llave_sitio = h.llave_sitio
JOIN dw.dim_tiempo_dia d ON d.llave_dia = h.llave_dia
JOIN dw.dim_tiempo_mes t ON t.llave_mes = d.llave_mes
GROUP BY h.tenant_id, s.titulo, t.mes_anio_etiqueta;
GRANT SELECT ON dw.v_cobertura_por_sitio_mes TO anon, authenticated;

CREATE OR REPLACE VIEW dw.v_pagos_por_regimen_mes AS
SELECT
  h.tenant_id,
  h.regimen,
  t.mes_anio_etiqueta,
  count(*) AS cnt_pagos,
  sum(h.monto) AS total_pagado,
  round(avg(h.monto), 2) AS pago_promedio
FROM dw.hecho_pagos_dispersados h
JOIN dw.dim_tiempo_dia d ON d.llave_dia = h.llave_dia
JOIN dw.dim_tiempo_mes t ON t.llave_mes = d.llave_mes
WHERE h.status = 'pagado'
GROUP BY h.tenant_id, h.regimen, t.mes_anio_etiqueta;
GRANT SELECT ON dw.v_pagos_por_regimen_mes TO anon, authenticated;

CREATE OR REPLACE VIEW dw.v_facturas_por_cliente_mes AS
SELECT
  h.tenant_id,
  c.razon_social AS cliente,
  t.mes_anio_etiqueta,
  count(*) AS cnt_facturas,
  sum(h.subtotal) AS subtotal,
  sum(h.iva)      AS iva,
  sum(h.total)    AS total,
  sum(h.pagado)   AS cobrado,
  sum(h.por_cobrar) AS por_cobrar
FROM dw.hecho_facturas_cliente h
JOIN dw.dim_cliente c    ON c.llave_cliente = h.llave_cliente
JOIN dw.dim_tiempo_dia d ON d.llave_dia = h.llave_dia
JOIN dw.dim_tiempo_mes t ON t.llave_mes = d.llave_mes
GROUP BY h.tenant_id, c.razon_social, t.mes_anio_etiqueta;
GRANT SELECT ON dw.v_facturas_por_cliente_mes TO anon, authenticated;

CREATE OR REPLACE VIEW dw.v_margen_por_puesto_mes AS
SELECT
  h.tenant_id,
  p.titulo AS puesto,
  t.mes_anio_etiqueta,
  count(*)                AS cnt_reservaciones,
  sum(h.costo_nomina)     AS costo_total,
  sum(h.precio_venta)     AS venta_total,
  sum(h.margen)           AS margen_total,
  CASE WHEN sum(h.precio_venta) > 0
    THEN round(100.0 * sum(h.margen) / sum(h.precio_venta), 2)
  END AS pct_margen
FROM dw.hecho_reservaciones h
JOIN dw.dim_puesto p    ON p.llave_puesto = h.llave_puesto
JOIN dw.dim_tiempo_dia d ON d.llave_dia = h.llave_dia
JOIN dw.dim_tiempo_mes t ON t.llave_mes = d.llave_mes
GROUP BY h.tenant_id, p.titulo, t.mes_anio_etiqueta;
GRANT SELECT ON dw.v_margen_por_puesto_mes TO anon, authenticated;

CREATE OR REPLACE VIEW dw.v_top_empleados_puntualidad AS
SELECT
  h.tenant_id,
  e.nombre_completo,
  e.folio,
  sum(h.cnt_reservaciones) AS total_turnos,
  sum(h.cnt_asistencias)   AS asistencias,
  sum(h.cnt_faltas)        AS faltas,
  CASE WHEN sum(h.cnt_reservaciones) > 0
    THEN round(100.0 * sum(h.cnt_asistencias) / sum(h.cnt_reservaciones), 2)
  END AS pct_puntualidad
FROM dw.hecho_asistencia_diaria h
JOIN dw.dim_empleado e ON e.llave_empleado = h.llave_empleado
GROUP BY h.tenant_id, e.nombre_completo, e.folio
HAVING sum(h.cnt_reservaciones) >= 3;
GRANT SELECT ON dw.v_top_empleados_puntualidad TO anon, authenticated;
