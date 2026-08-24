import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import Modal from '../../components/ui/Modal.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// HU 1.02 — Calendario de entrevistas y postulaciones
// Vista calendario + gestión de grupos de citas para entrevistas grupales de candidatos
export default function CalendarioEntrevistas() {
  useModuleAudit('calendario_entrevistas');
  const [grupos, setGrupos] = useState([]);
  const [vacantes, setVacantes] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [mesActual, setMesActual] = useState(new Date());
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [nuevo, setNuevo] = useState({ fecha_cita: '', hora_inicio: '10:00', hora_fin: '12:00', vacante_publicacion_id: '', sitio_id: '', cupo_maximo: 15 });
  const [msg, setMsg] = useState('');

  const cargar = async () => {
    if (!supabaseReady) return;
    const [{ data: g }, { data: v }, { data: s }] = await Promise.all([
      supabase.from('te_grupos_citas').select('*, te_vacantes(titulo)').order('fecha_cita'),
      supabase.from('te_vacantes').select('id, titulo').eq('estado', 'publicada'),
      supabase.from('tc_sitios').select('id, titulo').eq('activo', true)
    ]);
    setGrupos(g || []); setVacantes(v || []); setSitios(s || []);
  };
  useEffect(() => { cargar(); }, []);

  const agregar = async e => {
    e.preventDefault();
    const { error } = await supabase.from('te_grupos_citas').insert({
      ...nuevo,
      tenant_id: DEMO_TENANT_ID,
      cupo_maximo: parseInt(nuevo.cupo_maximo) || 15
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('calendario_entrevistas', 'INSERT', `grupo ${nuevo.fecha_cita} ${nuevo.hora_inicio}`);
    setNuevoOpen(false);
    setNuevo({ fecha_cita: '', hora_inicio: '10:00', hora_fin: '12:00', vacante_publicacion_id: '', sitio_id: '', cupo_maximo: 15 });
    setMsg('✓ Grupo creado');
    cargar();
  };

  // Grid mensual
  const cells = useMemo(() => {
    const y = mesActual.getFullYear(), m = mesActual.getMonth();
    const first = new Date(y, m, 1);
    const last = new Date(y, m + 1, 0).getDate();
    const off = (first.getDay() + 6) % 7;
    const arr = [];
    for (let i = 0; i < off; i++) arr.push(null);
    for (let d = 1; d <= last; d++) arr.push(d);
    return arr;
  }, [mesActual]);

  const grupoPorFecha = useMemo(() => {
    const g = {};
    for (const gr of grupos) g[gr.fecha_cita] = g[gr.fecha_cita] ? [...g[gr.fecha_cita], gr] : [gr];
    return g;
  }, [grupos]);

  const kpi_prox = grupos.filter(g => g.fecha_cita >= new Date().toISOString().slice(0,10) && g.estatus === 'vigente').length;
  const kpi_ocup = grupos.reduce((s, g) => s + Number(g.cupo_actual || 0), 0);
  const kpi_max  = grupos.reduce((s, g) => s + Number(g.cupo_maximo || 0), 0);

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento · HU 1.02</div>
      <h1>Calendario de entrevistas</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Grupos de citas para entrevistas grupales. Los candidatos los eligen desde el portal público al postularse.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Grupos próximos" value={kpi_prox} sub="vigentes" color="var(--green)" />
        <KpiCard label="Cupo ocupado" value={kpi_ocup} sub={`de ${kpi_max}`} />
        <KpiCard label="Vacantes publicadas" value={vacantes.length} sub="con grupos" color="var(--accent2)" />
      </div>

      <div className="card" style={{ padding: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <button className="btn ghost sm" onClick={() => setMesActual(new Date(mesActual.getFullYear(), mesActual.getMonth() - 1, 1))}>←</button>
          <strong style={{ minWidth: 200, textAlign: 'center' }}>{mesActual.toLocaleDateString('es-MX', { month: 'long', year: 'numeric' })}</strong>
          <button className="btn ghost sm" onClick={() => setMesActual(new Date(mesActual.getFullYear(), mesActual.getMonth() + 1, 1))}>→</button>
          <button className="btn ghost sm" onClick={() => setMesActual(new Date())}>Hoy</button>
        </div>
        <button className="btn" onClick={() => setNuevoOpen(true)}>+ Nuevo grupo</button>
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <div className="card" style={{ padding: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4, marginBottom: 8 }}>
          {['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'].map(d => (
            <div key={d} style={{ fontSize: 11, fontWeight: 800, color: 'var(--muted)', textAlign: 'center', textTransform: 'uppercase', padding: 4 }}>{d}</div>
          ))}
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
          {cells.map((d, i) => {
            if (d === null) return <div key={'e' + i} />;
            const iso = new Date(mesActual.getFullYear(), mesActual.getMonth(), d).toISOString().slice(0, 10);
            const items = grupoPorFecha[iso] || [];
            const esHoy = iso === new Date().toISOString().slice(0, 10);
            return (
              <div key={d} style={{
                minHeight: 90, border: `1px solid ${esHoy ? 'var(--accent)' : 'var(--border)'}`,
                borderRadius: 8, padding: 6, background: esHoy ? 'var(--accent-light)' : 'var(--white)'
              }}>
                <div style={{ fontSize: 11, fontWeight: 800, color: esHoy ? 'var(--accent)' : 'var(--text)' }}>{d}</div>
                {items.map(g => (
                  <div key={g.id} className="chip on" style={{ fontSize: 10, padding: '2px 6px', margin: '3px 0', display: 'block', textAlign: 'left' }}>
                    🕐 {g.hora_inicio} · {g.cupo_actual}/{g.cupo_maximo}
                  </div>
                ))}
              </div>
            );
          })}
        </div>
      </div>

      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title="Nuevo grupo de citas"
        footer={<><button className="btn ghost" onClick={() => setNuevoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregar}>Crear</button></>}>
        <form onSubmit={agregar} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Vacante *</label>
            <select required className="field" value={nuevo.vacante_publicacion_id} onChange={e => setNuevo({...nuevo, vacante_publicacion_id: e.target.value})}>
              <option value="">— elegir vacante —</option>
              {vacantes.map(v => <option key={v.id} value={v.id}>{v.titulo}</option>)}
            </select>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
            <div><label className="label">Fecha *</label><input required type="date" className="field" value={nuevo.fecha_cita} onChange={e => setNuevo({...nuevo, fecha_cita: e.target.value})} /></div>
            <div><label className="label">Hora inicio</label><input required type="time" className="field" value={nuevo.hora_inicio} onChange={e => setNuevo({...nuevo, hora_inicio: e.target.value})} /></div>
            <div><label className="label">Hora fin</label><input type="time" className="field" value={nuevo.hora_fin} onChange={e => setNuevo({...nuevo, hora_fin: e.target.value})} /></div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: 10 }}>
            <div><label className="label">Sitio</label>
              <select className="field" value={nuevo.sitio_id} onChange={e => setNuevo({...nuevo, sitio_id: e.target.value})}>
                <option value="">— sin sitio —</option>
                {sitios.map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
            </div>
            <div><label className="label">Cupo</label><input type="number" min="1" className="field" value={nuevo.cupo_maximo} onChange={e => setNuevo({...nuevo, cupo_maximo: e.target.value})} /></div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
