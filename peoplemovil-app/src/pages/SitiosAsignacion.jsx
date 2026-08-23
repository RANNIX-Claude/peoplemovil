import React, { useEffect, useMemo, useState } from 'react';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import ToggleVista from '../components/ui/ToggleVista.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

const TIPOS = ['sucursal', 'tienda', 'obra', 'foro', 'oficina', 'evento', 'otro'];

export default function SitiosAsignacion() {
  useModuleAudit('sitios_asignacion');
  const [tab, setTab] = useState('sitios');
  const [sitios, setSitios] = useState([]);
  const [pedidos, setPedidos] = useState([]);
  const [selected, setSelected] = useState(null);
  const [nuevoSitio, setNuevoSitio] = useState({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [filtroTipo, setFiltroTipo] = useState('todos');
  const [vistaPedidos, setVistaPedidos] = useState('tabla');   // 'tabla' | 'calendario'
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: s }, { data: p }] = await Promise.all([
      supabase.from('tc_sitios').select('id, titulo, tipo_sitio, direccion_abreviada, activo').order('titulo'),
      supabase.from('te_pedidos').select('id, folio, titulo, fecha_evento, status').order('fecha_evento', { ascending: false }).limit(80)
    ]);
    setSitios(s || []); setPedidos(p || []);
  }
  useEffect(() => { cargar(); }, []);

  const sitiosFiltrados = useMemo(() => filtroTipo === 'todos' ? sitios : sitios.filter(s => s.tipo_sitio === filtroTipo), [sitios, filtroTipo]);
  const kpiSitiosActivos = sitios.filter(s => s.activo).length;
  const kpiPedidosProx   = pedidos.filter(p => new Date(p.fecha_evento) >= new Date()).length;

  async function altaSitio(e) {
    e.preventDefault();
    const { error } = await supabase.from('tc_sitios').insert({ ...nuevoSitio, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('Rechazado: ' + error.message); return; }
    await logAccion('sitios', 'INSERT', `sitio ${nuevoSitio.titulo}`);
    setNuevoSitio({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });
    setNuevoOpen(false); setMsg('Sitio creado'); cargar();
  }

  return (
    <div>
      <div className="section-eyebrow">Operación</div>
      <h1>Sitios y Asignación</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Sitios operativos y pedidos de personal. El plan FREE limita a 1 sitio activo (trigger en base).</p>

      <div className="kpi-grid">
        <KpiCard label="Sitios activos" value={kpiSitiosActivos} sub={`${sitios.length} totales`} onClick={() => setTab('sitios')} />
        <KpiCard label="Pedidos próximos" value={kpiPedidosProx} sub="fecha ≥ hoy" color="var(--green)" onClick={() => setTab('pedidos')} />
      </div>

      <div className="chips">
        <Chip active={tab === 'sitios'}  onClick={() => setTab('sitios')}>Sitios</Chip>
        <Chip active={tab === 'pedidos'} onClick={() => setTab('pedidos')}>Pedidos</Chip>
        <span style={{ flex: 1 }} />
        {tab === 'sitios' && <button className="btn" onClick={() => setNuevoOpen(true)}>+ Nuevo sitio</button>}
      </div>

      {tab === 'sitios' && (
        <>
          <div className="chips">
            <Chip active={filtroTipo === 'todos'} onClick={() => setFiltroTipo('todos')}>Todos</Chip>
            {TIPOS.map(t => (
              <Chip key={t} active={filtroTipo === t} onClick={() => setFiltroTipo(filtroTipo === t ? 'todos' : t)}>{t}</Chip>
            ))}
          </div>
          <TablaWrap>
            <table>
              <thead><tr><th>Sitio</th><th>Tipo</th><th>Dirección</th><th>Estado</th></tr></thead>
              <tbody>
                {sitiosFiltrados.length === 0 && <tr><td colSpan="4" className="empty">Sin sitios que coincidan.</td></tr>}
                {sitiosFiltrados.map(s => (
                  <tr key={s.id} className="clickable" onClick={() => setSelected(s)}>
                    <td style={{ fontWeight: 700 }}>{s.titulo}</td>
                    <td style={{ fontSize: 12, color: 'var(--muted)', textTransform: 'capitalize' }}>{s.tipo_sitio}</td>
                    <td style={{ fontSize: 12, color: 'var(--muted)' }}>{s.direccion_abreviada || '—'}</td>
                    <td><Badge estado={s.activo ? 'activo' : 'inactivo'}>{s.activo ? 'ACTIVO' : 'INACTIVO'}</Badge></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
        </>
      )}

      {tab === 'pedidos' && (
        <>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 12 }}>
            <ToggleVista
              activa={vistaPedidos}
              onChange={setVistaPedidos}
              opciones={[
                { value: 'tabla',      label: 'Tabla',      icono: '☰' },
                { value: 'calendario', label: 'Calendario', icono: '📅' }
              ]}
            />
          </div>
          {vistaPedidos === 'tabla' ? (
            <TablaWrap>
              <table>
                <thead><tr><th>Folio</th><th>Título</th><th>Fecha</th><th>Estado</th></tr></thead>
                <tbody>
                  {pedidos.length === 0 && <tr><td colSpan="4" className="empty">Sin pedidos. Requiere plan PRO — trigger tg_ped_plan verifica el plan del tenant al crear.</td></tr>}
                  {pedidos.map(p => (
                    <tr key={p.id}>
                      <td className="mono">#{p.folio}</td>
                      <td>{p.titulo}</td>
                      <td>{p.fecha_evento}</td>
                      <td style={{ fontSize: 12 }}>{p.status}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          ) : (
            <VistaCalendario pedidos={pedidos} />
          )}
        </>
      )}

      {msg && <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 12 }}>{msg}</p>}

      <Modal open={!!selected} onClose={() => setSelected(null)} title={selected?.titulo || ''}>
        {selected && (
          <div style={{ display: 'grid', gap: 12 }}>
            <div><div className="label">Tipo</div><div style={{ textTransform: 'capitalize' }}>{selected.tipo_sitio}</div></div>
            <div><div className="label">Dirección</div><div>{selected.direccion_abreviada || '—'}</div></div>
            <div><div className="label">Estado</div><Badge estado={selected.activo ? 'activo' : 'inactivo'}>{selected.activo ? 'ACTIVO' : 'INACTIVO'}</Badge></div>
          </div>
        )}
      </Modal>

      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title="Nuevo sitio"
        footer={<><button className="btn ghost" onClick={() => setNuevoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={altaSitio}>Crear</button></>}>
        <form onSubmit={altaSitio} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Nombre del sitio</label><input required className="field" value={nuevoSitio.titulo} onChange={e => setNuevoSitio({ ...nuevoSitio, titulo: e.target.value })} /></div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 12 }}>
            <div><label className="label">Tipo</label>
              <select className="field" value={nuevoSitio.tipo_sitio} onChange={e => setNuevoSitio({ ...nuevoSitio, tipo_sitio: e.target.value })}>
                {TIPOS.map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            <div><label className="label">Dirección</label><input className="field" value={nuevoSitio.direccion} onChange={e => setNuevoSitio({ ...nuevoSitio, direccion: e.target.value })} /></div>
          </div>
          <p style={{ fontSize: 11, color: 'var(--muted)' }}>Plan FREE = máximo 1 sitio activo (trigger tg_sitios_limite en base).</p>
        </form>
      </Modal>
    </div>
  );
}

function VistaCalendario({ pedidos }) {
  const hoy = new Date();
  const anio = hoy.getFullYear(), mes = hoy.getMonth();
  const primerDia = new Date(anio, mes, 1);
  const ultimoDia = new Date(anio, mes + 1, 0).getDate();
  const offsetInicio = (primerDia.getDay() + 6) % 7;   // lunes = 0
  const cells = [];
  for (let i = 0; i < offsetInicio; i++) cells.push(null);
  for (let d = 1; d <= ultimoDia; d++) cells.push(d);

  const byFecha = pedidos.reduce((acc, p) => {
    (acc[p.fecha_evento] ||= []).push(p);
    return acc;
  }, {});

  return (
    <div className="card" style={{ padding: 16 }}>
      <div style={{ fontWeight: 800, marginBottom: 12 }}>{primerDia.toLocaleDateString('es-MX', { month: 'long', year: 'numeric' })}</div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
        {['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].map(d =>
          <div key={d} style={{ fontSize: 11, fontWeight: 700, color: 'var(--muted)', textAlign: 'center', textTransform: 'uppercase' }}>{d}</div>
        )}
        {cells.map((d, i) => {
          if (d === null) return <div key={'e' + i} />;
          const iso = new Date(anio, mes, d).toISOString().slice(0, 10);
          const items = byFecha[iso] || [];
          return (
            <div key={d} style={{ minHeight: 84, border: '1px solid var(--border)', borderRadius: 8, padding: 6, background: 'var(--white)' }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--muted)' }}>{d}</div>
              {items.slice(0, 3).map(p => (
                <div key={p.id} className="chip on" style={{ fontSize: 10, padding: '2px 6px', margin: '3px 0', display: 'block', textAlign: 'left' }}>
                  #{p.folio} {p.titulo?.slice(0, 18)}
                </div>
              ))}
              {items.length > 3 && <div style={{ fontSize: 10, color: 'var(--muted)' }}>+{items.length - 3}</div>}
            </div>
          );
        })}
      </div>
    </div>
  );
}
