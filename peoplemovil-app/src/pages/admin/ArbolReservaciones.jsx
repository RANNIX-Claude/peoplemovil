import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Semaforo from '../../components/Semaforo.jsx';
import Badge from '../../components/ui/Badge.jsx';
import { useModuleAudit } from '../../lib/audit.js';

// Consulta reservaciones — vista jerárquica del sistema Lobo original
// Jerarquía: sitio → unidad de negocio → fecha → pedido → detalle (producto)
// Colores del original:
//   verde  = disponible
//   gris   = disponible no liberado (borrador)
//   naranja = preasignado
//   morado  = forzado
export default function ArbolReservaciones() {
  useModuleAudit('consulta_reservaciones');
  const [pedidos, setPedidos] = useState([]);
  const [detalles, setDetalles] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [expandidos, setExpandidos] = useState({});

  useEffect(() => {
    if (!supabaseReady) return;
    (async () => {
      const [{ data: p }, { data: d }, { data: s }] = await Promise.all([
        supabase.from('te_pedidos').select('*').gte('fecha_evento', new Date(Date.now() - 30*86400000).toISOString().slice(0,10)).order('fecha_evento').limit(200),
        supabase.from('te_pedidos_detalle').select('*, tc_puestos(titulo)').limit(500),
        supabase.from('tc_sitios').select('*').eq('activo', true)
      ]);
      setPedidos(p || []); setDetalles(d || []); setSitios(s || []);
    })();
  }, []);

  // Agrupar: sitio → fecha → pedido → detalles
  const arbol = useMemo(() => {
    const t = {};
    for (const ped of pedidos) {
      const sitio = sitios.find(s => s.id === ped.sitio_id);
      const kSitio = sitio?.id || 'sin_sitio';
      const kFecha = ped.fecha_evento;
      t[kSitio] = t[kSitio] || { sitio, fechas: {} };
      t[kSitio].fechas[kFecha] = t[kSitio].fechas[kFecha] || { fecha: kFecha, pedidos: [] };
      t[kSitio].fechas[kFecha].pedidos.push({
        ...ped,
        detalles: detalles.filter(d => d.pedido_id === ped.id)
      });
    }
    return t;
  }, [pedidos, detalles, sitios]);

  const toggle = k => setExpandidos({ ...expandidos, [k]: !expandidos[k] });

  // Color de detalle según status
  const colorDetalle = st => {
    if (st === 'liberado') return { bg: '#E6F7EF', color: '#0D9457', label: 'DISPONIBLE' };
    if (st === 'borrador') return { bg: '#F3F4F6', color: '#6E6E73', label: 'NO LIBERADO' };
    if (st === 'procesado') return { bg: '#EDE8F7', color: '#7B5EA7', label: 'PROCESADO' };
    if (st === 'cancelado') return { bg: '#FEE2E2', color: '#D93025', label: 'CANCELADO' };
    return { bg: '#FEF3C7', color: '#F5A623', label: (st || '').toUpperCase() };
  };

  return (
    <div>
      <div className="section-eyebrow">Operación · Consulta reservaciones</div>
      <h1>Árbol de reservaciones</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 12 }}>
        Vista jerárquica heredada del sistema Lobo: sitio → fecha → pedido → detalle.
        Semáforo: verde &gt;80% cobertura, ámbar 60-80%, rojo &lt;60%.
      </p>

      {/* Leyenda de colores */}
      <div className="card" style={{ padding: 10, marginBottom: 16, display: 'flex', gap: 12, fontSize: 12, flexWrap: 'wrap' }}>
        <strong style={{ marginRight: 8 }}>Colores:</strong>
        <span><span style={{ display: 'inline-block', width: 12, height: 12, background: '#0D9457', borderRadius: 3, verticalAlign: 'middle' }}></span> Disponible (liberado)</span>
        <span><span style={{ display: 'inline-block', width: 12, height: 12, background: '#6E6E73', borderRadius: 3, verticalAlign: 'middle' }}></span> No liberado (borrador)</span>
        <span><span style={{ display: 'inline-block', width: 12, height: 12, background: '#F5A623', borderRadius: 3, verticalAlign: 'middle' }}></span> Preasignado</span>
        <span><span style={{ display: 'inline-block', width: 12, height: 12, background: '#7B5EA7', borderRadius: 3, verticalAlign: 'middle' }}></span> Forzado</span>
      </div>

      {Object.keys(arbol).length === 0 && <div className="card"><p style={{ color: 'var(--muted)' }}>Sin pedidos próximos.</p></div>}

      {Object.values(arbol).map(({ sitio, fechas }) => {
        const kSitio = sitio?.id || 'sin';
        const abierto = expandidos[kSitio] !== false;
        const totFechas = Object.keys(fechas).length;
        const totPedidos = Object.values(fechas).reduce((s, f) => s + f.pedidos.length, 0);
        const totDet = Object.values(fechas).reduce((s, f) => s + f.pedidos.reduce((s2, p) => s2 + p.detalles.length, 0), 0);

        return (
          <div key={kSitio} className="card" style={{ padding: 0, overflow: 'hidden', margin: '0 0 12px' }}>
            <button onClick={() => toggle(kSitio)}
              style={{ width: '100%', padding: 14, background: 'var(--surface)', border: 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer', textAlign: 'left' }}>
              <div>
                <span style={{ marginRight: 8 }}>{abierto ? '▼' : '▶'}</span>
                <strong>📍 {sitio?.titulo || 'Sin sitio'}</strong>
                <span style={{ marginLeft: 12, fontSize: 11, color: 'var(--muted)' }}>{totFechas} fechas · {totPedidos} pedidos · {totDet} detalles</span>
              </div>
            </button>

            {abierto && Object.values(fechas).map(({ fecha, pedidos }) => {
              const kFecha = `${kSitio}-${fecha}`;
              const abFecha = expandidos[kFecha] !== false;
              return (
                <div key={kFecha} style={{ borderTop: '1px solid var(--border)' }}>
                  <button onClick={() => toggle(kFecha)}
                    style={{ width: '100%', padding: '10px 14px 10px 34px', background: 'var(--white)', border: 'none', display: 'flex', justifyContent: 'space-between', cursor: 'pointer', textAlign: 'left' }}>
                    <div>
                      <span style={{ marginRight: 8, color: 'var(--muted)' }}>{abFecha ? '▼' : '▶'}</span>
                      📅 <strong>{new Date(fecha).toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' })}</strong>
                      <span style={{ marginLeft: 12, fontSize: 11, color: 'var(--muted)' }}>{pedidos.length} pedido(s)</span>
                    </div>
                  </button>
                  {abFecha && pedidos.map(ped => {
                    const kPed = `${kFecha}-${ped.id}`;
                    const abPed = expandidos[kPed] !== false;
                    const totReq = ped.detalles.reduce((s, d) => s + Number(d.cantidad || 0), 0);
                    const totRes = ped.detalles.reduce((s, d) => s + Number(d.cantidad_reservados_real || 0), 0);
                    const cob = totReq > 0 ? totRes / totReq : 0;
                    return (
                      <div key={kPed} style={{ borderTop: '1px dashed var(--border)' }}>
                        <button onClick={() => toggle(kPed)}
                          style={{ width: '100%', padding: '10px 14px 10px 60px', background: 'var(--white)', border: 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer', textAlign: 'left' }}>
                          <div>
                            <span style={{ marginRight: 8, color: 'var(--muted)' }}>{abPed ? '▼' : '▶'}</span>
                            <span className="mono">#{ped.folio}</span> · {ped.titulo}
                          </div>
                          <div style={{ display: 'flex', gap: 12, alignItems: 'center', minWidth: 200 }}>
                            <div style={{ minWidth: 100 }}><Semaforo porcentaje={cob} /></div>
                            <span style={{ fontSize: 11, color: 'var(--muted)' }}>{totRes}/{totReq}</span>
                          </div>
                        </button>
                        {abPed && (
                          <div style={{ padding: '10px 14px 10px 90px', background: 'var(--surface)' }}>
                            {ped.detalles.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin detalles de puesto capturados.</p>}
                            {ped.detalles.map(d => {
                              const col = colorDetalle(d.status_detalle);
                              const pct = d.cantidad > 0 ? (d.cantidad_reservados_real || 0) / d.cantidad : 0;
                              return (
                                <div key={d.id} style={{ padding: '8px 12px', background: 'var(--white)', borderLeft: `4px solid ${col.color}`, marginBottom: 4, borderRadius: 6, display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
                                  <div>
                                    <span style={{ background: col.bg, color: col.color, padding: '2px 8px', borderRadius: 4, fontSize: 10, fontWeight: 800, marginRight: 8 }}>{col.label}</span>
                                    <strong>{d.tc_puestos?.titulo}</strong>
                                    <span style={{ marginLeft: 8, color: 'var(--muted)' }}>Cant. {d.cantidad}, reservados {d.cantidad_reservados_real || 0}</span>
                                  </div>
                                  <div style={{ minWidth: 100 }}><Semaforo porcentaje={pct} /></div>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              );
            })}
          </div>
        );
      })}
    </div>
  );
}
