import React, { useState } from 'react';
import Layout from './components/Layout.jsx';
import Dashboard from './pages/Dashboard.jsx';
import Personal from './pages/Personal.jsx';
import SitiosAsignacion from './pages/SitiosAsignacion.jsx';
import Checador from './pages/Checador.jsx';
import Nomina from './pages/Nomina.jsx';
import Pricing from './pages/Pricing.jsx';
import Configuracion from './pages/Configuracion.jsx';
import Utilerias from './pages/Utilerias.jsx';
import Bitacora from './pages/Bitacora.jsx';

const SECCIONES = [
  { titulo: 'Operación', items: [
    { id: 'dashboard', label: 'Dashboard',           Comp: Dashboard },
    { id: 'sitios',    label: 'Sitios y Asignación', Comp: SitiosAsignacion },
    { id: 'checador',  label: 'Checador',            Comp: Checador },
    { id: 'nomina',    label: 'Nómina',              Comp: Nomina }
  ]},
  { titulo: 'Personal', items: [
    { id: 'personal', label: 'Empleados y candidatos', Comp: Personal }
  ]},
  { titulo: 'Administración', items: [
    { id: 'config',  label: 'Configuración', Comp: Configuracion },
    { id: 'pricing', label: 'Pricing',       Comp: Pricing }
  ]},
  { titulo: 'Soporte / Dev', items: [
    { id: 'utilerias', label: 'Utilerías (explorador de datos)', Comp: Utilerias },
    { id: 'bitacora',  label: 'Bitácora de accesos',              Comp: Bitacora }
  ]}
];

const FLAT = SECCIONES.flatMap(g => g.items);

export default function App() {
  const [active, setActive] = useState('dashboard');
  const Comp = FLAT.find(t => t.id === active)?.Comp || Dashboard;
  return (
    <Layout secciones={SECCIONES} active={active} onSelect={setActive}>
      <Comp />
    </Layout>
  );
}
