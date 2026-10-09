import React, { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';
import { supabaseReady } from '../../lib/supabase.js';

// requiere: código de permiso necesario para ver el item (null = visible para cualquier usuario logueado)
const SECCIONES = [
  { titulo: 'Operación', items: [
    { path: '/admin/dashboard',      label: 'Dashboard', icono: '📊', requiere: null },
    { path: '/admin/sitios',         label: 'Pedidos y sitios', icono: '📦', requiere: 'pedidos.ver' },
    { path: '/admin/arbol',          label: 'Árbol de reservaciones', icono: '🌳', requiere: 'reservaciones.ver' },
    { path: '/admin/preasignacion',  label: 'Pre-asignación', icono: '🧩', requiere: 'reservaciones.ver' },
    { path: '/admin/asistencia',     label: 'Confirmación asistencia', icono: '✅', requiere: 'checador.ver' },
    { path: '/admin/checador',       label: 'Checador biométrico', icono: '👆', requiere: 'checador.ver' },
    { path: '/admin/nomina',         label: 'Nómina', icono: '💰', requiere: 'nomina.ver' }
  ]},
  { titulo: 'Comercial', items: [
    { path: '/admin/requisiciones', label: 'Requisiciones de personal', icono: '🧾', requiere: 'requisiciones.ver' },
    { path: '/admin/facturacion',   label: 'Facturación', icono: '🧮', requiere: 'facturacion.ver' }
  ]},
  { titulo: 'Reclutamiento', items: [
    { path: '/admin/personal',                label: 'Empleados y candidatos', icono: '👥', requiere: 'empleados.ver' },
    { path: '/admin/funnel',                  label: 'Funnel de selección', icono: '🎯', requiere: 'vacantes.ver' },
    { path: '/admin/calendario-entrevistas',  label: 'Calendario entrevistas', icono: '📅', requiere: 'candidatos.ver' },
    { path: '/admin/entrevista-grupal',       label: 'Asistencia por grupos', icono: '🙋', requiere: 'candidatos.editar' },
    { path: '/admin/firma-contratos',         label: 'Firma de contratos', icono: '✍️', requiere: 'candidatos.editar' },
    { path: '/admin/curso-induccion',         label: 'Cursos de inducción', icono: '🎓', requiere: 'candidatos.editar' },
    { path: '/admin/alta-masiva',             label: 'Alta masiva empleados', icono: '📥', requiere: 'empleados.crear' }
  ]},
  { titulo: 'Analítica', items: [
    { path: '/admin/dw',            label: 'Data Warehouse', icono: '📈', requiere: 'reportes.ver' }
  ]},
  { titulo: 'Administración', items: [
    { path: '/admin/catalogos',     label: 'Catálogos (HU 9.01)', icono: '📚', requiere: 'catalogos.ver' },
    { path: '/admin/usuarios',      label: 'Usuarios y roles (HU 9.03)', icono: '🔐', requiere: 'usuarios.ver' },
    { path: '/admin/config',        label: 'Configuración', icono: '⚙️', requiere: null },
    { path: '/admin/suscripcion',   label: 'Mi suscripción', icono: '💳', requiere: null },
    { path: '/admin/pricing',       label: 'Pricing público', icono: '🏷️', requiere: null }
  ]},
  { titulo: 'Soporte / Dev', items: [
    { path: '/admin/utilerias',     label: 'Utilerías (explorador)', icono: '🛠️', requiere: 'usuarios.ver' },
    { path: '/admin/bitacora',      label: 'Bitácora de accesos', icono: '📜', requiere: 'usuarios.ver' }
  ]}
];

// Etiqueta de build: AAMMDD-HHMM del momento en que se hizo este deploy.
// Se actualiza a mano en cada release para poder confirmar a simple vista
// qué versión quedó realmente publicada (pedido del usuario 2026-10-08).
const BUILD_TAG = '261008-0710';

export default function AdminShell() {
  const [openMobile, setOpenMobile] = useState(false);
  const ambiente = import.meta.env.VITE_AMBIENTE;
  const { usuario, hasPermiso, signOut } = useAdminAuth();

  const secciones = supabaseReady && usuario
    ? SECCIONES
        .map(g => ({ ...g, items: g.items.filter(it => !it.requiere || hasPermiso(it.requiere)) }))
        .filter(g => g.items.length > 0)
    : SECCIONES; // sin Supabase conectado o cargando: mostrar todo (modo demo)

  return (
    <div className="app-layout">
      <aside className={'sidebar' + (openMobile ? ' open' : '')}>
        <div className="sidebar-logo">
          <div className="brand">
            <div className="brand-icon">P</div>
            <div>
              <div className="brand-name">PeopleMovil</div>
              <div className="brand-sub">RANNIX · Admin</div>
              <div style={{ fontSize: 10, color: 'var(--muted)', opacity: 0.7, marginTop: 2 }}>build {BUILD_TAG}</div>
            </div>
          </div>
        </div>
        {secciones.map(g => (
          <React.Fragment key={g.titulo}>
            <div className="nav-section">{g.titulo}</div>
            {g.items.map(it => (
              <NavLink
                key={it.path}
                to={it.path}
                className={({ isActive }) => 'nav-link' + (isActive ? ' active' : '')}
                onClick={() => setOpenMobile(false)}
              ><span className="nav-icon">{it.icono}</span>{it.label}</NavLink>
            ))}
          </React.Fragment>
        ))}
        <div className="nav-section">Otros portales</div>
        <NavLink to="/vacantes" className="nav-link"><span className="nav-icon">🌐</span>Portal público</NavLink>
        <NavLink to="/portal" className="nav-link"><span className="nav-icon">🧑‍💼</span>Portal freelance</NavLink>
      </aside>
      <div className={'sidebar-scrim' + (openMobile ? ' open' : '')} onClick={() => setOpenMobile(false)} />
      <main className="app-content">
        <div className="topbar">
          <button className="btn ghost mobile-menu-btn" onClick={() => setOpenMobile(true)}>☰ Menú</button>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 700 }}>Tenant demo</span>
            <span className="badge proceso">PLAN PRO</span>
            {ambiente && ambiente !== 'PRODUCCION' && <span className="env-badge">{ambiente}</span>}
            {usuario && (
              <>
                <span style={{ fontSize: 12, color: 'var(--muted)' }}>
                  {usuario.nombre || usuario.nombre_usuario} · <strong>{usuario.rol_nombre}</strong>
                </span>
                <button className="btn ghost sm" onClick={signOut}>Cerrar sesión</button>
              </>
            )}
          </div>
        </div>
        <Outlet />
      </main>
    </div>
  );
}
