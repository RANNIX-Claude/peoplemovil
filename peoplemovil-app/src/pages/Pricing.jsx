import React from 'react';
import { PLANES } from '../lib/plan.js';

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
  return (
    <div>
      <div className="text-center max-w-2xl mx-auto">
        <h1 className="text-2xl font-bold">Planes que se ajustan al tamaño del negocio</h1>
        <p className="mt-2 text-sm text-slate-600">
          Los límites viven en catálogo, no en código. Cambiar de plan es cambiar una fila en <code>suscripciones</code>.
        </p>
      </div>
      <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
        {CARDS.map(c => (
          <div key={c.plan.codigo} className={'card p-6 ' + (c.highlight ? 'ring-2 ring-brand-600' : '')}>
            <div className="flex items-baseline justify-between">
              <h2 className="text-xl font-bold">{c.plan.titulo}</h2>
              <div className="text-right">
                <span className="text-3xl font-bold">${c.plan.precio_mensual_mxn.toLocaleString('es-MX')}</span>
                <span className="text-xs text-slate-500"> MXN/mes</span>
              </div>
            </div>
            <p className="mt-2 text-sm text-slate-600">{c.tagline}</p>
            <ul className="mt-6 space-y-2 text-sm">
              {c.features.map(f => (
                <li key={f} className="flex gap-2"><span className="text-emerald-600 shrink-0">✓</span><span>{f}</span></li>
              ))}
            </ul>
            <button className={'mt-6 w-full ' + (c.highlight ? 'btn-primary justify-center' : 'btn-ghost justify-center border border-slate-300')}>{c.cta}</button>
          </div>
        ))}
      </div>
    </div>
  );
}
