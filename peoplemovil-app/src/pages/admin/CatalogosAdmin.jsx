import React, { useEffect, useMemo, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Modal from '../../components/ui/Modal.jsx';
import Chip from '../../components/ui/Chip.jsx';
import Badge from '../../components/ui/Badge.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

// HU 9.01 — Administración de Catálogos
// Un solo módulo con selector de catálogo + toolbar (Agregar/Eliminar/Buscar/Exportar) + tabla editable
const CATALOGOS = [
  { key: 'tc_bancos',                  label: 'Bancos',                  cols: ['clave','nombre','activo'] },
  { key: 'tc_sitios',                  label: 'Sitios',                  cols: ['titulo','tipo_sitio','direccion_abreviada','activo'] },
  { key: 'tc_puestos',                 label: 'Puestos',                 cols: ['titulo','regimen_pago','ciclo_pago','porcentaje_minimo','pago_default','activo'] },
  { key: 'tc_uniformes',               label: 'Uniformes',               cols: ['titulo','titulo_abreviado'] },
  { key: 'tc_clientes',                label: 'Clientes',                cols: ['razon_social','rfc','correo','telefono','activo'] },
  { key: 'tc_productos',               label: 'Productos',               cols: ['titulo','subcategoria','vigente'] },
  { key: 'tc_sociedades_pagadoras',    label: 'Sociedades pagadoras',    cols: ['titulo','numero_sociedad','activo'] },
  { key: 'tc_sociedades_propias',      label: 'Sociedades propias',      cols: ['titulo','razon_social','vigente'] },
  { key: 'tc_unidades_negocio',        label: 'Unidades de negocio',     cols: ['titulo','activo'] },
  { key: 'tc_turnos',                  label: 'Turnos',                  cols: ['titulo','hora_inicio','hora_fin','activo'] },
  { key: 'tc_tipos_personal',          label: 'Tipos de personal',       cols: ['clave','descripcion'] },
  { key: 'tc_responsables',            label: 'Responsables / coord.',   cols: ['nombre','correo','telefono','activo'] },
  { key: 'tc_fases_evento',            label: 'Fases del evento',        cols: ['clave','titulo','orden'] },
  { key: 'tc_causas_aclaracion',       label: 'Causas de aclaración',    cols: ['clave','descripcion'] },
  { key: 'tc_tipos_documento',         label: 'Tipos de documento',      cols: ['clave','titulo','requerido_alta'] },
  { key: 'tc_estados_mx',              label: 'Estados MX',              cols: ['clave_ine','nombre'] },
  { key: 'tc_tipos_movimiento_pedido', label: 'Tipos movimiento pedido', cols: ['clave','titulo','se_factura','activo'] },
  { key: 'tc_tipos_complejidad',       label: 'Tipos de complejidad',    cols: ['clave','titulo','factor_costo','activo'] },
  { key: 'tc_tipos_duracion_evento',   label: 'Duración de evento',      cols: ['clave','titulo','dias_minimos','dias_maximos'] },
  { key: 'tc_reglas_asistencia_timescan', label: 'Reglas asistencia',    cols: ['titulo','min_ant_entrada','min_retardo','min_ant_salida','min_desp_salida'] },
  { key: 'tc_como_se_entero',          label: 'Cómo se enteró',          cols: ['clave','titulo','activo'] },
  { key: 'tc_causas_baja_reingreso',   label: 'Causas baja/reingreso',   cols: ['clave','titulo','tipo'] },
  { key: 'tc_partidas_presupuestales', label: 'Partidas presup. (PEP)',  cols: ['clave_pep','descripcion','categoria','anio','vigente'] },
  { key: 'tc_presentaciones_producto', label: 'Presentaciones producto', cols: ['clave','titulo','activo'] },
  { key: 'tc_planes_suscripcion',      label: 'Planes suscripción',      cols: ['codigo','titulo','precio_mensual_mxn'] }
];

export default function CatalogosAdmin() {
  useModuleAudit('catalogos_admin');
  const [catActiva, setCatActiva] = useState(CATALOGOS[0]);
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [busqueda, setBusqueda] = useState('');
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [nuevoRow, setNuevoRow] = useState({});
  const [msg, setMsg] = useState('');

  const cargar = async () => {
    if (!supabaseReady) return;
    setLoading(true);
    const { data, error } = await supabase.from(catActiva.key).select('*').limit(500);
    if (error) setMsg('⚠ ' + error.message);
    else { setRows(data || []); setMsg(''); }
    setLoading(false);
  };
  useEffect(() => { cargar(); setNuevoRow({}); }, [catActiva]);

  const filtradas = useMemo(() => {
    if (!busqueda.trim()) return rows;
    const q = busqueda.toLowerCase();
    return rows.filter(r => Object.values(r).some(v => v != null && String(v).toLowerCase().includes(q)));
  }, [rows, busqueda]);

  const agregar = async () => {
    const payload = { ...nuevoRow, tenant_id: DEMO_TENANT_ID };
    const { error } = await supabase.from(catActiva.key).insert(payload);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('catalogos_admin', 'INSERT', `${catActiva.key}: ${JSON.stringify(nuevoRow)}`);
    setNuevoOpen(false); setNuevoRow({}); setMsg('✓ Agregado');
    cargar();
  };

  const eliminar = async r => {
    if (!confirm('¿Eliminar este registro?')) return;
    const { error } = await supabase.from(catActiva.key).delete().eq('id', r.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('catalogos_admin', 'DELETE', `${catActiva.key} #${r.id}`);
    setMsg('✓ Eliminado');
    cargar();
  };

  const exportarCSV = () => {
    if (filtradas.length === 0) return;
    const cols = catActiva.cols;
    const esc = v => v == null ? '' : `"${String(v).replace(/"/g, '""')}"`;
    const csv = [cols.join(','), ...filtradas.map(r => cols.map(c => esc(r[c])).join(','))].join('\n');
    const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `${catActiva.key}_${new Date().toISOString().slice(0,10)}.csv`;
    a.click();
  };

  const fmt = v => {
    if (v == null) return <span style={{ color: 'var(--muted)' }}>—</span>;
    if (typeof v === 'boolean') return <Badge estado={v ? 'activo' : 'inactivo'}>{v ? 'SÍ' : 'NO'}</Badge>;
    if (typeof v === 'object') return <span className="mono">{JSON.stringify(v).slice(0, 30)}</span>;
    return String(v);
  };

  return (
    <div>
      <div className="section-eyebrow">Administración · HU 9.01</div>
      <h1>Administración de catálogos</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Todos los catálogos del sistema en un solo lugar. Elegí el catálogo y agregá/eliminá según corresponda.
      </p>

      <div className="card" style={{ padding: 12 }}>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
          <div style={{ flex: 1, minWidth: 240 }}>
            <label className="label">Catálogo</label>
            <select className="field" value={catActiva.key} onChange={e => setCatActiva(CATALOGOS.find(c => c.key === e.target.value))}>
              {CATALOGOS.map(c => <option key={c.key} value={c.key}>{c.label} ({c.key})</option>)}
            </select>
          </div>
          <div style={{ flex: 1, minWidth: 200 }}>
            <label className="label">Búsqueda</label>
            <input className="field" placeholder="Buscar en todos los campos…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
          </div>
          <div style={{ display: 'flex', gap: 6, alignItems: 'end' }}>
            <button className="btn" onClick={() => setNuevoOpen(true)}>+ Agregar</button>
            <button className="btn outline sm" onClick={exportarCSV}>📥 CSV</button>
          </div>
        </div>
        <div style={{ marginTop: 8, fontSize: 12, color: 'var(--muted)' }}>
          <strong>{filtradas.length}</strong> de {rows.length} registros {loading && '· cargando…'}
        </div>
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr>{catActiva.cols.map(c => <th key={c}>{c}</th>)}<th></th></tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && (
              <tr><td colSpan={catActiva.cols.length + 1} className="empty">Sin registros. Agregá el primero.</td></tr>
            )}
            {filtradas.map(r => (
              <tr key={r.id}>
                {catActiva.cols.map(c => <td key={c}>{fmt(r[c])}</td>)}
                <td style={{ textAlign: 'right' }}>
                  <button className="btn ghost sm" onClick={() => eliminar(r)}>🗑</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title={`Agregar en ${catActiva.label}`}
        footer={<><button className="btn ghost" onClick={() => setNuevoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={agregar}>Confirmar</button></>}>
        <div style={{ display: 'grid', gap: 12 }}>
          {catActiva.cols.map(c => (
            <div key={c}>
              <label className="label">{c}</label>
              <input className="field" value={nuevoRow[c] || ''} onChange={e => setNuevoRow({ ...nuevoRow, [c]: e.target.value })} />
            </div>
          ))}
        </div>
      </Modal>
    </div>
  );
}
