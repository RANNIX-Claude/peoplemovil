# Escenario 14 — Pedido de matriciales para validar los sueldos (walkthrough de capturas)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\23 - P20190319_0000 Escenario 14 Pedido de matriciales para validar los sueldos\`
(61 PNGs, video de 189s, ver `info.json`). Sistema real "Lobo" en `integramx-001-site2.btempurl.com/qafreelance/` (QA, screenshots del 18/03/2019).

Este documento complementa la fila "Escenario 14" de `ESCENARIOS_PRUEBA_FREELANCE.md` (líneas 427-437) con el detalle pantalla-por-pantalla: nombres exactos de campo, opciones de catálogo, y el resultado numérico observado.

---

## 1. Listado de Pedidos (001_00m00s.png)

Pantalla "Pedidos" (menú superior: Inicio | Recursos humanos | Operaciones | Nómina | Catálogos | Seguridad sistema | Variables | Salir).

Grid con columnas: **Id Pedido, Título, Estatus, Unidad de negocio, Sucursal, lugar, Responsable**. Toolbar: botón "+" (nuevo), exportar XLS, exportar PDF, "Selecciona columnas", filtro "Buscar en [Id Pedido ▾] valor [...]".
Valores de Estatus vistos en el grid: `Vigente`, `Liberado`, `Cancelado`.

## 2. Alta de pedido — Información General (004_00m10s.png → 023_00m58s.png)

Formulario "Información General" con los siguientes campos, en este orden:

| Campo | Tipo de control | Notas |
|---|---|---|
| Cliente * | combo con autocompletado/búsqueda | lista larga de razones sociales (ej. "LiveMed, S. de R.L. de C.V.", "Mint Creative Lab S.A. de C.V.", "OCESA Promotora, S. A. de C.V.", etc.) |
| Contacto | combo | depende del cliente ("Villa Vera Mario") |
| Sucursal * | combo | `(Ninguno)`, `CDMX`, `Guadalajara`, `Monterrey`, `Otra`, `Queretaro` |
| Unidad de negocio * | combo | ej. "Plaza Condesa", "Producción"... (se llena tras elegir cliente/sucursal) |
| PEP * | combo con texto compuesto `CLAVE || Nombre` | ej. `EC-ZO-2018-06-17T165EC-P | Pepe Aguilar Zocalo`; lista incluye muchas claves con prefijos `AA`, `AR-AR`, `CH-SC`, `CL-OI`, `DC-EO`, `DC-FA`, `DC-HR`, `DC-OI`, `DC-PF`, `EC-OI`, `EC-ZO` |
| Evento * | combo | ej. "Entrega 03" (ligado al PEP elegido) |
| Título | textbox libre | se escribió manualmente "Entrega 03 Escenario 14" |
| Lugar de cita * | combo | ej. "Academia Maddox Satélite", "Zócalo" — autocompleta "Dirección lugar de cita" (solo lectura) |
| Dirección lugar de cita | read-only, autollenado | "Plaza de la Constitución, Colonia Centro" |
| Otro | checkbox | sin marcar |
| Tipo de movimiento: | combo | valor usado: `Pedido` (único visible en esta corrida; no se abrió el desplegable completo aquí) |
| Tipo de complejidad | combo | ver catálogo completo abajo |
| Duración del evento(Días de show) | **input numérico libre** (no catálogo) | se tecleó `2` |
| Sociedad pagadora | combo | "Car Sport Racing SA de CV" (prellenado por default, consistente con el bug reportado en Escenario 1/3 de "sociedad pagadora por default con ID 10") |
| Permitir cancelar confirmaciones | combo Sí/No | `NO` |
| Responsable * | combo | "Jose Edgar Barrera Diaz" |

Botones al pie: **Guardar**, **Regresar**.

### Catálogo completo "Tipo de complejidad" (imagen 024_01m00s.png y 023_00m58s.png)

Desplegado completo, 7 opciones:
1. `Teatro Metropolitan, Plaza Condesa y Plazas Similares_` (nótese el guión bajo colgante al final del texto — defecto de datos en el catálogo legado)
2. `Auditorio Nacional, Auditorio Guadalajara y Plazas Similares`
3. `Palacio de los Deportes, Arena VFG y Plazas Similares`
4. `Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares` ← seleccionada para este escenario
5. `Estadios Foro y Plazas Similares en el Extranjero`
6. `Festivales de mas de 50,000 asistentes`
7. `No Aplica`

**Contradice** la observación de bug en Escenario 2 ("únicamente muestra 3 opciones del foro sol, y dos son iguales"): en esta corrida (Escenario 14) el combo muestra correctamente las 6 complejidades + "No Aplica", sin duplicados. Puede ser que el bug ya estuviera corregido para cuando se grabó este video, o que dependa de la Unidad de Negocio elegida.

Tras seleccionar "Foro Sol..." y teclear Duración = 2, aparece el toast naranja **"Esperando a integramx-001-site2.btempurl.com..."** (loading normal del postback), y el formulario conserva los valores (028_01m11s.png).

Campo "PEP" — al abrir el combo se ve catálogo largo de claves de evento tipo `XX-YY-2018-...`. No se investigó exhaustivamente dado que no es el foco del escenario.

## 3. Alta del Pedido — confirmación (029-031)

Tras **Guardar**, el sistema regresa al listado de Pedidos con el nuevo registro arriba: **Id Pedido 776**, Título "Entrega 03 Escenario 14", Estatus `Vigente`, Unidad de negocio `Produccion`, Sucursal `CDMX`, lugar `Zócalo`, Responsable "Jose Edgar Barrera Diaz" (029_01m13s.png, 030_01m14s.png).

## 4. Pantalla "Detalles de pedido" (031_01m16s.png en adelante)

Encabezado: **"PEDIDO No.: 776"**, con barra de acciones: **Editar pedido | Liberar Pedido | Cancelar Pedido | Regresar**.

Debajo, sección **"Matriz de Puestos"** (inicialmente vacía). Al entrar sin detalles capturados, el sistema muestra un **toast de advertencia naranja**: 

> **"No existe información para formar Matriz."**

(mensaje exacto, visto en 033_01m25s.png)

### Formulario "Movimientos detalles pedido" → pestaña "Detalles"

Campos, columna izquierda:

| Campo | Tipo | Valor usado |
|---|---|---|
| Estatus | read-only | `Vigente` |
| Evento Práctica | checkbox | sin marcar |
| Tipo personal * | combo | `Staff` (también existe `Operativo`, visto en otros escenarios) |
| Título * | textbox | "Entrega 03 Escenario 14" (heredado) |
| Producto | combo | `Asistente Operador-IN` |
| Lugar de Cita | combo | "Zócalo" |
| Dirección cita | read-only | "Plaza de la Constitución, Colonia Centro" |
| Otro | checkbox | — |
| Indicaciones especiales | textarea | vacío |
| Bloque por producto | combo numérico | `1` (valores vistos: `Ninguno`, `1`) |
| Facturable | combo Sí/No | `NO` |

Botón adicional: **Cancelar detalle**.

Columna derecha:

| Campo | Tipo | Valor usado |
|---|---|---|
| Cantidad | numérico | `1` |
| Turnos | numérico | `1.00` |
| *(texto informativo junto a Turnos)* | — | **"12 Horas por turno"** — se muestra automáticamente al elegir el producto. **Contradice** el bug reportado en Escenario 1/2 ("no muestra la información de horas por turno"): aquí sí aparece. |
| Fecha cita * | date-time picker (calendario + hora + minuto) | `10/04/2019 08:00` |
| Fecha liberación | date-time picker | vacío en este detalle |
| Fecha final cita | date-time picker, **autocalculada** | `10/04/19 20:00` (= fecha cita + 12 horas del turno) |
| Presentación por producto | combo | `(Ninguno)` |
| Completar con similares | combo Sí/No | `NO` |
| Fase del evento | **read-only, deshabilitado** | `No aplica` (consistente con Escenarios 2/3: al usar complejidad a nivel de pedido con personal Staff, Fase del evento queda fijo en "No aplica") |
| Permitir cancelar | combo Sí/No | `NO` |

Botones: **Agregar Detalle**, **Cancelar**.

### Catálogo completo "Producto" visto con Tipo personal = Staff (036_01m37s.png, 035_01m36s.png)

`Ninguno`, `Diseño de Iluminación A-IN`, `Diseño de Iluminación B-IN`, `Diseño de Iluminación C-IN`, `Productor A-IN`, `Productor B-IN`, `Productor C-IN`, `Stage Manager A-IN`, `Stage Manager B-IN`, `Asistente Operador-IN` ← elegido, `Asistente Coordinador-IN`, `Logistica Coordinador-IN`, `Logistica Operador-IN`, `Logistica Aux-IN`, `Asistente Aux B-IN`, `Asistente Aux A-IN`.

**Contradice** el bug de Escenario 2 ("El producto asistente operador PRG-IN no aparece si tomamos el tipo de personal staff, pero si tomamos el tipo de personal operativo sí aparece"): aquí, con Tipo personal = Staff, "Asistente Operador-IN" sí aparece en el catálogo y se puede seleccionar sin problema.

### Selector de fecha (037-043)

Date-picker en español: mes/año con flechas `«` `‹` `›` `»`, botón "Hoy", días en columnas `Dom Lun Mar Mié Jue Vie Sáb`. Selectores de hora y minuto (dropdowns `00`-`23` / `00`-`59`) separados a la derecha del campo de fecha. Al fijar hora = `08`, el campo "Fecha final cita" se autocompleta a las `20:00` del mismo día (08:00 + 12h de turno).

## 5. Alta del Detalle y Matriz de Puestos (045_02m07s.png, 046_02m09s.png)

Tras pulsar **Agregar Detalle**, toast naranja de éxito:

> **"Registro Agregado Correctamente"**

Debajo del encabezado del pedido aparecen dos cajas read-only **antes** de la sección "Movimientos detalles pedido":

- **Total Solicitados**: `1`
- **Presupuesto por día**: `24525`

Y la sección **"Matriz de Puestos"** se puebla con una tabla cuadrícula (pivote fecha × bloque):

| Bloque | Productos | 10/04 08:00 |
|---|---|---|
| 1 | Asistente Operador-In | `1 - T1` (celda en rojo) |
| | **Total Solicitados** | `1` |
| | **Presupuesto por día** | `24525` |

Importante: el importe de **$24,525** ya se calcula y se muestra en la cuadrícula **inmediatamente al agregar el detalle**, antes de liberar el pedido y antes de que el freelancer confirme el evento. Esto confirma que el cálculo de sueldo matricial (puesto + complejidad + duración) es una consulta síncrona al tabulador al momento de capturar el detalle, no un cálculo diferido a nómina.

## 6. Liberar pedido y confirmación en portal freelance (047_02m14s.png → 059_02m53s.png)

El pedido se libera (acción "Liberar Pedido" del encabezado, botón visto en el paso 4; la captura exacta del clic no quedó en el muestreo pero el resultado sí). El flujo continúa en el **portal del empleado freelance**, app distinta: pantalla de login "Acceso" con fondo de escenario/luces, logo **"RRHH"**, campos **Usuario** / **Contraseña**, link **"¿Olvidaste tu contraseña?"**, checkboxes **"Mantenerme Conectado"** y **"Recordar"**, botón **Ingresar**. Usuario usado: `rrodrigo`.

Tras ingresar, menú del portal: **Inicio | Calendario de eventos | Saldos | Confirmación de eventos | Aclaraciones | Salir**.

### Pantalla "Confirmación de eventos"

Dos columnas: **"Eventos por confirmar"** / **"Eventos confirmados"**.

En "Eventos por confirmar" aparecen tarjetas con formato `PUESTO--Título Fecha Hora (IdEventoDetalle)`:
- `ASISTENTE OPERADOR--Futbol América vs Pumas 29/03/19 10:00 (2023)` (de otro escenario, visible en la cola)
- `ASISTENTE OPERADOR--Entrega 03 10/04/19 08:00 (2102) BLOQUE` ← nuestro escenario

Al pulsar sobre la tarjeta se expande el detalle:

| Campo | Valor |
|---|---|
| Evento | Entrega 03 |
| Puesto | Asistente Operador |
| Fecha | 10/04/19 08:00 a 10/04/19 08:00 |
| Turnos | 1.00 |
| Lugar | Zócalo |
| Dirección | Plaza de la Constitución, Colonia Centro |
| Uniforme | (vacío) |
| Indicaciones Especiales | (vacío) |

Botón **Confirmar**. Al pulsarlo aparece un **modal de confirmación**:

> Título: **"Confirmación al Evento"**
> Cuerpo: `ENTREGA 03--10/04/19 08:00 (BLOQUE)`
> Botones: **Sí** / **No**

Al aceptar (`Sí`), el evento pasa a la columna "Eventos confirmados" con tarjeta `ASISTENTE OPERADOR..Entrega 03 10/04/19 08:00` y detalle expandido:

| Campo | Valor |
|---|---|
| Evento | Entrega 03 |
| Descripción | Asistente Operador |
| Fecha | 10/04/19 08:00 a 10/04/19 20:00 |
| Turnos | 1.00 |
| Lugar | Zócalo |
| Dirección | Plaza de la Constitución, Colonia Centro |
| Presentación producto | (vacío) |
| Indicaciones Especiales | (vacío) |

Pie de tarjeta: `10/04/19 08:00   10/04/19 20:00   Reservación 134   CONFIRMADO`. El identificador de reservación es **134**.

## 7. Portal — "Saldos" → "Ver eventos por procesar" (056-061)

Pantalla **"Consulta de pagos freelance"** (bajo el menú "Saldos"), sección **"Concentrado de Honorarios"**:

- Campo **Periodo** (combo), valor `1071`
- Campos read-only en cero (antes de procesar): Número de cuenta, Pago bruto, SD proporcional, Cuota fija, Crédito general, Impuesto total a retener, Banco, Días laborados, Impuesto marginal, Subsidio acreditable, Impuesto diario, Pago neto
- Link **"Ver eventos por procesar"**
- Sección inferior **"Detalle de movimientos por pagar"** con columnas: **Tipo, Referencia, Descripción, Puesto, Importe** (paginador Ant/Sig)

Al pulsar "Ver eventos por procesar" se abre un **modal "Eventos por procesar"** con tabla:

| Detalle | Título | Cita | Pago | Tipo |
|---|---|---|---|---|
| 2102 | Entrega 03 Escenario 14 | 10/04/19 08:00 | **$ 24,525.00** | Reservación |

Pie: **TOTAL: $ 24,525.00**

Esto **confirma exactamente** el resultado esperado documentado en `ESCENARIOS_PRUEBA_FREELANCE.md` línea 437: *"Validar que el importe para el pedido creado en este ecenario sea $24,525"* — el importe coincide al centavo con lo que ya se había calculado y mostrado en la Matriz de Puestos del paso 5, antes incluso de liberar/confirmar. El id de detalle de pedido es **2102**, el Id de Reservación es **134**.

---

## 8. Botones/acciones observadas (resumen)

- Pedidos (listado): `+` (nuevo), exportar XLS, exportar PDF, "Selecciona columnas"
- Alta pedido: **Guardar**, **Regresar**
- Detalle pedido (encabezado): **Editar pedido**, **Liberar Pedido**, **Cancelar Pedido**, **Regresar**
- Captura de detalle: **Agregar Detalle**, **Cancelar**, **Cancelar detalle**
- Portal freelance: **Ingresar** (login), **Confirmar** (evento), modal **Sí/No** (confirmación)

## 9. Mensajes exactos observados

- Toast de advertencia (naranja): **"No existe información para formar Matriz."** — se muestra al entrar al detalle del pedido sin haber capturado aún ningún renglón.
- Toast de éxito (naranja): **"Registro Agregado Correctamente"** — al agregar un detalle de pedido.
- Modal de confirmación en portal: título **"Confirmación al Evento"**, cuerpo `"<TÍTULO>--<FECHA> (BLOQUE)"`, botones **Sí** / **No**.
- Barra de progreso del navegador: "Esperando a integramx-001-site2.btempurl.com..." (no es mensaje de aplicación, es UI de Chrome).

---

## 10. Comparación contra el esquema `tp_sueldos_matriciales` (reset_database.sql)

Definición actual (líneas 2958-2972 de `db/reset_database.sql`):

```sql
CREATE TABLE IF NOT EXISTS tp_sueldos_matriciales (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES te_tenants(id) ON DELETE CASCADE,
  puesto_id             uuid NOT NULL REFERENCES tc_puestos(id),
  tipo_complejidad_id   uuid REFERENCES tc_tipos_complejidad(id),
  tipo_duracion_id      uuid REFERENCES tc_tipos_duracion_evento(id),
  turnos                numeric(5,2) NOT NULL DEFAULT 1,
  sueldo_base           numeric(12,2) NOT NULL,
  factor                numeric(5,3) NOT NULL DEFAULT 1.0,
  vigente_desde         date NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta         date,
  activo                boolean NOT NULL DEFAULT true,
  ...
);
```

**Dimensiones vistas en pantalla para este escenario** (Pedido → Puesto "Asistente Operador-IN", Tipo personal Staff, Complejidad "Foro Sol...", Duración 2 días, Turnos 1, Cantidad 1 → resultado $24,525):

| Dimensión en pantalla | Columna en `tp_sueldos_matriciales` | ¿Cubierta? |
|---|---|---|
| Puesto (producto "Asistente Operador-IN") | `puesto_id` | Sí |
| Tipo de complejidad (a nivel pedido) | `tipo_complejidad_id` | Sí |
| Duración del evento en días de show (a nivel pedido, entero libre = 2) | `tipo_duracion_id` (vía catálogo `tc_tipos_duracion_evento` + rangos en `tp_duraciones_evento`) | Sí, indirectamente — el número crudo de días capturado en pantalla (`te_pedidos.duracion_dias`, ya existe) se debe resolver a un rango/tipo de duración para hacer el join; **no se ve en pantalla un selector de "tipo de duración"**, es puramente numérico, así que la resolución día→tipo_duracion debe hacerse en backend. |
| Turnos del detalle (1.00) | `turnos` | Sí |
| Importe final ($24,525) | resultado de `sueldo_base * factor` (u otro cálculo con `tp_duraciones_evento.factor_sueldo`) | Sí, aunque el `factor` nunca se expone en la UI — es cálculo interno, consistente con el diseño actual. |

**Gaps / puntos a verificar, no visibles en este escenario pero relevantes por referencia cruzada con otros escenarios del mismo documento:**

1. **Falta dimensión "Fase del evento" en `tp_sueldos_matriciales`.** En este Escenario 14, "Fase del evento" aparece fijo en `No aplica` (deshabilitado) porque el puesto se cotiza por complejidad+duración. Pero el Escenario 26 ("Pedidos de runners para validar los sueldos", mismo archivo fuente, línea 661-693) describe un puesto **"Runner"** cuyo sueldo depende de **"Fase de Evento: Fase 4 Runner (Dia 4)"** junto con la complejidad del pedido ("Teatro Metropólitan", 1 día de show) — es decir, para ciertos puestos la fase del evento SÍ es un eje más de la tarifa matricial, no es mutuamente excluyente con complejidad. La tabla actual no tiene `fase_evento_id`. Recomendación: agregar columna opcional `fase_evento_id uuid REFERENCES tc_fases_evento(id)` a `tp_sueldos_matriciales` para soportar puestos tipo Runner.
2. **Duración capturada como número libre, no como catálogo.** La pantalla de Escenario 14 confirma que "Duración del evento(Días de show)" es un `<input numérico>` simple en el encabezado del pedido (ya mapeado a `te_pedidos.duracion_dias int`, línea 2217). El join hacia `tc_tipos_duracion_evento`/`tp_duraciones_evento` para resolver el `tipo_duracion_id` de la matriz debe hacerse por rango (`dias_desde`/`dias_hasta`), lo cual ya está modelado en `tp_duraciones_evento` — sin cambios necesarios, solo confirma que la lógica de resolución debe vivir en la función de cálculo de sueldo, no en la captura de UI.
3. **Posible redundancia entre `tp_sueldos_matriciales.factor` y `tp_duraciones_evento.factor_sueldo`.** Ambas tablas tienen un multiplicador de tipo `factor`. Conviene documentar/clarificar cuál aplica en qué punto del cálculo (p. ej. `factor` en sueldos_matriciales podría ser un ajuste fijo del renglón del tabulador, mientras `factor_sueldo` en duraciones_evento es el prorrateo por día de show 100%-50%-50% visto en Escenario 29). No se detectó en las pantallas de Escenario 14 evidencia de un prorrateo (el pedido solo tiene 1 detalle, cantidad 1, y se pagó el 100% de $24,525), así que no se puede confirmar desde este escenario cuál factor se aplicó — recomendable cruzar con capturas del Escenario 29 (Prorrateo) si existen.
4. **Catálogo "Tipo de complejidad" con dato sucio**: la opción 1 trae un guión bajo colgante (`"...Plazas Similares_"`) — si se migran catálogos literalmente del sistema legado, limpiar este typo en el seed de `tc_tipos_complejidad`.
5. **No se observó en este escenario** ningún campo de sueldo/tabulador editable por el usuario de operación (ej. una pantalla de catálogo "Sueldos matriciales" con grid puesto×complejidad×duración→sueldo) — el escenario solo prueba el *consumo* del tabulador, no su *administración*. Sería valioso buscar en otras carpetas de capturas una pantalla de catálogo/admin de `tp_sueldos_matriciales` si existe, para validar columnas editables (p. ej. vigencias).

## 11. Conclusión

El Escenario 14 queda **confirmado end-to-end**: Pedido de Producción con complejidad "Foro Sol..." y duración 2 días de show, un único detalle (Puesto "Asistente Operador-IN", Staff, Cantidad 1, Turnos 1, 10/04/2019 08:00-20:00), liberado y confirmado por un freelance en el portal, genera una Reservación (id 134) y un detalle de pedido (id 2102) con importe exacto de **$24,525.00**, visible tanto en la Matriz de Puestos del back-office (inmediatamente al capturar el detalle) como en "Saldos → Ver eventos por procesar" del portal del freelance tras la confirmación. No se encontraron discrepancias entre el resultado numérico esperado por el script de QA y lo mostrado en pantalla.
