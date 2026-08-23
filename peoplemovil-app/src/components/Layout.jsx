import React, { useState } from 'react';

// Sidebar RANNIX: agrupado por Visual/Patrones/Funciones/Reglas.
// Adaptado a PeopleMovil como: Operación / Personal / Config / Utilerías.
export default function Layout({ secciones, active, onSelect, children }) {
  const [openMobile, setOpenMobile] = useState(false);
  const ambiente = import.meta.env.VITE_AMBIENTE;

  return (
    <div className="app-layout">
      <aside className={'sidebar' + (openMobile ? ' open' : '')}>
        <div className="sidebar-logo">
          <div className="brand">
            <div className="brand-icon">P</div>
            <div>
              <div className="brand-name">PeopleMovil</div>
              <div className="brand-sub">RANNIX Consulting</div>
            </div>
          </div>
        </div>
        {secciones.map(grupo => (
          <React.Fragment key={grupo.titulo}>
            <div className="nav-section">{grupo.titulo}</div>
            {grupo.items.map(item => (
              <button
                key={item.id}
                className={'nav-link' + (active === item.id ? ' active' : '')}
                onClick={() => { onSelect(item.id); setOpenMobile(false); }}
              >
                {item.label}
              </button>
            ))}
          </React.Fragment>
        ))}
      </aside>
      <div className={'sidebar-scrim' + (openMobile ? ' open' : '')} onClick={() => setOpenMobile(false)} />

      <main className="app-content">
        <div className="topbar">
          <button className="btn ghost mobile-menu-btn" onClick={() => setOpenMobile(true)}>☰ Menú</button>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 700 }}>Tenant demo</span>
            <span className="badge proceso">PLAN PRO</span>
            {ambiente && ambiente !== 'PRODUCCION' && <span className="env-badge">{ambiente}</span>}
          </div>
        </div>
        {children}
      </main>
    </div>
  );
}
