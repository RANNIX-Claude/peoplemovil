import React, { useEffect, useState } from 'react';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import { tituloConLinea } from '../components/ui/CardHeader.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

export default function Configuracion() {
  useModuleAudit('configuracion');
  const [params, setParams] = useState(null);
  const [puestos, setPuestos] = useState([]);
  const [avisoActivo, setAvisoActivo] = useState(null);
  const [msg, setMsg] = useState('');

  useEffect(() => { cargar(); }, []);
  async function cargar() {
    if (!supabaseReady) return;
    const [{ data: p }, { data: ps }, { data: av }] = await Promise.all([
      supabase.from('tp_parametros_globales').select('*').eq('tenant_id', DEMO_TENANT_ID).maybeSingle(),
      supabase.from('tc_puestos').select('id, titulo, porcentaje_certeza_inicial, porcentaje_minimo, horas_entre_turnos, horas_antes_cancelar, penalizacion_retardo, penalizacion_falta').order('titulo').limit(60),
      supabase.from('tp_avisos_privacidad').select('*').order('vigente_desde', { ascending: false }).limit(1)
    ]);
    setParams(p); setPuestos(ps || []); setAvisoActivo((av && av[0]) || null);
  }

  async function guardarParams() {
    const { error } = await supabase.from('tp_parametros_globales').update(params).eq('tenant_id', DEMO_TENANT_ID);
    if (error) { setMsg('Error: ' + error.message); return; }
    await logAccion('configuracion', 'UPDATE', 'tp_parametros_globales actualizado');
    setMsg('Guardado');
  }

  return (
    <div>
      <div className="section-eyebrow">Administración</div>
      <h1>Configuración</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 24 }}>Parámetros globales del tenant y todos los umbrales de negocio por puesto. Cambiar aquí = cambiar la regla, sin tocar código.</p>

      <div className="kpi-grid">
        <KpiCard label="Puestos configurados" value={puestos.length} sub="tc_puestos" />
        <KpiCard label="Retención registros" value={params ? `${params.retencion_registros_dias} d` : '—'} sub="mínimo legal 5 años" />
        <KpiCard label="Aviso privacidad vigente" value={avisoActivo?.version || '—'} sub={avisoActivo ? new Date(avisoActivo.vigente_desde).toLocaleDateString('es-MX') : ''} color="var(--accent2)" />
      </div>

      <div className="card">
        <div className="section-eyebrow">Parámetros globales</div>
        <h3 style={{ ...tituloConLinea, marginTop: 4 }}>⚙️ tp_parametros_globales</h3>
        {!params ? <p style={{ fontSize: 12, color: 'var(--muted)' }}>Cargando…</p> : (
          <>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 14 }}>
              {[
                ['horas_lookahead_autocancel', 'Lookahead auto-cancelación (h)'],
                ['horas_gracia_confirmacion',  'Gracia para confirmar (h)'],
                ['retencion_registros_dias',   'Retención de registros (días)'],
                ['certeza_inicial_default',    'Certeza inicial default (0-1)'],
                ['aviso_privacidad_version',   'Versión del aviso de privacidad']
              ].map(([k, l]) => (
                <div key={k}>
                  <label className="label">{l}</label>
                  <input className="field" value={params[k] ?? ''} onChange={e => setParams({ ...params, [k]: e.target.value })} />
                </div>
              ))}
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 16 }}>
              <p style={{ fontSize: 11, color: 'var(--muted)' }}>Los 72h/8h del sistema original vivían hardcodeados. Aquí son editables por tenant.</p>
              <button className="btn" onClick={guardarParams}>Guardar</button>
            </div>
            {msg && <p style={{ marginTop: 8, fontSize: 12, color: 'var(--muted)' }}>{msg}</p>}
          </>
        )}
      </div>

      <h3 style={tituloConLinea}>🧩 Parámetros por puesto (<code>tc_puestos</code>)</h3>
      <TablaWrap>
        <table>
          <thead>
            <tr>
              <th>Puesto</th>
              <th style={{ textAlign: 'right' }}>Certeza inicial</th>
              <th style={{ textAlign: 'right' }}>Mín. certeza</th>
              <th style={{ textAlign: 'right' }}>Horas entre turnos</th>
              <th style={{ textAlign: 'right' }}>Horas antes cancelar</th>
              <th style={{ textAlign: 'right' }}>Pen. retardo</th>
              <th style={{ textAlign: 'right' }}>Pen. falta</th>
            </tr>
          </thead>
          <tbody>
            {puestos.length === 0 && <tr><td colSpan="7" className="empty">Sin puestos.</td></tr>}
            {puestos.map(p => (
              <tr key={p.id}>
                <td style={{ fontWeight: 700 }}>{p.titulo}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.porcentaje_certeza_inicial}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.porcentaje_minimo}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.horas_entre_turnos}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.horas_antes_cancelar}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.penalizacion_retardo}</td>
                <td style={{ textAlign: 'right' }} className="mono">{p.penalizacion_falta}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
      <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 10 }}>
        Estos valores alimentan los triggers PRC_ObtenerCertezaPuesto, PRC_Noempalmereservacion y PRC_ValidacionesCancelarReservacion.
      </p>
    </div>
  );
}
