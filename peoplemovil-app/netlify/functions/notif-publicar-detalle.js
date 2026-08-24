// Trigger manual/webhook: cuando un pedido_detalle pasa a status_detalle='liberado',
// notifica a los empleados con la plaza correspondiente (via digest o inmediato).
// Uso: POST { pedido_detalle_id }

import { createClient } from '@supabase/supabase-js';

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { pedido_detalle_id } = JSON.parse(event.body || '{}');
  if (!pedido_detalle_id) return { statusCode: 400, body: JSON.stringify({ error: 'pedido_detalle_id requerido' }) };

  const supa = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE);

  // Obtener el detalle y los empleados con esa plaza
  const { data: det } = await supa.from('te_pedidos_detalle').select('*, tc_puestos(titulo), te_pedidos(sitio_id, tenant_id)')
    .eq('id', pedido_detalle_id).maybeSingle();
  if (!det) return { statusCode: 404, body: JSON.stringify({ error: 'detalle no existe' }) };

  const { data: empleados } = await supa.from('tr_empleado_plaza')
    .select('empleado_id, te_empleados(correo, telefono, pref_notif_email, pref_notif_whatsapp, nombres, apellido_paterno)')
    .eq('puesto_id', det.puesto_id).eq('activo', true).eq('tenant_id', det.te_pedidos.tenant_id);

  let enviados = 0;
  const errs = [];

  for (const ep of empleados || []) {
    const e = ep.te_empleados;
    if (!e) continue;
    const asunto = `Nueva oferta: ${det.tc_puestos?.titulo || 'puesto'}`;
    const cuerpo = `Hola ${e.nombres}, hay una nueva oferta que matchea con tu plaza. Ver detalles en el portal.`;

    if (e.pref_notif_email && e.correo && process.env.RESEND_API_KEY) {
      await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { Authorization: `Bearer ${process.env.RESEND_API_KEY}`, 'content-type': 'application/json' },
        body: JSON.stringify({
          from: 'PeopleMovil <no-reply@peoplemovil.mx>',
          to: e.correo,
          subject: asunto,
          html: `<p>${cuerpo}</p><p><a href="https://peoplemovil-app.netlify.app/portal/publicaciones">Ver oferta →</a></p>`
        })
      }).then(() => enviados++).catch(err => errs.push(`resend ${ep.empleado_id}: ${err.message}`));
    }

    if (e.pref_notif_whatsapp && e.telefono && process.env.TWILIO_ACCOUNT_SID) {
      const sid = process.env.TWILIO_ACCOUNT_SID;
      const tok = process.env.TWILIO_AUTH_TOKEN;
      const auth = Buffer.from(`${sid}:${tok}`).toString('base64');
      const form = new URLSearchParams({
        From: process.env.TWILIO_WA_FROM || 'whatsapp:+14155238886',
        To: `whatsapp:${e.telefono}`,
        Body: `${asunto}\n${cuerpo}\nAbrí: peoplemovil-app.netlify.app/portal`
      });
      await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
        method: 'POST',
        headers: { Authorization: `Basic ${auth}`, 'content-type': 'application/x-www-form-urlencoded' },
        body: form
      }).catch(err => errs.push(`twilio ${ep.empleado_id}: ${err.message}`));
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ ok: true, empleados_notificados: (empleados || []).length, enviados, errores: errs.slice(0, 10) })
  };
}
