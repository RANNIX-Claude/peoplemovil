import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import Modal from '../../components/ui/Modal.jsx';
import Chip from '../../components/ui/Chip.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';
import { subirImagenBacklog, resolverUrlBacklog, eliminarImagenBacklog } from '../../lib/storage.js';

// Backlog de funcionalidad -- seguimiento del inventario hecho/pendiente por
// portal (pedido del usuario 2026-10-09, Migración 027): cada hallazgo tiene
// evidencia (imágenes), observaciones, estado (pendiente/en_proceso/atendido)
// y se puede agrupar en paquetes de trabajo ("Sprint 1", "Sprint 2"...).

const PORTAL_LABEL = { admin: '🛠️ Admin', freelance: '🧑‍🔧 Freelance', publico: '🌐 Público', backend: '⚙️ Backend' };
const ESTADOS = [
  { k: 'pendiente', label: 'Pendiente', badge: 'pendiente' },
  { k: 'en_proceso', label: 'En proceso', badge: 'proceso' },
  { k: 'atendido', label: 'Atendido', badge: 'activo' },
];
const badgeEstado = k => ESTADOS.find(e => e.k === k)?.badge || 'inactivo';
const labelEstado = k => ESTADOS.find(e => e.k === k)?.label || k;

function ImagenMini({ path, onBorrar }) {
  const [url, setUrl] = useState(null);
  useEffect(() => { let activo = true; resolverUrlBacklog(path).then(u => { if (activo) setUrl(u); }); return () => { activo = false; }; }, [path]);
  return (
    <div style={{ position: 'relative', width: 84, height: 84, borderRadius: 8, overflow: 'hidden', border: '1px solid var(--border)', flex: '0 0 auto' }}>
      {url ? <img src={url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : <div style={{ width: '100%', height: '100%', background: 'var(--surface)' }} />}
      {onBorrar && (
        <button type="button" onClick={onBorrar} title="Quitar imagen"
          style={{ position: 'absolute', top: 2, right: 2, width: 20, height: 20, borderRadius: '50%', border: 'none', background: 'rgba(0,0,0,.6)', color: '#fff', cursor: 'pointer', fontSize: 12, lineHeight: '20px', padding: 0 }}>×</button>
      )}
    </div>
  );
}

export default function BacklogFuncionalidad() {
  useModuleAudit('backlog_funcionalidad');
  const [items, setItems] = useState([]);
  const [imagenes, setImagenes] = useState({}); // item_id -> [{id, storage_path}]
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState('');

  const [fPortal, setFPortal] = useState('todos');
  const [fEstado, setFEstado] = useState('todos');
  const [fSprint, setFSprint] = useState('todos');
  const [busqueda, setBusqueda] = useState('');

  const [detalle, setDetalle] = useState(null); // item en edición (modal)
  const [draft, setDraft] = useState({});
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [nuevo, setNuevo] = useState({ portal: 'admin', grupo: '', titulo: '', ruta: '', descripcion: '' });
  const [subiendo, setSubiendo] = useState(false);

  const cargar = async () => {
    if (!supabaseReady) return;
    setLoading(true);
    const [{ data: it, error: e1 }, { data: img, error: e2 }] = await Promise.all([
      supabase.from('te_backlog_items').select('*').order('portal').order('grupo').order('orden'),
      supabase.from('te_backlog_imagenes').select('id, item_id, storage_path').order('subida_en'),
    ]);
    if (e1 || e2) setMsg('⚠ ' + (e1 || e2).message);
    else {
      setItems(it || []);
      const porItem = {};
      (img || []).forEach(i => { (porItem[i.item_id] ||= []).push(i); });
      setImagenes(porItem);
      setMsg('');
    }
    setLoading(false);
  };
  useEffect(() => { cargar(); }, []);

  const sprints = useMemo(() => {
    const s = new Set(items.map(i => i.sprint).filter(Boolean));
    return Array.from(s).sort();
  }, [items]);

  const filtrados = useMemo(() => {
    const q = busqueda.trim().toLowerCase();
    return items.filter(i => {
      if (fPortal !== 'todos' && i.portal !== fPortal) return false;
      if (fEstado !== 'todos' && i.estado !== fEstado) return false;
      if (fSprint === '__sin__' && i.sprint) return false;
      if (fSprint !== 'todos' && fSprint !== '__sin__' && i.sprint !== fSprint) return false;
      if (q) {
        const hay = `${i.titulo} ${i.grupo} ${i.ruta || ''} ${i.descripcion || ''}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [items, fPortal, fEstado, fSprint, busqueda]);

  const agrupados = useMemo(() => {
    const porPortal = {};
    filtrados.forEach(i => {
      (porPortal[i.portal] ||= {});
      (porPortal[i.portal][i.grupo] ||= []).push(i);
    });
    return porPortal;
  }, [filtrados]);

  const pctAtendido = () => {
    if (!items.length) return 0;
    return Math.round((items.filter(i => i.estado === 'atendido').length / items.length) * 100);
  };

  function abrirDetalle(item) {
    setDetalle(item);
    setDraft({ descripcion: item.descripcion || '', estado: item.estado, sprint: item.sprint || '' });
  }

  async function guardarDetalle() {
    if (!detalle) return;
    const { error } = await supabase.from('te_backlog_items').update({
      descripcion: draft.descripcion || null,
      estado: draft.estado,
      sprint: draft.sprint.trim() || null,
    }).eq('id', detalle.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('backlog_funcionalidad', 'UPDATE', `${detalle.titulo} -> ${draft.estado}${draft.sprint ? ' / ' + draft.sprint : ''}`);
    setMsg('✓ Guardado'); setDetalle(null); cargar();
  }

  async function subirImagenes(e) {
    const files = Array.from(e.target.files || []);
    e.target.value = '';
    if (!files.length || !detalle) return;
    setSubiendo(true);
    try {
      for (const file of files) {
        const path = await subirImagenBacklog(DEMO_TENANT_ID, detalle.id, file);
        const { error } = await supabase.from('te_backlog_imagenes').insert({ item_id: detalle.id, storage_path: path });
        if (error) throw error;
      }
      await logAccion('backlog_funcionalidad', 'INSERT', `${files.length} imagen(es) subida(s) a ${detalle.titulo}`);
      const { data } = await supabase.from('te_backlog_imagenes').select('id, item_id, storage_path').eq('item_id', detalle.id).order('subida_en');
      setImagenes(prev => ({ ...prev, [detalle.id]: data || [] }));
    } catch (err) { setMsg('No se pudo subir la imagen: ' + err.message); }
    setSubiendo(false);
  }

  async function borrarImagen(img) {
    if (!confirm('¿Quitar esta imagen?')) return;
    await eliminarImagenBacklog(img.storage_path);
    const { error } = await supabase.from('te_backlog_imagenes').delete().eq('id', img.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    setImagenes(prev => ({ ...prev, [detalle.id]: (prev[detalle.id] || []).filter(x => x.id !== img.id) }));
  }

  async function crearItem(e) {
    e.preventDefault();
    if (!nuevo.grupo.trim() || !nuevo.titulo.trim()) { setMsg('Completá al menos grupo y título.'); return; }
    const { error } = await supabase.from('te_backlog_items').insert({
      portal: nuevo.portal, grupo: nuevo.grupo.trim(), titulo: nuevo.titulo.trim(),
      ruta: nuevo.ruta.trim() || null, descripcion: nuevo.descripcion.trim() || null,
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('backlog_funcionalidad', 'INSERT', nuevo.titulo);
    setNuevo({ portal: 'admin', grupo: '', titulo: '', ruta: '', descripcion: '' });
    setNuevoOpen(false); setMsg('✓ Agregado'); cargar();
  }

  if (!supabaseReady) return <div className="card" style={{ margin: 20 }}>Conectá Supabase para usar el backlog de funcionalidad.</div>;

  return (
    <div style={{ padding: 20 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 10 }}>
        <div>
          <h1 style={{ margin: 0 }}>Backlog de funcionalidad</h1>
          <p style={{ color: 'var(--muted)', margin: '4px 0 0', fontSize: 13 }}>
            Hallazgos y pendientes por portal, con evidencia y seguimiento -- se va depurando aquí mismo, sprint por sprint.
          </p>
        </div>
        <button className="btn" onClick={() => setNuevoOpen(true)}>+ Nuevo hallazgo</button>
      </div>

      <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', margin: '16px 0' }}>
        <KpiCard label="Total" value={items.length} />
        <KpiCard label="Pendientes" value={items.filter(i => i.estado === 'pendiente').length} color="var(--gold)" />
        <KpiCard label="En proceso" value={items.filter(i => i.estado === 'en_proceso').length} color="var(--accent)" />
        <KpiCard label="Atendidos" value={items.filter(i => i.estado === 'atendido').length} color="var(--green)" />
        <KpiCard label="% de bateo" value={pctAtendido() + '%'} color="var(--accent2)" />
      </div>

      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', alignItems: 'center', margin: '0 0 16px' }}>
        <input className="field" placeholder="Buscar hallazgo…" value={busqueda} onChange={e => setBusqueda(e.target.value)} style={{ maxWidth: 220 }} />
        <Chip active={fPortal === 'todos'} onClick={() => setFPortal('todos')}>Todos los portales</Chip>
        {Object.entries(PORTAL_LABEL).map(([k, l]) => (
          <Chip key={k} active={fPortal === k} onClick={() => setFPortal(fPortal === k ? 'todos' : k)}>{l}</Chip>
        ))}
        <span style={{ width: 1, alignSelf: 'stretch', background: 'var(--border)' }} />
        <Chip active={fEstado === 'todos'} onClick={() => setFEstado('todos')}>Cualquier estado</Chip>
        {ESTADOS.map(e => (
          <Chip key={e.k} active={fEstado === e.k} onClick={() => setFEstado(fEstado === e.k ? 'todos' : e.k)}>{e.label}</Chip>
        ))}
        {sprints.length > 0 && (
          <>
            <span style={{ width: 1, alignSelf: 'stretch', background: 'var(--border)' }} />
            <select className="field" value={fSprint} onChange={e => setFSprint(e.target.value)} style={{ maxWidth: 170 }}>
              <option value="todos">Cualquier sprint</option>
              <option value="__sin__">Sin asignar</option>
              {sprints.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </>
        )}
      </div>

      {loading && <p style={{ color: 'var(--muted)' }}>Cargando…</p>}
      {msg && <p style={{ fontSize: 13 }}>{msg}</p>}

      {Object.entries(agrupados).map(([portal, grupos]) => (
        <div key={portal} style={{ marginBottom: 22 }}>
          <h2 style={{ fontSize: 14, textTransform: 'uppercase', letterSpacing: '.03em', color: 'var(--accent)', margin: '0 0 8px' }}>
            {PORTAL_LABEL[portal] || portal}
          </h2>
          {Object.entries(grupos).map(([grupo, lista]) => (
            <div key={grupo} style={{ marginBottom: 14 }}>
              <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--muted)', margin: '0 0 6px' }}>{grupo}</div>
              {lista.map(item => (
                <div key={item.id} className="card" style={{ margin: '0 0 8px', padding: '10px 14px', cursor: 'pointer' }} onClick={() => abrirDetalle(item)}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
                    <div style={{ minWidth: 0 }}>
                      <div style={{ fontWeight: 700, fontSize: 14 }}>{item.titulo}</div>
                      {item.ruta && <div style={{ fontSize: 11, color: 'var(--muted)', fontFamily: 'monospace' }}>{item.ruta}</div>}
                    </div>
                    <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexShrink: 0 }}>
                      {item.sprint && <span className="chip" style={{ fontSize: 11 }}>{item.sprint}</span>}
                      {(imagenes[item.id] || []).length > 0 && <span style={{ fontSize: 11, color: 'var(--muted)' }}>📷 {imagenes[item.id].length}</span>}
                      <Badge estado={badgeEstado(item.estado)}>{labelEstado(item.estado)}</Badge>
                    </div>
                  </div>
                  {item.descripcion && <div style={{ fontSize: 12.5, color: 'var(--muted)', marginTop: 6, lineHeight: 1.4 }}>{item.descripcion}</div>}
                </div>
              ))}
            </div>
          ))}
        </div>
      ))}
      {!loading && filtrados.length === 0 && <div className="card" style={{ padding: 24, textAlign: 'center', color: 'var(--muted)' }}>Nada con estos filtros.</div>}

      <Modal open={!!detalle} onClose={() => setDetalle(null)} title={detalle?.titulo} wide
        footer={<button className="btn" onClick={guardarDetalle}>Guardar</button>}>
        {detalle && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ fontSize: 12, fontWeight: 700, display: 'block', marginBottom: 4 }}>Estado</label>
              <div style={{ display: 'flex', gap: 6 }}>
                {ESTADOS.map(e => (
                  <button key={e.k} type="button" className="chip" aria-pressed={draft.estado === e.k}
                    style={draft.estado === e.k ? { background: 'var(--accent)', color: '#fff', borderColor: 'var(--accent)' } : undefined}
                    onClick={() => setDraft(d => ({ ...d, estado: e.k }))}>{e.label}</button>
                ))}
              </div>
            </div>
            <div>
              <label style={{ fontSize: 12, fontWeight: 700, display: 'block', marginBottom: 4 }}>Paquete de trabajo (sprint)</label>
              <input className="field" list="lista-sprints" placeholder="p.ej. Sprint 1"
                value={draft.sprint} onChange={e => setDraft(d => ({ ...d, sprint: e.target.value }))} />
              <datalist id="lista-sprints">{sprints.map(s => <option key={s} value={s} />)}</datalist>
            </div>
            <div>
              <label style={{ fontSize: 12, fontWeight: 700, display: 'block', marginBottom: 4 }}>Observaciones</label>
              <textarea className="field" rows={5} value={draft.descripcion}
                onChange={e => setDraft(d => ({ ...d, descripcion: e.target.value }))}
                placeholder="Qué se encontró, qué falta, decisiones tomadas…" />
            </div>
            <div>
              <label style={{ fontSize: 12, fontWeight: 700, display: 'block', marginBottom: 4 }}>Imágenes de evidencia</label>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 8 }}>
                {(imagenes[detalle.id] || []).map(img => (
                  <ImagenMini key={img.id} path={img.storage_path} onBorrar={() => borrarImagen(img)} />
                ))}
              </div>
              <input type="file" accept="image/*" multiple onChange={subirImagenes} disabled={subiendo} />
              {subiendo && <span style={{ fontSize: 12, color: 'var(--muted)', marginLeft: 8 }}>Subiendo…</span>}
            </div>
          </div>
        )}
      </Modal>

      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title="Nuevo hallazgo"
        footer={<button className="btn" onClick={crearItem}>Agregar</button>}>
        <form onSubmit={crearItem} style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <label style={{ fontSize: 12, fontWeight: 700 }}>Portal
            <select className="field" value={nuevo.portal} onChange={e => setNuevo(n => ({ ...n, portal: e.target.value }))}>
              {Object.entries(PORTAL_LABEL).map(([k, l]) => <option key={k} value={k}>{l}</option>)}
            </select>
          </label>
          <label style={{ fontSize: 12, fontWeight: 700 }}>Grupo / sección
            <input className="field" value={nuevo.grupo} onChange={e => setNuevo(n => ({ ...n, grupo: e.target.value }))} placeholder="p.ej. Operación" />
          </label>
          <label style={{ fontSize: 12, fontWeight: 700 }}>Título
            <input className="field" value={nuevo.titulo} onChange={e => setNuevo(n => ({ ...n, titulo: e.target.value }))} placeholder="Qué pantalla o función es" />
          </label>
          <label style={{ fontSize: 12, fontWeight: 700 }}>Ruta / archivo (opcional)
            <input className="field" value={nuevo.ruta} onChange={e => setNuevo(n => ({ ...n, ruta: e.target.value }))} placeholder="/admin/sitios" />
          </label>
          <label style={{ fontSize: 12, fontWeight: 700 }}>Observación inicial (opcional)
            <textarea className="field" rows={3} value={nuevo.descripcion} onChange={e => setNuevo(n => ({ ...n, descripcion: e.target.value }))} />
          </label>
        </form>
      </Modal>
    </div>
  );
}
