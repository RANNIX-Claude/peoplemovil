import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';

export default function Publicaciones() {
  const [publicaciones, setPub] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sel, setSel] = useState(null);
  const [msg, setMsg] = useState(null);

  const cargar = async () => {
    if (!supabaseReady) { setLoading(false); return; }
    setLoading(true);
    const { data, error } = await supabase.from('v_publicaciones_para_freelance').select('*').order('fecha');
    if (!error) setPub(data || []);
    setLoading(false);
  };
  useEffect(() => { cargar(); }, []);

  const inscribirme = async pub => {
    setMsg(null);
    const { error } = await supabase.rpc('inscribirme_a_publicacion', { p_detalle: pub.pedido_detalle_id });
    if (error) { setMsg('❌ ' + error.message); return; }
    setMsg('✓ Inscripción confirmada');
    setSel(null); cargar();
  };

  return (
    <div>
      <div className="section-eyebrow">Ofertas para vos</div>
      <h1 style={{ marginBottom: 4 }}>Publicaciones</h1>
      <p style={{ fontSize: 13, color: 'var(--muted)', marginBottom: 20 }}>
        Estas son las ofertas que coinciden con tus plazas activas.
      </p>

      {msg && <div className="card" style={{ padding: 12, marginBottom: 12 }}>{msg}</div>}

      {loading && <p>Cargando…</p>}
      {!loading && publicaciones.length === 0 && (
        <div className="card">
          <p style={{ color: 'var(--muted)', textAlign: 'center', padding: 20 }}>
            No hay ofertas nuevas por el momento. Vuelve mañana o revisá tu perfil para agregar más plazas.
          </p>
        </div>
      )}

      <div style={{ display: 'grid', gap: 12 }}>
        {publicaciones.map(p => (
          <div key={p.pedido_detalle_id} className="card" style={{ margin: 0, cursor: 'pointer' }} onClick={() => setSel(p)}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
              <div>
                <div style={{ fontWeight: 800, fontSize: 15 }}>{p.puesto}</div>
                <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 4 }}>
                  📍 {p.sitio} · {p.fecha ? new Date(p.fecha).toLocaleDateString('es-MX', { weekday:'short', day:'numeric', month:'short' }) : 'Fecha por confirmar'}
                </div>
                {p.turno && <div style={{ fontSize: 12, color: 'var(--muted)' }}>🕐 {p.turno_hora_inicio}–{p.turno_hora_fin}</div>}
              </div>
              <Badge estado={(p.cupo_total - p.cupo_ocupado) > 3 ? 'activo' : 'pendiente'}>
                {p.cupo_ocupado}/{p.cupo_total}
              </Badge>
            </div>
            {p.costo_unit && <div style={{ marginTop: 8, fontSize: 12, color: 'var(--accent2)', fontWeight: 700 }}>
              ${Number(p.costo_unit).toLocaleString('es-MX')} MXN
            </div>}
          </div>
        ))}
      </div>

      <Modal open={!!sel} onClose={() => setSel(null)} title={sel?.puesto || ''}
        footer={
          <>
            <button className="btn ghost" onClick={() => setSel(null)}>Cancelar</button>
            <button className="btn green" onClick={() => inscribirme(sel)}>Inscribirme →</button>
          </>
        }>
        {sel && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Puesto</div><div>{sel.puesto}</div></div>
            <div><div className="label">Sitio</div><div>{sel.sitio}</div></div>
            {sel.cliente && <div><div className="label">Cliente</div><div>{sel.cliente}</div></div>}
            {sel.fecha && <div><div className="label">Fecha</div><div>{new Date(sel.fecha).toLocaleDateString('es-MX', { weekday:'long', day:'numeric', month:'long', year:'numeric' })}</div></div>}
            {sel.turno && <div><div className="label">Turno</div><div>{sel.turno} ({sel.hora_inicio || sel.turno_hora_inicio}–{sel.hora_fin || sel.turno_hora_fin})</div></div>}
            {sel.fase && <div><div className="label">Fase evento</div><div>{sel.fase}</div></div>}
            <div><div className="label">Cupo</div><div>{sel.cupo_ocupado} / {sel.cupo_total} inscritos</div></div>
            {sel.costo_unit && <div><div className="label">Pago</div><div style={{ color: 'var(--accent2)', fontWeight: 800, fontSize: 18 }}>${Number(sel.costo_unit).toLocaleString('es-MX')} MXN</div></div>}
            {sel.cierra_en && <div><div className="label">Cierra inscripciones</div><div>{new Date(sel.cierra_en).toLocaleString('es-MX')}</div></div>}
          </div>
        )}
      </Modal>
    </div>
  );
}
