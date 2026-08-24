import React, { useEffect, useMemo, useState } from 'react';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import Semaforo from '../components/Semaforo.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

const fmt = n => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 0 });

// Vista 1: Lista de pedidos con toolbar (heredado del manual Pedidos)
// Vista 2: Detalle de pedido con 3 pestañas + acciones Editar/Liberar/Cancelar
export default function SitiosAsignacion() {
  useModuleAudit('sitios_asignacion');
  const [pedidos, setPedidos] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [clientes, setClientes] = useState([]);
  const [pedidoSel, setPedidoSel] = useState(null);
  const [pestana, setPestana] = useState('general');
  const [detalles, setDetalles] = useState([]);
  const [reservaciones, setReservaciones] = useState([]);
  const [filtroStatus, setFiltroStatus] = useState('todos');
  const [busqueda, setBusqueda] = useState('');
  const [nuevoPedidoOpen, setNuevoPedidoOpen] = useState(false);
  const [nuevoPedido, setNuevoPedido] = useState({ titulo:'', sitio_id:'', cliente_id:'', fecha_evento:'' });
  const [nuevoSitioOpen, setNuevoSitioOpen] = useState(false);
  const [nuevoSitio, setNuevoSitio] = useState({ titulo:'', tipo_sitio:'sucursal', direccion:'' });
  const [msg, setMsg] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: s }, { data: c }] = await Promise.all([
      supabase.from('te_pedidos').select('*').order('fecha_evento', { ascending: false }).limit(100),
      supabase.from('tc_sitios').select('id, titulo, tipo_sitio, direccion_abreviada, activo').order('titulo'),
      supabase.from('tc_clientes').select('id, razon_social').eq('activo', true).order('razon_social')
    ]);
    setPedidos(p || []); setSitios(s || []); setClientes(c || []);
  }
  useEffect(() => { cargar(); }, []);

  const cargarDetallePedido = async (ped) => {
    setPedidoSel(ped); setPestana('general');
    const [{ data: d }, { data: r }] = await Promise.all([
      supabase.from('te_pedidos_detalle').select('*, tc_puestos(titulo)').eq('pedido_id', ped.id),
      supabase.from('te_reservaciones').select('*, te_empleados(nombres, apellido_paterno, folio)').eq('pedido_id', ped.id).limit(200)
    ]);
    setDetalles(d || []); setReservaciones(r || []);
  };

  const liberarPedido = async () => {
    if (!pedidoSel) return;
    if (!confirm('¿Liberar el pedido? Todos los detalles en borrador pasan a LIBERADO y se publican en el portal.')) return;
    const { data, error } = await supabase.rpc('liberar_pedido', { p_pedido: pedidoSel.id });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('sitios_asignacion', 'LIBERAR', `pedido ${pedidoSel.folio}: ${data} detalles liberados`);
    setMsg(`✓ ${data} detalles liberados`);
    await cargarDetallePedido(pedidoSel);
  };

  const cancelarPedido = async () => {
    if (!pedidoSel) return;
    if (!confirm('¿Cancelar el pedido? Se cancelan detalles no procesados y sus reservaciones.')) return;
    const { error } = await supabase.from('te_pedidos').update({ status: 'cancelado' }).eq('id', pedidoSel.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await supabase.from('te_pedidos_detalle').update({ status_detalle: 'cancelado' })
      .eq('pedido_id', pedidoSel.id).not('status_detalle', 'in', '(procesado,facturado)');
    await supabase.from('te_reservaciones').update({ estado: 'cancelado', regla_aplicada: 'cancelacion_pedido' })
      .eq('pedido_id', pedidoSel.id).not('estado', 'in', '(procesado,cancelado)');
    await logAccion('sitios_asignacion', 'CANCELAR', `pedido ${pedidoSel.folio}`);
    setMsg('✓ Pedido cancelado');
    await cargarDetallePedido({...pedidoSel, status: 'cancelado'});
    cargar();
  };

  const altaPedido = async (e) => {
    e.preventDefault();
    const folio = Math.floor(Date.now() / 1000) % 1000000;
    const { error } = await supabase.from('te_pedidos').insert({
      ...nuevoPedido,
      tenant_id: DEMO_TENANT_ID,
      folio,
      cliente_id: nuevoPedido.cliente_id || null,
      status: 'borrador'
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('sitios_asignacion', 'INSERT', `pedido: ${nuevoPedido.titulo}`);
    setNuevoPedidoOpen(false);
    setNuevoPedido({ titulo:'', sitio_id:'', cliente_id:'', fecha_evento:'' });
    setMsg('✓ Pedido creado');
    cargar();
  };

  const altaSitio = async (e) => {
    e.preventDefault();
    const { error } = await supabase.from('tc_sitios').insert({ ...nuevoSitio, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('❌ ' + error.message); return; }
    setNuevoSitioOpen(false);
    setNuevoSitio({ titulo:'', tipo_sitio:'sucursal', direccion:'' });
    setMsg('✓ Sitio creado');
    cargar();
  };

  const exportarCSV = () => {
    if (pedidos.length === 0) return;
    const cols = ['folio','titulo','fecha_evento','status','sitio_id','cliente_id','costo_estimado'];
    const esc = v => v == null ? '' : `"${String(v).replace(/"/g, '""')}"`;
    const csv = [cols.join(','), ...pedidos.map(p => cols.map(c => esc(p[c])).join(','))].join('\n');
    const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `pedidos_${new Date().toISOString().slice(0,10)}.csv`;
    a.click();
  };

  const pedidosFiltrados = useMemo(() => pedidos.filter(p =>
    (filtroStatus === 'todos' || p.status === filtroStatus) &&
    (!busqueda || `${p.folio} ${p.titulo}`.toLowerCase().includes(busqueda.toLowerCase()))
  ), [pedidos, filtroStatus, busqueda]);

  const kpiActivos = pedidos.filter(p => !['cancelado','procesado'].includes(p.status)).length;
  const kpiHoy = pedidos.filter(p => p.fecha_evento === new Date().toISOString().slice(0,10)).length;

  // ============================================================
  // VISTA DETALLE: si hay pedidoSel, muestra la ficha
  // ============================================================
  if (pedidoSel) {
    const nombreSitio = sitios.find(s => s.id === pedidoSel.sitio_id)?.titulo || '—';
    const nombreCliente = clientes.find(c => c.id === pedidoSel.cliente_id)?.razon_social;
    const totalReq = detalles.reduce((s, d) => s + Number(d.cantidad || 0), 0);
    const totalReserv = detalles.reduce((s, d) => s + Number(d.cantidad_reservados_real || 0), 0);
    const cobertura = totalReq > 0 ? totalReserv / totalReq : 0;

    return (
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 }}>
          <div>
            <button className="btn ghost sm" onClick={() => setPedidoSel(null)}>← Volver a lista</button>
            <div className="section-eyebrow" style={{ marginTop: 10 }}>Pedido #{pedidoSel.folio}</div>
            <h1>{pedidoSel.titulo}</h1>
            <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
              <Badge estado={pedidoSel.status === 'liberado' ? 'activo' : pedidoSel.status === 'cancelado' ? 'vencido' : pedidoSel.status === 'procesado' ? 'inactivo' : 'pendiente'}>
                {pedidoSel.status?.toUpperCase()}
              </Badge>
              <Badge estado="inactivo">{pedidoSel.fecha_evento}</Badge>
              <Badge estado="proceso">📍 {nombreSitio}</Badge>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6 }}>
            <button className="btn ghost sm">✏️ Editar</button>
            {pedidoSel.status !== 'liberado' && pedidoSel.status !== 'cancelado' && (
              <button className="btn green sm" onClick={liberarPedido}>🚀 Liberar pedido</button>
            )}
            {pedidoSel.status !== 'cancelado' && (
              <button className="btn red sm" onClick={cancelarPedido}>✗ Cancelar</button>
            )}
          </div>
        </div>

        {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

        {/* Pestañas al estilo sistema Lobo */}
        <div style={{ display: 'flex', gap: 0, borderBottom: '2px solid var(--border)', marginBottom: 20 }}>
          {[
            { k: 'general',   label: '📋 Información principal', num: null },
            { k: 'matriz',    label: '🎯 Matriz de puestos',      num: detalles.length },
            { k: 'movtos',    label: '📊 Movimientos / Reservaciones', num: reservaciones.length }
          ].map(t => (
            <button key={t.k}
              onClick={() => setPestana(t.k)}
              style={{
                padding: '10px 20px', border: 'none',
                background: pestana === t.k ? 'var(--accent-light)' : 'transparent',
                color: pestana === t.k ? 'var(--accent)' : 'var(--muted)',
                fontWeight: pestana === t.k ? 800 : 500,
                borderBottom: pestana === t.k ? '3px solid var(--accent)' : '3px solid transparent',
                cursor: 'pointer', fontSize: 13, marginBottom: -2
              }}>
              {t.label}{t.num !== null ? ` (${t.num})` : ''}
            </button>
          ))}
        </div>

        {pestana === 'general' && (
          <>
            <div className="kpi-grid">
              <KpiCard label="Cobertura" value={`${Math.round(cobertura * 100)}%`}
                       sub={`${totalReserv} / ${totalReq} reservados`}
                       color={cobertura >= 0.8 ? 'var(--green)' : cobertura >= 0.6 ? 'var(--gold)' : 'var(--red)'} />
              <KpiCard label="Detalles del pedido" value={detalles.length} sub="líneas de puestos" />
              <KpiCard label="Reservaciones" value={reservaciones.length} sub="empleados asignados" />
            </div>

            <div className="card">
              <h3>Datos del pedido</h3>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, fontSize: 13 }}>
                <div><div className="label">Sitio</div><div>{nombreSitio}</div></div>
                <div><div className="label">Cliente</div><div>{nombreCliente || '—'}</div></div>
                <div><div className="label">Fecha evento</div><div>{pedidoSel.fecha_evento}</div></div>
                <div><div className="label">Horario</div><div>{pedidoSel.hora_inicio || '—'} → {pedidoSel.hora_fin || '—'}</div></div>
                <div><div className="label">Status</div><Badge estado={pedidoSel.status === 'liberado' ? 'activo' : 'pendiente'}>{pedidoSel.status}</Badge></div>
                <div><div className="label">Costo estimado</div><div>${fmt(pedidoSel.costo_estimado)}</div></div>
                {pedidoSel.subtotal && <div><div className="label">Subtotal</div><div>${fmt(pedidoSel.subtotal)}</div></div>}
                {pedidoSel.total_con_iva && <div><div className="label">Total con IVA</div><div style={{ fontWeight: 800 }}>${fmt(pedidoSel.total_con_iva)}</div></div>}
              </div>
            </div>
          </>
        )}

        {pestana === 'matriz' && (
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: 16, borderBottom: '1px solid var(--border)', fontSize: 13, color: 'var(--muted)' }}>
              Desglose de puestos requeridos. Cada línea es un <code>te_pedidos_detalle</code>.
            </div>
            <TablaWrap>
              <table>
                <thead>
                  <tr><th>#</th><th>Puesto</th><th style={{ textAlign: 'right' }}>Cant. req.</th><th style={{ textAlign: 'right' }}>Reservados</th><th style={{ textAlign: 'right' }}>%</th><th>Cobertura</th><th style={{ textAlign: 'right' }}>Precio</th><th>Estado</th></tr>
                </thead>
                <tbody>
                  {detalles.length === 0 && <tr><td colSpan="8" className="empty">Sin detalles capturados. Agregá desde "Movimientos".</td></tr>}
                  {detalles.map((d, i) => {
                    const pct = d.cantidad > 0 ? (d.cantidad_reservados_real || 0) / d.cantidad : 0;
                    return (
                      <tr key={d.id}>
                        <td className="mono">{i + 1}</td>
                        <td>{d.tc_puestos?.titulo || '(puesto)'}</td>
                        <td style={{ textAlign: 'right' }}>{d.cantidad}</td>
                        <td style={{ textAlign: 'right' }}>{d.cantidad_reservados_real || 0}</td>
                        <td style={{ textAlign: 'right' }}>{Math.round(pct * 100)}%</td>
                        <td style={{ minWidth: 120 }}><Semaforo porcentaje={pct} /></td>
                        <td style={{ textAlign: 'right' }}>${fmt(d.precio || d.costo_unit)}</td>
                        <td>
                          <Badge estado={d.status_detalle === 'liberado' ? 'activo' : d.status_detalle === 'cancelado' ? 'vencido' : d.status_detalle === 'procesado' ? 'inactivo' : 'pendiente'}>
                            {d.status_detalle || 'borrador'}
                          </Badge>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </TablaWrap>
          </div>
        )}

        {pestana === 'movtos' && (
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: 16, borderBottom: '1px solid var(--border)', fontSize: 13, color: 'var(--muted)' }}>
              Empleados asignados a este pedido. Aquí se ven las reservaciones vigentes (preasignadas, confirmadas, forzadas).
            </div>
            <TablaWrap>
              <table>
                <thead>
                  <tr><th>Empleado</th><th>Puesto</th><th>Cita inicio</th><th>Estado reserv.</th><th>Estado asist.</th></tr>
                </thead>
                <tbody>
                  {reservaciones.length === 0 && <tr><td colSpan="5" className="empty">Sin reservaciones. Se generan cuando el freelance se inscribe o RRHH preasigna.</td></tr>}
                  {reservaciones.map(r => (
                    <tr key={r.id}>
                      <td>#{r.te_empleados?.folio} {r.te_empleados?.nombres} {r.te_empleados?.apellido_paterno}</td>
                      <td className="mono" style={{ fontSize: 11 }}>{r.puesto_id?.slice(0, 8)}…</td>
                      <td>{new Date(r.cita_inicio).toLocaleString('es-MX')}</td>
                      <td><Badge estado={
                        r.estado === 'confirmado_voluntario' || r.estado === 'confirmado_opcional' ? 'activo' :
                        r.estado === 'forzada' ? 'proceso' :
                        r.estado === 'preasignado' ? 'pendiente' :
                        r.estado === 'cancelado' ? 'vencido' :
                        r.estado === 'procesado' ? 'inactivo' : 'inactivo'
                      }>{r.estado?.replace(/_/g, ' ')}</Badge></td>
                      <td><Badge estado={r.estado_asistencia === 'asistencia' ? 'activo' : r.estado_asistencia === 'falta' ? 'vencido' : r.estado_asistencia === 'retardo' ? 'pendiente' : 'inactivo'}>{r.estado_asistencia}</Badge></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          </div>
        )}
      </div>
    );
  }

  // ============================================================
  // VISTA LISTA: toolbar (agregar/exportar/filtros) + tabla pedidos
  // ============================================================
  return (
    <div>
      <div className="section-eyebrow">Operación</div>
      <h1>Pedidos, sitios y asignación</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Módulo central de operación. Cada pedido es una necesidad de personal para una fecha en un sitio.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Pedidos activos" value={kpiActivos} sub="no cancelados" onClick={() => setFiltroStatus('borrador')} />
        <KpiCard label="Pedidos hoy" value={kpiHoy} sub={new Date().toLocaleDateString('es-MX')} color="var(--green)" />
        <KpiCard label="Sitios activos" value={sitios.filter(s => s.activo).length} sub={`de ${sitios.length}`} />
        <KpiCard label="Clientes" value={clientes.length} sub="con pedidos" color="var(--accent2)" />
      </div>

      {/* Toolbar tipo Lobo */}
      <div className="card" style={{ padding: 12, marginBottom: 12 }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center' }}>
          <button className="btn" onClick={() => setNuevoPedidoOpen(true)}>+ Nuevo pedido</button>
          <button className="btn ghost sm" onClick={() => setNuevoSitioOpen(true)}>+ Sitio</button>
          <button className="btn outline sm" onClick={exportarCSV}>📥 Exportar CSV</button>
          <span style={{ flex: 1 }} />
          <input className="field" style={{ maxWidth: 240 }} placeholder="Buscar por folio o título…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
        </div>
        <div className="chips" style={{ margin: '10px 0 0' }}>
          {['todos','borrador','liberado','procesado','cancelado'].map(s => (
            <Chip key={s} active={filtroStatus === s} onClick={() => setFiltroStatus(filtroStatus === s ? 'todos' : s)}>
              {s}
            </Chip>
          ))}
        </div>
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Folio</th><th>Título</th><th>Fecha evento</th><th>Sitio</th><th>Cliente</th><th>Status</th><th style={{ textAlign: 'right' }}>Total</th></tr>
          </thead>
          <tbody>
            {pedidosFiltrados.length === 0 && <tr><td colSpan="7" className="empty">Sin pedidos que coincidan. Crea uno nuevo o cambia el filtro.</td></tr>}
            {pedidosFiltrados.map(p => (
              <tr key={p.id} className="clickable" onClick={() => cargarDetallePedido(p)}>
                <td className="mono">#{p.folio}</td>
                <td>{p.titulo}</td>
                <td>{p.fecha_evento}</td>
                <td>{sitios.find(s => s.id === p.sitio_id)?.titulo || '—'}</td>
                <td>{clientes.find(c => c.id === p.cliente_id)?.razon_social || '—'}</td>
                <td><Badge estado={p.status === 'liberado' ? 'activo' : p.status === 'cancelado' ? 'vencido' : p.status === 'procesado' ? 'inactivo' : 'pendiente'}>{p.status}</Badge></td>
                <td style={{ textAlign: 'right' }} className="mono">{p.total_con_iva ? '$' + fmt(p.total_con_iva) : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={nuevoPedidoOpen} onClose={() => setNuevoPedidoOpen(false)} title="Nuevo pedido"
        footer={<><button className="btn ghost" onClick={() => setNuevoPedidoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={altaPedido}>Confirmar</button></>}>
        <form onSubmit={altaPedido} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Título del pedido *</label>
            <input required className="field" value={nuevoPedido.titulo} onChange={e => setNuevoPedido({...nuevoPedido, titulo: e.target.value})} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Sitio *</label>
              <select required className="field" value={nuevoPedido.sitio_id} onChange={e => setNuevoPedido({...nuevoPedido, sitio_id: e.target.value})}>
                <option value="">— elegir —</option>
                {sitios.filter(s => s.activo).map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
            </div>
            <div><label className="label">Cliente</label>
              <select className="field" value={nuevoPedido.cliente_id} onChange={e => setNuevoPedido({...nuevoPedido, cliente_id: e.target.value})}>
                <option value="">— sin cliente —</option>
                {clientes.map(c => <option key={c.id} value={c.id}>{c.razon_social}</option>)}
              </select>
            </div>
          </div>
          <div><label className="label">Fecha del evento *</label>
            <input required type="date" className="field" value={nuevoPedido.fecha_evento} onChange={e => setNuevoPedido({...nuevoPedido, fecha_evento: e.target.value})} />
          </div>
          <p style={{ fontSize: 11, color: 'var(--muted)' }}>El plan del tenant se verifica en la base al insertar (trigger tg_ped_plan).</p>
        </form>
      </Modal>

      <Modal open={nuevoSitioOpen} onClose={() => setNuevoSitioOpen(false)} title="Nuevo sitio"
        footer={<><button className="btn ghost" onClick={() => setNuevoSitioOpen(false)}>Cancelar</button>
                <button className="btn" onClick={altaSitio}>Crear</button></>}>
        <form onSubmit={altaSitio} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Nombre *</label><input required className="field" value={nuevoSitio.titulo} onChange={e => setNuevoSitio({...nuevoSitio, titulo: e.target.value})} /></div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 12 }}>
            <div><label className="label">Tipo</label>
              <select className="field" value={nuevoSitio.tipo_sitio} onChange={e => setNuevoSitio({...nuevoSitio, tipo_sitio: e.target.value})}>
                {['sucursal','tienda','obra','foro','oficina','evento','otro'].map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            <div><label className="label">Dirección</label><input className="field" value={nuevoSitio.direccion} onChange={e => setNuevoSitio({...nuevoSitio, direccion: e.target.value})} /></div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
