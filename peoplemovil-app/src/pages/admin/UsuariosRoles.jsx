import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Chip from '../../components/ui/Chip.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit } from '../../lib/audit.js';

// HU 9.03 — Usuarios, Roles y Perfiles
// Muestra: usuarios (empleados vinculados a auth), roles (basados en te_empleados + tabla roles)
const ROLES = ['admin', 'coordinador', 'analista_rrhh', 'nomina', 'operacion', 'freelance', 'lectura'];

export default function UsuariosRoles() {
  useModuleAudit('usuarios_roles');
  const [empleados, setEmpleados] = useState([]);
  const [filtroRol, setFiltroRol] = useState('todos');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('te_empleados').select('id, folio, nombres, apellido_paterno, correo, auth_user_id, regimen_pago, activo, tipo_empleado')
      .order('folio').then(({ data }) => setEmpleados(data || []));
  }, []);

  const conAuth = empleados.filter(e => e.auth_user_id);
  const sinAuth = empleados.filter(e => !e.auth_user_id);

  return (
    <div>
      <div className="section-eyebrow">Administración · HU 9.03</div>
      <h1>Usuarios, Roles y Perfiles</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Vinculación entre empleados y usuarios de Supabase Auth. Un empleado accede al portal freelance cuando su <code>auth_user_id</code> está vinculado.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Empleados totales" value={empleados.length} />
        <KpiCard label="Con acceso portal" value={conAuth.length} color="var(--green)" sub={`${Math.round(100 * conAuth.length / Math.max(empleados.length, 1))}%`} />
        <KpiCard label="Pendientes de vincular" value={sinAuth.length} color="var(--gold)" sub="sin auth_user_id" />
        <KpiCard label="Roles definidos" value={ROLES.length} sub="7 roles del sistema" color="var(--accent2)" />
      </div>

      <div className="card">
        <h3>Roles del sistema</h3>
        <div className="chips">
          {ROLES.map(r => <Chip key={r} active={filtroRol === r} onClick={() => setFiltroRol(filtroRol === r ? 'todos' : r)}>{r}</Chip>)}
        </div>
        <p style={{ fontSize: 12, color: 'var(--muted)' }}>
          En la app actual los roles se asignan por: acceso admin (todos los te_empleados con auth y sin plaza freelance) vs
          acceso freelance (empleados con plaza activa). Se puede refinar con tabla te_roles + tr_usuario_rol.
        </p>
      </div>

      <h3>Empleados y su acceso</h3>
      <TablaWrap>
        <table>
          <thead>
            <tr><th>Folio</th><th>Nombre</th><th>Correo</th><th>Régimen</th><th>Tipo</th><th>Auth vinculado</th><th>Estado</th></tr>
          </thead>
          <tbody>
            {empleados.length === 0 && <tr><td colSpan="7" className="empty">Sin empleados.</td></tr>}
            {empleados.map(e => (
              <tr key={e.id}>
                <td className="mono">#{e.folio}</td>
                <td>{e.nombres} {e.apellido_paterno}</td>
                <td className="mono" style={{ fontSize: 11 }}>{e.correo || '—'}</td>
                <td style={{ fontSize: 12 }}>{e.regimen_pago}</td>
                <td>{e.tipo_empleado || '—'}</td>
                <td>{e.auth_user_id ? <Badge estado="activo">✓ Vinculado</Badge> : <Badge estado="pendiente">Sin vincular</Badge>}</td>
                <td><Badge estado={e.activo ? 'activo' : 'inactivo'}>{e.activo ? 'Activo' : 'Baja'}</Badge></td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
    </div>
  );
}
