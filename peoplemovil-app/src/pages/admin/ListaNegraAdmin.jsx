import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../../lib/supabase.js';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import Modal from '../../components/ui/Modal.jsx';
import Badge from '../../components/ui/Badge.jsx';
import { useModuleAudit, logAccion } from '../../lib/audit.js';
import { useAdminAuth } from '../../lib/AdminAuthContext.jsx';

// Escenario 18 QA — Administración de Lista Negra, equivalente a
// te_listanegraw.aspx/te_listanegra.aspx del legado Lobo. El veto se
// identifica por RFC/CURP del empleado (no por empleado_id) — mismo
// criterio que ya usa v_publicaciones_para_freelance para la bolsa del
// portal (ver §9 de CLAUDE.md) y que ahora también usa tg_reservacion_valida()
// para Confirmación Forzada/Preasignada. Sin "Lugar de evento" = veto global
// (equivalente al checkbox "Todos" del legado).
export default function ListaNegraAdmin() {
  useModuleAudit('lista_negra_admin');
  const { hasPermiso } = useAdminAuth();
  const puedeVer = hasPermiso('lista_negra.ver');
  const puedeEditar = hasPermiso('lista_negra.editar');
  const [rows, setRows] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState('');
  const [nuevoOpen, setNuevoOpen] = useState(false);
  const [busqueda, setBusqueda] = useState('');
  const [resultados, setResultados] = useState([]);
  const [empSel, setEmpSel] = useState(null);
  const [sitioId, setSitioId] = useState('');
  const [fechaExpiracion, setFechaExpiracion] = useState('');
  const [motivo, setMotivo] = useState('');

  const cargar = async () => {
    if (!supabaseReady) return;
    setLoading(true);
    const [{ data, error }, { data: s }] = await Promise.all([
      supabase.from('te_lista_negra_empleados').select('*, tc_sitios(titulo)').order('creado_en', { ascending: false }).limit(200),
      supabase.from('tc_sitios').select('id, titulo').eq('activo', true).order('titulo')
    ]);
    if (error) setMsg('⚠ ' + error.message);
    else setRows(data || []);
    setSitios(s || []);
    setLoading(false);
  };
  useEffect(() => { if (puedeVer) cargar(); }, [puedeVer]);

  const buscarEmpleado = async (texto) => {
    setBusqueda(texto); setEmpSel(null);
    if (!texto || texto.length < 2) { setResultados([]); return; }
    const folioNum = Number(texto);
    const filtro = Number.isFinite(folioNum) && texto.trim() !== ''
      ? `nombres.ilike.%${texto}%,apellido_paterno.ilike.%${texto}%,apellido_materno.ilike.%${texto}%,folio.eq.${folioNum}`
      : `nombres.ilike.%${texto}%,apellido_paterno.ilike.%${texto}%,apellido_materno.ilike.%${texto}%`;
    const { data } = await supabase.from('te_empleados')
      .select('id, folio, nombres, apellido_paterno, apellido_materno, rfc, curp')
      .eq('tenant_id', DEMO_TENANT_ID)
      .or(filtro)
      .limit(10);
    setResultados(data || []);
  };

  const abrirNuevo = () => {
    setBusqueda(''); setResultados([]); setEmpSel(null);
    setSitioId(''); setFechaExpiracion(''); setMotivo('');
    setNuevoOpen(true);
  };

  const guardar = async () => {
    if (!empSel) { setMsg('❌ Elegí un empleado de la lista de resultados.'); return; }
    if (!empSel.rfc && !empSel.curp) {
      setMsg('❌ Este empleado no tiene RFC ni CURP capturado — el veto no se podría aplicar (el cruce de lista negra usa esos campos, no el folio). Captura RFC/CURP en su expediente primero.');
      return;
    }
    const payload = {
      tenant_id: DEMO_TENANT_ID,
      rfc: empSel.rfc || null,
      curp: empSel.curp || null,
      nombre_completo: [empSel.nombres, empSel.apellido_paterno, empSel.apellido_materno].filter(Boolean).join(' '),
      motivo: motivo || '',
      sitio_id: sitioId || null,
      fecha_expiracion: fechaExpiracion || null
    };
    const { error } = await supabase.from('te_lista_negra_empleados').insert(payload);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('lista_negra_admin', 'INSERT', `veto folio ${empSel.folio} (${payload.nombre_completo}) sitio=${sitioId || 'TODOS'}`);
    setMsg('✓ Empleado incluido en la lista negra');
    setNuevoOpen(false);
    cargar();
  };

  const desactivar = async (r) => {
    if (!confirm('¿Quitar de la lista negra (desactivar el veto)?')) return;
    const { error } = await supabase.from('te_lista_negra_empleados').update({ activo: false }).eq('id', r.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('lista_negra_admin', 'DESACTIVAR', `veto ${r.id}`);
    setMsg('✓ Veto desactivado');
    cargar();
  };

  if (!puedeVer) {
    // Guard a nivel de página, no solo de botón -- a diferencia del resto del
    // admin (ver §8 de CLAUDE.md: el gating de hasPermiso() hoy es solo de
    // UI/botones, el menú solo OCULTA el link pero no bloquea la ruta). El
    // Escenario 18 QA pide explícitamente validar que un usuario sin acceso
    // NO pueda entrar a esta pantalla, así que aquí sí hace falta bloquear
    // el contenido completo, no solo los botones de editar.
    return (
      <div>
        <div className="section-eyebrow">Administración</div>
        <h1>Lista negra de empleados</h1>
        <div className="card" style={{ padding: 20, marginTop: 12 }}>
          <strong>No tenés permiso para ver este módulo.</strong>
          <p style={{ color: 'var(--muted)', fontSize: 13, marginTop: 6 }}>
            Tu rol no tiene el permiso <code>lista_negra.ver</code>. Contactá a un administrador si necesitás acceso.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="section-eyebrow">Administración</div>
      <h1>Lista negra de empleados</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Empleados vetados para asignación — por RFC/CURP, acotado opcionalmente a un sitio y con fecha de expiración opcional.
        Equivalente a "Empleados vetados" del sistema legado.
      </p>

      <div className="card" style={{ padding: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
          <div style={{ fontSize: 12, color: 'var(--muted)' }}>
            <strong>{rows.length}</strong> registros {loading && '· cargando…'}
            {!puedeEditar && <span> · solo lectura (tu rol no tiene <code>lista_negra.editar</code>)</span>}
          </div>
          {puedeEditar && <button className="btn" onClick={abrirNuevo}>+ Agregar a lista negra</button>}
        </div>
      </div>

      {msg && <p style={{ fontSize: 12, marginTop: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Nombre</th><th>RFC</th><th>CURP</th><th>Lugar de evento</th><th>Desde</th><th>Hasta</th><th>Activo</th><th></th></tr>
          </thead>
          <tbody>
            {rows.length === 0 && <tr><td colSpan="8" className="empty">Sin empleados vetados.</td></tr>}
            {rows.map(r => (
              <tr key={r.id}>
                <td>{r.nombre_completo}</td>
                <td>{r.rfc || '—'}</td>
                <td>{r.curp || '—'}</td>
                <td>{r.tc_sitios?.titulo || 'Todos los sitios'}</td>
                <td>{r.fecha_bloqueo}</td>
                <td>{r.fecha_expiracion || 'Indefinido'}</td>
                <td><Badge estado={r.activo ? 'activo' : 'inactivo'}>{r.activo ? 'SÍ' : 'NO'}</Badge></td>
                <td style={{ textAlign: 'right' }}>
                  {puedeEditar && r.activo && <button className="btn ghost sm" onClick={() => desactivar(r)}>Desactivar</button>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      <Modal open={nuevoOpen} onClose={() => setNuevoOpen(false)} title="Agregar a lista negra"
        footer={<><button className="btn ghost" onClick={() => setNuevoOpen(false)}>Cancelar</button>
                <button className="btn" onClick={guardar}>Guardar</button></>}>
        <div style={{ display: 'grid', gap: 12 }}>
          <div>
            <label className="label">Id Emp. / Nombre</label>
            <input className="field" placeholder="Buscar por folio o nombre…" value={busqueda} onChange={e => buscarEmpleado(e.target.value)} />
            {resultados.length > 0 && (
              <div className="card" style={{ marginTop: 6, padding: 6, maxHeight: 160, overflowY: 'auto' }}>
                {resultados.map(r => (
                  <div key={r.id} style={{ padding: 6, cursor: 'pointer', borderRadius: 6, background: empSel?.id === r.id ? 'var(--border)' : 'transparent' }}
                    onClick={() => { setEmpSel(r); setBusqueda(`#${r.folio} ${r.nombres} ${r.apellido_paterno}`); setResultados([]); }}>
                    #{r.folio} {r.nombres} {r.apellido_paterno} {r.apellido_materno}
                    {!r.rfc && !r.curp && <span style={{ color: 'var(--danger)', fontSize: 11 }}> (sin RFC/CURP — el veto no aplicaría)</span>}
                  </div>
                ))}
              </div>
            )}
            {empSel && <div style={{ fontSize: 12, color: 'var(--muted)', marginTop: 4 }}>Nombre: {empSel.nombres} {empSel.apellido_paterno} {empSel.apellido_materno} — RFC {empSel.rfc || '—'} — CURP {empSel.curp || '—'}</div>}
          </div>
          <div>
            <label className="label">Lugar de evento</label>
            <select className="field" value={sitioId} onChange={e => setSitioId(e.target.value)}>
              <option value="">— Todos los sitios —</option>
              {sitios.map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
            </select>
          </div>
          <div>
            <label className="label">Hasta (fecha de expiración, opcional)</label>
            <input type="date" className="field" value={fechaExpiracion} onChange={e => setFechaExpiracion(e.target.value)} />
          </div>
          <div>
            <label className="label">Motivo (opcional, interno)</label>
            <input className="field" value={motivo} onChange={e => setMotivo(e.target.value)} />
          </div>
          <div style={{ fontSize: 12, color: 'var(--muted)' }}>"Fecha desde" se registra automáticamente con la fecha de hoy.</div>
        </div>
      </Modal>
    </div>
  );
}
