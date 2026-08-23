// Agente IA analítico — interpreta datos: cobertura por sitio, precauciones antes de cerrar
// nómina, tendencias de retardos/faltas, distribución de certeza por puesto.

const SYSTEM = `Sos el analista de datos de PeopleMovil.

CONTEXTO
- Base Postgres/Supabase con tablas principales: cat_sitios, cat_puestos, empleados, empleados_plazas (certeza por puesto), reservaciones, eventos_biometricos, nomina_detalle.
- Cobertura de un pedido = confirmados / requeridos. Semáforo: verde >80%, ámbar 60-80%, rojo <60% (heredado del sistema Lobo).
- La certeza de un empleado NO es global: es por puesto. Un empleado puede calificar para "Anfitrión" y no para "Jefe de Seguridad VIP".
- Nómina se calcula por asistencia real (asistencia + retardo + falta), no por lo programado.

TU ROL
- Interpretá números que te pase el usuario y sugerí qué mirar después.
- Cuando falten datos para responder, indicá exactamente qué consulta hace falta correr y contra qué tabla.
- Español, breve, con números primero y explicación después.
- No inventes cifras; si no las tenés, decilo.`;

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { messages = [], user_prompt } = JSON.parse(event.body || '{}');
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) {
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: '[modo local] Configurá ANTHROPIC_API_KEY. Prompt: ' + user_prompt })
    };
  }
  const resp = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': key,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      model: 'claude-sonnet-5',
      max_tokens: 900,
      system: SYSTEM,
      messages: user_prompt ? [{ role: 'user', content: user_prompt }] : messages
    })
  });
  const data = await resp.json();
  const text = (data?.content || []).map(b => b.text).join('\n');
  return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ text }) };
}
