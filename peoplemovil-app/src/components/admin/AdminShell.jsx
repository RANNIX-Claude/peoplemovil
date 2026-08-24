import React, { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';

const SECCIONES = [
  { titulo: 'Operación', items: [
    { path: '/admin/dashboard',     label: 'Dashboard' },
    { path: '/admin/sitios',        label: 'Sitios y Asignación' },
    { path: '/admin/checador',      label: 'Checador' },
    { path: '/admin/nomina',        label: 'Nómina' }
  ]},
  { titulo: 'Comercial', items: [
    { path: '/admin/requisiciones', label: 'Requisiciones de personal' },
    { path: '/admin/facturacion',   label: 'Facturación' }
  ]},
  { titulo: 'Reclutamiento', items: [
    { path: '/admin/personal',      label: 'Empleados y candidatos' },
    { path: '/admin/funnel',        label: 'Funnel de reclutamiento' }
  ]},
  { titulo: 'Administración', items: [
    { path: '/admin/config',        label: 'Configuración' },
    { path: '/admin/pricing',       label: 'Pricing' }
  ]},
  { titulo: 'Soporte / Dev', items: [
    { path: '/admin/utilerias',     label: 'Utilerías (explorador)' },
    { path: '/admin/bitacora',      label: 'Bitácora de accesos' }
  ]}
];

export default function AdminShell() {
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
              <div className="brand-sub">RANNIX · Admin</div>
            </div>
          </div>
        </div>
        {SECCIONES.map(g => (
          <React.Fragment key={g.titulo}>
            <div className="nav-section">{g.titulo}</div>
            {g.items.map(it => (
              <NavLink
                key={it.path}
                to={it.path}
                className={({ isActive }) => 'nav-link' + (isActive ? ' active' : '')}
                onClick={() => setOpenMobile(false)}
              >{it.label}</NavLink>
            ))}
          </React.Fragment>
        ))}
        <div className="nav-section">Otros portales</div>
        <NavLink to="/vacantes" className="nav-link">→ Portal público</NavLink>
        <NavLink to="/portal" className="nav-link">→ Portal freelance</NavLink>
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
        <Outlet />
      </main>
    </div>
  );
}
