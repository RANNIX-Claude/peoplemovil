# Inventario de pantallas complejas v2 -- extraido de doc\web (fuente mas completa, 1538 archivos)

Re-extraccion de las 44 tablas sin formulario en el XPZ, esta vez contra la carpeta `C:\work\PeopleMovil\doc\web` (el codigo generado para despliegue, mas completo que `Dev\genexus\web`). Se prioriza el archivo de Transaccion exacto (ej. `te_empleado.cs`) sobre el WorkWith/lista (`te_empleadoww.cs`) porque trae el formulario de captura completo, no solo los filtros de busqueda.

---

## Bancos
*Bancos*

### Archivo: `tc_bancos.cs` (exact, 2785 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |

### Archivo: `tc_bancosgeneral.cs` (general, 1445 lineas, 5 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |
| 2 | TC_bancosNombre |
| 3 | TC_BancosIMG |
| 4 | TC_bancosID_CTRL |
| 5 | TC_bancosID_PARM |

### Archivo: `tc_bancosview.cs` (view, 1579 lineas, 0 atributos detectados)

### Archivo: `tc_bancosprompt.cs` (prompt, 4189 lineas, 0 atributos detectados)

### Archivo: `tc_bancosww.cs` (ww, 5965 lineas, 0 atributos detectados)

### Archivo: `tc_bancoste_empleadowc.cs` (wc, 12506 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |

### Archivo: `tc_bancostp_pensioneswc.cs` (wc, 6672 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_bancosID |

---

## Empleados
*Empleados*

### Archivo: `empleados.cs` (exact, 6830 lineas, 58 atributos detectados)

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

### Archivo: `te_empleados.cs` (exact, 4142 lineas, 16 atributos detectados)

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
| 13 | TC_RegPagoDes |
| 14 | TC_SucursalPagDes |
| 15 | TE_empleadosBusqueda |
| 16 | TE_empleadosUser |

### Archivo: `empleadosgeneral.cs` (general, 2963 lineas, 59 atributos detectados)

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

### Archivo: `te_empleadosgeneral.cs` (general, 1937 lineas, 18 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `empleadosview.cs` (view, 1257 lineas, 0 atributos detectados)

### Archivo: `te_empleadosview.cs` (view, 1578 lineas, 0 atributos detectados)

### Archivo: `empleadosprompt.cs` (prompt, 10102 lineas, 0 atributos detectados)

### Archivo: `te_empleadosprompt.cs` (prompt, 7986 lineas, 0 atributos detectados)

### Archivo: `empleadosww.cs` (ww, 18438 lineas, 0 atributos detectados)

### Archivo: `te_empleadosww.cs` (ww, 13526 lineas, 0 atributos detectados)

### Archivo: `te_empleadoste_candwc.cs` (wc, 12218 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_EmpleadosId |

### Archivo: `te_empleadoste_reservawc.cs` (wc, 8729 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_EmpleadosId |

### Archivo: `empleadosconversion.cs` (other, 1730 lineas, 0 atributos detectados)

### Archivo: `empleadosww1.cs` (other, 18438 lineas, 0 atributos detectados)

### Archivo: `te_empleados_bc.cs` (other, 2674 lineas, 0 atributos detectados)

---

## Pedidos
*Pedidos*

### Archivo: `pedidos.cs` (exact, 6363 lineas, 46 atributos detectados)

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

### Archivo: `pedidosgeneral.cs` (general, 3069 lineas, 48 atributos detectados)

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

### Archivo: `pedidosview.cs` (view, 1258 lineas, 0 atributos detectados)

### Archivo: `pedidosprompt.cs` (prompt, 10027 lineas, 0 atributos detectados)

### Archivo: `pedidosww.cs` (ww, 10077 lineas, 0 atributos detectados)

### Archivo: `pedidos2.cs` (other, 6526 lineas, 46 atributos detectados)

| # | Atributo (segun codigo generado) |
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

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## Periodos
*Periodos*

### Archivo: `periodos.cs` (exact, 2754 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PeriodosID |
| 2 | Fecha_Inicio |
| 3 | Fecha_Fin |
| 4 | Actual |

### Archivo: `tp_periodos.cs` (exact, 2806 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_PeriodosActual |
| 2 | TP_PeriodosID |
| 3 | TP_PeriodosFecInicio |
| 4 | TP_PeriodosFecFin |

### Archivo: `periodosgeneral.cs` (general, 1460 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | PeriodosID |
| 2 | Actual |
| 3 | Fecha_Fin |
| 4 | Fecha_Inicio |
| 5 | PeriodosID_CTRL |
| 6 | PeriodosID_PARM |

### Archivo: `tp_periodosgeneral.cs` (general, 1483 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TP_PeriodosID |
| 2 | TP_PeriodosActual |
| 3 | TP_PeriodosFecFin |
| 4 | TP_PeriodosFecInicio |
| 5 | TP_PeriodosID_CTRL |
| 6 | TP_PeriodosID_PARM |

### Archivo: `periodosview.cs` (view, 1258 lineas, 0 atributos detectados)

### Archivo: `tp_periodosview.cs` (view, 1258 lineas, 0 atributos detectados)

### Archivo: `periodosprompt.cs` (prompt, 5411 lineas, 0 atributos detectados)

### Archivo: `tp_periodosprompt.cs` (prompt, 5443 lineas, 0 atributos detectados)

### Archivo: `periodosww.cs` (ww, 7824 lineas, 0 atributos detectados)

### Archivo: `tp_periodosww.cs` (ww, 7752 lineas, 0 atributos detectados)

---

## Plazas
*Plazas*

### Archivo: `te_plazas.cs` (exact, 4906 lineas, 23 atributos detectados)

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
| 16 | TE_PlazasID |
| 17 | TC_PuestosDes |
| 18 | TC_ReglaAsistDes |
| 19 | TE_PlazasModificado |
| 20 | TP_pago_default |
| 21 | TE_EmpNombre |
| 22 | TE_EmpPrimer_Apellido |
| 23 | TE_EmpleadoAlias |

### Archivo: `te_plazasgeneral.cs` (general, 2446 lineas, 21 atributos detectados)

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

### Archivo: `te_plazasview.cs` (view, 1245 lineas, 0 atributos detectados)

### Archivo: `te_plazasprompt.cs` (prompt, 8266 lineas, 0 atributos detectados)

### Archivo: `te_plazasww.cs` (ww, 12447 lineas, 0 atributos detectados)

### Archivo: `te_plazasdetplazaste_plazasencwc.cs` (wc, 6318 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_plazasEncId |

### Archivo: `te_plazasencplazaswc.cs` (wc, 4328 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_plazasEncId |

### Archivo: `te_plazasdet.cs` (other, 3442 lineas, 9 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasdetgeneral.cs` (other, 1678 lineas, 11 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasdetprompt.cs` (other, 5860 lineas, 0 atributos detectados)

### Archivo: `te_plazasdette_plazasenc.cs` (other, 1654 lineas, 9 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasdetview.cs` (other, 1586 lineas, 0 atributos detectados)

### Archivo: `te_plazasdetww.cs` (other, 10688 lineas, 0 atributos detectados)

### Archivo: `te_plazasdetwwexport.cs` (other, 2045 lineas, 0 atributos detectados)

### Archivo: `te_plazasdetwwexportreport.cs` (other, 2097 lineas, 0 atributos detectados)

### Archivo: `te_plazasdetwwgetfilterdata.cs` (other, 1368 lineas, 0 atributos detectados)

### Archivo: `te_plazasenc.cs` (other, 5202 lineas, 11 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasencgeneral.cs` (other, 1644 lineas, 9 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasencplazasprompt.cs` (other, 3940 lineas, 0 atributos detectados)

### Archivo: `te_plazasencprompt.cs` (other, 5279 lineas, 0 atributos detectados)

### Archivo: `te_plazasencte_plazasdet.cs` (other, 1691 lineas, 11 atributos detectados)

| # | Atributo (segun codigo generado) |
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

### Archivo: `te_plazasencview.cs` (other, 1546 lineas, 0 atributos detectados)

### Archivo: `te_plazasencww.cs` (other, 8214 lineas, 0 atributos detectados)

### Archivo: `te_plazasencwwexport.cs` (other, 1387 lineas, 0 atributos detectados)

### Archivo: `te_plazasencwwexportreport.cs` (other, 1367 lineas, 0 atributos detectados)

### Archivo: `te_plazasencwwgetfilterdata.cs` (other, 970 lineas, 0 atributos detectados)

---

## Productos
*Productos*

### Archivo: `tc_productos.cs` (exact, 6128 lineas, 38 atributos detectados)

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

### Archivo: `tc_productosgeneral.cs` (general, 2972 lineas, 40 atributos detectados)

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
| 37 | TC_PuestosDes |
| 38 | TC_ProductosDEs |
| 39 | TC_ProductosId_CTRL |
| 40 | TC_ProductosId_PARM |

### Archivo: `tc_productosview.cs` (view, 1574 lineas, 0 atributos detectados)

### Archivo: `tc_productosprompt.cs` (prompt, 10747 lineas, 0 atributos detectados)

### Archivo: `tc_productosww.cs` (ww, 14246 lineas, 0 atributos detectados)

### Archivo: `tc_productoste_detpedpuestowc.cs` (wc, 12288 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |

### Archivo: `tc_productostp_preciosproductoswc.cs` (wc, 6165 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |

### Archivo: `tp_productosimi.cs` (other, 2578 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

### Archivo: `tp_productosstaff.cs` (other, 3176 lineas, 8 atributos detectados)

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

## Puestos
*Puestos*

### Archivo: `tc_puestos.cs` (exact, 5873 lineas, 31 atributos detectados)

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

### Archivo: `tc_puestosgeneral.cs` (general, 2510 lineas, 31 atributos detectados)

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

### Archivo: `tc_puestosview.cs` (view, 2461 lineas, 0 atributos detectados)

### Archivo: `tc_puestosprompt.cs` (prompt, 10855 lineas, 0 atributos detectados)

### Archivo: `tc_puestosww.cs` (ww, 17883 lineas, 0 atributos detectados)

### Archivo: `tc_puestostc_productoswc.cs` (wc, 11010 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

### Archivo: `tc_puestoste_plazasdet1wc.cs` (wc, 7185 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | ST_PuestosId |

### Archivo: `tc_puestoste_plazasdetwc.cs` (wc, 4835 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

### Archivo: `tc_puestoste_plazasenc1wc.cs` (wc, 6558 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | ST_PuestosId |

### Archivo: `tc_puestoste_plazasencwc.cs` (wc, 6808 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

### Archivo: `tc_puestoste_plazaswc.cs` (wc, 6790 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

### Archivo: `tc_puestoste_reqperwc.cs` (wc, 11515 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

### Archivo: `tc_puestoste_vacantewc.cs` (wc, 7841 lineas, 1 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_PuestosId |

---

## TA_AltaEmp
*TA_Alta Emp*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TA_ManejoImagenes
*TA_Manejo Imagenes*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TC_ConceptosExtras
*TC_Conceptos Extras*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TC_DocuEmp
*Documentos empleados*

### Archivo: `tc_docuemp.cs` (exact, 2595 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_docuempID |
| 2 | TC_docuempDescrip |

---

## TC_Espectaculo
*TC_Espectaculo*

### Archivo: `tc_espectaculo.cs` (exact, 2715 lineas, 5 atributos detectados)

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

### Archivo: `tc_inmueble.cs` (exact, 3319 lineas, 11 atributos detectados)

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

### Archivo: `tc_regpago.cs` (exact, 2620 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_RegPagoId |
| 2 | TC_RegPagoDes |

---

## TC_SegMovCan
*Movientos Candidatos*

### Archivo: `tc_segmovcan.cs` (exact, 2593 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_SegMovCanId |
| 2 | TC_SegMovCanDes |

---

## TC_Termycond
*Términos y Condiciones*

### Archivo: `tc_termycond.cs` (exact, 2695 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_TermycondId |
| 2 | TC_TermycondTitulo |
| 3 | TC_TermycondObse |

---

## TC_TipoCliente
*Tipo Cliente*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TC_TipoMovimiento
*Tipo de movimiento*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TC_bancos2
*TC_bancos2*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TC_socidad
*Socidades*

### Archivo: `tc_socidad.cs` (exact, 2587 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_socidadId |
| 2 | TC_socidades |

---

## TE_CierreNomina
*TE_Cierre Nomina*

### Archivo: `tl_cierrenomina.cs` (exact, 2729 lineas, 4 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TC_PeriodoID |
| 3 | TL_CierreNominaPaso |
| 4 | TL_CierreNominaFechaHora |

### Archivo: `tl_cierrenominageneral.cs` (general, 1452 lineas, 6 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TL_CierreNominaID |
| 2 | TL_CierreNominaFechaHora |
| 3 | TL_CierreNominaPaso |
| 4 | TC_PeriodoID |
| 5 | TL_CierreNominaID_CTRL |
| 6 | TL_CierreNominaID_PARM |

### Archivo: `tl_cierrenominaview.cs` (view, 1252 lineas, 0 atributos detectados)

### Archivo: `tl_cierrenominaprompt.cs` (prompt, 4665 lineas, 0 atributos detectados)

### Archivo: `tl_cierrenominaww.cs` (ww, 7034 lineas, 0 atributos detectados)

---

## TE_DetPedPuesto
*Puestos Detalle Pedido*

### Archivo: `te_detpedpuesto.cs` (exact, 5126 lineas, 28 atributos detectados)

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

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TE_FacturaDetAuxiliar
*Detalle facturas *

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TE_FacturaDetPed
*Detalles Pedidos Factura*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TE_InconsistenciasCierreNomina
*TE_Inconsistencias Cierre Nomina*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TE_Puente
*Puente detalle Puestos*

### Archivo: `te_puente.cs` (exact, 11841 lineas, 107 atributos detectados)

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

### Archivo: `te_puente_bc.cs` (other, 7206 lineas, 0 atributos detectados)

---

## TE_RegistroNACS
*TE_Registro NACS*

### Archivo: `te_registronacs.cs` (exact, 2652 lineas, 3 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TE_RegistroNACSID |
| 2 | TE_EMpleadoID |
| 3 | TE_RegistroNACS |

---

## TL_Modulos
*Movimientos de modulos*

### Archivo: `tl_modulos.cs` (exact, 3285 lineas, 10 atributos detectados)

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

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TP_ImpHonoAsim
*Impuestos honorarios asimilables*

### Archivo: `tp_imphonoasim.cs` (exact, 3219 lineas, 9 atributos detectados)

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

### Archivo: `tp_preciosproductos.cs` (other, 3102 lineas, 7 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | TC_ProductosId |
| 2 | TP_PreciosProductosID |
| 3 | TC_ProductosDEs |
| 4 | TP_PreciosProductosPrecio |
| 5 | TP_PreciosProductosFechaHora |
| 6 | TP_PreciosProductos |
| 7 | TP_PreciosProductosVigencia |

### Archivo: `tp_preciosproductosgeneral.cs` (other, 1584 lineas, 9 atributos detectados)

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

### Archivo: `tp_preciosproductosprompt.cs` (other, 5874 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductosview.cs` (other, 1252 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductosww.cs` (other, 9061 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductoswwexport.cs` (other, 1514 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductoswwexportreport.cs` (other, 1480 lineas, 0 atributos detectados)

### Archivo: `tp_preciosproductoswwgetfilterdata.cs` (other, 1545 lineas, 0 atributos detectados)

---

## TP_ProdcutosOperativo
*Productos Operativos*

### Archivo: `tp_prodcutosoperativo.cs` (exact, 3165 lineas, 8 atributos detectados)

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

### Archivo: `tp_productosimi.cs` (exact, 2578 lineas, 2 atributos detectados)

| # | Atributo (segun codigo generado) |
|---|---|
| 1 | IdProducto |
| 2 | IdProductoSimi |

---

## TP_ProductosStaff
*Productos Staff*

### Archivo: `tp_productosstaff.cs` (exact, 3176 lineas, 8 atributos detectados)

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

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TP_Universo
*Universo de registros*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TP_Usuario
*Usuarios*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TR_SocProTipoCliente
*Sociedad tipo cliente*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TR_UniNegCompledidad
*Unidad de negocio por complejidad*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TR_UsuarioSucursal
*Usuarios sucursal*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## TR_UsuarioUnidadNeg
*Usuario unidad negocio*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---

## UserCustomizations
*User Custom*

**Sin archivo candidato ni en esta carpeta.** Confirma que genuinamente no existe pantalla generada.

---
