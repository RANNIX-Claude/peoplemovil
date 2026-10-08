# Walkthrough visual — Escenario 4 (Pedido Azteca / Futbol América vs Pumas)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\13 - Escenario4\`
Video origen: YouTube `l8LMIzTDLtQ` ("Escenario4", canal WJaJa VideoClips), 767s, 253 capturas (`001_00m00s.png` ... `253_12m43s.png`).
Muestreo: ~45 frames espaciados uniformemente a lo largo de toda la secuencia, más frames adicionales dirigidos donde el contenido cambiaba (catálogo PEP, mensajes de éxito, grid final). Se revisaron en total ~48 imágenes.

Este video graba DOS fuentes en paralelo, alternando entre pestañas:
1. El sistema real "Lobo" en vivo, dominio **integramx-001-site2.btempurl.com/qafreelancev2/** (ambiente QA/staging del sistema AppSCPF), app "RRHH" con menú Inicio / Recursos humanos / Operaciones / Nómina / Catálogos / Seguridad sistema.
2. El archivo Excel **`Scripts de Prueba Freelance.xlsx`** (el mismo que ya se volcó a `ESCENARIOS_PRUEBA_FREELANCE.md`), con una captura de pantalla PEGADA del sistema de PRODUCCIÓN real `apoyo.rh.ocesa.mx` mostrando el resultado esperado/real de un pedido ya existente (Pedido No. 261688) como referencia.

Esto da dos vistas del mismo tipo de pantalla (QA vs Producción) que permiten contrastar.

---

## 1. Flujo observado (orden cronológico de los frames)

### 1.1 Alta de Pedido — pantalla "Pedidos" (`te_pedido.aspx?INS,0`)

Frames: `001`–`045`, `130`–`135`

Formulario **"Información General"** con barra superior "Pedidos" y dos links arriba del panel azul: **"Agregar Detalle"** y **"Agregar Factura"** (visibles incluso antes de guardar — aunque lógicamente solo aplican después de crear el pedido).

Campos capturados, en este orden exacto, todos con asterisco rojo (obligatorios) salvo que se indique:
| Campo | Tipo de control | Notas |
|---|---|---|
| Cliente | combo/autocomplete | Ej. "Coisa Consultores Industrial..." (texto cortado en UI — el script de prueba lo llama "Coisa Consultores Industriales") |
| Id Contacto | dropdown dependiente de Cliente | Opciones vistas: `(Ninguno)`, Gabriel Uribe, **Laura Polanco**, Marisol Marquez Pavón |
| Id sucursal | dropdown | Ej. "CDMX" |
| Unidad de negocio | dropdown | Ej. "Seguridad" (también existen PRG, Producción, Operaciones Inmuebles, Transportes por otros escenarios) |
| Id PEP | dropdown buscable, dependiente de Unidad de Negocio | ver catálogo completo en sección 2 |
| Id evento | dropdown | ver catálogo completo en sección 2 |
| Título | texto libre | se autorellena al elegir evento + PEP (ej. "Jacob Whitesides 2019-----Escenario 4"), pero **es editable manualmente** |
| Lugar de cita | dropdown | se autorellena desde el PEP seleccionado (ej. "Estadio Azteca"); valor inicial "Sin definir" |
| Dirección lugar | textarea readonly-ish | se autorellena ("Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX") |
| Otro | checkbox | sin desarrollar en el video |
| Tipo de movimiento | dropdown | opciones: `(Ninguno)`, **Pedido**, **Servicio interno** (confirma scripts: "únicamente muestra pedido" en escenarios 1-3 ya estaba corregido para escenario 4) |
| Sociedad pagadora | dropdown | se autorellena (ej. "Servicios de Protección Priv...") — el combo de Unidad de Negocio AFECTA la sociedad pagadora propuesta |
| Permitir cancelar confirmaciones | dropdown | NO / (SI, no visto) |
| Responsable | dropdown | Ej. "Israel Benavid Solis Carrera" — catálogo `tc_responsables` |
| Agregar contacto | checkbox | al lado de "Id Contacto", para dar de alta contacto nuevo inline |

Botones al fondo del formulario: **Confirmar** / **Regresar** (edición) — en el alta inicial solo hay scroll, el botón de guardar está fuera del rango muestreado pero el patrón es consistente con "Confirmar/Cancelar" visto en el resto del sistema.

### 1.2 Side-trip: catálogo de PEP / Presupuestos (`tc_pepww.aspx`, `tc_pep.aspx?UPD,<id>`)

Frames: `034`–`096`

El usuario abre el catálogo **"Presupuestos"** (menú Catálogos → Pedidos → ... ; URL real `tc_pepww.aspx`) para localizar/editar el PEP del Estadio Azteca, porque no existía pre-cargado con el lugar correcto.

**Grid "Presupuestos"** — columnas: `Id PEP` | `Título` | `PeP|Descripción` | `Unidad de negocio` | `Lugar` | `Vigente` (checkbox) | `Año` | `Tercero`. Encabezado con botones **`+`** (nuevo), **XLS**, **PDF**, **"Selecciona columnas"**, filtro **"Buscar en [combo de columna] valor [Comienza con/...] [texto]"**. Paginado real: "Página 1 de 507" (507 páginas de PEPs — catálogo histórico enorme heredado de OCESA). Un filtro vacío devuelve el mensaje **"No se encontraron registros"**.

**Formulario de edición de un PEP** (`tc_pep.aspx?UPD,20817`) — panel "Información General":
| Campo | Valor visto |
|---|---|
| Título | "Seguridad Estadio Azteca" |
| TC_Pep Pep (código) | "LT-AZ-2018-01-01N085LT-A" |
| Categoria | dropdown, valor "PEP" |
| Lugar | dropdown, **"Estadio Azteca"** — catálogo de lugares/sitios físicos, separado de "Lugar de cita" del pedido |
| Vigente | checkbox (marcado) |
| PeP\|Descripción | campo **calculado/readonly**, concatena código + título: "LT-AZ-2018-01-01N085LT-A Seguridad Estadio Azteca" |
| Unidad de negocio | dropdown — aquí vale **"Operaciones Inmuebles"**, DIFERENTE a la UN "Seguridad" del pedido que lo usa. Confirma que el PEP tiene su propia UN "dueña" del inmueble, desacoplada de la UN que hace el pedido |
| Año | dropdown, "2018" |
| Presupuesto | numérico, "0.00" |
| Tercero | dropdown NO/SI, "NO" |

Botones: **Confirmar** / **Cancelar**.

### 1.3 Alta de Detalle de pedido — pantalla "Detalles de pedido" (`wp_pedidodetalle.aspx?<idPedido>`)

Frames: `141`–`253` (el núcleo del escenario — se repite ~10 veces, una por producto)

Tras **"Pulsar Aceptar"** el pedido queda creado con folio **1049**, título "Jacob Whitesides 2019-----Escenario 4" (el sistema reutiliza el nombre del evento "Jacob Whitesides 2019" aunque el escenario de prueba es sobre "Futbol América vs Pumas" — aparente error de captura del probador, no del sistema). La pantalla de detalle muestra dos zonas:

**(A) Zona superior — "Movimientos detalles pedido" / grid resultado**, visible solo después de agregar al menos un detalle. Columnas: **Bloque** (vacío en todas las filas de este escenario — no se usó agrupación por bloque) | **Productos** | columna de fecha (ej. "22/08") con subencabezado de hora ("06:00"). Cada fila: `{Producto}-{Código} | {Título del pedido}---Detalle` seguido del valor **`{Cantidad} - T {Turnos}`** (ej. "Anfitrion In-IN | Jacob Whitesides 2019-----Escenario 4---Detalle" → "40 - T 1.00"). Filas de pie: **"Total Solicitados"** y **"Presupuesto por día"**.

**(B) Zona inferior — formulario "Detalles"** (repetido para cada alta), con dos columnas:

Columna izquierda:
| Campo | Notas |
|---|---|
| Estatus | readonly, **"Vigente"** (no "Normal" ni "borrador"/"liberado" del enum nuevo — ver sección 3) |
| Tipo personal | readonly tras la primera alta, **"Operativo"** |
| Título | editable, prellenado con el título del pedido |
| Producto | dropdown — catálogo completo en sección 2 |
| Lugar de Cita | dropdown, prellenado "Estadio Azteca" |
| Dirección cita | textarea, prellenada |
| Otro | checkbox |
| Indicaciones especiales | textarea libre |
| Bloque por producto | dropdown, **"Ninguno"** por default (o número de bloque nuevo) |
| Facturable | dropdown NO/SI, **"NO"** por default (confirma bug ya anotado en Escenario 1/4 del texto: "Factura está determinado como NO por default") |

Columna derecha:
| Campo | Notas |
|---|---|
| Evento Práctica | checkbox, sin marcar |
| Cantidad | numérico |
| Turnos | numérico, con **etiqueta dinámica a la derecha**: p.ej. "1.00 **8 Horas por turno**" — SÍ se muestra la info de horas por turno (contradice la observación de bug en Escenario 1 "en ningún momento se muestra esa información"; en Escenario 4 el campo de ayuda aparece correctamente) |
| Fecha cita | date-picker (calendario desplegable tipo mini-mes) + dos combos `hh`/`mm` — ej. 22/08/2019 06:00 |
| Fecha liberación | mismo patrón fecha+hora, vacío por default |
| Fecha final cita | mismo patrón fecha+hora — **se autocalcula** a partir de Fecha cita + horas del turno del producto (ej. inicio 06:00 → fin 14:00 para turno de 8 horas) |
| Presentación por producto | dropdown — valor visto "Pantalón Negro de Vestir, Pl..." (catálogo `tc_presentaciones_producto`) |
| Completar con similares | dropdown NO/SI, **"NO"** (seleccionado así en todo el escenario, a diferencia del Escenario 1 que usó "SI") |
| Fase del evento | dropdown, default **"No aplica"** |
| Permitir cancelar | dropdown NO/SI, **"NO"** |

Botones: **"Agregar Detalle"** (azul, primario) / **"Cancelar"**.

**Mensaje de confirmación**: tras pulsar "Agregar Detalle", aparece un **toast/banner naranja** en la esquina superior derecha, debajo del menú de usuario, con ícono de alerta (!) y texto:
> **"Registro Agregado Correctamente"**

(Mismo patrón de notificación en runtime; no se capturó ningún mensaje de error/validación en los frames muestreados — el video no reproduce el caso de "fecha de liberación posterior a fecha de cita" que el script de prueba espera validar con alerta.)

### 1.4 Grid final de Pedidos (listado) — pantalla `te_pedidodoww.aspx`

Frame `130`. Columnas del listado: **Id** | **Título** | **Estatus** | **Unid.Neg.** | **Sucursal** | **lugar** | **Responsable** | **Complejidad** | **T.Mov** | **PeP\|Descripción**. El pedido recién creado aparece como fila **1049** "Jacob Whitesides 2019-----Escenario 4", Estatus **"Vigente"**, Unid.Neg. "Seguridad", Sucursal "CDMX", lugar "Estadio Azteca", Responsable "Israel Benavid Solis Carrera", T.Mov "Pedido". Filas vecinas muestran otros pedidos reales con Estatus **"Cancelado"** y **"Procesado"**, y con **Complejidad** rellena solo quando aplica (ej. "Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares", "No aplica").

### 1.5 Captura de referencia de Producción (pegada en el Excel)

Frames `147`, `158`, `169`, `175`, `180`, `186`, `203`, `237` (misma imagen estática revisada en varios momentos). Es un recorte de `apoyo.rh.ocesa.mx` (sistema real de producción, NO el QA) para el **Pedido No. 261688**:

```
[ Editar Pedido ]      [ Liberar Pedido ]      [ Cancelar Pedido ]
Registro Agregado                                    [Regresar]
Pedido No. 261688
Título: Seguridad Futbol America Pumas Semifinal Clausura 2018 PRUEBA   Status: Normal
Evento: Futbol America Pumas Semifinal Clausura 2018                    Sucursal: México
Lugar de Cita: Estadio Azteca                                           Unidad de Negocio: Seguridad

Personal Operativo                                   01/02
Productos                                             16:00 p.m.
Anfitrion - IN | Futbol America PRUEBA                 40 - T 1
Anfitrion Incluyente - IN | Futbol America PRUEBA      40 - T 1
Control de Accesos - FE | Futbol America PRUEBA        30 - T 1
Control de Accesos - MA | Futbol America PRUEBA        30 - T 1
Local Crew - FE | Futbol America PRUEBA                40 - T 1
Local Crew - MA | Futbol America PRUEBA               100 - T 1
Seguridad - FE | Futbol America PRUEBA                 50 - T 1
Seguridad - MA | Futbol America PRUEBA                 70 - T 1
Seguridad Coordinador - MA | Futbol America PRUEBA      1 - T 1
Seguridad Supervisor - IN | Futbol America PRUEBA       7 - T 1
Total Solicitados                                      408/0
Presupuesto por Día                                $119,700.00
[ Agregar Detalle ]
```

Esto es la **prueba definitiva del layout de matriz "Fecha × Producto"** pedida en la tarea: una tabla donde las FILAS son productos/puestos y las COLUMNAS son fechas de cita (cada fecha distinta agrega una columna nueva), con el valor de celda `Cantidad - T Turnos`. El pie de tabla totaliza personal solicitado y presupuesto por día. Esto coincide con el resultado final logrado en QA (folio 1049): mismos 10 productos, mismas cantidades (ver 1.3-A), total final **408** y presupuesto **$119,400.00** (vs. $119,700.00 de producción — diferencia de $300, probablemente por variación de tarifas entre el PEP de pruebas y el de producción).

### 1.6 Prueba de rol/portal (`wp_pedidodetalle.aspx?1049` en incógnito)

Frames `249`–`253`. El probador abre una ventana de incógnito y entra como usuario con rol **"Operacion"** (no "Administrator") al mismo detalle de pedido 1049. El menú superior se reduce a **Inicio / Operaciones / Salir** (desaparecen Recursos humanos, Nómina, Catálogos, Seguridad sistema) — confirma **control de acceso por rol a nivel de menú**. La pantalla de detalle y el grid de resultados son los mismos, con permiso de lectura/alta de detalles.

---

## 2. Catálogos (valores de dropdown) capturados

**Producto** (orden alfabético visto en el combo, truncado a lo que aparece en pantalla):
`Ninguno`, `-IN`, `Agente de servicio-MA`, `Anfitrion In-IN`, `Anfitrion Incluyente-FE`, `Anfitrion Incluyente-MA`, `Anfitrion Incluyente-IN`, `Anfitrion-IN-IN`, `Apoyo Control de Accesos-MA`, `Apoyo Local Crew-IN`, `Apoyo Retencion de Talento-IN`, `Apoyo Seguridad-MA`, `Asistente Administrativo-IN`, `Asistente Operativo-IN`, `Control de Accesos-MA`, `Control de Accesos-FE`, `Control de Accesos-IN`, `Control de Accesos 4-MA`, `Control de Accesos 4-FE`, `Instructor de Capacitación-IN`, ... (sigue, catálogo largo). El sufijo `-IN/-FE/-MA` aparenta ser un código de variante/turno del producto (posible Inicial/Fin de Evento/Montaje, o similar) — no está documentado en el texto QA y merece aclaración con el cliente.

**Id PEP** (catálogo completo visto en los combos, para Unidad de Negocio = Seguridad):
`(Ninguno)`, `ABC` (dos entradas distintas con el mismo nombre), `Ejemplo Pep`, `Alejandro Sanz 2 EL-HR-2019-11-07N085LP-A`, `Alejandro Sanz EL-HR-2019-11-07N085LP-A`, `EL-AT-2016-11-11T214EL-A Sasha Benny y Erick`, `LT-AZ-2018-01-01N085LT-A LT-AZ-2018-01-01N085LT-A` (el del Estadio Azteca), `N/085-PD-2015-03-09 Preventa Formula 1`, `PT-RT-2015-09-04T009PT-A Sasha Benny y Erick Queretaro`, `RACPEP RACTIPO`, `Seguridad ABC`, `Seguridad Z-PEP-Temporal`.

**Id evento**: `(Ninguno)`, `Feria del Juguete 2017`, `Futbol América vs Pumas`, `Jacob Whitesides 2019`, `Tributo a Michael Jackson`.

**Tipo de movimiento**: `(Ninguno)`, `Pedido`, `Servicio interno`.

**Id Contacto** (para cliente Coisa Consultores Industriales): `(Ninguno)`, `Gabriel Uribe`, `Laura Polanco`, `Marisol Marquez Pavón`.

**Completar con similares**, **Facturable**, **Permitir cancelar(confirmaciones)**, **Tercero** (en PEP): todos dropdowns binarios `NO` / `SI` (NO por default en todos).

**Fase del evento**: al menos `No aplica` (default para este tipo de pedido/UN).

---

## 3. Contraste con `te_pedidos_detalle` y `te_pedidos` del schema (`reset_database.sql`)

El schema ya cubre, correctamente, casi todos los campos vistos: `status_detalle` (`estado_detalle_pedido_enum`: borrador/liberado/cancelado/procesado/facturado), `fecha_cita`, `hora_cita_inicio/fin`, `fecha_liberacion`, `bloque_num`, `id_tipo_personal`, `producto_id`, `turnos`, `cantidad_reservados*`, `presentacion_id`, `completar_productos_similares`, `facturable`, `permitir_cancelar_confirmaciones`, `fase_evento_str`, `indicaciones_especiales`, `id_lugar_entrega`, `direccion_entrega`.

### Hallazgos NUEVOS / discrepancias a revisar:

1. **Valores de estatus de Pedido no coinciden con el enum.** El schema usa `te_pedidos.status text` libre (no enum) con default `'borrador'`, y el flujo de liberación lo mueve a `'liberado'` (ver `tg_... PRC_LiberarPedido`). Pero en la UI real/QA el campo **"Estatus del Pedido"** muestra literalmente **"Vigente"**, **"Cancelado"**, **"Procesado"** — y en producción se vio también **"Normal"**. Ninguno de estos coincide con `'borrador'/'liberado'`. Sugerencia: documentar el mapeo Lobo→PeopleMovil (p.ej. Normal/Vigente ≈ borrador o liberado según si tiene detalles liberados; Procesado ≈ facturado/cerrado). Esto ya estaba anotado como bug ("El estatus del pedido aparece como: NINGUNO") en el texto QA del Escenario 1, así que el propio Lobo tenía inconsistencia aquí — vale la pena no copiar el string literal sino el concepto.

2. **El PEP tiene su propia `Unidad de negocio`, distinta de la del Pedido.** El formulario `tc_pep.aspx` trae un combo "Unidad de negocio" (en el ejemplo, "Operaciones Inmuebles" para un PEP usado por un pedido de UN "Seguridad"). El schema actual sólo tiene `tc_partidas_presupuestales` (PEP) sin verificar si ya tiene su propio `unidad_negocio_id` — **confirmar que exista esa FK en el catálogo de PEP**, independiente de `te_pedidos.unidad_negocio_id`.

3. **Campo "Lugar" en el PEP vs. "Lugar de cita" en el Pedido/Detalle son conceptos relacionados pero editados en pantallas distintas.** El PEP fija el inmueble "dueño" (p.ej. "Estadio Azteca"); el Pedido y cada Detalle heredan y pueden sobre-escribir una `Dirección` libre. Confirma el diseño ya existente de `id_lugar_entrega`/`direccion_entrega` en `te_pedidos_detalle`, pero sugiere que `tc_partidas_presupuestales` (PEP) debería tener su propio `sitio_id` FK hacia `cat_sitios`, del cual el pedido copia el default.

4. **Etiqueta dinámica "N Horas por turno"** junto al campo Turnos del detalle — es un hint de UI calculado desde el producto/puesto seleccionado (coincide con `tc_turnos`/`cat_puestos`), no es un campo de BD nuevo, pero confirma que el frontend debe mostrar esta ayuda (actualmente puede no estar implementada en PeopleMovil).

5. **Autocálculo de "Fecha final cita"** a partir de Fecha cita + duración del turno del producto — comportamiento a replicar en el frontend/validación (no solo almacenar `hora_cita_fin`, sino calcularla por default).

6. **"Total Solicitados" y "Presupuesto por día" como agregados de cabecera del pedido**, calculados sobre todos los detalles vigentes de una fecha/columna. Confirma la necesidad de una vista o cálculo agregado por pedido+fecha (posible vista materializada o cálculo on-the-fly), no solo campos por detalle. Se observó un posible bug de refresco: justo después de un alta, el total mostrado reflejó transitoriamente solo la cantidad del último renglón agregado (70) en vez del acumulado real (408), que sí apareció correcto tras recarga de página — vale la pena asegurarse que el cálculo en PeopleMovil sea siempre server-side/recalculado y no dependa de un estado de UI parcial.

7. **Columna "Bloque" vacía cuando no se usa `Bloque por producto`.** Confirma que `bloque_num` es verdaderamente opcional (NULL) para personal Operativo con productos distintos en la misma fecha — a diferencia de Escenario 2/3 (Staff) donde cada producto exige bloque nuevo. Este Escenario 4 es justamente el caso "Varios Detalles Mismo Día" sin bloque: 10 filas de detalle, mismo pedido, misma fecha de cita, mismo lugar, SIN bloque, cada una como producto independiente — confirma que la matriz "Fecha × Producto" no depende de bloques para mostrarse agrupada por columna de fecha.

8. **Control de acceso por rol a nivel de menú** confirmado visualmente: el rol "Operacion" ve un menú reducido (Inicio/Operaciones/Salir) vs. "Administrator" (menú completo con RRHH, Nómina, Catálogos, Seguridad sistema). Esto es coherente con el sistema de roles/permisos que PeopleMovil ya deba tener, pero confirma que el menú de navegación debe ser también sensible al rol, no solo las acciones.

9. **Catálogo de Producto con sufijos `-IN/-FE/-MA`** (Inicial/Fin de Evento/Montaje u otra convención) no documentado en el texto QA — recomendamos aclarar con el cliente el significado exacto de estos sufijos antes de diseñar `tc_productos`, ya que claramente son variantes del mismo "producto base" (ej. "Anfitrion") multiplicadas por fase/momento.

10. **Mensaje de éxito estándar**: toast naranja "Registro Agregado Correctamente" tras cada alta de detalle — útil para especificar el copy exacto de confirmaciones en PeopleMovil.

No se observó ningún mensaje de error/validación (p. ej. el de "fecha de liberación no puede ser posterior a la fecha de cita" que el texto QA referencia) en los frames muestreados de este video — el flujo grabado fue el "happy path" completo del escenario.
