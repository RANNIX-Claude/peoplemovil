import { createClient } from '@supabase/supabase-js';

// En dev usa un tenant demo si no hay auth real. En producción, el JWT de Supabase Auth
// setea app.current_tenant vía claim; aquí se envía como header en Netlify Functions.
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
