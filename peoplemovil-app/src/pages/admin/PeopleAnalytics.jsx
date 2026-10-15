import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import {
  ResponsiveContainer, BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend,
} from 'recharts';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import { useModuleAudit } from '../../lib/audit.js';

// ---------------------------------------------------------------------------
// Primitivos visuales propios de este módulo (a pedido del usuario 2026-10-14:
// "debe ser una copia" del look de otro dashboard interno del usuario -- IwolPark,
// tarjetas blancas con sombra suave, KPIs grandes en bold, pills de color, tabs
// horizontales subrayadas). Se definen AQUÍ, con el mismo nombre/API que los
// componentes compartidos de ui/ (KpiCard, Chip, Badge) que reemplazan, para no
// tocar esos archivos -- son usados por media app y hay otra sesión en paralelo
// modificando varias pantallas que los consumen (Semaforo.jsx, SitiosAsignacion.jsx,
// etc.); así el rediseño queda contenido a este módulo, cero riesgo de choque.
// ---------------------------------------------------------------------------
function KpiCard({ label, value, sub, color, onClick, drillLabel = 'Ver desglose →' }) {
  const clickable = typeof onClick === 'function';
  return (
    <div onClick={onClick} style={{
      background: '#fff', border: '1px solid #ECECF1', borderRadius: 16,
      padding: '16px 18px', boxShadow: '0 1px 2px rgba(20,20,43,.04)',
      cursor: clickable ? 'pointer' : 'default',
    }}>
      <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: '.05em', textTransform: 'uppercase', color: '#8E8E99' }}>{label}</div>
      <div style={{ fontSize: 28, fontWeight: 800, color: color || '#1C1C28', marginTop: 6, lineHeight: 1.1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{value}</div>
      {sub && <div style={{ fontSize: 11.5, color: '#9696A3', marginTop: 4 }}>{sub}</div>}
      {clickable && <div style={{ fontSize: 11, color: C.morado, fontWeight: 700, marginTop: 8 }}>{drillLabel}</div>}
    </div>
  );
}
const BADGE_COLORS = {
  activo: { bg: '#E7F7EE', fg: '#1E9E5A' }, vencido: { bg: '#FBEAEC', fg: '#D23B51' },
  pendiente: { bg: '#FDF2E0', fg: '#C8841A' }, proceso: { bg: '#EAF1FD', fg: '#2563C9' },
  inactivo: { bg: '#F1F1F4', fg: '#7A7A85' },
};
function Badge({ estado = 'inactivo', children }) {
  const c = BADGE_COLORS[estado] || BADGE_COLORS.inactivo;
  return <span style={{ display: 'inline-block', padding: '3px 10px', borderRadius: 999, fontSize: 11, fontWeight: 700, background: c.bg, color: c.fg, whiteSpace: 'nowrap' }}>{children}</span>;
}
function Chip({ active, onClick, children }) {
  return (
    <button type="button" onClick={onClick} style={{
      border: 'none', borderRadius: 999, padding: '6px 13px', fontSize: 12.5, fontWeight: active ? 700 : 500,
      cursor: 'pointer', whiteSpace: 'nowrap',
      background: active ? C.morado : '#F1F0F6', color: active ? '#fff' : '#53535F',
    }}>{children}</button>
  );
}

// ===========================================================================
// Réplica fiel (Fase 3) de los 9 tableros de referencia "Agile HR Analytics"
// (carpeta pEOPLEaNALITYCS, pedido del usuario 2026-10-14) -- mismo layout/
// combos (Año, Mes, Unidad de Negocio) y las mismas métricas, pero sobre los
// datos reales del tenant (Data Warehouse, Migraciones 058-061). Decisión
// confirmada con el usuario: datos reales, no los valores literales de las
// capturas de referencia; "Seniority"/"Generación" se omiten por no existir
// como dato real (mismo criterio que la Fase 1, Migración 058).
//
// Capacitación/Vacaciones/Reclutamiento (Fase 1/2, sin equivalente directo
// en las 9 capturas de referencia) se conservan como módulos aparte al final
// del submenú -- "no se tira nada" (confirmado con el usuario).
// ===========================================================================

const C = {
  morado: '#7B5EA7', azul: '#0A66C2', ambar: '#D9A441', verde: '#2FA86B',
  rosa: '#C85C8E', gris: '#9A9AA2', moradoClaro: '#C9B8E8',
  naranja: '#E8900C', rojo: '#D23B51',
};
const SERIE = [C.morado, C.azul, C.ambar, C.verde, C.rosa, C.gris, C.moradoClaro];

const GRANOS = [
  { key: 'mes', label: 'Mes' },
  { key: 'trimestre', label: 'Trimestre' },
  { key: 'anio', label: 'Año' },
];

const PERM_TIPO_LABEL = {
  incapacidad_enfermedad_general: 'Incapacidad — Enfermedad general',
  incapacidad_maternidad: 'Incapacidad — Maternidad',
  incapacidad_riesgo_trabajo: 'Incapacidad — Riesgo de trabajo',
  permiso_con_goce: 'Permiso con goce de sueldo',
  permiso_sin_goce: 'Permiso sin goce de sueldo',
  otro: 'Otro',
};

const MESES = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

const fmt = n => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 1 });
const fmtPct = n => (n == null || Number.isNaN(n) ? '—' : Number(n).toFixed(1) + '%');
const fmt$ = n => '$' + Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 0 });

async function fetchVista(vista, opts = {}) {
  if (!supabaseReady) return [];
  let q = supabase.from(vista).select('*');
  if (opts.order) q = q.order(opts.order, { ascending: opts.asc ?? true });
  q = q.limit(opts.limit || 1000);
  const { data, error } = await q;
  if (error) { console.warn('[PeopleAnalytics]', vista, error.message); return []; }
  return data || [];
}

// ---------------------------------------------------------------------------
// Fecha/corte helpers -- el filtro Año/Mes reconstruye el estado real a esa
// fecha (activoACorte usa fecha_alta/fecha_baja reales, no un snapshot
// guardado), y antigüedad/edad se recalculan contra la fecha de corte.
// ---------------------------------------------------------------------------
function parseFecha(s) { return s ? new Date(s + 'T00:00:00') : null; }
function fechaCorte(anio, mes) {
  if (anio === 'todos') return new Date();
  const y = Number(anio);
  if (mes === 'todos') return new Date(y, 11, 31);
  return new Date(y, Number(mes), 0);
}
function activoACorte(emp, corte) {
  const alta = parseFecha(emp.fecha_alta);
  if (!alta || alta > corte) return false;
  const baja = parseFecha(emp.fecha_baja);
  if (baja && baja <= corte) return false;
  return true;
}
function enRango(fechaStr, anio, mes) {
  const d = parseFecha(fechaStr);
  if (!d) return false;
  if (anio !== 'todos' && d.getFullYear() !== Number(anio)) return false;
  if (mes !== 'todos' && (d.getMonth() + 1) !== Number(mes)) return false;
  return true;
}
function aniosEntre(desde, hasta) {
  if (!desde || !hasta) return null;
  return (hasta - desde) / (1000 * 60 * 60 * 24 * 365.25);
}
function rangoEdad(edad) {
  if (edad == null) return 'Sin dato';
  if (edad < 20) return '20-';
  if (edad < 30) return '20-30';
  if (edad < 40) return '30-40';
  if (edad < 50) return '40-50';
  if (edad < 60) return '50-60';
  return '60+';
}
function rangoAntiguedad(anios) {
  if (anios == null) return 'Sin dato';
  if (anios < 3) return '1-3 años';
  if (anios < 5) return '3-5 años';
  if (anios < 10) return '5-10 años';
  return '10+ años';
}

// ===========================================================================
// Shell: carga de datos compartida + submenú + barra de filtros
// ===========================================================================
const TABS = [
  { grupo: 'Réplica de referencia', items: [
    { key: 'resumen', label: 'Resumen', icon: '🧭' },
    { key: 'diversidad', label: 'Diversidad', icon: '🧑‍🤝‍🧑' },
    { key: 'unidad', label: 'Unidad de Negocio', icon: '🏢' },
    { key: 'desempeno', label: 'Desempeño', icon: '🎯' },
    { key: 'ausentismo', label: 'Ausentismo', icon: '🩺' },
    { key: 'bajas', label: 'Análisis de Bajas', icon: '📤' },
    { key: 'rotacion', label: 'Análisis de Rotación', icon: '🔄' },
    { key: 'prediccion', label: 'Predicción de Rotación', icon: '📈' },
    { key: 'prediccion_emp', label: 'Predicción — Empleado', icon: '🧑‍💼' },
  ]},
  { grupo: 'Otros módulos', items: [
    { key: 'capacitacion', label: 'Capacitación', icon: '🎓' },
    { key: 'vacaciones', label: 'Vacaciones', icon: '🏖️' },
    { key: 'reclutamiento', label: 'Reclutamiento', icon: '🧲' },
  ]},
];

export default function PeopleAnalytics() {
  useModuleAudit('people_analytics');
  const [tab, setTab] = useState('resumen');
  const [anio, setAnio] = useState('todos');
  const [mes, setMes] = useState('todos');
  const [unidad, setUnidad] = useState('todas');
  const [loading, setLoading] = useState(true);
  const [D, setD] = useState(null);
  const [actualizadoEn, setActualizadoEn] = useState(null);

  async function cargar() {
    setLoading(true);
    const [empleados, puestos, movimientos, evaluaciones, capacitaciones, vacaciones, permisos, riesgo] = await Promise.all([
      fetchVista('v_empleados_detalle', { limit: 5000 }),
      fetchVista('dw_dim_puesto', { limit: 1000 }),
      fetchVista('dw_hecho_movimiento_empleado', { limit: 5000 }),
      fetchVista('dw_hecho_evaluacion_desempeno', { limit: 5000 }),
      fetchVista('dw_hecho_capacitacion', { limit: 5000 }),
      fetchVista('dw_hecho_vacaciones', { limit: 5000 }),
      fetchVista('dw_hecho_permisos', { limit: 5000 }),
      fetchVista('v_riesgo_rotacion_empleado', { limit: 5000 }),
    ]);
    const empleadoMap = new Map(empleados.map(e => [e.id, e]));
    const unidades = [...new Set(empleados.map(e => e.unidad_negocio).filter(Boolean))].sort();
    const anios = new Set();
    for (const e of empleados) {
      if (e.fecha_alta) anios.add(new Date(e.fecha_alta).getFullYear());
      if (e.fecha_baja) anios.add(new Date(e.fecha_baja).getFullYear());
    }
    for (const m of movimientos) if (m.fecha) anios.add(new Date(m.fecha).getFullYear());
    const aniosDisponibles = [...anios].sort();
    setD({ empleados, puestos, movimientos, evaluaciones, capacitaciones, vacaciones, permisos, riesgo, empleadoMap, unidades, aniosDisponibles });
    setActualizadoEn(new Date());
    setLoading(false);
  }
  useEffect(() => { cargar(); /* eslint-disable-next-line */ }, []);

  const filtros = { anio, mes, unidad };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', flexWrap: 'wrap', gap: 10, marginBottom: 4 }}>
        <div>
          <div className="section-eyebrow">Analítica</div>
          <h1 style={{ margin: 0 }}>People Analytics</h1>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          {actualizadoEn && <span style={{ fontSize: 11.5, color: '#9696A3' }}>Actualizado: {actualizadoEn.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}</span>}
          <button type="button" onClick={cargar} disabled={loading} style={{
            display: 'flex', alignItems: 'center', gap: 6, border: 'none', borderRadius: 10, padding: '8px 14px',
            background: C.morado, color: '#fff', fontWeight: 700, fontSize: 12.5, cursor: loading ? 'default' : 'pointer', opacity: loading ? .6 : 1,
          }}>↻ Actualizar</button>
        </div>
      </div>
      <p style={{ color: 'var(--muted)', marginBottom: 16, fontSize: 12.5 }}>
        Réplica de los tableros de referencia sobre datos reales del tenant (Data Warehouse, Migraciones 058-061).
      </p>

      {loading || !D ? (
        <div style={{ background: '#fff', border: '1px solid #ECECF1', borderRadius: 16, padding: 20 }}>
          <p style={{ fontSize: 12, color: 'var(--muted)' }}>Cargando datos del Data Warehouse…</p>
        </div>
      ) : (
        <>
          <div style={{ background: '#fff', border: '1px solid #ECECF1', borderRadius: 16, padding: '6px 10px', marginBottom: 16, boxShadow: '0 1px 2px rgba(20,20,43,.04)' }}>
            {TABS.map((g, gi) => (
              <div key={g.grupo} style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', borderTop: gi > 0 ? '1px solid #F1F0F6' : 'none', paddingTop: gi > 0 ? 4 : 0, marginTop: gi > 0 ? 4 : 0 }}>
                {g.items.map(it => (
                  <button key={it.key} type="button" onClick={() => setTab(it.key)}
                    style={{
                      display: 'flex', alignItems: 'center', gap: 6, border: 'none', background: 'none', cursor: 'pointer',
                      padding: '10px 12px', fontSize: 12.5, whiteSpace: 'nowrap',
                      color: tab === it.key ? C.morado : '#53535F', fontWeight: tab === it.key ? 700 : 500,
                      borderBottom: tab === it.key ? `2px solid ${C.morado}` : '2px solid transparent',
                    }}>
                    <span aria-hidden="true">{it.icon}</span>{it.label}
                  </button>
                ))}
              </div>
            ))}
          </div>

          <FiltroBarra D={D} anio={anio} setAnio={setAnio} mes={mes} setMes={setMes} unidad={unidad} setUnidad={setUnidad} />
          {tab === 'resumen' && <DashResumen D={D} f={filtros} />}
          {tab === 'diversidad' && <DashDiversidad D={D} f={filtros} />}
          {tab === 'unidad' && <DashUnidadNegocio D={D} f={filtros} />}
          {tab === 'desempeno' && <DashDesempeno D={D} f={filtros} />}
          {tab === 'ausentismo' && <DashAusentismo D={D} f={filtros} />}
          {tab === 'bajas' && <DashBajas D={D} f={filtros} />}
          {tab === 'rotacion' && <DashRotacion D={D} f={filtros} />}
          {tab === 'prediccion' && <DashPrediccion D={D} f={filtros} />}
          {tab === 'prediccion_emp' && <DashPrediccionEmpleado D={D} />}
          {tab === 'capacitacion' && <TabCapacitacion />}
          {tab === 'vacaciones' && <TabVacaciones />}
          {tab === 'reclutamiento' && <TabReclutamiento />}
        </>
      )}
    </div>
  );
}

function FiltroBarra({ D, anio, setAnio, mes, setMes, unidad, setUnidad }) {
  return (
    <div style={{ background: '#fff', border: '1px solid #ECECF1', borderRadius: 16, padding: '12px 16px', marginBottom: 16, boxShadow: '0 1px 2px rgba(20,20,43,.04)' }}>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 16, alignItems: 'center' }}>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          <Chip active={anio === 'todos'} onClick={() => { setAnio('todos'); setMes('todos'); }}>Todos</Chip>
          {D.aniosDisponibles.map(a => <Chip key={a} active={anio === String(a)} onClick={() => setAnio(String(a))}>{a}</Chip>)}
        </div>
        <div style={{ width: 1, alignSelf: 'stretch', background: '#ECECF1' }} />
        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
          <Chip active={mes === 'todos'} onClick={() => setMes('todos')}>Todo el año</Chip>
          {MESES.map((m, i) => <Chip key={m} active={mes === String(i + 1)} onClick={() => setMes(String(i + 1))}>{m}</Chip>)}
        </div>
        <div style={{ width: 1, alignSelf: 'stretch', background: '#ECECF1' }} />
        <div>
          <select className="field" style={{ minWidth: 200, borderRadius: 10 }} value={unidad} onChange={e => setUnidad(e.target.value)}>
            <option value="todas">Unidad de Negocio: Todas</option>
            {D.unidades.map(u => <option key={u} value={u}>{u}</option>)}
          </select>
        </div>
      </div>
    </div>
  );
}

function Panel({ titulo, subtitulo, accion, children }) {
  return (
    <div style={{ background: '#fff', border: '1px solid #ECECF1', borderRadius: 16, padding: '18px 20px', marginBottom: 16, boxShadow: '0 1px 2px rgba(20,20,43,.04)' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14, gap: 12 }}>
        <div>
          <div style={{ fontWeight: 700, fontSize: 14.5, color: '#1C1C28' }}>{titulo}</div>
          {subtitulo && <div style={{ fontSize: 11.5, color: '#9696A3', marginTop: 2 }}>{subtitulo}</div>}
        </div>
        {accion}
      </div>
      {children}
    </div>
  );
}
function Vacio({ cargando, texto }) {
  return <div style={{ padding: 32, textAlign: 'center', color: '#9696A3', fontSize: 12 }}>
    {cargando ? 'Cargando…' : (texto || 'Sin datos para este corte de Año/Mes/Unidad de Negocio.')}
  </div>;
}
function GranoSelector({ grano, setGrano }) {
  return (
    <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
      {GRANOS.map(g => (
        <Chip key={g.key} active={grano === g.key} onClick={() => setGrano(g.key)}>{g.label}</Chip>
      ))}
    </div>
  );
}

// Empleados activos a la fecha de corte del filtro Año/Mes, filtrados además
// por Unidad de Negocio -- reconstrucción real a partir de fecha_alta/
// fecha_baja, no un snapshot guardado.
function empleadosFiltrados(D, f) {
  const corte = fechaCorte(f.anio, f.mes);
  return D.empleados.filter(e => activoACorte(e, corte) && (f.unidad === 'todas' || e.unidad_negocio === f.unidad))
    .map(e => {
      const edad = aniosEntre(parseFecha(e.fecha_nacimiento), corte);
      const antiguedad = aniosEntre(parseFecha(e.fecha_alta), corte);
      return { ...e, edadCorte: edad, antiguedadCorte: antiguedad, rangoEdadCorte: rangoEdad(edad), rangoAntiguedadCorte: rangoAntiguedad(antiguedad) };
    });
}
function unidadDe(D, empleadoId) { return D.empleadoMap.get(empleadoId)?.unidad_negocio; }
function filtraPorUnidadYFecha(D, filas, f, campoFecha = 'fecha') {
  return filas.filter(r =>
    (f.unidad === 'todas' || unidadDe(D, r.empleado_id) === f.unidad) &&
    enRango(r[campoFecha], f.anio, f.mes)
  );
}

// ===========================================================================
// 1. Resumen (≈ Summary Dashboard)
// ===========================================================================
function DashResumen({ D, f }) {
  const activos = useMemo(() => empleadosFiltrados(D, f), [D, f.anio, f.mes, f.unidad]);
  const altas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'alta'), f), [D, f.anio, f.mes, f.unidad]);
  const bajas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'baja'), f), [D, f.anio, f.mes, f.unidad]);
  const vacTomadas = useMemo(() => filtraPorUnidadYFecha(D, D.vacaciones.filter(v => v.estado !== 'cancelada'), f, 'fecha'), [D, f.anio, f.mes, f.unidad]);
  const permTomados = useMemo(() => filtraPorUnidadYFecha(D, D.permisos.filter(p => p.estado !== 'cancelado'), f, 'fecha'), [D, f.anio, f.mes, f.unidad]);

  const antiguedadProm = activos.length ? activos.reduce((s, e) => s + (e.antiguedadCorte || 0), 0) / activos.length : null;
  const edadProm = activos.length ? activos.reduce((s, e) => s + (e.edadCorte || 0), 0) / activos.length : null;
  const femPct = activos.length ? (activos.filter(e => e.sexo === 'F').length / activos.length) * 100 : null;
  const diasVacTomados = vacTomadas.reduce((s, v) => s + Number(v.dias || 0), 0);
  const diasPermTomados = permTomados.reduce((s, p) => s + Number(p.dias || 0), 0);

  const porContrato = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.regimen_pago || 'Sin dato'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([tipo, n]) => ({ tipo, n }));
  }, [activos]);

  const porUnidad = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.unidad_negocio || 'Sin unidad'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([unidad, headcount]) => ({ unidad, headcount })).sort((a, b) => b.headcount - a.headcount).slice(0, 12);
  }, [activos]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Headcount" value={fmt(activos.length)} sub="a la fecha de corte" />
        <KpiCard label="Contrataciones (altas)" value={fmt(altas.length)} color={C.verde} />
        <KpiCard label="Bajas" value={fmt(bajas.length)} color={C.rosa} />
        <KpiCard label="% Mujeres" value={fmtPct(femPct)} />
        <KpiCard label="Antigüedad promedio" value={antiguedadProm == null ? '—' : fmt(antiguedadProm) + ' años'} color={C.azul} />
        <KpiCard label="Edad promedio" value={edadProm == null ? '—' : fmt(edadProm) + ' años'} color={C.morado} />
        <KpiCard label="Días de vacaciones tomados" value={fmt(diasVacTomados)} />
        <KpiCard label="Días de ausentismo tomados" value={fmt(diasPermTomados)} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <Panel titulo="Headcount por tipo de contrato">
          {porContrato.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={porContrato} dataKey="n" nameKey="tipo" outerRadius={85} label={({ tipo, n }) => `${tipo}: ${n}`}>
                  {porContrato.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </Panel>
        <Panel titulo="Headcount por unidad de negocio">
          {porUnidad.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={porUnidad} layout="vertical" margin={{ left: 24 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" allowDecimals={false} />
                <YAxis type="category" dataKey="unidad" width={130} tick={{ fontSize: 11 }} />
                <Tooltip />
                <Bar dataKey="headcount" fill={C.morado} radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>
      </div>
    </>
  );
}

// ===========================================================================
// 2. Diversidad
// ===========================================================================
function DashDiversidad({ D, f }) {
  const activos = useMemo(() => empleadosFiltrados(D, f), [D, f.anio, f.mes, f.unidad]);
  const total = activos.length;
  const porSexo = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.sexo || 'Sin dato'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([sexo, n]) => ({ sexo, n }));
  }, [activos]);
  const porEdad = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.rangoEdadCorte; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([rango, n]) => ({ rango, n }));
  }, [activos]);
  const porUnidadSexo = useMemo(() => {
    const m = new Map();
    for (const e of activos) {
      const k = e.unidad_negocio || 'Sin unidad';
      if (!m.has(k)) m.set(k, { unidad: k, F: 0, M: 0, X: 0 });
      const row = m.get(k);
      row[e.sexo || 'X'] = (row[e.sexo || 'X'] || 0) + 1;
    }
    return [...m.values()].sort((a, b) => (b.F + b.M + b.X) - (a.F + a.M + a.X)).slice(0, 12);
  }, [activos]);

  const femPct = total ? ((porSexo.find(s => s.sexo === 'F')?.n || 0) / total) * 100 : null;
  const malePct = total ? ((porSexo.find(s => s.sexo === 'M')?.n || 0) / total) * 100 : null;

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Headcount" value={fmt(total)} />
        <KpiCard label="% Mujeres" value={fmtPct(femPct)} color={C.rosa} />
        <KpiCard label="% Hombres" value={fmtPct(malePct)} color={C.azul} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <Panel titulo="Headcount por género">
          {total === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={240}>
              <PieChart>
                <Pie data={porSexo} dataKey="n" nameKey="sexo" outerRadius={90} label={({ sexo, n }) => `${sexo}: ${n}`}>
                  {porSexo.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </Panel>
        <Panel titulo="Headcount por rango de edad">
          {total === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={porEdad}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="rango" tick={{ fontSize: 11 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="n" fill={C.morado} radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>
      </div>
      <Panel titulo="Diversidad de género por unidad de negocio">
        {porUnidadSexo.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={Math.max(220, porUnidadSexo.length * 32)}>
            <BarChart data={porUnidadSexo} layout="vertical" margin={{ left: 24 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" allowDecimals={false} />
              <YAxis type="category" dataKey="unidad" width={140} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              <Bar dataKey="F" name="Mujeres" stackId="g" fill={C.rosa} />
              <Bar dataKey="M" name="Hombres" stackId="g" fill={C.azul} />
              <Bar dataKey="X" name="Otro/sin dato" stackId="g" fill={C.gris} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

// ===========================================================================
// 3. Unidad de Negocio (≈ Business Unit) -- usa el combo de Unidad de Negocio
//    de la barra de filtros como selector principal, igual que la referencia.
// ===========================================================================
function DashUnidadNegocio({ D, f }) {
  const activos = useMemo(() => empleadosFiltrados(D, f), [D, f.anio, f.mes, f.unidad]);
  const altas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'alta'), f), [D, f.anio, f.mes, f.unidad]);
  const bajas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'baja'), f), [D, f.anio, f.mes, f.unidad]);

  const porTipoEmpleado = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.tipo_empleado || 'Sin dato'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([tipo, n]) => ({ tipo, n }));
  }, [activos]);

  const porContratoSexo = useMemo(() => {
    const m = new Map();
    for (const e of activos) {
      const k = e.regimen_pago || 'Sin dato';
      if (!m.has(k)) m.set(k, { contrato: k, F: 0, M: 0, X: 0 });
      const row = m.get(k);
      row[e.sexo || 'X'] = (row[e.sexo || 'X'] || 0) + 1;
    }
    return [...m.values()];
  }, [activos]);

  const porAntiguedad = useMemo(() => {
    const m = new Map();
    for (const e of activos) { const k = e.rangoAntiguedadCorte; m.set(k, (m.get(k) || 0) + 1); }
    const orden = ['1-3 años', '3-5 años', '5-10 años', '10+ años', 'Sin dato'];
    return orden.filter(k => m.has(k)).map(rango => ({ rango, n: m.get(rango) }));
  }, [activos]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label={`Headcount${f.unidad !== 'todas' ? ' · ' + f.unidad : ''}`} value={fmt(activos.length)} />
        <KpiCard label="Altas" value={fmt(altas.length)} color={C.verde} />
        <KpiCard label="Bajas" value={fmt(bajas.length)} color={C.rosa} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <Panel titulo="Headcount por tipo de empleado (freelance/staff)">
          {porTipoEmpleado.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={porTipoEmpleado} dataKey="n" nameKey="tipo" outerRadius={85} label={({ tipo, n }) => `${tipo}: ${n}`}>
                  {porTipoEmpleado.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </Panel>
        <Panel titulo="Headcount por rango de antigüedad">
          {porAntiguedad.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={porAntiguedad}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="rango" tick={{ fontSize: 11 }} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="n" fill={C.azul} radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>
      </div>
      <Panel titulo="Distribución por tipo de contrato y género">
        {porContratoSexo.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={Math.max(180, porContratoSexo.length * 40)}>
            <BarChart data={porContratoSexo} layout="vertical" margin={{ left: 40 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" allowDecimals={false} />
              <YAxis type="category" dataKey="contrato" width={120} tick={{ fontSize: 11 }} />
              <Tooltip />
              <Legend />
              <Bar dataKey="F" name="Mujeres" stackId="g" fill={C.rosa} />
              <Bar dataKey="M" name="Hombres" stackId="g" fill={C.azul} />
              <Bar dataKey="X" name="Otro/sin dato" stackId="g" fill={C.gris} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

// ===========================================================================
// 4. Calificación de Desempeño
// ===========================================================================
function DashDesempeno({ D, f }) {
  const evals = useMemo(() => filtraPorUnidadYFecha(D, D.evaluaciones, f), [D, f.anio, f.mes, f.unidad]);
  const califProm = evals.length ? evals.reduce((s, e) => s + Number(e.calificacion || 0), 0) / evals.length : null;
  const conBuena = evals.filter(e => Number(e.calificacion) >= 7).length;

  const distribucion = useMemo(() => {
    const buckets = [{ rango: '0-4', min: 0, max: 4, n: 0 }, { rango: '4-6', min: 4, max: 6, n: 0 },
      { rango: '6-8', min: 6, max: 8, n: 0 }, { rango: '8-10', min: 8, max: 10.01, n: 0 }];
    for (const e of evals) {
      const c = Number(e.calificacion);
      const b = buckets.find(b => c >= b.min && c < b.max);
      if (b) b.n++;
    }
    return buckets;
  }, [evals]);

  const porUnidad = useMemo(() => {
    const m = new Map();
    for (const e of evals) {
      const u = unidadDe(D, e.empleado_id) || 'Sin unidad';
      if (!m.has(u)) m.set(u, { unidad: u, suma: 0, n: 0 });
      const row = m.get(u); row.suma += Number(e.calificacion || 0); row.n++;
    }
    return [...m.values()].map(r => ({ unidad: r.unidad, promedio: round1(r.suma / r.n) })).sort((a, b) => b.promedio - a.promedio);
  }, [evals, D]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Evaluaciones en el periodo" value={fmt(evals.length)} />
        <KpiCard label="Calificación promedio (0-10)" value={califProm == null ? '—' : fmt(califProm)} color={C.morado} />
        <KpiCard label="% con calificación ≥ 7" value={evals.length ? fmtPct((conBuena / evals.length) * 100) : '—'} color={C.verde} />
      </div>
      <Panel titulo="Distribución de calificaciones">
        {evals.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={distribucion}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="rango" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="n" fill={C.azul} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
      <Panel titulo="Calificación promedio por unidad de negocio">
        {porUnidad.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={Math.max(180, porUnidad.length * 30)}>
            <BarChart data={porUnidad} layout="vertical" margin={{ left: 60 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" domain={[0, 10]} />
              <YAxis type="category" dataKey="unidad" width={160} tick={{ fontSize: 11 }} />
              <Tooltip />
              <Bar dataKey="promedio" fill={C.morado} radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}
function round1(n) { return Math.round(n * 10) / 10; }

// ===========================================================================
// 5. Ausentismo
// ===========================================================================
function DashAusentismo({ D, f }) {
  const permisos = useMemo(() => filtraPorUnidadYFecha(D, D.permisos.filter(p => p.estado !== 'cancelado'), f), [D, f.anio, f.mes, f.unidad]);
  const diasTotales = permisos.reduce((s, p) => s + Number(p.dias || 0), 0);
  const diasIncapacidad = permisos.filter(p => (p.tipo || '').startsWith('incapacidad')).reduce((s, p) => s + Number(p.dias || 0), 0);
  const diasSinGoce = permisos.filter(p => !p.goce_sueldo).reduce((s, p) => s + Number(p.dias || 0), 0);
  const empleadosAfectados = new Set(permisos.map(p => p.empleado_id)).size;

  const porTipo = useMemo(() => {
    const m = new Map();
    for (const p of permisos) { const k = PERM_TIPO_LABEL[p.tipo] || p.tipo || 'Sin tipo'; m.set(k, (m.get(k) || 0) + Number(p.dias || 0)); }
    return [...m.entries()].map(([tipo, dias]) => ({ tipo, dias })).sort((a, b) => b.dias - a.dias);
  }, [permisos]);

  const porUnidad = useMemo(() => {
    const m = new Map();
    for (const p of permisos) {
      const u = unidadDe(D, p.empleado_id) || 'Sin unidad';
      m.set(u, (m.get(u) || 0) + Number(p.dias || 0));
    }
    return [...m.entries()].map(([unidad, dias]) => ({ unidad, dias })).sort((a, b) => b.dias - a.dias).slice(0, 12);
  }, [permisos, D]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Días de ausentismo" value={fmt(diasTotales)} color={C.rosa} />
        <KpiCard label="Días por incapacidad" value={fmt(diasIncapacidad)} color={C.ambar} />
        <KpiCard label="Días sin goce de sueldo" value={fmt(diasSinGoce)} />
        <KpiCard label="Empleados afectados" value={fmt(empleadosAfectados)} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <Panel titulo="Días por tipo de permiso/incapacidad">
          {porTipo.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={Math.max(180, porTipo.length * 30)}>
              <BarChart data={porTipo} layout="vertical" margin={{ left: 60 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" allowDecimals={false} />
                <YAxis type="category" dataKey="tipo" width={180} tick={{ fontSize: 11 }} />
                <Tooltip />
                <Bar dataKey="dias" fill={C.morado} radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>
        <Panel titulo="Días de ausentismo por unidad de negocio">
          {porUnidad.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={Math.max(180, porUnidad.length * 30)}>
              <BarChart data={porUnidad} layout="vertical" margin={{ left: 60 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" allowDecimals={false} />
                <YAxis type="category" dataKey="unidad" width={140} tick={{ fontSize: 11 }} />
                <Tooltip />
                <Bar dataKey="dias" fill={C.rosa} radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </Panel>
      </div>
    </>
  );
}

// ===========================================================================
// 6. Análisis de Bajas (≈ Termination Analysis)
// ===========================================================================
function DashBajas({ D, f }) {
  const bajas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'baja'), f), [D, f.anio, f.mes, f.unidad]);

  const porMotivo = useMemo(() => {
    const m = new Map();
    for (const b of bajas) { const k = b.motivo_baja || 'Sin motivo capturado'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([motivo, n]) => ({ motivo, n })).sort((a, b) => b.n - a.n).slice(0, 12);
  }, [bajas]);

  const porTipo = useMemo(() => {
    const m = new Map([['Voluntaria', 0], ['Involuntaria', 0], ['Sin clasificar', 0]]);
    for (const b of bajas) {
      const k = b.tipo_baja === 'voluntaria' ? 'Voluntaria' : b.tipo_baja === 'involuntaria' ? 'Involuntaria' : 'Sin clasificar';
      m.set(k, m.get(k) + 1);
    }
    return [...m.entries()].map(([tipo, n]) => ({ tipo, n })).filter(r => r.n > 0);
  }, [bajas]);

  const porGenero = useMemo(() => {
    const m = new Map();
    for (const b of bajas) { const e = D.empleadoMap.get(b.empleado_id); const k = e?.sexo || 'Sin dato'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([sexo, n]) => ({ sexo, n }));
  }, [bajas, D]);

  const porUnidadTipo = useMemo(() => {
    const m = new Map();
    for (const b of bajas) {
      const u = unidadDe(D, b.empleado_id) || 'Sin unidad';
      if (!m.has(u)) m.set(u, { unidad: u, Voluntaria: 0, Involuntaria: 0, 'Sin clasificar': 0 });
      const row = m.get(u);
      const k = b.tipo_baja === 'voluntaria' ? 'Voluntaria' : b.tipo_baja === 'involuntaria' ? 'Involuntaria' : 'Sin clasificar';
      row[k]++;
    }
    return [...m.values()].sort((a, b) => (b.Voluntaria + b.Involuntaria + b['Sin clasificar']) - (a.Voluntaria + a.Involuntaria + a['Sin clasificar'])).slice(0, 12);
  }, [bajas, D]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Bajas en el periodo" value={fmt(bajas.length)} color={C.rosa} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <Panel titulo="Bajas por tipo (voluntaria/involuntaria)">
          {porTipo.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={porTipo} dataKey="n" nameKey="tipo" outerRadius={85} label={({ tipo, n }) => `${tipo}: ${n}`}>
                  {porTipo.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </Panel>
        <Panel titulo="Bajas por género">
          {porGenero.length === 0 ? <Vacio /> : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={porGenero} dataKey="n" nameKey="sexo" outerRadius={85} label={({ sexo, n }) => `${sexo}: ${n}`}>
                  {porGenero.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          )}
        </Panel>
      </div>
      <Panel titulo="Bajas por motivo (texto libre capturado en el expediente)">
        {porMotivo.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={Math.max(180, porMotivo.length * 28)}>
            <BarChart data={porMotivo} layout="vertical" margin={{ left: 40 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" allowDecimals={false} />
              <YAxis type="category" dataKey="motivo" width={180} tick={{ fontSize: 11 }} />
              <Tooltip />
              <Bar dataKey="n" fill={C.rosa} radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
      <Panel titulo="Bajas por unidad de negocio y tipo (sustituye el diagrama Sankey de la referencia -- recharts no trae Sankey nativo)">
        {porUnidadTipo.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={Math.max(200, porUnidadTipo.length * 32)}>
            <BarChart data={porUnidadTipo} layout="vertical" margin={{ left: 24 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" allowDecimals={false} />
              <YAxis type="category" dataKey="unidad" width={140} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              <Bar dataKey="Voluntaria" stackId="t" fill={C.ambar} />
              <Bar dataKey="Involuntaria" stackId="t" fill={C.rosa} />
              <Bar dataKey="Sin clasificar" stackId="t" fill={C.gris} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

// ===========================================================================
// 7. Análisis de Rotación (≈ Attrition Analysis)
// ===========================================================================
function DashRotacion({ D, f }) {
  const activos = useMemo(() => empleadosFiltrados(D, f), [D, f.anio, f.mes, f.unidad]);
  const bajas = useMemo(() => filtraPorUnidadYFecha(D, D.movimientos.filter(m => m.tipo_movimiento === 'baja'), f), [D, f.anio, f.mes, f.unidad]);
  const vol = bajas.filter(b => b.tipo_baja === 'voluntaria').length;
  const invol = bajas.filter(b => b.tipo_baja === 'involuntaria').length;
  const base = activos.length + bajas.length;
  const tasaGeneral = base > 0 ? (bajas.length / base) * 100 : null;
  const tasaVol = base > 0 ? (vol / base) * 100 : null;
  const tasaInvol = base > 0 ? (invol / base) * 100 : null;

  const porAntiguedad = useMemo(() => {
    const m = new Map();
    for (const b of bajas) {
      const e = D.empleadoMap.get(b.empleado_id);
      const anios = aniosEntre(parseFecha(e?.fecha_alta), parseFecha(b.fecha) || new Date());
      const k = rangoAntiguedad(anios);
      if (!m.has(k)) m.set(k, { rango: k, Voluntaria: 0, Involuntaria: 0 });
      const row = m.get(k);
      if (b.tipo_baja === 'voluntaria') row.Voluntaria++; else if (b.tipo_baja === 'involuntaria') row.Involuntaria++;
    }
    const orden = ['1-3 años', '3-5 años', '5-10 años', '10+ años', 'Sin dato'];
    return orden.filter(k => m.has(k)).map(k => m.get(k));
  }, [bajas, D]);

  return (
    <>
      <div className="kpi-grid">
        <KpiCard label="Tasa de rotación general" value={fmtPct(tasaGeneral)} color={C.morado} />
        <KpiCard label="Rotación voluntaria" value={fmtPct(tasaVol)} color={C.ambar} />
        <KpiCard label="Rotación involuntaria" value={fmtPct(tasaInvol)} color={C.rosa} />
        <KpiCard label="Bajas en el periodo" value={fmt(bajas.length)} />
      </div>
      <Panel titulo="Bajas voluntarias vs. involuntarias por rango de antigüedad">
        {porAntiguedad.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={porAntiguedad}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="rango" tick={{ fontSize: 11 }} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Legend />
              <Bar dataKey="Voluntaria" fill={C.ambar} radius={[4, 4, 0, 0]} />
              <Bar dataKey="Involuntaria" fill={C.rosa} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

// ===========================================================================
// 8. Predicción de Rotación (≈ Attrition Prediction, tabla) -- score
//    heurístico ponderado (NO es un modelo de Machine Learning entrenado),
//    pesos editables en Configuración → tp_parametros_globales.
// ===========================================================================
function DashPrediccion({ D, f }) {
  const [minRiesgo, setMinRiesgo] = useState(0);
  const filas = useMemo(() => {
    return D.riesgo
      .filter(r => f.unidad === 'todas' || r.unidad_negocio === f.unidad)
      .filter(r => Number(r.riesgo_pct || 0) >= minRiesgo)
      .sort((a, b) => Number(b.riesgo_pct || 0) - Number(a.riesgo_pct || 0));
  }, [D, f.unidad, minRiesgo]);

  return (
    <>
      <div style={{ background: '#FDF2E0', border: '1px solid #F3DFB0', borderRadius: 14, padding: '12px 16px', marginBottom: 16, fontSize: 12, color: '#7A5A14' }}>
        ⚠️ Esto <strong>no es un modelo de Machine Learning entrenado</strong> -- es un score heurístico transparente
        (0-100%), combinación ponderada de 5 factores reales (antigüedad, ausentismo, desempeño, capacitación,
        compensación relativa al puesto). Pesos editables en <a href="/admin/config" style={{ color: '#7A5A14', fontWeight: 700 }}>Configuración</a>.
      </div>
      <div className="kpi-grid">
        <KpiCard label="Empleados activos evaluados" value={fmt(D.riesgo.length)} />
        <KpiCard label="Riesgo promedio" value={fmtPct(D.riesgo.length ? D.riesgo.reduce((s, r) => s + Number(r.riesgo_pct || 0), 0) / D.riesgo.length : null)} color={C.morado} />
      </div>
      <Panel titulo="Filtrar por riesgo mínimo">
        <input type="range" min="0" max="100" step="5" value={minRiesgo} onChange={e => setMinRiesgo(Number(e.target.value))} style={{ width: '100%' }} />
        <p style={{ fontSize: 12, color: 'var(--muted)' }}>Mostrando empleados con riesgo ≥ {minRiesgo}%</p>
      </Panel>
      <Panel titulo="Empleados ordenados por riesgo de rotación">
        <TablaWrap>
          <table>
            <thead>
              <tr><th>Empleado</th><th>Puesto</th><th>Unidad de negocio</th><th>Riesgo</th><th>Antigüedad</th><th>Ausentismo</th><th>Desempeño</th><th>Capacitación</th><th>Compensación</th></tr>
            </thead>
            <tbody>
              {filas.length === 0 && <tr><td colSpan="9" className="empty">Sin empleados que cumplan el filtro.</td></tr>}
              {filas.slice(0, 100).map(r => (
                <tr key={r.empleado_id}>
                  <td>{r.nombre_completo}</td>
                  <td style={{ fontSize: 12 }}>{r.puesto || '—'}</td>
                  <td style={{ fontSize: 12 }}>{r.unidad_negocio || '—'}</td>
                  <td><Badge estado={r.riesgo_pct >= 66 ? 'vencido' : r.riesgo_pct >= 33 ? 'pendiente' : 'activo'}>{fmtPct(r.riesgo_pct)}</Badge></td>
                  <td className="mono">{fmtPct(r.pct_antiguedad)}</td>
                  <td className="mono">{fmtPct(r.pct_ausentismo)}</td>
                  <td className="mono">{r.pct_desempeno == null ? '—' : fmtPct(r.pct_desempeno)}</td>
                  <td className="mono">{fmtPct(r.pct_capacitacion)}</td>
                  <td className="mono">{r.pct_compensacion == null ? '—' : fmtPct(r.pct_compensacion)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      </Panel>
    </>
  );
}

// ===========================================================================
// 9. Predicción de Rotación — Por Empleado (≈ Employee Attrition Prediction)
// ===========================================================================
function DashPrediccionEmpleado({ D }) {
  const [empId, setEmpId] = useState('');
  const fila = D.riesgo.find(r => r.empleado_id === empId) || null;
  const emp = empId ? D.empleadoMap.get(empId) : null;

  return (
    <>
      <Panel titulo="Elegir empleado">
        <select className="field" value={empId} onChange={e => setEmpId(e.target.value)}>
          <option value="">Elegí un empleado…</option>
          {D.riesgo.slice().sort((a, b) => a.nombre_completo.localeCompare(b.nombre_completo)).map(r => (
            <option key={r.empleado_id} value={r.empleado_id}>{r.nombre_completo} · {r.puesto || 'sin puesto'}</option>
          ))}
        </select>
      </Panel>
      {!fila ? <Vacio texto="Elegí un empleado para ver su desglose de riesgo." /> : (
        <>
          <div className="kpi-grid">
            <KpiCard label="Riesgo de rotación" value={fmtPct(fila.riesgo_pct)} color={fila.riesgo_pct >= 66 ? C.rosa : fila.riesgo_pct >= 33 ? C.ambar : C.verde} />
            <KpiCard label="Antigüedad" value={fmt(fila.antiguedad_anios) + ' años'} />
            <KpiCard label="Sueldo actual vs. promedio del puesto" value={fila.sueldo_actual == null ? 'Sin plaza con sueldo' : `${fmt$(fila.sueldo_actual)} / ${fmt$(fila.sueldo_promedio_puesto)}`} />
          </div>
          <Panel titulo={`Desglose de factores — ${fila.nombre_completo}`}>
            <TablaWrap>
              <table>
                <thead><tr><th>Factor</th><th>Contribución al riesgo</th><th>Detalle</th></tr></thead>
                <tbody>
                  <tr><td>Antigüedad</td><td className="mono">{fmtPct(fila.pct_antiguedad)}</td><td style={{ fontSize: 12 }}>{fmt(fila.antiguedad_anios)} años en el puesto</td></tr>
                  <tr><td>Ausentismo</td><td className="mono">{fmtPct(fila.pct_ausentismo)}</td><td style={{ fontSize: 12 }}>{fmt(fila.dias_ausentismo_12m)} días de permiso/incapacidad en 12 meses</td></tr>
                  <tr><td>Desempeño</td><td className="mono">{fila.pct_desempeno == null ? '—' : fmtPct(fila.pct_desempeno)}</td><td style={{ fontSize: 12 }}>{fila.ultima_calificacion == null ? 'Sin evaluación capturada' : `Última calificación: ${fila.ultima_calificacion}/10`}</td></tr>
                  <tr><td>Capacitación</td><td className="mono">{fmtPct(fila.pct_capacitacion)}</td><td style={{ fontSize: 12 }}>{fmt(fila.horas_capacitacion_12m)} horas en 12 meses</td></tr>
                  <tr><td>Compensación relativa</td><td className="mono">{fila.pct_compensacion == null ? '—' : fmtPct(fila.pct_compensacion)}</td><td style={{ fontSize: 12 }}>{fila.sueldo_actual == null ? 'Sin plaza con sueldo capturado' : `${fmt$(fila.sueldo_actual)} vs. promedio del puesto ${fmt$(fila.sueldo_promedio_puesto)}`}</td></tr>
                </tbody>
              </table>
            </TablaWrap>
          </Panel>
        </>
      )}
    </>
  );
}

// ===========================================================================
// Capacitación, Vacaciones, Reclutamiento -- módulos de la Fase 1/2, se
// conservan tal cual (sin equivalente directo en las 9 capturas de
// referencia) con su propio selector de grano mes/trimestre/año.
// ===========================================================================
function TabCapacitacion() {
  const [grano, setGrano] = useState('mes');
  const [serie, setSerie] = useState([]);
  const [raw, setRaw] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { (async () => {
    setLoading(true);
    const [s, r] = await Promise.all([
      fetchVista(`v_capacitacion_por_${grano}`, { order: 'anio', limit: 60 }),
      supabaseReady ? supabase.from('dw_hecho_capacitacion').select('tipo,horas').limit(5000) : Promise.resolve({ data: [] }),
    ]);
    setSerie(s); setRaw(r.data || []);
    setLoading(false);
  })(); }, [grano]);

  const totalCap = serie.reduce((s, r) => s + (r.capacitaciones || 0), 0);
  const horasTotales = serie.reduce((s, r) => s + Number(r.horas_totales || 0), 0);
  const empCapacitados = Math.max(...serie.map(r => r.empleados_capacitados || 0), 0);

  const porTipo = useMemo(() => {
    const m = new Map();
    for (const r of raw) { const k = r.tipo || 'Sin tipo'; m.set(k, (m.get(k) || 0) + 1); }
    return [...m.entries()].map(([tipo, n]) => ({ tipo, n }));
  }, [raw]);

  if (loading) return <Vacio cargando />;
  return (
    <>
      <div className="kpi-grid">
        <KpiCard label={`Capacitaciones (${grano})`} value={fmt(totalCap)} />
        <KpiCard label="Horas totales" value={fmt(horasTotales)} color={C.morado} />
        <KpiCard label="Empleados capacitados (pico por periodo)" value={fmt(empCapacitados)} color={C.verde} />
      </div>
      <GranoSelector grano={grano} setGrano={setGrano} />
      <Panel titulo="Horas de capacitación por periodo">
        {serie.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={serie}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="periodo" tick={{ fontSize: 11 }} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="horas_totales" name="Horas" fill={C.morado} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
      <Panel titulo="Capacitaciones por tipo">
        {porTipo.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie data={porTipo} dataKey="n" nameKey="tipo" outerRadius={80} label={({ tipo, n }) => `${tipo}: ${n}`}>
                {porTipo.map((_, i) => <Cell key={i} fill={SERIE[i % SERIE.length]} />)}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

function TabVacaciones() {
  const [grano, setGrano] = useState('mes');
  const [serie, setSerie] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { (async () => {
    setLoading(true);
    setSerie(await fetchVista(`v_vacaciones_por_${grano}`, { order: 'anio', limit: 60 }));
    setLoading(false);
  })(); }, [grano]);

  const diasTotales = serie.reduce((s, r) => s + Number(r.dias_totales || 0), 0);
  const primaTotal = serie.reduce((s, r) => s + Number(r.prima_total || 0), 0);
  const periodos = serie.reduce((s, r) => s + (r.periodos_tomados || 0), 0);

  if (loading) return <Vacio cargando />;
  return (
    <>
      <div className="kpi-grid">
        <KpiCard label={`Periodos tomados (${grano})`} value={fmt(periodos)} />
        <KpiCard label="Días totales tomados" value={fmt(diasTotales)} color={C.morado} />
        <KpiCard label="Prima vacacional total" value={fmt$(primaTotal)} color={C.verde} />
      </div>
      <GranoSelector grano={grano} setGrano={setGrano} />
      <Panel titulo="Días de vacaciones tomados por periodo">
        {serie.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={serie}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="periodo" tick={{ fontSize: 11 }} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="dias_totales" name="Días" fill={C.azul} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}

function TabReclutamiento() {
  const [grano, setGrano] = useState('mes');
  const [serie, setSerie] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { (async () => {
    setLoading(true);
    setSerie(await fetchVista(`v_reclutamiento_por_${grano}`, { order: 'anio', limit: 60 }));
    setLoading(false);
  })(); }, [grano]);

  const publicadas = serie.reduce((s, r) => s + (r.vacantes_publicadas || 0), 0);
  const cerradas = serie.reduce((s, r) => s + (r.vacantes_cerradas || 0), 0);
  const postulados = serie.reduce((s, r) => s + (r.candidatos_postulados || 0), 0);
  const contratados = serie.reduce((s, r) => s + (r.candidatos_contratados || 0), 0);
  const diasProm = serie.filter(r => r.dias_promedio_para_cubrir != null);
  const diasPromVal = diasProm.length ? diasProm.reduce((s, r) => s + Number(r.dias_promedio_para_cubrir), 0) / diasProm.length : null;
  const aceptacion = postulados > 0 ? (contratados / postulados) * 100 : null;

  if (loading) return <Vacio cargando />;
  return (
    <>
      <div className="kpi-grid">
        <KpiCard label={`Vacantes publicadas (${grano})`} value={fmt(publicadas)} />
        <KpiCard label="Vacantes cerradas" value={fmt(cerradas)} />
        <KpiCard label="Días promedio para cubrir" value={diasPromVal == null ? '—' : fmt(diasPromVal)} color={C.ambar} />
        <KpiCard label="Candidatos postulados" value={fmt(postulados)} />
        <KpiCard label="Tasa de aceptación" value={fmtPct(aceptacion)} color={C.verde} sub="contratados / postulados" />
      </div>
      <GranoSelector grano={grano} setGrano={setGrano} />
      <Panel titulo="Vacantes publicadas vs. cerradas por periodo">
        {serie.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={serie}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="periodo" tick={{ fontSize: 11 }} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Legend />
              <Bar dataKey="vacantes_publicadas" name="Publicadas" fill={C.azul} radius={[4, 4, 0, 0]} />
              <Bar dataKey="vacantes_cerradas" name="Cerradas" fill={C.verde} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
      <Panel titulo="Candidatos postulados vs. contratados por periodo">
        {serie.length === 0 ? <Vacio /> : (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={serie}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="periodo" tick={{ fontSize: 11 }} />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Legend />
              <Bar dataKey="candidatos_postulados" name="Postulados" fill={C.moradoClaro} radius={[4, 4, 0, 0]} />
              <Bar dataKey="candidatos_contratados" name="Contratados" fill={C.morado} radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </Panel>
    </>
  );
}
