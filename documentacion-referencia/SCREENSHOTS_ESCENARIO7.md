# Escenario 7 — Comprobar fecha y hora de liberación (walkthrough visual)

Fuente: capturas de video QA 2019, carpeta
`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\09 - Escenario7\`
(68 PNGs, `001_00m00s.png` … `068_03m38s.png`, video YouTube `0ATDo1veP2c`, duración 231s).
Muestreo visto: ~25 frames distribuidos uniformemente a lo largo de toda la secuencia.

Sistema: GeneXus "Lobo"/AppSCPF, módulo **RRHH**, menú **Operaciones**. Dos roles distintos
se usan en el mismo recorrido: **Operacion** (staffing, crea/libera el pedido) y **Freelance**
(el empleado, confirma el evento). También aparece brevemente el rol **Administrator**
(catálogos Nómina → Plazas empleados) para verificar el alta del freelance de prueba.

---

## 1. Pantalla "Pedidos" — Información General (crear pedido)

Frames: `004_00m13s.png`–`028_01m21s.png`.

Formulario de cabecera de pedido, sección **"Información General"** (banda azul), con dos
enlaces arriba del formulario: **"Agregar Detalle"** y **"Agregar Factura"**.

Campos (orden visual, todos excepto "Otro" y "Dirección lugar" marcados con `*` obligatorio):

| Campo | Tipo de control | Notas |
|---|---|---|
| Cliente | combo buscable | lista muy larga de razones sociales (ej. "Ocesa Presenta, S.A. de C.V.", "OCESA Promotora, S. A. de C.V.") — autocomplete tipo GeneXus (escribe y filtra) |
| Id Contacto | combo | depende del Cliente elegido; lista de nombres de personas de contacto del cliente (ej. "Lucas Vázquez", "Diana Weber") + checkbox **"Agregar contacto"** al lado para dar de alta uno nuevo |
| Id sucursal | combo | ej. "CDMX" |
| Unidad de negocio | combo | catálogo largo visto: Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, Operaciones Inmuebles, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, PRG, PRG_Complejidad, Produccion, Publicidad, Recursos Humanos Operaciones, Renta de Equipos, **RRHH**, **Seguridad**, Transportes (lista alfabética, scroll). Para este escenario se elige **"Seguridad"**. |
| Id PEP | combo | lista de códigos de proyecto/PEP, ej. "EL-AT-2016-11-11T214EL-A Sasha Benny y Erick", "LT-AZ-2018-01-01N085LT-A…", "Seguridad ABC", "Seguridad Z-PEP-Temporal" |
| Id evento | combo | depende del PEP elegido; opciones vistas: "(Ninguno)", "Feria del Juguete 2017", "Futbol América vs Pumas", "Jacob Whitesides 2019", "Tributo a Michael Jackson" |
| Título | texto libre | se autocompleta con el nombre del evento al elegirlo, pero es editable; valor final usado: `Jacob Whitesides 2019---Escenario7` |
| Lugar de cita | combo | ej. "Sin definir" → "Teatro Telcel" |
| Dirección lugar | textarea | ej. "Lago Zurich 245" |
| Otro | checkbox | sin marcar |
| Tipo de movimiento | combo (sólo lectura tras Unidad de negocio) | valor "Pedido" |
| Sociedad pagadora | combo | ej. "Operadora de Centros de Es[pectáculos]…" |
| Permitir cancelar confirmaciones | combo Sí/No | valor usado: **"NO"** |
| Responsable | combo | lista de empleados internos; usado "Jose Edgar Barrera Diaz" |

Botones al pie: **"Confirmar"** / **"Regresar"**.

Al confirmar, el sistema asigna folio de pedido (visto **"PEDIDO No.: 1053"**).

## 2. Listado "Pedidos" (`te_pedidoww.aspx`)

Frame: `028_01m21s.png`.

Grid con columnas: Id, Título, Estatus, Unid. Neg., Sucursal, lugar, Responsable,
Complejidad, T.Mov, PeP | Descripción. Barra superior: exportar a Excel/PDF,
"Selecciona columnas", filtro "Buscar en [combo de campo] valor […]".
Valores de **Estatus** observados en la lista: `Vigente`, `Liberado`, `Cancelado`,
`Procesado` — se muestran como texto plano (no se alcanza a confirmar en los frames
muestreados un color/ícono tipo "semáforo" distinto por fila; puede requerir revisar el
video completo en ese tramo si se necesita el detalle exacto del semáforo de colores).

## 3. Pantalla "Detalles de pedido" (`wp_pedidodetalle.aspx?1053`)

Frames: `031_01m30s.png`–`048_02m13s.png`.

Encabezado con folio **"PEDIDO No.: 1053"**, acciones: **"Editar pedido"**, **"Liberar
Pedido"**, **"Cancelar Pedido"**, botón **"Regresar"**.
Sección **"Matriz de Puestos"** (inicialmente vacía; mensaje de aviso naranja visto al
entrar sin detalles: **"No existe información para formar Matriz"**).
Sección **"Movimientos detalles pedido"**, tab **"Detalles"**, con el formulario de alta de
un detalle de pedido:

| Campo | Tipo | Notas |
|---|---|---|
| Estatus | sólo lectura | "Vigente" |
| Evento Práctica | checkbox | sin marcar |
| Tipo personal | sólo lectura | "Operativo" |
| Título | texto | heredado del pedido, editable |
| Producto | combo | ej. "Seguridad-IN" |
| Lugar de Cita | combo | "Teatro Telcel" |
| Dirección cita | textarea | "Lago Zurich 245" |
| Otro | checkbox | — |
| Indicaciones especiales | textarea | — |
| Bloque por producto | combo | "Ninguno" |
| Facturable | combo Sí/No | "NO" |
| **Cantidad** | numérico | 1 |
| **Turnos** | numérico, sólo lectura calculado | "1.00" con leyenda **"8 Horas por turno"** al lado |
| **Fecha cita** `*` | datepicker (dd/mm/aaaa) + 2 combos hora/minuto | obligatorio; se usó **22/08/2019 06:00** (posterior al día en curso, tal como pide el escenario) |
| **Fecha liberación** | datepicker + hora/minuto | al abrir el calendario, por default resalta/propone **"Hoy"** (19/08/2019); se fijó manualmente en **19/08/2019 12:30** |
| **Fecha final cita** | datepicker + hora/minuto | se autocalcula a partir de Fecha cita + duración de turno (8h): **22/08/2019 14:00** |
| Presentación por producto | combo | tras elegir Producto, se autocompleta con el uniforme del catálogo: **"Pantalón Negro de Vestir, Playera Azul y Chamarra Azul"** |
| Completar con similares | combo Sí/No | "NO" |
| Fase del evento | combo | "No aplica" |
| Permitir cancelar | combo Sí/No | "NO" |

Botones: **"Agregar Detalle"** / **"Cancelar"**.

El datepicker de GeneXus muestra mes completo en español ("Agosto, 2019"), cabecera de
navegación `« ‹ Hoy › »`, columnas de días `Dom Lun Mar Mie Jue Vie Sab`.

Al guardar el detalle aparece notificación naranja superior derecha:
**"Registro Agregado Correctamente"**.

### Matriz de Puestos (tras agregar el detalle)

Tabla con columnas **Bloque | Productos | 22/08 | 06:00**, fila de producto
`Seguridad-IN | Jacob Whitesides 2019---Escenario7` con cantidad **"1 - T 1.0"**, y
totales: **"Total Solicitados: 1"**, **"Presupuesto por día: $300.00"**.

## 4. Login y módulo Freelance ("Confirmación de eventos")

Frames: `049_02m27s.png`–`068_03m38s.png`.

Pantalla de login genérica (`inicio.aspx`), marca **"RRHH"**, fondo foto de concierto.
Campos: **Usuario** (número de empleado, ej. `65837`), **Contraseña**, botón
**"Ingresar"**. Mensaje de validación visto bajo el formulario cuando falta sesión:
**"El usuario debe estar autenticado."**

Tras entrar como Freelance (empleado "Lucas Santos Leal"), el menú superior muestra:
**Comunicados generales | Calendario de eventos | Saldos | Confirmación de eventos |
Aclaraciones | Salir**, y a la derecha el nombre+rol ("Lucas Santos Leal Santos — Freelance").

Pantalla **"Confirmación de eventos"**: dos paneles lado a lado,
**"Eventos por confirmar"** y **"Eventos confirmados"**, ambos vacíos mientras la hora
actual es anterior a la Fecha liberación (12:22 pm, 12:26 pm, 12:36 pm, 12:37 pm — todas
antes de las 12:30 fijadas o inmediatamente después pero sin refrescar).

**Validación clave del escenario** — a las 12:38 pm (después de las 12:30 programadas),
al recargar/entrar de nuevo a "Confirmación de eventos", aparece en el panel izquierdo
la tarjeta del evento:

> **"SEGURIDAD--Jacob Whitesides 2019 22/08/19 06:00 (2407)"**

Esto confirma visualmente que el pedido se liberó exactamente a la hora programada en
"Fecha liberación" (no antes). Al desplegar la tarjeta se ven los detalles:

| Campo | Valor visto |
|---|---|
| Evento | Jacob Whitesides 2019 |
| Puesto | Seguridad |
| Fecha | 22/08/19 06:00 a 22/08/19 14:00 |
| Turnos | 1.00 |
| Lugar | Lago Zurich 245 |
| Dirección | Lago Zurich 245 |
| Uniforme | Pantalón Negro de Vestir, Playera Azul y Chamarra Azul |
| Indicaciones Especiales | (vacío) |

Botón **"Confirmar"** (azul) al pie de la tarjeta. El video termina (frame 068, 03m38s)
sin mostrar el clic de confirmación ni el movimiento de la tarjeta al panel "Eventos
confirmados" — esa parte no quedó capturada en los frames disponibles.

## 5. Verificación auxiliar del freelance (rol Administrator)

Frames: `055_02m54s.png`–`063_03m27s.png` (en pestaña de incógnito paralela).

Mientras se espera la hora de liberación, el probador entra como **Administrator** a
**Nómina → Plazas empleados** (listado `te_plasww.aspx`) y abre el registro del empleado
`65837` (Lucas Santos Leal) para corroborar su puesto antes de la prueba:

Grid "Plazas empleados": columnas Id empleado, Nombre, Sexo, Certeza, Estatus, Pago,
Id puesto, Puesto, Pago default, Unidad negocio, Inicio, Vigente.
Detalle de la plaza (`te_plasww.aspx?UPD=6521`):

| Campo | Valor |
|---|---|
| Id Empleado | 65837 |
| Empleado | Lucas Santos Leal Santos-- |
| Sexo | Masculino |
| Certeza | 0.90 |
| Estatus | Activo |
| Pago | 300.00 |
| Puesto | Seguridad \|\| Seguridad |
| Pago default | 300.00 |
| Regla Asistencia | Regla de asistencia 1 |
| Min.Ant.Entrar / Min.Ant.Salir / Min.Desp.Entrar | 3 / 15 / 15 |
| Id Und.Neg. / Unidad de negocio | 1 / Seguridad |
| ID sociedad / Sociedad | 1 / Servicios de Protección Privada Lobo, SA de CV |
| % Certeza Inicial | 0.90 |
| Inicio | 21/05/2019 00:00:00 |
| Fin | (vacío) |
| Principal | Sí |
| Descripción-Unidad Negocio | Seguridad \|\| Seguridad |

Botones **"Confirmar"** / **"Cancelar"**.

---

## Nuevas reglas de negocio / campos NO documentados antes en ESCENARIOS_PRUEBA_FREELANCE.md

1. **"Fecha final cita" es un campo autocalculado y visible** (Fecha cita + duración del
   turno, 8h por defecto), distinto de "Fecha cita" y de "Fecha liberación" — el texto no
   menciona este tercer campo de fecha explícitamente.
2. **"Fecha liberación" es un datetime independiente** con su propio date+hora+minuto
   picker (no deriva de "Fecha cita"); al abrir el calendario propone "Hoy" por default,
   confirmando que normalmente se libera el mismo día que se crea el detalle.
3. El combo **"Turnos"** y el campo numérico asociado muestran la leyenda fija
   **"8 Horas por turno"** — parámetro de negocio visible en UI (probablemente
   configurable, relevante para cómo PeopleMovil calcule `fecha_cita`/`fecha vigencia`).
4. **"Presentación por producto"** (uniforme) se autocompleta a partir del catálogo de
   "Producto" elegido — confirma que el uniforme es un atributo del catálogo de producto,
   no un campo libre por detalle (aunque aquí aparece editable como combo).
5. Mensaje de sistema **"No existe información para formar Matriz"** cuando se entra a
   Detalles de pedido sin haber agregado ningún detalle todavía — validación/mensaje de
   UI no capturado en el texto del escenario.
6. Mensaje de éxito al guardar un detalle: **"Registro Agregado Correctamente"**
   (notificación toast naranja, esquina superior derecha).
7. En login, mensaje de validación de sesión: **"El usuario debe estar autenticado."**
8. La tarjeta de evento en "Confirmación de eventos" incluye un **número de folio interno
   entre paréntesis** junto al título, ej. `(2407)` — distinto del número de pedido (1053)
   y del detalle; probablemente el id de la fila de `te_pedidos_detalle` o de una tabla de
   reservación/asignación. Relevante para mapear al futuro modelo de PeopleMovil
   (`te_pedidos_detalle.id` vs. un id de "reservación").
9. El campo **"Permitir cancelar confirmaciones"** (a nivel pedido) y **"Permitir
   cancelar"** (a nivel detalle) son dos combos Sí/No separados — confirma que existen
   dos granularidades distintas de la regla "permitir cancelar" (pedido vs. detalle).
10. No se pudo confirmar visualmente en los frames muestreados el "semáforo de colores"
    de los detalles de pedido que menciona el texto del escenario (el listado de Pedidos
    sólo mostró el texto de Estatus sin color aparente); recomendable revisar el video
    completo fotograma a fotograma en el tramo 01:21–01:30 y después de liberar (03:30+)
    si se necesita el detalle exacto de esa validación.
