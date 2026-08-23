import React from 'react';

export default function Layout({ tabs, active, onSelect, children }) {
  return (
    <div className="min-h-screen bg-slate-50">
      <header className="border-b border-slate-200 bg-white sticky top-0 z-10">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between py-4">
            <div className="flex items-center gap-3">
              <img src="/favicon.svg" alt="" className="h-8 w-8" />
              <div>
                <h1 className="text-lg font-bold text-slate-900">PeopleMovil</h1>
                <p className="text-xs text-slate-500">Gestión de personal rotativo · Reforma LFT 2026-2027</p>
              </div>
            </div>
            <div className="hidden sm:flex items-center gap-2 text-xs text-slate-500">
              <span className="tag bg-emerald-100 text-emerald-800">Plan PRO</span>
              <span>Tenant demo</span>
            </div>
          </div>
          <nav className="flex gap-1 overflow-x-auto -mb-px pb-1">
            {tabs.map(t => (
              <button
                key={t.id}
                onClick={() => onSelect(t.id)}
                className={
                  'whitespace-nowrap rounded-t-md px-3 py-2 text-sm font-medium border-b-2 transition ' +
                  (active === t.id
                    ? 'border-brand-600 text-brand-700 bg-brand-50'
                    : 'border-transparent text-slate-600 hover:text-slate-900 hover:bg-slate-100')
                }
              >
                {t.label}
              </button>
            ))}
          </nav>
        </div>
      </header>
      <main className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{children}</main>
      <footer className="mx-auto max-w-7xl px-4 py-6 text-xs text-slate-400 text-center">
        PeopleMovil · Multi-tenant · RLS activo · Registros append-only
      </footer>
    </div>
  );
}
