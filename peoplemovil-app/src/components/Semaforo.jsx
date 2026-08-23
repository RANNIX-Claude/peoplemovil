import React from 'react';

// Verde ≥ 80% · Ámbar 60-80% · Rojo < 60% (heredado del sistema Lobo).
export default function Semaforo({ porcentaje, label }) {
  const p = Number(porcentaje) || 0;
  const cls = p >= 0.8 ? 'g' : p >= 0.6 ? 'y' : 'r';
  const pct = Math.round(p * 100);
  return (
    <div className="semaforo">
      <div className="semaforo-bar"><div className={'semaforo-fill ' + cls} style={{ width: pct + '%' }} /></div>
      <span className={'semaforo-pct ' + cls}>{pct}%</span>
      {label && <span style={{ fontSize: 11, color: 'var(--muted)' }}>{label}</span>}
    </div>
  );
}
