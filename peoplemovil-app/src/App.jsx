import React, { useState } from 'react';
import Layout from './components/Layout.jsx';
import Dashboard from './pages/Dashboard.jsx';
import Personal from './pages/Personal.jsx';
import SitiosAsignacion from './pages/SitiosAsignacion.jsx';
import Checador from './pages/Checador.jsx';
import Nomina from './pages/Nomina.jsx';
import Pricing from './pages/Pricing.jsx';
import Configuracion from './pages/Configuracion.jsx';

const TABS = [
  { id: 'dashboard', label: 'Dashboard', Comp: Dashboard },
  { id: 'personal', label: 'Personal', Comp: Personal },
  { id: 'sitios', label: 'Sitios y Asignación', Comp: SitiosAsignacion },
  { id: 'checador', label: 'Checador', Comp: Checador },
  { id: 'nomina', label: 'Nómina', Comp: Nomina },
  { id: 'pricing', label: 'Pricing', Comp: Pricing },
  { id: 'config', label: 'Configuración', Comp: Configuracion }
];

export default function App() {
  const [active, setActive] = useState('dashboard');
  const Comp = TABS.find(t => t.id === active)?.Comp || Dashboard;
  return (
    <Layout tabs={TABS} active={active} onSelect={setActive}>
      <Comp />
    </Layout>
  );
}
