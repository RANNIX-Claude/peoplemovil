# Inventario de tablas reales extraido DIRECTO del SQL Server en vivo (db_a81e28_appscpfv2)

Fuente: conexion directa via System.Data.SqlClient a `sql5063.site4now.net`, base `db_a81e28_appscpfv2` (SQL Server 2019, hosting compartido site4now). Esta es la estructura REAL tal como esta desplegada -- tipos de dato exactos, PKs e FKs declarados en el motor, no inferidos del XPZ. 102 tablas de negocio (se excluyeron las tablas internas de GAM/GeneXus por instrucción del usuario).

**Nota importante:** esta instancia esta practicamente vacia de datos (es un sandbox/dev, no producción con los 56,593 empleados que vimos en el Access) -- el valor aqui es la ESTRUCTURA exacta, no los datos.

---

## Empleados
58 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| EmpleadosID | int |  | PK |  |
| IdEmpleadoEventual | int | si |  |  |
| Tipo_de_Empleado | varchar(255) | si |  |  |
| Primer_Apellido | varchar(255) | si |  |  |
| Segundo_Apellido | varchar(255) | si |  |  |
| Nombre_s_ | varchar(255) | si |  |  |
| EmpleadosStatus | varchar(255) | si |  |  |
| Genero | varchar(255) | si |  |  |
| Porcentaje_Puntualidad | decimal(17,6) | si |  |  |
| Lugar_de_Trabajo_Eventos | varchar(255) | si |  |  |
| EmpleadosIdSucursal | int | si |  |  |
| Nombre_Sucursal | varchar(255) | si |  |  |
| Regimen_Pago | varchar(255) | si |  |  |
| Ciclo_de_Pago | varchar(255) | si |  |  |
| EmpleadosCorreo_Electronico | varchar(255) | si |  |  |
| IdBanco | int | si |  |  |
| EmpleadosNombre_Banco | varchar(255) | si |  |  |
| Cuenta_Banco | varchar(255) | si |  |  |
| Fecha_de_Nacimiento | datetime | si |  |  |
| Estado_de_Nacimiento | varchar(255) | si |  |  |
| EmpleadosRFC | varchar(255) | si |  |  |
| CURP | varchar(255) | si |  |  |
| Credencial_Elector | varchar(255) | si |  |  |
| Cartilla | varchar(255) | si |  |  |
| Estatura | decimal(17,6) | si |  |  |
| Estado_Civil | varchar(255) | si |  |  |
| Talla | varchar(255) | si |  |  |
| EmpleadosDireccion | varchar(255) | si |  |  |
| Calle | varchar(255) | si |  |  |
| Numero_Exterior | varchar(255) | si |  |  |
| Numero_Interior | varchar(255) | si |  |  |
| Colonia | varchar(255) | si |  |  |
| EmpleadosCodigo_postal | varchar(255) | si |  |  |
| Delegacion_o_Municipio | varchar(255) | si |  |  |
| EmpleadosTelefono_movil | varchar(255) | si |  |  |
| EmpleadosTelefono_particular | varchar(255) | si |  |  |
| Fecha_Ingreso | datetime | si |  |  |
| Fecha_Antiguedad | datetime | si |  |  |
| Fecha_Baja | datetime | si |  |  |
| IdSolicitud | int | si |  |  |
| EmpleadosIdEmpresaPagadora | int | si |  |  |
| IdEmpresaPagadora_Lista | int | si |  |  |
| IdPuesto | int | si |  |  |
| NombrePuesto | varchar(255) | si |  |  |
| IdPuesto_Lista2 | int | si |  |  |
| EmpleadosCreado | datetime | si |  |  |
| EmpleadosModificado | datetime | si |  |  |
| Grado_de_Estudios | varchar(255) | si |  |  |
| Status_Grado_de_Estudios | varchar(255) | si |  |  |
| Licenciatura_o_Curso | varchar(255) | si |  |  |
| Idiomas | varchar(255) | si |  |  |
| En_Caso_de_Accidente_avisar_A | varchar(255) | si |  |  |
| Cirugias_Tratamientos_y_Padecimientos | varchar(255) | si |  |  |
| Tipo_de_Sangre | varchar(255) | si |  |  |
| Recomendado_Por | varchar(255) | si |  |  |
| Status_Oculto | varchar(255) | si |  |  |
| SobreNombre | varchar(255) | si |  |  |
| Estado_Provincia2 | smallint | si |  |  |

## Facturas_Pagos
12 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| Facturas_PagosID | int |  | PK |  |
| Tipo_de_Operacion | varchar(255) |  |  |  |
| Banco | varchar(255) |  |  |  |
| Referencia | varchar(255) |  |  |  |
| Facturas_PagosCantidad | decimal(17,6) |  |  |  |
| Cantidad_Aplicada | decimal(17,6) |  |  |  |
| Fecha_de_Movimiento | datetime |  |  |  |
| Pago_Cancelado | smallint |  |  |  |
| Observaciones | varchar(255) |  |  |  |
| Factura_Servicio_Interno | int |  |  |  |
| Facturas_PagosIdFacturaServicioInterno | int |  |  |  |
| Titulo21 | smallint |  |  |  |

## Pedidos
46 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| PedidosID | int |  | PK |  |
| Titulo2 | varchar(255) | si |  |  |
| PedidosStatus | varchar(255) | si |  |  |
| IdCliente | int | si |  |  |
| Nombre_Cliente | varchar(255) | si |  |  |
| RFC_Cliente | varchar(255) | si |  |  |
| Direccion_Cliente | varchar(255) | si |  |  |
| Telefono_Cliente | varchar(255) | si |  |  |
| IdContacto | int | si |  |  |
| Nombre_Contacto | varchar(255) | si |  |  |
| Telefono_Contacto | varchar(255) | si |  |  |
| IdEvento | int | si |  |  |
| Titulo_Evento | varchar(255) | si |  |  |
| PedidosIdSucursal | int | si |  |  |
| Titulo_Sucursal | varchar(255) | si |  |  |
| IdUnidadDeNegocio | int | si |  |  |
| Titulo_Unidad_de_Negocio | varchar(255) | si |  |  |
| IdPEP | int | si |  |  |
| Titulo_PEP | varchar(255) | si |  |  |
| Descripcion_PEP | varchar(255) | si |  |  |
| IdLugarCita | int | si |  |  |
| Lugar_Cita | varchar(255) | si |  |  |
| Direccion_Lugar_Cita | varchar(4000) | si |  |  |
| Tipo_de_Movimiento | varchar(255) | si |  |  |
| IdSociedad | int | si |  |  |
| Titulo_Sociedad | varchar(255) | si |  |  |
| IdSociedadPagadora | int | si |  |  |
| Titulo_Sociedad_Pagadora | varchar(255) | si |  |  |
| IdTipoDeComplejidad | int | si |  |  |
| Titulo_Tipo_de_Complejidad | varchar(255) | si |  |  |
| Duracion_del_Evento_Numero_de_Dias_ | int | si |  |  |
| IdTipoDuracionDelEvento | int | si |  |  |
| Titulo_Duracion_del_Evento | varchar(255) | si |  |  |
| Permitir_Cancelaciones | varchar(255) | si |  |  |
| Status_Facturacion | varchar(255) | si |  |  |
| SubTotal | decimal(17,6) | si |  |  |
| IVA | decimal(17,6) | si |  |  |
| Total_Con_IVA | decimal(17,6) | si |  |  |
| Costo_Por_Nomina | decimal(17,6) | si |  |  |
| PedidosCreado | datetime | si |  |  |
| IdResponsable | int | si |  |  |
| Responsable | varchar(255) | si |  |  |
| Creado_Por | varchar(255) | si |  |  |
| PedidosModificado | datetime | si |  |  |
| Modificado_Por | varchar(255) | si |  |  |
| Version_Vigente | smallint | si |  |  |

## Pedidos2
46 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| Pedidos2ID | int |  | PK |  |
| Pedidos2Titulo | varchar(255) | si |  |  |
| Pedidos2Status | varchar(255) | si |  |  |
| Pedidos2IdCliente | int | si |  |  |
| Nombre_Cliente2 | varchar(255) | si |  |  |
| RFC_Cliente2 | varchar(255) | si |  |  |
| Direccion_Cliente2 | varchar(255) | si |  |  |
| Pedidos2Telefono_Cliente | varchar(255) | si |  |  |
| Pedidos2IdContacto | int | si |  |  |
| Pedidos2Nombre_Contacto | varchar(255) | si |  |  |
| Pedidos2Telefono_Contacto | varchar(255) | si |  |  |
| IdEvento2 | int | si |  |  |
| Titulo_Evento2 | varchar(255) | si |  |  |
| Pedidos2IdSucursal | int | si |  |  |
| Titulo_Sucursal2 | varchar(255) | si |  |  |
| Pedidos2IdUnidadDeNegocio | int | si |  |  |
| Titulo_Unidad_de_Negocio2 | varchar(255) | si |  |  |
| Pedidos2IdPEP | int | si |  |  |
| Titulo_PEP2 | varchar(255) | si |  |  |
| Descripcion_PEP2 | varchar(255) | si |  |  |
| IdLugarCita2 | int | si |  |  |
| Lugar_Cita2 | varchar(255) | si |  |  |
| Direccion_Lugar_Cita2 | varchar(4000) | si |  |  |
| Pedidos2Tipo_de_Movimiento | varchar(255) | si |  |  |
| Pedidos2IdSociedad | int | si |  |  |
| Titulo_Sociedad2 | varchar(255) | si |  |  |
| IdSociedadPagadora2 | int | si |  |  |
| Titulo_Sociedad_Pagadora2 | varchar(255) | si |  |  |
| IdTipoDeComplejidad2 | int | si |  |  |
| Titulo_Tipo_de_Complejidad2 | varchar(255) | si |  |  |
| Duracion_del_Evento_Numero_de_Dias_2 | int | si |  |  |
| IdTipoDuracionDelEvento2 | int | si |  |  |
| Titulo_Duracion_del_Evento2 | varchar(255) | si |  |  |
| Permitir_Cancelaciones2 | varchar(255) | si |  |  |
| Status_Facturacion2 | varchar(255) | si |  |  |
| SubTotal2 | decimal(17,6) | si |  |  |
| Pedidos2IVA | decimal(17,6) | si |  |  |
| Total_Con_IVA2 | decimal(17,6) | si |  |  |
| Costo_Por_Nomina2 | decimal(17,6) | si |  |  |
| Creado | datetime | si |  |  |
| IdResponsable2 | int | si |  |  |
| Responsable2 | varchar(255) | si |  |  |
| Creado_Por2 | varchar(255) | si |  |  |
| Pedidos2Modificado | datetime | si |  |  |
| Modificado_Por2 | varchar(255) | si |  |  |
| Version_Vigente2 | smallint | si |  |  |

## Pedidos22
46 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| Pedidos2ID | int |  | PK |  |
| Pedidos2Titulo | varchar(255) | si |  |  |
| Pedidos2Status | varchar(255) | si |  |  |
| Pedidos2IdCliente | int | si |  |  |
| Nombre_Cliente2 | varchar(255) | si |  |  |
| RFC_Cliente2 | varchar(255) | si |  |  |
| Direccion_Cliente2 | varchar(255) | si |  |  |
| Pedidos2Telefono_Cliente | varchar(255) | si |  |  |
| Pedidos2IdContacto | int | si |  |  |
| Pedidos2Nombre_Contacto | varchar(255) | si |  |  |
| Pedidos2Telefono_Contacto | varchar(255) | si |  |  |
| IdEvento2 | int | si |  |  |
| Titulo_Evento2 | varchar(255) | si |  |  |
| Pedidos2IdSucursal | int | si |  |  |
| Titulo_Sucursal2 | varchar(255) | si |  |  |
| Pedidos2IdUnidadDeNegocio | int | si |  |  |
| Titulo_Unidad_de_Negocio2 | varchar(255) | si |  |  |
| Pedidos2IdPEP | int | si |  |  |
| Titulo_PEP2 | varchar(255) | si |  |  |
| Descripcion_PEP2 | varchar(255) | si |  |  |
| IdLugarCita2 | int | si |  |  |
| Lugar_Cita2 | varchar(255) | si |  |  |
| Direccion_Lugar_Cita2 | varchar(4000) | si |  |  |
| Pedidos2Tipo_de_Movimiento | varchar(255) | si |  |  |
| Pedidos2IdSociedad | int | si |  |  |
| Titulo_Sociedad2 | varchar(255) | si |  |  |
| IdSociedadPagadora2 | int | si |  |  |
| Titulo_Sociedad_Pagadora2 | varchar(255) | si |  |  |
| IdTipoDeComplejidad2 | int | si |  |  |
| Titulo_Tipo_de_Complejidad2 | varchar(255) | si |  |  |
| Duracion_del_Evento_Numero_de_Dias_2 | int | si |  |  |
| IdTipoDuracionDelEvento2 | int | si |  |  |
| Titulo_Duracion_del_Evento2 | varchar(255) | si |  |  |
| Permitir_Cancelaciones2 | varchar(255) | si |  |  |
| Status_Facturacion2 | varchar(255) | si |  |  |
| SubTotal2 | decimal(17,6) | si |  |  |
| Pedidos2IVA | decimal(17,6) | si |  |  |
| Total_Con_IVA2 | decimal(17,6) | si |  |  |
| Costo_Por_Nomina2 | decimal(17,6) | si |  |  |
| Creado | datetime | si |  |  |
| IdResponsable2 | int | si |  |  |
| Responsable2 | varchar(255) | si |  |  |
| Creado_Por2 | varchar(255) | si |  |  |
| Pedidos2Modificado | datetime | si |  |  |
| Modificado_Por2 | varchar(255) | si |  |  |
| Version_Vigente2 | smallint | si |  |  |

## RepQuestionUser
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| RepId | int |  | PK |  |
| QstUserId | int |  | PK |  |
| QstUserName | nchar(508) | si |  |  |
| QstUserDsc | nchar(508) | si |  |  |
| QstUserCreDate | datetime |  |  |  |
| QstUserCreUser | nvarchar(500) |  |  |  |
| QstUserUpdDate | datetime |  |  |  |
| QstUserUpdUser | nvarchar(500) |  |  |  |
| QstUserGUID | nchar(80) |  |  |  |

## RepQuestionUserLng
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| RepId | int |  | PK |  |
| QstUserId | int |  | PK |  |
| QstUserLngId | nchar(6) |  | PK |  |
| QstUserNameLng | nchar(508) | si |  |  |
| QstUserDscLng | nchar(508) | si |  |  |

## TA_ProdCompFase
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TT_ProdPuestoMatID | decimal(10,0) |  | PK |  |
| TT_PPPuestoid | decimal(10,0) |  |  |  |
| TT_ProdDes | varchar(255) | si |  |  |
| TT_PPProdId | decimal(10,0) | si |  |  |
| TT_FaseID | decimal(10,0) | si |  |  |
| TT_FaseDesc | varchar(255) | si |  |  |
| TT_Complejidad | decimal(10,0) | si |  |  |
| TT_UnidadNeg | decimal(10,0) | si |  |  |
| TT_MAT | smallint | si |  |  |

## TC_CatBajRein
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_CatBajReinID | decimal(10,0) |  | PK |  |
| TC_CatBajReinDes | varchar(50) |  |  |  |
| TC_CatBajReinTipo | varchar(40) |  |  |  |

## TC_CausasAclara
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_CausasAclaraId | decimal(10,0) |  | PK |  |
| TC_CausasAclaraDes | varchar(150) |  |  |  |

## TC_Complejo
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_complejoid | decimal(10,0) |  | PK |  |
| TC_ComplejoDES | char(100) | si |  |  |
| TC_Complejovigente | bit | si |  |  |

## TC_EmpresaPagadora
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EmpresaPagadoraId | decimal(10,0) |  | PK |  |
| TC_EmpresaPagadoraNombre | varchar(150) |  |  |  |

## TC_EquipoBiometrico
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EquipoBiometricoID | decimal(10,0) |  | PK |  |
| TC_EquipoBiometricoDes | char(100) |  |  |  |
| TC_EquipoBiometricoModelso | varchar(10) |  |  |  |

## TC_Espectaculo
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EspectaculoID | smallint |  | PK |  |
| TC_EspectaculoDes | char(100) |  |  |  |
| TC_EspectaculoDesCta | char(15) |  |  |  |
| TC_EspectaculoImagen | varbinary |  |  |  |
| TC_EspectaculoImagen_GXI | varchar(2048) | si |  |  |

## TC_EstacionNACS
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EstacionNACSID | decimal(10,0) |  | PK |  |
| TC_EquipoBiometricoID | decimal(10,0) |  |  | TC_EquipoBiometrico.TC_EquipoBiometricoID |
| TC_EstacionNACSEStacion | char(100) |  |  |  |
| TC_InmuebleID | smallint |  |  | TC_Inmueble.TC_InmuebleID |

## TC_Estados
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EstadosID | decimal(10,0) |  | PK |  |
| TC_EstadosDes | char(100) |  |  |  |

## TC_EstatusAut
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_EstatusAutID | smallint |  | PK |  |
| TC_EstatusAutDes | char(100) |  |  |  |
| TC_EstatusAutDesAmp | char(300) | si |  |  |
| TC_EstatusAutIMG | varbinary | si |  |  |
| TC_EstatusAutIMG_GXI | varchar(2048) | si |  |  |

## TC_FaseEvento
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_FaseEventoID | decimal(10,0) |  | PK |  |
| TC_FaseEventoDEs | char(100) |  |  |  |

## TC_Inmueble
11 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_InmuebleID | smallint |  | PK |  |
| TC_InmuebleDes | char(100) | si |  |  |
| TC_InmuebleDesCta | char(15) | si |  |  |
| TC_InmuebleDesAmp | char(300) | si |  |  |
| TC_InmuebleImagen | varbinary | si |  |  |
| TC_InmuebleImagen_GXI | varchar(2048) | si |  |  |
| TC_InmuebleZona | smallint | si |  |  |
| TC_InmuebleUbicacion | varchar(1024) | si |  |  |
| TC_InmuebleGeo | char(50) | si |  |  |
| TC_InmuebleTel | char(20) | si |  |  |
| TC_InmuebleEmail | varchar(100) | si |  |  |

## TC_LugarCita
7 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_LugarCitaID | decimal(10,0) |  | PK |  |
| TC_LugarCitaDes | varchar(255) | si |  |  |
| TC_LugarCitaIMG | varbinary | si |  |  |
| TC_LugarCitaIMG_GXI | varchar(2048) | si |  |  |
| TC_LugarCitaDomicilio | varchar(1024) | si |  |  |
| TC_LugarCitaGEO | char(50) | si |  |  |
| TC_LugarCitavigen | bit | si |  |  |

## TC_MovPedidos
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_MovPedidosID | decimal(10,0) |  | PK |  |
| TC_MovPedidosDes | char(100) |  |  |  |

## TC_PresenProd
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_PresenProdId | decimal(10,0) |  | PK |  |
| TC_PresenProdDes | char(100) |  |  |  |
| TC_UnidadNegID | decimal(10,0) | si |  | TC_UnidadNeg.TC_UnidadNegID |

## TC_Productos
24 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_ProductosId | decimal(10,0) |  | PK |  |
| TC_ProductosDEs | varchar(150) |  |  |  |
| TC_PuestosId | decimal(10,0) |  |  | TC_Puestos.TC_PuestosId |
| TP_ProductosUnidadNegocioID | decimal(10,0) | si |  |  |
| TP_ProductosUnidad_de_Negocio | varchar(150) | si |  |  |
| TP_ProductosSubCategoria | varchar(40) | si |  |  |
| TP_ProductosIdPuestoCatalogo | smallint | si |  |  |
| TP_ProductosNumero_Material_SAP | smallint | si |  |  |
| TP_ProductosIdProductoSimilar1 | decimal(10,0) | si |  |  |
| TP_ProductosProductoSimilar1 | varchar(150) | si |  |  |
| TP_ProductosIdProductoSimilar2 | decimal(10,0) | si |  |  |
| TP_ProductosProducto_Similar2 | varchar(150) | si |  |  |
| TP_ProductosIdProductoSimilar3 | decimal(10,0) | si |  |  |
| TP_ProductosProductoSimilar3 | varchar(150) | si |  |  |
| TP_ProductosIdProductoSimilar4 | decimal(10,0) | si |  |  |
| TP_ProductosProductoSimilar4 | varchar(150) | si |  |  |
| TP_ProductosIdProductoSimilar5 | decimal(10,0) | si |  |  |
| TP_ProductosProductoSimilar5 | varchar(150) | si |  |  |
| TP_ProductosIdProductoSimilar6 | decimal(10,0) | si |  |  |
| TP_ProductosProductoSimilar6 | varchar(150) | si |  |  |
| TP_ProductosClave | decimal(10,0) | si |  |  |
| TP_ProductosTituloCompleto | varchar(150) | si |  |  |
| TP_ProductosVigente | bit | si |  |  |
| TP_Productostp_Id | decimal(10,0) | si |  |  |

## TC_Puestos
27 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_PuestosId | decimal(10,0) |  | PK |  |
| TC_PuestosDuracion | smallint | si |  |  |
| TC_UnidadNegID | decimal(10,0) | si |  | TC_UnidadNeg.TC_UnidadNegID |
| TC_PuestosDes | char(100) | si |  |  |
| TC_PuestosHrasEntrTur | smallint | si |  |  |
| TC_PuestosHrasAntesCanPed | smallint | si |  |  |
| TC_SucursalPagId | decimal(10,0) | si |  | TC_SucursalPag.TC_SucursalPagId |
| TC_PuestosPorCerIni | money | si |  |  |
| TC_PuestosPorMin | money | si |  |  |
| TC_PuestosConEntrSer | varchar(2) | si |  |  |
| TC_PuestosDiasSinConf | smallint | si |  |  |
| TC_PuestosMatricial | varchar(2) | si |  |  |
| TC_PuestosReqTimeScan | varchar(2) | si |  |  |
| TC_ReglaAsistId | decimal(10,0) | si |  | TC_ReglaAsist.TC_ReglaAsistId |
| TC_PuestosRetardo | money | si |  |  |
| TC_PuestosFalta | money | si |  |  |
| TP_Id | decimal(10,0) | si |  |  |
| TP_pago_default | money | si |  |  |
| TP_Idunidaddenegocio | decimal(10,0) | si |  |  |
| TP_puestounidadnegocio | varchar(255) | si |  |  |
| TP_reglaAsistTimescan | varchar(100) | si |  |  |
| TP_PuestosConComplejidad | bit | si |  |  |
| TP_puestosConFase | bit | si |  |  |
| TC_Puestosmatri | bit | si |  |  |
| TC_PuestosCiclopago | varchar(40) | si |  |  |
| TC_PuestosRegPag | varchar(40) | si |  |  |
| TC_EmpresaPagadoraId | decimal(10,0) | si |  | TC_EmpresaPagadora.TC_EmpresaPagadoraId |

## TC_ReglaAsist
7 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_ReglaAsistId | decimal(10,0) |  | PK |  |
| TC_ReglaAsistDes | char(100) |  |  |  |
| TC_ReglaAsistMinAntEntr | smallint |  |  |  |
| TC_ReglaAsistMinDesEntr | smallint |  |  |  |
| TC_ReglaAsistMinRetar | smallint |  |  |  |
| TC_ReglaAsistMinAntSal | smallint |  |  |  |
| TC_ReglaAsistMinDesSal | smallint |  |  |  |

## TC_Responsable
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_ResponsableId | decimal(10,0) |  | PK |  |
| TC_ResponsableNom | varchar(60) | si |  |  |
| TC_ResponsableApp | varchar(60) | si |  |  |
| TC_ResponsableMaterno | varchar(60) | si |  |  |
| TC_ResponsableFoto | varbinary | si |  |  |
| TC_ResponsableFoto_GXI | varchar(2048) | si |  |  |
| TC_ResponsableSexo | varchar(40) | si |  |  |
| TC_ResponsableEmail | varchar(100) | si |  |  |
| TC_ResponsablePass | varchar(40) | si |  |  |

## TC_SegMovCan
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_SegMovCanId | decimal(10,0) |  | PK |  |
| TC_SegMovCanDes | varchar(100) |  |  |  |

## TC_Sociedad
7 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_SociedadID | decimal(10,0) |  | PK |  |
| TC_SociedadDes | varchar(100) | si |  |  |
| TC_SociedadVigente | varchar(2) | si |  |  |
| TC_SociedadGeneraFacturas | varchar(2) | si |  |  |
| TC_SociedadGeneraOrSer | varchar(2) | si |  |  |
| TC_SociedadesPagadorasID | decimal(10,0) | si |  | TC_sociedadesPagadoras.TC_SociedadesPagadorasID |
| TC_SociedadTitulo | varchar(100) |  |  |  |

## TC_StatusDetPed
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_StatusDetPedId | decimal(10,0) |  | PK |  |
| TC_StatusDetPedDEs | char(100) |  |  |  |

## TC_Sucursal
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_SucursalID | decimal(10,0) |  | PK |  |
| TC_SucursalDes | char(100) |  |  |  |

## TC_SucursalPag
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_SucursalPagId | decimal(10,0) |  | PK |  |
| TC_SucursalPagDes | char(100) |  |  |  |

## TC_UnidadNeg
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_UnidadNegID | decimal(10,0) |  | PK |  |
| TC_UnidadNegDes | varchar(120) | si |  |  |
| TC_UnidadNegIMG | varbinary | si |  |  |
| TC_UnidadNegIMG_GXI | varchar(2048) | si |  |  |
| TC_SociedadID | decimal(10,0) | si |  | TC_Sociedad.TC_SociedadID |

## TC_bancos
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_bancosID | decimal(10,0) |  | PK |  |
| TC_bancosNombre | varchar(100) | si |  |  |
| TC_BancosIMG | varbinary | si |  |  |
| TC_BancosIMG_GXI | varchar(2048) | si |  |  |

## TC_ciudad
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_CiudadId | decimal(10,0) |  | PK |  |
| TC_CiudadNom | varchar(100) |  |  |  |
| TC_EstadosID | decimal(10,0) |  |  | TC_Estados.TC_EstadosID |

## TC_codigoPosCol
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_CodigoPosId | varchar(5) |  | PK | TC_dodigoPos.TC_CodigoPosId |
| TC_codigoPosColId | decimal(10,0) |  | PK |  |
| TC_CodigoPosColNom | varchar(100) |  |  |  |
| TC_CodigoPosColTipo | varchar(100) |  |  |  |

## TC_comoteEnt
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_ComoteEntId | decimal(10,0) |  | PK |  |
| TC_ComoteEntNon | varchar(100) |  |  |  |

## TC_docuemp
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_docuempID | decimal(10,0) |  | PK |  |
| TC_docuempDescrip | varchar(100) |  |  |  |

## TC_dodigoPos
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_CodigoPosId | varchar(5) |  | PK |  |
| TC_CodigoPosCiudad | varchar(100) |  |  |  |
| TC_CodigoPosMuni | varchar(100) |  |  |  |
| TC_CodigoPosEsta | varchar(100) |  |  |  |

## TC_folios
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_foliosId | decimal(10,0) |  | PK |  |
| TC_foliosNombre | varchar(100) | si |  |  |
| TC_foliosNum | decimal(10,0) | si |  |  |

## TC_pep
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_PepId | decimal(10,0) |  | PK |  |
| TC_Pepdes | char(100) | si |  |  |
| TC_PepTitComp | char(100) | si |  |  |
| TC_PepPep | char(100) | si |  |  |
| TC_PepCategoria | char(100) | si |  |  |
| TC_LugarCitaID | decimal(10,0) | si |  | TC_LugarCita.TC_LugarCitaID |
| TC_PepVigente | bit | si |  |  |
| TC_UnidadNegID | decimal(10,0) | si |  | TC_UnidadNeg.TC_UnidadNegID |

## TC_regPago
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_RegPagoId | decimal(10,0) |  | PK |  |
| TC_RegPagoDes | varchar(150) |  |  |  |

## TC_socidad
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_socidadId | decimal(10,0) |  | PK |  |
| TC_socidades | varchar(40) | si |  |  |

## TC_sociedadesPagadoras
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_SociedadesPagadorasID | decimal(10,0) |  | PK |  |
| TC_SociedadesPagadorasDes | varchar(255) | si |  |  |

## TC_termycond
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_TermycondId | decimal(10,0) |  | PK |  |
| TC_TermycondTitulo | varchar(100) |  |  |  |
| TC_TermycondObse | varchar(-1) |  |  |  |

## TC_tipoPersonal
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_TipoPersonalID | decimal(10,0) |  | PK |  |
| TC_TipoPersonalDes | char(100) |  |  |  |

## TC_turnos
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TC_TurnosId | decimal(10,0) |  | PK |  |
| TC_TurnosDes | char(100) |  |  |  |
| TC_TurnosHras | smallint |  |  |  |

## TE_Aclaraciones
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_AclaracionesId | decimal(10,0) |  | PK |  |
| TC_CausasAclaraId | decimal(10,0) |  |  | TC_CausasAclara.TC_CausasAclaraId |
| TE_AclaracionesAsun | varchar(-1) | si |  |  |
| TE_AclaracionesEsta | varchar(40) | si |  |  |
| TE_AclaracionesComRes | varchar(-1) | si |  |  |
| TE_ReservacionID | int | si |  | TE_Reservacion.TE_ReservacionID |

## TE_AgendaFreelance
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_AgendaFreelanceID | decimal(10,0) |  | PK |  |
| TE_ReservacionID | int | si |  | TE_Reservacion.TE_ReservacionID |
| TE_AgendaFreelanceTiempoInicial | datetime | si |  |  |
| TE_AgendaFreelanceTiempoFinal | datetime | si |  |  |
| TE_AgendaFreelanceVigente | bit |  |  |  |

## TE_CClientes
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_CClientesID | decimal(10,0) |  | PK |  |
| TE_CClientesNom | varchar(100) | si |  |  |
| TE_CClientesEmail | varchar(100) | si |  |  |
| TE_ClientesID | decimal(10,0) | si |  | TE_clientes.TE_ClientesID |

## TE_Cand01
81 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_CandID | decimal(10,0) |  | PK |  |
| TE_CandComoTeEn | varchar(40) | si |  |  |
| TC_ComoteEntId | decimal(10,0) | si |  | TC_comoteEnt.TC_ComoteEntId |
| TE_CandRefe | bit | si |  |  |
| TE_CandNombre | varchar(70) | si |  |  |
| TE_CandApPat | varchar(70) | si |  |  |
| TE_CandApMat | varchar(70) | si |  |  |
| TE_CandNacion | varchar(40) | si |  |  |
| TE_CandNacionExp | char(60) | si |  |  |
| TE_CandEdoCiv | varchar(40) | si |  |  |
| TE_CandEstatura | money | si |  |  |
| TE_CandFecNac | datetime | si |  |  |
| TE_CandSexo | varchar(40) | si |  |  |
| TE_CandCURP | varchar(18) | si |  |  |
| TE_CandNumCart | varchar(20) | si |  |  |
| TE_CandNumINE | varchar(20) | si |  |  |
| TE_CandRFC | char(13) | si |  |  |
| TC_CodigoPosId | varchar(5) | si |  | TC_dodigoPos.TC_CodigoPosId |
| TC_CodigoPosId | varchar(5) | si |  | TC_codigoPosCol.TC_CodigoPosId |
| TC_codigoPosColId | decimal(10,0) | si |  | TC_codigoPosCol.TC_codigoPosColId |
| TE_CandCalle | varchar(40) | si |  |  |
| TE_CandNumExt | varchar(10) | si |  |  |
| TE_CandNumiNT | varchar(10) | si |  |  |
| TE_CandTelPart | varchar(13) | si |  |  |
| TE_CandTelMovil | char(13) | si |  |  |
| TE_CandWhatsApp | char(13) | si |  |  |
| TE_CandFacebook | varchar(40) | si |  |  |
| TE_CandTwitter | varchar(40) | si |  |  |
| TE_CandInstagram | varchar(40) | si |  |  |
| TE_CandCtoApPat | char(50) | si |  |  |
| TE_CandCtoApMat | char(40) | si |  |  |
| TE_CandCtoNom | varchar(40) | si |  |  |
| TE_CandCtoTel | char(13) | si |  |  |
| TE_CandParentesco | varchar(40) | si |  |  |
| TE_CandIdioma | varchar(40) | si |  |  |
| TE_CandEmail | varchar(100) | si |  |  |
| TE_CandUltGraEst | varchar(40) | si |  |  |
| TE_CandEstatusUltGraEst | varchar(40) | si |  |  |
| TE_CandEnfCron | bit | si |  |  |
| TE_CandEnfCronica | varchar(40) | si |  |  |
| TE_CandCir | bit | si |  |  |
| TE_CandCiru | varchar(40) | si |  |  |
| TE_CandTrat | bit | si |  |  |
| TE_CandTratmed | varchar(40) | si |  |  |
| TE_CandSanfre | varchar(40) | si |  |  |
| TE_CandIfeI | varbinary | si |  |  |
| TE_CandIfeI_GXI | varchar(2048) | si |  |  |
| TE_CandCurpI | varbinary | si |  |  |
| TE_CandCurpI_GXI | varchar(2048) | si |  |  |
| TE_CandCompDom | varbinary | si |  |  |
| TE_CandCompDom_GXI | varchar(2048) | si |  |  |
| TE_CandActaNac | varbinary | si |  |  |
| TE_CandActaNac_GXI | varchar(2048) | si |  |  |
| TE_CandRFCI | varbinary | si |  |  |
| TE_CandRFCI_GXI | varchar(2048) | si |  |  |
| TE_EmpleadosId | int | si |  | TE_empleados.TE_EmpleadosId |
| TE_CandUser | varchar(100) | si |  |  |
| TE_CandEstatus | varchar(40) | si |  |  |
| TE_CandContrasena | varchar(20) | si |  |  |
| TE_CandBorrar | smallint | si |  |  |
| TE_CandActEstudia | bit | si |  |  |
| TE_CandActEstuCarrera | varchar(50) | si |  |  |
| TE_CandActEstuEscuela | varchar(50) | si |  |  |
| TE_CandIngles | bit | si |  |  |
| TE_CandInglesNivel | varchar(40) | si |  |  |
| TE_CandCtasCertifi | bit | si |  |  |
| TE_CandCtasCertiCual | varchar(50) | si |  |  |
| TE_CandHazTomaCurs | bit | si |  |  |
| TE_CandHazTomaCurCual | varchar(50) | si |  |  |
| TE_CandExpLab | bit | si |  |  |
| TE_CandUltEmp | varchar(50) | si |  |  |
| TE_CandUltempPues | varchar(50) | si |  |  |
| TE_CandUltempFI | datetime | si |  |  |
| TE_CandUltempFf | datetime | si |  |  |
| TE_CandUltempSuel | money | si |  |  |
| TE_CandUltempMotSali | varchar(70) | si |  |  |
| TE_CandLugaNAc | varchar(70) | si |  |  |
| TE_CandTalla | money | si |  |  |
| TE_CandTiencita | bit | si |  |  |
| TE_CandAltaempleado | bit | si |  |  |
| TE_CandNumEmpleDO | decimal(10,0) | si |  |  |

## TE_CitaGpoCan
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_GpocitasId | decimal(10,0) |  | PK | TE_Gpocitas.TE_GpocitasId |
| TE_CandID | decimal(10,0) |  | PK | TE_Cand01.TE_CandID |
| TE_CitaGpoCanEstatus | varchar(40) |  |  |  |
| TE_CitaGpoCanAsis | bit |  |  |  |
| TE_CitaGpoCanCambGpo | bit |  |  |  |
| TE_CitaGpoCanContinua | bit |  |  |  |
| TE_CitaGpoCanObser | varchar(-1) |  |  |  |
| TE_CitaGpoCanDocCompl | bit | si |  |  |
| TE_CitaGpoCangpoant | varchar(40) | si |  |  |

## TE_Comunicados
7 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ComunicadosId | decimal(10,0) |  | PK |  |
| TE_ComunicadosTitulo | varchar(100) |  |  |  |
| TE_ComunicadosAsunto | varchar(-1) |  |  |  |
| TE_ComunicadosFini | datetime |  |  |  |
| TE_ComunicadosFfin | datetime |  |  |  |
| TE_ComunicadosImagen | varbinary |  |  |  |
| TE_ComunicadosImagen_GXI | varchar(2048) | si |  |  |

## TE_ContacClie
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ContacClieID | decimal(10,0) |  | PK |  |
| TE_ContacClieNom | varchar(100) |  |  |  |

## TE_CurInducc
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_CurInduccId | decimal(10,0) |  | PK |  |
| TE_CurInduccDes | varchar(150) | si |  |  |
| TE_CurInduccFeHr | datetime | si |  |  |
| TE_CurInduccFEMin | varchar(40) | si |  |  |
| TE_CurInduccHr | varchar(40) | si |  |  |
| TE_CurInduccDuracion | smallint | si |  |  |
| TE_CurInduccCupo | smallint | si |  |  |
| TE_VacanteId | decimal(10,0) | si |  | TE_vacante.TE_VacanteId |
| TE_CurInduccCitaCur | varchar(40) | si |  |  |

## TE_DetPedPuesto
21 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_DetPedPuestoId | decimal(10,0) |  | PK |  |
| TC_TipoPersonalID | decimal(10,0) |  |  | TC_tipoPersonal.TC_TipoPersonalID |
| TE_DetPedPuestoTitulo | char(100) |  |  |  |
| TC_ProductosId | decimal(10,0) |  |  | TC_Productos.TC_ProductosId |
| TC_LugarCitaID | decimal(10,0) |  |  | TC_LugarCita.TC_LugarCitaID |
| TE_DetPedPuestoLugOtro | bit |  |  |  |
| TE_DetPedPuestoOtroLugar | char(100) |  |  |  |
| TE_DetPedPuestoDomotroLug | varchar(1024) |  |  |  |
| TE_DetPedPuestoObser | varchar(-1) |  |  |  |
| TE_DetPedPuestoBloque | varchar(2) |  |  |  |
| TE_DetPedPuestoFacturable | varchar(2) |  |  |  |
| TE_DetPedPuestoCanti | smallint |  |  |  |
| TE_DetPedPuestoTurnos | smallint |  |  |  |
| TE_DetPedPuestoFecha | datetime |  |  |  |
| TE_DetPedPuestoHraIni | datetime |  |  |  |
| TE_DetPedPuestoHraFin | datetime |  |  |  |
| TE_DetPedPuestoFeLib | datetime |  |  |  |
| TE_DetPedPuestoFeFinCita | datetime |  |  |  |
| TE_DetPedPuestoCompSimi | varchar(2) |  |  |  |
| TC_FaseEventoID | decimal(10,0) |  |  | TC_FaseEvento.TC_FaseEventoID |
| TE_DetPedPuestoPerCanc | varchar(2) |  |  |  |

## TE_Dispositivo
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_DispositivoId | char(128) |  | PK |  |
| TE_DispositivoToken | char(1000) |  |  |  |
| TE_DispositivoName | char(128) |  |  |  |
| TE_DispositivoType | smallint |  |  |  |
| TE_DispositivoEmpleado | char(20) |  |  |  |
| TE_DispositivoEstatus | bit |  |  |  |

## TE_Docemp
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_DocempdId | decimal(10,0) |  | PK |  |
| TE_EmpIdEmpleadoEventual | int |  |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TC_docuempID | decimal(10,0) |  |  | TC_docuemp.TC_docuempID |
| TE_DocempImagen | varbinary |  |  |  |
| TE_DocempImagen_GXI | varchar(2048) | si |  |  |

## TE_Empleado
66 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_EmpIdEmpleadoEventual | int |  | PK |  |
| ID | decimal(10,0) |  |  |  |
| Foto | varbinary | si |  |  |
| Foto_GXI | varchar(2048) | si |  |  |
| TE_EmpTipo_de_Empleado | varchar(40) | si |  |  |
| TE_EmpPrimer_Apellido | varchar(120) | si |  |  |
| TE_EmpSegundo_Apellido | varchar(50) | si |  |  |
| TE_EmpNombre | varchar(70) | si |  |  |
| TE_EmpStatus | varchar(40) | si |  |  |
| TE_EmpGenero | varchar(40) | si |  |  |
| TE_EmpPorPuntualidad | money | si |  |  |
| TE_EmpLugarEvento | varchar(100) | si |  |  |
| TE_EmpIdSucursal | int | si |  |  |
| TE_EmpNomSucursal | varchar(70) | si |  |  |
| TE_EmpRegPago | varchar(40) | si |  |  |
| TE_EmpCicloPago | varchar(40) | si |  |  |
| TE_EmpCorreo_Electronico | varchar(70) | si |  |  |
| TE_EmpIdBanco | int | si |  |  |
| TE_EmpNombre_Banco | varchar(70) | si |  |  |
| TE_EmpCuenta_Banco | decimal(10,0) | si |  |  |
| TE_EmpFecNac | datetime | si |  |  |
| TE_EmpEdoNac | varchar(70) | si |  |  |
| TE_EmpRFC | varchar(15) | si |  |  |
| TE_EmpCURP | varchar(25) | si |  |  |
| TE_EmpCredElector | varchar(25) | si |  |  |
| TE_EmpCartilla | varchar(25) | si |  |  |
| TE_EmpEstatura | decimal(17,6) | si |  |  |
| TE_EmpEdoCivil | varchar(40) | si |  |  |
| TE_EmpTalla | varchar(20) | si |  |  |
| TE_EmpDireccion | varchar(100) | si |  |  |
| TE_EmpCalle | varchar(40) | si |  |  |
| TE_EmpTE_EmpNumExt | varchar(10) | si |  |  |
| TE_EmpNunInt | varchar(10) | si |  |  |
| TE_EmpColonia | varchar(40) | si |  |  |
| TE_EmpCodPostal | varchar(7) | si |  |  |
| TE_EmpDelMun | varchar(50) | si |  |  |
| TE_EmpEdoProv | varchar(50) | si |  |  |
| TE_EmpTelMovil | varchar(15) | si |  |  |
| TE_EmpTelPart | varchar(15) | si |  |  |
| TE_EmpFecIng | datetime | si |  |  |
| TE_EmpFecAnt | datetime | si |  |  |
| TE_EmpFecBaja | datetime | si |  |  |
| TE_EmpIdSolicitud | int | si |  |  |
| TE_EmpIdEmpPagadora | int | si |  |  |
| TE_EmpIdEmpPagadora_L | int | si |  |  |
| TE_EmpIdPuesto | int | si |  |  |
| TE_EmpNombrePuesto | varchar(100) | si |  |  |
| IdPuesto_Lista | int | si |  |  |
| TE_EmpCreado | datetime | si |  |  |
| TE_EmpModificado | datetime | si |  |  |
| TE_EmpGraEstudios | varchar(50) | si |  |  |
| TE_EmpStatusGradoEstudio | varchar(50) | si |  |  |
| TE_EmpLicCurso | varchar(50) | si |  |  |
| TE_EmpIdiomas | varchar(50) | si |  |  |
| TE_EmpAccidente | varchar(50) | si |  |  |
| TE_EmpCirugiasTratam | varchar(50) | si |  |  |
| TE_EmpTipoSangre | varchar(50) | si |  |  |
| TE_EmpRecomendadoPor | varchar(50) | si |  |  |
| TE_EmpStatus_Oculto | varchar(50) | si |  |  |
| TE_EmpleadoBorrar | int | si |  |  |
| TE_EmpleadoAlias | varchar(40) | si |  |  |
| TC_bancosID | decimal(10,0) | si |  | TC_bancos.TC_bancosID |
| TC_CodigoPosId | varchar(5) | si |  | TC_dodigoPos.TC_CodigoPosId |
| TC_CodigoPosId | varchar(5) | si |  | TC_codigoPosCol.TC_CodigoPosId |
| TC_codigoPosColId | decimal(10,0) | si |  | TC_codigoPosCol.TC_codigoPosColId |
| TC_SucursalID | decimal(10,0) | si |  | TC_Sucursal.TC_SucursalID |

## TE_EvePrue
10 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_EvePrueId | decimal(10,0) |  | PK |  |
| TE_EventoID | decimal(10,0) | si |  | TE_Evento.TE_EventoID |
| TE_EvePrueHra | varchar(40) | si |  |  |
| TE_EvePrueMinu | varchar(40) | si |  |  |
| TC_LugarCitaID | decimal(10,0) | si |  | TC_LugarCita.TC_LugarCitaID |
| TC_PresenProdId | decimal(10,0) | si |  | TC_PresenProd.TC_PresenProdId |
| TE_EvePrueComoLlegar | varchar(200) | si |  |  |
| TE_EvePrueIndicaciones | varchar(-1) | si |  |  |
| TE_EvePrueCitaEve | varchar(40) | si |  |  |
| TE_EvePrueCupo | smallint | si |  |  |

## TE_Evento
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_EventoID | decimal(10,0) |  | PK |  |
| TE_EventoDes | varchar(100) | si |  |  |
| TE_EventoFecIni | datetime | si |  |  |
| TE_EventoIMG | varbinary | si |  |  |
| TE_EventoIMG_GXI | varchar(2048) | si |  |  |
| TE_EventoFeTer | datetime | si |  |  |
| TE_EventoHora | varchar(40) | si |  |  |
| TE_EventoMinutos | varchar(40) | si |  |  |

## TE_Extras
16 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ExtrasId | int |  | PK |  |
| TE_ExtrasMonto | decimal(17,2) | si |  |  |
| TE_ExtrasConcepto | varchar(255) | si |  |  |
| TE_ExtrasObservaciones | varchar(-1) | si |  |  |
| TE_ExtrasStatus | bit | si |  |  |
| TE_ExtraseriodoCobrado | money | si |  |  |
| TE_ExtrasIdPlaza | int | si |  |  |
| TE_Extrastp_Level | smallint | si |  |  |
| TE_Extrastp_Author | varchar(40) | si |  |  |
| TE_Extrastp_Editor | varchar(40) | si |  |  |
| TE_Extrastp_Created | datetime | si |  |  |
| TE_Extrastp_Modified | datetime | si |  |  |
| TE_ExtrasTurnos | decimal(17,2) | si |  |  |
| SP_EmpleadoID | int |  |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TE_ExtrasIdPedidoDetalle | decimal(17,6) | si |  |  |
| TE_pedDetId | decimal(10,0) |  |  | TE_Peddet.TE_pedDetId |

## TE_ExtrasMasivos
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ExtrasMasivosID | smallint |  | PK |  |
| TE_ExtrasMasivosArchivo | varbinary |  |  |  |
| TE_ExtrasMasivosArchivoNom | varchar(100) |  |  |  |
| TE_ExtrasMasivosArchivoExt | varchar(4) |  |  |  |
| TE_ExtrasMasivosTotalRegistros | smallint |  |  |  |
| TE_ExtrasMasivosFechayhoradeproceso | datetime |  |  |  |

## TE_ExtrasMasivosTE_ExtrasMasivosDet
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ExtrasMasivosID | smallint |  | PK | TE_ExtrasMasivos.TE_ExtrasMasivosID |
| TE_ExtrasMasivosDetId | smallint |  | PK |  |
| TE_ExtrasMasivosDetDat1 | varchar(40) |  |  |  |
| TE_ExtrasMasivosDetDat2 | varchar(40) |  |  |  |
| TE_ExtrasMasivosDetdat3 | varchar(40) |  |  |  |
| TE_ExtrasMasivosDetdat4 | varchar(40) |  |  |  |
| TE_ExtrasMasivosDetdat5 | datetime |  |  |  |
| TE_ExtrasMasivosDetdat6 | smallmoney |  |  |  |

## TE_FacturaDet
18 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_FacturaDetId | decimal(10,0) |  | PK |  |
| TE_FacturaDetDescripcion | varchar(100) |  |  |  |
| TE_FacturaDetAgrupado | varchar(2) |  |  |  |
| TE_FacturaDetCantidad | decimal(10,0) |  |  |  |
| TE_FacturaDetFolio | decimal(10,0) |  |  |  |
| TE_FacturaDetIdAgrupado | decimal(10,0) |  |  |  |
| TE_FacturaDetFacServInterno | decimal(10,0) |  |  |  |
| TE_FacturaDetIdProducto | decimal(10,0) |  |  |  |
| TE_FacturaDetIdPedidoDetalle | decimal(10,0) |  |  |  |
| TE_FacturaDetIdPedido | decimal(10,0) |  |  |  |
| TE_FacturaDetPrecioUnitario | money |  |  |  |
| TE_FacturaDetProducto | varchar(100) |  |  |  |
| TE_FacturaDetSubTotal | money |  |  |  |
| TE_FacturaDetTurnos | smallint |  |  |  |
| TE_FacturaDetIdFacturaServicioInterno | decimal(10,0) |  |  |  |
| TE_FacturaDetCreado | datetime |  |  |  |
| TE_FacturaDetModificado | datetime |  |  |  |
| TE_FacturaDetCreadoPor | smallint |  |  |  |

## TE_FacturaEnc
17 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_FacturaEncID | decimal(10,0) |  | PK |  |
| TE_FacturaEncIdFactura | smallint |  |  |  |
| TE_FacturaEncFolio | smallint |  |  |  |
| TE_FacturaEncTitulo | smallint |  |  |  |
| TE_FacturaEncStatus | varchar(40) |  |  |  |
| TE_FacturaEncIdSucursal | smallint |  |  |  |
| TE_FacturaEncSucursal | varchar(40) |  |  |  |
| TE_FacturaEncIdUnidadDeNegocio | smallint |  |  |  |
| TE_FacturaEncUnidaddeNegocio | varchar(40) |  |  |  |
| TC_sociedadesId | decimal(10,0) |  |  |  |
| TE_FacturaEncSociedad | varchar(40) |  |  |  |
| TE_FacturaEncFechadeMovimiento | datetime |  |  |  |
| TE_PedidoID | decimal(10,0) |  |  | TE_Pedido.TE_PedidoID |
| TE_FacturaEncPedido | varchar(40) |  |  |  |
| TE_FacturaEncIdCliente | smallint |  |  |  |
| TE_FacturaEncNombreoRazonSocial | varchar(40) |  |  |  |
| TE_FacturaEncDireccion | varchar(40) |  |  |  |

## TE_Gpocitas
10 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_GpocitasId | decimal(10,0) |  | PK |  |
| TE_GpocitasFI | datetime | si |  |  |
| TE_GpocitasHI | varchar(40) | si |  |  |
| TE_GpocitasMin | varchar(40) | si |  |  |
| TE_PubVacanteId | decimal(10,0) | si |  | TE_PubVacante.TE_PubVacanteId |
| TE_GpocitasTitulo | varchar(150) | si |  |  |
| TE_GpocitasCupo | decimal(10,0) | si |  |  |
| TC_SucursalID | decimal(10,0) | si |  | TC_Sucursal.TC_SucursalID |
| TE_GpocitasEstatus | varchar(40) | si |  |  |
| TE_GpocitasHraEntre | varchar(40) | si |  |  |

## TE_LogEmp
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_LogEmpid | decimal(10,0) |  | PK |  |
| TE_EmpIdEmpleadoEventual | int | si |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TE_LogEmpFecha | datetime | si |  |  |
| TE_LogEmpTipoMov | varchar(40) | si |  |  |
| TC_CatBajReinID | decimal(10,0) | si |  | TC_CatBajRein.TC_CatBajReinID |
| TE_LogEmpObserv | varchar(-1) | si |  |  |

## TE_Peddet
67 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_pedDetId | decimal(10,0) |  | PK |  |
| TE_PedidoID | decimal(10,0) |  |  | TE_Pedido.TE_PedidoID |
| TE_peddetfecREg | datetime | si |  |  |
| TC_TipoPersonalID | decimal(10,0) | si |  | TC_tipoPersonal.TC_TipoPersonalID |
| TE_pedDetTitu | char(100) | si |  |  |
| TC_ProductosId | decimal(10,0) | si |  | TC_Productos.TC_ProductosId |
| TC_StatusDetPedId | decimal(10,0) | si |  | TC_StatusDetPed.TC_StatusDetPedId |
| ST_LugarId | decimal(10,0) | si |  | TC_LugarCita.TC_LugarCitaID |
| TE_pedDetOtro | bit | si |  |  |
| TE_pedDetOtroDes | char(100) | si |  |  |
| TE_pedDetDirec | varchar(1024) | si |  |  |
| TE_pedDetObser | varchar(200) | si |  |  |
| TE_pedDetBloque | varchar(2) | si |  |  |
| TE_pedDetPuesFac | varchar(2) | si |  |  |
| TE_pedDetCant | smallint | si |  |  |
| TE_pedDetTurnos | money | si |  |  |
| TE_pedDetFeCita | datetime | si |  |  |
| TE_pedDetFeCitaHI | varchar(40) | si |  |  |
| TE_pedDetFeCitaFi | varchar(40) | si |  |  |
| TE_pedDetFeLib | datetime | si |  |  |
| TE_pedDetFeLibHI | varchar(40) | si |  |  |
| TE_pedDetFeLibHF | varchar(40) | si |  |  |
| TE_pedDetFeFinal | datetime | si |  |  |
| TE_pedDetFeFinalHI | varchar(40) | si |  |  |
| TE_pedDetFeFinalHF | varchar(40) | si |  |  |
| TC_PresenProdId | decimal(10,0) | si |  | TC_PresenProd.TC_PresenProdId |
| TE_pedDetCompSim | varchar(2) | si |  |  |
| TC_FaseEventoID | decimal(10,0) | si |  | TC_FaseEvento.TC_FaseEventoID |
| TE_PeddetCancelar | varchar(2) | si |  |  |
| TE_pedDetCantReReal | smallint | si |  |  |
| TE_pedDetPeriodoPago | smallint | si |  |  |
| TE_PeddetcantAsistieron | smallint | si |  |  |
| TE_pedDetPeriodoAsiten | smallint | si |  |  |
| TE_PeddetporComConPreAsig | smallint | si |  |  |
| TE_PeddetPpagoEspecial | varchar(2) | si |  |  |
| TE_PeddetFacSerInt | varchar(2) | si |  |  |
| TE_PeddetSegReser | smallint | si |  |  |
| TE_PeddetFechafincitaoculta | datetime | si |  |  |
| TE_PeddetIdPuesto | decimal(10,0) | si |  |  |
| TE_PeddetTituPuesto | varchar(255) | si |  |  |
| TE_PeddetProduMatricial | varchar(10) | si |  |  |
| TE_PeddetFechafinBloque | datetime | si |  |  |
| TE_PeddetFechaVigenPreasig | datetime | si |  |  |
| TE_PeddetCompleto | varchar(10) | si |  |  |
| TE_PeddetCompletoConPreasigna | varchar(10) | si |  |  |
| TE_PeddetLugardireccion | varchar(1024) | si |  |  |
| TE_PeddetSucursal | decimal(10,0) | si |  |  |
| TE_PeddetTituloSucu | varchar(255) | si |  |  |
| TE_PeddetUnidNegocio | decimal(10,0) | si |  |  |
| TE_PeddetTituloUnidadNego | varchar(255) | si |  |  |
| TE_PeddetIdsociedad | decimal(10,0) | si |  |  |
| TE_PeddetTituloSociedad | varchar(255) | si |  |  |
| TE_PeddetFacturable | varchar(10) | si |  |  |
| TE_PeddetFolioFactu | decimal(10,0) | si |  |  |
| TE_PeddetPrecio | money | si |  |  |
| TE_PeddetFechaEnvioSms | datetime | si |  |  |
| TE_PeddetCostoXnomina | money | si |  |  |
| TE_PeddetPagoEspecial | money | si |  |  |
| TE_PeddetStatusEnvioSms | varchar(10) | si |  |  |
| TE_PeddetEnvioSmsPreasignados | bit | si |  |  |
| TE_PeddetCreadoPor | varchar(40) | si |  |  |
| TE_PeddetCreado | datetime | si |  |  |
| TE_PeddetModificadoPor | varchar(40) | si |  |  |
| TE_PeddetModificado | datetime | si |  |  |
| TE_PeddetCorreoEnvFaltas | bit | si |  |  |
| TE_PeddetCorreoEnv_PEP_Temporal | bit | si |  |  |
| TE_PeddetBloqueNum | varchar(12) | si |  |  |

## TE_Pedido
40 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_PedidoID | decimal(10,0) |  | PK |  |
| ST_clientesID | decimal(10,0) | si |  | TE_clientes.TE_ClientesID |
| TE_CClientesID | decimal(10,0) | si |  | TE_CClientes.TE_CClientesID |
| TE_PedidoTipo | varchar(10) | si |  |  |
| TE_PedidoDes | char(100) | si |  |  |
| TE_PedidoFecha | datetime | si |  |  |
| TE_PedidoFeregistro | datetime | si |  |  |
| TE_EventoID | decimal(10,0) | si |  | TE_Evento.TE_EventoID |
| TE_PedidoTitulo | varchar(100) | si |  |  |
| TE_PedidoLugOtro | bit | si |  |  |
| TE_PedidoLugOtroDire | varchar(1024) | si |  |  |
| TC_MovPedidosID | decimal(10,0) | si |  | TC_MovPedidos.TC_MovPedidosID |
| TC_complejoid | decimal(10,0) | si |  | TC_Complejo.TC_complejoid |
| TC_SucursalID | decimal(10,0) | si |  | TC_Sucursal.TC_SucursalID |
| TC_SucursalPagId | decimal(10,0) | si |  | TC_SucursalPag.TC_SucursalPagId |
| TE_PedidoPermConf | varchar(2) | si |  |  |
| TC_ResponsableId | decimal(10,0) | si |  | TC_Responsable.TC_ResponsableId |
| TE_PedidoMonto | decimal(17,4) | si |  |  |
| TC_EstatusAutID | smallint | si |  | TC_EstatusAut.TC_EstatusAutID |
| TC_PepId | decimal(10,0) | si |  | TC_pep.TC_PepId |
| TE_PedidoDuracionDias | smallint | si |  |  |
| ST_UnidadNegPedId | decimal(10,0) | si |  | TC_UnidadNeg.TC_UnidadNegID |
| ST_lugaresPedidosId | decimal(10,0) | si |  | TC_LugarCita.TC_LugarCitaID |
| TE_PedidoIdSoc | decimal(10,0) | si |  |  |
| TE_PedidoTituloSoc | varchar(255) | si |  |  |
| TE_PedidoIdTipoDuraEvento | decimal(10,0) | si |  |  |
| TE_PedidoTituloDuraEvento | varchar(2555) | si |  |  |
| TE_PedidoStatusFact | varchar(255) | si |  |  |
| TE_PedidoSubtotal | money | si |  |  |
| TE_PedidoIva | money | si |  |  |
| TE_PedidoTotalConIva | money | si |  |  |
| TE_PedidoCostoXNomina | money | si |  |  |
| TE_PedidoCreado | datetime | si |  |  |
| TE_PedidoCreadoPor | varchar(40) | si |  |  |
| TE_PedidoModicado | datetime | si |  |  |
| TE_PedidoModificadoPor | varchar(40) | si |  |  |
| TE_PedidoVersionVigente | bit | si |  |  |
| TE_PedidoSociedadPagadora | decimal(10,0) | si |  |  |
| SP_SocPagId | decimal(10,0) | si |  | TC_sociedadesPagadoras.TC_SociedadesPagadorasID |
| TE_Pedidoborrar | smallint |  |  |  |

## TE_Plazas
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_PlazasID | int |  | PK |  |
| TE_EmpIdEmpleadoEventual | int | si |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TE_PlazasPago | decimal(17,2) | si |  |  |
| TE_PlazasInicioVigencia | datetime | si |  |  |
| TE_PlazasFinVigencia | datetime | si |  |  |
| TE_PlazasVigente | bit | si |  |  |
| TE_PlazasPrincipal | varchar(2) | si |  |  |
| TE_PlazasModificado | datetime | si |  |  |
| TC_PuestosId | decimal(10,0) | si |  | TC_Puestos.TC_PuestosId |

## TE_PostVaCan1
22 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_PubVacanteId | decimal(10,0) |  | PK | TE_PubVacante.TE_PubVacanteId |
| TE_CandID | decimal(10,0) |  | PK | TE_Cand01.TE_CandID |
| TE_CurInduccId | decimal(10,0) | si |  | TE_CurInducc.TE_CurInduccId |
| TE_EvePrueId | decimal(10,0) | si |  | TE_EvePrue.TE_EvePrueId |
| TE_PostVaCanFecReg | datetime | si |  |  |
| TE_PostVaCanEstatus | varchar(40) | si |  |  |
| TE_PostVaCanResul | varchar(40) | si |  |  |
| TE_PostVaCanFECie | datetime | si |  |  |
| TE_PostVaCanAsis | bit | si |  |  |
| TE_PostVaCanDocComp | bit | si |  |  |
| TE_PostVaCanConti | bit | si |  |  |
| TE_PostVaCanContiObser | varchar(-1) | si |  |  |
| TE_PostVaCanDocPsico | varbinary | si |  |  |
| TE_PostVaCanDocPsicoObs | varchar(-1) | si |  |  |
| TE_PostVaCanEntrevista | varchar(-1) | si |  |  |
| TE_PostVaCanAsisCurInducc | bit | si |  |  |
| TE_PostVaCanCalifCurInducc | smallint | si |  |  |
| TE_PostVaCanObserCurInducc | varchar(-1) | si |  |  |
| TE_PostVaCanAsisEvePrue | bit | si |  |  |
| TE_PostVaCanCalifEvePrue | smallint | si |  |  |
| TE_PostVaCanObserEvePrue | varchar(-1) | si |  |  |
| TE_PostVaCanId | decimal(10,0) |  |  |  |

## TE_PubVacante
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_PubVacanteId | decimal(10,0) |  | PK |  |
| TE_VacanteId | decimal(10,0) |  |  | TE_vacante.TE_VacanteId |
| TE_PubVacanteFeIni | datetime | si |  |  |
| TE_PubVacanteFEFin | datetime | si |  |  |
| TE_PubVacanteActiva | bit |  |  |  |

## TE_Puente
105 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_PuenteiD | smallint |  | PK |  |
| TE_PedidoID | decimal(10,0) |  |  | TE_Pedido.TE_PedidoID |
| TE_PuenteBloq | varchar(10) | si |  |  |
| TC_ProductosId | decimal(10,0) |  |  | TC_Productos.TC_ProductosId |
| TE_PuenteC1 | varchar(11) | si |  |  |
| TE_PuenteNp1 | decimal(10,0) | si |  |  |
| TE_PuenteC2 | varchar(11) | si |  |  |
| TE_PuenteNp2 | decimal(10,0) | si |  |  |
| TE_PuenteC3 | varchar(11) | si |  |  |
| TE_PuenteNp3 | decimal(10,0) | si |  |  |
| TE_PuenteC4 | varchar(11) | si |  |  |
| TE_PuenteNp4 | decimal(10,0) | si |  |  |
| TE_PuenteC5 | varchar(11) | si |  |  |
| TE_PuenteNp5 | decimal(10,0) | si |  |  |
| TE_PuenteC6 | varchar(11) | si |  |  |
| TE_PuenteNp6 | decimal(10,0) | si |  |  |
| TE_Puentec7 | varchar(11) | si |  |  |
| TE_PuenteNp7 | decimal(10,0) | si |  |  |
| TE_Puentec8 | varchar(11) | si |  |  |
| TE_PuenteNp8 | decimal(10,0) | si |  |  |
| TE_Puentec9 | varchar(11) | si |  |  |
| TE_PuenteNp9 | decimal(10,0) | si |  |  |
| TE_Puentec10 | varchar(11) | si |  |  |
| TE_PuenteNp10 | decimal(10,0) | si |  |  |
| TE_Puentec11 | varchar(11) | si |  |  |
| TE_Puentec12 | varchar(11) | si |  |  |
| TE_Puentec13 | varchar(11) | si |  |  |
| TE_Puentec14 | varchar(11) | si |  |  |
| TE_Puentec15 | varchar(11) | si |  |  |
| TE_Puentec16 | varchar(11) | si |  |  |
| TE_Puentec17 | varchar(11) | si |  |  |
| TE_Puentec18 | varchar(11) | si |  |  |
| TE_Puentec19 | varchar(11) | si |  |  |
| TE_Puentec20 | varchar(11) | si |  |  |
| TE_Puentec21 | varchar(11) | si |  |  |
| TE_Puentec22 | varchar(11) | si |  |  |
| TE_Puentec23 | varchar(11) | si |  |  |
| TE_Puentec24 | varchar(11) | si |  |  |
| TE_Puentec25 | varchar(11) | si |  |  |
| TE_Puentec26 | varchar(11) | si |  |  |
| TE_Puentec27 | varchar(11) | si |  |  |
| TE_Puentec28 | varchar(11) | si |  |  |
| TE_Puentec29 | varchar(11) | si |  |  |
| TE_Puentec30 | varchar(11) | si |  |  |
| TE_Puentec31 | varchar(11) | si |  |  |
| TE_Puentec32 | varchar(11) | si |  |  |
| TE_Puentec33 | varchar(11) | si |  |  |
| TE_Puentec34 | varchar(11) | si |  |  |
| TE_Puentec35 | varchar(11) | si |  |  |
| TE_Puentec36 | varchar(11) | si |  |  |
| TE_Puentec37 | varchar(11) | si |  |  |
| TE_Puentec38 | varchar(11) | si |  |  |
| TE_Puentec39 | varchar(11) | si |  |  |
| TE_Puentec40 | varchar(11) | si |  |  |
| TE_Puentec41 | varchar(11) | si |  |  |
| TE_Puentec42 | varchar(11) | si |  |  |
| TE_Puentec43 | varchar(11) | si |  |  |
| TE_Puentec44 | varchar(11) | si |  |  |
| TE_Puentec45 | varchar(11) | si |  |  |
| TE_Puentec46 | varchar(11) | si |  |  |
| TE_Puentec47 | varchar(11) | si |  |  |
| TE_Puentec48 | varchar(11) | si |  |  |
| TE_Puentec49 | varchar(11) | si |  |  |
| TE_Puentec50 | varchar(11) | si |  |  |
| TE_PuenteTipo | varchar(40) | si |  |  |
| TE_PuenteNp11 | decimal(10,0) | si |  |  |
| TE_PuenteNp12 | decimal(10,0) | si |  |  |
| TE_PuenteNp13 | decimal(10,0) | si |  |  |
| TE_PuenteNp14 | decimal(10,0) | si |  |  |
| TE_PuenteNp15 | decimal(10,0) | si |  |  |
| TE_PuenteNp16 | decimal(10,0) | si |  |  |
| TE_PuenteNp17 | decimal(10,0) | si |  |  |
| TE_PuenteNp18 | decimal(10,0) | si |  |  |
| TE_PuenteNp19 | decimal(10,0) | si |  |  |
| TE_PuenteNp20 | decimal(10,0) | si |  |  |
| TE_PuenteNp21 | decimal(10,0) | si |  |  |
| TE_PuenteNp22 | decimal(10,0) | si |  |  |
| TE_PuenteNp23 | decimal(10,0) | si |  |  |
| TE_PuenteNp24 | decimal(10,0) | si |  |  |
| TE_PuenteNp25 | decimal(10,0) | si |  |  |
| TE_PuenteNp26 | decimal(10,0) | si |  |  |
| TE_PuenteNp27 | decimal(10,0) | si |  |  |
| TE_PuenteNp28 | decimal(10,0) | si |  |  |
| TE_PuenteNp29 | decimal(10,0) | si |  |  |
| TE_PuenteNp30 | decimal(10,0) | si |  |  |
| TE_PuenteNp31 | decimal(10,0) | si |  |  |
| TE_PuenteNp32 | decimal(10,0) | si |  |  |
| TE_PuenteNp33 | decimal(10,0) | si |  |  |
| TE_PuenteNp34 | decimal(10,0) | si |  |  |
| TE_PuenteNp35 | decimal(10,0) | si |  |  |
| TE_PuenteNp36 | decimal(10,0) | si |  |  |
| TE_PuenteNp37 | decimal(10,0) | si |  |  |
| TE_PuenteNp38 | decimal(10,0) | si |  |  |
| TE_PuenteNp39 | decimal(10,0) | si |  |  |
| TE_PuenteNp40 | decimal(10,0) | si |  |  |
| TE_PuenteNp41 | decimal(10,0) | si |  |  |
| TE_PuenteNp42 | decimal(10,0) | si |  |  |
| TE_PuenteNp43 | decimal(10,0) | si |  |  |
| TE_PuenteNp44 | decimal(10,0) | si |  |  |
| TE_PuenteNp45 | decimal(10,0) | si |  |  |
| TE_PuenteNp46 | decimal(10,0) | si |  |  |
| TE_PuenteNp47 | decimal(10,0) | si |  |  |
| TE_PuenteNp48 | decimal(10,0) | si |  |  |
| TE_PuenteNp49 | decimal(10,0) | si |  |  |
| TE_PuenteNp50 | decimal(10,0) | si |  |  |

## TE_RegistroBiometrico
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_RegistroBiometricoId | decimal(10,0) |  | PK |  |
| TE_RegistroBiometricoFH | datetime |  |  |  |
| TE_EmpIdEmpleadoEventual | int |  |  | TE_Empleado.TE_EmpIdEmpleadoEventual |

## TE_RegistroNACS
3 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_RegistroNACSID | decimal(10,0) |  | PK |  |
| TE_EMpleadoID | decimal(10,0) |  |  |  |
| TE_RegistroNACS | smallint |  |  |  |

## TE_Reserva
12 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ReservaId | decimal(10,0) |  | PK |  |
| TE_pedDetId | decimal(10,0) |  |  | TE_Peddet.TE_pedDetId |
| TE_EmpleadosId | int |  |  | TE_empleados.TE_EmpleadosId |
| TE_ReservaConFFor | bit |  |  |  |
| TE_ReservaTipo | varchar(40) |  |  |  |
| TE_ReservaEstatus | varchar(40) |  |  |  |
| TE_ReservaAsis | bit | si |  |  |
| TE_ReservaRetardo | bit | si |  |  |
| TE_ReservaFalta | bit | si |  |  |
| TE_ReservaFAsit | datetime |  |  |  |
| TE_ReservaFsali | datetime |  |  |  |
| TE_ReservaObserv | varchar(-1) | si |  |  |

## TE_Reservacion
53 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ReservacionID | int |  | PK |  |
| TE_ReservacionTitulo | varchar(255) | si |  |  |
| TE_EmpIdEmpleadoEventual | int | si |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TE_ReservacionPorcentajePuntualidad | decimal(16,4) | si |  |  |
| TE_pedDetId | decimal(10,0) | si |  | TE_Peddet.TE_pedDetId |
| TE_ReservacionIdPedido | int | si |  |  |
| TE_ReservacionStatus | varchar(70) | si |  |  |
| TE_ReservacionCitaInicio | datetime | si |  |  |
| TE_ReservacionCitaFin | datetime | si |  |  |
| TE_ReservacionTipo | varchar(40) | si |  |  |
| TE_ReservacionHoraEntradaAsistencia | datetime | si |  |  |
| TE_ReservacionHoraSalidaAsistencia | datetime | si |  |  |
| TE_ReservacionEstadoAsistencia | varchar(40) | si |  |  |
| TE_ReservacionMedioAsistencia | varchar(255) | si |  |  |
| TE_ReservacionPagoPorTurno | decimal(16,4) | si |  |  |
| TE_ReservacionPagoProgramado | decimal(16,4) | si |  |  |
| TE_ReservacionPagoReal | decimal(16,4) | si |  |  |
| TE_ReservacionPeriodoAsistencia | int | si |  |  |
| TE_ReservPeriodoCobrado | int | si |  |  |
| TE_ReservacionAnioCobrado | int | si |  |  |
| TE_ReservacionDuracionEnTurnos | decimal(16,6) | si |  |  |
| TE_ReservacionIdProductoEvento | int | si |  |  |
| TE_ReservacionIdPuestoEvento | int | si |  |  |
| TE_ReservacionFormaDePago | varchar(255) | si |  |  |
| TE_ReservacionBloque | int | si |  |  |
| TE_ReservacionSeriado | varchar(255) | si |  |  |
| TE_ReservacionUnidadDeNegocio | varchar(255) | si |  |  |
| TE_ReservacionSociedad | varchar(255) | si |  |  |
| TE_ReservacionObservaciones | varchar(-1) | si |  |  |
| TE_ReservacionIP | varchar(255) | si |  |  |
| TE_ReservIacionTimescanEntrada | int | si |  |  |
| TE_ReservacionIdTimescanSalida | int | si |  |  |
| TE_ReservacionEstacionEntrada | varchar(255) | si |  |  |
| TE_ReservacionEstacionSalida | varchar(255) | si |  |  |
| TE_ReservacionPenalizacionSueldo | decimal(16,4) | si |  |  |
| TE_ReservacionPenalizacionDias | decimal(16,4) | si |  |  |
| TE_ReservacionReglaAplicada | smallint | si |  |  |
| TE_ReservacionTipoRegistroTimeScan | varchar(255) | si |  |  |
| TE_ReservacionCreado | datetime | si |  |  |
| TE_ReservacionCreadoPor | varchar(255) | si |  |  |
| TE_ReservacionModificado | datetime | si |  |  |
| TE_ReservacionModificadoPor | varchar(255) | si |  |  |
| TE_ReservacionFolioHonorarios | varchar(255) | si |  |  |
| TE_ReservacionIdReservacion_Lobo | int | si |  |  |
| TE_ReservacionEnvioCorreoEmpalmes | smallint | si |  |  |
| TE_ReservaciontpIdPlaza | int | si |  |  |
| TE_ReservacionSaldoVencido | smallint | si |  |  |
| TE_ReservacionIdPagoHonorario | int | si |  |  |
| TE_ReservacionIdPagoHonorario_Lista | smallint | si |  |  |
| TE_ReservacionSinPlazaParaPago | smallint | si |  |  |
| TE_ReservacionCampo0 | int | si |  |  |
| TE_ReservacionBorrar | smallint | si |  |  |
| TE_ReservacionHoraReservacion | datetime | si |  |  |

## TE_SegCan
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_SegCanId | decimal(10,0) |  | PK |  |
| TC_SegMovCanId | decimal(10,0) |  |  | TC_SegMovCan.TC_SegMovCanId |
| TE_CandID | decimal(10,0) |  |  | TE_Cand01.TE_CandID |
| TE_SegCanFecha | datetime |  |  |  |
| TE_SegCanObser | varchar(-1) |  |  |  |

## TE_clientes
17 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ClientesID | decimal(10,0) |  | PK |  |
| TE_ClientesNombre | varchar(150) | si |  |  |
| TE_ClientesCliente | varchar(40) | si |  |  |
| TE_ClientesEmail | varchar(100) | si |  |  |
| TE_ClientesTel1 | char(20) | si |  |  |
| TE_ClientesTel2 | char(20) | si |  |  |
| TE_ClientesDireccion | varchar(1024) | si |  |  |
| TE_ClientesCodPostal | smallint | si |  |  |
| TE_ClientesEstado | char(50) | si |  |  |
| TE_ClientesPais | char(50) | si |  |  |
| TE_ClientesContacto | char(80) | si |  |  |
| TE_ClientesTelContacto | char(20) | si |  |  |
| TE_ClientesRFC | char(13) | si |  |  |
| TE_ClientesTipoCte | char(40) | si |  |  |
| TE_ClientesRelacion | char(20) | si |  |  |
| TE_ClientesWEB | varchar(1000) | si |  |  |
| TE_ClientesClienteSAP | char(12) | si |  |  |

## TE_comPer
7 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ComPerId | decimal(10,0) |  | PK |  |
| TE_ComPerTitulo | varchar(100) |  |  |  |
| TE_ComPerAsunto | varchar(-1) |  |  |  |
| TE_ComPerFecha | datetime |  |  |  |
| TE_ComPerIma | varbinary |  |  |  |
| TE_ComPerIma_GXI | varchar(2048) | si |  |  |
| TE_EmpleadosId | int |  |  | TE_empleados.TE_EmpleadosId |

## TE_docCand
14 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_DocCandId | decimal(10,0) |  | PK |  |
| TE_CandID | decimal(10,0) |  | PK | TE_Cand01.TE_CandID |
| TE_DocCandIden | varbinary | si |  |  |
| TE_DocCandIden_GXI | varchar(2048) | si |  |  |
| TE_DocCandActaNac | varbinary | si |  |  |
| TE_DocCandActaNac_GXI | varchar(2048) | si |  |  |
| TE_DocCandCompEst | varbinary | si |  |  |
| TE_DocCandCompEst_GXI | varchar(2048) | si |  |  |
| TE_DocCandCurp | varbinary | si |  |  |
| TE_DocCandCurp_GXI | varchar(2048) | si |  |  |
| TE_DocCandRfc | varbinary | si |  |  |
| TE_DocCandRfc_GXI | varchar(2048) | si |  |  |
| TE_DocCandCompDom | varbinary | si |  |  |
| TE_DocCandCompDom_GXI | varchar(2048) | si |  |  |

## TE_empleados
13 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_EmpleadosId | int |  | PK |  |
| TE_EmpleadosNum | decimal(10,0) | si |  |  |
| TE_EmpleadosNom | varchar(100) | si |  |  |
| TE_EmpleadosApp | varchar(100) | si |  |  |
| TE_EmpleadosApm | varchar(100) | si |  |  |
| TE_EmpleadosAlias | varchar(40) | si |  |  |
| TE_EmpleadosFoto | varbinary | si |  |  |
| TE_EmpleadosFoto_GXI | varchar(2048) | si |  |  |
| TE_EmpleadosSolici | decimal(10,0) | si |  |  |
| TC_RegPagoId | decimal(10,0) | si |  | TC_regPago.TC_RegPagoId |
| TC_SucursalPagId | decimal(10,0) | si |  | TC_SucursalPag.TC_SucursalPagId |
| TE_empleadosFormapgo | varchar(40) | si |  |  |
| TE_empleadosUser | varchar(10) | si |  |  |

## TE_plazasEnc
11 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_plazasEncId | decimal(10,0) |  | PK |  |
| TE_EmpIdEmpleadoEventual | int |  |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
| TE_plazasEnccontar | smallint |  |  |  |
| TE_plazasDetPago | money | si |  |  |
| TE_plazasDetFechaIni | datetime | si |  |  |
| TE_plazasDetFechaFin | datetime | si |  |  |
| TE_plazasDetVigente | bit | si |  |  |
| TE_plazasDetPrincipal | varchar(2) | si |  |  |
| TE_plazasDetModificado | datetime | si |  |  |
| TC_PuestosId | decimal(10,0) |  |  | TC_Puestos.TC_PuestosId |
| ST_PuestosId | decimal(10,0) |  |  | TC_Puestos.TC_PuestosId |

## TE_plazasEncplazas
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_plazasEncId | decimal(10,0) |  | PK | TE_plazasEnc.TE_plazasEncId |
| TE_plazasEncplazasId | decimal(10,0) |  | PK |  |
| TE_plazasEncplazasPago | money |  |  |  |
| TE_plazasEncplazasFI | datetime |  |  |  |
| TE_plazasEncplazasFF | datetime |  |  |  |
| TE_plazasEncplazasVigente | bit |  |  |  |
| TE_plazasEncplazasPrincipal | varchar(2) |  |  |  |
| TE_plazasEncplazasModificado | datetime |  |  |  |
| TE_PlazasEncplazasEsPrincipal | bit |  |  |  |

## TE_reqPer
22 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ReqPerId | decimal(10,0) |  | PK |  |
| TE_ReqPerFecha | datetime | si |  |  |
| TC_ResponsableId | decimal(10,0) | si |  | TC_Responsable.TC_ResponsableId |
| TC_ResponsableDEs | char(100) | si |  |  |
| TE_ReqPerEstatus | varchar(40) | si |  |  |
| TE_ReqPerUserId | varchar(100) | si |  |  |
| TC_PuestosId | decimal(10,0) | si |  | TC_Puestos.TC_PuestosId |
| TE_ReqPerNomjefeInm | varchar(100) | si |  |  |
| TE_ReqPerCantElem | smallint | si |  |  |
| TE_ReqPerArea | varchar(40) | si |  |  |
| TE_ReqPerDepto | varchar(100) | si |  |  |
| TE_ReqPerDesPuesto | bit | si |  |  |
| TE_ReqPerDesPuestoedad | smallint | si |  |  |
| TE_ReqPerdesPuestoSexo | varchar(40) | si |  |  |
| TE_ReqPerDesPuestoEsco | varchar(40) | si |  |  |
| TE_ReqPerDesPuestoIdio | varchar(40) | si |  |  |
| TE_ReqPerDesPuestoViajar | varchar(2) | si |  |  |
| TE_ReqPerDesPuestoLicCon | varchar(2) | si |  |  |
| TE_ReqPerDesPuestoExp | varchar(2) | si |  |  |
| TE_ReqPerDesPuestoConTec | varchar(-1) | si |  |  |
| TE_ReqPerDesPuestoObj | varchar(-1) | si |  |  |
| TE_ReqPerDesPuestoAct | varchar(-1) | si |  |  |

## TE_reqPerdetalle
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_ReqPerId | decimal(10,0) |  | PK | TE_reqPer.TE_ReqPerId |
| TE_ReqPerdetalleCant | smallint |  | PK |  |
| TE_ReqPerdetalleIdent | varchar(40) |  |  |  |
| TE_ReqPerdetalleFecha | datetime |  |  |  |

## TE_vacante
16 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TE_VacanteId | decimal(10,0) |  | PK |  |
| TE_VacanteTitulo | varchar(150) | si |  |  |
| TE_VacanteFun | varchar(-1) | si |  |  |
| TE_VacanteReq | varchar(-1) | si |  |  |
| TC_PuestosId | decimal(10,0) | si |  | TC_Puestos.TC_PuestosId |
| TE_VacanteImagen | varbinary | si |  |  |
| TE_VacanteImagen_GXI | varchar(2048) | si |  |  |
| TE_VacanteLigaPsi | varchar(1000) | si |  |  |
| TE_VacanteCtitulo | varchar(50) | si |  |  |
| TE_VacanteCCuer | varchar(-1) | si |  |  |
| TE_VacanteCIma | varbinary | si |  |  |
| TE_VacanteCIma_GXI | varchar(2048) | si |  |  |
| TE_VacanteCtaDoc | smallint | si |  |  |
| TE_VacanteREqIngles | bit | si |  |  |
| TE_VacanteREqExp | bit | si |  |  |
| TE_VacanteCodigo | varchar(10) | si |  |  |

## TL_AltasBajas
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TL_AltasBajasID | decimal(10,0) |  | PK |  |
| TL_AltasBajasNoEmpleado | smallint |  |  |  |
| TL_AltasBajasNombreEmp | varchar(80) |  |  |  |
| TL_AltasBajasFechaHora | datetime |  |  |  |
| TL_AltasBajasDeEstado | varchar(10) |  |  |  |
| TL_AltasBajasAestado | varchar(40) |  |  |  |
| TL_AltasBajasUsuario | varchar(15) |  |  |  |
| TL_AltasBajasObservacion | varchar(300) |  |  |  |

## TL_CierreNomina
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TL_CierreNominaID | decimal(10,0) |  | PK |  |
| TC_PeriodoID | decimal(10,0) |  |  |  |
| TL_CierreNominaPaso | varchar(40) |  |  |  |
| TL_CierreNominaFechaHora | datetime |  |  |  |

## TL_Modulos
10 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TL_ModulosId | decimal(10,0) |  | PK |  |
| TL_ModulosModulo | varchar(100) | si |  |  |
| TL_ModulosModuloId | smallint | si |  |  |
| TL_ModulosFormulario | varchar(100) | si |  |  |
| TL_ModulosOperacion | varchar(100) | si |  |  |
| TL_ModulosValorInicial | varchar(40) | si |  |  |
| TL_ModulosValorFinal | varchar(40) | si |  |  |
| TL_ModulosFechaMovimiento | datetime | si |  |  |
| TL_ModulosUsuario | varchar(40) | si |  |  |
| TL_ModulosAtributo | varchar(100) | si |  |  |

## TL_Movempleados
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TL_MovempleadosId | decimal(10,0) |  | PK |  |
| TL_MovempleadosFecha | datetime |  |  |  |
| TL_MovempleadosTotalProceso | smallint | si |  |  |
| TL_MovempleadosUsuario | varchar(40) | si |  |  |

## TL_MovempleadosDet
5 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TL_MovempleadosId | decimal(10,0) |  | PK | TL_Movempleados.TL_MovempleadosId |
| TL_MovempleadosDetCandidato | decimal(10,0) |  | PK |  |
| TL_MovempleadosDetNumEmp | int | si |  |  |
| TL_MovempleadosDetEstatusEmp | varchar(40) | si |  |  |
| TL_MovempleadosDetCandidatoNom | varchar(170) | si |  |  |

## TP_ImpHonoAsim
9 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_ImpHonoAsimId | decimal(10,0) |  | PK |  |
| TP_ImpHonoAsimTipo | varchar(100) | si |  |  |
| TP_ImpHonoAsimLimInf | decimal(17,4) | si |  |  |
| TP_ImpHonoAsimLimSup | decimal(17,4) | si |  |  |
| TP_ImpHonoAsimFija | decimal(9,4) | si |  |  |
| TP_ImpHonoAsimPorcentaje | decimal(9,4) | si |  |  |
| TP_ImpHonoAsimActivo | smallint | si |  |  |
| TP_ImpHonoAsimPeriodoIni | varchar(20) | si |  |  |
| TP_ImpHonoAsimPeriodoFin | varchar(20) | si |  |  |

## TP_Pensiones
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_PensionesID | decimal(10,0) |  | PK |  |
| TP_Pensiones | smallint |  |  |  |
| TP_PensionesEmpleado | varchar(100) |  |  |  |
| TP_PensionesBeneficiario | varchar(100) |  |  |  |
| TP_PensionesNumEMpleado | int |  |  |  |
| TP_PensionesNumeroCuenta | varchar(20) |  |  |  |
| TC_bancosID | decimal(10,0) | si |  | TC_bancos.TC_bancosID |
| TP_PensionesPorcenyaje | smallmoney | si |  |  |

## TP_Periodos
4 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_PeriodosID | decimal(10,0) |  | PK |  |
| TP_PeriodosFecInicio | datetime | si |  |  |
| TP_PeriodosFecFin | datetime | si |  |  |
| TP_PeriodosActual | bit | si |  |  |

## TP_PreciosProductos
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_PreciosProductosID | decimal(10,0) |  | PK |  |
| TC_ProductosId | decimal(10,0) |  |  | TC_Productos.TC_ProductosId |
| TP_PreciosProductosPrecio | money |  |  |  |
| TP_PreciosProductosFechaHora | datetime |  |  |  |
| TP_PreciosProductos | smallint |  |  |  |
| TP_PreciosProductosVigencia | char(20) |  |  |  |

## TP_ProdcutosOperativo
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_ProdcutosOperativoId | decimal(10,0) |  | PK |  |
| TP_ProdcutosOperativoIdProd | decimal(10,0) | si |  |  |
| TP_ProdcutosOperativoProdDes | varchar(150) | si |  |  |
| TP_ProdcutosOperativoUnidadNego | decimal(10,0) | si |  |  |
| TP_ProdcutosOperativoTieneFase | varchar(2) | si |  |  |
| TP_ProdcutosOperativoPuesto | decimal(10,0) | si |  |  |
| TP_ProdcutosOperativoPuestoCerteza | money | si |  |  |
| TP_ProdcutosOperativoSexo | varchar(2) | si |  |  |

## TP_ProductoSimi
2 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| IdProducto | int |  | PK |  |
| IdProductoSimi | int |  |  |  |

## TP_ProductosStaff
8 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_ProductosStaffId | decimal(10,0) |  | PK |  |
| TP_ProductosStaffIdprod | decimal(10,0) | si |  |  |
| TP_ProductosStaffProddDes | varchar(150) | si |  |  |
| TP_ProductosStaffUnidadNego | decimal(10,0) | si |  |  |
| TP_ProductosStaffComplejidad | decimal(10,0) | si |  |  |
| TP_ProductosStaffPuesto | decimal(10,0) | si |  |  |
| TP_ProductosStaffPuestoCerteza | money | si |  |  |
| TP_ProductosStaffSexo | varchar(2) | si |  |  |

## TP_ReglasAsistTimeScan
6 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| TP_ReglasAsistTimeScanID | decimal(10,0) |  | PK |  |
| TP_ReglasAsistTimeScanTitulo | varchar(40) | si |  |  |
| TP_ReglasAsistTimeScanMinAntesEntrada | smallint | si |  |  |
| TP_ReglasAsistTimeScanMinDespuesEntrada | smallint | si |  |  |
| TP_ReglasAsistTimeScanMinutosParaRetardo | smallint | si |  |  |
| TP_ReglasAsistTimeScanMinDespuesSalida | smallint | si |  |  |

## TP_SueldoMatriciales
14 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| Iddos | smallint |  | PK |  |
| TP_SueldoMatricialIdPuesto | int |  |  |  |
| Titulo | varchar(255) | si |  |  |
| TP_SueldoMatricialIdPuestoCatalogo | int | si |  |  |
| TP_SueldoMatricialIdTipoComplejidad | int | si |  |  |
| TP_SueldoMatricialIdTipoComplejidadCatalogo | int | si |  |  |
| TP_SueldoMatricialIdTipoDuracion | int | si |  |  |
| TP_SueldoMatricialIdTipoDuracionCatalogo | int | si |  |  |
| TP_SueldoMatricialFase_de_Evento | varchar(255) | si |  |  |
| TP_SueldoMatricialSueldo_Base | decimal(17,6) | si |  |  |
| TP_SueldoMatricialFecha_Inicio | datetime | si |  |  |
| TP_SueldoMatricialFecha_Fin | datetime | si |  |  |
| TP_SueldoMatricialActivo | smallint | si |  |  |
| tp_IdDOS | int | si |  |  |

## Te_pagos
41 columnas

| Columna | Tipo | Nullable | PK | FK |
|---|---|---|---|---|
| Te_pagosID | int |  | PK |  |
| Te_pagosNombres | varchar(255) | si |  |  |
| Te_pagosRegimen | varchar(255) | si |  |  |
| Te_pagosPeriodo | int | si |  |  |
| Te_pagosPeriododePago | int | si |  |  |
| Te_pagosIdBanco | int | si |  |  |
| Te_pagosNombreBanco | varchar(255) | si |  |  |
| Te_pagosNumeroCuentaBanco | varchar(255) | si |  |  |
| Te_pagosDiasLaborados | varchar(255) | si |  |  |
| Te_pagosPagoBruto | decimal(16,6) | si |  |  |
| Te_pagosSDP | decimal(16,6) | si |  |  |
| Te_pagosIM | decimal(16,6) | si |  |  |
| Te_pagosCF | decimal(16,6) | si |  |  |
| Te_pagosSA | decimal(16,6) | si |  |  |
| Te_pagosCG | decimal(16,6) | si |  |  |
| Te_pagosID2 | int | si |  |  |
| Te_pagosIT | decimal(16,6) | si |  |  |
| Te_pagosIVA | decimal(16,6) | si |  |  |
| Te_pagosRIVA | decimal(16,6) | si |  |  |
| Te_pagosRISR | decimal(16,6) | si |  |  |
| Te_pagosPagoNeto | decimal(16,6) | si |  |  |
| Te_pagosIdEmpresaPagadora | int | si |  |  |
| Te_pagosEmpresaPagadora | varchar(255) | si |  |  |
| Te_pagosObservaciones | varchar(255) | si |  |  |
| Te_pagosSolicitudPago | varchar(255) | si |  |  |
| Te_pagosModificado | datetime | si |  |  |
| Te_pagosCreado | datetime | si |  |  |
| Te_pagosCreadopor | int | si |  |  |
| Te_pagosModificadopor | int | si |  |  |
| Te_pagosIdPuestoPrincipal | int | si |  |  |
| Te_pagosPuestoPrincipal | varchar(255) | si |  |  |
| Te_pagosIdUnidadDeNegocio | int | si |  |  |
| Te_pagosUnidadDeNegocio | varchar(255) | si |  |  |
| Te_pagosIdSociedadPropia | int | si |  |  |
| Te_pagosSociedadPropia | varchar(255) | si |  |  |
| Te_pagosCumpleReglas | smallint | si |  |  |
| Te_pagosCumpleReglaPoseeCuentadeBanco | smallint | si |  |  |
| Te_pagosCumpleReglaUltimoPagoenPeriodosRecientes | smallint | si |  |  |
| Te_pagosCumpleReglaRecibePagoenelPeriodoActual | smallint | si |  |  |
| Te_pagosId_Lista | int | si |  |  |
| TE_EmpIdEmpleadoEventual | int | si |  | TE_Empleado.TE_EmpIdEmpleadoEventual |
