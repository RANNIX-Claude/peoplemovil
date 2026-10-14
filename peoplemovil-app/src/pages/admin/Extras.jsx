import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Modal from '../../components/ui/Modal.jsx';
import Chip from '../../components/ui/Chip.jsx';
import { tituloConLinea } from '../../components/ui/CardHeader.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// Escenario 23 QA ("Extras"): captura (nomina.crear) vs. autorización (nomina.aprobar),
// incluida la aprobación masiva de todos los extras "En Espera". El Pago Bruto se
// refleja al recalcular el periodo de nómina (ver calcular_nomina_periodo, Migración 055).
const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function Extras() {
  useModuleAudit('extras');
  const { usuario, hasPermiso, tenantId } = useAdminAuth();
  const TENANT_ID = tenantId || DEMO_TENANT_ID;
  const puedeCrear = hasPermiso('nomina.crear');
  const puedeAprobar = hasPermiso('nomina.aprobar');

  const [extras, setExtras] = useState([]);
  const [empleadosMap, setEmpleadosMap] = useState({});
  const [conceptos, setConceptos] = useState([]);
  const [filtro, setFiltro] = useState('en_espera');
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [msg, setMsg] = useState('');

  const [fEmpleadoTexto, setFEmpleadoTexto] = useState('');
  const [fEmpleadoResultados, setFEmpleadoResultados] = useState([]);
  const [fEmpleado, setFEmpleado] = useState(null);
  const [fReservaciones, setFReservaciones] = useState([]);
  const [fPedidoDetalle, setFPedidoDetalle] = useState('');
  const [fTurnos, setFTurnos] = useState('0.5');
  const [fConcepto, setFConcepto] = useState('');
  const [guardando, setGuardando] = useState(false);

  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: ex }, { data: conc }] = await Promise.all([
      supabase.from('te_extras_nomina').select('*').order('creado_en', { ascending: false }).limit(200),
      supabase.from('tc_conceptos_extra').select('*').eq('activo', true),
    ]);
    setExtras(ex || []); setConceptos(conc || []);
    const ids = Array.from(new Set((ex || []).map(e => e.empleado_id)));
    if (ids.length) {
      const { data: emps } = await supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno').in('id', ids);
      const map = {}; (emps || []).forEach(e => { map[e.id] = e; });
      setEmpleadosMap(map);
    }
  }
  useEffect(() => { cargar(); }, []);

  const buscarEmpleado = async texto => {
    setFEmpleadoTexto(texto); setFEmpleado(null);
    if (!texto || texto.trim().length < 1) { setFEmpleadoResultados([]); return; }
    const esFolio = /^\d+$/.test(texto.trim());
    let q = supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno')
      .eq('tenant_id', TENANT_ID).eq('activo', true).limit(10);
    q = esFolio ? q.eq('folio', Number(texto.trim()))
      : q.or(`nombres.ilike.%${texto}%,apellido_paterno.ilike.%${texto}%`);
    const { data } = await q;
    setFEmpleadoResultados(data || []);
  };

  const elegirEmpleado = async emp => {
    setFEmpleado(emp); setFEmpleadoTexto(`#${emp.folio} ${emp.nombres} ${emp.apellido_paterno}`); setFEmpleadoResultados([]);
    const { data } = await supabase.from('te_reservaciones')
      .select('id, pedido_detalle_id, puesto_id, cita_inicio, tc_puestos(titulo)')
      .eq('empleado_id', emp.id).eq('estado', 'procesado')
      .order('cita_inicio', { ascending: false }).limit(20);
    setFReservaciones(data || []);
    setFPedidoDetalle('');
  };

  const crearExtra = async () => {
    if (!fEmpleado || !fPedidoDetalle || !fConcepto) { setMsg('Faltan datos: empleado, detalle de pedido y concepto.'); return; }
    setGuardando(true);
    const resv = fReservaciones.find(r => r.pedido_detalle_id === fPedidoDetalle);
    const { data: sueldo } = await supabase.rpc('sueldo_plaza_vigente', {
      p_empleado: fEmpleado.id, p_puesto: resv?.puesto_id, p_fecha: (resv?.cita_inicio || '').slice(0, 10)
    });
    const turnos = Number(fTurnos) || 0;
    const monto = Math.round((Number(sueldo) || 0) * turnos * 100) / 100;
    const { error } = await supabase.from('te_extras_nomina').insert({
      tenant_id: TENANT_ID, empleado_id: fEmpleado.id, pedido_detalle_id: fPedidoDetalle,
      concepto_id: fConcepto, concepto: conceptos.find(c => c.id === fConcepto)?.nombre || 'Extra',
      tipo: 'bono', turnos, monto, aplicado: false
    });
    setGuardando(false);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('extras', 'CREAR', `empleado ${fEmpleado.id}, turnos ${turnos}, monto ${monto}`);
    setMsg(`✓ Extra creado por ${fmt(monto)} (en espera de autorización)`);
    setNuevoOpen(false);
    setFEmpleado(null); setFEmpleadoTexto(''); setFReservaciones([]); setFPedidoDetalle(''); setFTurnos('0.5'); setFConcepto('');
    cargar();
  };

  const aprobarTodosEnEspera = async () => {
    const idsEnEspera = extras.filter(e => !e.aplicado).map(e => e.id);
    if (idsEnEspera.length === 0) return;
    const { error } = await supabase.from('te_extras_nomina')
      .update({ aplicado: true, autorizado_por: usuario?.id })
      .in('id', idsEnEspera);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('extras', 'APROBAR_MASIVO', `${idsEnEspera.length} extras aprobados`);
    setMsg(`✓ Aprobados ${idsEnEspera.length} extras`);
    cargar();
  };

  const filtrados = useMemo(() => extras.filter(e =>
    filtro === 'todos' || (filtro === 'en_espera' ? !e.aplicado : e.aplicado)
  ), [extras, filtro]);

  const kpiEnEspera = extras.filter(e => !e.aplicado).length;
  const kpiAplicados = extras.filter(e => e.aplicado).length;
  const kpiMonto = extras.reduce((s, e) => s + Number(e.monto || 0), 0);

  return (
    <div>
      <div className="section-eyebrow">Fiscal</div>
      <h1>Extras</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Pagos adicionales por empleado (turnos extra, bonos). Cualquiera con permiso <code>nomina.crear</code> puede
        capturar o modificar un extra "En Espera" — solo <code>nomina.aprobar</code> (Gerente de Nóminas) puede autorizarlo.
      </p>

      <div className="kpi-grid">
        <KpiCard label="En espera" value={kpiEnEspera} color={kpiEnEspera ? 'var(--gold)' : 'var(--green)'} onClick={() => setFiltro(filtro === 'en_espera' ? 'todos' : 'en_espera')} />
        <KpiCard label="Aplicados" value={kpiAplicados} color="var(--green)" onClick={() => setFiltro(filtro === 'aplicado' ? 'todos' : 'aplicado')} />
        <KpiCard label="Monto total" value={fmt(kpiMonto)} color="var(--accent2)" />
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', margin: '16px 0' }}>
        <div className="chips">
          <Chip active={filtro === 'todos'} onClick={() => setFiltro('todos')}>Todos ({extras.length})</Chip>
          <Chip active={filtro === 'en_espera'} onClick={() => setFiltro('en_espera')}>En Espera ({kpiEnEspera})</Chip>
          <Chip active={filtro === 'aplicado'} onClick={() => setFiltro('aplicado')}>Aplicado ({kpiAplicados})</Chip>
        </div>
        <div>
          {puedeCrear && <button className="btn" onClick={() => setNuevoOpen(true)}>+ Nuevo Extra</button>}
          {puedeAprobar && kpiEnEspera > 0 && filtro === 'en_espera' && (
            <button className="btn green" style={{ marginLeft: 8 }} onClick={aprobarTodosEnEspera}>
              Aprobar todos en espera ({kpiEnEspera})
            </button>
          )}
        </div>
      </div>

      {!puedeAprobar && <p style={{ fontSize: 12, color: 'var(--muted)' }}>
        Tu rol no tiene <code>nomina.aprobar</code> — puedes crear/modificar extras pero no autorizarlos.
      </p>}

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Empleado</th><th>Concepto</th><th style={{ textAlign: 'right' }}>Turnos</th>
                <th style={{ textAlign: 'right' }}>Monto</th><th>Estatus</th></tr>
          </thead>
          <tbody>
            {filtrados.length === 0 && <tr><td colSpan="5" className="empty">Sin extras con este filtro.</td></tr>}
            {filtrados.map(e => {
              const emp = empleadosMap[e.empleado_id];
              return (
                <tr key={e.id}>
                  <td>{emp ? `#${emp.folio} ${emp.nombres} ${emp.apellido_paterno}` : e.empleado_id.slice(0, 8) + '…'}</td>
                  <td style={{ fontSize: 12 }}>{e.concepto}</td>
                  <td style={{ textAlign: 'right' }}>{e.turnos ?? '—'}</td>
                  <td style={{ textAlign: 'right', fontWeight: 800 }}>{fmt(e.monto)}</td>
                  <td><Badge estado={e.aplicado ? 'activo' : 'pendiente'}>{e.aplicado ? 'APLICADO' : 'EN ESPERA'}</Badge></td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={nuevoOpen} onClose={() => !guardando && setNuevoOpen(false)} title="Nuevo Extra"
        footer={<>
          <button className="btn ghost" disabled={guardando} onClick={() => setNuevoOpen(false)}>Cancelar</button>
          <button className="btn green" disabled={guardando} onClick={crearExtra}>{guardando ? 'Guardando…' : 'Guardar'}</button>
        </>}>
        <div style={{ display: 'grid', gap: 12 }}>
          <div style={{ position: 'relative' }}>
            <label className="label">Empleado</label>
            <input className="field" value={fEmpleadoTexto} onChange={e => buscarEmpleado(e.target.value)} placeholder="Folio o nombre…" />
            {fEmpleadoResultados.length > 0 && (
              <div className="card" style={{ position: 'absolute', zIndex: 5, width: '100%', maxHeight: 180, overflowY: 'auto' }}>
                {fEmpleadoResultados.map(r => (
                  <div key={r.id} className="clickable" style={{ padding: 8, fontSize: 13 }} onClick={() => elegirEmpleado(r)}>
                    #{r.folio} {r.nombres} {r.apellido_paterno}
                  </div>
                ))}
              </div>
            )}
          </div>
          <div>
            <label className="label">Detalle de pedido (IdEventoDetalle)</label>
            <select className="field" value={fPedidoDetalle} onChange={e => setFPedidoDetalle(e.target.value)} disabled={!fEmpleado}>
              <option value="">— selecciona —</option>
              {fReservaciones.map(r => (
                <option key={r.pedido_detalle_id} value={r.pedido_detalle_id}>
                  {r.tc_puestos?.titulo} · {new Date(r.cita_inicio).toLocaleDateString('es-MX')}
                </option>
              ))}
            </select>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div>
              <label className="label">Turnos</label>
              <input type="number" step="0.5" className="field" value={fTurnos} onChange={e => setFTurnos(e.target.value)} />
            </div>
            <div>
              <label className="label">Concepto Extra</label>
              <select className="field" value={fConcepto} onChange={e => setFConcepto(e.target.value)}>
                <option value="">— selecciona —</option>
                {conceptos.map(c => <option key={c.id} value={c.id}>{c.nombre}</option>)}
              </select>
            </div>
          </div>
        </div>
      </Modal>
    </div>
  );
}
