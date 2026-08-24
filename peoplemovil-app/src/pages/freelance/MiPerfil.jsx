import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';

export default function MiPerfil() {
  const [emp, setEmp] = useState(null);
  const [plazas, setPlazas] = useState([]);
  const [nipNuevo, setNipNuevo] = useState('');
  const [prefs, setPrefs] = useState({ email: true, whatsapp: true, push: true, hora: '08:00' });
  const [msg, setMsg] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => { cargar(); }, []);

  async function cargar() {
    if (!supabaseReady) { setLoading(false); return; }
    const u = (await supabase.auth.getUser()).data.user;
    if (!u) { setLoading(false); return; }
    const { data: e } = await supabase.from('te_empleados').select('*').eq('auth_user_id', u.id).maybeSingle();
    if (!e) { setLoading(false); return; }
    setEmp(e);
    setPrefs({
      email: e.pref_notif_email ?? true,
      whatsapp: e.pref_notif_whatsapp ?? true,
      push: e.pref_notif_push ?? true,
      hora: e.pref_digest_hora || '08:00'
    });
    const { data: pl } = await supabase.from('tr_empleado_plaza').select('*, tc_puestos(titulo)')
      .eq('empleado_id', e.id).eq('activo', true);
    setPlazas(pl || []);
    setLoading(false);
  }

  const guardarPrefs = async () => {
    const { error } = await supabase.rpc('actualizar_mis_preferencias', {
      p_email: prefs.email, p_wa: prefs.whatsapp, p_push: prefs.push, p_digest_hora: prefs.hora
    });
    setMsg(error ? '❌ ' + error.message : '✓ Preferencias guardadas');
  };

  const cambiarNip = async () => {
    if (!nipNuevo || nipNuevo.length < 4) { setMsg('NIP mínimo 4 dígitos'); return; }
    const { error } = await supabase.rpc('cambiar_mi_nip', { p_nip_nuevo: nipNuevo });
    setMsg(error ? '❌ ' + error.message : '✓ NIP actualizado');
    setNipNuevo('');
  };

  if (loading) return <p>Cargando…</p>;

  if (!emp) return (
    <div className="card">
      <p style={{ padding: 12, color: 'var(--muted)' }}>Tu usuario no está vinculado a un empleado activo. Contactá a RRHH para que asocien tu cuenta.</p>
    </div>
  );

  return (
    <div>
      <div className="section-eyebrow">Perfil</div>
      <h1 style={{ marginBottom: 4 }}>{emp.nombres} {emp.apellido_paterno}</h1>
      <p style={{ fontSize: 12, color: 'var(--muted)', marginBottom: 20 }}>Folio #{emp.folio} · {emp.regimen_pago}</p>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12 }}>{msg}</div>}

      <div className="card">
        <h3>Mis plazas activas</h3>
        {plazas.length === 0 ? (
          <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin plazas asignadas aún. Habla con tu coordinador.</p>
        ) : (
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {plazas.map(p => (
              <Badge key={p.id} estado="proceso">
                {p.tc_puestos?.titulo || '(puesto)'} · certeza {p.porcentaje_puntualidad ? Math.round(p.porcentaje_puntualidad * 100) + '%' : '—'}
              </Badge>
            ))}
          </div>
        )}
      </div>

      <div className="card">
        <h3>Cambiar NIP</h3>
        <div style={{ display: 'flex', gap: 8, alignItems: 'end' }}>
          <div style={{ flex: 1 }}>
            <label className="label">NIP nuevo (4-6 dígitos)</label>
            <input type="password" className="field mono" value={nipNuevo} onChange={e => setNipNuevo(e.target.value)} maxLength={6} pattern="[0-9]{4,6}" />
          </div>
          <button className="btn" onClick={cambiarNip}>Guardar</button>
        </div>
      </div>

      <div className="card">
        <h3>Preferencias de notificación</h3>
        <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
          <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input type="checkbox" checked={prefs.email} onChange={e => setPrefs({ ...prefs, email: e.target.checked })} />
            📧 Email (a {emp.correo || 'sin correo'})
          </label>
          <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input type="checkbox" checked={prefs.whatsapp} onChange={e => setPrefs({ ...prefs, whatsapp: e.target.checked })} />
            💬 WhatsApp (a {emp.telefono || 'sin teléfono'})
          </label>
          <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <input type="checkbox" checked={prefs.push} onChange={e => setPrefs({ ...prefs, push: e.target.checked })} />
            🔔 Push in-app
          </label>
          <div>
            <label className="label">Hora del digest diario</label>
            <input type="time" className="field" style={{ maxWidth: 140 }} value={prefs.hora} onChange={e => setPrefs({ ...prefs, hora: e.target.value })} />
          </div>
          <button className="btn" onClick={guardarPrefs} style={{ marginTop: 8 }}>Guardar preferencias</button>
        </div>
      </div>
    </div>
  );
}
