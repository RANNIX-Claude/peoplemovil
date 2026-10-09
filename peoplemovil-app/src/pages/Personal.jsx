import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import ToggleVista from '../components/ui/ToggleVista.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';
import { resolverUrlArchivo } from '../lib/storage.js';

function iniciales(nombres, apPat) {
  return `${(nombres || '?').trim()[0] || ''}${(apPat || '').trim()[0] || ''}`.toUpperCase();
}

// Avatar con foto (resuelta bajo demanda, puede ser URL pública demo o path
// del bucket privado) o iniciales como respaldo — mismo criterio que el
// expediente completo del empleado.
function Avatar({ empleado, size = 40 }) {
  const [url, setUrl] = useState(null);
  useEffect(() => {
    let activo = true;
    if (empleado.foto_url) resolverUrlArchivo(empleado.foto_url).then(u => { if (activo) setUrl(u); });
    return () => { activo = false; };
  }, [empleado.foto_url]);
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', flexShrink: 0, overflow: 'hidden',
      background: 'var(--accent-light)', border: '1px solid var(--border)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {url
        ? <img src={url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
        : <span style={{ fontSize: size * 0.4, fontWeight: 800, color: 'var(--accent)' }}>{iniciales(empleado.nombres, empleado.apellido_paterno)}</span>}
    </div>
  );
}

// Agrupa empleados activos por una categoría (puesto, sitio, régimen...) para
// la vista de "tablas dinámicas" — cuenta rápida sin duplicar nada en la base,
// todo derivado de lo que ya se cargó para la lista.
function agruparPor(empleados, getEtiqueta) {
  const map = new Map();
  for (const e of empleados) {
    const key = getEtiqueta(e) || 'Sin asignar';
    map.set(key, (map.get(key) || 0) + 1);
  }
  return [...map.entries()].sort((a, b) => b[1] - a[1]);
}

function TablaPivot({ titulo, filas, onFiltrar }) {
  const total = filas.reduce((s, [, n]) => s + n, 0);
  return (
    <div className="card">
      <h3 style={{ marginTop: 0 }}>{titulo}</h3>
      {filas.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin datos con los filtros actuales.</p>}
      {filas.map(([label, n]) => (
        <div key={label} style={{ marginBottom: 10, cursor: onFiltrar ? 'pointer' : 'default' }}
          onClick={() => onFiltrar?.(label)} title={onFiltrar ? 'Clic para filtrar la lista por este valor' : undefined}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 3 }}>
            <span>{label}</span><strong>{n}</strong>
          </div>
          <div className="semaforo-bar" style={{ height: 6 }}>
            <div className="semaforo-fill g" style={{ width: `${total ? Math.round((n / total) * 100) : 0}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}

const VISTAS = [
  { value: 'mosaico', label: 'Mosaico', icono: '🔲' },
  { value: 'lista', label: 'Lista', icono: '📋' },
  { value: 'resumen', label: 'Tablas dinámicas', icono: '📊' },
];

export default function Personal() {
  useModuleAudit('personal');
  const navigate = useNavigate();
  const [tab, setTab] = useState('empleados');
  const [vista, setVista] = useState('mosaico');
  const [empleados, setEmpleados] = useState([]);
  const [candidatos, setCandidatos] = useState([]);
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [nuevoCand, setNuevoCand] = useState({ nombres: '', apellido_paterno: '', rfc: '', curp: '', sexo: 'M', paso_induccion: false });
  const [filtroRegimen, setFiltroRegimen] = useState('todos');
  const [filtroPuesto, setFiltroPuesto] = useState('todos');
  const [filtroSitio, setFiltroSitio] = useState('todos');
  const [busqueda, setBusqueda] = useState('');
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: e }, { data: c }] = await Promise.all([
      supabase.from('te_empleados')
        .select('id, folio, nombres, apellido_paterno, apellido_materno, activo, regimen_pago, tipo_empleado, id_banco, clabe, correo, telefono, foto_url, puesto:tc_puestos(titulo, pago_default), sitio:tc_sitios(titulo)')
        .order('folio'),
      supabase.from('te_candidatos').select('id, nombres, apellido_paterno, rfc, paso_induccion, promovido_a_empleado, sexo').order('creado_en', { ascending: false })
    ]);
    setEmpleados(e || []); setCandidatos(c || []);
  }
  useEffect(() => { cargar(); }, []);

  const puestosUnicos = useMemo(() => [...new Set(empleados.map(e => e.puesto?.titulo).filter(Boolean))].sort(), [empleados]);
  const sitiosUnicos = useMemo(() => [...new Set(empleados.map(e => e.sitio?.titulo).filter(Boolean))].sort(), [empleados]);

  const empleadosFiltrados = useMemo(() => empleados.filter(e =>
    (filtroRegimen === 'todos' || e.regimen_pago === filtroRegimen) &&
    (filtroPuesto === 'todos' || e.puesto?.titulo === filtroPuesto) &&
    (filtroSitio === 'todos' || e.sitio?.titulo === filtroSitio) &&
    (!busqueda || `${e.nombres} ${e.apellido_paterno} ${e.folio}`.toLowerCase().includes(busqueda.toLowerCase()))
  ), [empleados, filtroRegimen, filtroPuesto, filtroSitio, busqueda]);

  const kpiActivos    = empleados.filter(e => e.activo).length;
  const kpiSinBanco   = empleados.filter(e => e.activo && !e.id_banco).length;
  const kpiCandsListo = candidatos.filter(c => c.paso_induccion && !c.promovido_a_empleado).length;

  const porPuesto  = useMemo(() => agruparPor(empleadosFiltrados.filter(e => e.activo), e => e.puesto?.titulo), [empleadosFiltrados]);
  const porSitio   = useMemo(() => agruparPor(empleadosFiltrados.filter(e => e.activo), e => e.sitio?.titulo), [empleadosFiltrados]);
  const porRegimen = useMemo(() => agruparPor(empleadosFiltrados.filter(e => e.activo), e => e.regimen_pago), [empleadosFiltrados]);
  const porTipo    = useMemo(() => agruparPor(empleadosFiltrados.filter(e => e.activo), e => e.tipo_empleado), [empleadosFiltrados]);

  function limpiarFiltros() { setFiltroRegimen('todos'); setFiltroPuesto('todos'); setFiltroSitio('todos'); setBusqueda(''); }

  async function altaCand(e) {
    e.preventDefault();
    if (!supabaseReady) { setMsg('Configurá VITE_SUPABASE_URL/KEY'); return; }
    const { error } = await supabase.from('te_candidatos').insert({ ...nuevoCand, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    await logAccion('personal', 'INSERT', `candidato ${nuevoCand.nombres} ${nuevoCand.apellido_paterno}`);
    setNuevoCand({ nombres: '', apellido_paterno: '', rfc: '', curp: '', sexo: 'M', paso_induccion: false });
    setNuevoOpen(false); setMsg('Candidato dado de alta'); cargar();
  }

  async function promover(id) {
    const { error, data } = await supabase.rpc('promover_candidato_a_empleado', { p_candidato: id });
    if (error) { setMsg('Error: ' + error.message); return; }
    await logAccion('personal', 'PROMOVER', `candidato ${id} → empleado folio ${data}`);
    setMsg('Promovido, folio ' + data); cargar();
  }

  return (
    <div>
      <div className="section-eyebrow">Recursos humanos</div>
      <h1>Personal</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Empleados activos, candidatos en proceso, alta manual y promoción tras inducción.</p>

      <div className="kpi-grid">
        <KpiCard label="Empleados activos" value={kpiActivos} sub="con folio asignado" onClick={() => { setTab('empleados'); limpiarFiltros(); }} />
        <KpiCard label="Puestos distintos" value={puestosUnicos.length} sub="catálogo en uso" color="var(--accent2)" onClick={() => { setTab('empleados'); setVista('resumen'); }} />
        <KpiCard label="Sitios distintos" value={sitiosUnicos.length} sub="con personal asignado" color="var(--accent2)" onClick={() => { setTab('empleados'); setVista('resumen'); }} />
        <KpiCard label="Sin banco / CLABE" value={kpiSinBanco} sub="bloquea dispersión" color={kpiSinBanco ? 'var(--red)' : 'var(--green)'} onClick={() => { setTab('empleados'); setVista('lista'); }} />
        <KpiCard label="Candidatos con inducción" value={kpiCandsListo} sub="listos para promover" color="var(--gold)" onClick={() => setTab('candidatos')} />
      </div>

      <div className="chips">
        <Chip active={tab === 'empleados'} onClick={() => setTab('empleados')}>Empleados</Chip>
        <Chip active={tab === 'candidatos'} onClick={() => setTab('candidatos')}>Candidatos</Chip>
        <span style={{ flex: 1 }} />
        <button className="btn" onClick={() => setNuevoOpen(true)}>+ Nuevo candidato</button>
      </div>

      {tab === 'empleados' && (
        <>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center', marginBottom: 16, flexWrap: 'wrap', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
              <input className="field" style={{ maxWidth: 240 }} placeholder="Buscar por nombre o folio…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
              <select className="field" style={{ maxWidth: 180 }} value={filtroPuesto} onChange={e => setFiltroPuesto(e.target.value)}>
                <option value="todos">Todos los puestos</option>
                {puestosUnicos.map(p => <option key={p} value={p}>{p}</option>)}
              </select>
              <select className="field" style={{ maxWidth: 180 }} value={filtroSitio} onChange={e => setFiltroSitio(e.target.value)}>
                <option value="todos">Todos los sitios</option>
                {sitiosUnicos.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
              <div className="chips" style={{ margin: 0 }}>
                {['todos', 'Nomina', 'Honorarios Normales', 'Honorarios Asimilables'].map(r => (
                  <Chip key={r} active={filtroRegimen === r} onClick={() => setFiltroRegimen(r === filtroRegimen ? 'todos' : r)}>
                    {r === 'todos' ? 'Todos' : r}
                  </Chip>
                ))}
              </div>
              {(filtroRegimen !== 'todos' || filtroPuesto !== 'todos' || filtroSitio !== 'todos' || busqueda) && (
                <button className="btn ghost sm" onClick={limpiarFiltros}>Limpiar filtros</button>
              )}
            </div>
            <ToggleVista opciones={VISTAS} activa={vista} onChange={setVista} />
          </div>

          {vista === 'mosaico' && (
            <div className="card-grid">
              {empleadosFiltrados.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin empleados que coincidan.</p>}
              {empleadosFiltrados.map(e => (
                <div key={e.id} className="card" style={{ cursor: 'pointer', marginBottom: 0 }} onClick={() => navigate('/admin/personal/' + e.id)}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
                    <Avatar empleado={e} />
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontWeight: 700, fontSize: 14, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{e.nombres} {e.apellido_paterno}</div>
                      <div style={{ fontSize: 11, color: 'var(--muted)' }}>#{e.folio}</div>
                    </div>
                    <Badge estado={e.activo ? 'activo' : 'inactivo'}>{e.activo ? 'ACTIVO' : 'BAJA'}</Badge>
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--muted)', marginBottom: 4 }}>💼 {e.puesto?.titulo || 'Sin puesto'}</div>
                  <div style={{ fontSize: 12, color: 'var(--muted)', marginBottom: 12 }}>📍 {e.sitio?.titulo || 'Sin sitio'}</div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: 11, fontWeight: 700, padding: '3px 8px', borderRadius: 6, background: '#FEF3C7', color: 'var(--gold)' }}>
                      {e.puesto?.pago_default ? '$' + Number(e.puesto.pago_default).toLocaleString('es-MX') + '/día' : 'Sin tarifa'}
                    </span>
                    <span style={{ fontSize: 11, color: 'var(--accent)', fontWeight: 700 }}>Ver expediente →</span>
                  </div>
                </div>
              ))}
            </div>
          )}

          {vista === 'lista' && (
            <TablaWrap>
              <table>
                <thead>
                  <tr><th>Folio</th><th>Nombre</th><th>Puesto</th><th>Sitio</th><th>Régimen</th><th>Estado</th></tr>
                </thead>
                <tbody>
                  {empleadosFiltrados.length === 0 && <tr><td colSpan="6" className="empty">Sin empleados que coincidan.</td></tr>}
                  {empleadosFiltrados.map(e => (
                    <tr key={e.id} className="clickable" onClick={() => navigate('/admin/personal/' + e.id)}>
                      <td className="mono">#{e.folio}</td>
                      <td>{e.nombres} {e.apellido_paterno}</td>
                      <td style={{ fontSize: 12 }}>{e.puesto?.titulo || '—'}</td>
                      <td style={{ fontSize: 12 }}>{e.sitio?.titulo || '—'}</td>
                      <td style={{ fontSize: 12 }}>{e.regimen_pago}</td>
                      <td><Badge estado={e.activo ? 'activo' : 'inactivo'}>{e.activo ? 'ACTIVO' : 'BAJA'}</Badge></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          )}

          {vista === 'resumen' && (
            <div className="card-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))' }}>
              <TablaPivot titulo="Por puesto" filas={porPuesto} onFiltrar={v => { setFiltroPuesto(v); setVista('lista'); }} />
              <TablaPivot titulo="Por sitio" filas={porSitio} onFiltrar={v => { setFiltroSitio(v); setVista('lista'); }} />
              <TablaPivot titulo="Por régimen de pago" filas={porRegimen} onFiltrar={v => { setFiltroRegimen(v); setVista('lista'); }} />
              <TablaPivot titulo="Por tipo de empleado" filas={porTipo} />
            </div>
          )}
        </>
      )}

      {tab === 'candidatos' && (
        <TablaWrap>
          <table>
            <thead>
              <tr><th>Nombre</th><th>RFC</th><th>Inducción</th><th>Estado</th><th></th></tr>
            </thead>
            <tbody>
              {candidatos.length === 0 && <tr><td colSpan="5" className="empty">Sin candidatos aún.</td></tr>}
              {candidatos.map(c => (
                <tr key={c.id}>
                  <td>{c.nombres} {c.apellido_paterno}</td>
                  <td className="mono">{c.rfc || '—'}</td>
                  <td><Badge estado={c.paso_induccion ? 'activo' : 'pendiente'}>{c.paso_induccion ? 'CONFIRMADA' : 'PENDIENTE'}</Badge></td>
                  <td><Badge estado={c.promovido_a_empleado ? 'proceso' : 'inactivo'}>{c.promovido_a_empleado ? 'YA EMPLEADO' : 'CANDIDATO'}</Badge></td>
                  <td style={{ textAlign: 'right' }}>
                    {c.paso_induccion && !c.promovido_a_empleado && (
                      <button className="btn green sm" onClick={() => promover(c.id)}>Promover</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      )}

      {msg && <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 12 }}>{msg}</p>}

      {/* Modal nuevo candidato */}
      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title="Nuevo candidato"
        footer={<><button className="btn ghost" onClick={() => setNuevoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={altaCand}>Registrar</button></>}>
        <form onSubmit={altaCand} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          <div><label className="label">Nombres</label><input required className="field" value={nuevoCand.nombres} onChange={e => setNuevoCand({ ...nuevoCand, nombres: e.target.value })} /></div>
          <div><label className="label">Apellido paterno</label><input required className="field" value={nuevoCand.apellido_paterno} onChange={e => setNuevoCand({ ...nuevoCand, apellido_paterno: e.target.value })} /></div>
          <div><label className="label">RFC</label><input className="field mono" value={nuevoCand.rfc} onChange={e => setNuevoCand({ ...nuevoCand, rfc: e.target.value.toUpperCase() })} /></div>
          <div><label className="label">CURP</label><input className="field mono" value={nuevoCand.curp} onChange={e => setNuevoCand({ ...nuevoCand, curp: e.target.value.toUpperCase() })} /></div>
          <div><label className="label">Sexo</label>
            <select className="field" value={nuevoCand.sexo} onChange={e => setNuevoCand({ ...nuevoCand, sexo: e.target.value })}>
              <option value="M">Masculino</option><option value="F">Femenino</option><option value="X">Otro</option>
            </select>
          </div>
          <div><label className="label">¿Ya pasó inducción?</label>
            <div style={{ padding: '8px 0' }}>
              <input type="checkbox" checked={nuevoCand.paso_induccion} onChange={e => setNuevoCand({ ...nuevoCand, paso_induccion: e.target.checked })} /> Sí, se puede promover al confirmar
            </div>
          </div>
          <p style={{ gridColumn: 'span 2', fontSize: 11, color: 'var(--muted)' }}>
            Al guardar, la validación de RFC/CURP duplicado corre a nivel schema (PRC_ValidaRfcCurp).
          </p>
        </form>
      </Modal>
    </div>
  );
}
