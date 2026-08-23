// Onboarding de nueva empresa cliente: crea tenant + suscripción FREE por default,
// inicializa cat_parametros_globales y aviso_privacidad v1.0, y dispara email de bienvenida.
// Corre server-side con la service_role de Supabase para pasar RLS al crear el tenant.

import { createClient } from '@supabase/supabase-js';

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { razon_social, rfc, vertical = 'otro', plan = 'FREE', admin_email } = JSON.parse(event.body || '{}');
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE;
  if (!url || !key) return { statusCode: 500, body: JSON.stringify({ error: 'supabase env missing' }) };
  const supa = createClient(url, key, { auth: { persistSession: false } });

  const { data: t, error: e1 } = await supa.from('tenants')
    .insert({ razon_social, rfc, vertical }).select().single();
  if (e1) return { statusCode: 500, body: JSON.stringify({ error: e1.message }) };

  await supa.from('suscripciones').insert({ tenant_id: t.id, plan_codigo: plan });
  await supa.from('cat_parametros_globales').insert({ tenant_id: t.id });
  await supa.from('avisos_privacidad').insert({
    tenant_id: t.id, version: 'v1.0',
    texto: 'Aviso de privacidad para tratamiento de datos biométricos conforme a LFPDPPP. Revocable en cualquier momento.'
  });

  // dispara bienvenida
  if (admin_email) {
    await fetch(`${event.headers.host ? 'https://' + event.headers.host : ''}/.netlify/functions/notificacion-resend`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ template: 'onboarding', to: admin_email, vars: { tenant: razon_social, plan } })
    }).catch(() => {});
  }
  return { statusCode: 200, body: JSON.stringify({ ok: true, tenant: t }) };
}
