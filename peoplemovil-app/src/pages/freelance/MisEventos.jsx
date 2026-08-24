import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';

export default function MisEventos() {
  const [eventos, setEventos] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!supabaseReady) { setLoading(false); return; }
    supabase.from('v_agenda_freelance').select('*').order('cita_inicio', { ascending: true })
      .then(({ data }) => { setEventos(data || []); setLoading(false); });
  }, []);

  const proximos = eventos.filter(e => new Date(e.cita_inicio) >= new Date());
  const pasados = eventos.filter(e => new Date(e.cita_inicio) < new Date()).reverse();

  const chip = est => {
    if (est === 'confirmado_voluntario' || est === 'confirmado_opcional') return 'activo';
    if (est === 'preasignado') return 'pendiente';
    if (est === 'cancelado') return 'vencido';
    if (est === 'procesado') return 'proceso';
    return 'inactivo';
  };

  return (
    <div>
      <div className="section-eyebrow">Agenda</div>
      <h1 style={{ marginBottom: 20 }}>Mis eventos</h1>

      {loading && <p>Cargando…</p>}

      <h3>Próximos ({proximos.length})</h3>
      {proximos.length === 0 && <p style={{ fontSize: 13, color: 'var(--muted)' }}>Sin eventos próximos. Ver ofertas en Publicaciones.</p>}
      <div style={{ display: 'grid', gap: 10, marginBottom: 24 }}>
        {proximos.map(e => (
          <div key={e.id} className="card" style={{ margin: 0 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <div style={{ fontWeight: 800, fontSize: 14 }}>{e.puesto}</div>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>📍 {e.sitio}</div>
                <div style={{ fontSize: 12, color: 'var(--accent)', marginTop: 6, fontWeight: 700 }}>
                  {new Date(e.cita_inicio).toLocaleString('es-MX', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>
              <Badge estado={chip(e.estado)}>{e.estado.replace(/_/g, ' ')}</Badge>
            </div>
          </div>
        ))}
      </div>

      <h3>Pasados ({pasados.length})</h3>
      <div style={{ display: 'grid', gap: 8 }}>
        {pasados.slice(0, 10).map(e => (
          <div key={e.id} style={{ padding: 10, background: 'var(--surface)', borderRadius: 8, fontSize: 12, display: 'flex', justifyContent: 'space-between' }}>
            <div>
              <strong>{e.puesto}</strong> · {e.sitio}
              <div style={{ color: 'var(--muted)' }}>{new Date(e.cita_inicio).toLocaleDateString('es-MX')}</div>
            </div>
            <Badge estado={chip(e.estado_asistencia === 'asistencia' ? 'confirmado_voluntario' : e.estado_asistencia)}>
              {e.estado_asistencia}
            </Badge>
          </div>
        ))}
      </div>
    </div>
  );
}
