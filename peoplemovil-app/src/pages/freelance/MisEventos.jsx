import React, { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';

const fmtFecha = iso => new Date(iso).toLocaleString('es-MX', {
  weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit'
});

// Semáforo de urgencia -- cuánto falta para el evento, solo visual (no altera
// ninguna regla de negocio real de cancelación/penalización, esas siguen
// pendientes de decisión -- ver CLAUDE.md §11).
const urgencia = iso => {
  const horas = (new Date(iso) - new Date()) / 3600000;
  if (horas < 48) return { color: 'var(--red)', label: 'Es en menos de 48h' };
  if (horas < 24 * 7) return { color: 'var(--gold)', label: 'Es esta semana' };
  return { color: 'var(--green)', label: 'Hay tiempo' };
};

const chip = est => {
  if (est === 'confirmado_voluntario' || est === 'confirmado_opcional' || est === 'forzada') return 'activo';
  if (est === 'preasignado') return 'pendiente';
  if (est === 'cancelado') return 'vencido';
  if (est === 'procesado') return 'proceso';
  return 'inactivo';
};

// 'forzada' = el admin te asignó directamente (Preasignación), sin pasar por tu
// confirmación voluntaria -- para el freelance es, en los hechos, un evento ya
// asignado: debe verse junto a los confirmados, no desaparecer de la pantalla.
const ESTADOS_ASIGNADO = ['confirmado_voluntario', 'confirmado_opcional', 'forzada'];

export default function MisEventos() {
  const [eventos, setEventos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sel, setSel] = useState(null);
  const [accion, setAccion] = useState(null); // 'confirmar' | 'cancelar' | null
  const [enviando, setEnviando] = useState(false);

  const cargar = async () => {
    if (!supabaseReady) { setLoading(false); return; }
    setLoading(true);
    const { data, error } = await supabase.from('v_agenda_freelance').select('*').order('cita_inicio', { ascending: true });
    if (!error) setEventos(data || []);
    setLoading(false);
  };
  useEffect(() => { cargar(); }, []);

  const futuros = eventos.filter(e => new Date(e.cita_inicio) >= new Date());
  const pasados = eventos.filter(e => new Date(e.cita_inicio) < new Date()).reverse();

  const porConfirmar = futuros.filter(e => e.estado === 'preasignado');
  const confirmados = futuros.filter(e => ESTADOS_ASIGNADO.includes(e.estado));

  const confirmar = async e => {
    setEnviando(true);
    const { error } = await supabase.rpc('confirmar_mi_reservacion', { p_reservacion: e.id });
    setEnviando(false);
    if (error) { toast.error(error.message); return; }
    toast.success('Asistencia confirmada');
    setSel(null); setAccion(null); cargar();
  };

  const cancelar = async e => {
    setEnviando(true);
    const { error } = await supabase.rpc('cancelar_mi_reservacion', { p_reservacion: e.id });
    setEnviando(false);
    if (error) { toast.error(error.message); return; }
    toast.success('Participación cancelada');
    setSel(null); setAccion(null); cargar();
  };

  return (
    <div>
      <div className="section-eyebrow">Agenda</div>
      <h1 style={{ marginBottom: 20 }}>Mis eventos</h1>

      {loading && <p>Cargando…</p>}

      <h3>Por confirmar ({porConfirmar.length})</h3>
      {porConfirmar.length === 0 && (
        <p style={{ fontSize: 13, color: 'var(--muted)' }}>No tenés eventos pendientes de confirmar.</p>
      )}
      <div style={{ display: 'grid', gap: 10, marginBottom: 24 }}>
        {porConfirmar.map(e => (
          <EventoCard key={e.id} e={e} showUrgencia onClick={() => { setSel(e); setAccion('confirmar'); }} />
        ))}
      </div>

      <h3>Confirmados ({confirmados.length})</h3>
      {confirmados.length === 0 && (
        <p style={{ fontSize: 13, color: 'var(--muted)' }}>Sin eventos confirmados todavía.</p>
      )}
      <div style={{ display: 'grid', gap: 10, marginBottom: 24 }}>
        {confirmados.map(e => (
          <EventoCard key={e.id} e={e} onClick={() => { setSel(e); setAccion('cancelar'); }} />
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

      <Modal open={!!sel} onClose={() => { setSel(null); setAccion(null); }} title={sel?.puesto || ''}
        footer={sel && (
          accion === 'confirmar' ? (
            <>
              <button className="btn ghost" onClick={() => { setSel(null); setAccion(null); }} disabled={enviando}>Cerrar</button>
              <button className="btn green" onClick={() => confirmar(sel)} disabled={enviando}>
                {enviando ? 'Confirmando…' : 'Confirmar asistencia →'}
              </button>
            </>
          ) : (
            <>
              <button className="btn ghost" onClick={() => { setSel(null); setAccion(null); }} disabled={enviando}>Cerrar</button>
              {sel.permitir_cancelar_confirmaciones !== false && (
                <button className="btn red" onClick={() => cancelar(sel)} disabled={enviando}>
                  {enviando ? 'Cancelando…' : 'Cancelar participación'}
                </button>
              )}
            </>
          )
        )}>
        {sel && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Evento</div><div>{sel.pedido_titulo} {sel.pedido_folio ? `· Folio ${sel.pedido_folio}` : ''}</div></div>
            <div><div className="label">Puesto</div><div>{sel.puesto}</div></div>
            <div><div className="label">Fecha</div><div>{fmtFecha(sel.cita_inicio)} – {fmtFecha(sel.cita_fin)}</div></div>
            {sel.duracion_en_turnos && <div><div className="label">Turnos</div><div>{sel.duracion_en_turnos}</div></div>}
            <div><div className="label">Lugar de cita</div><div>{sel.lugar_cita || sel.sitio}</div></div>
            {sel.direccion_cita && <div><div className="label">Dirección</div><div>{sel.direccion_cita}</div></div>}
            {sel.indicaciones_especiales && <div><div className="label">Indicaciones</div><div>{sel.indicaciones_especiales}</div></div>}
            {accion === 'cancelar' && sel.permitir_cancelar_confirmaciones === false && (
              <div style={{ fontSize: 12, color: 'var(--red)' }}>
                Este evento ya no permite cancelar confirmaciones. Si no podés asistir, contactá a tu coordinador.
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}

function EventoCard({ e, onClick, showUrgencia }) {
  const u = showUrgencia ? urgencia(e.cita_inicio) : null;
  return (
    <div className="card" style={{ margin: 0, cursor: 'pointer', borderLeft: `3px solid ${u ? u.color : 'var(--accent)'}` }} onClick={onClick}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
        <div>
          <div style={{ fontWeight: 800, fontSize: 14 }}>{e.puesto}</div>
          <div style={{ fontSize: 12, color: 'var(--muted)' }}>📍 {e.lugar_cita || e.sitio}</div>
          <div style={{ fontSize: 12, color: 'var(--accent)', marginTop: 6, fontWeight: 700 }}>
            {fmtFecha(e.cita_inicio)}
          </div>
        </div>
        <Badge estado={chip(e.estado)}>{e.estado.replace(/_/g, ' ')}</Badge>
      </div>
      {u && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8 }}>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: u.color, flexShrink: 0 }} />
          <span style={{ fontSize: 11, fontWeight: 700, color: u.color }}>{u.label}</span>
        </div>
      )}
    </div>
  );
}
