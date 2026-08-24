// Stripe: crea sesión Checkout + webhook para actualizar te_suscripciones
// GET /.netlify/functions/payments?action=checkout&plan=PRO → devuelve session.url
// POST /.netlify/functions/payments (con Stripe signature) → webhook

import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const STRIPE = process.env.STRIPE_SECRET_KEY ? new Stripe(process.env.STRIPE_SECRET_KEY) : null;

export async function handler(event) {
  const { httpMethod, queryStringParameters } = event;

  if (!STRIPE) {
    return { statusCode: 200, body: JSON.stringify({ ok: true, dry: true, note: 'STRIPE_SECRET_KEY no configurada' }) };
  }

  // Checkout
  if (httpMethod === 'GET' && queryStringParameters?.action === 'checkout') {
    const plan = queryStringParameters.plan;
    const tenant_id = queryStringParameters.tenant_id;
    const priceId = plan === 'PRO' ? process.env.STRIPE_PRICE_MENSUAL : null;
    if (!priceId) return { statusCode: 400, body: JSON.stringify({ error: 'Plan no configurado' }) };

    const session = await STRIPE.checkout.sessions.create({
      mode: 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${queryStringParameters.origin || 'https://peoplemovil-app.netlify.app'}/admin/suscripcion?ok=1`,
      cancel_url:  `${queryStringParameters.origin || 'https://peoplemovil-app.netlify.app'}/admin/suscripcion?cancel=1`,
      metadata: { tenant_id, plan }
    });
    return {
      statusCode: 200,
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ url: session.url })
    };
  }

  // Webhook Stripe
  if (httpMethod === 'POST') {
    const sig = event.headers['stripe-signature'];
    let ev;
    try {
      ev = STRIPE.webhooks.constructEvent(event.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (e) {
      return { statusCode: 400, body: `Webhook Error: ${e.message}` };
    }

    if (['checkout.session.completed','customer.subscription.updated','customer.subscription.deleted','invoice.payment_failed'].includes(ev.type)) {
      const supa = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE);
      const obj = ev.data.object;
      const tenant_id = obj.metadata?.tenant_id;
      if (tenant_id) {
        const plan = obj.metadata?.plan || 'PRO';
        const activa = !['customer.subscription.deleted','invoice.payment_failed'].includes(ev.type);
        await supa.from('te_suscripciones')
          .update({ plan_codigo: plan, activa })
          .eq('tenant_id', tenant_id).eq('activa', true);
      }
    }
    return { statusCode: 200, body: 'ok' };
  }

  return { statusCode: 405, body: 'method not allowed' };
}
