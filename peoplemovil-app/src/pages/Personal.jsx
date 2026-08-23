import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';

export default function Personal() {
  const [tab, setTab] = useState('empleados');
  const [empleados, setEmpleados] = useState([]);
  const [candidatos, setCandidatos] = useState([]);
  const [nuevoCand, setNuevoCand] = useState({ nombres: '', apellido_paterno: '', rfc: '', curp: '', sexo: 'M' });
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: e }, { data: c }] = await Promise.all([
      supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno, activo, regimen_pago').order('folio'),
      supabase.from('te_candidatos').select('id, nombres, apellido_paterno, paso_induccion, promovido_a_empleado').order('creado_en', { ascending: false })
    ]);
    setEmpleados(e || []); setCandidatos(c || []);
  }
  useEffect(() => { cargar(); }, []);

  async function altaCand(e) {
    e.preventDefault();
    if (!supabaseReady) { setMsg('Configurá VITE_SUPABASE_URL/KEY para persistir'); return; }
    const { error } = await supabase.from('te_candidatos').insert({ ...nuevoCand, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('Error: ' + error.message); return; }
    setNuevoCand({ nombres: '', apellido_paterno: '', rfc: '', curp: '', sexo: 'M' });
    setMsg('Candidato dado de alta');
    cargar();
  }

  async function promover(id) {
    const { error, data } = await supabase.rpc('promover_candidato_a_empleado', { p_candidato: id });
    setMsg(error ? 'Error: ' + error.message : 'Promovido, folio ' + data);
    cargar();
  }

  return (
    <div className="space-y-6">
      <div className="flex gap-1 border-b border-slate-200">
        {['empleados','candidatos','alta'].map(id => (
          <button key={id} onClick={() => setTab(id)}
            className={'px-3 py-2 text-sm font-medium ' + (tab === id ? 'border-b-2 border-brand-600 text-brand-700' : 'text-slate-600 hover:text-slate-900')}>
            {id[0].toUpperCase() + id.slice(1)}
          </button>
        ))}
      </div>

      {msg && <p className="text-xs text-slate-600">{msg}</p>}

      {tab === 'empleados' && (
        <div className="card overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Folio</th>
                <th className="px-4 py-2 text-left">Nombre</th>
                <th className="px-4 py-2 text-left">Régimen</th>
                <th className="px-4 py-2 text-left">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {empleados.map(e => (
                <tr key={e.id}>
                  <td className="px-4 py-2 tabular-nums">{e.folio}</td>
                  <td className="px-4 py-2">{e.nombres} {e.apellido_paterno}</td>
                  <td className="px-4 py-2">{e.regimen_pago}</td>
                  <td className="px-4 py-2">
                    <span className={'tag ' + (e.activo ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600')}>
                      {e.activo ? 'Activo' : 'Baja'}
                    </span>
                  </td>
                </tr>
              ))}
              {!empleados.length && <tr><td colSpan="4" className="p-6 text-center text-slate-500 text-xs">Aún no hay empleados. Promoví candidatos desde la pestaña Candidatos.</td></tr>}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'candidatos' && (
        <div className="card overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Nombre</th>
                <th className="px-4 py-2 text-left">Inducción</th>
                <th className="px-4 py-2 text-left">Estado</th>
                <th></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {candidatos.map(c => (
                <tr key={c.id}>
                  <td className="px-4 py-2">{c.nombres} {c.apellido_paterno}</td>
                  <td className="px-4 py-2">
                    <span className={'tag ' + (c.paso_induccion ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800')}>
                      {c.paso_induccion ? 'Confirmada' : 'Pendiente'}
                    </span>
                  </td>
                  <td className="px-4 py-2 text-xs text-slate-500">{c.promovido_a_empleado ? 'Ya empleado' : 'Candidato'}</td>
                  <td className="px-4 py-2 text-right">
                    {c.paso_induccion && !c.promovido_a_empleado && (
                      <button className="btn-primary" onClick={() => promover(c.id)}>Promover a empleado</button>
                    )}
                  </td>
                </tr>
              ))}
              {!candidatos.length && <tr><td colSpan="4" className="p-6 text-center text-slate-500 text-xs">Sin candidatos.</td></tr>}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'alta' && (
        <form onSubmit={altaCand} className="card p-4 grid grid-cols-1 md:grid-cols-2 gap-4 max-w-2xl">
          <div><label className="label">Nombres</label><input className="field" required value={nuevoCand.nombres} onChange={e => setNuevoCand({ ...nuevoCand, nombres: e.target.value })} /></div>
          <div><label className="label">Apellido paterno</label><input className="field" required value={nuevoCand.apellido_paterno} onChange={e => setNuevoCand({ ...nuevoCand, apellido_paterno: e.target.value })} /></div>
          <div><label className="label">RFC</label><input className="field" value={nuevoCand.rfc} onChange={e => setNuevoCand({ ...nuevoCand, rfc: e.target.value.toUpperCase() })} /></div>
          <div><label className="label">CURP</label><input className="field" value={nuevoCand.curp} onChange={e => setNuevoCand({ ...nuevoCand, curp: e.target.value.toUpperCase() })} /></div>
          <div><label className="label">Sexo</label>
            <select className="field" value={nuevoCand.sexo} onChange={e => setNuevoCand({ ...nuevoCand, sexo: e.target.value })}>
              <option value="M">Masculino</option><option value="F">Femenino</option><option value="X">Otro</option>
            </select>
          </div>
          <div className="md:col-span-2"><button className="btn-primary" type="submit">Registrar candidato</button></div>
          <p className="md:col-span-2 text-xs text-slate-500">
            La validación de RFC/CURP duplicado (PRC_ValidaRfcCurp) corre a nivel schema — no vas a poder guardar duplicados.
          </p>
        </form>
      )}
    </div>
  );
}
