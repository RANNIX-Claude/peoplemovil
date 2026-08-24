import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';

export default function Postularme() {
  const { vacanteId } = useParams();
  const [vac, setVac] = useState(null);
  const [step, setStep] = useState('form');   // form | grupos | ok
  const [grupos, setGrupos] = useState([]);
  const [cand, setCand] = useState({ nombres:'', apellido_paterno:'', apellido_materno:'', rfc:'', curp:'', correo:'', telefono:'' });
  const [candId, setCandId] = useState(null);
  const [postulId, setPostulId] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('v_vacantes_publicas').select('*').eq('id', vacanteId).maybeSingle()
      .then(({ data }) => setVac(data));
  }, [vacanteId]);

  const submitPostulacion = async e => {
    e.preventDefault();
    setError(null); setLoading(true);
    const { data, error } = await supabase.rpc('postular_a_vacante', {
      p_tenant: DEMO_TENANT_ID,
      p_vacante_publicacion: vacanteId,
      p_nombres: cand.nombres,
      p_apellido_paterno: cand.apellido_paterno,
      p_apellido_materno: cand.apellido_materno || null,
      p_rfc: cand.rfc.toUpperCase(),
      p_curp: cand.curp.toUpperCase(),
      p_correo: cand.correo,
      p_telefono: cand.telefono,
      p_ip: null, p_user_agent: navigator.userAgent
    });
    setLoading(false);
    if (error) { setError(error.message); return; }
    setPostulId(data);
    // Obtener candidato_id: si existía, la RPC devuelve postulacion_id, no candidato_id. Consulto.
    const { data: c } = await supabase.from('te_candidatos').select('id').eq('rfc', cand.rfc.toUpperCase()).maybeSingle();
    if (c) setCandId(c.id);
    // Listar grupos disponibles
    const { data: gs } = await supabase.from('v_grupos_citas_disponibles').select('*')
      .eq('vacante_publicacion_id', vacanteId).order('fecha_cita');
    setGrupos(gs || []);
    setStep('grupos');
  };

  const agendar = async grupo => {
    if (!candId) return setError('No pude identificar tu candidatura. Volvé a intentar.');
    setLoading(true); setError(null);
    const { error } = await supabase.rpc('agendar_entrevista_grupal', {
      p_tenant: DEMO_TENANT_ID, p_candidato: candId, p_grupo_cita: grupo.id
    });
    setLoading(false);
    if (error) return setError(error.message);
    setStep('ok');
  };

  return (
    <div>
      <Link to={`/vacantes/${vacanteId}`} style={{ fontSize: 12 }}>← Volver</Link>
      <h1 style={{ marginTop: 12 }}>Postularme a: {vac?.titulo}</h1>

      {step === 'form' && (
        <form onSubmit={submitPostulacion} className="card" style={{ display: 'grid', gap: 14 }}>
          <h3>Tus datos</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Nombre(s) *</label><input required className="field" value={cand.nombres} onChange={e => setCand({...cand, nombres: e.target.value})}/></div>
            <div><label className="label">Apellido paterno *</label><input required className="field" value={cand.apellido_paterno} onChange={e => setCand({...cand, apellido_paterno: e.target.value})}/></div>
            <div><label className="label">Apellido materno</label><input className="field" value={cand.apellido_materno} onChange={e => setCand({...cand, apellido_materno: e.target.value})}/></div>
            <div><label className="label">Correo *</label><input required type="email" className="field" value={cand.correo} onChange={e => setCand({...cand, correo: e.target.value})}/></div>
            <div><label className="label">Teléfono *</label><input required className="field" value={cand.telefono} onChange={e => setCand({...cand, telefono: e.target.value})}/></div>
            <div><label className="label">RFC *</label><input required className="field mono" pattern="[A-Z]{4}[0-9]{6}[A-Z0-9]{3}" title="Formato: 4 letras + 6 dígitos + 3 caracteres" value={cand.rfc} onChange={e => setCand({...cand, rfc: e.target.value.toUpperCase()})}/></div>
            <div style={{ gridColumn: 'span 2' }}><label className="label">CURP *</label><input required className="field mono" pattern="[A-Z]{4}[0-9]{6}[A-Z0-9]{8}" title="18 caracteres" value={cand.curp} onChange={e => setCand({...cand, curp: e.target.value.toUpperCase()})}/></div>
          </div>
          {error && <div style={{ background: '#FEE2E2', color: 'var(--red)', padding: 10, borderRadius: 8, fontSize: 13 }}>⚠ {error}</div>}
          <button className="btn" type="submit" disabled={loading} style={{ justifyContent: 'center', padding: 12, fontSize: 15 }}>
            {loading ? 'Enviando…' : 'Enviar postulación →'}
          </button>
          <p style={{ fontSize: 11, color: 'var(--muted)', textAlign: 'center' }}>
            Al enviar, recibirás un email con confirmación y los siguientes pasos.
          </p>
        </form>
      )}

      {step === 'grupos' && (
        <div className="card">
          <h3>✓ Postulación recibida</h3>
          <p style={{ marginBottom: 16 }}>Ahora agendá tu entrevista grupal. Elegí el horario que mejor te acomode:</p>
          {grupos.length === 0 ? (
            <div style={{ padding: 12, background: 'var(--surface)', borderRadius: 8 }}>
              <p style={{ fontSize: 13 }}>Aún no hay grupos de citas disponibles para esta vacante.</p>
              <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 8 }}>
                RRHH te contactará por correo cuando abran nuevos horarios.
              </p>
              <button className="btn outline" style={{ marginTop: 12 }} onClick={() => setStep('ok')}>Entendido</button>
            </div>
          ) : (
            <div style={{ display: 'grid', gap: 10 }}>
              {grupos.map(g => (
                <div key={g.id} className="kpi-card" style={{ margin: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 10 }}>
                    <div>
                      <div style={{ fontWeight: 700, fontSize: 15 }}>
                        {new Date(g.fecha_cita).toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' })}
                      </div>
                      <div style={{ fontSize: 13, color: 'var(--muted)' }}>
                        🕐 {g.hora_inicio}{g.hora_fin ? ` - ${g.hora_fin}` : ''} · {g.lugares_libres} lugares libres
                      </div>
                    </div>
                    <button className="btn sm" onClick={() => agendar(g)} disabled={loading}>Agendar</button>
                  </div>
                </div>
              ))}
            </div>
          )}
          {error && <div style={{ marginTop: 10, color: 'var(--red)' }}>⚠ {error}</div>}
        </div>
      )}

      {step === 'ok' && (
        <div className="card" style={{ textAlign: 'center', padding: 40 }}>
          <div style={{ fontSize: 60 }}>✓</div>
          <h2>¡Listo!</h2>
          <p style={{ color: 'var(--muted)', marginBottom: 20 }}>Tu postulación quedó registrada. Revisá tu correo para las instrucciones.</p>
          <Link to="/vacantes" className="btn outline" style={{ justifyContent: 'center' }}>Ver otras vacantes</Link>
        </div>
      )}
    </div>
  );
}
