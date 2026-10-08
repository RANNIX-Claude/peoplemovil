# Escenario 13 — Walkthrough visual (carpeta "05 - Escenario13")

Fuente: 130 capturas de un video de QA de 2019 (`JzOsQu9xH9c`, 7m26s), carpeta
`doc\Panttallas del sistema tomados desde varios video escvenarios de pruebas de pruebas\05 - Escenario13\`.
Muestreo revisado: ~33 frames distribuidos a lo largo de todo el video (001, 005, 009, 013, 017, 021, 025,
029, 033, 037, 041, 045, 049, 053, 057, 061, 065, 069, 073, 077, 081, 085-095 contiguos, 097, 101, 105, 109,
113, 117, 121, 125, 129-130).

Este escenario corresponde a **Escenario 13: "Validar que no se puedan cancelar reservaciones"** de
`ESCENARIOS_PRUEBA_FREELANCE.md` (líneas 396-426). El texto del script coincide exactamente con lo que se ve
en pantalla: el analista QA tiene abierto un Excel **"Scripts de Prueba Freelance.xlsx"** (hoja "Otros
Escenarios Pedidos", filas 74-99) con el mismo texto palabra por palabra que el `.md`, y lo va tachando/
siguiendo mientras ejecuta cada paso en el navegador. No se encontraron pasos adicionales que falten en el
`.md`.

## Módulos vistos

1. **Backoffice RRHH → Pedidos** (`te_pedido.aspx`, `te_pedidowww.aspx`, `wp_pedidodetalle.aspx`) — alta/edición
   de Pedido y su(s) Detalle(s), operado por el rol "Operacion".
2. **Portal Freelance** (`wwpbaseobjects.home.aspx`, `wp_confirmacioneventosfl.aspx`) — operado por el
   empleado, para confirmar/cancelar su asistencia a un evento.

---

## 1. Pantalla "Pedidos" — Información General (alta de Pedido)

Capturas: `001_00m00s.png` a `017_00m38s.png`, `049_02m07s.png` (grid), `057_02m38s.png`–`061_03m01s.png` (edición).

Encabezado azul "Información General". Enlaces superiores: **"Agregar Detalle"** y **"Agregar Factura"**.

Campos (orden visual, los marcados `*` son obligatorios):
- **Cliente** `*` — combo. Valor de prueba: "OCESA Promotora, S. A. de C...".
- **Id Contacto** `*` — combo, se llena tras elegir Cliente. Valor: "Heriberto Reyes Vasquez".
- Checkbox **"Agregar contacto"** (a la derecha, nivel del campo Id Contacto).
- **Id sucursal** `*` — combo. **Catálogo visible completo**: `(Ninguno)`, `CDMX`, `Guadalajara`, `Monterrey`,
  `Otra`, `Queretaro`. (Nota: "Queretaro" sin acento en la UI real.)
- **Unidad de negocio** `*` — combo. Valor usado: "Seguridad".
- **Id PEP** (sin `*`, pero se llenó) — combo. Valor: "EL-AT-2016-11-11T214EL-A S...".
- **Id evento** `*` — combo. Valor: "Jacob Whitesides 2019".
- **Título** `*` — textbox, se autocompleta/edita a partir del evento: "Jacob Whitesides 2019---Escena...".
- **Lugar de cita** — combo, default "Sin definir". Valor usado: "Teatro Telcel".
- **Dirección lugar** — textarea. Valor: "Lago Zurich 245".
- **Otro** — checkbox (deshabilita/activa un campo libre de lugar, no explorado a fondo).
- **Tipo de movimiento** `*` — combo. Valor: "Pedido".
- **Sociedad pagadora** `*` — combo. Valor: "Operadora de Centros de Es...".
- **Permitir cancelar confirmaciones** `*` — combo. **Catálogo: `NO` / `SI`** (en ese orden, NO es el
  default). Éste es el campo a nivel **Pedido (cabecera)** que bloquea/permite cancelaciones para TODOS los
  detalles del pedido.
- **Responsable** `*` — combo. Valor: "Israel Benavid Solis Carrera".

Botones al pie: **Confirmar** (azul, primario) y **Regresar**.

Footer de toda la app: "RRHH - copyright 2018".

---

## 2. Pantalla "Pedidos" — listado/grid (`te_pedidowww.aspx`)

Captura: `073_03m39s.png`.

Toolbar: botón `+` (agregar), export `XLS`, export `PDF`, botón "Selecciona columnas", filtro con combo
"Buscar en" (ej. "Id pedido") + caja de valor + flechas de paginación `< >` + botón limpiar `×`.

Columnas de la grilla: **Id, Título, Estatus, Unid.Neg., Sucursal, lugar, Responsable, Complejidad, T.Mov,
PeP | Descripción**.

Valores de Estatus observados en la lista: `Vigente`, `Liberado` (confirma que existe un estado intermedio
antes de "Vigente" y que el Pedido de este escenario — fila "Jacob Whitesides 2019---Escenario 13", id
**1058** — se crea en estatus `Vigente`, no `Liberado`, a diferencia de otros escenarios de la misma lista que
sí aparecen `Liberado`).

Columna "T.Mov" (Tipo de movimiento) tiene valores `Pedido` y `Servicio interno` en la misma grilla — confirma
que `tipo_movimiento_id` tiene más de un valor de catálogo además de "Pedido".

---

## 3. Pantalla "Detalles de pedido" — alta de Detalle (`wp_pedidodetalle.aspx`)

Capturas: `025_01m16s.png`–`045_01m59s.png`, `101_05m25s.png`–`130_07m11s.png` (edición posterior).

Tab única visible: **"Detalles"** (hay una segunda tab "Reservaciones" que aparece sólo en modo edición, ver
`091_04m43s.png`: tabs **"Detalles" / "Reservaciones"**).

Campos columna izquierda:
- **Estatus** (solo lectura) — "Vigente".
- **Evento Práctica** — checkbox.
- **Tipo personal** `*` (solo lectura tras elegir) — "Operativo".
- **Título** `*` — textbox, hereda del Pedido.
- **Producto** (sin label `*` visible siempre, a veces solo-lectura) — combo. Valor: "Seguridad-IN".
- **Lugar de Cita** `*` — combo. "Teatro Telcel".
- **Dirección cita** — textarea. "Lago Zurich 245".
- **Otro** — checkbox.
- **Indicaciones especiales** — textarea (vacío en la prueba).
- **Bloque por producto** — combo. Default "Ninguno".
- **Facturable** — combo. Valor usado: "NO".

Campos columna derecha:
- **Cantidad** — numérico (1).
- **Turnos** — numérico (1.00), con nota fija a la derecha: **"8 Horas por turno"**.
- **Fecha cita** `*` — date picker + combo hora + combo minuto. El date picker es un calendario emergente en
  español: título del mes "Agosto, 2019", cabecera de días **Dom Lun Mar Mié Jue Vie Sáb**, con enlace
  "Hoy" y flechas `« <` / `> »` (mes/año).
- **Fecha liberación** `*` — igual estructura (date + hora + minuto).
- **Fecha final cita** `*` — igual estructura.
- **Presentación por producto** — combo. Valor de prueba: "Pantalón Negro de Vestir, Playera Azul y Chamarra
  Azul" (uniforme/dress code).
- **Completar con similares** — combo. Valor: "NO".
- **Fase del evento** — combo. Valor: "No aplica".
- **Permitir cancelar** `*` — combo. **Catálogo: `NO` / `SI`**. Éste es el flag a nivel **Detalle**,
  INDEPENDIENTE del flag a nivel Pedido ("Permitir cancelar confirmaciones"). Es exactamente el campo que
  el escenario manipula paso a paso ("Marcar el detalle de pedido como que sí se puede cancelar" /
  "Editar el detalle para que no permita cancelar" / etc.).

Botones: **Agregar Detalle** (alta) / **Modificar detalle** (edición) + **Cancelar** — y en el bloque
"Movimientos detalles pedido" hay además un botón **"Cancelar detalle"** separado (ver `090_04m42s.png`),
distinto del botón genérico "Cancelar" del formulario — es decir, "Cancelar" descarta la edición sin guardar,
mientras "Cancelar detalle" es una acción de negocio (cancela el renglón completo del pedido).

Al editar un detalle ya creado (`101_05m25s.png`) aparece encabezado de sección **"MODIFICACION DETALLE DE
PEDIDO :"**.

Fecha de ejemplo usada: cita **23/08/2019 06:00 a 14:00**, fecha de liberación **16/08/2019 06:00** → brecha
exacta de **7 días (168 h)**, consistente con el paso "fecha de cita más de 72 horas a partir de la hora
actual" (muy por encima del umbral, no al límite).

---

## 4. Pantalla "Detalles de pedido" — vista resumen tras guardar (`wp_pedidodetalle.aspx?1058`)

Captura: `081_04m12s.png`, `109_06m00s.png`.

Enlaces/acciones en la barra superior: **"Editar pedido"** · **"Liberar Pedido"** · **"Cancelar Pedido"** —
y botón **"Regresar"** a la derecha. Confirma que a nivel Pedido existen 3 acciones de ciclo de vida
distintas: editar, liberar (publicar) y cancelar (el pedido completo, no solo un detalle).

Título de sección: **"PEDIDO No.: 1058"**.

Bloque **"Matriz de Puestos"**: tabla con columnas "Bloque | Productos | <fecha> <hora>", renglón de ejemplo
`Seguridad-IN | Jacob Whitesides 2019---Escenario 13 | 1 - T 1.00`, más totales: **"Total Solicitados: 1 / 1"**
y **"Presupuesto por día: $ 300.00"**.

Bloque inferior **"Movimientos detalles pedido"** con tab "Detalles" (grid de los detalles del pedido).

---

## 5. Portal Freelance — Home (`wwpbaseobjects.home.aspx`)

Captura: `053_02m16s.png`.

Barra de navegación superior (marca "RRHH", fondo azul): **Inicio** · **Comunicados generales** ·
**Calendario de eventos** · **Saldos** · **Confirmación de eventos** · **Aclaraciones** · **Salir**. Menú de
usuario arriba a la derecha: **"Freelance"** (rol).

---

## 6. Portal Freelance — Confirmación de eventos (`wp_confirmacioneventosfl.aspx`)

Capturas: `057_02m38s.png`, `069–129` (secuencia completa de confirmar → cancelar).

Dos paneles lado a lado:

- **"Eventos por confirmar"** (izquierda): lista de renglones con formato
  `PUESTO--NombreEvento FechaCorta Hora (IdNumerico)`, ej.
  `SEGURIDAD--Jacob Whitesides 2019 20/08/19 06:00 (2408)`. Nótese el separador **doble guion `--`** entre
  puesto y evento.
- **"Eventos confirmados"** (derecha): lista con formato `PUESTO.NombreEvento FechaCorta Hora` — **aquí el
  separador es un solo punto `.`**, SIN el id numérico entre paréntesis. (Posible inconsistencia/resto de
  legado en el formateo del título entre los dos estados; útil para no asumir que el mismo template genera
  ambas listas.)

### 6a. Detalle al seleccionar un evento "por confirmar" (frame `130_07m11s.png`)

Campos mostrados: **Evento, Puesto, Fecha, Turnos, Lugar, Dirección, Uniforme, Indicaciones Especiales**.
Botón: **"Confirmar"**.

### 6b. Detalle al seleccionar un evento ya "confirmado" (frames `061`–`125`)

Campos mostrados: **Evento, Descripción, Fecha, Turnos, Lugar, Dirección, Presentación producto, Indicaciones
Especiales**. Botón: **"Cancelar"**.

**Hallazgo de UI (inconsistencia de etiquetas):** el mismo dato de "puesto/producto" se rotula **"Puesto"**
en la vista "por confirmar" pero **"Descripción"** en la vista "confirmado"; y el mismo dato de "uniforme" se
rotula **"Uniforme"** en un panel y **"Presentación producto"** en el otro. Son dos templates distintos para
lo que conceptualmente es el mismo objeto (reservación/detalle). Para PeopleMovil conviene unificar a una
sola etiqueta consistente en ambos estados.

### 6c. Resultado de "Cancelar" cuando SÍ está permitido (frames `121_06m48s.png` → `125_07m00s.png` → `129/130`)

Antes: "Eventos confirmados" tenía 2 renglones (22/08/19 08:00 y 23/08/19 06:00). Se selecciona el de
23/08/19 06:00, aparece el botón **Cancelar**, se hace clic. Resultado inmediato: la lista "Eventos
confirmados" baja a 1 renglón (solo queda 22/08/19 08:00) y el evento cancelado **reaparece en "Eventos por
confirmar"** con un **ID NUEVO** `(2412)`, distinto de los IDs ya existentes (2408, 2407). Esto confirma que
cancelar una confirmación NO reutiliza el registro de reservación original: se genera un nuevo renglón/estado
"por confirmar". Útil para el diseño de `te_reservaciones` / `reservacion_bitacora` en PeopleMovil (soporta
el patrón append-only que ya se documentó en D9/D10 de `CLAUDE.md`, aunque ahí se aplicó solo a
`eventos_biometricos`).

### 6d. Resultado de "Cancelar" cuando NO está permitido — SIN mensaje de error visible

Capturas relevantes: `085`–`088` (clic en "Cancelar" sobre el evento 23/08/19 06:00 **antes** de que el
detalle se editara para permitir cancelar).

**Hallazgo importante:** en ningún frame capturado aparece un cuadro de alerta, mensaje de validación en
rojo, ni un `alert()` del navegador al intentar cancelar una confirmación bloqueada. La secuencia observada
es: clic en "Cancelar" → breve "Esperando a integramx-001-site2.btempurl.com..." en la barra de estado del
navegador (`086_04m26s.png`) → la página se recarga → el evento **sigue apareciendo igual en "Eventos
confirmados"**, sin ningún texto de error visible en el frame siguiente (`088_04m30s.png`). Es decir, el
sistema legado **bloquea la acción de forma silenciosa** (probablemente un postback que no hace nada o un
`alert()` de JS que el frame-grab no alcanzó a capturar, ya que son eventos modales efímeros). El texto del
escenario dice "El sistema no debe permitir realizar la cancelación" pero **no hay evidencia visual de que el
usuario reciba una explicación del porqué**. Para PeopleMovil se recomienda mostrar un mensaje explícito
(ej. "No es posible cancelar: la cita es en menos de 72 horas" o "Este pedido no permite cancelaciones"),
mejorando la UX legado en vez de replicarla.

---

## 7. Edición del flag a nivel Pedido ("Permitir cancelar confirmaciones")

Captura: `077_03m57s.png`.

Pantalla `te_pedido.aspx?UPD,1058` (editar Pedido). El combo **"Permitir cancelar confirmaciones"** desplegado
muestra exactamente dos opciones, en este orden: **`NO`** (resaltado/seleccionado) y **`SI`**. Confirma
catálogo binario simple, sin opción "(Ninguno)".

Al pie del formulario de edición aparecen **3 botones**: **Confirmar**, **Regresar**, **Cancelar pedido**
(este último solo visible en modo edición, no en alta — ver `077_03m57s.png` vs `001_00m00s.png`).

---

## 8. Datos de prueba / catálogo de empleados (hoja Excel auxiliar)

Captura: `045_01m59s.png` — archivo **"DatosFReelanceParaEscenarios_01.xlsx"**, hoja **"Control de accesos"**.
Columnas: `Certeza (filtro 0 a 1) | Estatus = Activo | Puesto = Control de Accesos` como encabezado de
filtro, y tabla de datos: **Empleado | Nombre completo | Sexo | Certeza | Estatus | Id Puesto | Puesto |
Vigente | Principal**. Esto es el padrón de empleados de prueba usado para elegir con qué "otro empleado de
seguridad" se confirma/cancela en cada paso del escenario (no es específico de Escenario 13, es un insumo
compartido entre escenarios).

---

## Resumen — reglas de negocio nuevas o que precisan detalle (no estaban explícitas en el `.md` ni se
confirmó visualmente antes en el schema)

1. **Confirmado — existen DOS flags de cancelación independientes**, no uno solo:
   - Nivel Pedido: combo **"Permitir cancelar confirmaciones"** (NO/SI) → ya existe en el schema como
     `te_pedidos.permitir_cancelaciones` (línea 2219 de `reset_database.sql`). ✅ coincide.
   - Nivel Detalle: combo **"Permitir cancelar"** (NO/SI) → ya existe como
     `te_pedidos_detalle.permitir_cancelar_confirmaciones` (línea 2280). ✅ coincide.
   - Ambos deben evaluarse en AND (si cualquiera de los dos está en "NO", la cancelación debe bloquearse) —
     el escenario de prueba efectivamente los manipula por separado y exige que ambos permitan antes de
     que la cancelación funcione.

2. **Nueva (posible gap):** al cancelar una confirmación, el sistema legado genera un **nuevo registro/ID**
   para el evento que vuelve a "por confirmar" en vez de revertir el estado del registro existente. Si
   PeopleMovil quiere trazabilidad completa de "quién confirmó, quién canceló, cuándo", esto sugiere que
   `te_reservaciones` debería tratarse como append-only (como ya se hizo con `eventos_biometricos`), o al
   menos loguear cada transición en `reservacion_bitacora` con el motivo y quién la hizo — la tabla
   `reservacion_bitacora` ya existe en el schema (referenciada en línea 1108/1209), así que solo hay que
   confirmar que capture este caso.

3. **UX gap a decidir conscientemente:** el legado NO muestra mensaje de error explícito cuando bloquea una
   cancelación — simplemente no hace nada. PeopleMovil debería decidir explícitamente si replica ese
   comportamiento silencioso o (recomendado) agrega un mensaje de error claro indicando la razón específica
   del bloqueo (pedido no cancelable / detalle no cancelable / faltan menos de 72h para la cita).

4. **Etiquetas inconsistentes entre vistas** del portal freelance para el mismo dato: "Puesto" vs
   "Descripción", y "Uniforme" vs "Presentación producto", según si el evento está pendiente de confirmar o
   ya confirmado. Dato de diseño UI, no de modelo de datos — documentarlo para no replicar la inconsistencia
   sin querer.

5. **Catálogo confirmado de "Id sucursal"**: `(Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro` — útil
   si `cat_sitios`/sucursales necesita semilla de datos de referencia con esos nombres exactos (ver D2 en
   `CLAUDE.md`, sitios unificados con `tipo_sitio`).

6. Separador visual **"8 Horas por turno"** junto al campo Turnos del Detalle — confirma que 1 turno = 8
   horas fijas en este negocio (dato ya usado en cálculos del schema, aquí solo se confirma la etiqueta
   exacta en UI).
