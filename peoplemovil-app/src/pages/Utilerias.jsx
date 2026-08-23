import React, { useEffect, useMemo, useState } from 'react';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Modal from '../components/ui/Modal.jsx';
import Chip from '../components/ui/Chip.jsx';
import Badge from '../components/ui/Badge.jsx';
import { supabase, supabaseReady } from '../lib/supabase.js';
import { useModuleAudit } from '../lib/audit.js';

// Explorador de datos — herramienta de soporte técnico.
// Permite consultar cualquier tabla del schema sin ir a producción Supabase.
// RLS del tenant sigue aplicando: solo verás filas del tenant activo.

const TABLAS = [
  // Operativo
  { table: 'te_pedidos',                grupo: 'Operativo',    label: 'Pedidos' },
  { table: 'te_pedidos_detalle',        grupo: 'Operativo',    label: 'Pedidos detalle' },
  { table: 'te_reservaciones',          grupo: 'Operativo',    label: 'Reservaciones' },
  { table: 'te_eventos_biometricos',    grupo: 'Operativo',    label: 'Eventos biométricos (append-only)' },
  { table: 'te_reservacion_bitacora',   grupo: 'Operativo',    label: 'Bitácora de reservaciones' },
  // RH / personas
  { table: 'te_candidatos',             grupo: 'Personal',     label: 'Candidatos' },
  { table: 'te_empleados',              grupo: 'Personal',     label: 'Empleados' },
  { table: 'tr_empleado_plaza',         grupo: 'Personal',     label: 'Empleado ↔ plaza (certeza por puesto)' },
  { table: 'te_consentimientos',        grupo: 'Personal',     label: 'Consentimientos (append-only)' },
  { table: 'te_documentos_candidato',   grupo: 'Personal',     label: 'Documentos de candidato' },
  { table: 'te_documentos_empleado',    grupo: 'Personal',     label: 'Documentos de empleado' },
  { table: 'te_movimientos_empleado',   grupo: 'Personal',     label: 'Movimientos de empleado' },
  { table: 'te_agenda_freelance',       grupo: 'Personal',     label: 'Agenda de freelance' },
  { table: 'te_vacantes',               grupo: 'Personal',     label: 'Vacantes' },
  { table: 'tr_postulacion_candidato_vacante', grupo: 'Personal', label: 'Postulaciones' },
  { table: 'te_cursos_induccion',       grupo: 'Personal',     label: 'Cursos de inducción' },
  { table: 'tr_asistencia_curso',       grupo: 'Personal',     label: 'Asistencia a curso' },
  // Fiscal
  { table: 'te_nominas_periodo',        grupo: 'Fiscal',       label: 'Nóminas — periodos' },
  { table: 'te_nomina_detalle',         grupo: 'Fiscal',       label: 'Nómina detalle' },
  { table: 'te_extras_nomina',          grupo: 'Fiscal',       label: 'Extras de nómina' },
  { table: 'te_facturas_enc',           grupo: 'Fiscal',       label: 'Facturas encabezado' },
  { table: 'te_facturas_det',           grupo: 'Fiscal',       label: 'Facturas detalle' },
  { table: 'te_pagos_dispersion',       grupo: 'Fiscal',       label: 'Pagos dispersados' },
  { table: 'te_aclaraciones',           grupo: 'Fiscal',       label: 'Aclaraciones de pago' },
  // Catálogos
  { table: 'tc_sitios',                 grupo: 'Catálogos',    label: 'Sitios' },
  { table: 'tc_puestos',                grupo: 'Catálogos',    label: 'Puestos' },
  { table: 'tc_turnos',                 grupo: 'Catálogos',    label: 'Turnos' },
  { table: 'tc_bancos',                 grupo: 'Catálogos',    label: 'Bancos' },
  { table: 'tc_sociedades_pagadoras',   grupo: 'Catálogos',    label: 'Sociedades pagadoras' },
  { table: 'tc_sociedades_propias',     grupo: 'Catálogos',    label: 'Sociedades propias' },
  { table: 'tc_unidades_negocio',       grupo: 'Catálogos',    label: 'Unidades de negocio' },
  { table: 'tc_uniformes',              grupo: 'Catálogos',    label: 'Uniformes' },
  { table: 'tc_clientes',               grupo: 'Catálogos',    label: 'Clientes' },
  { table: 'tc_productos',              grupo: 'Catálogos',    label: 'Productos' },
  { table: 'tc_estaciones',             grupo: 'Catálogos',    label: 'Estaciones de checado' },
  { table: 'tc_dispositivos',           grupo: 'Catálogos',    label: 'Dispositivos biométricos' },
  { table: 'tc_responsables',           grupo: 'Catálogos',    label: 'Responsables' },
  { table: 'tc_fases_evento',           grupo: 'Catálogos',    label: 'Fases de evento' },
  { table: 'tc_tipos_personal',         grupo: 'Catálogos',    label: 'Tipos de personal' },
  { table: 'tc_tipos_documento',        grupo: 'Catálogos',    label: 'Tipos de documento' },
  { table: 'tc_causas_aclaracion',      grupo: 'Catálogos',    label: 'Causas de aclaración' },
  { table: 'tc_repse_registros',        grupo: 'Catálogos',    label: 'REPSE registros' },
  { table: 'tc_estados_mx',             grupo: 'Catálogos',    label: 'Estados MX' },
  // Sistema
  { table: 'te_tenants',                grupo: 'Sistema',      label: 'Tenants' },
  { table: 'tc_planes_suscripcion',     grupo: 'Sistema',      label: 'Planes de suscripción' },
  { table: 'te_suscripciones',          grupo: 'Sistema',      label: 'Suscripciones' },
  { table: 'tp_parametros_globales',    grupo: 'Sistema',      label: 'Parámetros globales' },
  { table: 'tp_avisos_privacidad',      grupo: 'Sistema',      label: 'Avisos de privacidad' },
  { table: 'tp_terminos_condiciones',   grupo: 'Sistema',      label: 'Términos y condiciones' },
  { table: 'tp_precios_producto',       grupo: 'Sistema',      label: 'Precios de producto' },
  { table: 'tp_pensiones_alimenticias', grupo: 'Sistema',      label: 'Pensiones alimenticias' },
  { table: 'tp_folios',                 grupo: 'Sistema',      label: 'Folios consecutivos' },
  { table: 'te_comunicados',            grupo: 'Sistema',      label: 'Comunicados' },
  { table: 'tr_comunicado_destinatario', grupo: 'Sistema',     label: 'Comunicados destinatarios' }
];

const GRUPOS = ['Operativo', 'Personal', 'Fiscal', 'Catálogos', 'Sistema'];
const PAGE_SIZE = 50;

export default function Utilerias() {
  useModuleAudit('utilerias');
  const [tablaActiva, setTablaActiva] = useState(TABLAS[0]);
  const [rows, setRows] = useState([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const [orderCol, setOrderCol] = useState(null);
  const [orderAsc, setOrderAsc] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [grupo, setGrupo] = useState('todos');
  const [detalle, setDetalle] = useState(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState(null);

  useEffect(() => { cargar(); }, [tablaActiva, page, orderCol, orderAsc]);
  async function cargar() {
    if (!supabaseReady) return;
    setLoading(true); setErr(null);
    let q = supabase.from(tablaActiva.table).select('*', { count: 'exact' })
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);
    if (orderCol) q = q.order(orderCol, { ascending: orderAsc });
    const { data, count, error } = await q;
    if (error) { setErr(error.message); setRows([]); setTotal(0); }
    else { setRows(data || []); setTotal(count || 0); }
    setLoading(false);
  }

  const columnas = rows[0] ? Object.keys(rows[0]) : [];
  const rowsFiltradas = useMemo(() => {
    if (!busqueda.trim()) return rows;
    const q = busqueda.toLowerCase();
    return rows.filter(r =>
      Object.values(r).some(v => v != null && String(v).toLowerCase().includes(q))
    );
  }, [rows, busqueda]);

  const tablasFiltradas = grupo === 'todos' ? TABLAS : TABLAS.filter(t => t.grupo === grupo);

  function ordenarPor(col) {
    if (orderCol === col) setOrderAsc(!orderAsc);
    else { setOrderCol(col); setOrderAsc(true); }
    setPage(0);
  }

  function exportarCSV() {
    if (rowsFiltradas.length === 0) return;
    const cols = Object.keys(rowsFiltradas[0]);
    const esc = v => v == null ? '' : `"${String(v).replace(/"/g, '""')}"`;
    const csv = [cols.join(','), ...rowsFiltradas.map(r => cols.map(c => esc(r[c])).join(','))].join('\n');
    const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `${tablaActiva.table}_${new Date().toISOString().slice(0,10)}.csv`;
    a.click();
  }

  const fmtCell = v => {
    if (v == null) return <span style={{ color: 'var(--muted)', fontStyle: 'italic' }}>null</span>;
    if (typeof v === 'boolean') return <Badge estado={v ? 'activo' : 'inactivo'}>{v ? 'TRUE' : 'FALSE'}</Badge>;
    if (typeof v === 'object') return <span className="mono" style={{ fontSize: 10 }}>{JSON.stringify(v).slice(0, 40)}…</span>;
    const s = String(v);
    return s.length > 60 ? s.slice(0, 60) + '…' : s;
  };

  return (
    <div>
      <div className="section-eyebrow">Soporte técnico / Dev</div>
      <h1>Utilerías · Explorador de datos</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Consulta cualquier tabla del schema sin salir de la app. Útil durante el arranque para dar soporte inmediato.
        <strong> RLS del tenant aplica</strong> — solo ves filas del tenant activo, aunque uses este panel.
      </p>

      <div className="chips">
        <Chip active={grupo === 'todos'} onClick={() => setGrupo('todos')}>Todos</Chip>
        {GRUPOS.map(g => <Chip key={g} active={grupo === g} onClick={() => setGrupo(grupo === g ? 'todos' : g)}>{g}</Chip>)}
      </div>

      <div className="card">
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 3fr auto', gap: 12, alignItems: 'end' }}>
          <div>
            <label className="label">Tabla</label>
            <select
              className="field"
              value={tablaActiva.table}
              onChange={e => { setTablaActiva(TABLAS.find(t => t.table === e.target.value)); setPage(0); setOrderCol(null); }}
            >
              {GRUPOS.map(g => {
                const items = tablasFiltradas.filter(t => t.grupo === g);
                if (!items.length) return null;
                return (
                  <optgroup key={g} label={g}>
                    {items.map(t => <option key={t.table} value={t.table}>{t.label} — {t.table}</option>)}
                  </optgroup>
                );
              })}
            </select>
          </div>
          <div>
            <label className="label">Búsqueda global (client-side)</label>
            <input className="field" placeholder="filtra en todos los campos visibles…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
          </div>
          <button className="btn outline" onClick={exportarCSV} disabled={rowsFiltradas.length === 0}>📥 Exportar CSV</button>
        </div>
        <div style={{ marginTop: 10, fontSize: 12, color: 'var(--muted)', display: 'flex', gap: 14, flexWrap: 'wrap' }}>
          <span><strong style={{ color: 'var(--text)' }}>{total.toLocaleString('es-MX')}</strong> filas en <code>{tablaActiva.table}</code></span>
          <span>Página {page + 1} de {Math.max(1, Math.ceil(total / PAGE_SIZE))}</span>
          {orderCol && <span>Orden: <code>{orderCol}</code> {orderAsc ? '↑' : '↓'}</span>}
          {loading && <span>cargando…</span>}
          {err && <Badge estado="vencido">{err}</Badge>}
        </div>
      </div>

      <TablaWrap>
        <table>
          <thead>
            <tr>
              {columnas.map(c => (
                <th key={c} style={{ cursor: 'pointer', whiteSpace: 'nowrap' }} onClick={() => ordenarPor(c)}>
                  {c} {orderCol === c && (orderAsc ? '↑' : '↓')}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rowsFiltradas.length === 0 && (
              <tr><td colSpan={columnas.length || 1} className="empty">
                {loading ? 'Cargando…' : (err ? err : (busqueda ? 'Sin coincidencias en la página actual.' : 'Tabla vacía o RLS filtra todo (tenant sin datos).'))}
              </td></tr>
            )}
            {rowsFiltradas.map((r, i) => (
              <tr key={i} className="clickable" onClick={() => setDetalle(r)}>
                {columnas.map(c => <td key={c}>{fmtCell(r[c])}</td>)}
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      {/* Paginador */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 }}>
        <span style={{ fontSize: 12, color: 'var(--muted)' }}>{PAGE_SIZE} filas por página</span>
        <div style={{ display: 'flex', gap: 6 }}>
          <button className="btn ghost sm" disabled={page === 0} onClick={() => setPage(page - 1)}>← Anterior</button>
          <button className="btn ghost sm" disabled={(page + 1) * PAGE_SIZE >= total} onClick={() => setPage(page + 1)}>Siguiente →</button>
        </div>
      </div>

      {/* Modal detalle de fila */}
      <Modal open={!!detalle} onClose={() => setDetalle(null)} title={`Detalle · ${tablaActiva.table}`} wide>
        {detalle && (
          <div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 8, fontSize: 12 }}>
              {Object.entries(detalle).map(([k, v]) => (
                <React.Fragment key={k}>
                  <div style={{ fontWeight: 700, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '.03em', fontSize: 10, alignSelf: 'center' }}>{k}</div>
                  <div className="mono" style={{ wordBreak: 'break-all' }}>
                    {v == null ? <span style={{ color: 'var(--muted)', fontStyle: 'italic' }}>null</span>
                      : typeof v === 'object' ? JSON.stringify(v, null, 2)
                      : String(v)}
                  </div>
                </React.Fragment>
              ))}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
