import React, { useEffect, useState } from 'react';
import { supabase, supabaseReady } from '../../lib/supabase.js';
import KpiCard from '../../components/ui/KpiCard.jsx';
import Badge from '../../components/ui/Badge.jsx';
import Chip from '../../components/ui/Chip.jsx';
import TablaWrap from '../../components/ui/TablaWrap.jsx';
import { useModuleAudit } from '../../lib/audit.js';

const ETAPAS = [
  { key: 'postulado', label: '1. Postulados', desc: 'Recién llegaron' },
  { key: 'recepcion_pendiente', label: '2. Recepción pendiente', desc: 'Documentación por revisar' },
  { key: 'entrevista_grupal_agendada', label: '3. Cita grupal', desc: 'Agendaron entrevista' },
  { key: 'entrevista_individual', label: '4. Entrevista individual', desc: 'Con psicométrico + obs' },
  { key: 'en_curso_induccion', label: '5. Curso inducción', desc: 'Asisten a curso' },
  { key: 'en_evento_prueba', label: '6. Evento prueba', desc: 'En evento de prueba' },
  { key: 'listo_alta', label: '7. Listo para alta', desc: 'Se convierten a empleado' }
];

export default function FunnelReclutamiento() {
  useModuleAudit('funnel_reclutamiento');
  const [postulaciones, setPostulaciones] = useState([]);
  const [etapaFiltro, setEtapaFiltro] = useState('todas');

  useEffect(() => {
    if (!supabaseReady) return;
    supabase.from('tr_postulacion_candidato_vacante').select('*, te_candidatos(nombres, apellido_paterno)').order('fecha_registro', { ascending: false })
      .then(({ data }) => setPostulaciones(data || []));
  }, []);

  const cnt = etapa => postulaciones.filter(p => p.estatus_full === etapa).length;
  const filtradas = etapaFiltro === 'todas' ? postulaciones : postulaciones.filter(p => p.estatus_full === etapaFiltro);

  return (
    <div>
      <div className="section-eyebrow">Reclutamiento</div>
      <h1>Funnel de selección</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Cada candidato avanza por 7 etapas hasta convertirse en empleado. Klick en una etapa para filtrar.
      </p>

      <div className="kpi-grid" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))' }}>
        {ETAPAS.map(e => (
          <KpiCard key={e.key} label={e.label} value={cnt(e.key)} sub={e.desc}
                   onClick={() => setEtapaFiltro(etapaFiltro === e.key ? 'todas' : e.key)}
                   color={etapaFiltro === e.key ? 'var(--accent2)' : undefined} />
        ))}
      </div>

      <div className="chips">
        <Chip active={etapaFiltro === 'todas'} onClick={() => setEtapaFiltro('todas')}>Todas ({postulaciones.length})</Chip>
        {ETAPAS.map(e => (
          <Chip key={e.key} active={etapaFiltro === e.key} onClick={() => setEtapaFiltro(etapaFiltro === e.key ? 'todas' : e.key)}>
            {e.label} ({cnt(e.key)})
          </Chip>
        ))}
      </div>

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Candidato</th><th>Etapa</th><th>Resultado</th><th>Registrado</th><th>Doc completa</th><th>Asistencia curso</th><th>Asistencia evento prueba</th></tr>
          </thead>
          <tbody>
            {filtradas.length === 0 && <tr><td colSpan="7" className="empty">Sin postulaciones en esta etapa.</td></tr>}
            {filtradas.map(p => (
              <tr key={p.id}>
                <td>{p.te_candidatos?.nombres} {p.te_candidatos?.apellido_paterno}</td>
                <td><Badge estado="proceso">{p.estatus_full}</Badge></td>
                <td style={{ fontSize: 11 }}>{p.resultado}</td>
                <td>{p.fecha_registro?.slice(0, 10)}</td>
                <td>{p.doc_completa ? '✓' : '—'}</td>
                <td>{p.asis_curso_induccion ? `✓ ${p.calif_curso_induccion || ''}` : '—'}</td>
                <td>{p.asis_evento_prueba ? `✓ ${p.calif_evento_prueba || ''}` : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>
    </div>
  );
}
