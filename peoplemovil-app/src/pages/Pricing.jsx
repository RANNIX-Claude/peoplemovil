import React from 'react';
import { PLANES } from '../lib/plan.js';
import { useModuleAudit } from '../lib/audit.js';

const CARDS = [
  {
    plan: PLANES.FREE,
    tagline: 'Cumplí con el checador legal sin pagar.',
    features: [
      '1 sitio activo',
      'Hasta 15 trabajadores',
      'Checador fijo (lector USB + agente local)',
      'Registro append-only con timestamp de servidor',
      'Consentimiento biométrico versionado',
      'Retención 5 años configurable',
      'Multi-tenant con RLS'
    ],
    cta: 'Empezar gratis',
    highlight: false
  },
  {
    plan: PLANES.PRO,
    tagline: 'Motor completo de asignación, checador dual y nómina.',
    features: [
      'Sitios y trabajadores ilimitados',
      'Checador fijo + móvil (GPS + selfie)',
      'Módulo de pedidos y asignación',
      'Motor de certeza por puesto',
      'Validación de traslape y ventana de cancelación',
      'Cancelación automática de preasignados',
      'Nómina/honorarios con dispersión diferenciada',
      'Reporte de precauciones antes del cierre',
      'REPSE por reservación',
      'Reportes de cumplimiento STPS/IMSS'
    ],
    cta: 'Elegir PRO',
    highlight: true
  }
];

export default function Pricing() {
  useModuleAudit('pricing');
  return (
    <div>
      <div className="section-eyebrow">Suscripción</div>
      <h1>Planes de PeopleMovil</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Los límites viven en catálogo (<code>tc_planes_suscripcion</code>), no en código. Cambiar de plan es cambiar una fila en <code>te_suscripciones</code>.</p>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: 20 }}>
        {CARDS.map(c => (
          <div key={c.plan.codigo} className="card" style={{ margin: 0, borderColor: c.highlight ? 'var(--accent)' : undefined, borderWidth: c.highlight ? 2 : 1 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 6 }}>
              <h2 style={{ margin: 0 }}>{c.plan.titulo}</h2>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontSize: 28, fontWeight: 900, color: 'var(--accent)' }}>${c.plan.precio_mensual_mxn.toLocaleString('es-MX')}</span>
                <span style={{ fontSize: 11, color: 'var(--muted)' }}> MXN/mes</span>
              </div>
            </div>
            <p style={{ color: 'var(--muted)', fontSize: 13, marginBottom: 16 }}>{c.tagline}</p>
            <ul style={{ listStyle: 'none', display: 'grid', gap: 8, fontSize: 13 }}>
              {c.features.map(f => (
                <li key={f} style={{ display: 'flex', gap: 8 }}>
                  <span style={{ color: 'var(--green)', fontWeight: 900 }}>✓</span>
                  <span>{f}</span>
                </li>
              ))}
            </ul>
            <button className={'btn ' + (c.highlight ? '' : 'outline')} style={{ marginTop: 20, width: '100%', justifyContent: 'center' }}>{c.cta}</button>
          </div>
        ))}
      </div>
    </div>
  );
}
