import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { useModuleAudit } from '../../lib/audit.js';

const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Facturacion() {
  useModuleAudit('facturacion');
  const [facturas, setFacturas] = useState([]);
  const [pagosMap, setPagosMap] = useState({});   // factura_id → sum pagado
  const [sel, setSel] = useState(null);
  const [partidas, setPartidas] = useState([]);
  const [pagos, setPagos] = useState([]);

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: f }, { data: pgs }] = await Promise.all([
      supabase.from('te_facturas_enc').select('*').order('fecha_emision', { ascending: false }).limit(50),
      supabase.from('te_pagos_factura').select('factura_id, monto')
    ]);
    setFacturas(f || []);
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

      <Modal open={!!sel} onClose={() => setSel(null)} title={`Factura ${sel?.serie}#${sel?.folio}`} wide>
        {sel && (
          <div style={{ display: 'grid', gap: 14 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12, fontSize: 13 }}>
              <div><div className="label">Subtotal</div><div>{fmt(sel.subtotal)}</div></div>
              <div><div className="label">IVA</div><div>{fmt(sel.iva)}</div></div>
              <div><div className="label">Total</div><div style={{ fontWeight: 800 }}>{fmt(sel.total)}</div></div>
            </div>
            <div>
              <h3>Partidas ({partidas.length})</h3>
              {partidas.map(p => (
                <div key={p.id} style={{ padding: 8, background: 'var(--surface)', borderRadius: 6, marginBottom: 4, fontSize: 12 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>{p.concepto} · {p.cantidad}{p.turnos > 0 ? `×${p.turnos} turnos` : ''}</span>
                    <span style={{ fontWeight: 700 }}>{fmt(p.importe)}</span>
                  </div>
                </div>
              ))}
            </div>
            <div>
              <h3>Pagos ({pagos.length})</h3>
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
          </div>
        )}
      </Modal>
    </div>
  );
}
