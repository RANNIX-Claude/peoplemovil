import React, { useEffect, useState } from 'react';
import Semaforo from '../components/Semaforo.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit } from '../lib/audit.js';

export default function Dashboard() {
  useModuleAudit('dashboard');
  const [kpis, setKpis] = useState({ sitios: 0, empleados: 0, pedidos_hoy: 0, cobertura: 0 });
  const [coberturas, setCoberturas] = useState([]);
  const [precauciones, setPrecauciones] = useState([]);
  const [drill, setDrill] = useState(null);   // {tipo, titulo, filas}

  useEffect(() => {
    if (!supabaseReady) return;
    (async () => {
      const [{ count: s }, { count: e }, { count: pHoy }, { data: prec }] = await Promise.all([
        supabase.from('tc_sitios').select('*', { count: 'exact', head: true }).eq('activo', true),
        supabase.from('te_empleados').select('*', { count: 'exact', head: true }).eq('activo', true),
        supabase.from('te_pedidos').select('*', { count: 'exact', head: true }).eq('fecha_evento', new Date().toISOString().slice(0, 10)),
        supabase.rpc('reporte_precauciones_nomina', { p_tenant: DEMO_TENANT_ID })
      ]);
      setKpis({ sitios: s || 0, empleados: e || 0, pedidos_hoy: pHoy || 0, cobertura: 0 });
      setPrecauciones(prec || []);
    })();
  }, []);

  async function drillSitios() {
    const { data } = await supabase.from('tc_sitios').select('titulo, tipo_sitio, activo').order('titulo');
    setDrill({ titulo: 'Sitios activos', filas: (data || []).map(r => [r.titulo, r.tipo_sitio, r.activo ? 'Activo' : 'Inactivo']),
      cols: ['Sitio', 'Tipo', 'Estado'] });
  }
  async function drillEmpleados() {
    const { data } = await supabase.from('te_empleados').select('folio, nombres, apellido_paterno, regimen_pago').eq('activo', true).order('folio');
    setDrill({ titulo: 'Empleados activos',
      filas: (data || []).map(r => [r.folio, `${r.nombres} ${r.apellido_paterno}`, r.regimen_pago]),
      cols: ['Folio', 'Nombre', 'Régimen'] });
  }
  async function drillPrecauciones() {
    setDrill({ titulo: 'Precauciones antes de cerrar nómina',
      filas: (precauciones || []).map(p => [p.nombre, (p.motivos || []).join(', ')]),
      cols: ['Empleado', 'Motivos'] });
  }

  return (
    <div>
      <div className="section-eyebrow">Vista general</div>
      <h1>Dashboard</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Estado operativo del tenant en un vistazo.</p>

      <div className="kpi-grid">
        <KpiCard label="Sitios activos"     value={kpis.sitios}     sub="tc_sitios · activo=true" onClick={drillSitios} />
        <KpiCard label="Empleados activos"  value={kpis.empleados}  sub="te_empleados · activo=true" onClick={drillEmpleados} />
        <KpiCard label="Pedidos hoy"        value={kpis.pedidos_hoy} sub={new Date().toLocaleDateString('es-MX')} color="var(--green)" />
        <KpiCard label="Precauciones nómina" value={precauciones.length} sub="antes de cerrar dispersión" color="var(--red)" onClick={precauciones.length ? drillPrecauciones : undefined} />
      </div>

      <div className="card-grid">
        <div className="card" style={{ margin: 0 }}>
          <div className="section-eyebrow">Cobertura por sitio</div>
          <h3 style={{ marginTop: 6 }}>Semáforo (verde &gt;80% · ámbar 60-80% · rojo &lt;60%)</h3>
          {coberturas.length === 0
            ? <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin pedidos activos aún — cuando los haya se listan aquí.</p>
            : <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 10 }}>
                {coberturas.map(c => (
                  <li key={c.sitio_id}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 4 }}>
                      <span style={{ fontWeight: 700 }}>{c.sitio}</span>
                      <span style={{ color: 'var(--muted)' }}>{c.confirmados}/{c.requeridos}</span>
                    </div>
                    <Semaforo porcentaje={c.pct} />
                  </li>
                ))}
              </ul>}
        </div>

        <div className="card" style={{ margin: 0 }}>
          <div className="section-eyebrow">Precauciones fiscales</div>
          <h3 style={{ marginTop: 6 }}>Antes de cerrar nómina</h3>
          {precauciones.length === 0
            ? <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin precauciones. Todo el personal tiene datos fiscales completos.</p>
            : <ul style={{ listStyle: 'none', fontSize: 12 }}>
                {precauciones.slice(0, 6).map(p => (
                  <li key={p.empleado_id} style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid var(--border)' }}>
                    <span style={{ fontWeight: 700 }}>{p.nombre}</span>
                    <Badge estado="vencido">{(p.motivos || []).join(' · ')}</Badge>
                  </li>
                ))}
                {precauciones.length > 6 && (
                  <li style={{ paddingTop: 8 }}>
                    <button className="btn ghost sm" onClick={drillPrecauciones}>Ver los {precauciones.length} →</button>
                  </li>
                )}
              </ul>}
        </div>
      </div>

      <div className="card">
        <p style={{ fontSize: 12, color: 'var(--muted)' }}>
          <strong style={{ color: 'var(--text)' }}>Cumplimiento LFT 2026-2027:</strong> el registro de asistencia
          está en modo append-only (RLS bloquea UPDATE/DELETE en <code>te_eventos_biometricos</code>). Cada evento está
          vinculado a un consentimiento vigente. Retención configurable en Configuración.
        </p>
      </div>

      <Modal open={!!drill} onClose={() => setDrill(null)} title={drill?.titulo || ''} wide>
        {drill && (
          <TablaWrap>
            <table>
              <thead><tr>{drill.cols.map(c => <th key={c}>{c}</th>)}</tr></thead>
              <tbody>
                {drill.filas.length === 0 && <tr><td colSpan={drill.cols.length} className="empty">Sin registros.</td></tr>}
                {drill.filas.map((f, i) => (
                  <tr key={i}>{f.map((v, j) => <td key={j}>{v}</td>)}</tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
        )}
      </Modal>
    </div>
  );
}
