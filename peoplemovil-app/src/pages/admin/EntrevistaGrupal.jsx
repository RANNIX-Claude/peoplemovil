import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Reclutamiento, paso 3 del flujo (ver NOTIFICACIONES_RECLUTAMIENTO.md):
// "Asistencia por Grupos" del legado — marca ¿Asistió? + ¿Documentos completos?
// por candidato de un grupo de entrevista, en lote.
export default function EntrevistaGrupal() {
  useModuleAudit('entrevista_grupal');
  const [grupos, setGrupos] = useState([]);
  const [grupoId, setGrupoId] = useState('');
  const [filas, setFilas] = useState([]);
  const [confirmando, setConfirmando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_grupos_citas').select('*, te_vacantes(titulo)')
      .order('fecha_cita', { ascending: false })
      .then(({ data }) => setGrupos(data || []));
  }, []);

  const cargarFilas = async (id) => {
    if (!supabaseReady || !id) { setFilas([]); return; }
    const { data } = await supabase.from('tr_cita_grupo_candidato')
      .select('candidato_id, asistio, doc_completa, te_candidatos(nombres, apellido_paterno, apellido_materno, sexo)')
      .eq('grupo_cita_id', id);
    setFilas((data || []).map(r => ({
      candidato_id: r.candidato_id,
      nombre: `${r.te_candidatos?.nombres || ''} ${r.te_candidatos?.apellido_paterno || ''} ${r.te_candidatos?.apellido_materno || ''}`.trim(),
      sexo: r.te_candidatos?.sexo,
      asistio: r.asistio,
      doc_completa: r.doc_completa
    })));
  };

  const onGrupo = (id) => { setGrupoId(id); setMsg(''); cargarFilas(id); };

  const toggle = (cid, campo) => {
    setFilas(filas.map(f => f.candidato_id === cid ? { ...f, [campo]: !f[campo] } : f));
  };

  const grupo = useMemo(() => grupos.find(g => g.id === grupoId), [grupos, grupoId]);
  const nAsistio = filas.filter(f => f.asistio).length;

  const confirmar = async () => {
    setGuardando(true); setMsg('');
    const { data, error } = await supabase.rpc('confirmar_asistencia_grupo', {
      p_grupo_cita_id: grupoId,
      p_candidatos: filas.map(f => ({ candidato_id: f.candidato_id, asistio: !!f.asistio, doc_completa: !!f.doc_completa }))
    });
    if (error) { setMsg('❌ ' + error.message); setGuardando(false); setConfirmando(false); return; }
    await logAccion('entrevista_grupal', 'ACTUALIZAR_LISTA', `grupo ${grupoId}: ${data} registros`);
    setMsg(`✓ Actualizados ${data} registros. Quienes asistieron y traen documentos completos avanzan a "Firma de contratos".`);
    setGuardando(false); setConfirmando(false);
    cargarFilas(grupoId);
  };

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento · Proceso de Reclutamiento</div>
      <h1>Asistencia por grupos</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Marca asistencia y documentación completa de cada candidato del grupo de entrevista. Solo avanzan a Firma de contratos quienes cumplen ambas.
      </p>

      <div className="card" style={{ padding: 12, marginBottom: 16 }}>
        <label className="label">Grupo de entrevista</label>
        <select className="field" value={grupoId} onChange={e => onGrupo(e.target.value)}>
          <option value="">— elegir grupo —</option>
          {grupos.map(g => (
            <option key={g.id} value={g.id}>
              {g.fecha_cita} {g.hora_inicio} — {g.te_vacantes?.titulo || 'sin vacante'} ({g.cupo_actual}/{g.cupo_maximo})
            </option>
          ))}
        </select>
      </div>

      {grupoId && (
        <>
          <div className="kpi-grid">
            <KpiCard label="Candidatos del grupo" value={filas.length} />
            <KpiCard label="Marcados asistió" value={nAsistio} color="var(--green)" />
            <KpiCard label="Cupo" value={`${grupo?.cupo_actual ?? 0}/${grupo?.cupo_maximo ?? 0}`} />
          </div>

          {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

          <TablaWrap>
            <table>
              <thead>
                <tr><th>Candidato</th><th>Sexo</th><th>¿Asistió?</th><th>¿Documentos completos?</th></tr>
              </thead>
              <tbody>
                {filas.length === 0 && <tr><td colSpan="4" className="empty">Este grupo no tiene candidatos agendados.</td></tr>}
                {filas.map(f => (
                  <tr key={f.candidato_id}>
                    <td>{f.nombre}</td>
                    <td>{f.sexo}</td>
                    <td><input type="checkbox" checked={!!f.asistio} onChange={() => toggle(f.candidato_id, 'asistio')} /></td>
                    <td><input type="checkbox" checked={!!f.doc_completa} onChange={() => toggle(f.candidato_id, 'doc_completa')} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>

          {filas.length > 0 && (
            <div style={{ marginTop: 14, display: 'flex', gap: 10 }}>
              <button className="btn" onClick={() => setConfirmando(true)}>Actualizar Lista</button>
            </div>
          )}
        </>
      )}

      <Modal open={confirmando} onClose={() => !guardando && setConfirmando(false)} title="¿Actualizar lista de asistencia?"
        footer={<>
          <button className="btn ghost" onClick={() => setConfirmando(false)} disabled={guardando}>No</button>
          <button className="btn" onClick={confirmar} disabled={guardando}>{guardando ? 'Guardando…' : 'Sí'}</button>
        </>}>
        <p>Confirmar actualización de: <b>{filas.length}</b> registros.</p>
      </Modal>
    </div>
  );
}
