import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Modal from '../components/ui/Modal.jsx';
import TablaWrap from '../components/ui/TablaWrap.jsx';
import Badge from '../components/ui/Badge.jsx';
import Chip from '../components/ui/Chip.jsx';
import KpiCard from '../components/ui/KpiCard.jsx';
import Semaforo from '../components/Semaforo.jsx';
import { tituloConLinea } from '../components/ui/CardHeader.jsx';
import { supabase, supabaseReady, DEMO_TENANT_ID } from '../lib/supabase.js';
import { useModuleAudit, logAccion } from '../lib/audit.js';

const fmt = n => Number(n || 0).toLocaleString('es-MX', { maximumFractionDigits: 0 });

const PEDIDO_VACIO = {
  titulo: '', cliente_id: '', contacto_id: '', evento_id: '',
  unidad_negocio_id: '', partida_presupuestal_id: '', sitio_id: '', lugar_cita_id: '',
  id_sociedad_propia: '', sociedad_pagadora_id: '', tipo_movimiento_id: '',
  tipo_complejidad_id: '', tipo_duracion_id: '', duracion_dias: '',
  permitir_cancelaciones: true, fecha_evento: '', responsable_id: ''
};

const DETALLE_VACIO = {
  id_tipo_personal: '', producto_id: '', puesto_id: '', cantidad: 1, turnos: 1,
  fecha_cita: '', hora_cita_inicio: '', hora_cita_fin: '', fecha_final_cita: '',
  fecha_liberacion: '', presentacion_id: '', fase_evento_id: '',
  lugar_cita_id: '', lugar_otro: false, lugar_otro_descripcion: '',
  facturable: true, permitir_cancelar_confirmaciones: true,
  completar_productos_similares: false, indicaciones_especiales: ''
};

// Vista 1: Lista de pedidos con toolbar (heredado del manual Pedidos)
// Vista 2: Detalle de pedido — Registro (datos principales) + Matriz de puestos (agregar detalle) + Movimientos
export default function SitiosAsignacion() {
  useModuleAudit('sitios_asignacion');
  const nav = useNavigate();

  // --- listado ---
  const [pedidos, setPedidos] = useState([]);
  const [sitios, setSitios] = useState([]);
  const [clientes, setClientes] = useState([]);
  const [filtroStatus, setFiltroStatus] = useState('todos');
  const [busqueda, setBusqueda] = useState('');

  // --- catálogos para el registro de pedido ---
  const [unidadesNegocio, setUnidadesNegocio] = useState([]);
  const [sociedadesPropias, setSociedadesPropias] = useState([]);
  const [sociedadesPagadoras, setSociedadesPagadoras] = useState([]);
  const [tiposMovimiento, setTiposMovimiento] = useState([]);
  const [tiposComplejidad, setTiposComplejidad] = useState([]);
  const [tiposDuracion, setTiposDuracion] = useState([]);
  const [responsables, setResponsables] = useState([]);
  const [lugaresCita, setLugaresCita] = useState([]);
  const [peps, setPeps] = useState([]); // filtrado por UN seleccionada
  const [contactos, setContactos] = useState([]); // filtrado por cliente seleccionado
  const [eventos, setEventos] = useState([]); // filtrado por cliente seleccionado

  // --- catálogos para el detalle ---
  const [tiposPersonal, setTiposPersonal] = useState([]);
  const [productos, setProductos] = useState([]);
  const [puestos, setPuestos] = useState([]);
  const [presentaciones, setPresentaciones] = useState([]);
  const [fasesEvento, setFasesEvento] = useState([]);

  // --- ficha de pedido ---
  const [pedidoSel, setPedidoSel] = useState(null);
  const [pestana, setPestana] = useState('general');
  const [detalles, setDetalles] = useState([]);
  const [matrizFilas, setMatrizFilas] = useState([]); // formato largo desde matriz_puestos_pedido()
  const [reservaciones, setReservaciones] = useState([]);

  // --- modales ---
  const [nuevoPedidoOpen, setNuevoPedidoOpen] = useState(false);
  const [nuevoPedido, setNuevoPedido] = useState(PEDIDO_VACIO);
  const [nuevoSitioOpen, setNuevoSitioOpen] = useState(false);
  const [nuevoSitio, setNuevoSitio] = useState({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });
  const [nuevoEventoTitulo, setNuevoEventoTitulo] = useState('');
  const [detalleOpen, setDetalleOpen] = useState(false);
  const [nuevoDetalle, setNuevoDetalle] = useState(DETALLE_VACIO);
  const [editandoDetalleId, setEditandoDetalleId] = useState(null); // null = alta, id = editando ese te_pedidos_detalle
  const [celdaDetalle, setCeldaDetalle] = useState(null); // popup "Detalle" al dar click en una celda de la matriz
  const [menuCeldaId, setMenuCeldaId] = useState(null); // pedido_detalle_id con el menú contextual (Editar/Reservaciones/Cancelar/Liberar) abierto
  const [menuPos, setMenuPos] = useState(null); // {top,left} en viewport, calculado del botón ▾ (la tabla tiene overflow-x:auto, así que el menú usa position:fixed para no quedar recortado)
  const [msg, setMsg] = useState('');
  const [msgDetalle, setMsgDetalle] = useState('');

  async function cargar() {
    if (!supabaseReady) return;
    const [
      { data: p }, { data: s }, { data: c }, { data: un }, { data: sp }, { data: spag },
      { data: tm }, { data: tcx }, { data: td }, { data: resp }, { data: lc },
      { data: tper }, { data: prod }, { data: pues }, { data: pres }, { data: fev }
    ] = await Promise.all([
      supabase.from('te_pedidos').select('*').order('fecha_evento', { ascending: false }).limit(100),
      supabase.from('tc_sitios').select('id, titulo, tipo_sitio, direccion_abreviada, activo').order('titulo'),
      supabase.from('tc_clientes').select('id, razon_social').eq('activo', true).order('razon_social'),
      supabase.from('tc_unidades_negocio').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_sociedades_propias').select('id, titulo').order('titulo'),
      supabase.from('tc_sociedades_pagadoras').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_tipos_movimiento_pedido').select('id, titulo, se_factura').eq('activo', true).order('titulo'),
      supabase.from('tc_tipos_complejidad').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_tipos_duracion_evento').select('id, titulo, dias_minimos, dias_maximos').eq('activo', true).order('titulo'),
      supabase.from('tc_responsables').select('id, nombre').order('nombre'),
      supabase.from('tc_lugares_cita').select('id, titulo, direccion').eq('activo', true).order('titulo'),
      supabase.from('tc_tipos_personal').select('id, clave, descripcion'),
      supabase.from('tc_productos').select('id, titulo, subcategoria, id_puesto').eq('vigente', true).order('titulo'),
      supabase.from('tc_puestos').select('id, titulo, duracion_turno_horas').eq('activo', true).order('titulo'),
      supabase.from('tc_presentaciones_producto').select('id, titulo').eq('activo', true).order('titulo'),
      supabase.from('tc_fases_evento').select('id, clave, titulo, orden').order('orden')
    ]);
    setPedidos(p || []); setSitios(s || []); setClientes(c || []);
    setUnidadesNegocio(un || []); setSociedadesPropias(sp || []); setSociedadesPagadoras(spag || []);
    setTiposMovimiento(tm || []); setTiposComplejidad(tcx || []); setTiposDuracion(td || []);
    setResponsables(resp || []); setLugaresCita(lc || []);
    setTiposPersonal(tper || []); setProductos(prod || []); setPuestos(pues || []); setPresentaciones(pres || []);
    setFasesEvento(fev || []);
  }
  useEffect(() => { cargar(); }, []);

  // --- Cliente elegido: cargar sus contactos y eventos ---
  useEffect(() => {
    if (!supabaseReady || !nuevoPedido.cliente_id) { setContactos([]); setEventos([]); return; }
    (async () => {
      const [{ data: ct }, { data: ev }] = await Promise.all([
        supabase.from('tc_contactos_cliente').select('id, nombre, telefono').eq('cliente_id', nuevoPedido.cliente_id).eq('activo', true).order('nombre'),
        supabase.from('tc_eventos').select('id, titulo').eq('cliente_id', nuevoPedido.cliente_id).eq('activo', true).order('titulo')
      ]);
      setContactos(ct || []); setEventos(ev || []);
    })();
  }, [nuevoPedido.cliente_id]);

  // --- Unidad de negocio elegida: cargar sus PEPs (y, como en el sistema real, se despliegan junto con la sociedad pagadora) ---
  useEffect(() => {
    if (!supabaseReady || !nuevoPedido.unidad_negocio_id) { setPeps([]); return; }
    supabase.from('tc_partidas_presupuestales')
      .select('id, clave_pep, descripcion, id_sitio, id_lugar_predeterminado, id_sociedad_propia')
      .eq('id_unidad_negocio', nuevoPedido.unidad_negocio_id).eq('vigente', true).order('clave_pep')
      .then(({ data }) => setPeps(data || []));
  }, [nuevoPedido.unidad_negocio_id]);

  // --- PEP elegido: el sistema real muestra nombre/dirección del inmueble -> autocompletamos sitio y lugar de cita ---
  const onPepChange = (pepId) => {
    const pep = peps.find(x => x.id === pepId);
    setNuevoPedido(prev => ({
      ...prev,
      partida_presupuestal_id: pepId,
      sitio_id: pep?.id_sitio || prev.sitio_id,
      lugar_cita_id: pep?.id_lugar_predeterminado || prev.lugar_cita_id,
      id_sociedad_propia: pep?.id_sociedad_propia || prev.id_sociedad_propia
    }));
  };

  const crearEventoRapido = async () => {
    if (!nuevoEventoTitulo.trim() || !nuevoPedido.cliente_id) return;
    const { data, error } = await supabase.from('tc_eventos')
      .insert({ tenant_id: DEMO_TENANT_ID, cliente_id: nuevoPedido.cliente_id, titulo: nuevoEventoTitulo.trim() })
      .select('id, titulo').single();
    if (error) { setMsg('❌ ' + error.message); return; }
    setEventos(prev => [...prev, data]);
    setNuevoPedido(prev => ({ ...prev, evento_id: data.id }));
    setNuevoEventoTitulo('');
  };

  const cargarDetallePedido = async (ped) => {
    setPedidoSel(ped); setPestana('general');
    const [{ data: d }, { data: r }, { data: m }, { data: pepRow }] = await Promise.all([
      supabase.from('te_pedidos_detalle').select('*, tc_puestos(titulo), tc_productos(titulo), tc_lugares_cita(titulo), tc_fases_evento(titulo)').eq('pedido_id', ped.id),
      supabase.from('te_reservaciones').select('*, te_empleados(nombres, apellido_paterno, folio)').eq('pedido_id', ped.id).limit(200),
      supabase.rpc('matriz_puestos_pedido', { p_pedido_id: ped.id }),
      ped.partida_presupuestal_id
        ? supabase.from('tc_partidas_presupuestales').select('id, clave_pep, descripcion').eq('id', ped.partida_presupuestal_id).maybeSingle()
        : Promise.resolve({ data: null })
    ]);
    setDetalles(d || []); setReservaciones(r || []); setMatrizFilas(m || []);
    // Mezcla el PEP del pedido actual a la lista para que el lookup de la ficha lo encuentre
    // aunque no se haya pasado por el formulario de alta (que es lo único que carga `peps`).
    if (pepRow) setPeps(prev => (prev.some(p => p.id === pepRow.id) ? prev : [...prev, pepRow]));
  };

  // Pivotea matrizFilas (formato largo: una fila por fecha) a una matriz real:
  // filas = Bloque+Producto, columnas = fechas distintas, celda = cantidad/turnos de esa fecha.
  // Esto reemplaza al TE_Puente del sistema legado (tabla con 50 columnas fijas C1..C50/Np1..Np50).
  const matrizPivot = useMemo(() => {
    if (matrizFilas.length === 0) return { fechas: [], grupos: [] };
    const fechasSet = new Set();
    const grupos = new Map();
    for (const r of matrizFilas) {
      if (r.fecha_cita) fechasSet.add(r.fecha_cita);
      const key = `${r.bloque_num ?? '—'}|${r.producto_id ?? r.puesto_id ?? 'sin-producto'}`;
      if (!grupos.has(key)) {
        grupos.set(key, {
          bloque_num: r.bloque_num,
          producto_titulo: r.producto_titulo || r.puesto_titulo || '(sin producto)',
          puesto_titulo: r.puesto_titulo,
          celdas: new Map(),
          totalSolicitados: 0,
          totalReservados: 0,
          presupuesto: 0
        });
      }
      const g = grupos.get(key);
      if (r.fecha_cita) g.celdas.set(r.fecha_cita, r);
      g.totalSolicitados += Number(r.cantidad || 0);
      g.totalReservados += Number(r.cantidad_reservados_real || 0);
      g.presupuesto += Number(r.costo_unit || r.precio || 0) * Number(r.cantidad || 0);
    }
    const fechas = Array.from(fechasSet).sort();
    // Presupuesto POR DÍA real (como en el legado: una cifra por columna, no un
    // promedio del pedido completo) -- suma, para cada fecha, cantidad × costo
    // de todos los renglones que tienen celda ese día.
    const presupuestoPorFecha = new Map();
    for (const f of fechas) {
      let total = 0;
      for (const g of grupos.values()) {
        const c = g.celdas.get(f);
        if (c) total += Number(c.cantidad || 0) * Number(c.costo_unit ?? c.precio ?? 0);
      }
      presupuestoPorFecha.set(f, total);
    }
    return { fechas, grupos: Array.from(grupos.values()), presupuestoPorFecha };
  }, [matrizFilas]);

  // Popup "Detalle" al dar click en una celda de la Matriz de Puestos — equivalente
  // a la ventana del sistema legado (ID, Lugar de Cita, Fecha Cita, Fecha Fin Cita,
  // Fecha Liberación, Completar con Similares, Cantidad Reservados / Real / con
  // Preasignados, Porcentaje Completo, Fase del Evento).
  const verDetalleCelda = (pedidoDetalleId) => {
    const d = detalles.find(x => x.id === pedidoDetalleId);
    if (d) setCeldaDetalle(d);
  };

  const liberarPedido = async () => {
    if (!pedidoSel) return;
    if (!confirm('¿Liberar el pedido? Todos los detalles en borrador pasan a LIBERADO y se publican en el portal.')) return;
    const { data, error } = await supabase.rpc('liberar_pedido', { p_pedido: pedidoSel.id });
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('sitios_asignacion', 'LIBERAR', `pedido ${pedidoSel.folio}: ${data} detalles liberados`);
    setMsg(`✓ ${data} detalles liberados`);
    await cargarDetallePedido(pedidoSel);
  };

  const cancelarPedido = async () => {
    if (!pedidoSel) return;
    if (!confirm('¿Cancelar el pedido? Se cancelan detalles no procesados y sus reservaciones.')) return;
    const { error } = await supabase.from('te_pedidos').update({ status: 'cancelado' }).eq('id', pedidoSel.id);
    if (error) { setMsg('❌ ' + error.message); return; }
    await supabase.from('te_pedidos_detalle').update({ status_detalle: 'cancelado' })
      .eq('pedido_id', pedidoSel.id).not('status_detalle', 'in', '(procesado,facturado)');
    await supabase.from('te_reservaciones').update({ estado: 'cancelado', regla_aplicada: 'cancelacion_pedido' })
      .eq('pedido_id', pedidoSel.id).not('estado', 'in', '(procesado,cancelado)');
    await logAccion('sitios_asignacion', 'CANCELAR', `pedido ${pedidoSel.folio}`);
    setMsg('✓ Pedido cancelado');
    await cargarDetallePedido({ ...pedidoSel, status: 'cancelado' });
    cargar();
  };

  const altaPedido = async (e) => {
    e.preventDefault();
    if (!nuevoPedido.sitio_id) { setMsg('❌ Falta sitio (seleccioná un PEP que tenga inmueble predeterminado, o elegí sitio manualmente).'); return; }
    const { data: folio, error: errFolio } = await supabase.rpc('siguiente_folio', { p_tenant: DEMO_TENANT_ID, p_tipo: 'pedido' });
    if (errFolio) { setMsg('❌ ' + errFolio.message); return; }
    const payload = {
      tenant_id: DEMO_TENANT_ID,
      folio,
      titulo: nuevoPedido.titulo,
      sitio_id: nuevoPedido.sitio_id,
      cliente_id: nuevoPedido.cliente_id || null,
      contacto_id: nuevoPedido.contacto_id || null,
      evento_id: nuevoPedido.evento_id || null,
      unidad_negocio_id: nuevoPedido.unidad_negocio_id || null,
      partida_presupuestal_id: nuevoPedido.partida_presupuestal_id || null,
      lugar_cita_id: nuevoPedido.lugar_cita_id || null,
      id_sociedad_propia: nuevoPedido.id_sociedad_propia || null,
      sociedad_pagadora_id: nuevoPedido.sociedad_pagadora_id || null,
      tipo_movimiento_id: nuevoPedido.tipo_movimiento_id || null,
      tipo_complejidad_id: nuevoPedido.tipo_complejidad_id || null,
      tipo_duracion_id: nuevoPedido.tipo_duracion_id || null,
      duracion_dias: nuevoPedido.duracion_dias || null,
      permitir_cancelaciones: nuevoPedido.permitir_cancelaciones,
      fecha_evento: nuevoPedido.fecha_evento,
      responsable_id: nuevoPedido.responsable_id || null,
      status: 'borrador'
    };
    const { error } = await supabase.from('te_pedidos').insert(payload);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('sitios_asignacion', 'INSERT', `pedido #${folio}: ${nuevoPedido.titulo}`);
    setNuevoPedidoOpen(false);
    setNuevoPedido(PEDIDO_VACIO);
    setMsg(`✓ Pedido #${folio} creado`);
    cargar();
  };

  const altaSitio = async (e) => {
    e.preventDefault();
    const { error } = await supabase.from('tc_sitios').insert({ ...nuevoSitio, tenant_id: DEMO_TENANT_ID });
    if (error) { setMsg('❌ ' + error.message); return; }
    setNuevoSitioOpen(false);
    setNuevoSitio({ titulo: '', tipo_sitio: 'sucursal', direccion: '' });
    setMsg('✓ Sitio creado');
    cargar();
  };

  // --- Agregar detalle (Escenario 1, pasos 11-22 del manual real) ---
  const onProductoChange = (productoId) => {
    const prod = productos.find(x => x.id === productoId);
    setNuevoDetalle(prev => ({ ...prev, producto_id: productoId, puesto_id: prod?.id_puesto || '' }));
  };

  const puestoDetalle = puestos.find(p => p.id === nuevoDetalle.puesto_id);

  const guardarDetalle = async (e) => {
    e.preventDefault();
    setMsgDetalle('');
    if (!nuevoDetalle.puesto_id) { setMsgDetalle('❌ Elegí un producto (define el puesto).'); return; }
    if (nuevoDetalle.fecha_liberacion && nuevoDetalle.fecha_cita &&
        new Date(nuevoDetalle.fecha_liberacion) > new Date(nuevoDetalle.fecha_cita)) {
      setMsgDetalle('❌ La fecha de liberación no puede ser posterior a la fecha de cita.');
      return;
    }
    const payload = {
      puesto_id: nuevoDetalle.puesto_id,
      producto_id: nuevoDetalle.producto_id || null,
      id_tipo_personal: nuevoDetalle.id_tipo_personal || null,
      cantidad: Number(nuevoDetalle.cantidad) || 1,
      turnos: Number(nuevoDetalle.turnos) || 1,
      fecha_cita: nuevoDetalle.fecha_cita || null,
      hora_cita_inicio: nuevoDetalle.hora_cita_inicio || null,
      hora_cita_fin: nuevoDetalle.hora_cita_fin || null,
      fecha_final_cita: nuevoDetalle.fecha_final_cita || null,
      fecha_liberacion: nuevoDetalle.fecha_liberacion || null,
      presentacion_id: nuevoDetalle.presentacion_id || null,
      fase_evento_id: nuevoDetalle.fase_evento_id || null,
      lugar_cita_id: nuevoDetalle.lugar_otro ? null : (nuevoDetalle.lugar_cita_id || null),
      lugar_otro: nuevoDetalle.lugar_otro,
      lugar_otro_descripcion: nuevoDetalle.lugar_otro ? (nuevoDetalle.lugar_otro_descripcion || null) : null,
      facturable: nuevoDetalle.facturable,
      permitir_cancelar_confirmaciones: nuevoDetalle.permitir_cancelar_confirmaciones,
      completar_productos_similares: nuevoDetalle.completar_productos_similares,
      indicaciones_especiales: nuevoDetalle.indicaciones_especiales || null
    };
    if (editandoDetalleId) {
      const { error } = await supabase.from('te_pedidos_detalle').update(payload).eq('id', editandoDetalleId);
      if (error) { setMsgDetalle('❌ ' + error.message); return; }
      await logAccion('sitios_asignacion', 'EDITAR_DETALLE', `pedido ${pedidoSel.folio}: detalle ${editandoDetalleId}`);
    } else {
      const { error } = await supabase.from('te_pedidos_detalle').insert({ ...payload, tenant_id: DEMO_TENANT_ID, pedido_id: pedidoSel.id });
      if (error) { setMsgDetalle('❌ ' + error.message); return; }
      await logAccion('sitios_asignacion', 'INSERT_DETALLE', `pedido ${pedidoSel.folio}: +${payload.cantidad} de producto`);
    }
    setDetalleOpen(false);
    setNuevoDetalle(DETALLE_VACIO);
    setEditandoDetalleId(null);
    await cargarDetallePedido(pedidoSel);
  };

  // --- Menú contextual de celda (Editar / Reservaciones / Cancelar / Liberar) ---
  // Réplica del menú de apoyo.rh.ocesa.mx/Pedidos al hacer click en una celda de
  // la matriz. "Liberar"/"Cancelar" aquí actúan sobre ESE renglón (te_pedidos_detalle),
  // a diferencia del botón "Liberar pedido" que libera todos los renglones del pedido.
  const abrirEditarDetalle = (pedidoDetalleId) => {
    const d = detalles.find(x => x.id === pedidoDetalleId);
    if (!d) return;
    setNuevoDetalle({
      id_tipo_personal: d.id_tipo_personal || '',
      producto_id: d.producto_id || '',
      puesto_id: d.puesto_id || '',
      cantidad: d.cantidad ?? 1,
      turnos: d.turnos ?? 1,
      fecha_cita: d.fecha_cita || '',
      hora_cita_inicio: d.hora_cita_inicio || '',
      hora_cita_fin: d.hora_cita_fin || '',
      fecha_final_cita: d.fecha_final_cita ? d.fecha_final_cita.slice(0, 10) : '',
      fecha_liberacion: d.fecha_liberacion ? d.fecha_liberacion.slice(0, 10) : '',
      presentacion_id: d.presentacion_id || '',
      fase_evento_id: d.fase_evento_id || '',
      lugar_cita_id: d.lugar_cita_id || '',
      lugar_otro: !!d.lugar_otro,
      lugar_otro_descripcion: d.lugar_otro_descripcion || '',
      facturable: d.facturable ?? true,
      permitir_cancelar_confirmaciones: d.permitir_cancelar_confirmaciones ?? true,
      completar_productos_similares: !!d.completar_productos_similares,
      indicaciones_especiales: d.indicaciones_especiales || ''
    });
    setEditandoDetalleId(pedidoDetalleId);
    setMsgDetalle('');
    setDetalleOpen(true);
  };

  const irAReservaciones = (pedidoDetalleId) => {
    nav(`/admin/preasignacion?detalle=${pedidoDetalleId}`);
  };

  const cancelarDetalleLinea = async (pedidoDetalleId) => {
    if (!confirm('¿Cancelar este renglón del pedido? Sus reservaciones vigentes también se cancelan.')) return;
    const { error } = await supabase.from('te_pedidos_detalle').update({ status_detalle: 'cancelado' }).eq('id', pedidoDetalleId);
    if (error) { setMsg('❌ ' + error.message); return; }
    await supabase.from('te_reservaciones').update({ estado: 'cancelado', regla_aplicada: 'cancelacion_detalle' })
      .eq('pedido_detalle_id', pedidoDetalleId).not('estado', 'in', '(procesado,cancelado)');
    await logAccion('sitios_asignacion', 'CANCELAR_DETALLE', `detalle ${pedidoDetalleId}`);
    setMsg('✓ Renglón cancelado');
    await cargarDetallePedido(pedidoSel);
  };

  const liberarDetalleLinea = async (pedidoDetalleId) => {
    if (!confirm('¿Liberar este renglón? Pasa a LIBERADO y se publica en el portal.')) return;
    const { error } = await supabase.from('te_pedidos_detalle').update({ status_detalle: 'liberado' }).eq('id', pedidoDetalleId);
    if (error) { setMsg('❌ ' + error.message); return; }
    await logAccion('sitios_asignacion', 'LIBERAR_DETALLE', `detalle ${pedidoDetalleId}`);
    setMsg('✓ Renglón liberado');
    await cargarDetallePedido(pedidoSel);
  };

  const exportarCSV = () => {
    if (pedidos.length === 0) return;
    const cols = ['folio', 'titulo', 'fecha_evento', 'status', 'sitio_id', 'cliente_id', 'costo_estimado'];
    const esc = v => v == null ? '' : `"${String(v).replace(/"/g, '""')}"`;
    const csv = [cols.join(','), ...pedidos.map(p => cols.map(c => esc(p[c])).join(','))].join('\n');
    const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `pedidos_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
  };

  const pedidosFiltrados = useMemo(() => pedidos.filter(p =>
    (filtroStatus === 'todos' || p.status === filtroStatus) &&
    (!busqueda || `${p.folio} ${p.titulo}`.toLowerCase().includes(busqueda.toLowerCase()))
  ), [pedidos, filtroStatus, busqueda]);

  const kpiActivos = pedidos.filter(p => !['cancelado', 'procesado'].includes(p.status)).length;
  const kpiHoy = pedidos.filter(p => p.fecha_evento === new Date().toISOString().slice(0, 10)).length;

  // ============================================================
  // VISTA DETALLE: si hay pedidoSel, muestra la ficha
  // ============================================================
  if (pedidoSel) {
    const nombreSitio = sitios.find(s => s.id === pedidoSel.sitio_id)?.titulo || '—';
    const nombreCliente = clientes.find(c => c.id === pedidoSel.cliente_id)?.razon_social;
    const totalReq = detalles.reduce((s, d) => s + Number(d.cantidad || 0), 0);
    const totalReserv = detalles.reduce((s, d) => s + Number(d.cantidad_reservados_real || 0), 0);
    const cobertura = totalReq > 0 ? totalReserv / totalReq : 0;

    return (
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 }}>
          <div>
            <button className="btn ghost sm" onClick={() => setPedidoSel(null)}>← Volver a lista</button>
            <div className="section-eyebrow" style={{ marginTop: 10 }}>Pedido #{pedidoSel.folio}</div>
            <h1>{pedidoSel.titulo}</h1>
            <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
              <Badge estado={pedidoSel.status === 'liberado' ? 'activo' : pedidoSel.status === 'cancelado' ? 'vencido' : pedidoSel.status === 'procesado' ? 'inactivo' : 'pendiente'}>
                {pedidoSel.status?.toUpperCase()}
              </Badge>
              <Badge estado="inactivo">{pedidoSel.fecha_evento}</Badge>
              <Badge estado="proceso">📍 {nombreSitio}</Badge>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6 }}>
            {pedidoSel.status !== 'liberado' && pedidoSel.status !== 'cancelado' && (
              <button className="btn green sm" onClick={liberarPedido}>🚀 Liberar pedido</button>
            )}
            {pedidoSel.status !== 'cancelado' && (
              <button className="btn red sm" onClick={cancelarPedido}>✗ Cancelar</button>
            )}
          </div>
        </div>

        {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

        {/* Pestañas al estilo sistema Lobo */}
        <div style={{ display: 'flex', gap: 0, borderBottom: '2px solid var(--border)', marginBottom: 20 }}>
          {[
            { k: 'general', label: '📋 Información principal', num: null },
            { k: 'matriz', label: '🎯 Matriz de puestos', num: detalles.length },
            { k: 'movtos', label: '📊 Movimientos / Reservaciones', num: reservaciones.length }
          ].map(t => (
            <button key={t.k}
              onClick={() => setPestana(t.k)}
              style={{
                padding: '10px 20px', border: 'none',
                background: pestana === t.k ? 'var(--accent-light)' : 'transparent',
                color: pestana === t.k ? 'var(--accent)' : 'var(--muted)',
                fontWeight: pestana === t.k ? 800 : 500,
                borderBottom: pestana === t.k ? '3px solid var(--accent)' : '3px solid transparent',
                cursor: 'pointer', fontSize: 13, marginBottom: -2
              }}>
              {t.label}{t.num !== null ? ` (${t.num})` : ''}
            </button>
          ))}
        </div>

        {pestana === 'general' && (
          <>
            <div className="kpi-grid">
              <KpiCard label="Cobertura" value={`${Math.round(cobertura * 100)}%`}
                sub={`${totalReserv} / ${totalReq} reservados`}
                color={cobertura >= 0.8 ? 'var(--green)' : cobertura >= 0.6 ? 'var(--gold)' : 'var(--red)'} />
              <KpiCard label="Detalles del pedido" value={detalles.length} sub="líneas de puestos" />
              <KpiCard label="Reservaciones" value={reservaciones.length} sub="empleados asignados" />
            </div>

            <div className="card">
              <h3 style={tituloConLinea}>📦 Datos del pedido</h3>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, fontSize: 13 }}>
                <div><div className="label">Cliente</div><div>{nombreCliente || '—'}</div></div>
                <div><div className="label">Contacto</div><div>{pedidoSel.contacto_nombre || '—'} {pedidoSel.contacto_telefono ? `· ${pedidoSel.contacto_telefono}` : ''}</div></div>
                <div><div className="label">Sitio / inmueble</div><div>{nombreSitio}</div></div>
                <div><div className="label">Lugar de cita</div><div>{lugaresCita.find(l => l.id === pedidoSel.lugar_cita_id)?.titulo || '—'}</div></div>
                <div><div className="label">Unidad de negocio</div><div>{unidadesNegocio.find(u => u.id === pedidoSel.unidad_negocio_id)?.titulo || '—'}</div></div>
                <div><div className="label">PEP</div><div>{peps.find(p => p.id === pedidoSel.partida_presupuestal_id)?.clave_pep || '—'}</div></div>
                <div><div className="label">Tipo de movimiento</div><div>{tiposMovimiento.find(t => t.id === pedidoSel.tipo_movimiento_id)?.titulo || '—'}</div></div>
                <div><div className="label">Sociedad pagadora</div><div>{sociedadesPagadoras.find(s => s.id === pedidoSel.sociedad_pagadora_id)?.titulo || '—'}</div></div>
                <div><div className="label">Permitir cancelaciones</div><div>{pedidoSel.permitir_cancelaciones ? 'Sí' : 'No'}</div></div>
                <div><div className="label">Fecha evento</div><div>{pedidoSel.fecha_evento}</div></div>
                <div><div className="label">Status</div><Badge estado={pedidoSel.status === 'liberado' ? 'activo' : 'pendiente'}>{pedidoSel.status}</Badge></div>
                <div><div className="label">Costo estimado</div><div>${fmt(pedidoSel.costo_estimado)}</div></div>
                {pedidoSel.subtotal && <div><div className="label">Subtotal</div><div>${fmt(pedidoSel.subtotal)}</div></div>}
                {pedidoSel.total_con_iva && <div><div className="label">Total con IVA</div><div style={{ fontWeight: 800 }}>${fmt(pedidoSel.total_con_iva)}</div></div>}
              </div>
            </div>
          </>
        )}

        {pestana === 'matriz' && (
          <div>
            <div className="card" style={{ padding: 0, marginBottom: 20 }}>
              <div style={{ padding: 16, borderBottom: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: 13, color: 'var(--muted)' }}>
                  Matriz de Puestos — fechas como columnas, Bloque + Producto como filas (equivalente a la matriz del sistema Lobo, vía <code>matriz_puestos_pedido()</code>).
                </span>
                {pedidoSel.status !== 'cancelado' && (
                  <button className="btn sm" onClick={() => { setNuevoDetalle({ ...DETALLE_VACIO, lugar_cita_id: pedidoSel?.lugar_cita_id || '' }); setEditandoDetalleId(null); setMsgDetalle(''); setDetalleOpen(true); }}>+ Agregar detalle</button>
                )}
              </div>
              {matrizPivot.grupos.length === 0 ? (
                <p className="empty" style={{ padding: 16 }}>Sin detalles capturados. Usá "+ Agregar detalle".</p>
              ) : (
                <TablaWrap>
                  <table>
                    <thead>
                      <tr>
                        <th>Bloque</th>
                        <th>Producto</th>
                        {matrizPivot.fechas.map(f => <th key={f} style={{ textAlign: 'center' }}>{new Date(f + 'T00:00:00').toLocaleDateString('es-MX', { day: '2-digit', month: '2-digit' })}</th>)}
                      </tr>
                    </thead>
                    <tbody>
                      {matrizPivot.grupos.map((g, i) => (
                        <tr key={i}>
                          <td className="mono">{g.bloque_num ?? '—'}</td>
                          <td>{g.producto_titulo}</td>
                          {matrizPivot.fechas.map(f => {
                            const c = g.celdas.get(f);
                            const menuOpen = c && menuCeldaId === c.pedido_detalle_id;
                            return (
                              <td key={f} style={{ textAlign: 'center', fontSize: 12, position: 'relative' }}>
                                {c ? (
                                  <>
                                    <span onClick={() => verDetalleCelda(c.pedido_detalle_id)} title="Ver detalle" style={{ cursor: 'pointer' }}>
                                      {c.cantidad} - T {Number(c.turnos || 0).toFixed(2)}
                                    </span>{' '}
                                    <button type="button" title="Más acciones"
                                      onClick={(e) => {
                                        e.stopPropagation();
                                        if (menuOpen) { setMenuCeldaId(null); return; }
                                        const r = e.currentTarget.getBoundingClientRect();
                                        setMenuPos({ top: r.bottom + 4, left: r.left + r.width / 2 });
                                        setMenuCeldaId(c.pedido_detalle_id);
                                      }}
                                      style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: 'var(--muted)', fontSize: 10, padding: '0 2px', verticalAlign: 'middle' }}>
                                      ▾
                                    </button>
                                    {menuOpen && menuPos && (
                                      <>
                                        <div onClick={() => setMenuCeldaId(null)} style={{ position: 'fixed', inset: 0, zIndex: 15 }} />
                                        <div style={{
                                          position: 'fixed', top: menuPos.top, left: menuPos.left, transform: 'translateX(-50%)', zIndex: 20,
                                          background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 'var(--border-radius)',
                                          boxShadow: 'var(--card-sh)', minWidth: 160, textAlign: 'left', overflow: 'hidden'
                                        }}>
                                          {[
                                            ['✏️ Editar', () => abrirEditarDetalle(c.pedido_detalle_id)],
                                            ['👥 Reservaciones', () => irAReservaciones(c.pedido_detalle_id)],
                                            ['✗ Cancelar', () => cancelarDetalleLinea(c.pedido_detalle_id)],
                                            ['🚀 Liberar', () => liberarDetalleLinea(c.pedido_detalle_id)]
                                          ].map(([label, fn]) => (
                                            <button key={label} type="button"
                                              onClick={() => { setMenuCeldaId(null); fn(); }}
                                              style={{ display: 'block', width: '100%', textAlign: 'left', padding: '8px 12px', border: 'none', background: 'transparent', cursor: 'pointer', fontSize: 12, fontWeight: 600 }}
                                              onMouseEnter={e => e.currentTarget.style.background = 'var(--surface2, rgba(0,0,0,.04))'}
                                              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
                                              {label}
                                            </button>
                                          ))}
                                        </div>
                                      </>
                                    )}
                                  </>
                                ) : '—'}
                              </td>
                            );
                          })}
                        </tr>
                      ))}
                      <tr style={{ fontWeight: 800, borderTop: '2px solid var(--border)' }}>
                        <td colSpan="2">Total Solicitados</td>
                        {matrizPivot.fechas.map(f => {
                          const total = matrizPivot.grupos.reduce((s, g) => s + (g.celdas.get(f)?.cantidad || 0), 0);
                          return <td key={f} style={{ textAlign: 'center' }}>{total || '—'}</td>;
                        })}
                      </tr>
                      <tr style={{ fontWeight: 800 }}>
                        <td colSpan="2">Presupuesto por día</td>
                        {matrizPivot.fechas.map(f => (
                          <td key={f} style={{ textAlign: 'center' }}>${fmt(matrizPivot.presupuestoPorFecha?.get(f) || 0)}</td>
                        ))}
                      </tr>
                    </tbody>
                  </table>
                </TablaWrap>
              )}
            </div>

            <div className="card" style={{ padding: 0 }}>
              <div style={{ padding: 16, borderBottom: '1px solid var(--border)', fontSize: 13, color: 'var(--muted)' }}>
                Detalle por línea. Cada renglón es un <code>te_pedidos_detalle</code>.
              </div>
              <TablaWrap>
                <table>
                  <thead>
                    <tr><th>#</th><th>Puesto</th><th>Producto</th><th>Fecha cita</th><th style={{ textAlign: 'right' }}>Cant. req.</th><th style={{ textAlign: 'right' }}>Reservados</th><th style={{ textAlign: 'right' }}>%</th><th>Cobertura</th><th>Estado</th></tr>
                  </thead>
                  <tbody>
                    {detalles.length === 0 && <tr><td colSpan="9" className="empty">Sin detalles capturados. Usá "+ Agregar detalle".</td></tr>}
                    {detalles.map((d, i) => {
                      const pct = d.cantidad > 0 ? (d.cantidad_reservados_real || 0) / d.cantidad : 0;
                      return (
                        <tr key={d.id}>
                          <td className="mono">{i + 1}</td>
                          <td>{d.tc_puestos?.titulo || '(puesto)'}</td>
                          <td>{d.tc_productos?.titulo || '—'}</td>
                          <td>{d.fecha_cita || '—'}</td>
                          <td style={{ textAlign: 'right' }}>{d.cantidad}</td>
                          <td style={{ textAlign: 'right' }}>{d.cantidad_reservados_real || 0}</td>
                          <td style={{ textAlign: 'right' }}>{Math.round(pct * 100)}%</td>
                          <td style={{ minWidth: 120 }}><Semaforo porcentaje={pct} /></td>
                          <td>
                            <Badge estado={d.status_detalle === 'liberado' ? 'activo' : d.status_detalle === 'cancelado' ? 'vencido' : d.status_detalle === 'procesado' ? 'inactivo' : 'pendiente'}>
                              {d.status_detalle || 'borrador'}
                            </Badge>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </TablaWrap>
            </div>
          </div>
        )}

        {pestana === 'movtos' && (
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: 16, borderBottom: '1px solid var(--border)', fontSize: 13, color: 'var(--muted)' }}>
              Empleados asignados a este pedido. Aquí se ven las reservaciones vigentes (preasignadas, confirmadas, forzadas).
            </div>
            <TablaWrap>
              <table>
                <thead>
                  <tr><th>Empleado</th><th>Puesto</th><th>Cita inicio</th><th>Estado reserv.</th><th>Estado asist.</th></tr>
                </thead>
                <tbody>
                  {reservaciones.length === 0 && <tr><td colSpan="5" className="empty">Sin reservaciones. Se generan cuando el freelance se inscribe o RRHH preasigna.</td></tr>}
                  {reservaciones.map(r => (
                    <tr key={r.id}>
                      <td>#{r.te_empleados?.folio} {r.te_empleados?.nombres} {r.te_empleados?.apellido_paterno}</td>
                      <td className="mono" style={{ fontSize: 11 }}>{r.puesto_id?.slice(0, 8)}…</td>
                      <td>{new Date(r.cita_inicio).toLocaleString('es-MX')}</td>
                      <td><Badge estado={
                        r.estado === 'confirmado_voluntario' || r.estado === 'confirmado_opcional' ? 'activo' :
                        r.estado === 'forzada' ? 'proceso' :
                        r.estado === 'preasignado' ? 'pendiente' :
                        r.estado === 'cancelado' ? 'vencido' :
                        r.estado === 'procesado' ? 'inactivo' : 'inactivo'
                      }>{r.estado?.replace(/_/g, ' ')}</Badge></td>
                      <td><Badge estado={r.estado_asistencia === 'asistencia' ? 'activo' : r.estado_asistencia === 'falta' ? 'vencido' : r.estado_asistencia === 'retardo' ? 'pendiente' : 'inactivo'}>{r.estado_asistencia}</Badge></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TablaWrap>
          </div>
        )}

        {/* Modal: Agregar/Editar Detalle (Escenario 1, pasos 11-22; "Editar" reutiliza la misma pantalla, como en el legado) */}
        <Modal open={detalleOpen} onClose={() => setDetalleOpen(false)} title={editandoDetalleId ? 'Editar detalle del pedido' : 'Agregar detalle al pedido'} wide
          footer={<><button className="btn ghost" onClick={() => setDetalleOpen(false)}>Cancelar</button>
            <button className="btn" onClick={guardarDetalle}>{editandoDetalleId ? 'Guardar cambios' : 'Agregar registro'}</button></>}>
          <form onSubmit={guardarDetalle} style={{ display: 'grid', gap: 12 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div><label className="label">Tipo de personal</label>
                <select className="field" value={nuevoDetalle.id_tipo_personal} onChange={e => setNuevoDetalle({ ...nuevoDetalle, id_tipo_personal: e.target.value })}>
                  <option value="">— elegir —</option>
                  {tiposPersonal.map(t => <option key={t.id} value={t.id}>{t.descripcion || t.clave}</option>)}
                </select>
              </div>
              <div><label className="label">Producto *</label>
                <select required className="field" value={nuevoDetalle.producto_id} onChange={e => onProductoChange(e.target.value)}>
                  <option value="">— elegir —</option>
                  {productos.map(p => <option key={p.id} value={p.id}>{p.titulo}{p.subcategoria ? ` - ${p.subcategoria}` : ''}</option>)}
                </select>
              </div>
            </div>
            {puestoDetalle && (
              <p style={{ fontSize: 12, color: 'var(--muted)' }}>
                Puesto: <strong>{puestoDetalle.titulo}</strong>
                {puestoDetalle.duracion_turno_horas ? ` · se maneja 1 turno = ${puestoDetalle.duracion_turno_horas} horas` : ''}
              </p>
            )}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div><label className="label">Cantidad *</label>
                <input required type="number" min="1" className="field" value={nuevoDetalle.cantidad} onChange={e => setNuevoDetalle({ ...nuevoDetalle, cantidad: e.target.value })} />
              </div>
              <div><label className="label">Turnos *</label>
                <input required type="number" min="0.5" step="0.5" className="field" value={nuevoDetalle.turnos} onChange={e => setNuevoDetalle({ ...nuevoDetalle, turnos: e.target.value })} />
              </div>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
              <div><label className="label">Fecha de cita</label>
                <input type="date" className="field" value={nuevoDetalle.fecha_cita} onChange={e => setNuevoDetalle({ ...nuevoDetalle, fecha_cita: e.target.value })} />
              </div>
              <div><label className="label">Hora inicio</label>
                <input type="time" className="field" value={nuevoDetalle.hora_cita_inicio} onChange={e => setNuevoDetalle({ ...nuevoDetalle, hora_cita_inicio: e.target.value })} />
              </div>
              <div><label className="label">Hora fin</label>
                <input type="time" className="field" value={nuevoDetalle.hora_cita_fin} onChange={e => setNuevoDetalle({ ...nuevoDetalle, hora_cita_fin: e.target.value })} />
              </div>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div><label className="label">Fecha final de cita</label>
                <input type="date" className="field" value={nuevoDetalle.fecha_final_cita} onChange={e => setNuevoDetalle({ ...nuevoDetalle, fecha_final_cita: e.target.value })} />
                <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }}>Último día que cubre este renglón (eventos multi-día).</p>
              </div>
              <div><label className="label">Fecha de liberación</label>
                <input type="date" className="field" value={nuevoDetalle.fecha_liberacion} onChange={e => setNuevoDetalle({ ...nuevoDetalle, fecha_liberacion: e.target.value })} />
                <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }}>No puede ser posterior a la fecha de cita.</p>
              </div>
            </div>
            <div>
              <label className="label">Lugar de cita</label>
              <div style={{ display: 'flex', gap: 16, marginBottom: 6 }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="radio" name="lugarCitaModo" checked={!nuevoDetalle.lugar_otro} onChange={() => setNuevoDetalle({ ...nuevoDetalle, lugar_otro: false })} />
                  Elegir sitio
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="radio" name="lugarCitaModo" checked={nuevoDetalle.lugar_otro} onChange={() => setNuevoDetalle({ ...nuevoDetalle, lugar_otro: true })} />
                  Otro
                </label>
              </div>
              {!nuevoDetalle.lugar_otro ? (
                <select className="field" value={nuevoDetalle.lugar_cita_id} onChange={e => setNuevoDetalle({ ...nuevoDetalle, lugar_cita_id: e.target.value })}>
                  <option value="">— elegir —</option>
                  {lugaresCita.map(l => <option key={l.id} value={l.id}>{l.titulo}</option>)}
                </select>
              ) : (
                <input className="field" placeholder="Dirección de la cita" value={nuevoDetalle.lugar_otro_descripcion} onChange={e => setNuevoDetalle({ ...nuevoDetalle, lugar_otro_descripcion: e.target.value })} />
              )}
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, alignItems: 'center' }}>
              <div><label className="label">Presentación por producto</label>
                <select className="field" value={nuevoDetalle.presentacion_id} onChange={e => setNuevoDetalle({ ...nuevoDetalle, presentacion_id: e.target.value })}>
                  <option value="">— sin presentación —</option>
                  {presentaciones.map(p => <option key={p.id} value={p.id}>{p.titulo}</option>)}
                </select>
              </div>
              <div><label className="label">Fase del evento</label>
                <select className="field" value={nuevoDetalle.fase_evento_id} onChange={e => setNuevoDetalle({ ...nuevoDetalle, fase_evento_id: e.target.value })}>
                  <option value="">— sin fase —</option>
                  {fasesEvento.map(f => <option key={f.id} value={f.id}>{f.titulo}</option>)}
                </select>
              </div>
            </div>
            <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <input type="checkbox" checked={nuevoDetalle.completar_productos_similares} onChange={e => setNuevoDetalle({ ...nuevoDetalle, completar_productos_similares: e.target.checked })} />
                Completar con similares
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <input type="checkbox" checked={nuevoDetalle.facturable} onChange={e => setNuevoDetalle({ ...nuevoDetalle, facturable: e.target.checked })} />
                Facturable
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <input type="checkbox" checked={nuevoDetalle.permitir_cancelar_confirmaciones} onChange={e => setNuevoDetalle({ ...nuevoDetalle, permitir_cancelar_confirmaciones: e.target.checked })} />
                Permitir cancelar confirmaciones
              </label>
            </div>
            <div><label className="label">Indicaciones especiales</label>
              <textarea className="field" rows="2" value={nuevoDetalle.indicaciones_especiales} onChange={e => setNuevoDetalle({ ...nuevoDetalle, indicaciones_especiales: e.target.value })}></textarea>
            </div>
            {msgDetalle && <p style={{ fontSize: 12 }}>{msgDetalle}</p>}
          </form>
        </Modal>

        {/* Popup "Detalle" — al dar click en una celda de la Matriz de Puestos,
            réplica del popup del sistema legado (apoyo.rh.ocesa.mx/Pedidos) */}
        <Modal open={!!celdaDetalle} onClose={() => setCeldaDetalle(null)}
          title={celdaDetalle ? (celdaDetalle.tc_productos?.titulo || celdaDetalle.tc_puestos?.titulo || 'Detalle') : 'Detalle'}
          footer={<button className="btn ghost" onClick={() => setCeldaDetalle(null)}>Cerrar</button>}>
          {celdaDetalle && (
            <div style={{ display: 'grid', gap: 10, fontSize: 13 }}>
              <div style={{ borderBottom: '2px solid var(--accent)', paddingBottom: 8 }}>
                <div className="label">ID</div>
                <div className="mono" style={{ fontSize: 11 }}>{celdaDetalle.id}</div>
              </div>
              <div><div className="label">Lugar de Cita</div>
                <div>{celdaDetalle.lugar_otro ? (celdaDetalle.lugar_otro_descripcion || '—') : (celdaDetalle.tc_lugares_cita?.titulo || nombreSitio)}</div>
              </div>
              <div><div className="label">Fecha Cita</div>
                <div>{celdaDetalle.fecha_cita || '—'}{celdaDetalle.hora_cita_inicio ? ` ${celdaDetalle.hora_cita_inicio}` : ''}</div>
              </div>
              <div><div className="label">Fecha Fin Cita</div>
                <div>
                  {celdaDetalle.fecha_final_cita
                    ? new Date(celdaDetalle.fecha_final_cita).toLocaleString('es-MX')
                    : `${celdaDetalle.fecha_cita || '—'}${celdaDetalle.hora_cita_fin ? ` ${celdaDetalle.hora_cita_fin}` : ''}`}
                </div>
              </div>
              <div><div className="label">Fecha Liberación</div>
                <div>{celdaDetalle.fecha_liberacion ? new Date(celdaDetalle.fecha_liberacion).toLocaleString('es-MX') : '—'}</div>
              </div>
              <div><div className="label">Completar con Similares</div>
                <div>{celdaDetalle.completar_productos_similares ? 'Sí' : 'No'}</div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
                <div><div className="label">Cantidad Reservados</div><div>{celdaDetalle.cantidad_reservados ?? 0}</div></div>
                <div><div className="label">Reservados Real</div><div>{celdaDetalle.cantidad_reservados_real ?? 0}</div></div>
                <div><div className="label">Con Preasignados</div><div>{celdaDetalle.cantidad_reservados_con_pre ?? 0}</div></div>
              </div>
              <div><div className="label">Porcentaje Completo</div>
                <div>{Number(celdaDetalle.porcentaje_completo || 0)}%</div>
              </div>
              <div><div className="label">Fase del Evento</div>
                <div>{celdaDetalle.tc_fases_evento?.titulo || celdaDetalle.fase_evento_str || '—'}</div>
              </div>
            </div>
          )}
        </Modal>
      </div>
    );
  }

  // ============================================================
  // VISTA LISTA: toolbar (agregar/exportar/filtros) + tabla pedidos
  // ============================================================
  return (
    <div>
      <div className="section-eyebrow">Operación</div>
      <h1>Pedidos, sitios y asignación</h1>
      <p style={{ color: 'var(--muted)', marginBottom: 20 }}>
        Módulo central de operación. Cada pedido es una necesidad de personal para una fecha en un sitio.
      </p>

      <div className="kpi-grid">
        <KpiCard label="Pedidos activos" value={kpiActivos} sub="no cancelados" onClick={() => setFiltroStatus('borrador')} />
        <KpiCard label="Pedidos hoy" value={kpiHoy} sub={new Date().toLocaleDateString('es-MX')} color="var(--green)" />
        <KpiCard label="Sitios activos" value={sitios.filter(s => s.activo).length} sub={`de ${sitios.length}`} />
        <KpiCard label="Clientes" value={clientes.length} sub="con pedidos" color="var(--accent2)" />
      </div>

      {/* Toolbar tipo Lobo */}
      <div className="card" style={{ padding: 12, marginBottom: 12 }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center' }}>
          <button className="btn" onClick={() => { setNuevoPedido(PEDIDO_VACIO); setMsg(''); setNuevoPedidoOpen(true); }}>+ Nuevo pedido</button>
          <button className="btn ghost sm" onClick={() => setNuevoSitioOpen(true)}>+ Sitio</button>
          <button className="btn outline sm" onClick={exportarCSV}>📥 Exportar CSV</button>
          <span style={{ flex: 1 }} />
          <input className="field" style={{ maxWidth: 240 }} placeholder="Buscar por folio o título…" value={busqueda} onChange={e => setBusqueda(e.target.value)} />
        </div>
        <div className="chips" style={{ margin: '10px 0 0' }}>
          {['todos', 'borrador', 'liberado', 'procesado', 'cancelado'].map(s => (
            <Chip key={s} active={filtroStatus === s} onClick={() => setFiltroStatus(filtroStatus === s ? 'todos' : s)}>
              {s}
            </Chip>
          ))}
        </div>
      </div>

      {msg && <p style={{ fontSize: 12, marginBottom: 12 }}>{msg}</p>}

      <TablaWrap>
        <table>
          <thead>
            <tr><th>Folio</th><th>Título</th><th>Fecha evento</th><th>Sitio</th><th>Cliente</th><th>Status</th><th style={{ textAlign: 'right' }}>Total</th></tr>
          </thead>
          <tbody>
            {pedidosFiltrados.length === 0 && <tr><td colSpan="7" className="empty">Sin pedidos que coincidan. Crea uno nuevo o cambia el filtro.</td></tr>}
            {pedidosFiltrados.map(p => (
              <tr key={p.id} className="clickable" onClick={() => cargarDetallePedido(p)}>
                <td className="mono">#{p.folio}</td>
                <td>{p.titulo}</td>
                <td>{p.fecha_evento}</td>
                <td>{sitios.find(s => s.id === p.sitio_id)?.titulo || '—'}</td>
                <td>{clientes.find(c => c.id === p.cliente_id)?.razon_social || '—'}</td>
                <td><Badge estado={p.status === 'liberado' ? 'activo' : p.status === 'cancelado' ? 'vencido' : p.status === 'procesado' ? 'inactivo' : 'pendiente'}>{p.status}</Badge></td>
                <td style={{ textAlign: 'right' }} className="mono">{p.total_con_iva ? '$' + fmt(p.total_con_iva) : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </TablaWrap>

      {/* Modal: Registro de pedido (Escenario 1, pasos 1-10 del manual real) */}
      <Modal open={nuevoPedidoOpen} onClose={() => setNuevoPedidoOpen(false)} title="Registro de pedido" wide
        footer={<><button className="btn ghost" onClick={() => setNuevoPedidoOpen(false)}>Cancelar</button>
          <button className="btn" onClick={altaPedido}>Aceptar</button></>}>
        <form onSubmit={altaPedido} style={{ display: 'grid', gap: 14 }}>
          <div><label className="label">Título del pedido *</label>
            <input required className="field" value={nuevoPedido.titulo} onChange={e => setNuevoPedido({ ...nuevoPedido, titulo: e.target.value })} />
          </div>

          <div className="section-eyebrow" style={{ marginTop: 4 }}>Cliente y evento</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Cliente *</label>
              <select required className="field" value={nuevoPedido.cliente_id}
                onChange={e => setNuevoPedido({ ...nuevoPedido, cliente_id: e.target.value, contacto_id: '', evento_id: '' })}>
                <option value="">— elegir —</option>
                {clientes.map(c => <option key={c.id} value={c.id}>{c.razon_social}</option>)}
              </select>
            </div>
            <div><label className="label">Contacto</label>
              <select className="field" value={nuevoPedido.contacto_id} disabled={!nuevoPedido.cliente_id}
                onChange={e => setNuevoPedido({ ...nuevoPedido, contacto_id: e.target.value })}>
                <option value="">{nuevoPedido.cliente_id ? '— elegir —' : 'elegí cliente primero'}</option>
                {contactos.map(c => <option key={c.id} value={c.id}>{c.nombre}{c.telefono ? ` · ${c.telefono}` : ''}</option>)}
              </select>
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr auto', gap: 12, alignItems: 'end' }}>
            <div><label className="label">Evento</label>
              <select className="field" value={nuevoPedido.evento_id} disabled={!nuevoPedido.cliente_id}
                onChange={e => setNuevoPedido({ ...nuevoPedido, evento_id: e.target.value })}>
                <option value="">{nuevoPedido.cliente_id ? '— elegir —' : 'elegí cliente primero'}</option>
                {eventos.map(ev => <option key={ev.id} value={ev.id}>{ev.titulo}</option>)}
              </select>
            </div>
            <div><label className="label">…o crear evento nuevo</label>
              <input className="field" placeholder="Título del evento" value={nuevoEventoTitulo} disabled={!nuevoPedido.cliente_id}
                onChange={e => setNuevoEventoTitulo(e.target.value)} />
            </div>
            <button type="button" className="btn ghost sm" disabled={!nuevoPedido.cliente_id || !nuevoEventoTitulo.trim()} onClick={crearEventoRapido}>+ Crear</button>
          </div>
          <div><label className="label">Fecha del evento *</label>
            <input required type="date" className="field" value={nuevoPedido.fecha_evento} onChange={e => setNuevoPedido({ ...nuevoPedido, fecha_evento: e.target.value })} />
          </div>

          <div className="section-eyebrow" style={{ marginTop: 4 }}>Ubicación y presupuesto</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Unidad de negocio *</label>
              <select required className="field" value={nuevoPedido.unidad_negocio_id}
                onChange={e => setNuevoPedido({ ...nuevoPedido, unidad_negocio_id: e.target.value, partida_presupuestal_id: '' })}>
                <option value="">— elegir —</option>
                {unidadesNegocio.map(u => <option key={u.id} value={u.id}>{u.titulo}</option>)}
              </select>
            </div>
            <div><label className="label">PEP *</label>
              <select required className="field" value={nuevoPedido.partida_presupuestal_id} disabled={!nuevoPedido.unidad_negocio_id}
                onChange={e => onPepChange(e.target.value)}>
                <option value="">{nuevoPedido.unidad_negocio_id ? '— elegir —' : 'elegí unidad de negocio primero'}</option>
                {peps.map(p => <option key={p.id} value={p.id}>{p.clave_pep} — {p.descripcion}</option>)}
              </select>
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Sitio / inmueble *</label>
              <select required className="field" value={nuevoPedido.sitio_id} onChange={e => setNuevoPedido({ ...nuevoPedido, sitio_id: e.target.value })}>
                <option value="">— elegir —</option>
                {sitios.filter(s => s.activo).map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
              <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }}>Se autocompleta al elegir el PEP si tiene inmueble predeterminado.</p>
            </div>
            <div><label className="label">Lugar de cita</label>
              <select className="field" value={nuevoPedido.lugar_cita_id} onChange={e => setNuevoPedido({ ...nuevoPedido, lugar_cita_id: e.target.value })}>
                <option value="">— elegir —</option>
                {lugaresCita.map(l => <option key={l.id} value={l.id}>{l.titulo}</option>)}
              </select>
            </div>
          </div>

          <div className="section-eyebrow" style={{ marginTop: 4 }}>Facturación y tipo de movimiento</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label className="label">Tipo de movimiento *</label>
              <select required className="field" value={nuevoPedido.tipo_movimiento_id} onChange={e => setNuevoPedido({ ...nuevoPedido, tipo_movimiento_id: e.target.value })}>
                <option value="">— elegir —</option>
                {tiposMovimiento.map(t => <option key={t.id} value={t.id}>{t.titulo}{t.se_factura ? ' (se factura)' : ''}</option>)}
              </select>
            </div>
            <div><label className="label">Sociedad propia</label>
              <select className="field" value={nuevoPedido.id_sociedad_propia} onChange={e => setNuevoPedido({ ...nuevoPedido, id_sociedad_propia: e.target.value })}>
                <option value="">— elegir —</option>
                {sociedadesPropias.map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, alignItems: 'end' }}>
            <div><label className="label">Sociedad pagadora</label>
              <select className="field" value={nuevoPedido.sociedad_pagadora_id} onChange={e => setNuevoPedido({ ...nuevoPedido, sociedad_pagadora_id: e.target.value })}>
                <option value="">— elegir —</option>
                {sociedadesPagadoras.map(s => <option key={s.id} value={s.id}>{s.titulo}</option>)}
              </select>
            </div>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
              <input type="checkbox" checked={nuevoPedido.permitir_cancelaciones} onChange={e => setNuevoPedido({ ...nuevoPedido, permitir_cancelaciones: e.target.checked })} />
              Permitir cancelaciones
            </label>
          </div>

          <details>
            <summary style={{ cursor: 'pointer', fontSize: 13, fontWeight: 700, color: 'var(--muted)' }}>Complejidad y responsable (opcional)</summary>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12, marginTop: 10 }}>
              <div><label className="label">Tipo de complejidad</label>
                <select className="field" value={nuevoPedido.tipo_complejidad_id} onChange={e => setNuevoPedido({ ...nuevoPedido, tipo_complejidad_id: e.target.value })}>
                  <option value="">— ninguno —</option>
                  {tiposComplejidad.map(t => <option key={t.id} value={t.id}>{t.titulo}</option>)}
                </select>
              </div>
              <div><label className="label">Tipo de duración</label>
                <select className="field" value={nuevoPedido.tipo_duracion_id} onChange={e => setNuevoPedido({ ...nuevoPedido, tipo_duracion_id: e.target.value })}>
                  <option value="">— ninguno —</option>
                  {tiposDuracion.map(t => <option key={t.id} value={t.id}>{t.titulo}</option>)}
                </select>
              </div>
              <div><label className="label">Duración (días)</label>
                <input type="number" min="1" className="field" value={nuevoPedido.duracion_dias} onChange={e => setNuevoPedido({ ...nuevoPedido, duracion_dias: e.target.value })} />
              </div>
            </div>
            <div style={{ marginTop: 10 }}><label className="label">Responsable</label>
              <select className="field" value={nuevoPedido.responsable_id} onChange={e => setNuevoPedido({ ...nuevoPedido, responsable_id: e.target.value })}>
                <option value="">— ninguno —</option>
                {responsables.map(r => <option key={r.id} value={r.id}>{r.nombre}</option>)}
              </select>
            </div>
          </details>

          <p style={{ fontSize: 11, color: 'var(--muted)' }}>El plan del tenant se verifica en la base al insertar (trigger tg_ped_plan). El folio se asigna con <code>siguiente_folio()</code>.</p>
        </form>
      </Modal>

      <Modal open={nuevoSitioOpen} onClose={() => setNuevoSitioOpen(false)} title="Nuevo sitio"
        footer={<><button className="btn ghost" onClick={() => setNuevoSitioOpen(false)}>Cancelar</button>
          <button className="btn" onClick={altaSitio}>Crear</button></>}>
        <form onSubmit={altaSitio} style={{ display: 'grid', gap: 12 }}>
          <div><label className="label">Nombre *</label><input required className="field" value={nuevoSitio.titulo} onChange={e => setNuevoSitio({ ...nuevoSitio, titulo: e.target.value })} /></div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 12 }}>
            <div><label className="label">Tipo</label>
              <select className="field" value={nuevoSitio.tipo_sitio} onChange={e => setNuevoSitio({ ...nuevoSitio, tipo_sitio: e.target.value })}>
                {['sucursal', 'tienda', 'obra', 'foro', 'oficina', 'evento', 'otro'].map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            <div><label className="label">Dirección</label><input className="field" value={nuevoSitio.direccion} onChange={e => setNuevoSitio({ ...nuevoSitio, direccion: e.target.value })} /></div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
