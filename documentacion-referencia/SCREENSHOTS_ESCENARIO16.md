# Walkthrough de pantallas — Escenario 16: Disminución de personal solicitado + Certeza valor

> Fuente: `26 - P20190319 _0000 Escenario 16 Disminución de personal solicitado Certeza valor\` (84 PNGs, video YouTube `XbLmmUqEjXY`, 280s).

Muestra revisada: ~25 imágenes distribuidas uniformemente (001, 005, 009, 013, 017, 021, 025, 029, 033, 037, 041, 045, 049, 053, 057, 061, 065, 069, 073, 074, 077, 081, 082, 083, 084).

## 1. Flujo observado

1. **001_00m00s.png** — Pantalla **Pedidos** (`te_pedidow.aspx`), listado existente de pedidos de otros escenarios QA (776 "Entrega 03 Escenario 14", 777 "Entrega 03 Escenario 15", etc.) — confirma que todos los escenarios de este set de pruebas comparten el mismo ambiente/tenant QA y se numeran secuencialmente por pedido.
2. **005_00m15s–013_00m43s** — Creación de **Pedido 778 "Entrega 03 Escenario 16"**:
   - Cliente: "OCESA Promotora, S.A. de C.V." (dropdown con catálogo largo de clientes: Maguen Team, Make Pro, Mandarina Marketing, Marketing Management México, Martínez López Jorge, Mas Volumen, MC Show Business, Mex Tenis, Mint Creative Lab, Mixología B.S., MMS Comunicaciones, MTV Networks, Música Esencial, Ocesa Anfiteatro, Ocesa Comercial, Ocesa Presenta, OCESA Promotora…).
   - Contacto: "Macedo Wendy".
   - Sucursal: CDMX.
   - **Unidad de negocio: "Seguridad"**.
   - **PEP**: "(Ninguno)" inicialmente.
   - Lugar de cita: inicia en "Academia Maddox Satélite" (default), luego cambiado a **"Palacio de los Deportes"** con dirección auto-completada "Av Viaducto Río de la Piedad y Río Churubusco S/N, Granjas México, 08400 Ciudad de México, CDMX".
   - Tipo de movimiento: "Servicio interno".
   - Sociedad pagadora: "Servicios de Protección Privada Lobo, S.A. de C.V.".
   - **"Permitir cancelar confirmaciones" = NO** (dropdown a nivel pedido, igual que en Escenario 13).
3. **017_01m02s.png** — Formulario de Detalle de pedido: dropdown **Producto** con catálogo completo de puestos visto: Apoyo Retención de Talento-IN, Apoyo Seguridad-MA, Asistente Administrativo-IN, Asistente Operativo-IN, Control de Accesos-MA/FE/IN, Control de Accesos 4-MA/FE, Instructor de Capacitación-IN, Local Crew-FE/MA/IN, Local Crew Asistente de Supervisor-FE/MA, Local Crew Supervisor-FE/MA, **Seguridad-IN** (seleccionado).
4. **021_01m18s.png** — Detalle con **Cantidad = 6**, Turnos = 1.00 ("8 Horas por turno" como texto de ayuda), selector de **Fecha cita** (calendario emergente, mes Abril 2019).
   - **DIVERGENCIA vs texto del escenario**: `ESCENARIOS_PRUEBA_FREELANCE.md` dice "Crear un detalle con cantidad 5", pero la prueba real ejecutada usó **cantidad = 6** (y 6 empleados, como anota el propio script Excel QA: "Para este escenario se necesitarán 6 empleados").
5. **025_01m27s.png** — Dropdown **"Presentación por producto"** (catálogo de uniformes, igual observado en otros escenarios): Pantalón Mezclilla Azul/Camisa Blanca/Zapatos Negros, Pantalón Negro de Vestir+Camisa Blanca, +Playera Azul y Chamarra Azul, +Playera Lobo y Chamarra Lobo, +Playera Naranja y Chamarra Naranja, +Playera Negro-Rojo y Chamarra Negro-Rojo, Pantalón negro de vestir y playera guinda, Traje Negro y Camisa Blanca.
6. **029_01m38s.png** — Pedido 778 guardado: Matriz de Puestos "23/04 06:00, Seguridad-In 6-T1", Total Solicitados = 6, Presupuesto por día = 1800. Acciones de cabecera: "Editar pedido | Liberar Pedido | Cancelar Pedido | Regresar".
7. **033_01m45s / 037_01m59s** — Pestaña **Reservaciones** del detalle liberado: panel "Personal Confirmado" vacío, con botones **"Confirmación Forzada"** y **"Confirmación Preasignada"**.
8. **041_02m08s.png** — Hoja Excel "Scripts de Prueba Freelance_leonardo" (pestaña "Otros Escenarios Pedidos") muestra los **6 empleados reales usados y su certeza valor**, con IDs QA concretos (distintos de los IDs de ejemplo del texto del escenario):
   | IdContacto | Alias | Nombre completo | Certeza valor |
   |---|---|---|---|
   | 65754 | Mcarlos | Carlos Kenji Cruz Moreno | 0.9 |
   | 65751 | Vcarlos | Carlos Daniel Castro Vera | 0.9 |
   | 65712 | Ojavier | Javier Raúl Ortiz Peralta | 0.9 |
   | 65746 | Aalberto | César Alberto Chávez Azcona | 0.7 |
   | 65724 | Ctarek | Rodolfo Tarek Salazar Canaan | 0.8 |
   | 65690 | Bedwin | Edwin Jael García Barranco | 1.0 |
   - **DIVERGENCIA vs texto del escenario**: el texto original usa IDs genéricos (1, 1962, 2074, 2116, 2790, 2795); el ambiente QA real usa IDs de empleado distintos (65690–65754), confirmando que esos números del documento son solo placeholders/ejemplo, no IDs reales a replicar.
9. **045_02m14s – 061_02m50s** — Secuencia de **5 Confirmaciones Forzadas** aplicadas en este orden exacto (coincide con el guion): 65754 (0.9) → 65751 (0.9) → 65712 (0.9) [tercer 0.9] → 65746 (0.7) → 65724 (0.8), todas quedando con Estatus `CONFIRMADO FORZADO`. (El sexto empleado, 65690 con certeza 1, se confirma más adelante, fuera de la muestra exacta revisada pero referenciado en el guion Excel como "Quinto el empleado que vale 1" — en la práctica el orden visto en la grid difiere ligeramente del orden textual del guion, ver sección 4).
10. **065_03m06s.png** — Tooltip/popup "Editar Liberar Cancelar Pedido" al pasar el cursor sobre la celda de la matriz, mostrando detalle emergente: ID 2104, Lugar de cita, Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, **Cantidad reservados = 6**, **Cantidad reservados real = 0**, Cantidad reservados con preasignación = 0, **Porcentaje completo = 86.67%** (=5/6 confirmados reales en ese momento).
11. **069_03m16s.png** — Edición del detalle: **Estatus = Liberado**, Cantidad sigue en 6.
12. **073_03m29s.png — HALLAZGO CLAVE**: Al intentar reducir la Cantidad directamente de **6 a 3** y pulsar "Modificar detalle", el sistema muestra un **mensaje de error naranja en la barra superior**:
    > **"Imposible realizar el cambio, se tienen reservaciones con certeza valor menor a 1"**
    El cambio es **rechazado** (el campo Cantidad permanece en 3 pero NO se guarda — ver siguiente paso).
13. **074_03m38s–081_04m13s** — El usuario QA reintenta con un valor intermedio: cambia Cantidad a **4** (en vez de 3) y pulsa "Modificar detalle" de nuevo.
14. **083_04m20s / 084_04m25s.png** — Esta vez el sistema acepta el cambio: banner **"Registro Modificado Correctamente"**. En la pestaña Reservaciones, el grid confirma la cancelación automática de los **dos empleados de menor certeza valor**:
    - 65746 — César Alberto Chávez Azcona → **Estatus: Cancelado** (fila resaltada en rosa/rojo)
    - 65724 — Rodolfo Tarek Salazar Canaan → **Estatus: Cancelado** (fila resaltada en rosa/rojo)
    - Los 4 restantes (65754, 65751, 65712 con certeza 0.9, y 65690 con certeza 1) permanecen `CONFIRMADO FORZADO`.
    Esto **confirma la lógica de negocio esperada** del escenario: al reducir la cantidad solicitada, el sistema cancela automáticamente primero a los empleados con menor certeza valor (0.7 y 0.8 antes que los de 0.9 o 1).

La grabación de esta carpeta **termina en la imagen 084** (reducción 6→4), sin llegar a mostrar el segundo paso del guion (reducir de 3 a 2 y validar que se cancele "el último que confirmó con certeza valor 0.9"). Es decir, el recorte de video solo cubre la primera mitad del escenario.

## 2. Catálogos / valores de dropdown observados

- **Unidad de negocio**: catálogo extenso visto parcialmente — A Muse, Actividades Deportivas, Administración y Contratación de Talento, Admón y Finanzas, Aldea Digital, Anfitriones, Asdeporte, Atención a Clientes, Calacas Zíngaro, Cavalia, Cirque Du Soleil, Comercial, Control de Accesos, Corona Capital, E-Ticket, Enlace, Estacionamientos, Estadio 3 de Marzo Gdl, Estadio Azul, **Seguridad** (usado), Producción, Transportes, Operaciones Inmuebles, PRG.
- **Evento** (dropdown, visto en pantalla 057): (Ninguno), Club VIP 2018, **Entrega 03** (seleccionado — convención interna de nombre de "evento" para las pruebas QA), Feria del Juguete 2017, Futbol América vs Pumas, Green Day 2019, Jacob Whitesides, SIdonie, Tributo a Michael Jackson.
- **Producto / Puesto**: ver lista completa en sección 1.3 (catálogo de puestos de seguridad/operativos).
- **Permitir cancelar confirmaciones**: `SI`/`NO`.
- **Estatus de reservación**: `CONFIRMADO FORZADO`, `Cancelado`.
- **Estatus de pedido/detalle**: `Vigente`, `Liberado`.

## 3. Mensajes exactos capturados

- **Error de validación al reducir cantidad en más de ~2 unidades de golpe** (imagen 073):
  > "Imposible realizar el cambio, se tienen reservaciones con certeza valor menor a 1"
- **Confirmación de guardado exitoso** (imagen 029, 053, 057, 083): "Registro agregado correctamente" / "Registro Modificado Correctamente".
- **Error al crear pedido sin Evento** (imagen 049): "Evento es requerido." (texto en rojo junto al dropdown "Evento").

## 4. Reglas de negocio / hallazgos NUEVOS no capturados en el schema/texto del escenario

1. **Límite de reducción incremental**: el sistema **no permite reducir la cantidad de un detalle en un solo paso cuando quedarían pendientes de cancelar reservaciones con certeza_valor < 1 por encima de cierto umbral** — en la prueba, reducir de 6→3 (3 cancelaciones necesarias) fue **rechazado**, pero reducir de 6→4 (2 cancelaciones) fue **aceptado**. Esto es una regla de negocio/técnica **no documentada en el texto del escenario ni en el esquema actual**: aparenta forzar reducciones incrementales (de a lo sumo ~2 personas con certeza<1 por edición) en vez de permitir saltos grandes. Se recomienda:
   - Confirmar con el equipo de negocio si este es un comportamiento deseado (p. ej. "no cancelar más de N personas de una sola vez sin confirmación adicional") o es un bug/limitación técnica de la versión Lobo que PeopleMovil debería corregir (permitir la reducción directa en un solo paso, siempre que la lógica de selección de cancelados sea determinística).
   - Si se decide preservar la regla, se necesita un parámetro de negocio equivalente a `cat_parametros_globales.max_cancelaciones_automaticas_por_edicion` (nombre sugerido) en vez de hardcodearlo.
2. **Selección automática de quién se cancela al reducir cantidad**: confirmado que el criterio es **ordenar por `certeza_valor` ascendente** y cancelar primero a los de menor certeza; en empates de certeza valor, se cancela al que confirmó **más tarde** (el orden de "último que confirmó" del guion). El modelo de datos debe soportar una consulta ordenable por `(certeza_valor ASC, fecha_confirmacion DESC)` para implementar esta regla de autocancelación.
3. **Popup de resumen por celda de Matriz de Puestos**: al pasar el cursor sobre una celda se despliega un popup "Editar Liberar Cancelar Pedido" con: ID de detalle, Lugar de cita, Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, **Cantidad reservados**, **Cantidad reservados real**, **Cantidad reservados con preasignación**, **Porcentaje completo** (campo calculado, visto en 86.67% = 5/6). Esto sugiere que la UI de PeopleMovil debería exponer estos 4 contadores (reservados, reservados real, reservados con preasignación, % completo) como parte del detalle de pedido, no solo el estatus agregado.
4. **Campo "Evento" obligatorio y separado de "PEP"**: al crear un pedido, "Evento" es un campo catalogado y requerido independiente de "PEP" y "Unidad de negocio" — confirma que el modelo de datos de `pedidos` necesita una FK a un catálogo de eventos además de PEP/unidad de negocio/sitio.
5. **Convención "Entrega 03"**: todos los pedidos de este set QA usan el mismo "Evento = Entrega 03" y "Título = Entrega 03 Escenario NN" — es una convención de prueba, no una regla de negocio real; se anota para que no se confunda con dato de producción al analizar capturas futuras.

## 5. Archivos fuente citados

`001_00m00s.png`, `005_00m15s.png`, `009_00m23s.png`, `013_00m43s.png`, `017_01m02s.png`, `021_01m18s.png`, `025_01m27s.png`, `029_01m38s.png`, `033_01m45s.png`, `037_01m59s.png`, `041_02m08s.png`, `045_02m14s.png`, `049_02m23s.png`, `053_02m31s.png`, `057_02m41s.png`, `061_02m50s.png`, `065_03m06s.png`, `069_03m16s.png`, `073_03m29s.png`, `074_03m38s.png`, `077_03m58s.png`, `081_04m13s.png`, `082_04m19s.png`, `083_04m20s.png`, `084_04m25s.png`
(todos dentro de `26 - P20190319 _0000 Escenario 16 Disminución de personal solicitado Certeza valor\`)
