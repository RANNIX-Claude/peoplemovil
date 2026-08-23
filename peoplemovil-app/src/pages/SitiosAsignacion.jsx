import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';

export default function SitiosAsignacion() {
  const [tab, setTab] = useState('sitios');
  const [sitios, setSitios] = useState([]);
  const [pedidos, setPedidos] = useState([]);
  const [msg, setMsg] = useState('');
  const [nuevoSitio, setNuevoSitio] = useState({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: s }, { data: p }] = await Promise.all([
      supabase.from('cat_sitios').select('id, titulo, tipo_sitio, direccion_abreviada, activo').order('titulo'),
      supabase.from('pedidos').select('id, folio, titulo, fecha_evento, status').order('fecha_evento', { ascending: false }).limit(50)
    ]);
    setSitios(s || []); setPedidos(p || []);
  }
  useEffect(() => { cargar(); }, []);

  async function altaSitio(e) {
    e.preventDefault();
    const { error } = await supabase.from('cat_sitios').insert({ ...nuevoSitio, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    setNuevoSitio({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });
    setMsg('Sitio creado');
    cargar();
  }

  return (
    <div className="space-y-6">
      <div className="flex gap-1 border-b border-slate-200">
        {['sitios','pedidos','nuevo-sitio'].map(id => (
          <button key={id} onClick={() => setTab(id)}
            className={'px-3 py-2 text-sm font-medium capitalize ' + (tab === id ? 'border-b-2 border-brand-600 text-brand-700' : 'text-slate-600 hover:text-slate-900')}>
            {id.replace('-', ' ')}
          </button>
        ))}
      </div>
      {msg && <p className="text-xs text-slate-600">{msg}</p>}

      {tab === 'sitios' && (
        <div className="card overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Sitio</th>
                <th className="px-4 py-2 text-left">Tipo</th>
                <th className="px-4 py-2 text-left">Dirección</th>
                <th className="px-4 py-2 text-left">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {sitios.map(s => (
                <tr key={s.id}>
                  <td className="px-4 py-2 font-medium">{s.titulo}</td>
                  <td className="px-4 py-2 text-xs text-slate-500 capitalize">{s.tipo_sitio}</td>
                  <td className="px-4 py-2 text-xs text-slate-500">{s.direccion_abreviada || '—'}</td>
                  <td className="px-4 py-2"><span className={'tag ' + (s.activo ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-500')}>{s.activo ? 'Activo' : 'Inactivo'}</span></td>
                </tr>
              ))}
              {!sitios.length && <tr><td colSpan="4" className="p-6 text-center text-slate-500 text-xs">Sin sitios cargados aún.</td></tr>}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'pedidos' && (
        <div className="card overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Folio</th>
                <th className="px-4 py-2 text-left">Título</th>
                <th className="px-4 py-2 text-left">Fecha</th>
                <th className="px-4 py-2 text-left">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {pedidos.map(p => (
                <tr key={p.id}>
                  <td className="px-4 py-2 tabular-nums">{p.folio}</td>
                  <td className="px-4 py-2">{p.titulo}</td>
                  <td className="px-4 py-2">{p.fecha_evento}</td>
                  <td className="px-4 py-2 text-xs">{p.status}</td>
                </tr>
              ))}
              {!pedidos.length && <tr><td colSpan="4" className="p-6 text-center text-slate-500 text-xs">Sin pedidos.</td></tr>}
            </tbody>
          </table>
          <p className="text-xs text-slate-500 p-3 border-t">
            Crear pedidos requiere plan PRO. Al insertar, el trigger <code>tg_pedidos_plan</code> verifica el plan del tenant.
          </p>
        </div>
      )}

      {tab === 'nuevo-sitio' && (
        <form onSubmit={altaSitio} className="card p-4 grid grid-cols-1 md:grid-cols-2 gap-4 max-w-2xl">
          <div className="md:col-span-2"><label className="label">Nombre del sitio</label><input required className="field" value={nuevoSitio.titulo} onChange={e => setNuevoSitio({ ...nuevoSitio, titulo: e.target.value })} /></div>
          <div><label className="label">Tipo</label>
            <select className="field" value={nuevoSitio.tipo_sitio} onChange={e => setNuevoSitio({ ...nuevoSitio, tipo_sitio: e.target.value })}>
              {['sucursal','tienda','obra','foro','oficina','evento','otro'].map(t => <option key={t}>{t}</option>)}
            </select>
          </div>
          <div><label className="label">Dirección</label><input className="field" value={nuevoSitio.direccion} onChange={e => setNuevoSitio({ ...nuevoSitio, direccion: e.target.value })} /></div>
          <div className="md:col-span-2"><button className="btn-primary" type="submit">Crear sitio</button></div>
          <p className="md:col-span-2 text-xs text-slate-500">
            En plan FREE solo se permite 1 sitio activo. Al segundo, el trigger <code>tg_sitios_limite</code> lo rechaza desde la base.
          </p>
        </form>
      )}
    </div>
  );
}
