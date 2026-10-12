import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { supabase, supabaseReady } from './supabase.js';

const AdminAuthContext = createContext(null);

export function AdminAuthProvider({ children }) {
  const [session, setSession] = useState(null);
  const [usuario, setUsuario] = useState(null);
  const [permisos, setPermisos] = useState(new Set());
  const [tenantId, setTenantId] = useState(null);
  const [loading, setLoading] = useState(true);

  const cargarUsuario = useCallback(async () => {
    if (!supabaseReady) { setLoading(false); return; }
    const [{ data: usuarioRows }, { data: permisosRow }, { data: tid }] = await Promise.all([
      supabase.rpc('mi_usuario'),
      supabase.rpc('mis_permisos'),
      // Tenant real de ESTA sesión, resuelto en el servidor contra la membresía
      // real del usuario (Migración 025) -- nunca el header x-tenant-id ni
      // DEMO_TENANT_ID. Usarlo en vez de la constante hardcodeada es lo que
      // permite que el admin de un tenant demo multi-vertical (construcción,
      // seguridad privada, BTL) escriba en SU propio tenant, no en "eventos".
      supabase.rpc('current_tenant_id'),
    ]);
    setUsuario(usuarioRows && usuarioRows[0] ? usuarioRows[0] : null);
    setPermisos(new Set(permisosRow || []));
    setTenantId(tid || null);
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
      else { setUsuario(null); setPermisos(new Set()); setTenantId(null); setLoading(false); }
    });
    return () => sub.subscription.unsubscribe();
  }, [cargarUsuario]);

  const hasPermiso = useCallback((codigo) => permisos.has(codigo), [permisos]);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    setUsuario(null);
    setPermisos(new Set());
    setTenantId(null);
  }, []);

  const value = {
    session, usuario, permisos, tenantId, loading,
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
