import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';

export default function AdminLogin() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const nav = useNavigate();
  const loc = useLocation();
  const { recargar } = useAdminAuth();
  const from = loc.state?.from || '/admin/dashboard';

  const handle = async e => {
    e.preventDefault(); setError(null); setLoading(true);
    try {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
      await recargar();
      nav(from, { replace: true });
    } catch (e) { setError(e.message); }
    setLoading(false);
  };

  return (
    <div style={{ maxWidth: 380, margin: '60px auto', padding: 20 }}>
      <div className="card" style={{ padding: 28 }}>
        <div style={{ textAlign: 'center', marginBottom: 24 }}>
          <div style={{ width: 60, height: 60, margin: '0 auto 12px', background: 'var(--accent)',
                        borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        color: '#fff', fontWeight: 900, fontSize: 26 }}>P</div>
          <h1 style={{ fontSize: 22 }}>PeopleMovil Admin</h1>
          <p style={{ fontSize: 12, color: 'var(--muted)' }}>RANNIX · Panel interno</p>
        </div>

        <form onSubmit={handle} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Correo</label>
            <input required type="email" className="field" value={email} onChange={e => setEmail(e.target.value)} />
          </div>
          <div>
            <label className="label">Contraseña</label>
            <input required type="password" className="field" value={password} onChange={e => setPassword(e.target.value)} minLength={6} />
          </div>
          {error && <div style={{ background: '#FEE2E2', color: 'var(--red)', padding: 8, borderRadius: 6, fontSize: 12 }}>{error}</div>}
          <button className="btn" type="submit" disabled={loading} style={{ justifyContent: 'center', padding: 12 }}>
            {loading ? '…' : 'Entrar'}
          </button>
        </form>

        {!supabaseReady && <p style={{ marginTop: 20, fontSize: 11, color: 'var(--muted)', textAlign: 'center' }}>
          Modo demo: Supabase no está conectado. Configurá <code>VITE_SUPABASE_URL</code>.
        </p>}
      </div>
    </div>
  );
}
