import React from 'react';

export default function EmptyState({ title, hint }) {
  return (
    <div className="card p-12 text-center">
      <h3 className="text-sm font-semibold text-slate-900">{title}</h3>
      {hint && <p className="mt-2 text-xs text-slate-500 max-w-md mx-auto">{hint}</p>}
    </div>
  );
}
