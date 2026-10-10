import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Chip from '../../components/ui/Chip.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { tituloConLinea } from '../../components/ui/CardHeader.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Cada métrica resuelve su vista real según el grano elegido -- nombres
// completos en vez de interpolar "por_X" a ciegas, porque el patrón de
// nombres no es uniforme entre vistas (ver Migración 030c en reset_database.sql).
const METRICAS = [
  { key: 'asistencia',   label: 'Asistencia',          icon: '📅', vista: g => `v_asistencia_por_${g}` },
  { key: 'cobertura',    label: 'Cobertura por sitio',  icon: '📍', vista: g => `v_cobertura_por_sitio_${g}` },
  { key: 'pagos',        label: 'Pagos por régimen',    icon: '💰', vista: g => `v_pagos_por_regimen_${g}` },
  { key: 'facturas',     label: 'Facturas por cliente', icon: '🧾', vista: g => `v_facturas_por_cliente_${g}` },
  { key: 'margen',       label: 'Margen por puesto',    icon: '📊', vista: g => `v_margen_por_puesto_${g}` },
  { key: 'puntualidad',  label: 'Top puntualidad',      icon: '⭐', vista: g => g === 'mes' ? 'v_top_empleados_puntualidad' : `v_top_empleados_puntualidad_${g}` },
];
const GRANOS = [
  { key: 'semana', label: 'Semana' },
  { key: 'mes', label: 'Mes' },
  { key: 'trimestre', label: 'Trimestre' },
  { key: 'anio', label: 'Año' },
];

const fmt = n => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 2 });
const fmt$ = n => '$' + fmt(n);

export default function DataWarehouse() {
  useModuleAudit('data_warehouse');
  const [metricaActiva, setMetricaActiva] = useState(METRICAS[0]);
  const [grano, setGrano] = useState('mes');
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [ultimoEtl, setUltimoEtl] = useState(null);
  const [msg, setMsg] = useState(null);

  const vistaKey = metricaActiva.vista(grano);

  useEffect(() => { cargar(); }, [vistaKey]);
  async function cargar() {
    if (!supabaseReady) return;
    setLoading(true);
    const { data, error } = await supabase.from(vistaKey).select('*').order('periodo', { ascending: false }).limit(500);
    if (error) setMsg('⚠ ' + error.message);
    else { setRows(data || []); setMsg(null); }
    setLoading(false);
  }

  async function refrescarETL() {
    setMsg('Refrescando DW…');
    const { data, error } = await supabase.rpc('refrescar_dw_todo');
    if (error) { setMsg('❌ ' + error.message); return; }
    setUltimoEtl(data);
    await logAccion('data_warehouse', 'ETL', JSON.stringify(data));
    setMsg('✓ DW refrescado: ' + JSON.stringify(data));
    cargar();
  }

  const columnas = rows[0] ? Object.keys(rows[0]).filter(c => c !== 'tenant_id' && c !== 'anio' && !c.endsWith('_id')) : [];

  return (
    <div>
      <div className="section-eyebrow">Analítica</div>
      <h1>Data Warehouse</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        24 vistas analíticas (6 métricas × semana/mes/trimestre/año) sobre un modelo estrella real
        (11 dimensiones + 5 hechos). ETL idempotente, corre solo o con <code>refrescar_dw_todo()</code> —
        <strong> programado automáticamente todos los días a las 03:00 UTC</strong> vía <code>pg_cron</code>.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Vistas disponibles" value={METRICAS.length * GRANOS.length} sub="6 métricas × 4 cortes" />
        <KpiCard label="Filas en vista actual" value={rows.length.toLocaleString('es-MX')} sub={`${metricaActiva.label} · ${grano}`} />
        <KpiCard label="Último ETL" value={ultimoEtl ? '✓' : '—'} sub={ultimoEtl ? new Date(ultimoEtl.refrescado_en).toLocaleString('es-MX') : 'Presiona Refrescar (o espera al cron 03:00 UTC)'} color="var(--accent2)" onClick={refrescarETL} drillLabel="Refrescar DW →" />
      </div>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 12 }}>{msg}</div>}

      <div className="chips">
        {METRICAS.map(m => (
          <Chip key={m.key} active={metricaActiva.key === m.key} onClick={() => setMetricaActiva(m)}>
            {m.icon} {m.label}
          </Chip>
        ))}
      </div>
      <div className="chips" style={{ marginTop: -4 }}>
        {GRANOS.map(g => (
          <Chip key={g.key} active={grano === g.key} onClick={() => setGrano(g.key)}>{g.label}</Chip>
        ))}
      </div>

      <TablaWrap>
        <table>
          <thead>
            <tr>{columnas.map(c => <th key={c} style={{ whiteSpace: 'nowrap' }}>{c}</th>)}</tr>
          </thead>
          <tbody>
            {rows.length === 0 && (
              <tr><td colSpan={columnas.length || 1} className="empty">
                {loading ? 'Cargando…' : 'Sin datos aún para este corte. Presiona "Refrescar DW →" en la card superior para poblar los hechos.'}
              </td></tr>
            )}
            {rows.map((r, i) => (
              <tr key={i}>
                {columnas.map(c => {
                  const v = r[c];
                  let rendered;
                  if (v == null) rendered = <span style={{ color: 'var(--muted)' }}>—</span>;
                  else if (typeof v === 'number') {
                    if (c.startsWith('pct')) rendered = <Badge estado={v >= 80 ? 'activo' : v >= 60 ? 'pendiente' : 'vencido'}>{v.toFixed(2)}%</Badge>;
                    else if (c.includes('total') || c.includes('costo') || c.includes('venta') || c.includes('margen') || c.includes('cobrado') || c.includes('cobrar') || c.includes('monto') || c.includes('ingreso') || c.includes('subtotal') || c.includes('iva')) rendered = fmt$(v);
                    else rendered = fmt(v);
                  } else rendered = String(v).slice(0, 40);
                  return <td key={c}>{rendered}</td>;
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <div className="card" style={{ marginTop: 24 }}>
        <div className="section-eyebrow">Composición del DW</div>
        <h3 style={tituloConLinea}>⭐ Dimensiones (11) + Hechos (5) + Vistas (24)</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16, fontSize: 12 }}>
          <div>
            <strong>Dimensiones tiempo</strong>
            <ul style={{ marginTop: 6 }}>
              <li>dw_dim_tiempo_dia (2020-2030)</li>
              <li>dw_dim_tiempo_semana (ISO)</li>
              <li>dw_dim_tiempo_mes</li>
              <li>dw_dim_tiempo_trimestre</li>
              <li>dw_dim_tiempo_anio</li>
            </ul>
          </div>
          <div>
            <strong>Dimensiones negocio</strong>
            <ul style={{ marginTop: 6 }}>
              <li>dw_dim_tenant</li>
              <li>dw_dim_empleado</li>
              <li>dw_dim_puesto</li>
              <li>dw_dim_sitio</li>
              <li>dw_dim_cliente</li>
              <li>dw_dim_geografia (estado, por sitio)</li>
            </ul>
          </div>
          <div>
            <strong>Hechos (grano día)</strong>
            <ul style={{ marginTop: 6 }}>
              <li>dw_hecho_asistencia_diaria</li>
              <li>dw_hecho_cobertura_sitio_dia</li>
              <li>dw_hecho_reservaciones</li>
              <li>dw_hecho_pagos_dispersados</li>
              <li>dw_hecho_facturas_cliente</li>
            </ul>
          </div>
        </div>
        <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 12 }}>
          Margen por puesto usa <code>tc_puestos.pago_default</code> como costo aproximado -- el
          tabulador real (<code>tp_sueldos_matriciales</code>) todavía no está cableado a ningún
          cálculo (pendiente conocido, ver CLAUDE.md §11), así que el costo puede salir en $0 para
          puestos que solo se tarifan por la matriz.
        </p>
      </div>
    </div>
  );
}
