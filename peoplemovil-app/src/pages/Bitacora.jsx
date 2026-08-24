import React, { useEffect, useMemo, useState } from 'react';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { supabase, supabaseReady } from '../lib/supabase.js';
import { useModuleAudit } from '../lib/audit.js';

export default function Bitacora() {
  useModuleAudit('bitacora');
  const [rows, setRows] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [filtroAccion, setFiltroAccion] = useState('todas');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('tl_registro_modulos').select('*').order('ts_servidor', { ascending: false }).limit(300)
      .then(({ data }) => setRows(data || []));
  }, []);

  const acciones = useMemo(() => [...new Set(rows.map(r => r.accion))], [rows]);
  const filtradas = useMemo(() => rows.filter(r =>
    (filtroAccion === 'todas' || r.accion === filtroAccion) &&
    (!busqueda || `${r.modulo} ${r.accion} ${r.detalle}`.toLowerCase().includes(busqueda.toLowerCase()))
  ), [rows, busqueda, filtroAccion]);

  const hoy = new Date().toISOString().slice(0, 10);
  const kpiHoy   = rows.filter(r => r.ts_servidor?.startsWith(hoy)).length;
  const kpiTotal = rows.length;
  const kpiMods  = new Set(rows.map(r => r.modulo)).size;

  const colorAccion = a => a === 'DELETE' ? 'vencido' : a === 'UPDATE' ? 'pendiente' : a === 'INSERT' ? 'proceso' : 'inactivo';

  return (
    <div>
      <div className="section-eyebrow">Soporte técnico / Dev</div>
      <h1>Bitácora de accesos</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Registro de cada acceso a un módulo y de cada acción con blast-radius (INSERT/UPDATE/DELETE/CALCULAR).
        Alimentada por <code>useModuleAudit()</code> y <code>logAccion()</code>.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Eventos hoy"     value={kpiHoy} sub={hoy} color="var(--green)" />
        <KpiCard label="Últimos 300"     value={kpiTotal} sub="máximo cargado" />
        <KpiCard label="Módulos activos" value={kpiMods} sub="con actividad" color="var(--accent2)" />
      </div>

      <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap', marginBottom: 8 }}>
        <input className="field" style={{ maxWidth: 320 }} placeholder="Buscar por módulo, acción o detalle…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
        <div className="chips" style={{ margin: 0 }}>
          <Chip active={filtroAccion === 'todas'} onClick={() => setFiltroAccion('todas')}>Todas</Chip>
          {acciones.map(a => (
            <Chip key={a} active={filtroAccion === a} onClick={() => setFiltroAccion(filtroAccion === a ? 'todas' : a)}>{a}</Chip>
          ))}
        </div>
      </div>

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Timestamp servidor</th><th>Módulo</th><th>Acción</th><th>Actor</th><th>Detalle</th></tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && <tr><td colSpan="5" className="empty">Sin eventos que coincidan. Empezá a navegar la app para que se pueble.</td></tr>}
            {filtradas.map(r => (
              <tr key={r.id}>
                <td className="mono">{new Date(r.ts_servidor).toLocaleString('es-MX')}</td>
                <td style={{ fontWeight: 700 }}>{r.modulo}</td>
                <td><Badge estado={colorAccion(r.accion)}>{r.accion}</Badge></td>
                <td className="mono" style={{ fontSize: 11 }}>{r.actor_id ? String(r.actor_id).slice(0, 8) + '…' : '—'}</td>
                <td style={{ fontSize: 12, color: 'var(--muted)' }}>{r.detalle || ''}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
    </div>
  );
}
