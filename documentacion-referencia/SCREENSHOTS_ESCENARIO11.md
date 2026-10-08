# Escenario 11 — Hallazgos visuales del video QA (2019)

**Fuente:** 89 capturas de frame extraídas del video QA
`07 - Escanario11.pdf` / YouTube `HECsavJdI9I` ("Escanario11", canal *WJaJa VideoClips*, 275 s), ubicadas en
`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\07 - Escanario11\`.
Archivos citados con su nombre exacto (`NNN_MMmSSs.png`).

**Sistema:** GeneXus "RRHH" (AppSCPF / Lobo), ambiente QA
`integramx-001-site2.btempurl.com/qafreelancev1/...`. Módulo cubierto: **Pedidos → Detalles de pedido → Reservaciones** (confirmación de personal) y **Empleados** (alta/consulta). Confirma y amplía el texto de "Escenario 11: Confirmación de personal sin puesto asignado vigente" en `ESCENARIOS_PRUEBA_FREELANCE.md` (líneas 373-381).

Se revisó una muestra uniforme de ~31 frames a lo largo de los 4:29 min del video (prácticamente 1 de cada 3), cubriendo el 100% del rango 001→089.

---

## 1. Walkthrough cronológico

### 1.1 Alta de Pedido (pantalla "Pedidos", alta)
- `001_00m00s.png` — Pantalla **Pedidos**, sección "Información General". Dos links de acción arriba del panel: **Agregar Detalle** / **Agregar Factura**. Campos visibles (todos con asterisco rojo `*` de obligatorio salvo donde se indica): **Cliente** (combo, ya con "OCESA Promotora, S. A. de C...​"), **Id Contacto** (combo, "(Ninguno)"), **Id sucursal** (combo), **Unidad de negocio** (combo), **Id PEP** (combo), **Id evento** (combo), **Título** (texto libre), **Lugar de cita** (combo, "Sin definir"), **Dirección lugar** (textarea), checkbox **Otro**, **Tipo de movimiento** (combo). Checkbox suelto a la derecha: **Agregar contacto**.
- `004_00m06s.png` — Combo **Id sucursal** desplegado. Opciones completas: `(Ninguno)`, `CDMX`, `Guadalajara`, `Monterrey`, `Otra`, `Queretaro`.
- `008_00m16s.png` — Tras elegir sucursal CDMX aparecen más campos obligatorios: **Unidad de negocio** = "Control de Accesos", y más abajo **Sociedad pagadora** (combo, "Operadora de Centros de Es...​"), **Permitir cancelar confirmaciones** (combo Sí/NO, aquí "NO"), **Responsable** (combo "(Ninguno)").
- `012_00m23s.png` — **Id PEP** se llena con un código tipo proyecto: `EI-TF-2018-03-06T009IP-A Pl...` (formato `XX-XX-AAAA-MM-DDTNNNIP-A <texto>`). **Id evento** = "Jacob Whitesides 2019" (autocompleta **Título** = "Jacob Whitesides 2019" y **Dirección lugar** = "Sin definir").
- `016_00m35s.png` — **Lugar de cita** = "Pepsi Center WTC" (combo de sitios predefinidos); **Título** se edita manualmente a "Jacob Whitesides 2019----Escen[ario 11]" (el tester anexa el nombre del escenario al título para poder ubicarlo después en el listado de Pedidos).
- `017_00m36s.png` / `018_00m38s.png` — Scroll al resto del formulario: tras **Lugar de cita** aparece un textarea de solo lectura **lugar** (dirección completa autollenada: "Dakota sin num. Col. Napoles, Del. Benito Juarez, Mexico DF cp 03810"), luego **Otro** (checkbox), **Tipo de movimiento** = "Servicio interno" (combo), **Sociedad pagadora** = "Operadora de Centros de Es...", **Permitir cancelar confirmaciones** = "NO", **Responsable** (combo). Botones al pie: **Confirmar** / **Regresar**.
- `020_00m46s.png` — Combo **Responsable** desplegado con lista de nombres de empleados/ejecutivos: Angelica Jazmin Lopez Perez, Antonio de Jesus Mecalo Olmos, Cesar Ramirez Mejia, Gerardo Martinez Morales, **Israel Benavid Solis Carrera** (seleccionado), Jose Edgar Barrera Diaz, Juan Carlos Zavala Enriquez, Julio Cesar Angeles Ibarra, Ramon Roberto Garza Juarez.

### 1.2 Detalle del pedido
- `024_00m57s.png` — Tras **Confirmar**, el sistema navega a **Detalles de pedido** (`wp_pedidodetalle.aspx?1056`, Pedido No. 1056). Aparece un **toast naranja de advertencia en la esquina superior derecha: "No existe información para formar Matriz."** — se dispara porque la sección **Matriz de Puestos** todavía está vacía (sin detalle de pedido capturado aún). Secciones de la pantalla: cabecera con acciones **Editar pedido / Liberar Pedido / Cancelar Pedido** y botón **Regresar**; bloque **PEDIDO No.: 1056**; bloque **Matriz de Puestos** (vacío en este punto); bloque **Movimientos detalles pedido** con pestaña **Detalles**.
- `028_01m06s.png` — Formulario de alta de detalle (pestaña **Detalles**). Campos: **Estatus** (read-only, "Vigente"), **Evento Práctica** (checkbox), **Tipo personal** (read-only, "Operativo"), **Título** (heredado del pedido), **Producto** (combo — aquí "Control de Accesos Supervis[or-MA]", es el **puesto/producto solicitado**), **Lugar de Cita** (combo, "Pepsi Center WTC"), **Dirección cita** (texto), **Otro** (checkbox), **Indicaciones especiales** (textarea), **Bloque por producto** (combo "Ninguno"), **Facturable** (combo "NO"). Columna derecha: **Cantidad** (numérico) + **Turnos** + cálculo "X Horas por turno", **Fecha cita** (fecha + hora + minuto, 3 controles), **Fecha liberación** (fecha + hora + minuto), **Fecha final cita** (fecha + hora + minuto), **Presentación por producto** (combo), **Completar con similares** (combo Sí/NO), **Fase del evento** (combo), **Permitir cancelar** (combo Sí/NO). Botones **Agregar Detalle** / **Cancelar**.
- `030_01m10s.png` — Selector de hora (dropdown nativo 00-23) abierto para **Fecha cita**.
- `031_01m13s.png` / `032_01m17s.png` — Detalle completado: Cantidad = 1, Turnos = 1.00 ("8 Horas por turno"), Fecha cita = 23/08/2019 20:00, Fecha final cita = 24/08/2019 04:00 (turno nocturno), **Presentación por producto** = "Pantalón Mezclilla Azul, Car[misa...]" (uniforme). Botón **Agregar Detalle**.
- `036_01m25s.png` — Popup/tooltip **"Editar Liberar Cancelar Pedido"** al pasar el mouse sobre la línea de detalle en la **Matriz de Puestos**. Muestra un resumen de solo lectura del detalle: **ID** 2410, **Lugar de cita** Pepsi Center WTC, **Fecha cita** 23/08/2019 20:00, **Fecha fin cita** 24/08/2019 04:00, **Fecha liberación** (vacía), **Completar con similares** NO, **Cantidad reservados** 0, **Cantidad reservados real** 0, **Cantidad reservados con preasignación** 0, **Porcentaje completo** 0.00, **Fase de evento** (vacío), **Presentación producto** "Pantalón Mezclilla Azul, Camisa Blanca y Zapatos Negros", **Indicaciones especiales**.
  - Tabla **Matriz de Puestos**: columnas **Bloque | Productos | [fecha 23/08] | [hora 20:00]**, fila `Control de Accesos Supervisor-MA | Jacob Whitesides 2019----Escenario 11` con cantidad `1 - T 1.00`; totales **Total Solicitados** = 1, **Presupuesto por día** = $100.00.

### 1.3 Primer intento de Confirmación/Pre-asignación (empleado SIN puesto) — mensaje impreciso
- `056_02m36s.png` — Dentro de **Detalles de pedido**, el detalle ya está **Liberado** (Estatus cambia de "Vigente"/en edición a "Liberado"). Aparece la 2ª pestaña del bloque "MODIFICACION DETALLE DE PEDIDO": **Reservaciones** (junto a **Detalles**), con sub-sección **Personal Confirmado**: campo **Nombre** (autocompletar "Nombre completo / Alias"), dos botones de acción **Confirmación Forzada** y **Confirmación Preasignada**, ícono de impresora **Imprimir lista de Asistencia**, y tabla resultado con columnas **IdContacto | Nombre completo | Estatus**.
- `053_02m18s.png` / `054_02m23s.png` — Con el empleado **"65858-Huerta Danilo Santos"** tecleado en Nombre y tras pulsar **Confirmación Preasignada** (empleado que a esa altura NO tiene asignado el puesto "Control de Accesos"), aparece un **toast naranja con DOS líneas de validación simultáneas**, texto exacto (zoom aplicado para verificar):
  > **"La cantidad solicitada es menor a igual a 3"**
  > **"El porcentaje de certeza del empleado es menor a 1"**

  Ninguna de las dos líneas menciona el verdadero motivo (falta de puesto/plaza vigente). Esto **confirma textualmente** la observación ya anotada en `ESCENARIOS_PRUEBA_FREELANCE.md` línea 379: *"Las ventanas emergentes deben ser más precisas al indicar el error para ubicarlo. En este caso cumplió con certeza valor, perfil, vigencia y no fue posible identificar la falla."* — el popup real mezcla validaciones de cantidad/certeza que no son la causa raíz del rechazo.

### 1.4 Consulta de Empleados
- `062_02m51s.png` — Menú **Empleados** (usuario "Adminpersonal") con submenú: **Empleados**, **Alta masiva de empleados**, **Alta individual empleado**, **Baja empleado**, **Reactivación empleado**, **Observaciones empleado**, **Consulta registro TimeScan**, **Cambio de cuenta de banco**.
- `063_02m55s.png` / `065_03m04s.png` — Pantalla listado **Empleado** (`te_empleadoww.aspx`). Columnas de grid: **Id, Nombre Completo, Estatus, Sexo, Certeza, Correo electrónico, Sucursal**. Barra de herramientas: botón **+** (alta), exportar **XLS/PDF**, **Selecciona columnas**, filtro **Buscar en [Nombre Completo ▾] valor [__]**. El filtro "Nombre Completo" al hacer clic en el encabezado de columna abre un mini-panel con **Ordenar de A a Z / Ordenar de Z a A** y rango **Desde / Hasta** + botón **Buscar**. Tras buscar por "3422" sólo queda el registro: **Id 3422, Amado Alberto Alvarado Salvador, Activo, Masculino, Certeza 1.00, correo adrian.aguimor@gmail.com, Sucursal CDMX**.
- `067_03m10s.png` — Clic en el ícono de edición (lápiz) de ese empleado; inmediatamente se hace **Salir** (logout) — el video **no muestra** la pantalla de edición/alta de puesto del empleado (el salto de reloj de 03:21 pm a 03:46 pm entre frames 075→081 indica que el tester hizo el alta del puesto fuera de cámara o editando directamente en la hoja Excel de referencia).

### 1.5 Hoja de referencia de datos de prueba (evidencia externa, confirma datos maestros)
- `078_03m44s.png` — Excel **DatosFReelanceParaEscenarios_01.xlsx**, pestaña **"Control de acceso"**: cabecera de parámetros **Certeza 0 Hasta 1**, **Estatus Activo**, **Puesto "Control de Accesos"**; tabla de empleados candidatos con columnas **Empleado | Nombre completo | Sexo | Certeza | Estatus | Id Puesto | Puesto | Vigente | Principal**:
  | Empleado | Nombre | Certeza | Estatus | Id Puesto | Puesto | Vigente | Principal |
  |---|---|---|---|---|---|---|---|
  | 58172 | Oscar Fernan[dez]... | 1 | Activo | 484 | Control de A[ccesos] | true | **Sí** |
  | 39115 | Arturo Flores | 1 | Activo | 189 | Control de A[ccesos] | true | NO |
  | 3422 | Amado Albe[rto]... | 1 | Activo | 189 | Control de A[ccesos] | true | NO |

  **Nota de discrepancia:** el texto de `ESCENARIOS_PRUEBA_FREELANCE.md` indica *"Crear un empleado de seguridad ID(58172)"*, pero en el video el empleado realmente usado para la confirmación final es **ID 3422 (Amado Alberto Alvarado Salvador)**, no 58172. 58172 (Oscar Fernández) aparece en la hoja de referencia como el empleado "Principal" preconfigurado para control de accesos, posiblemente reutilizado en otros escenarios.
- `087_04m19s.png`/`088_04m24s.png`/`089_04m29s.png` — Mismo Excel, pestaña **"Otros Escenarios Pedidos"**, filas 48-57 (el texto exacto que luego se copió/adaptó a `ESCENARIOS_PRUEBA_FREELANCE.md`, confirmando que ese .md es transcripción literal de este Excel):
  > Escenario 11: Confirmación de personal sin puesto asignado vigente
  > - Crear un empleado de seguridad ID(58172)
  > - Crear un Pedido de control de accesos con un único detalle
  > - Realizar una Pre-asignación del empleado de seguridad para el pedido de control de accesos
  > - Validar que el sistema no permita la pre-asignación ya que el empleado no cuenta con el puesto requerido
  > - Agregar el puesto de control de accesos al Empleado, con una fecha fin de puesto anterior a la fecha del evento
  > - Realizar una Pre-asignación del empleado para el pedido de control de accesos
  > - Validar que el sistema no permita la pre-asignación ya que el empleado no cuenta con el puesto requerido
  > NOTA: Las pruebas de validación con pre-asignaciones se realizarán también en la página de reservaciones, ya que aplican las mismas reglas.

### 1.6 Segundo intento — mensaje de error SÍ específico de perfil/puesto
- `075_03m38s.png` — De vuelta en **Reservaciones**, el campo **Nombre** es un autocompletar: al teclear un Id numérico (p. ej. "34" o "3422") despliega una lista `IdEmpleado-Nombre completo` (ej. `34224-Marcos Alejandro Gutierrez Hernandez`, `34227-Olga Gauzin Isidoro`, `83422-Rocío Maricela Fuentes Cantero`, `3422-Amado Alberto Alvarado Salvador`).
- `080_03m51s.png` — Con **"3422-Amado Alberto Alvarado S[alvador]"** seleccionado, clic en **Confirmación Preasignada**. Resultado: **toast naranja: "El empleado no cumple con el perfil requerido."** — este SÍ es un mensaje específico de validación de puesto/perfil (a diferencia del mensaje confuso de cantidad/certeza del primer intento con el empleado 65858). Confirma que el sistema valida "perfil requerido" (= puesto asignado vigente) como regla independiente, aunque con textos de error inconsistentes entre los dos intentos.
- `085_04m14s.png` — Con el mismo empleado 3422, el tester prueba en cambio el botón **Confirmación Forzada** (en vez de Preasignada). Resultado: **toast naranja de éxito: "Registro agregado correctamente."** La tabla de resultados bajo "Personal Confirmado" muestra la fila: **IdContacto 3422 | Nombre completo "3422-Amado Alberto Alvarado Salvador" | Estatus "CONFIRMADO FORZADO"**, con un ícono ✕ para des-confirmar en esa misma fila.

  **Hallazgo clave:** la **Confirmación Forzada SÍ permite** asignar/confirmar a un empleado sin el perfil/puesto requerido (bypassa la validación de perfil que sí aplica "Confirmación Preasignada"). Esto es consistente con la semántica esperada de "forzada" vs. "preasignada", pero **no está documentado explícitamente** en el texto de Escenario 11 ni en el schema actual — es una regla de negocio importante: *Confirmación Preasignada valida puesto/perfil/certeza del empleado; Confirmación Forzada la omite (asignación manual de administrador, sin más validación visible en el toast que las de disponibilidad/cantidad)*.

---

## 2. Inventario de campos por pantalla

### Pedidos — alta/edición (cabecera)
Cliente*, Id Contacto*, Id sucursal*, Unidad de negocio*, Id PEP, Id evento*, Título*, Lugar de cita, Dirección lugar (textarea, autollenado), Otro (checkbox), Tipo de movimiento*, Sociedad pagadora*, Permitir cancelar confirmaciones*, Responsable*, Agregar contacto (checkbox). Acciones: **Agregar Detalle**, **Agregar Factura**, **Confirmar**, **Regresar**.

### Detalles de pedido — alta de detalle (pestaña "Detalles")
Estatus (read-only), Evento Práctica (checkbox), Tipo personal* (read-only "Operativo"), Título*, Producto* (= puesto solicitado), Lugar de Cita*, Dirección cita, Otro (checkbox), Indicaciones especiales, Bloque por producto, Facturable; Cantidad, Turnos (con cálculo "N Horas por turno"), Fecha cita* (fecha+hora+min), Fecha liberación (fecha+hora+min), Fecha final cita (fecha+hora+min), Presentación por producto, Completar con similares, Fase del evento, Permitir cancelar. Acciones: **Agregar Detalle** / **Modificar detalle** / **Cancelar detalle** / **Cancelar**.

### Detalles de pedido — encabezado
PEDIDO No.: {id}. Acciones: **Editar pedido**, **Liberar Pedido**, **Cancelar Pedido**, **Regresar**. Bloque **Matriz de Puestos** (tabla Bloque/Productos/fecha/hora, Total Solicitados, Presupuesto por día). Popup flotante **"Editar Liberar Cancelar Pedido"** con: ID, Lugar de cita, Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, Cantidad reservados, Cantidad reservados real, Cantidad reservados con preasignación, Porcentaje completo, Fase de evento, Presentación producto, Indicaciones especiales.

### Detalles de pedido — pestaña "Reservaciones" ("Personal Confirmado")
Nombre (autocompletar por nombre/alias o ID empleado). Botones: **Confirmación Forzada**, **Confirmación Preasignada**, ícono **Imprimir lista de Asistencia**. Tabla resultado: IdContacto, Nombre completo, Estatus (valores vistos: **CONFIRMADO FORZADO**), ícono ✕ para remover.

### Empleado — listado
Id, Nombre Completo, Estatus, Sexo, Certeza, Correo electrónico, Sucursal. Toolbar: alta (+), exportar XLS/PDF, Selecciona columnas, filtro "Buscar en [campo] valor [...]". Menú **Empleados**: Empleados, Alta masiva de empleados, Alta individual empleado, Baja empleado, Reactivación empleado, Observaciones empleado, Consulta registro TimeScan, Cambio de cuenta de banco.

### Login
Pantalla **Acceso**: campos Usuario, Contraseña, botón **Ingresar**. Mensaje visto al cargar sin sesión: **"El usuario debe estar autenticado."**

---

## 3. Catálogos/Opciones de dropdown observados

- **Id sucursal:** (Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro.
- **Unidad de negocio:** "Control de Accesos" (único valor visto con certeza; no se abrió la lista completa).
- **Tipo de movimiento:** "Servicio interno" (único valor visto).
- **Permitir cancelar confirmaciones / Permitir cancelar / Completar con similares:** Sí / NO (boolean-style combo).
- **Responsable:** lista de nombres de ejecutivos/operadores (ver §1.1, frame 020).
- **Producto** (en detalle de pedido): "Control de Accesos Supervisor-MA" visto; es el campo que determina el **puesto** requerido para la validación de perfil.
- **Fecha cita / Fecha liberación / Fecha final cita — selector de hora:** dropdown nativo 00–23 (horas) y 00-59 min (minutos) adosado a un datepicker de calendario mensual estilo jQuery UI (visto en frame 014 con "Agosto, 2019" y navegación «/‹ Hoy ›/»).

---

## 4. Mensajes exactos capturados (validación / éxito)

| Momento | Texto exacto (toast naranja, esquina sup. derecha) | Contexto |
|---|---|---|
| Al entrar a Detalles de pedido sin matriz aún | **"No existe información para formar Matriz."** | Antes de dar de alta el primer detalle del pedido. |
| 1er intento Confirmación Preasignada, empleado 65858 sin puesto | **"La cantidad solicitada es menor a igual a 3"** + **"El porcentaje de certeza del empleado es menor a 1"** (dos líneas en el mismo toast) | Mensaje impreciso — no indica falta de puesto. Confirma la queja ya registrada en el texto QA. |
| 2do intento Confirmación Preasignada, empleado 3422 sin puesto vigente | **"El empleado no cumple con el perfil requerido."** | Mensaje SÍ específico de perfil/puesto, pero inconsistente con el mensaje anterior para un caso de fondo equivalente. |
| Confirmación Forzada, empleado 3422 | **"Registro agregado correctamente."** | Éxito; estatus resultante en la grilla: **"CONFIRMADO FORZADO"**. |
| Pantalla de login sin sesión | **"El usuario debe estar autenticado."** | — |

---

## 5. Reglas de negocio / campos NUEVOS no capturados (o insuficientemente capturados) en `ESCENARIOS_PRUEBA_FREELANCE.md` o en `db/reset_database.sql`

1. **Dos botones de confirmación con comportamiento de validación distinto:** "Confirmación Preasignada" valida perfil/puesto/certeza del empleado contra el producto solicitado; "Confirmación Forzada" **omite** esa validación y permite confirmar a cualquier empleado buscado por nombre/ID (comportamiento de "override" de administrador). El texto de Escenario 11 sólo prueba "Pre-asignación"; el video muestra que el camino de éxito final fue vía **Confirmación Forzada**, no vía Preasignada — el escenario de texto no deja claro que la ruta "Preasignada" siga fallando incluso tras agregar el puesto (ver más abajo) y que el QA tuvo que usar "Forzada" para cerrar la prueba.

2. **Mensajería de validación inconsistente/duplicada:** el mismo tipo de fallo (empleado sin puesto vigente) produjo en una ocasión un mensaje genérico de "cantidad solicitada" + "porcentaje de certeza" (no relacionado con la causa real) y en otra ocasión el mensaje correcto "El empleado no cumple con el perfil requerido". PeopleMovil debería estandarizar en un único mensaje claro tipo *"El empleado no tiene asignado el puesto requerido ('{puesto}') o no está vigente a la fecha del evento."*

3. **Gap de schema — `tr_empleado_plaza` no tiene vigencia por fechas.** El texto QA pide explícitamente: *"Agregar el puesto ... con una fecha fin de puesto anterior a la fecha del evento"* y espera que la pre-asignación siga fallando (puesto no vigente a la fecha del evento). Sin embargo, `db/reset_database.sql` define `tr_empleado_plaza` (línea 665) **sin columnas de vigencia por fecha** (`fecha_inicio_plaza` / `fecha_fin_plaza`), sólo con un booleano `activo`. La función `valida_emp_puesto()` (línea 1137) tampoco verifica que exista una fila de `tr_empleado_plaza` para ese empleado+puesto: si no existe ninguna, `obtener_certeza_puesto()` hace `COALESCE` al `porcentaje_certeza_inicial` del puesto (línea 1134) y la validación de certeza podría **pasar igualmente**, sin rechazar por "no tiene el puesto asignado". Esto es exactamente el bug/gap que Escenario 11 busca probar — **se recomienda**:
   - Agregar `fecha_inicio_plaza date` y `fecha_fin_plaza date NULL` a `tr_empleado_plaza`.
   - Modificar `valida_emp_puesto()` para que, si **no existe** fila vigente de `tr_empleado_plaza` (empleado_id + puesto_id, `activo` = true, y fecha del evento dentro de `[fecha_inicio_plaza, fecha_fin_plaza]` o `fecha_fin_plaza IS NULL`), retorne `valido = false, motivo = 'empleado no tiene el puesto requerido asignado o no vigente'` **antes** de evaluar certeza/sexo.
   - Diferenciar explícitamente, a nivel de función/RPC, el camino de "confirmación forzada" (sin llamar `valida_emp_puesto`) del de "confirmación preasignada" (con la validación completa), replicando el comportamiento observado en el video.

4. **Campo "Principal" en la relación empleado-puesto** (visto en el Excel de datos maestros, no es UI del sistema pero sí es dato de negocio real): cada empleado puede tener varios puestos, y uno de ellos se marca como **Principal = Sí/NO**. No existe un campo equivalente en `tr_empleado_plaza` del schema actual (sólo `porcentaje_puntualidad` y `activo`). Vale la pena evaluar si PeopleMovil necesita distinguir "puesto principal" vs. "puestos secundarios" de un freelancer.

5. **Autocompletar de "Nombre" en Reservaciones** acepta tanto nombre/alias como ID numérico del empleado y muestra sugerencias `Id-NombreCompleto` — confirma que la búsqueda de personal para confirmar/pre-asignar es por texto libre con autocompletado, no por selección desde una lista fija.

6. **Discrepancia de ID de empleado de prueba:** el texto indica ID 58172, pero el video usa primero el ID 65858 (Huerta Danilo Santos) y finalmente el ID 3422 (Amado Alberto Alvarado Salvador) para cerrar la prueba exitosamente. 58172 (Oscar Fernández) sí existe en los datos maestros de referencia como empleado "Principal" de Control de Accesos, pero no aparece usado en pantalla durante este video — posible indicio de que el escenario se grabó en una toma distinta a la del ID originalmente planeado, o que 58172 se usó en una repetición anterior no incluida en este set de 89 frames.

7. El video **no muestra** la pantalla real de "Alta individual empleado" / edición de empleado donde se agrega el puesto con su fecha de vigencia (paso crítico del escenario) — ese paso ocurrió fuera de cámara (salto de 03:21 pm a 03:46 pm). Se recomienda buscar otro video/escenario (p. ej. de alta de empleados) si se necesita el detalle exacto de esos campos de UI.
