import React from 'react';

// Grid estándar para una lista de <Campo> -- mismo criterio en toda la app.
export const gridAuto = { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(170px, 1fr))', gap: 16 };

// Campo de solo-lectura en "renglón": línea divisoria debajo para que el
// grid se lea como filas (como el RH de referencia, IRPAPP), no como huecos
// sueltos. Etiqueta chica/gris vs. valor más grande/oscuro -- contraste
// deliberado entre ambos.
export default function Campo({ label, valor }) {
  return (
    <div style={{ borderBottom: '1px solid var(--border)', paddingBottom: 10 }}>
      <div className="label">{label}</div>
      <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text)' }}>
        {valor || <span style={{ color: 'var(--muted)', fontWeight: 400 }}>—</span>}
      </div>
    </div>
  );
}
