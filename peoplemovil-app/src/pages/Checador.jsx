import React, { useEffect, useState } from 'react';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import Modal from '../components/ui/Modal.jsx';
import { tituloConLinea } from '../components/ui/CardHeader.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

export default function Checador() {
  useModuleAudit('checador');
  const [modo, setModo] = useState('fijo');
  const [empleados, setEmpleados] = useState([]);
  const [historial, setHistorial] = useState([]);
  const [seleccion, setSeleccion] = useState({ empleado_id: '', tipo_marcaje: 'entrada', dispositivo_serie: 'USB-DEMO-001' });
  const [ubi, setUbi] = useState(null);
  const [detalle, setDetalle] = useState(null);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    cargar();
  }, []);
  async function cargar() {
    const [{ data: emp }, { data: hist }] = await Promise.all([
      supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno').eq('activo', true).order('folio'),
      supabase.from('te_eventos_biometricos').select('id, ts_servidor, tipo_marcaje, empleado_id, medio_asistencia, latitud, longitud').order('ts_servidor', { ascending: false }).limit(50)
    ]);
    setEmpleados(emp || []); setHistorial(hist || []);
  }

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
    const { data: disp } = await supabase.from('tc_dispositivos').select('id').eq('numero_serie', seleccion.dispositivo_serie).maybeSingle();
    const payload = {
      tenant_id: DEMO_TENANT_ID,
      empleado_id: seleccion.empleado_id,
      tipo_marcaje: seleccion.tipo_marcaje,
      medio_asistencia: modo === 'movil' ? 'geolocalizacion' : 'biometrico',
      dispositivo_id: disp?.id,
      latitud: ubi?.lat,
      longitud: ubi?.lng,
      hash_muestra: 'demo-' + crypto.randomUUID(),
      consentimiento_id: '00000000-0000-0000-0000-000000000000'
    };
    const { error } = await supabase.from('te_eventos_biometricos').insert(payload);
    if (error) { setMsg('Rechazado: ' + error.message); return; }
    await logAccion('checador', 'MARCAJE', `${modo}·${seleccion.tipo_marcaje} · empleado ${seleccion.empleado_id}`);
    setMsg('Marcaje registrado'); cargar();
  }

  const hoy = new Date().toISOString().slice(0, 10);
  const kpiHoy    = historial.filter(h => h.ts_servidor?.startsWith(hoy)).length;
  const kpiMovil  = historial.filter(h => h.medio_asistencia === 'geolocalizacion').length;
  const kpiFijo   = historial.filter(h => h.medio_asistencia === 'biometrico').length;

  return (
    <div>
      <div className="section-eyebrow">Registro legal de jornada</div>
      <h1>Checador</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Registro append-only con timestamp de servidor y consentimiento vinculado. Un endpoint central para lector fijo (USB) y móvil (GPS).</p>

      <div className="kpi-grid">
        <KpiCard label="Marcajes hoy"  value={kpiHoy}   sub={hoy} color="var(--green)" />
        <KpiCard label="Modo fijo"     value={kpiFijo}  sub="lector USB" />
        <KpiCard label="Modo móvil"    value={kpiMovil} sub="geolocalización" color="var(--accent2)" />
      </div>

      <div className="card">
        <div className="chips">
          <Chip active={modo === 'fijo'} onClick={() => setModo('fijo')}>Checador fijo (USB)</Chip>
          <Chip active={modo === 'movil'} onClick={() => setModo('movil')}>Checador móvil (GPS)</Chip>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 12, alignItems: 'end' }}>
          <div>
            <label className="label">Empleado</label>
            <select className="field" value={seleccion.empleado_id} onChange={e => setSeleccion({ ...seleccion, empleado_id: e.target.value })}>
              <option value="">— seleccionar —</option>
              {empleados.map(e => <option key={e.id} value={e.id}>#{e.folio} · {e.nombres} {e.apellido_paterno}</option>)}
            </select>
          </div>
          <div>
            <label className="label">Tipo</label>
            <select className="field" value={seleccion.tipo_marcaje} onChange={e => setSeleccion({ ...seleccion, tipo_marcaje: e.target.value })}>
              <option value="entrada">Entrada</option><option value="salida">Salida</option>
            </select>
          </div>
          {modo === 'fijo' ? (
            <div>
              <label className="label">Dispositivo (serie)</label>
              <input className="field mono" value={seleccion.dispositivo_serie} onChange={e => setSeleccion({ ...seleccion, dispositivo_serie: e.target.value })} />
            </div>
          ) : (
            <div>
              <label className="label">Ubicación</label>
              <div className="field mono" style={{ background: 'var(--surface)' }}>
                {ubi?.lat ? `${ubi.lat.toFixed(5)}, ${ubi.lng.toFixed(5)}` : (ubi?.error || 'obteniendo…')}
              </div>
            </div>
          )}
          <div style={{ display: 'flex', alignItems: 'flex-end' }}>
            <button className="btn" style={{ width: '100%', justifyContent: 'center' }} onClick={checar}>Registrar marcaje</button>
          </div>
        </div>
        {msg && <p style={{ marginTop: 12, fontSize: 12, color: 'var(--muted)' }}>{msg}</p>}
        <p style={{ marginTop: 8, fontSize: 11, color: 'var(--muted)' }}>
          {modo === 'movil'
            ? 'Modo móvil requiere plan PRO — trigger tg_evbio_valida verifica plan al insertar.'
            : 'Se envía la serie del lector para trazabilidad legal.'}
        </p>
      </div>

      <h3 style={tituloConLinea}>🕐 Últimos 50 marcajes (append-only)</h3>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Timestamp servidor</th><th>Empleado</th><th>Tipo</th><th>Medio</th></tr>
          </thead>
          <tbody>
            {historial.length === 0 && <tr><td colSpan="4" className="empty">Sin marcajes aún.</td></tr>}
            {historial.map(h => {
              const e = empleados.find(x => x.id === h.empleado_id);
              return (
                <tr key={h.id} className="clickable" onClick={() => setDetalle(h)}>
                  <td className="mono">{new Date(h.ts_servidor).toLocaleString('es-MX')}</td>
                  <td>{e ? `#${e.folio} ${e.nombres} ${e.apellido_paterno}` : <span className="mono">{h.empleado_id.slice(0,8)}…</span>}</td>
                  <td><Badge estado={h.tipo_marcaje === 'entrada' ? 'activo' : 'proceso'}>{h.tipo_marcaje.toUpperCase()}</Badge></td>
                  <td style={{ fontSize: 12 }}>{h.medio_asistencia}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={!!detalle} onClose={() => setDetalle(null)} title="Detalle del marcaje">
        {detalle && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">ID evento</div><div className="mono">{detalle.id}</div></div>
            <div><div className="label">Timestamp de servidor</div><div className="mono">{new Date(detalle.ts_servidor).toISOString()}</div></div>
            <div><div className="label">Tipo</div><Badge estado={detalle.tipo_marcaje === 'entrada' ? 'activo' : 'proceso'}>{detalle.tipo_marcaje.toUpperCase()}</Badge></div>
            <div><div className="label">Medio</div><div>{detalle.medio_asistencia}</div></div>
            {detalle.latitud && <div><div className="label">Geolocalización</div><div className="mono">{detalle.latitud}, {detalle.longitud}</div></div>}
            <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 6 }}>
              Este registro es append-only. Cualquier corrección va como registro nuevo con <code>corrige_id</code>.
            </p>
          </div>
        )}
      </Modal>
    </div>
  );
}
