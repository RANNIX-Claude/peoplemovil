# Escenario 3 — Walkthrough de pantallas (frame-by-frame)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\14 - Escenario3\`
(154 PNGs, video original: https://www.youtube.com/watch?v=GwPBnguF_C0, duración 413s, canal "WJaJa VideoClips").

Muestra revisada: 40 capturas distribuidas uniformemente a lo largo de toda la secuencia (001, 005, 009, 013, 017, 021, 025, 029, 033, 037, 041, 045, 049, 053, 057, 061, 065, 069, 073, 077, 081, 085, 089, 093, 097, 101, 105, 109, 113, 117, 121, 125, 129, 133, 137, 141, 145, 149, 153, 154), más revisión dirigida de algunas vecinas cuando un dropdown aparecía a medio abrir.

El video intercala dos fuentes: (a) la aplicación web real "Pedidos" (RRHH / integramx-001-site2.btempurl.com/qafreelancev2) y (b) el archivo Excel `Scripts de Prueba Freelance.xlsx`, hoja "Escenario 3", que el probador tiene abierto en paralelo y va resaltando en amarillo paso a paso. Las capturas del Excel confirman que el texto ya volcado en `ESCENARIOS_PRUEBA_FREELANCE.md` (sección "Hoja: Escenario 3") es literal y completo — no se encontraron pasos adicionales fuera de los ya transcritos.

## 1. Encabezado del pedido ("Información General") — pantalla `te_pedido.aspx`

Capturas: 001, 005, 009, 013, 017.

Campos del formulario, en orden, con su control:
- **Cliente** * — combo con buscador tipo autocomplete (al escribir/abrir muestra lista larga de razones sociales, ej. "MC Show Business, S.A. de C.V.", "Ocesa Anfiteatro...", "OCESA Promotora, S.A. de C.V." — este último fue el seleccionado).
- **Id Contacto** * — combo dependiente del cliente (quedó "Mario Villa Vera").
- **Id sucursal** * — combo (quedó "CDMX").
- **Unidad de negocio** * — combo con lista larga (ej. "A Muse", "Actividades Deportivas", "Admón y Finanzas", "Aldea Digital", "Anfitriones", "Asdeporte", "Atención a Clientes", "Calacas Zíngaro", "Cavalia", "Cirque Du Soleil", "Comercial", "Control de Accesos", "Corona Capital", "E-Ticket", "Enlace", "Estacionamientos", "Estadio 3 de Marzo Gdl", "Estadio Azul"... lista alfabética muy larga; "PRG" fue la seleccionada).
- **Id PEP** — combo dependiente de la UN, con opciones del tipo "IT-PD-2015-08-27N085LT-A Test Day FIBA", "IT-PD-2018-12-19B085DA-E pepPrg_1", "Z-PEP-Temporal PRG", "zzzzz2 zzzz1" (se eligió el segundo, PEP real asociado a un inmueble).
- **Id evento** * — combo (quedó "Jacob Whitesides 2019").
- **Título** * — textbox, se autorellena a partir del evento ("Jacob Whitesides 2019---Escenario3...") y es editable.
- **Lugar de cita** — combo (quedó "Palacio de los Deportes").
- **lugar / Dirección lugar** — textarea de solo lectura/autorrelleno con la dirección completa ("Av Viaducto Rio de la Piedad y Rio Churubusco S/N, Granjas México, 08400 Ciudad de México, CDMX").
- **Otro** — checkbox (sin marcar).
- **Tipo de movimiento** * — combo; solo se vio "Servicio interno" seleccionado en este escenario (coincide con el Excel: "Únicamente muestra 'pedido'" era la observación de Escenario 1/2, aquí seleccionan explícitamente Servicio Interno).
- **Tipo de complejidad** — combo con catálogo largo de "complejidades" con nombre de recintos, ej. "Auditorio Nacional, Auditori..." (valor que aparece por defecto/primero en la lista al abrir el combo) y también existe la opción **"No Aplica"**, que es la que finalmente se deja seleccionada (confirma el paso 9 del Excel: "En complejidad indicar que No Aplica").
- **Duración del evento (Días de show)** — textbox numérico, default `0`. Es **campo requerido condicionalmente**: al pulsar Aceptar/Confirmar sin llenarlo aparece el error (ver sección 3).
- **Sociedad pagadora** — combo; se autocompleta en cuanto se elige la Unidad de Negocio (quedó "Operadora de Centros de Es[pectáculos]..."). Esto confirma la observación de Escenario 3 fila 5 del Excel: "La sociedad pagadora por default está con ID 10".
- **Permitir cancelar confirmaciones** * — combo Sí/NO (quedó "NO").
- **Responsable** * — combo de personas (lista de nombres: Angélica Jazmín López Pérez, Antonio de Jesús Mecalco Olmos, Cesar Ramírez Mejía, Gerardo Martínez Morales, Israel Benavid Solís Carrera, Jose Edgar Barrera Diaz, Juan Carlos Zavala Enríquez, Julio Cesar Angeles Ibarra, Ramón Roberto Garza Juárez; se eligió "Jose Edgar Barrera Diaz"). **Este campo "Responsable" NO aparece mencionado en absoluto en el texto de Escenario 3 del Excel**, es un hallazgo nuevo de la captura en vivo (sí aparece como paso explícito en Escenario 4: "Incluir un Responsable del Pedido").
- Botones al pie del formulario: **Confirmar** y **Regresar**.

## 2. Confirmación del encabezado

Al pulsar Confirmar, el sistema asigna folio y navega a `wp_pedidodetalle.aspx?<id>` mostrando "PEDIDO No.: 1048" (captura 057). La cabecera de esa pantalla muestra tres links de acción: **Editar pedido | Liberar Pedido | Cancelar Pedido**, y un botón **Regresar** a la derecha. Debajo: sección **Matriz de Puestos** (vacía al inicio) y sección **Movimientos detalles pedido** con pestaña **Detalles**.

Mensaje de advertencia visto justo después de crear el pedido, antes de tener detalles (captura 057, banner naranja): **"No existe información para formar Matriz."**

## 3. Formulario "Detalles de pedido" (alta de un detalle)

Capturas: 061, 065 (Excel), 069, 073, 077, 081, 085, 089, 093, 097, 101, 105, 109, 113, 117, 121, 129, 133, 141, 149, 153.

Campos del formulario de detalle, columna izquierda:
- **Estatus** (solo lectura) — "Vigente".
- **Tipo personal** * — solo lectura en este punto, muestra "Operativo".
- **Título** * — textbox (hereda el título del pedido).
- **Producto** * — combo (ej. "Técnico Audio PRG - IN" / se ve también escrito "Tecnico Audio PRG-IN" sin acentos en otra captura — inconsistencia de capitalización/acentos entre dos renders de la misma pantalla).
- **Lugar de Cita** * — combo ("Palacio de los Deportes").
- **Dirección cita** — textarea autorrellenada.
- **Otro** — checkbox.
- **Indicaciones especiales** — textarea libre.
- **Bloque por producto** — combo ("Ninguno" por defecto; existe la opción de crear "Nuevo Bloque", coincide con el Excel Escenario 2 pasos 20-21).
- **Facturable** — combo Sí/NO ("NO" por defecto — confirma la observación de Escenario 3 paso 8: "Factura está determinado como de No por default").

Columna derecha:
- **Evento Práctica** — checkbox (nuevo campo, no mencionado en el texto del Excel para Escenario 3; sin marcar).
- **Cantidad** * — textbox numérico.
- **Turnos** — textbox numérico, con texto de ayuda a la derecha que cambia dinámicamente: **"12 Horas por turno"** (confirma el paso 15 del Excel: "Debe mostrar 1 turno por 12 horas").
- **Fecha cita** * — date/time picker (dos combos de hora HH y MM, 00-23 / incrementos de minuto).
- **Fecha liberación** — date/time picker.
- **Fecha final cita** — date/time picker (se autocalcula a partir de fecha cita + duración del turno, ej. 21/08/2019 09:00 cita → 21/08/2019 21:00 fin, con 12 horas de turno).
- **Presentación por producto** — combo, quedó "(Ninguno)" (confirma "Validar que no se muestran presentaciones").
- **Completar con similares** — combo Sí/NO, "NO".
- **Fase del evento** — combo (ver detalle completo abajo).
- **Permitir cancelar** — combo Sí/NO, "NO".
- Botones: **Agregar Detalle** y **Cancelar**.

## 4. Campo "Fase del evento" — catálogo completo observado

El combo se abrió por completo y se capturó dos veces (097 y 113), con el mismo contenido en ambas:

```
No aplica
Desmontaje
Montaje
Preparacion
Show
```

Orden exacto en pantalla: "No aplica" aparece primero (como valor ya seleccionado/resaltado), y debajo la lista desplegada muestra: **Desmontaje, Montaje, Preparacion, Show** — es decir, orden alfabético de las 4 fases "reales" con "No aplica" como opción adicional fuera del orden alfabético (funciona como sentinela/default).

**Son 5 valores en total, ni más ni menos.** Esto fue verificado visualmente en dos capturas independientes (097_04m43s.png y 113_05m27s.png), ambas muestran la lista completa abierta con las mismas 5 opciones.

Nota ortográfica: en el render del combo "Preparacion" se ve sin tilde visible sobre la "o"; no se puede descartar al 100% que sea un artefacto de renderizado de fuente de GeneXus, pero en ningún frame se ve acento. Se recomienda verificar contra el catálogo real de la BD legacy si existe acceso.

Cada vez que se selecciona una fase y se pulsa "Agregar Detalle", aparece un banner naranja de éxito: **"Registro Agregado Correctamente"** (capturas 121, 145). Esto se repite 4 veces en el escenario, una por cada detalle agregado con cada fase: Preparación (1er detalle, mismo bloque que el inicial sin bloque explícito), luego Montaje, Show y Desmontaje agregados como "nuevos pedido detalle" sucesivos reutilizando el mismo producto "Técnico Audio PRG-IN" (el sistema conserva los valores previamente capturados, tal como dice el Excel paso 22: "El sistema debe guardar el valor introducido anteriormente", con la salvedad marcada en el Excel de que turnos y cantidad NO se conservan).

## 5. Grid "Matriz de Puestos" y tooltip de detalle (hover)

Captura 153 muestra el tooltip emergente que aparece al posicionar el cursor sobre una celda de la matriz (equivalente al paso 23 de Escenario 1: "Al posicionarse sobre el producto debe mostrar..."). Encabezado del tooltip: **"Editar Liberar Cancelar Pedido"** (tres acciones en una sola línea). Campos exactos listados debajo, en este orden:

```
ID                                   2386
Lugar de cita                        Palacio de los Deportes
Fecha cita                           21/08/2019 09:00
Fecha fin cita                       21/08/2019 21:00
Fecha liberación                     20/08/2019 06:00
Completar con similares              NO
Cantidad reservados                  0
Cantidad reservados real             0
Cantidad reservados con preasignación 0
Porcentaje completo                  0.00
Fase de evento                       Preparacion
Presentación producto                (vacío)
Indicaciones especiales              (vacío)
```

Nota de nomenclatura: en el formulario de alta el campo se llama **"Fase del evento"**, pero en este tooltip de la matriz aparece rotulado **"Fase de evento"** (sin "l"). Es una inconsistencia menor de copy en el sistema legado, útil para no asumir que el label es idéntico en todas las pantallas.

Esto confirma casi palabra por palabra la lista de campos que pedía validar el Escenario 1, paso 23: "ID, Lugar de Cita, Fecha Cita, Fecha Fin Cita, Fecha Liberación, Completar con Similares, Cantidad Reservados, Cantidad Reservados Real, Cantidad Reservados con preasignación, Porcentaje Completo, Fase del Evento, Presentación" — con "Indicaciones especiales" como campo adicional no mencionado ahí.

La tabla "Matriz de Puestos" en sí tiene columnas: **Bloque | Productos | <fecha, ej. 21/08> | <hora, 09:00> | ...</br>** y filas resumen **Total Solicitados** y **Presupuesto por día** (ej. "$1,000.00" con 4 detalles de 1 turno c/u). Cada detalle agregado aparece como una columna adicional dentro de la misma fila de producto (ej. "1 - T 1.00" repetido 4 veces conforme se agregan los 4 detalles de fase distinta), y "Total Solicitados" sube de 2 a 4 conforme se agregan detalles.

## 6. Mensajes de validación / error capturados

- **"Duración del evento(Días de show) es requerido."** — banner rojo que aparece al intentar Confirmar el encabezado sin llenar "Duración del evento(Días de show)" cuando hay una Complejidad distinta de "No Aplica" seleccionada (captura 041). Confirma que este campo es condicionalmente obligatorio (ligado a Tipo de complejidad), consistente con la lógica descrita en Escenario 2 y Escenario 29 (prorrateo por días de show).
- **"No existe información para formar Matriz."** — banner naranja informativo cuando el pedido aún no tiene ningún detalle (captura 057).
- **"Registro Agregado Correctamente"** — banner naranja de éxito tras cada alta de detalle (capturas 121, 145).

No se observaron otros mensajes de error/validación en la muestra revisada (p. ej. no se vio el mensaje de fecha de liberación posterior a fecha de cita, que sí se documenta en Escenarios 1 y 4 del texto, pero no ocurre en este Escenario 3 porque no se fuerza ese caso).

## 7. Botones / acciones — lista consolidada

- Encabezado de pedido: **Confirmar**, **Regresar**.
- Detalle de pedido (página): **Editar pedido**, **Liberar Pedido**, **Cancelar Pedido**, **Regresar**.
- Formulario de alta de detalle: **Agregar Detalle** (el Excel lo llama "Agregar Registro" — son sinónimos del mismo botón; el texto de QA usa el nombre informal, la UI real dice "Agregar Detalle"), **Cancelar**.
- Checkbox "Agregar contacto" visible en el encabezado junto al combo de Contacto (permite dar de alta un contacto nuevo sin salir del formulario — coincide con Escenario 20 del Excel).

## 8. Coincidencias y contradicciones vs. ESCENARIOS_PRUEBA_FREELANCE.md

**Coincide exactamente:**
- Los 32 pasos de la hoja Excel "Escenario 3" fueron fotografiados en pantalla abierta en paralelo (capturas 025-153), confirmando que el volcado de texto existente es literal.
- Secuencia Preparación → Montaje → Show → Desmontaje, cada uno en un "Agregar nuevo pedido detalle" separado reutilizando el mismo producto.
- "Debe mostrar 1 turno por 12 horas" → confirmado por el texto de ayuda "12 Horas por turno" junto al campo Turnos.
- "Factura está determinado como de No por default" → confirmado, Facturable = NO por defecto.
- "La sociedad pagadora por default está con ID 10" (en realidad se refiere a que se autocompleta un valor por defecto al elegir la UN, no necesariamente literal "10" en UI) → confirmado el autocompletado de Sociedad pagadora.
- "El sistema debe guardar el valor introducido anteriormente" (para Producto al repetir "Agregar nuevo pedido detalle") → confirmado.

**Nuevo / no mencionado en el texto:**
- Campo **Responsable** en el encabezado (combo de personas), no estaba en el texto de Escenario 3 (sí en Escenario 4).
- Campo **Evento Práctica** (checkbox) en el detalle de pedido — no mencionado en ningún escenario del texto.
- Campo **Indicaciones especiales** (textarea) en el detalle — no mencionado explícitamente en el texto de Escenario 3 (aparece implícito en la lista de Escenario 1 solo como "Presentación", sin "Indicaciones especiales").
- Mensaje exacto de validación de Duración del evento: "Duración del evento(Días de show) es requerido."
- Inconsistencia de copy "Fase del evento" (formulario) vs. "Fase de evento" (tooltip de matriz).
- El combo "Tipo de complejidad" no se limita a una lista corta: muestra un catálogo largo tipo autocompletar con nombres de recintos/auditorios, más la opción "No Aplica".

**Contradice / corrige al Excel:**
- Ninguna contradicción directa de fondo encontrada; el texto de Escenario 3 ya documentaba correctamente que Preparación/Montaje/Show/Desmontaje son 4 de los 5 valores reales del catálogo (el texto no menciona "No Aplica" como quinto valor explícito del catálogo, pero sí lo usa como comportamiento esperado en Escenario 2 y Escenario 5 ["Por Default pone No Aplica debido a la UN" / "El campo dice 'Ninguno' en vez de 'No aplica'"] — la captura de Escenario 3 confirma que el combo real sí tiene "No aplica" como opción explícita dentro del mismo catálogo, no solo como placeholder).

## 9. Veredicto sobre `fase_evento_enum` en el schema (`db/reset_database.sql`)

Definición actual en el schema:
```sql
CREATE TYPE fase_evento_enum AS ENUM ('montaje','evento','desmontaje','otro');
...
INSERT INTO tc_fases_evento (tenant_id, clave, titulo, orden) VALUES
  ('00000000-0000-0000-0000-000000000001','montaje','Montaje',1),
  ('00000000-0000-0000-0000-000000000001','evento','Evento en vivo',2),
  ('00000000-0000-0000-0000-000000000001','desmontaje','Desmontaje',3);
```

**NO coincide con lo observado en pantalla y requiere corrección.** El catálogo real del sistema legado (confirmado en dos capturas independientes con el dropdown totalmente abierto, 097 y 113) tiene exactamente estos 5 valores:

1. **No aplica** (sentinela/default — falta por completo en el schema; hoy solo existe implícitamente como NULL en `fase_evento_id`, pero el legado lo trata como un valor explícito del catálogo seleccionable).
2. **Preparación** (falta por completo en el schema — no hay ningún valor equivalente).
3. **Montaje** (coincide).
4. **Show** (el schema tiene "evento"/"Evento en vivo" en su lugar — **nombre incorrecto**, el legado nunca usa la palabra "evento" como fase, usa "Show").
5. **Desmontaje** (coincide).

El valor `'otro'` del enum del schema **no se observó en ningún momento** en el catálogo real (ni en el combo desplegado, ni en el tooltip, ni en el Excel). Es un valor inventado sin respaldo en esta evidencia.

**Recomendación concreta:** redefinir el enum como
```sql
CREATE TYPE fase_evento_enum AS ENUM ('no_aplica','preparacion','montaje','show','desmontaje');
```
y actualizar el seed de `tc_fases_evento` para insertar las 5 filas con esos `clave`/`titulo` (orden sugerido: no_aplica=0, preparacion=1, montaje=2, show=3, desmontaje=4), eliminando `'evento'` y `'otro'`. Si se prefiere no tener un valor explícito "no_aplica" en el enum (modelarlo como `fase_evento_id IS NULL`), al menos renombrar `'evento'` → `'show'` y agregar `'preparacion'` es indispensable para reflejar el comportamiento real capturado en Escenario 3.
