import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

// Admin (interno)
import AdminShell from './components/admin/AdminShell.jsx';
import Dashboard from './pages/Dashboard.jsx';
import Personal from './pages/Personal.jsx';
import SitiosAsignacion from './pages/SitiosAsignacion.jsx';
import Checador from './pages/Checador.jsx';
import Nomina from './pages/Nomina.jsx';
import Pricing from './pages/Pricing.jsx';
import Configuracion from './pages/Configuracion.jsx';
import Utilerias from './pages/Utilerias.jsx';
import Bitacora from './pages/Bitacora.jsx';
import Requisiciones from './pages/admin/Requisiciones.jsx';
import Facturacion from './pages/admin/Facturacion.jsx';
import FunnelReclutamiento from './pages/admin/FunnelReclutamiento.jsx';
import DataWarehouse from './pages/admin/DataWarehouse.jsx';
import Suscripcion from './pages/admin/Suscripcion.jsx';
import CatalogosAdmin from './pages/admin/CatalogosAdmin.jsx';
import UsuariosRoles from './pages/admin/UsuariosRoles.jsx';
import ArbolReservaciones from './pages/admin/ArbolReservaciones.jsx';
import Preasignacion from './pages/admin/Preasignacion.jsx';
import ConfirmacionAsistencia from './pages/admin/ConfirmacionAsistencia.jsx';
import CalendarioEntrevistas from './pages/admin/CalendarioEntrevistas.jsx';
import AltaMasivaEmpleados from './pages/admin/AltaMasivaEmpleados.jsx';

// Portal público candidatos
import PublicShell from './components/public/PublicShell.jsx';
import VacantesPublicas from './pages/public/VacantesPublicas.jsx';
import DetalleVacante from './pages/public/DetalleVacante.jsx';
import Postularme from './pages/public/Postularme.jsx';

// Portal freelance
import FreelanceShell from './components/freelance/FreelanceShell.jsx';
import FreelanceLogin from './pages/freelance/FreelanceLogin.jsx';
import MisEventos from './pages/freelance/MisEventos.jsx';
import Publicaciones from './pages/freelance/Publicaciones.jsx';
import MiPerfil from './pages/freelance/MiPerfil.jsx';
import MisPagos from './pages/freelance/MisPagos.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin/dashboard" replace />} />

        <Route path="/admin" element={<AdminShell />}>
          <Route index element={<Navigate to="dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="personal" element={<Personal />} />
          <Route path="sitios" element={<SitiosAsignacion />} />
          <Route path="arbol" element={<ArbolReservaciones />} />
          <Route path="preasignacion" element={<Preasignacion />} />
          <Route path="asistencia" element={<ConfirmacionAsistencia />} />
          <Route path="checador" element={<Checador />} />
          <Route path="nomina" element={<Nomina />} />
          <Route path="requisiciones" element={<Requisiciones />} />
          <Route path="funnel" element={<FunnelReclutamiento />} />
          <Route path="calendario-entrevistas" element={<CalendarioEntrevistas />} />
          <Route path="alta-masiva" element={<AltaMasivaEmpleados />} />
          <Route path="facturacion" element={<Facturacion />} />
          <Route path="catalogos" element={<CatalogosAdmin />} />
          <Route path="usuarios" element={<UsuariosRoles />} />
          <Route path="config" element={<Configuracion />} />
          <Route path="pricing" element={<Pricing />} />
          <Route path="dw" element={<DataWarehouse />} />
          <Route path="suscripcion" element={<Suscripcion />} />
          <Route path="utilerias" element={<Utilerias />} />
          <Route path="bitacora" element={<Bitacora />} />
        </Route>

        <Route path="/vacantes" element={<PublicShell />}>
          <Route index element={<VacantesPublicas />} />
          <Route path=":vacanteId" element={<DetalleVacante />} />
        </Route>
        <Route path="/postularme/:vacanteId" element={<PublicShell />}>
          <Route index element={<Postularme />} />
        </Route>

        <Route path="/portal" element={<FreelanceShell />}>
          <Route index element={<Navigate to="publicaciones" replace />} />
          <Route path="login" element={<FreelanceLogin />} />
          <Route path="mis-eventos" element={<MisEventos />} />
          <Route path="publicaciones" element={<Publicaciones />} />
          <Route path="mis-pagos" element={<MisPagos />} />
          <Route path="perfil" element={<MiPerfil />} />
        </Route>

        <Route path="*" element={<Navigate to="/admin/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
