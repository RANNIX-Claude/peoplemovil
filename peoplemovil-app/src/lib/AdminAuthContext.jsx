import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { supabase, supabaseReady } from './supabase.js';

const AdminAuthContext = createContext(null);

export function AdminAuthProvider({ children }) {
  const [session, setSession] = useState(null);
  const [usuario, setUsuario] = useState(null);
  const [permisos, setPermisos] = useState(new Set());
  const [loading, setLoading] = useState(true);

  const cargarUsuario = useCallback(async () => {
    if (!supabaseReady) { setLoading(false); return; }
    const [{ data: usuarioRows }, { data: permisosRow }] = await Promise.all([
      supabase.rpc('mi_usuario'),
      supabase.rpc('mis_permisos'),
    ]);
    setUsuario(usuarioRows && usuarioRows[0] ? usuarioRows[0] : null);
    setPermisos(new Set(permisosRow || []));
    setLoading(false);
  }, []);

  useEffect(() => {
    if (!supabaseReady) { setLoading(false); return; }
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) cargarUsuario(); else setLoading(false);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) { setLoading(true); cargarUsuario(); }
      else { setUsuario(null); setPermisos(new Set()); setLoading(false); }
    });
    return () => sub.subscription.unsubscribe();
  }, [cargarUsuario]);

  const hasPermiso = useCallback((codigo) => permisos.has(codigo), [permisos]);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setUsuario(null);
    setPermisos(new Set());
  }, []);

  const value = {
    session, usuario, permisos, loading,
    autenticado: !!session,
    vinculado: !!usuario, // tiene sesión pero ¿está ligada a un te_usuarios activo?
    hasPermiso, signOut, recargar: cargarUsuario,
  };

  return <AdminAuthContext.Provider value={value}>{children}</AdminAuthContext.Provider>;
}

export function useAdminAuth() {
  const ctx = useContext(AdminAuthContext);
  if (!ctx) throw new Error('useAdminAuth debe usarse dentro de AdminAuthProvider');
  return ctx;
}
