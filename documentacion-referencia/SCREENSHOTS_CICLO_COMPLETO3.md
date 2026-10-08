# Screenshots — Video 17 "Ciclo Completo3"

Fuente: `doc\Panttallas del sistema tomados desde varios video escvenarios de pruebas de pruebas\17 - Ciclo Completo3\`
187 capturas (`001_00m00s.png` … `187_13m19s.png`), video original: https://youtu.be/SQS5tSZYKEE (duración 811s / 13m31s).
Muestreo revisado: ~42 imágenes distribuidas uniformemente (cada 5 frames aprox.) más algunas intermedias para confirmar transiciones clave. Usuario logueado como "Administrator", módulo "RRHH", navegador Chrome con reloj de Windows 22/07/2019 (fecha de datos de prueba, no la fecha de grabación).

## 1. Flujo real observado (secuencia de pantallas/módulos)

Este video es el más valioso de toda la colección porque muestra el ciclo **end-to-end completo** encadenado en una sola sesión, desde "grupo de entrevista" hasta la dispersión bancaria y el archivo de facturación. Numeración = orden real de uso:

1. **Operaciones → Grupos para entrevistas** (listado de grupos de entrevista por vacante/horario)
2. **Lista de candidatos en grupo** (detalle de un grupo: marcar asistencia de candidatos y "Doc. Completa"; confirmar con modal)
3. **Operaciones → Firma de contratos** (listado, misma estructura de grilla que "Grupos para entrevistas")
4. **Lista firma de contrato** (detalle: marcar ¿Asistió?, Doc.Com., folio, Resultado = Aceptado/Rechazado, asignar Curso de inducción; confirmar con modal)
5. **Correo automático "Notificación curso de inducción"** enviado al candidato (vía cuenta Outlook/Hotmail, remitente `registro.sistema.freelance@gmail.com`)
6. **Lista candidatos curso de inducción** (detalle: marcar ¿Asistido?, asignar "Evento prueba" — catálogo de eventos/escenarios de prueba con fecha+hora+nombre; confirmar)
7. **Correo automático "alta de personal Freelance"** con PDF adjunto (lista de folios dados de alta como empleados), remitente tipo `...pleados <registro....@gmail.com>` (posible "Registro Alta Empleados")
8. **Nómina → Empleado** (listado de empleados dados de alta: Id, Nombre, Estatus, Sexo, Certeza, Correo, Sucursal)
9. **Nómina → Plazas empleados** (listado de plazas asignadas por empleado: Puesto, Pago, Unidad de negocio, fecha)
10. **Detalles de pedido** (pantalla "hub": Matriz de Puestos, pestañas Detalles/Reservaciones, botones "Confirmación Forzada" y "Confirmación Preasignada", impresión PDF de "Lista de Asistencia" en formato manual para firma física)
11. **Nómina → Pago honorarios** (listado/consulta de pagos por empleado, régimen, banco, cuenta, empresa pagadora, unidad de negocio)
12. **Registro asistencia manual** (pantalla para capturar asistencia real del evento: botones Asistencia/Retardo/Falta por reservación, con pago asociado; "Confirmar Lista")
13. **Nómina → Pago honorarios** (se vuelve a consultar, ahora reflejando los nuevos registros con periodo de pago asignado)
14. **Nómina → Cierre de nómina** (selección de fecha, listado a cerrar, botón "Cierre de nómina")
15. **Nómina → Dispersión Nómina** (selección de periodo, descarga de 4 archivos Excel: "Lobo Honorarios Asimilables", "Lobo Honorarios Normales", "Otras Hon.Asimilables", "Otras Hon.Normales")
16. **Revisión de los Excel de dispersión descargados** (múltiples pestañas internas: Datos Empleados, Desglose Dispersión, Reservaciones Pagos Desglosado, Facturación, Dispersión Columnas) — fin del ciclo.

Resumen del ciclo de negocio confirmado: **Candidato → Grupo de entrevista → Firma de contrato → Curso de inducción → Alta como Empleado/Plaza → Pedido/Reservación → Registro de asistencia real → Pago de honorarios → Cierre de nómina → Dispersión bancaria → Facturación**.

---

## 2. Detalle por pantalla

### 2.1 Grupos para entrevistas
Archivo: `001_00m00s.png`. Menú: Operaciones (implícito, título "Grupos para entrevistas").
Grilla con botones Nuevo(+), exportar XLS/PDF, "Selecciona columnas", filtro "Buscar en [Hora cita ▾] valor [Comienza con ▾] [___]".
Columnas: **Hora cita, Puesto, Nombre de vacante, Estatus de grupo, % Disponibilidad, Cupo, Sucursal, Núm.Candidatos, En proceso**.
Datos de ejemplo: Puesto "Acomodador", Vacante "VacanteTit00034", Estatus "Activo", Sucursal "CDMX", filas con cupos 50/20/20/20/20/20 y % disponibilidad variable (0, 20, 50, 55).
Dos iconos de acción a la izquierda de cada fila (lupa/engrane — no identificados con certeza, probablemente "ver"/"editar").
Paginación "Página 1 de 1" con botones Ant/1/Sig.

### 2.2 Lista de candidatos en grupo
Archivos: `006_00m38s.png`, `011_00m51s.png`.
URL: `wp_registroasistenciacandidatos_lista.aspx?UPD,61,01%2F10%2F19+10%3A00,Acomodador+...`
Título "Lista de candidatos en grupo". Tabla con filas numeradas (60-95 visibles), columnas: **# fila, Nombre completo (CandNombreXXXXX CandApPatXXXXX CandApMatXXXXX), Sexo (Masculino), checkbox 1, checkbox 2 (sin headers visibles en el scroll, probablemente "¿Asistió?" y "Doc. Completa")**, icono engrane de "Cambiar grupo" por fila.
Botones al pie: "Actualizar Lista" / "Cancelar".
Modal de confirmación: **"¿ACTUALIZAR LISTA DE ASISTENCIA?"** texto "Confirmar actualización de: 40" con botones **Sí / No**.

### 2.3 Firma de contratos (listado)
Archivo: `016_01m18s.png`. URL: `wp_firmadecontratos.aspx`.
Misma estructura de grilla que "Grupos para entrevistas": columnas Hora cita, Puesto, Nombre de vacante, Estatus de grupo, Sucursal, % Disponibilidad, Cupo, Núm.Candidatos, En proceso.
Datos adicionales nuevos vistos aquí: vacantes "Vigiliante001" (puesto Seguridad, sin estatus/vacío en Sucursal=CDMX), "Taquilleros para Playa Limbo" (puesto Taquillas), "Stage Hand para evento" (puesto Stage Hand) — confirma catálogo amplio de puestos/eventos de prueba.

### 2.4 Lista firma de contrato (detalle)
Archivos: `021_01m31s.png`, `026_01m51s.png`. URL: `wp_firmadecontratos_lista.aspx?UPD,61,...`
Sección **"Información General"**: campos **Id, Hora cita, Puesto, Nombre de vacante, Cupo, Núm.Candidatos**, y dropdown **"Curso inducción"** (valor "No asignado").
Sección **"Lista Candidatos"**, por cada candidato: **¿Asistió? (checkbox), Doc.Com. (checkbox), Folios (#), Nombre completo, Resultado (dropdown: "Aceptado" visible — probable opción "Rechazado"), Curso de inducción (dropdown, "(Ninguno)")**.
Modal de confirmación: **"¿ACTUALIZAR FIRMA DE CONTRATOS?"** texto "Se registraran en CURSOS DE INDUCCIÓN : 40 registros", botones Sí/No. (Nota: aquí los dropdowns "Curso de inducción" por fila ya muestran valores tipo "16/07/19 07:00 | D-40" tras seleccionar.)

### 2.5 Correo "Notificación curso de inducción"
Archivo: `031_02m08s.png` (ventana cargando) y contenido legible en frames cercanos.
Bandeja Outlook.com, remitente **"Registro portal freelance <registro.sistema.freelance@gmail.com>"**, asunto **"Notificación curso de inducción"**.
Cuerpo (texto citado parcialmente, dato de prueba, no información real de terceros):
- "Confirmación de curso de inducción"
- "Estimado(a): CandNombre00247 CandApPat00247 CandApMat00247"
- "¡Ya estás a un paso! Agradecemos tu interés y compromiso en tu proceso de selección."
- "Te confirmamos los datos para tu curso de inducción:"
- **Día: 16/07/19**, **Hora: 07:00**
- **Lugar: Av. Río Churubusco esq. con Añil s/n, Puerta 1. Recepción Lobo — Palacio de los Deportes, Col. Granjas México, Ciudad de México.**
- (corta en "Favor de presentar Identificación Oficial...")
Confirma que el sistema dispara automáticamente un correo al candidato con el detalle de cita del curso de inducción, usando una dirección fija "Recepción Lobo — Palacio de los Deportes".

### 2.6 Lista candidatos curso de inducción
Archivos: `036_02m31s.png`, `041_02m50s.png`. URL: `wp_cursosdeinduccioncandidatos_lista.aspx?UPD,39,VacanteTit00034,...`
Información General: **Curso inducción, Cita, Puesto, Nombre de vacante** + dropdown **"Evento prueba"** ("No asignado" por defecto).
El dropdown "Evento prueba" despliega un catálogo largo de **escenarios/eventos de prueba** usados como datos semilla, formato `DD/MM/AA HH:MM-NOMBRE_EVENTO-TIPO-IN | Nombre evento año`, ejemplos observados:
- 26/02/19 06:00-JACOB WHITESIDES 2019-Seguridad-In | Jacob Whitesides 2019
- 28/03/19 08:00-SIDONIE-Seguridad-In | Sidonie Escenario 15
- 04/03/19, 28/06/19, 05/03/19 — GREEN DAY 2019-Seguridad-In | Green Day 2019 (varios escenarios: 19-2, 10)
- 29/03/19 14:00-SIDONIE-Seguridad-In | Sidonie Escenario 16
- 30/04/19 (x3) SIDONIE-Seguridad-In | Sidonie - Pedido de Práctica / Escenario 9
- 01/06/19 10:00-FERIA DEL JUGUETE 2017-Local Crew-In | Feria del Juguete 2017
- 07/07/19 09:00 / 11/07/19 06:00-JACOB WHITESIDES 2019-Seguridad-IN | Jacob Whitesides 2019 Evento prueba
- 27/06/19 06:25-GREEN DAY 2019-Agente de servicio-MA | Green Day 2019 Evento prueba
Tabla de candidatos: **¿Asistido? (checkbox), Evento Prueba (dropdown por candidato), Cambiar grupo (engrane)**. Botones "Actualizar Lista"/"Cancelar".

### 2.7 Correo "alta de personal Freelance" (con PDF adjunto)
Archivos: `046_03m01s.png`, `051_03m20s.png`, `056_03m34s.png`.
Correo en Outlook con adjunto PDF nombrado algo como **"..._08_37.pdf"**, cuerpo parcialmente legible: "...enviamos la relación de los candidatos que han [sido aceptados] y dados de alta como personal Freelance de [la empresa/evento]." — remitente visible parcialmente "...pleados <registro....gmail.com>" (probablemente dirección tipo `registro.altaempleados@...`).
El PDF se abre en visor embebido (Descargar / Imprimir / Mostrar correo electrónico).

### 2.8 PDF adjunto — Lista de altas (dentro del correo)
Archivo: `061_03m59s.png`. Vista de lista con **Id (65910-65937 en el rango mostrado), Nombre completo (CandNombreXXXXX CandApPatXXXXX CandApMatXXXXX), columna "SEGURIDAD"** (probable "Unidad de negocio" o "Departamento"), numeración secuencial 220-247. Confirma que el PDF adjunto es el listado de folios/candidatos recién dados de alta como empleados.

### 2.9 Empleado (listado)
Archivos: `066_04m11s.png`, `071_04m20s.png`. URL: `te_empleadoww.aspx` (menú Nómina).
Columnas: **Id, Nombre Completo, Estatus (Activo), Sexo (Masculino), Certeza (0.90), Correo electrónico, Sucursal (CDMX)**.
Correo electrónico de prueba usado para todos los registros: `calvario.marron.leonardo@outlook.com` (dato de prueba del QA, no compartir/reutilizar).
Confirma el campo **"Certeza"** (0.90 para todos) como atributo nuevo de empleado no documentado antes — posiblemente score de verificación/match de identidad.

### 2.10 Plazas empleados (listado)
Archivo: `076_04m28s.png`. URL: `te_plazasww.aspx`.
Columnas: **Id, [Nombre], Sexo, Certeza, Estatus, [col numérica 0.00], [cupo/orden 1], Puesto (Acomodador), [pago] 300.00, Unidad de negocio (Control de Accesos), fecha "22/07/2 00:00"**.
Confirma el vínculo "Plaza" = empleado + puesto + pago diario + unidad de negocio + fecha de la plaza.

### 2.11 Detalles de pedido
Archivos: `081_04m42s.png`, `083_04m56s.png` (cargando PDF), `086_05m03s.png`, `088_05m08s.png`. URL: `wp_pedidodetalle.aspx?1048`.
Sección **"Matriz de Puestos"**: tabla Bloque/Productos con fecha (11/07), hora (06:00), fila "**Acomodador-MA | Jacob Whitesides 2019**" con valores "50 - T 1.00"; **Total Solicitados: 50 / 40**; **Presupuesto por día: $1,000.00**.
Sección **"MODIFICACION DETALLE DE PEDIDO"** con pestañas **Detalles / Reservaciones**.
En pestaña Reservaciones: **"Personal Confirmado"**, campo de búsqueda "Nombre completo / Alias", botones **"Confirmación Forzada"** y **"Confirmación Preasignada"**.
Desde aquí se genera una impresión PDF (`aprc_impresionmanualformato2.aspx`) con 2 páginas:
- **Página 1 — "Lista de Asistencia"**: encabezado "1048/2384/ACOMODADOR-MA", campos **Título (Jacob Whitesides), Turnos (1.00), Fecha cita (11/07/2019 06:00:00), Creado por (admin), Fecha impresión, Lugar (Hotel Crowne Plaza México)**; tabla de firmas manual con columnas **E, S, Num, Nombre, Descuento, Firma** (hoja de asistencia física para firmar in situ).
- **Página 2**: tabla resumen **Puestos/Total** ("Acomodador" = 40), **Total femenino (0) / Total masculino (40)**, cuadro de **"Observaciones"**.

### 2.12 Pago honorarios (consulta)
Archivos: `091_05m44s.png`, `106_06m45s.png`, `111_07m14s.png`, `116_07m36s.png`, `136...` (releída), `141_09m54s.png`. URL: `wp_consultahonorarios.aspx` (menú Nómina).
Columnas: **Id, Nombre Completo, Régimen (Honorarios Asimilables / Honorarios Normales), Periodo pago (0 antes del cierre, luego "1087"), Banco, Cuenta, Pago bruto, Pago neto, Empresa pagadora, Unidad de negocio**.
Empresa pagadora constante: **"Tecno Inter, S.A. De C.V."**. Unidades de negocio vistas: **Seguridad, PRG, Produccion, Control de Accesos**.
Ejemplos de cálculo bruto→neto: $400.00→$357.11, $300.00→$274.63, $200.00→$186.33, $285.00→$262.03, $500.00→$435.75, $100.00→$95.34, $9,700.00→$9,247.98, $5,600.00→$5,339.04; también casos con pago bruto **negativo** (-$400.00, -$300.00) cuyo neto queda en $0.00 (posible ajuste/descuento o registro erróneo).

### 2.13 Menú "Nómina" (listado completo de opciones)
Archivo: `111_07m14s.png`, `121_08m10s.png`, `146_10m15s.png`.
Opciones confirmadas en el menú superior **Nómina**: Alta masiva de empleados · Alta individual empleado · Listado de empleados · Desactivación empleado · Reactivación empleado · Cambio de cuenta de banco · Observaciones empleado · Plazas empleados · **Sueldos matriciales** (submenú, flecha "▸") · Listas de asistencia · Alta Masiva extras · Extras · Autorización Extras · Asignación de folios · Pago de honorarios · Cierre de nómina · Dispersión nómina · Lista negra · Aclaraciones (y posiblemente más opciones fuera del viewport, el menú continúa después de "Aclaraciones").

### 2.14 Registro asistencia manual
Archivos: `096_06m27s.png`, `098_06m31s.png`, `101_06m35s.png`. URL: `wp_regasistman.aspx`.
Datos generales: **Pedido Detalle** (id numérico, ej. 2384, con icono de ayuda "?"), **Título** (Jacob Whitesides 2019), **Evento** (Jacob Whitesides 2019), **Fecha cita** (11/07/2019 06:00:00), **Dirección lugar de cita** (Dakota número 95, Colonia Nápoles), **Unidad de negocio** (Control de Accesos).
Sección **"Asistencia manual"**, pestaña **Reservaciones**: tabla **Nombre completo, Tipo (Reservación), Estatus (Procesado), [grupo de botones] Asistencia / Retardo / Falta, Pago ($300.00 por persona)**.
Botones al pie: **"Confirmar Lista"** / **"Cancelar"**.
Nueva dirección de evento de prueba: "Dakota número 95, Colonia Nápoles" (distinta a la dirección del curso de inducción).

### 2.15 Cierre de nómina
Archivos: `126_08m35s.png`, `131_09m07s.png`, `136_09m40s.png`. URL: `wp_cierredenominaperiodo.aspx`.
Campo **"Fecha"** (formato DD/MM/AA HH:MM con selector de calendario) — vacío al entrar, luego se captura "22/07/19 11:11".
Tabla: **Id, Nombre, Banco, Num.Cta., Te_pagos Regimen, Empresa pagadora, Días Trab., Pago neto**.
Botón **"Cierre de nómina"**. Tras ejecutarlo, el "Periodo pago" en Pago honorarios cambia de 0 a un número de periodo (visto "1087").

### 2.16 Dispersión Nómina
Archivo: `151_10m53s.png`. URL: `wp_dispersionexcelgeneracion.aspx`.
Campo **"Periodo"** (dropdown "Seleccione un periodo").
Cuatro íconos de descarga XLS con etiquetas: **"Lobo Honorarios Asimilables"**, **"Lobo Honorarios Normales"**, **"Otras Hon.Asimilables"**, **"Otras Hon.Normales"**. Texto "Descargar" debajo del selector.
Confirma que la dispersión separa pagos por **marca/origen (Lobo vs Otras)** y por **régimen fiscal (Asimilables vs Normales)** — 4 archivos distintos por periodo.

### 2.17 Archivos Excel de dispersión (post-descarga)
Archivos: `156_11m19s.png`, `161_11m27s.png`, `166_11m54s.png`, `171_12m25s.png`, `176_12m45s.png`, `181_13m00s.png`, `186_13m17s.png`, `187_13m19s.png`.
Cada libro descargado ("ArchivoBaseNominaXXXX.xlsx") trae varias pestañas internas:
- **"Datos Empleados"**: IdContacto, Apellidos, Nombre(s), Fecha de Nacimiento, Genero, RFC, CURP, Cuenta Banco, Banco, Teléfono móvil, Teléfono particular.
- **"Desglose Dispersion"**: Regimen, DiasLaborados, SDP, IM, CF, SA, CG, ID, Pago Bruto, Impuesto Total a Retener, Pago Neto, Unidad de Negocio, **Sociedad Propia** (valor visto: "OCTR-Ocesa Corhum").
- **"Reservaciones Pagos Desglosado"** (pestaña presente, no se exploró el contenido en el muestreo).
- **"Facturacion"**: NombrePep, DescripcionPep, Inmueble, PagoReal, Comision 4%(valor), Subtotal factura, IVAFactura, Factura y cantidad a fondear. Ejemplo de fila: PEP "LT-AZ-2018-01-01N085LT-A", Inmueble "Sin definir", PagoReal 95.34, Comisión 4% = 3.81, Subtotal factura 95.34, IVA 15.25, Total a fondear $110.59.
- **"Dispersión Columnas"**: EmpresaPagadora, Regimen, IdContacto, ApellidoPaterno, ApellidoMaterno, Nombres, PagoNeto, CuentaBanco, Banco. (Archivo con menos filas, ej. solo régimen "Honorarios Normales" — separa por régimen en archivos distintos: "Lobo Honorarios Normales" trae solo folios 41102 y 52672 del ejemplo).
Uno de los archivos abre con advertencia "**VISTA PROTEGIDA**: Tenga cuidado, los archivos de Internet pueden contener virus" y otro con "**ADVERTENCIA DE SEGURIDAD**: Se han deshabilitado las conexiones de datos externos" (ambos son banners estándar de Excel al abrir un archivo descargado del navegador, no errores del sistema).

---

## 3. Elementos nuevos / no documentados previamente

- **Campo "Certeza"** (0.0–1.0, ej. 0.90) en Empleado y Plazas empleados — probable score de confianza de verificación de identidad/match, no visto en otros escenarios documentados.
- **Catálogo "Evento prueba"** para Curso de Inducción: lista extensa de eventos de prueba con nombres de conciertos/ferias reales usados como datos semilla (Jacob Whitesides, Green Day, Sidonie, Feria del Juguete, etc.) — útil para poblar datos de prueba de PeopleMovil.
- **Botones "Confirmación Forzada" / "Confirmación Preasignada"** en Detalles de pedido → pestaña Reservaciones: dos modos distintos de confirmar personal en un pedido, no documentados en los escenarios de texto previos.
- **Formato de impresión "Lista de Asistencia"** (`aprc_impresionmanualformato2.aspx`) con hoja de firmas física (columnas E, S, Num, Nombre, Descuento, Firma) — usado para control de acceso en sitio.
- **Flujo de correo dual**: (1) correo de confirmación de curso de inducción al candidato, (2) correo interno de alta masiva como personal Freelance con PDF adjunto de folios dados de alta.
- **Dispersión Nómina separa 4 archivos**: por marca ("Lobo" vs "Otras") × por régimen fiscal ("Honorarios Asimilables" vs "Honorarios Normales").
- **Pestaña "Facturacion"** en el Excel de dispersión con campos de PEP/Inmueble/Comisión 4%/IVA/Fondeo — sugiere integración con facturación de inmuebles/sedes (campo "Sociedad Propia" ej. "OCTR-Ocesa Corhum", y "NombrePep" con formato tipo "LT-AZ-2018-01-01N085LT-A").
- **Pagos brutos negativos** (-$400.00, -$300.00) en Pago honorarios con neto forzado a $0.00 — posible caso de ajuste/corrección o dato anómalo de prueba a validar con negocio.
- **Unidades de negocio nuevas observadas**: "Seguridad", "PRG", "Produccion", "Control de Accesos" (más allá de las ya conocidas).
- Direcciones de ejemplo usadas como sedes de evento: "Av. Río Churubusco esq. con Añil s/n, Puerta 1, Recepción Lobo — Palacio de los Deportes, Col. Granjas México, CDMX" (curso de inducción) y "Dakota número 95, Colonia Nápoles" (registro de asistencia del evento Jacob Whitesides) y "Hotel Crowne Plaza México" (lugar impreso en hoja de asistencia).
