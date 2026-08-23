import { useEffect } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from './supabase.js';

// useModuleAudit — registra el acceso al módulo cuando el componente monta.
// Uso: useModuleAudit('personal');
export function useModuleAudit(nombreModulo) {
  useEffect(() => {
    if (!supabaseReady || !nombreModulo) return;
    supabase.rpc('log_bitacora', {
      p_modulo:  nombreModulo,
      p_accion:  'ACCESO',
      p_detalle: `usuario accedió a ${nombreModulo}`
    }).then(() => {}, () => {});
  }, [nombreModulo]);
}

// Para acciones puntuales (INSERT/UPDATE/DELETE) desde cualquier página.
export async function logAccion(modulo, accion, detalle = '') {
  if (!supabaseReady) return;
  const { error } = await supabase.rpc('log_bitacora', {
    p_modulo:  modulo,
    p_accion:  accion,
    p_detalle: detalle
  });
  if (error) console.warn('log_bitacora falló:', error.message);
}

export { DEMO_TENANT_ID };
