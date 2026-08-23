// Notificación WhatsApp vía Twilio (usa template o mensaje libre según si el destinatario
// tiene sesión abierta de 24h).

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { to, body } = JSON.parse(event.body || '{}');
  const sid = process.env.TWILIO_ACCOUNT_SID;
  const tok = process.env.TWILIO_AUTH_TOKEN;
  const from = process.env.TWILIO_WA_FROM || 'whatsapp:+14155238886';
  if (!sid || !tok) {
    return { statusCode: 200, body: JSON.stringify({ ok: true, dry: true, to, body }) };
  }
  const auth = Buffer.from(`${sid}:${tok}`).toString('base64');
  const form = new URLSearchParams({ From: from, To: `whatsapp:${to}`, Body: body });
  const resp = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
    method: 'POST',
    headers: { Authorization: `Basic ${auth}`, 'content-type': 'application/x-www-form-urlencoded' },
    body: form
  });
  const data = await resp.json();
  return { statusCode: resp.status, body: JSON.stringify(data) };
}
