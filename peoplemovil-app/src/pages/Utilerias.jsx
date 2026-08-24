import React, { useEffect, useMemo, useState } from 'react';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Modal from '../components/ui/Modal.jsx';
import Chip from '../components/ui/Chip.jsx';
import Badge from '../components/ui/Badge.jsx';
import { supabase, supabaseReady } from '../lib/supabase.js';
import { useModuleAudit } from '../lib/audit.js';

const PAGE_SIZE = 50;

export default function Utilerias() {
  useModuleAudit('utilerias');
  const [tablas, setTablas] = useState([]);
  const [tablaActiva, setTablaActiva] = useState(null);
  const [rows, setRows] = useState([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const [orderCol, setOrderCol] = useState(null);
  const [orderAsc, setOrderAsc] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const [dominio, setDominio] = useState('todos');
  const [detalle, setDetalle] = useState(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState(null);

  // Cargar catálogo dinámico de tablas al montar
  useEffect(() => {
    if (!supabaseReady) return;
    supabase.rpc('list_public_tables').then(({ data }) => {
      const lista = data || [];
      setTablas(lista);
      if (lista.length > 0) setTablaActiva(lista[0]);
    });
  }, []);

  useEffect(() => { if (tablaActiva) cargar(); }, [tablaActiva, page, orderCol, orderAsc]);

  async function cargar() {
    if (!supabaseReady || !tablaActiva) return;
    setLoading(true); setErr(null);
    let q = supabase.from(tablaActiva.nombre).select('*', { count: 'exact' })
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

  const dominios = useMemo(() => [...new Set(tablas.map(t => t.dominio))], [tablas]);
  const tablasFiltradas = dominio === 'todos' ? tablas : tablas.filter(t => t.dominio === dominio);
  const tablasAgrupadas = useMemo(() => {
    const g = {};
    tablasFiltradas.forEach(t => {
      g[t.dominio] = g[t.dominio] || [];
      g[t.dominio].push(t);
    });
    return g;
  }, [tablasFiltradas]);

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
    a.download = `${tablaActiva.nombre}_${new Date().toISOString().slice(0,10)}.csv`;
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
        Cualquier tabla del schema sin salir de la app. Se cargan dinámicamente vía <code>list_public_tables()</code>.
        <strong> RLS del tenant aplica</strong>: solo ves filas del tenant activo.
        Total detectadas: <strong>{tablas.length}</strong>.
      </p>

      <div className="chips">
        <Chip active={dominio === 'todos'} onClick={() => setDominio('todos')}>Todos ({tablas.length})</Chip>
        {dominios.map(d => (
          <Chip key={d} active={dominio === d} onClick={() => setDominio(dominio === d ? 'todos' : d)}>
            {d} ({tablas.filter(t => t.dominio === d).length})
          </Chip>
        ))}
      </div>

      <div className="card">
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 3fr auto', gap: 12, alignItems: 'end' }}>
          <div>
            <label className="label">Tabla</label>
            <select
              className="field"
              value={tablaActiva?.nombre || ''}
              onChange={e => {
                const t = tablas.find(x => x.nombre === e.target.value);
                if (t) { setTablaActiva(t); setPage(0); setOrderCol(null); }
              }}
            >
              {Object.entries(tablasAgrupadas).map(([dom, lst]) => (
                <optgroup key={dom} label={`${dom} (${lst.length})`}>
                  {lst.map(t => <option key={t.nombre} value={t.nombre}>{t.nombre}</option>)}
                </optgroup>
              ))}
            </select>
          </div>
          <div>
            <label className="label">Búsqueda global (client-side)</label>
            <input className="field" placeholder="filtra en todos los campos visibles…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
          </div>
          <button className="btn outline" onClick={exportarCSV} disabled={rowsFiltradas.length === 0}>📥 Exportar CSV</button>
        </div>
        <div style={{ marginTop: 10, fontSize: 12, color: 'var(--muted)', display: 'flex', gap: 14, flexWrap: 'wrap' }}>
          <span><strong style={{ color: 'var(--text)' }}>{total.toLocaleString('es-MX')}</strong> filas en <code>{tablaActiva?.nombre}</code></span>
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

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 }}>
        <span style={{ fontSize: 12, color: 'var(--muted)' }}>{PAGE_SIZE} filas por página</span>
        <div style={{ display: 'flex', gap: 6 }}>
          <button className="btn ghost sm" disabled={page === 0} onClick={() => setPage(page - 1)}>← Anterior</button>
          <button className="btn ghost sm" disabled={(page + 1) * PAGE_SIZE >= total} onClick={() => setPage(page + 1)}>Siguiente →</button>
        </div>
      </div>

      <Modal open={!!detalle} onClose={() => setDetalle(null)} title={`Detalle · ${tablaActiva?.nombre}`} wide>
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
