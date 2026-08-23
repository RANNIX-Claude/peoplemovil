// Notificación por email vía Resend. Casos: onboarding tenant, asignación de turno,
// recordatorio de checado, resultado de nómina.

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
  })
};

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { template, to, vars } = JSON.parse(event.body || '{}');
  const tpl = TEMPLATES[template];
  if (!tpl) return { statusCode: 400, body: JSON.stringify({ error: 'template desconocido' }) };
  const key = process.env.RESEND_API_KEY;
  if (!key) {
    return { statusCode: 200, body: JSON.stringify({ ok: true, dry: true, ...tpl(vars) }) };
  }
  const t = tpl(vars);
  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${key}`, 'content-type': 'application/json' },
    body: JSON.stringify({ from: 'PeopleMovil <no-reply@peoplemovil.mx>', to, subject: t.subject, html: t.html })
  });
  const data = await resp.json();
  return { statusCode: resp.status, body: JSON.stringify(data) };
}
