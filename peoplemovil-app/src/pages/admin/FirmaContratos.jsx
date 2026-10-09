import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

const RESULTADOS = [
  { value: 'aceptado_curso', label: 'Aceptado' },
  { value: 'rechazado_perfil', label: 'Rechazado — perfil' },
  { value: 'rechazado_documentacion', label: 'Rechazado — documentación' },
  { value: 'rechazado_evaluacion', label: 'Rechazado — evaluación' }
];

// Reclutamiento, pasos 5-6 del flujo (ver NOTIFICACIONES_RECLUTAMIENTO.md):
// "Firma de contratos" del legado — captura Resultado y asigna Curso de
// inducción (selector de cabecera que propaga a todas las filas, igual que
// el legado). Al confirmar dispara el correo 1 (individual, por candidato).
export default function FirmaContratos() {
  useModuleAudit('firma_contratos');
  const [vacantes, setVacantes] = useState([]);
  const [vacanteId, setVacanteId] = useState('');
  const [cursos, setCursos] = useState([]);
  const [filas, setFilas] = useState([]);
  const [resultadoCab, setResultadoCab] = useState('aceptado_curso');
  const [cursoCab, setCursoCab] = useState('');
  const [confirmando, setConfirmando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_vacantes').select('id, titulo').order('titulo').then(({ data }) => setVacantes(data || []));
    supabase.from('te_cursos_induccion').select('id, titulo, fecha, hora_inicio').order('fecha').then(({ data }) => setCursos(data || []));
  }, []);

  const cargarFilas = async (id) => {
    if (!supabaseReady || !id) { setFilas([]); return; }
    const { data } = await supabase.from('tr_postulacion_candidato_vacante')
      .select('candidato_id, resultado, curso_induccion_id, te_candidatos(nombres, apellido_paterno, apellido_materno, correo)')
      .eq('vacante_id', id).eq('estatus_full', 'entrevista_individual');
    setFilas((data || []).map(r => ({
      candidato_id: r.candidato_id,
      nombre: `${r.te_candidatos?.nombres || ''} ${r.te_candidatos?.apellido_paterno || ''} ${r.te_candidatos?.apellido_materno || ''}`.trim(),
      correo: r.te_candidatos?.correo,
      resultado: 'aceptado_curso',
      curso_induccion_id: ''
    })));
  };

  const onVacante = (id) => { setVacanteId(id); setMsg(''); cargarFilas(id); };

  // Propagar cabecera a todas las filas — mismo patrón que el legado.
  const aplicarResultadoCab = (v) => { setResultadoCab(v); setFilas(filas.map(f => ({ ...f, resultado: v }))); };
  const aplicarCursoCab = (v) => { setCursoCab(v); setFilas(filas.map(f => ({ ...f, curso_induccion_id: v }))); };

  const nAceptados = filas.filter(f => f.resultado === 'aceptado_curso').length;

  const confirmar = async () => {
    if (nAceptados > 0 && !cursoCab) { setMsg('❌ Asigná un curso de inducción para los candidatos aceptados.'); setConfirmando(false); return; }
    setGuardando(true); setMsg('');

    // La RPC solo acepta un resultado por llamada — se agrupan por resultado.
    const porResultado = {};
    for (const f of filas) (porResultado[f.resultado] ||= []).push(f.candidato_id);

    let correosEnviados = 0, correosError = 0;
    for (const [resultado, ids] of Object.entries(porResultado)) {
      const { data, error } = await supabase.rpc('registrar_firma_contrato', {
        p_candidatos: ids,
        p_resultado: resultado,
        p_curso_induccion_id: resultado === 'aceptado_curso' ? cursoCab : null
      });
      if (error) { setMsg('❌ ' + error.message); setGuardando(false); setConfirmando(false); return; }

      // Correo 1: uno por candidato, personalizado (confirmado contra captura real de Outlook).
      for (const row of data || []) {
        if (!row.correo) continue;
        try {
          const resp = await fetch('/.netlify/functions/notificacion-resend', {
            method: 'POST',
            headers: { 'content-type': 'application/json' },
            body: JSON.stringify({
              template: 'curso_induccion_confirmacion',
              to: row.correo,
              vars: {
                nombre: `${row.nombres} ${row.apellido_paterno} ${row.apellido_materno || ''}`.trim(),
                dia: row.curso_fecha, hora: row.curso_hora, lugar: row.curso_lugar,
                tenant_id: DEMO_TENANT_ID, candidato_id: row.candidato_id
              }
            })
          });
          resp.ok ? correosEnviados++ : correosError++;
        } catch { correosError++; }
      }
    }

    await logAccion('firma_contratos', 'ACTUALIZAR_LISTA', `vacante ${vacanteId}: ${filas.length} registros, ${correosEnviados} correos`);
    setMsg(`✓ Se registraron en CURSOS DE INDUCCIÓN: ${nAceptados} registros. Correos de confirmación: ${correosEnviados} enviados${correosError ? `, ${correosError} con error` : ''}.`);
    setGuardando(false); setConfirmando(false);
    cargarFilas(vacanteId);
  };

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento · Proceso de Reclutamiento</div>
      <h1>Firma de contratos</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Captura el resultado de la entrevista y asigná el curso de inducción. Al confirmar, cada candidato aceptado recibe su correo de confirmación.
      </p>

      <div className="card" style={{ padding: 12, marginBottom: 16 }}>
        <label className="label">Vacante</label>
        <select className="field" value={vacanteId} onChange={e => onVacante(e.target.value)}>
          <option value="">— elegir vacante —</option>
          {vacantes.map(v => <option key={v.id} value={v.id}>{v.titulo}</option>)}
        </select>
      </div>

      {vacanteId && (
        <>
          <div className="kpi-grid">
            <KpiCard label="Candidatos pendientes de firma" value={filas.length} />
            <KpiCard label="Marcados Aceptado" value={nAceptados} color="var(--green)" />
          </div>

          <div className="card" style={{ padding: 12, marginBottom: 12, display: 'flex', gap: 14, flexWrap: 'wrap', alignItems: 'end' }}>
            <div>
              <label className="label">Resultado (aplica a todas las filas)</label>
              <select className="field" value={resultadoCab} onChange={e => aplicarResultadoCab(e.target.value)}>
                {RESULTADOS.map(r => <option key={r.value} value={r.value}>{r.label}</option>)}
              </select>
            </div>
            <div style={{ flex: 1, minWidth: 220 }}>
              <label className="label">Curso de inducción (aplica a todas las filas)</label>
              <select className="field" value={cursoCab} onChange={e => aplicarCursoCab(e.target.value)}>
                <option value="">(Ninguno)</option>
                {cursos.map(c => <option key={c.id} value={c.id}>{c.fecha} {c.hora_inicio} — {c.titulo}</option>)}
              </select>
            </div>
          </div>

          {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

          <TablaWrap>
            <table>
              <thead>
                <tr><th>Candidato</th><th>Correo</th><th>Resultado</th><th>Curso de inducción</th></tr>
              </thead>
              <tbody>
                {filas.length === 0 && <tr><td colSpan="4" className="empty">Sin candidatos en "entrevista individual" para esta vacante.</td></tr>}
                {filas.map(f => (
                  <tr key={f.candidato_id}>
                    <td>{f.nombre}</td>
                    <td className="mono" style={{ fontSize: 11 }}>{f.correo || '—'}</td>
                    <td>
                      <select className="field" value={f.resultado} onChange={e => setFilas(filas.map(x => x.candidato_id === f.candidato_id ? { ...x, resultado: e.target.value } : x))}>
                        {RESULTADOS.map(r => <option key={r.value} value={r.value}>{r.label}</option>)}
                      </select>
                    </td>
                    <td>
                      {f.resultado === 'aceptado_curso'
                        ? (cursos.find(c => c.id === f.curso_induccion_id)?.titulo || cursos.find(c => c.id === cursoCab)?.titulo || '(Ninguno)')
                        : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>

          {filas.length > 0 && (
            <div style={{ marginTop: 14 }}>
              <button className="btn" onClick={() => setConfirmando(true)}>Actualizar Lista</button>
            </div>
          )}
        </>
      )}

      <Modal open={confirmando} onClose={() => !guardando && setConfirmando(false)} title="¿Actualizar firma de contratos?"
        footer={<>
          <button className="btn ghost" onClick={() => setConfirmando(false)} disabled={guardando}>No</button>
          <button className="btn" onClick={confirmar} disabled={guardando}>{guardando ? 'Guardando…' : 'Sí'}</button>
        </>}>
        <p>Se registrarán en CURSOS DE INDUCCIÓN: <b>{nAceptados}</b> registros.</p>
        {filas.length - nAceptados > 0 && <p>Se marcarán como rechazados: <b>{filas.length - nAceptados}</b> registros.</p>}
      </Modal>
    </div>
  );
}
