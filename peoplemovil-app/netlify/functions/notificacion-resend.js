// Notificación por email vía Resend. Casos: onboarding tenant, asignación de turno,
// recordatorio de checado, resultado de nómina, y las 2 notificaciones de reclutamiento
// (confirmación de curso de inducción al candidato, aviso de alta a RH con PDF adjunto)
// identificadas en el video "Ciclo completo" del legado — ver NOTIFICACIONES_RECLUTAMIENTO.md.

import { createClient } from '@supabase/supabase-js';
import { generarPdfAltaEmpleados } from './_lib/pdf-alta-empleados.js';

const TEMPLATES = {
  onboarding: (v) => ({
    subject: `Bienvenido a PeopleMovil, ${v.tenant}`,
    html: `<h1>Bienvenido, ${v.tenant}</h1>
<p>Tu cuenta ya está lista. Para empezar:</p>
<ol>
  <li>Configurá tu primer sitio en <b>Sitios y Asignación</b>.</li>
  <li>Dá de alta a tu personal en <b>Personal</b>.</li>
  <li>Publicá el aviso de privacidad y recabá consentimientos.</li>
</ol>
<p>Estás en plan <b>${v.plan}</b>. Podés cambiar cuando quieras.</p>`
  }),
  asignacion: (v) => ({
    subject: `Nueva asignación: ${v.evento}`,
    html: `<p>Hola ${v.nombre}, te asignamos como <b>${v.puesto}</b> el ${v.fecha} en ${v.sitio}. Cita: ${v.hora}. Confirmá desde la app.</p>`
  }),
  recordatorio_checado: (v) => ({
    subject: `Recordatorio de checado — ${v.sitio}`,
    html: `<p>Hola ${v.nombre}, en 1 hora empieza tu turno en <b>${v.sitio}</b>. No olvides checar entrada.</p>`
  }),
  nomina_resultado: (v) => ({
    subject: `Resultado de nómina periodo ${v.periodo}`,
    html: `<p>Hola ${v.nombre}, tu pago del periodo ${v.periodo} es <b>$${v.monto} MXN</b>, régimen ${v.regimen}. Ya está en proceso de dispersión.</p>`
  }),
  // Individual por candidato (uno por destinatario, nunca agrupado — confirmado
  // contra captura real de Outlook del legado: "Estimado(a): <nombre del candidato>").
  curso_induccion_confirmacion: (v) => ({
    subject: 'Notificación curso de inducción',
    html: `<p>Confirmación de curso de inducción</p>
<p>Estimado(a): ${v.nombre}</p>
<p>¡Ya estás a un paso! Agradecemos tu interés y compromiso en tu proceso de selección.</p>
<p>Te confirmamos los datos para tu curso de inducción:</p>
<p><b>Día:</b> ${v.dia}<br/><b>Hora:</b> ${v.hora}</p>
<p><b>Lugar:</b> ${v.lugar || 'por confirmar'}</p>
<p>Favor de presentar Identificación Oficial.</p>
<p>Recuerda que debes asistir con el código de vestimenta: ${v.codigoVestimenta || 'casual formal, calzado cerrado'}.</p>`
  }),
  // Uno por lote confirmado (se repite tantas veces como lotes se procesen en
  // el día — confirmado: 5 veces en una tarde en la bandeja del legado).
  // Lleva adjunto el PDF "Relación de personal dado de alta".
  alta_empleados_rh: (v) => ({
    subject: 'Notificación del sistema',
    html: `<p>Anexo la presente enviamos la relación de los candidatos que han sido seleccionados y dados de alta como personal Freelance de manera automática.</p>
<p>— ${v.firmante || 'Administración de personal'}</p>`
  })
};

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { template, to, vars } = JSON.parse(event.body || '{}');
  const tpl = TEMPLATES[template];
  if (!tpl) return { statusCode: 400, body: JSON.stringify({ error: 'template desconocido' }) };
  if (!to) return { statusCode: 400, body: JSON.stringify({ error: 'to requerido' }) };

  const t = tpl(vars || {});
  const payload = { from: 'PeopleMovil <no-reply@peoplemovil.mx>', to, subject: t.subject, html: t.html };

  // Adjunto: tabla "Relación de personal dado de alta" como PDF (solo para este template).
  if (template === 'alta_empleados_rh' && Array.isArray(vars?.empleados) && vars.empleados.length) {
    const pdfBytes = await generarPdfAltaEmpleados(vars.empleados, vars.fecha);
    payload.attachments = [{
      filename: `alta_empleados_${(vars.fecha || '').replace(/\//g, '')}.pdf`,
      content: Buffer.from(pdfBytes).toString('base64')
    }];
  }

  const key = process.env.RESEND_API_KEY;
  if (!key) {
    return { statusCode: 200, body: JSON.stringify({ ok: true, dry: true, subject: t.subject, adjunto: !!payload.attachments }) };
  }

  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${key}`, 'content-type': 'application/json' },
    body: JSON.stringify(payload)
  });
  const data = await resp.json();

  // Bitácora de envío — te_comunicados/tr_comunicado_destinatario ya existían sin usarse.
  if (resp.ok && vars?.tenant_id && (vars?.candidato_id || vars?.destinatarios)) {
    try {
      const supa = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE);
      const { data: com } = await supa.from('te_comunicados').insert({
        tenant_id: vars.tenant_id, titulo: t.subject, cuerpo: t.html, publicado_en: new Date().toISOString()
      }).select('id').maybeSingle();
      if (com) {
        const destinatarios = vars.destinatarios || [{ candidato_id: vars.candidato_id }];
        await supa.from('tr_comunicado_destinatario').insert(
          destinatarios.map(d => ({
            tenant_id: vars.tenant_id, comunicado_id: com.id,
            candidato_id: d.candidato_id || null, empleado_id: d.empleado_id || null,
            canal: 'email', enviado_en: new Date().toISOString()
          }))
        );
      }
    } catch { /* la bitácora nunca debe tumbar el envío ya exitoso */ }
  }

  return { statusCode: resp.status, body: JSON.stringify(data) };
}
