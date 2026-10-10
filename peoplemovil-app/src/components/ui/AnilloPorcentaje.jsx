import React from 'react';

// Anillo de porcentaje (conic-gradient) -- mismo umbral g/y/r que <Semaforo>,
// en formato circular. Acepta un color fijo (p.ej. blanco sobre fondo morado
// del banner de identidad) o deriva el color semántico del porcentaje.
export default function AnilloPorcentaje({ porcentaje, size = 40, label, trackColor, fgColor }) {
  const p = Number(porcentaje) || 0;
  const color = fgColor || (p >= 0.8 ? 'var(--green)' : p >= 0.6 ? 'var(--gold)' : 'var(--red)');
  const pct = Math.round(p * 100);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
      <div className="anillo-pct" style={{ width: size, height: size, background: `conic-gradient(${color} ${pct}%, ${trackColor || 'var(--border)'} 0)` }}>
        <div className="anillo-pct-inner" style={{ width: size - 8, height: size - 8, fontSize: size * 0.26, color: fgColor ? '#fff' : color, background: fgColor ? 'transparent' : 'var(--white)' }}>{pct}%</div>
      </div>
      {label && <span style={{ fontSize: 11, fontWeight: 700, color: fgColor || 'var(--muted)', textAlign: 'center', whiteSpace: 'pre-line', lineHeight: 1.3 }}>{label}</span>}
    </div>
  );
}
