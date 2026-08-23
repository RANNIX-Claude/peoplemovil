import React from 'react';

// KPI Card — heredado del estándar RANNIX.
// Si recibe onClick, se marca como clickeable y muestra "Ver desglose →".
export default function KpiCard({ label, value, sub, color, drillLabel = 'Ver desglose →', onClick }) {
  const clickable = typeof onClick === 'function';
  return (
    <div className={'kpi-card' + (clickable ? ' clickable' : '')} onClick={onClick}>
      <div className="kpi-label">{label}</div>
      <div className="kpi-value" style={color ? { color } : undefined}>{value}</div>
      {sub && <div className="kpi-sub">{sub}</div>}
      {clickable && <div className="kpi-drill">{drillLabel}</div>}
    </div>
  );
}
