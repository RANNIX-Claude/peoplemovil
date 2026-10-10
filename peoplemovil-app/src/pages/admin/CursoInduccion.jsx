import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { tituloConLinea } from '../../components/ui/CardHeader.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Reclutamiento, pasos 8-9-10 del flujo (ver NOTIFICACIONES_RECLUTAMIENTO.md):
// "Lista candidatos curso de inducción" del legado — confirma ¿Asistió? por
// candidato; quien asiste se da de alta como empleado automáticamente en la
// misma operación. Después se puede avisar a RH (correo-lote con PDF, el
// mismo que en el legado se repite una vez por cada lote confirmado).
export default function CursoInduccion() {
  useModuleAudit('curso_induccion');
  const [cursos, setCursos] = useState([]);
  const [cursoId, setCursoId] = useState('');
  const [filas, setFilas] = useState([]);
  const [resultados, setResultados] = useState(null); // respuesta de la RPC, null = aún no confirmado
  const [confirmando, setConfirmando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [msg, setMsg] = useState('');
  const [correoRH, setCorreoRH] = useState('');
  const [enviandoAviso, setEnviandoAviso] = useState(false);

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_cursos_induccion').select('id, titulo, fecha, hora_inicio')
      .order('fecha', { ascending: false }).then(({ data }) => setCursos(data || []));
  }, []);

  const cargarFilas = async (id) => {
    if (!supabaseReady || !id) { setFilas([]); return; }
    const { data } = await supabase.from('tr_asistencia_curso')
      .select('candidato_id, asistio, te_candidatos(nombres, apellido_paterno, apellido_materno, promovido_a_empleado)')
      .eq('curso_id', id);
    setFilas((data || []).map(r => ({
      candidato_id: r.candidato_id,
      nombre: `${r.te_candidatos?.nombres || ''} ${r.te_candidatos?.apellido_paterno || ''} ${r.te_candidatos?.apellido_materno || ''}`.trim(),
      promovido: r.te_candidatos?.promovido_a_empleado,
      asistio: r.asistio
    })));
  };

  const onCurso = (id) => { setCursoId(id); setMsg(''); setResultados(null); cargarFilas(id); };

  const toggle = (cid) => setFilas(filas.map(f => f.candidato_id === cid ? { ...f, asistio: !f.asistio } : f));
  const nAsistio = filas.filter(f => f.asistio).length;

  const confirmar = async () => {
    setGuardando(true); setMsg('');
    const { data, error } = await supabase.rpc('confirmar_asistencia_curso', {
      p_curso_induccion_id: cursoId,
      p_candidatos: filas.map(f => ({ candidato_id: f.candidato_id, asistio: !!f.asistio }))
    });
    if (error) { setMsg('❌ ' + error.message); setGuardando(false); setConfirmando(false); return; }
    const altasOk = (data || []).filter(r => r.ok && r.empleado_id);
    await logAccion('curso_induccion', 'ACTUALIZAR_ASISTENCIA', `curso ${cursoId}: ${data.length} procesados, ${altasOk.length} altas`);
    setResultados(data || []);
    setMsg(`✓ Confirmados ${data.length} registros. Altas de empleado: ${altasOk.length}.`);
    setGuardando(false); setConfirmando(false);
    cargarFilas(cursoId);
  };

  const enviarAvisoRH = async () => {
    if (!correoRH) { setMsg('❌ Capturá el correo de RH destino.'); return; }
    const altasOk = (resultados || []).filter(r => r.ok && r.empleado_id);
    if (altasOk.length === 0) { setMsg('❌ No hay altas confirmadas en este lote.'); return; }
    setEnviandoAviso(true);
    const curso = cursos.find(c => c.id === cursoId);
    try {
      const resp = await fetch('/.netlify/functions/notificacion-resend', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          template: 'alta_empleados_rh',
          to: correoRH,
          vars: {
            fecha: curso?.fecha || new Date().toISOString().slice(0, 10),
            tenant_id: DEMO_TENANT_ID,
            destinatarios: altasOk.map(a => ({ empleado_id: a.empleado_id })),
            empleados: altasOk.map(a => ({
              numEmpleado: a.folio, nombre: `${a.nombres} ${a.apellido_paterno} ${a.apellido_materno || ''}`.trim(),
              puesto: a.puesto || '', solicitud: a.folio
            }))
          }
        })
      });
      setMsg(resp.ok ? `✓ Aviso enviado a ${correoRH} con ${altasOk.length} altas (PDF adjunto).` : '❌ No se pudo enviar el aviso.');
    } catch (e) { setMsg('❌ ' + e.message); }
    setEnviandoAviso(false);
  };

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento · Proceso de Reclutamiento</div>
      <h1>Cursos de inducción</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Confirmá asistencia al curso. Quien asiste se da de alta como empleado automáticamente; después podés avisarle a RH por correo con el PDF de altas.
      </p>

      <div className="card" style={{ padding: 12, marginBottom: 16 }}>
        <label className="label">Curso de inducción</label>
        <select className="field" value={cursoId} onChange={e => onCurso(e.target.value)}>
          <option value="">— elegir curso —</option>
          {cursos.map(c => <option key={c.id} value={c.id}>{c.fecha} {c.hora_inicio} — {c.titulo}</option>)}
        </select>
      </div>

      {cursoId && (
        <>
          <div className="kpi-grid">
            <KpiCard label="Inscritos" value={filas.length} />
            <KpiCard label="Marcados asistió" value={nAsistio} color="var(--green)" />
          </div>

          {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

          <TablaWrap>
            <table>
              <thead>
                <tr><th>Candidato</th><th>¿Asistió?</th>{resultados && <th>Resultado</th>}</tr>
              </thead>
              <tbody>
                {filas.length === 0 && <tr><td colSpan="3" className="empty">Sin candidatos inscritos a este curso.</td></tr>}
                {filas.map(f => {
                  const r = resultados?.find(x => x.candidato_id === f.candidato_id);
                  return (
                    <tr key={f.candidato_id}>
                      <td>{f.nombre}</td>
                      <td><input type="checkbox" checked={!!f.asistio} onChange={() => toggle(f.candidato_id)} disabled={!!resultados} /></td>
                      {resultados && <td>{r ? <Badge estado={r.ok && r.empleado_id ? 'activo' : (r.ok ? 'inactivo' : 'vencido')}>{r.mensaje}</Badge> : '—'}</td>}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </TablaWrap>

          {filas.length > 0 && !resultados && (
            <div style={{ marginTop: 14 }}>
              <button className="btn" onClick={() => setConfirmando(true)}>Actualizar Lista</button>
            </div>
          )}

          {resultados && (
            <div className="card" style={{ padding: 14, marginTop: 14 }}>
              <h3 style={tituloConLinea}>📧 Avisar a RH (correo con PDF de altas)</h3>
              <div style={{ display: 'flex', gap: 10, alignItems: 'end', flexWrap: 'wrap' }}>
                <div style={{ flex: 1, minWidth: 220 }}>
                  <label className="label">Correo de RH destino</label>
                  <input className="field" type="email" placeholder="rh@tuempresa.com" value={correoRH} onChange={e => setCorreoRH(e.target.value)} />
                </div>
                <button className="btn" onClick={enviarAvisoRH} disabled={enviandoAviso}>
                  {enviandoAviso ? 'Enviando…' : 'Enviar aviso con PDF'}
                </button>
              </div>
            </div>
          )}
        </>
      )}

      <Modal open={confirmando} onClose={() => !guardando && setConfirmando(false)} title="Actualizar asistencia"
        footer={<>
          <button className="btn ghost" onClick={() => setConfirmando(false)} disabled={guardando}>No</button>
          <button className="btn" onClick={confirmar} disabled={guardando}>{guardando ? 'Guardando…' : 'Sí'}</button>
        </>}>
        <p>¿Confirmar asistencia de: <b>{filas.length}</b> Registros?</p>
      </Modal>
    </div>
  );
}
