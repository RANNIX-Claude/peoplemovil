import React from 'react';

// Toggle Tabla / Calendario (o dos opciones cualquiera con label + icono)
export default function ToggleVista({ opciones, activa, onChange }) {
  return (
    <div className="toggle" role="tablist">
      {opciones.map(o => (
        <button
          key={o.value}
          role="tab"
          aria-selected={activa === o.value}
          className={activa === o.value ? 'on' : ''}
          onClick={() => onChange(o.value)}
        >
          {o.icono} {o.label}
        </button>
      ))}
    </div>
  );
}
