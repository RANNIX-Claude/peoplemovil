# Validación visual — Escenario 1 (Pedido Metropólitan/Jacob Whitesides, Seguridad, Sin Cancelación)

Fuente: 107 capturas frame-by-frame en
`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\16 - Escenario1\`
(video "Escenario1", `Xk2blIjesjg`, 285s). Se revisó una muestra homogénea de ~40 imágenes a lo
largo de toda la secuencia (frames 001, 004, 007... hasta 107), cruzando cada una contra los pasos
transcritos en `ESCENARIOS_PRUEBA_FREELANCE.md` (Hoja: Escenario 1).

El sistema real es una app ASP.NET/GeneXus clásica, no SPA: `integramx-001-site2.btempurl.com`,
rutas `te_pedido.aspx` (alta), `te_pedidowow.aspx` (listado/work-with), `wp_pedidodetalle.aspx?<id>`
(ficha de detalle). Usuario de la demo: perfil "Operacion", menú superior `RRHH | Inicio |
Operaciones ▾ | Salir`.

---

## 1. Pantalla "Pedidos" — Alta (`te_pedido.aspx?INS,0`)

Panel único "Información General", con enlaces arriba del panel (antes de guardar, visibles pero no
funcionales hasta Confirmar): **Agregar Detalle** | **Agregar Factura**.

Orden EXACTO de campos (de arriba hacia abajo, columna izquierda; "Agregar contacto" checkbox está
a la derecha, alineado con Id Contacto):

| # | Campo | Control | Obligatorio (*) | Observado |
|---|---|---|---|---|
| 1 | Cliente | combo | * | "OCESA Promotora, S.A. de C...." |
| 2 | Id Contacto | combo | * | "Mario Villa Vera" — checkbox "Agregar contacto" a la derecha |
| 3 | Id sucursal | combo | * | Opciones vistas: (Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro |
| 4 | Unidad de negocio | combo | * | "Seguridad" |
| 5 | Id PEP | combo | * | "EL-AT-2016-11-11T214EL-A S..." (depende de la UN elegida) |
| 6 | Id evento | combo | * | Opciones vistas: (Ninguno), Feria del Juguete 2017, Futbol América vs Pumas, Jacob Whitesides 2019, Tributo a Michael Jackson |
| 7 | Título | texto | * | Se autocompleta con "{evento}--Escenario1" al elegir evento (editable) |
| 8 | Lugar de cita | combo | — | Se autocompleta con "Teatro Telcel" al elegir el PEP |
| 9 | Dirección lugar | textarea (readonly visual) | — | Se autocompleta "Lago Zurich 245" |
| 10 | Otro | checkbox | — | |
| 11 | Tipo de movimiento | combo | * | **BUG confirmado visualmente**: sólo lista "Pedido" (el texto decía "únicamente muestra Pedido" — se confirma en pantalla, el combo no se puede desplegar a una 2ª opción) |
| 12 | Sociedad pagadora | combo | * | "Operadora de Centros de Es..." — aparece ya con una sociedad default aun antes de elegir UN (coincide con la observación del texto: "Antes de seleccionar la UN la sociedad pagadora está por default con ID 10") |
| 13 | Permitir cancelar confirmaciones | combo | — | **Es un COMBO con valores SI/NO**, no checkbox. Visto en "NO" |
| 14 | Responsable | combo | * (asterisco visible) | Opciones de personas, ej. "Jose Edgar Barrera Diaz". Aunque el guion de texto no lo pide como paso explícito en Escenario 1, el campo trae asterisco rojo = obligatorio para poder Confirmar |

Botones de pie: **Confirmar** / **Regresar** (no "Aceptar" como dice el texto — el texto parafrasea,
el botón real dice "Confirmar").

Tras Confirmar, la app navega a `te_pedidowow.aspx` (listado) mostrando el nuevo pedido con
**Estatus = "Vigente"** (no "Normal" ni "NINGUNO" — ver sección 3 sobre por qué el texto reporta otra
cosa).

## 2. Pantalla "Pedidos" (listado / work-with, `te_pedidowow.aspx`)

Toolbar: botón `+` (alta rápida), icono **XLS**, icono **PDF**, dropdown **"Selecciona columnas"**,
filtro `Buscar en [combo: Id pedido] valor [___] [< >] [0]` (paginación numérica a la derecha del
input de valor).

Columnas EXACTAS de la grilla (izquierda a derecha):

`Id | Título | Estatus | Unid.Neg. | Sucursal | lugar | Responsable | Complejidad | T.Mov | PeP|Descripción`

Valores de Estatus observados en la grilla: **Vigente**, **Procesado**, **Cancelado** (tras cancelar
el pedido 1046 al final del escenario, su fila cambia a "Cancelado").

## 3. Pantalla "Detalles de pedido" (ficha, `wp_pedidodetalle.aspx?<id>`)

Única pestaña visible: **"Detalles"**. (El texto de pasos 23/24 sugiere "tres pestañas" — en las
capturas disponibles sólo se ve una pestaña "Detalles"; no se alcanzó a ver pestañas adicionales en
la muestra revisada, puede requerir scroll u otro estado del pedido.)

Layout en DOS COLUMNAS. Columna izquierda:

| Campo | Control | Notas |
|---|---|---|
| Estatus | texto (readonly) | Visto = **"Vigente"** (no "Normal"). Este es el estatus del PEDIDO reflejado en la ficha de detalle, probablemente el bug reportado en paso 11 ("aparece como NINGUNO") se refiere a un estado distinto/anterior o a otro build — en esta captura es "Vigente" consistentemente |
| Evento Práctica | checkbox | |
| Tipo personal | texto plano (no combo) | "Operativo" — confirma que para Seguridad sólo se fuerza Operativo, sin dropdown |
| Título * | texto | prerrellenado y editable |
| Producto | combo | "Seguridad-MA" |
| Lugar de Cita | combo | "Teatro Telcel" |
| Dirección cita | texto | "Lago Zurich 245" |
| Otro | checkbox | |
| Indicaciones especiales | textarea | |
| Bloque por producto | combo | "Ninguno" |
| Facturable | combo (SI/NO) | "NO" — confirma el bug del texto: no viene prerrellenado "Sí" por default |

Columna derecha:

| Campo | Control | Notas |
|---|---|---|
| Cantidad | número | 2 |
| Turnos | número | 3.00 |
| **"8 Horas por turno"** | texto estático junto a Turnos | **Sí aparece** (contradice la observación original del texto "no muestra la información"; en esta grabación se ve y queda resaltado/subrayado por el narrador justo al elegir el producto — parece un bug ya corregido para esta build, el texto script lo marca con doble "x" = corregido) |
| Fecha cita * | fecha + combo hora (00-23) + combo minuto | ej. 08/08/2019, 06:00 |
| Fecha liberación | fecha + hora + minuto | ej. 07/08/2019, 00:00 |
| **Fecha final cita** | fecha (auto) + hora + minuto | **Campo NO mencionado en el texto ni implementado en el React**: se calcula solo (ej. 09/08/2019 06:00) cuando se ponen Cantidad/Turnos y Fecha cita — es la fecha/hora en que termina el turno |
| Presentación por producto | combo | catálogo ligado al producto, ej. "Pantalón Negro de Vestir, Playera Azul y Chamarra Azul" (un único registro combinado, no una lista libre) — **campo obligatorio en la práctica**: ver mensaje de validación abajo |
| Completar con similares | **combo SI/NO** (no checkbox) | |
| Fase del evento | combo | "No aplica" por default |
| Permitir cancelar | combo SI/NO | "NO" |

Botones: **Agregar Detalle** / **Cancelar**.

### Mensaje de validación (texto exacto capturado)

Toast naranja en la esquina superior derecha, con icono ⓘ y botón ×:

> **"La Presentación del producto es requerida"**

Esto confirma que `presentacion_id` es obligatorio en la práctica del sistema real aunque la UI no
lo marque con asterisco — el React actual lo trata como opcional ("— sin presentación —").

### Confirmación de alta de detalle

Toast naranja arriba a la derecha:

> **"Registro Agregado Correctamente"**

---

## 4. "Matriz de Puestos" (la "Matriz de información" del paso 22)

Tras agregar el detalle, la app regresa a la ficha del pedido (`wp_pedidodetalle.aspx?1046`) con una
cabecera de 3 enlaces + botón:

`Editar pedido` | `Liberar Pedido` | `Cancelar Pedido` ................. `[Regresar]`

`PEDIDO No.: 1046`

**Es una tabla PIVOTE, no una tabla plana por detalle.** Estructura real:

- Columna fija 1: **Bloque**
- Columna fija 2: **Productos** (texto compuesto "`{producto} | {título del pedido}`", ej.
  "Seguridad-MA | Jacob Whitesides 2019--Escenario1")
- Una columna por **cada fecha de cita** (ej. "08/08"), con una sub-fila de **hora** debajo del
  encabezado de fecha (ej. "06:00")
- Celda de datos = `"{cantidad} - T {turnos}"`, ej. **"2 - T 3.00"**
- Fila de pie **"Total Solicitados"** = suma de cantidades (ej. 2)
- Fila de pie **"Presupuesto por día"** = monto (ej. "$ 1,800.00")

Esto es MUY distinto de "Fecha, hora, productos, Turnos, Totales (personal y monto)" leído
literalmente como columnas separadas — en realidad fecha+hora son el ENCABEZADO DE COLUMNA (pivote
por fecha), no columnas de la fila.

Debajo: sección **"Movimientos detalles pedido"** con una sub-pestaña **"Detalles"** (no se alcanzó
a ver su contenido expandido en la muestra).

## 5. Flyout al pasar el cursor sobre la celda de la matriz (pasos 23/24 del texto)

Al posicionar el mouse sobre la celda "2 - T 3.00" aparece un panel flotante con encabezado de 3
enlaces en vez de 4:

> **Editar | Liberar | Cancelar Pedido**

(El texto esperaba "Editar, Reservaciones, Cancelar y Liberar" — en pantalla real sólo se ven 3
acciones y **no aparece "Reservaciones"** como opción de este flyout específico; coincide con la nota
del QA "revisar punto una vez más con ayuda de Leo" — bug/duda confirmada visualmente, no se ve
"Reservaciones" en ningún frame muestreado).

Debajo de esos 3 enlaces, el panel muestra el detalle completo del registro — esto SÍ corresponde al
paso 23 ("Al posicionarse sobre el producto debe mostrar..."), con TODOS los campos esperados
presentes y en este orden exacto:

```
ID                                   2382
Lugar de cita                        Teatro Telcel
Fecha cita                           08/08/2019 06:00
Fecha fin cita                       09/08/2019 06:00
Fecha liberación                     07/08/2019 00:00
Completar con similares              SI
Cantidad reservados                  0
Cantidad reservados real             0
Cantidad reservados con preasignación 0
Porcentaje completo                  0.00
Fase de evento                       (vacío)
Presentación producto                Pantalón Negro de Vestir, Playera Azul y Chamarra Azul
Indicaciones especiales              (vacío)
```

Nota: el campo en pantalla real se llama **"Fecha fin cita"**, no "Fecha Fin Cita" con mayúsculas
distintas, y aparece **"Presentación producto"** y no "Presentación" a secas.

## 6. Cancelación del pedido (paso 25)

Al pulsar "Cancelar Pedido" aparece un modal centrado:

- Título: **"CANCELAR PEDIDO"**
- Cuerpo: vacío/sin texto de confirmación visible en la captura
- Botones: **Sí** (azul) / **No** (gris)

Tras confirmar con "Sí", la app vuelve al listado `te_pedidowow.aspx` y el pedido 1046 aparece con
**Estatus = "Cancelado"**, confirmando el resultado esperado del paso 25. No se logró capturar en la
muestra el error reportado en el texto ("nos mostró un error al querer regresar al menú de
pedidos") — posiblemente es un toast muy breve entre dos frames consecutivos de la muestra (~2-3s de
separación); no se descarta pero no quedó evidencia visual directa.

---

## 7. Comparación campo-por-campo contra `SitiosAsignacion.jsx`

Archivo revisado: `C:\Users\ASUS\OneDrive\work\PeopleMovil\Dev\peoplemovil-app\src\pages\SitiosAsignacion.jsx`

### Modal "Registro de pedido" (alta) vs. pantalla real "Pedidos"

| Campo real (orden) | ¿Existe en React? | Gap |
|---|---|---|
| Cliente | Sí | — |
| Id Contacto | Sí (`Contacto`) | — |
| **Id sucursal** (CDMX/Guadalajara/Monterrey/Otra/Queretaro) | **No** | **React gap**: no existe ningún campo "sucursal" en `PEDIDO_VACIO` ni en el formulario — el sistema real lo pide ANTES de Unidad de negocio y antes de PEP, como filtro geográfico independiente de "Sitio". |
| Unidad de negocio | Sí | — |
| Id PEP (`partida_presupuestal_id`) | Sí | — |
| Id evento | Sí, con alta rápida de evento | — |
| Título | Sí | — |
| Lugar de cita | Sí | — |
| Dirección lugar (autocompletada, readonly) | **No** — React sólo autocompleta `sitio_id`/`lugar_cita_id`, no hay textarea de dirección visible en el modal | **React gap**: falta mostrar la dirección del inmueble como feedback visual al elegir PEP |
| Otro (checkbox) | No | Gap menor |
| Tipo de movimiento | Sí | — |
| Sociedad pagadora | Sí | — |
| **Permitir cancelar confirmaciones como COMBO SI/NO** | Implementado como **checkbbox boolean** (`permitir_cancelaciones`) | **React gap de tipo de control**: el sistema real usa un combo (y el default visible en el escenario es "NO"), el React usa checkbox marcado=true por defecto (sentido invertido de affordance) |
| Responsable | Sí, pero **opcional** en React | **React gap**: en el sistema real el campo trae asterisco rojo (obligatorio); en React no es `required` |
| Sitio/inmueble explícito como combo propio | Sí (React lo expone como campo separado "Sitio / inmueble *") | El sistema real NO tiene un combo "Sitio" visible en el alta — el sitio se deriva 100% del PEP elegido y no se ve como campo editable en esta pantalla. El React lo vuelve editable manualmente, lo cual es una diferencia de modelo (puede ser intencional para destrabar casos sin PEP con inmueble predeterminado) |
| Complejidad / Duración / Días (sección "opcional") | Sí, en `<details>` | El sistema real no mostró esta sección en Escenario 1 (es de Escenario 2/3, UN PRG) — consistente, no es gap. |

### Modal "Agregar detalle" vs. pantalla real "Detalles de pedido"

| Campo real | ¿Existe en React? | Gap |
|---|---|---|
| Estatus (del pedido, readonly) | No se muestra en el modal de detalle | Gap menor — informativo |
| Tipo personal (texto fijo "Operativo" para Seguridad) | Sí, pero como **combo editable** (`tiposPersonal` select) | **React gap**: el sistema real NO deja elegir tipo de personal para Seguridad, lo fuerza a "Operativo" (texto plano, no combo). React permite elegir libremente. |
| Título (editable, prerrellenado) | **No existe en el modal de detalle del React** | Gap — el real permite re-editar el título por detalle |
| Producto | Sí | — |
| Lugar de Cita / Dirección cita | **No existen en el modal de detalle** (sólo existen en el pedido general) | Gap — el real los repite/permite overridear por detalle |
| Otro (checkbox) | No | Gap menor |
| Indicaciones especiales | Sí | — |
| Bloque por producto | **No existe** | **React gap importante**: no hay concepto de "bloque" en el modelo de detalle de React; el sistema real agrupa detalles en bloques (clave para Escenario 2/3 con Staff) |
| Facturable (combo SI/NO) | **No existe** | **React gap**: falta el campo Facturable en el detalle |
| Cantidad | Sí | — |
| Turnos | Sí | — |
| **"X Horas por turno" (texto informativo junto a Turnos)** | Sí, aproximado: React muestra "· se maneja 1 turno = N horas" pero como párrafo debajo del producto, no junto a Turnos | Diferencia de layout, no gap funcional grave |
| Fecha cita (+ hora + minuto) | Sólo **fecha** (`type="date"`), **sin selector de hora/minuto** | **React gap**: falta la granularidad de hora/minuto en fecha de cita |
| Fecha liberación (+ hora + minuto) | Sólo fecha, sin hora/minuto | **React gap**: igual que arriba |
| **Fecha final cita** (fecha/hora fin, autocalculada) | **No existe en absoluto** | **React gap**: falta completamente este campo/concepto (fin de turno calculado) |
| Presentación por producto | Sí, combo "— sin presentación —" opcional | **React gap de validación**: en el sistema real este campo es obligatorio en la práctica (ver mensaje "La Presentación del producto es requerida"); en React no es `required` |
| Completar con similares | Implementado como **checkbox** | **React gap de tipo de control**: el real es combo SI/NO |
| Fase del evento | **No existe** | **React gap**: falta el campo Fase del evento (con default "No aplica") |
| Permitir cancelar (por detalle) | **No existe** (sólo existe a nivel pedido) | **React gap**: el real permite esta bandera también por detalle, no sólo por pedido |

### Vista "Matriz de puestos" / tabla de detalles

| Real | React (pestaña "Matriz de puestos") | Gap |
|---|---|---|
| Tabla **pivote**: filas = Bloque+Producto, columnas = fechas de cita (una por fecha, con sub-fila de hora), celda = "Cant - T Turnos" | Tabla **plana**: una fila por detalle con columnas fijas `# / Puesto / Producto / Fecha cita / Cant. req. / Reservados / % / Cobertura / Estado` | **React gap estructural grande**: el layout real es un pivote por fecha (crítico para ver varios días de un vistazo, como en Escenario 4/5 con seriados); el React es una lista simple. No es necesariamente "incorrecto" como alternativa de UX, pero no replica el comportamiento real. |
| Fila "Total Solicitados" | No existe fila de totales en la tabla (sólo KPIs arriba: Cobertura/Detalles/Reservaciones) | Gap menor — cubierto parcialmente por los KPI cards |
| Fila "Presupuesto por día" ($) | No existe (sólo "Costo estimado" a nivel pedido en la pestaña General) | Gap — falta el desglose de presupuesto por día |
| Flyout "Editar / Liberar / Cancelar Pedido" + ficha de 12 campos al pasar el mouse sobre la celda | No existe hover/flyout en la tabla del React; las acciones Editar/Liberar/Cancelar sólo existen a nivel de pedido completo (botones fijos arriba) | **React gap**: falta la interacción de hover-detalle y las acciones por detalle individual (editar/cancelar un detalle específico, no sólo el pedido entero) |
| Listado "Pedidos" con columnas `Id/Título/Estatus/Unid.Neg./Sucursal/lugar/Responsable/Complejidad/T.Mov/PeP|Descripción` + exportar XLS/PDF + selector de columnas + buscador por Id | React: `Folio/Título/Fecha evento/Sitio/Cliente/Status/Total` + sólo exportar CSV | Columnas distintas; falta Sucursal, Responsable, Complejidad, T.Mov, PEP como columnas; falta exportar a PDF y "Selecciona columnas"; el buscador real filtra por Id, el de React por folio/título (ya cubierto, pero con menos granularidad) |

---

## 8. Mensajes de validación/error con texto exacto encontrados

1. **"La Presentación del producto es requerida"** (toast naranja, alta de detalle) — confirma bug
   implícito del guion de texto: aunque "Facturable" se señala como el campo sin prerrellenar,
   realmente el bloqueador visible es Presentación.
2. **"Registro Agregado Correctamente"** (toast naranja, éxito al agregar detalle).
3. Modal de confirmación **"CANCELAR PEDIDO"** con botones Sí/No (sin texto de cuerpo capturado).

No se logró capturar en la muestra evenly-spaced el mensaje de error al "regresar al menú de
pedidos" tras cancelar, mencionado en la observación del paso 25 del texto.
