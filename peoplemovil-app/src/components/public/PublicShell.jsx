import React from 'react';
import { Outlet, Link, NavLink } from 'react-router-dom';

export default function PublicShell() {
  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)' }}>
      <header style={{
        background: 'var(--white)', borderBottom: '1px solid var(--border)',
        padding: '12px 20px', display: 'flex', justifyContent: 'space-between',
        alignItems: 'center', position: 'sticky', top: 0, zIndex: 5
      }}>
        <Link to="/vacantes" style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
          <div className="brand-icon">P</div>
          <div>
            <div className="brand-name">PeopleMovil</div>
            <div className="brand-sub">Vacantes activas</div>
          </div>
        </Link>
        <nav style={{ display: 'flex', gap: 16 }}>
          <NavLink to="/vacantes" className="nav-link" style={{ padding: '6px 12px' }}>Vacantes</NavLink>
          <NavLink to="/portal" className="nav-link" style={{ padding: '6px 12px' }}>Ya soy freelance →</NavLink>
        </nav>
      </header>
      <main style={{ maxWidth: 1000, margin: '0 auto', padding: '24px 20px' }}>
        <Outlet />
      </main>
      <footer style={{ padding: 24, textAlign: 'center', fontSize: 12, color: 'var(--muted)' }}>
        PeopleMovil · Postularme es gratis, no requiere cuenta previa.
      </footer>
    </div>
  );
}
