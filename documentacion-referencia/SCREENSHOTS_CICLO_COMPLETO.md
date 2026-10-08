# Ciclo Completo — Análisis de screenshots (video "Ciclo completo", 20 - Ciclo completo)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\20 - Ciclo completo\`
225 frames, video de 13m32s (`https://youtu.be/8_uJAljE3-M`). Muestreo representativo de ~51 frames espaciados a lo largo de todo el video (aprox. cada 5 frames, más algunos frames intermedios de relleno en zonas de transición).

IMPORTANTE sobre el método de grabación: el operador tiene **varias pestañas del navegador abiertas en paralelo** (Correo/Outlook, y 2-4 pestañas de la app RRHH) y va saltando entre ellas. Por eso el orden de aparición de los frames en el video NO es estrictamente el orden de clics de una sola pantalla seguida — es una mezcla de 2-3 flujos que avanzan en paralelo (flujo de reclutamiento en una pestaña, flujo de nómina en otra, correo en una tercera). El "flujo real" de negocio de abajo está reconstruido combinando el orden de aparición con la lógica de datos (folios, IDs de empleado, etc.) que sí es secuencial.

---

## 1. FLUJO REAL (secuencia de pantallas/módulos del ciclo completo)

Candidato ya pasó por entrevista agrupada → Freelance dado de alta como empleado → asignado a un Pedido/evento → asistencia registrada → pagado vía nómina de honorarios → dispersión/exportación contable.

1. **Grupos para entrevistas** (lista) — RRHH ▸ (`wp_registrosasistenciacandidatos.aspx`) — `001_00m00s.png`, `006_00m24s.png`
2. **Lista de candidatos en grupo** (detalle de un grupo de entrevista: asistencia + documentos) — (`wp_registroasistenciacandidatos_lista.aspx?UPD=...`) — `003_00m10s.png`, `058_03m34s.png`
3. **Firma de contratos** (lista, mismo layout que "Grupos para entrevistas" pero para la etapa de firma) — (`wp_firmadecontratos.aspx`) — `011_00m39s.png`
4. **Lista firma de contrato** (detalle: asistió, doc. completos, folio, resultado de entrevista, asignación de curso de inducción) — (`wp_firmadecontratos_lista.aspx?UPD=...`) — `016_00m55s.png`
5. **Correo saliente automático**: "Notificación curso de inducción" al candidato (fecha, hora, lugar, código de vestimenta) — Outlook — `021_01m17s.png`
6. **Lista candidatos curso de inducción** (asignar "Evento Prueba", marcar asistencia, cambiar de grupo) — (`wp_cursosdeinduccioncandidatos_lista.aspx?UPD=...`) — `026_01m40s.png`
7. Modal **"ACTUALIZAR ASISTENCIA"** → confirma alta de asistencia al curso (dispara alta automática de empleados) — `031_01m57s.png`
8. **Empleado** (listado, ahora el candidato aceptado ya aparece como empleado "Activo") — RRHH ▸ (`te_empleadoww.aspx`) — `036_02m14s.png`
9. **Plazas empleados** (asigna Puesto, Pago, Unidad de negocio a la nueva plaza del empleado) — Nómina ▸ (`te_plazasww.aspx`) — `041_02m31s.png`
10. **Detalles de pedido** (formulario del pedido/evento: tipo de personal, lugar, fechas, cantidad de turnos; grid de contactos/empleados confirmados al pedido) — Operaciones ▸ Pedidos (`wp_pedidodetalle.aspx?<id>`) — `046_02m54s.png`, `051_03m11s.png`
11. **Correo saliente automático**: "Registro alta de empleados" con PDF adjunto "Relación de personal dado de alta" — Outlook — `056_03m32s.png`, `061_03m41s.png`
12. **Pedidos** (listado principal) + menú **Operaciones** desplegado completo — (`te_pedidoww.aspx`) — `066_03m59s.png`
13. **Registro asistencia manual** — formulario inicial (buscar Pedido Detalle) — (`wp_regasistman.aspx`) — `068_04m06s.png`
14. **Registro asistencia manual** — pestaña "Reservaciones": marcar Asistencia/Retardo/Falta por persona, Confirmar Lista — `071_04m15s.png`
15. Modal **"Actualizar lista de Asistencia de Asistencia"** → confirma procesar N registros — `076_04m29s.png`
16. **Inicio** (home en blanco) — `081_04m53s.png`
17. **Pago honorarios** (consulta general de honorarios por régimen/banco/empresa pagadora; nuevos empleados aparecen con banco "No definido") — Nómina ▸ (`wp_consultahonorarios.aspx`) — `086_05m09s.png`, `091_05m21s.png`, `096_05m42s.png`, `101_05m56s.png`, `103_06m02s.png`
18. **Asignación Folios** (por empleado: captura Núm. folio, selecciona reservaciones a procesar, Asignar) — Nómina ▸ (`wp_asignacionfolios.aspx`) — `106_06m20s.png`, `111_06m33s.png`, `116_06m52s.png`, `121_07m11s.png`
19. Modal **"Asignación de folios"** → confirma folio para N registros (se repite por cada empleado) — `126_07m37s.png`
20. **Pago honorarios** (recarga, los folios ya quedan asignados pero banco sigue "No definido" para los freelance nuevos) — `131_07m46s.png`, `136_08m04s.png`, `141_08m24s.png`
21. **Cierre de nómina** (primera vista, campo Fecha vacío) — Nómina ▸ (`wp_cierredenominaperiodo.aspx`) — `146_08m36s.png`
22. Menú **Nómina** desplegado completo (catálogo de 18 opciones) — `151_09m07s.png`, `181_10m39s.png`, `208_12m28s.png`
23. **Cuentas de banco empleados** (captura Banco/Cuenta por Id Emp. para corregir "No definido") — Nómina ▸ Cambio de cuenta de banco (`te_ctasbcoempww.aspx`) — `156_09m22s.png`
24. **Cierre de nómina** (grid recargado, bancos ya asignados) — `161_09m41s.png`, `166_09m53s.png`
25. **Cierre de nómina** — error de validación **"Debe ingresar una fecha correcta"** (campo Fecha vacío) — `171_10m18s.png`
26. Modal **"CIERRE DE NÓMINA"** → "Se Confirman 20 REGISTRO(S) a procesar para el periodo : 1087" — `176_10m28s.png`
27. **Pago honorarios** (post-cierre: columna "Periodo pago" ahora muestra 1087 para todos) — `186_10m51s.png`, `191_11m08s.png`, `193_11m18s.png`
28. **Dispersión Nómina** (selecciona Periodo, descarga 4 archivos XLS: Lobo Honorarios Asimilables / Normales, Otras Hon. Asimilables / Normales) — Nómina ▸ (`wp_dispersionexcelgeneracion.aspx`) — `196_11m33s.png`
29. **Excel generado** "ArchivoBaseNomina3002.xlsx" (y luego otro, "ArchivoBaseNomina4170.xlsx", para otra Unidad de Negocio/Sociedad) — pestañas: Concentrado General Sociedad, Dispersión Columnas, Datos Empleados, Desglose Dispersion, Reservaciones Pagos Desglosado, Facturacion — `201_12m01s.png`, `206_12m14s.png`, `211_12m43s.png`, `216_13m07s.png`, `221_13m19s.png`, `225_13m32s.png`

Fin del video en la revisión de los Excel de dispersión/facturación (`225_13m32s.png`).

---

## 2. DETALLE POR PANTALLA

### 2.1 Grupos para entrevistas (lista)
`001_00m00s.png`, `006_00m24s.png` — url `wp_registrosasistenciacandidatos.aspx`
- Toolbar: botón `+` (nuevo), exportar XLS, exportar PDF, "Selecciona columnas"
- Filtro: "Buscar en" [combo: Hora cita] — "valor" [combo: Comienza con] — [textbox] — botón limpiar (X)
- Columnas de grid: **Hora cita** (fecha+hora), **Puesto**, **Nombre de vacante**, **Estatus de grupo** (Activo), **Sucursal** (CDMX), **% Disponibilidad** (puede ser negativo, ej. -50, -45), **Cupo**, **Núm.Candidatos**, **En proceso**
- Cada fila tiene 3 iconos de acción a la izquierda (ojo/buscar, reloj, aspa/eliminar)
- Paginación "Página 1 de 1", "Ant"/"Sig"
- Ejemplo de datos: Puesto "Acomodador", vacante "VacanteTit00034", Sucursal CDMX

### 2.2 Lista de candidatos en grupo
`003_00m10s.png`, `058_03m34s.png` — url `wp_registroasistenciacandidatos_lista.aspx?UPD=<id>,<hora>%2F<fecha>+<puesto>...`
- Grid: **Folio**, **Nombre completo**, **Sexo**, **¿Asistió?** (checkbox), **¿Documentos Completos?** (checkbox), **Cambiar grupo** (icono engranaje)
- Botones: "Actualizar Lista", "Cancelar"
- Todos los checkboxes vienen pre-marcados (true) en los datos de prueba vistos

### 2.3 Firma de contratos (lista)
`011_00m39s.png` — url `wp_firmadecontratos.aspx`
- Mismo layout/columnas que "Grupos para entrevistas" (Hora cita, Puesto, Nombre de vacante, Estatus de grupo, Sucursal, % Disponibilidad, Cupo, Núm.Candidatos, En proceso)
- Más filas de ejemplo visibles: puestos "Seguridad" (vacante "Vigiliante001" [sic, typo en sistema original]), "Acomodador", "Taquilleros" (vacante "Taquilleros para Playa Limbo"), "Stage Hand" (vacante "Stage Hand para evento")

### 2.4 Lista firma de contrato
`016_00m55s.png` — url `wp_firmadecontratos_lista.aspx?UPD=...`
- Grid: **¿Asistió?** (checkbox), **Doc.Com.** (checkbox doc. completos), **Folios** (num.), **Nombre completo** (3 líneas: Nombre, ApPat, ApMat concatenados), **Resultado** (dropdown — valor visto: "Aceptado"), **Curso de inducción** (dropdown con fecha+hora+código, ej. "16/07/19 07:00 | D-20")
- Botones: "Actualizar Lista", "Cancelar"

### 2.5 Correo — Notificación curso de inducción
`021_01m17s.png` — Outlook, remitente `registro.sistema.freelance@gmail.com`, asunto "Notificación curso de inducción"
- Cuerpo (plantilla automática):
  - "Confirmación de curso de inducción"
  - "Estimado(a): <Nombre Candidato>"
  - "¡Ya estás a un paso! Agradecemos tu interés y compromiso en tu proceso de selección."
  - "Te confirmamos los datos para tu curso de inducción:"
  - **Día:** 16/07/19
  - **Hora:** 07:00
  - **Lugar:** Av. Río Churubusco esq. con Añil s/n, Puerta 1. Recepción Lobo. Palacio de los Deportes, Col. Granjas México, Ciudad de México.
  - "Favor de presentar Identificación Oficial."
  - "Recuerda que debes asistir con el código de vestimenta:" (texto cortado en el frame)

### 2.6 Lista candidatos curso de inducción
`026_01m40s.png` — url `wp_cursosdeinduccioncandidatos_lista.aspx?UPD=...`
- Campo **Evento prueba** (dropdown grande con decenas de eventos reales, formato "FECHA HH:MM-NOMBRE EVENTO-TIPO | Descripción"), valor por defecto "No asignado"
  - Ejemplos de opciones vistas: "05/03/19 06:00-GREEN DAY 2019-Seguridad-In | Green Day 2019 - Escenario 19-2", "27/02/19 07:00-JACOB WHITESIDES 2019-Seguridad-In", "26/03/19 00:00-GREEN DAY 2019-Seguridad-Ma", "29/03/19 14:00-SIDONIE-Seguridad-In | Sidonie Escenario 16", "01/06/19 10:00-FERIA DEL JUGUETE 2017-Local Crew-IN", "11/07/19 06:00-JACOB WHITESIDES 2019-Acomodador-MA", "15/07/19 15:00-FUTBOL AMÉRICA VS PUMAS-Seguridad-IN | Futbol América vs Pumas seguridad Azteca", "18/06/19 16:00-FERIA DEL JUGUETE 2017-Seguridad-IN"
- Grid: Id, Publicación, Folios, Nombre completo, **¿Asistió?** (checkbox), **Evento Prueba** (dropdown por fila), **Cambiar grupo** (icono engranaje)
- Botones: "Actualizar Lista", "Cancelar"

### 2.7 Modal — Actualizar asistencia (curso de inducción)
`031_01m57s.png`
- Título: "ACTUALIZAR ASISTENCIA"
- Texto: "¿Confirmar asistencia de : 10 Registros ?"
- Botones: "Sí" / "No"

### 2.8 Empleado (listado)
`036_02m14s.png` — url `te_empleadoww.aspx`
- Filtro: "Buscar en" [Nombre Completo] / valor
- Columnas: **Id**, **Nombre Completo**, **Estatus** (Activo), **Sexo** (Masculino), **Certeza** (score decimal, ej. 0.90), **Correo electrónico**, **Sucursal** (CDMX)
- Fila "+" nuevo, exportar XLS/PDF, "Selecciona columnas"
- Correo visto en todos los empleados de prueba: `calvario.marron.leonardo@outlook.com` (cuenta del probador reutilizada como correo de los candidatos de prueba)

### 2.9 Plazas empleados
`041_02m31s.png` — url `te_plazasww.aspx`
- Columnas: **Id empleado**, **Nombre**, **Sexo**, **Certeza**, **Estatus** (dropdown inline: Activo), **Pago** (0.00), **Id puesto**, **Puesto** (ej. "Acomodador", "Seguridad" — enlaces), **Pago default** (ej. 100.00, 300.00), **Unidad negocio** (ej. "Control de Accesos", "Seguridad"), **Inicio** (fecha/hora alta)
- Filtro: Buscar en [Nombre] / Comienza con

### 2.10 Detalles de pedido
`046_02m54s.png`, `051_03m11s.png` — url `wp_pedidodetalle.aspx?<id>` (ej. `1048`)
- Campo **Presupuesto por día** ($1,000.00)
- Sección "Movimientos detalles pedido", tab **Detalles**:
  - **Estatus** (Vigente, solo lectura), **Evento Práctica** (checkbox)
  - **Tipo personal\*** (ej. "Operativo")
  - **Título\*** (ej. "Jacob Whitesides 2019")
  - **Producto** (dropdown, "Ninguno")
  - **Lugar de Cita\*** (dropdown, ej. "Hotel Crowne Plaza México")
  - **Dirección cita** (texto, ej. "Dakota número 95, Colonia Nápoles...")
  - **Otro** (checkbox)
  - **Indicaciones especiales** (textarea)
  - **Cantidad** / **Turnos** (numéricos)
  - **Fecha cita\*** (fecha + hora inicio/fin dropdown)
  - **Fecha liberación**
  - **Fecha final cita**
  - **Presentación por producto** (dropdown, "(Ninguno)")
  - **Completar con similares** (dropdown, "NO")
- Grid inferior (scrolleado): **IdContacto**, **Nombre completo**, **Estatus** (ej. "CONFIRMADO FORZADO"), icono quitar (X) por fila
- Botón "Imprimir lista de Asistencia" (icono impresora)

### 2.11 Correo — Registro alta de empleados (con PDF)
`056_03m32s.png`, `061_03m41s.png` — Outlook, remitente `registro.sistema.freelance@gmail.com`, asunto "Notificación del sistema"
- Adjunto: PDF `15072019_15_19.pdf` (2 KB)
- Cuerpo: "Anexo la presente enviamos la relación de los candidatos que han sido seleccionados y dados de alta como personal Freelance de manera automática." — firmado "Erika Lara / Administración de personal"
- Vista previa del PDF: título **"Relación de personal dado de alta con fecha: 15/07/19"**
  - Columnas: **Num.Empleado**, **Nombre**, **Puesto** (ej. "SEGURIDAD"), **Solicitud** (número de folio/solicitud)

### 2.12 Pedidos (listado) + menú Operaciones
`066_03m59s.png` — url `te_pedidoww.aspx`
- Columnas: **Id**, **Título** (ej. "Jacob Whitesides 2019", "Concierto especial 2019 Esc 26", "Futbol América vs Pumas", "Green Day 2019 cambio lugar", "Green Day 2019 Nómina"), **Sucursal**, **lugar**, **Responsable**, **Complejidad** ("Servicio interno" / "Pedido"), **T.Mov**, **PeP | Descripción** (código tipo "EL-TF-2018-05-18T009IP-A Ha Ash")
- Menú **Operaciones** (submenú completo visto): Contactos, Clientes, Contactos clientes, Eventos, Lugares de Cita, Unidad de Negocio, Carga masiva Peps, Peps masivos, Peps y Centros de Costos, Pedidos, Facturación, Listas de asistencia, **Registro manual de asistencia** (resaltado/activo), Consulta reservaciones, Requisición de Personal, TimeScan por Empleado, TimeScan por Detalle Pedido

### 2.13 Registro asistencia manual — formulario inicial
`068_04m06s.png` — url `wp_regasistman.aspx`
- Sección "Datos generales": **Pedido Detalle\*** (input con icono lupa/lookup + icono ayuda "?"), **Título** (solo lectura, se llena tras elegir pedido), **Evento**, **Fecha cita**, **Dirección lugar de cita**, **Unidad de negocio** ("(Ninguno)" por defecto)

### 2.14 Registro asistencia manual — tab Reservaciones
`071_04m15s.png` — mismo url
- Tab "Reservaciones"
- Grid: **Nombre completo**, **Tipo** (Reservación), **Estatus** (CONFIRMADO FORZADO), botones por fila **[Asistencia] [Retardo] [Falta]**, **Pago** ($100.00)
- Botones: "Confirmar Lista", "Cancelar"

### 2.15 Modal — Actualizar lista de Asistencia
`076_04m29s.png`
- Título: "Actualizar lista de Asistencia de Asistencia" (texto duplicado tal cual en el sistema original)
- Texto: "Procesar 10 con registro de asistencia"
- Botones: "Sí" / "No"

### 2.16 Inicio
`081_04m53s.png` — url `wwpbaseobjects.home.aspx` — página en blanco (dashboard vacío)

### 2.17 Pago honorarios
`086_05m09s.png`…`193_11m18s.png` (varios momentos) — url `wp_consultahonorarios.aspx`
- Columnas (vista ancha, `141_08m24s.png`): **Id**, **Nombre Completo**, **Régimen** (Honorarios Normales / Honorarios Asimilables), **Periodo pago** (número, ej. 1087; 0 antes del cierre), **Banco** (Bancomer, Banorte, HSBC, Inbursa, "No definido"), **Cuenta**, **Pago bruto**, **Pago neto**, **Empresa pagadora** (ej. "Tecno Inter, S.A. De C.V."), **Unidad de negocio** (Seguridad, PRG, Producción, Control de Accesos)
- Antes de asignar banco: fila con pago bruto negativo visible ej. "-$300.00" → "$0.00" neto (caso de ajuste/descuento)
- Empleados nuevos (CandNombre00208...00217) aparecen con **Banco = "No definido"**, Cuenta = 0, hasta que se corrige en "Cambio de cuenta de banco"

### 2.18 Asignación Folios
`106_06m20s.png`…`126_07m37s.png` — url `wp_asignacionfolios.aspx`
- Sección "Datos empleado": **Nombre** (solo lectura), foto del empleado (placeholder "Foto" si no hay imagen, o foto real), **Sucursal** (ej. Queretaro), **Estatus** (Activo), **Reg.pago** (Honorarios Normales), **Núm.folio\*** (input, ej. "XCNDJ686", "KGIFJRU67" — strings alfanuméricos), link **"Ver Reservaciones con folio"**
- Grid: **Id Reservación**, **Pedido**, **Id detalle**, **Título** (ej. "Concierto especial 2019 Esc 25"), **Puesto** (ej. "Productor B", "Runner", "Seguridad"), **Fecha**, **Turnos**, **Estado Asistencia** (Asistencia), **Pago Real** (ej. $9,700.00, $5,600.00, $300.00), **Tipo** (Reservación), **Procesar** (checkbox), fila **TOTAL**
- Botones: "Asignar", "Cancelar" ; paginación "Ant"/"Sig"

### 2.19 Modal — Asignación de folios
`126_07m37s.png`
- Título: "Asignación de folios"
- Texto: "Confirmar el FOLIO :KGIFJRU67 Para los :1 registros de Reservaciones"
- Botones: "Sí" / "No"

### 2.20 Menú Nómina (catálogo completo)
`091_05m21s.png`, `151_09m07s.png`, `181_10m39s.png`, `208_12m28s.png`
- Alta masiva de empleados
- Alta individual empleado
- Listado de empleados
- Desactivación empleado
- Reactivación empleado
- Cambio de cuenta de banco
- Observaciones empleado
- Plazas empleados
- Sueldos matriciales (submenú, flecha ▸)
- Listas de asistencia
- Alta Masiva extras
- Extras
- Autorización Extras
- Asignación de folios
- Pago de honorarios
- Cierre de nómina
- Dispersión nómina
- Lista negra
- Aclaraciones (cortado en el frame, probablemente hay más opciones abajo)

### 2.21 Cuentas de banco empleados
`156_09m22s.png` — url `te_ctasbcoempww.aspx?INS,0`
- Encabezado "Información General"
- **Id Emp.\*** (input numérico + icono lupa)
- **Nombre Completo** (solo lectura, se autocompleta)
- **Banco\*** (dropdown) — opciones vistas: (Ninguno), 13, 14, 15, 16, 17 (códigos numéricos sin nombre — posible dato de catálogo incompleto/legacy), Banamex CCC, Bancomer, Banorte, Doce, HSBC, Inbursa, IXE, once, Santander, Scotia Bank, Serfin ssss, Sin Banco
- **Cuenta\*** (input)
- Botones: "Confirmar", "Cancelar"
- Nota: catálogo de bancos tiene entradas basura ("13".."17", "Doce", "once" en minúsculas) — típico de un catálogo GeneXus mal curado; para PeopleMovil usar un catálogo de bancos limpio (CLABE/banco estándar SPEI)

### 2.22 Cierre de nómina
`146_08m36s.png`, `161_09m41s.png`, `166_09m53s.png`, `171_10m18s.png`, `176_10m28s.png` — url `wp_cierredenominaperiodo.aspx`
- Sección "Información General": **Periodo:** (ej. 1087), **Fecha inicial** (ej. 02/07/19 02:04:00), **Fecha final** (vacío hasta cerrar, `/ /  00:00:00`)
- Sección "Fecha final del cierre actual": campo **Fecha** (date+time picker) — **obligatorio**
- Grid: **Id**, **Nombre**, **Banco**, **Num.Cta.**, **Te_pagos Regimen** (Honorarios Asimilables/Normales), **Empresa pagadora**, **Días Trab.**, **Pago neto**
- Botones: "Lista de precauciones", "Cierre de nómina"
- **Validación**: si se intenta cerrar sin capturar Fecha → mensaje de error en banner naranja arriba: **"Debe ingresar una fecha correcta"**
- Fila con banco "No definido" se resalta en **rojo** dentro del grid (señal visual de bloqueo/advertencia) — visto en `161_09m41s.png` para el empleado 65858
- Modal de confirmación: **"CIERRE DE NÓMINA"** → "Se Confirman 20 REGISTRO(S) a procesar para el periodo : 1087" — botones "Sí"/"No"

### 2.23 Dispersión Nómina
`196_11m33s.png` — url `wp_dispersionexcelgeneracion.aspx`
- Campo **Periodo** (dropdown, ej. 1087)
- 4 botones de descarga (icono XLS verde), cada uno con su etiqueta: **"Lobo Honorarios Asimilables"**, **"Lobo Honorarios Normales"**, **"Otras Hon.Asimilables"**, **"Otras Hon.Normales"**
- Texto "Descargar" debajo de la fila de iconos

### 2.24 Excel de dispersión generado (ArchivoBaseNomina####.xlsx)
`201_12m01s.png`…`225_13m32s.png` — abiertos en Excel, modo "Vista protegida" al inicio
- Pestañas vistas: **Concentrado General Sociedad**, **Dispersión Columnas**, **Datos Empleados**, **Desglose Dispersion**, **Reservaciones Pagos Desglosado**, **Facturacion**
- Pestaña **"Dispersión Columnas"** — columnas: Regimen, DiasLaborados, SDP, IM, CF, SA, CG, ID, Pago Bruto, Impuesto Total a Retener, Columna1, **Pago Neto**, Unidad de Negocio, Sociedad Propia (ej. "085-Lobo", "OCTR-Ocesa Corhum")
- Pestaña **"Facturacion"** — columnas: NombrePep, DescripcionPep, Inmueble ("Sin definir" en los ejemplos), PagoReal, Comisión 4% (calculada), Subtotal factura, IVAFactura, Factura y cantidad a fondear (total con IVA)
- Se generan **archivos distintos por Unidad de Negocio/Sociedad Propia** (ej. "ArchivoBaseNomina3002" para Seguridad/085-Lobo, "ArchivoBaseNomina4170" para Control de Accesos/OCTR-Ocesa Corhum) — es decir, la dispersión de nómina se parte por entidad legal pagadora, relevante para el modelo multi-tenant/multi-empresa de PeopleMovil

---

## 3. HALLAZGOS NUEVOS / NO DOCUMENTADOS ANTES (vs. ESCENARIOS_PRUEBA_FREELANCE.md)

1. **Etapa de agrupación de candidatos previa a firma de contrato**: existe una pantalla "Grupos para entrevistas" con % de Disponibilidad (puede ser negativo) y Cupo — sugiere lógica de sobre-booking de candidatos por vacante.
2. **"Lista de candidatos en grupo"** con checkboxes independientes de ¿Asistió? y ¿Documentos Completos? — dos validaciones separadas antes de pasar a firma de contrato.
3. **Firma de contratos** es un módulo separado (no solo un estatus) con su propio listado y detalle, donde se captura el **Resultado de entrevista** (dropdown, valor "Aceptado") y se **asigna el curso de inducción** desde ahí mismo.
4. **Curso de inducción** tiene su propio catálogo de "Eventos Prueba" (reutiliza el catálogo de Eventos reales de la operación, ej. conciertos/partidos) como lugar/sesión del curso — el curso de inducción se agenda dentro de un evento operativo existente.
5. Confirmar asistencia al curso de inducción **dispara automáticamente el alta de empleados** (aparecen inmediatamente en "Empleado" con Estatus Activo y un score "Certeza" de 0.90 — posible score de scoring/fraude o validación de identidad).
6. **Campo "Certeza"** (0.00–1.00) en Empleado y Plazas empleados — no documentado en escenarios de texto; posible relevancia para un módulo de verificación de identidad/antifraude en PeopleMovil.
7. **Dos correos automáticos del sistema** confirmados con contenido completo: (a) confirmación de curso de inducción al candidato, (b) aviso a RH de alta de personal con PDF adjunto "Relación de personal dado de alta".
8. **Campo "Completar con similares"** en Detalles de pedido (dropdown NO/¿SI?) — sugiere lógica de autocompletar vacantes con personal de perfil similar cuando faltan candidatos.
9. **Estatus "CONFIRMADO FORZADO"** en contactos de pedido y en reservaciones — sugiere una vía de asignación manual/forzada distinta de la reservación normal vía la app, relevante para flujos de excepción.
10. **Registro asistencia manual** es un módulo separado de "Listas de asistencia", con botones por fila **Asistencia / Retardo / Falta** — 3 estados de asistencia, no solo sí/no.
11. **Asignación de Folios**: antes de pagar, cada reservación de un empleado se debe "amarrar" a un **folio** alfanumérico (parece ser el número de recibo de honorarios / comprobante fiscal), capturado manualmente por el operador por empleado.
12. **Catálogo de Bancos sucio**: contiene entradas sin sentido ("13","14","15","16","17","Doce","once") mezcladas con bancos reales (Bancomer, Banorte, HSBC, Inbursa, Santander, Scotia Bank, Banamex CCC, IXE, Serfin) y una opción "Sin Banco" — a limpiar/normalizar en PeopleMovil.
13. **Cierre de nómina**: validación obligatoria de fecha de cierre ("Debe ingresar una fecha correcta"), y filas en rojo cuando el banco no está definido (bloqueo visual, aunque no impidió completar el cierre en el flujo visto — a confirmar si es solo advertencia o bloqueo duro).
14. **Dispersión Nómina** genera 4 archivos Excel distintos por combinación Régimen fiscal (Honorarios Asimilables vs Normales) × Marca ("Lobo" vs "Otras") — es decir, hay razón social/marca aparte de "Lobo" en el mismo sistema (multi-marca dentro de una sola instancia), con archivos separados también por Unidad de Negocio/Sociedad Propia (ej. "085-Lobo" vs "OCTR-Ocesa Corhum").
15. Pestaña Excel **"Facturacion"** muestra el cálculo de la comisión del operador (4% visto en los ejemplos) sobre el pago real, más IVA, para fondeo — modelo de negocio tipo staffing con comisión + traspaso de nómina a terceros (Sociedad Propia / PeP = centro de costos del cliente final).
16. Columnas Excel de nómina (**SDP, IM, CF, SA, CG, ID**) son códigos/abreviaturas sin leyenda visible en el frame — probablemente conceptos de nómina fiscal mexicana (Salario Diario, ISR/IMSS, Cuota Fija, Subsidio al Empleo, Crédito al Gasto, etc.) a confirmar con un screenshot de mayor resolución o con el usuario de negocio.

---

## 4. CAMPOS DE FORMULARIO — RESUMEN CONSOLIDADO POR PANTALLA

(ver detalle completo en sección 2; aquí solo los campos de captura, no las columnas de grid)

- **Lista firma de contrato**: ¿Asistió?, Doc.Com., Resultado (dropdown), Curso de inducción (dropdown)
- **Lista candidatos curso de inducción**: Evento prueba (dropdown), ¿Asistió?
- **Detalles de pedido**: Tipo personal*, Título*, Producto, Lugar de Cita*, Dirección cita, Otro (checkbox), Indicaciones especiales, Cantidad, Turnos, Fecha cita*, Fecha liberación, Fecha final cita, Presentación por producto, Completar con similares
- **Registro asistencia manual**: Pedido Detalle* (lookup), Título (auto), Evento (auto), Fecha cita (auto), Dirección lugar de cita (auto), Unidad de negocio (auto)
- **Asignación Folios**: Núm.folio*, Procesar (checkbox por fila)
- **Cuentas de banco empleados**: Id Emp.*, Banco*, Cuenta*
- **Cierre de nómina**: Fecha* (de cierre)
- **Dispersión Nómina**: Periodo (dropdown)

---

## 5. ARCHIVOS CITADOS (muestra, nombres de archivo exactos)

`001_00m00s.png`, `003_00m10s.png`, `006_00m24s.png`, `011_00m39s.png`, `016_00m55s.png`, `021_01m17s.png`, `026_01m40s.png`, `031_01m57s.png`, `036_02m14s.png`, `041_02m31s.png`, `046_02m54s.png`, `051_03m11s.png`, `056_03m32s.png`, `058_03m34s.png`, `061_03m41s.png`, `066_03m59s.png`, `068_04m06s.png`, `071_04m15s.png`, `076_04m29s.png`, `081_04m53s.png`, `086_05m09s.png`, `091_05m21s.png`, `096_05m42s.png`, `101_05m56s.png`, `103_06m02s.png`, `106_06m20s.png`, `111_06m33s.png`, `116_06m52s.png`, `121_07m11s.png`, `126_07m37s.png`, `131_07m46s.png`, `136_08m04s.png`, `141_08m24s.png`, `146_08m36s.png`, `151_09m07s.png`, `156_09m22s.png`, `161_09m41s.png`, `166_09m53s.png`, `171_10m18s.png`, `176_10m28s.png`, `181_10m39s.png`, `186_10m51s.png`, `191_11m08s.png`, `193_11m18s.png`, `196_11m33s.png`, `201_12m01s.png`, `206_12m14s.png`, `208_12m28s.png`, `211_12m43s.png`, `216_13m07s.png`, `221_13m19s.png`, `225_13m32s.png`
