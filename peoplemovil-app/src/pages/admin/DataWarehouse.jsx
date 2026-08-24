import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Chip from '../../components/ui/Chip.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

const VISTAS = [
  { key: 'v_asistencia_por_mes',       label: 'Asistencia por mes',      icon: '📅' },
  { key: 'v_cobertura_por_sitio_mes',  label: 'Cobertura por sitio',     icon: '📍' },
  { key: 'v_pagos_por_regimen_mes',    label: 'Pagos por régimen',       icon: '💰' },
  { key: 'v_facturas_por_cliente_mes', label: 'Facturas por cliente',    icon: '🧾' },
  { key: 'v_margen_por_puesto_mes',    label: 'Margen por puesto',       icon: '📊' },
  { key: 'v_top_empleados_puntualidad', label: 'Top puntualidad',        icon: '⭐' }
];

const fmt = n => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 2 });
const fmt$ = n => '$' + fmt(n);

export default function DataWarehouse() {
  useModuleAudit('data_warehouse');
  const [vistaActiva, setVistaActiva] = useState(VISTAS[0]);
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [ultimoEtl, setUltimoEtl] = useState(null);
  const [msg, setMsg] = useState(null);

  useEffect(() => { cargar(); }, [vistaActiva]);
  async function cargar() {
    if (!supabaseReady) return;
    setLoading(true);
    const { data, error } = await supabase.schema('dw').from(vistaActiva.key).select('*').limit(500);
    if (error) setMsg('⚠ ' + error.message);
    else { setRows(data || []); setMsg(null); }
    setLoading(false);
  }

  async function refrescarETL() {
    setMsg('Refrescando DW…');
    const { data, error } = await supabase.schema('dw').rpc('refrescar_todo');
    if (error) { setMsg('❌ ' + error.message); return; }
    setUltimoEtl(data);
    await logAccion('data_warehouse', 'ETL', JSON.stringify(data));
    setMsg('✓ DW refrescado: ' + JSON.stringify(data));
    cargar();
  }

  const columnas = rows[0] ? Object.keys(rows[0]).filter(c => c !== 'tenant_id') : [];

  return (
    <div>
      <div className="section-eyebrow">Analítica</div>
      <h1>Data Warehouse</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        6 vistas analíticas con dimensiones de tiempo y hechos calculados desde las operacionales.
        ETL idempotente — corre <code>dw.refrescar_todo()</code> cuando necesites recalcular.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Vistas disponibles" value={VISTAS.length} sub="analíticas listas" />
        <KpiCard label="Filas en vista actual" value={rows.length.toLocaleString('es-MX')} sub={vistaActiva.label} />
        <KpiCard label="Último ETL" value={ultimoEtl ? '✓' : '—'} sub={ultimoEtl ? new Date(ultimoEtl.refrescado_en).toLocaleString('es-MX') : 'Presiona Refrescar'} color="var(--accent2)" onClick={refrescarETL} drillLabel="Refrescar DW →" />
      </div>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 12 }}>{msg}</div>}

      <div className="chips">
        {VISTAS.map(v => (
          <Chip key={v.key} active={vistaActiva.key === v.key} onClick={() => setVistaActiva(v)}>
            {v.icon} {v.label}
          </Chip>
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
                {loading ? 'Cargando…' : 'Sin datos aún. Presiona "Refrescar DW →" en la card superior para poblar los hechos.'}
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
                    else if (c.includes('total') || c.includes('costo') || c.includes('venta') || c.includes('margen') || c.includes('cobrado') || c.includes('cobrar')) rendered = fmt$(v);
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
        <h3>Dimensiones (9) + Hechos (5) + Vistas (6)</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16, fontSize: 12 }}>
          <div>
            <strong>Dimensiones tiempo</strong>
            <ul style={{ marginTop: 6 }}>
              <li>dim_tiempo_dia (2020-2030)</li>
              <li>dim_tiempo_mes</li>
              <li>dim_tiempo_trimestre</li>
              <li>dim_tiempo_anio</li>
            </ul>
          </div>
          <div>
            <strong>Dimensiones negocio</strong>
            <ul style={{ marginTop: 6 }}>
              <li>dim_tenant</li>
              <li>dim_empleado</li>
              <li>dim_puesto</li>
              <li>dim_sitio</li>
              <li>dim_cliente</li>
            </ul>
          </div>
          <div>
            <strong>Hechos</strong>
            <ul style={{ marginTop: 6 }}>
              <li>hecho_asistencia_diaria</li>
              <li>hecho_cobertura_sitio_dia</li>
              <li>hecho_reservaciones</li>
              <li>hecho_pagos_dispersados</li>
              <li>hecho_facturas_cliente</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
