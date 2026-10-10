import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import { PLANES } from '../../lib/plan.js';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Badge from '../../components/ui/Badge.jsx';
import { tituloConLinea } from '../../components/ui/CardHeader.jsx';
import { useModuleAudit } from '../../lib/audit.js';

const fmt$ = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Suscripcion() {
  useModuleAudit('suscripcion');
  const [susc, setSusc] = useState(null);
  const [tenant, setTenant] = useState(null);
  const [uso, setUso] = useState({ sitios: 0, empleados: 0 });
  const [msg, setMsg] = useState(null);

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: t }, { data: s }, { count: cs }, { count: ce }] = await Promise.all([
      supabase.from('te_tenants').select('*').eq('id', DEMO_TENANT_ID).maybeSingle(),
      supabase.from('te_suscripciones').select('*, tc_planes_suscripcion(*)').eq('tenant_id', DEMO_TENANT_ID).eq('activa', true).maybeSingle(),
      supabase.from('tc_sitios').select('*', { count: 'exact', head: true }).eq('activo', true),
      supabase.from('te_empleados').select('*', { count: 'exact', head: true }).eq('activo', true)
    ]);
    setTenant(t); setSusc(s);
    setUso({ sitios: cs || 0, empleados: ce || 0 });
  }

  const cambiarPlan = async plan => {
    // Actualizar suscripcion actual (en real Stripe se dispararía checkout)
    setMsg('En producción: se redirige a Stripe Checkout con el price_id del plan ' + plan);
    // Demo: hacer update directo si el usuario confirma
    if (!confirm(`Cambiar a plan ${plan}? (demo — sin cobro real)`)) return;
    const { error } = await supabase.from('te_suscripciones')
      .update({ plan_codigo: plan }).eq('tenant_id', DEMO_TENANT_ID).eq('activa', true);
    setMsg(error ? '❌ ' + error.message : '✓ Plan cambiado a ' + plan);
    cargar();
  };

  const irPortalCliente = () => {
    setMsg('En producción: se redirige a Stripe Customer Portal para gestionar método de pago, ver facturas y cancelar.');
  };

  const codigoPlan = susc?.plan_codigo || 'FREE';
  const plan = PLANES[codigoPlan] || PLANES.FREE;

  return (
    <div>
      <div className="section-eyebrow">Administración</div>
      <h1>Mi suscripción</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Estado de la suscripción SaaS de <strong>{tenant?.razon_social || 'este tenant'}</strong> con PeopleMovil.
      </p>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

      <div className="kpi-grid">
        <KpiCard label="Plan activo" value={codigoPlan} sub={plan.titulo} color="var(--accent2)" />
        <KpiCard label="Sitios usados" value={uso.sitios} sub={plan.max_sitios ? `de ${plan.max_sitios}` : 'ilimitado'}
                 color={plan.max_sitios && uso.sitios >= plan.max_sitios ? 'var(--red)' : 'var(--green)'} />
        <KpiCard label="Empleados usados" value={uso.empleados} sub={plan.max_empleados_activos ? `de ${plan.max_empleados_activos}` : 'ilimitado'}
                 color={plan.max_empleados_activos && uso.empleados >= plan.max_empleados_activos ? 'var(--red)' : 'var(--green)'} />
        <KpiCard label="Costo mensual" value={fmt$(plan.precio_mensual_mxn)} sub="MXN + IVA" />
      </div>

      <div className="card">
        <h3 style={tituloConLinea}>💎 Detalle de tu plan {codigoPlan}</h3>
        {susc && (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, fontSize: 13, marginBottom: 16 }}>
            <div><div className="label">Estado</div><Badge estado="activo">ACTIVA</Badge></div>
            <div><div className="label">Vigente desde</div><div>{susc.vigente_desde ? new Date(susc.vigente_desde).toLocaleDateString('es-MX') : '—'}</div></div>
            {susc.vigente_hasta && <div><div className="label">Vigente hasta</div><div>{new Date(susc.vigente_hasta).toLocaleDateString('es-MX')}</div></div>}
          </div>
        )}

        <div style={{ display: 'grid', gap: 6, fontSize: 13 }}>
          {[
            ['Checador fijo', plan.incluye_checador_fijo !== false],
            ['Checador móvil', plan.incluye_checador_movil],
            ['Asignación / pedidos', plan.incluye_asignacion],
            ['Nómina / honorarios', plan.incluye_nomina],
            ['REPSE', plan.incluye_repse]
          ].map(([label, ok]) => (
            <div key={label} style={{ display: 'flex', gap: 8 }}>
              <span style={{ color: ok ? 'var(--green)' : 'var(--red)', fontWeight: 900 }}>{ok ? '✓' : '✗'}</span>
              <span>{label}</span>
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', gap: 10, marginTop: 20, flexWrap: 'wrap' }}>
          {codigoPlan === 'FREE' ? (
            <button className="btn green" onClick={() => cambiarPlan('PRO')}>Upgrade a PRO ({fmt$(1499)} MXN/mes)</button>
          ) : (
            <button className="btn outline" onClick={() => cambiarPlan('FREE')}>Downgrade a FREE</button>
          )}
          <button className="btn outline" onClick={irPortalCliente}>💳 Método de pago / Facturas</button>
        </div>
      </div>

      <div className="card">
        <div className="section-eyebrow">Nota implementación</div>
        <p style={{ fontSize: 12, color: 'var(--muted)' }}>
          En producción: los botones de cambio de plan disparan Stripe Checkout via <code>/.netlify/functions/payments</code>.
          El webhook <code>customer.subscription.updated</code> actualiza <code>te_suscripciones</code> automáticamente.
          Para México, alternativa Conekta también disponible (env vars <code>CONEKTA_*</code>).
        </p>
      </div>
    </div>
  );
}
