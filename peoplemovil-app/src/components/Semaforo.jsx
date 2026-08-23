import React from 'react';

// Heredado del sistema Lobo: verde >80% cobertura, ámbar 60-80%, rojo <60%
export default function Semaforo({ porcentaje, label }) {
  const p = Number(porcentaje) || 0;
  const bg = p >= 0.8 ? 'bg-emerald-500' : p >= 0.6 ? 'bg-amber-500' : 'bg-rose-500';
  const bgL = p >= 0.8 ? 'bg-emerald-100 text-emerald-800' : p >= 0.6 ? 'bg-amber-100 text-amber-800' : 'bg-rose-100 text-rose-800';
  const pct = Math.round(p * 100);
  return (
    <div className="flex items-center gap-2">
      <div className="h-2 flex-1 rounded-full bg-slate-200 overflow-hidden">
        <div className={`h-full ${bg}`} style={{ width: `${pct}%` }} />
      </div>
      <span className={`tag ${bgL} tabular-nums`}>{pct}%</span>
      {label && <span className="text-xs text-slate-500">{label}</span>}
    </div>
  );
}
