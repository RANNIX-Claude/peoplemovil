import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Chip from '../../components/ui/Chip.jsx';
import Modal from '../../components/ui/Modal.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// HU 2.05 + 3.11 — Confirmación de asistencia y registro manual (Escenario 22 QA:
// "Captura de lista manual de asistencia"). Las reservaciones recién forzadas llegan
// con estado_asistencia='pendiente' — se tratan como "Asistencia" por default tanto
// en pantalla como al guardar (igual que el legado, donde el checkbox venía premarcado).
// Los cambios se acumulan en estado local y se confirman en lote con "Confirmar Lista",
// igual que el modal "Procesar N con registro de asistencia" del sistema original.
const ESTADOS = ['asistencia', 'retardo', 'falta'];
const efectivo = estado => (estado === 'pendiente' ? 'asistencia' : estado);

export default function ConfirmacionAsistencia() {
  useModuleAudit('confirmacion_asistencia');
  const [fecha, setFecha] = useState(new Date().toISOString().slice(0, 10));
  const [reservaciones, setReservaciones] = useState([]);
  const [local, setLocal] = useState({}); // id -> estado elegido en pantalla (sin guardar)
  const [filtro, setFiltro] = useState('todas');
  const [msg, setMsg] = useState('');
  const [confirmando, setConfirmando] = useState(false);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_reservaciones')
      .select('*, te_empleados(folio, nombres, apellido_paterno), tc_puestos(titulo), tc_sitios(titulo)')
      .gte('cita_inicio', fecha + 'T00:00:00Z')
      .lte('cita_inicio', fecha + 'T23:59:59Z')
      .then(({ data }) => {
        setReservaciones(data || []);
        const init = {};
        (data || []).forEach(r => { init[r.id] = efectivo(r.estado_asistencia); });
        setLocal(init);
      });
  }, [fecha]);

  const elegir = (r, estado) => setLocal(prev => ({ ...prev, [r.id]: estado }));

  const confirmarLista = async () => {
    setGuardando(true);
    const cambios = reservaciones.filter(r => r.estado !== 'procesado' || efectivo(r.estado_asistencia) !== local[r.id]);
    for (const r of reservaciones) {
      const estadoElegido = local[r.id] || 'asistencia';
      const { error } = await supabase.from('te_reservaciones').update({
        estado_asistencia: estadoElegido,
        estado: 'procesado',
        hora_entrada_real: estadoElegido === 'asistencia' || estadoElegido === 'retardo' ? new Date().toISOString() : null
      }).eq('id', r.id);
      if (error) { setMsg('❌ ' + error.message); setGuardando(false); return; }
    }
    await logAccion('confirmacion_asistencia', 'CONFIRMAR_LISTA', `${cambios.length} de ${reservaciones.length} registros, fecha ${fecha}`);
    setReservaciones(reservaciones.map(r => ({ ...r, estado: 'procesado', estado_asistencia: local[r.id] || 'asistencia' })));
    setMsg(`✓ Procesados ${reservaciones.length} registros con asistencia`);
    setGuardando(false);
    setConfirmando(false);
  };

  const filtradas = useMemo(() => reservaciones.filter(r =>
    filtro === 'todas' || local[r.id] === filtro
  ), [reservaciones, filtro, local]);

  const kpiAsis = reservaciones.filter(r => local[r.id] === 'asistencia').length;
  const kpiRetardos = reservaciones.filter(r => local[r.id] === 'retardo').length;
  const kpiFaltas = reservaciones.filter(r => local[r.id] === 'falta').length;
  const kpiSinProcesar = reservaciones.filter(r => r.estado !== 'procesado').length;

  return (
    <div>
      <div className="section-eyebrow">Operación · HU 2.05 / 3.11</div>
      <h1>Confirmación de asistencia</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Captura manual de asistencia para reservaciones ya ocurridas (asignación forzada incluida).
        Todas las reservaciones parten como "Asistencia" — marca Retardo/Falta solo las excepciones
        y confirma la lista completa al final.
      </p>

      <div className="card" style={{ padding: 12, marginBottom: 12, display: 'flex', gap: 12, alignItems: 'end', flexWrap: 'wrap' }}>
        <div>
          <label className="label">Fecha</label>
          <input type="date" className="field" value={fecha} onChange={e => setFecha(e.target.value)} />
        </div>
        <div style={{ flex: 1, fontSize: 12, color: 'var(--muted)' }}>
          <strong>{reservaciones.length}</strong> reservaciones en esta fecha
          {kpiSinProcesar > 0 && <> · <strong style={{ color: 'var(--gold)' }}>{kpiSinProcesar}</strong> sin confirmar</>}
        </div>
        {reservaciones.length > 0 && (
          <button className="btn green" disabled={guardando} onClick={() => setConfirmando(true)}>
            Confirmar Lista ({reservaciones.length})
          </button>
        )}
      </div>

      <div className="kpi-grid">
        <KpiCard label="Asistencias" value={kpiAsis} color="var(--green)" onClick={() => setFiltro(filtro === 'asistencia' ? 'todas' : 'asistencia')} />
        <KpiCard label="Retardos" value={kpiRetardos} color="var(--gold)" onClick={() => setFiltro(filtro === 'retardo' ? 'todas' : 'retardo')} />
        <KpiCard label="Faltas" value={kpiFaltas} color="var(--red)" onClick={() => setFiltro(filtro === 'falta' ? 'todas' : 'falta')} />
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <div className="chips">
        <Chip active={filtro === 'todas'} onClick={() => setFiltro('todas')}>Todas ({reservaciones.length})</Chip>
        {ESTADOS.map(e => <Chip key={e} active={filtro === e} onClick={() => setFiltro(filtro === e ? 'todas' : e)}>{e}</Chip>)}
      </div>

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Empleado</th><th>Puesto</th><th>Sitio</th><th>Cita</th><th>Estado</th><th style={{ textAlign: 'right' }}>Acciones</th></tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && <tr><td colSpan="6" className="empty">Sin reservaciones en esta fecha o filtro.</td></tr>}
            {filtradas.map(r => {
              const estado = local[r.id] || 'asistencia';
              return (
                <tr key={r.id}>
                  <td>#{r.te_empleados?.folio} {r.te_empleados?.nombres} {r.te_empleados?.apellido_paterno}</td>
                  <td>{r.tc_puestos?.titulo}</td>
                  <td>{r.tc_sitios?.titulo}</td>
                  <td className="mono" style={{ fontSize: 11 }}>{new Date(r.cita_inicio).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}</td>
                  <td>
                    <Badge estado={
                      estado === 'asistencia' ? 'activo' :
                      estado === 'retardo' ? 'pendiente' : 'vencido'
                    }>{estado}{r.estado === 'procesado' && ' · confirmado'}</Badge>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <button className={'btn sm' + (estado === 'asistencia' ? ' green' : ' ghost')} onClick={() => elegir(r, 'asistencia')} title="Marcar asistencia">✓</button>{' '}
                    <button className="btn sm" style={{ background: estado === 'retardo' ? 'var(--gold)' : undefined }} onClick={() => elegir(r, 'retardo')} title="Retardo">⏰</button>{' '}
                    <button className={'btn sm' + (estado === 'falta' ? ' red' : ' ghost')} onClick={() => elegir(r, 'falta')} title="Falta">✗</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={confirmando} onClose={() => !guardando && setConfirmando(false)} title="Actualizar lista de Asistencia"
        footer={<>
          <button className="btn ghost" disabled={guardando} onClick={() => setConfirmando(false)}>No</button>
          <button className="btn green" disabled={guardando} onClick={confirmarLista}>{guardando ? 'Procesando…' : 'Sí'}</button>
        </>}>
        <p>Procesar {reservaciones.length} con registro de asistencia.</p>
      </Modal>
    </div>
  );
}
