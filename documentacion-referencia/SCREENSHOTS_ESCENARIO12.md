**✅ Implementado y probado (2026-10-08, Migración 020)**: `puesto_aceptado_por_detalle()` + `tg_reservacion_valida()` ya replican la cadena de resolución y el mensaje exacto `"El empleado no cumple con el perfil requerido"`. Probado end-to-end en vivo contra la base real (pedido #193 "Escenario 12 - Productos similares", tenant eventos) — bloqueado con similares=NO, permitido con similares=SÍ. `Preasignacion.jsx` ahora tiene un buscador libre de empleados (antes solo listaba por plaza exacta, por lo que el escenario ni se podía intentar). Ver `CLAUDE.md` §7 (Migración 020) y `db/reset_database.sql`. Pendiente menor: no existe todavía una pantalla "Modificar detalle" para editar `completar_productos_similares` después de creado (se hizo por SQL directo en la prueba); el alta inicial del detalle sí lo captura (`SitiosAsignacion.jsx`).

# Escenario 12 — Productos similares (walkthrough visual)

Fuente: 95 capturas de pantalla extraídas cuadro a cuadro del video QA
`06 - Escenario12` (`https://youtu.be/Uhni7lOmpJE`, duración 5m17s, grabado 19/08/2019),
carpeta `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\06 - Escenario12\`.
Se revisó una muestra representativa (~45 de 95 imágenes) a lo largo de todo el video.
Las imágenes se citan como `NNN_MMmSSs.png`.

Contrasta contra el texto QA en `ESCENARIOS_PRUEBA_FREELANCE.md` (líneas 382-395,
"Escenario 12: Productos similares") y contra `tr_productos_similares` /
`completar_productos_similares` en `db/reset_database.sql`.

## Módulo / pantalla

Sistema "RRHH" (GeneXus, AppSCPF / Lobo), host de QA
`integramx-001-site2.btempurl.com/qafreelancev1/`. Rol "Operacion" (operador
de pedidos) para la pantalla principal del escenario; un segundo sitio/rol
"Nomina" (`te_plazasww.aspx`, "Plazas empleados") se usa en paralelo, en otra
pestaña/perfil del navegador, solo para **consultar** qué empleados tienen la
plaza "Control de Accesos" (no es parte del flujo que ve el operador).

Pantallas recorridas, en orden:
1. `Inicio` (`wwpbaseobjects.home.aspx`) — menú superior `RRHH | Inicio |
   Operaciones ▾ | Salir` y, a la derecha, `Operacion ▾`.
2. `Pedidos` — alta de pedido (`te_pedido.aspx?INS,0`).
3. `Pedidos` → grid de listado con filtro (`wp_pedidodetalle.aspx?<id>` es el
   detalle).
4. `Detalles de pedido` — formulario de detalle de pedido con dos pestañas:
   `Detalles` y `Reservaciones`.
5. `Plazas empleados` (otro sitio/rol, `te_plazasww.aspx`) — catálogo de
   empleados por puesto, usado solo para investigar candidatos.

## 1. Campos de formulario y controles observados

### 1.1 Pedidos → "Información General" (`009_00m45s.png` a `045_02m16s.png`)

Encabezado de la página: título **Pedidos**, con dos links arriba del bloque
azul: **Agregar Detalle** y **Agregar Factura**.

Bloque "Información General" (todos los campos marcados con `*` rojo son
obligatorios):

| Campo | Control | Notas |
|---|---|---|
| Cliente * | combo con buscador tipo autocomplete | lista alfabética larga de clientes, ej. "LiveMed, S. de R.L. de C.V.", "Logística Organizacional Para La Integración de Eventos...", "Los Publívoros...", "MC Show Business...", "MTV Networks de México...", "Música Esencial...", **"Ocesa Anfiteatro, S.A. de C."**, luego se cambia a **"OCESA Promotora, S. A. de..."** |
| Id Contacto * | combo, dependiente del cliente | valor usado: "Heriberto Reyes Vasquez" |
| Id sucursal * | combo | valor usado: "CDMX" |
| Unidad de negocio * | combo con buscador, catálogo largo | ver lista completa abajo — valor usado: **"Seguridad"** |
| Id PEP * | combo (autocomplete) | valor usado: `LT-AZ-2018-01-01N085LT-A L...` (truncado en pantalla) |
| Id evento * | combo | valor usado: **"Jacob Whitesides 2019"** |
| Título * | texto libre | autogenerado/editado: "Jacob Whitesides 2019--Escenario 12" |
| Lugar de cita | combo, "Sin definir" por default | valor usado: **"Estadio Azteca"** |
| Dirección lugar | textarea, se autocompleta al elegir Lugar de cita | "Calz. de Tlalpan 3465, Sta. Úrsula Coapa, Coyoacán, 04650 Ciudad de México, CDMX" |
| Otro | checkbox | sin marcar |
| Tipo de movimiento * | combo | "(Ninguno)" → **"Pedido"** |
| Sociedad pagadora * | combo | "Operadora de Centros de Es[pectáculos]..." |
| Permitir cancelar confirmaciones * | combo Sí/No | **"NO"** (importante para Escenario 13, no para este) |
| Responsable * | combo (autocomplete) | "Juan Carlos Zavala Enríquez" |

Botones al pie: **Confirmar** y **Regresar**.

Catálogo completo de "Unidad de negocio" visible en el dropdown abierto
(`013_00m53s.png`), orden alfabético — confirma que es un catálogo de
**unidades de negocio operativas** del tipo de evento/servicio, no solo
"Seguridad":
`(Ninguno)`, `A Muse`, `Actividades Deportivas`, `Administración y
Contratación de Talento`, `Admón y Finanzas`, `Aldea Digital`,
`Anfitriones`, `Asdeporte`, `Atención a Clientes`, `Calacas Zíngaro`,
`Cavalia`, `Cirque Du Soleil`, `Comercial`, `Control de Accesos`,
`Corona Capital`, `E-Ticket`, `Enlace`, `Estacionamientos`,
`Estadio 3 de Marzo Gdl`, `Estadio Azul`, ... (la lista sigue, truncada
en pantalla). Nótese que **"Control de Accesos" y "Seguridad" son ambas
unidades de negocio/puestos distintos** dentro del mismo catálogo — es la
base conceptual de "productos similares".

### 1.2 Pedidos → listado (`033_01m50s.png`)

Grid "Pedidos" con toolbar: botón `+` (nuevo), `XLS`, `PDF`,
`Selecciona columnas ▾`, filtro `Buscar en [Id pedido ▾] valor [< ▾] [___]`.
Columnas: `Id`, `Título`, `Estatus` (Vigente/Liberado), `Unid.Neg.`,
`Sucursal`, `lugar`, `Responsable`, `Complejidad`, `T.Mov`, `PeP|Descripción`.
El pedido creado queda como **Id 1057**, Estatus "Vigente", Unid.Neg.
"Seguridad", lugar "Estadio Azteca", T.Mov "Pedido".

### 1.3 Detalles de pedido → pestaña "Detalles" (`037_02m00s.png` a
`094_05m07s.png`)

| Campo | Control | Valor usado |
|---|---|---|
| Estatus | solo lectura | "Vigente" |
| Evento Práctica | checkbox | sin marcar |
| Tipo personal * | solo lectura | "Operativo" |
| Título * | texto | hereda el título del pedido |
| Producto | combo | **"Seguridad-IN"** |
| Lugar de Cita * | combo | "Estadio Azteca" |
| Dirección cita | textarea | heredada |
| Otro | checkbox | sin marcar |
| Indicaciones especiales | textarea | vacío |
| Bloque por producto | combo | "Ninguno" |
| Facturable | combo Sí/No | "NO" |
| Cantidad | numérico | 1 |
| Turnos | numérico (calculado) | 1.00 — nota "8 Horas por turno" |
| Fecha cita * | fecha + hora (combos 00-23 / 00-59) | 29/08/2019 06:00 |
| Fecha liberación | fecha + hora, con mini-calendario (`050_02m43s.png`) | 16/08/2019 06:00 |
| Fecha final cita | fecha + hora | 29/08/2019 14:00 |
| Presentación por producto | combo | **"Pantalón Negro de Vestir, Pl[aya]..."** (texto truncado) |
| **Completar con similares** | combo **NO / SÍ** | **campo central del escenario** — inicia en "NO", se cambia a "SÍ" |
| Fase del evento | combo | "No aplica" |
| Permitir cancelar | combo NO/SÍ | "NO" |

Botones: **Agregar Detalle** / **Cancelar** (alta); **Modificar detalle** /
**Cancelar** (edición).

Tras guardar el detalle aparece la caja "Matriz de Puestos" con columnas
`Bloque | Productos | 29/08 | 06:00`, fila `Seguridad-IN | <Título> | 1 - T
1.00`, y totales `Total Solicitados: 1` / `Presupuesto por día: $300.00`.

### 1.4 Detalles de pedido → pestaña "Reservaciones" ("Personal Confirmado")

Caja con:
- Campo **Nombre** (placeholder "Nombre completo / Alias") — autocomplete de
  empleados.
- Botón **Confirmación Forzada**.
- Botón **Confirmación Preasignada**.
- Link/ícono **Imprimir lista de Asistencia** (ícono de impresora).
- Grid resultado: columnas `IdContacto | Nombre completo | Estatus`, con "X"
  para cancelar cada fila.
- Estatus observado en el grid: **"CONFIRMADO FORZADO"**.

### 1.5 Plazas empleados (catálogo, pantalla de apoyo/Nómina)

Grid con toolbar `+ | XLS | PDF | Selecciona columnas ▾`, filtro
`Buscar en [Nombre/Puesto/Unidad de negocio/Sociedad ▾] valor [Comienza con ▾]
[___]` y botón de limpiar filtro. Columnas: `Id empleado`, `Nombre`, `Sexo`,
`Certeza`, `Estatus` (Activo/Inactivo), `Pago`, `Id puesto`, `Puesto`
(ordenable, con sub-menú "Ordenar de A a Z / Z a A / Limpiar búsqueda" y
rango `Desde`/`Hasta`), `Pago default`, `Unidad de negocio`, `Inicio`,
`Vigente` (checkbox), `Sociedad`, `Principal`.

## 2. Catálogo / configuración de "productos similares"

**No existe una pantalla dedicada de catálogo de "productos similares"** (no
hay un ABC visual para mapear qué producto es similar a cuál). El control
observado es, en cambio, un **flag booleano por detalle de pedido**:
el combo **"Completar con similares"** (valores **NO** / **SÍ**) dentro del
formulario "Detalles" de `Detalles de pedido`. Esto coincide exactamente con
la columna ya existente en el esquema:
`te_pedidos_detalle.completar_productos_similares boolean DEFAULT false`
(línea 2271 de `reset_database.sql`), y con la tabla `tr_productos_similares`
(mapeo producto ↔ producto_similar, bidireccional) que define **qué
productos son intercambiables** cuando ese flag está en SÍ.

En el video, el producto del detalle es **"Seguridad-IN"**, y el empleado de
prueba (Oscar Fernández Plata, id 58172) solo tiene la plaza **"Control de
Accesos"** (no tiene plaza "Seguridad"). Con esto se demuestra visualmente
que **"Control de Accesos" actúa como producto/puesto similar de
"Seguridad-IN"**.

## 3. Mensajes exactos observados (validación / confirmación)

| Mensaje (texto literal, banner naranja superior derecho) | Cuándo aparece |
|---|---|
| **"Registro agregado correctamente"** | Al guardar un nuevo detalle de pedido, y al confirmar forzadamente a un empleado con éxito (`077_04m18s.png`, `094_05m07s.png`) |
| **"Registro Agregado Correctamente"** (con mayúsculas distintas, aparente inconsistencia de capitalización entre pantallas) | Variante vista en `051_02m48s.png` |
| **"Reservación cancelada"** | Al dar clic en la "X" de una fila de "Personal Confirmado" para cancelar/quitar una confirmación forzada (`075_04m11s.png`) |
| **"El empleado no cumple con el perfil requerido"** | **Mensaje de validación clave del escenario.** Aparece al intentar "Confirmación Forzada" de un empleado cuyo puesto no coincide con el producto del detalle y "Completar con similares" = NO (`083_04m30s.png`) |
| **"Registro Modificado Correctamente"** | Al guardar el detalle tras cambiar "Completar con similares" de NO a SÍ con el botón "Modificar detalle" (`087_04m49s.png`, `088_04m50s.png`) |
| **"El usuario debe estar autenticado."** | Pantalla de login "Acceso" del sitio secundario (Nómina/Plazas), mensaje de sesión expirada, no ligado al escenario en sí (`055_03m05s.png`) |

No se observó ningún mensaje de validación de campo obligatorio (los `*`
rojos no se llegaron a disparar en el recorrido muestreado).

## 4. Botones / acciones, nombres exactos

- `Confirmar` / `Regresar` (alta de pedido)
- `Agregar Detalle` / `Cancelar` (alta de detalle)
- `Modificar detalle` / `Cancelar` (edición de detalle)
- `Confirmación Forzada` / `Confirmación Preasignada` (pestaña Reservaciones)
- `Editar pedido` / `Liberar Pedido` / `Cancelar Pedido` / `Regresar` (vista
  de detalle de pedido ya liberado)
- `Imprimir lista de Asistencia` (ícono impresora)
- `X` (eliminar fila / cancelar reservación) en grids

## 5. Secuencia reconstruida del escenario (contrastada con el texto QA)

1. Alta de pedido "Seguridad" con Cliente OCESA Promotora, evento "Jacob
   Whitesides 2019", lugar "Estadio Azteca", `Permitir cancelar
   confirmaciones = NO` (001-033).
2. Alta de detalle: Producto "Seguridad-IN", cantidad 1, fecha cita
   29/08/2019 06:00, **Completar con similares = NO** (037-052). Mensaje
   "Registro Agregado Correctamente".
3. Primer intento de Confirmación Forzada (sin escribir nombre, aparenta
   auto-seleccionar) confirma al empleado **3422 — Amado Alberto Alvarado
   Salvador**, estatus CONFIRMADO FORZADO. **Nota:** Amado también tiene la
   plaza "Seguridad" (vista directa, no similar) según el catálogo de
   Plazas — por lo que este primer intento no prueba el caso de similares;
   parece un paso de verificación/orden previo que luego se revierte.
4. Se cancela esa reservación ("Reservación cancelada", `075_04m11s.png`).
5. Se consulta en paralelo (otra pestaña/rol "Nómina", sitio
   `te_plazasww.aspx`) el catálogo de empleados con puesto **"Control de
   Accesos"** (id puesto 4), localizando a **58172 — Oscar Fernández
   Plata** (único con la plaza como Principal="Sí" en la hoja de datos de
   prueba) y a 39115 — Arturo Flores / 3422 — Amado Alberto como
   secundarios (frame `066_03m37s.png`, hoja Excel
   `DatosFReelanceParaEscenarios_01.xlsx`, pestaña "Control de accesos").
6. Se intenta Confirmación Forzada de Oscar Fernández Plata con
   `Completar con similares` aún en **NO**. Hay una secuencia algo errática
   en el muestreo (un primer intento muestra éxito en 077-080, luego se
   cancela en 081, se reintenta en 082-083) y finalmente se observa con
   certeza el **rechazo**: banner **"El empleado no cumple con el perfil
   requerido"** (`083_04m30s.png`), con el grid de "Personal Confirmado"
   vacío — esto confirma el paso "Validar que el sistema no permite
   realizar esta asignación" del texto QA.
7. Se edita el detalle y se cambia **Completar con similares → SÍ**,
   "Modificar detalle" → "Registro Modificado Correctamente" (085-088).
8. Se repite la Confirmación Forzada de Oscar Fernández Plata (58172): esta
   vez **tiene éxito** — "Registro agregado correctamente", estatus
   CONFIRMADO FORZADO (`094_05m07s.png`) — confirma "Validar que el sistema
   permite realizar esta asignación".
9. El texto QA indica los pasos finales (entrar al portal del empleado de
   control de accesos y validar que el pedido no se muestra / sí se
   muestra en sus reservaciones); esos pasos del PORTAL DE EMPLEADO no
   aparecen en las 95 capturas muestreadas (posiblemente ocurrieron fuera
   del rango capturado, o en una sesión de navegador distinta no incluida
   en este set de imágenes).

## 6. Reglas de negocio / campos NUEVOS o a confirmar (no capturados aún en
   ESCENARIOS_PRUEBA_FREELANCE.md ni evidentes en el esquema actual)

1. **Mensaje de validación textual exacto** a replicar:
   `"El empleado no cumple con el perfil requerido"` — no hay constante ni
   mención de este texto en el repo; debe codificarse tal cual (o
   traducirse/parametrizarse) en la validación de
   `confirmar_forzado`/`confirmar_preasignado` cuando el puesto del
   empleado no matchea `tr_producto_puesto` del producto del detalle y
   `completar_productos_similares = false`.
2. **Regla de "similar" es a nivel PRODUCTO, no solo PUESTO**: el campo que
   el usuario manipula es el del detalle de pedido
   (`completar_productos_similares`) ligado al **producto** ("Seguridad-IN"),
   y el match efectivo se resuelve contra el **puesto** de la plaza del
   empleado ("Control de Accesos"). Esto implica que la validación debe
   recorrer: producto del detalle → `tr_producto_puesto` (puestos
   aceptados) → si no hay match directo y `completar_productos_similares =
   true` → `tr_productos_similares` (productos similares) → sus puestos
   vía `tr_producto_puesto` también. **Confirmar que esta cadena de
   resolución está implementada** en las funciones de confirmación forzada
   o preasignada actuales del proyecto (no se encontró lógica de este tipo
   en `reset_database.sql`, solo las tablas de catálogo).
3. **El botón "Confirmación Forzada" sin nombre capturado puede
   auto-seleccionar un candidato** (paso 3 de la secuencia): comportamiento
   a confirmar/replicar o descartar como curiosidad de la demo — si se
   replica, definir el criterio de auto-selección (¿mejor certeza? ¿primer
   match exacto?).
4. **Inconsistencia de mayúsculas** en el mensaje de éxito ("Registro
   agregado correctamente" vs "Registro Agregado Correctamente") y
   duplicidad de redacción con "Registro Modificado Correctamente" —
   sugiere una plantilla de notificación genérica
   `"Registro {accion} Correctamente"` reutilizada para alta/edición; buen
   patrón a adoptar en PeopleMovil (toast genérico reutilizable), pero
   normalizando capitalización.
5. **Catálogo "Unidad de negocio"** visto en el pedido (`013_00m53s.png`)
   es mucho más amplio que "Seguridad/Transportes/Producción" — incluye
   decenas de unidades operativas tipo "Cirque Du Soleil", "Corona
   Capital", "Estacionamientos", etc. Confirmar si esto debe modelarse como
   catálogo abierto (`cat_unidades_negocio` o similar) versus un enum
   fijo, ya que en Lobo es claramente una tabla editable con muchos
   registros específicos por cliente/evento recurrente — no vista aún
   como tabla propia en `reset_database.sql` (puede estar ya cubierta por
   `cat_sitios`/`tc_productos`, pero vale la pena un segundo vistazo).
6. **Campo "Presentación por producto"** (dress code / uniforme, ej.
   "Pantalón Negro de Vestir, Pl[aya]...") a nivel de detalle de pedido —
   confirmar si existe columna equivalente en `te_pedidos_detalle` (no se
   buscó explícitamente en esta pasada; candidato a revisar).
7. **Campo "Indicaciones especiales"** (textarea) coincide con la columna
   ya agregada `indicaciones_especiales text` — confirmado, sin acción
   necesaria.

## 7. Bug confirmado por QA en el legado (video de regresión 2019-03-19)

Video adicional revisado: `R20190319 Escenario 12` (`https://youtu.be/TZA4CV4aSRg`,
2m23s, canal WJaJa VideoClips). No tiene transcripción de YouTube; se recorrió
manualmente moviendo `video.currentTime` vía JS y tomando capturas en varios
puntos. Contenido:

1. **Hoja de control de QA** (`comentarios_freelance.xlsx`, captura de pantalla
   dentro del propio video) — bitácora de bugs reportados por escenario (8 al
   17), fecha 18-19/03/2019. La fila del Escenario 12 dice textual (celda H13):
   > "Minuto 3:23: Al agregar el empleado sigue mostrando el error indicando
   > que no cumple el perfil, **el cuál no es correcto en este caso**."
2. El resto del video muestra el sistema real (`integramx-001-site2...`):
   listado "Pedidos" → "Detalles de pedido" → pestaña Reservaciones con
   "Personal Confirmado" (empleado "5401 - Oscar García Palacios",
   botones "Confirmación Forzada"/"Confirmación Preasignada") → formulario
   "Editar/Liberar/Cancelar Pedido" con el campo **"Completar con similares"**
   visible — mismo patrón ya documentado en las secciones 1-6 de este archivo,
   confirmado con datos de otra corrida de prueba.

**Conclusión:** el propio QA de OCESA marcó como defecto que el mensaje
`"El empleado no cumple con el perfil requerido"` aparecía **incorrectamente**
en al menos un caso de este escenario (falso positivo) — es decir, el legado
tenía un bug conocido y sin resolver en esta misma validación. La
implementación de PeopleMovil (Migración 020, `puesto_aceptado_por_detalle()`)
**no replica este bug**: se probó end-to-end el 2026-10-08 y bloquea/permite
correctamente según corresponda. Decisión: no es necesario reproducir un
defecto reconocido como tal por el QA original — la fidelidad máxima aplica a
las reglas de negocio intencionales, no a bugs no resueltos. Si en el futuro
se encuentra evidencia de que este "bug" en realidad escondía una regla de
negocio válida no documentada, revisar este hallazgo de nuevo.
