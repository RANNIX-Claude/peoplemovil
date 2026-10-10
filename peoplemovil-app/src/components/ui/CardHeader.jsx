import React from 'react';

// Línea divisoria estándar para un <h3> suelto (sin CardHeader) que encabeza
// una card -- mismo criterio visual que <CardHeader>, para los casos donde
// no hace falta botón "Editar".
export const tituloConLinea = { marginTop: 0, marginBottom: 12, paddingBottom: 10, borderBottom: '1px solid var(--border)' };

// Encabezado de card con ícono + botón "Editar"/acción opcional -- mismo
// criterio visual que el módulo RH de referencia (IRPAPP): cada card se
// identifica de un vistazo por su ícono, con una línea divisoria debajo.
export default function CardHeader({ titulo, icono, accion, onEditar }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, paddingBottom: 10, borderBottom: '1px solid var(--border)' }}>
      <h3 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: 8 }}>{icono && <span aria-hidden="true">{icono}</span>}{titulo}</h3>
      {accion || (onEditar && <button className="btn ghost sm" onClick={onEditar}>✎ Editar</button>)}
    </div>
  );
}
