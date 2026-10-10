import React, { useMemo, useState } from 'react';
import Badge from '../ui/Badge.jsx';
import Modal from '../ui/Modal.jsx';

const DIAS = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

const toKey = d => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const addDays = (d, n) => { const r = new Date(d); r.setDate(r.getDate() + n); return r; };
const addMonths = (d, n) => { const r = new Date(d); r.setMonth(r.getMonth() + n); return r; };
const startOfWeekMonday = d => {
  const r = new Date(d);
  r.setDate(r.getDate() - ((r.getDay() + 6) % 7));
  r.setHours(0, 0, 0, 0);
  return r;
};

// Semanas (de lunes a domingo) necesarias para cubrir un mes completo -- 5 o 6
// según el mes, nunca una grilla fija de 6 que deje filas vacías de más.
function gridMes(anchor) {
  const primero = new Date(anchor.getFullYear(), anchor.getMonth(), 1);
  const ultimo = new Date(anchor.getFullYear(), anchor.getMonth() + 1, 0);
  const inicio = startOfWeekMonday(primero);
  const finSemana = startOfWeekMonday(ultimo);
  const semanas = [];
  let cur = inicio;
  while (cur <= finSemana) {
    semanas.push(Array.from({ length: 7 }, (_, i) => addDays(cur, i)));
    cur = addDays(cur, 7);
  }
  return semanas;
}

const chip = est => {
  if (est === 'confirmado_voluntario' || est === 'confirmado_opcional' || est === 'forzada') return 'activo';
  if (est === 'preasignado') return 'pendiente';
  if (est === 'cancelado') return 'vencido';
  if (est === 'procesado') return 'proceso';
  return 'inactivo';
};
const colorEstado = est => {
  if (est === 'confirmado_voluntario' || est === 'confirmado_opcional' || est === 'forzada') return 'var(--green)';
  if (est === 'preasignado') return 'var(--gold)';
  if (est === 'cancelado') return 'var(--red)';
  return 'var(--muted)';
};

// Calendario de la agenda del freelance -- semana/mes/2 meses, con los
// eventos de cada día marcados por estado. Un día puede traer varios
// eventos con PUESTOS distintos (el mismo colaborador puede tener varias
// plazas: carpintero en uno, jalar cables en otro, vigilante en otro) --
// por eso el detalle del día lista el puesto de cada evento, no uno solo.
export default function AgendaCalendario({ eventos }) {
  const [vista, setVista] = useState('mes'); // 'semana' | 'mes' | '2meses'
  const [anchor, setAnchor] = useState(() => { const d = new Date(); d.setHours(0, 0, 0, 0); return d; });
  const [diaSel, setDiaSel] = useState(null);

  const porDia = useMemo(() => {
    const map = {};
    eventos.forEach(e => {
      const k = toKey(new Date(e.cita_inicio));
      (map[k] ||= []).push(e);
    });
    return map;
  }, [eventos]);

  const hoy = toKey(new Date());
  const maxChips = vista === 'semana' ? 4 : 2;

  const mover = dir => {
    if (vista === 'semana') setAnchor(a => addDays(a, dir * 7));
    else if (vista === 'mes') setAnchor(a => addMonths(a, dir));
    else setAnchor(a => addMonths(a, dir * 2));
  };

  const renderDia = (d, mesRef) => {
    const k = toKey(d);
    const evs = porDia[k] || [];
    const fueraDeMes = mesRef != null && d.getMonth() !== mesRef;
    return (
      <div key={k}
        onClick={() => evs.length && setDiaSel({ fecha: d, eventos: evs })}
        style={{
          minHeight: vista === 'semana' ? 90 : 64, padding: 6, borderRadius: 8,
          border: '1px solid var(--border)',
          background: k === hoy ? 'var(--accent-light)' : 'var(--white)',
          opacity: fueraDeMes ? .4 : 1,
          cursor: evs.length ? 'pointer' : 'default'
        }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: k === hoy ? 'var(--accent)' : 'var(--text)' }}>{d.getDate()}</div>
        <div style={{ display: 'grid', gap: 2, marginTop: 4 }}>
          {evs.slice(0, maxChips).map(e => (
            <div key={e.id} style={{
              fontSize: 10, fontWeight: 700, padding: '1px 4px', borderRadius: 4,
              background: colorEstado(e.estado) + '22', color: colorEstado(e.estado),
              whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'
            }}>{e.puesto}</div>
          ))}
          {evs.length > maxChips && (
            <div style={{ fontSize: 10, color: 'var(--muted)' }}>+{evs.length - maxChips} más</div>
          )}
        </div>
      </div>
    );
  };

  const renderMes = (mesAnchor, conTitulo) => (
    <div>
      {conTitulo && (
        <div style={{ textAlign: 'center', fontWeight: 800, fontSize: 13, marginBottom: 8, textTransform: 'capitalize' }}>
          {MESES[mesAnchor.getMonth()]} {mesAnchor.getFullYear()}
        </div>
      )}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 4, marginBottom: 4 }}>
        {DIAS.map(d => <div key={d} style={{ fontSize: 10, fontWeight: 700, color: 'var(--muted)', textAlign: 'center' }}>{d}</div>)}
      </div>
      <div style={{ display: 'grid', gap: 4 }}>
        {gridMes(mesAnchor).map((semana, i) => (
          <div key={i} style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 4 }}>
            {semana.map(d => renderDia(d, mesAnchor.getMonth()))}
          </div>
        ))}
      </div>
    </div>
  );

  const renderSemana = () => {
    const inicio = startOfWeekMonday(anchor);
    const dias = Array.from({ length: 7 }, (_, i) => addDays(inicio, i));
    return (
      <div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 4, marginBottom: 4 }}>
          {dias.map((d, i) => (
            <div key={i} style={{ fontSize: 10, fontWeight: 700, color: 'var(--muted)', textAlign: 'center' }}>{DIAS[i]} {d.getDate()}</div>
          ))}
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 4 }}>
          {dias.map(d => renderDia(d, null))}
        </div>
      </div>
    );
  };

  let label;
  if (vista === 'semana') {
    const inicio = startOfWeekMonday(anchor), fin = addDays(inicio, 6);
    label = `${inicio.getDate()} ${MESES[inicio.getMonth()].slice(0, 3)} – ${fin.getDate()} ${MESES[fin.getMonth()].slice(0, 3)}`;
  } else if (vista === 'mes') {
    label = `${MESES[anchor.getMonth()]} ${anchor.getFullYear()}`;
  } else {
    label = `${MESES[anchor.getMonth()]} – ${MESES[addMonths(anchor, 1).getMonth()]} ${anchor.getFullYear()}`;
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 10, marginBottom: 14 }}>
        <h3 style={{ margin: 0 }}>Calendario</h3>
        <div style={{ display: 'flex', gap: 6 }}>
          {[['semana', 'Semana'], ['mes', 'Mes'], ['2meses', '2 meses']].map(([v, label2]) => (
            <button key={v} onClick={() => setVista(v)} className={'btn sm' + (vista === v ? '' : ' ghost')}>
              {label2}
            </button>
          ))}
        </div>
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
        <button className="btn ghost sm" onClick={() => mover(-1)}>←</button>
        <div style={{ fontWeight: 800, fontSize: 14, textTransform: 'capitalize' }}>{label}</div>
        <button className="btn ghost sm" onClick={() => mover(1)}>→</button>
      </div>

      {vista === 'semana' && renderSemana()}
      {vista === 'mes' && renderMes(anchor, false)}
      {vista === '2meses' && (
        <div className="mis-eventos-cols">
          {renderMes(anchor, true)}
          {renderMes(addMonths(anchor, 1), true)}
        </div>
      )}

      <Modal open={!!diaSel} onClose={() => setDiaSel(null)}
        title={diaSel ? diaSel.fecha.toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' }) : ''}>
        {diaSel && (
          <div style={{ display: 'grid', gap: 10 }}>
            {diaSel.eventos.map(e => (
              <div key={e.id} style={{ padding: 10, border: '1px solid var(--border)', borderRadius: 8 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8 }}>
                  <div style={{ fontWeight: 800, fontSize: 13 }}>{e.puesto}</div>
                  <Badge estado={chip(e.estado)}>{e.estado.replace(/_/g, ' ')}</Badge>
                </div>
                <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>📍 {e.lugar_cita || e.sitio}</div>
                <div style={{ fontSize: 12, color: 'var(--accent)', marginTop: 4, fontWeight: 700 }}>
                  {new Date(e.cita_inicio).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })} – {new Date(e.cita_fin).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>
            ))}
          </div>
        )}
      </Modal>
    </div>
  );
}
