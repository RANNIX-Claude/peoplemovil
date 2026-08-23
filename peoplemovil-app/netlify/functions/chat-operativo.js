// Agente IA operativo — responde dudas del día a día:
// checador, asignación, cancelaciones, cómo registrar candidatos, cómo promover.
// Usa Anthropic Claude via API si ANTHROPIC_API_KEY está seteado.

const SYSTEM = `Sos el asistente operativo de PeopleMovil, un motor de gestión de personal rotativo multi-tenant para México.

CONTEXTO DEL PRODUCTO
- Resuelve dos problemas: registro electrónico de jornada (Reforma LFT 2026-2027) y asignación diaria de personal por sitio/turno con certeza, penalizaciones y nómina/honorarios.
- Se implementó en Supabase/Postgres con RLS por tenant y frontend React/Tailwind desplegado en Netlify.
- Los parámetros de negocio (certeza mínima por puesto, margen entre turnos, ventana de cancelación, penalizaciones) viven en el catálogo cat_puestos y en cat_parametros_globales, NUNCA en código.

REGLAS DE NEGOCIO CLAVE (traducidas de PRC_* del sistema Lobo/AppSCPF)
1. PRC_Noempalmereservacion — un empleado no puede tener dos turnos que se traslapen ni que estén más cerca que "horas_entre_turnos" del puesto.
2. PRC_ValidaEmpPuesto + PRC_ObtenerCertezaPuesto — no se puede reservar a alguien cuya certeza (por puesto, no global) sea menor al "porcentaje_minimo" del puesto.
3. PRC_ValidacionesCancelarReservacion — no se puede cancelar si faltan menos de "horas_antes_cancelar" del puesto, salvo estado 'forzada'.
4. PRC_CancelacionAutomaticaPreasignados — reservaciones en 'confirmado_opcional' se cancelan solas si faltan <72h y llevan >8h sin confirmar (ambos valores editables en cat_parametros_globales).
5. eventos_biometricos es append-only, con timestamp de servidor y consentimiento vigente obligatorio.

TU ROL
- Respondé en español, breve y directo.
- Cuando la respuesta requiera una acción concreta en el sistema, nombrá la pantalla exacta (Personal, Checador, Sitios y Asignación, Nómina, Configuración).
- Si el usuario pregunta por un límite, mencioná el plan (FREE: 1 sitio y 15 empleados, sin móvil/asignación/nómina; PRO: ilimitado).
- Nunca inventes campos de la base. Si no lo sabés, decilo.`;

export async function handler(event) {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'method not allowed' };
  const { messages = [], user_prompt } = JSON.parse(event.body || '{}');
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) {
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: '[modo local] Configurá ANTHROPIC_API_KEY para respuestas reales. Prompt: ' + user_prompt })
    };
  }
  try {
    const resp = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-5',
        max_tokens: 700,
        system: SYSTEM,
        messages: user_prompt ? [{ role: 'user', content: user_prompt }] : messages
      })
    });
    const data = await resp.json();
    const text = (data?.content || []).map(b => b.text).join('\n');
    return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ text, raw: data }) };
  } catch (e) {
    return { statusCode: 500, body: JSON.stringify({ error: String(e) }) };
  }
}
