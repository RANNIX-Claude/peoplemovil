import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { tituloConLinea } from '../../components/ui/CardHeader.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Escenario 28 QA ("Facturación"): Agregar una Factura desde un pedido, seleccionando
// uno o varios detalles no facturados; agrupar partidas en un rubro con Producto;
// generar el TXT para SAP.
const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Facturacion() {
  useModuleAudit('facturacion');
  const { hasPermiso } = useAdminAuth();
  const puedeCrear = hasPermiso('facturacion.crear');

  const [facturas, setFacturas] = useState([]);
  const [pagosMap, setPagosMap] = useState({});
  const [sel, setSel] = useState(null);
  const [partidas, setPartidas] = useState([]);
  const [pagos, setPagos] = useState([]);

  const [nuevaOpen, setNuevaOpen] = useState(false);
  const [busqueda, setBusqueda] = useState('');
  const [pedido, setPedido] = useState(null);
  const [detalles, setDetalles] = useState([]);
  const [detallesSel, setDetallesSel] = useState({});
  const [productos, setProductos] = useState([]);
  const [msg, setMsg] = useState('');
  const [txtModal, setTxtModal] = useState(null);

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: f }, { data: pgs }, { data: prod }] = await Promise.all([
      supabase.from('te_facturas_enc').select('*').order('fecha_emision', { ascending: false }).limit(50),
      supabase.from('te_pagos_factura').select('factura_id, monto'),
      supabase.from('tc_productos').select('id, titulo').limit(200),
    ]);
    setFacturas(f || []);
    setProductos(prod || []);
    const map = {};
    (pgs || []).forEach(p => { map[p.factura_id] = (map[p.factura_id] || 0) + Number(p.monto); });
    setPagosMap(map);
  }

  const abrirDetalle = async fac => {
    setSel(fac);
    const [{ data: dp }, { data: pg }] = await Promise.all([
      supabase.from('te_facturas_det').select('*').eq('factura_id', fac.id),
      supabase.from('te_pagos_factura').select('*').eq('factura_id', fac.id).order('fecha_pago', { ascending: false })
    ]);
    setPartidas(dp || []); setPagos(pg || []);
  };

  // --- Agregar una Factura (Escenario 28) ---
  useEffect(() => {
    if (!supabaseReady) return;
    const q = busqueda.trim();
    if (!q) return;
    const t = setTimeout(async () => {
      const folioNum = /^\d+$/.test(q) ? Number(q) : -1;
      const { data } = await supabase.from('te_pedidos').select('*')
        .or(`folio.eq.${folioNum},titulo.ilike.%${q}%`)
        .order('fecha_evento', { ascending: false }).limit(10);
      if (data && data.length === 1) elegirPedido(data[0]);
      else if (data && data.length > 1) setMsg(`${data.length} pedidos encontrados, afina la búsqueda (folio exacto).`);
      else setMsg('Sin resultados.');
    }, 300);
    return () => clearTimeout(t);
  }, [busqueda]);

  const elegirPedido = async p => {
    setPedido(p); setMsg('');
    const { data } = await supabase.from('te_pedidos_detalle').select('*')
      .eq('pedido_id', p.id).eq('facturable', true).order('creado_en');
    setDetalles(data || []);
    setDetallesSel({});
  };

  const toggleDetalle = id => setDetallesSel(prev => ({ ...prev, [id]: !prev[id] }));

  const generarFactura = async () => {
    const ids = Object.keys(detallesSel).filter(id => detallesSel[id]);
    if (ids.length === 0) { setMsg('Selecciona al menos un detalle.'); return; }
    const { data: serie } = await supabase.from('te_facturas_serie').select('*')
      .eq('sociedad_propia_id', pedido.id_sociedad_propia).eq('activo', true).limit(1).maybeSingle();
    if (!serie) { setMsg('❌ No hay serie de facturación configurada para la sociedad propia de este pedido.'); return; }
    const { data: facturaId, error } = await supabase.rpc('crear_factura_desde_detalles', {
      p_tenant: pedido.tenant_id, p_pedido: pedido.id, p_sociedad_propia: pedido.id_sociedad_propia,
      p_tipo_movimiento: pedido.tipo_movimiento_id, p_serie: serie.id, p_detalles_ids: ids
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('facturacion', 'GENERAR', `pedido ${pedido.folio}: ${ids.length} detalles → factura ${facturaId}`);
    setMsg(`✓ Factura generada con ${ids.length} rubro(s).`);
    setNuevaOpen(false); setPedido(null); setBusqueda(''); setDetalles([]); setDetallesSel({});
    cargar();
    const { data: fac } = await supabase.from('te_facturas_enc').select('*').eq('id', facturaId).single();
    if (fac) abrirDetalle(fac);
  };

  // --- Edición de partida (cantidad/precio editables) ---
  const editarPartida = async (p, campo, valor) => {
    const num = Number(valor) || 0;
    const nueva = { ...p, [campo]: num };
    nueva.importe = Number(nueva.cantidad) * Number(nueva.precio_unit);
    await supabase.from('te_facturas_det').update({ [campo]: num, importe: nueva.importe }).eq('id', p.id);
    const { data: subt } = await supabase.from('te_facturas_det').select('importe, iva').eq('factura_id', sel.id);
    const subtotal = (subt || []).reduce((s, r) => s + Number(r.importe || 0), 0);
    const iva = (subt || []).reduce((s, r) => s + Number(r.iva || 0), 0);
    await supabase.from('te_facturas_enc').update({ subtotal, iva, total: subtotal + iva }).eq('id', sel.id);
    abrirDetalle({ ...sel, subtotal, iva, total: subtotal + iva });
  };

  const agregarPartidaVacia = async () => {
    await supabase.from('te_facturas_det').insert({
      tenant_id: sel.tenant_id, factura_id: sel.id, concepto: 'Nueva partida', cantidad: 1, precio_unit: 0, importe: 0, tipo_partida: 'manual'
    });
    abrirDetalle(sel);
  };

  const [agruparSel, setAgruparSel] = useState({});
  const [agruparProducto, setAgruparProducto] = useState('');
  const agrupar = async () => {
    const ids = Object.keys(agruparSel).filter(id => agruparSel[id]);
    if (ids.length < 2 || !agruparProducto) { setMsg('Selecciona 2+ partidas y un Producto para agrupar.'); return; }
    const { error } = await supabase.rpc('agrupar_partidas_factura', {
      p_factura_id: sel.id, p_detalle_ids: ids, p_producto_id: agruparProducto
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('facturacion', 'AGRUPAR', `factura ${sel.id}: ${ids.length} partidas agrupadas`);
    setAgruparSel({}); setAgruparProducto('');
    const { data: fac } = await supabase.from('te_facturas_enc').select('*').eq('id', sel.id).single();
    abrirDetalle(fac);
  };

  const generarTxt = async () => {
    const { data: txt, error } = await supabase.rpc('generar_txt_sap', {
      p_sociedad_propia: sel.sociedad_propia_id, p_folio_desde: sel.folio, p_folio_hasta: sel.folio
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    setTxtModal(txt);
  };

  const descargarTxt = () => {
    const blob = new Blob([txtModal], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = `SAP_${sel.serie || ''}${sel.folio}.txt`; a.click();
    URL.revokeObjectURL(url);
  };

  const kpi_total = facturas.reduce((s, f) => s + Number(f.total || 0), 0);
  const kpi_pagadas = facturas.filter(f => (f.status_full || f.status) === 'pagada').length;
  const kpi_pendientes = facturas.filter(f => !['pagada','cancelada'].includes(f.status_full || f.status)).length;
  const kpi_por_cobrar = facturas.reduce((s, f) => {
    if (['cancelada'].includes(f.status_full || f.status)) return s;
    return s + Number(f.total || 0) - Number(pagosMap[f.id] || 0);
  }, 0);

  return (
    <div>
      <div className="section-eyebrow">Fiscal</div>
      <h1>Facturación</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Facturas emitidas a clientes por servicios de personal. Series por sociedad propia, pagos parciales, export a SAP.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Facturas cargadas" value={facturas.length} sub="últimas 50" />
        <KpiCard label="Monto total emitido" value={fmt(kpi_total)} color="var(--accent2)" />
        <KpiCard label="Pagadas" value={kpi_pagadas} sub="al 100%" color="var(--green)" />
        <KpiCard label="Por cobrar" value={fmt(kpi_por_cobrar)} sub="pendientes + parciales" color="var(--gold)" />
      </div>

      {puedeCrear && (
        <div style={{ marginBottom: 16 }}>
          <button className="btn" onClick={() => setNuevaOpen(true)}>+ Agregar una Factura</button>
        </div>
      )}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Serie/Folio</th><th>Cliente</th><th>Fecha</th><th style={{ textAlign: 'right' }}>Total</th><th style={{ textAlign: 'right' }}>Pagado</th><th>Estado</th></tr>
          </thead>
          <tbody>
            {facturas.length === 0 && <tr><td colSpan="6" className="empty">Sin facturas cargadas. Se generan desde pedidos con detalles facturables.</td></tr>}
            {facturas.map(f => {
              const pagado = pagosMap[f.id] || 0;
              return (
                <tr key={f.id} className="clickable" onClick={() => abrirDetalle(f)}>
                  <td className="mono">{f.serie || ''}#{f.folio}</td>
                  <td className="mono" style={{ fontSize: 11 }}>{f.cliente_id?.slice(0, 8)}…</td>
                  <td>{f.fecha_emision}</td>
                  <td style={{ textAlign: 'right' }}>{fmt(f.total)}</td>
                  <td style={{ textAlign: 'right', color: pagado > 0 ? 'var(--green)' : 'var(--muted)' }}>{fmt(pagado)}</td>
                  <td>
                    <Badge estado={(f.status_full === 'pagada') ? 'activo' : (f.status_full === 'pagada_parcial') ? 'proceso' : (f.status_full === 'cancelada') ? 'vencido' : 'pendiente'}>
                      {f.status_full || f.status}
                    </Badge>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </TablaWrap>

      {msg && <p style={{ fontSize: 12, marginTop: 12 }}>{msg}</p>}

      <Modal open={!!sel} onClose={() => setSel(null)} title={`Factura ${sel?.serie}#${sel?.folio}`} wide>
        {sel && (
          <div style={{ display: 'grid', gap: 14 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12, fontSize: 13 }}>
              <div><div className="label">Subtotal</div><div>{fmt(sel.subtotal)}</div></div>
              <div><div className="label">IVA</div><div>{fmt(sel.iva)}</div></div>
              <div><div className="label">Total</div><div style={{ fontWeight: 800 }}>{fmt(sel.total)}</div></div>
            </div>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h3 style={tituloConLinea}>🧾 Partidas ({partidas.length})</h3>
                {puedeCrear && <button className="btn ghost sm" onClick={agregarPartidaVacia}>+ Partida</button>}
              </div>
              {partidas.map(p => (
                <div key={p.id} style={{ padding: 8, background: 'var(--surface)', borderRadius: 6, marginBottom: 4, fontSize: 12 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8 }}>
                    {puedeCrear && !p.agrupa_de_partidas && (
                      <input type="checkbox" checked={!!agruparSel[p.id]} onChange={() => setAgruparSel(prev => ({ ...prev, [p.id]: !prev[p.id] }))} />
                    )}
                    <span style={{ flex: 1 }}>{p.concepto}</span>
                    {puedeCrear ? (
                      <>
                        <input type="number" step="1" defaultValue={p.cantidad} style={{ width: 60 }}
                          onBlur={e => editarPartida(p, 'cantidad', e.target.value)} />
                        <span>×</span>
                        <input type="number" step="0.01" defaultValue={p.precio_unit} style={{ width: 80 }}
                          onBlur={e => editarPartida(p, 'precio_unit', e.target.value)} />
                      </>
                    ) : <span>{p.cantidad} × {fmt(p.precio_unit)}</span>}
                    <span style={{ fontWeight: 700, minWidth: 80, textAlign: 'right' }}>{fmt(p.importe)}</span>
                  </div>
                  {p.agrupa_de_partidas && (
                    <details style={{ marginTop: 4 }}>
                      <summary style={{ cursor: 'pointer', color: 'var(--muted)' }}>Ver detalle agrupado ({p.agrupa_de_partidas.length})</summary>
                      <ul style={{ margin: '4px 0 0 16px' }}>
                        {p.agrupa_de_partidas.map((o, i) => <li key={i}>{o.concepto} — {fmt(o.importe)}</li>)}
                      </ul>
                    </details>
                  )}
                </div>
              ))}
              {puedeCrear && (
                <div style={{ display: 'flex', gap: 8, marginTop: 8, alignItems: 'center' }}>
                  <select className="field" value={agruparProducto} onChange={e => setAgruparProducto(e.target.value)} style={{ flex: 1 }}>
                    <option value="">Producto para agrupar selección…</option>
                    {productos.map(p => <option key={p.id} value={p.id}>{p.titulo}</option>)}
                  </select>
                  <button className="btn ghost sm" onClick={agrupar}>Agrupar seleccionadas</button>
                </div>
              )}
            </div>
            <div>
              <h3 style={tituloConLinea}>💳 Pagos ({pagos.length})</h3>
              {pagos.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin pagos registrados aún.</p>}
              {pagos.map(p => (
                <div key={p.id} style={{ padding: 8, background: 'var(--surface)', borderRadius: 6, marginBottom: 4, fontSize: 12 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>{p.fecha_pago} · {p.metodo} {p.referencia ? `(#${p.referencia})` : ''}</span>
                    <span style={{ fontWeight: 700, color: 'var(--green)' }}>{fmt(p.monto)}</span>
                  </div>
                </div>
              ))}
            </div>
            <button className="btn ghost sm" onClick={generarTxt}>Generar TXT para SAP</button>
          </div>
        )}
      </Modal>

      <Modal open={nuevaOpen} onClose={() => setNuevaOpen(false)} title="Agregar una Factura" wide>
        <div style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Pedido (folio o título)</label>
            <input className="field" value={busqueda} onChange={e => setBusqueda(e.target.value)} placeholder="Ej. 253 o Escenario 22…" />
          </div>
          {pedido && (
            <>
              <div className="card" style={{ padding: 10, fontSize: 13 }}>
                <div><strong>Pedido #{pedido.folio}</strong> — {pedido.titulo}</div>
                <div style={{ color: 'var(--muted)', fontSize: 12 }}>Sociedad propia y Tipo de Movimiento precargados del pedido (no editables).</div>
              </div>
              <TablaWrap>
                <table>
                  <thead><tr><th></th><th>Detalle</th><th style={{ textAlign: 'right' }}>Cantidad</th><th style={{ textAlign: 'right' }}>Precio</th><th>Estatus</th></tr></thead>
                  <tbody>
                    {detalles.map(d => (
                      <tr key={d.id} style={{ opacity: d.folio_factura ? 0.5 : 1 }}>
                        <td>
                          <input type="checkbox" disabled={!!d.folio_factura}
                            checked={!!detallesSel[d.id]} onChange={() => toggleDetalle(d.id)} />
                        </td>
                        <td>{d.titulo || d.id.slice(0, 8)}</td>
                        <td style={{ textAlign: 'right' }}>{d.cantidad}</td>
                        <td style={{ textAlign: 'right' }}>{fmt(d.precio)}</td>
                        <td>{d.folio_factura ? <Badge estado="inactivo">Ya facturado (#{d.folio_factura})</Badge> : <Badge estado="pendiente">Disponible</Badge>}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </TablaWrap>
              <button className="btn green" onClick={generarFactura}>Generar factura</button>
            </>
          )}
          {msg && <p style={{ fontSize: 12 }}>{msg}</p>}
        </div>
      </Modal>

      <Modal open={!!txtModal} onClose={() => setTxtModal(null)} title="TXT para SAP" wide
        footer={<button className="btn green" onClick={descargarTxt}>Descargar .txt</button>}>
        <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12, background: 'var(--surface)', padding: 10, borderRadius: 6 }}>{txtModal}</pre>
      </Modal>
    </div>
  );
}
