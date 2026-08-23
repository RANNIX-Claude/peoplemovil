import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';

export default function Configuracion() {
  const [params, setParams] = useState(null);
  const [puestos, setPuestos] = useState([]);
  const [msg, setMsg] = useState('');

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: ps }] = await Promise.all([
      supabase.from('cat_parametros_globales').select('*').eq('tenant_id', DEMO_TENANT_ID).maybeSingle(),
      supabase.from('cat_puestos').select('id, titulo, porcentaje_certeza_inicial, porcentaje_minimo, horas_entre_turnos, horas_antes_cancelar, penalizacion_retardo, penalizacion_falta').order('titulo').limit(50)
    ]);
    setParams(p); setPuestos(ps || []);
  }

  async function guardarParams() {
    const { error } = await supabase.from('cat_parametros_globales').update(params).eq('tenant_id', DEMO_TENANT_ID);
    setMsg(error ? 'Error: ' + error.message : 'Guardado');
  }

  return (
    <div className="space-y-6">
      <section className="card p-4">
        <h2 className="text-sm font-semibold mb-3">Parámetros globales del tenant</h2>
        {!params ? <p className="text-xs text-slate-500">Cargando…</p> : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {[
              ['horas_lookahead_autocancel', 'Ventana lookahead auto-cancelación (h)'],
              ['horas_gracia_confirmacion', 'Gracia para confirmar (h)'],
              ['retencion_registros_dias', 'Retención de registros (días)'],
              ['certeza_inicial_default', 'Certeza inicial default (0-1)'],
              ['aviso_privacidad_version', 'Versión del aviso de privacidad']
            ].map(([k, l]) => (
              <div key={k}>
                <label className="label">{l}</label>
                <input className="field" value={params[k] ?? ''} onChange={e => setParams({ ...params, [k]: e.target.value })} />
              </div>
            ))}
            <div className="md:col-span-3 flex justify-between">
              <p className="text-xs text-slate-500">Los 72h/8h del sistema original vivían hardcodeados. Aquí son editables por tenant.</p>
              <button className="btn-primary" onClick={guardarParams}>Guardar</button>
            </div>
          </div>
        )}
        {msg && <p className="mt-2 text-xs text-slate-600">{msg}</p>}
      </section>

      <section className="card overflow-x-auto">
        <div className="p-3 border-b text-sm font-semibold">Parámetros por puesto (cat_puestos)</div>
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2 text-left">Puesto</th>
              <th className="px-4 py-2 text-right">Certeza inicial</th>
              <th className="px-4 py-2 text-right">Mín. certeza</th>
              <th className="px-4 py-2 text-right">Horas entre turnos</th>
              <th className="px-4 py-2 text-right">Horas antes cancelar</th>
              <th className="px-4 py-2 text-right">Pen. retardo</th>
              <th className="px-4 py-2 text-right">Pen. falta</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {puestos.map(p => (
              <tr key={p.id}>
                <td className="px-4 py-2 font-medium">{p.titulo}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.porcentaje_certeza_inicial}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.porcentaje_minimo}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.horas_entre_turnos}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.horas_antes_cancelar}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.penalizacion_retardo}</td>
                <td className="px-4 py-2 text-right tabular-nums">{p.penalizacion_falta}</td>
              </tr>
            ))}
            {!puestos.length && <tr><td colSpan="7" className="p-6 text-center text-slate-500 text-xs">Sin puestos.</td></tr>}
          </tbody>
        </table>
        <p className="text-xs text-slate-500 p-3 border-t">
          Cada valor de esta tabla es lo que consultan los triggers de validación (PRC_ObtenerCertezaPuesto, PRC_Noempalmereservacion, PRC_ValidacionesCancelarReservacion). Cambiar aquí = cambiar la regla, sin tocar código.
        </p>
      </section>
    </div>
  );
}
