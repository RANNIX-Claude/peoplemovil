// Digest diario para freelancers: recorre empleados activos, arma digest y envía.
// Trigger: cron scheduled en netlify.toml o llamada manual.

import { createClient } from '@supabase/supabase-js';

export async function handler(event) {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE;
  if (!url || !key) return { statusCode: 500, body: JSON.stringify({ error: 'supabase env missing' }) };
  const supa = createClient(url, key, { auth: { persistSession: false } });

  // Iterar tenants activos
  const { data: tenants } = await supa.from('te_tenants').select('id').eq('activo', true);
  let enviados = 0;
  const errores = [];

  for (const t of tenants || []) {
    // Set tenant activo via SET LOCAL — no funciona con service_role directo. Usamos SQL raw.
    const { data: empleados } = await supa
      .from('te_empleados')
      .select('id, correo, telefono, pref_notif_email, pref_notif_whatsapp')
      .eq('tenant_id', t.id).eq('activo', true);

    for (const emp of empleados || []) {
      const { data: dig, error } = await supa.rpc('armar_digest_freelance', { p_empleado: emp.id, p_dias: 7 });
      if (error) { errores.push(`${emp.id}: ${error.message}`); continue; }
      if (!dig || (dig.publicaciones?.length || 0) + (dig.agenda?.length || 0) === 0) continue;

      // Email via Resend
      if (dig.pref_email && dig.correo && process.env.RESEND_API_KEY) {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: { Authorization: `Bearer ${process.env.RESEND_API_KEY}`, 'content-type': 'application/json' },
          body: JSON.stringify({
            from: 'PeopleMovil <no-reply@peoplemovil.mx>',
            to: dig.correo,
            subject: `Tu digest de hoy: ${dig.publicaciones.length} ofertas + ${dig.agenda.length} próximos eventos`,
            html: renderDigestHtml(dig)
          })
        }).catch(e => errores.push(`resend ${emp.id}: ${e.message}`));
        enviados++;
      }

      // WhatsApp via Twilio
      if (dig.pref_whatsapp && dig.telefono && process.env.TWILIO_ACCOUNT_SID) {
        const sid = process.env.TWILIO_ACCOUNT_SID;
        const tok = process.env.TWILIO_AUTH_TOKEN;
        const from = process.env.TWILIO_WA_FROM || 'whatsapp:+14155238886';
        const auth = Buffer.from(`${sid}:${tok}`).toString('base64');
        const form = new URLSearchParams({
          From: from, To: `whatsapp:${dig.telefono}`,
          Body: renderDigestText(dig)
        });
        await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
          method: 'POST',
          headers: { Authorization: `Basic ${auth}`, 'content-type': 'application/x-www-form-urlencoded' },
          body: form
        }).catch(e => errores.push(`twilio ${emp.id}: ${e.message}`));
      }
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ ok: true, enviados, errores: errores.slice(0, 20), tenants: (tenants || []).length })
  };
}

function renderDigestHtml(d) {
  const pubs = (d.publicaciones || []).map(p =>
    `<li><strong>${escapeHtml(p.puesto)}</strong> · ${escapeHtml(p.sitio || '')} · ${p.fecha || 'fecha por definir'} · cupo ${p.cupo_ocupado}/${p.cupo_total}</li>`
  ).join('');
  const agenda = (d.agenda || []).map(a =>
    `<li>${new Date(a.cita_inicio).toLocaleString('es-MX')} — <strong>${escapeHtml(a.puesto)}</strong> en ${escapeHtml(a.sitio || '')} (${a.estado})</li>`
  ).join('');
  return `<h1>Hola ${escapeHtml(d.nombre)}</h1>
<p>Este es tu resumen diario en PeopleMovil.</p>
<h2>${d.publicaciones.length} ofertas para vos</h2>
<ul>${pubs || '<li>Sin ofertas nuevas hoy</li>'}</ul>
<h2>${d.agenda.length} eventos próximos</h2>
<ul>${agenda || '<li>Sin eventos próximos</li>'}</ul>
<p>Saldo pendiente: <strong>$${Number(d.saldo || 0).toLocaleString('es-MX')}</strong></p>
<p><a href="https://peoplemovil-app.netlify.app/portal">Abrir el portal →</a></p>`;
}

function renderDigestText(d) {
  return `PeopleMovil digest\n${d.publicaciones.length} ofertas para vos, ${d.agenda.length} eventos próximos. Saldo: $${Number(d.saldo||0).toLocaleString('es-MX')}. Abrí el portal: peoplemovil-app.netlify.app/portal`;
}

function escapeHtml(s) {
  return String(s || '').replace(/[&<>"']/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
}
