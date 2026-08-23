import React, { useEffect, useState } from 'react';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Nomina() {
  useModuleAudit('nomina');
  const [periodos, setPeriodos] = useState([]);
  const [detalle, setDetalle] = useState([]);
  const [precauciones, setPrec] = useState([]);
  const [seleccion, setSel] = useState(null);
  const [detalleModal, setDetalleModal] = useState(null);
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: prec }] = await Promise.all([
      supabase.from('te_nominas_periodo').select('*').order('fecha_desde', { ascending: false }),
      supabase.rpc('reporte_precauciones_nomina', { p_tenant: DEMO_TENANT_ID })
    ]);
    setPeriodos(p || []); setPrec(prec || []);
  }
  useEffect(() => { cargar(); }, []);

  async function verDetalle(nom) {
    setSel(nom);
    const { data } = await supabase.from('te_nomina_detalle').select('*').eq('nomina_id', nom.id);
    setDetalle(data || []);
  }

  async function calcular(nom) {
    const { error, data } = await supabase.rpc('calcular_nomina_periodo', { p_nomina: nom.id });
    setMsg(error ? 'Error: ' + error.message : 'Calculado, ' + data + ' empleados');
    await logAccion('nomina', 'CALCULAR', `periodo ${nom.fecha_desde} → ${nom.fecha_hasta}: ${data || 0} empleados`);
    verDetalle(nom);
  }

  const kpiPeriodosAbiertos = periodos.filter(p => !p.cerrada).length;
  const kpiPrecauciones     = precauciones.length;
  const kpiEmpleadosPeriodo = detalle.length;
  const kpiMontoTotal       = detalle.reduce((s, d) => s + Number(d.monto_neto || 0), 0);

  return (
    <div>
      <div className="section-eyebrow">Fiscal</div>
      <h1>Nómina</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Cálculo por asistencia real (asistencia + retardo + falta). Precauciones bloquean dispersión hasta resolverlas.</p>

      <div className="kpi-grid">
        <KpiCard label="Periodos abiertos"  value={kpiPeriodosAbiertos} sub={`${periodos.length} totales`} />
        <KpiCard label="Precauciones"       value={kpiPrecauciones}     color={kpiPrecauciones ? 'var(--red)' : 'var(--green)'} sub="antes de cerrar" />
        <KpiCard label="Empleados periodo"  value={kpiEmpleadosPeriodo} sub={seleccion ? `${seleccion.fecha_desde} → ${seleccion.fecha_hasta}` : 'sin selección'} />
        <KpiCard label="Monto neto periodo" value={fmt(kpiMontoTotal)}  sub="suma de la selección" color="var(--accent2)" />
      </div>

      <div className="card">
        <div className="section-eyebrow">Precauciones antes de cierre</div>
        <h3 style={{ marginTop: 4 }}>PRC_ReportePrecaucionesNomina</h3>
        {precauciones.length === 0
          ? <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin precauciones. Todo el personal está listo para dispersión.</p>
          : <ul style={{ listStyle: 'none', fontSize: 12 }}>
              {precauciones.map(p => (
                <li key={p.empleado_id} style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
                  <span style={{ fontWeight: 700 }}>{p.nombre}</span>
                  <span>{(p.motivos || []).map((m, i) => <Badge key={i} estado="vencido">{m}</Badge>)}</span>
                </li>
              ))}
            </ul>}
      </div>

      <h3>Periodos de nómina</h3>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Ciclo</th><th>Desde</th><th>Hasta</th><th>Estado</th><th></th></tr>
          </thead>
          <tbody>
            {periodos.length === 0 && <tr><td colSpan="5" className="empty">Sin periodos aún. Crear uno desde configuración.</td></tr>}
            {periodos.map(p => (
              <tr key={p.id}>
                <td>{p.ciclo_pago}</td>
                <td>{p.fecha_desde}</td>
                <td>{p.fecha_hasta}</td>
                <td><Badge estado={p.cerrada ? 'inactivo' : 'pendiente'}>{p.cerrada ? 'CERRADA' : 'ABIERTA'}</Badge></td>
                <td style={{ textAlign: 'right' }}>
                  <button className="btn ghost sm" onClick={() => verDetalle(p)}>Ver</button>
                  {!p.cerrada && <button className="btn green sm" style={{ marginLeft: 6 }} onClick={() => calcular(p)}>Calcular</button>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      {seleccion && (
        <>
          <h3>Detalle del periodo {seleccion.fecha_desde} → {seleccion.fecha_hasta}</h3>
          <TablaWrap>
            <table>
              <thead>
                <tr><th>Empleado</th><th style={{ textAlign: 'right' }}>Turnos</th><th style={{ textAlign: 'right' }}>Bruto</th>
                    <th style={{ textAlign: 'right' }}>Penal.</th><th style={{ textAlign: 'right' }}>Neto</th><th>Régimen</th></tr>
              </thead>
              <tbody>
                {detalle.length === 0 && <tr><td colSpan="6" className="empty">Sin detalle. Presiona "Calcular" en el periodo.</td></tr>}
                {detalle.map(d => (
                  <tr key={d.id} className="clickable" onClick={() => setDetalleModal(d)}>
                    <td className="mono">{d.empleado_id.slice(0, 8)}…</td>
                    <td style={{ textAlign: 'right' }}>{d.reservaciones_cnt}</td>
                    <td style={{ textAlign: 'right' }}>{fmt(d.monto_bruto)}</td>
                    <td style={{ textAlign: 'right' }}>{fmt(d.penalizaciones_aplicadas)}</td>
                    <td style={{ textAlign: 'right', fontWeight: 800 }}>{fmt(d.monto_neto)}</td>
                    <td style={{ fontSize: 12 }}>{d.regimen_pago}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
        </>
      )}

      {msg && <p style={{ fontSize: 12, color: 'var(--muted)' }}>{msg}</p>}

      <Modal open={!!detalleModal} onClose={() => setDetalleModal(null)} title="Detalle de nómina por empleado">
        {detalleModal && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Empleado (id)</div><div className="mono">{detalleModal.empleado_id}</div></div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <div><div className="label">Turnos</div><div>{detalleModal.reservaciones_cnt}</div></div>
              <div><div className="label">Régimen</div><div>{detalleModal.regimen_pago}</div></div>
              <div><div className="label">Bruto</div><div>{fmt(detalleModal.monto_bruto)}</div></div>
              <div><div className="label">Penalizaciones</div><div>{fmt(detalleModal.penalizaciones_aplicadas)}</div></div>
              <div><div className="label">Extras</div><div>{fmt(detalleModal.extras_aplicados)}</div></div>
              <div><div className="label">Pensión</div><div>{fmt(detalleModal.pension_aplicada)}</div></div>
              <div><div className="label">Salario diario prom.</div><div>{fmt(detalleModal.salario_diario_promedio)}</div></div>
              <div><div className="label">Neto</div><div style={{ fontWeight: 900 }}>{fmt(detalleModal.monto_neto)}</div></div>
            </div>
            {detalleModal.precauciones && Object.values(detalleModal.precauciones).some(Boolean) && (
              <div>
                <div className="label">Precauciones</div>
                <div>
                  {detalleModal.precauciones.sin_banco    && <Badge estado="vencido">SIN BANCO</Badge>}{' '}
                  {detalleModal.precauciones.sin_clabe    && <Badge estado="vencido">SIN CLABE</Badge>}{' '}
                  {detalleModal.precauciones.sin_pagadora && <Badge estado="vencido">SIN PAGADORA</Badge>}
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
