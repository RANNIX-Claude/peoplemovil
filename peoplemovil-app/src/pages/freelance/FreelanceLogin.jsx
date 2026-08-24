import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase, supabaseReady } from '../../lib/supabase.js';

export default function FreelanceLogin() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [mode, setMode] = useState('signin');  // signin | signup | magiclink
  const [msg, setMsg] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const nav = useNavigate();
  const loc = useLocation();
  const from = loc.state?.from || '/portal/publicaciones';

  const handle = async e => {
    e.preventDefault(); setError(null); setMsg(null); setLoading(true);
    try {
      if (mode === 'signin') {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        nav(from, { replace: true });
      } else if (mode === 'signup') {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        setMsg('Cuenta creada. Revisá tu correo para verificar.');
      } else {
        const { error } = await supabase.auth.signInWithOtp({ email });
        if (error) throw error;
        setMsg('Te enviamos un magic link a ' + email);
      }
    } catch (e) { setError(e.message); }
    setLoading(false);
  };

  return (
    <div style={{ maxWidth: 380, margin: '40px auto', padding: 20 }}>
      <div className="card" style={{ padding: 28 }}>
        <div style={{ textAlign: 'center', marginBottom: 24 }}>
          <div style={{ width: 60, height: 60, margin: '0 auto 12px', background: 'var(--accent)',
                        borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        color: '#fff', fontWeight: 900, fontSize: 26 }}>P</div>
          <h1 style={{ fontSize: 22 }}>Portal Freelance</h1>
          <p style={{ fontSize: 12, color: 'var(--muted)' }}>PeopleMovil</p>
        </div>

        <form onSubmit={handle} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Correo</label>
            <input required type="email" className="field" value={email} onChange={e => setEmail(e.target.value)} />
          </div>
          {mode !== 'magiclink' && (
            <div>
              <label className="label">Contraseña</label>
              <input required type="password" className="field" value={password} onChange={e => setPassword(e.target.value)} minLength={6} />
            </div>
          )}
          {error && <div style={{ background: '#FEE2E2', color: 'var(--red)', padding: 8, borderRadius: 6, fontSize: 12 }}>{error}</div>}
          {msg && <div style={{ background: '#E6F7EF', color: 'var(--green)', padding: 8, borderRadius: 6, fontSize: 12 }}>{msg}</div>}
          <button className="btn" type="submit" disabled={loading} style={{ justifyContent: 'center', padding: 12 }}>
            {loading ? '…' : (mode === 'signin' ? 'Entrar' : mode === 'signup' ? 'Crear cuenta' : 'Enviarme magic link')}
          </button>
        </form>

        <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 6, fontSize: 12, textAlign: 'center' }}>
          {mode !== 'signin' && <button onClick={() => setMode('signin')} className="btn ghost sm">Ya tengo cuenta</button>}
          {mode !== 'signup' && <button onClick={() => setMode('signup')} className="btn ghost sm">Crear cuenta nueva</button>}
          {mode !== 'magiclink' && <button onClick={() => setMode('magiclink')} className="btn ghost sm">Enviarme magic link (sin contraseña)</button>}
        </div>

        {!supabaseReady && <p style={{ marginTop: 20, fontSize: 11, color: 'var(--muted)', textAlign: 'center' }}>
          Modo demo: Supabase Auth no está conectado. Configurá <code>VITE_SUPABASE_URL</code>.
        </p>}
      </div>
    </div>
  );
}
