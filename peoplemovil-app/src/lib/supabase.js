import { createClient } from '@supabase/supabase-js';

// Fallback para accesos SIN sesión (portal público de vacantes, demo sin login).
// current_tenant_id() (ver Migración 025, db/reset_database.sql) ignora este header
// por completo cuando hay una sesión autenticada -- en ese caso resuelve el tenant
// real desde te_usuarios/te_empleados vía el JWT, nunca desde lo que mande el cliente.
export const DEMO_TENANT_ID = '00000000-0000-0000-0000-000000000001';

const url = import.meta.env.VITE_SUPABASE_URL || '';
const key = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = (url && key)
  ? createClient(url, key, {
      auth: { persistSession: true, autoRefreshToken: true },
      global: { headers: { 'x-tenant-id': DEMO_TENANT_ID } }
    })
  : null;

export const supabaseReady = !!supabase;
