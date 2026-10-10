import React, { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';
import AgendaCalendario from '../../components/freelance/AgendaCalendario.jsx';

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
  // Agenda (ya es tuyo: preasignado a confirmar, o ya confirmado/forzada)
  const [eventos, setEventos] = useState([]);
  const [loadingEventos, setLoadingEventos] = useState(true);

  // Ofertas (bolsa abierta -- todavía no es tuyo, te inscribís)
  const [ofertas, setOfertas] = useState([]);
  const [loadingOfertas, setLoadingOfertas] = useState(true);

  const [sel, setSel] = useState(null);
  const [accion, setAccion] = useState(null); // 'oferta' | 'confirmar' | 'cancelar' | null
  const [enviando, setEnviando] = useState(false);

  const cargarEventos = async () => {
    if (!supabaseReady) { setLoadingEventos(false); return; }
    setLoadingEventos(true);
    const { data, error } = await supabase.from('v_agenda_freelance').select('*').order('cita_inicio', { ascending: true });
    if (!error) setEventos(data || []);
    setLoadingEventos(false);
  };
  const cargarOfertas = async () => {
    if (!supabaseReady) { setLoadingOfertas(false); return; }
    setLoadingOfertas(true);
    const { data, error } = await supabase.from('v_publicaciones_para_freelance').select('*').order('fecha');
    if (!error) setOfertas(data || []);
    setLoadingOfertas(false);
  };
  useEffect(() => { cargarEventos(); cargarOfertas(); }, []);

  const futuros = eventos.filter(e => new Date(e.cita_inicio) >= new Date());
  const pasados = eventos.filter(e => new Date(e.cita_inicio) < new Date()).reverse();

  const porConfirmar = futuros.filter(e => e.estado === 'preasignado');
  const confirmados = futuros.filter(e => ESTADOS_ASIGNADO.includes(e.estado));

  const inscribirme = async o => {
    setEnviando(true);
    const { error } = await supabase.rpc('inscribirme_a_publicacion', { p_detalle: o.pedido_detalle_id });
    setEnviando(false);
    if (error) { toast.error(error.message); return; }
    toast.success('Inscripción confirmada');
    setSel(null); setAccion(null); cargarOfertas(); cargarEventos();
  };

  const confirmar = async e => {
    setEnviando(true);
    const { error } = await supabase.rpc('confirmar_mi_reservacion', { p_reservacion: e.id });
    setEnviando(false);
    if (error) { toast.error(error.message); return; }
    toast.success('Asistencia confirmada');
    setSel(null); setAccion(null); cargarEventos();
  };

  const cancelar = async e => {
    setEnviando(true);
    const { error } = await supabase.rpc('cancelar_mi_reservacion', { p_reservacion: e.id });
    setEnviando(false);
    if (error) { toast.error(error.message); return; }
    toast.success('Participación cancelada');
    setSel(null); setAccion(null); cargarEventos();
  };

  return (
    <div>
      <div className="section-eyebrow">Agenda</div>
      <h1 style={{ marginBottom: 20 }}>Mis eventos</h1>

      {(loadingEventos || loadingOfertas) && <p>Cargando…</p>}

      {/* En celular se apilan en orden (base mobile-first): Ofertas, Por
          confirmar, Confirmados. En escritorio, Ofertas queda en su propia
          columna y Por confirmar/Confirmados comparten la otra -- las tres
          visibles en una sola hoja, sin cambiar de pestaña. */}
      <div className="mis-eventos-cols" style={{ marginBottom: 24 }}>
        <div>
          <h3>Ofertas ({ofertas.length})</h3>
          {ofertas.length === 0 && (
            <p style={{ fontSize: 13, color: 'var(--muted)' }}>No hay ofertas nuevas por el momento.</p>
          )}
          <div style={{ display: 'grid', gap: 10, maxHeight: 520, overflowY: 'auto', paddingRight: 2 }}>
            {ofertas.map(o => (
              <OfertaCard key={o.pedido_detalle_id} o={o} onClick={() => { setSel(o); setAccion('oferta'); }} />
            ))}
          </div>
        </div>

        <div>
          <div style={{ marginBottom: 24 }}>
            <h3>Por confirmar ({porConfirmar.length})</h3>
            {porConfirmar.length === 0 && (
              <p style={{ fontSize: 13, color: 'var(--muted)' }}>No tenés eventos pendientes de confirmar.</p>
            )}
            <div style={{ display: 'grid', gap: 10, maxHeight: 240, overflowY: 'auto', paddingRight: 2 }}>
              {porConfirmar.map(e => (
                <EventoCard key={e.id} e={e} showUrgencia onClick={() => { setSel(e); setAccion('confirmar'); }} />
              ))}
            </div>
          </div>

          <div>
            <h3>Confirmados ({confirmados.length})</h3>
            {confirmados.length === 0 && (
              <p style={{ fontSize: 13, color: 'var(--muted)' }}>Sin eventos confirmados todavía.</p>
            )}
            <div style={{ display: 'grid', gap: 10, maxHeight: 240, overflowY: 'auto', paddingRight: 2 }}>
              {confirmados.map(e => (
                <EventoCard key={e.id} e={e} onClick={() => { setSel(e); setAccion('cancelar'); }} />
              ))}
            </div>
          </div>
        </div>
      </div>

      <div style={{ marginBottom: 32 }}>
        <AgendaCalendario eventos={eventos} />
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
          accion === 'oferta' ? (
            <>
              <button className="btn ghost" onClick={() => { setSel(null); setAccion(null); }} disabled={enviando}>Cerrar</button>
              <button className="btn green" onClick={() => inscribirme(sel)} disabled={enviando}>
                {enviando ? 'Inscribiendo…' : 'Inscribirme →'}
              </button>
            </>
          ) : accion === 'confirmar' ? (
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
        {sel && accion === 'oferta' && (
          <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
            <div><div className="label">Puesto</div><div>{sel.puesto}</div></div>
            <div><div className="label">Sitio</div><div>{sel.sitio}</div></div>
            {sel.cliente && <div><div className="label">Cliente</div><div>{sel.cliente}</div></div>}
            {sel.fecha && <div><div className="label">Fecha</div><div>{new Date(sel.fecha).toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}</div></div>}
            {sel.turno && <div><div className="label">Turno</div><div>{sel.turno} ({sel.hora_inicio || sel.turno_hora_inicio}–{sel.hora_fin || sel.turno_hora_fin})</div></div>}
            {sel.fase && <div><div className="label">Fase evento</div><div>{sel.fase}</div></div>}
            <div><div className="label">Cupo</div><div>{sel.cupo_ocupado} / {sel.cupo_total} inscritos</div></div>
            {sel.costo_unit && <div><div className="label">Pago</div><div style={{ color: 'var(--accent2)', fontWeight: 800, fontSize: 18 }}>${Number(sel.costo_unit).toLocaleString('es-MX')} MXN</div></div>}
            {sel.cierra_en && <div><div className="label">Cierra inscripciones</div><div>{new Date(sel.cierra_en).toLocaleString('es-MX')}</div></div>}
          </div>
        )}
        {sel && accion !== 'oferta' && (
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

function OfertaCard({ o, onClick }) {
  return (
    <div className="card" style={{ margin: 0, cursor: 'pointer' }} onClick={onClick}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
        <div>
          <div style={{ fontWeight: 800, fontSize: 14 }}>{o.puesto}</div>
          <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 4 }}>
            📍 {o.sitio} · {o.fecha ? new Date(o.fecha).toLocaleDateString('es-MX', { weekday: 'short', day: 'numeric', month: 'short' }) : 'Fecha por confirmar'}
          </div>
          {o.turno && <div style={{ fontSize: 12, color: 'var(--muted)' }}>🕐 {o.turno_hora_inicio}–{o.turno_hora_fin}</div>}
        </div>
        <Badge estado={(o.cupo_total - o.cupo_ocupado) > 3 ? 'activo' : 'pendiente'}>
          {o.cupo_ocupado}/{o.cupo_total}
        </Badge>
      </div>
      {o.costo_unit && <div style={{ marginTop: 8, fontSize: 12, color: 'var(--accent2)', fontWeight: 700 }}>
        ${Number(o.costo_unit).toLocaleString('es-MX')} MXN
      </div>}
    </div>
  );
}
