import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Chip from '../../components/ui/Chip.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// HU 2.05 + 3.11 — Confirmación de asistencia y registro manual
// Muestra reservaciones de fechas pasadas/hoy y permite marcar asistencia/retardo/falta en batch
const ESTADOS = ['pendiente','asistencia','retardo','falta'];

export default function ConfirmacionAsistencia() {
  useModuleAudit('confirmacion_asistencia');
  const [fecha, setFecha] = useState(new Date().toISOString().slice(0, 10));
  const [reservaciones, setReservaciones] = useState([]);
  const [filtro, setFiltro] = useState('todas');
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_reservaciones')
      .select('*, te_empleados(folio, nombres, apellido_paterno), tc_puestos(titulo), tc_sitios(titulo)')
      .gte('cita_inicio', fecha + 'T00:00:00Z')
      .lte('cita_inicio', fecha + 'T23:59:59Z')
      .then(({ data }) => setReservaciones(data || []));
  }, [fecha]);

  const marcarEstado = async (r, nuevoEstado) => {
    const { error } = await supabase.from('te_reservaciones').update({
      estado_asistencia: nuevoEstado,
      estado: nuevoEstado === 'falta' ? 'procesado' : 'procesado',
      hora_entrada_real: nuevoEstado === 'asistencia' || nuevoEstado === 'retardo' ? new Date().toISOString() : null
    }).eq('id', r.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('confirmacion_asistencia', 'MARCAR', `reservacion ${r.id}: ${nuevoEstado}`);
    setReservaciones(reservaciones.map(x => x.id === r.id ? { ...x, estado_asistencia: nuevoEstado, estado: 'procesado' } : x));
    setMsg(`✓ ${nuevoEstado}`);
  };

  const filtradas = useMemo(() => reservaciones.filter(r =>
    filtro === 'todas' || r.estado_asistencia === filtro
  ), [reservaciones, filtro]);

  const kpiAsis = reservaciones.filter(r => r.estado_asistencia === 'asistencia').length;
  const kpiRetardos = reservaciones.filter(r => r.estado_asistencia === 'retardo').length;
  const kpiFaltas = reservaciones.filter(r => r.estado_asistencia === 'falta').length;
  const kpiPend = reservaciones.filter(r => r.estado_asistencia === 'pendiente').length;

  return (
    <div>
      <div className="section-eyebrow">Operación · HU 2.05 / 3.11</div>
      <h1>Confirmación de asistencia</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Captura manual de asistencia para reservaciones ya ocurridas. Alternativa al checador biométrico.
      </p>

      <div className="card" style={{ padding: 12, marginBottom: 12, display: 'flex', gap: 12, alignItems: 'end', flexWrap: 'wrap' }}>
        <div>
          <label className="label">Fecha</label>
          <input type="date" className="field" value={fecha} onChange={e => setFecha(e.target.value)} />
        </div>
        <div style={{ flex: 1, fontSize: 12, color: 'var(--muted)' }}>
          <strong>{reservaciones.length}</strong> reservaciones en esta fecha
        </div>
      </div>

      <div className="kpi-grid">
        <KpiCard label="Asistencias" value={kpiAsis} color="var(--green)" onClick={() => setFiltro(filtro === 'asistencia' ? 'todas' : 'asistencia')} />
        <KpiCard label="Retardos" value={kpiRetardos} color="var(--gold)" onClick={() => setFiltro(filtro === 'retardo' ? 'todas' : 'retardo')} />
        <KpiCard label="Faltas" value={kpiFaltas} color="var(--red)" onClick={() => setFiltro(filtro === 'falta' ? 'todas' : 'falta')} />
        <KpiCard label="Pendientes" value={kpiPend} sub="por marcar" onClick={() => setFiltro(filtro === 'pendiente' ? 'todas' : 'pendiente')} />
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
            {filtradas.map(r => (
              <tr key={r.id}>
                <td>#{r.te_empleados?.folio} {r.te_empleados?.nombres} {r.te_empleados?.apellido_paterno}</td>
                <td>{r.tc_puestos?.titulo}</td>
                <td>{r.tc_sitios?.titulo}</td>
                <td className="mono" style={{ fontSize: 11 }}>{new Date(r.cita_inicio).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}</td>
                <td>
                  <Badge estado={
                    r.estado_asistencia === 'asistencia' ? 'activo' :
                    r.estado_asistencia === 'retardo' ? 'pendiente' :
                    r.estado_asistencia === 'falta' ? 'vencido' : 'inactivo'
                  }>{r.estado_asistencia}</Badge>
                </td>
                <td style={{ textAlign: 'right' }}>
                  <button className="btn green sm" onClick={() => marcarEstado(r, 'asistencia')} title="Marcar asistencia">✓</button>{' '}
                  <button className="btn sm" style={{ background: 'var(--gold)' }} onClick={() => marcarEstado(r, 'retardo')} title="Retardo">⏰</button>{' '}
                  <button className="btn red sm" onClick={() => marcarEstado(r, 'falta')} title="Falta">✗</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
    </div>
  );
}
