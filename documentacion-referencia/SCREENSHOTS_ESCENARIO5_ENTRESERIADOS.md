# Hallazgos de capturas — Escenario 5 "Entre Seriados"

Fuente: 40 capturas (`001_00m00s.png` … `040_02m45s.png`) extraídas del video
`https://youtu.be/wSKzFMSHb18` ("Escenario5 Entre Seriados", 172 s, WJaJa VideoClips),
carpeta `doc\Panttallas del sistema tomados desde varios video escvenarios de pruebas de pruebas\10 - Escenario5 Entre Seriados\`.
Las 40 imágenes fueron revisadas en su totalidad. Complementa (no contradice) el texto
de `ESCENARIOS_PRUEBA_FREELANCE.md`, sección "Hoja: Escenario 5".

## 1. Resumen del flujo observado

1. **001–005**: Login al sistema "RRHH" (pantalla con fondo de concierto). Campos
   `Usuario` / `Contraseña`, botón `Ingresar`, aviso `El usuario debe estar autenticado.`
   Usuario operativo usado: `Svillanueva`.
2. **006**: Listado `Pedidos` (grid `te_pedidoww.aspx`) — confirma pedidos ya creados
   para este escenario (ver sección 4).
3. **007–010**: `Detalles de pedido` (`wp_pedidodetalle.aspx?1051`) — bloque
   "Matriz de Puestos", pestañas `Detalles` / `Reservaciones`, sección
   `Personal Confirmado` con botones `Confirmación Forzada` y `Confirmación Preasignada`.
4. **011**: Al pulsar `Confirmación Forzada` sobre un puesto con
   `Confirmar Entre Seriados = NO`, aparece un toast naranja:
   **"El puesto no permite Confirmación Entre Seriados"**.
5. **012–015**: Capturas del archivo Excel fuente `Scripts de Prueba Freelance.xlsx`
   (hoja "Escenario 5"), idéntico al contenido ya transcrito en
   `ESCENARIOS_PRUEBA_FREELANCE.md` — confirma que ese Excel es el origen del .md.
6. **016–020**: Cambio de ventana al catálogo `Puestos` (`tc_puestos.aspx?UPD.287`),
   nuevo login en ventana de incógnito con usuario **`admin`** (rol administrador,
   distinto del usuario operativo que crea pedidos).
7. **021, 026–027**: Formulario completo de mantenimiento de **Puesto** (ver sección 2),
   con `Confirmar Entre Seriados = NO` para el puesto "Rigger PRG" (Id 287).
8. **022–024**: Navegación por el menú `Catálogos` → submenús `Pedidos` y `Otros`,
   confirma la ruta exacta al catálogo de Puestos: `Catálogos → Otros → Puestos`.
9. **025, 028**: Listado del catálogo `Puestos` (`tc_puestosww.aspx`), filtrado por
   "Rig": dos registros, Id 287 "Rigger PRG" (UN PRG) e Id 41 "Rigger" (UN Produccion).
10. **029–039**: Se vuelve al pedido 1051 (usuario operación), pestaña `Reservaciones`,
    se captura al contacto en el campo `Nombre` (autocompletado "IdContacto-Nombre"),
    se pulsa `Confirmación Forzada`.
11. **040**: Esta vez (tras haber cambiado `Confirmar Entre Seriados` a `SI` en el
    puesto) el forzado **sí procede**: toast verde/naranja
    **"Registro agregado correctamente"**, y la fila agregada muestra
    `Estatus = CONFIRMADO FORZADO` para `36477 - Marisol Lícea Luengas`.

Este flujo reproduce exactamente los pasos 22–24 (y la repetición indicada) de la
hoja "Escenario 5" del documento de referencia: forzar la asignación de una persona
que ya está confirmada en otro pedido/bloque el mismo día debe **fallar** cuando el
puesto no permite "confirmación entre seriados", y debe **permitirse** cuando esa
propiedad del puesto se activa.

## 2. Campos de formulario observados

### 2.1 Login (`inicio.aspx`)
- `Usuario` (texto)
- `Contraseña` (texto/password)
- Botón `Ingresar`
- Mensaje de validación: `El usuario debe estar autenticado.`

### 2.2 Listado de Pedidos (`te_pedidoww.aspx`)
Columnas de grid: `Id`, `Título`, `Estatus`, `Unid.Neg.`, `Sucursal`, `lugar`,
`Responsable`, `Complejidad`, `T.Mov`, `PeP | Descripción`.
Controles: botón `+` (nuevo), exportar `XLS`/`PDF`, `Selecciona columnas`, filtro
`Buscar en [campo] [operador] [valor]`.

### 2.3 Detalles de pedido (`wp_pedidodetalle.aspx`)
- Encabezado: `Editar pedido` (link), `Cancelar Pedido` (link), botón `Regresar`,
  título `PEDIDO No.: {id}`.
- Bloque `Matriz de Puestos`: tabla `Bloque | Productos | {fecha}` con fila de hora
  (ej. `06:00`) y fila de producto (ej. `Rigger PRG-IN | Jacob Whitesides 2019---Escenario5A   1 - T 1.00`),
  totales `Total Solicitados` y `Presupuesto por día`.
- Bloque `MODIFICACION DETALLE DE PEDIDO` con pestañas:
  - **Detalles**: `Estatus` (ro), `Evento Práctica` (checkbox), `Tipo personal`,
    `Título`, `Producto` (combo), `Lugar de Cita` (combo), `Dirección cita`,
    `Otro` (checkbox) + `Indicaciones especiales` (texto), `Cantidad` + `Turnos`
    (con hint de solo lectura, ej. `12 Horas por turno`), `Fecha cita` (fecha+hora+min),
    `Fecha liberación` (fecha+hora+min), `Fecha final cita` (fecha+hora+min),
    `Presentación por producto` (combo, `(Ninguno)` por defecto),
    `Completar con similares` (combo `NO`/`SI`).
  - **Reservaciones**: sección `Personal Confirmado` con campo `Nombre`
    (placeholder `Nombre completo / Alias`, autocompletado por IdContacto-Nombre),
    botones **`Confirmación Forzada`** y **`Confirmación Preasignada`**, icono
    `Imprimir lista de Asistencia` (impresora), tabla resultado
    `IdContacto | Nombre completo | Estatus` (con `X` para remover fila).
    Valor de `Estatus` tras forzar: **`CONFIRMADO FORZADO`**.
- Menú `Operaciones` (dentro del detalle de pedido): `Eventos`, `Lugares de Cita`,
  `Unidad de Negocio`, `Peps y Centros de Costos`, `Pedidos`, `Requisición de Personal`.

### 2.4 Catálogo de Puestos (`tc_puestos.aspx` / `tc_puestosww.aspx`)
Acceso: menú `Catálogos` → `Otros` → `Puestos`.

Listado: columnas `Id`, `Puesto`, `Unidad de negocio`, `H.antes Can. Conf.`,
`Pagadora`, `Regla`; filtro `Buscar en Puesto [Comienza con] [valor]`.

Formulario de edición — bloque `Información General`, campos en orden exacto:
1. `Id puesto` (ro)
2. `Duración Turno` (numérico con selector, ej. `12`)
3. `Puesto` (texto, nombre del puesto, ej. `Rigger PRG`)
4. `Id Und.Neg.` (combo, ej. `PRG`)
5. `Horas Entre Turnos` (numérico, ej. `0`)
6. `H.antes Can. Conf.` (numérico, ej. `72`)
7. `% Certeza Inicial` (numérico, ej. `1.00`)
8. `Porcentaje Minimo` (numérico, ej. `0.00`)
9. **`Confirmar Entre Seriados`** (combo booleano **`NO` / `SI`**) ← campo clave,
   corresponde a `tc_puestos.confirmar_entre_seriados`
10. `Días sin Confirmar` (numérico, ej. `120`)
11. `Requiere TimeScan` (combo `NO`/`SI`)
12. `Regla Asistencia` (combo, ej. `Regla de asistencia 1`)
13. `Título` (ro, derivado de la regla seleccionada)
14. `Retardo` (numérico, ej. `-0.50`)
15. `Falta` (numérico, ej. `-1.00`)
16. `Sueldo bruto` (numérico, ej. `100.00`)
17. `Tipo registro` (combo, ej. `Requiere un registro en tod[o...]`)
18. `Matricial` (checkbox)
19. `Ciclo de pago` (combo, ej. `(Ninguno)`)
20. `Régimen de pago` (combo, ej. `Honorarios Normales`)
21. `Id Pagaora` (combo, ej. `Tecno Inter, S.A. De C.V.`)
22. `Requiere inglés` (checkbox)
23. `Requiere Exp.Lab` (checkbox)
24. Botones `Confirmar` / `Cancelar`

Submenú `Catálogos → Pedidos`: `Clientes`, `Contactos clientes`, `Complejidad`,
`Eventos`, `Estatus detalle pedido`, `Estatus pedidos`, `Fases de eventos`,
`Lugares de cita`, `Movimientos pedidos`, `Pep`, `Presentación de producto`,
`Sociedades pagadoras`, `Sucursales`, `Tipo de personal`, `Unidades de negocio`.

Submenú `Catálogos → Otros`: `Ciudades`, `Códigos postales`,
`Colonias códigos postales`, `Claves para Puestos`, `Estados`, `Medios`,
`Parámetros del sistema`, `Periodicidad`, `Puestos`, `Productos`,
`Reglas de asistencias`, `Responsables`.

## 3. Mensajes exactos observados

| Contexto | Mensaje literal |
|---|---|
| Login sin autenticar | `El usuario debe estar autenticado.` |
| Forzar confirmación con puesto que NO permite entre-seriados | **`El puesto no permite Confirmación Entre Seriados`** (toast naranja, pantalla 011) |
| Forzar confirmación con puesto que SÍ permite entre-seriados | **`Registro agregado correctamente`** (toast, pantalla 040) |
| Estatus resultante de una confirmación forzada exitosa | **`CONFIRMADO FORZADO`** (columna `Estatus`, tabla de Reservaciones) |

## 4. Pedidos visibles en el grid (contexto de datos de prueba)

El listado de pedidos (pantalla 006) confirma la convención de nombres usada para
este escenario y sus variantes:

| Id | Título | Estatus | Unid.Neg. | PEP |
|---|---|---|---|---|
| 1051 | Jacob Whitesides 2019---Escenario5A | Liberado | PRG | Z-PEP-Temporal PRG |
| 1050 | Jacob Whitesides 2019---Escenario 5 | Liberado | Operaciones Inmuebles | Z-PEP-Temporal Operaciones Inmuebles |
| 1049 | Jacob Whitesides 2019-----Escenario 4 | Liberado | Seguridad | LT-AZ-2018-01-01N085LT-A |
| 1048 | Jacob Whitesides 2019---Escenario3 | Vigente | PRG | — |
| 1047 | Jacob Whitesides 2019---Escenario2 | Vigente | PRG | IT-PD-2015-08-27N085LT-A Test Day FIBA |

Esto confirma que el **pedido 1050** ("Escenario 5") corresponde al primer pedido de
la hoja (UN Operaciones Inmuebles / producto "Especialistas Estructuras Inmuebles"),
y el **pedido 1051** ("Escenario5A") corresponde al segundo pedido de la misma hoja
(UN PRG / producto "Riger"/"Rigger"), el que efectivamente se usa para probar el
forzado entre seriados en estas capturas. El sufijo "A" en el título es la
convención usada por QA para distinguir la segunda mitad del mismo escenario.

## 5. Qué significa "Entre Seriados" operativamente

"Entre Seriados" (en UI: **`Confirmar Entre Seriados`**) es una propiedad a nivel
**Puesto** (catálogo `tc_puestos`, columna `confirmar_entre_seriados`, boolean
NO/SI) que controla si una misma persona puede ser **confirmada por la fuerza**
(botón `Confirmación Forzada` en la pestaña `Reservaciones` del detalle de pedido)
para cubrir un día/turno de un pedido **distinto** al que originalmente la tenía
confirmada dentro de la misma semana/serie (seriado = bloque recurrente de días,
p. ej. lunes–viernes).

Flujo de negocio reproducido en el video:
1. Se crea un pedido seriado (lunes a viernes) y alguien confirma el bloque
   (p. ej. en el pedido 1050, UN Operaciones Inmuebles). Luego se cancela el
   detalle del miércoles, dejando el bloque con 4 días (lunes, martes, jueves,
   viernes) — ese miércoles queda "libre".
2. Se crea un **segundo pedido** distinto (1051, UN PRG) con cita exactamente ese
   miércoles liberado, y se intenta **forzar** la asignación de la misma persona
   que ya confirmó el bloque del primer pedido.
3. Si el **Puesto** del segundo pedido (ej. "Rigger PRG") tiene
   `Confirmar Entre Seriados = NO` (valor por defecto), el sistema **rechaza** el
   forzado con el mensaje `El puesto no permite Confirmación Entre Seriados` — es
   decir, no deja que un hueco de un seriado sea cubierto por fuerza con alguien
   que pertenece a otro pedido/serie distinto.
4. Si un administrador cambia esa propiedad del puesto a `Confirmar Entre Seriados
   = SI` (vía `Catálogos → Otros → Puestos`), repitiendo exactamente la misma
   prueba, el forzado **sí se permite**: se agrega el registro
   (`Registro agregado correctamente`) con `Estatus = CONFIRMADO FORZADO`.

## 6. Reglas de negocio nuevas / confirmadas (no explícitas, o solo implícitas, en el .md original)

- El control es **a nivel de Puesto**, no a nivel de pedido ni de operación global:
  dos puestos con el mismo nombre genérico ("Rigger") pero distinta Unidad de
  Negocio (Id 287 "Rigger PRG" vs Id 41 "Rigger" en Producción) tienen su propio
  valor independiente de `Confirmar Entre Seriados`.
- El bloqueo/permiso se evalúa específicamente en la acción **`Confirmación
  Forzada`** (no se probó/observó su efecto sobre `Confirmación Preasignada` en
  estas capturas).
- El mensaje de error es un **toast** (no bloquea el formulario, no es una alerta
  modal), de color naranja, posicionado arriba a la derecha del header.
- El estado resultante de una confirmación forzada se registra literalmente como
  `CONFIRMADO FORZADO` en la columna `Estatus` de la tabla `Personal Confirmado`
  — distinto del estado que tendría una confirmación preasignada normal (no se
  observó ese texto en estas capturas, solo el forzado).
- La edición de la propiedad `Confirmar Entre Seriados` requiere entrar como
  usuario con rol administrador (catálogos), distinto del usuario "Operacion"
  que gestiona pedidos — confirma una separación de permisos entre quien opera
  pedidos y quien configura catálogos de Puestos.
- El campo `H.antes Can. Conf.` (horas antes para poder cancelar/confirmar, valor
  `72`) y `Días sin Confirmar` (`120`) conviven en el mismo formulario que
  `Confirmar Entre Seriados`, sugiriendo que esa pantalla concentra varias reglas
  de negocio de confirmación/asistencia por puesto (retardo, falta, regla de
  asistencia, TimeScan, etc.) que deberían mapearse juntas al rediseñar el
  catálogo de Puestos en PeopleMovil.
