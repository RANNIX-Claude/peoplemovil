import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';

export default function VacantesPublicas() {
  const [vacantes, setVacantes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!supabaseReady) { setLoading(false); return; }
    supabase.from('v_vacantes_publicas').select('*').order('fecha_publicacion', { ascending: false })
      .then(({ data }) => { setVacantes(data || []); setLoading(false); });
  }, []);

  return (
    <div>
      <div className="section-eyebrow">Postularme</div>
      <h1>Vacantes activas</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>
        Elegí una vacante, revisá los detalles y postulate. Sin registro previo.
      </p>

      {loading && <p>Cargando…</p>}
      {!loading && vacantes.length === 0 && (
        <div className="card"><p style={{ color: 'var(--muted)' }}>
          No hay vacantes publicadas en este momento. Volvé pronto o consultá con RRHH.
        </p></div>
      )}

      <div style={{ display: 'grid', gap: 14 }}>
        {vacantes.map(v => (
          <Link key={v.id} to={`/vacantes/${v.id}`}
            className="card" style={{ margin: 0, textDecoration: 'none', color: 'inherit', cursor: 'pointer', transition: 'transform .12s' }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
              <div>
                <h2 style={{ marginBottom: 4 }}>{v.titulo}</h2>
                <div style={{ fontSize: 12, color: 'var(--muted)', display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                  <span>📍 {v.sitio || 'Ubicación TBD'}</span>
                  <span>💼 {v.puesto || 'Puesto general'}</span>
                  {v.cliente && <span>🏢 {v.cliente}</span>}
                </div>
              </div>
              <Badge estado="activo">ABIERTA</Badge>
            </div>
            {v.descripcion && (
              <p style={{ marginTop: 10, fontSize: 13, color: 'var(--muted)' }}>{v.descripcion.slice(0, 200)}…</p>
            )}
            <div style={{ marginTop: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: 11, color: 'var(--muted)' }}>
                {v.postulados_actual || 0}{v.cupo_maximo ? ` / ${v.cupo_maximo}` : ''} postulados
                {v.fecha_termino && ` · cierra ${new Date(v.fecha_termino).toLocaleDateString('es-MX')}`}
              </span>
              <span className="btn sm">Ver y postularme →</span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
