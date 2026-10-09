import React, { useEffect, useState } from 'react';
import { Outlet, NavLink, useNavigate, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { supabase, supabaseReady } from '../../lib/supabase.js';

export default function FreelanceShell() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const nav = useNavigate();
  const loc = useLocation();

  useEffect(() => {
    if (!supabaseReady) { setLoading(false); return; }
    supabase.auth.getSession().then(({ data }) => {
      setUser(data.session?.user || null);
      setLoading(false);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_e, session) => {
      setUser(session?.user || null);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (loading) return;
    if (!user && loc.pathname !== '/portal/login') {
      nav('/portal/login', { replace: true, state: { from: loc.pathname } });
    }
  }, [user, loading, loc.pathname, nav]);

  if (loading) return <div style={{ padding: 40, textAlign: 'center' }}>Cargando…</div>;
  if (!user && loc.pathname !== '/portal/login') return null;

  const cerrarSesion = async () => {
    await supabase.auth.signOut();
    nav('/portal/login', { replace: true });
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)', paddingBottom: 80 }}>
      <Toaster position="top-center" toastOptions={{
        style: { fontSize: 13, fontWeight: 600, borderRadius: 10 },
        success: { iconTheme: { primary: 'var(--green)', secondary: '#fff' } },
        error: { iconTheme: { primary: 'var(--red)', secondary: '#fff' } }
      }} />
      <header style={{
        background: 'var(--accent)', color: '#fff', padding: '14px 20px',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        position: 'sticky', top: 0, zIndex: 5
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            width: 32, height: 32, background: '#fff', borderRadius: 8,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--accent)', fontWeight: 900
          }}>P</div>
          <div>
            <div style={{ fontWeight: 800, fontSize: 15 }}>Mi Portal</div>
            <div style={{ fontSize: 10, opacity: .8 }}>PeopleMovil</div>
          </div>
        </div>
        {user && (
          <button onClick={cerrarSesion} className="btn sm" style={{ background: 'rgba(255,255,255,.15)', color: '#fff' }}>
            Cerrar sesión
          </button>
        )}
      </header>
      <main style={{ maxWidth: 720, margin: '0 auto', padding: '20px 16px' }}>
        <Outlet />
      </main>
      {user && (
        <nav style={{
          position: 'fixed', bottom: 0, left: 0, right: 0,
          background: 'var(--white)', borderTop: '1px solid var(--border)',
          display: 'flex', justifyContent: 'space-around', padding: '10px 0',
          zIndex: 10
        }}>
          <BottomLink to="/portal/publicaciones" icon="📋" label="Ofertas" />
          <BottomLink to="/portal/mis-eventos" icon="📅" label="Mis eventos" />
          <BottomLink to="/portal/mis-pagos" icon="💰" label="Pagos" />
          <BottomLink to="/portal/perfil" icon="👤" label="Perfil" />
        </nav>
      )}
    </div>
  );
}

function BottomLink({ to, icon, label }) {
  return (
    <NavLink
      to={to}
      style={({ isActive }) => ({
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        gap: 2, fontSize: 10, fontWeight: 700,
        color: isActive ? 'var(--accent)' : 'var(--muted)',
        textDecoration: 'none'
      })}
    >
      <span style={{ fontSize: 18 }}>{icon}</span>
      {label}
    </NavLink>
  );
}
