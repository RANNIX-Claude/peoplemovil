import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';
import { supabaseReady } from '../../lib/supabase.js';

export default function RequireAdminAuth({ children }) {
  const { loading, autenticado, vinculado, usuario } = useAdminAuth();
  const loc = useLocation();

  if (!supabaseReady) return children; // modo demo sin Supabase conectado

  if (loading) {
    return <div style={{ padding: 40, textAlign: 'center', color: 'var(--muted)' }}>Cargando sesión…</div>;
  }
  if (!autenticado) {
    return <Navigate to="/admin/login" state={{ from: loc.pathname }} replace />;
  }
  if (!vinculado) {
    return (
      <div style={{ maxWidth: 420, margin: '60px auto', padding: 20 }}>
        <div className="card" style={{ padding: 24, textAlign: 'center' }}>
          <p style={{ fontWeight: 700, marginBottom: 8 }}>Tu cuenta no tiene un usuario interno activo</p>
          <p style={{ fontSize: 13, color: 'var(--muted)' }}>
            Iniciaste sesión correctamente, pero no hay un registro en Usuarios y roles ligado a esta cuenta
            (o está inactivo/bloqueado). Pide a un administrador que te dé de alta.
          </p>
        </div>
      </div>
    );
  }
  return children;
}
