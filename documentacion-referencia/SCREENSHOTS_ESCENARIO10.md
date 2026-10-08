# Escenario 10 — Walkthrough visual (capturas de video QA, 2019-08-19)

Fuente: 215 frames PNG extraídos de una grabación de pantalla (YouTube `fDs2ADagS6o`, canal
"WJaJa VideoClips", 12m01s) en
`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\01 - Escenario10\`.
Se revisó una muestra representativa (~45 frames) distribuida en todo el video. El QA real tenía
dos monitores: el navegador Chrome a la izquierda con el sistema "RRHH" (AppSCPF/Lobo), y Excel a
la derecha con `Scripts de Prueba Freelance.xlsx` (texto ya transcrito en
`ESCENARIOS_PRUEBA_FREELANCE.md`) y `DatosFreelanceParaEscenarios_01.xlsx` (catálogo de empleados
de prueba con IDs, puesto, certeza valor). El sitio es un ambiente de QA GeneXus clásico:
`integramx-001-site2.btempurl.com/qafreelancev1/...aspx` — confirma que el sistema original está
hecho en **GeneXus con páginas WebForm (.aspx)**, no SPA.

El escenario cubre **tres roles/portales distintos** dentro de la misma app "RRHH":

1. **Portal interno "Operación"** (menú: Inicio · Operaciones ▾ · Salir) — crear pedido, detalle,
   preasignar/forzar empleados, cancelar reservación individual.
2. **Portal interno "AdminPersonal"** (menú: Inicio · Empleados ▾ · Otros procesos ▾ · Salir) —
   catálogo de empleados, alta/baja, edición de datos del empleado (incl. sucursal).
3. **Portal "Freelance"** (menú: Comunicados generales · Calendario de eventos · Saldos ·
   Confirmación de eventos · Aclaraciones · Salir) — el mismo login `inicio.aspx`, pero con rol de
   empleado freelance, usado para validar qué eventos ve/puede confirmar cada trabajador.

Los tres comparten la misma pantalla de login y el mismo layout (navbar azul oscuro, logo "RRHH"
arriba a la izquierda, "copyright 2018" en el footer).

---

## 1. Login (`inicio.aspx`)

Frames: `197_10m56s.png`, `198_10m58s.png`, `203_11m13s.png`, `204_11m15s.png`.

- Fondo: foto de concierto a pantalla completa (marca de agua "Jacob Whitesides 2019" — el evento
  de prueba usado en este escenario).
- Card centrado con logo **"RRHH"**, campos **Usuario** y **Contraseña** (ambos simples, sin
  mostrar/ocultar contraseña), botón **"Ingresar"**.
- Mensaje de error visible permanentemente bajo el card cuando no hay sesión:
  **"El usuario debe estar autenticado."** (franja amarilla/naranja clara, icono de alerta). No es
  un mensaje de error de credenciales incorrectas — aparece simplemente al cargar la página de
  login sin sesión.
- El usuario usado para el rol Freelance de prueba en este escenario es el *username* del propio
  empleado: `aroldan` (visto escribiéndose en el campo Usuario, frame `204_11m15s.png`) — es decir,
  el **username del portal Freelance = alias del empleado** (coincide con la columna "Alias" vista
  en `DatosFreelanceParaEscenarios_01.xlsx`, p.ej. `iguerra`, `aalvarado`, `omujica`, `imendez`,
  `aroldan`).

---

## 2. Creación del pedido — `te_pedido.aspx?INS,0` ("Pedidos")

Frames: `008_00m14s.png`–`017_00m31s.png`.

Formulario de una sola sección **"Información General"**, con dos links arriba ("Agregar Detalle",
"Agregar Factura" — deshabilitados/no navegables hasta guardar el pedido). Campos, en orden:

| Campo | Tipo | Notas observadas |
|---|---|---|
| Cliente * | combo | ej. "OCESA Promotora, S. A. de..." |
| Id Contacto * | combo | ej. "Hugo Israel Villanueva Galla..." |
| (checkbox) Agregar contacto | checkbox, a la derecha | permite dar de alta un contacto nuevo sin salir del formulario |
| Id sucursal * | combo | catálogo observado: **(Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro** |
| Unidad de negocio * | combo (catálogo largo, alfabético) | muestra de opciones visibles: A Muse, Actividades Deportivas, Administración y Contratación de Talento, Admón y Finanzas, Aldea Digital, **Anfitriones**, Asdeporte, Atención a Clientes, Calacas Zíngaro, Cavalia, Cirque Du Soleil, Comercial, **Control de Accesos**, Corona Capital, E-Ticket, Enlace, Estacionamientos, Estadio 3 de Marzo Gdl, Estadio Azul, ... (sigue scroll) ... **Seguridad** (seleccionada en este escenario) |
| Id PEP * | combo | ej. `LT-AZ-2018-01-01N085LT-A L...` (mismo PEP ya visto en Escenario 4 del texto) |
| Id evento * | combo | catálogo completo observado: **(Ninguno), Feria del Juguete 2017, Futbol América vs Pumas, Jacob Whitesides 2019, Tributo a Michael Jackson** — confirma que el catálogo de eventos de QA es muy reducido (4 eventos) |
| Título * | texto | se autocompleta con el nombre del evento al elegirlo, pero es editable (aquí quedó "Jacob Whitesides 2019---Escenario10" tras edición manual) |
| Lugar de cita | combo | default "Sin definir"; al elegir PEP/evento se autocompletó a "Estadio Azteca" |
| Dirección lugar | textarea | se autocompleta: "Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX" (dirección real del Estadio Azteca) |
| (checkbox) Otro | checkbox | junto a Dirección lugar |
| Tipo de movimiento * | combo | visto con una sola opción seleccionable en la práctica: "Pedido" (confirma la queja ya registrada en Escenario 1-3 del texto: "Únicamente muestra pedido") |
| Sociedad pagadora * | combo | ej. "Operadora de Centros de Es..." (autocompletada al elegir UN) |
| Permitir cancelar confirmaciones * | combo Sí/No | en este escenario = **NO** |
| Responsable * | combo de contactos | lista de nombres de personas (ej. Angelica Jazmin Lopez Perez, Antonio de Jesus Mecalco Olmos, Cesar Ramirez Mejia, Gerardo Martinez Morales, Israel Benavid Solis Carrera, Jose Edgar Barrera Diaz, Juan Carlos Zavala Enriquez, Julio Cesar Angeles Ibarra, Ramon Roberto Garza Juarez) — seleccionado "Jose Edgar Barrera Diaz" |

Botones al fondo: **Confirmar** / **Regresar**.

> Nota: el campo "Responsable" no estaba documentado como obligatorio/explícito en
> `ESCENARIOS_PRUEBA_FREELANCE.md` para el Escenario 10 (sólo aparece como paso opcional en
> Escenario 4), pero en el video sí se llenó, y tiene asterisco de obligatorio (*) en este build.

---

## 3. Detalle de pedido — `wp_pedidodetalle.aspx?1055` (pestaña "Detalles")

Frames: `033_01m22s.png`–`036_01m29s.png`, `079_03m49s.png`, `208_11m41s.png` (vigente/liberado).

Página "Detalles de pedido", con dos links arriba: **"Editar pedido"** y **"Cancelar Pedido"**, y
botón **"Regresar"** a la derecha. Debajo, encabezado **"PEDIDO No.: 1055"**.

Sección **"Matriz de Puestos"**: tabla compacta tipo pívot con columnas Bloque | Productos | fecha
(22/08) | hora (08:00). Fila de producto: `Seguridad-IN | Jacob Whitesides 2019---Escenario10` con
valor `4 - T 1.00` (cantidad - turnos). Filas resumen: **Total Solicitados** (`4/3`, luego `4/4`
según cuántas reservaciones tiene vs. cuántas pide — el denominador sube según el detalle) y
**Presupuesto por día** (`$1,200.00`).

Sección **"Movimientos detalles pedido"**, pestaña **Detalles**, formulario de alta/edición del
detalle:

| Campo | Tipo | Valor visto |
|---|---|---|
| Estatus | solo lectura | Vigente → (tras liberar) **Liberado** |
| Evento Práctica | checkbox | sin marcar |
| Tipo personal * | solo lectura/combo | "Operativo" |
| Título * | texto | "Jacob Whitesides 2019---Escena[rio10]" |
| Producto | combo | "Seguridad-IN" |
| Lugar de Cita * | combo | "Estadio Azteca" |
| Dirección cita | textarea | igual a dirección del PEP |
| Otro | checkbox | |
| Indicaciones especiales | textarea | vacío |
| Bloque por producto | combo | "Ninguno" |
| Facturable | combo Sí/No | "NO" |
| Cantidad | numérico | 4 |
| Turnos | numérico | 1.00, con texto auxiliar gris **"8 Horas por turno"** a la derecha (deriva del catálogo del producto) |
| Fecha cita * | fecha+hora (combos HH / MM) | 22/08/2019 08:00 |
| Fecha liberación | fecha+hora | 19/08/2019 06:00 (día anterior, 2 horas antes de la hora de cita en este caso puntual del QA) |
| Fecha final cita | fecha+hora | 22/08/2019 16:00 (= fecha cita + 8h, el turno completo) |
| Presentación por producto | combo | catálogo de uniformes — valor elegido: **"Pantalón Negro de Vestir, Playera Azul y Chamarra Azul"** (texto completo visible luego en el portal Freelance como campo "Uniforme") |
| Completar con similares | combo Sí/No | "NO" |
| Fase del evento | combo | "No aplica" |
| Permitir cancelar | combo Sí/No | "NO" |

Botones: **Agregar Detalle** / **Cancelar**.

> Confirma literalmente el texto de Escenario 1 paso 23 (la lista de campos que debe mostrar la
> "flecha"/tooltip sobre el producto): el popup hover muestra exactamente **ID, Lugar de cita,
> Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, Cantidad reservados,
> Cantidad reservados real, Cantidad reservados con preasignación, Porcentaje completo, Fase del
> evento, Presentación producto, Indicaciones especiales** (frame `139_07m41s.png`).

---

## 4. Pestaña "Reservaciones" — preasignación / confirmación forzada / cancelación individual

Frames: `145_08m05s.png`, `159_08m34s.png`, `169_09m09s.png`, `195_10m51s.png`–`199_11m01s.png`,
`211_11m53s.png`.

Dentro del mismo `wp_pedidodetalle.aspx`, pestaña **"Reservaciones"**, sección con título en banda
azul **"Personal Confirmado"**:

- Campo de búsqueda **Nombre** (placeholder "Nombre completo / Alias").
- Dos botones de acción, a la derecha: **"Confirmación Forzada"** y **"Confirmación Preasignada"**
  (ambos en azul oscuro, estilo primario, lado a lado).
- Icono de impresora con texto **"Imprimir lista de Asistencia"**.
- Tabla: columnas **IdContacto | Nombre completo | Estatus** + columna de acción con icono **X**
  (deshabilitado/gris hasta que el pedido está liberado) para cancelar esa reservación individual.
- Hallazgo importante: **tanto "Confirmación Forzada" como "Confirmación Preasignada" dejan al
  empleado con Estatus = "CONFIRMADO"** en esta tabla — la UI operativa (lado empresa) NO muestra
  un estatus intermedio "PREASIGNADO" distinto; ambos botones terminan poblando la misma lista de
  "Personal Confirmado" con estatus `CONFIRMADO`. La diferencia preasignado/forzado/confirmado-
  voluntario debe vivir en un campo interno (tipo de confirmación / `regla_aplicada`) no expuesto
  directamente en esta grilla, sólo en el estatus final visible.
- Los 4 empleados preasignados en el escenario (vistos en la tabla, frame `199_11m01s.png`):
  **2795-Isaac Guerra Hernández, 3422-Amado Alberto Alvarado Salvador, 3891-Oscar Eduardo Mojica
  Reyes, 3926-Ignacio Méndez Ruíz** — nótese que estos IDs **no coinciden** con los IDs que indica
  el texto de `ESCENARIOS_PRUEBA_FREELANCE.md` para el Escenario 10
  (`3891,16338,33817,46486,54501`); el QA real usó otro set de 4 (ver sección 7).

### Cancelación individual (botón "X")

Frames `195_10m51s.png`–`197_10m56s.png`:

- Clic en el icono X de una fila abre un **modal de confirmación** titulado **"Cancelar"**, cuerpo:
  `Cancelar a... : 3422-Amado Alberto Alvarado Salvador(223)` (el número entre paréntesis — `223` —
  parece ser el **Id de la reservación/detalle de pedido-empleado**, no el id de contacto),
  botones **"Sí" / "No"**.
- Al confirmar, aparece una **notificación toast naranja/ámbar** en la esquina superior derecha de
  la barra de navegación con el texto **"Reservación cancelada"** y un icono de alerta (▲!), con un
  botón "x" para cerrarla manualmente (se queda visible varios segundos).
- Tras cancelar, la fila desaparece de "Personal Confirmado" y "Total Solicitados" en la Matriz de
  Puestos vuelve a mostrar sólo 3 confirmados sobre 4 pedidos (`4/3`).

> **Hallazgo clave para el proceso "Correr manualmente el proceso de cancelación de
> preasignados"**: en el video **no existe una pantalla/botón dedicado "Ejecutar proceso de
> cancelación de preasignados"**. Lo que el QA hizo para simular ese paso del guión fue **cancelar
> manualmente, uno por uno, con el icono X**, la reservación del empleado preasignado que no
> confirmaría (3422-Amado Alberto Alvarado Salvador). Es decir: el "proceso batch" mencionado en
> el texto del escenario aparentemente **no tenía UI propia en este build** — o el tester usó el
> botón de cancelación manual individual como equivalente funcional para la prueba. Esto es
> consistente con que, en el Excel `Scripts de Prueba Freelance.xlsx` (sheet "Otros Escenarios
> Pedidos"), la fila **"Correr manualmente el proceso de cancelación de preasignados" aparece
> resaltada en rojo** (frame `164_08m57s.png`) — probablemente marcando que este paso era
> ambiguo/problemático de ejecutar o verificar en la UI.

---

## 5. Portal AdminPersonal — catálogo de Empleados

Frames: `182_09m59s.png`–`192_10m31s.png`.

Menú superior (rol **AdminPersonal**): **Inicio | Empleados ▾ | Otros procesos ▾ | Salir**. El
submenú **Empleados ▾** despliega:

- Empleados
- Alta masiva de empleados
- Alta individual empleado
- Baja empleado
- Reactivación empleado
- Observaciones empleado
- Consulta registro TimeScan
- Cambio de cuenta de banco

(No se exploró el contenido de **"Otros procesos ▾"** en los frames muestreados — es el candidato
más probable para contener, en otro build o con otro rol, el proceso batch de cancelación de
preasignados, dado que no apareció en "Empleados ▾".)

Grid **"Empleado"** (listado): toolbar con botón **"+"** (alta), export **XLS**/**PDF**,
**"Selecciona columnas"**, filtro **"Buscar en"** (combo de campo) + **"valor"** + icono de
limpiar. Columnas visibles: **Id, Nombre Completo, Estatus, Sexo, Certeza, Correo electrónico,
Sucursal** (hay más columnas fuera de viewport, con scroll horizontal). Al hacer clic en el header
de columna aparece un menú: **Ordenar de A a Z / Ordenar de Z a A / Limpiar búsqueda**, más un
mini-filtro de rango **Desde / Hasta** + botón **Buscar** — es decir, el grid soporta filtro de
rango numérico directo en el header de "Id", no sólo el filtro superior.

### Edición de empleado (`te_empleadow.aspx?UPD,8161`)

Frame `189_10m19s.png`: formulario de edición con campos (parte baja visible): **Fecha ingreso\***,
**Fecha baja**, **Solicitud** (numérico), **Grado de estudios**, **Estatus estudios**, **Idiomas**,
**Accidente**, **Cirugías Tratamiento**, **Tipo sangre\*** (ej. "O+"), **Recomendado por**,
**Alias**, **Sucursal\*** (combo). Botones **Confirmar** / **Cancelar**.

- En este escenario, el QA edita al empleado **8161 - Alberto Roldán Palacios** y le cambia la
  **Sucursal de "Queretaro" a "CDMX"** — un paso no documentado explícitamente en el texto del
  Escenario 10, pero necesario en la práctica: el empleado "disponible" que debía poder ver el
  pedido liberado tenía que pertenecer a la sucursal correcta (CDMX, igual que el PEP/Lugar de
  cita del pedido) para que el pedido le apareciera en "Confirmación de eventos". **Esto confirma
  una regla de negocio implícita no documentada en el texto: la visibilidad de un pedido liberado
  para un freelance depende de la Sucursal del empleado, además de su Puesto/Certeza/vigencia.**

---

## 6. Portal Freelance — Confirmación de eventos (`wp_confirmacioneventosfl.aspx`)

Frames: `145_08m05s.png` (nav), `148_08m09s.png`, `149_08m13s.png`, `206_11m24s.png`–
`209_11m50s.png`.

Navbar Freelance: **Comunicados generales | Calendario de eventos | Saldos | Confirmación de
eventos | Aclaraciones | Salir**, usuario mostrado arriba a la derecha como **"Freelance"**.

Página **"Confirmación de eventos"**: dos columnas con encabezado azul:

- **"Eventos por confirmar"** (izquierda): lista de tarjetas, cada una con el formato
  `UNIDAD DE NEGOCIO--NombreEvento fecha hora (IdEventoDetalle)`, ej.:
  `SEGURIDAD--Jacob Whitesides 2019 20/08/19 06:00 (2408)`
  `SEGURIDAD--Jacob Whitesides 2019 22/08/19 08:00 (2409)`
  `CONTROL DE ACCESOS--Jacob Whitesides 2019 22/08/19 06:00 (2393)`
  `SEGURIDAD--Jacob Whitesides 2019 22/08/19 06:00 (2407)`
- **"Eventos confirmados"** (derecha): mismas tarjetas pero sin el Id entre paréntesis, ej.
  `SEGURIDAD..Jacob Whitesides 2019 22/08/19 08:00`.

Al hacer clic en una tarjeta de "Eventos por confirmar" se expande un panel con el detalle:

| Campo | Ejemplo |
|---|---|
| Evento | Jacob Whitesides 2019 |
| Puesto | Seguridad |
| Fecha | 22/08/19 08:00 a 22/08/19 16:00 |
| Turnos | 1.00 |
| Lugar | Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX |
| Dirección | (igual que Lugar) |
| Uniforme | Pantalón Negro de Vestir, Playera Azul y Chamarra Azul |
| Indicaciones Especiales | (vacío) |

Botón **"Confirmar"** → abre modal **"Confirmación al Evento"** con el texto
`JACOB WHITESIDES 2019--22/08/19 08:00` y botones **"Sí" / "No"**. Al aceptar, la tarjeta se mueve
de "Eventos por confirmar" a "Eventos confirmados" (sin recargar toda la página).

- **Antes** de correr la cancelación manual del preasignado, el evento `2409` (22/08/19 08:00) NO
  aparece en la lista de ningún otro empleado de seguridad fuera de los 4 preasignados — esto es lo
  que el escenario llama "no pueden ver el pedido".
- **Después** de cancelar manualmente la reservación de uno de los 4 preasignados (liberando un
  lugar: 4 solicitados / 4 preasignados-3 tras cancelar uno → queda hueco), el empleado
  **8161-Alberto Roldán Palacios** (tras moverlo a sucursal CDMX), al iniciar sesión como
  `aroldan`, **sí ve el evento `2409` en "Eventos por confirmar"** y puede confirmarlo con éxito,
  pasando a "Eventos confirmados". Esto valida el resultado esperado final del escenario.

---

## 7. Catálogo de empleados de prueba (Excel auxiliar, no parte de la app)

Frames `185_10m09s.png`, `211_11m53s.png` muestran `DatosFreelanceParaEscenarios_01.xlsx`, hoja
"Seguridad Certeza 1" — útil como referencia de datos de prueba (no UI del sistema), columnas:
**Empleado (Id), Nombre completo-Alias, Certeza, Pago, Id Puesto, Puesto, Vigente, Principal,
Estatus**, con un link al alias. Empleados de seguridad con certeza 1.0 e Id Puesto 16 ("Seguridad")
listados incluyen: 1-Victor N. Galindo Ramírez, 850-Carlos Augusto Martínez De la Rosa, **2795-Isaac
Guerra Hernández**, 3091-Antonio Castañeda Negrete, **3422-Amado Alberto Alvarado Salvador**,
**3891-Oscar Eduardo Mojica Reyes**, **3926-Ignacio Méndez Ruíz**, 4104-Guillermo Alonso Sánchez
Alvarez, 4998-César González Salcedo, 6252-Javier Gustavo Garcia Soria Sanchez, 6357-Ignacio Andrés
Razo Tapia, **8161-Alberto Roldán Palacios**, 10861-Victor Hugo Verduzco Rivas, 16338-Oscar
Becerril Hernández.

Esto confirma que el escenario real de QA usó los empleados 2795, 3422, 3891, 3926 (certeza 1.0,
puesto Seguridad) como los "4 preasignados", y 8161 (certeza 1.0, originalmente sucursal Querétaro,
reubicado a CDMX) como "el otro empleado de seguridad" — **no** los IDs literales
`3891,16338,33817,46486,54501` que aparecen en el texto `ESCENARIOS_PRUEBA_FREELANCE.md`. El texto
documenta la intención del escenario; el video documenta la ejecución real con datos distintos
(probablemente los IDs originales ya no existían/eran válidos en el momento de grabar).

---

## 8. Reglas de negocio / detalles NUEVOS no capturados en el texto ni evidentes en el schema

1. **Confirmación Forzada y Confirmación Preasignada dejan el mismo estatus "CONFIRMADO"** en la
   grilla de Reservaciones del pedido — no hay un estatus "PREASIGNADO" visible distinto en esta
   pantalla operativa. El enum `estado_reservacion_enum` del schema PeopleMovil (disponible,
   preasignado, confirmado_opcional, confirmado_voluntario, forzada, procesado, cancelado) es más
   granular que lo que el usuario operativo ve en pantalla; validar si esa granularidad debe
   exponerse en la UI o quedarse sólo en backend/auditoría.
2. **No se encontró una pantalla/botón dedicado para "ejecutar manualmente el proceso de
   cancelación de preasignados"** en los menús navegados (Operación, AdminPersonal). El QA
   simuló el resultado cancelando manualmente la reservación individual vía el icono "X" en
   Reservaciones. Esto es un hueco a decidir explícitamente en PeopleMovil: ¿exponer un botón de
   "ejecutar ahora" el job de autocancelación (parámetro `horas_lookahead_autocancel` /
   `horas_gracia_confirmacion` ya en `cat_parametros_globales`), visible para administración?
3. **Modal de cancelación individual** muestra un identificador numérico entre paréntesis junto al
   nombre del empleado — ej. `3422-Amado Alberto Alvarado Salvador(223)` — que no es el IdContacto
   (3422) sino aparentemente el **id interno de la reservación** (PK de la tabla puente
   pedido-detalle-empleado). Vale la pena exponer ese id en el equivalente de
   `reservacion_bitacora`/reservaciones para trazabilidad en confirmaciones de UI.
4. **Notificaciones toast**: patrón consistente de notificación ámbar/naranja en la esquina
   superior derecha de la barra de navegación tras una acción de cancelación (texto "Reservación
   cancelada"), con cierre manual (×) — no es un simple `alert()`, sino un componente de
   notificación persistente in-page.
5. **Visibilidad de pedidos por Sucursal del empleado**: se confirmó empíricamente (no está en el
   texto) que el campo Sucursal del empleado condiciona si ve o no un pedido/detalle liberado en su
   portal Freelance — el QA tuvo que reubicar al empleado 8161 de Querétaro a CDMX antes de que el
   pedido (con Id sucursal = CDMX) apareciera en su "Confirmación de eventos". Esto es una regla de
   elegibilidad adicional a Puesto + Certeza + Vigencia + Lista Negra que ya documenta el texto
   (Escenario 9, 11, 18).
6. **Presentación por producto = Uniforme**: el campo "Presentación por producto" capturado en el
   detalle del pedido (operación) es exactamente el mismo texto que se muestra como "Uniforme" en
   el detalle del evento en el portal Freelance — confirma que es el mismo dato, sólo renombrado
   por audiencia (interno vs. freelance).
7. **Catálogo de eventos de QA es muy acotado**: sólo 4 eventos existían en el combo "Id evento":
   Feria del Juguete 2017, Futbol América vs Pumas, Jacob Whitesides 2019, Tributo a Michael
   Jackson — útil como dato de contexto/semillas de prueba, no como catálogo real de producción.
8. **Catálogo de sucursales**: (Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro — 5
   sucursales fijas + "Otra".
9. **Username del portal Freelance = alias del empleado** (ej. `aroldan` para Alberto Roldán
   Palacios), consistente con la columna "Alias" del catálogo de empleados.
10. **Login unificado**: los tres roles (Operación, AdminPersonal, Freelance) usan la misma pantalla
    de login (`inicio.aspx`) y el mismo layout de aplicación "RRHH"; el menú de navegación cambia
    según el rol del usuario autenticado, confirmando un sistema de roles/permisos por usuario
    (relevante para el futuro RLS/roles de PeopleMovil).
