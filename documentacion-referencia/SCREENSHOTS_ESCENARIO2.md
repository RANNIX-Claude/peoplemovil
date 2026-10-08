# Escenario 2 — Hallazgos de capturas de pantalla (video walkthrough)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\15 - Escenario2\`
(172 PNGs, video de 8m08s, `-uCa_EyU4OQ`, "Escenario2"). El video intercala capturas del sistema real (app GeneXus "RRHH" en `integramx-001-site2.btempurl.com/qafreelancev2/`) con capturas de la hoja Excel `Scripts de Prueba Freelance.xlsx` (pestaña "Escenario 2") que el probador va leyendo en voz alta. El contenido de la hoja Excel es idéntico al ya volcado en `ESCENARIOS_PRUEBA_FREELANCE.md`, así que este documento se enfoca en lo que aparece en el SISTEMA REAL, que aporta detalle no capturado en el texto plano del Excel.

Muestreo: ~40 frames espaciados uniformemente a lo largo de las 172 capturas (aprox. cada 5), más frames adicionales dirigidos alrededor de los pasos 9-12 (Complejidad/Duración) donde se abrían combos. Archivos citados por nombre exacto.

---

## 1. Pantalla "Pedidos" — Encabezado / Información General (alta de pedido)

Vista: `te_pedido.aspx?INS,0` — título de página "Pedidos", card azul "Información General".

Campos y controles, en el orden que aparecen (columna izquierda, todos con combo tipo `(Ninguno)` por default salvo donde se indica):

1. **Cliente*** — combo buscable/autocompletar. (`001_00m00s.png`, `006_00m10s.png` — lista desplegada: MMS Comunicaciones, MTV Networks de México, Música Esencial, Ocesa Anfiteatro, OCESA Comercial, Ocesa Presenta (aparece DOS veces en la lista — posible duplicado de catálogo), OCESA Promotora, Ochoa Sport, ODC OPERACIÓN DIFUSIÓN Y COMUNICACIÓN, Oelli, Operadora de Centros de Espectáculos, Operadora Orcellón, OPERADORA PERPEL, ORGANIZACIÓN DE ASISTENCIA Y PROMOCION SOCIAL CIUDAD DE DIOS A.C., Organización y Servicios Integrales Para Espectáculos, PA Media, Par2 Asesores y Mkt, Pata Negra — lista alfabética larga, scrollable, con razón social completa "S.A. de C.V.")
2. **Id Contacto*** — combo, se llena tras elegir cliente (ej. "Gabriela Flores").
3. **Id sucursal*** — combo (ej. "CDMX").
4. **Unidad de negocio*** — combo. Lista vista parcialmente abierta en `011_00m21s.png`: (Ninguno), A Muse, Actividades Deportivas, Admón y Contratación de Talento, Admón y Finanzas, Aldea Digital, Anfitriones, Asdeporte, Atención a Clientes, Calacas Zingaro, Cavalia, Cirque Du Soleil, Comercial, Control de Accesos, Corona Capital, E-Ticket, Enlace, Estacionamientos, Estadio 3 de Marzo Gdl, Estadio Azul... (lista muy larga, alfabética — catálogo `tc_unidades_negocio` tiene muchas más UN que las mencionadas en el Excel, que solo habla de "Seguridad" y "PRG").
5. **Id PEP** — combo (sin asterisco obligatorio visible en frame inicial).
6. **Id evento*** — combo. Lista vista en `031_01m01s.png`: (Ninguno), Feria del Juguete 2017, Futbol América vs Pumas, **Jacob Whitesides 2019** (seleccionado), Tributo a Michael Jackson.
7. **Título*** — textbox, se autollena a partir del evento+algo (ej. "Jacob Whitesides 2019---Escena[rio2]" — el sistema concatena el nombre del evento con sufijo libre).
8. **Lugar de cita** — combo (no "Sin definir" aparece como valor placeholder en frame 1). Lista larga de inmuebles/recintos vista en `036_01m14s.png`: Foro Scotiabank, **Foro Sol** (seleccionado), Galerías Monterrey, Hipódromo de las Américas Acceso B, Hipódromo de las Américas Carpa neumática, Hipódromo de las Américas Grada Central, Hipódromo de las Américas Infield, Hotel Camino Real, Hotel Camino Real Monterrey, Hotel Crowne Plaza México, Hotel Crowne Plaza Monterrey, Hotel Fiesta Americana Guadalajara, Hotel Fiesta Americana Reforma, Hotel Four Seasons, Hotel Olas Altas Inn, Hotel Royal Pedregal, Instituto Bilingüe Rudyard Kipling, Jardín Versal, Lugar de Prueba, Lunario del Auditorio Nacional...
9. **Dirección lugar / "lugar"** — textarea de solo lectura, se autollena con la dirección del PEP/inmueble elegido (ej. "Av. Viaducto Rio de la Piedad S/N, Granjas México, 08400 Iztacalco, CDMX").
10. **Otro** — checkbox (deja capturar dirección manual probablemente).
11. **Tipo de movimiento*** — combo. Opciones exactas (`042_01m26s.png`): **(Ninguno)**, **Pedido**, **Servicio interno**. (Esto CONTRADICE la observación de bug en el Excel para Escenario 1/2/3 que decía "únicamente muestra pedido" — en esta captura el combo sí muestra las 3 opciones correctamente, incluyendo "Servicio interno" seleccionado. Puede ser que el bug ya estaba corregido para el momento del video, o que el bug reportado aplicaba a otro punto del flujo.)
12. **Tipo de complejidad** — combo. **Lista COMPLETA capturada abierta en `044_01m31s.png` y `045_01m34s.png`** (7 opciones visibles, orden alfabético):
    - Auditorio Nacional, Auditorio Guadalajara y Plazas Similares
    - Estadios Foro y Plazas Similares en el Extranjero
    - Festivales de mas de 50,000 asistentes
    - **Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares** (la seleccionada en el escenario)
    - No Aplica
    - Palacio de los Deportes, Arena VFG y Plazas Similares
    - Teatro Metropolitan, Plaza Condesa y Plazas Similares

    Nota: el Excel original decía "únicamente muestra 3 opciones del foro sol, y dos son iguales" como bug — en el video, el catálogo muestra 7 opciones limpias y distintas (ninguna duplicada), lo que sugiere que el bug fue corregido antes de esta grabación, o que el bug se refería a una sesión distinta. De cualquier forma, estos 7 textos exactos son el catálogo real a replicar (vs. los 6 valores genéricos placeholder actualmente en el seed de `reset_database.sql`: foro_sol_1d, foro_sol_2d, palacio_1d, auditorio_1d, teatro_1d, evento_gral).
13. **Duración del evento (Días de show)** — **campo de texto NUMÉRICO libre, NO es un combo/catálogo**. Se ve como una caja vacía que luego toma el valor "0" y después "1" (`041_01m25s.png` → `0`; `046_01m37s.png` → `1`). Esto es una diferencia de modelo importante: el sistema legado no usa un catálogo de "tipos de duración" (como `tc_tipos_duracion_evento` en el schema nuevo) sino que captura directamente el número de días de show como entero. El label completo del campo es **"Duración del evento(Días de show)"** (sin espacio antes del paréntesis en la UI).
14. **Sociedad pagadora*** — combo (ej. "Operadora de Centros de Es[pectáculos]").
15. **Permitir cancelar confirmaciones*** — combo con opciones NO/SI (visto como "NO").
16. **Responsable*** — combo de personas, ej. "(Ninguno)" → "Julio Cesar Angeles Ibarra". Este campo **tiene asterisco obligatorio** y aparece también en Escenario 2, no solo en Escenario 4 como registraba el Excel original (paso "Incluir un Responsable del Pedido" solo se documentaba en Escenario 4).
17. Botones: **Confirmar** (azul) y **Regresar**.

---

## 2. Pantalla de listado "Pedidos" (grid)

Vista: `te_pedidoww.aspx` — accesible tras agregar/al navegar hacia atrás.

Columnas de la grilla (`058_02m09s.png`): **Id, Título, Estatus, Unid.Neg., Sucursal, lugar, Responsable, Complejidad, T.Mov, PeP | Descripción**. Botones de exportar: icono "+", XLS, PDF. "Selecciona columnas" (configurable). Filtro: "Buscar en [combo campo]" + caja de valor + flechas de paginación.

Valores de Estatus observados en la grilla: **Vigente, Cancelado, Procesado**. (El Excel documentaba quejas sobre el campo "Estatus del Pedido" mostrando "NINGUNO" en vez de "Normal" en otros escenarios — en esta grilla los valores son distintos: Vigente/Cancelado/Procesado, sugiriendo que el enum de estatus de pedido tiene más de 3-4 valores reales).

Columna "Complejidad" confirma literalmente los mismos textos largos del catálogo (ej. "Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares", "Auditorio Nacional, Auditorio Guadalajara y Plazas Similares") — coincide exactamente con las opciones del combo documentadas arriba.

Columna "T.Mov" confirma valores "Servicio interno" y "Pedido" en la práctica.

Pedido creado en este escenario: **ID 1047**, Título "Jacob Whitesides 2019---Escenario2", Estatus "Vigente", Unid.Neg. "PRG", Sucursal "CDMX", lugar "Foro Sol", Responsable "Julio Cesar Angeles Ibarra", Complejidad "Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares", T.Mov "Servicio interno", PeP "IT-PD-2015-08-27N085LT-A Test Day FIBA".

---

## 3. Pantalla "Detalles de pedido" (alta de detalle / línea de pedido)

Vista: `wp_pedidodetalle.aspx?1047`. Sección superior: encabezado con **"Matriz de Puestos"** (visible parcialmente en `172_08m03s.png` — título de sección no documentado en el Excel) y tabla "Bloque | Productos | [fechas como columnas]".

Card "Detalles" / "Movimientos detalles pedido", formulario con dos columnas:

Columna izquierda:
- **Estatus** (solo lectura, ej. "Vigente")
- **Tipo personal*** — combo: Staff, Operativo (confirma el Excel: "Validar que muestra Staff y Operativo").
- **Título*** — textbox prellenado con el título del pedido.
- **Producto** — combo, catálogo cambia según Tipo personal/UN. Con **Tipo personal = Staff** y UN=PRG, lista completa capturada abierta en `121_05m03s.png`:
  (Ninguno), Stage Manager A PRG-MA, Stage Manager A PRG-FE, Stage Manager A PRG-IN, Stage Manager B PRG-MA, Stage Manager B PRG-FE, Stage Manager B PRG-IN, Asistente Coordinador PRG-IN, **Asistente Operador PRG-IN**, **Asistente Aux A PRG-IN**.
  Nota: el Excel nombra el segundo producto como "Asistente Auxiliar A"; el sistema lo etiqueta como **"Asistente Aux A PRG-IN"** (abreviado) — divergencia de nomenclatura a documentar.
- **Lugar de Cita*** — combo (hereda "Foro Sol").
- **Dirección cita** — solo lectura.
- **Otro** — checkbox.
- **Indicaciones especiales** — textarea.
- **Bloque por producto** — combo numérico. Aparece vacío/"Ninguno" al inicio; tras agregar un primer registro, pasa a ofrecer **1, 2** (y luego **1, 2, 3**) — es decir, el sistema numera automáticamente los bloques disponibles y dejar elegir "Nuevo Bloque" los incrementa (`126_05m17s.png`, `136_05m38s.png`).
- **Facturable*** — combo NO/SI, visto en "NO" por defecto.

Columna derecha:
- **Evento Práctica** — checkbox (no documentado en el Excel; aparece junto a "Estatus").
- **Cantidad** — numérico.
- **Turnos** — numérico, con **texto auxiliar inline "X Horas por turno"** que se autollena según el producto elegido (ej. "**12 Horas por turno**" al elegir Asistente Operador PRG-IN) — esto SÍ confirma el dato que el Excel decía que "en ningún momento se muestra esa información" (parece que en este escenario de PRG sí se muestra correctamente, a diferencia de Seguridad en Escenario 1).
- **Fecha cita*** — date + hora (2 combos 00-23) + hora (00-59, incrementos). Combo de horas visto desplegado en `091_03m24s.png` (00,01,02...19...).
- **Fecha liberación** — date + hora.
- **Fecha final cita** — date + hora (se autocalcula sumando las horas del turno: fecha cita 08/08/2019 10:00 + 12h turno → fecha final cita 08/08/2019 22:00, visto en `136_05m38s.png` y confirmado en el popup de `156_07m00s.png`).
- **Presentación por producto** — combo (Ninguno por defecto).
- **Completar con similares** — combo NO/SI.
- **Fase del evento** — campo de SOLO LECTURA (texto gris), muestra **"No aplica"** cuando Tipo personal=Staff + hay complejidad/días de show (confirma el Excel paso 19, aunque el Excel decía que en otro escenario aparecía "Ninguno" en vez de "No aplica" — aquí el texto exacto es **"No aplica"**, con minúscula en "aplica").
- **Permitir cancelar*** — combo NO/SI.
- Botones: **Agregar Detalle** (azul) y **Cancelar**.

---

## 4. Matriz / grid de bloques y productos (tras agregar registros)

Capturada en `141_06m14s.png` y `156_07m00s.png`. Tabla con:
- Encabezado de columnas = **fechas** (ej. "07/08", "08/08") con sub-fila de **horas** (ej. "06:00", "10:00").
- Filas por **Bloque** (1, 2, 3...) con columna "Productos" mostrando `Producto | Título del pedido` (ej. "Asistente Operador PRG-IN | Jacob Whitesides 2019---Escenario2") y celdas con formato **"[Cantidad] - T [Turnos].00"** (ej. "1 - T 1.00").
- Fila **"Total Solicitados"** — suma de cantidades por columna/fecha.
- Fila **"Presupuesto por día"** — monto en pesos por columna/fecha (ej. "$ 3,000.00", "$ 12,800.00") — **confirma el paso 22 del Excel**: "Validar que el presupuesto día va ligado a la complejidad y los días de show".

**Tooltip/popover al pasar el cursor sobre una celda** — título **"Editar Liberar Cancelar Pedido"** (tres acciones en un mismo menú), con los siguientes campos de solo lectura (confirma casi exactamente el paso 23 del Excel):
- ID (ej. 2384, 2385 — folio del detalle)
- Lugar de cita
- Fecha cita
- Fecha fin cita
- Fecha liberación
- Completar con similares
- Cantidad reservados
- Cantidad reservados real
- Cantidad reservados con preasignación
- Porcentaje completo
- Fase de evento
- Presentación producto
- Indicaciones especiales

(El Excel decía "ID, Lugar de Cita, Fecha Cita, Fecha Fin Cita, Fecha Liberación, Completar con Similares, Cantidad Reservados, Cantidad Reservados Real, Cantidad Reservados con preasignación, Porcentaje Completo, Fase del Evento, Presentación" — la captura confirma TODOS estos campos literalmente, en el mismo orden, más "Indicaciones especiales" que el Excel no mencionaba explícitamente en ese paso.)

---

## 5. Mensajes de confirmación / error (wording exacto)

- **Toast naranja de éxito** (esquina superior derecha, con icono de alerta ⚠ amarillo/naranja pero usado para éxito): **"Registro Agregado Correctamente"** — visto en `161_07m18s.png` tras pulsar "Agregar Detalle".
- **Toast naranja de error**: **"No existe información para formar Matriz."** — visto en `060_02m13s.png`, aparece al entrar a Detalles de pedido cuando aún no hay ningún detalle/registro capturado (matriz vacía). Mensaje con punto final.
- Ambos toasts comparten el mismo estilo visual (franja naranja superior derecha, ícono de signo de exclamación), sin distinguir visualmente éxito de error más que por el texto.

---

## 6. Botones / acciones confirmadas

- **Agregar Detalle** / **Cancelar** (formulario de detalle)
- **Confirmar** / **Regresar** (formulario de encabezado de pedido)
- **Editar / Liberar / Cancelar Pedido** (menú contextual de 3 acciones sobre una celda de la matriz — aparecen como enlaces dentro del mismo popover, no botones separados)
- **Seleccionar columnas**, exportar **XLS**/**PDF**, botón "+" (grid de listado de pedidos)

---

## 7. Reglas de negocio NUEVAS o no capturadas en el schema/Excel

1. **"Duración del evento (Días de show)" es un campo numérico entero libre capturado en el pedido**, NO una referencia a un catálogo de "tipos de duración" (`tc_tipos_duracion_evento`). El catálogo de complejidad (`tc_tipos_complejidad`) sí es un combo de catálogo. El modelo actual (`reset_database.sql`) ya tiene `te_pedidos.duracion_dias int` (correcto, coincide) pero también tiene `tipo_duracion_id` FK a `tc_tipos_duracion_evento` — en el sistema legado real no se ve ningún combo de "tipo de duración" en el flujo de alta de pedido; solo se captura el entero. Confirmar si `tc_tipos_duracion_evento`/`tp_duraciones_evento` se usan en otra pantalla (tabulador de sueldos) y no en el alta de pedido.

2. **Catálogo real y completo de Tipo de Complejidad (7 valores, no 6)**, con textos exactos a usar como seed real en vez de los genéricos actuales:
   - Auditorio Nacional, Auditorio Guadalajara y Plazas Similares
   - Estadios Foro y Plazas Similares en el Extranjero
   - Festivales de mas de 50,000 asistentes
   - Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares
   - No Aplica
   - Palacio de los Deportes, Arena VFG y Plazas Similares
   - Teatro Metropolitan, Plaza Condesa y Plazas Similares

   (El valor "No Aplica" es parte del MISMO catálogo combo, no un estado especial fuera de catálogo — relevante para Escenario 3/5 donde "No Aplica" se selecciona como complejidad para UN que no la requieren.)

3. **"Bloque por producto" es un combo que lista los bloques YA EXISTENTES + permite crear uno nuevo**, y el sistema incrementa automáticamente el número disponible (1 → 1,2 → 1,2,3) conforme se agregan detalles. Esto es la mecánica real detrás de "Seleccionar nuevo Bloque" del Excel.

4. **Turnos trae un texto auxiliar inline "[N] Horas por turno"** derivado del producto (no es una validación aparte, es texto descriptivo junto al campo numérico de Turnos) — contradice/matiza el bug reportado en Escenario 1 de que esa información "no se muestra en ningún momento" (en PRG/Escenario 2 sí se mostró).

5. **"Fecha final cita" se autocalcula** sumando la duración del turno (horas) a la fecha/hora de cita — confirmado numéricamente (10:00 + 12h turno = 22:00 el mismo día).

6. **Campo "Responsable" (combo de persona) es obligatorio (*) en el alta de pedido en Escenario 2**, no solo mencionado para Escenario 4 — debería ser un campo estándar de `te_pedidos`, posiblemente ya cubierto por algún `responsable_id`; verificar en el schema.

7. **Campo "Evento Práctica" (checkbox)** aparece en el formulario de Detalles de pedido, al lado de Estatus — no documentado en el Excel ni evidente en el schema revisado (`te_pedidos_detalle` o equivalente). Podría mapear a algo como "es simulacro/ensayo, no cuenta para nómina real".

8. **Mensajes de sistema exactos**: "Registro Agregado Correctamente" (éxito) y "No existe información para formar Matriz." (error/estado vacío) — útiles para repicar copy en PeopleMovil.

9. **Nomenclatura de catálogo de clientes con posible duplicado**: "Ocesa Presenta, S.A. de C.V." aparece DOS veces consecutivas en la lista alfabética del combo Cliente (`006_00m10s.png`) — podría ser un bug de datos duplicados en el sistema legado a NO replicar, o dos registros legítimos distintos (sucursales/razones sociales con mismo nombre).

10. **Nomenclatura de producto abreviada**: el catálogo de productos reales usa "Asistente Aux A PRG-IN" (no "Asistente Auxiliar A" como en el texto QA) — sufijo de 2-3 letras de Unidad de Negocio al final del nombre de producto es el patrón general (PRG-IN, PRG-MA, PRG-FE), confirmando el patrón ya visto en otros escenarios (Seguridad-MA, Seguridad-FE, etc.).

11. **Título del pedido se autogenera concatenando el nombre del evento** (ej. "Jacob Whitesides 2019" + sufijo libre "---Escenario2") pero sigue siendo editable (campo de texto, no solo lectura).

12. **Sección de la matriz de bloques/productos en Detalles de pedido se titula "Matriz de Puestos"** (visible parcialmente en `172_08m03s.png`) — nombre de UI a conservar.

---

## 8. Confirmaciones directas de lo ya documentado en ESCENARIOS_PRUEBA_FREELANCE.md

- Tipo de movimiento SÍ muestra 2 opciones (Pedido, Servicio interno) + Ninguno — contrario al bug anotado para Escenario 1/2/3 en el texto, en este video el combo se ve correctamente con 3 valores.
- Tipo de personal muestra Staff y Operativo (paso 13).
- Fase del evento = "No aplica" cuando hay complejidad + Staff (paso 19), aunque con capitalización "No aplica" (no "No Aplica").
- El presupuesto por día está ligado a complejidad + días de show, visible en la fila "Presupuesto por día" de la matriz (paso 22).
- El detalle, al posicionarse sobre el producto en la matriz, muestra el listado casi exacto de 12 campos del paso 23.
