# Escenario 15 — Cancelación de asignación forzada (walkthrough de capturas de pantalla)

Fuente: 51 capturas PNG extraídas del video `P20190319_0000 Escenario 15 Cancelación de asignación forzada`
(YouTube id `8kuFYbczd9s`, 194s, canal "WJaJa VideoClips"), ubicadas en:
`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\24 - P20190319_0000 Escenario 15 Cancelación de asignación forzada\`

Muestreo revisado (escalonado a lo largo de todo el video, ~25 de 51 frames): 001, 004, 007, 008, 009, 010, 011, 012, 013, 016, 017, 018, 019, 022, 025, 028, 031, 032, 033, 034, 035, 036, 037, 038, 039, 040, 041, 042, 043, 044, 045, 046, 047, 048, 049, 050, 051.

Este video cubre el flujo completo del Escenario 15 tal como está descrito en `ESCENARIOS_PRUEBA_FREELANCE.md`: crear un pedido de Seguridad que permita cancelación, crear un detalle de pedido que permita cancelación, con fecha de cita >72h; hacer una asignación forzada a un empleado; liberar el pedido; entrar al portal freelance con ese empleado; intentar cancelar el evento confirmado.

---

## 1. Pantalla "Pedidos" (listado) — admin/backoffice

Captura: `001_00m00s.png`, `010_00m25s.png`, `019_01m10s.png`

- Navbar superior: `RRHH | ... Recursos humanos | Operaciones | Nómina | Catálogos | Seguridad sistema | Variables | Salir` (ícono de usuario a la derecha).
- Toolbar de grid: botón `+` (nuevo), `xls`, `pdf`, `Selecciona columnas ▾`, filtro `Buscar en [Id Pedido ▾] valor [ ] ◁▷`.
- Columnas de la grilla: `Id Pedido`, `Título`, `Estatus`, `Unidad de negocio`, `Sucursal`, `lugar`, `Responsable`. Columna de iconos de acción a la izquierda (lupa, lápiz, X) por fila.
- Valores de `Estatus` vistos en la grilla: `Vigente`, `Liberado`.
- Footer: `OCESA - copyright 2018`.
- Se ve la lista de pedidos de escenarios anteriores (766–776, "Entrega 03 Escenario NN") antes de crear el pedido 777 de este escenario; luego aparece la fila nueva `777 | Entrega 03 Escenario 15 | Vigente | Seguridad | CDMX | Estadio Azteca | Israel Benavid Solis Carrera`.

## 2. Alta de Pedido — formulario "Información General"

Captura: `004_00m13s.png`, `007_00m20s.png`, `008_00m22s.png`, `009_00m24s.png`, `010...`, `011_00m28s.png`, `012_00m38s.png`

Campos del formulario (en orden), con `*` = obligatorio marcado en rojo por el sistema:
- `Cliente*` — combo. Valor usado: `OCESA Promotora, S. A. de C.V.`
- `Contacto` — combo dependiente de Cliente. Valor usado: `Gutierrez Leal Miguel`.
- Botón `Agregar Contacto` (azul, a la derecha del bloque Cliente/Contacto).
- `Sucursal*` — combo. Valor usado: `CDMX`.
- `Unidad de negocio*` — combo. Catálogo completo visible en el dropdown (orden alfabético, cortado por scroll — puede haber opciones arriba de "Modelos y Edecanes"):
  `Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, Operaciones Inmuebles, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, PRG, PRG_Complejidad, Produccion, Publicidad, Recursos Humanos Operaciones, Renta de Equipos, RRHH, Seguridad` (seleccionada, resaltada en azul).
- `PEP*` — combo, dependiente de UN+Sucursal. Opciones vistas para Seguridad/CDMX:
  `(Ninguno)`, `LT-AZ-2018-01-01N085LT-A | LT-AZ-2018-01-01N085LT-A`, `N/085-PD-2015-03-09 | Preventa Formula 1`. Se seleccionó el primero (Estadio Azteca).
- `Evento*` — combo, dependiente del PEP. Valor usado: `Entrega 03`.
- `Título` — input libre. Valor capturado: `Entrega 03 Escenario 15`.
- `Lugar de cita*` — combo. Autocompletado a `Estadio Azteca` al elegir el PEP.
- `Dirección lugar de cita` — label de solo lectura, autocompleta: `Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX`.
- `Otro` — checkbox (sin marcar).
- `Tipo de movimiento` — combo. Valor usado: `Servicio interno` (coherente con otros escenarios, donde el catálogo solo expone "Pedido" / "Servicio Interno").
- `Tipo de complejidad` — combo (visible vacío antes de elegir UN; para Seguridad no se usó).
- `Duración del evento (Días de show)` — input numérico (default `0`, visible solo antes de elegir UN; desaparece/no aplica para Seguridad).
- `Sociedad pagadora` — label/input semi-automático. **Antes de elegir la UN** mostraba por default `Car Sport Racing SA de CV` (frame 004) — confirma el bug ya anotado en Escenario 1 de la MD ("Antes de seleccionar la UN la sociedad pagadora está por default con ID 10/otro valor erróneo"). **Después de elegir UN Seguridad** cambia correctamente a `Servicios de Protección Privada Lobo, S.A. de C.V.`
- `Permitir cancelar confirmaciones` — combo **NO/SI**, a nivel de PEDIDO (no detalle). Default `NO`. Se cambió explícitamente a **`SI`** en el frame `018_01m08s.png` justo antes de guardar — es el paso "Crear un pedido de seguridad que permita la cancelación" del script.
- `Responsable*` — combo. Valor usado: `Israel Benavid Solis Carrera`.
- Botones al pie del formulario: `Guardar`, `Regresar`, y tras guardar aparece además `Cancelar pedido`.

Tras guardar, la pantalla de detalle de pedido (cabecera) muestra además la barra de acciones: `Editar pedido | Liberar Pedido | Cancelar Pedido | Regresar`, y el título `PEDIDO No.: 777`.

## 3. Detalle de pedido — pestaña "Detalles" (alta de línea)

Captura: `022_01m18s.png`, `025_01m24s.png`, `028_01m31s.png`, `031_01m37s.png`

- `Producto` — combo de puestos, dependiente de la UN. Catálogo visible para Seguridad (scroll parcial):
  `Apoyo Retencion de Talento-IN, Apoyo Seguridad-MA, Asistente Administrativo-IN, Asistente Operativo-IN, Control de Accesos-MA, Control de Accesos-FE, Control de Accesos-IN, Control de Accesos 4-MA, Control de Accesos 4-FE, Instructor de Capacitación-IN, Local Crew-FE, Local Crew-MA, Local Crew-FE, Local Crew-IN, Local Crew Asistente de Supervisor-FE, Local Crew Asistente de Supervisor-MA, Local Crew Supervisor-FE, Local Crew Supervisor-MA, Seguridad-IN` (seleccionado), `Seguridad-IN` (aparece dos veces en la lista — posible duplicado de catálogo).
- `Estatus` — label de solo lectura. Valores vistos: `Vigente` (antes de liberar) → `Liberado` (después de pulsar `Liberar Pedido`).
- `Evento Práctica` — checkbox.
- `Tipo personal*` — label de solo lectura (no editable en este flujo). Valor: `Operativo`.
- `Título*` — input, hereda `Entrega 03 Escenario 15`.
- `Lugar de Cita` / `Dirección cita` — heredados del pedido.
- `Otro` — checkbox.
- `Indicaciones especiales` — textarea.
- `Bloque por producto` — combo. Valor: `Ninguno`.
- `Facturable` — combo NO/SI. Valor: `NO`.
- Botón `Cancelar detalle` (rojo/azul, pie izquierdo del panel Detalles).
- `Cantidad` — input numérico. Valor: `1`.
- `Turnos` — input numérico. Valor: `1.00`. Label auxiliar fijo: `8 Horas por turno`.
- `Fecha cita*` — date/time picker (fecha + hora). Valor: `04/04/2019 04:00`.
- `Fecha liberación` — date/time picker. **Quedó vacío** en este escenario (la liberación se hizo con el botón de cabecera `Liberar Pedido`, no por fecha programada de detalle).
- `Fecha final cita` — date/time picker. Valor: `04/04/19 12:00` (8h de turno).
- `Presentación por producto` — combo. Valor usado: `Pantalón Negro de Vestir y Camisa Blanca`.
- `Completar con similares` — combo NO/SI. Valor: `NO`.
- `Fase del evento` — combo. Valor: `No aplica`.
- `Permitir cancelar` — combo **NO/SI**, a nivel de DETALLE (distinto del de cabecera). Default `NO`; se cambió explícitamente a **`SI`** (frames `032_01m43s.png` → `035_01m55s.png`, visible ya en `SI` después de liberar) — es el paso "Crear un detalle de pedido que permita la cancelación".
- Botones: `Agregar Detalle`, `Cancelar`.
- Tras agregar el detalle aparece la "Matriz de Puestos": columnas `Bloque | Productos | 04/04 (04:00)`, fila `Seguridad-In 1 - T1`, `Total Solicitados: 1`, `Presupuesto por día: 300`.

**Confirma/aclara la MD:** el texto del Escenario 15 dice "Crear un pedido... que permita la cancelación" y "Crear un detalle de pedido que permita la cancelación" como si fuera un solo concepto; las capturas muestran que son **dos campos independientes** en dos pantallas distintas (`Permitir cancelar confirmaciones` en cabecera de Pedido, `Permitir cancelar` en el Detalle), ambos NO/SI y ambos deben ponerse en `SI` para este escenario.

## 4. Detalle de pedido — pestaña "Reservaciones" (asignación forzada)

Captura: `038_02m01s.png`, `040_02m06s.png` (ventana Excel), `042_02m10s.png`

- Pestañas del panel "MODIFICACION DETALLE DE PEDIDO": `Detalles | Reservaciones`.
- Sub-encabezado: `Personal Confirmado`.
- Campo `Nombre` — input de búsqueda con placeholder `Nombre completo / Alias`.
- Botones: `Confirmación Forzada` y `Confirmación Preasignada` (ambos azul oscuro, lado a lado).
- Ícono `Imprimir lista de Asistencia` (impresora) a la derecha.
- Grilla inferior: columnas `IdContacto | Nombre completo | Estatus`.
- Se buscó/seleccionó `62304-Abel Ornelas Montoya` y se pulsó `Confirmación Forzada`.
- Resultado en grilla: `62304 | 62304 - Abel Ornelas Montoya | CONFIRMADO FORZADO` (con botón `✕` al final de la fila, deshabilitado/gris — posible indicio de que ese estatus no se puede remover desde ahí).
- Tooltip emergente (frame `043_02m16s.png`) al pasar el mouse sobre el bloque de la matriz: `Editar Liberar Cancelar Pedido` con detalle: `ID 2103 | Lugar de cita: Estadio Azteca | Fecha cita: 04/04/2019 04:00 | Fecha fin cita: 04/04/19 12:00 | Fecha liberación: (vacío) | Completar con similares: NO | Cantidad reservados: 1 | Cantidad reservados real: 0 | Cantidad reservados con preasignación: 0 | Porcentaje completo: 100.00 | Fase de evento: (vacío) | Indicaciones especiales: (vacío)`.

**Hallazgo importante — fuente primaria:** el frame `040_02m06s.png` es, de hecho, una captura de la hoja de cálculo QA real abierta en Excel (`Scripts de Prueba Freelance_leonardo.xlsx`, pestaña "Otros Escenarios Pedidos"), mostrando **línea por línea el mismo texto del Escenario 15** que ya está volcado en `ESCENARIOS_PRUEBA_FREELANCE.md` (filas 119–127: "Cancelación de asignación forzada / Crear un pedido de seguridad que permita la cancelación / ... / Validar que el sistema no permita la cancelación"), y además una celda con la anotación manual del tester: `62304 | Mabel | Abel Ornelas Montoya --`. Esto confirma que el empleado usado para la asignación forzada de este escenario es **ID 62304, Abel Ornelas Montoya** (la columna "Mabel" parece ser el nombre de la tester/columna de responsable de la prueba, no parte del nombre del empleado).

## 5. Login y portal Freelance (empleado)

Captura: `046_02m23s.png`, `047_02m25s.png`, `048_02m34s.png`, `049_02m39s.png`, `050_03m08s.png`, `051_03m10s.png`

- Pantalla de login (`gamexamplelogin1.aspx`), fondo de escenario con reflectores. Caja blanca centrada con header `RRHH`, campos `Usuario`, `Contraseña`, link `¿Olvidaste tu contraseña?`, checkboxes `Mantenerme Conectado` y `Recordar`, botón `Ingresar`.
- Tras ingresar como Abel Ornelas Montoya, navbar del portal freelance: `Resultados generales | Calendario de eventos | Saldos | Confirmación de eventos | Aclaraciones | Salir`.
- Pantalla `Confirmación de eventos` — dos columnas:
  - **`Eventos por confirmar`** (izquierda): lista de botones azules con formato `UNIDADNEGOCIO--Título fecha hora (ID)`, ej. `SEGURIDAD--Green Day 2019 28/03/19 13:00 (1997)`, `ASISTENTE OPERADOR--Futbol América vs Pumas 29/03/19 10:00 (2023)`, `SEGURIDAD--Sidonie 22/03/19 10:00 (2058)`, etc.
  - **`Eventos confirmados`** (derecha): mismo formato, incluye `SEGURIDAD..Entrega 03 19/03/19 07:00`, `SEGURIDAD..Entrega 03 19/03/19 19:00`, y **`SEGURIDAD..Entrega 03 04/04/19 04:00`** — este último es el evento de este escenario (ID de detalle 2103, fecha 04/04/19 coincide con lo capturado en el pedido).
- Al pulsar sobre el evento confirmado del escenario, se despliega un panel de detalle de solo lectura con los campos:
  `Evento: Entrega 03`, `Descripción: Seguridad`, `Fecha: 04/04/19 04:00 a 04/04/19 12:00`, `Turnos: 1.00`, `Lugar: Estadio Azteca`, `Dirección: Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX`, `Presentación producto: Pantalón Negro de Vestir y Camisa Blanca`, `Indicaciones Especiales: (vacío)`.
- Esquina superior derecha: menú de usuario desplegado `Abel Ornelas Montoya / Freelance` con única opción `Salir`.
- **No se observa ningún botón de "Cancelar confirmación" en el panel de detalle**, ni ningún mensaje de error/validación/alerta en ninguno de los frames capturados hasta el final del video (190s de 194s totales). El panel del evento confirmado es puramente informativo en las capturas disponibles.

---

## 6. Mensajes de validación / confirmación

**No se capturó ningún texto literal de error o confirmación** en los 51 frames (ni alert, ni modal, ni notificación toast) relacionado con el intento de cancelación. La extracción de frames parece basarse en cambios de escena/UI, y es posible que el intento real de cancelar (clic + mensaje de bloqueo) haya ocurrido en los ~4 segundos finales del video no cubiertos por una captura, o que el sistema simplemente **no exponga ningún control de cancelar** para un evento cuyo estatus de reservación es `CONFIRMADO FORZADO` (en vez de mostrar el control y bloquearlo con un mensaje). Esto es consistente con, pero no confirma, el resultado esperado de la MD: *"Validar que el sistema no permita la cancelación"*.

Recomendación: si se dispone del video original (`https://youtu.be/8kuFYbczd9s`), revisar los últimos 4-5 segundos (~03:10 a 03:14) para capturar el intento de clic y cualquier mensaje — no estaba disponible como frame extraído en este set de 51 PNGs.

---

## 7. Reglas de negocio / campos NUEVOS no capturados (o no explícitos) en ESCENARIOS_PRUEBA_FREELANCE.md

1. **"Permitir cancelar" existe en DOS niveles independientes**, ambos NO/SI: `Permitir cancelar confirmaciones` en la cabecera del Pedido, y `Permitir cancelar` en cada línea de Detalle de pedido. La MD solo decía "que permita la cancelación" sin distinguir que son dos campos/formularios distintos que deben configurarse por separado.
2. **Catálogo de Unidad de negocio** (orden alfabético visto, 20 valores, posiblemente incompleto por scroll): Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, Operaciones Inmuebles, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, PRG, PRG_Complejidad, Produccion, Publicidad, Recursos Humanos Operaciones, Renta de Equipos, RRHH, Seguridad.
3. **Catálogo de productos/puestos de Seguridad** (parcial, visible en dropdown): Apoyo Retencion de Talento-IN, Apoyo Seguridad-MA, Asistente Administrativo-IN, Asistente Operativo-IN, Control de Accesos-MA/FE/IN, Control de Accesos 4-MA/FE, Instructor de Capacitación-IN, Local Crew-FE/MA/IN, Local Crew Asistente de Supervisor-FE/MA, Local Crew Supervisor-FE/MA, Seguridad-IN (con posible entrada duplicada en el catálogo).
4. **Formato del PEP en el combo**: `"<código PEP> | <descripción>"`, ej. `LT-AZ-2018-01-01N085LT-A | LT-AZ-2018-01-01N085LT-A` y `N/085-PD-2015-03-09 | Preventa Formula 1` — confirma que pueden coexistir PEPs "de venue" (códigos LT-) y PEPs "de preventa/temporal" en el mismo combo dependiente de UN+Sucursal.
5. **Bug reconfirmado**: `Sociedad pagadora` muestra un valor por default incorrecto (`Car Sport Racing SA de CV`) antes de seleccionar la Unidad de negocio — mismo bug ya anotado en Escenario 1/3 de la MD ("sociedad pagadora por default con ID 10"), ahora visto también en el flujo de Escenario 15.
6. **Botones `Confirmación Forzada` / `Confirmación Preasignada`** están en la pestaña "Reservaciones" del Detalle de pedido (no en la pestaña "Detalles"), junto a un campo de búsqueda `Nombre completo / Alias` y una grilla `IdContacto | Nombre completo | Estatus`. El estatus textual resultante de una asignación forzada es literalmente **`CONFIRMADO FORZADO`**.
7. **El botón "quitar" (✕) de la fila de reservación confirmada aparece deshabilitado/gris** para un registro `CONFIRMADO FORZADO` — posible evidencia adicional (a nivel de UI de backoffice) de que ese estatus no se puede remover ni siquiera por el administrador desde esa grilla.
8. **Tooltip de la Matriz de Puestos** (al pasar el mouse sobre la celda del bloque) expone campos adicionales no documentados en la MD: `ID` (identificador interno del detalle, ej. `2103`), `Cantidad reservados`, `Cantidad reservados real`, `Cantidad reservados con preasignación`, `Porcentaje completo` — útil para el modelo de datos de "detalle de pedido" en PeopleMovil.
9. **Portal freelance — pantalla "Confirmación de eventos"** separa los eventos en dos listas (`Eventos por confirmar` vs `Eventos confirmados`) con formato de etiqueta `UNIDADNEGOCIO--Título fecha hora (ID)`; el panel de detalle de un evento confirmado es de solo lectura (`Evento, Descripción, Fecha, Turnos, Lugar, Dirección, Presentación producto, Indicaciones Especiales`) y **en las capturas disponibles no muestra ningún botón de cancelar** para el evento con asignación forzada — a diferencia de lo que cabría esperar (un botón presente pero bloqueado con mensaje). Esto sugiere que la regla "no cancelar asignación forzada" podría implementarse ocultando el control en vez de (o además de) validarlo en servidor; debe confirmarse contra el Escenario 13 (que sí describe mensajes de bloqueo de cancelación) antes de asumirlo como regla de diseño para PeopleMovil.
10. **Empleado de prueba identificado**: ID `62304`, nombre `Abel Ornelas Montoya`, confirmado tanto en la UI (grilla de reservaciones y menú de usuario del portal) como en la celda de anotación manual de la hoja de cálculo QA original capturada en pantalla.
11. **Fecha de liberación de detalle quedó vacía**: el escenario usó el botón de cabecera `Liberar Pedido` (acción a nivel pedido) en vez de programar una `Fecha liberación` en el detalle — confirma que son dos mecanismos de liberación independientes (inmediato vs programado), relevante para el campo `fecha_liberacion` / lógica de `PRC_CancelacionAutomaticaPreasignados` en el nuevo esquema.
