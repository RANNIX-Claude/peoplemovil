# Inventario de pantallas complejas (WebPanels/Transacciones personalizadas) -- extraido del codigo .NET generado

Estas 44 tablas NO tienen un formulario embebido en el XPZ (se verifico buscando objeto por objeto); su pantalla real vive como codigo ya generado en `Dev/genexus/web/*.cs`. Aqui se listan, por pantalla, los archivos `.cs` candidatos encontrados y los campos (atributos) detectados dentro de cada uno, extraidos del patron `"A<numero><NombreAtributo>"` que usa GeneXus internamente para referenciar cada atributo en el codigo generado.

Ojo: cuando aparece mas de un archivo candidato (ej. `pedidos.cs` y `pedidos2.cs`), es señal de que el sistema tuvo mas de una version de esa pantalla a lo largo de los ~10 años; hay que decidir cual es la vigente antes de reimplementar.

---

## Bancos
*Bancos*

### Archivo: `tc_bancos.cs` (prefix='tc_' suffix='', 2777 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |

### Archivo: `tc_bancosgeneral.cs` (prefix='tc_' suffix='general', 1437 lineas, 5 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |
| 4 | TC_bancosID_CTRL |
| 5 | TC_bancosID_PARM |

### Archivo: `tc_bancosprompt.cs` (prefix='tc_' suffix='prompt', 4196 lineas, 0 atributos detectados)

### Archivo: `tc_bancosview.cs` (prefix='tc_' suffix='view', 1571 lineas, 0 atributos detectados)

---

## Empleados
*Empleados*

### Archivo: `empleados.cs` (exact, 6860 lineas, 58 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | EmpleadosID |
| 2 | IdEmpleadoEventual |
| 3 | Tipo_de_Empleado |
| 4 | Primer_Apellido |
| 5 | Segundo_Apellido |
| 6 | Nombre_s_ |
| 7 | EmpleadosStatus |
| 8 | Genero |
| 9 | Porcentaje_Puntualidad |
| 10 | Estado_Provincia2 |
| 11 | Lugar_de_Trabajo_Eventos |
| 12 | EmpleadosIdSucursal |
| 13 | Nombre_Sucursal |
| 14 | Regimen_Pago |
| 15 | Ciclo_de_Pago |
| 16 | EmpleadosCorreo_Electronico |
| 17 | IdBanco |
| 18 | EmpleadosNombre_Banco |
| 19 | Cuenta_Banco |
| 20 | Fecha_de_Nacimiento |
| 21 | Estado_de_Nacimiento |
| 22 | EmpleadosRFC |
| 23 | CURP |
| 24 | Credencial_Elector |
| 25 | Cartilla |
| 26 | Estatura |
| 27 | Estado_Civil |
| 28 | Talla |
| 29 | EmpleadosDireccion |
| 30 | Calle |
| 31 | Numero_Exterior |
| 32 | Numero_Interior |
| 33 | Colonia |
| 34 | EmpleadosCodigo_postal |
| 35 | Delegacion_o_Municipio |
| 36 | EmpleadosTelefono_movil |
| 37 | EmpleadosTelefono_particular |
| 38 | Fecha_Ingreso |
| 39 | Fecha_Antiguedad |
| 40 | Fecha_Baja |
| 41 | IdSolicitud |
| 42 | EmpleadosIdEmpresaPagadora |
| 43 | IdEmpresaPagadora_Lista |
| 44 | IdPuesto |
| 45 | NombrePuesto |
| 46 | IdPuesto_Lista2 |
| 47 | EmpleadosCreado |
| 48 | EmpleadosModificado |
| 49 | Grado_de_Estudios |
| 50 | Status_Grado_de_Estudios |
| 51 | Licenciatura_o_Curso |
| 52 | Idiomas |
| 53 | En_Caso_de_Accidente_avisar_A |
| 54 | Cirugias_Tratamientos_y_Padecimientos |
| 55 | Tipo_de_Sangre |
| 56 | Recomendado_Por |
| 57 | Status_Oculto |
| 58 | SobreNombre |

### Archivo: `empleadosgeneral.cs` (prefix='' suffix='general', 2991 lineas, 60 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | EmpleadosID |
| 2 | SobreNombre |
| 3 | Status_Oculto |
| 4 | Recomendado_Por |
| 5 | Tipo_de_Sangre |
| 6 | Cirugias_Tratamientos_y_Padecimientos |
| 7 | En_Caso_de_Accidente_avisar_A |
| 8 | Idiomas |
| 9 | Licenciatura_o_Curso |
| 10 | Status_Grado_de_Estudios |
| 11 | Grado_de_Estudios |
| 12 | EmpleadosModificado |
| 13 | EmpleadosCreado |
| 14 | IdPuesto_Lista2 |
| 15 | NombrePuesto |
| 16 | IdPuesto |
| 17 | IdEmpresaPagadora_Lista |
| 18 | EmpleadosIdEmpresaPagadora |
| 19 | IdSolicitud |
| 20 | Fecha_Baja |
| 21 | Fecha_Antiguedad |
| 22 | Fecha_Ingreso |
| 23 | EmpleadosTelefono_particular |
| 24 | EmpleadosTelefono_movil |
| 25 | Delegacion_o_Municipio |
| 26 | EmpleadosCodigo_postal |
| 27 | Colonia |
| 28 | Numero_Interior |
| 29 | Numero_Exterior |
| 30 | Calle |
| 31 | EmpleadosDireccion |
| 32 | Talla |
| 33 | Estado_Civil |
| 34 | Estatura |
| 35 | Cartilla |
| 36 | Credencial_Elector |
| 37 | CURP |
| 38 | EmpleadosRFC |
| 39 | Estado_de_Nacimiento |
| 40 | Fecha_de_Nacimiento |
| 41 | Cuenta_Banco |
| 42 | EmpleadosNombre_Banco |
| 43 | IdBanco |
| 44 | EmpleadosCorreo_Electronico |
| 45 | Ciclo_de_Pago |
| 46 | Regimen_Pago |
| 47 | Nombre_Sucursal |
| 48 | EmpleadosIdSucursal |
| 49 | Lugar_de_Trabajo_Eventos |
| 50 | Estado_Provincia2 |
| 51 | Porcentaje_Puntualidad |
| 52 | Genero |
| 53 | EmpleadosStatus |
| 54 | Nombre_s_ |
| 55 | Segundo_Apellido |
| 56 | Primer_Apellido |
| 57 | Tipo_de_Empleado |
| 58 | IdEmpleadoEventual |
| 59 | EmpleadosID_CTRL |
| 60 | EmpleadosID_PARM |

### Archivo: `empleadosprompt.cs` (prefix='' suffix='prompt', 10660 lineas, 0 atributos detectados)

### Archivo: `empleadosview.cs` (prefix='' suffix='view', 1249 lineas, 0 atributos detectados)

### Archivo: `te_empleados.cs` (prefix='te_' suffix='', 4658 lineas, 16 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_RegPagoId |
| 2 | TC_SucursalPagId |
| 3 | TE_empleadosFormapgo |
| 4 | TE_EmpleadosId |
| 5 | TE_EmpleadosNum |
| 6 | TE_EmpleadosNom |
| 7 | TE_EmpleadosApp |
| 8 | TE_EmpleadosApm |
| 9 | TE_EmpleadosAlias |
| 10 | TE_EmpleadosNomcomp |
| 11 | TE_EmpleadosFoto |
| 12 | TE_EmpleadosSolici |
| 13 | TC_SucursalPagDes |
| 14 | TE_empleadosBusqueda |
| 15 | TE_empleadosUser |
| 16 | TC_RegPagoDes |

### Archivo: `te_empleadosgeneral.cs` (prefix='te_' suffix='general', 1950 lineas, 17 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_EmpleadosId |
| 2 | TE_empleadosFormapgo |
| 3 | TE_empleadosUser |
| 4 | TC_SucursalPagDes |
| 5 | TC_SucursalPagId |
| 6 | TC_RegPagoDes |
| 7 | TE_EmpleadosSolici |
| 8 | TE_EmpleadosApm |
| 9 | TE_EmpleadosApp |
| 10 | TE_EmpleadosNom |
| 11 | TE_EmpleadosAlias |
| 12 | TE_EmpleadosNum |
| 13 | TE_EmpleadosFoto |
| 14 | TE_EmpleadosNomcomp |
| 15 | TE_empleadosBusqueda |
| 16 | TE_EmpleadosId_CTRL |
| 17 | TE_EmpleadosId_PARM |

### Archivo: `te_empleadosprompt.cs` (prefix='te_' suffix='prompt', 5386 lineas, 0 atributos detectados)

### Archivo: `te_empleadosview.cs` (prefix='te_' suffix='view', 1433 lineas, 0 atributos detectados)

### Archivo: `te_empleadosww.cs` (prefix='te_' suffix='ww', 8158 lineas, 0 atributos detectados)

---

## Pedidos
*Pedidos*

### Archivo: `pedidos.cs` (exact, 6355 lineas, 46 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PedidosID |
| 2 | Titulo2 |
| 3 | PedidosStatus |
| 4 | IdCliente |
| 5 | Nombre_Cliente |
| 6 | RFC_Cliente |
| 7 | Direccion_Cliente |
| 8 | Telefono_Cliente |
| 9 | IdContacto |
| 10 | Nombre_Contacto |
| 11 | Telefono_Contacto |
| 12 | IdEvento |
| 13 | Titulo_Evento |
| 14 | PedidosIdSucursal |
| 15 | Titulo_Sucursal |
| 16 | IdUnidadDeNegocio |
| 17 | Titulo_Unidad_de_Negocio |
| 18 | IdPEP |
| 19 | Titulo_PEP |
| 20 | Descripcion_PEP |
| 21 | IdLugarCita |
| 22 | Lugar_Cita |
| 23 | Direccion_Lugar_Cita |
| 24 | Tipo_de_Movimiento |
| 25 | IdSociedad |
| 26 | Titulo_Sociedad |
| 27 | IdSociedadPagadora |
| 28 | Titulo_Sociedad_Pagadora |
| 29 | IdTipoDeComplejidad |
| 30 | Titulo_Tipo_de_Complejidad |
| 31 | Duracion_del_Evento_Numero_de_Dias_ |
| 32 | IdTipoDuracionDelEvento |
| 33 | Titulo_Duracion_del_Evento |
| 34 | Permitir_Cancelaciones |
| 35 | Status_Facturacion |
| 36 | SubTotal |
| 37 | IVA |
| 38 | Total_Con_IVA |
| 39 | Costo_Por_Nomina |
| 40 | PedidosCreado |
| 41 | IdResponsable |
| 42 | Responsable |
| 43 | Creado_Por |
| 44 | PedidosModificado |
| 45 | Modificado_Por |
| 46 | Version_Vigente |

### Archivo: `pedidosgeneral.cs` (prefix='' suffix='general', 3061 lineas, 48 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PedidosID |
| 2 | Version_Vigente |
| 3 | Modificado_Por |
| 4 | PedidosModificado |
| 5 | Creado_Por |
| 6 | Responsable |
| 7 | IdResponsable |
| 8 | PedidosCreado |
| 9 | Costo_Por_Nomina |
| 10 | Total_Con_IVA |
| 11 | IVA |
| 12 | SubTotal |
| 13 | Status_Facturacion |
| 14 | Permitir_Cancelaciones |
| 15 | Titulo_Duracion_del_Evento |
| 16 | IdTipoDuracionDelEvento |
| 17 | Duracion_del_Evento_Numero_de_Dias_ |
| 18 | Titulo_Tipo_de_Complejidad |
| 19 | IdTipoDeComplejidad |
| 20 | Titulo_Sociedad_Pagadora |
| 21 | IdSociedadPagadora |
| 22 | Titulo_Sociedad |
| 23 | IdSociedad |
| 24 | Tipo_de_Movimiento |
| 25 | Direccion_Lugar_Cita |
| 26 | Lugar_Cita |
| 27 | IdLugarCita |
| 28 | Descripcion_PEP |
| 29 | Titulo_PEP |
| 30 | IdPEP |
| 31 | Titulo_Unidad_de_Negocio |
| 32 | IdUnidadDeNegocio |
| 33 | Titulo_Sucursal |
| 34 | PedidosIdSucursal |
| 35 | Titulo_Evento |
| 36 | IdEvento |
| 37 | Telefono_Contacto |
| 38 | Nombre_Contacto |
| 39 | IdContacto |
| 40 | Telefono_Cliente |
| 41 | Direccion_Cliente |
| 42 | RFC_Cliente |
| 43 | Nombre_Cliente |
| 44 | IdCliente |
| 45 | PedidosStatus |
| 46 | Titulo2 |
| 47 | PedidosID_CTRL |
| 48 | PedidosID_PARM |

### Archivo: `pedidosprompt.cs` (prefix='' suffix='prompt', 10034 lineas, 0 atributos detectados)

### Archivo: `pedidosview.cs` (prefix='' suffix='view', 1250 lineas, 0 atributos detectados)

---

## Pedidos_Detalle
*Pedidos_Detalle*

### Archivo: `pedidos.cs` (fallback-fuzzy, 6355 lineas, 46 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PedidosID |
| 2 | Titulo2 |
| 3 | PedidosStatus |
| 4 | IdCliente |
| 5 | Nombre_Cliente |
| 6 | RFC_Cliente |
| 7 | Direccion_Cliente |
| 8 | Telefono_Cliente |
| 9 | IdContacto |
| 10 | Nombre_Contacto |
| 11 | Telefono_Contacto |
| 12 | IdEvento |
| 13 | Titulo_Evento |
| 14 | PedidosIdSucursal |
| 15 | Titulo_Sucursal |
| 16 | IdUnidadDeNegocio |
| 17 | Titulo_Unidad_de_Negocio |
| 18 | IdPEP |
| 19 | Titulo_PEP |
| 20 | Descripcion_PEP |
| 21 | IdLugarCita |
| 22 | Lugar_Cita |
| 23 | Direccion_Lugar_Cita |
| 24 | Tipo_de_Movimiento |
| 25 | IdSociedad |
| 26 | Titulo_Sociedad |
| 27 | IdSociedadPagadora |
| 28 | Titulo_Sociedad_Pagadora |
| 29 | IdTipoDeComplejidad |
| 30 | Titulo_Tipo_de_Complejidad |
| 31 | Duracion_del_Evento_Numero_de_Dias_ |
| 32 | IdTipoDuracionDelEvento |
| 33 | Titulo_Duracion_del_Evento |
| 34 | Permitir_Cancelaciones |
| 35 | Status_Facturacion |
| 36 | SubTotal |
| 37 | IVA |
| 38 | Total_Con_IVA |
| 39 | Costo_Por_Nomina |
| 40 | PedidosCreado |
| 41 | IdResponsable |
| 42 | Responsable |
| 43 | Creado_Por |
| 44 | PedidosModificado |
| 45 | Modificado_Por |
| 46 | Version_Vigente |

---

## Periodos
*Periodos*

### Archivo: `periodos.cs` (exact, 2746 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PeriodosID |
| 2 | Fecha_Inicio |
| 3 | Fecha_Fin |
| 4 | Actual |

### Archivo: `periodosgeneral.cs` (prefix='' suffix='general', 1452 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PeriodosID |
| 2 | Actual |
| 3 | Fecha_Fin |
| 4 | Fecha_Inicio |
| 5 | PeriodosID_CTRL |
| 6 | PeriodosID_PARM |

### Archivo: `periodosprompt.cs` (prefix='' suffix='prompt', 5418 lineas, 0 atributos detectados)

### Archivo: `periodosview.cs` (prefix='' suffix='view', 1250 lineas, 0 atributos detectados)

### Archivo: `tp_periodos.cs` (prefix='tp_' suffix='', 2798 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_PeriodosActual |
| 2 | TP_PeriodosID |
| 3 | TP_PeriodosFecInicio |
| 4 | TP_PeriodosFecFin |

### Archivo: `tp_periodosgeneral.cs` (prefix='tp_' suffix='general', 1475 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_PeriodosID |
| 2 | TP_PeriodosActual |
| 3 | TP_PeriodosFecFin |
| 4 | TP_PeriodosFecInicio |
| 5 | TP_PeriodosID_CTRL |
| 6 | TP_PeriodosID_PARM |

### Archivo: `tp_periodosprompt.cs` (prefix='tp_' suffix='prompt', 5450 lineas, 0 atributos detectados)

### Archivo: `tp_periodosview.cs` (prefix='tp_' suffix='view', 1250 lineas, 0 atributos detectados)

---

## Plazas
*Plazas*

### Archivo: `te_plazas.cs` (prefix='te_' suffix='', 4927 lineas, 23 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_EmpIdEmpleadoEventual |
| 2 | TC_PuestosId |
| 3 | TC_ReglaAsistId |
| 4 | TE_EmpGenero |
| 5 | TE_EmpStatus |
| 6 | TE_PlazasVigente |
| 7 | TE_PlazasPrincipal |
| 8 | TE_EmpleadoBuscar |
| 9 | TE_EmpPorPuntualidad |
| 10 | TE_PlazasPago |
| 11 | TC_ReglaAsistMinAntEntr |
| 12 | TC_ReglaAsistMinAntSal |
| 13 | TC_ReglaAsistMinDesEntr |
| 14 | TE_PlazasInicioVigencia |
| 15 | TE_PlazasFinVigencia |
| 16 | TP_pago_default |
| 17 | TE_PlazasID |
| 18 | TC_PuestosDes |
| 19 | TC_ReglaAsistDes |
| 20 | TE_PlazasModificado |
| 21 | TE_EmpNombre |
| 22 | TE_EmpPrimer_Apellido |
| 23 | TE_EmpleadoAlias |

### Archivo: `te_plazasgeneral.cs` (prefix='te_' suffix='general', 2477 lineas, 22 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_PlazasID |
| 2 | TC_ReglaAsistId |
| 3 | TC_PuestosId |
| 4 | TE_EmpGenero |
| 5 | TE_EmpStatus |
| 6 | TE_PlazasVigente |
| 7 | TE_PlazasPrincipal |
| 8 | TE_PlazasModificado |
| 9 | TC_ReglaAsistDes |
| 10 | TC_PuestosDes |
| 11 | TP_pago_default |
| 12 | TE_PlazasFinVigencia |
| 13 | TE_PlazasInicioVigencia |
| 14 | TC_ReglaAsistMinDesEntr |
| 15 | TC_ReglaAsistMinAntSal |
| 16 | TC_ReglaAsistMinAntEntr |
| 17 | TE_PlazasPago |
| 18 | TE_EmpPorPuntualidad |
| 19 | TE_EmpIdEmpleadoEventual |
| 20 | TE_EmpleadoBuscar |
| 21 | TE_PlazasID_CTRL |
| 22 | TE_PlazasID_PARM |

### Archivo: `te_plazasprompt.cs` (prefix='te_' suffix='prompt', 8982 lineas, 0 atributos detectados)

### Archivo: `te_plazasview.cs` (prefix='te_' suffix='view', 1237 lineas, 0 atributos detectados)

---

## Productos
*Productos*

### Archivo: `tc_productos.cs` (prefix='tc_' suffix='', 6084 lineas, 38 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |
| 2 | TC_UnidadNegID |
| 3 | TC_PuestosConEntrSer |
| 4 | TC_PuestosMatricial |
| 5 | TC_Puestosmatri |
| 6 | TP_ProductosVigente |
| 7 | TC_ProductosId |
| 8 | TC_ProductosDEs |
| 9 | TC_UnidadNegDes |
| 10 | TC_PuestosPorCerIni |
| 11 | TC_PuestosPorMin |
| 12 | TP_pago_default |
| 13 | TC_PuestosRetardo |
| 14 | TC_PuestosFalta |
| 15 | TC_PuestosHrasAntesCanPed |
| 16 | TC_PuestosHrasEntrTur |
| 17 | TC_PuestosDuracion |
| 18 | TP_ProductosUnidadNegocioID |
| 19 | TP_ProductosUnidad_de_Negocio |
| 20 | TP_ProductosSubCategoria |
| 21 | TP_ProductosIdPuestoCatalogo |
| 22 | TP_ProductosNumero_Material_SAP |
| 23 | TP_ProductosIdProductoSimilar1 |
| 24 | TP_ProductosProductoSimilar1 |
| 25 | TP_ProductosIdProductoSimilar2 |
| 26 | TP_ProductosProducto_Similar2 |
| 27 | TP_ProductosIdProductoSimilar3 |
| 28 | TP_ProductosProductoSimilar3 |
| 29 | TP_ProductosIdProductoSimilar4 |
| 30 | TP_ProductosProductoSimilar4 |
| 31 | TP_ProductosIdProductoSimilar5 |
| 32 | TP_ProductosProductoSimilar5 |
| 33 | TP_ProductosIdProductoSimilar6 |
| 34 | TP_ProductosProductoSimilar6 |
| 35 | TP_ProductosClave |
| 36 | TP_ProductosTituloCompleto |
| 37 | TP_Productostp_Id |
| 38 | TC_PuestosDes |

### Archivo: `tc_productosgeneral.cs` (prefix='tc_' suffix='general', 2945 lineas, 39 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |
| 2 | TC_PuestosId |
| 3 | TC_PuestosConEntrSer |
| 4 | TC_PuestosMatricial |
| 5 | TC_Puestosmatri |
| 6 | TP_ProductosVigente |
| 7 | TP_Productostp_Id |
| 8 | TP_ProductosTituloCompleto |
| 9 | TP_ProductosClave |
| 10 | TP_ProductosProductoSimilar6 |
| 11 | TP_ProductosIdProductoSimilar6 |
| 12 | TP_ProductosProductoSimilar5 |
| 13 | TP_ProductosIdProductoSimilar5 |
| 14 | TP_ProductosProductoSimilar4 |
| 15 | TP_ProductosIdProductoSimilar4 |
| 16 | TP_ProductosProductoSimilar3 |
| 17 | TP_ProductosIdProductoSimilar3 |
| 18 | TP_ProductosProducto_Similar2 |
| 19 | TP_ProductosIdProductoSimilar2 |
| 20 | TP_ProductosProductoSimilar1 |
| 21 | TP_ProductosIdProductoSimilar1 |
| 22 | TP_ProductosNumero_Material_SAP |
| 23 | TP_ProductosIdPuestoCatalogo |
| 24 | TP_ProductosSubCategoria |
| 25 | TP_ProductosUnidad_de_Negocio |
| 26 | TP_ProductosUnidadNegocioID |
| 27 | TC_PuestosDuracion |
| 28 | TC_PuestosHrasEntrTur |
| 29 | TC_PuestosHrasAntesCanPed |
| 30 | TC_PuestosFalta |
| 31 | TC_PuestosRetardo |
| 32 | TP_pago_default |
| 33 | TC_PuestosPorMin |
| 34 | TC_PuestosPorCerIni |
| 35 | TC_UnidadNegDes |
| 36 | TC_UnidadNegID |
| 37 | TC_ProductosDEs |
| 38 | TC_ProductosId_CTRL |
| 39 | TC_ProductosId_PARM |

### Archivo: `tc_productosprompt.cs` (prefix='tc_' suffix='prompt', 5434 lineas, 0 atributos detectados)

### Archivo: `tc_productosview.cs` (prefix='tc_' suffix='view', 1429 lineas, 0 atributos detectados)

### Archivo: `tc_productosww.cs` (prefix='tc_' suffix='ww', 10249 lineas, 0 atributos detectados)

---

## Puestos
*Puestos*

### Archivo: `tc_puestos.cs` (prefix='tc_' suffix='', 6583 lineas, 31 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_UnidadNegID |
| 2 | TC_ReglaAsistId |
| 3 | TC_EmpresaPagadoraId |
| 4 | TC_SucursalPagId |
| 5 | TC_PuestosConEntrSer |
| 6 | TC_PuestosMatricial |
| 7 | TC_PuestosReqTimeScan |
| 8 | TP_puestosConFase |
| 9 | TC_Puestosmatri |
| 10 | TC_PuestosCiclopago |
| 11 | TC_PuestosRegPag |
| 12 | TC_PuestosId |
| 13 | TC_PuestosDuracion |
| 14 | TC_PuestosDes |
| 15 | TC_PuestosHrasEntrTur |
| 16 | TC_PuestosHrasAntesCanPed |
| 17 | TC_PuestosPorCerIni |
| 18 | TC_PuestosPorMin |
| 19 | TC_PuestosDiasSinConf |
| 20 | TC_PuestosRetardo |
| 21 | TC_PuestosFalta |
| 22 | TP_Id |
| 23 | TP_pago_default |
| 24 | TP_Idunidaddenegocio |
| 25 | TP_puestounidadnegocio |
| 26 | TP_reglaAsistTimescan |
| 27 | TP_PuestosConComplejidad |
| 28 | TC_UnidadNegDes |
| 29 | TC_SucursalPagDes |
| 30 | TC_ReglaAsistDes |
| 31 | TC_EmpresaPagadoraNombre |

### Archivo: `tc_puestosgeneral.cs` (prefix='tc_' suffix='general', 2449 lineas, 28 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |
| 2 | TC_PuestosConEntrSer |
| 3 | TC_PuestosMatricial |
| 4 | TC_PuestosReqTimeScan |
| 5 | TP_puestosConFase |
| 6 | TC_Puestosmatri |
| 7 | TC_PuestosCiclopago |
| 8 | TC_PuestosRegPag |
| 9 | TC_EmpresaPagadoraNombre |
| 10 | TP_PuestosConComplejidad |
| 11 | TP_reglaAsistTimescan |
| 12 | TP_puestounidadnegocio |
| 13 | TP_Idunidaddenegocio |
| 14 | TP_pago_default |
| 15 | TP_Id |
| 16 | TC_PuestosFalta |
| 17 | TC_PuestosRetardo |
| 18 | TC_ReglaAsistDes |
| 19 | TC_PuestosDiasSinConf |
| 20 | TC_PuestosPorMin |
| 21 | TC_PuestosPorCerIni |
| 22 | TC_PuestosHrasAntesCanPed |
| 23 | TC_PuestosHrasEntrTur |
| 24 | TC_PuestosDes |
| 25 | TC_UnidadNegDes |
| 26 | TC_PuestosDuracion |
| 27 | TC_PuestosId_CTRL |
| 28 | TC_PuestosId_PARM |

### Archivo: `tc_puestosprompt.cs` (prefix='tc_' suffix='prompt', 6020 lineas, 0 atributos detectados)

### Archivo: `tc_puestosview.cs` (prefix='tc_' suffix='view', 2142 lineas, 0 atributos detectados)

### Archivo: `tc_puestosww.cs` (prefix='tc_' suffix='ww', 9462 lineas, 0 atributos detectados)

---

## TA_AltaEmp
*TA_Alta Emp*

### Archivo: `candaltaempexportreport.cs` (fallback-fuzzy, 2360 lineas, 0 atributos detectados)

### Archivo: `candaltaempgetfilterdata.cs` (fallback-fuzzy, 5856 lineas, 0 atributos detectados)

### Archivo: `prc_altaempleados.cs` (fallback-fuzzy, 1456 lineas, 0 atributos detectados)

### Archivo: `wp_altaempleadoind.cs` (fallback-fuzzy, 3121 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_CandNomComp |
| 2 | TE_CandEdad |

---

## TA_ManejoImagenes
*TA_Manejo Imagenes*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TC_ConceptosExtras
*TC_Conceptos Extras*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TC_DocuEmp
*Documentos empleados*

### Archivo: `tc_docuemp.cs` (exact, 2611 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_docuempID |
| 2 | TC_docuempDescrip |

---

## TC_Espectaculo
*TC_Espectaculo*

### Archivo: `tc_espectaculo.cs` (prefix='tc_' suffix='', 2731 lineas, 5 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_EspectaculoID |
| 2 | TC_EspectaculoDes |
| 3 | TC_EspectaculoDesCta |
| 4 | TC_EspectaculoImagen |
| 5 | TC_EspectaculoImagen_GXI |

---

## TC_Inmueble
*TC_Inmueble*

### Archivo: `tc_inmueble.cs` (prefix='tc_' suffix='', 3335 lineas, 11 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_InmuebleID |
| 2 | TC_InmuebleDes |
| 3 | TC_InmuebleDesCta |
| 4 | TC_InmuebleDesAmp |
| 5 | TC_InmuebleImagen |
| 6 | TC_InmuebleZona |
| 7 | TC_InmuebleUbicacion |
| 8 | TC_InmuebleGeo |
| 9 | TC_InmuebleTel |
| 10 | TC_InmuebleEmail |
| 11 | TC_InmuebleImagen_GXI |

---

## TC_RegPago
*Régimen de Pagos*

### Archivo: `tc_regpago.cs` (prefix='tc_' suffix='', 2636 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_RegPagoId |
| 2 | TC_RegPagoDes |

---

## TC_SegMovCan
*Movientos Candidatos*

### Archivo: `tc_segmovcan.cs` (exact, 2609 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_SegMovCanId |
| 2 | TC_SegMovCanDes |

---

## TC_Termycond
*Términos y Condiciones*

### Archivo: `tc_termycond.cs` (exact, 2711 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_TermycondId |
| 2 | TC_TermycondTitulo |
| 3 | TC_TermycondObse |

---

## TC_TipoCliente
*Tipo Cliente*

### Archivo: `gxdomaintipocliente.cs` (fallback-fuzzy, 66 lineas, 0 atributos detectados)

---

## TC_TipoMovimiento
*Tipo de movimiento*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TC_bancos2
*TC_bancos2*

### Archivo: `tc_bancos.cs` (fallback-fuzzy, 2777 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |

---

## TC_socidad
*Socidades*

### Archivo: `tc_socidad.cs` (prefix='tc_' suffix='', 2603 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_socidadId |
| 2 | TC_socidades |

---

## TE_CierreNomina
*TE_Cierre Nomina*

### Archivo: `tl_cierrenomina.cs` (prefix='tl_' suffix='', 2721 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TC_PeriodoID |
| 3 | TL_CierreNominaPaso |
| 4 | TL_CierreNominaFechaHora |

### Archivo: `tl_cierrenominageneral.cs` (prefix='tl_' suffix='general', 1444 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TL_CierreNominaFechaHora |
| 3 | TL_CierreNominaPaso |
| 4 | TC_PeriodoID |
| 5 | TL_CierreNominaID_CTRL |
| 6 | TL_CierreNominaID_PARM |

### Archivo: `tl_cierrenominaprompt.cs` (prefix='tl_' suffix='prompt', 4672 lineas, 0 atributos detectados)

### Archivo: `tl_cierrenominaview.cs` (prefix='tl_' suffix='view', 1244 lineas, 0 atributos detectados)

---

## TE_DetPedPuesto
*Puestos Detalle Pedido*

### Archivo: `te_detpedpuesto.cs` (exact, 5142 lineas, 28 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_TipoPersonalID |
| 2 | TC_ProductosId |
| 3 | TC_PuestosId |
| 4 | TC_LugarCitaID |
| 5 | TC_FaseEventoID |
| 6 | TE_DetPedPuestoLugOtro |
| 7 | TE_DetPedPuestoBloque |
| 8 | TE_DetPedPuestoFacturable |
| 9 | TE_DetPedPuestoCompSimi |
| 10 | TE_DetPedPuestoPerCanc |
| 11 | TE_DetPedPuestoId |
| 12 | TC_TipoPersonalDes |
| 13 | TE_DetPedPuestoTitulo |
| 14 | TC_ProductosDEs |
| 15 | TC_LugarCitaDes |
| 16 | TC_LugarCitaDomicilio |
| 17 | TE_DetPedPuestoOtroLugar |
| 18 | TE_DetPedPuestoDomotroLug |
| 19 | TE_DetPedPuestoObser |
| 20 | TE_DetPedPuestoCanti |
| 21 | TE_DetPedPuestoTurnos |
| 22 | TE_DetPedPuestoFecha |
| 23 | TE_DetPedPuestoHraIni |
| 24 | TE_DetPedPuestoHraFin |
| 25 | TE_DetPedPuestoFeLib |
| 26 | TE_DetPedPuestoFeFinCita |
| 27 | TC_PuestosDes |
| 28 | TC_FaseEventoDEs |

---

## TE_Excel
*TE_Excel*

### Archivo: `type_SdtSDT_lecturaExcel_SDT_lecturaExcelItem.cs` (fallback-fuzzy, 694 lineas, 0 atributos detectados)

---

## TE_FacturaDetAuxiliar
*Detalle facturas *

### Archivo: `te_facturadet.cs` (fallback-fuzzy, 3844 lineas, 18 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_FacturaDetAgrupado |
| 2 | TE_FacturaDetId |
| 3 | TE_FacturaDetDescripcion |
| 4 | TE_FacturaDetCantidad |
| 5 | TE_FacturaDetFolio |
| 6 | TE_FacturaDetIdAgrupado |
| 7 | TE_FacturaDetFacServInterno |
| 8 | TE_FacturaDetIdProducto |
| 9 | TE_FacturaDetIdPedidoDetalle |
| 10 | TE_FacturaDetIdPedido |
| 11 | TE_FacturaDetPrecioUnitario |
| 12 | TE_FacturaDetProducto |
| 13 | TE_FacturaDetSubTotal |
| 14 | TE_FacturaDetTurnos |
| 15 | TE_FacturaDetIdFacturaServicioInterno |
| 16 | TE_FacturaDetCreado |
| 17 | TE_FacturaDetModificado |
| 18 | TE_FacturaDetCreadoPor |

---

## TE_FacturaDetPed
*Detalles Pedidos Factura*

### Archivo: `te_facturadet.cs` (fallback-fuzzy, 3844 lineas, 18 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_FacturaDetAgrupado |
| 2 | TE_FacturaDetId |
| 3 | TE_FacturaDetDescripcion |
| 4 | TE_FacturaDetCantidad |
| 5 | TE_FacturaDetFolio |
| 6 | TE_FacturaDetIdAgrupado |
| 7 | TE_FacturaDetFacServInterno |
| 8 | TE_FacturaDetIdProducto |
| 9 | TE_FacturaDetIdPedidoDetalle |
| 10 | TE_FacturaDetIdPedido |
| 11 | TE_FacturaDetPrecioUnitario |
| 12 | TE_FacturaDetProducto |
| 13 | TE_FacturaDetSubTotal |
| 14 | TE_FacturaDetTurnos |
| 15 | TE_FacturaDetIdFacturaServicioInterno |
| 16 | TE_FacturaDetCreado |
| 17 | TE_FacturaDetModificado |
| 18 | TE_FacturaDetCreadoPor |

---

## TE_InconsistenciasCierreNomina
*TE_Inconsistencias Cierre Nomina*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TE_Puente
*Puente detalle Puestos*

### Archivo: `te_puente.cs` (exact, 11857 lineas, 107 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_PedidoID |
| 2 | TC_ProductosId |
| 3 | TE_PuenteiD |
| 4 | TE_PuenteBloq |
| 5 | TC_ProductosDEs |
| 6 | TP_ProductosTituloCompleto |
| 7 | TE_PuenteC1 |
| 8 | TE_PuenteNp1 |
| 9 | TE_PuenteC2 |
| 10 | TE_PuenteNp2 |
| 11 | TE_PuenteC3 |
| 12 | TE_PuenteNp3 |
| 13 | TE_PuenteC4 |
| 14 | TE_PuenteNp4 |
| 15 | TE_PuenteC5 |
| 16 | TE_PuenteNp5 |
| 17 | TE_PuenteC6 |
| 18 | TE_PuenteNp6 |
| 19 | TE_Puentec7 |
| 20 | TE_PuenteNp7 |
| 21 | TE_Puentec8 |
| 22 | TE_PuenteNp8 |
| 23 | TE_Puentec9 |
| 24 | TE_PuenteNp9 |
| 25 | TE_Puentec10 |
| 26 | TE_PuenteNp10 |
| 27 | TE_Puentec11 |
| 28 | TE_PuenteNp11 |
| 29 | TE_Puentec12 |
| 30 | TE_PuenteNp12 |
| 31 | TE_Puentec13 |
| 32 | TE_PuenteNp13 |
| 33 | TE_Puentec14 |
| 34 | TE_PuenteNp14 |
| 35 | TE_Puentec15 |
| 36 | TE_PuenteNp15 |
| 37 | TE_Puentec16 |
| 38 | TE_PuenteNp16 |
| 39 | TE_Puentec17 |
| 40 | TE_PuenteNp17 |
| 41 | TE_Puentec18 |
| 42 | TE_PuenteNp18 |
| 43 | TE_Puentec19 |
| 44 | TE_PuenteNp19 |
| 45 | TE_Puentec20 |
| 46 | TE_PuenteNp20 |
| 47 | TE_Puentec21 |
| 48 | TE_PuenteNp21 |
| 49 | TE_Puentec22 |
| 50 | TE_PuenteNp22 |
| 51 | TE_Puentec23 |
| 52 | TE_PuenteNp23 |
| 53 | TE_Puentec24 |
| 54 | TE_PuenteNp24 |
| 55 | TE_Puentec25 |
| 56 | TE_PuenteNp25 |
| 57 | TE_Puentec26 |
| 58 | TE_PuenteNp26 |
| 59 | TE_Puentec27 |
| 60 | TE_PuenteNp27 |
| 61 | TE_Puentec28 |
| 62 | TE_PuenteNp28 |
| 63 | TE_Puentec29 |
| 64 | TE_PuenteNp29 |
| 65 | TE_Puentec30 |
| 66 | TE_PuenteNp30 |
| 67 | TE_Puentec31 |
| 68 | TE_PuenteNp31 |
| 69 | TE_Puentec32 |
| 70 | TE_PuenteNp32 |
| 71 | TE_Puentec33 |
| 72 | TE_PuenteNp33 |
| 73 | TE_Puentec34 |
| 74 | TE_PuenteNp34 |
| 75 | TE_Puentec35 |
| 76 | TE_PuenteNp35 |
| 77 | TE_Puentec36 |
| 78 | TE_PuenteNp36 |
| 79 | TE_Puentec37 |
| 80 | TE_PuenteNp37 |
| 81 | TE_Puentec38 |
| 82 | TE_PuenteNp38 |
| 83 | TE_Puentec39 |
| 84 | TE_PuenteNp39 |
| 85 | TE_Puentec40 |
| 86 | TE_PuenteNp40 |
| 87 | TE_Puentec41 |
| 88 | TE_PuenteNp41 |
| 89 | TE_Puentec42 |
| 90 | TE_PuenteNp42 |
| 91 | TE_Puentec43 |
| 92 | TE_PuenteNp43 |
| 93 | TE_Puentec44 |
| 94 | TE_PuenteNp44 |
| 95 | TE_Puentec45 |
| 96 | TE_PuenteNp45 |
| 97 | TE_Puentec46 |
| 98 | TE_PuenteNp46 |
| 99 | TE_Puentec47 |
| 100 | TE_PuenteNp47 |
| 101 | TE_Puentec48 |
| 102 | TE_PuenteNp48 |
| 103 | TE_Puentec49 |
| 104 | TE_PuenteNp49 |
| 105 | TE_Puentec50 |
| 106 | TE_PuenteNp50 |
| 107 | TE_PuenteTipo |

---

## TE_RegistroNACS
*TE_Registro NACS*

### Archivo: `te_registronacs.cs` (prefix='te_' suffix='', 2668 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_RegistroNACSID |
| 2 | TE_EMpleadoID |
| 3 | TE_RegistroNACS |

---

## TL_Modulos
*Movimientos de modulos*

### Archivo: `tl_modulos.cs` (prefix='tl_' suffix='', 3301 lineas, 10 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TL_ModulosId |
| 2 | TL_ModulosModulo |
| 3 | TL_ModulosModuloId |
| 4 | TL_ModulosFormulario |
| 5 | TL_ModulosOperacion |
| 6 | TL_ModulosAtributo |
| 7 | TL_ModulosValorInicial |
| 8 | TL_ModulosValorFinal |
| 9 | TL_ModulosFechaMovimiento |
| 10 | TL_ModulosUsuario |

---

## TP_CombSucUN
*TP_Comb Suc UN*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TP_ImpHonoAsim
*Impuestos honorarios asimilables*

### Archivo: `tp_imphonoasim.cs` (prefix='tp_' suffix='', 3235 lineas, 9 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_ImpHonoAsimId |
| 2 | TP_ImpHonoAsimTipo |
| 3 | TP_ImpHonoAsimLimInf |
| 4 | TP_ImpHonoAsimLimSup |
| 5 | TP_ImpHonoAsimFija |
| 6 | TP_ImpHonoAsimPorcentaje |
| 7 | TP_ImpHonoAsimActivo |
| 8 | TP_ImpHonoAsimPeriodoIni |
| 9 | TP_ImpHonoAsimPeriodoFin |

---

## TP_Precios
*TP_Precios*

### Archivo: `tc_productostp_preciosproductoswc.cs` (fallback-fuzzy, 4945 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |

### Archivo: `tp_preciosproductos.cs` (fallback-fuzzy, 3096 lineas, 7 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |
| 2 | TP_PreciosProductosID |
| 3 | TC_ProductosDEs |
| 4 | TP_PreciosProductosPrecio |
| 5 | TP_PreciosProductosFechaHora |
| 6 | TP_PreciosProductos |
| 7 | TP_PreciosProductosVigencia |

### Archivo: `tp_preciosproductosgeneral.cs` (fallback-fuzzy, 1576 lineas, 9 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_PreciosProductosID |
| 2 | TP_PreciosProductosVigencia |
| 3 | TP_PreciosProductos |
| 4 | TP_PreciosProductosFechaHora |
| 5 | TP_PreciosProductosPrecio |
| 6 | TC_ProductosDEs |
| 7 | TC_ProductosId |
| 8 | TP_PreciosProductosID_CTRL |
| 9 | TP_PreciosProductosID_PARM |

### Archivo: `tp_preciosproductosprompt.cs` (fallback-fuzzy, 5881 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductosview.cs` (fallback-fuzzy, 1244 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductoswwexportreport.cs` (fallback-fuzzy, 1472 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductoswwgetfilterdata.cs` (fallback-fuzzy, 1537 lineas, 0 atributos detectados)

---

## TP_ProdcutosOperativo
*Productos Operativos*

### Archivo: `tp_prodcutosoperativo.cs` (exact, 3181 lineas, 8 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_ProdcutosOperativoSexo |
| 2 | TP_ProdcutosOperativoId |
| 3 | TP_ProdcutosOperativoIdProd |
| 4 | TP_ProdcutosOperativoProdDes |
| 5 | TP_ProdcutosOperativoUnidadNego |
| 6 | TP_ProdcutosOperativoTieneFase |
| 7 | TP_ProdcutosOperativoPuesto |
| 8 | TP_ProdcutosOperativoPuestoCerteza |

---

## TP_ProductoSimi
*TP_Producto Simi*

### Archivo: `tp_productosimi.cs` (exact, 2594 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

---

## TP_ProductosStaff
*Productos Staff*

### Archivo: `tp_productosstaff.cs` (exact, 3192 lineas, 8 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_ProductosStaffSexo |
| 2 | TP_ProductosStaffId |
| 3 | TP_ProductosStaffIdprod |
| 4 | TP_ProductosStaffProddDes |
| 5 | TP_ProductosStaffUnidadNego |
| 6 | TP_ProductosStaffComplejidad |
| 7 | TP_ProductosStaffPuesto |
| 8 | TP_ProductosStaffPuestoCerteza |

---

## TP_ReglasConfirmacion
*Reglas de confirmación*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TP_Universo
*Universo de registros*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TP_Usuario
*Usuarios*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TR_SocProTipoCliente
*Sociedad tipo cliente*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TR_UniNegCompledidad
*Unidad de negocio por complejidad*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TR_UsuarioSucursal
*Usuarios sucursal*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## TR_UsuarioUnidadNeg
*Usuario unidad negocio*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---

## UserCustomizations
*User Custom*

**No se encontro archivo .cs candidato con nombre relacionado.** Pendiente: revisar Manual Usuario/Tecnico o buscar con otro criterio.

---
