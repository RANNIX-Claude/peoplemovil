# Inventario de tablas reales extraido del XPZ (AppSCPF_05_11_19.xpz)

Generado por extraccion directa de la KB de GeneXus. Total de tablas: **143**. Total de atributos (catalogo global): **1774**.

No es un resumen manual: viene de parsear el XML interno de GeneXus (Objects de tipo Table + catalogo de Attributes con su tipo/longitud/dominio).

## Bancos
*Bancos*  guid: `cc40fcb6-3f22-5db0-db8c-cc80f1092244`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| IdBanco | PK |  | Numeric (9) |
| Titulo2 |  |  | VarChar (255) |

## Empleados
*Empleados*  guid: `38ebdd29-564a-f4e5-1f60-5ca2ad76f5b8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| IdEmpleadoEventual | PK |  | Numeric (9) |
| EmpleadosID |  |  | Numeric (9) |
| Tipo_de_Empleado |  |  | VarChar (255) |
| Primer_Apellido |  |  | VarChar (255) |
| Segundo_Apellido |  |  | VarChar (255) |
| Nombre_s_ |  |  | VarChar (255) |
| EmpleadosStatus |  |  | VarChar (255) |
| Genero |  |  | VarChar (255) |
| Porcentaje_Puntualidad |  |  | Numeric (18,6) |
| Lugar_de_Trabajo_Eventos |  |  | VarChar (255) |
| EmpleadosIdSucursal |  |  | Numeric (9) |
| Nombre_Sucursal |  |  | VarChar (255) |
| Regimen_Pago |  |  | VarChar (255) |
| EmpleadosCiclo_de_Pago |  |  | VarChar (255) |
| Correo_Electronico |  |  | VarChar (255) |
| EmpleadosIdBanco |  |  | Numeric (9) |
| Nombre_Banco |  |  | VarChar (255) |
| Cuenta_Banco |  |  | VarChar (255) |
| Fecha_de_Nacimiento |  |  | DateTime |
| Estado_de_Nacimiento |  |  | VarChar (255) |
| RFC |  |  | VarChar (255) |
| CURP |  |  | VarChar (255) |
| Credencial_Elector |  |  | VarChar (255) |
| Cartilla |  |  | VarChar (255) |
| Estatura |  |  | Numeric (18,6) |
| Estado_Civil |  |  | VarChar (255) |
| Talla |  |  | VarChar (255) |
| Direccion |  |  | VarChar (255) |
| Calle |  |  | VarChar (255) |
| Numero_Exterior |  |  | VarChar (255) |
| Numero_Interior |  |  | VarChar (255) |
| Colonia |  |  | VarChar (255) |
| Codigo_postal |  |  | VarChar (255) |
| Delegacion_o_Municipio |  |  | VarChar (255) |
| Estado_Provincia |  |  | VarChar (255) |
| Telefono_movil |  |  | VarChar (255) |
| Telefono_particular |  |  | VarChar (255) |
| Fecha_Ingreso |  |  | DateTime |
| Fecha_Antiguedad |  |  | DateTime |
| Fecha_Baja |  |  | DateTime |
| IdSolicitud |  |  | Numeric (9) |
| EmpleadosIdEmpresaPagadora |  |  | Numeric (9) |
| EmpleadosIdEmpresaPagadora_Lista |  |  | Numeric (9) |
| EmpleadosIdPuesto |  |  | Numeric (9) |
| NombrePuesto |  |  | VarChar (255) |
| IdPuesto_Lista2 |  |  | Numeric (9) |
| EmpleadosCreado |  |  | DateTime |
| EmpleadosModificado |  |  | DateTime |
| Grado_de_Estudios |  |  | VarChar (255) |
| Status_Grado_de_Estudios |  |  | VarChar (255) |
| Licenciatura_o_Curso |  |  | VarChar (255) |
| Idiomas |  |  | VarChar (255) |
| En_Caso_de_Accidente_avisar_A |  |  | VarChar (255) |
| Cirugias_Tratamientos_y_Padecimientos |  |  | VarChar (255) |
| Tipo_de_Sangre |  |  | VarChar (255) |
| Recomendado_Por |  |  | VarChar (255) |
| Status_Oculto |  |  | VarChar (255) |
| SobreNombre |  |  | VarChar (255) |

## Pedidos
*Pedidos*  guid: `dde799c5-057a-bff1-0fac-d5988e2c4549`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| PedidosID | PK |  | Numeric (9) |
| Titulo3 |  | si | (sin tipo explicito / heredado de dominio) |
| PedidosStatus |  | si | VarChar (255) |
| IdCliente |  | si | Numeric (9) |
| Nombre_Cliente |  | si | VarChar (255) |
| RFC_Cliente |  | si | VarChar (255) |
| Direccion_Cliente |  | si | VarChar (255) |
| Telefono_Cliente |  | si | VarChar (255) |
| IdContacto |  | si | Numeric (9) |
| Nombre_Contacto |  | si | VarChar (255) |
| Telefono_Contacto |  | si | VarChar (255) |
| IdEvento |  | si | Numeric (9) |
| Titulo_Evento |  | si | VarChar (255) |
| PedidosIdSucursal |  | si | Numeric (9) |
| PedidosTitulo_Sucursal |  | si | VarChar (255) |
| PedidosIdUnidadDeNegocio |  | si | Numeric (9) |
| PedidosTitulo_Unidad_de_Negocio |  | si | VarChar (255) |
| IdPEP |  | si | Numeric (9) |
| Titulo_PEP |  | si | VarChar (255) |
| Descripcion_PEP |  | si | VarChar (255) |
| IdLugarCita |  | si | Numeric (9) |
| Lugar_Cita |  | si | VarChar (255) |
| Direccion_Lugar_Cita |  | si | VarChar (4000) |
| Tipo_de_Movimiento |  | si | VarChar (255) |
| IdSociedad |  | si | Numeric (9) |
| PedidosTitulo_Sociedad |  | si | VarChar (255) |
| IdSociedadPagadora |  | si | Numeric (9) |
| Titulo_Sociedad_Pagadora |  | si | VarChar (255) |
| IdTipoDeComplejidad |  | si | Numeric (9) |
| Titulo_Tipo_de_Complejidad |  | si | VarChar (255) |
| Duracion_del_Evento_Numero_de_Dias_ |  | si | Numeric (9) |
| IdTipoDuracionDelEvento |  | si | Numeric (9) |
| Titulo_Duracion_del_Evento |  | si | VarChar (255) |
| Permitir_Cancelaciones |  | si | VarChar (255) |
| Status_Facturacion |  | si | VarChar (255) |
| SubTotal |  | si | Numeric (18,6) |
| IVA |  | si | Numeric (18,6) |
| Total_Con_IVA |  | si | Numeric (18,6) |
| PedidosCosto_Por_Nomina |  | si | Numeric (18,6) |
| PedidosCreado |  | si | DateTime |
| IdResponsable |  | si | Numeric (9) |
| Responsable |  | si | VarChar (255) |
| PedidosCreado_Por |  | si | VarChar (255) |
| PedidosModificado |  | si | DateTime |
| PedidosModificado_Por |  | si | VarChar (255) |
| Version_Vigente |  | si | Numeric (1) |

## Pedidos_Detalle
*Pedidos_Detalle*  guid: `5faf3dd8-208c-5646-1b97-82e81a03d7a7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| Pedidos_DetalleID | PK |  | Numeric (9) |
| Pedidos_DetalleTitulo |  | si | VarChar (255) |
| IdPedido |  |  | Numeric (9) |
| Pedidos_DetalleStatus |  | si | VarChar (20) |
| Producto |  | si | Numeric (9) |
| Titulo_Producto |  | si | VarChar (100) |
| Fecha_Entrega |  | si | DateTime |
| Fecha_Fin_Cita |  | si | DateTime |
| Fecha_Fin_Cita_Oculta |  | si | DateTime |
| Fecha_Liberacion |  | si | DateTime |
| Turnos |  | si | Numeric (18,6) |
| Cantidad |  | si | Numeric (18,6) |
| Pedidos_DetalleIdPuesto |  | si | Numeric (9) |
| Titulo_Puesto |  | si | VarChar (100) |
| Producto_Matricial |  | si | VarChar (10) |
| Presentacion |  | si | Numeric (9) |
| Titulo_Presentacion |  | si | VarChar (100) |
| Completar_Productos_Similares |  | si | VarChar (10) |
| Bloque |  | si | Numeric (9) |
| Fecha_Fin_Bloque |  | si | DateTime |
| Fecha_Vigencia_Preasignados |  | si | DateTime |
| Porcentaje_Completo |  | si | Numeric (18,6) |
| Completo |  | si | VarChar (10) |
| Porcentaje_Completo_con_Preasignados |  | si | Numeric (18,6) |
| Completo_con_Preasignados |  | si | VarChar (10) |
| Cantidad_Reservados |  | si | Numeric (18,6) |
| Cantidad_Reservados_con_Preasignados |  | si | Numeric (18,6) |
| Cantidad_Reservados_Real |  | si | Numeric (18,6) |
| Cantidad_Que_Asistieron |  | si | Numeric (18,6) |
| Id_Lugar_de_Entrega |  | si | Numeric (9) |
| Lugar_de_Entrega |  | si | VarChar (255) |
| Direccion_de_Entrega |  | si | VarChar (4000) |
| Sucursal |  | si | Numeric (9) |
| Pedidos_DetalleTitulo_Sucursal |  | si | VarChar (20) |
| Pedidos_DetalleUnidad_de_Negocio |  | si | Numeric (9) |
| Pedidos_DetalleTitulo_Unidad_de_Negocio |  | si | VarChar (50) |
| Sociedad |  | si | Numeric (9) |
| Pedidos_DetalleTitulo_Sociedad |  | si | VarChar (50) |
| Indicaciones_Especiales |  | si | VarChar (4000) |
| Periodo_de_Pago |  | si | Numeric (9) |
| Periodo_de_Lista_de_Asistencia |  | si | Numeric (9) |
| Facturable |  | si | VarChar (10) |
| FolioFactura |  | si | Numeric (9) |
| Factura_Servicio_Interno |  | si | VarChar (100) |
| Fase_del_Evento |  | si | VarChar (50) |
| Precio |  | si | Numeric (18,6) |
| Fecha_Envio_SMS |  | si | DateTime |
| Pedidos_DetalleCosto_Por_Nomina |  | si | Numeric (18,6) |
| Pago_Especial |  | si | Numeric (18,6) |
| Permitir_Cancelar_Confirmaciones |  | si | VarChar (10) |
| Status_Envio_SMS |  | si | VarChar (10) |
| Envio_SMS_Preasignados |  | si | Numeric (1) |
| Pedidos_DetalleCreado_por |  | si | VarChar (50) |
| Pedidos_DetalleCreado |  | si | DateTime |
| Pedidos_DetalleModificado_por |  | si | VarChar (50) |
| Pedidos_DetalleModificado |  | si | DateTime |
| CorreoEnviado_Faltas |  | si | Numeric (1) |
| CorreoEnviado_PEP_Temporal |  | si | Numeric (1) |

## Periodos
*Periodos*  guid: `f1c6cf8b-5e60-79bb-178c-568f2f47a7a1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| PeriodosID | PK |  | Numeric (9) |
| Fecha_Inicio |  |  | DateTime |
| Fecha_Fin |  |  | DateTime |
| Actual |  |  | Numeric (1) |

## Plazas
*Plazas*  guid: `d851b4a7-60bd-574c-ad88-09f295e58f38`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| PlazasID | PK |  | Numeric (9) |
| IdCatalogo |  | si | Numeric (9) |
| Plazastp_id |  | si | Numeric (9) |
| Nombre_Plaza |  | si | VarChar (255) |
| PlazasStatus |  | si | VarChar (50) |
| IdEmpleado |  | si | Numeric (9) |
| Nombre_Empleado_Actual |  | si | VarChar (255) |
| Perfil_Nomina |  | si | VarChar (255) |
| Puesto |  | si | Numeric (9) |
| Nombre_Puesto |  | si | VarChar (255) |
| Pago |  | si | Numeric (18,4) |
| Inicio_Vigencia |  | si | DateTime |
| Fin_Vigencia |  | si | DateTime |
| PlazasVigente |  | si | VarChar (255) |
| Principal |  | si | VarChar (2) |
| IdSueldoLobo |  | si | Numeric (9) |
| PlazasCreado |  | si | DateTime |
| PlazasModificado |  | si | DateTime |

## Productos
*Productos*  guid: `2d1981ae-02b9-510e-2dbb-efabd83f82eb`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| IdProducto2 | PK |  | Numeric (9) |
| ProductosTitulo |  |  | VarChar (255) |
| SubCategoria |  |  | VarChar (50) |
| ProductosIdPuesto |  |  | Numeric (9) |
| IdPuestoCatalogo |  |  | Numeric (9) |
| ProductosIdUnidadDeNegocio |  |  | Numeric (9) |
| ProductosUnidad_de_Negocio |  |  | Numeric (9) |
| Numero_Material_SAP |  |  | VarChar (50) |
| IdProductoSimilar1 |  |  | Numeric (9) |
| Producto_Similar1 |  |  | Numeric (9) |
| IdProductoSimilar2 |  |  | Numeric (9) |
| Producto_Similar2 |  |  | Numeric (9) |
| IdProductoSimilar3 |  |  | Numeric (9) |
| Producto_Similar3 |  |  | Numeric (9) |
| IdProductoSimilar4 |  |  | Numeric (9) |
| Producto_Similar4 |  |  | Numeric (9) |
| IdProductoSimilar5 |  |  | Numeric (9) |
| Producto_Similar5 |  |  | Numeric (9) |
| IdProductoSimilar6 |  |  | Numeric (9) |
| Producto_Similar6 |  |  | Numeric (9) |
| Clave |  |  | VarChar (255) |
| Titulo_Completo |  |  | VarChar (255) |
| ProductosVigente |  |  | VarChar (10) |
| Productostp_Id |  |  | Numeric (9) |

## Puestos
*Puestos*  guid: `db71aa36-11a4-efbd-e939-b11813bf5057`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| PuestosID | PK |  | Numeric (9) |
| PuestosIdPuesto |  |  | Numeric (9) |
| PuestosTitulo |  |  | VarChar (255) |
| Pago_Default |  |  | Numeric (18,6) |
| PuestosIdUnidadDeNegocio |  |  | Numeric (9) |
| IdUnidadDeNegocio_Lista |  |  | Numeric (9) |
| Puesto_Unidad_de_Negocio |  |  | VarChar (255) |
| Duracion_Turno |  |  | Numeric (18,6) |
| Horas_Entre_Turnos |  |  | Numeric (9) |
| Horas_Antes_Para_Cancelar_Pedido |  |  | Numeric (9) |
| Porcentaje_Certeza_Inicial |  |  | Numeric (18,6) |
| Porcentaje_Minimo |  |  | Numeric (18,6) |
| Confirmar_Entre_Seriados |  |  | Numeric (1) |
| Dias_sin_Confirmar |  |  | Numeric (9) |
| Matricial |  |  | Numeric (1) |
| Requiere_TimeScan |  |  | VarChar (2) |
| Regla_para_Asistencia_por_TimeScan |  |  | Numeric (9) |
| Tipo_de_Registros_en_TimeScan |  |  | VarChar (50) |
| Penalizacion_Retardo |  |  | Numeric (18,6) |
| Penalizacion_Falta |  |  | Numeric (18,6) |
| PuestosCiclo_de_Pago |  |  | VarChar (50) |
| Regimen_de_Pago |  |  | VarChar (50) |
| PuestosIdEmpresaPagadora |  |  | Numeric (9) |
| PuestosIdEmpresaPagadora_Lista |  |  | Numeric (9) |

## TA_AltaEmp
*TA_Alta Emp*  guid: `bf98ba17-cc65-4834-b2ca-41e0df091269`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TA_AltaEmpId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_CandID |  |  | Domain:autonumerico |
| TA_AltaEmpClave |  |  | VarChar (10) |

## TA_ManejoImagenes
*TA_Manejo Imagenes*  guid: `551643ce-1c02-485c-9232-4c7987867ed0`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TA_ManejoImagenesId | PK |  | Domain:ID |
| TA_ManejoImagenesArchivo |  |  | Blob |
| TA_ManejoImagenesArchNom |  |  | VarChar |
| TA_ManejoImagenesArchExt |  |  | VarChar (4) |

## TA_ProdCompFase
*Productos por complejidad y fase*  guid: `6776df3c-7b20-4a33-81cc-f24684e3df6e`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TT_ProdPuestoMatID | PK |  | Domain:ID |
| TT_PPPuestoid |  |  | Domain:ID |
| TT_ProdDes |  | si | VarChar (255) |
| TT_PPProdId |  | si | Domain:ID |
| TT_FaseID |  | si | Domain:ID |
| TT_FaseDesc |  | si | VarChar (255) |
| TT_Complejidad |  | si | Domain:ID |
| TT_UnidadNeg |  | si | Domain:ID |
| TT_MAT |  | si | Numeric |

## TC_CatBajRein
*Catálogo de bajas y reingresos*  guid: `e2a22977-e06f-4839-9d07-775f21167c60`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CatBajReinID | PK |  | Domain:autonumerico |
| TC_CatBajReinDes |  |  | VarChar (50) |
| TC_CatBajReinTipo |  |  | Domain:tipoConBajasRein |

## TC_CausasAclara
*Causas aclaraciones*  guid: `ddeacd7c-8bca-4377-bd05-2f0407dc87da`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CausasAclaraId | PK |  | Domain:autonumerico |
| TC_CausasAclaraDes |  |  | VarChar (150) |

## TC_Ciudad
*Ciudades*  guid: `b22e704d-c66c-492a-ad64-3ae3448ca8a6`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CiudadId | PK |  | Domain:autonumerico |
| TC_CiudadNom |  |  | VarChar (100) |
| TC_EstadosID |  |  | Domain:autonumerico |
| TC_EstadosDes |  |  | Domain:Des |

## TC_CodigoPos
*Códigos postales*  guid: `3b110c49-3e01-4cdb-b4c8-7afa348dedde`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CodigoPosId | PK |  | VarChar (5) |
| TC_CodigoPosCiudad |  | si | VarChar (100) |
| TC_CodigoPosMuni |  | si | VarChar (100) |
| TC_CodigoPosEsta |  | si | VarChar (100) |

## TC_CodigoPosCol
*Códigos Postales Colonias*  guid: `c720a5c8-10a3-4c20-9e36-6ef344ed086f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CodigoPosId | PK |  | VarChar (5) |
| TC_codigoPosColId | PK |  | Domain:autonumerico |
| TC_CodigoPosColNom |  | si | VarChar (100) |
| TC_CodigoPosColTipo |  | si | VarChar (100) |
| TC_CodigoPosCiudad |  |  | VarChar (100) |
| TC_CodigoPosMuni |  |  | VarChar (100) |
| TC_CodigoPosEsta |  |  | VarChar (100) |

## TC_ComoteEnt
*Como te enteraste*  guid: `0c2d4dba-e819-4782-acb6-4675998cc47f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ComoteEntId | PK |  | Domain:autonumerico [AUTONUMERICO] |
| TC_ComoteEntNon |  |  | VarChar (100) |

## TC_Complejo
*Complejidad*  guid: `3a214520-4ba3-4906-9770-3a78c430bb0e`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_complejoid | PK |  | Domain:ID |
| TC_ComplejoDES |  | si | Domain:Des |
| TC_Complejovigente |  | si | Boolean |

## TC_ConceptosExtras
*TC_Conceptos Extras*  guid: `3563d6cc-2d9e-40cd-a5c4-9228ca0dd5ca`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ConceptosExtrasId | PK |  | Domain:ID [AUTONUMERICO] |
| TC_ConceptosExtrasConcepto |  |  | VarChar (150) |
| TC_ConceptosExtrasLibre |  |  | Boolean |

## TC_Contactos
*Contactos*  guid: `bf069df2-61c2-401b-a6fd-5fac107340e7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ContactosId | PK |  | Domain:ID |
| TC_ContactosPrimerApellido |  | si | VarChar (100) |
| TC_ContactosSegundoApellido |  | si | VarChar (100) |
| TC_ContactosNombre |  | si | VarChar (100) |
| TC_ContactosNombreCompleto |  | si | VarChar (150) |
| TC_ContactosFechaNacimiento |  | si | Date |
| TC_ContactosDireccion |  | si | Domain:Address, GeneXus |
| TC_ContactosCodigoPostal |  | si | VarChar (5) |
| TC_ContactosEstado |  | si | VarChar (20) |
| TC_ContactosPais |  | si | VarChar (20) |
| TC_ContactosRFC |  | si | VarChar (13) |
| TC_ContactosCURP |  | si | VarChar (18) |
| TC_ContactosTelefonoParticular |  | si | VarChar (40) |
| TC_ContactosTelefonoTrabajo1 |  | si | VarChar (40) |
| TC_ContactosTelefonoTrabajo2 |  | si | VarChar (40) |
| TC_ContactosTelefonoMovil |  | si | VarChar (40) |
| TC_ContactosEmail |  | si | Domain:Email, GeneXus |
| TC_ContactosEmpresa |  | si | VarChar (150) |
| TC_ContactosPuesto |  | si | VarChar (150) |
| TC_ContactosRelacion |  | si | VarChar (100) |
| TC_ContactosNumeroCliSap |  | si | VarChar |

## TC_Credenciales
*Credenciales*  guid: `05cbd4cf-802f-4e6c-a220-ec36e853894f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CredencialesId | PK |  | Domain:ID |
| TC_CredencialesNombre |  | si | Domain:Nombre |
| TC_CredencialesFrente |  | si | Image |
| TC_CredencialesReverso |  | si | Image |

## TC_DocuEmp
*Documentos empleados*  guid: `0fc3e520-bfb2-405c-b45d-ba436a46ed28`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_docuempID | PK |  | Domain:autonumerico |
| TC_docuempDescrip |  |  | VarChar (100) |

## TC_EmpresaPagadora
*Empresa pagadora*  guid: `18da8a66-fcd8-40f5-91e7-5c7d497bce23`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EmpresaPagadoraId | PK |  | Numeric (4) |
| TC_EmpresaPagadoraNombre |  | si | VarChar (150) |
| TC_EmpresaPagadoraBorrar |  | si | (sin tipo explicito / heredado de dominio) |

## TC_EquipoBiometrico
*TC_Equipo Biometrico*  guid: `b802af9c-2c64-48d5-b624-62ec8b229fe1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EquipoBiometricoID | PK |  | Domain:ID |
| TC_EquipoBiometricoDes |  |  | Domain:Des |
| TC_EquipoBiometricoModelso |  |  | VarChar (10) |

## TC_Espectaculo
*TC_Espectaculo*  guid: `c56427da-c247-ad2e-aae3-cad0f7a156b7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EspectaculoID | PK |  | Numeric (4) [AUTONUMERICO] |
| TC_EspectaculoDes |  |  | Character (100) |
| TC_EspectaculoDesCta |  |  | Character (15) |
| TC_EspectaculoImagen |  |  | Image (0) |

## TC_EstacionNACS
*NACS*  guid: `50fa650e-9f62-48c7-ac48-ec72d07c8def`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EstacionNACSID | PK |  | Domain:ID [AUTONUMERICO] |
| TC_EquipoBiometricoID |  | si | Domain:ID |
| TC_EstacionNACSEStacion |  | si | Domain:Des |
| TC_InmuebleID |  | si | Domain:inmuebles [AUTONUMERICO] |
| TC_InmuebleDes |  |  | Character (100) |

## TC_Estados
*Estados*  guid: `47c6a827-98a1-4f0e-9966-dc82897cd12e`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EstadosID | PK |  | Domain:autonumerico |
| TC_EstadosDes |  |  | Domain:Des |

## TC_EstatusAut
*Estatus pedidos*  guid: `68b08a87-3e91-8974-b118-aad57119bc0f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_EstatusAutID | PK |  | Numeric (4) |
| TC_EstatusAutDes |  |  | Character (100) |
| TC_EstatusAutDesAmp |  | si | Character (300) |
| TC_EstatusAutIMG |  | si | Image (0) |

## TC_FaseEvento
*Fases deEventos*  guid: `e6d0c487-c0a7-462c-8cba-eb6517babd29`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_FaseEventoID | PK |  | Domain:ID |
| TC_FaseEventoDEs |  |  | Domain:Des |

## TC_Inmueble
*TC_Inmueble*  guid: `446ac75b-f010-bdaa-62fd-d55efc35aeff`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_InmuebleID | PK |  | Domain:inmuebles [AUTONUMERICO] |
| TC_InmuebleDes |  | si | Character (100) |
| TC_InmuebleDesCta |  | si | Character (15) |
| TC_InmuebleDesAmp |  | si | Character (300) |
| TC_InmuebleImagen |  | si | Image (0) |
| TC_InmuebleZona |  | si | Numeric (4) |
| TC_InmuebleUbicacion |  | si | VarChar (1024) |
| TC_InmuebleGeo |  | si | Character (50) |
| TC_InmuebleTel |  | si | Character (20) |
| TC_InmuebleEmail |  | si | VarChar (100) |

## TC_LugarCita
*Lugar de cita*  guid: `78f7b1e4-0167-43ea-b476-6eab7d2ee5ae`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_LugarCitaID | PK |  | Domain:ID |
| TC_LugarCitaDes |  | si | VarChar (255) |
| TC_LugarCitaIMG |  | si | Image |
| TC_LugarCitaDomicilio |  | si | Domain:Address, GeneXus |
| TC_LugarCitaGEO |  | si | Domain:Geolocation, GeneXus |
| TC_LugarCitavigen |  | si | Boolean |
| TC_LugarCitaDireccionAbrev |  | si | VarChar (150) |
| TC_LugarCitaTelefonos |  | si | VarChar |
| TC_LugarCitaModificado |  | si | Date |

## TC_MovPedidos
*Movimientos Pedidos*  guid: `039b241c-dee2-4155-bed1-aa13e7a9fadd`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_MovPedidosID | PK |  | Domain:ID |
| TC_MovPedidosDes |  |  | Domain:Des |

## TC_Pep
*Presupuestos*  guid: `59e83f44-d092-4b5b-ae8b-b530f6ef7874`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PepId | PK |  | Domain:ID |
| TC_Pepdes |  | si | Character (100) |
| TC_PepTitComp |  | si | Domain:Des |
| TC_PepPep |  | si | VarChar (100) |
| TC_PepCategoria |  | si | Domain:Des |
| TC_PepLugarId |  |  | Domain:ID |
| TC_PepVigente |  | si | Boolean |
| TC_PepPepDEs |  |  | VarChar (150) |
| TC_PepUnidNegId |  | si | Domain:ID |
| TC_PepAno |  | si | (sin tipo explicito / heredado de dominio) |
| TC_PepPresupuesto |  | si | Numeric (10,2) |
| TC_PepTercero |  | si | Domain:SINO |

## TC_PepsMasivos
*Peps masivos*  guid: `b804c6c3-5793-4564-9159-5e9ae2512b0f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PepsMasivosId | PK |  | Domain:ID [AUTONUMERICO] |
| TC_PepsMasivosTitulo |  | si | VarChar (150) |
| TC_PepsMasivosDesc |  | si | VarChar (150) |
| TC_PepsMasivosAno |  | si | (sin tipo explicito / heredado de dominio) |
| TC_PepsMasivosPresu |  | si | (10,2) |

## TC_Periodicidad
*Periodicidad*  guid: `401e8e1d-1dbe-4020-b962-d7062930f4e1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PeriodicidadId | PK |  | Domain:ID |
| TC_PeriodicidadDesc |  | si | VarChar (150) |

## TC_PresenProd
*Presentación de Producto*  guid: `89842216-0be3-47e4-ba1a-2aae1e14a748`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PresenProdId | PK |  | Domain:ID |
| TC_PresenProdDes |  |  | Domain:Des |
| TC_UnidadNegID |  | si | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |

## TC_Productos
*Catalogo Productos*  guid: `044e3265-34ff-4388-b58b-edc75843bb68`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ProductosId | PK |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TC_UnidadNegID |  |  | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TC_PuestosPorCerIni |  |  | Numeric (18,2) |
| TC_PuestosConEntrSer |  |  | Domain:SINO |
| TC_PuestosMatricial |  |  | Domain:SINO |
| TC_PuestosPorMin |  |  | Numeric (10,2) |
| TP_pago_default |  |  | Numeric (10,2) |
| TC_PuestosRetardo |  |  | Numeric (10,2) |
| TC_PuestosFalta |  |  | Numeric (10,2) |
| TC_PuestosHrasAntesCanPed |  |  | (sin tipo explicito / heredado de dominio) |
| TC_PuestosHrasEntrTur |  |  | (sin tipo explicito / heredado de dominio) |
| TC_Puestosmatri |  |  | Boolean |
| TC_PuestosDuracion |  |  | (sin tipo explicito / heredado de dominio) |
| TP_ProductosUnidadNegocioID |  | si | Domain:ID |
| TP_ProductosUnidad_de_Negocio |  | si | VarChar (150) |
| TP_ProductosSubCategoria |  | si | VarChar (40) |
| TP_ProductosIdPuestoCatalogo |  | si | (sin tipo explicito / heredado de dominio) |
| TP_ProductosNumero_Material_SAP |  | si | VarChar (40) |
| TP_ProductosIdProductoSimilar1 |  | si | Domain:ID |
| TP_ProductosProductoSimilar1 |  | si | VarChar (150) |
| TP_ProductosIdProductoSimilar2 |  | si | Domain:ID |
| TP_ProductosProducto_Similar2 |  | si | VarChar (150) |
| TP_ProductosIdProductoSimilar3 |  | si | Domain:ID |
| TP_ProductosProductoSimilar3 |  | si | VarChar (150) |
| TP_ProductosIdProductoSimilar4 |  | si | Domain:ID |
| TP_ProductosProductoSimilar4 |  | si | VarChar (150) |
| TP_ProductosIdProductoSimilar5 |  | si | Domain:ID |
| TP_ProductosProductoSimilar5 |  | si | VarChar (150) |
| TP_ProductosIdProductoSimilar6 |  | si | Domain:ID |
| TP_ProductosProductoSimilar6 |  | si | VarChar (150) |
| TP_ProductosClave |  | si | Domain:ID |
| TP_ProductosTituloCompleto |  | si | VarChar (150) |
| TP_ProductosVigente |  | si | Boolean (2) |
| TP_Productostp_Id |  | si | Domain:ID |

## TC_Puestos
*Puestos*  guid: `4db18415-a919-4726-b3df-f96199e7b61a`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PuestosId | PK |  | Numeric (10) |
| TC_PuestosDuracion |  | si | (sin tipo explicito / heredado de dominio) |
| TC_UnidadNegID |  | si | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TC_PuestosDes |  | si | VarChar (100) |
| TC_PuestosDEsUnidadNegocio |  |  | VarChar (100) |
| TC_PuestosHrasEntrTur |  | si | (sin tipo explicito / heredado de dominio) |
| TC_PuestosHrasAntesCanPed |  | si | (sin tipo explicito / heredado de dominio) |
| TC_SucursalPagId |  | si | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| TC_PuestosPorCerIni |  | si | Numeric (18,2) |
| TC_PuestosPorMin |  | si | Numeric (10,2) |
| TC_PuestosConEntrSer |  | si | Domain:SINO |
| TC_PuestosDiasSinConf |  | si | (sin tipo explicito / heredado de dominio) |
| TC_PuestosMatricial |  | si | Domain:SINO |
| TC_PuestosReqTimeScan |  | si | Domain:SINO |
| TC_ReglaAsistId |  | si | Domain:autonumerico |
| TC_ReglaAsistDes |  |  | Domain:Des |
| TC_PuestosRetardo |  | si | Numeric (10,2) |
| TC_PuestosFalta |  | si | Numeric (10,2) |
| TP_Id |  | si | Domain:ID |
| TP_pago_default |  | si | Numeric (10,2) |
| TP_Idunidaddenegocio |  | si | Numeric (10) |
| TP_puestounidadnegocio |  | si | VarChar (255) |
| TP_reglaAsistTimescan |  | si | VarChar (100) |
| TP_PuestosConComplejidad |  | si | Boolean (4) |
| TP_puestosConFase |  | si | Boolean |
| TC_Puestosmatri |  | si | Boolean |
| TC_PuestosCiclopago |  | si | Domain:ciclopago |
| TC_PuestosRegPag |  | si | Domain:regimenpago |
| TC_EmpresaPagadoraId |  | si | Numeric (4) |
| TC_EmpresaPagadoraNombre |  |  | VarChar (150) |
| TC_PuestosReqIngles |  | si | Boolean |
| TC_PuestosReqExpLab |  | si | Boolean |
| TC_PeriodicidadId |  | si | Domain:ID |
| TC_PeriodicidadDesc |  |  | VarChar (150) |

## TC_RegPago
*Régimen de Pagos*  guid: `c2874ac2-463a-4fb8-a5b7-2596838ca420`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_RegPagoId | PK |  | Domain:ID |
| TC_RegPagoDes |  |  | VarChar (150) |

## TC_ReglaAsist
*Regla de Asistencias*  guid: `368de5e1-bf95-4d0f-b86b-fd587d0263b9`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ReglaAsistId | PK |  | Domain:autonumerico |
| TC_ReglaAsistDes |  | si | Domain:Des |
| TC_ReglaAsistMinAntEntr |  | si | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinDesEntr |  | si | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinRetar |  | si | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinAntSal |  | si | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinDesSal |  | si | (sin tipo explicito / heredado de dominio) |

## TC_Responsable
*Responsables*  guid: `96e70fbd-79f1-4fe7-8c72-cc217af85f94`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ResponsableId | PK |  | Domain:autonumerico |
| TC_ResponsableNom |  | si | VarChar (150) |
| TC_ResponsableApp |  | si | VarChar (60) |
| TC_ResponsableMaterno |  | si | VarChar (60) |
| TC_ResponsableFoto |  | si | Image |
| TC_ResponsableSexo |  | si | Domain:sexo |
| TC_ResponsableEmail |  | si | Domain:Email, GeneXus |
| TC_ResponsablePass |  | si | VarChar |

## TC_SegMovCan
*Movientos Candidatos*  guid: `7089bb83-bd27-40b1-a254-182e7236241c`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_SegMovCanId | PK |  | Domain:ID |
| TC_SegMovCanDes |  |  | VarChar (100) |

## TC_Sociedad
*TC_Sociedad*  guid: `2175e141-61d3-41cc-b3b3-942013e1c786`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_SociedadID | PK |  | Numeric (10) |
| TC_SociedadTitulo |  |  | VarChar (100) |
| TC_SociedadDes |  | si | VarChar (100) |
| TC_SociedadVigente |  | si | Domain:SINO |
| TC_SociedadGeneraFacturas |  | si | Domain:SINO |
| TC_SociedadGeneraOrSer |  | si | Domain:SINO |
| TC_SociedadesPagadorasID |  | si | Domain:ID |
| TC_SociedadesPagadorasDes |  |  | VarChar (120) |

## TC_StatusDetPed
*Estatus Detalle Pedido*  guid: `03e6f9cb-bab6-4043-a03c-53bc678e8d58`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_StatusDetPedId | PK |  | Numeric (10) |
| TC_StatusDetPedDEs |  |  | Domain:Des |

## TC_Sucursal
*Sucursales*  guid: `1e4154bf-2f1c-4304-a684-e226f09b54af`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_SucursalID | PK |  | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |

## TC_SucursalPag
*Sucursal Pagadora*  guid: `f2829f0e-3294-470c-b989-50a8a42c3c28`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_SucursalPagId | PK |  | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |

## TC_Termycond
*Términos y Condiciones*  guid: `c1df6967-3fca-476d-9f4d-5d9bcb440554`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_TermycondId | PK |  | Domain:autonumerico |
| TC_TermycondTitulo |  |  | VarChar (100) |
| TC_TermycondObse |  |  | LongVarChar |

## TC_TipoCliente
*Tipo Cliente*  guid: `8fc60128-9e45-4af8-8384-2b170a9ea790`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_TipoClienteId | PK |  | Domain:ID |
| TC_TipoClienteDesc |  | si | VarChar (100) |

## TC_TipoMovimiento
*Tipo de movimiento*  guid: `6c73d36e-a833-45d6-af1f-5f29f314ea7c`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_TipoMovimientoId | PK |  | Domain:ID |
| TC_TipoMovimientoDesc |  | si | VarChar (100) |

## TC_TipoPersonal
*Tipo de Personal*  guid: `8fb48d2a-9c99-47d9-b0f1-e76540c8fc49`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_TipoPersonalID | PK |  | Domain:ID |
| TC_TipoPersonalDes |  |  | Domain:Des |

## TC_Turnos
*Turnos*  guid: `4815e065-5189-4dc5-980b-881da32e7d6a`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_TurnosId | PK |  | Domain:ID |
| TC_TurnosDes |  |  | Domain:Des |
| TC_TurnosHras |  |  | (sin tipo explicito / heredado de dominio) |

## TC_UnidadNeg
*Unidad de negocio*  guid: `31bfb463-57ed-d757-0029-0afc5c2827bc`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_UnidadNegID | PK |  | Numeric (10) |
| TC_UnidadNegDes |  | si | VarChar (120) |
| TC_UnidadNegIMG |  | si | Image (0) |
| TC_SociedadID |  | si | Numeric (10) |
| TC_SociedadDes |  |  | VarChar (100) |

## TC_bancos
*Bancos*  guid: `89f9ca0b-9917-48d4-b9e9-fca2c42f9901`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_bancosID | PK |  | Domain:autonumerico |
| TC_bancosNombre |  | si | VarChar (100) |
| TC_BancosIMG |  | si | Image |

## TC_bancos2
*TC_bancos2*  guid: `e704bc50-1638-6f4b-e3c6-c7bebead6706`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_bancosID2 | PK |  | Numeric (10) [AUTONUMERICO] |
| TC_bancosNombre2 |  | si | VarChar (100) |
| TC_BancosIMG2 |  | si | Image (0) |

## TC_folios
*Folios*  guid: `33450f71-4e97-4a38-8b0c-3ab15538a489`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_foliosId | PK |  | Domain:autonumerico |
| TC_foliosNombre |  | si | VarChar (100) |
| TC_foliosNum |  | si | Numeric (10) |

## TC_socidad
*Socidades*  guid: `e6a4f929-4387-499e-8c35-3c095122e8f4`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_socidadId | PK |  | Domain:autonumerico |
| TC_socidades |  | si | VarChar |

## TC_sociedadesPagadoras
*Sociedades pagadoras*  guid: `41100737-3938-492b-ae38-d7303da18674`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_SociedadesPagadorasID | PK |  | Domain:ID |
| TC_SociedadesPagadorasDes |  | si | VarChar (120) |

## TE_Aclaraciones
*Aclaraciones empleados*  guid: `968063fb-e244-4c32-b37f-4b334b9e39d8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_AclaracionesId | PK |  | Domain:autonumerico |
| TC_CausasAclaraId |  |  | Domain:autonumerico |
| TC_CausasAclaraDes |  |  | VarChar (150) |
| TE_AclaracionesAsun |  |  | LongVarChar |
| TE_AclaracionesEsta |  | si | Domain:CausasAclara |
| TE_AclaracionesComRes |  | si | LongVarChar |
| TE_ReservacionID |  | si | Numeric (9) |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TE_pedDetTitu |  |  | Domain:Des |

## TE_AgendaFreelance
*Agenda Freelance*  guid: `880e7225-9f75-4fa9-8a6f-a45e3cd433e9`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_AgendaFreelanceID | PK |  | Domain:autonumerico |
| TE_AgendaFreelanceEmpId |  | si | Numeric (9) |
| TE_ReservacionID |  | si | Numeric (9) |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TE_pedDetId |  |  | Numeric (10) |
| TE_pedDetTitu |  |  | Domain:Des |
| TE_PedidoID |  |  | Numeric (10) |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_pedDetFeCita |  |  | Date |
| TE_pedDetFeCitaHI |  |  | Domain:horas |
| TE_pedDetFeCitaFi |  |  | Domain:minutos |
| TC_ProductosId |  |  | Numeric (10) |
| TE_pedDetTurnos |  |  | Numeric (18,2) |
| TE_AgendaFreelanceTiempoInicial |  | si | DateTime |
| TE_AgendaFreelanceTiempoFinal |  | si | DateTime |
| TE_AgendaFreelanceVigente |  |  | Boolean |

## TE_CClientes
*Contactos Clientes*  guid: `ca10b33f-f7b1-468a-aa7e-774074a734a7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_CClientesID | PK |  | Domain:ID |
| TE_ClientesID |  | si | Domain:ID |
| TE_ClientesNombre |  |  | VarChar (150) |
| TC_ContactosId |  | si | Domain:ID |
| TC_ContactosPrimerApellido |  |  | VarChar (100) |
| TC_ContactosSegundoApellido |  |  | VarChar (100) |
| TC_ContactosNombreCompleto |  |  | VarChar (150) |
| TC_ContactosNombre |  |  | VarChar (100) |
| TC_ContactosTelefonoMovil |  |  | VarChar (40) |
| TC_ContactosEmail |  |  | Domain:Email, GeneXus |
| TC_ContactosEmpresa |  |  | VarChar (150) |
| TC_ContactosPuesto |  |  | VarChar (150) |
| TE_CClientesNom |  |  | VarChar (100) |

## TE_Cand
*Cartera de Talento*  guid: `7383434d-d9af-3e17-ffef-55864708e5e8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_CandID | PK |  | Domain:autonumerico |
| TE_CandComoTeEn |  | si | Domain:comoteenterast |
| TC_ComoteEntId |  | si | Domain:autonumerico [AUTONUMERICO] |
| TC_ComoteEntNon |  |  | VarChar (100) |
| TE_CandRefe |  | si | Boolean |
| TE_CandNombre |  | si | VarChar (70) |
| TE_CandApPat |  | si | VarChar (70) |
| TE_CandApMat |  | si | VarChar (70) |
| TE_CandNomComp |  |  | VarChar (150) |
| TE_CandNacion |  | si | Domain:nacionalidad |
| TE_CandNacionExp |  | si | Character (60) |
| TE_CandEdoCiv |  | si | Domain:Estadocivil |
| TE_CandEstatura |  | si | Numeric (10,2) |
| TE_CandFecNac |  | si | Date |
| TE_CandEdad |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CandSexo |  | si | Domain:sexo |
| TE_CandCURP |  | si | VarChar (18) |
| TE_CandNumCart |  | si | VarChar (20) |
| TE_CandNumINE |  | si | VarChar (20) |
| TE_CandRFC |  | si | VarChar (13) |
| TC_CodigoPosId |  | si | VarChar (5) |
| TC_codigoPosColId |  | si | Domain:autonumerico |
| TC_CodigoPosColNom |  |  | VarChar (100) |
| TC_CodigoPosCiudad |  |  | VarChar (100) |
| TC_CodigoPosMuni |  |  | VarChar (100) |
| TC_CodigoPosEsta |  |  | VarChar (100) |
| TC_CodigoPosColTipo |  |  | VarChar (100) |
| TE_CandCalle |  | si | VarChar (40) |
| TE_CandNumExt |  | si | VarChar (10) |
| TE_CandNumiNT |  | si | VarChar (10) |
| TE_CandTelPart |  | si | VarChar (13) |
| TE_CandTelMovil |  | si | Character (13) |
| TE_CandWhatsApp |  | si | Character (13) |
| TE_CandFacebook |  | si | VarChar (40) |
| TE_CandTwitter |  | si | VarChar (40) |
| TE_CandInstagram |  | si | VarChar (40) |
| TE_CandCtoApPat |  | si | Character (50) |
| TE_CandCtoApMat |  | si | Character (40) |
| TE_CandCtoNom |  | si | VarChar (40) |
| TE_CandCtoNomCompleto |  | si | VarChar (150) |
| TE_CandCtoTel |  | si | Character (13) |
| TE_CandParentesco |  | si | VarChar (40) |
| TE_CandIdioma |  | si | VarChar (40) |
| TE_CandEmail |  | si | Domain:Email, GeneXus |
| TE_CandUltGraEst |  | si | Domain:Escolaridad |
| TE_CandEstatusUltGraEst |  | si | Domain:EstatusEst |
| TE_CandEnfCron |  | si | Boolean (1) |
| TE_CandEnfCronica |  | si | VarChar (40) |
| TE_CandCir |  | si | Boolean (1) |
| TE_CandCiru |  | si | VarChar (40) |
| TE_CandTrat |  | si | Boolean (1) |
| TE_CandTratmed |  | si | VarChar (40) |
| TE_CandIfeI |  | si | Image (0) |
| TE_CandCurpI |  | si | Image (0) |
| TE_CandSanfre |  | si | VarChar (40) |
| TE_CandCompDom |  | si | Image (0) |
| TE_CandActaNac |  | si | Image (0) |
| TE_CandRFCI |  | si | Image |
| TE_EmpleadosId |  | si | Numeric (8) |
| TE_EmpleadosNomcomp |  |  | VarChar (150) |
| TE_CandUser |  | si | VarChar (100) |
| TE_CandEstatus |  | si | Domain:EstatusCandi |
| TE_CandContrasena |  | si | VarChar (20) |
| TE_CandPorcCompl |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CandBorrar |  | si | Numeric (4) |
| TE_CandActEstudia |  | si | Boolean |
| TE_CandActEstuCarrera |  | si | VarChar (50) |
| TE_CandActEstuEscuela |  | si | VarChar (50) |
| TE_CandIngles |  | si | Boolean |
| TE_CandInglesNivel |  | si | Domain:nivelIng |
| TE_CandCtasCertifi |  | si | Boolean |
| TE_CandCtasCertiCual |  | si | VarChar (50) |
| TE_CandHazTomaCurs |  | si | Boolean |
| TE_CandHazTomaCurCual |  | si | VarChar (50) |
| TE_CandExpLab |  | si | Boolean |
| TE_CandUltEmp |  | si | VarChar (50) |
| TE_CandUltempPues |  | si | VarChar (50) |
| TE_CandUltempFI |  | si | Date |
| TE_CandUltempFf |  | si | Date |
| TE_CandUltempSuel |  | si | Numeric (10,2) |
| TE_CandUltempMotSali |  | si | VarChar (70) |
| TE_CandLugaNAc |  | si | VarChar (70) |
| TE_CandEstadoNac |  | si | (10) |
| TE_CandEstado |  | si | VarChar (150) |
| TE_CandCiudadNac |  | si | (10) |
| TE_CandCiudad |  | si | VarChar (150) |
| TE_CandTalla |  | si | Numeric (10,2) |
| TE_CandTieneIfeIma |  |  | Boolean |
| TE_CandTieneActIma |  |  | Boolean |
| TE_CandTieneCurp |  |  | Boolean |
| TE_CandTieneRfc |  |  | Boolean |
| TE_CandCompDomIma |  |  | Boolean |
| TE_CandTieneCompEstIma |  |  | Boolean |
| TE_CandTiencita |  | si | Boolean |
| TE_CandAltaempleado |  | si | Boolean |
| TE_CandNumEmpleDO |  | si | Numeric (10) |

## TE_CierreNomina
*TE_Cierre Nomina*  guid: `8a2d60b6-79ec-4f0b-b549-4e6dfb2bf649`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_CierreNominaId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_CierreNominaFolio |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CierreNominaFechaCierre |  |  | DateTime |
| TE_CierreNominaTitulo |  |  | VarChar (120) |

## TE_CitaGpoCan
*Candidatos en Grupos*  guid: `296dab1c-6658-4a63-ba9b-3028ddac2876`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_GpocitasId | PK |  | Domain:autonumerico |
| TE_GpocitasFI |  |  | Date |
| TE_GpocitasHraEntre |  |  | Domain:HraGpo |
| TE_VacanteTitulo |  |  | VarChar (150) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_PubVacanteId | PK |  | Domain:autonumerico |
| TE_CandID | PK |  | Domain:autonumerico |
| TE_CandNomComp |  |  | VarChar (150) |
| TE_CandNombre |  |  | VarChar (70) |
| TE_CandApPat |  |  | VarChar (70) |
| TE_CandApMat |  |  | VarChar (70) |
| TE_PostVaCanId |  |  | Domain:autonumerico [AUTONUMERICO] |
| TE_PostVaCanResul |  |  | Domain:ResVacante |
| TE_PostVaCanEstatus |  |  | Domain:EstatusCita |
| TE_CitaGpoCanEstatus |  | si | Domain:EstCitaCan |
| TE_CitaGpoCanAsis |  | si | Boolean |
| TE_CitaGpoCanCambGpo |  | si | Boolean |
| TE_CitaGpoCanContinua |  | si | Boolean |
| TE_CitaGpoCanObser |  | si | LongVarChar |
| TE_CandTieneIfeIma |  |  | Boolean |
| TE_CandTieneActIma |  |  | Boolean |
| TE_CandTieneCompEstIma |  |  | Boolean |
| TE_CandTieneCurp |  |  | Boolean |
| TE_CandTieneRfc |  |  | Boolean |
| TE_CandCompDomIma |  |  | Boolean |
| TE_CitaGpoCanDocCompl |  | si | Boolean |
| TE_CitaGpoCangpoant |  | si | VarChar |

## TE_Clientes
*Clientes*  guid: `8dc00290-9918-4693-b22e-1ff7b9e1534c`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ClientesID | PK |  | Domain:ID |
| TE_ClientesNombre |  | si | VarChar (150) |
| TE_ClientesCliente |  | si | Domain:tipoCliente |
| TE_ClientesEmail |  | si | Domain:Email, GeneXus |
| TE_ClientesTel1 |  | si | Domain:Phone, GeneXus |
| TE_ClientesTel2 |  | si | Domain:Phone, GeneXus |
| TE_ClientesDireccion |  | si | Domain:Address, GeneXus |
| TE_ClientesCodPostal |  | si | VarChar (20) |
| TE_ClientesEstado |  | si | Character (50) |
| TE_ClientesPais |  | si | Character (50) |
| TE_ClientesContacto |  | si | Character (80) |
| TE_ClientesTelContacto |  | si | VarChar (40) |
| TE_ClientesRFC |  | si | Character (13) |
| TE_ClientesTipoCte |  | si | Character (40) |
| TE_ClientesRelacion |  | si | Character |
| TE_ClientesWEB |  | si | Domain:Url, GeneXus |
| TE_ClientesClienteSAP |  | si | Character (12) |
| TE_ClientesSocPag |  | si | (sin tipo explicito / heredado de dominio) |
| TE_ClientesSocPagNombre |  | si | VarChar (150) |
| TC_TipoClienteId |  |  | Domain:ID |
| TC_TipoClienteDesc |  |  | VarChar (100) |
| TE_ClientesMaterialSAP |  | si | VarChar |
| TE_ClientesRererencia |  | si | VarChar |

## TE_ComPer
*Comunicados Personales*  guid: `79e65731-ccdf-4624-b03e-6be9b33295dc`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ComPerId | PK |  | Domain:autonumerico |
| TE_ComPerTitulo |  |  | VarChar (100) |
| TE_ComPerAsunto |  |  | LongVarChar |
| TE_ComPerFecha |  |  | Date |
| TE_ComPerIma |  |  | Image |
| TE_EmpleadosId |  |  | Numeric (8) |
| TE_EmpleadosNomcomp |  |  | VarChar (150) |

## TE_Comunicados
*Comunicados*  guid: `f1c95324-9860-4b61-9a07-64045a318150`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ComunicadosId | PK |  | Domain:autonumerico |
| TE_ComunicadosTitulo |  |  | VarChar (100) |
| TE_ComunicadosAsunto |  |  | LongVarChar |
| TE_ComunicadosFini |  |  | Date |
| TE_ComunicadosFfin |  |  | Date |
| TE_ComunicadosImagen |  |  | Image |

## TE_ContacClie
*Contactos Clientes*  guid: `33b7597a-cb0a-43b6-bae7-fb0df5f60487`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ContacClieID | PK |  | Domain:ID |
| TE_ContacClieNom |  |  | VarChar (100) |

## TE_CtasBcoEmp
*Cuentas de banco empleados*  guid: `650f79bc-4762-4818-8448-699f535d0d3d`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_CtasBcoEmpId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| TE_CtasBcoEmpBanco |  | si | (sin tipo explicito / heredado de dominio) |
| TE_CtasBcoEmpNomBanco |  | si | VarChar |
| TE_CtasBcoEmpCuenta |  | si | VarChar |
| TE_CtasBcoEmpFechaReg |  | si | DateTime |
| TE_CtasBcoEmpborrar1 |  | si | (sin tipo explicito / heredado de dominio) |

## TE_CurInducc
*Cursos de inducción*  guid: `0999c8d4-644e-4458-b923-80ce5407340a`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_CurInduccId | PK |  | Domain:autonumerico |
| TE_CurInduccDes |  | si | VarChar (150) |
| TE_CurInduccFeHr |  | si | Date (8) |
| TE_CurInduccFEMin |  | si | Domain:minutos |
| TE_CurInduccHr |  | si | Domain:horas |
| TE_CurInduccDuracion |  | si | (sin tipo explicito / heredado de dominio) |
| TE_CurInduccCupo |  | si | (sin tipo explicito / heredado de dominio) |
| TE_VacanteId |  | si | Domain:autonumerico |
| TE_VacanteTitulo |  |  | VarChar (150) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_CurInduccCitaCur |  | si | Domain:HraGpo |
| TE_CurInduccCita |  |  | VarChar (15) |
| TE_CurInduccIntegrantes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CurInduccCitaCurso |  |  | VarChar (20) |
| TE_CurInduccEventoPrueba |  | si | (10) |
| TE_CurInduccEstatus |  | si | Domain:EstatusGpo |

## TE_DetPedPuesto
*Puestos Detalle Pedido*  guid: `e048c201-e24b-4e87-a0b4-8a87fef62672`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_DetPedPuestoId | PK |  | Domain:ID |
| TE_DetPedPuestoBorrar |  |  | (sin tipo explicito / heredado de dominio) |

## TE_DispersionExcel
*TE_Dispersion Excel*  guid: `668c5fc5-9d73-4898-9adf-4ebff479399d`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_DispersionExcelId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_DispersionExcelDocu |  |  | Blob |

## TE_DocCand
*Documentos de candidato*  guid: `8fb45586-0d06-458e-ad54-9ff7749e40bf`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_DocCandId | PK |  | Domain:autonumerico [AUTONUMERICO] |
| TE_CandID | PK |  | Domain:autonumerico |
| TE_CandNomComp |  |  | VarChar (150) |
| TE_DocCandIden |  | si | Image |
| TE_DocCandActaNac |  | si | Image |
| TE_DocCandCompEst |  | si | Image |
| TE_DocCandCurp |  | si | Image |
| TE_DocCandRfc |  | si | Image |
| TE_DocCandCompDom |  | si | Image |

## TE_Docemp
*Documentos empleado*  guid: `105eeeb3-ea0b-4d52-81e0-f073c1f6dded`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_DocempdId | PK |  | Domain:autonumerico |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| TC_docuempID |  |  | Domain:autonumerico |
| TC_docuempDescrip |  |  | VarChar (100) |
| TE_DocempImagen |  |  | Image (4) |
| TE_DocempBlob |  | si | Blob |
| TE_DocempNomArch |  | si | VarChar |
| TE_DocempExtArch |  | si | VarChar (4) |

## TE_Empleado
*Empleado*  guid: `15280b20-b17b-884e-16f6-f816341a1271`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_EmpIdEmpleadoEventual | PK |  | Numeric (10) |
| ID |  |  | Numeric (9) [AUTONUMERICO] |
| Foto |  | si | Image |
| TE_EmpTipo_de_Empleado |  | si | Domain:tipodeempleado |
| TE_EmpPrimer_Apellido |  | si | VarChar (120) |
| TE_EmpSegundo_Apellido |  | si | VarChar (50) |
| TE_EmpNombre |  | si | VarChar (70) |
| TE_EmpStatus |  | si | Domain:Estatusempleado |
| TE_EmpGenero |  | si | Domain:GeneroEmpleado |
| TE_EmpPorPuntualidad |  | si | Numeric (18,2) |
| TE_EmpLugarEvento |  | si | VarChar (100) |
| TE_EmpIdSucursal |  | si | Numeric (9) |
| TE_EmpNomSucursal |  | si | VarChar (70) |
| TE_EmpRegPago |  | si | Domain:regimendepago |
| TE_EmpCicloPago |  | si | Domain:ciclodepago |
| TE_EmpCorreo_Electronico |  | si | VarChar (70) |
| TE_EmpIdBanco |  | si | Numeric (9) |
| TE_EmpNombre_Banco |  | si | VarChar (70) |
| TE_EmpCuenta_Banco |  | si | VarChar (40) |
| TE_EmpFecNac |  | si | Date |
| TE_EmpEdoNac |  | si | VarChar (70) |
| TE_EmpRFC |  | si | VarChar (15) |
| TE_EmpCURP |  | si | VarChar (25) |
| TE_EmpCredElector |  | si | VarChar (25) |
| TE_EmpCartilla |  | si | VarChar (25) |
| TE_EmpEstatura |  | si | Numeric (18,2) |
| TE_EmpEdoCivil |  | si | Domain:Estadocivil |
| TE_EmpTalla |  | si | VarChar (20) |
| TE_EmpDireccion |  | si | VarChar (100) |
| TE_EmpCalle |  | si | VarChar (40) |
| TE_EmpTE_EmpNumExt |  | si | VarChar (10) |
| TE_EmpNunInt |  | si | VarChar (10) |
| TE_EmpColonia |  | si | VarChar (40) |
| TE_EmpCodPostal |  | si | VarChar (7) |
| TE_EmpDelMun |  | si | VarChar (50) |
| TE_EmpEdoProv |  | si | VarChar (50) |
| TE_EmpTelMovil |  | si | VarChar (15) |
| TE_EmpTelPart |  | si | VarChar (15) |
| TE_EmpFecIng |  | si | Date |
| TE_EmpFecAnt |  | si | Date |
| TE_EmpFecBaja |  | si | Date |
| TE_EmpIdSolicitud |  | si | Numeric (9) |
| TE_EmpIdEmpPagadora |  | si | Numeric (9) |
| TE_EmpIdEmpPagadora_L |  | si | Numeric (9) |
| TE_EmpIdPuesto |  | si | Numeric (9) |
| TE_EmpNombrePuesto |  | si | VarChar (100) |
| IdPuesto_Lista |  | si | Numeric (9) |
| TE_EmpCreado |  | si | DateTime |
| TE_EmpModificado |  | si | DateTime |
| TE_EmpGraEstudios |  | si | VarChar (50) |
| TE_EmpStatusGradoEstudio |  | si | VarChar (50) |
| TE_EmpLicCurso |  | si | VarChar (50) |
| TE_EmpIdiomas |  | si | VarChar (50) |
| TE_EmpAccidente |  | si | VarChar (50) |
| TE_EmpCirugiasTratam |  | si | VarChar (50) |
| TE_EmpTipoSangre |  | si | VarChar (50) |
| TE_EmpRecomendadoPor |  | si | VarChar (50) |
| TE_EmpStatus_Oculto |  | si | VarChar (50) |
| TE_EmpleadoBorrar |  | si | Numeric (10) |
| TE_EmpleadoAlias |  | si | VarChar |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TC_bancosID |  | si | Domain:autonumerico |
| TC_bancosNombre |  |  | VarChar (100) |
| TC_CodigoPosId |  | si | VarChar (5) |
| TC_CodigoPosMuni |  |  | VarChar (100) |
| TC_CodigoPosCiudad |  |  | VarChar (100) |
| TC_CodigoPosEsta |  |  | VarChar (100) |
| TC_codigoPosColId |  | si | Domain:autonumerico |
| TC_CodigoPosColNom |  |  | VarChar (100) |
| TC_SucursalID |  | si | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TE_EmpleadoBusXNombre1 |  |  | VarChar (220) |
| TE_EmpleadoBusReserva |  | si | VarChar (120) |
| TE_EmpleadoNombreCompleto |  | si | VarChar (120) |

## TE_Empleados
*Empleados*  guid: `66331fd9-e538-495b-9356-cdb709f07b97`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_EmpleadosId | PK |  | Numeric (8) |
| TE_EmpleadosNum |  | si | Numeric (10) |
| TE_EmpleadosNom |  | si | VarChar (100) |
| TE_EmpleadosApp |  | si | VarChar (100) |
| TE_EmpleadosApm |  | si | VarChar (100) |
| TE_EmpleadosAlias |  | si | VarChar |
| TE_EmpleadosNomcomp |  | si | VarChar (150) |
| TE_EmpleadosFoto |  | si | Image |
| TE_EmpleadosSolici |  | si | Numeric (10) |
| TC_RegPagoId |  | si | Domain:ID |
| TC_RegPagoDes |  |  | VarChar (150) |
| TC_SucursalPagId |  | si | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| TE_empleadosFormapgo |  | si | Domain:formpPgo |
| TE_empleadosBusqueda |  |  | VarChar (100) |
| TE_empleadosUser |  | si | VarChar (10) |

## TE_EvePrue
*Eventos Prueba*  guid: `4b76e464-37f7-4c17-b765-d627b0d07efb`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_EvePrueId | PK |  | Domain:autonumerico |
| TE_PedidoID |  |  | Numeric (10) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TE_EventoID |  |  | Numeric (10) |
| TE_EventoDes |  |  | VarChar (100) |
| TE_EventoFecIni |  |  | Date |
| TE_EventoIMG |  |  | Image (0) |
| TE_pedDetId |  | si | Numeric (10) |
| TC_ProductosId |  |  | Numeric (10) |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_PeddetFechacitaFin |  |  | VarChar (15) |
| TE_PeddetFechafincitaoculta |  |  | DateTime |
| TE_PeddetFacSerInt |  |  | Domain:SINO |
| TC_ProductosDEs |  |  | VarChar (150) |
| TE_pedDetCant |  |  | Numeric (4) |
| TE_pedDetTurnos |  |  | Numeric (18,2) |
| TE_pedDetObser |  |  | VarChar (200) |
| TE_pedDetCantReserv |  |  | (10) |
| TE_PeddetProductoTitulo |  |  | VarChar (150) |
| TE_EvePrueHra |  | si | Domain:horas |
| TE_EvePrueMinu |  | si | Domain:minutos |
| ST_lugaresPedidosId |  |  | (sin tipo explicito / heredado de dominio) |
| ST_lugaresPedidosdom |  |  | (sin tipo explicito / heredado de dominio) |
| ST_lugaresPedidosDes |  |  | (sin tipo explicito / heredado de dominio) |
| TC_PresenProdId |  |  | Domain:ID |
| TC_PresenProdDes |  |  | Domain:Des |
| TE_EvePrueComoLlegar |  | si | VarChar (200) |
| TE_EvePrueIndicaciones |  | si | LongVarChar |
| TE_EvePrueCitaEve |  | si | Domain:HraGpo |
| TE_EvePrueCupo |  | si | (sin tipo explicito / heredado de dominio) |
| TE_EvePrueCitaEvento |  |  | VarChar (20) |
| TE_EvePrueIntegrantes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_EvePrueEstatus |  | si | Domain:EstatusGpo |

## TE_Evento
*Eventos*  guid: `dd7be47d-5837-da29-6d7c-e499d58e1fad`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_EventoID | PK |  | Numeric (10) |
| TE_EventoDes |  | si | VarChar (100) |
| TE_EventoFecIni |  | si | Date |
| TE_EventoHora |  | si | Domain:horas |
| TE_EventoMinutos |  | si | Domain:minutos |
| TE_EventoIMG |  | si | Image (0) |
| TE_EventoFeinicial |  | si | DateTime |
| TE_EventoFeTer |  | si | Date |
| TE_EventoFechaVigencia |  |  | Date |
| TC_InmuebleID |  | si | Domain:inmuebles [AUTONUMERICO] |
| TC_InmuebleDes |  |  | Character (100) |

## TE_Excel
*TE_Excel*  guid: `57ffe9ec-20f6-4405-aa26-58313946e730`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ExcelId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_ExcelDocumento |  | si | Blob |
| TE_ExcelNombreaArchivo |  | si | VarChar |
| TE_ExcelExtension |  | si | VarChar (4) |

## TE_Extras
*Extras*  guid: `d7ea6d83-9534-e13c-5dab-cb34d5193e60`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ExtrasId | PK |  | Numeric (9) [AUTONUMERICO] |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TE_EmpStatus |  |  | Domain:Estatusempleado |
| TE_pedDetId |  |  | Numeric (10) |
| TE_pedDetTitu |  |  | Domain:Des |
| TE_pedDetFeCita |  |  | Date |
| TE_pedDetFeCitaHI |  |  | Domain:horas |
| TE_pedDetFeCitaFi |  |  | Domain:minutos |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_PeddetFechafincitaoculta |  |  | DateTime |
| TC_ProductosId |  |  | Numeric (10) |
| TE_pedDetTurnos |  |  | Numeric (18,2) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TP_pago_default |  |  | Numeric (10,2) |
| TC_bancosNombre |  |  | VarChar (100) |
| TE_EmpCuenta_Banco |  |  | VarChar (40) |
| TE_ExtrasTurnos |  | si | Numeric (18,2) |
| TE_ExtrasMonto |  | si | Numeric (18,2) |
| TC_ConceptosExtrasId |  | si | Domain:ID [AUTONUMERICO] |
| TC_ConceptosExtrasConcepto |  |  | VarChar (150) |
| TC_ConceptosExtrasLibre |  |  | Boolean |
| TE_ExtrasObservaciones |  | si | LongVarChar (2097152) |
| TE_ExtrasStatusAutorizacion |  | si | Boolean |
| TE_ExtrasStatus |  | si | Character (20) |
| TE_ExtraseriodoCobrado |  | si | Numeric (10,2) |
| TE_ExtrasIdPedidoDetalle |  | si | Numeric (18,6) |
| TE_ExtrasIdPlaza |  | si | Numeric (9) |
| TE_Extrastp_Level |  | si | Numeric (2) |
| TE_Extrastp_Author |  | si | VarChar (40) |
| TE_Extrastp_Editor |  | si | VarChar (40) |
| TE_Extrastp_Created |  | si | DateTime |
| TE_Extrastp_Modified |  | si | DateTime |
| TE_ExtrasNumeroFolioHonorarios |  | si | VarChar (20) |
| TE_ExtrasReservacion |  | si | Numeric (10) |

## TE_ExtrasMasivos
*Alta masiva de extras*  guid: `8036a405-b8b5-41f6-83f8-e9e7a83e0206`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ExtrasMasivosID | PK |  | Numeric |
| TE_ExtrasMasivosArchivo |  |  | Blob |
| TE_ExtrasMasivosArchivoNom |  |  | VarChar (100) |
| TE_ExtrasMasivosArchivoExt |  |  | VarChar (4) |
| TE_ExtrasMasivosTotalRegistros |  |  | (sin tipo explicito / heredado de dominio) |
| TE_ExtrasMasivosFechayhoradeproceso |  |  | DateTime |
| TE_ExtrasMasivosDetalleId | PK |  | (sin tipo explicito / heredado de dominio) |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpNombre |  |  | VarChar (70) |
| TE_pedDetId |  |  | Numeric (10) |
| TE_pedDetTitu |  |  | Domain:Des |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_ExtrasMasivosDetalleTurnos |  |  | (sin tipo explicito / heredado de dominio) |
| TE_ExtrasMasivosDetalleMOnto |  |  | (10,2) |
| TE_ExtrasMasivosDetalleConcepto |  |  | VarChar (50) |
| TE_ExtrasMasivosDetalleOberva |  |  | LongVarChar |

## TE_FacturaDet
*Facturas detalle*  guid: `009905ad-f504-49f6-bca3-7ee87f895f7f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaDetId | PK |  | Domain:ID |
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaDetDescripcion |  | si | VarChar (100) |
| TE_FacturaDetAgrupado |  | si | Domain:SINO |
| TE_FacturaDetCantidad |  | si | Numeric (10) |
| TC_ProductosId |  | si | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TP_ProductosNumero_Material_SAP |  |  | VarChar (40) |
| TE_FacturaDetFolio |  | si | Numeric (10) |
| TE_FacturaDetIdAgrupado |  | si | Numeric (10) |
| TE_FacturaDetFacServInterno |  | si | Numeric (10) |
| TE_FacturaDetIdProducto |  | si | Numeric (10) |
| TE_FacturaDetIdPedidoDetalle |  | si | Numeric (10) |
| TE_FacturaDetIdPedido |  | si | Numeric (10) |
| TE_FacturaDetPrecioUnitario |  | si | Numeric (10,2) |
| TE_FacturaDetProducto |  | si | VarChar (100) |
| TE_FacturaDetSubTotal |  |  | Numeric (10,2) |
| TE_FacturaDetTurnos |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaDetIdFacturaServicioInterno |  | si | Numeric (10) |
| TE_FacturaDetCreado |  | si | DateTime |
| TE_FacturaDetModificado |  | si | DateTime |
| TE_FacturaDetModificadoPor |  | si | VarChar |
| TE_FacturaDetCreadoPor |  | si | VarChar (100) |
| TE_FacturaDetContarPedidoDetalles |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaDetTipo |  | si | VarChar (2) |
| TE_FacturaDetTienePedidos |  | si | (sin tipo explicito / heredado de dominio) |

## TE_FacturaDetAuxiliar
*Detalle facturas *  guid: `d58f188a-4d44-4407-bf21-13a559b7b1e4`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaDetAuxiliarId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaDetAuxiliarDescripcion |  | si | VarChar (100) |
| TE_FacturaDetAuxiliarAgrupado |  | si | Domain:SINO |
| TE_FacturaDetAuxiliarCantidad |  | si | Numeric (10) |
| TC_ProductosId |  |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TE_FacturaDetAuxiliarFolio |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarIdAgrupado |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarFacServInterno |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarIdProducto |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarIdPedidoDetalle |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarIdPedido |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarPrecioUnitario |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarProducto |  | si | VarChar (100,2) |
| TE_FacturaDetAuxiliarSubTotal |  | si | Numeric (10,2) |
| TE_FacturaDetAuxiliarTurnos |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaDetAuxiliarIdFacturaServicioInterno |  | si | Numeric (10) |
| TE_FacturaDetAuxiliarCreado |  | si | DateTime |
| TE_FacturaDetAuxiliarModificado |  | si | DateTime |
| TE_FacturaDetAuxiliarCreadoPor |  | si | VarChar (100) |
| TE_FacturaDetAuxiliarContarPedidoDetalles |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaDetAuxiliarTipo |  | si | VarChar (2) |

## TE_FacturaDetPed
*Detalles Pedidos Factura*  guid: `f3e4039d-7123-4e01-8d75-d30d5b96b9d1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaDetId | PK |  | Domain:ID |
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaDetPedId | PK |  | Numeric (10) |
| TE_FacturaDetPedTitulo |  | si | Domain:Des |
| TE_FacturaDetPedCant |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaDetPedTurnos |  | si | (18,2) |
| TE_FacturaDetPedPrecio |  | si | (10,2) |
| TE_FacturaDetPedProductoID |  | si | (10) |
| TE_FacturaDetPedProductoDes |  | si | VarChar (150) |
| TE_FacturaDetPedPuestoID |  | si | (10) |
| TE_FacturaDetPedPedidoId |  | si | Numeric (10) |

## TE_FacturaDetPedidoDetalle
*TE_Factura Det Pedido Detalle*  guid: `b4c54ffe-f3bd-4445-89d6-8a479d26b235`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaDetId | PK |  | Domain:ID |
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_pedDetId | PK |  | Numeric (10) |
| TE_pedDetTitu |  |  | Domain:Des |
| TE_pedDetCant |  |  | Numeric (4) |
| TE_pedDetTurnos |  |  | Numeric (18,2) |
| TC_ProductosId |  |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_PedidoID |  |  | Numeric (10) |

## TE_FacturaEnc
*Facturas*  guid: `b429af8b-4a7c-4350-b34b-cfc0cbdfa861`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaEncIdFactura |  | si | (10) |
| TE_FacturaEncFolio |  | si | (10) |
| TE_FacturaEncTipo |  | si | VarChar (30) |
| TE_FacturaEncPedido |  | si | Numeric (10) |
| TE_PedidoID |  | si | Numeric (10) |
| TC_PepPepDEs |  |  | VarChar (150) |
| ST_clientesID |  |  | (sin tipo explicito / heredado de dominio) |
| ST_clientesNom |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TC_ContactosNombreCompleto |  |  | VarChar (150) |
| ST_lugaresPedidosDes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncSucursal |  | si | Numeric (10) |
| TE_FacturaEncIdUnidadDeNegocio |  | si | (10) |
| TE_FacturaEncIdPep |  | si | (10) |
| TE_FacturaEncIdCliente |  | si | (10) |
| TE_FacturaEncTelefonoCliente |  | si | VarChar |
| TE_FacturaEncIdContacto |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncTelefonoContacto |  | si | VarChar |
| TE_FacturaEncCorreoElecContacto1 |  | si | Domain:Email, GeneXus |
| TE_FacturaEncCorreoElecContacto2 |  | si | Domain:Email, GeneXus |
| TE_FacturaEncCorreoElecContacto3 |  | si | Domain:Email, GeneXus |
| TE_FacturaEncInmueble |  | si | Numeric |
| TE_FacturaEncInmuebleOtro |  | si | VarChar |
| TE_FacturaEncFechadeMovimiento |  | si | DateTime |
| TE_FacturaEncNumeroSAP |  | si | VarChar |
| TE_FacturaEncIdUnidadDeMedida |  | si | VarChar |
| TE_FacturaEncFormaDePago |  | si | VarChar |
| TE_FacturaEncMetodoDePago |  | si | VarChar |
| TE_FacturaEncCuenta |  | si | VarChar |
| TE_FacturaEncLugarDeExpedicion |  | si | VarChar (100) |
| TE_FacturaEncTipoDeCliente |  | si | VarChar |
| TE_FacturaEncUsoCFI |  | si | VarChar |
| TE_FacturaEncTipoRelacionCFDI |  | si | VarChar |
| TE_FacturaEncUUIDRElacionado |  | si | VarChar |
| TE_FacturaEncClaveUnidad |  | si | VarChar |
| TE_FacturaEncClaveProducto |  | si | VarChar |
| TE_FacturaEncAduana |  | si | VarChar |
| TE_FacturaEncNumeroPedimentoAduana |  | si | VarChar |
| TE_FacturaEncPatenteAduanal |  | si | VarChar |
| TE_FacturaEncTextoCabezaPortal |  | si | VarChar |
| TE_FacturaEncTextoPosicionPortal |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncCondicionPago2 |  | si | VarChar |
| TE_FacturaEncTipoProceso |  | si | VarChar |
| TE_FacturaEncTipoComite |  | si | VarChar |
| TE_FacturaEncIdContabilidad |  | si | VarChar |
| TE_FacturaEncAmbito |  | si | VarChar |
| TE_FacturaEncConsecutivo |  | si | VarChar |
| TE_FacturaEncClaveEntidad |  | si | VarChar |
| TE_FacturaEncRetencion |  | si | VarChar |
| TE_FacturaEncMoneda |  | si | VarChar (3,2) |
| TE_FacturaEncCentroCostos |  | si | VarChar (100) |
| TE_FacturaEncContarPartidas |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncEstatus |  | si | VarChar |
| TE_FacturaEncTXT |  | si | LongVarChar |
| TE_FacturaEncOrganizacionVenta |  | si | VarChar (100) |
| TE_FacturaEncCanalDistribucion |  | si | VarChar (100) |
| TE_FacturaEncSector |  | si | VarChar (100) |
| TE_FacturaEncDEscripcion |  | si | VarChar (100) |
| TE_FacturaEncGeneradoSap |  | si | Domain:SINO |
| TC_TipoMovimientoId |  | si | Domain:ID |
| TC_TipoMovimientoDesc |  |  | VarChar (100) |
| TC_SucursalID |  |  | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |

## TE_Gpocitas
*Grupos para entrevistas*  guid: `cf78f666-85bb-4b81-8606-81df0e43c371`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_GpocitasId | PK |  | Domain:autonumerico |
| TE_GpocitasFI |  | si | Date |
| TE_GpocitasHI |  | si | Domain:horas |
| TE_GpocitasMin |  | si | Domain:minutos |
| TE_PubVacanteId |  | si | Domain:autonumerico |
| TE_VacanteId |  |  | Domain:autonumerico |
| TE_GpocitasTitulo |  | si | VarChar (150) |
| TE_GpocitasHrajunta |  |  | VarChar (5) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_VacanteTitulo |  |  | VarChar (150) |
| TE_GpocitasCupo |  | si | Numeric (10) |
| TC_SucursalID |  | si | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |
| TE_GpocitasCitado |  |  | Numeric (10) |
| TE_GpocitasPorcen |  | si | Numeric (10) |
| TE_GpocitasEstatus |  | si | Domain:EstatusGpo |
| TE_GpocitasHraEntre |  | si | Domain:HraGpo |
| TE_GpocitasCitadoProceso |  |  | (sin tipo explicito / heredado de dominio) |
| TE_GpocitasCitadoHraCitaGpo |  |  | DateTime |
| TE_GpocitasCierreAsisten |  | si | Boolean |
| TE_GpocitasCierreFirmaContra |  | si | Boolean |

## TE_InconsistenciasCierreNomina
*TE_Inconsistencias Cierre Nomina*  guid: `d9736ed0-b9d6-4edf-900d-a2369accd15b`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_InconsistenciasCierreNominaId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_CierreNominaId |  |  | Domain:ID [AUTONUMERICO] |
| TE_CierreNominaFolio |  |  | (sin tipo explicito / heredado de dominio) |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |

## TE_ListaNegra
*Empleados vetados*  guid: `39e76a20-f15c-40c4-a7f1-005f0cb32f33`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ListaNegraId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TE_ListaNegraFechaDesde |  | si | DateTime |
| TE_ListaNegraFechaHasta |  | si | DateTime |
| TC_LugarCitaID |  | si | Domain:ID |
| TC_LugarCitaDes |  |  | VarChar (255) |
| TE_ListaNegraVetadoTodos |  | si | Boolean |

## TE_LogEmp
*Movimientos empleado*  guid: `dcb08cd7-fbb5-4a1a-9fe2-13779a7067b8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_LogEmpid | PK |  | Domain:autonumerico |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| TE_LogEmpFecha |  | si | DateTime |
| TE_LogEmpTipoMov |  | si | Domain:MovEmpleado |
| TC_CatBajReinID |  | si | Domain:autonumerico |
| TC_CatBajReinDes |  |  | VarChar (50) |
| TE_LogEmpObserv |  | si | LongVarChar |

## TE_ObservaEmp
*Observaciones empleado*  guid: `41cc2083-c7cf-40ef-8431-d75043866ecb`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ObservaEmpId | PK |  | Domain:ID [AUTONUMERICO] |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| TE_ObservaEmpFecha |  | si | DateTime |
| TE_ObservaEmpObser |  | si | LongVarChar |

## TE_Pagos
*TE_Pagos*  guid: `d77f0642-f7ba-8d8a-b74d-fc68aae5e3c0`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| Te_pagosID | PK |  | Numeric (9) |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TE_EmpRegPago |  |  | Domain:regimendepago |
| TE_EmpCuenta_Banco |  |  | VarChar (40) |
| TC_bancosID |  |  | Domain:autonumerico |
| TC_bancosNombre |  |  | VarChar (100) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| Te_pagosNombres |  | si | VarChar (255) |
| Te_pagosRegimen |  | si | VarChar (255) |
| Te_pagosPeriodo |  | si | Numeric (9) |
| Te_pagosPeriododePago |  | si | Numeric (10) |
| Te_pagosIdBanco |  | si | Numeric (9) |
| Te_pagosNombreBanco |  | si | VarChar (255) |
| Te_pagosNumeroCuentaBanco |  | si | VarChar (255) |
| Te_pagosDiasLaborados |  | si | VarChar (255) |
| Te_pagosPagoBruto |  | si | Numeric (17,6) |
| Te_pagosSDP |  | si | Numeric (17,6) |
| Te_pagosIM |  | si | Numeric (17,6) |
| Te_pagosCF |  | si | Numeric (17,6) |
| Te_pagosSA |  | si | Numeric (17,6) |
| Te_pagosCG |  | si | Numeric (17,6) |
| Te_pagosID2 |  | si | Numeric (17,6) |
| Te_pagosIT |  | si | Numeric (17,6) |
| Te_pagosIVA |  | si | Numeric (16,6) |
| Te_pagosRIVA |  | si | Numeric (16,6) |
| Te_pagosRISR |  | si | Numeric (16,6) |
| Te_pagosPagoNeto |  | si | Numeric (17,6) |
| Te_pagosIdEmpresaPagadora |  | si | Numeric (9) |
| Te_pagosEmpresaPagadora |  | si | VarChar (255) |
| Te_pagosObservaciones |  | si | VarChar (255) |
| Te_pagosSolicitudPago |  | si | VarChar (255) |
| Te_pagosModificado |  | si | DateTime |
| Te_pagosCreado |  | si | DateTime |
| Te_pagosCreadopor |  | si | Numeric (9) |
| Te_pagosModificadopor |  | si | Numeric (9) |
| Te_pagosIdPuestoPrincipal |  | si | Numeric (9) |
| Te_pagosPuestoPrincipal |  | si | VarChar (255) |
| Te_pagosIdUnidadDeNegocio |  | si | Numeric (9) |
| Te_pagosUnidadDeNegocio |  | si | VarChar (255) |
| Te_pagosIdSociedadPropia |  | si | Numeric (9) |
| Te_pagosSociedadPropia |  | si | VarChar (255) |
| Te_pagosCumpleReglas |  | si | Numeric (1) |
| Te_pagosCumpleReglaPoseeCuentadeBanco |  | si | Numeric (1) |
| Te_pagosCumpleReglaUltimoPagoenPeriodosRecientes |  | si | Numeric (1) |
| Te_pagosCumpleReglaRecibePagoenelPeriodoActual |  | si | Numeric (1) |
| Te_pagosId_Lista |  | si | Numeric (9) |
| TE_PagosBorrar |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PagosEstatusCierre |  | si | Boolean |

## TE_Peddet
*Detalle pedidos*  guid: `ccb79c93-7154-43d2-b12d-f75efe269d70`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_pedDetId | PK |  | Numeric (10) |
| TE_pedDetTitu |  | si | Domain:Des |
| TE_PedidoID |  |  | Numeric (10) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TE_EventoID |  |  | Numeric (10) |
| TE_EventoDes |  |  | VarChar (100) |
| TE_EventoIMG |  |  | Image (0) |
| TE_EventoFeinicial |  |  | DateTime |
| TE_PedidoFecha |  |  | DateTime |
| TC_SociedadID |  |  | Numeric (10) |
| TC_SociedadDes |  |  | VarChar (100) |
| TC_PepPep |  |  | VarChar (100) |
| TC_SucursalPagId |  |  | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| ST_UnidadNegPedId |  |  | (sin tipo explicito / heredado de dominio) |
| ST_UnidadNegPedDes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_peddetfecREg |  | si | Date |
| TC_StatusDetPedId |  | si | Numeric (10) |
| TC_StatusDetPedDEs |  |  | Domain:Des |
| TC_ProductosId |  |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TP_ProductosSubCategoria |  |  | VarChar (40) |
| TC_PuestosPorCerIni |  |  | Numeric (18,2) |
| TC_PuestosConEntrSer |  |  | Domain:SINO |
| TC_PuestosMatricial |  |  | Domain:SINO |
| TC_Puestosmatri |  |  | Boolean |
| TC_PuestosPorMin |  |  | Numeric (10,2) |
| TP_pago_default |  |  | Numeric (10,2) |
| TC_PuestosRetardo |  |  | Numeric (10,2) |
| TC_PuestosFalta |  |  | Numeric (10,2) |
| TC_PuestosHrasAntesCanPed |  |  | (sin tipo explicito / heredado de dominio) |
| TC_PuestosHrasEntrTur |  |  | (sin tipo explicito / heredado de dominio) |
| TC_PuestosDuracion |  |  | (sin tipo explicito / heredado de dominio) |
| TP_ProductosTituloCompleto |  |  | VarChar (150) |
| TE_pedDetFeCita |  | si | Date |
| TE_pedDetFeCitaHI |  | si | Domain:horas |
| TE_pedDetFeCitaFi |  | si | Domain:minutos |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_pedDetFeFinal |  | si | Date |
| TE_pedDetFeFinalHI |  | si | Domain:horas |
| TE_pedDetFeFinalHF |  | si | Domain:minutos |
| TE_PeddetFechafincitaoculta |  | si | DateTime |
| TE_pedDetFeLib |  | si | Date |
| TE_pedDetFeLibHI |  | si | Domain:horas |
| TE_pedDetFeLibHF |  | si | Domain:minutos |
| TE_PeddetFeLibJunta |  |  | DateTime |
| TE_pedDetTurnos |  | si | Numeric (18,2) |
| TE_pedDetCant |  | si | Numeric (4) |
| TE_PeddetCostoPersona |  | si | Numeric (10,2) |
| TE_PeddetIdPuesto |  | si | Numeric (10) |
| TE_PeddetTituPuesto |  | si | VarChar (255) |
| TE_PeddetProduMatricial |  | si | VarChar (10) |
| TC_PresenProdId |  | si | Domain:ID |
| TC_PresenProdDes |  |  | Domain:Des |
| TE_pedDetCompSim |  | si | Domain:SINO |
| TE_pedDetBloque |  | si | Domain:SINO |
| TE_PeddetFechafinBloque |  | si | DateTime |
| TE_PeddetFechaVigenPreasig |  | si | DateTime |
| TE_PeddetCompleto |  | si | VarChar (10) |
| TE_PeddetporComConPreAsig |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PeddetCompletoConPreasigna |  | si | VarChar (10) |
| TE_PeddetcantAsistieron |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PeddetLugarId |  | si | Numeric (10) |
| TE_PeddetLugarId1 |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PeddetLugardireccion |  | si | VarChar (200) |
| TE_PeddetSucursal |  | si | Numeric (10) |
| TE_PeddetTituloSucu |  | si | VarChar (255) |
| TE_PeddetUnidNegocio |  | si | Numeric (10) |
| TE_PeddetTituloUnidadNego |  | si | VarChar (255) |
| TE_PeddetIdsociedad |  | si | Numeric (10) |
| TE_PeddetTituloSociedad |  | si | VarChar (255) |
| TE_pedDetObser |  | si | VarChar (200) |
| TE_pedDetPeriodoPago |  | si | (sin tipo explicito / heredado de dominio) |
| TE_pedDetPeriodoAsiten |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PeddetFacturable |  | si | VarChar (10) |
| TE_PeddetFolioFactu |  | si | Numeric (10) |
| TE_PeddetFacSerInt |  | si | Domain:SINO |
| TC_FaseEventoID |  | si | Domain:ID |
| TC_FaseEventoDEs |  |  | Domain:Des |
| TE_PeddetPrecio |  | si | Numeric (10,2) |
| TE_PeddetFechaEnvioSms |  | si | DateTime |
| TE_PeddetCostoXnomina |  | si | Numeric (10,2) |
| TE_PeddetPagoEspecial |  | si | Numeric (10,2) |
| TE_PeddetPpagoEspecial |  | si | Domain:SINO |
| TE_PeddetCancelar |  | si | Domain:SINO |
| TE_PeddetStatusEnvioSms |  | si | VarChar (10) |
| TE_PeddetEnvioSmsPreasignados |  | si | Boolean |
| TE_PeddetCreadoPor |  | si | VarChar |
| TE_PeddetCreado |  | si | DateTime |
| TE_PeddetModificadoPor |  | si | VarChar |
| TE_PeddetModificado |  | si | DateTime |
| TE_PeddetCorreoEnvFaltas |  | si | Boolean |
| TE_PeddetCorreoEnv_PEP_Temporal |  | si | Boolean |
| TC_TipoPersonalID |  | si | Domain:ID |
| TC_TipoPersonalDes |  |  | Domain:Des |
| TE_pedDetOtro |  | si | Boolean |
| TE_pedDetOtroDes |  | si | Domain:Des |
| TE_pedDetDirec |  | si | Domain:Address, GeneXus |
| TE_pedDetPuesFac |  | si | Domain:SINO |
| TE_PeddetSegReser |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PeddetFechacita |  |  | VarChar (15) |
| TE_PeddetBloqueNum |  | si | VarChar (12) |
| TE_PeddetBloqueNumDistinto |  |  | VarChar (15) |
| TE_PeddetFechacitaFin |  |  | VarChar (15) |
| TE_pedDetPorCompleto |  | si | (10,2) |
| TE_pedDetCAntPreAsig |  | si | (10) |
| TE_pedDetCantReserv |  | si | (10) |
| TE_pedDetCantReRealCalculada |  |  | (sin tipo explicito / heredado de dominio) |
| TE_pedDetCantReReal |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PeddetEventoPrueba |  | si | Boolean |
| TE_PeddetProductoTitulo |  | si | VarChar (150) |

## TE_Pedido
*Pedidos*  guid: `c0c3a4a9-71ab-768f-6c0f-863763f0dc8a`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_PedidoID | PK |  | Numeric (10) |
| TE_PedidoTitulo |  | si | VarChar (100) |
| TC_EstatusAutID |  | si | Numeric (4) |
| TC_EstatusAutDes |  |  | Character (100) |
| ST_clientesID |  | si | (sin tipo explicito / heredado de dominio) |
| ST_clientesNom |  |  | (sin tipo explicito / heredado de dominio) |
| ST_ClientesSocPag |  |  | (sin tipo explicito / heredado de dominio) |
| TE_ClientesCliente |  |  | Domain:tipoCliente |
| TE_CClientesID |  | si | Domain:ID |
| TE_CClientesNom |  |  | VarChar (100) |
| TC_ContactosEmail |  |  | Domain:Email, GeneXus |
| TC_ContactosTelefonoParticular |  |  | VarChar (40) |
| TC_ContactosId |  |  | Domain:ID |
| TC_ContactosNombreCompleto |  |  | VarChar (150) |
| TE_EventoID |  | si | Numeric (10) |
| TE_EventoDes |  |  | VarChar (100) |
| TE_EventoFeinicial |  |  | DateTime |
| TC_SucursalID |  |  | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |
| ST_UnidadNegPedId |  | si | (sin tipo explicito / heredado de dominio) |
| ST_UnidadNegPedDes |  |  | (sin tipo explicito / heredado de dominio) |
| TC_PepId |  | si | Domain:ID |
| TC_Pepdes |  |  | Character (100) |
| TC_PepUnidNegId |  |  | Domain:ID |
| TC_PepLugarId |  |  | Domain:ID |
| TC_PepPepDEs |  |  | VarChar (150) |
| ST_lugaresPedidosId |  | si | (sin tipo explicito / heredado de dominio) |
| ST_lugaresPedidosDes |  |  | (sin tipo explicito / heredado de dominio) |
| ST_lugaresPedidosdom |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PedidoDireccionLugar |  | si | VarChar (200) |
| TE_PedidoDireccionLugar1 |  |  | VarChar (200) |
| TC_MovPedidosID |  | si | Domain:ID |
| TC_MovPedidosDes |  |  | Domain:Des |
| TE_PedidoIdSoc |  | si | Numeric (10) |
| TE_PedidoTituloSoc |  | si | VarChar (255) |
| SP_SocPagId |  | si | (sin tipo explicito / heredado de dominio) |
| SP_SocPagDes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PedidoSociedadPagadora |  | si | Domain:ID |
| TC_complejoid |  | si | Domain:ID |
| TC_ComplejoDES |  |  | Domain:Des |
| TE_PedidoDuracionDias |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PedidoIdTipoDuraEvento |  | si | Numeric (10) |
| TE_PedidoTituloDuraEvento |  | si | VarChar (2555) |
| TE_PedidoPermConf |  | si | Domain:SINO |
| TE_PedidoStatusFact |  | si | VarChar (255) |
| TE_PedidoSubtotal |  | si | Numeric (10,2) |
| TE_PedidoIva |  | si | Numeric (10,2) |
| TE_PedidoTotalConIva |  | si | Numeric (10,2) |
| TE_PedidoCostoXNomina |  | si | Numeric (10,2) |
| TE_PedidoCreado |  | si | DateTime |
| TC_ResponsableId |  | si | Domain:autonumerico |
| TE_PedidoCreadoPor |  | si | VarChar |
| TE_PedidoModicado |  | si | DateTime |
| TE_PedidoModificadoPor |  | si | VarChar |
| TE_PedidoVersionVigente |  | si | Boolean |
| TC_SucursalPagId |  | si | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| TE_PedidoDes |  | si | Character (100) |
| TE_PedidoTipo |  | si | Domain:tipoPedido |
| TE_PedidoFecha |  | si | DateTime |
| TE_PedidoFeregistro |  | si | DateTime |
| TE_PedidoLugOtro |  | si | Boolean (100) |
| TE_PedidoOtroLugar |  | si | VarChar (100) |
| TE_PedidoLugOtroDire |  | si | Domain:Address, GeneXus |
| TE_PedidoMonto |  | si | Numeric (18,4) |
| TE_EventoIMG |  |  | Image (0) |
| TE_pedidoContarProcesados |  |  | (sin tipo explicito / heredado de dominio) |
| TE_Pedidoborrar |  | si | (sin tipo explicito / heredado de dominio) |
| TC_ResponsableNom |  |  | VarChar (150) |
| TE_PedidoTieneComplejidad |  |  | Numeric (4) |

## TE_Plazas
*Plazas empleados*  guid: `ab9c99de-53d9-19e1-17fc-9e0686121447`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_PlazasID | PK |  | Numeric (10) |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TE_EmpNombre |  |  | VarChar (70) |
| TE_EmpGenero |  |  | Domain:GeneroEmpleado |
| TE_EmpPorPuntualidad |  |  | Numeric (18,2) |
| TE_EmpStatus |  |  | Domain:Estatusempleado |
| TE_PlazasPago |  | si | Numeric (18,2) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TP_pago_default |  |  | Numeric (10,2) |
| TC_ReglaAsistId |  |  | Domain:autonumerico |
| TC_ReglaAsistDes |  |  | Domain:Des |
| TC_ReglaAsistMinAntEntr |  |  | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinAntSal |  |  | (sin tipo explicito / heredado de dominio) |
| TC_ReglaAsistMinDesEntr |  |  | (sin tipo explicito / heredado de dominio) |
| TC_UnidadNegID |  |  | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TC_SociedadID |  |  | Numeric (10) |
| TC_SociedadDes |  |  | VarChar (100) |
| TC_PuestosPorCerIni |  |  | Numeric (18,2) |
| TE_PlazasInicioVigencia |  | si | DateTime |
| TE_PlazasFinVigencia |  | si | DateTime |
| TE_PlazasVigente |  | si | Boolean (1) |
| TE_PlazasPrincipal |  | si | Domain:SINO |
| TE_PlazasModificado |  | si | DateTime |
| TC_PuestosDEsUnidadNegocio |  |  | VarChar (100) |

## TE_PlazasEnc
*Plazas*  guid: `e2dad99a-a664-4f25-807f-7609154fd785`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_plazasEncId | PK |  | Domain:autonumerico |
| TE_EmpIdEmpleadoEventual |  |  | Numeric (10) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TE_EmpStatus |  |  | Domain:Estatusempleado |
| TE_EmpGenero |  |  | Domain:GeneroEmpleado |
| TE_EmpPorPuntualidad |  |  | Numeric (18,2) |
| TE_plazasEnccontar |  |  | (sin tipo explicito / heredado de dominio) |
| ST_PuestosId |  |  | (sin tipo explicito / heredado de dominio) |
| TE_plazasEncplazasId | PK |  | Domain:ID |
| TE_plazasEncplazasPago |  |  | Numeric (10,2) |
| TE_plazasEncplazasFI |  |  | Date |
| TE_plazasEncplazasFF |  |  | Date |
| TE_plazasEncplazasVigente |  |  | Boolean |
| TE_plazasEncplazasPrincipal |  |  | Domain:SINO |
| TE_plazasEncplazasModificado |  |  | DateTime |
| TE_PlazasEncplazasEsPrincipal |  |  | Boolean |

## TE_PostVaCan
*Folios*  guid: `5a5e1259-c564-4db9-9c36-fd7e916e1a05`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_PubVacanteId | PK |  | Domain:autonumerico |
| TE_PostVaCanId |  |  | Domain:autonumerico [AUTONUMERICO] |
| TE_CandID | PK |  | Domain:autonumerico |
| TE_CandPorcCompl |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CandBorrar |  |  | Numeric (4) |
| TE_PostVaCanFecReg |  | si | DateTime |
| TE_VacanteId |  |  | Domain:autonumerico |
| TE_VacanteTitulo |  |  | VarChar (150) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_VacanteLigaPsi |  |  | Domain:Url, GeneXus |
| TE_PubVacanteFeIni |  |  | Date |
| TE_CandNumEmpleDO |  |  | Numeric (10) |
| TE_PubVacanteFEFin |  |  | Date |
| TE_PostVaCanResul |  | si | Domain:ResVacante |
| TE_PostVaCanFECie |  | si | DateTime |
| TE_CandNombre |  |  | VarChar (70) |
| TE_CandApPat |  |  | VarChar (70) |
| TE_CandApMat |  |  | VarChar (70) |
| TE_CandNomComp |  |  | VarChar (150) |
| TE_CandSexo |  |  | Domain:sexo |
| TE_CandEdoCiv |  |  | Domain:Estadocivil |
| TE_CandEdad |  |  | (sin tipo explicito / heredado de dominio) |
| TE_CandUltGraEst |  |  | Domain:Escolaridad |
| TE_PostVaCanAsis |  | si | Boolean |
| TE_PostVaCanDocComp |  | si | Boolean |
| TE_PostVaCanEstatus |  | si | Domain:EstatusCita |
| TE_PostVaCanConti |  | si | Boolean |
| TE_PostVaCanContiObser |  | si | LongVarChar |
| TE_PostVaCanDocPsico |  | si | Blob |
| TE_PostVaCanDocPsicoObs |  | si | LongVarChar |
| TE_PostVaCanEntrevista |  | si | LongVarChar |
| TE_CurInduccId |  | si | Domain:autonumerico |
| TE_CurInduccDes |  |  | VarChar (150) |
| TE_CurInduccFeHr |  |  | Date (8) |
| TE_CurInduccCitaCur |  |  | Domain:HraGpo |
| TE_PostVaCanAsisCurInducc |  | si | Boolean |
| TE_PostVaCanCalifCurInducc |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PostVaCanObserCurInducc |  | si | LongVarChar |
| TE_EvePrueId |  | si | Domain:autonumerico |
| TE_PostVaCanAsisEvePrue |  | si | Boolean |
| TE_PostVaCanCalifEvePrue |  | si | (sin tipo explicito / heredado de dominio) |
| TE_PostVaCanObserEvePrue |  | si | LongVarChar |
| TE_PostVaCanTieneGpo |  |  | Boolean |
| TE_PostVaCanFechaGrupo |  |  | VarChar (10) |
| TE_PostVaCanHoraCitaGrupo |  |  | VarChar (10) |
| TC_PuestosCiclopago |  |  | Domain:ciclopago |
| TC_PuestosRegPag |  |  | Domain:regimenpago |
| TC_SucursalPagId |  |  | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| TC_PuestosId |  |  | Numeric (10) |

## TE_PubVacante
*Publicación vacantes*  guid: `15b85589-3234-4fa5-85e1-abbed3cc66b1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_PubVacanteId | PK |  | Domain:autonumerico |
| TE_VacanteId |  |  | Domain:autonumerico |
| TE_VacanteTitulo |  |  | VarChar (150) |
| TE_VacanteFun |  |  | LongVarChar (2097152) |
| TE_VacanteImagen |  |  | Image |
| TE_VacanteReq |  |  | LongVarChar (2097152) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_VacanteLigaPsi |  |  | Domain:Url, GeneXus |
| TE_VacanteCodigo |  |  | VarChar (40) |
| TE_VacanteREqExp |  |  | Boolean |
| TE_VacanteREqIngles |  |  | Boolean |
| TE_PubVacanteFeIni |  | si | Date |
| TE_PubVacanteFEFin |  | si | Date |
| TE_PubVacantePost |  |  | Numeric (10) |
| TE_PubVacanteGpos |  |  | Numeric (10) |
| TE_PubVacanteActiva |  |  | Boolean |

## TE_Puente
*Puente detalle Puestos*  guid: `e961dc53-11be-46a8-83e1-4422d5af47ba`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_PuenteiD | PK |  | (sin tipo explicito / heredado de dominio) [AUTONUMERICO] |
| TE_PedidoID |  |  | Numeric (10) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TE_PuenteBloq |  | si | VarChar (10) |
| TC_ProductosId |  |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TP_ProductosSubCategoria |  |  | VarChar (40) |
| TE_PuenteDesProdPedido |  |  | VarChar (225) |
| TP_ProductosTituloCompleto |  |  | VarChar (150) |
| TE_PuenteC1 |  | si | VarChar (11) |
| TE_PuenteNp1 |  | si | Numeric (10) |
| TE_PuenteC2 |  | si | VarChar (11) |
| TE_PuenteNp2 |  | si | Numeric (10) |
| TE_PuenteC3 |  | si | VarChar (11) |
| TE_PuenteNp3 |  | si | Numeric (10) |
| TE_PuenteC4 |  | si | VarChar (11) |
| TE_PuenteNp4 |  | si | Numeric (10) |
| TE_PuenteC5 |  | si | VarChar (11) |
| TE_PuenteNp5 |  | si | Numeric (10) |
| TE_PuenteC6 |  | si | VarChar (11) |
| TE_PuenteNp6 |  | si | Numeric (10) |
| TE_Puentec7 |  | si | VarChar (11) |
| TE_PuenteNp7 |  | si | Numeric (10) |
| TE_Puentec8 |  | si | VarChar (11) |
| TE_PuenteNp8 |  | si | Numeric (10) |
| TE_Puentec9 |  | si | VarChar (11) |
| TE_PuenteNp9 |  | si | Numeric (10) |
| TE_Puentec10 |  | si | VarChar (11) |
| TE_PuenteNp10 |  | si | Numeric (10) |
| TE_Puentec11 |  | si | VarChar (11) |
| TE_PuenteNp11 |  | si | (10) |
| TE_Puentec12 |  | si | VarChar (11) |
| TE_PuenteNp12 |  | si | (10) |
| TE_Puentec13 |  | si | VarChar (11) |
| TE_PuenteNp13 |  | si | (10) |
| TE_Puentec14 |  | si | VarChar (11) |
| TE_PuenteNp14 |  | si | (10) |
| TE_Puentec15 |  | si | VarChar (11) |
| TE_PuenteNp15 |  | si | (10) |
| TE_Puentec16 |  | si | VarChar (11) |
| TE_PuenteNp16 |  | si | (10) |
| TE_Puentec17 |  | si | VarChar (11) |
| TE_PuenteNp17 |  | si | (10) |
| TE_Puentec18 |  | si | VarChar (11) |
| TE_PuenteNp18 |  | si | (10) |
| TE_Puentec19 |  | si | VarChar (11) |
| TE_PuenteNp19 |  | si | (10) |
| TE_Puentec20 |  | si | VarChar (11) |
| TE_PuenteNp20 |  | si | (10) |
| TE_Puentec21 |  | si | VarChar (11) |
| TE_PuenteNp21 |  | si | (10) |
| TE_Puentec22 |  | si | VarChar (11) |
| TE_PuenteNp22 |  | si | (10) |
| TE_Puentec23 |  | si | VarChar (11) |
| TE_PuenteNp23 |  | si | (10) |
| TE_Puentec24 |  | si | VarChar (11) |
| TE_PuenteNp24 |  | si | (10) |
| TE_Puentec25 |  | si | VarChar (11) |
| TE_PuenteNp25 |  | si | (10) |
| TE_Puentec26 |  | si | VarChar (11) |
| TE_PuenteNp26 |  | si | (10) |
| TE_Puentec27 |  | si | VarChar (11) |
| TE_PuenteNp27 |  | si | (10) |
| TE_Puentec28 |  | si | VarChar (11) |
| TE_PuenteNp28 |  | si | (10) |
| TE_Puentec29 |  | si | VarChar (11) |
| TE_PuenteNp29 |  | si | (10) |
| TE_Puentec30 |  | si | VarChar (11) |
| TE_PuenteNp30 |  | si | (10) |
| TE_Puentec31 |  | si | VarChar (11) |
| TE_PuenteNp31 |  | si | (10) |
| TE_Puentec32 |  | si | VarChar (11) |
| TE_PuenteNp32 |  | si | (10) |
| TE_Puentec33 |  | si | VarChar (11) |
| TE_PuenteNp33 |  | si | (10) |
| TE_Puentec34 |  | si | VarChar (11) |
| TE_PuenteNp34 |  | si | (10) |
| TE_Puentec35 |  | si | VarChar (11) |
| TE_PuenteNp35 |  | si | (10) |
| TE_Puentec36 |  | si | VarChar (11) |
| TE_PuenteNp36 |  | si | (10) |
| TE_Puentec37 |  | si | VarChar (11) |
| TE_PuenteNp37 |  | si | (10) |
| TE_Puentec38 |  | si | VarChar (11) |
| TE_PuenteNp38 |  | si | (10) |
| TE_Puentec39 |  | si | VarChar (11) |
| TE_PuenteNp39 |  | si | (10) |
| TE_Puentec40 |  | si | VarChar (11) |
| TE_PuenteNp40 |  | si | (10) |
| TE_Puentec41 |  | si | VarChar (11) |
| TE_PuenteNp41 |  | si | (10) |
| TE_Puentec42 |  | si | VarChar (11) |
| TE_PuenteNp42 |  | si | (10) |
| TE_Puentec43 |  | si | VarChar (11) |
| TE_PuenteNp43 |  | si | (10) |
| TE_Puentec44 |  | si | VarChar (11) |
| TE_PuenteNp44 |  | si | (10) |
| TE_Puentec45 |  | si | VarChar (11) |
| TE_PuenteNp45 |  | si | (10) |
| TE_Puentec46 |  | si | VarChar (11) |
| TE_PuenteNp46 |  | si | (10) |
| TE_Puentec47 |  | si | VarChar (11) |
| TE_PuenteNp47 |  | si | (10) |
| TE_Puentec48 |  | si | VarChar (11) |
| TE_PuenteNp48 |  | si | (10) |
| TE_Puentec49 |  | si | VarChar (11) |
| TE_PuenteNp49 |  | si | (10) |
| TE_Puentec50 |  | si | VarChar (11) |
| TE_PuenteNp50 |  | si | (10) |
| TE_PuenteTipo |  | si | VarChar |

## TE_RegistroBiometrico
*Registro de asistencias automaticas*  guid: `64122934-a315-4f8d-932b-0fd37dee6714`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_RegistroBiometricoId | PK |  | Domain:autonumerico |
| TE_RegistroBiometricoFH |  | si | DateTime |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TC_EstacionNACSID |  | si | Domain:ID [AUTONUMERICO] |
| TC_EstacionNACSEStacion |  |  | Domain:Des |
| TC_InmuebleID |  |  | Domain:inmuebles [AUTONUMERICO] |
| TC_InmuebleDes |  |  | Character (100) |

## TE_RegistroNACS
*TE_Registro NACS*  guid: `46d369ef-1a69-4a88-81b4-a6c7e9fdeeaf`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_RegistroNACSID | PK |  | Domain:ID |
| TE_EMpleadoID |  |  | Domain:ID |
| TE_RegistroNACS |  |  | (sin tipo explicito / heredado de dominio) |

## TE_ReqPer
*Requisición de personal*  guid: `ba22e2b2-6f3a-4ea6-aa83-fa5557aa0240`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ReqPerId | PK |  | Domain:autonumerico [AUTONUMERICO] |
| TE_ReqPerFecha |  | si | Date |
| TC_ResponsableId |  | si | Domain:autonumerico |
| TC_ResponsableDEs |  | si | Domain:Des |
| TE_ReqPerEstatus |  | si | Domain:EstatusrequiPer |
| TE_ReqPerUserId |  | si | Domain:GAMUserIdentification |
| TC_PuestosId |  | si | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_ReqPerNomjefeInm |  | si | VarChar (100) |
| TE_ReqPerCantElem |  | si | (sin tipo explicito / heredado de dominio) |
| TE_ReqPerArea |  | si | VarChar |
| TE_ReqPerDepto |  | si | VarChar (100) |
| TC_UnidadNegID |  |  | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TE_ReqPerDesPuesto |  | si | Boolean |
| TE_ReqPerDesPuestoedad |  | si | (sin tipo explicito / heredado de dominio) |
| TE_ReqPerdesPuestoSexo |  | si | Domain:SexoReqPer |
| TE_ReqPerDesPuestoEsco |  | si | Domain:Escolaridad |
| TE_ReqPerDesPuestoIdio |  | si | VarChar |
| TE_ReqPerDesPuestoViajar |  | si | Domain:SINO |
| TE_ReqPerDesPuestoLicCon |  | si | Domain:SINO |
| TE_ReqPerDesPuestoExp |  | si | Domain:SINO |
| TE_ReqPerDesPuestoConTec |  | si | LongVarChar |
| TE_ReqPerDesPuestoObj |  | si | LongVarChar |
| TE_ReqPerDesPuestoAct |  | si | LongVarChar |
| TE_ReqPerdetalleCant | PK |  | (sin tipo explicito / heredado de dominio) |
| TE_ReqPerdetalleIdent |  |  | Domain:SexoReqPer |
| TE_ReqPerdetalleFecha |  |  | Date |

## TE_Reserva
*Reservaciones*  guid: `4fc9cafd-a1fa-41b3-ac13-815badcebd2e`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ReservaId | PK |  | Domain:autonumerico |
| TE_pedDetId |  |  | Numeric (10) |
| TE_EmpleadosId |  |  | Numeric (8) |
| TE_EmpleadosNomcomp |  |  | VarChar (150) |
| TE_EmpleadosNum |  |  | Numeric (10) |
| TE_ReservaConFFor |  |  | Boolean |
| TE_ReservaTipo |  |  | Domain:conFreserva |
| TE_ReservaEstatus |  |  | Domain:Esrtatusreser |
| TE_ReservaAsis |  | si | Boolean |
| TE_ReservaRetardo |  | si | Boolean |
| TE_ReservaFalta |  | si | Boolean |
| TE_ReservaFAsit |  |  | DateTime |
| TE_ReservaFsali |  |  | DateTime |
| TE_ReservaObserv |  | si | LongVarChar |

## TE_Reservacion
*TE_Reservacion*  guid: `846604d7-5281-30f0-5a92-724dd4e721d8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_ReservacionID | PK |  | Numeric (9) |
| TE_ReservacionTitulo |  | si | VarChar (255) |
| TE_EmpIdEmpleadoEventual |  | si | Numeric (10) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TE_EmpleadoBusXNombre |  |  | VarChar (240) |
| TE_EmpleadoNombreCompleto |  |  | VarChar (120) |
| TE_EmpCorreo_Electronico |  |  | VarChar (70) |
| TE_EmpPorPuntualidad |  |  | Numeric (18,2) |
| TE_EmpRegPago |  |  | Domain:regimendepago |
| TC_bancosNombre |  |  | VarChar (100) |
| TE_EmpCuenta_Banco |  |  | VarChar (40) |
| TC_EmpresaPagadoraId |  |  | Numeric (4) |
| TC_EmpresaPagadoraNombre |  |  | VarChar (150) |
| TE_ReservacionPorcentajePuntualidad |  | si | Numeric (18,4) |
| TE_pedDetId |  | si | Numeric (10) |
| TE_PeddetCancelar |  |  | Domain:SINO |
| TE_PedidoID |  |  | Numeric (10) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TC_PepPep |  |  | VarChar (100) |
| TC_Pepdes |  |  | Character (100) |
| TC_SucursalPagId |  |  | Domain:ID |
| TC_SucursalPagDes |  |  | Domain:Des |
| TE_pedDetTurnos |  |  | Numeric (18,2) |
| TE_pedDetCompSim |  |  | Domain:SINO |
| TC_PresenProdDes |  |  | Domain:Des |
| TC_ProductosId |  |  | Numeric (10) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosFalta |  |  | Numeric (10,2) |
| TC_PuestosRetardo |  |  | Numeric (10,2) |
| TC_Puestosmatri |  |  | Boolean |
| TE_PeddetBloqueNum |  |  | VarChar (12) |
| TC_FaseEventoID |  |  | Domain:ID |
| TC_FaseEventoDEs |  |  | Domain:Des |
| TE_PeddetFechacitaJunta |  |  | DateTime |
| TE_PeddetFechacitaFin |  |  | VarChar (15) |
| TE_PeddetFechafincitaoculta |  |  | DateTime |
| TC_PuestosHrasAntesCanPed |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PedidoDuracionDias |  |  | (sin tipo explicito / heredado de dominio) |
| TC_complejoid |  |  | Domain:ID |
| ST_UnidadNegPedId |  |  | (sin tipo explicito / heredado de dominio) |
| ST_UnidadNegPedDes |  |  | (sin tipo explicito / heredado de dominio) |
| TC_UnidadNegID |  |  | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TC_SociedadesPagadorasID |  |  | Domain:ID |
| TC_SociedadesPagadorasDes |  |  | VarChar (120) |
| TC_SociedadID |  |  | Numeric (10) |
| TC_SociedadDes |  |  | VarChar (100) |
| TE_PeddetProductoTitulo |  |  | VarChar (150) |
| TE_ReservacionIdPedido |  | si | Numeric (9) |
| TE_ReservacionStatus |  | si | Domain:EstatusReser |
| TE_ReservacionCitaInicio |  | si | DateTime |
| TE_ReservacionCitaFin |  | si | DateTime |
| TE_ReservacionTipo |  | si | Domain:TipoReservacion |
| TE_ReservacionHoraEntradaAsistencia |  | si | DateTime |
| TE_ReservacionHoraSalidaAsistencia |  | si | DateTime |
| TE_ReservacionEstadoAsistencia |  | si | Domain:EstadoAsistencia |
| TE_ReservacionMedioAsistencia |  | si | VarChar (255) |
| TE_ReservacionPagoPorTurno |  | si | Numeric (18,4) |
| TE_ReservacionPagoProgramado |  | si | Numeric (18,4) |
| TE_ReservacionPagoReal |  | si | Numeric (18,4) |
| TE_ReservacionPeriodoAsistencia |  | si | Numeric (9) |
| TE_ReservPeriodoCobrado |  | si | Numeric (9) |
| TE_ReservacionAnioCobrado |  | si | Numeric (9) |
| TE_ReservacionDuracionEnTurnos |  | si | Numeric (18,6) |
| TE_ReservacionIdProductoEvento |  | si | Numeric (9) |
| TE_ReservacionIdPuestoEvento |  | si | Numeric (9) |
| TE_ReservacionFormaDePago |  | si | VarChar (255) |
| TE_ReservacionBloque |  | si | Numeric (9) |
| TE_ReservacionSeriado |  | si | VarChar (255) |
| TE_ReservacionUnidadDeNegocio |  | si | VarChar (255) |
| TE_ReservacionSociedad |  | si | VarChar (255) |
| TE_ReservacionObservaciones |  | si | LongVarChar (8) |
| TE_ReservacionIP |  | si | VarChar (255) |
| TE_ReservIacionTimescanEntrada |  | si | Numeric (9) |
| TE_ReservacionIdTimescanSalida |  | si | Numeric (9) |
| TE_ReservacionEstacionEntrada |  | si | VarChar (255) |
| TE_ReservacionEstacionSalida |  | si | VarChar (255) |
| TE_ReservacionPenalizacionSueldo |  | si | Numeric (18,4) |
| TE_ReservacionPenalizacionDias |  | si | Numeric (18,4) |
| TE_ReservacionReglaAplicada |  | si | Numeric (4) |
| TE_ReservacionTipoRegistroTimeScan |  | si | VarChar (255) |
| TE_ReservacionCreado |  | si | DateTime |
| TE_ReservacionCreadoPor |  | si | VarChar (255) |
| TE_ReservacionModificado |  | si | DateTime |
| TE_ReservacionModificadoPor |  | si | VarChar (255) |
| TE_ReservacionFolioHonorarios |  | si | VarChar (255) |
| TE_ReservacionIdReservacion_Lobo |  | si | Numeric (9) |
| TE_ReservacionEnvioCorreoEmpalmes |  | si | Numeric (1) |
| TE_ReservaciontpIdPlaza |  | si | Numeric (9) |
| TE_ReservacionSaldoVencido |  | si | Numeric (1) |
| TE_ReservacionIdPagoHonorario |  | si | Numeric (9) |
| TE_ReservacionIdPagoHonorario_Lista |  | si | (sin tipo explicito / heredado de dominio) |
| TE_ReservacionSinPlazaParaPago |  | si | Numeric (1) |
| TE_ReservacionCampo0 |  | si | Numeric (9) |
| TE_ReservacionBorrar |  | si | (sin tipo explicito / heredado de dominio) |
| TE_ReservacionHoraReservacion |  | si | DateTime |
| TE_ReservacionEstatusPago |  | si | Boolean |

## TE_SegCan
*Seguimiento Candidatos*  guid: `4c13a28f-c033-4f5e-aac9-9d513d6cdea0`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_SegCanId | PK |  | Domain:ID |
| TC_SegMovCanId |  |  | Domain:ID |
| TC_SegMovCanDes |  |  | VarChar (100) |
| TE_CandID |  |  | Domain:autonumerico |
| TE_CandNomComp |  |  | VarChar (150) |
| TE_SegCanFecha |  |  | DateTime |
| TE_SegCanObser |  |  | LongVarChar |

## TE_Vacante
*Catálogo de vacantes*  guid: `3d89d9d2-4a71-44a9-bce6-5e51073369a0`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_VacanteId | PK |  | Domain:autonumerico |
| TE_VacanteTitulo |  | si | VarChar (150) |
| TE_VacanteFun |  | si | LongVarChar (2097152) |
| TE_VacanteReq |  | si | LongVarChar (2097152) |
| TC_PuestosId |  | si | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_VacanteImagen |  | si | Image |
| TE_VacanteLigaPsi |  | si | Domain:Url, GeneXus |
| TE_VacanteCtitulo |  | si | VarChar (50) |
| TE_VacanteCCuer |  | si | LongVarChar |
| TE_VacanteCIma |  | si | Image |
| TE_VacanteCtaDoc |  | si | (sin tipo explicito / heredado de dominio) |
| TE_VacanteREqIngles |  | si | Boolean |
| TE_VacanteREqExp |  | si | Boolean |
| TE_VacanteCodigo |  | si | VarChar (40) |

## TE_plazasDet
*Plazas detalle*  guid: `37d86cbf-edb9-42eb-9304-cf1665d84b3a`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_plazasEncId | PK |  | Domain:autonumerico |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TE_plazasDetPago |  | si | Numeric (10,2) |
| TE_plazasDetFechaIni |  | si | Date |
| TE_plazasDetFechaFin |  | si | Date |
| TE_plazasDetVigente |  | si | Boolean |
| TE_plazasDetPrincipal |  | si | Domain:SINO |
| TE_plazasDetModificado |  | si | DateTime |

## TL_AltasBajas
*TL_Altas Bajas*  guid: `8b278a42-0db6-4a04-83ae-cf07bdeb99d3`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_AltasBajasID | PK |  | Domain:ID |
| TL_AltasBajasNoEmpleado |  |  | Numeric |
| TL_AltasBajasNombreEmp |  |  | VarChar (80) |
| TL_AltasBajasFechaHora |  |  | DateTime |
| TL_AltasBajasDeEstado |  |  | VarChar (10) |
| TL_AltasBajasAestado |  |  | VarChar |
| TL_AltasBajasUsuario |  |  | VarChar (15) |
| TL_AltasBajasObservacion |  |  | VarChar (300) |

## TL_CierreNomina
*TL_Cierre Nomina*  guid: `bc3e27ea-f500-4503-81a1-46b0f4fe94c1`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_CierreNominaID | PK |  | Domain:ID |
| TC_PeriodoID |  |  | Domain:ID |
| TL_CierreNominaPaso |  |  | VarChar |
| TL_CierreNominaFechaHora |  |  | DateTime |

## TL_DetalleOperacion
*Detalle operación*  guid: `2be4d472-c5ad-45c9-863b-08c3811839f8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_DetalleOperacionId | PK |  | Domain:ID [AUTONUMERICO] |
| TL_DetalleOperacionFecha |  | si | DateTime |
| TL_DetalleOperacionModulo |  | si | VarChar |
| TL_DetalleOperacionAntes |  | si | LongVarChar |
| TL_DetalleOperacionDespues |  | si | LongVarChar |
| TL_DetalleOperacionIdRegistro |  | si | Numeric (10) |
| TL_DetalleOperacionUsuario |  | si | VarChar |
| TL_DetalleOperacionFormulario |  | si | VarChar |

## TL_Modulos
*Movimientos de modulos*  guid: `67efc8ee-603c-41b6-afa0-7d3d6969ef89`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_ModulosId | PK |  | Domain:autonumerico |
| TL_ModulosModulo |  | si | VarChar (100) |
| TL_ModulosModuloId |  | si | Numeric (4) |
| TL_ModulosFormulario |  | si | VarChar (100) |
| TL_ModulosOperacion |  | si | VarChar (100) |
| TL_ModulosAtributo |  | si | VarChar (100) |
| TL_ModulosValorInicial |  | si | VarChar |
| TL_ModulosValorFinal |  | si | VarChar |
| TL_ModulosFechaMovimiento |  | si | DateTime |
| TL_ModulosUsuario |  | si | VarChar |
| TL_ModulosBorrar |  | si | (sin tipo explicito / heredado de dominio) |

## TL_Movempleados
*Movientos empleados*  guid: `d3af11d3-84b9-473f-b677-267da05164d6`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_MovempleadosId | PK |  | Domain:autonumerico |
| TL_MovempleadosFecha |  |  | DateTime |
| TL_MovempleadosTotalProceso |  | si | (sin tipo explicito / heredado de dominio) |
| TL_MovempleadosTotalProcesados |  | si | (sin tipo explicito / heredado de dominio) |
| TL_MovempleadosEstatus |  |  | Boolean |
| TL_MovempleadosUsuario |  | si | VarChar |

## TL_MovempleadosDet
*Detalle de movientos de empleados*  guid: `fc0411de-15cf-4917-8166-f351c57469ea`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_MovempleadosId | PK |  | Domain:autonumerico |
| TL_MovempleadosDetNumEmp |  | si | Numeric (9) |
| TE_EmpleadoBuscar |  |  | VarChar (150) |
| TL_MovempleadosDetEstatusEmp |  | si | Domain:logempleado |
| TL_MovempleadosDetCandidato | PK |  | Numeric (10) |
| TL_MovempleadosDetCandidatoNom |  | si | VarChar (170) |

## TL_RegistroModulos
*Acciones modulos*  guid: `efd24a51-3fc8-4ec4-aaa3-e963235c7469`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TL_RegistroModulosId | PK |  | Numeric (10) [AUTONUMERICO] |
| TL_RegistroModulosModulo |  | si | VarChar |
| TL_RegistroModulosModo |  | si | VarChar (3) |
| TL_RegistroModulosFecha |  | si | DateTime |
| TL_RegistroModulosUser |  | si | VarChar |
| TL_RegistroModulosIdRegistro |  | si | (10) |

## TP_Ambiente
*Parámetros*  guid: `ba3a0824-c6db-443b-bf93-f81e3a9961c8`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_AmbienteId | PK |  | Domain:ID |
| TP_AmbienteSrvDB |  | si | VarChar (100) |
| TP_AmbienteSrvIIS |  | si | VarChar (100) |
| TP_AmbienteSrvCorreo |  | si | VarChar (100) |
| TP_AmbienteUserCorreo |  | si | VarChar (100) |
| TP_AmbientePassCorreo |  | si | VarChar (100) |
| TP_AmbientePuertoCorreo |  | si | (sin tipo explicito / heredado de dominio) |
| TP_AmbienteUrlLogin |  | si | Domain:Url, GeneXus |
| TP_AmbienteUrlAyuda |  | si | Domain:Url, GeneXus |
| TP_AmbienteAvisodePrivacidad |  | si | LongVarChar |
| TP_AmbienteTerminosYCondi |  | si | LongVarChar |
| TP_AmbienteSoporte |  | si | Domain:Email, GeneXus |
| TP_AmbienteRespAdmPer |  | si | VarChar (160) |
| TP_AmbienteEmailRespAdmPer |  | si | Domain:Email, GeneXus |
| TP_AmbientePassEmailAdmPer |  |  | VarChar |
| TP_AmbienteRespReclu |  | si | VarChar (150) |
| TP_AmbienteEmailReclu |  | si | Domain:Email, GeneXus |
| TP_AmbientePassRespReclu |  | si | VarChar |

## TP_ClaveExamen
*Claves de puestos*  guid: `d7c350f4-be91-4f3a-9720-b30d4406be84`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ClaveExamenId | PK |  | Domain:ID [AUTONUMERICO] |
| TC_PuestosId |  | si | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TP_ClaveExamenUrl |  | si | Domain:Url, GeneXus |
| TP_ClaveExamenVigente |  | si | Boolean |
| TP_ClaveExamenClave |  | si | VarChar |

## TP_CombSucUN
*TP_Comb Suc UN*  guid: `a6a6fe46-c425-4144-9772-8fb5bdb4bc61`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_UniversoKEY | PK |  | VarChar (40) |

## TP_Duracion
*Duración*  guid: `80335f2a-6a1e-4a59-8651-2a30113e5c52`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_DuracionId | PK |  | Domain:ID |
| TP_DuracionDesc |  | si | VarChar (150) |

## TP_DuracionDet
*Duración detalle*  guid: `bd4aa8b8-2d9e-4786-84ac-b62fb5e99f61`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_DuracionDetId | PK |  | Domain:ID |
| TP_DuracionId | PK |  | Domain:ID |
| TP_DuracionDesc |  |  | VarChar (150) |
| TP_DuracionDetMinDias |  | si | (sin tipo explicito / heredado de dominio) |
| TP_DuracionDetMaxDias |  | si | (sin tipo explicito / heredado de dominio) |
| TP_DuracionDetFacPago |  | si | (sin tipo explicito / heredado de dominio) |
| TP_DuracionDetProrrateado |  | si | Boolean |
| TP_DuracionDetDivProrra |  | si | (sin tipo explicito / heredado de dominio) |

## TP_Generales
*Parámentros generales*  guid: `a91958d1-adbc-4c13-a103-6e94530828b9`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_GeneralesId | PK |  | Domain:ID [AUTONUMERICO] |
| TP_GeneralesUrl |  | si | Domain:Url, GeneXus |
| TP_GeneralesEmail |  | si | Domain:Email, GeneXus |
| TP_GeneralesServerEmail |  | si | Domain:Email, GeneXus |

## TP_ImpHonoAsim
*Impuestos honorarios asimilables*  guid: `f5e85c53-7f1d-45ad-bd90-e389e2e59dac`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ImpHonoAsimId | PK |  | Domain:autonumerico |
| TP_ImpHonoAsimTipo |  | si | VarChar (100) |
| TP_ImpHonoAsimLimInf |  | si | Numeric (18,4) |
| TP_ImpHonoAsimLimSup |  | si | Numeric (18,4) |
| TP_ImpHonoAsimFija |  | si | Numeric (10,4) |
| TP_ImpHonoAsimPorcentaje |  | si | Numeric (10,4) |
| TP_ImpHonoAsimActivo |  | si | Numeric |
| TP_ImpHonoAsimPeriodoIni |  | si | VarChar (20) |
| TP_ImpHonoAsimPeriodoFin |  | si | VarChar (20) |

## TP_Pensiones
*TP_Pensiones*  guid: `dd831c9f-dd71-4352-84f8-5eccf07b30af`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_PensionesID | PK |  | Domain:ID |
| TP_Pensiones |  |  | (sin tipo explicito / heredado de dominio) |
| TP_PensionesEmpleado |  |  | VarChar (100) |
| TP_PensionesBeneficiario |  |  | VarChar (100) |
| TP_PensionesNumEMpleado |  |  | Numeric (8) |
| TP_PensionesNumeroCuenta |  |  | VarChar (20) |
| TC_bancosID |  | si | Domain:autonumerico |
| TC_bancosNombre |  |  | VarChar (100) |
| TP_PensionesPorcenyaje |  | si | Numeric (5,2) |

## TP_Periodos
*TP_Periodos*  guid: `c39e0cec-5791-5ef7-5fbf-2f68e0bdfe64`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_PeriodosID | PK |  | Numeric (10) |
| TP_PeriodosFecInicio |  | si | DateTime |
| TP_PeriodosFecFin |  | si | DateTime |
| TP_PeriodosActual |  | si | Boolean (1) |
| TP_PeriodosAnterior |  | si | Numeric (4) |

## TP_Precios
*TP_Precios*  guid: `6b8fcf45-4365-40ac-b43f-96f23c5a7255`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_PreciosId | PK |  | Domain:ID |
| TC_ProductosId |  | si | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TC_PuestosId |  |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TP_PreciosPrecios |  | si | (10,2) |
| TP_PreciosVigente |  | si | Boolean |

## TP_PreciosProductos
*TP_Precios Productos*  guid: `81b032c5-4ef0-4cd2-99fe-6492b9e53021`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_PreciosProductosID | PK |  | Domain:ID |
| TC_ProductosId |  | si | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TP_PreciosProductosPrecio |  | si | Numeric (10,2) |
| TP_PreciosProductosFechaIncial |  | si | Date |
| TP_PreciosProductosFechaFinal |  | si | Date |
| TP_PreciosProductosVigencia |  | si | Boolean |
| TP_PreciosProductosCreadoPor |  | si | VarChar (40) |
| TP_PreciosProductosCreado |  | si | DateTime |
| TP_PreciosProductosModificadoPor |  | si | VarChar |
| TP_PreciosProductosModificado |  | si | DateTime |
| TP_PreciosProductosUniNeg |  | si | (10) |
| TP_PreciosProductosPuestoId |  | si | Numeric (10) |
| TP_PreciosProductosPuestoDes |  | si | VarChar (100) |

## TP_ProdcutosOperativo
*Productos Operativos*  guid: `2e7ca91c-0221-4b03-b3ea-d5b75d8a7aa6`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ProdcutosOperativoId | PK |  | Domain:autonumerico |
| TP_ProdcutosOperativoIdProd |  | si | Numeric (10) |
| TP_ProdcutosOperativoProdDes |  | si | VarChar (150) |
| TP_ProdcutosOperativoUnidadNego |  | si | Numeric (10) |
| TP_ProdcutosOperativoTieneFase |  | si | VarChar (2) |
| TP_ProdcutosOperativoPuesto |  | si | Domain:ID |
| TP_ProdcutosOperativoPuestoCerteza |  | si | Numeric (10,2) |
| TP_ProdcutosOperativoSexo |  | si | VarChar (2) |

## TP_ProductoSimi
*TP_Producto Simi*  guid: `33b4671a-c0b7-268c-8126-65c2b89d74e3`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| IdProducto | PK |  | Numeric (9) |
| IdProductoSimi |  |  | Numeric (9) |

## TP_ProductosStaff
*Productos Staff*  guid: `f80035e9-0003-497f-a4b7-84663eba4618`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ProductosStaffId | PK |  | Domain:autonumerico |
| TP_ProductosStaffIdprod |  | si | Numeric (10) |
| TP_ProductosStaffProddDes |  | si | VarChar (150) |
| TP_ProductosStaffUnidadNego |  | si | Numeric (10) |
| TP_ProductosStaffComplejidad |  | si | Numeric (10) |
| TP_ProductosStaffPuesto |  | si | Domain:ID |
| TP_ProductosStaffPuestoCerteza |  | si | Numeric (10,2) |
| TP_ProductosStaffSexo |  | si | VarChar (2) |

## TP_ReglasAsistTimeScan
*TP_Reglas Asist Time Scan*  guid: `c7b1d4c6-c98e-48aa-a7ff-03ff0551a279`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ReglasAsistTimeScanID | PK |  | Domain:ID |
| TP_ReglasAsistTimeScanTitulo |  | si | VarChar |
| TP_ReglasAsistTimeScanMinAntesEntrada |  | si | (sin tipo explicito / heredado de dominio) |
| TP_ReglasAsistTimeScanMinDespuesEntrada |  | si | (sin tipo explicito / heredado de dominio) |
| TP_ReglasAsistTimeScanMinutosParaRetardo |  | si | (sin tipo explicito / heredado de dominio) |
| TP_ReglasAsistTimeScanMinDespuesSalida |  | si | (sin tipo explicito / heredado de dominio) |

## TP_ReglasConfirmacion
*Reglas de confirmación*  guid: `618806c5-09ed-479d-832a-f00b87cb17a7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_ReglasConfirmacionId | PK |  | Domain:ID [AUTONUMERICO] |
| TP_ReglasConfirmacionTitulo |  | si | VarChar (200) |
| TP_ReglasConfirmacionNormal |  | si | Boolean |
| TP_ReglasConfirmacionForzado |  | si | Boolean |
| TP_ReglasConfirmacionPreasignado |  | si | Boolean |
| TP_ReglasConfirmacionDescripcion |  | si | VarChar (200) |
| TP_ReglasConfirmacionTipodeRegla |  | si | VarChar |
| TP_ReglasConfirmacionBorrar |  |  | (sin tipo explicito / heredado de dominio) |

## TP_SueldoMatriciales
*Sueldos Matriciales*  guid: `d99a9e44-90cc-2c89-4d47-a012d9bae9a2`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| Iddos | PK |  | (10) |
| TP_SueldoMatricialIdPuesto |  | si | Numeric (9) |
| Titulo |  | si | VarChar (255) |
| TP_SueldoMatricialIdPuestoCatalogo |  | si | Numeric (9) |
| TP_SueldoMatricialIdTipoComplejidad |  | si | Numeric (9) |
| TP_SueldoMatricialIdTipoComplejidadCatalogo |  | si | Numeric (9) |
| TP_SueldoMatricialIdTipoDuracion |  | si | Numeric (9) |
| TP_SueldoMatricialIdTipoDuracionCatalogo |  | si | Numeric (9) |
| TP_SueldoMatricialFase_de_Evento |  | si | VarChar (255) |
| TP_SueldoMatricialSueldo_Base |  | si | Numeric (18,6) |
| TP_SueldoMatricialFecha_Inicio |  | si | DateTime |
| TP_SueldoMatricialFecha_Fin |  | si | DateTime |
| TP_SueldoMatricialActivo |  | si | Numeric (1) |
| tp_IdDOS |  | si | Numeric (9) |
| TP_SueldoMatricialesBorrar |  | si | (sin tipo explicito / heredado de dominio) |

## TP_TipoDuracion
*Tipo duración del evento*  guid: `a6ebaec8-48b7-40c5-a0da-26bcfdc5600d`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_TipoDuracionId | PK |  | Domain:ID |
| TP_TipoDuracionLimInf |  |  | (sin tipo explicito / heredado de dominio) |
| TP_TipoDuracionLimSup |  |  | (sin tipo explicito / heredado de dominio) |
| TP_TipoDuracionPorcentaje1 |  |  | (10,2) |
| TP_TipoDuracionPorcentaje2 |  |  | (10,2) |
| TP_TipoDuracionPorcentaje3 |  |  | Numeric (10,2) |
| TP_TipoDuracionPorcentaje4 |  |  | Numeric (10,2) |

## TP_Universo
*Universo de registros*  guid: `196b39c7-affa-40e6-866b-b072c53f2ceb`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_UniversoKEY | PK |  | VarChar (40) |
| TP_UniversoUsuario | PK |  | VarChar (40) |

## TP_Usuario
*Usuarios*  guid: `7acfb5e0-d18f-43fa-8921-e06599d48422`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TP_UsuarioId | PK |  | Domain:ID |
| TP_UsuarioUsuario |  | si | VarChar (100) |
| TP_UsuarioNombre |  | si | VarChar (100) |
| TP_UsuarioApellido |  | si | VarChar (100) |
| TP_UsuarioEmail |  | si | Domain:Email, GeneXus |
| TP_UsuarioExternal |  | si | VarChar (100) |
| TP_UsuarioPass |  | si | VarChar (100) |
| TP_UsuarioRol |  | si | (sin tipo explicito / heredado de dominio) |
| TP_UsuarioRolNombre |  | si | VarChar (100) |

## TR_CredencialPuesto
*Credencial puesto*  guid: `b8f37a27-3425-4dfc-b8b5-f26afe1c5964`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_CredencialesId | PK |  | Domain:ID |
| TC_CredencialesNombre |  |  | Domain:Nombre |
| TC_CredencialesFrente |  |  | Image |
| TC_CredencialesReverso |  |  | Image |
| TC_PuestosId | PK |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |

## TR_ProductosSimilares
*Productos similares*  guid: `8df05706-39e2-44f7-93b3-5661c992d2c7`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_ProductosId | PK |  | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| SP_ProductosSimilaresId | PK |  | (sin tipo explicito / heredado de dominio) |
| SP_ProductosSimilaresDes |  |  | (sin tipo explicito / heredado de dominio) |
| TR_ProductosSimilaresMarca | PK |  | VarChar (2) |

## TR_PuestosSimi
*Puestos Similares*  guid: `0eaacd42-9063-4f36-960b-be39cfad1f74`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TC_PuestosId | PK |  | Numeric (10) |
| TC_PuestosDes |  |  | VarChar (100) |
| TC_UnidadNegID |  |  | Numeric (10) |
| TC_UnidadNegDes |  |  | VarChar (120) |
| TR_PuestosSimiSimilarId | PK |  | Numeric (10) |
| TR_PuestosSimiDes |  |  | Domain:Des |
| TR_PuestosSimiBorrar |  |  | (sin tipo explicito / heredado de dominio) |

## TR_SocProTipoCliente
*Sociedad tipo cliente*  guid: `c19aa917-5057-4ecf-a5a5-539c1b83085f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TR_SocProTipoClienteId | PK |  | Domain:ID |
| TC_SociedadID |  | si | Numeric (10) |
| TC_SociedadTitulo |  |  | VarChar (100) |
| TR_SocProTipoClienteTipo |  | si | VarChar |
| TR_SocProTipoClienteOrgVta |  | si | VarChar |
| TR_SocProTipoClienteCanal |  | si | VarChar |
| TR_SocProTipoClienteSector |  | si | VarChar |

## TR_UniNegCompledidad
*Unidad de negocio por complejidad*  guid: `62afa5fb-7e52-470c-b98c-d23e64e68c18`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TR_UniNegCompledidadID | PK |  | Domain:ID |
| TR_UniNegCompledidadUN |  | si | (10) |
| TR_UniNegCompledidadCO |  | si | (10) |
| TR_UniNegCompledidadCOD |  | si | VarChar (100) |

## TR_UsuarioSucursal
*Usuarios sucursal*  guid: `fadd447d-be9a-4fb5-8e9c-0eeb5907371f`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TR_UsuarioSucursalId | PK |  | Domain:ID |
| TR_UsuarioSucursalUsuario |  | si | Domain:ID |
| TR_UsuarioSucursalSucId |  | si | Domain:ID |

## TR_UsuarioUnidadNeg
*Usuario unidad negocio*  guid: `ad2a5247-e510-4052-a9c7-101e179ec454`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TR_UsuarioUnidadNegId | PK |  | Domain:ID |
| TR_UsuarioUnidadNegUsuarioId |  | si | Domain:ID |
| TR_UsuarioUnidadNegUnNegID |  | si | Domain:ID |

## TV_Variables
*TV_Variables*  guid: `64f7e0ac-af61-40e4-8e8a-b94133197dbb`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TV_VariablesId | PK |  | Domain:ID [AUTONUMERICO] |
| TV_VariablesFormulario |  | si | VarChar |
| TV_VariablesFechaHora |  | si | DateTime |
| TV_VariablesTipoProceso |  | si | VarChar (100) |
| TV_VariablesVariable |  | si | VarChar (100) |
| TV_VariablesValorVariable |  | si | LongVarChar (2097152) |

## TW_FacturasEdicion
*Facturas*  guid: `ddfab6c1-9b79-46a3-aec4-e5fe654ce516`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| TE_FacturaEncID | PK |  | Domain:ID [AUTONUMERICO] |
| TE_FacturaEncIdFactura |  | si | (10) |
| TE_FacturaEncFolio |  | si | (10) |
| TE_FacturaEncEstatus |  | si | VarChar |
| TC_PepPepDEs |  |  | VarChar (150) |
| ST_clientesID |  |  | (sin tipo explicito / heredado de dominio) |
| ST_clientesNom |  |  | (sin tipo explicito / heredado de dominio) |
| TE_PedidoID |  | si | Numeric (10) |
| TE_PedidoTitulo |  |  | VarChar (100) |
| TC_SucursalID |  |  | Numeric (10) |
| TC_SucursalDes |  |  | VarChar (100) |
| ST_UnidadNegPedId |  |  | (sin tipo explicito / heredado de dominio) |
| ST_UnidadNegPedDes |  |  | (sin tipo explicito / heredado de dominio) |
| TC_ContactosNombreCompleto |  |  | VarChar (150) |
| ST_lugaresPedidosDes |  |  | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncTipo |  | si | VarChar (30) |
| TE_FacturaEncFechadeMovimiento |  | si | DateTime |
| TC_SociedadDes |  |  | VarChar (100) |
| TE_FacturaEncTXT |  | si | LongVarChar |
| TE_FacturaEncContarPartidas |  | si | (sin tipo explicito / heredado de dominio) |
| TE_FacturaEncOrganizacionVenta |  | si | VarChar (100) |
| TE_FacturaEncCanalDistribucion |  | si | VarChar (100) |
| TE_FacturaEncSector |  | si | VarChar (100) |
| TE_FacturaEncDEscripcion |  | si | VarChar (100) |
| TE_FacturaDetId | PK |  | Domain:ID |
| TE_FacturaDetDescripcion |  | si | VarChar (100) |
| TC_ProductosId |  | si | Numeric (10) |
| TC_ProductosDEs |  |  | VarChar (150) |
| TE_FacturaDetCantidad |  | si | Numeric (10) |
| TE_FacturaDetPrecioUnitario |  | si | Numeric (10,2) |
| TE_FacturaDetSubTotal |  |  | Numeric (10,2) |
| TE_FacturaDetTienePedidos |  | si | (sin tipo explicito / heredado de dominio) |

## UserCustomizations
*User Custom*  guid: `00d1a926-22f5-4fec-af63-b8c5d5ada345`

| Columna | PK | Nullable | Tipo |
|---|---|---|---|
| UserCustomizationsId | PK |  | Domain:GAMGUID |
| UserCustomizationsKey | PK |  | VarChar (200) |
| UserCustomizationsValue |  |  | LongVarChar |
