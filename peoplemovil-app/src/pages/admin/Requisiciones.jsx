import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Modal from '../../components/ui/Modal.jsx';
import KpiCard from '../../components/ui/KpiCard.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';

export default function Requisiciones() {
  useModuleAudit('requisiciones');
  const [rows, setRows] = useState([]);
  const [clientes, setClientes] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [nueva, setNueva] = useState({ titulo:'', cliente_id:'', fecha_evento:'', cantidad_estimada:1, descripcion:'' });
  const [modalNueva, setModalNueva] = useState(false);
  const [convModal, setConvModal] = useState(null);
  const [sitioConv, setSitioConv] = useState('');
  const [msg, setMsg] = useState('');

  const cargar = async () => {
    if (!supabaseReady) return;
    const [{ data: r }, { data: c }, { data: s }] = await Promise.all([
      supabase.from('te_requisicion_personal').select('*').order('fecha_evento', { ascending: false }),
      supabase.from('tc_clientes').select('id, razon_social').eq('activo', true).order('razon_social'),
      supabase.from('tc_sitios').select('id, titulo').eq('activo', true).order('titulo')
    ]);
    setRows(r || []); setClientes(c || []); setSitios(s || []);
  };
  useEffect(() => { cargar(); }, []);

  const crear = async e => {
    e.preventDefault();
    const folio = Math.floor(Date.now() / 1000) % 100000;
    const { error } = await supabase.from('te_requisicion_personal').insert({
      ...nueva, tenant_id: DEMO_TENANT_ID, folio,
      cliente_id: nueva.cliente_id || null,
      cantidad_estimada: nueva.cantidad_estimada || null
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('requisiciones', 'INSERT', `req: ${nueva.titulo}`);
    setMsg('✓ Requisición creada');
    setModalNueva(false); setNueva({ titulo:'', cliente_id:'', fecha_evento:'', cantidad_estimada:1, descripcion:'' });
    cargar();
  };

  const convertir = async () => {
    if (!sitioConv) return setMsg('Elegí un sitio');
    const { data, error } = await supabase.rpc('convertir_requisicion_a_pedido', {
      p_requisicion: convModal.id,
      p_titulo: convModal.titulo,
      p_sitio_id: sitioConv
    });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('requisiciones', 'CONVERTIR', `req ${convModal.id} → pedido ${data}`);
    setMsg('✓ Pedido generado: ' + data);
    setConvModal(null); setSitioConv(''); cargar();
  };

  const kpi_recibidas = rows.filter(r => r.estatus === 'recibida').length;
  const kpi_convertidas = rows.filter(r => r.estatus === 'convertida').length;
  const kpi_rechazadas = rows.filter(r => r.estatus === 'rechazada').length;

  return (
    <div>
      <div className="section-eyebrow">Comercial</div>
      <h1>Requisiciones de personal</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Solicitudes crudas de clientes o áreas antes de formalizar como pedido.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Recibidas" value={kpi_recibidas} sub="por procesar" color="var(--gold)" />
        <KpiCard label="Convertidas a pedido" value={kpi_convertidas} sub="ya en operación" color="var(--green)" />
        <KpiCard label="Rechazadas" value={kpi_rechazadas} sub="no procedieron" color="var(--red)" />
      </div>

      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 12 }}>
        <button className="btn" onClick={() => setModalNueva(true)}>+ Nueva requisición</button>
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Folio</th><th>Título</th><th>Fecha evento</th><th>Cant.</th><th>Estatus</th><th></th></tr>
          </thead>
          <tbody>
            {rows.length === 0 && <tr><td colSpan="6" className="empty">Sin requisiciones aún.</td></tr>}
            {rows.map(r => (
              <tr key={r.id}>
                <td className="mono">#{r.folio}</td>
                <td>{r.titulo}</td>
                <td>{r.fecha_evento}</td>
                <td>{r.cantidad_estimada || '—'}</td>
                <td>
                  <Badge estado={r.estatus === 'convertida' ? 'activo' : r.estatus === 'rechazada' ? 'vencido' : 'pendiente'}>
                    {r.estatus}
                  </Badge>
                </td>
                <td style={{ textAlign: 'right' }}>
                  {r.estatus === 'recibida' && !r.pedido_generado_id && (
                    <button className="btn green sm" onClick={() => setConvModal(r)}>Convertir a pedido</button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={modalNueva} onClose={() => setModalNueva(false)} title="Nueva requisición"
        footer={<><button className="btn ghost" onClick={() => setModalNueva(false)}>Cancelar</button>
                <button className="btn" onClick={crear}>Crear</button></>}>
        <form onSubmit={crear} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Título *</label><input required className="field" value={nueva.titulo} onChange={e => setNueva({...nueva, titulo: e.target.value})} /></div>
          <div><label className="label">Cliente</label>
            <select className="field" value={nueva.cliente_id} onChange={e => setNueva({...nueva, cliente_id: e.target.value})}>
              <option value="">— sin cliente —</option>
              {clientes.map(c => <option key={c.id} value={c.id}>{c.razon_social}</option>)}
            </select>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Fecha evento *</label><input required type="date" className="field" value={nueva.fecha_evento} onChange={e => setNueva({...nueva, fecha_evento: e.target.value})} /></div>
            <div><label className="label">Cantidad estimada</label><input type="number" min="1" className="field" value={nueva.cantidad_estimada} onChange={e => setNueva({...nueva, cantidad_estimada: e.target.value})} /></div>
          </div>
          <div><label className="label">Descripción</label><textarea className="field" rows="3" value={nueva.descripcion} onChange={e => setNueva({...nueva, descripcion: e.target.value})}></textarea></div>
        </form>
      </Modal>

      <Modal open={!!convModal} onClose={() => setConvModal(null)} title="Convertir a pedido"
        footer={<><button className="btn ghost" onClick={() => setConvModal(null)}>Cancelar</button>
                <button className="btn green" onClick={convertir}>Convertir</button></>}>
        {convModal && (
          <div style={{ display: 'grid', gap: 12 }}>
            <p>Se generará un pedido operativo a partir de <strong>{convModal.titulo}</strong> ({convModal.fecha_evento}).</p>
            <div>
              <label className="label">Sitio del pedido *</label>
              <select className="field" value={sitioConv} onChange={e => setSitioConv(e.target.value)}>
                <option value="">— elegí sitio —</option>
                {sitios.map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
