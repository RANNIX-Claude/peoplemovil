import React from 'react';

// Badges de estado — usa el color semántico correcto por estado.
// Uso: <Badge estado="activo">ACTIVO</Badge>
// Estados válidos: activo | vencido | pendiente | proceso | inactivo
export default function Badge({ estado = 'inactivo', children }) {
  return <span className={'badge ' + estado}>{children}</span>;
}
