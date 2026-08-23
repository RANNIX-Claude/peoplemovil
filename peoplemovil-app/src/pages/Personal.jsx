import React, { useEffect, useMemo, useState } from 'react';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

export default function Personal() {
  useModuleAudit('personal');
  const [tab, setTab] = useState('empleados');
  const [empleados, setEmpleados] = useState([]);
  const [candidatos, setCandidatos] = useState([]);
  const [selected, setSelected] = useState(null);
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [nuevoCand, setNuevoCand] = useState({ nombres: '', apellido_paterno: '', rfc: '', curp: '', sexo: 'M', paso_induccion: false });
  const [filtroRegimen, setFiltroRegimen] = useState('todos');
  const [busqueda, setBusqueda] = useState('');
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: e }, { data: c }] = await Promise.all([
      supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno, activo, regimen_pago, id_banco, clabe, correo, telefono').order('folio'),
      supabase.from('te_candidatos').select('id, nombres, apellido_paterno, rfc, paso_induccion, promovido_a_empleado, sexo').order('creado_en', { ascending: false })
    ]);
    setEmpleados(e || []); setCandidatos(c || []);
  }
  useEffect(() => { cargar(); }, []);

  const empleadosFiltrados = useMemo(() => empleados.filter(e =>
    (filtroRegimen === 'todos' || e.regimen_pago === filtroRegimen) &&
    (!busqueda || `${e.nombres} ${e.apellido_paterno} ${e.folio}`.toLowerCase().includes(busqueda.toLowerCase()))
  ), [empleados, filtroRegimen, busqueda]);

  const kpiActivos    = empleados.filter(e => e.activo).length;
  const kpiSinBanco   = empleados.filter(e => e.activo && !e.id_banco).length;
  const kpiCandsListo = candidatos.filter(c => c.paso_induccion && !c.promovido_a_empleado).length;

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
        <KpiCard label="Empleados activos" value={kpiActivos} sub="con folio asignado" onClick={() => setTab('empleados')} />
        <KpiCard label="Sin banco / CLABE" value={kpiSinBanco} sub="bloquea dispersión" color={kpiSinBanco ? 'var(--red)' : 'var(--green)'} onClick={() => { setTab('empleados'); setBusqueda(''); }} />
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
          <div style={{ display: 'flex', gap: 12, alignItems: 'center', marginBottom: 12, flexWrap: 'wrap' }}>
            <input className="field" style={{ maxWidth: 280 }} placeholder="Buscar por nombre o folio…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
            <div className="chips" style={{ margin: 0 }}>
              {['todos', 'Nomina', 'Honorarios Normales', 'Honorarios Asimilables'].map(r => (
                <Chip key={r} active={filtroRegimen === r} onClick={() => setFiltroRegimen(r === filtroRegimen ? 'todos' : r)}>
                  {r === 'todos' ? 'Todos' : r}
                </Chip>
              ))}
            </div>
          </div>
          <TablaWrap>
            <table>
              <thead>
                <tr><th>Folio</th><th>Nombre</th><th>Régimen</th><th>Estado</th></tr>
              </thead>
              <tbody>
                {empleadosFiltrados.length === 0 && <tr><td colSpan="4" className="empty">Sin empleados que coincidan.</td></tr>}
                {empleadosFiltrados.map(e => (
                  <tr key={e.id} className="clickable" onClick={() => setSelected(e)}>
                    <td className="mono">#{e.folio}</td>
                    <td>{e.nombres} {e.apellido_paterno}</td>
                    <td style={{ fontSize: 12 }}>{e.regimen_pago}</td>
                    <td><Badge estado={e.activo ? 'activo' : 'inactivo'}>{e.activo ? 'ACTIVO' : 'BAJA'}</Badge></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
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

      {/* Modal detalle empleado */}
      <Modal open={!!selected} onClose={() => setSelected(null)} title={selected ? `#${selected.folio} · ${selected.nombres} ${selected.apellido_paterno}` : ''}>
        {selected && (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, fontSize: 13 }}>
            <div><div className="label">Régimen de pago</div><div>{selected.regimen_pago}</div></div>
            <div><div className="label">Estado</div><Badge estado={selected.activo ? 'activo' : 'inactivo'}>{selected.activo ? 'ACTIVO' : 'BAJA'}</Badge></div>
            <div><div className="label">Correo</div><div>{selected.correo || '—'}</div></div>
            <div><div className="label">Teléfono</div><div>{selected.telefono || '—'}</div></div>
            <div><div className="label">Banco</div><div>{selected.id_banco ? 'Asignado' : <Badge estado="vencido">SIN BANCO</Badge>}</div></div>
            <div><div className="label">CLABE</div><div className="mono">{selected.clabe || <Badge estado="vencido">SIN CLABE</Badge>}</div></div>
          </div>
        )}
      </Modal>

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
