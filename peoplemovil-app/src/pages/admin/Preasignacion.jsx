import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// HU 2.04 — Pre-asignación de personal
// Elige un pedido_detalle y le asigna empleados (preasignación normal o forzada)
export default function Preasignacion() {
  useModuleAudit('preasignacion');
  const [detalles, setDetalles] = useState([]);
  const [selDetalle, setSelDetalle] = useState(null);
  const [disponibles, setDisponibles] = useState([]);
  const [reservados, setReservados] = useState([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [empSel, setEmpSel] = useState(null);
  const [tipoAsig, setTipoAsig] = useState('preasignado');
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_pedidos_detalle').select('*, tc_puestos(titulo), te_pedidos(folio, titulo, sitio_id, fecha_evento)')
      .in('status_detalle', ['borrador','liberado']).order('fecha_cita').limit(50)
      .then(({ data }) => setDetalles(data || []));
  }, []);

  const cargarDetalle = async (d) => {
    setSelDetalle(d);
    const [{ data: emp }, { data: res }] = await Promise.all([
      supabase.from('tr_empleado_plaza')
        .select('empleado_id, porcentaje_puntualidad, te_empleados(id, folio, nombres, apellido_paterno, activo)')
        .eq('puesto_id', d.puesto_id).eq('activo', true),
      supabase.from('te_reservaciones').select('*, te_empleados(folio, nombres, apellido_paterno)')
        .eq('pedido_detalle_id', d.id)
    ]);
    const activos = (emp || []).filter(e => e.te_empleados?.activo);
    // filtrar quienes ya están reservados
    const yaReservados = new Set((res || []).filter(r => r.estado !== 'cancelado').map(r => r.empleado_id));
    setDisponibles(activos.filter(e => !yaReservados.has(e.empleado_id)));
    setReservados(res || []);
  };

  const asignar = async () => {
    if (!empSel || !selDetalle) return;
    const cita_i = selDetalle.te_pedidos?.fecha_evento ? new Date(selDetalle.te_pedidos.fecha_evento + 'T08:00:00Z') : new Date();
    const cita_f = new Date(cita_i.getTime() + 8*3600000);
    const { error } = await supabase.from('te_reservaciones').insert({
      tenant_id: DEMO_TENANT_ID,
      pedido_id: selDetalle.pedido_id,
      pedido_detalle_id: selDetalle.id,
      empleado_id: empSel.empleado_id,
      puesto_id: selDetalle.puesto_id,
      sitio_id: selDetalle.te_pedidos?.sitio_id,
      estado: tipoAsig,
      cita_inicio: cita_i.toISOString(),
      cita_fin: cita_f.toISOString(),
      regla_aplicada: `preasignacion_manual_${tipoAsig}`
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('preasignacion', 'ASIGNAR', `emp ${empSel.empleado_id} → detalle ${selDetalle.id} (${tipoAsig})`);
    setMsg(`✓ ${tipoAsig === 'forzada' ? 'Forzada' : 'Preasignación'} creada`);
    setModalOpen(false); setEmpSel(null);
    cargarDetalle(selDetalle);
  };

  const cancelar = async r => {
    if (!confirm('¿Cancelar esta reservación?')) return;
    const { error } = await supabase.from('te_reservaciones').update({ estado: 'cancelado' }).eq('id', r.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('preasignacion', 'CANCELAR', `reservacion ${r.id}`);
    setMsg('✓ Cancelada');
    cargarDetalle(selDetalle);
  };

  return (
    <div>
      <div className="section-eyebrow">Operación · HU 2.04</div>
      <h1>Pre-asignación de personal</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Elegí un detalle de pedido, mira los empleados con esa plaza y asignalos (preasignación normal o forzada).
      </p>

      {msg && <div className="card" style={{ padding: 10, marginBottom: 12, fontSize: 13 }}>{msg}</div>}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 16, alignItems: 'start' }}>
        {/* Columna izquierda: lista de detalles */}
        <div>
          <h3>Detalles activos</h3>
          <div style={{ display: 'grid', gap: 6 }}>
            {detalles.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin detalles.</p>}
            {detalles.map(d => (
              <div key={d.id} className="kpi-card clickable"
                   style={{ margin: 0, padding: 10, borderColor: selDetalle?.id === d.id ? 'var(--accent)' : 'var(--border)', borderWidth: selDetalle?.id === d.id ? 2 : 1 }}
                   onClick={() => cargarDetalle(d)}>
                <div style={{ fontSize: 12, fontWeight: 700 }}>{d.tc_puestos?.titulo}</div>
                <div style={{ fontSize: 11, color: 'var(--muted)' }}>#{d.te_pedidos?.folio} · {d.te_pedidos?.titulo}</div>
                <div style={{ fontSize: 11, color: 'var(--muted)' }}>{d.te_pedidos?.fecha_evento} · Cant. {d.cantidad}</div>
                <Badge estado={d.status_detalle === 'liberado' ? 'activo' : 'pendiente'}>{d.status_detalle}</Badge>
              </div>
            ))}
          </div>
        </div>

        {/* Columna derecha: selDetalle */}
        <div>
          {!selDetalle && (
            <div className="card">
              <p style={{ color: 'var(--muted)', textAlign: 'center', padding: 24 }}>Elegí un detalle a la izquierda para ver empleados disponibles.</p>
            </div>
          )}
          {selDetalle && (
            <>
              <div className="kpi-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
                <KpiCard label="Cupo total" value={selDetalle.cantidad} sub="requeridos" />
                <KpiCard label="Reservados" value={reservados.filter(r => r.estado !== 'cancelado').length} sub="activos" color="var(--green)" />
                <KpiCard label="Disponibles con plaza" value={disponibles.length} sub={selDetalle.tc_puestos?.titulo} color="var(--accent2)" />
              </div>

              <h3>Reservados actuales</h3>
              <TablaWrap>
                <table>
                  <thead>
                    <tr><th>Empleado</th><th>Tipo</th><th>Cita</th><th></th></tr>
                  </thead>
                  <tbody>
                    {reservados.length === 0 && <tr><td colSpan="4" className="empty">Aún sin reservados.</td></tr>}
                    {reservados.map(r => (
                      <tr key={r.id}>
                        <td>#{r.te_empleados?.folio} {r.te_empleados?.nombres} {r.te_empleados?.apellido_paterno}</td>
                        <td>
                          <Badge estado={
                            r.estado === 'confirmado_voluntario' || r.estado === 'confirmado_opcional' ? 'activo' :
                            r.estado === 'forzada' ? 'proceso' :
                            r.estado === 'preasignado' ? 'pendiente' :
                            r.estado === 'cancelado' ? 'vencido' : 'inactivo'
                          }>{r.estado?.replace(/_/g, ' ')}</Badge>
                        </td>
                        <td className="mono" style={{ fontSize: 11 }}>{new Date(r.cita_inicio).toLocaleString('es-MX')}</td>
                        <td style={{ textAlign: 'right' }}>
                          {r.estado !== 'cancelado' && r.estado !== 'procesado' &&
                            <button className="btn ghost sm" onClick={() => cancelar(r)}>✗</button>}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </TablaWrap>

              <h3>Empleados con plaza disponible</h3>
              <TablaWrap>
                <table>
                  <thead>
                    <tr><th>Empleado</th><th>Certeza</th><th></th></tr>
                  </thead>
                  <tbody>
                    {disponibles.length === 0 && <tr><td colSpan="3" className="empty">Sin empleados con esa plaza disponibles.</td></tr>}
                    {disponibles.map(e => (
                      <tr key={e.empleado_id}>
                        <td>#{e.te_empleados?.folio} {e.te_empleados?.nombres} {e.te_empleados?.apellido_paterno}</td>
                        <td>
                          <Badge estado={e.porcentaje_puntualidad >= 0.9 ? 'activo' : e.porcentaje_puntualidad >= 0.7 ? 'pendiente' : 'vencido'}>
                            {e.porcentaje_puntualidad ? Math.round(e.porcentaje_puntualidad * 100) + '%' : 'nuevo'}
                          </Badge>
                        </td>
                        <td style={{ textAlign: 'right' }}>
                          <button className="btn green sm" onClick={() => { setEmpSel(e); setTipoAsig('preasignado'); setModalOpen(true); }}>Preasignar</button>{' '}
                          <button className="btn red sm" onClick={() => { setEmpSel(e); setTipoAsig('forzada'); setModalOpen(true); }}>Forzar</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </TablaWrap>
            </>
          )}
        </div>
      </div>

      <Modal open={modalOpen} onClose={() => setModalOpen(false)} title={`${tipoAsig === 'forzada' ? 'Confirmación forzada' : 'Preasignación'}`}
        footer={<><button className="btn ghost" onClick={() => setModalOpen(false)}>Cancelar</button>
                <button className={'btn ' + (tipoAsig === 'forzada' ? 'red' : 'green')} onClick={asignar}>Confirmar</button></>}>
        {empSel && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Empleado</div><div>#{empSel.te_empleados?.folio} {empSel.te_empleados?.nombres} {empSel.te_empleados?.apellido_paterno}</div></div>
            <div><div className="label">Puesto</div><div>{selDetalle?.tc_puestos?.titulo}</div></div>
            <div><div className="label">Certeza</div><div>{empSel.porcentaje_puntualidad ? Math.round(empSel.porcentaje_puntualidad * 100) + '%' : 'Sin historial'}</div></div>
            <div><div className="label">Tipo asignación</div>
              <Badge estado={tipoAsig === 'forzada' ? 'proceso' : 'pendiente'}>{tipoAsig.toUpperCase()}</Badge>
            </div>
            {tipoAsig === 'forzada' && <p style={{ fontSize: 11, color: 'var(--red)' }}>⚠ La confirmación forzada bypassa la validación de certeza mínima del puesto.</p>}
          </div>
        )}
      </Modal>
    </div>
  );
}
