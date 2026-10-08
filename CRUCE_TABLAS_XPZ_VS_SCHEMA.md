# Cruce: 143 tablas reales del XPZ vs. esquema actual (db/reset_database.sql, 96 tablas)

Emparejamiento automatico por similitud de nombre (no es 100% confiable; revisar los casos marcados como dudosos). Para los pares con score alto se muestra tambien el diff de columnas: cuales atributos de GeneXus NO se identificaron en la tabla actual.

**Resumen:** 73 con match de alta confianza, 59 de confianza media (revisar), 11 sin match razonable (posiblemente faltantes por completo en el esquema actual).

---

## 0. Revisión manual -- correcciones al emparejamiento automático

El emparejamiento por similitud de texto falla por debajo de ~0.85 de score porque compara nombres, no significado. Se revisaron a mano la sección C completa (11 "sin match") y la sección D completa (35 tablas del esquema actual "sin origen"), cruzándolas entre sí y contra `HALLAZGOS_ACCDB_DATOS_REALES.md`. Esto es más confiable que las secciones A/B de abajo para las tablas aquí listadas -- úsese esto en vez del score automático para estos casos:

**Parejas reales que el algoritmo no encontró (por nombre muy distinto, pero mismo concepto):**
| Tabla GeneXus (XPZ) | Tabla actual | Nota |
|---|---|---|
| `TC_Pep` (Presupuestos, 12 cols) | `tc_partidas_presupuestales` (15 cols) | Es el PEP/centro de costo -- confirmado también en `dbo_Peps y Centros de Costos` del Access real |
| `TA_ManejoImagenes` (4 cols) | `te_adjuntos` (24 cols) | Manejo de imágenes genérico -> patrón de adjuntos polimórficos ya implementado, más completo que el original |
| `TE_LogEmp` (Movimientos empleado, 8 cols) | `te_movimientos_empleado` (13 cols) | Match directo por significado, nombre muy distinto en snake_case |
| `TP_Periodos` / `Periodos` (ambos mal emparejados con `te_pedidos` por el algoritmo) | `te_nominas_periodo` (11 cols) | Son los periodos de nómina, no de pedidos -- el algoritmo se equivocó feo aquí |
| `TC_Inmueble` (10 cols) | `tc_sitios` (18 cols) | Catálogo de inmuebles/propiedades -- probablemente el origen de `tc_sitios`, a confirmar con más detalle de columnas |

**Gaps reales confirmados (sí faltan, no es error del algoritmo):**
- **`TC_SegMovCan`** (Movimientos Candidatos) + **`TE_SegCan`** (Seguimiento Candidatos) -- no existe ningún equivalente a "bitácora de candidato" en el esquema actual (coincide con lo que ya decía `ANALISIS_BRECHAS_MANUALES_VS_MODELO.md` sección "Candidatos y reclutamiento": *"Seguimiento/bitácora de candidato... falta equivalente a nivel candidato"*). Acción: crear `te_seguimiento_candidato` (candidato_id, tipo_movimiento, fecha, observaciones, actor).
- **`TP_ImpHonoAsim`** (Impuestos honorarios asimilables, 9 cols) -- es la **tabla de tasas/rangos fiscales** que GeneXus usaba para CALCULAR el desglose fiscal que agregamos en la Migración 006 (`impuesto_marginal`, `cuota_fija`, `subsidio_acreditable`, `credito_general`...). Hoy esos campos existen en `te_nomina_detalle` como el RESULTADO calculado, pero no existe la tabla de parámetros/tasas de origen -- viola el principio "cero parámetros de negocio hardcodeados" si el cálculo se hace con constantes en código. Acción: crear `tp_tasas_honorarios_asimilables` (rango_desde, rango_hasta, tasa_im, cuota_fija, etc., vigencia).
- **`TP_ClaveExamen`** (Claves de puestos, 6 cols) -- claves/respuestas de examen psicométrico por puesto. Nicho, prioridad baja.
- **`TC_SucursalPag`** (Sucursal Pagadora, 2 cols) y **`TA_AltaEmp`** (3 cols) -- catálogos pequeños, prioridad baja, revisar si ya los cubre algo existente antes de crear tabla nueva.
- **`TE_Excel`** (4 cols) -- tabla de staging para exportar a Excel en el sistema legado; no aplica en la arquitectura nueva (se genera al vuelo), no requiere tabla.

**Tablas de la sección D que NO son gaps** -- son infraestructura SaaS multi-tenant que el sistema legado (on-premise, un solo cliente) nunca necesitó, agregadas intencionalmente en el rediseño: `te_tenants`, `te_suscripciones`, `tc_planes_suscripcion`, `tp_parametros_globales`, `te_magic_links`, `te_bitacora_accesos`, `te_intentos_acceso_portal`, `te_consentimientos` (LFT/privacidad), `te_export_sap_lote`, `te_facturas_serie`, `tr_asistencia_curso`, `tr_comunicado_destinatario`, `tr_empleado_plaza`, `tr_postulacion_candidato_vacante`, `tr_producto_puesto`, `te_vacante_plantilla`, `tl_movimientos_empleado_encabezado`, `tp_nomina_precauciones_catalogo`, `tp_precios_especiales_cliente`, `te_cambio_cuenta_bancaria`, `te_pedido_fechas`, `te_reservacion_bitacora`, `te_requisicion_personal`, `tc_colonias_cp`, `tc_dispositivos`, `tc_sociedades_propias`, `tc_tipos_documento`. `te_procesar_lista_manual` y `te_proceso_cierre_nomina` sí tienen origen real, pero en el Access (`dbo_Procesar Por Lista Manual`, `dbo_Proceso Cierre Nomina`), no en este XPZ específico -- ver `HALLAZGOS_ACCDB_DATOS_REALES.md`.

**Nota sobre la sección B (confianza media) de abajo:** varias de esas 59 parejas también están mal (ej. `TP_Usuario -> tc_causas_aclaracion` score 0.52 es absurdo -- `TP_Usuario` ya se resolvió en la Migración 005 como `te_usuarios`/`tc_roles`; `TC_Credenciales -> tr_credencial_puesto` debería apuntar a un catálogo `tc_credenciales` propio, no a la tabla de relación). No se revisó la sección B completa a mano por tiempo -- tratar cada entrada con escepticismo, especialmente las de score < 0.65.

---

## A. Matches de alta confianza

### TC_Puestos -> `tc_puestos` (score 1.00)
*Puestos* -- GeneXus: 36 cols, Postgres actual: 26 cols, encontradas: 6, **faltantes: 30**

Atributos de GeneXus NO identificados en la tabla actual: TC_UnidadNegID, TC_UnidadNegDes, TC_PuestosDes, TC_PuestosDEsUnidadNegocio, TC_PuestosHrasEntrTur, TC_PuestosHrasAntesCanPed, TC_SucursalPagId, TC_SucursalPagDes, TC_PuestosPorCerIni, TC_PuestosPorMin, TC_PuestosConEntrSer, TC_PuestosMatricial, TC_PuestosReqTimeScan, TC_ReglaAsistId, TC_ReglaAsistDes, TP_Id, TP_pago_default, TP_Idunidaddenegocio, TP_puestounidadnegocio, TP_reglaAsistTimescan, TP_PuestosConComplejidad, TP_puestosConFase, TC_Puestosmatri, TC_PuestosRegPag, TC_EmpresaPagadoraId, TC_EmpresaPagadoraNombre, TC_PuestosReqIngles, TC_PuestosReqExpLab, TC_PeriodicidadId, TC_PeriodicidadDesc

### TC_Turnos -> `tc_turnos` (score 1.00)
*Turnos* -- GeneXus: 3 cols, Postgres actual: 10 cols, encontradas: 1, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: TC_TurnosDes, TC_TurnosHras

### TC_Productos -> `tc_productos` (score 1.00)
*Catalogo Productos* -- GeneXus: 38 cols, Postgres actual: 11 cols, encontradas: 1, **faltantes: 37**

Atributos de GeneXus NO identificados en la tabla actual: TC_ProductosDEs, TC_PuestosId, TC_PuestosDes, TC_UnidadNegID, TC_UnidadNegDes, TC_PuestosPorCerIni, TC_PuestosConEntrSer, TC_PuestosMatricial, TC_PuestosPorMin, TP_pago_default, TC_PuestosRetardo, TC_PuestosFalta, TC_PuestosHrasAntesCanPed, TC_PuestosHrasEntrTur, TC_Puestosmatri, TC_PuestosDuracion, TP_ProductosUnidadNegocioID, TP_ProductosUnidad_de_Negocio, TP_ProductosSubCategoria, TP_ProductosIdPuestoCatalogo, TP_ProductosNumero_Material_SAP, TP_ProductosIdProductoSimilar1, TP_ProductosProductoSimilar1, TP_ProductosIdProductoSimilar2, TP_ProductosProducto_Similar2, TP_ProductosIdProductoSimilar3, TP_ProductosProductoSimilar3, TP_ProductosIdProductoSimilar4, TP_ProductosProductoSimilar4, TP_ProductosIdProductoSimilar5, TP_ProductosProductoSimilar5, TP_ProductosIdProductoSimilar6, TP_ProductosProductoSimilar6, TP_ProductosClave, TP_ProductosTituloCompleto, TP_ProductosVigente, TP_Productostp_Id

### TE_Clientes -> `tc_clientes` (score 1.00)
*Clientes* -- GeneXus: 23 cols, Postgres actual: 13 cols, encontradas: 2, **faltantes: 21**

Atributos de GeneXus NO identificados en la tabla actual: TE_ClientesNombre, TE_ClientesCliente, TE_ClientesEmail, TE_ClientesTel1, TE_ClientesTel2, TE_ClientesDireccion, TE_ClientesCodPostal, TE_ClientesEstado, TE_ClientesPais, TE_ClientesContacto, TE_ClientesTelContacto, TE_ClientesTipoCte, TE_ClientesRelacion, TE_ClientesWEB, TE_ClientesClienteSAP, TE_ClientesSocPag, TE_ClientesSocPagNombre, TC_TipoClienteId, TC_TipoClienteDesc, TE_ClientesMaterialSAP, TE_ClientesRererencia

### TE_Empleados -> `te_empleados` (score 1.00)
*Empleados* -- GeneXus: 16 cols, Postgres actual: 32 cols, encontradas: 2, **faltantes: 14**

Atributos de GeneXus NO identificados en la tabla actual: TE_EmpleadosNum, TE_EmpleadosApp, TE_EmpleadosApm, TE_EmpleadosAlias, TE_EmpleadosNomcomp, TE_EmpleadosFoto, TE_EmpleadosSolici, TC_RegPagoId, TC_RegPagoDes, TC_SucursalPagId, TC_SucursalPagDes, TE_empleadosFormapgo, TE_empleadosBusqueda, TE_empleadosUser

### TE_Comunicados -> `te_comunicados` (score 1.00)
*Comunicados* -- GeneXus: 6 cols, Postgres actual: 10 cols, encontradas: 2, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TE_ComunicadosAsunto, TE_ComunicadosFini, TE_ComunicadosFfin, TE_ComunicadosImagen

### TE_Aclaraciones -> `te_aclaraciones` (score 1.00)
*Aclaraciones empleados* -- GeneXus: 10 cols, Postgres actual: 15 cols, encontradas: 2, **faltantes: 8**

Atributos de GeneXus NO identificados en la tabla actual: TC_CausasAclaraId, TC_CausasAclaraDes, TE_AclaracionesAsun, TE_AclaracionesComRes, TE_ReservacionID, TE_EmpIdEmpleadoEventual, TE_EmpleadoBuscar, TE_pedDetTitu

### TC_bancos -> `tc_bancos` (score 1.00)
*Bancos* -- GeneXus: 3 cols, Postgres actual: 9 cols, encontradas: 2, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_BancosIMG

### TC_folios -> `tp_folios` (score 1.00)
*Folios* -- GeneXus: 3 cols, Postgres actual: 5 cols, encontradas: 1, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: TC_foliosNombre, TC_foliosNum

### TC_sociedadesPagadoras -> `tc_sociedades_pagadoras` (score 1.00)
*Sociedades pagadoras* -- GeneXus: 2 cols, Postgres actual: 11 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_SociedadesPagadorasDes

### TE_AgendaFreelance -> `te_agenda_freelance` (score 1.00)
*Agenda Freelance* -- GeneXus: 17 cols, Postgres actual: 12 cols, encontradas: 1, **faltantes: 16**

Atributos de GeneXus NO identificados en la tabla actual: TE_AgendaFreelanceEmpId, TE_ReservacionID, TE_EmpIdEmpleadoEventual, TE_EmpleadoBusXNombre, TE_pedDetId, TE_pedDetTitu, TE_PedidoID, TE_PeddetFechacitaJunta, TE_pedDetFeCita, TE_pedDetFeCitaHI, TE_pedDetFeCitaFi, TC_ProductosId, TE_pedDetTurnos, TE_AgendaFreelanceTiempoInicial, TE_AgendaFreelanceTiempoFinal, TE_AgendaFreelanceVigente

### TR_ProductosSimilares -> `tr_productos_similares` (score 1.00)
*Productos similares* -- GeneXus: 5 cols, Postgres actual: 9 cols, encontradas: 0, **faltantes: 5**

Atributos de GeneXus NO identificados en la tabla actual: TC_ProductosId, TC_ProductosDEs, SP_ProductosSimilaresId, SP_ProductosSimilaresDes, TR_ProductosSimilaresMarca

### Bancos -> `tc_bancos` (score 1.00)
*Bancos* -- GeneXus: 2 cols, Postgres actual: 9 cols, encontradas: 0, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: IdBanco, Titulo2

### TL_DetalleOperacion -> `tl_detalle_operacion` (score 1.00)
*Detalle operación* -- GeneXus: 8 cols, Postgres actual: 20 cols, encontradas: 1, **faltantes: 7**

Atributos de GeneXus NO identificados en la tabla actual: TL_DetalleOperacionFecha, TL_DetalleOperacionModulo, TL_DetalleOperacionAntes, TL_DetalleOperacionDespues, TL_DetalleOperacionIdRegistro, TL_DetalleOperacionUsuario, TL_DetalleOperacionFormulario

### Pedidos -> `te_pedidos` (score 1.00)
*Pedidos* -- GeneXus: 46 cols, Postgres actual: 19 cols, encontradas: 8, **faltantes: 38**

Atributos de GeneXus NO identificados en la tabla actual: Titulo3, IdCliente, Nombre_Cliente, RFC_Cliente, Direccion_Cliente, Telefono_Cliente, IdContacto, Nombre_Contacto, Telefono_Contacto, IdEvento, Titulo_Evento, PedidosIdSucursal, PedidosTitulo_Sucursal, PedidosIdUnidadDeNegocio, PedidosTitulo_Unidad_de_Negocio, IdPEP, Titulo_PEP, Descripcion_PEP, IdLugarCita, Lugar_Cita, Direccion_Lugar_Cita, Tipo_de_Movimiento, PedidosTitulo_Sociedad, IdSociedadPagadora, Titulo_Sociedad_Pagadora, IdTipoDeComplejidad, Titulo_Tipo_de_Complejidad, Duracion_del_Evento_Numero_de_Dias_, IdTipoDuracionDelEvento, Titulo_Duracion_del_Evento, Permitir_Cancelaciones, Status_Facturacion, SubTotal, IVA, Total_Con_IVA, PedidosCosto_Por_Nomina, IdResponsable, Version_Vigente

### Empleados -> `te_empleados` (score 1.00)
*Empleados* -- GeneXus: 58 cols, Postgres actual: 32 cols, encontradas: 11, **faltantes: 47**

Atributos de GeneXus NO identificados en la tabla actual: IdEmpleadoEventual, Tipo_de_Empleado, Primer_Apellido, Segundo_Apellido, EmpleadosStatus, Genero, Porcentaje_Puntualidad, Lugar_de_Trabajo_Eventos, EmpleadosIdSucursal, Nombre_Sucursal, EmpleadosCiclo_de_Pago, Correo_Electronico, Nombre_Banco, Cuenta_Banco, Fecha_de_Nacimiento, Estado_de_Nacimiento, Credencial_Elector, Cartilla, Estatura, Estado_Civil, Talla, Calle, Numero_Exterior, Numero_Interior, Colonia, Codigo_postal, Delegacion_o_Municipio, Estado_Provincia, Telefono_movil, Telefono_particular, Fecha_Ingreso, Fecha_Antiguedad, IdSolicitud, EmpleadosIdEmpresaPagadora, EmpleadosIdEmpresaPagadora_Lista, NombrePuesto, IdPuesto_Lista2, Grado_de_Estudios, Status_Grado_de_Estudios, Licenciatura_o_Curso, Idiomas, En_Caso_de_Accidente_avisar_A, Cirugias_Tratamientos_y_Padecimientos, Tipo_de_Sangre, Recomendado_Por, Status_Oculto, SobreNombre

### Puestos -> `tc_puestos` (score 1.00)
*Puestos* -- GeneXus: 24 cols, Postgres actual: 26 cols, encontradas: 11, **faltantes: 13**

Atributos de GeneXus NO identificados en la tabla actual: PuestosIdPuesto, PuestosIdUnidadDeNegocio, IdUnidadDeNegocio_Lista, Puesto_Unidad_de_Negocio, Horas_Antes_Para_Cancelar_Pedido, Confirmar_Entre_Seriados, Matricial, Requiere_TimeScan, Regla_para_Asistencia_por_TimeScan, Tipo_de_Registros_en_TimeScan, PuestosCiclo_de_Pago, Regimen_de_Pago, PuestosIdEmpresaPagadora_Lista

### Pedidos_Detalle -> `te_pedidos_detalle` (score 1.00)
*Pedidos_Detalle* -- GeneXus: 58 cols, Postgres actual: 11 cols, encontradas: 6, **faltantes: 52**

Atributos de GeneXus NO identificados en la tabla actual: Pedidos_DetalleTitulo, IdPedido, Pedidos_DetalleStatus, Producto, Titulo_Producto, Fecha_Entrega, Fecha_Fin_Cita, Fecha_Fin_Cita_Oculta, Fecha_Liberacion, Turnos, Pedidos_DetalleIdPuesto, Titulo_Puesto, Producto_Matricial, Presentacion, Titulo_Presentacion, Completar_Productos_Similares, Bloque, Fecha_Fin_Bloque, Fecha_Vigencia_Preasignados, Porcentaje_Completo, Completo, Porcentaje_Completo_con_Preasignados, Completo_con_Preasignados, Cantidad_Reservados, Cantidad_Reservados_con_Preasignados, Cantidad_Reservados_Real, Cantidad_Que_Asistieron, Id_Lugar_de_Entrega, Lugar_de_Entrega, Direccion_de_Entrega, Sucursal, Pedidos_DetalleTitulo_Sucursal, Pedidos_DetalleUnidad_de_Negocio, Pedidos_DetalleTitulo_Unidad_de_Negocio, Sociedad, Pedidos_DetalleTitulo_Sociedad, Indicaciones_Especiales, Periodo_de_Pago, Periodo_de_Lista_de_Asistencia, Facturable, FolioFactura, Factura_Servicio_Interno, Fase_del_Evento, Precio, Fecha_Envio_SMS, Pedidos_DetalleCosto_Por_Nomina, Pago_Especial, Permitir_Cancelar_Confirmaciones, Status_Envio_SMS, Envio_SMS_Preasignados, CorreoEnviado_Faltas, CorreoEnviado_PEP_Temporal

### Productos -> `tc_productos` (score 1.00)
*Productos* -- GeneXus: 24 cols, Postgres actual: 11 cols, encontradas: 4, **faltantes: 20**

Atributos de GeneXus NO identificados en la tabla actual: IdProducto2, IdPuestoCatalogo, ProductosIdUnidadDeNegocio, ProductosUnidad_de_Negocio, Numero_Material_SAP, IdProductoSimilar1, Producto_Similar1, IdProductoSimilar2, Producto_Similar2, IdProductoSimilar3, Producto_Similar3, IdProductoSimilar4, Producto_Similar4, IdProductoSimilar5, Producto_Similar5, IdProductoSimilar6, Producto_Similar6, Clave, Titulo_Completo, Productostp_Id

### TR_CredencialPuesto -> `tr_credencial_puesto` (score 1.00)
*Credencial puesto* -- GeneXus: 6 cols, Postgres actual: 9 cols, encontradas: 0, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TC_CredencialesId, TC_CredencialesNombre, TC_CredencialesFrente, TC_CredencialesReverso, TC_PuestosId, TC_PuestosDes

### TP_SueldoMatriciales -> `tp_sueldos_matriciales` (score 0.97)
*Sueldos Matriciales* -- GeneXus: 15 cols, Postgres actual: 15 cols, encontradas: 0, **faltantes: 15**

Atributos de GeneXus NO identificados en la tabla actual: Iddos, TP_SueldoMatricialIdPuesto, Titulo, TP_SueldoMatricialIdPuestoCatalogo, TP_SueldoMatricialIdTipoComplejidad, TP_SueldoMatricialIdTipoComplejidadCatalogo, TP_SueldoMatricialIdTipoDuracion, TP_SueldoMatricialIdTipoDuracionCatalogo, TP_SueldoMatricialFase_de_Evento, TP_SueldoMatricialSueldo_Base, TP_SueldoMatricialFecha_Inicio, TP_SueldoMatricialFecha_Fin, TP_SueldoMatricialActivo, tp_IdDOS, TP_SueldoMatricialesBorrar

### TP_PreciosProductos -> `tp_precios_producto` (score 0.97)
*TP_Precios Productos* -- GeneXus: 14 cols, Postgres actual: 13 cols, encontradas: 7, **faltantes: 7**

Atributos de GeneXus NO identificados en la tabla actual: TC_ProductosId, TC_ProductosDEs, TP_PreciosProductosFechaIncial, TP_PreciosProductosFechaFinal, TP_PreciosProductosVigencia, TP_PreciosProductosUniNeg, TP_PreciosProductosPuestoDes

### TC_TipoPersonal -> `tc_tipos_personal` (score 0.96)
*Tipo de Personal* -- GeneXus: 2 cols, Postgres actual: 8 cols, encontradas: 2, **faltantes: 0**

### TC_Responsable -> `tc_responsables` (score 0.96)
*Responsables* -- GeneXus: 8 cols, Postgres actual: 10 cols, encontradas: 2, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TC_ResponsableApp, TC_ResponsableMaterno, TC_ResponsableFoto, TC_ResponsableSexo, TC_ResponsableEmail, TC_ResponsablePass

### TC_FaseEvento -> `tc_fases_evento` (score 0.95)
*Fases deEventos* -- GeneXus: 2 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_FaseEventoDEs

### TE_FacturaEnc -> `te_facturas_enc` (score 0.95)
*Facturas* -- GeneXus: 65 cols, Postgres actual: 16 cols, encontradas: 2, **faltantes: 63**

Atributos de GeneXus NO identificados en la tabla actual: TE_FacturaEncIdFactura, TE_FacturaEncTipo, TE_FacturaEncPedido, TE_PedidoID, TC_PepPepDEs, ST_clientesID, ST_clientesNom, TE_PedidoTitulo, TC_UnidadNegDes, TC_ContactosNombreCompleto, ST_lugaresPedidosDes, TE_FacturaEncSucursal, TE_FacturaEncIdUnidadDeNegocio, TE_FacturaEncIdPep, TE_FacturaEncIdCliente, TE_FacturaEncTelefonoCliente, TE_FacturaEncIdContacto, TE_FacturaEncTelefonoContacto, TE_FacturaEncCorreoElecContacto1, TE_FacturaEncCorreoElecContacto2, TE_FacturaEncCorreoElecContacto3, TE_FacturaEncInmueble, TE_FacturaEncInmuebleOtro, TE_FacturaEncFechadeMovimiento, TE_FacturaEncNumeroSAP, TE_FacturaEncIdUnidadDeMedida, TE_FacturaEncFormaDePago, TE_FacturaEncMetodoDePago, TE_FacturaEncCuenta, TE_FacturaEncLugarDeExpedicion, TE_FacturaEncTipoDeCliente, TE_FacturaEncUsoCFI, TE_FacturaEncTipoRelacionCFDI, TE_FacturaEncUUIDRElacionado, TE_FacturaEncClaveUnidad, TE_FacturaEncClaveProducto, TE_FacturaEncAduana, TE_FacturaEncNumeroPedimentoAduana, TE_FacturaEncPatenteAduanal, TE_FacturaEncTextoCabezaPortal, TE_FacturaEncTextoPosicionPortal, TE_FacturaEncCondicionPago2, TE_FacturaEncTipoProceso, TE_FacturaEncTipoComite, TE_FacturaEncIdContabilidad, TE_FacturaEncAmbito, TE_FacturaEncConsecutivo, TE_FacturaEncClaveEntidad, TE_FacturaEncRetencion, TE_FacturaEncMoneda, TE_FacturaEncCentroCostos, TE_FacturaEncContarPartidas, TE_FacturaEncEstatus, TE_FacturaEncTXT, TE_FacturaEncOrganizacionVenta, TE_FacturaEncCanalDistribucion, TE_FacturaEncSector, TE_FacturaEncDEscripcion, TE_FacturaEncGeneradoSap, TC_TipoMovimientoId, TC_TipoMovimientoDesc, TC_SucursalID, TC_SucursalDes

### TE_FacturaDet -> `te_facturas_det` (score 0.95)
*Facturas detalle* -- GeneXus: 26 cols, Postgres actual: 12 cols, encontradas: 6, **faltantes: 20**

Atributos de GeneXus NO identificados en la tabla actual: TE_FacturaEncID, TE_FacturaDetDescripcion, TE_FacturaDetAgrupado, TC_ProductosId, TC_ProductosDEs, TP_ProductosNumero_Material_SAP, TE_FacturaDetFolio, TE_FacturaDetIdAgrupado, TE_FacturaDetFacServInterno, TE_FacturaDetIdProducto, TE_FacturaDetIdPedidoDetalle, TE_FacturaDetIdPedido, TE_FacturaDetPrecioUnitario, TE_FacturaDetProducto, TE_FacturaDetSubTotal, TE_FacturaDetTurnos, TE_FacturaDetIdFacturaServicioInterno, TE_FacturaDetContarPedidoDetalles, TE_FacturaDetTipo, TE_FacturaDetTienePedidos

### TE_CClientes -> `tc_clientes` (score 0.94)
*Contactos Clientes* -- GeneXus: 13 cols, Postgres actual: 13 cols, encontradas: 1, **faltantes: 12**

Atributos de GeneXus NO identificados en la tabla actual: TE_ClientesID, TE_ClientesNombre, TC_ContactosId, TC_ContactosPrimerApellido, TC_ContactosSegundoApellido, TC_ContactosNombreCompleto, TC_ContactosNombre, TC_ContactosTelefonoMovil, TC_ContactosEmail, TC_ContactosEmpresa, TC_ContactosPuesto, TE_CClientesNom

### TE_Empleado -> `te_empleados` (score 0.94)
*Empleado* -- GeneXus: 75 cols, Postgres actual: 32 cols, encontradas: 1, **faltantes: 74**

Atributos de GeneXus NO identificados en la tabla actual: TE_EmpIdEmpleadoEventual, Foto, TE_EmpTipo_de_Empleado, TE_EmpPrimer_Apellido, TE_EmpSegundo_Apellido, TE_EmpNombre, TE_EmpStatus, TE_EmpGenero, TE_EmpPorPuntualidad, TE_EmpLugarEvento, TE_EmpIdSucursal, TE_EmpNomSucursal, TE_EmpRegPago, TE_EmpCicloPago, TE_EmpCorreo_Electronico, TE_EmpIdBanco, TE_EmpNombre_Banco, TE_EmpCuenta_Banco, TE_EmpFecNac, TE_EmpEdoNac, TE_EmpRFC, TE_EmpCURP, TE_EmpCredElector, TE_EmpCartilla, TE_EmpEstatura, TE_EmpEdoCivil, TE_EmpTalla, TE_EmpDireccion, TE_EmpCalle, TE_EmpTE_EmpNumExt, TE_EmpNunInt, TE_EmpColonia, TE_EmpCodPostal, TE_EmpDelMun, TE_EmpEdoProv, TE_EmpTelMovil, TE_EmpTelPart, TE_EmpFecIng, TE_EmpFecAnt, TE_EmpFecBaja, TE_EmpIdSolicitud, TE_EmpIdEmpPagadora, TE_EmpIdEmpPagadora_L, TE_EmpIdPuesto, TE_EmpNombrePuesto, IdPuesto_Lista, TE_EmpCreado, TE_EmpModificado, TE_EmpGraEstudios, TE_EmpStatusGradoEstudio, TE_EmpLicCurso, TE_EmpIdiomas, TE_EmpAccidente, TE_EmpCirugiasTratam, TE_EmpTipoSangre, TE_EmpRecomendadoPor, TE_EmpStatus_Oculto, TE_EmpleadoBorrar, TE_EmpleadoAlias, TE_EmpleadoBuscar, TC_bancosID, TC_bancosNombre, TC_CodigoPosId, TC_CodigoPosMuni, TC_CodigoPosCiudad, TC_CodigoPosEsta, TC_codigoPosColId, TC_CodigoPosColNom, TC_SucursalID, TC_SucursalDes, TE_EmpleadoBusXNombre, TE_EmpleadoBusXNombre1, TE_EmpleadoBusReserva, TE_EmpleadoNombreCompleto

### TE_Vacante -> `te_vacantes` (score 0.93)
*Catálogo de vacantes* -- GeneXus: 15 cols, Postgres actual: 15 cols, encontradas: 2, **faltantes: 13**

Atributos de GeneXus NO identificados en la tabla actual: TE_VacanteFun, TE_VacanteReq, TC_PuestosId, TC_PuestosDes, TE_VacanteImagen, TE_VacanteLigaPsi, TE_VacanteCtitulo, TE_VacanteCCuer, TE_VacanteCIma, TE_VacanteCtaDoc, TE_VacanteREqIngles, TE_VacanteREqExp, TE_VacanteCodigo

### TE_Pedido -> `te_pedidos` (score 0.92)
*Pedidos* -- GeneXus: 70 cols, Postgres actual: 19 cols, encontradas: 7, **faltantes: 63**

Atributos de GeneXus NO identificados en la tabla actual: TC_EstatusAutID, TC_EstatusAutDes, ST_clientesID, ST_clientesNom, ST_ClientesSocPag, TE_ClientesCliente, TE_CClientesID, TE_CClientesNom, TC_ContactosEmail, TC_ContactosTelefonoParticular, TC_ContactosId, TC_ContactosNombreCompleto, TE_EventoID, TE_EventoDes, TE_EventoFeinicial, TC_SucursalID, TC_SucursalDes, ST_UnidadNegPedId, ST_UnidadNegPedDes, TC_PepId, TC_Pepdes, TC_PepUnidNegId, TC_PepLugarId, TC_PepPepDEs, ST_lugaresPedidosId, ST_lugaresPedidosDes, ST_lugaresPedidosdom, TE_PedidoDireccionLugar, TE_PedidoDireccionLugar1, TC_MovPedidosID, TC_MovPedidosDes, TE_PedidoTituloSoc, SP_SocPagId, SP_SocPagDes, TE_PedidoSociedadPagadora, TC_complejoid, TC_ComplejoDES, TE_PedidoDuracionDias, TE_PedidoIdTipoDuraEvento, TE_PedidoTituloDuraEvento, TE_PedidoPermConf, TE_PedidoStatusFact, TE_PedidoSubtotal, TE_PedidoIva, TE_PedidoTotalConIva, TE_PedidoCostoXNomina, TC_ResponsableId, TE_PedidoModicado, TE_PedidoVersionVigente, TC_SucursalPagId, TC_SucursalPagDes, TE_PedidoDes, TE_PedidoTipo, TE_PedidoFeregistro, TE_PedidoLugOtro, TE_PedidoOtroLugar, TE_PedidoLugOtroDire, TE_PedidoMonto, TE_EventoIMG, TE_pedidoContarProcesados, TE_Pedidoborrar, TC_ResponsableNom, TE_PedidoTieneComplejidad

### TC_bancos2 -> `tc_bancos` (score 0.92)
*TC_bancos2* -- GeneXus: 3 cols, Postgres actual: 9 cols, encontradas: 0, **faltantes: 3**

Atributos de GeneXus NO identificados en la tabla actual: TC_bancosID2, TC_bancosNombre2, TC_BancosIMG2

### TE_Reservacion -> `te_reservaciones` (score 0.92)
*TE_Reservacion* -- GeneXus: 97 cols, Postgres actual: 34 cols, encontradas: 20, **faltantes: 77**

Atributos de GeneXus NO identificados en la tabla actual: TE_ReservacionTitulo, TE_EmpIdEmpleadoEventual, TE_EmpleadoBuscar, TE_EmpleadoBusXNombre, TE_EmpleadoNombreCompleto, TE_EmpCorreo_Electronico, TE_EmpPorPuntualidad, TE_EmpRegPago, TC_bancosNombre, TE_EmpCuenta_Banco, TC_EmpresaPagadoraId, TC_EmpresaPagadoraNombre, TE_pedDetId, TE_PeddetCancelar, TE_PedidoID, TE_PedidoTitulo, TC_PepPep, TC_Pepdes, TC_SucursalPagId, TC_SucursalPagDes, TE_pedDetTurnos, TE_pedDetCompSim, TC_PresenProdDes, TC_ProductosId, TC_PuestosId, TC_PuestosFalta, TC_PuestosRetardo, TC_Puestosmatri, TE_PeddetBloqueNum, TC_FaseEventoID, TC_FaseEventoDEs, TE_PeddetFechacitaJunta, TE_PeddetFechacitaFin, TE_PeddetFechafincitaoculta, TC_PuestosHrasAntesCanPed, TE_PedidoDuracionDias, TC_complejoid, ST_UnidadNegPedId, ST_UnidadNegPedDes, TC_UnidadNegID, TC_UnidadNegDes, TC_SociedadesPagadorasID, TC_SociedadesPagadorasDes, TC_SociedadID, TC_SociedadDes, TE_PeddetProductoTitulo, TE_ReservacionIdPedido, TE_ReservacionTipo, TE_ReservacionHoraEntradaAsistencia, TE_ReservacionHoraSalidaAsistencia, TE_ReservacionPagoPorTurno, TE_ReservacionPagoProgramado, TE_ReservacionPagoReal, TE_ReservacionPeriodoAsistencia, TE_ReservPeriodoCobrado, TE_ReservacionAnioCobrado, TE_ReservacionIdProductoEvento, TE_ReservacionIdPuestoEvento, TE_ReservacionFormaDePago, TE_ReservacionBloque, TE_ReservacionSeriado, TE_ReservacionUnidadDeNegocio, TE_ReservacionSociedad, TE_ReservacionObservaciones, TE_ReservacionIP, TE_ReservIacionTimescanEntrada, TE_ReservacionIdTimescanSalida, TE_ReservacionTipoRegistroTimeScan, TE_ReservacionIdReservacion_Lobo, TE_ReservacionEnvioCorreoEmpalmes, TE_ReservaciontpIdPlaza, TE_ReservacionIdPagoHonorario, TE_ReservacionIdPagoHonorario_Lista, TE_ReservacionSinPlazaParaPago, TE_ReservacionCampo0, TE_ReservacionBorrar, TE_ReservacionHoraReservacion

### TL_CierreNomina -> `tl_log_cierre_nomina` (score 0.89)
*TL_Cierre Nomina* -- GeneXus: 4 cols, Postgres actual: 8 cols, encontradas: 2, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: TC_PeriodoID, TL_CierreNominaFechaHora

### TE_CierreNomina -> `tl_log_cierre_nomina` (score 0.89)
*TE_Cierre Nomina* -- GeneXus: 4 cols, Postgres actual: 8 cols, encontradas: 1, **faltantes: 3**

Atributos de GeneXus NO identificados en la tabla actual: TE_CierreNominaFolio, TE_CierreNominaFechaCierre, TE_CierreNominaTitulo

### TP_ReglasAsistTimeScan -> `tc_reglas_asistencia_timescan` (score 0.88)
*TP_Reglas Asist Time Scan* -- GeneXus: 6 cols, Postgres actual: 12 cols, encontradas: 2, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TP_ReglasAsistTimeScanMinAntesEntrada, TP_ReglasAsistTimeScanMinDespuesEntrada, TP_ReglasAsistTimeScanMinutosParaRetardo, TP_ReglasAsistTimeScanMinDespuesSalida

### TC_Estados -> `tc_estados_mx` (score 0.88)
*Estados* -- GeneXus: 2 cols, Postgres actual: 8 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_EstadosDes

### TL_AltasBajas -> `tl_log_altas_bajas` (score 0.87)
*TL_Altas Bajas* -- GeneXus: 8 cols, Postgres actual: 11 cols, encontradas: 4, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TL_AltasBajasNoEmpleado, TL_AltasBajasNombreEmp, TL_AltasBajasFechaHora, TL_AltasBajasUsuario

### TC_Ciudad -> `tc_ciudades` (score 0.86)
*Ciudades* -- GeneXus: 4 cols, Postgres actual: 9 cols, encontradas: 2, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: TC_EstadosID, TC_EstadosDes

### TC_CausasAclara -> `tc_causas_aclaracion` (score 0.86)
*Causas aclaraciones* -- GeneXus: 2 cols, Postgres actual: 8 cols, encontradas: 2, **faltantes: 0**

### TL_Movempleados -> `te_empleados` (score 0.86)
*Movientos empleados* -- GeneXus: 6 cols, Postgres actual: 32 cols, encontradas: 2, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TL_MovempleadosTotalProceso, TL_MovempleadosTotalProcesados, TL_MovempleadosEstatus, TL_MovempleadosUsuario

### TP_ProductoSimi -> `tc_productos` (score 0.86)
*TP_Producto Simi* -- GeneXus: 2 cols, Postgres actual: 11 cols, encontradas: 0, **faltantes: 2**

Atributos de GeneXus NO identificados en la tabla actual: IdProducto, IdProductoSimi

### TC_Credenciales -> `tr_credencial_puesto` (score 0.86)
*Credenciales* -- GeneXus: 4 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 3**

Atributos de GeneXus NO identificados en la tabla actual: TC_CredencialesNombre, TC_CredencialesFrente, TC_CredencialesReverso

### TE_Gpocitas -> `te_grupos_citas` (score 0.84)
*Grupos para entrevistas* -- GeneXus: 22 cols, Postgres actual: 16 cols, encontradas: 4, **faltantes: 18**

Atributos de GeneXus NO identificados en la tabla actual: TE_GpocitasHI, TE_GpocitasMin, TE_PubVacanteId, TE_VacanteId, TE_GpocitasTitulo, TE_GpocitasHrajunta, TC_PuestosId, TC_PuestosDes, TE_VacanteTitulo, TC_SucursalID, TC_SucursalDes, TE_GpocitasCitado, TE_GpocitasPorcen, TE_GpocitasHraEntre, TE_GpocitasCitadoProceso, TE_GpocitasCitadoHraCitaGpo, TE_GpocitasCierreAsisten, TE_GpocitasCierreFirmaContra

### TE_FacturaDetPed -> `te_facturas_det` (score 0.83)
*Detalles Pedidos Factura* -- GeneXus: 11 cols, Postgres actual: 12 cols, encontradas: 3, **faltantes: 8**

Atributos de GeneXus NO identificados en la tabla actual: TE_FacturaDetId, TE_FacturaEncID, TE_FacturaDetPedTitulo, TE_FacturaDetPedTurnos, TE_FacturaDetPedProductoID, TE_FacturaDetPedProductoDes, TE_FacturaDetPedPuestoID, TE_FacturaDetPedPedidoId

### TC_MovPedidos -> `te_pedidos` (score 0.82)
*Movimientos Pedidos* -- GeneXus: 2 cols, Postgres actual: 19 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_MovPedidosDes

### TC_EstacionNACS -> `tc_estaciones` (score 0.82)
*NACS* -- GeneXus: 5 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TC_EquipoBiometricoID, TC_EstacionNACSEStacion, TC_InmuebleID, TC_InmuebleDes

### TR_PuestosSimi -> `tr_puestos_similares` (score 0.81)
*Puestos Similares* -- GeneXus: 7 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TC_PuestosId, TC_PuestosDes, TC_UnidadNegID, TC_UnidadNegDes, TR_PuestosSimiDes, TR_PuestosSimiBorrar

### TP_Periodos -> `te_pedidos` (score 0.80)
*TP_Periodos* -- GeneXus: 5 cols, Postgres actual: 19 cols, encontradas: 1, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TP_PeriodosFecInicio, TP_PeriodosFecFin, TP_PeriodosActual, TP_PeriodosAnterior

### Periodos -> `te_pedidos` (score 0.80)
*Periodos* -- GeneXus: 4 cols, Postgres actual: 19 cols, encontradas: 1, **faltantes: 3**

Atributos de GeneXus NO identificados en la tabla actual: Fecha_Inicio, Fecha_Fin, Actual

### TC_TipoMovimiento -> `tc_tipos_movimiento_pedido` (score 0.80)
*Tipo de movimiento* -- GeneXus: 2 cols, Postgres actual: 11 cols, encontradas: 2, **faltantes: 0**

### TP_ProductosStaff -> `tc_productos` (score 0.78)
*Productos Staff* -- GeneXus: 8 cols, Postgres actual: 11 cols, encontradas: 2, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TP_ProductosStaffIdprod, TP_ProductosStaffProddDes, TP_ProductosStaffUnidadNego, TP_ProductosStaffComplejidad, TP_ProductosStaffPuestoCerteza, TP_ProductosStaffSexo

### TE_PubVacante -> `te_vacantes` (score 0.78)
*Publicación vacantes* -- GeneXus: 16 cols, Postgres actual: 15 cols, encontradas: 1, **faltantes: 15**

Atributos de GeneXus NO identificados en la tabla actual: TE_VacanteId, TE_VacanteTitulo, TE_VacanteFun, TE_VacanteImagen, TE_VacanteReq, TC_PuestosDes, TE_VacanteLigaPsi, TE_VacanteCodigo, TE_VacanteREqExp, TE_VacanteREqIngles, TE_PubVacanteFeIni, TE_PubVacanteFEFin, TE_PubVacantePost, TE_PubVacanteGpos, TE_PubVacanteActiva

### TP_TipoDuracion -> `tc_tipos_duracion_evento` (score 0.77)
*Tipo duración del evento* -- GeneXus: 7 cols, Postgres actual: 11 cols, encontradas: 1, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TP_TipoDuracionLimInf, TP_TipoDuracionLimSup, TP_TipoDuracionPorcentaje1, TP_TipoDuracionPorcentaje2, TP_TipoDuracionPorcentaje3, TP_TipoDuracionPorcentaje4

### TW_FacturasEdicion -> `te_facturas_enc` (score 0.77)
*Facturas* -- GeneXus: 32 cols, Postgres actual: 16 cols, encontradas: 0, **faltantes: 32**

Atributos de GeneXus NO identificados en la tabla actual: TE_FacturaEncID, TE_FacturaEncIdFactura, TE_FacturaEncFolio, TE_FacturaEncEstatus, TC_PepPepDEs, ST_clientesID, ST_clientesNom, TE_PedidoID, TE_PedidoTitulo, TC_SucursalID, TC_SucursalDes, ST_UnidadNegPedId, ST_UnidadNegPedDes, TC_ContactosNombreCompleto, ST_lugaresPedidosDes, TE_FacturaEncTipo, TE_FacturaEncFechadeMovimiento, TC_SociedadDes, TE_FacturaEncTXT, TE_FacturaEncContarPartidas, TE_FacturaEncOrganizacionVenta, TE_FacturaEncCanalDistribucion, TE_FacturaEncSector, TE_FacturaEncDEscripcion, TE_FacturaDetId, TE_FacturaDetDescripcion, TC_ProductosId, TC_ProductosDEs, TE_FacturaDetCantidad, TE_FacturaDetPrecioUnitario, TE_FacturaDetSubTotal, TE_FacturaDetTienePedidos

### TC_ComoteEnt -> `tc_como_se_entero` (score 0.76)
*Como te enteraste* -- GeneXus: 2 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_ComoteEntNon

### TE_Cand -> `te_candidatos` (score 0.75)
*Cartera de Talento* -- GeneXus: 96 cols, Postgres actual: 23 cols, encontradas: 7, **faltantes: 89**

Atributos de GeneXus NO identificados en la tabla actual: TE_CandComoTeEn, TC_ComoteEntId, TC_ComoteEntNon, TE_CandRefe, TE_CandApPat, TE_CandApMat, TE_CandNomComp, TE_CandNacion, TE_CandNacionExp, TE_CandEdoCiv, TE_CandFecNac, TE_CandEdad, TE_CandNumCart, TE_CandNumINE, TC_CodigoPosId, TC_codigoPosColId, TC_CodigoPosColNom, TC_CodigoPosCiudad, TC_CodigoPosMuni, TC_CodigoPosEsta, TC_CodigoPosColTipo, TE_CandCalle, TE_CandNumExt, TE_CandNumiNT, TE_CandTelPart, TE_CandTelMovil, TE_CandWhatsApp, TE_CandFacebook, TE_CandTwitter, TE_CandInstagram, TE_CandCtoApPat, TE_CandCtoApMat, TE_CandCtoNom, TE_CandCtoNomCompleto, TE_CandCtoTel, TE_CandParentesco, TE_CandIdioma, TE_CandEmail, TE_CandUltGraEst, TE_CandEstatusUltGraEst, TE_CandEnfCron, TE_CandEnfCronica, TE_CandCir, TE_CandCiru, TE_CandTrat, TE_CandTratmed, TE_CandIfeI, TE_CandCurpI, TE_CandSanfre, TE_CandCompDom, TE_CandActaNac, TE_CandRFCI, TE_EmpleadosId, TE_EmpleadosNomcomp, TE_CandUser, TE_CandEstatus, TE_CandContrasena, TE_CandPorcCompl, TE_CandBorrar, TE_CandActEstudia, TE_CandActEstuCarrera, TE_CandActEstuEscuela, TE_CandIngles, TE_CandInglesNivel, TE_CandCtasCertifi, TE_CandCtasCertiCual, TE_CandHazTomaCurs, TE_CandHazTomaCurCual, TE_CandExpLab, TE_CandUltEmp, TE_CandUltempPues, TE_CandUltempFI, TE_CandUltempFf, TE_CandUltempSuel, TE_CandUltempMotSali, TE_CandLugaNAc, TE_CandEstadoNac, TE_CandEstado, TE_CandCiudadNac, TE_CandCiudad, TE_CandTieneIfeIma, TE_CandTieneActIma, TE_CandTieneCurp, TE_CandTieneRfc, TE_CandCompDomIma, TE_CandTieneCompEstIma, TE_CandTiencita, TE_CandAltaempleado, TE_CandNumEmpleDO

### TC_UnidadNeg -> `tc_unidades_negocio` (score 0.75)
*Unidad de negocio* -- GeneXus: 5 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 4**

Atributos de GeneXus NO identificados en la tabla actual: TC_UnidadNegDes, TC_UnidadNegIMG, TC_SociedadID, TC_SociedadDes

### TE_Evento -> `tc_fases_evento` (score 0.75)
*Eventos* -- GeneXus: 11 cols, Postgres actual: 9 cols, encontradas: 1, **faltantes: 10**

Atributos de GeneXus NO identificados en la tabla actual: TE_EventoDes, TE_EventoFecIni, TE_EventoHora, TE_EventoMinutos, TE_EventoIMG, TE_EventoFeinicial, TE_EventoFeTer, TE_EventoFechaVigencia, TC_InmuebleID, TC_InmuebleDes

### TC_Sociedad -> `tc_sociedades_pagadoras` (score 0.75)
*TC_Sociedad* -- GeneXus: 8 cols, Postgres actual: 11 cols, encontradas: 2, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TC_SociedadDes, TC_SociedadVigente, TC_SociedadGeneraFacturas, TC_SociedadGeneraOrSer, TC_SociedadesPagadorasID, TC_SociedadesPagadorasDes

### TE_Reserva -> `te_reservaciones` (score 0.75)
*Reservaciones* -- GeneXus: 14 cols, Postgres actual: 34 cols, encontradas: 3, **faltantes: 11**

Atributos de GeneXus NO identificados en la tabla actual: TE_pedDetId, TE_EmpleadosId, TE_EmpleadosNomcomp, TE_EmpleadosNum, TE_ReservaConFFor, TE_ReservaTipo, TE_ReservaRetardo, TE_ReservaFalta, TE_ReservaFAsit, TE_ReservaFsali, TE_ReservaObserv

### TC_CodigoPos -> `tc_codigos_postales` (score 0.75)
*Códigos postales* -- GeneXus: 4 cols, Postgres actual: 11 cols, encontradas: 4, **faltantes: 0**

### TE_CurInducc -> `te_cursos_induccion` (score 0.75)
*Cursos de inducción* -- GeneXus: 17 cols, Postgres actual: 13 cols, encontradas: 3, **faltantes: 14**

Atributos de GeneXus NO identificados en la tabla actual: TE_CurInduccDes, TE_CurInduccFeHr, TE_CurInduccFEMin, TE_CurInduccHr, TE_VacanteId, TE_VacanteTitulo, TC_PuestosId, TC_PuestosDes, TE_CurInduccCitaCur, TE_CurInduccCita, TE_CurInduccIntegrantes, TE_CurInduccCitaCurso, TE_CurInduccEventoPrueba, TE_CurInduccEstatus

### TL_MovempleadosDet -> `te_empleados` (score 0.75)
*Detalle de movientos de empleados* -- GeneXus: 6 cols, Postgres actual: 32 cols, encontradas: 1, **faltantes: 5**

Atributos de GeneXus NO identificados en la tabla actual: TL_MovempleadosId, TL_MovempleadosDetNumEmp, TE_EmpleadoBuscar, TL_MovempleadosDetEstatusEmp, TL_MovempleadosDetCandidatoNom

### TE_Extras -> `te_extras_nomina` (score 0.75)
*Extras* -- GeneXus: 36 cols, Postgres actual: 13 cols, encontradas: 2, **faltantes: 34**

Atributos de GeneXus NO identificados en la tabla actual: TE_EmpIdEmpleadoEventual, TE_EmpleadoBusXNombre, TE_EmpStatus, TE_pedDetId, TE_pedDetTitu, TE_pedDetFeCita, TE_pedDetFeCitaHI, TE_pedDetFeCitaFi, TE_PeddetFechacitaJunta, TE_PeddetFechafincitaoculta, TC_ProductosId, TE_pedDetTurnos, TC_PuestosId, TC_PuestosDes, TP_pago_default, TC_bancosNombre, TE_EmpCuenta_Banco, TE_ExtrasTurnos, TC_ConceptosExtrasId, TC_ConceptosExtrasConcepto, TC_ConceptosExtrasLibre, TE_ExtrasObservaciones, TE_ExtrasStatusAutorizacion, TE_ExtrasStatus, TE_ExtraseriodoCobrado, TE_ExtrasIdPedidoDetalle, TE_ExtrasIdPlaza, TE_Extrastp_Level, TE_Extrastp_Author, TE_Extrastp_Editor, TE_Extrastp_Created, TE_Extrastp_Modified, TE_ExtrasNumeroFolioHonorarios, TE_ExtrasReservacion

### TE_Pagos -> `te_pagos_dispersion` (score 0.75)
*TE_Pagos* -- GeneXus: 49 cols, Postgres actual: 14 cols, encontradas: 6, **faltantes: 43**

Atributos de GeneXus NO identificados en la tabla actual: TE_EmpIdEmpleadoEventual, TE_EmpleadoBuscar, TE_EmpRegPago, TE_EmpCuenta_Banco, TC_bancosID, TC_bancosNombre, TE_EmpleadoNombreCompleto, Te_pagosNombres, Te_pagosRegimen, Te_pagosPeriodo, Te_pagosPeriododePago, Te_pagosIdBanco, Te_pagosNombreBanco, Te_pagosNumeroCuentaBanco, Te_pagosDiasLaborados, Te_pagosPagoBruto, Te_pagosSDP, Te_pagosIM, Te_pagosCF, Te_pagosCG, Te_pagosID2, Te_pagosIT, Te_pagosIVA, Te_pagosRIVA, Te_pagosRISR, Te_pagosPagoNeto, Te_pagosIdEmpresaPagadora, Te_pagosEmpresaPagadora, Te_pagosObservaciones, Te_pagosSolicitudPago, Te_pagosIdPuestoPrincipal, Te_pagosPuestoPrincipal, Te_pagosIdUnidadDeNegocio, Te_pagosUnidadDeNegocio, Te_pagosIdSociedadPropia, Te_pagosSociedadPropia, Te_pagosCumpleReglas, Te_pagosCumpleReglaPoseeCuentadeBanco, Te_pagosCumpleReglaUltimoPagoenPeriodosRecientes, Te_pagosCumpleReglaRecibePagoenelPeriodoActual, Te_pagosId_Lista, TE_PagosBorrar, TE_PagosEstatusCierre

### TP_Pensiones -> `tp_pensiones_alimenticias` (score 0.75)
*TP_Pensiones* -- GeneXus: 9 cols, Postgres actual: 15 cols, encontradas: 3, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TP_Pensiones, TP_PensionesNumEMpleado, TP_PensionesNumeroCuenta, TC_bancosID, TC_bancosNombre, TP_PensionesPorcenyaje

### TE_ListaNegra -> `te_lista_negra_empleados` (score 0.75)
*Empleados vetados* -- GeneXus: 8 cols, Postgres actual: 14 cols, encontradas: 1, **faltantes: 7**

Atributos de GeneXus NO identificados en la tabla actual: TE_EmpIdEmpleadoEventual, TE_EmpleadoBusXNombre, TE_ListaNegraFechaDesde, TE_ListaNegraFechaHasta, TC_LugarCitaID, TC_LugarCitaDes, TE_ListaNegraVetadoTodos

### TP_Precios -> `tp_precios_producto` (score 0.75)
*TP_Precios* -- GeneXus: 7 cols, Postgres actual: 13 cols, encontradas: 2, **faltantes: 5**

Atributos de GeneXus NO identificados en la tabla actual: TC_ProductosId, TC_ProductosDEs, TC_PuestosId, TC_PuestosDes, TP_PreciosPrecios

### TP_Duracion -> `tc_tipos_duracion_evento` (score 0.75)
*Duración* -- GeneXus: 2 cols, Postgres actual: 11 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TP_DuracionDesc

### TC_CodigoPosCol -> `tc_codigos_postales` (score 0.74)
*Códigos Postales Colonias* -- GeneXus: 7 cols, Postgres actual: 11 cols, encontradas: 1, **faltantes: 6**

Atributos de GeneXus NO identificados en la tabla actual: TC_CodigoPosId, TC_CodigoPosColNom, TC_CodigoPosColTipo, TC_CodigoPosCiudad, TC_CodigoPosMuni, TC_CodigoPosEsta

### TP_DuracionDet -> `tp_duraciones_evento` (score 0.74)
*Duración detalle* -- GeneXus: 8 cols, Postgres actual: 12 cols, encontradas: 1, **faltantes: 7**

Atributos de GeneXus NO identificados en la tabla actual: TP_DuracionId, TP_DuracionDesc, TP_DuracionDetMinDias, TP_DuracionDetMaxDias, TP_DuracionDetFacPago, TP_DuracionDetProrrateado, TP_DuracionDetDivProrra

### TC_TipoCliente -> `tc_clientes` (score 0.74)
*Tipo Cliente* -- GeneXus: 2 cols, Postgres actual: 13 cols, encontradas: 1, **faltantes: 1**

Atributos de GeneXus NO identificados en la tabla actual: TC_TipoClienteDesc

## B. Matches de confianza media (revisar manualmente)

- `TE_CitaGpoCan` (Candidatos en Grupos, 27 cols) -> posible `tr_cita_grupo_candidato` (score 0.71)
- `TC_EquipoBiometrico` (TC_Equipo Biometrico, 3 cols) -> posible `te_eventos_biometricos` (score 0.71)
- `TE_FacturaDetPedidoDetalle` (TE_Factura Det Pedido Detalle, 11 cols) -> posible `te_pedidos_detalle` (score 0.70)
- `TE_EvePrue` (Eventos Prueba, 33 cols) -> posible `te_eventos_prueba` (score 0.70)
- `TE_RegistroNACS` (TE_Registro NACS, 3 cols) -> posible `tc_repse_registros` (score 0.69)
- `TE_FacturaDetAuxiliar` (Detalle facturas , 23 cols) -> posible `te_facturas_det` (score 0.69)
- `TC_socidad` (Socidades, 2 cols) -> posible `tc_ciudades` (score 0.67)
- `TA_ProdCompFase` (Productos por complejidad y fase, 9 cols) -> posible `tc_productos` (score 0.67)
- `TE_RegistroBiometrico` (Registro de asistencias automaticas, 8 cols) -> posible `te_eventos_biometricos` (score 0.67)
- `TE_DispersionExcel` (TE_Dispersion Excel, 2 cols) -> posible `te_pagos_dispersion` (score 0.67)
- `TR_UniNegCompledidad` (Unidad de negocio por complejidad, 4 cols) -> posible `tc_tipos_complejidad` (score 0.67)
- `TC_EmpresaPagadora` (Empresa pagadora, 3 cols) -> posible `tc_sociedades_pagadoras` (score 0.65)
- `TE_ObservaEmp` (Observaciones empleado, 5 cols) -> posible `te_observaciones_empleado` (score 0.65)
- `TC_PresenProd` (Presentación de Producto, 4 cols) -> posible `tp_precios_producto` (score 0.64)
- `TE_ExtrasMasivos` (Alta masiva de extras, 16 cols) -> posible `te_extras_nomina` (score 0.64)
- `TE_DetPedPuesto` (Puestos Detalle Pedido, 2 cols) -> posible `tc_puestos` (score 0.63)
- `TC_Contactos` (Contactos, 21 cols) -> posible `te_candidatos` (score 0.63)
- `TL_Modulos` (Movimientos de modulos, 11 cols) -> posible `tc_productos` (score 0.62)
- `TP_Ambiente` (Parámetros, 18 cols) -> posible `tc_clientes` (score 0.62)
- `TC_CatBajRein` (Catálogo de bajas y reingresos, 3 cols) -> posible `tc_causas_baja_reingreso` (score 0.62)
- `TL_RegistroModulos` (Acciones modulos, 6 cols) -> posible `tc_repse_registros` (score 0.62)
- `TE_InconsistenciasCierreNomina` (TE_Inconsistencias Cierre Nomina, 5 cols) -> posible `tl_log_cierre_nomina` (score 0.62)
- `TE_Puente` (Puente detalle Puestos, 110 cols) -> posible `tc_puestos` (score 0.62)
- `TE_Peddet` (Detalle pedidos, 113 cols) -> posible `te_pedidos` (score 0.62)
- `TC_StatusDetPed` (Estatus Detalle Pedido, 2 cols) -> posible `te_facturas_det` (score 0.61)
- `TE_PlazasEnc` (Plazas, 16 cols) -> posible `te_facturas_enc` (score 0.60)
- `TE_plazasDet` (Plazas detalle, 9 cols) -> posible `te_facturas_det` (score 0.60)
- `TP_ProdcutosOperativo` (Productos Operativos, 8 cols) -> posible `tc_productos` (score 0.59)
- `TC_Complejo` (Complejidad, 3 cols) -> posible `te_empleados` (score 0.59)
- `TC_ReglaAsist` (Regla de Asistencias, 7 cols) -> posible `tc_reglas_asistencia_timescan` (score 0.59)
- `TE_PostVaCan` (Folios, 50 cols) -> posible `te_vacantes` (score 0.59)
- `TV_Variables` (TV_Variables, 6 cols) -> posible `te_vacantes` (score 0.59)
- `TP_Universo` (Universo de registros, 2 cols) -> posible `tc_uniformes` (score 0.59)
- `TP_ReglasConfirmacion` (Reglas de confirmación, 8 cols) -> posible `te_reservaciones` (score 0.58)
- `TR_UsuarioUnidadNeg` (Usuario unidad negocio, 3 cols) -> posible `tc_unidades_negocio` (score 0.58)
- `TC_Espectaculo` (TC_Espectaculo, 4 cols) -> posible `tc_estaciones` (score 0.57)
- `UserCustomizations` (User Custom, 3 cols) -> posible `tc_estaciones` (score 0.57)
- `TC_Termycond` (Términos y Condiciones, 3 cols) -> posible `tp_terminos_condiciones` (score 0.57)
- `TP_Generales` (Parámentros generales, 4 cols) -> posible `tc_responsables` (score 0.57)
- `TC_Periodicidad` (Periodicidad, 2 cols) -> posible `tp_avisos_privacidad` (score 0.57)
- `TC_DocuEmp` (Documentos empleados, 2 cols) -> posible `te_documentos_empleado` (score 0.56)
- `TR_SocProTipoCliente` (Sociedad tipo cliente, 7 cols) -> posible `tc_clientes` (score 0.56)
- `TE_ComPer` (Comunicados Personales, 7 cols) -> posible `tc_como_se_entero` (score 0.56)
- `TC_PepsMasivos` (Peps masivos, 5 cols) -> posible `tc_puestos` (score 0.56)
- `TE_DocCand` (Documentos de candidato, 9 cols) -> posible `te_documentos_candidato` (score 0.54)
- `TE_Plazas` (Plazas empleados, 27 cols) -> posible `te_empleados` (score 0.53)
- `Plazas` (Plazas, 18 cols) -> posible `te_empleados` (score 0.53)
- `TE_CtasBcoEmp` (Cuentas de banco empleados, 8 cols) -> posible `te_cuentas_bancarias_empleado` (score 0.53)
- `TC_EstatusAut` (Estatus pedidos, 4 cols) -> posible `tc_estados_mx` (score 0.53)
- `TE_ContacClie` (Contactos Clientes, 2 cols) -> posible `te_nomina_detalle` (score 0.52)
- `TP_Usuario` (Usuarios, 9 cols) -> posible `tc_causas_aclaracion` (score 0.52)
- `TC_ConceptosExtras` (TC_Conceptos Extras, 3 cols) -> posible `tc_como_se_entero` (score 0.52)
- `TR_UsuarioSucursal` (Usuarios sucursal, 3 cols) -> posible `te_pagos_factura` (score 0.52)
- `TC_LugarCita` (Lugar de cita, 9 cols) -> posible `te_grupos_citas` (score 0.50)
- `TC_Sucursal` (Sucursales, 2 cols) -> posible `te_pagos_factura` (score 0.50)
- `TC_RegPago` (Régimen de Pagos, 2 cols) -> posible `te_empleados` (score 0.50)
- `TE_ReqPer` (Requisición de personal, 28 cols) -> posible `tc_repse_registros` (score 0.50)
- `TE_Docemp` (Documentos empleado, 9 cols) -> posible `te_documentos_empleado` (score 0.50)
- `TP_CombSucUN` (TP_Comb Suc UN, 1 cols) -> posible `te_cursos_induccion` (score 0.50)

## C. Sin match razonable -- probablemente faltantes por completo en el esquema actual

- **TA_AltaEmp** -- *TA_Alta Emp* (3 cols) -- mejor candidato encontrado: `te_facturas_enc` (score 0.44, insuficiente)
- **TA_ManejoImagenes** -- *TA_Manejo Imagenes* (4 cols) -- mejor candidato encontrado: `te_consentimientos` (score 0.48, insuficiente)
- **TC_Inmueble** -- *TC_Inmueble* (10 cols) -- mejor candidato encontrado: `te_nomina_detalle` (score 0.48, insuficiente)
- **TC_Pep** -- *Presupuestos* (12 cols) -- mejor candidato encontrado: `tc_puestos` (score 0.40, insuficiente)
- **TC_SegMovCan** -- *Movientos Candidatos* (2 cols) -- mejor candidato encontrado: `te_vacantes` (score 0.47, insuficiente)
- **TC_SucursalPag** -- *Sucursal Pagadora* (2 cols) -- mejor candidato encontrado: `te_suscripciones` (score 0.42, insuficiente)
- **TE_Excel** -- *TE_Excel* (4 cols) -- mejor candidato encontrado: `tc_estaciones` (score 0.40, insuficiente)
- **TE_LogEmp** -- *Movimientos empleado* (8 cols) -- mejor candidato encontrado: `tl_log_cierre_nomina` (score 0.48, insuficiente)
- **TE_SegCan** -- *Seguimiento Candidatos* (7 cols) -- mejor candidato encontrado: `te_tenants` (score 0.46, insuficiente)
- **TP_ClaveExamen** -- *Claves de puestos* (6 cols) -- mejor candidato encontrado: `te_extras_nomina` (score 0.43, insuficiente)
- **TP_ImpHonoAsim** -- *Impuestos honorarios asimilables* (9 cols) -- mejor candidato encontrado: `tc_responsables` (score 0.43, insuficiente)

## D. Tablas del esquema actual SIN origen claro en el XPZ (revisar si son de la reconstruccion 'desde cero')

- `tc_colonias_cp` (9 cols)
- `tc_dispositivos` (11 cols)
- `tc_partidas_presupuestales` (15 cols)
- `tc_planes_suscripcion` (14 cols)
- `tc_presentaciones_producto` (10 cols)
- `tc_sitios` (18 cols)
- `tc_sociedades_propias` (13 cols)
- `tc_tipos_documento` (9 cols)
- `te_adjuntos` (24 cols)
- `te_bitacora_accesos` (7 cols)
- `te_cambio_cuenta_bancaria` (16 cols)
- `te_consentimientos` (12 cols)
- `te_export_sap_lote` (15 cols)
- `te_facturas_serie` (12 cols)
- `te_intentos_acceso_portal` (11 cols)
- `te_magic_links` (12 cols)
- `te_movimientos_empleado` (13 cols)
- `te_nominas_periodo` (11 cols)
- `te_pedido_fechas` (12 cols)
- `te_procesar_lista_manual` (12 cols)
- `te_proceso_cierre_nomina` (13 cols)
- `te_requisicion_personal` (21 cols)
- `te_reservacion_bitacora` (10 cols)
- `te_suscripciones` (10 cols)
- `te_tenants` (9 cols)
- `te_vacante_plantilla` (19 cols)
- `tl_movimientos_empleado_encabezado` (10 cols)
- `tp_nomina_precauciones_catalogo` (10 cols)
- `tp_parametros_globales` (10 cols)
- `tp_precios_especiales_cliente` (13 cols)
- `tr_asistencia_curso` (11 cols)
- `tr_comunicado_destinatario` (12 cols)
- `tr_empleado_plaza` (10 cols)
- `tr_postulacion_candidato_vacante` (11 cols)
- `tr_producto_puesto` (9 cols)
