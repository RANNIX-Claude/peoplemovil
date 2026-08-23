import React from 'react';

// Envoltorio estándar para tablas — asegura scroll horizontal y estilos.
// Uso:
//   <TablaWrap>
//     <table><thead>…</thead><tbody>…</tbody></table>
//   </TablaWrap>
export default function TablaWrap({ children, className = '' }) {
  return <div className={'tabla-wrap ' + className}>{children}</div>;
}
