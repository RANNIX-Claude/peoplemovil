# Inventario FINAL de pantallas complejas -- fusion de Dev\genexus\web + doc\web

Version consolidada: para cada una de las 44 tablas sin formulario en el XPZ, se busco en AMBAS carpetas de codigo generado (son snapshots distintos, cada uno con huecos diferentes) y se tomo el mejor resultado de cada una. Fuente citada por archivo.

---

## Bancos
*Bancos*

### [Dev\genexus\web] `tc_bancos.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |

### [Dev\genexus\web] `tc_bancosgeneral.cs` (general, 5 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |
| 4 | TC_bancosID_CTRL |
| 5 | TC_bancosID_PARM |

### [Dev\genexus\web] `tc_bancoste_empleadowc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |

### [Dev\genexus\web] `tc_bancostp_pensioneswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |

### [doc\web (más completa)] `tc_bancos.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |

### [doc\web (más completa)] `tc_bancosgeneral.cs` (general, 5 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |
| 4 | TC_bancosID_CTRL |
| 5 | TC_bancosID_PARM |

### [doc\web (más completa)] `tc_bancosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `tc_bancoste_empleadowc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |

### [doc\web (más completa)] `tc_bancostp_pensioneswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_bancosID |

---

## Empleados
*Empleados*

### [Dev\genexus\web] `empleados.cs` (exact, 58 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_empleados.cs` (exact, 16 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `empleadosgeneral.cs` (general, 60 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_empleadosgeneral.cs` (general, 17 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_empleadosww.cs` (ww, 0 atributos)

### [Dev\genexus\web] `te_empleadoste_candwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpleadosId |

### [Dev\genexus\web] `te_empleadoste_reservawc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpleadosId |

### [doc\web (más completa)] `empleados.cs` (exact, 58 atributos)

| # | Atributo |
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
| 10 | Lugar_de_Trabajo_Eventos |
| 11 | EmpleadosIdSucursal |
| 12 | Nombre_Sucursal |
| 13 | Regimen_Pago |
| 14 | Ciclo_de_Pago |
| 15 | EmpleadosCorreo_Electronico |
| 16 | IdBanco |
| 17 | EmpleadosNombre_Banco |
| 18 | Cuenta_Banco |
| 19 | Fecha_de_Nacimiento |
| 20 | Estado_de_Nacimiento |
| 21 | EmpleadosRFC |
| 22 | CURP |
| 23 | Credencial_Elector |
| 24 | Cartilla |
| 25 | Estatura |
| 26 | Estado_Civil |
| 27 | Talla |
| 28 | EmpleadosDireccion |
| 29 | Calle |
| 30 | Numero_Exterior |
| 31 | Numero_Interior |
| 32 | Colonia |
| 33 | EmpleadosCodigo_postal |
| 34 | Delegacion_o_Municipio |
| 35 | EmpleadosTelefono_movil |
| 36 | EmpleadosTelefono_particular |
| 37 | Fecha_Ingreso |
| 38 | Fecha_Antiguedad |
| 39 | Fecha_Baja |
| 40 | IdSolicitud |
| 41 | EmpleadosIdEmpresaPagadora |
| 42 | IdEmpresaPagadora_Lista |
| 43 | IdPuesto |
| 44 | NombrePuesto |
| 45 | IdPuesto_Lista2 |
| 46 | EmpleadosCreado |
| 47 | EmpleadosModificado |
| 48 | Grado_de_Estudios |
| 49 | Status_Grado_de_Estudios |
| 50 | Licenciatura_o_Curso |
| 51 | Idiomas |
| 52 | En_Caso_de_Accidente_avisar_A |
| 53 | Cirugias_Tratamientos_y_Padecimientos |
| 54 | Tipo_de_Sangre |
| 55 | Recomendado_Por |
| 56 | Status_Oculto |
| 57 | SobreNombre |
| 58 | Estado_Provincia2 |

### [doc\web (más completa)] `te_empleados.cs` (exact, 16 atributos)

| # | Atributo |
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
| 13 | TC_RegPagoDes |
| 14 | TC_SucursalPagDes |
| 15 | TE_empleadosBusqueda |
| 16 | TE_empleadosUser |

### [doc\web (más completa)] `empleadosgeneral.cs` (general, 59 atributos)

| # | Atributo |
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
| 50 | Porcentaje_Puntualidad |
| 51 | Genero |
| 52 | EmpleadosStatus |
| 53 | Nombre_s_ |
| 54 | Segundo_Apellido |
| 55 | Primer_Apellido |
| 56 | Tipo_de_Empleado |
| 57 | IdEmpleadoEventual |
| 58 | EmpleadosID_CTRL |
| 59 | EmpleadosID_PARM |

### [doc\web (más completa)] `te_empleadosgeneral.cs` (general, 18 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpleadosId |
| 2 | TE_empleadosFormapgo |
| 3 | TE_empleadosUser |
| 4 | TC_SucursalPagDes |
| 5 | TC_SucursalPagId |
| 6 | TC_RegPagoDes |
| 7 | TC_RegPagoId |
| 8 | TE_EmpleadosSolici |
| 9 | TE_EmpleadosApm |
| 10 | TE_EmpleadosApp |
| 11 | TE_EmpleadosNom |
| 12 | TE_EmpleadosAlias |
| 13 | TE_EmpleadosNum |
| 14 | TE_EmpleadosFoto |
| 15 | TE_EmpleadosNomcomp |
| 16 | TE_empleadosBusqueda |
| 17 | TE_EmpleadosId_CTRL |
| 18 | TE_EmpleadosId_PARM |

### [doc\web (más completa)] `empleadosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `te_empleadosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `te_empleadoste_candwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpleadosId |

### [doc\web (más completa)] `te_empleadoste_reservawc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpleadosId |

---

## Pedidos
*Pedidos*

### [Dev\genexus\web] `pedidos.cs` (exact, 46 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `pedidosgeneral.cs` (general, 48 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `pedidos2.cs` (other, 46 atributos)

| # | Atributo |
|---|---|
| 1 | Pedidos2ID |
| 2 | Pedidos2Titulo |
| 3 | Pedidos2Status |
| 4 | Pedidos2IdCliente |
| 5 | Nombre_Cliente2 |
| 6 | RFC_Cliente2 |
| 7 | Direccion_Cliente2 |
| 8 | Pedidos2Telefono_Cliente |
| 9 | Pedidos2IdContacto |
| 10 | Pedidos2Nombre_Contacto |
| 11 | Pedidos2Telefono_Contacto |
| 12 | IdEvento2 |
| 13 | Titulo_Evento2 |
| 14 | Pedidos2IdSucursal |
| 15 | Titulo_Sucursal2 |
| 16 | Pedidos2IdUnidadDeNegocio |
| 17 | Titulo_Unidad_de_Negocio2 |
| 18 | Pedidos2IdPEP |
| 19 | Titulo_PEP2 |
| 20 | Descripcion_PEP2 |
| 21 | IdLugarCita2 |
| 22 | Lugar_Cita2 |
| 23 | Direccion_Lugar_Cita2 |
| 24 | Pedidos2Tipo_de_Movimiento |
| 25 | Pedidos2IdSociedad |
| 26 | Titulo_Sociedad2 |
| 27 | IdSociedadPagadora2 |
| 28 | Titulo_Sociedad_Pagadora2 |
| 29 | IdTipoDeComplejidad2 |
| 30 | Titulo_Tipo_de_Complejidad2 |
| 31 | Duracion_del_Evento_Numero_de_Dias_2 |
| 32 | IdTipoDuracionDelEvento2 |
| 33 | Titulo_Duracion_del_Evento2 |
| 34 | Permitir_Cancelaciones2 |
| 35 | Status_Facturacion2 |
| 36 | SubTotal2 |
| 37 | Pedidos2IVA |
| 38 | Total_Con_IVA2 |
| 39 | Costo_Por_Nomina2 |
| 40 | Creado |
| 41 | IdResponsable2 |
| 42 | Responsable2 |
| 43 | Creado_Por2 |
| 44 | Pedidos2Modificado |
| 45 | Modificado_Por2 |
| 46 | Version_Vigente2 |

### [doc\web (más completa)] `pedidos.cs` (exact, 46 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `pedidosgeneral.cs` (general, 48 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `pedidosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `pedidos2.cs` (other, 46 atributos)

| # | Atributo |
|---|---|
| 1 | Pedidos2ID |
| 2 | Pedidos2Titulo |
| 3 | Pedidos2Status |
| 4 | Pedidos2IdCliente |
| 5 | Nombre_Cliente2 |
| 6 | RFC_Cliente2 |
| 7 | Direccion_Cliente2 |
| 8 | Pedidos2Telefono_Cliente |
| 9 | Pedidos2IdContacto |
| 10 | Pedidos2Nombre_Contacto |
| 11 | Pedidos2Telefono_Contacto |
| 12 | IdEvento2 |
| 13 | Titulo_Evento2 |
| 14 | Pedidos2IdSucursal |
| 15 | Titulo_Sucursal2 |
| 16 | Pedidos2IdUnidadDeNegocio |
| 17 | Titulo_Unidad_de_Negocio2 |
| 18 | Pedidos2IdPEP |
| 19 | Titulo_PEP2 |
| 20 | Descripcion_PEP2 |
| 21 | IdLugarCita2 |
| 22 | Lugar_Cita2 |
| 23 | Direccion_Lugar_Cita2 |
| 24 | Pedidos2Tipo_de_Movimiento |
| 25 | Pedidos2IdSociedad |
| 26 | Titulo_Sociedad2 |
| 27 | IdSociedadPagadora2 |
| 28 | Titulo_Sociedad_Pagadora2 |
| 29 | IdTipoDeComplejidad2 |
| 30 | Titulo_Tipo_de_Complejidad2 |
| 31 | Duracion_del_Evento_Numero_de_Dias_2 |
| 32 | IdTipoDuracionDelEvento2 |
| 33 | Titulo_Duracion_del_Evento2 |
| 34 | Permitir_Cancelaciones2 |
| 35 | Status_Facturacion2 |
| 36 | SubTotal2 |
| 37 | Pedidos2IVA |
| 38 | Total_Con_IVA2 |
| 39 | Costo_Por_Nomina2 |
| 40 | Creado |
| 41 | IdResponsable2 |
| 42 | Responsable2 |
| 43 | Creado_Por2 |
| 44 | Pedidos2Modificado |
| 45 | Modificado_Por2 |
| 46 | Version_Vigente2 |

---

## Pedidos_Detalle
*Pedidos_Detalle*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## Periodos
*Periodos*

### [Dev\genexus\web] `periodos.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | PeriodosID |
| 2 | Fecha_Inicio |
| 3 | Fecha_Fin |
| 4 | Actual |

### [Dev\genexus\web] `tp_periodos.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | TP_PeriodosActual |
| 2 | TP_PeriodosID |
| 3 | TP_PeriodosFecInicio |
| 4 | TP_PeriodosFecFin |

### [Dev\genexus\web] `periodosgeneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | PeriodosID |
| 2 | Actual |
| 3 | Fecha_Fin |
| 4 | Fecha_Inicio |
| 5 | PeriodosID_CTRL |
| 6 | PeriodosID_PARM |

### [Dev\genexus\web] `tp_periodosgeneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | TP_PeriodosID |
| 2 | TP_PeriodosActual |
| 3 | TP_PeriodosFecFin |
| 4 | TP_PeriodosFecInicio |
| 5 | TP_PeriodosID_CTRL |
| 6 | TP_PeriodosID_PARM |

### [doc\web (más completa)] `periodos.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | PeriodosID |
| 2 | Fecha_Inicio |
| 3 | Fecha_Fin |
| 4 | Actual |

### [doc\web (más completa)] `tp_periodos.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | TP_PeriodosActual |
| 2 | TP_PeriodosID |
| 3 | TP_PeriodosFecInicio |
| 4 | TP_PeriodosFecFin |

### [doc\web (más completa)] `periodosgeneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | PeriodosID |
| 2 | Actual |
| 3 | Fecha_Fin |
| 4 | Fecha_Inicio |
| 5 | PeriodosID_CTRL |
| 6 | PeriodosID_PARM |

### [doc\web (más completa)] `tp_periodosgeneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | TP_PeriodosID |
| 2 | TP_PeriodosActual |
| 3 | TP_PeriodosFecFin |
| 4 | TP_PeriodosFecInicio |
| 5 | TP_PeriodosID_CTRL |
| 6 | TP_PeriodosID_PARM |

### [doc\web (más completa)] `periodosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `tp_periodosww.cs` (ww, 0 atributos)

---

## Plazas
*Plazas*

### [Dev\genexus\web] `te_plazas.cs` (exact, 23 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_plazasgeneral.cs` (general, 22 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_plazasdetplazaste_plazasencwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |

### [Dev\genexus\web] `te_plazasencplazaswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |

### [Dev\genexus\web] `te_plazasdet.cs` (other, 9 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TC_PuestosDes |
| 5 | TE_plazasDetPago |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetFechaFin |
| 8 | TE_plazasEncId |
| 9 | TE_plazasDetModificado |

### [Dev\genexus\web] `te_plazasdetgeneral.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TE_plazasDetModificado |
| 5 | TE_plazasDetFechaFin |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetPago |
| 8 | TC_PuestosDes |
| 9 | TC_PuestosId |
| 10 | TE_plazasEncId_CTRL |
| 11 | TE_plazasEncId_PARM |

### [Dev\genexus\web] `te_plazasdette_plazasenc.cs` (other, 10 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_EmpStatus |
| 3 | TE_EmpGenero |
| 4 | ST_PuestosId |
| 5 | TE_plazasEnccontar |
| 6 | TE_EmpPorPuntualidad |
| 7 | TE_EmpIdEmpleadoEventual |
| 8 | TE_EmpleadoBuscar |
| 9 | TE_plazasEncId_CTRL |
| 10 | TE_plazasEncId_PARM |

### [Dev\genexus\web] `te_plazasenc.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpIdEmpleadoEventual |
| 2 | ST_PuestosId |
| 3 | TE_EmpStatus |
| 4 | TE_EmpGenero |
| 5 | TE_EmpleadoBuscar |
| 6 | TE_EmpPorPuntualidad |
| 7 | TE_plazasEnccontar |
| 8 | TE_plazasEncId |
| 9 | TE_EmpNombre |
| 10 | TE_EmpPrimer_Apellido |
| 11 | TE_EmpleadoAlias |

### [Dev\genexus\web] `te_plazasencgeneral.cs` (other, 9 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_EmpStatus |
| 3 | TE_EmpGenero |
| 4 | TE_plazasEnccontar |
| 5 | TE_EmpPorPuntualidad |
| 6 | TE_EmpIdEmpleadoEventual |
| 7 | TE_EmpleadoBuscar |
| 8 | TE_plazasEncId_CTRL |
| 9 | TE_plazasEncId_PARM |

### [Dev\genexus\web] `te_plazasencte_plazasdet.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TE_plazasDetModificado |
| 5 | TE_plazasDetFechaFin |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetPago |
| 8 | TC_PuestosDes |
| 9 | TC_PuestosId |
| 10 | TE_plazasEncId_CTRL |
| 11 | TE_plazasEncId_PARM |

### [doc\web (más completa)] `te_plazas.cs` (exact, 23 atributos)

| # | Atributo |
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
| 16 | TE_PlazasID |
| 17 | TC_PuestosDes |
| 18 | TC_ReglaAsistDes |
| 19 | TE_PlazasModificado |
| 20 | TP_pago_default |
| 21 | TE_EmpNombre |
| 22 | TE_EmpPrimer_Apellido |
| 23 | TE_EmpleadoAlias |

### [doc\web (más completa)] `te_plazasgeneral.cs` (general, 21 atributos)

| # | Atributo |
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
| 11 | TE_PlazasFinVigencia |
| 12 | TE_PlazasInicioVigencia |
| 13 | TC_ReglaAsistMinDesEntr |
| 14 | TC_ReglaAsistMinAntSal |
| 15 | TC_ReglaAsistMinAntEntr |
| 16 | TE_PlazasPago |
| 17 | TE_EmpPorPuntualidad |
| 18 | TE_EmpIdEmpleadoEventual |
| 19 | TE_EmpleadoBuscar |
| 20 | TE_PlazasID_CTRL |
| 21 | TE_PlazasID_PARM |

### [doc\web (más completa)] `te_plazasww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `te_plazasdetplazaste_plazasencwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |

### [doc\web (más completa)] `te_plazasencplazaswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |

### [doc\web (más completa)] `te_plazasdet.cs` (other, 9 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TC_PuestosDes |
| 5 | TE_plazasDetPago |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetFechaFin |
| 8 | TE_plazasEncId |
| 9 | TE_plazasDetModificado |

### [doc\web (más completa)] `te_plazasdetgeneral.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TE_plazasDetModificado |
| 5 | TE_plazasDetFechaFin |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetPago |
| 8 | TC_PuestosDes |
| 9 | TC_PuestosId |
| 10 | TE_plazasEncId_CTRL |
| 11 | TE_plazasEncId_PARM |

### [doc\web (más completa)] `te_plazasdette_plazasenc.cs` (other, 9 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_EmpStatus |
| 3 | TE_EmpGenero |
| 4 | TE_plazasEnccontar |
| 5 | TE_EmpPorPuntualidad |
| 6 | TE_EmpIdEmpleadoEventual |
| 7 | TE_EmpleadoBuscar |
| 8 | TE_plazasEncId_CTRL |
| 9 | TE_plazasEncId_PARM |

### [doc\web (más completa)] `te_plazasenc.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_EmpIdEmpleadoEventual |
| 2 | ST_PuestosId |
| 3 | TE_EmpStatus |
| 4 | TE_EmpGenero |
| 5 | TE_EmpleadoBuscar |
| 6 | TE_EmpPorPuntualidad |
| 7 | TE_plazasEnccontar |
| 8 | TE_plazasEncId |
| 9 | TE_EmpNombre |
| 10 | TE_EmpPrimer_Apellido |
| 11 | TE_EmpleadoAlias |

### [doc\web (más completa)] `te_plazasencgeneral.cs` (other, 9 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_EmpStatus |
| 3 | TE_EmpGenero |
| 4 | TE_plazasEnccontar |
| 5 | TE_EmpPorPuntualidad |
| 6 | TE_EmpIdEmpleadoEventual |
| 7 | TE_EmpleadoBuscar |
| 8 | TE_plazasEncId_CTRL |
| 9 | TE_plazasEncId_PARM |

### [doc\web (más completa)] `te_plazasencte_plazasdet.cs` (other, 11 atributos)

| # | Atributo |
|---|---|
| 1 | TE_plazasEncId |
| 2 | TE_plazasDetVigente |
| 3 | TE_plazasDetPrincipal |
| 4 | TE_plazasDetModificado |
| 5 | TE_plazasDetFechaFin |
| 6 | TE_plazasDetFechaIni |
| 7 | TE_plazasDetPago |
| 8 | TC_PuestosDes |
| 9 | TC_PuestosId |
| 10 | TE_plazasEncId_CTRL |
| 11 | TE_plazasEncId_PARM |

---

## Productos
*Productos*

### [Dev\genexus\web] `tc_productos.cs` (exact, 38 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tc_productosgeneral.cs` (general, 39 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tc_productosww.cs` (ww, 0 atributos)

### [Dev\genexus\web] `tc_productoste_detpedpuestowc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |

### [Dev\genexus\web] `tc_productostp_preciosproductoswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |

### [Dev\genexus\web] `tp_productosimi.cs` (other, 2 atributos)

| # | Atributo |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

### [Dev\genexus\web] `tp_productosstaff.cs` (other, 8 atributos)

| # | Atributo |
|---|---|
| 1 | TP_ProductosStaffSexo |
| 2 | TP_ProductosStaffId |
| 3 | TP_ProductosStaffIdprod |
| 4 | TP_ProductosStaffProddDes |
| 5 | TP_ProductosStaffUnidadNego |
| 6 | TP_ProductosStaffComplejidad |
| 7 | TP_ProductosStaffPuesto |
| 8 | TP_ProductosStaffPuestoCerteza |

### [doc\web (más completa)] `tc_productos.cs` (exact, 38 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |
| 2 | TC_UnidadNegID |
| 3 | TC_PuestosConEntrSer |
| 4 | TC_PuestosMatricial |
| 5 | TC_Puestosmatri |
| 6 | TP_ProductosVigente |
| 7 | TC_ProductosId |
| 8 | TC_ProductosDEs |
| 9 | TC_PuestosDes |
| 10 | TC_UnidadNegDes |
| 11 | TC_PuestosPorCerIni |
| 12 | TC_PuestosPorMin |
| 13 | TP_pago_default |
| 14 | TC_PuestosRetardo |
| 15 | TC_PuestosFalta |
| 16 | TC_PuestosHrasAntesCanPed |
| 17 | TC_PuestosHrasEntrTur |
| 18 | TC_PuestosDuracion |
| 19 | TP_ProductosUnidadNegocioID |
| 20 | TP_ProductosUnidad_de_Negocio |
| 21 | TP_ProductosSubCategoria |
| 22 | TP_ProductosIdPuestoCatalogo |
| 23 | TP_ProductosNumero_Material_SAP |
| 24 | TP_ProductosIdProductoSimilar1 |
| 25 | TP_ProductosProductoSimilar1 |
| 26 | TP_ProductosIdProductoSimilar2 |
| 27 | TP_ProductosProducto_Similar2 |
| 28 | TP_ProductosIdProductoSimilar3 |
| 29 | TP_ProductosProductoSimilar3 |
| 30 | TP_ProductosIdProductoSimilar4 |
| 31 | TP_ProductosProductoSimilar4 |
| 32 | TP_ProductosIdProductoSimilar5 |
| 33 | TP_ProductosProductoSimilar5 |
| 34 | TP_ProductosIdProductoSimilar6 |
| 35 | TP_ProductosProductoSimilar6 |
| 36 | TP_ProductosClave |
| 37 | TP_ProductosTituloCompleto |
| 38 | TP_Productostp_Id |

### [doc\web (más completa)] `tc_productosgeneral.cs` (general, 40 atributos)

| # | Atributo |
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
| 37 | TC_PuestosDes |
| 38 | TC_ProductosDEs |
| 39 | TC_ProductosId_CTRL |
| 40 | TC_ProductosId_PARM |

### [doc\web (más completa)] `tc_productosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `tc_productoste_detpedpuestowc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |

### [doc\web (más completa)] `tc_productostp_preciosproductoswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |

### [doc\web (más completa)] `tp_productosimi.cs` (other, 2 atributos)

| # | Atributo |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

### [doc\web (más completa)] `tp_productosstaff.cs` (other, 8 atributos)

| # | Atributo |
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

## Puestos
*Puestos*

### [Dev\genexus\web] `tc_puestos.cs` (exact, 31 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tc_puestosgeneral.cs` (general, 28 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tc_puestosww.cs` (ww, 0 atributos)

### [Dev\genexus\web] `tc_puestostc_productoswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [Dev\genexus\web] `tc_puestoste_plazasdet1wc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | ST_PuestosId |

### [Dev\genexus\web] `tc_puestoste_plazasdetwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [Dev\genexus\web] `tc_puestoste_plazasenc1wc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | ST_PuestosId |

### [Dev\genexus\web] `tc_puestoste_plazasencwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [Dev\genexus\web] `tc_puestoste_plazaswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [Dev\genexus\web] `tc_puestoste_reqperwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [Dev\genexus\web] `tc_puestoste_vacantewc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestos.cs` (exact, 31 atributos)

| # | Atributo |
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
| 14 | TC_UnidadNegDes |
| 15 | TC_PuestosDes |
| 16 | TC_PuestosHrasEntrTur |
| 17 | TC_PuestosHrasAntesCanPed |
| 18 | TC_PuestosPorCerIni |
| 19 | TC_PuestosPorMin |
| 20 | TC_PuestosDiasSinConf |
| 21 | TC_ReglaAsistDes |
| 22 | TC_PuestosRetardo |
| 23 | TC_PuestosFalta |
| 24 | TP_Id |
| 25 | TP_pago_default |
| 26 | TP_Idunidaddenegocio |
| 27 | TP_puestounidadnegocio |
| 28 | TP_reglaAsistTimescan |
| 29 | TP_PuestosConComplejidad |
| 30 | TC_EmpresaPagadoraNombre |
| 31 | TC_SucursalPagDes |

### [doc\web (más completa)] `tc_puestosgeneral.cs` (general, 31 atributos)

| # | Atributo |
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
| 10 | TC_EmpresaPagadoraId |
| 11 | TP_PuestosConComplejidad |
| 12 | TP_reglaAsistTimescan |
| 13 | TP_puestounidadnegocio |
| 14 | TP_Idunidaddenegocio |
| 15 | TP_pago_default |
| 16 | TP_Id |
| 17 | TC_PuestosFalta |
| 18 | TC_PuestosRetardo |
| 19 | TC_ReglaAsistDes |
| 20 | TC_ReglaAsistId |
| 21 | TC_PuestosDiasSinConf |
| 22 | TC_PuestosPorMin |
| 23 | TC_PuestosPorCerIni |
| 24 | TC_PuestosHrasAntesCanPed |
| 25 | TC_PuestosHrasEntrTur |
| 26 | TC_PuestosDes |
| 27 | TC_UnidadNegDes |
| 28 | TC_UnidadNegID |
| 29 | TC_PuestosDuracion |
| 30 | TC_PuestosId_CTRL |
| 31 | TC_PuestosId_PARM |

### [doc\web (más completa)] `tc_puestosww.cs` (ww, 0 atributos)

### [doc\web (más completa)] `tc_puestostc_productoswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestoste_plazasdet1wc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | ST_PuestosId |

### [doc\web (más completa)] `tc_puestoste_plazasdetwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestoste_plazasenc1wc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | ST_PuestosId |

### [doc\web (más completa)] `tc_puestoste_plazasencwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestoste_plazaswc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestoste_reqperwc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

### [doc\web (más completa)] `tc_puestoste_vacantewc.cs` (wc, 1 atributos)

| # | Atributo |
|---|---|
| 1 | TC_PuestosId |

---

## TA_AltaEmp
*TA_Alta Emp*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TA_ManejoImagenes
*TA_Manejo Imagenes*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TC_ConceptosExtras
*TC_Conceptos Extras*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TC_DocuEmp
*Documentos empleados*

### [Dev\genexus\web] `tc_docuemp.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_docuempID |
| 2 | TC_docuempDescrip |

### [doc\web (más completa)] `tc_docuemp.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_docuempID |
| 2 | TC_docuempDescrip |

---

## TC_Espectaculo
*TC_Espectaculo*

### [Dev\genexus\web] `tc_espectaculo.cs` (exact, 5 atributos)

| # | Atributo |
|---|---|
| 1 | TC_EspectaculoID |
| 2 | TC_EspectaculoDes |
| 3 | TC_EspectaculoDesCta |
| 4 | TC_EspectaculoImagen |
| 5 | TC_EspectaculoImagen_GXI |

### [doc\web (más completa)] `tc_espectaculo.cs` (exact, 5 atributos)

| # | Atributo |
|---|---|
| 1 | TC_EspectaculoID |
| 2 | TC_EspectaculoDes |
| 3 | TC_EspectaculoDesCta |
| 4 | TC_EspectaculoImagen |
| 5 | TC_EspectaculoImagen_GXI |

---

## TC_Inmueble
*TC_Inmueble*

### [Dev\genexus\web] `tc_inmueble.cs` (exact, 11 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `tc_inmueble.cs` (exact, 11 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tc_regpago.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_RegPagoId |
| 2 | TC_RegPagoDes |

### [doc\web (más completa)] `tc_regpago.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_RegPagoId |
| 2 | TC_RegPagoDes |

---

## TC_SegMovCan
*Movientos Candidatos*

### [Dev\genexus\web] `tc_segmovcan.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_SegMovCanId |
| 2 | TC_SegMovCanDes |

### [doc\web (más completa)] `tc_segmovcan.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_SegMovCanId |
| 2 | TC_SegMovCanDes |

---

## TC_Termycond
*Términos y Condiciones*

### [Dev\genexus\web] `tc_termycond.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TC_TermycondId |
| 2 | TC_TermycondTitulo |
| 3 | TC_TermycondObse |

### [doc\web (más completa)] `tc_termycond.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TC_TermycondId |
| 2 | TC_TermycondTitulo |
| 3 | TC_TermycondObse |

---

## TC_TipoCliente
*Tipo Cliente*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TC_TipoMovimiento
*Tipo de movimiento*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TC_bancos2
*TC_bancos2*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TC_socidad
*Socidades*

### [Dev\genexus\web] `tc_socidad.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_socidadId |
| 2 | TC_socidades |

### [doc\web (más completa)] `tc_socidad.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | TC_socidadId |
| 2 | TC_socidades |

---

## TE_CierreNomina
*TE_Cierre Nomina*

### [Dev\genexus\web] `tl_cierrenomina.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TC_PeriodoID |
| 3 | TL_CierreNominaPaso |
| 4 | TL_CierreNominaFechaHora |

### [Dev\genexus\web] `tl_cierrenominageneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TL_CierreNominaFechaHora |
| 3 | TL_CierreNominaPaso |
| 4 | TC_PeriodoID |
| 5 | TL_CierreNominaID_CTRL |
| 6 | TL_CierreNominaID_PARM |

### [doc\web (más completa)] `tl_cierrenomina.cs` (exact, 4 atributos)

| # | Atributo |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TC_PeriodoID |
| 3 | TL_CierreNominaPaso |
| 4 | TL_CierreNominaFechaHora |

### [doc\web (más completa)] `tl_cierrenominageneral.cs` (general, 6 atributos)

| # | Atributo |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TL_CierreNominaFechaHora |
| 3 | TL_CierreNominaPaso |
| 4 | TC_PeriodoID |
| 5 | TL_CierreNominaID_CTRL |
| 6 | TL_CierreNominaID_PARM |

### [doc\web (más completa)] `tl_cierrenominaww.cs` (ww, 0 atributos)

---

## TE_DetPedPuesto
*Puestos Detalle Pedido*

### [Dev\genexus\web] `te_detpedpuesto.cs` (exact, 28 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `te_detpedpuesto.cs` (exact, 28 atributos)

| # | Atributo |
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

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TE_FacturaDetAuxiliar
*Detalle facturas *

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TE_FacturaDetPed
*Detalles Pedidos Factura*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TE_InconsistenciasCierreNomina
*TE_Inconsistencias Cierre Nomina*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TE_Puente
*Puente detalle Puestos*

### [Dev\genexus\web] `te_puente.cs` (exact, 107 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `te_puente.cs` (exact, 107 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `te_registronacs.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TE_RegistroNACSID |
| 2 | TE_EMpleadoID |
| 3 | TE_RegistroNACS |

### [doc\web (más completa)] `te_registronacs.cs` (exact, 3 atributos)

| # | Atributo |
|---|---|
| 1 | TE_RegistroNACSID |
| 2 | TE_EMpleadoID |
| 3 | TE_RegistroNACS |

---

## TL_Modulos
*Movimientos de modulos*

### [Dev\genexus\web] `tl_modulos.cs` (exact, 10 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `tl_modulos.cs` (exact, 10 atributos)

| # | Atributo |
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

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TP_ImpHonoAsim
*Impuestos honorarios asimilables*

### [Dev\genexus\web] `tp_imphonoasim.cs` (exact, 9 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `tp_imphonoasim.cs` (exact, 9 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tp_preciosproductos.cs` (other, 7 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |
| 2 | TP_PreciosProductosID |
| 3 | TC_ProductosDEs |
| 4 | TP_PreciosProductosPrecio |
| 5 | TP_PreciosProductosFechaHora |
| 6 | TP_PreciosProductos |
| 7 | TP_PreciosProductosVigencia |

### [Dev\genexus\web] `tp_preciosproductosgeneral.cs` (other, 9 atributos)

| # | Atributo |
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

### [doc\web (más completa)] `tp_preciosproductos.cs` (other, 7 atributos)

| # | Atributo |
|---|---|
| 1 | TC_ProductosId |
| 2 | TP_PreciosProductosID |
| 3 | TC_ProductosDEs |
| 4 | TP_PreciosProductosPrecio |
| 5 | TP_PreciosProductosFechaHora |
| 6 | TP_PreciosProductos |
| 7 | TP_PreciosProductosVigencia |

### [doc\web (más completa)] `tp_preciosproductosgeneral.cs` (other, 9 atributos)

| # | Atributo |
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

---

## TP_ProdcutosOperativo
*Productos Operativos*

### [Dev\genexus\web] `tp_prodcutosoperativo.cs` (exact, 8 atributos)

| # | Atributo |
|---|---|
| 1 | TP_ProdcutosOperativoSexo |
| 2 | TP_ProdcutosOperativoId |
| 3 | TP_ProdcutosOperativoIdProd |
| 4 | TP_ProdcutosOperativoProdDes |
| 5 | TP_ProdcutosOperativoUnidadNego |
| 6 | TP_ProdcutosOperativoTieneFase |
| 7 | TP_ProdcutosOperativoPuesto |
| 8 | TP_ProdcutosOperativoPuestoCerteza |

### [doc\web (más completa)] `tp_prodcutosoperativo.cs` (exact, 8 atributos)

| # | Atributo |
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

### [Dev\genexus\web] `tp_productosimi.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

### [doc\web (más completa)] `tp_productosimi.cs` (exact, 2 atributos)

| # | Atributo |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

---

## TP_ProductosStaff
*Productos Staff*

### [Dev\genexus\web] `tp_productosstaff.cs` (exact, 8 atributos)

| # | Atributo |
|---|---|
| 1 | TP_ProductosStaffSexo |
| 2 | TP_ProductosStaffId |
| 3 | TP_ProductosStaffIdprod |
| 4 | TP_ProductosStaffProddDes |
| 5 | TP_ProductosStaffUnidadNego |
| 6 | TP_ProductosStaffComplejidad |
| 7 | TP_ProductosStaffPuesto |
| 8 | TP_ProductosStaffPuestoCerteza |

### [doc\web (más completa)] `tp_productosstaff.cs` (exact, 8 atributos)

| # | Atributo |
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

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TP_Universo
*Universo de registros*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TP_Usuario
*Usuarios*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TR_SocProTipoCliente
*Sociedad tipo cliente*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TR_UniNegCompledidad
*Unidad de negocio por complejidad*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TR_UsuarioSucursal
*Usuarios sucursal*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## TR_UsuarioUnidadNeg
*Usuario unidad negocio*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## UserCustomizations
*User Custom*

**No se encontro en ninguna de las dos carpetas.** Confirmado dos veces: pantalla genuinamente inexistente en el codigo generado disponible.

---

## Resumen

- Con campos reales encontrados: 24 de 44
- Genuinamente sin pantalla en ninguna fuente: 20 de 44

Tablas sin pantalla confirmadas (dos fuentes independientes, ambas negativas):
- Pedidos_Detalle
- TA_AltaEmp
- TA_ManejoImagenes
- TC_ConceptosExtras
- TC_TipoCliente
- TC_TipoMovimiento
- TC_bancos2
- TE_Excel
- TE_FacturaDetAuxiliar
- TE_FacturaDetPed
- TE_InconsistenciasCierreNomina
- TP_CombSucUN
- TP_ReglasConfirmacion
- TP_Universo
- TP_Usuario
- TR_SocProTipoCliente
- TR_UniNegCompledidad
- TR_UsuarioSucursal
- TR_UsuarioUnidadNeg
- UserCustomizations