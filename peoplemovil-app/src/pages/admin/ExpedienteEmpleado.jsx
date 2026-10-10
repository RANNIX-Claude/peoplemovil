import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Modal from '../../components/ui/Modal.jsx';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import AnilloPorcentaje from '../../components/ui/AnilloPorcentaje.jsx';
import Semaforo from '../../components/Semaforo.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import { useModuleAudit, logAccion } from '../../lib/audit.js';
import { subirArchivoEmpleado, resolverUrlArchivo } from '../../lib/storage.js';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';

const TABS = [
  { k: 'resumen', label: '📋 Resumen' },
  { k: 'laboral', label: '💼 Información laboral' },
  { k: 'personal', label: '🪪 Domicilio y datos personales' },
  { k: 'documentos', label: '📄 Documentos' },
  { k: 'vacaciones', label: '🏖️ Vacaciones' },
  { k: 'capacitacion', label: '🎓 Capacitación' },
  { k: 'evaluaciones', label: '⭐ Evaluaciones' },
  { k: 'beneficios', label: '❤️ Beneficios' },
  { k: 'plazas', label: '🎯 Plazas y certeza' },
  { k: 'asistencia', label: '🕒 Asistencia' },
  { k: 'nomina', label: '💰 Nómina' },
  { k: 'movimientos', label: '📜 Movimientos' },
];

const SEXO_LABEL = { M: 'Masculino', F: 'Femenino', X: 'Otro' };

function fmtFecha(d) {
  if (!d) return null;
  const iso = d.length === 10 ? d + 'T00:00:00' : d;
  return new Date(iso).toLocaleDateString('es-MX', { day: '2-digit', month: 'short', year: 'numeric' });
}
function fmtFechaHora(d) {
  if (!d) return null;
  const dt = new Date(d);
  return dt.toLocaleDateString('es-MX', { day: '2-digit', month: 'short', year: 'numeric' }) +
    ' · ' + dt.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
}
function antiguedad(fechaAlta) {
  if (!fechaAlta) return '—';
  const inicio = new Date(fechaAlta.length === 10 ? fechaAlta + 'T00:00:00' : fechaAlta);
  const hoy = new Date();
  let meses = (hoy.getFullYear() - inicio.getFullYear()) * 12 + (hoy.getMonth() - inicio.getMonth());
  if (hoy.getDate() < inicio.getDate()) meses--;
  if (meses < 0) meses = 0;
  const anios = Math.floor(meses / 12);
  const mesesRest = meses % 12;
  if (anios === 0) return `${mesesRest} mes${mesesRest === 1 ? '' : 'es'}`;
  return `${anios} año${anios === 1 ? '' : 's'}` + (mesesRest ? ` ${mesesRest} mes${mesesRest === 1 ? '' : 'es'}` : '');
}
function iniciales(nombres, apPat) {
  return `${(nombres || '?').trim()[0] || ''}${(apPat || '').trim()[0] || ''}`.toUpperCase();
}

// Espejo en JS de dias_vacaciones_lft() en la base (Migración 024) — LFT Art. 76,
// reforma de "vacaciones dignas" vigente desde 2023. El legado OCESA no tenía
// este módulo; se agrega por pedido explícito del usuario para alinear el
// proyecto a la ley vigente, no porque el sistema original lo tuviera.
function diasVacacionesLFT(anio) {
  if (!anio || anio <= 0) return 0;
  if (anio === 1) return 12;
  if (anio === 2) return 14;
  if (anio === 3) return 16;
  if (anio === 4) return 18;
  if (anio >= 5 && anio <= 9) return 20;
  return 20 + 2 * Math.ceil((anio - 9) / 5);
}
const LFT_TABLA = [
  ['1er año', diasVacacionesLFT(1)], ['2do año', diasVacacionesLFT(2)],
  ['3er año', diasVacacionesLFT(3)], ['4to año', diasVacacionesLFT(4)],
  ['5to–9no año', diasVacacionesLFT(5)], ['10mo–14to año', diasVacacionesLFT(10)],
  ['15to–19no año', diasVacacionesLFT(15)], ['20mo–24to año', diasVacacionesLFT(20)],
  ['25to–29no año', diasVacacionesLFT(25)], ['30mo año en adelante', diasVacacionesLFT(30)],
];

// El "año laboral" no se guarda — se deriva de fecha_alta en cada render (evita
// duplicar un dato calculable). Solo los períodos efectivamente tomados viven en la base.
function construirAniosLaborales(fechaAlta, periodos) {
  if (!fechaAlta) return [];
  const inicio = new Date(fechaAlta.length === 10 ? fechaAlta + 'T00:00:00' : fechaAlta);
  const hoy = new Date();
  const anios = [];
  let n = 1;
  let cursor = new Date(inicio);
  while (cursor <= hoy && n <= 60) {
    const fin = new Date(cursor);
    fin.setFullYear(fin.getFullYear() + 1);
    fin.setDate(fin.getDate() - 1);
    const derecho = diasVacacionesLFT(n);
    const tomados = periodos.filter(p => p.anio_laboral === n && p.estado !== 'cancelada').reduce((s, p) => s + Number(p.dias), 0);
    anios.push({
      anio: n,
      fecha_inicio: cursor.toISOString().slice(0, 10),
      fecha_fin: fin.toISOString().slice(0, 10),
      derecho, tomados,
      disponibles: Math.max(0, derecho - tomados),
      vencido: fin < hoy,
    });
    cursor = new Date(fin);
    cursor.setDate(cursor.getDate() + 1);
    n++;
  }
  return anios.reverse();
}

// Campo de solo-lectura en "renglón": línea divisoria debajo para que el
// grid se lea como filas (como el RH de referencia), no como huecos sueltos.
// Etiqueta chica/gris vs. valor más grande/oscuro -- contraste deliberado.
function Campo({ label, valor }) {
  return (
    <div style={{ borderBottom: '1px solid var(--border)', paddingBottom: 10 }}>
      <div className="label">{label}</div>
      <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text)' }}>
        {valor || <span style={{ color: 'var(--muted)', fontWeight: 400 }}>—</span>}
      </div>
    </div>
  );
}

// Resuelve un path del bucket privado (o una URL pública de datos demo) a un
// link con el que el navegador pueda abrir el archivo.
function ArchivoLink({ path, label = 'Ver ↗' }) {
  const [url, setUrl] = useState(null);
  useEffect(() => {
    let activo = true;
    if (path) resolverUrlArchivo(path).then(u => { if (activo) setUrl(u); });
    return () => { activo = false; };
  }, [path]);
  if (!path) return <span style={{ color: 'var(--muted)' }}>—</span>;
  if (!url) return <span style={{ fontSize: 12, color: 'var(--muted)' }}>…</span>;
  return <a href={url} target="_blank" rel="noreferrer" style={{ fontSize: 12 }}>{label}</a>;
}

const gridAuto = { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(170px, 1fr))', gap: 16 };
const tituloConLinea = { marginTop: 0, marginBottom: 12, paddingBottom: 10, borderBottom: '1px solid var(--border)' };
const CAP_TIPOS = { interna: 'activo', externa: 'pendiente', certificacion: 'proceso' };

// Encabezado de card con ícono + botón "Editar" opcional (gateado por permiso
// desde el padre) -- mismo criterio visual que el módulo RH de referencia
// (IRPAPP): cada card se identifica de un vistazo por su ícono.
function CardHeader({ titulo, icono, onEditar }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, paddingBottom: 10, borderBottom: '1px solid var(--border)' }}>
      <h3 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: 8 }}>{icono && <span aria-hidden="true">{icono}</span>}{titulo}</h3>
      {onEditar && <button className="btn ghost sm" onClick={onEditar}>✎ Editar</button>}
    </div>
  );
}

// Modal de edición genérico: recibe la definición de una "sección" (título +
// lista de campos) y los valores actuales del empleado, y delega el guardado
// al padre (que calcula el diff y lo audita en tl_movimientos_empleado_det).
function EditSectionModal({ open, onClose, section, values, onSave }) {
  const [form, setForm] = useState({});
  useEffect(() => {
    if (open && section) setForm(Object.fromEntries(section.fields.map(f => [f.key, values[f.key] ?? ''])));
  }, [open, section, values]);
  if (!section) return null;
  function submit(e) { e.preventDefault(); onSave(section, form); }
  return (
    <Modal open={open} onClose={onClose} title={'Editar ' + section.title.toLowerCase()}
      footer={<><button className="btn ghost" onClick={onClose}>Cancelar</button>
              <button className="btn" onClick={submit}>Guardar</button></>}>
      <form onSubmit={submit} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {section.fields.map(f => (
          <div key={f.key} style={f.full ? { gridColumn: 'span 2' } : undefined}>
            <label className="label">{f.label}</label>
            {f.type === 'select' ? (
              <select className="field" value={form[f.key] ?? ''} onChange={e => setForm({ ...form, [f.key]: e.target.value })}>
                <option value="">—</option>
                {f.options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            ) : (
              <input type={f.type || 'text'} step={f.type === 'number' ? '0.01' : undefined} className="field"
                value={form[f.key] ?? ''} onChange={e => setForm({ ...form, [f.key]: e.target.value })} />
            )}
          </div>
        ))}
      </form>
    </Modal>
  );
}

export default function ExpedienteEmpleado() {
  useModuleAudit('expediente_empleado');
  const { id } = useParams();
  const navigate = useNavigate();
  const { usuario, hasPermiso } = useAdminAuth();
  const puedeEditar = hasPermiso('empleados.editar');
  const puedeDarBaja = hasPermiso('empleados.eliminar');

  const [tab, setTab] = useState('resumen');
  const [empleado, setEmpleado] = useState(null);
  const [documentos, setDocumentos] = useState([]);
  const [tiposDoc, setTiposDoc] = useState([]);
  const [plazas, setPlazas] = useState([]);
  const [asistencia, setAsistencia] = useState([]);
  const [nomina, setNomina] = useState([]);
  const [movimientos, setMovimientos] = useState([]);
  const [vacaciones, setVacaciones] = useState([]);
  const [capacitaciones, setCapacitaciones] = useState([]);
  const [evaluaciones, setEvaluaciones] = useState([]);
  const [tiposBeneficio, setTiposBeneficio] = useState([]);
  const [beneficios, setBeneficios] = useState([]);
  const [catPuestos, setCatPuestos] = useState([]);
  const [catSitios, setCatSitios] = useState([]);
  const [catSociedades, setCatSociedades] = useState([]);
  const [catBancos, setCatBancos] = useState([]);
  const [cambiosCuenta, setCambiosCuenta] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [msg, setMsg] = useState('');
  const [fotoResuelta, setFotoResuelta] = useState(null);

  const fotoInputRef = useRef(null);

  const [editSectionKey, setEditSectionKey] = useState(null);
  const [bajaModalOpen, setBajaModalOpen] = useState(false);
  const [bajaForm, setBajaForm] = useState({ fecha_baja: '', motivo_baja: '' });
  const [cuentaModalOpen, setCuentaModalOpen] = useState(false);
  const [nuevaCuenta, setNuevaCuenta] = useState({ banco_id_nuevo: '', numero_cuenta_nuevo: '', clabe_nueva: '', motivo: '' });

  const [docModalOpen, setDocModalOpen] = useState(false);
  const [nuevoDoc, setNuevoDoc] = useState({ tipo_documento_id: '', vigencia_hasta: '', observaciones: '' });
  const [archivoDoc, setArchivoDoc] = useState(null);

  const [vacModalOpen, setVacModalOpen] = useState(false);
  const [nuevoVac, setNuevoVac] = useState({ anio_laboral: '', fecha_inicio: '', fecha_fin: '', dias: '', prima_vacacional: '', observaciones: '' });

  const [capModalOpen, setCapModalOpen] = useState(false);
  const [nuevoCap, setNuevoCap] = useState({ titulo: '', institucion: '', tipo: 'interna', horas: '', fecha_inicio: '', fecha_fin: '', vigencia_hasta: '', observaciones: '' });
  const [archivoCap, setArchivoCap] = useState(null);

  const [evalModalOpen, setEvalModalOpen] = useState(false);
  const [nuevoEval, setNuevoEval] = useState({ periodo: '', fecha_evaluacion: '', calificacion: '', fortalezas: '', areas_oportunidad: '', comentarios: '' });

  const [benModalOpen, setBenModalOpen] = useState(false);
  const [nuevoBen, setNuevoBen] = useState({ tipo_beneficio_id: '', fecha_inicio: '', monto: '', observaciones: '' });

  async function cargar() {
    if (!supabaseReady || !id) return;
    setCargando(true);
    const [
      { data: emp, error: errEmp },
      { data: docs },
      { data: tdoc },
      { data: plz },
      { data: asis },
      { data: nom },
      { data: mov },
      { data: vac },
      { data: cap },
      { data: evalu },
      { data: tben },
      { data: ben },
      { data: cpue },
      { data: csit },
      { data: csoc },
      { data: cban },
      { data: cc },
    ] = await Promise.all([
      supabase.from('te_empleados')
        .select('*, puesto:tc_puestos(titulo, pago_default), sitio:tc_sitios(titulo, tipo_sitio), banco:tc_bancos(nombre), sociedad:tc_sociedades_pagadoras(titulo), tipo_personal:tc_tipos_personal(descripcion)')
        .eq('id', id).single(),
      supabase.from('te_documentos_empleado')
        .select('*, tipo:tc_tipos_documento(clave, titulo, requerido_alta)')
        .eq('empleado_id', id).order('creado_en', { ascending: false }),
      supabase.from('tc_tipos_documento').select('id, clave, titulo, requerido_alta').order('titulo'),
      supabase.from('tr_empleado_plaza').select('*, puesto:tc_puestos(titulo)').eq('empleado_id', id),
      supabase.from('te_eventos_biometricos').select('*').eq('empleado_id', id).order('ts_servidor', { ascending: false }).limit(30),
      supabase.from('te_nomina_detalle').select('*, periodo:te_nominas_periodo(fecha_desde, fecha_hasta, ciclo_pago, cerrada)').eq('empleado_id', id).order('creado_en', { ascending: false }),
      supabase.from('tl_movimientos_empleado_det').select('*').eq('empleado_id', id).order('fecha_efectiva', { ascending: false }).limit(50),
      supabase.from('te_vacaciones_periodos').select('*').eq('empleado_id', id).order('fecha_inicio', { ascending: false }),
      supabase.from('te_capacitaciones_empleado').select('*').eq('empleado_id', id).order('fecha_inicio', { ascending: false }),
      supabase.from('te_evaluaciones_empleado').select('*, evaluador:te_usuarios(nombre, apellido_paterno)').eq('empleado_id', id).order('fecha_evaluacion', { ascending: false }),
      supabase.from('tc_tipos_beneficio').select('*').eq('activo', true).order('titulo'),
      supabase.from('te_beneficios_empleado').select('*, tipo:tc_tipos_beneficio(titulo, descripcion)').eq('empleado_id', id).order('fecha_inicio', { ascending: false }),
      supabase.from('tc_puestos').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_sitios').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_sociedades_pagadoras').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_bancos').select('id, nombre').eq('activo', true).order('nombre'),
      supabase.from('te_cambio_cuenta_bancaria').select('*, banco:tc_bancos(nombre)').eq('empleado_id', id).order('solicitado_en', { ascending: false }),
    ]);
    if (errEmp) { setMsg('No se pudo cargar el expediente: ' + errEmp.message); setCargando(false); return; }
    setEmpleado(emp);
    setDocumentos(docs || []);
    setTiposDoc(tdoc || []);
    setPlazas(plz || []);
    setAsistencia(asis || []);
    setNomina(nom || []);
    setMovimientos(mov || []);
    setVacaciones(vac || []);
    setCapacitaciones(cap || []);
    setEvaluaciones(evalu || []);
    setTiposBeneficio(tben || []);
    setBeneficios(ben || []);
    setCatPuestos(cpue || []);
    setCatSitios(csit || []);
    setCatSociedades(csoc || []);
    setCatBancos(cban || []);
    setCambiosCuenta(cc || []);
    setCargando(false);
  }
  useEffect(() => { cargar(); /* eslint-disable-next-line */ }, [id]);

  useEffect(() => {
    let activo = true;
    if (empleado?.foto_url) resolverUrlArchivo(empleado.foto_url).then(u => { if (activo) setFotoResuelta(u); });
    else setFotoResuelta(null);
    return () => { activo = false; };
  }, [empleado?.foto_url]);

  const requeridos = useMemo(() => tiposDoc.filter(t => t.requerido_alta), [tiposDoc]);
  const requeridosCubiertos = useMemo(
    () => requeridos.filter(t => documentos.some(d => d.tipo_documento_id === t.id)),
    [requeridos, documentos]
  );
  const pctExpediente = requeridos.length ? requeridosCubiertos.length / requeridos.length : 0;

  const aniosLaborales = useMemo(() => construirAniosLaborales(empleado?.fecha_alta, vacaciones), [empleado?.fecha_alta, vacaciones]);
  const totalDisponibles = useMemo(() => aniosLaborales.reduce((s, a) => s + a.disponibles, 0), [aniosLaborales]);

  // Secciones editables del expediente (generan el modal + el diff de auditoría).
  // La cuenta bancaria queda FUERA a propósito: el legado ya modela un flujo de
  // solicitud con aprobación (te_cambio_cuenta_bancaria) — un cambio directo
  // aquí sería simplificar un control antifraude real, no solo un dato más.
  const secciones = useMemo(() => ({
    laboral: {
      title: 'Información laboral',
      fields: [
        { key: 'tipo_empleado', label: 'Tipo de empleado', type: 'select', options: [
          { value: 'freelance', label: 'Freelance' }, { value: 'staff', label: 'Staff' },
          { value: 'interno', label: 'Interno' }, { value: 'eventual', label: 'Eventual' },
        ] },
        { key: 'id_puesto_principal', label: 'Puesto principal', type: 'select', options: catPuestos.map(p => ({ value: p.id, label: p.titulo })) },
        { key: 'id_sitio_principal', label: 'Sitio principal', type: 'select', options: catSitios.map(s => ({ value: s.id, label: s.titulo })) },
        { key: 'regimen_pago', label: 'Régimen de pago', type: 'select', options: ['Nomina', 'Honorarios Normales', 'Honorarios Asimilables'].map(v => ({ value: v, label: v })) },
        { key: 'ciclo_pago', label: 'Ciclo de pago', type: 'select', options: ['Semanal', 'Quincenal', 'Mensual'].map(v => ({ value: v, label: v })) },
        { key: 'id_sociedad_pagadora', label: 'Sociedad pagadora', type: 'select', options: catSociedades.map(s => ({ value: s.id, label: s.titulo })) },
        { key: 'recomendado_por', label: 'Recomendado por', type: 'text' },
      ],
    },
    identidad: {
      title: 'Identidad',
      fields: [
        { key: 'rfc', label: 'RFC', type: 'text' },
        { key: 'curp', label: 'CURP', type: 'text' },
        { key: 'fecha_nacimiento', label: 'Fecha de nacimiento', type: 'date' },
        { key: 'estado_nacimiento', label: 'Estado de nacimiento', type: 'text' },
        { key: 'sexo', label: 'Sexo', type: 'select', options: [{ value: 'M', label: 'Masculino' }, { value: 'F', label: 'Femenino' }, { value: 'X', label: 'Otro' }] },
        { key: 'estado_civil', label: 'Estado civil', type: 'text' },
        { key: 'tipo_sangre', label: 'Tipo de sangre', type: 'select', options: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(v => ({ value: v, label: v })) },
        { key: 'estatura', label: 'Estatura (m)', type: 'number' },
        { key: 'talla', label: 'Talla', type: 'text' },
      ],
    },
    domicilio: {
      title: 'Domicilio',
      fields: [
        { key: 'calle', label: 'Calle', type: 'text' },
        { key: 'numero_exterior', label: 'Número exterior', type: 'text' },
        { key: 'numero_interior', label: 'Número interior', type: 'text' },
        { key: 'colonia', label: 'Colonia', type: 'text' },
        { key: 'codigo_postal', label: 'Código postal', type: 'text' },
        { key: 'delegacion_municipio', label: 'Municipio / Alcaldía', type: 'text' },
        { key: 'estado_provincia', label: 'Estado', type: 'text' },
        { key: 'telefono', label: 'Teléfono', type: 'text' },
        { key: 'correo', label: 'Correo', type: 'text' },
      ],
    },
    docsIdentidad: {
      title: 'Documentos de identidad',
      fields: [
        { key: 'credencial_elector', label: 'Credencial de elector', type: 'text' },
        { key: 'cartilla', label: 'Cartilla militar', type: 'text' },
      ],
    },
    academico: {
      title: 'Perfil académico',
      fields: [
        { key: 'grado_estudios', label: 'Grado de estudios', type: 'text' },
        { key: 'licenciatura_curso', label: 'Licenciatura / curso', type: 'text' },
        { key: 'idiomas', label: 'Idiomas', type: 'text' },
      ],
    },
    emergencia: {
      title: 'Emergencia y salud',
      fields: [
        { key: 'contacto_emergencia', label: 'Contacto de emergencia', type: 'text' },
        { key: 'datos_medicos', label: 'Datos médicos', type: 'text' },
      ],
    },
  }), [catPuestos, catSitios, catSociedades]);

  // Inserta en el log de auditoría — no bloquea el flujo principal si falla,
  // pero deja rastro en consola (antes fallaba en silencio contra una tabla
  // que ya no existía con ese nombre: te_movimientos_empleado fue renombrada
  // a tl_movimientos_empleado_det cuando se agregó el encabezado de lotes).
  async function registrarMovimiento(payload) {
    const { error } = await supabase.from('tl_movimientos_empleado_det').insert(payload);
    if (error) console.warn('No se pudo registrar el movimiento:', error.message);
  }

  async function guardarSeccion(section, formValues) {
    const updates = {};
    const movs = [];
    for (const f of section.fields) {
      let nuevo = formValues[f.key];
      if (nuevo === '') nuevo = null;
      if (f.type === 'number' && nuevo != null) nuevo = Number(nuevo);
      const anterior = empleado[f.key] ?? null;
      if (String(anterior ?? '') === String(nuevo ?? '')) continue;
      updates[f.key] = nuevo;
      const etiquetaDe = v => {
        if (v == null) return null;
        const opt = f.options?.find(o => String(o.value) === String(v));
        return opt ? opt.label : String(v);
      };
      movs.push({ campo: f.label, valor_anterior: etiquetaDe(anterior), valor_nuevo: etiquetaDe(nuevo) });
    }
    if (Object.keys(updates).length === 0) { setEditSectionKey(null); return; }
    const { error } = await supabase.from('te_empleados').update(updates).eq('id', id);
    if (error) { setMsg('No se pudo guardar: ' + error.message); return; }
    if (movs.length) {
      await registrarMovimiento(
        movs.map(m => ({ tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_movimiento: section.title, campo: m.campo, valor_anterior: m.valor_anterior, valor_nuevo: m.valor_nuevo }))
      );
    }
    await logAccion('expediente_empleado', 'UPDATE', `${section.title}: ${movs.map(m => m.campo).join(', ')}`);
    setEditSectionKey(null); setMsg('Cambios guardados'); cargar();
  }

  async function confirmarBaja(e) {
    e.preventDefault();
    if (!bajaForm.motivo_baja.trim()) { setMsg('Indicá el motivo de la baja.'); return; }
    const { error } = await supabase.from('te_empleados').update({
      activo: false, fecha_baja: bajaForm.fecha_baja || new Date().toISOString().slice(0, 10), motivo_baja: bajaForm.motivo_baja,
    }).eq('id', id);
    if (error) { setMsg('No se pudo dar de baja: ' + error.message); return; }
    await registrarMovimiento({
      tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_movimiento: 'Baja', campo: 'activo',
      valor_anterior: 'ACTIVO', valor_nuevo: 'BAJA', motivo: bajaForm.motivo_baja,
      fecha_efectiva: bajaForm.fecha_baja || new Date().toISOString().slice(0, 10),
    });
    await logAccion('expediente_empleado', 'BAJA', bajaForm.motivo_baja);
    setBajaForm({ fecha_baja: '', motivo_baja: '' }); setBajaModalOpen(false); setMsg('Empleado dado de baja'); cargar();
  }

  async function reactivar() {
    if (!confirm('¿Reactivar a este empleado?')) return;
    const { error } = await supabase.from('te_empleados').update({ activo: true, fecha_baja: null, motivo_baja: null }).eq('id', id);
    if (error) { setMsg('Error: ' + error.message); return; }
    await registrarMovimiento({
      tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_movimiento: 'Reactivación', campo: 'activo', valor_anterior: 'BAJA', valor_nuevo: 'ACTIVO',
    });
    await logAccion('expediente_empleado', 'REACTIVAR', '');
    setMsg('Empleado reactivado'); cargar();
  }

  async function solicitarCambioCuenta(e) {
    e.preventDefault();
    if (!nuevaCuenta.numero_cuenta_nuevo) { setMsg('Indicá el número de cuenta nuevo.'); return; }
    const { error } = await supabase.from('te_cambio_cuenta_bancaria').insert({
      tenant_id: DEMO_TENANT_ID, empleado_id: id,
      banco_id_nuevo: nuevaCuenta.banco_id_nuevo || null, numero_cuenta_nuevo: nuevaCuenta.numero_cuenta_nuevo,
      clabe_nueva: nuevaCuenta.clabe_nueva || null, motivo: nuevaCuenta.motivo || null, status: 'pendiente',
    });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    await logAccion('expediente_empleado', 'INSERT', 'solicitud de cambio de cuenta bancaria');
    setNuevaCuenta({ banco_id_nuevo: '', numero_cuenta_nuevo: '', clabe_nueva: '', motivo: '' });
    setCuentaModalOpen(false); setMsg('Solicitud registrada — queda pendiente de aprobación'); cargar();
  }

  async function resolverCambioCuenta(c, aprobar) {
    if (aprobar) {
      const { error: errEmp } = await supabase.from('te_empleados').update({
        id_banco: c.banco_id_nuevo, cuenta_bancaria: c.numero_cuenta_nuevo, clabe: c.clabe_nueva,
      }).eq('id', id);
      if (errEmp) { setMsg('No se pudo aplicar el cambio: ' + errEmp.message); return; }
      await registrarMovimiento({
        tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_movimiento: 'Cambio de cuenta bancaria',
        campo: 'cuenta_bancaria', valor_anterior: empleado.cuenta_bancaria, valor_nuevo: c.numero_cuenta_nuevo, motivo: c.motivo,
      });
    }
    const { error } = await supabase.from('te_cambio_cuenta_bancaria').update({
      status: aprobar ? 'aprobado' : 'rechazado', aprobado_por: usuario?.id || null, aprobado_en: new Date().toISOString(),
    }).eq('id', c.id);
    if (error) { setMsg('Error: ' + error.message); return; }
    await logAccion('expediente_empleado', aprobar ? 'APROBAR_CAMBIO_CUENTA' : 'RECHAZAR_CAMBIO_CUENTA', c.id);
    setMsg(aprobar ? 'Cambio de cuenta aplicado' : 'Solicitud rechazada'); cargar();
  }

  async function subirFoto(e) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    try {
      const path = await subirArchivoEmpleado(DEMO_TENANT_ID, id, file, 'foto');
      const { error } = await supabase.from('te_empleados').update({ foto_url: path }).eq('id', id);
      if (error) throw error;
      await logAccion('expediente_empleado', 'UPDATE', 'foto de perfil actualizada');
      setMsg('Foto actualizada'); cargar();
    } catch (err) { setMsg('No se pudo subir la foto: ' + err.message); }
  }

  async function agregarDocumento(e) {
    e.preventDefault();
    if (!nuevoDoc.tipo_documento_id || !archivoDoc) { setMsg('Elegí el tipo de documento y seleccioná el archivo.'); return; }
    try {
      const path = await subirArchivoEmpleado(DEMO_TENANT_ID, id, archivoDoc, 'documentos');
      const { error } = await supabase.from('te_documentos_empleado').insert({
        tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_documento_id: nuevoDoc.tipo_documento_id,
        url_almacen: path, vigencia_hasta: nuevoDoc.vigencia_hasta || null, observaciones: nuevoDoc.observaciones || null,
      });
      if (error) throw error;
      await logAccion('expediente_empleado', 'INSERT', `documento ${nuevoDoc.tipo_documento_id} subido`);
      setNuevoDoc({ tipo_documento_id: '', vigencia_hasta: '', observaciones: '' });
      setArchivoDoc(null); setDocModalOpen(false); setMsg('Documento subido'); cargar();
    } catch (err) { setMsg('No se pudo subir el documento: ' + err.message); }
  }

  async function agregarVacacion(e) {
    e.preventDefault();
    if (!nuevoVac.anio_laboral || !nuevoVac.fecha_inicio || !nuevoVac.fecha_fin || !nuevoVac.dias) {
      setMsg('Completá año laboral, fechas y días.'); return;
    }
    const { error } = await supabase.from('te_vacaciones_periodos').insert({
      tenant_id: DEMO_TENANT_ID, empleado_id: id,
      anio_laboral: Number(nuevoVac.anio_laboral),
      fecha_inicio: nuevoVac.fecha_inicio, fecha_fin: nuevoVac.fecha_fin,
      dias: Number(nuevoVac.dias), prima_vacacional: Number(nuevoVac.prima_vacacional || 0),
      observaciones: nuevoVac.observaciones || null,
    });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    await logAccion('expediente_empleado', 'INSERT', `período de vacaciones año ${nuevoVac.anio_laboral}`);
    setNuevoVac({ anio_laboral: '', fecha_inicio: '', fecha_fin: '', dias: '', prima_vacacional: '', observaciones: '' });
    setVacModalOpen(false); setMsg('Período registrado'); cargar();
  }

  async function cancelarVacacion(vid) {
    if (!confirm('¿Cancelar este período de vacaciones?')) return;
    const { error } = await supabase.from('te_vacaciones_periodos').update({ estado: 'cancelada' }).eq('id', vid);
    if (error) { setMsg('Error: ' + error.message); return; }
    await logAccion('expediente_empleado', 'UPDATE', `período de vacaciones ${vid} cancelado`);
    cargar();
  }

  async function agregarCapacitacion(e) {
    e.preventDefault();
    if (!nuevoCap.titulo) { setMsg('Ponele un título a la capacitación.'); return; }
    try {
      let constanciaPath = null;
      if (archivoCap) constanciaPath = await subirArchivoEmpleado(DEMO_TENANT_ID, id, archivoCap, 'capacitaciones');
      const { error } = await supabase.from('te_capacitaciones_empleado').insert({
        tenant_id: DEMO_TENANT_ID, empleado_id: id, titulo: nuevoCap.titulo, institucion: nuevoCap.institucion || null,
        tipo: nuevoCap.tipo, horas: nuevoCap.horas ? Number(nuevoCap.horas) : null,
        fecha_inicio: nuevoCap.fecha_inicio || new Date().toISOString().slice(0, 10),
        fecha_fin: nuevoCap.fecha_fin || null, vigencia_hasta: nuevoCap.vigencia_hasta || null,
        constancia_url: constanciaPath, observaciones: nuevoCap.observaciones || null,
      });
      if (error) throw error;
      await logAccion('expediente_empleado', 'INSERT', `capacitación ${nuevoCap.titulo}`);
      setNuevoCap({ titulo: '', institucion: '', tipo: 'interna', horas: '', fecha_inicio: '', fecha_fin: '', vigencia_hasta: '', observaciones: '' });
      setArchivoCap(null); setCapModalOpen(false); setMsg('Capacitación registrada'); cargar();
    } catch (err) { setMsg('No se pudo guardar: ' + err.message); }
  }

  async function agregarEvaluacion(e) {
    e.preventDefault();
    if (!nuevoEval.periodo) { setMsg('Indicá el período de la evaluación.'); return; }
    const { error } = await supabase.from('te_evaluaciones_empleado').insert({
      tenant_id: DEMO_TENANT_ID, empleado_id: id, periodo: nuevoEval.periodo,
      fecha_evaluacion: nuevoEval.fecha_evaluacion || new Date().toISOString().slice(0, 10),
      calificacion: nuevoEval.calificacion !== '' ? Number(nuevoEval.calificacion) : null,
      fortalezas: nuevoEval.fortalezas || null, areas_oportunidad: nuevoEval.areas_oportunidad || null,
      comentarios: nuevoEval.comentarios || null,
    });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    await logAccion('expediente_empleado', 'INSERT', `evaluación ${nuevoEval.periodo}`);
    setNuevoEval({ periodo: '', fecha_evaluacion: '', calificacion: '', fortalezas: '', areas_oportunidad: '', comentarios: '' });
    setEvalModalOpen(false); setMsg('Evaluación registrada'); cargar();
  }

  async function asignarBeneficio(e) {
    e.preventDefault();
    if (!nuevoBen.tipo_beneficio_id) { setMsg('Elegí un tipo de beneficio.'); return; }
    const { error } = await supabase.from('te_beneficios_empleado').insert({
      tenant_id: DEMO_TENANT_ID, empleado_id: id, tipo_beneficio_id: nuevoBen.tipo_beneficio_id,
      fecha_inicio: nuevoBen.fecha_inicio || new Date().toISOString().slice(0, 10),
      monto: nuevoBen.monto !== '' ? Number(nuevoBen.monto) : null, observaciones: nuevoBen.observaciones || null,
    });
    if (error) { setMsg('Rechazado por la base: ' + error.message); return; }
    await logAccion('expediente_empleado', 'INSERT', `beneficio ${nuevoBen.tipo_beneficio_id} asignado`);
    setNuevoBen({ tipo_beneficio_id: '', fecha_inicio: '', monto: '', observaciones: '' });
    setBenModalOpen(false); setMsg('Beneficio asignado'); cargar();
  }

  async function darBajaBeneficio(bid) {
    if (!confirm('¿Dar de baja este beneficio?')) return;
    const { error } = await supabase.from('te_beneficios_empleado').update({ activo: false, fecha_fin: new Date().toISOString().slice(0, 10) }).eq('id', bid);
    if (error) { setMsg('Error: ' + error.message); return; }
    await logAccion('expediente_empleado', 'UPDATE', `beneficio ${bid} dado de baja`);
    cargar();
  }

  if (cargando) return <div style={{ padding: 40, color: 'var(--muted)' }}>Cargando expediente…</div>;
  if (!empleado) return (
    <div>
      <button className="btn ghost sm" onClick={() => navigate('/admin/personal')}>← Volver a Personal</button>
      <p style={{ marginTop: 16 }}>{msg || 'No se encontró el empleado.'}</p>
    </div>
  );

  return (
    <div>
      <button className="btn ghost sm" onClick={() => navigate('/admin/personal')}>← Volver a Personal</button>

      {/* Banner de identidad */}
      <div style={{
        background: 'linear-gradient(135deg, var(--accent), var(--accent-dark))',
        borderRadius: 14, padding: '22px 26px', margin: '14px 0 20px',
        display: 'flex', alignItems: 'center', gap: 18, flexWrap: 'wrap',
      }}>
        <div style={{ position: 'relative', cursor: 'pointer', flexShrink: 0 }} onClick={() => fotoInputRef.current?.click()} title="Cambiar foto">
          <div style={{
            width: 76, height: 76, borderRadius: '50%', overflow: 'hidden',
            background: 'rgba(255,255,255,.22)', border: '3px solid rgba(255,255,255,.55)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            {fotoResuelta
              ? <img src={fotoResuelta} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              : <span style={{ fontSize: 26, fontWeight: 900, color: '#fff' }}>{iniciales(empleado.nombres, empleado.apellido_paterno)}</span>}
          </div>
          <span style={{
            position: 'absolute', bottom: -2, right: -2, background: '#fff', borderRadius: '50%',
            width: 24, height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, boxShadow: '0 1px 4px rgba(0,0,0,.35)',
          }}>📷</span>
          <input ref={fotoInputRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={subirFoto} />
        </div>
        <div style={{ flex: 1, minWidth: 220 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
            <h1 style={{ color: '#fff', margin: 0 }}>{empleado.nombres} {empleado.apellido_paterno} {empleado.apellido_materno}</h1>
            <Badge estado={empleado.activo ? 'activo' : 'inactivo'}>{empleado.activo ? 'ACTIVO' : 'BAJA'}</Badge>
          </div>
          <div style={{ color: 'rgba(255,255,255,.95)', fontSize: 14, fontWeight: 700, marginTop: 4 }}>
            {empleado.puesto?.titulo || 'Sin puesto'}
          </div>
          <div style={{ color: 'rgba(255,255,255,.8)', fontSize: 12, marginTop: 8, display: 'flex', gap: 14, flexWrap: 'wrap' }}>
            {empleado.telefono && <span>📞 {empleado.telefono}</span>}
            <span>🪪 #{empleado.folio}</span>
            <span>📅 Desde {fmtFecha(empleado.fecha_alta)}</span>
            <span>📍 {empleado.sitio?.titulo || 'Sin sitio'}</span>
          </div>
        </div>
        <AnilloPorcentaje porcentaje={pctExpediente} size={64} fgColor="#fff" trackColor="rgba(255,255,255,.3)"
          label={`Expediente\n${requeridosCubiertos.length}/${requeridos.length} docs`} />
      </div>

      {msg && <p style={{ fontSize: 12, color: 'var(--muted)', marginBottom: 12 }}>{msg}</p>}

      {/* Pestañas al estilo sistema Lobo */}
      <div style={{ display: 'flex', gap: 0, borderBottom: '2px solid var(--border)', marginBottom: 20, overflowX: 'auto' }}>
        {TABS.map(t => (
          <button key={t.k} onClick={() => setTab(t.k)} style={{
            padding: '10px 16px', border: 'none', whiteSpace: 'nowrap',
            background: tab === t.k ? 'var(--accent-light)' : 'transparent',
            color: tab === t.k ? 'var(--accent)' : 'var(--muted)',
            fontWeight: tab === t.k ? 800 : 500,
            borderBottom: tab === t.k ? '3px solid var(--accent)' : '3px solid transparent',
            cursor: 'pointer', fontSize: 13, marginBottom: -2,
          }}>{t.label}</button>
        ))}
      </div>

      {tab === 'resumen' && (
        <>
          <div className="kpi-grid">
            <KpiCard label="Puesto actual" value={empleado.puesto?.titulo || '—'} sub={empleado.tipo_empleado || 'Sin tipo asignado'} />
            <KpiCard label="Antigüedad" value={antiguedad(empleado.fecha_alta)} sub={`Desde ${fmtFecha(empleado.fecha_alta) || '—'}`} />
            <KpiCard label="Sitio principal" value={empleado.sitio?.titulo || '—'} sub={empleado.sitio?.tipo_sitio || ''} />
            <KpiCard label="Expediente" value={`${Math.round(pctExpediente * 100)}%`}
              sub={`${requeridosCubiertos.length}/${requeridos.length} docs obligatorios`}
              color={pctExpediente === 1 ? 'var(--green)' : pctExpediente >= 0.6 ? 'var(--gold)' : 'var(--red)'}
              onClick={() => setTab('documentos')} />
            <KpiCard label="Vacaciones disponibles" value={`${totalDisponibles} días`} sub={`${aniosLaborales.length} año(s) laboral(es) · LFT Art. 76`}
              color="var(--accent2)" onClick={() => setTab('vacaciones')} />
          </div>

          <div className="card">
            <h3 style={tituloConLinea}>💼 Información laboral</h3>
            <div style={gridAuto}>
              <Campo label="Régimen de pago" valor={empleado.regimen_pago} />
              <Campo label="Ciclo de pago" valor={empleado.ciclo_pago} />
              <Campo label="Sociedad pagadora" valor={empleado.sociedad?.titulo} />
              <Campo label="Banco" valor={empleado.banco?.nombre} />
            </div>
          </div>

          <div className="card">
            <h3 style={tituloConLinea}>📄 Documentos recientes</h3>
            <TablaWrap>
              <table>
                <thead><tr><th>Tipo</th><th>Vigencia</th><th>Registrado</th><th></th></tr></thead>
                <tbody>
                  {documentos.length === 0 && <tr><td colSpan="4" className="empty">Sin documentos registrados.</td></tr>}
                  {documentos.slice(0, 4).map(d => (
                    <tr key={d.id}>
                      <td>{d.tipo?.titulo || '—'}</td>
                      <td>{fmtFecha(d.vigencia_hasta) || '—'}</td>
                      <td>{fmtFecha(d.creado_en)}</td>
                      <td style={{ textAlign: 'right' }}><ArchivoLink path={d.url_almacen} /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          </div>

          <div className="card">
            <h3 style={tituloConLinea}>📜 Actividad reciente</h3>
            {movimientos.length === 0 && <p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin movimientos registrados.</p>}
            {movimientos.slice(0, 5).map(m => (
              <div key={m.id} style={{ fontSize: 12, padding: '6px 0', borderBottom: '1px solid var(--border)' }}>
                <strong>{m.tipo_movimiento}</strong>{m.campo ? ` · ${m.campo}` : ''} — {fmtFecha(m.fecha_efectiva)}
              </div>
            ))}
          </div>
        </>
      )}

      {tab === 'laboral' && (
        <>
          {puedeDarBaja && (
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
              {empleado.activo
                ? <button className="btn red sm" onClick={() => setBajaModalOpen(true)}>Dar de baja</button>
                : <button className="btn green sm" onClick={reactivar}>Reactivar empleado</button>}
            </div>
          )}

          <div className="card">
            <CardHeader titulo="Información laboral" icono="💼" onEditar={puedeEditar ? () => setEditSectionKey('laboral') : undefined} />
            <div style={gridAuto}>
              <Campo label="Folio" valor={'#' + empleado.folio} />
              <Campo label="Estado" valor={<Badge estado={empleado.activo ? 'activo' : 'inactivo'}>{empleado.activo ? 'ACTIVO' : 'BAJA'}</Badge>} />
              <Campo label="Tipo de empleado" valor={empleado.tipo_empleado} />
              <Campo label="Tipo de personal" valor={empleado.tipo_personal?.descripcion} />
              <Campo label="Puesto principal" valor={empleado.puesto?.titulo} />
              <Campo label="Sitio principal" valor={empleado.sitio?.titulo} />
              <Campo label="Régimen de pago" valor={empleado.regimen_pago} />
              <Campo label="Ciclo de pago" valor={empleado.ciclo_pago} />
              <Campo label="Sociedad pagadora" valor={empleado.sociedad?.titulo} />
              <Campo label="Fecha de alta" valor={fmtFecha(empleado.fecha_alta)} />
              {!empleado.activo && <Campo label="Fecha de baja" valor={fmtFecha(empleado.fecha_baja)} />}
              {!empleado.activo && <Campo label="Motivo de baja" valor={empleado.motivo_baja} />}
              <Campo label="Recomendado por" valor={empleado.recomendado_por} />
              <Campo label="Fecha de antigüedad" valor={fmtFecha(empleado.fecha_antiguedad)} />
            </div>
          </div>

          <div className="card">
            <CardHeader titulo="Datos bancarios" icono="🏦" onEditar={puedeEditar ? () => setCuentaModalOpen(true) : undefined} />
            <div style={gridAuto}>
              <Campo label="Banco" valor={empleado.banco?.nombre} />
              <Campo label="Cuenta" valor={<span className="mono">{empleado.cuenta_bancaria}</span>} />
              <Campo label="CLABE" valor={<span className="mono">{empleado.clabe}</span>} />
            </div>
            <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 12 }}>
              La cuenta no se edita directamente — "Editar" abre una <strong>solicitud de cambio</strong> que queda pendiente de aprobación (control antifraude del sistema original).
            </p>
            {cambiosCuenta.length > 0 && (
              <TablaWrap>
                <table>
                  <thead><tr><th>Banco nuevo</th><th>Cuenta nueva</th><th>Motivo</th><th>Estado</th><th>Solicitada</th><th></th></tr></thead>
                  <tbody>
                    {cambiosCuenta.map(c => (
                      <tr key={c.id}>
                        <td style={{ fontSize: 12 }}>{c.banco?.nombre || '—'}</td>
                        <td className="mono">{c.numero_cuenta_nuevo}</td>
                        <td style={{ fontSize: 12, color: 'var(--muted)' }}>{c.motivo || '—'}</td>
                        <td><Badge estado={c.status === 'aprobado' ? 'activo' : c.status === 'rechazado' ? 'vencido' : 'pendiente'}>{c.status.toUpperCase()}</Badge></td>
                        <td style={{ fontSize: 12 }}>{fmtFecha(c.solicitado_en)}</td>
                        <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                          {c.status === 'pendiente' && puedeEditar && (
                            <>
                              <button className="btn green sm" style={{ marginRight: 6 }} onClick={() => resolverCambioCuenta(c, true)}>Aprobar</button>
                              <button className="btn ghost sm" onClick={() => resolverCambioCuenta(c, false)}>Rechazar</button>
                            </>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </TablaWrap>
            )}
          </div>

          <div className="card">
            <h3 style={tituloConLinea}>⏱️ Puntualidad global</h3>
            <Semaforo porcentaje={empleado.porcentaje_puntualidad_global || 0} />
          </div>
        </>
      )}

      {tab === 'personal' && (
        <>
          <div className="card">
            <CardHeader titulo="Identidad" icono="🪪" onEditar={puedeEditar ? () => setEditSectionKey('identidad') : undefined} />
            <div style={gridAuto}>
              <Campo label="RFC" valor={empleado.rfc && <span className="mono">{empleado.rfc}</span>} />
              <Campo label="CURP" valor={empleado.curp && <span className="mono">{empleado.curp}</span>} />
              <Campo label="Fecha de nacimiento" valor={fmtFecha(empleado.fecha_nacimiento)} />
              <Campo label="Estado de nacimiento" valor={empleado.estado_nacimiento} />
              <Campo label="Sexo" valor={SEXO_LABEL[empleado.sexo]} />
              <Campo label="Estado civil" valor={empleado.estado_civil} />
              <Campo label="Tipo de sangre" valor={empleado.tipo_sangre} />
              <Campo label="Estatura" valor={empleado.estatura ? `${empleado.estatura} m` : null} />
              <Campo label="Talla" valor={empleado.talla} />
            </div>
          </div>

          <div className="card">
            <CardHeader titulo="Domicilio" icono="🏠" onEditar={puedeEditar ? () => setEditSectionKey('domicilio') : undefined} />
            <div style={gridAuto}>
              <Campo label="Calle y número" valor={[empleado.calle, empleado.numero_exterior].filter(Boolean).join(' #') + (empleado.numero_interior ? ` int. ${empleado.numero_interior}` : '')} />
              <Campo label="Colonia" valor={empleado.colonia} />
              <Campo label="Código postal" valor={empleado.codigo_postal} />
              <Campo label="Municipio / Alcaldía" valor={empleado.delegacion_municipio} />
              <Campo label="Estado" valor={empleado.estado_provincia} />
              <Campo label="Teléfono" valor={empleado.telefono} />
              <Campo label="Correo" valor={empleado.correo} />
            </div>
          </div>

          <div className="card">
            <CardHeader titulo="Documentos de identidad (folio)" icono="🗂️" onEditar={puedeEditar ? () => setEditSectionKey('docsIdentidad') : undefined} />
            <div style={gridAuto}>
              <Campo label="Credencial de elector" valor={empleado.credencial_elector} />
              <Campo label="Cartilla militar" valor={empleado.cartilla} />
            </div>
          </div>

          <div className="card">
            <CardHeader titulo="Perfil académico" icono="🎓" onEditar={puedeEditar ? () => setEditSectionKey('academico') : undefined} />
            <div style={gridAuto}>
              <Campo label="Grado de estudios" valor={empleado.grado_estudios} />
              <Campo label="Licenciatura / curso" valor={empleado.licenciatura_curso} />
              <Campo label="Idiomas" valor={empleado.idiomas} />
            </div>
          </div>

          <div className="card">
            <CardHeader titulo="Emergencia y salud" icono="🚑" onEditar={puedeEditar ? () => setEditSectionKey('emergencia') : undefined} />
            <div style={gridAuto}>
              <Campo label="Contacto de emergencia" valor={empleado.contacto_emergencia} />
              <Campo label="Datos médicos" valor={empleado.datos_medicos} />
            </div>
          </div>
        </>
      )}

      {tab === 'documentos' && (
        <>
          <div className="card">
            <h3 style={tituloConLinea}>📄 Documentos obligatorios ({requeridosCubiertos.length}/{requeridos.length})</h3>
            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
              {requeridos.map(t => {
                const ok = documentos.some(d => d.tipo_documento_id === t.id);
                return (
                  <span key={t.id} style={{
                    display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, fontWeight: 600,
                    padding: '6px 12px', borderRadius: 8,
                    background: ok ? '#E6F7EF' : '#F3F4F6', color: ok ? 'var(--green)' : 'var(--muted)',
                  }}>
                    {ok ? '✓' : '○'} {t.titulo}
                  </span>
                );
              })}
              {requeridos.length === 0 && <span style={{ fontSize: 12, color: 'var(--muted)' }}>No hay tipos de documento marcados como obligatorios en el catálogo.</span>}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
            <button className="btn sm" onClick={() => setDocModalOpen(true)}>📤 Subir documento</button>
          </div>

          <TablaWrap>
            <table>
              <thead><tr><th>Tipo</th><th>Vigencia</th><th>Observaciones</th><th>Registrado</th><th></th></tr></thead>
              <tbody>
                {documentos.length === 0 && <tr><td colSpan="5" className="empty">Sin documentos registrados.</td></tr>}
                {documentos.map(d => (
                  <tr key={d.id}>
                    <td>{d.tipo?.titulo || '—'} {d.tipo?.requerido_alta && <Badge estado="proceso">OBLIGATORIO</Badge>}</td>
                    <td>{fmtFecha(d.vigencia_hasta) || '—'}</td>
                    <td style={{ fontSize: 12, color: 'var(--muted)' }}>{d.observaciones || '—'}</td>
                    <td>{fmtFecha(d.creado_en)}</td>
                    <td style={{ textAlign: 'right' }}><ArchivoLink path={d.url_almacen} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
          <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 10 }}>
            Los archivos se guardan en un bucket privado de Supabase Storage (no público) — los enlaces "Ver ↗" son URLs firmadas que expiran en 1 hora, igual que el resto de datos sensibles del expediente.
          </p>
        </>
      )}

      {tab === 'vacaciones' && (
        <>
          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 10 }}>
              <div>
                <h3 style={{ margin: 0 }}>🏖️ Saldo de vacaciones</h3>
                <p style={{ fontSize: 12, color: 'var(--muted)', margin: '4px 0 0' }}>
                  {aniosLaborales.length} año{aniosLaborales.length === 1 ? '' : 's'} laboral{aniosLaborales.length === 1 ? '' : 'es'} · {totalDisponibles} días disponibles en total
                </p>
              </div>
              <button className="btn sm" onClick={() => setVacModalOpen(true)}>+ Registrar período</button>
            </div>
          </div>

          {aniosLaborales.length === 0 && (
            <div className="card"><p style={{ fontSize: 12, color: 'var(--muted)' }}>Este empleado todavía no cumple su primer año laboral (LFT Art. 76 otorga el primer bloque de días al cumplir 1 año de servicio).</p></div>
          )}
          {aniosLaborales.map(a => (
            <div key={a.anio} className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8, flexWrap: 'wrap', gap: 8 }}>
                <div>
                  <strong>Año {a.anio}</strong>
                  <span style={{ fontSize: 12, color: 'var(--muted)', marginLeft: 8 }}>{fmtFecha(a.fecha_inicio)} — {fmtFecha(a.fecha_fin)}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Badge estado={a.vencido ? 'inactivo' : 'activo'}>{a.vencido ? 'VENCIDO' : 'VIGENTE'}</Badge>
                  <strong style={{ fontSize: 15 }}>{a.tomados}/{a.derecho} días</strong>
                </div>
              </div>
              <Semaforo porcentaje={a.derecho ? Math.min(1, a.tomados / a.derecho) : 0} />
            </div>
          ))}

          <div className="card">
            <h3 style={tituloConLinea}>🗓️ Períodos tomados</h3>
            <TablaWrap>
              <table>
                <thead><tr><th>Año</th><th>Período</th><th>Días</th><th>Prima vacacional</th><th>Estado</th><th></th></tr></thead>
                <tbody>
                  {vacaciones.length === 0 && <tr><td colSpan="6" className="empty">Sin períodos registrados.</td></tr>}
                  {vacaciones.map(v => (
                    <tr key={v.id}>
                      <td>{v.anio_laboral}</td>
                      <td>{fmtFecha(v.fecha_inicio)} — {fmtFecha(v.fecha_fin)}</td>
                      <td>{v.dias}</td>
                      <td className="mono">${Number(v.prima_vacacional).toLocaleString('es-MX')}</td>
                      <td><Badge estado={v.estado === 'cancelada' ? 'vencido' : v.estado === 'autorizada' ? 'proceso' : 'activo'}>{v.estado.toUpperCase()}</Badge></td>
                      <td style={{ textAlign: 'right' }}>{v.estado !== 'cancelada' && <button className="btn ghost sm" onClick={() => cancelarVacacion(v.id)}>Cancelar</button>}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          </div>

          <details className="card">
            <summary style={{ fontWeight: 700, fontSize: 13, cursor: 'pointer' }}>📖 Guía de vacaciones — LFT Art. 76 y 80 (reforma 2023)</summary>
            <div style={{ marginTop: 14, fontSize: 12, color: 'var(--muted)', lineHeight: 1.7 }}>
              <p>La Ley Federal del Trabajo (Art. 76, reforma de "vacaciones dignas" vigente desde 2023) obliga a dar 12 días de vacaciones desde el primer año cumplido, con incrementos cada año hasta el quinto, y luego +2 días cada 5 años de antigüedad. Además, el Art. 80 obliga a pagar una prima vacacional de al menos 25% sobre el salario de esos días.</p>
              <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 10 }}>
                <thead><tr>{LFT_TABLA.map(([l]) => <th key={l} style={{ fontSize: 10, textAlign: 'left', padding: '4px 8px', color: 'var(--muted)', borderBottom: '1px solid var(--border)' }}>{l}</th>)}</tr></thead>
                <tbody><tr>{LFT_TABLA.map(([l, d]) => <td key={l} style={{ padding: '6px 8px', fontWeight: 700, color: 'var(--text)' }}>{d} días</td>)}</tr></tbody>
              </table>
            </div>
          </details>
        </>
      )}

      {tab === 'capacitacion' && (
        <>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
            <button className="btn sm" onClick={() => setCapModalOpen(true)}>+ Registrar capacitación</button>
          </div>
          <TablaWrap>
            <table>
              <thead><tr><th>Título</th><th>Tipo</th><th>Institución</th><th>Horas</th><th>Fechas</th><th>Vigencia</th><th></th></tr></thead>
              <tbody>
                {capacitaciones.length === 0 && <tr><td colSpan="7" className="empty">Sin capacitaciones registradas.</td></tr>}
                {capacitaciones.map(c => (
                  <tr key={c.id}>
                    <td>{c.titulo}</td>
                    <td><Badge estado={CAP_TIPOS[c.tipo] || 'inactivo'}>{c.tipo.toUpperCase()}</Badge></td>
                    <td style={{ fontSize: 12 }}>{c.institucion || '—'}</td>
                    <td>{c.horas || '—'}</td>
                    <td style={{ fontSize: 12 }}>{fmtFecha(c.fecha_inicio)}{c.fecha_fin ? ' — ' + fmtFecha(c.fecha_fin) : ''}</td>
                    <td style={{ fontSize: 12 }}>{fmtFecha(c.vigencia_hasta) || '—'}</td>
                    <td style={{ textAlign: 'right' }}><ArchivoLink path={c.constancia_url} label="Constancia ↗" /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
        </>
      )}

      {tab === 'evaluaciones' && (
        <>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
            <button className="btn sm" onClick={() => setEvalModalOpen(true)}>+ Registrar evaluación</button>
          </div>
          {evaluaciones.length === 0 && <div className="card"><p style={{ fontSize: 12, color: 'var(--muted)' }}>Sin evaluaciones registradas.</p></div>}
          {evaluaciones.map(ev => (
            <div key={ev.id} className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: 8 }}>
                <div>
                  <strong>{ev.periodo}</strong>
                  <div style={{ fontSize: 12, color: 'var(--muted)' }}>
                    {fmtFecha(ev.fecha_evaluacion)}{ev.evaluador ? ` · Evaluó: ${ev.evaluador.nombre || ''} ${ev.evaluador.apellido_paterno || ''}`.trim() : ''}
                  </div>
                </div>
                {ev.calificacion != null && (
                  <div style={{ fontSize: 22, fontWeight: 900, color: ev.calificacion >= 8 ? 'var(--green)' : ev.calificacion >= 6 ? 'var(--gold)' : 'var(--red)' }}>
                    {ev.calificacion}/10
                  </div>
                )}
              </div>
              {(ev.fortalezas || ev.areas_oportunidad || ev.comentarios) && (
                <div style={{ marginTop: 10, display: 'grid', gap: 6, fontSize: 12 }}>
                  {ev.fortalezas && <div><strong>Fortalezas:</strong> {ev.fortalezas}</div>}
                  {ev.areas_oportunidad && <div><strong>Áreas de oportunidad:</strong> {ev.areas_oportunidad}</div>}
                  {ev.comentarios && <div><strong>Comentarios:</strong> {ev.comentarios}</div>}
                </div>
              )}
            </div>
          ))}
        </>
      )}

      {tab === 'beneficios' && (
        <>
          <div className="card">
            <h3 style={tituloConLinea}>❤️ Catálogo de prestaciones del tenant</h3>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {tiposBeneficio.map(t => {
                const asignado = beneficios.some(b => b.tipo_beneficio_id === t.id && b.activo);
                return (
                  <span key={t.id} title={t.descripcion} style={{
                    fontSize: 12, fontWeight: 600, padding: '6px 12px', borderRadius: 8,
                    background: asignado ? '#E6F7EF' : '#F3F4F6', color: asignado ? 'var(--green)' : 'var(--muted)',
                  }}>{asignado ? '✓' : '○'} {t.titulo}</span>
                );
              })}
              {tiposBeneficio.length === 0 && <span style={{ fontSize: 12, color: 'var(--muted)' }}>Sin catálogo de prestaciones configurado para este tenant.</span>}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
            <button className="btn sm" onClick={() => setBenModalOpen(true)}>+ Asignar beneficio</button>
          </div>

          <TablaWrap>
            <table>
              <thead><tr><th>Beneficio</th><th>Desde</th><th>Hasta</th><th>Monto</th><th>Estado</th><th></th></tr></thead>
              <tbody>
                {beneficios.length === 0 && <tr><td colSpan="6" className="empty">Sin beneficios asignados.</td></tr>}
                {beneficios.map(b => (
                  <tr key={b.id}>
                    <td>{b.tipo?.titulo || '—'}</td>
                    <td>{fmtFecha(b.fecha_inicio)}</td>
                    <td>{fmtFecha(b.fecha_fin) || '—'}</td>
                    <td className="mono">{b.monto != null ? '$' + Number(b.monto).toLocaleString('es-MX') : '—'}</td>
                    <td><Badge estado={b.activo ? 'activo' : 'inactivo'}>{b.activo ? 'ACTIVO' : 'DADO DE BAJA'}</Badge></td>
                    <td style={{ textAlign: 'right' }}>{b.activo && <button className="btn ghost sm" onClick={() => darBajaBeneficio(b.id)}>Dar de baja</button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TablaWrap>
        </>
      )}

      {tab === 'plazas' && (
        <TablaWrap>
          <table>
            <thead><tr><th>Puesto</th><th>Puntualidad</th><th>Estado</th></tr></thead>
            <tbody>
              {plazas.length === 0 && <tr><td colSpan="3" className="empty">Sin plazas adicionales registradas.</td></tr>}
              {plazas.map(p => (
                <tr key={p.id}>
                  <td>{p.puesto?.titulo || '—'}</td>
                  <td style={{ maxWidth: 220 }}>{p.porcentaje_puntualidad != null ? <Semaforo porcentaje={p.porcentaje_puntualidad} /> : '—'}</td>
                  <td><Badge estado={p.activo ? 'activo' : 'inactivo'}>{p.activo ? 'ACTIVA' : 'INACTIVA'}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      )}

      {tab === 'asistencia' && (
        <TablaWrap>
          <table>
            <thead><tr><th>Fecha</th><th>Tipo</th><th>Medio</th><th>Regla aplicada</th></tr></thead>
            <tbody>
              {asistencia.length === 0 && <tr><td colSpan="4" className="empty">Sin registros de asistencia.</td></tr>}
              {asistencia.map(a => (
                <tr key={a.id}>
                  <td>{fmtFechaHora(a.ts_servidor)}</td>
                  <td><Badge estado={a.tipo_marcaje === 'entrada' ? 'activo' : 'proceso'}>{a.tipo_marcaje?.toUpperCase()}</Badge></td>
                  <td style={{ fontSize: 12 }}>{a.medio_asistencia}</td>
                  <td style={{ fontSize: 12, color: 'var(--muted)' }}>{a.regla_aplicada || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      )}

      {tab === 'nomina' && (
        <TablaWrap>
          <table>
            <thead><tr><th>Periodo</th><th>Ciclo</th><th>Reservaciones</th><th>Bruto</th><th>Neto</th><th>Estatus</th></tr></thead>
            <tbody>
              {nomina.length === 0 && <tr><td colSpan="6" className="empty">Sin recibos de nómina.</td></tr>}
              {nomina.map(n => (
                <tr key={n.id}>
                  <td>{fmtFecha(n.periodo?.fecha_desde)} — {fmtFecha(n.periodo?.fecha_hasta)}</td>
                  <td style={{ fontSize: 12 }}>{n.periodo?.ciclo_pago}</td>
                  <td>{n.reservaciones_cnt}</td>
                  <td className="mono">${Number(n.monto_bruto).toLocaleString('es-MX')}</td>
                  <td className="mono">${Number(n.monto_neto).toLocaleString('es-MX')}</td>
                  <td><Badge estado={n.estatus_pago === 'pagado' ? 'activo' : n.estatus_pago === 'cancelado' ? 'vencido' : 'pendiente'}>{n.estatus_pago?.toUpperCase()}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      )}

      {tab === 'movimientos' && (
        <TablaWrap>
          <table>
            <thead><tr><th>Fecha</th><th>Tipo</th><th>Campo</th><th>Antes → Después</th><th>Motivo</th></tr></thead>
            <tbody>
              {movimientos.length === 0 && <tr><td colSpan="5" className="empty">Sin movimientos registrados.</td></tr>}
              {movimientos.map(m => (
                <tr key={m.id}>
                  <td>{fmtFecha(m.fecha_efectiva)}</td>
                  <td>{m.tipo_movimiento}</td>
                  <td style={{ fontSize: 12 }}>{m.campo || '—'}</td>
                  <td style={{ fontSize: 12 }}>{m.valor_anterior || '—'} → {m.valor_nuevo || '—'}</td>
                  <td style={{ fontSize: 12, color: 'var(--muted)' }}>{m.motivo || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </TablaWrap>
      )}

      {/* Modal: subir documento */}
      <Modal open={docModalOpen} onClose={() => setDocModalOpen(false)} title="Subir documento"
        footer={<><button className="btn ghost" onClick={() => setDocModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregarDocumento}>Guardar</button></>}>
        <form onSubmit={agregarDocumento} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Tipo de documento</label>
            <select className="field" value={nuevoDoc.tipo_documento_id} onChange={e => setNuevoDoc({ ...nuevoDoc, tipo_documento_id: e.target.value })}>
              <option value="">Elegí un tipo…</option>
              {tiposDoc.map(t => <option key={t.id} value={t.id}>{t.titulo}{t.requerido_alta ? ' (obligatorio)' : ''}</option>)}
            </select>
          </div>
          <div>
            <label className="label">Archivo</label>
            <input type="file" className="field" onChange={e => setArchivoDoc(e.target.files?.[0] || null)} />
          </div>
          <div>
            <label className="label">Vigencia hasta (opcional)</label>
            <input type="date" className="field" value={nuevoDoc.vigencia_hasta} onChange={e => setNuevoDoc({ ...nuevoDoc, vigencia_hasta: e.target.value })} />
          </div>
          <div>
            <label className="label">Observaciones (opcional)</label>
            <input className="field" value={nuevoDoc.observaciones} onChange={e => setNuevoDoc({ ...nuevoDoc, observaciones: e.target.value })} />
          </div>
        </form>
      </Modal>

      {/* Modal: registrar período de vacaciones */}
      <Modal open={vacModalOpen} onClose={() => setVacModalOpen(false)} title="Registrar período de vacaciones"
        footer={<><button className="btn ghost" onClick={() => setVacModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregarVacacion}>Guardar</button></>}>
        <form onSubmit={agregarVacacion} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Año laboral</label>
            <select className="field" value={nuevoVac.anio_laboral} onChange={e => setNuevoVac({ ...nuevoVac, anio_laboral: e.target.value })}>
              <option value="">Elegí un año…</option>
              {aniosLaborales.map(a => <option key={a.anio} value={a.anio}>Año {a.anio} ({a.disponibles} días disponibles)</option>)}
            </select>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Fecha de inicio</label><input type="date" className="field" value={nuevoVac.fecha_inicio} onChange={e => setNuevoVac({ ...nuevoVac, fecha_inicio: e.target.value })} /></div>
            <div><label className="label">Fecha de fin</label><input type="date" className="field" value={nuevoVac.fecha_fin} onChange={e => setNuevoVac({ ...nuevoVac, fecha_fin: e.target.value })} /></div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Días</label><input type="number" min="0.5" step="0.5" className="field" value={nuevoVac.dias} onChange={e => setNuevoVac({ ...nuevoVac, dias: e.target.value })} /></div>
            <div>
              <label className="label">Prima vacacional (25% LFT Art. 80)</label>
              <input type="number" min="0" step="0.01" className="field" value={nuevoVac.prima_vacacional} onChange={e => setNuevoVac({ ...nuevoVac, prima_vacacional: e.target.value })} />
              {empleado.puesto?.pago_default > 0 && nuevoVac.dias && (
                <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }}>
                  Sugerencia: ${(Number(nuevoVac.dias) * empleado.puesto.pago_default * 0.25).toLocaleString('es-MX', { maximumFractionDigits: 2 })} (25% de {nuevoVac.dias} día(s) a ${empleado.puesto.pago_default}/día del puesto)
                </p>
              )}
            </div>
          </div>
          <div><label className="label">Observaciones (opcional)</label><input className="field" value={nuevoVac.observaciones} onChange={e => setNuevoVac({ ...nuevoVac, observaciones: e.target.value })} /></div>
        </form>
      </Modal>

      {/* Modal: registrar capacitación */}
      <Modal open={capModalOpen} onClose={() => setCapModalOpen(false)} title="Registrar capacitación"
        footer={<><button className="btn ghost" onClick={() => setCapModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregarCapacitacion}>Guardar</button></>}>
        <form onSubmit={agregarCapacitacion} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Título</label><input className="field" value={nuevoCap.titulo} onChange={e => setNuevoCap({ ...nuevoCap, titulo: e.target.value })} /></div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div>
              <label className="label">Tipo</label>
              <select className="field" value={nuevoCap.tipo} onChange={e => setNuevoCap({ ...nuevoCap, tipo: e.target.value })}>
                <option value="interna">Interna</option><option value="externa">Externa</option><option value="certificacion">Certificación</option>
              </select>
            </div>
            <div><label className="label">Institución</label><input className="field" value={nuevoCap.institucion} onChange={e => setNuevoCap({ ...nuevoCap, institucion: e.target.value })} /></div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
            <div><label className="label">Horas</label><input type="number" min="0" step="0.5" className="field" value={nuevoCap.horas} onChange={e => setNuevoCap({ ...nuevoCap, horas: e.target.value })} /></div>
            <div><label className="label">Inicio</label><input type="date" className="field" value={nuevoCap.fecha_inicio} onChange={e => setNuevoCap({ ...nuevoCap, fecha_inicio: e.target.value })} /></div>
            <div><label className="label">Fin</label><input type="date" className="field" value={nuevoCap.fecha_fin} onChange={e => setNuevoCap({ ...nuevoCap, fecha_fin: e.target.value })} /></div>
          </div>
          <div><label className="label">Vigencia hasta (opcional)</label><input type="date" className="field" value={nuevoCap.vigencia_hasta} onChange={e => setNuevoCap({ ...nuevoCap, vigencia_hasta: e.target.value })} /></div>
          <div><label className="label">Constancia (opcional)</label><input type="file" className="field" onChange={e => setArchivoCap(e.target.files?.[0] || null)} /></div>
          <div><label className="label">Observaciones (opcional)</label><input className="field" value={nuevoCap.observaciones} onChange={e => setNuevoCap({ ...nuevoCap, observaciones: e.target.value })} /></div>
        </form>
      </Modal>

      {/* Modal: registrar evaluación */}
      <Modal open={evalModalOpen} onClose={() => setEvalModalOpen(false)} title="Registrar evaluación de desempeño"
        footer={<><button className="btn ghost" onClick={() => setEvalModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregarEvaluacion}>Guardar</button></>}>
        <form onSubmit={agregarEvaluacion} style={{ display: 'grid', gap: 12 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
            <div><label className="label">Período</label><input className="field" placeholder="2026-T1" value={nuevoEval.periodo} onChange={e => setNuevoEval({ ...nuevoEval, periodo: e.target.value })} /></div>
            <div><label className="label">Fecha</label><input type="date" className="field" value={nuevoEval.fecha_evaluacion} onChange={e => setNuevoEval({ ...nuevoEval, fecha_evaluacion: e.target.value })} /></div>
            <div><label className="label">Calificación (0–10)</label><input type="number" min="0" max="10" step="0.1" className="field" value={nuevoEval.calificacion} onChange={e => setNuevoEval({ ...nuevoEval, calificacion: e.target.value })} /></div>
          </div>
          <div><label className="label">Fortalezas</label><input className="field" value={nuevoEval.fortalezas} onChange={e => setNuevoEval({ ...nuevoEval, fortalezas: e.target.value })} /></div>
          <div><label className="label">Áreas de oportunidad</label><input className="field" value={nuevoEval.areas_oportunidad} onChange={e => setNuevoEval({ ...nuevoEval, areas_oportunidad: e.target.value })} /></div>
          <div><label className="label">Comentarios</label><input className="field" value={nuevoEval.comentarios} onChange={e => setNuevoEval({ ...nuevoEval, comentarios: e.target.value })} /></div>
        </form>
      </Modal>

      {/* Modal: asignar beneficio */}
      <Modal open={benModalOpen} onClose={() => setBenModalOpen(false)} title="Asignar beneficio"
        footer={<><button className="btn ghost" onClick={() => setBenModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={asignarBeneficio}>Guardar</button></>}>
        <form onSubmit={asignarBeneficio} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Beneficio</label>
            <select className="field" value={nuevoBen.tipo_beneficio_id} onChange={e => setNuevoBen({ ...nuevoBen, tipo_beneficio_id: e.target.value })}>
              <option value="">Elegí un beneficio…</option>
              {tiposBeneficio.map(t => <option key={t.id} value={t.id}>{t.titulo}</option>)}
            </select>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Desde</label><input type="date" className="field" value={nuevoBen.fecha_inicio} onChange={e => setNuevoBen({ ...nuevoBen, fecha_inicio: e.target.value })} /></div>
            <div><label className="label">Monto (opcional)</label><input type="number" min="0" step="0.01" className="field" value={nuevoBen.monto} onChange={e => setNuevoBen({ ...nuevoBen, monto: e.target.value })} /></div>
          </div>
          <div><label className="label">Observaciones (opcional)</label><input className="field" value={nuevoBen.observaciones} onChange={e => setNuevoBen({ ...nuevoBen, observaciones: e.target.value })} /></div>
        </form>
      </Modal>

      {/* Modal genérico: editar sección (Información laboral, Identidad, Domicilio, etc.) */}
      <EditSectionModal open={!!editSectionKey} onClose={() => setEditSectionKey(null)}
        section={editSectionKey ? secciones[editSectionKey] : null} values={empleado} onSave={guardarSeccion} />

      {/* Modal: dar de baja */}
      <Modal open={bajaModalOpen} onClose={() => setBajaModalOpen(false)} title="Dar de baja al empleado"
        footer={<><button className="btn ghost" onClick={() => setBajaModalOpen(false)}>Cancelar</button>
                <button className="btn red" onClick={confirmarBaja}>Dar de baja</button></>}>
        <form onSubmit={confirmarBaja} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Fecha de baja</label><input type="date" className="field" value={bajaForm.fecha_baja} onChange={e => setBajaForm({ ...bajaForm, fecha_baja: e.target.value })} /></div>
          <div><label className="label">Motivo</label><input className="field" value={bajaForm.motivo_baja} onChange={e => setBajaForm({ ...bajaForm, motivo_baja: e.target.value })} /></div>
        </form>
      </Modal>

      {/* Modal: solicitar cambio de cuenta bancaria (queda pendiente de aprobación) */}
      <Modal open={cuentaModalOpen} onClose={() => setCuentaModalOpen(false)} title="Solicitar cambio de cuenta bancaria"
        footer={<><button className="btn ghost" onClick={() => setCuentaModalOpen(false)}>Cancelar</button>
                <button className="btn" onClick={solicitarCambioCuenta}>Enviar solicitud</button></>}>
        <form onSubmit={solicitarCambioCuenta} style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Banco nuevo</label>
            <select className="field" value={nuevaCuenta.banco_id_nuevo} onChange={e => setNuevaCuenta({ ...nuevaCuenta, banco_id_nuevo: e.target.value })}>
              <option value="">Elegí un banco…</option>
              {catBancos.map(b => <option key={b.id} value={b.id}>{b.nombre}</option>)}
            </select>
          </div>
          <div><label className="label">Cuenta nueva</label><input className="field" value={nuevaCuenta.numero_cuenta_nuevo} onChange={e => setNuevaCuenta({ ...nuevaCuenta, numero_cuenta_nuevo: e.target.value })} /></div>
          <div><label className="label">CLABE nueva (opcional)</label><input className="field mono" value={nuevaCuenta.clabe_nueva} onChange={e => setNuevaCuenta({ ...nuevaCuenta, clabe_nueva: e.target.value })} /></div>
          <div><label className="label">Motivo (opcional)</label><input className="field" value={nuevaCuenta.motivo} onChange={e => setNuevaCuenta({ ...nuevaCuenta, motivo: e.target.value })} /></div>
          <p style={{ fontSize: 11, color: 'var(--muted)' }}>La solicitud queda <strong>pendiente de aprobación</strong> — no reemplaza la cuenta actual hasta que alguien con permiso la apruebe.</p>
        </form>
      </Modal>
    </div>
  );
}
