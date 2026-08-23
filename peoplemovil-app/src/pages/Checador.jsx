import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';

export default function Checador() {
  const [modo, setModo] = useState('fijo');
  const [empleados, setEmpleados] = useState([]);
  const [historial, setHistorial] = useState([]);
  const [seleccion, setSeleccion] = useState({ empleado_id: '', tipo_marcaje: 'entrada', dispositivo_serie: 'USB-DEMO-001' });
  const [ubi, setUbi] = useState(null);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    (async () => {
      const [{ data: emp }, { data: hist }] = await Promise.all([
        supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno').eq('activo', true).order('folio'),
        supabase.from('te_eventos_biometricos').select('id, ts_servidor, tipo_marcaje, empleado_id, medio_asistencia').order('ts_servidor', { ascending: false }).limit(30)
      ]);
      setEmpleados(emp || []); setHistorial(hist || []);
    })();
  }, []);

  useEffect(() => {
    if (modo === 'movil' && navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        pos => setUbi({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
        () => setUbi({ error: 'sin permiso' })
      );
    }
  }, [modo]);

  async function checar() {
    if (!seleccion.empleado_id) { setMsg('Elegí un empleado'); return; }
    const { data: disp } = await supabase.from('tc_dispositivos').select('id, consentimiento_id').eq('numero_serie', seleccion.dispositivo_serie).maybeSingle();
    const payload = {
      tenant_id: DEMO_TENANT_ID,
      empleado_id: seleccion.empleado_id,
      tipo_marcaje: seleccion.tipo_marcaje,
      medio_asistencia: modo === 'movil' ? 'geolocalizacion' : 'biometrico',
      dispositivo_id: disp?.id,
      latitud: ubi?.lat,
      longitud: ubi?.lng,
      hash_muestra: 'demo-' + crypto.randomUUID(),
      // consentimiento_id lo fuerza el trigger tg_evbio_valida con consentimiento_vigente()
      consentimiento_id: '00000000-0000-0000-0000-000000000000'
    };
    const { error } = await supabase.from('te_eventos_biometricos').insert(payload);
    if (error) { setMsg('Rechazado: ' + error.message); return; }
    setMsg('Marcaje registrado');
    const { data: hist } = await supabase.from('te_eventos_biometricos').select('id, ts_servidor, tipo_marcaje, empleado_id, medio_asistencia').order('ts_servidor', { ascending: false }).limit(30);
    setHistorial(hist || []);
  }

  return (
    <div className="space-y-6">
      <div className="flex gap-2">
        <button onClick={() => setModo('fijo')} className={'btn ' + (modo === 'fijo' ? 'bg-brand-600 text-white' : 'bg-slate-100 text-slate-700')}>Checador fijo (USB)</button>
        <button onClick={() => setModo('movil')} className={'btn ' + (modo === 'movil' ? 'bg-brand-600 text-white' : 'bg-slate-100 text-slate-700')}>Checador móvil (GPS)</button>
      </div>

      <div className="card p-4 grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
        <div className="md:col-span-2"><label className="label">Empleado</label>
          <select className="field" value={seleccion.empleado_id} onChange={e => setSeleccion({ ...seleccion, empleado_id: e.target.value })}>
            <option value="">— seleccionar —</option>
            {empleados.map(e => <option key={e.id} value={e.id}>#{e.folio} · {e.nombres} {e.apellido_paterno}</option>)}
          </select>
        </div>
        <div><label className="label">Tipo</label>
          <select className="field" value={seleccion.tipo_marcaje} onChange={e => setSeleccion({ ...seleccion, tipo_marcaje: e.target.value })}>
            <option value="entrada">Entrada</option><option value="salida">Salida</option>
          </select>
        </div>
        {modo === 'fijo' ? (
          <div><label className="label">Dispositivo (serie)</label>
            <input className="field" value={seleccion.dispositivo_serie} onChange={e => setSeleccion({ ...seleccion, dispositivo_serie: e.target.value })} />
          </div>
        ) : (
          <div><label className="label">Ubicación GPS</label>
            <div className="text-xs text-slate-600">{ubi?.lat ? `${ubi.lat.toFixed(5)}, ${ubi.lng.toFixed(5)}` : (ubi?.error || 'obteniendo…')}</div>
          </div>
        )}
        <div className="md:col-span-4 flex justify-between items-center">
          <p className="text-xs text-slate-500">
            {modo === 'movil'
              ? 'Modo móvil requiere plan PRO. El trigger verifica plan del tenant antes de aceptar.'
              : 'Modo fijo: se envía la serie del lector para trazabilidad legal.'}
          </p>
          <button className="btn-primary" onClick={checar}>Registrar marcaje</button>
        </div>
      </div>

      {msg && <p className="text-xs text-slate-600">{msg}</p>}

      <div className="card overflow-x-auto">
        <div className="p-3 border-b text-xs text-slate-500">Últimos 30 marcajes (append-only, timestamp de servidor)</div>
        <table className="min-w-full text-sm">
          <thead className="bg-slate-50 text-xs uppercase text-slate-500">
            <tr>
              <th className="px-4 py-2 text-left">Timestamp servidor</th>
              <th className="px-4 py-2 text-left">Empleado</th>
              <th className="px-4 py-2 text-left">Tipo</th>
              <th className="px-4 py-2 text-left">Medio</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {historial.map(h => {
              const e = empleados.find(x => x.id === h.empleado_id);
              return (
                <tr key={h.id}>
                  <td className="px-4 py-2 font-mono text-xs">{new Date(h.ts_servidor).toLocaleString('es-MX')}</td>
                  <td className="px-4 py-2">{e ? `#${e.folio} ${e.nombres} ${e.apellido_paterno}` : h.empleado_id}</td>
                  <td className="px-4 py-2 capitalize">{h.tipo_marcaje}</td>
                  <td className="px-4 py-2 text-xs">{h.medio_asistencia}</td>
                </tr>
              );
            })}
            {!historial.length && <tr><td colSpan="4" className="p-6 text-center text-slate-500 text-xs">Sin marcajes aún.</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}
