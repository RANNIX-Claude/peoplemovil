# Escenario 5 — Evidencia en video (carpeta "12 - Escenario5")

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\12 - Escenario5\`
185 capturas (`001_00m00s.png` … `185_08m54s.png`), video de YouTube "Escenario5" (canal WJaJa VideoClips, id `pOEo3n9jfAE`, duración 537s / 8m57s). Es la grabación **principal/completa** de Escenario 5 — más larga que las variantes "Entre Seriados" y "5AB" de carpetas hermanas (no cubiertas aquí).

Corresponde a la hoja **"Escenario 5"** de `ESCENARIOS_PRUEBA_FREELANCE.md`: *"Seriado con cancelación de un día para que no deje forzar ese día de otro pedido"*.

Metodología: muestreo uniforme de ~45 frames a lo largo de todo el video (pasos de 5, más frames adicionales en los puntos de inflexión: creación del pedido, matriz de bloque, cancelación de detalle, portal de confirmación freelance).

---

## 1. Flujo observado en pantalla

El video intercala tomas de la hoja Excel `Scripts de Prueba Freelance.xlsx` (pestaña "Escenario 5", guion de la prueba) con capturas reales del sistema **AppSCPF** (confirmado por el título de ventana "AppSCPF - GeneXus 15" visto en un alt-tab, frame `048_01m45s.png`; también se ve una base de datos SQL Server de nombre `SQL7002.DB_A3BCEE_ap...`, consistente con la pila legado GeneXus + SQL Server).

### 1.1 Alta del pedido (pantalla "Pedidos", `te_pedido.aspx?INS,0`)

Campos del bloque "Información General" (frames `011_00m20s`, `016_00m29s`, `031_01m04s`, `036_01m21s`, `043_01m33s`, `053_02m01s`, `063_02m40s`):

- **Cliente** * — combo con catálogo completo de clientes OCESA (alfabético). Seleccionado: `OCESA Promotora, S. A. de C.V.`. Opciones visibles en el desplegable (muestra parcial, orden alfabético): Magnos Comercialización de Entretenimiento, Maguen Team, Make Pro, Mandarina Marketing, Marketing Management México - Madrid, Marketing y Tendencias, Martinez López Jorge, Mas Volumen, MC Show Business, Mex Tenis, Mint Creative Lab, Mixología B.S., MMS Comunicaciones, MTV Networks de México, Música Esencial, Ocesa Anfiteatro, OCESA Comercial, Ocesa Presenta (aparece **dos veces** en el catálogo, posible duplicado de datos de prueba), OCESA Promotora.
- **Id Contacto** * — combo. Seleccionado: `Lucas Vázquez`.
- **Agregar contacto** — checkbox al lado de Id Contacto (alta rápida de contacto).
- **Id sucursal** * — combo. Opciones completas: `(Ninguno)`, `CDMX`, `Guadalajara`, `Monterrey`, `Otra`, `Queretaro`. Seleccionado: `CDMX`.
- **Unidad de negocio** * — combo. Seleccionado: `Operaciones Inmuebles` (primer pedido) / `PRG` (según guion, para el segundo pedido no confirmado en video — ver §3).
- **Id PEP** * — combo. Seleccionado: `Z-PEP-Temporal Operacione...` — confirma la convención de nombre **Z-PEP** para PEPs temporales ya documentada en el guion.
- **Id evento** * — combo. Vacío/`(Ninguno)` hasta seleccionar PEP; luego pasa a `Jacob Whitesides 2019` (nombre del evento de prueba).
- **Título** * — input libre. Valor usado: `Jacob Whitesides 2019---Escena[rio 5]` (se reutiliza como identificador del detalle en toda la prueba).
- **Lugar de cita** — combo. **Confirmado: con PEP temporal (Z-PEP) el campo nace en `Sin definir`**, igual que "Dirección lugar" (textarea) — coincide exactamente con el paso 6 del guion ("Validar que el sistema por defecto no trae lugar de cita, ni inmueble"). Tras elegir Lugar de cita = `Palacio de los Deportes`, el textarea "lugar"/"Dirección lugar" se autorellena con: `Av Viaducto Rio de la Piedad y Rio Churubusco S/N, Granjas México, 08400 Ciudad de México, CDMX`.
- **Otro** — checkbox (al lado de Lugar de cita / Dirección, probablemente para dirección manual libre).
- **Tipo de movimiento** * — combo con exactamente 3 opciones: `(Ninguno)`, `Pedido`, `Servicio interno`. Seleccionado: `Servicio interno` (coincide con guion).
- **Sociedad pagadora** * — combo (no se capturó su lista de opciones abierta).
- **Permitir cancelar confirmaciones** * — combo Sí/No. Seleccionado: `NO` (ver §2, es el campo que el guion llama "Permitir Cancelar" a nivel pedido).
- **Responsable** * — combo de personas físicas (catálogo de responsables/operadores internos), NO clientes: `(Ninguno)`, Angelica Jazmin Lopez Perez, Antonio de Jesus Mecalo Olmos, Cesar Ramirez Mejia, Gerardo Martinez Morales, Israel Benavid Solis Carrera, Jose Edgar Barrera Diaz, Juan Carlos Zavala Enriquez, Julio Cesar Angeles Ibarra, Ramon Roberto Garza Juarez.
- Links superiores: **Agregar Detalle** | **Agregar Factura**.
- Botones inferiores: **Confirmar** | **Regresar**.

No se vio en este video el campo "Complejidad" (el guion dice "En complejidad indicar que No Aplica" — probablemente aparece solo tras seleccionar la UN, no capturado en los frames muestreados).

### 1.2 Detalle de pedido (pantalla "Detalles de pedido", `wp_pedidodetalle.aspx?{idPedido}`)

Formulario de alta de un detalle (frame `083_03m49s.png`, formulario en blanco; `108_04m38s.png`/`148_06m36s.png`, formulario lleno):

Columna izquierda:
- **Estatus** (solo lectura): `Vigente` en alta; pasa a `Liberado` tras liberar el pedido.
- **Evento Práctica** — checkbox.
- **Tipo personal** * (solo lectura en el detalle, definido en el pedido): `Operativo`.
- **Título** * — input (hereda el del pedido, editable).
- **Producto** — combo. Seleccionado: `Especialista Estructuras Inm[uebles]-IN`.
- **Lugar de Cita** * — combo: `Palacio de los Deportes`.
- **Dirección cita** — textarea (autorellenada).
- **Otro** — checkbox.
- **Indicaciones especiales** — textarea.
- **Bloque por producto** — combo: `Ninguno` (antes de agrupar) → `1` (tras "Nuevo Bloque", ver §1.3).
- **Facturable** — combo Sí/No: `NO`.

Columna derecha:
- **Cantidad** — numérico: `1`.
- **Turnos** — numérico: `1.00`, con texto de ayuda **"12 Horas por turno"** junto al campo (coincide con el guion: "Debe mostrar 1 turno por 12 horas").
- **Fecha cita** * — date + hora (hh) + minuto (mm, selects de 00/06/etc.).
- **Fecha liberación** — date + hora + minuto.
- **Fecha final cita** — date + hora + minuto, **se autocalcula como Fecha cita + 12 horas** (p. ej. cita 12/08/2019 06:00 → fecha final cita 12/08/2019 18:00), consistente con "1 turno = 12 horas".
- **Presentación por producto** — combo: `(Ninguno)`.
- **Completar con similares** — combo Sí/No: `NO`.
- **Fase del evento** — combo: `No aplica` (el guion anota que en una versión decía "Ninguno" en vez de "No aplica"; en estos frames ya aparece correctamente como `No aplica`).
- **Permitir cancelar** — combo Sí/No: `NO` (campo a nivel **detalle**, distinto del "Permitir cancelar confirmaciones" a nivel **pedido**).
- Botones: **Agregar Detalle** | **Cancelar**.

Al guardar aparece un toast naranja: **"Registro Agregado Correctamente"** (frame `112_04m45s.png`/`148_06m36s.png`).

### 1.3 Matriz de Puestos (agrupación en bloque)

Tras dar de alta varios detalles con el mismo producto/puesto y "Nuevo Bloque", la pantalla "Detalles de pedido" muestra:

```
PEDIDO No.: 1050
Matriz de Puestos
Bloque | Productos                                          | 12/08  | 13/08  | 14/08  | 15/08  | 16/08
       |                                                     | 06:00  | 06:00  | 06:00  | 06:00  | 06:00
1      | Especialista Estructuras Inmuebles-IN | Jacob...    | 1 - T 1.00 | 1 - T 1.00 | 1 - T 1.00 | 1 - T 1.00 | 1 - T 1.00
Total Solicitados                                            | 1      | 1      | 1      | 1      | 1
Presupuesto por día                                          | $100.00| $100.00| $100.00| $100.00| $100.00
```
(frame `121_05m12s.png`)

Observación importante: las fechas usadas inicialmente fueron **12–16 de agosto de 2019 (lunes a viernes)**, pero la fecha del sistema en el momento de la grabación era **18/08/2019** (visible en el reloj de Windows). Como esas fechas ya habían quedado en el pasado, el operador **edita cada detalle existente y desplaza las fechas una semana hacia adelante**, a **19–23 de agosto de 2019** (también lunes a viernes), conservando el mismo Pedido 1050 / Bloque 1 (no se crea un pedido nuevo). La matriz final queda:

```
19/08  20/08  21/08  22/08  23/08
06:00  06:00  06:00  06:00  06:00
1-T1.00 1-T1.00 1-T1.00 1-T1.00 1-T1.00
```
(frame `167_07m38s.png`)

Regla implícita observada: **la fecha de cita de un detalle de pedido debe ser futura respecto a "hoy"** (al menos para que el flujo de liberación/confirmación del freelance funcione); fechas pasadas quedan "huérfanas" en el seriado.

Al hacer click sobre la celda de un día concreto en la matriz se abre un popup **"Editar Liberar Cancelar Pedido"** (frame `166_07m37s.png`) con campos de solo lectura: `ID` (p. ej. 2402 — el id interno del detalle individual), `Lugar de cita`, `Fecha cita`, `Fecha fin cita`, `Fecha liberación`, `Completar con similares`, `Cantidad reservados`, `Cantidad reservados real`, `Cantidad reservados con preasignación`, `Porcentaje completo`, `Fase de evento`, `Presentación producto`, `Indicaciones especiales`.

### 1.4 Liberación del pedido y botones a nivel cabecera

En la vista de detalle del pedido completo aparecen tres acciones de cabecera (frame `167_07m38s.png`): **Editar pedido** | **Cancelar Pedido** | botón **Regresar**. (El botón/; acción de "Liberar" no quedó capturado en un frame muestreado, pero el Estatus del detalle pasa de `Vigente` a `Liberado`, confirmando que ocurrió.)

### 1.5 Cancelación de UN día del seriado (miércoles 21/08)

Al entrar al detalle del miércoles (21/08/2019) vía "Modificación detalle de pedido", aparece un botón adicional **"Cancelar detalle"** (abajo a la izquierda, junto a "Modificar detalle"), distinto del "Cancelar Pedido" de cabecera (frame `170_07m48s.png`).

Al pulsarlo se abre un modal de confirmación (frame `175_08m13s.png`) con el texto **exacto**:

> **CANCELAR DETALLE**
> Deseas cancelar el detalle para : JACOB WHITESIDES 2019---ESCENARIO 5
> [**Sí**] [**No**]

Tras pulsar **Sí**, la Matriz de Puestos se refresca de inmediato y **la columna del 21/08 desaparece por completo** de la matriz, quedando solo 19/08, 20/08, 22/08 y 23/08 (frame `177_08m20s.png`):

```
Bloque Productos                                    19/08  20/08  22/08  23/08
                                                      06:00  06:00  06:00  06:00
1      Especialista Estructuras Inmuebles-IN|...     1-T1.00 1-T1.00 1-T1.00 1-T1.00
Total Solicitados                                    1/1    1/1    1/1    1/1
```

Esto **confirma pixel a pixel** el resultado esperado del guion: *"El bloque sigue existiendo, solo que ahora tiene 4 días (lunes, martes, jueves y viernes)"*. El bloque (`Bloque por producto = 1`) no se destruye ni se renumera; simplemente pierde la columna del día cancelado. La fila "Total Solicitados" cambia de formato de `1` a `1 /1` después de que el freelance confirma cada día (numerador/denominador = confirmados/solicitados, ver §1.6).

### 1.6 Portal del freelance ("RRHH", confirmación de bloque)

Login del portal freelance (frame `149_06m42s.png`): título `RRHH`, campos `Usuario` (`mlicea` = Marisol Licea) y `Contraseña`, botón `Ingresar`. Mensaje de validación visto: *"El usuario debe estar autenticado."*

Menú superior del portal (frame `150_06m46s.png`): **Comunicados generales | Calendario de eventos | Saldos | Confirmación de eventos | Aclaraciones | Salir**, con selector de rol arriba a la derecha mostrando "Freelance".

Pantalla **"Confirmación de eventos"** (`wp_confirmacioneventosfl.aspx`), dos columnas:

- **"Eventos por confirmar"**: el bloque pendiente aparece como **UNA sola tarjeta** que agrupa los 5 días, con encabezado:
  `ESPECIALISTA ESTRUCTURAS INMUEBLES--Jacob Whitesides 2019 19/08/19 06:00 (2400) BLOQUE`
  y campos: `Evento` (Jacob Whitesides 2019), `Puesto` (Especialista Estructuras Inmuebles), **`Fecha`: `19/08/19 06:00 a 23/08/19 06:00`** (rango completo del bloque, resaltado en pantalla), `Turnos` (1.00), `Lugar`, `Dirección`, `Uniforme`, `Indicaciones Especiales`, y un único botón **"Confirmar"** que confirma el bloque entero de una sola acción (frame `155_07m01s.png`).
- **"Eventos confirmados"**: tras confirmar, aparecen **5 renglones individuales**, uno por día, con el formato `ESPECIALISTA ESTRUCTURAS INMUEBLES..Jacob Whitesides 2019 {DD/MM/19} 06:00` para 19/08, 20/08, 21/08 (incluye el miércoles **antes** de que se cancele — frame `179_08m31s.png`), 22/08 y 23/08.

Importante para el modelo de datos: **el freelance confirma el bloque completo en un solo clic**, pero el sistema conserva y muestra la confirmación desglosada por día/detalle individual.

Durante la navegación por esta pantalla aparece una ráfaga de **toasts de notificación** (formato `Pedido: {id} bloque : {n}` / `Detalle del bloque : {id}`, frames `182_08m37s.png`–`184_08m45s.png`) con IDs de pedido muy diversos (886, 912, 905, 952, 920, 907, 932, 1047, 768, 903, 946, 937...) — parecen notificaciones genéricas de otros pedidos/bloques del ambiente de pruebas disparándose en cascada (posible efecto de reconexión/polling), **no específicas de este escenario**; se documentan solo como evidencia del formato de toast del sistema, no como regla de negocio del Escenario 5.

---

## 2. Catálogo de campos y controles observados (resumen)

| Pantalla | Campo | Tipo | Valores / notas |
|---|---|---|---|
| Pedidos (cabecera) | Cliente | combo búsqueda | catálogo completo de clientes |
| | Id Contacto | combo | contactos del cliente |
| | Agregar contacto | checkbox | alta rápida de contacto |
| | Id sucursal | combo | (Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro |
| | Unidad de negocio | combo | Operaciones Inmuebles, PRG, Seguridad, ... |
| | Id PEP | combo | PEPs de la UN; temporales con prefijo `Z-PEP-` |
| | Id evento | combo | depende del PEP |
| | Título | texto libre | |
| | Lugar de cita | combo | vacío ("Sin definir") si PEP es Z-PEP temporal |
| | Dirección lugar / lugar | textarea | autorellenada al elegir Lugar de cita |
| | Otro | checkbox | |
| | Tipo de movimiento | combo | (Ninguno), Pedido, Servicio interno |
| | Sociedad pagadora | combo | (opciones no capturadas) |
| | Permitir cancelar confirmaciones | combo Sí/No | a nivel pedido |
| | Responsable | combo | catálogo de personas (operadores internos) |
| Detalles de pedido | Estatus | solo lectura | Vigente → Liberado |
| | Evento Práctica | checkbox | |
| | Tipo personal | solo lectura (detalle) | Operativo |
| | Producto | combo | catálogo de productos de la UN |
| | Lugar de Cita / Dirección cita | combo + textarea | |
| | Bloque por producto | combo | Ninguno / id numérico de bloque |
| | Facturable | combo Sí/No | |
| | Cantidad / Turnos | numérico | ayuda "12 Horas por turno" |
| | Fecha cita / Fecha liberación / Fecha final cita | date+hora+min | Fecha final cita = Fecha cita + 12h (automático) |
| | Presentación por producto | combo | (Ninguno) |
| | Completar con similares | combo Sí/No | |
| | Fase del evento | combo | No aplica |
| | Permitir cancelar | combo Sí/No | a nivel detalle |
| Matriz de Puestos | — | tabla | Bloque, Productos, 1 columna por fecha, fila Total Solicitados, fila Presupuesto por día |
| Popup celda matriz | — | solo lectura | ID, Lugar de cita, Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, Cantidad reservados, Cantidad reservados real, Cantidad reservados con preasignación, Porcentaje completo, Fase de evento, Presentación producto, Indicaciones especiales |
| Portal freelance (RRHH) | Usuario / Contraseña | texto / password | login |
| | menú | nav | Comunicados generales, Calendario de eventos, Saldos, Confirmación de eventos, Aclaraciones, Salir |
| Confirmación de eventos | tarjeta "bloque" | — | Evento, Puesto, Fecha (rango), Turnos, Lugar, Dirección, Uniforme, Indicaciones Especiales, botón Confirmar |

### Mensajes exactos capturados

- Toast de alta de detalle: **"Registro Agregado Correctamente"**.
- Modal de cancelación de detalle — título: **"CANCELAR DETALLE"**; cuerpo: **"Deseas cancelar el detalle para : {TÍTULO}"**; botones **"Sí"** / **"No"**.
- Login del portal freelance, error de sesión: **"El usuario debe estar autenticado."**
- Toasts genéricos de fondo: **"Pedido: {id} bloque : {n}"**, **"Detalle del bloque : {id}"**.

---

## 3. Lo que NO quedó capturado en este video

El guion de `ESCENARIOS_PRUEBA_FREELANCE.md` para Escenario 5 continúa con un **segundo pedido** (UN **PRG**, producto **Riger**, cantidad 1 / turno 1, fecha de cita = el miércoles recién cancelado, fase de evento "Show", **sin bloque**) cuyo objetivo es **forzar la asignación de la persona que confirmó el bloque anterior**, esperando que el sistema **no lo permita** (por función del puesto), y luego repetir la prueba cambiando la propiedad del puesto para que sí permita la confirmación entre seriados.

En los 185 frames de esta carpeta (hasta 08m54s, fin de la grabación) **no se observa** la creación de ese segundo pedido ni el intento de asignación forzada ni el mensaje de rechazo correspondiente — la grabación termina en la pantalla de "Confirmación de eventos" del portal freelance, inmediatamente después de la cancelación del detalle del miércoles. Es posible que esa parte esté cubierta en las variantes hermanas ("Entre Seriados" / "5AB") mencionadas en el encargo, o que no se haya grabado. No se debe asumir el comportamiento del segundo pedido a partir de este video; para esa parte hay que apoyarse únicamente en el texto del guion QA.

---

## 4. Reglas de negocio a codificar en Postgres (seriados / cancelación de un día)

1. **Un "bloque" agrupa N `pedido_detalle`** (uno por día/turno) bajo un mismo `id_bloque` (aquí numérico simple, p. ej. `1`, único dentro del pedido). El bloque es la unidad de agrupación para presentar la "Matriz de Puestos", pero **cada día sigue siendo un registro independiente** (con su propio id interno, p. ej. 2400–2402 en los frames) con sus propias fechas, cantidad, turnos, reservas y estatus.
2. **Cancelar un día del seriado (`cancelar_detalle`) no cancela el bloque ni el pedido.** Debe marcar solo ese `pedido_detalle` como cancelado (o eliminarlo de la vista activa) y la matriz/consulta de "días del bloque" debe recalcularse excluyendo ese día — sin tocar cantidad/turnos/estatus de los demás días del bloque.
3. **El cupo/plaza liberado por el día cancelado del seriado NO debe quedar disponible para que otro pedido distinto "fuerce" una asignación sobre esa fecha/puesto usando la confirmación que la persona ya dio para el bloque original.** Es decir: la cancelación de un día de un seriado confirmado debe dejar ese slot (fecha + PEP/lugar + puesto) genuinamente libre para asignación normal, pero **sin arrastrar automáticamente la "certeza"/confirmación que el empleado dio sobre el bloque entero** hacia un pedido nuevo que intente forzar esa misma fecha. En otras palabras: la confirmación de un empleado está ligada al `pedido_detalle` (día) específico, no al bloque como superconjunto; cancelar un día debe invalidar/remover cualquier reserva/confirmación asociada a ese día puntual, de forma que un segundo pedido que intente forzar la asignación de la misma persona en esa fecha deba pasar nuevamente por todas las validaciones normales de asignación forzada (certeza, puesto vigente, empalme, lista negra, etc.) — no heredar aprobación del bloque cancelado.
4. **Validación de puesto en asignación forzada entre seriados distintos:** el guion exige que, al intentar forzar sobre el día liberado a la misma persona pero para un **producto/puesto distinto** (Riger vs. Especialista Estructuras Inmuebles) de **otra UN** (PRG vs. Operaciones Inmuebles), el sistema **rechace la asignación "en función del Puesto"** salvo que una propiedad del puesto habilite explícitamente "permitir confirmación entre seriados". Esto implica un flag a nivel `cat_puestos` (algo como `permite_confirmacion_entre_seriados boolean default false`) que la regla de asignación forzada debe consultar antes de permitir que una persona ya comprometida en un seriado (aunque sea con un día cancelado) se asigne a otro pedido/puesto en la misma fecha.
5. **Confirmación de bloque = acción atómica sobre N días, pero con registro individual por día.** El flujo del portal freelance confirma los 5 días con un solo clic, pero el sistema debe persistir una confirmación (evento/registro) por cada `pedido_detalle` del bloque, de forma que cancelar o consultar un día individual no dependa de desarmar la confirmación de todo el bloque.
6. **La fecha de cita de un detalle debe validarse contra "hoy".** El flujo de edición-y-reenvío observado (mover fechas pasadas 12–16/08 a 19–23/08) sugiere que fechas de cita ya vencidas no son operables en el ciclo de liberación/confirmación; conviene una validación/estado explícito (p. ej. `vencido`) en vez de dejarlo implícito.
7. **Doble nivel de "permitir cancelar":** existe un flag a nivel **pedido** ("Permitir cancelar confirmaciones") y otro a nivel **detalle** ("Permitir cancelar"); ambos deben modelarse como columnas separadas (`pedidos.permite_cancelar_confirmaciones`, `pedido_detalle.permite_cancelar`) — no colapsarlos en un solo campo, y la regla de cancelación de un detalle del seriado por operación (back-office) es independiente de si el **empleado** puede cancelar su propia confirmación desde el portal.
8. **Mensaje/UX de confirmación de cancelación por detalle:** replicar el texto "¿Deseas cancelar el detalle para: {título}?" como confirmación obligatoria antes de ejecutar la baja de un día del seriado, para evitar cancelaciones accidentales de un solo día dentro de un bloque de varios.
