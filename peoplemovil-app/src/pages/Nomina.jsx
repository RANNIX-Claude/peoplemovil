import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';

export default function Nomina() {
  const [periodos, setPeriodos] = useState([]);
  const [detalle, setDetalle] = useState([]);
  const [precauciones, setPrec] = useState([]);
  const [seleccion, setSel] = useState(null);
  const [msg, setMsg] = useState('');

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: prec }] = await Promise.all([
      supabase.from('nominas_periodo').select('*').order('fecha_desde', { ascending: false }),
      supabase.rpc('reporte_precauciones_nomina', { p_tenant: DEMO_TENANT_ID })
    ]);
    setPeriodos(p || []); setPrec(prec || []);
  }

  async function verDetalle(nom) {
    setSel(nom);
    const { data } = await supabase.from('nomina_detalle').select('*').eq('nomina_id', nom.id);
    setDetalle(data || []);
  }

  async function calcular(nom) {
    const { error, data } = await supabase.rpc('calcular_nomina_periodo', { p_nomina: nom.id });
    setMsg(error ? 'Error: ' + error.message : 'Calculado, ' + data + ' empleados');
    verDetalle(nom);
  }

  return (
    <div className="space-y-6">
      <section className="card p-4">
        <h2 className="text-sm font-semibold mb-3">Precauciones antes de cierre (PRC_ReportePrecaucionesNomina)</h2>
        {precauciones.length === 0
          ? <p className="text-xs text-slate-500">Sin precauciones. Todo el personal está listo para dispersión.</p>
          : <ul className="text-xs divide-y">{precauciones.map(p => (
              <li key={p.empleado_id} className="py-2 flex justify-between">
                <span className="font-medium">{p.nombre}</span>
                <span className="text-rose-700">{(p.motivos || []).join(', ')}</span>
              </li>
            ))}</ul>}
      </section>

      <section className="card overflow-x-auto">
        <div className="p-3 border-b text-sm font-semibold">Periodos de nómina</div>
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2 text-left">Ciclo</th>
              <th className="px-4 py-2 text-left">Desde</th>
              <th className="px-4 py-2 text-left">Hasta</th>
              <th className="px-4 py-2 text-left">Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {periodos.map(p => (
              <tr key={p.id}>
                <td className="px-4 py-2">{p.ciclo_pago}</td>
                <td className="px-4 py-2">{p.fecha_desde}</td>
                <td className="px-4 py-2">{p.fecha_hasta}</td>
                <td className="px-4 py-2"><span className={'tag ' + (p.cerrada ? 'bg-slate-100 text-slate-600' : 'bg-amber-100 text-amber-800')}>{p.cerrada ? 'Cerrada' : 'Abierta'}</span></td>
                <td className="px-4 py-2 text-right space-x-2">
                  <button className="btn-ghost" onClick={() => verDetalle(p)}>Ver</button>
                  {!p.cerrada && <button className="btn-primary" onClick={() => calcular(p)}>Calcular</button>}
                </td>
              </tr>
            ))}
            {!periodos.length && <tr><td colSpan="5" className="p-6 text-center text-slate-500 text-xs">Sin periodos aún. Crear uno desde configuración.</td></tr>}
          </tbody>
        </table>
      </section>

      {seleccion && (
        <section className="card overflow-x-auto">
          <div className="p-3 border-b text-sm font-semibold">Detalle del periodo {seleccion.fecha_desde} → {seleccion.fecha_hasta}</div>
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Empleado</th>
                <th className="px-4 py-2 text-right">Turnos</th>
                <th className="px-4 py-2 text-right">Bruto</th>
                <th className="px-4 py-2 text-right">Penal.</th>
                <th className="px-4 py-2 text-right">Neto</th>
                <th className="px-4 py-2 text-left">Régimen</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {detalle.map(d => (
                <tr key={d.id}>
                  <td className="px-4 py-2 font-mono text-xs">{d.empleado_id.slice(0, 8)}…</td>
                  <td className="px-4 py-2 text-right tabular-nums">{d.reservaciones_cnt}</td>
                  <td className="px-4 py-2 text-right tabular-nums">${d.monto_bruto}</td>
                  <td className="px-4 py-2 text-right tabular-nums">${d.penalizaciones_aplicadas}</td>
                  <td className="px-4 py-2 text-right tabular-nums font-semibold">${d.monto_neto}</td>
                  <td className="px-4 py-2 text-xs">{d.regimen_pago}</td>
                </tr>
              ))}
              {!detalle.length && <tr><td colSpan="6" className="p-6 text-center text-slate-500 text-xs">Sin detalle. Presiona Calcular.</td></tr>}
            </tbody>
          </table>
        </section>
      )}
      {msg && <p className="text-xs text-slate-600">{msg}</p>}
    </div>
  );
}
