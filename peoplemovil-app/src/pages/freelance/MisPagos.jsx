import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';

const fmt = n => '$' + Number(n || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 });

export default function MisPagos() {
  const [saldo, setSaldo] = useState(null);
  const [pagos, setPagos] = useState([]);
  const [nominaDet, setNominaDet] = useState([]);

  useEffect(() => {
    if (!supabaseReady) return;
    (async () => {
      const { data: emp } = await supabase.from('te_empleados').select('id')
        .eq('auth_user_id', (await supabase.auth.getUser()).data.user?.id).maybeSingle();
      if (!emp) return;
      const { data: s } = await supabase.rpc('saldo_empleado', { p_empleado: emp.id });
      setSaldo(s);
      const { data: p } = await supabase.from('te_pagos_dispersion').select('*')
        .eq('empleado_id', emp.id).order('dispersado_en', { ascending: false }).limit(20);
      setPagos(p || []);
      const { data: nd } = await supabase.from('te_nomina_detalle').select('*')
        .eq('empleado_id', emp.id).order('creado_en', { ascending: false }).limit(10);
      setNominaDet(nd || []);
    })();
  }, []);

  return (
    <div>
      <div className="section-eyebrow">Mis pagos</div>
      <h1>Saldo actual</h1>

      <div className="kpi-card" style={{ margin: '16px 0 24px', padding: 24, textAlign: 'center', background: 'var(--accent-light)' }}>
        <div className="kpi-label">Saldo pendiente</div>
        <div className="kpi-value" style={{ fontSize: 36, color: 'var(--accent-dk)' }}>{fmt(saldo || 0)}</div>
      </div>

      <h3>Detalle por periodo</h3>
      <div style={{ display: 'grid', gap: 8, marginBottom: 24 }}>
        {nominaDet.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin cálculos de nómina aún.</p>}
        {nominaDet.map(n => (
          <div key={n.id} className="card" style={{ margin: 0, padding: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
              <strong style={{ fontSize: 13 }}>{n.reservaciones_cnt} turnos · {n.regimen_pago}</strong>
              <Badge estado={n.estatus_pago === 'pagado' ? 'activo' : (n.estatus_pago === 'dispersado' ? 'proceso' : 'pendiente')}>
                {n.estatus_pago}
              </Badge>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8, fontSize: 11 }}>
              <div><div className="label">Bruto</div>{fmt(n.monto_bruto)}</div>
              <div><div className="label">Penal.</div>{fmt(n.penalizaciones_aplicadas)}</div>
              <div><div className="label">Neto</div><strong>{fmt(n.monto_neto)}</strong></div>
            </div>
          </div>
        ))}
      </div>

      <h3>Pagos recibidos</h3>
      <div style={{ display: 'grid', gap: 8 }}>
        {pagos.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin pagos registrados.</p>}
        {pagos.map(p => (
          <div key={p.id} className="card" style={{ margin: 0, padding: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <div>
                <strong>{fmt(p.monto)}</strong>
                <div style={{ fontSize: 11, color: 'var(--muted)' }}>
                  {p.dispersado_en ? new Date(p.dispersado_en).toLocaleDateString('es-MX') : 'Pendiente'} · {p.referencia_bancaria || ''}
                </div>
              </div>
              <Badge estado={p.status === 'pagado' ? 'activo' : 'pendiente'}>{p.status}</Badge>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
