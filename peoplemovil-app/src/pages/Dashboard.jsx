import React, { useEffect, useState } from 'react';
import Semaforo from '../components/Semaforo.jsx';
import { supabase, supabaseReady } from '../lib/supabase.js';

export default function Dashboard() {
  const [kpis, setKpis] = useState({ sitios: 0, empleados: 0, pedidos_hoy: 0, cobertura: 0 });
  const [coberturas, setCoberturas] = useState([]);
  const [alertas, setAlertas] = useState([]);
  const [precauciones, setPrecauciones] = useState([]);

  useEffect(() => {
    if (!supabaseReady) return;
    (async () => {
      const [{ count: s }, { count: e }, { data: cob }] = await Promise.all([
        supabase.from('cat_sitios').select('*', { count: 'exact', head: true }).eq('activo', true),
        supabase.from('empleados').select('*', { count: 'exact', head: true }).eq('activo', true),
        supabase.rpc('reporte_precauciones_nomina', { p_tenant: '00000000-0000-0000-0000-000000000001' })
      ]);
      setKpis(k => ({ ...k, sitios: s || 0, empleados: e || 0 }));
      setPrecauciones(cob || []);
    })();
  }, []);

  const kpi = [
    { label: 'Sitios activos', value: kpis.sitios },
    { label: 'Empleados activos', value: kpis.empleados },
    { label: 'Pedidos hoy', value: kpis.pedidos_hoy },
    { label: 'Cobertura promedio', value: `${Math.round((kpis.cobertura || 0) * 100)}%` }
  ];

  return (
    <div className="space-y-6">
      <section className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {kpi.map(k => (
          <div key={k.label} className="card p-4">
            <p className="text-xs uppercase tracking-wide text-slate-500">{k.label}</p>
            <p className="mt-2 text-2xl font-bold tabular-nums">{k.value}</p>
          </div>
        ))}
      </section>

      <section className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-4">
          <h2 className="text-sm font-semibold mb-3">Cobertura por sitio (semáforo)</h2>
          {coberturas.length === 0 ? (
            <p className="text-xs text-slate-500">Sin pedidos activos aún. Cuando los haya, se pintan aquí.</p>
          ) : (
            <ul className="space-y-3">
              {coberturas.map(c => (
                <li key={c.sitio_id}>
                  <div className="flex justify-between text-xs mb-1">
                    <span className="font-medium">{c.sitio}</span>
                    <span className="text-slate-500">{c.confirmados}/{c.requeridos}</span>
                  </div>
                  <Semaforo porcentaje={c.pct} />
                </li>
              ))}
            </ul>
          )}
        </div>

        <div className="card p-4">
          <h2 className="text-sm font-semibold mb-3">Alertas y precauciones</h2>
          {precauciones.length === 0 ? (
            <p className="text-xs text-slate-500">Sin precauciones. Todo el personal tiene datos fiscales completos.</p>
          ) : (
            <ul className="text-xs divide-y divide-slate-100">
              {precauciones.slice(0, 8).map(p => (
                <li key={p.empleado_id} className="py-2 flex justify-between">
                  <span className="font-medium">{p.nombre}</span>
                  <span className="text-rose-700">{(p.motivos || []).join(', ')}</span>
                </li>
              ))}
            </ul>
          )}
          {alertas.length > 0 && (
            <ul className="mt-4 space-y-1 text-xs">
              {alertas.map((a, i) => (
                <li key={i} className="text-amber-800">⚠ {a}</li>
              ))}
            </ul>
          )}
        </div>
      </section>

      <section className="card p-4 text-xs text-slate-500">
        <p>
          <strong className="text-slate-700">Cumplimiento LFT 2026-2027:</strong> el registro de asistencia
          está en modo append-only (RLS bloquea UPDATE/DELETE en <code>eventos_biometricos</code>).
          Cada evento está vinculado a un consentimiento vigente. Retención configurable en Configuración.
        </p>
      </section>
    </div>
  );
}
