import React, { useEffect, useState } from 'react';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { tituloConLinea } from '../components/ui/CardHeader.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useAdminAuth } from '../lib/AdminAuthContext.jsx';
import { useModuleAudit, logAccion } from '../lib/audit.js';

const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Nomina() {
  useModuleAudit('nomina');
  const { usuario, hasPermiso, tenantId } = useAdminAuth();
  const TENANT_ID = tenantId || DEMO_TENANT_ID;
  const puedeCerrar = hasPermiso('nomina.aprobar');

  const [periodos, setPeriodos] = useState([]);
  const [dispersion, setDispersion] = useState([]);
  const [lookups, setLookups] = useState({ empleados: {}, bancos: {}, pagadoras: {}, unidades: {} });
  const [precauciones, setPrec] = useState([]);
  const [seleccion, setSel] = useState(null);
  const [detalleModal, setDetalleModal] = useState(null);
  const [msg, setMsg] = useState('');
  const [honorarios, setHonorarios] = useState([]);
  const [pagosHonorarios, setPagosHonorarios] = useState([]);
  const [pagoHonModal, setPagoHonModal] = useState(null);

  const [cierreOpen, setCierreOpen] = useState(false);
  const [cierreTitulo, setCierreTitulo] = useState('');
  const [cierreDesde, setCierreDesde] = useState('');
  const [cierreHasta, setCierreHasta] = useState('');
  const [cierreEjecutaPrecauciones, setCierreEjecutaPrecauciones] = useState(true);
  const [cierreResultado, setCierreResultado] = useState(null);
  const [cerrando, setCerrando] = useState(false);

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: prec }, { data: hon }, { data: pagosHon }] = await Promise.all([
      supabase.from('te_nominas_periodo').select('*').order('fecha_desde', { ascending: false }),
      supabase.rpc('reporte_precauciones_nomina', { p_tenant: TENANT_ID }),
      supabase.from('v_reservaciones_sueldo_plaza').select('*')
        .in('estado', ['confirmado_voluntario', 'confirmado_opcional', 'forzada', 'procesado'])
        .order('cita_inicio', { ascending: false }).limit(100),
      supabase.from('v_pagos_honorarios').select('*').order('cita_inicio', { ascending: false }).limit(100),
    ]);
    setPeriodos(p || []); setPrec(prec || []); setHonorarios(hon || []); setPagosHonorarios(pagosHon || []);
  }
  useEffect(() => { cargar(); }, []);

  async function verDetalle(nom) {
    setSel(nom);
    const { data } = await supabase.from('te_pagos_dispersion').select('*').eq('periodo_id', nom.id);
    setDispersion(data || []);
    const empIds = Array.from(new Set((data || []).map(d => d.empleado_id)));
    const bancoIds = Array.from(new Set((data || []).map(d => d.banco_id).filter(Boolean)));
    const pagadoraIds = Array.from(new Set((data || []).map(d => d.empresa_pagadora_id).filter(Boolean)));
    const unidadIds = Array.from(new Set((data || []).map(d => d.unidad_negocio_id).filter(Boolean)));
    const [{ data: emps }, { data: bancos }, { data: pagadoras }, { data: unidades }] = await Promise.all([
      empIds.length ? supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno').in('id', empIds) : Promise.resolve({ data: [] }),
      bancoIds.length ? supabase.from('tc_bancos').select('id, nombre').in('id', bancoIds) : Promise.resolve({ data: [] }),
      pagadoraIds.length ? supabase.from('tc_sociedades_pagadoras').select('id, titulo').in('id', pagadoraIds) : Promise.resolve({ data: [] }),
      unidadIds.length ? supabase.from('tc_unidades_negocio').select('id, titulo').in('id', unidadIds) : Promise.resolve({ data: [] }),
    ]);
    const toMap = (arr, key) => { const m = {}; (arr || []).forEach(x => { m[x.id] = x; }); return m; };
    setLookups({ empleados: toMap(emps), bancos: toMap(bancos), pagadoras: toMap(pagadoras), unidades: toMap(unidades) });
  }

  async function calcular(nom) {
    const { error, data } = await supabase.rpc('calcular_nomina_periodo', { p_nomina: nom.id });
    setMsg(error ? 'Error: ' + error.message : 'Calculado, ' + data + ' empleados');
    await logAccion('nomina', 'CALCULAR', `periodo ${nom.fecha_desde} → ${nom.fecha_hasta}: ${data || 0} empleados`);
    verDetalle(nom);
  }

  async function ejecutarCierre() {
    if (!cierreTitulo || !cierreDesde || !cierreHasta) { setMsg('Falta Título o rango de fechas del periodo.'); return; }
    setCerrando(true);
    const { data: periodo, error: errP } = await supabase.from('te_nominas_periodo').insert({
      tenant_id: TENANT_ID, ciclo_pago: 'Semanal', fecha_desde: cierreDesde, fecha_hasta: cierreHasta
    }).select().single();
    if (errP) { setMsg('❌ ' + errP.message); setCerrando(false); return; }

    const { data: proceso, error: errPr } = await supabase.from('te_proceso_cierre_nomina').insert({
      tenant_id: TENANT_ID, periodo_id: periodo.id, titulo: cierreTitulo,
      ejecuta_precauciones_previas: cierreEjecutaPrecauciones, paso_actual: 'calculo'
    }).select().single();
    if (errPr) { setMsg('❌ ' + errPr.message); setCerrando(false); return; }

    const { data: nEmpleados } = await supabase.rpc('calcular_nomina_periodo', { p_nomina: periodo.id });

    let precaucionesLista = [];
    if (cierreEjecutaPrecauciones) {
      const { data: prec } = await supabase.rpc('reporte_precauciones_nomina', { p_tenant: TENANT_ID });
      precaucionesLista = prec || [];
    }

    const { data: dispersionRows } = await supabase.from('te_pagos_dispersion').select('empleado_id, empresa_pagadora_id').eq('periodo_id', periodo.id);
    const conPagadora = (dispersionRows || []).filter(d => d.empresa_pagadora_id).length;
    const sinPagadora = (dispersionRows || []).length - conPagadora;

    await supabase.from('te_proceso_cierre_nomina').update({
      precauciones_previas_terminadas: cierreEjecutaPrecauciones,
      ejecuta_cierre_nomina: true, cierre_completo: true, paso_actual: 'completo'
    }).eq('id', proceso.id);
    await supabase.from('te_nominas_periodo').update({ cerrada: true, fecha_cierre: new Date().toISOString() }).eq('id', periodo.id);

    await logAccion('nomina', 'CIERRE', `"${cierreTitulo}" periodo ${cierreDesde}→${cierreHasta}: ${nEmpleados} empleados, ${precaucionesLista.length} precauciones, ${conPagadora}/${(dispersionRows || []).length} en fichero de dispersión`);
    setCierreResultado({ nEmpleados, precauciones: precaucionesLista, totalEmpleados: (dispersionRows || []).length, conPagadora, sinPagadora, periodo });
    setCerrando(false);
    cargar();
    verDetalle(periodo);
  }

  const kpiPeriodosAbiertos = periodos.filter(p => !p.cerrada).length;
  const kpiPrecauciones     = precauciones.length;
  const kpiEmpleadosPeriodo = dispersion.length;
  const kpiMontoTotal       = dispersion.reduce((s, d) => s + Number(d.pago_neto || 0), 0);

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
        <h3 style={{ ...tituloConLinea, marginTop: 4 }}>⚠️ PRC_ReportePrecaucionesNomina</h3>
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

      <h3 style={tituloConLinea}>🎯 Honorarios por reservación (plaza vigente)</h3>
      <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: -8, marginBottom: 12 }}>
        Sueldo resuelto en vivo contra la plaza del empleado vigente en la fecha de la cita — no la plaza "principal" ni la más reciente.
        $0.00 significa que no tiene ninguna plaza de ese puesto vigente para esa fecha.
      </p>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Empleado</th><th>Puesto</th><th>Pedido</th><th>Fecha cita</th><th>Estado</th><th style={{ textAlign: 'right' }}>Sueldo calculado</th></tr>
          </thead>
          <tbody>
            {honorarios.length === 0 && <tr><td colSpan="6" className="empty">Sin reservaciones confirmadas.</td></tr>}
            {honorarios.map(h => (
              <tr key={h.reservacion_id}>
                <td>{h.empleado}</td>
                <td>{h.puesto}</td>
                <td className="mono">#{h.pedido_folio}</td>
                <td style={{ fontSize: 12 }}>{new Date(h.cita_inicio).toLocaleString('es-MX')}</td>
                <td style={{ fontSize: 12 }}>{h.estado}</td>
                <td style={{ textAlign: 'right', fontWeight: 800, color: h.sueldo_calculado ? 'var(--accent2)' : 'var(--red)' }}>{fmt(h.sueldo_calculado)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <h3 style={tituloConLinea}>📠 Pagos Honorarios (Régimen Honorarios Normales)</h3>
      <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: -8, marginBottom: 12 }}>
        Periodo de Pago 0 (sin cierre todavía). El Pago Neto sólo se calcula una vez asignado un folio fiscal
        en <strong>Asignación de Folios</strong> — mientras falte, se muestra sólo el Pago Bruto.
      </p>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Empleado</th><th>Régimen</th><th>Núm. cuenta</th><th>Unidad de negocio</th><th>Empresa pagadora</th>
                <th style={{ textAlign: 'right' }}>Pago bruto</th><th style={{ textAlign: 'right' }}>Pago neto</th><th></th></tr>
          </thead>
          <tbody>
            {pagosHonorarios.length === 0 && <tr><td colSpan="8" className="empty">Sin reservaciones de honorarios procesadas.</td></tr>}
            {pagosHonorarios.map(p => (
              <tr key={p.reservacion_id} className="clickable" onClick={() => setPagoHonModal(p)}>
                <td>{p.empleado}</td>
                <td style={{ fontSize: 12 }}>{p.regimen_pago}</td>
                <td className="mono" style={{ fontSize: 12 }}>{p.numero_cuenta || '—'}</td>
                <td style={{ fontSize: 12 }}>{p.unidad_negocio || '—'}</td>
                <td style={{ fontSize: 12 }}>{p.empresa_pagadora || '—'}</td>
                <td style={{ textAlign: 'right' }}>{fmt(p.pago_bruto)}</td>
                <td style={{ textAlign: 'right', fontWeight: 800, color: p.folio_honorarios ? 'var(--accent2)' : 'var(--red)' }}>
                  {p.folio_honorarios ? fmt(p.pago_neto) : 'Falta folio'}
                </td>
                <td style={{ textAlign: 'right' }}><button className="btn ghost sm">Ver</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3 style={tituloConLinea}>💰 Periodos de nómina</h3>
        {puedeCerrar && <button className="btn" onClick={() => { setCierreResultado(null); setCierreOpen(true); }}>+ Proceso Cierre de Nómina</button>}
      </div>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Ciclo</th><th>Desde</th><th>Hasta</th><th>Estado</th><th></th></tr>
          </thead>
          <tbody>
            {periodos.length === 0 && <tr><td colSpan="5" className="empty">Sin periodos aún. Crea uno con "Proceso Cierre de Nómina".</td></tr>}
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
          <h3 style={tituloConLinea}>📄 Pagos Honorarios — periodo {seleccion.fecha_desde} → {seleccion.fecha_hasta} (Periodo de Pago {seleccion.cerrada ? seleccion.id.slice(0, 8) : 0})</h3>
          <TablaWrap>
            <table>
              <thead>
                <tr><th>Empleado</th><th>Régimen</th><th>Núm. Cuenta</th><th style={{ textAlign: 'right' }}>Pago Bruto</th>
                    <th style={{ textAlign: 'right' }}>Pago Neto</th><th>Unidad de Negocio</th><th>Solicitud de Pago</th><th>Empresa Pagadora</th></tr>
              </thead>
              <tbody>
                {dispersion.length === 0 && <tr><td colSpan="8" className="empty">Sin detalle. Presiona "Calcular" en el periodo.</td></tr>}
                {dispersion.map(d => {
                  const emp = lookups.empleados[d.empleado_id];
                  return (
                    <tr key={d.id} className="clickable" onClick={() => setDetalleModal(d)}>
                      <td>{emp ? `#${emp.folio} ${emp.nombres} ${emp.apellido_paterno}` : d.empleado_id.slice(0, 8) + '…'}</td>
                      <td style={{ fontSize: 12 }}>{d.regimen}</td>
                      <td className="mono" style={{ fontSize: 12 }}>{d.clabe || '—'}</td>
                      <td style={{ textAlign: 'right' }}>{fmt(d.pago_bruto)}</td>
                      <td style={{ textAlign: 'right', fontWeight: 800 }}>{fmt(d.pago_neto)}</td>
                      <td style={{ fontSize: 12 }}>{lookups.unidades[d.unidad_negocio_id]?.titulo || '—'}</td>
                      <td style={{ fontSize: 12 }}>{d.solicitud_pago || '—'}</td>
                      <td style={{ fontSize: 12, color: d.empresa_pagadora_id ? undefined : 'var(--red)' }}>
                        {lookups.pagadoras[d.empresa_pagadora_id]?.titulo || 'SIN EMPRESA PAGADORA'}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </TablaWrap>
        </>
      )}

      {msg && <p style={{ fontSize: 12, color: 'var(--muted)' }}>{msg}</p>}

      <Modal open={!!detalleModal} onClose={() => setDetalleModal(null)} title="Detalle fiscal del pago" wide>
        {detalleModal && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Empleado</div><div>{lookups.empleados[detalleModal.empleado_id] ?
              `#${lookups.empleados[detalleModal.empleado_id].folio} ${lookups.empleados[detalleModal.empleado_id].nombres} ${lookups.empleados[detalleModal.empleado_id].apellido_paterno}` :
              detalleModal.empleado_id}</div></div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
              <div><div className="label">Días laborados</div><div>{detalleModal.dias_laborados}</div></div>
              <div><div className="label">Régimen</div><div>{detalleModal.regimen}</div></div>
              <div><div className="label">Pago Bruto</div><div style={{ fontWeight: 800 }}>{fmt(detalleModal.pago_bruto)}</div></div>
              <div><div className="label">SDP</div><div>{fmt(detalleModal.sdp)}</div></div>
              <div><div className="label">IM</div><div>{fmt(detalleModal.im)}</div></div>
              <div><div className="label">CF</div><div>{fmt(detalleModal.cf)}</div></div>
              <div><div className="label">SA</div><div>{fmt(detalleModal.sa)}</div></div>
              <div><div className="label">CG</div><div>{fmt(detalleModal.cg)}</div></div>
              <div><div className="label">Impuesto Diario</div><div>{fmt(detalleModal.impuesto_diario)}</div></div>
              <div><div className="label">IT</div><div>{fmt(detalleModal.it)}</div></div>
              <div><div className="label">IVA</div><div>{fmt(detalleModal.iva)}</div></div>
              <div><div className="label">RIVA</div><div>{fmt(detalleModal.riva)}</div></div>
              <div><div className="label">RISR</div><div>{fmt(detalleModal.risr)}</div></div>
              <div><div className="label">Pago Neto</div><div style={{ fontWeight: 900 }}>{fmt(detalleModal.pago_neto)}</div></div>
            </div>
            {!detalleModal.cumple_reglas && (
              <div>
                <div className="label">Precauciones</div>
                <div>
                  {!detalleModal.cumple_regla_banco && <Badge estado="vencido">SIN BANCO</Badge>}{' '}
                  {!detalleModal.empresa_pagadora_id && <Badge estado="vencido">SIN EMPRESA PAGADORA</Badge>}
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>

      <Modal open={!!pagoHonModal} onClose={() => setPagoHonModal(null)} title="Detalle de pago honorarios">
        {pagoHonModal && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Empleado</div><div>{pagoHonModal.empleado}</div></div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <div><div className="label">Días Laborados</div><div>{pagoHonModal.dias_laborados}</div></div>
              <div><div className="label">Pago Bruto</div><div style={{ fontWeight: 800 }}>{fmt(pagoHonModal.pago_bruto)}</div></div>
              <div><div className="label">IVA</div><div>{pagoHonModal.folio_honorarios ? fmt(pagoHonModal.iva) : '—'}</div></div>
              <div><div className="label">RIVA</div><div>{pagoHonModal.folio_honorarios ? fmt(pagoHonModal.retencion_iva) : '—'}</div></div>
              <div><div className="label">RISR</div><div>{pagoHonModal.folio_honorarios ? fmt(pagoHonModal.retencion_isr) : '—'}</div></div>
              <div><div className="label">Pago Neto</div>
                <div style={{ fontWeight: 900 }}>{pagoHonModal.folio_honorarios ? fmt(pagoHonModal.pago_neto) : 'Falta folio'}</div>
              </div>
            </div>
            {!pagoHonModal.folio_honorarios && (
              <p style={{ fontSize: 12, color: 'var(--red)' }}>
                Sin folio fiscal asignado — asígnalo en "Asignación de Folios" para ver el desglose fiscal completo.
              </p>
            )}
          </div>
        )}
      </Modal>

      <Modal open={cierreOpen} onClose={() => !cerrando && setCierreOpen(false)} title="Proceso Cierre de Nómina" wide
        footer={!cierreResultado && <>
          <button className="btn ghost" disabled={cerrando} onClick={() => setCierreOpen(false)}>Cancelar</button>
          <button className="btn green" disabled={cerrando} onClick={ejecutarCierre}>{cerrando ? 'Procesando…' : 'Guardar'}</button>
        </>}>
        {!cierreResultado ? (
          <div style={{ display: 'grid', gap: 12 }}>
            <div>
              <label className="label">Título</label>
              <input className="field" value={cierreTitulo} onChange={e => setCierreTitulo(e.target.value)} placeholder="Ej. Cierre semana 41" />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div>
                <label className="label">Periodo — desde</label>
                <input type="date" className="field" value={cierreDesde} onChange={e => setCierreDesde(e.target.value)} />
              </div>
              <div>
                <label className="label">Periodo — hasta</label>
                <input type="date" className="field" value={cierreHasta} onChange={e => setCierreHasta(e.target.value)} />
              </div>
            </div>
            <label style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 13 }}>
              <input type="checkbox" checked={cierreEjecutaPrecauciones} onChange={e => setCierreEjecutaPrecauciones(e.target.checked)} />
              Ejecutar Lista de Precauciones Previas al Cierre
            </label>
          </div>
        ) : (
          <div style={{ display: 'grid', gap: 12 }}>
            <p>✓ Calculado: <strong>{cierreResultado.nEmpleados}</strong> empleados.</p>
            {cierreEjecutaPrecauciones && (
              <div>
                <div className="label">Precauciones encontradas ({cierreResultado.precauciones.length})</div>
                {cierreResultado.precauciones.length === 0
                  ? <p style={{ fontSize: 12, color: 'var(--muted)' }}>Ninguna.</p>
                  : <ul style={{ listStyle: 'none', fontSize: 12 }}>
                      {cierreResultado.precauciones.map(p => (
                        <li key={p.empleado_id} style={{ padding: '4px 0' }}>
                          <strong>{p.nombre}</strong>: {(p.motivos || []).join(', ')}
                        </li>
                      ))}
                    </ul>}
              </div>
            )}
            <div>
              <div className="label">Fichero de dispersión</div>
              <p style={{ fontSize: 13 }}>
                <strong style={{ color: 'var(--green)' }}>{cierreResultado.conPagadora}</strong> de {cierreResultado.totalEmpleados} empleados
                tienen Empresa Pagadora y saldrán en el fichero
                {cierreResultado.sinPagadora > 0 && <> — <strong style={{ color: 'var(--red)' }}>{cierreResultado.sinPagadora}</strong> excluido(s) por no tener Empresa Pagadora</>}.
              </p>
            </div>
            <button className="btn green" onClick={() => setCierreOpen(false)}>Cerrar</button>
          </div>
        )}
      </Modal>
    </div>
  );
}
