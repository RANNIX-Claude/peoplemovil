import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Alta masiva de empleados
// Toma candidatos con paso_induccion=true y los promociona batch
export default function AltaMasivaEmpleados() {
  useModuleAudit('alta_masiva_empleados');
  const [candidatos, setCandidatos] = useState([]);
  const [seleccionados, setSeleccionados] = useState(new Set());
  const [msg, setMsg] = useState('');
  const [ejecutando, setEjecutando] = useState(false);

  const cargar = async () => {
    if (!supabaseReady) return;
    const { data } = await supabase.from('te_candidatos')
      .select('*')
      .eq('paso_induccion', true)
      .eq('promovido_a_empleado', false)
      .order('creado_en');
    setCandidatos(data || []);
  };
  useEffect(() => { cargar(); }, []);

  const toggleSeleccion = id => {
    const nueva = new Set(seleccionados);
    nueva.has(id) ? nueva.delete(id) : nueva.add(id);
    setSeleccionados(nueva);
  };
  const toggleTodos = () => {
    if (seleccionados.size === candidatos.length) setSeleccionados(new Set());
    else setSeleccionados(new Set(candidatos.map(c => c.id)));
  };

  const ejecutar = async () => {
    if (seleccionados.size === 0) { setMsg('Elegí al menos un candidato'); return; }
    if (!confirm(`¿Promover a empleado a ${seleccionados.size} candidato(s)?`)) return;
    setEjecutando(true); setMsg('');
    let ok = 0, err = 0;
    const errores = [];
    for (const id of seleccionados) {
      const { error } = await supabase.rpc('promover_candidato_a_empleado', { p_candidato: id });
      if (error) { err++; errores.push(id.slice(0,8) + ': ' + error.message); }
      else ok++;
    }
    await logAccion('alta_masiva_empleados', 'BATCH', `${ok} ok, ${err} err de ${seleccionados.size}`);
    setMsg(`✓ ${ok} promovidos${err > 0 ? `, ${err} errores: ${errores.slice(0,3).join('; ')}` : ''}`);
    setSeleccionados(new Set());
    setEjecutando(false);
    cargar();
  };

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento</div>
      <h1>Alta masiva de empleados</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Promoción por lote de candidatos que ya pasaron inducción. Cada uno recibe folio consecutivo (PRC_FoliosConsecutivos).
      </p>

      <div className="kpi-grid">
        <KpiCard label="Candidatos listos" value={candidatos.length} sub="con inducción confirmada" color="var(--gold)" />
        <KpiCard label="Seleccionados" value={seleccionados.size} sub="para promover" color="var(--accent2)" />
      </div>

      <div className="card" style={{ padding: 12, marginBottom: 12, display: 'flex', gap: 10, justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap' }}>
        <div>
          <button className="btn ghost sm" onClick={toggleTodos}>
            {seleccionados.size === candidatos.length ? '☐ Deseleccionar todos' : '☑ Seleccionar todos'}
          </button>
        </div>
        <button className="btn green" onClick={ejecutar} disabled={seleccionados.size === 0 || ejecutando}>
          {ejecutando ? 'Procesando…' : `Promover ${seleccionados.size} → empleado`}
        </button>
      </div>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

      <TablaWrap>
        <table>
          <thead>
            <tr>
              <th style={{ width: 40 }}></th>
              <th>Nombre</th>
              <th>RFC</th>
              <th>CURP</th>
              <th>Sexo</th>
              <th>Inducción</th>
              <th>Evento prueba</th>
            </tr>
          </thead>
          <tbody>
            {candidatos.length === 0 && (
              <tr><td colSpan="7" className="empty">
                Sin candidatos listos. Normalmente no hace falta usar esta pantalla: confirmar asistencia en "Cursos de inducción" ya promueve automáticamente. Esta queda como respaldo manual para casos sueltos.
              </td></tr>
            )}
            {candidatos.map(c => (
              <tr key={c.id} onClick={() => toggleSeleccion(c.id)} style={{ cursor: 'pointer', background: seleccionados.has(c.id) ? 'var(--accent-light)' : undefined }}>
                <td><input type="checkbox" checked={seleccionados.has(c.id)} onChange={() => toggleSeleccion(c.id)} /></td>
                <td>{c.nombres} {c.apellido_paterno} {c.apellido_materno}</td>
                <td className="mono" style={{ fontSize: 11 }}>{c.rfc || '—'}</td>
                <td className="mono" style={{ fontSize: 11 }}>{c.curp || '—'}</td>
                <td>{c.sexo}</td>
                <td><Badge estado={c.paso_induccion ? 'activo' : 'pendiente'}>{c.paso_induccion ? '✓' : '—'}</Badge></td>
                <td><Badge estado={c.paso_evento_prueba ? 'activo' : 'pendiente'}>{c.paso_evento_prueba ? '✓' : '—'}</Badge></td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
    </div>
  );
}
