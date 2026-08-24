import React, { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';

export default function DetalleVacante() {
  const { vacanteId } = useParams();
  const nav = useNavigate();
  const [vac, setVac] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!supabaseReady) { setLoading(false); return; }
    supabase.from('v_vacantes_publicas').select('*').eq('id', vacanteId).maybeSingle()
      .then(({ data }) => { setVac(data); setLoading(false); });
  }, [vacanteId]);

  if (loading) return <p>Cargando…</p>;
  if (!vac) return <div className="card"><p>Vacante no disponible o cerrada. <Link to="/vacantes">Ver otras</Link></p></div>;

  return (
    <div>
      <Link to="/vacantes" style={{ fontSize: 12 }}>← Volver a vacantes</Link>
      <div style={{ marginTop: 12 }}>
        <div className="section-eyebrow">Vacante abierta</div>
        <h1>{vac.titulo}</h1>
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', margin: '12px 0', fontSize: 13 }}>
          {vac.puesto && <Badge estado="proceso">{vac.puesto}</Badge>}
          {vac.sitio && <Badge estado="inactivo">📍 {vac.sitio}</Badge>}
          {vac.cliente && <Badge estado="activo">🏢 {vac.cliente}</Badge>}
        </div>
      </div>

      {vac.descripcion && (
        <div className="card">
          <h3>Descripción</h3>
          <p style={{ whiteSpace: 'pre-wrap', color: 'var(--muted)' }}>{vac.descripcion}</p>
        </div>
      )}

      <div className="card">
        <h3>Datos de la publicación</h3>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, fontSize: 13 }}>
          {vac.fecha_publicacion && <div><div className="label">Publicada</div><div>{new Date(vac.fecha_publicacion).toLocaleDateString('es-MX')}</div></div>}
          {vac.fecha_termino && <div><div className="label">Cierra</div><div>{new Date(vac.fecha_termino).toLocaleDateString('es-MX')}</div></div>}
          <div><div className="label">Postulados</div><div>{vac.postulados_actual || 0}{vac.cupo_maximo ? ` / ${vac.cupo_maximo}` : ''}</div></div>
        </div>
      </div>

      <button className="btn" style={{ width: '100%', justifyContent: 'center', padding: 14, fontSize: 15 }}
        onClick={() => nav(`/postularme/${vacanteId}`)}>
        Postularme a esta vacante →
      </button>

      <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 12, textAlign: 'center' }}>
        Solo te tomará 2 minutos. Después vas a poder agendar tu entrevista grupal.
      </p>
    </div>
  );
}
