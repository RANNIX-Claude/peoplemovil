# Walkthrough de pantallas — Escenario 13: Validar que no se puedan cancelar reservaciones (carpeta B)

> Fuente: `25 - P20190319_0000 Escenario 13 Validar que no se puedan cancelar reservaciones\` (144 PNGs, video YouTube `ZIwOvXHVffs`, 574s).
> NOTA: existe OTRA carpeta "05 - Escenario13" cubierta por otro agente en `SCREENSHOTS_ESCENARIO13_A.md`. Este documento cubre EXCLUSIVAMENTE la carpeta `25 - P20190319_0000 Escenario 13...` y no intenta reconciliar con el otro documento.

Muestra revisada: ~28 imágenes distribuidas uniformemente a lo largo de las 144 (001, 007, 013, 019, 025, 031, 037, 043, 049, 055, 061, 067, 073, 079, 085, 091, 097, 103, 109, 115–119, 121, 127, 133, 139, 142, 144).

## 1. Flujo observado

1. **001_00m00s.png** — Login RRHH (Usuario/Contraseña, checkboxes "Mantenerme Conectado" / "Recordar", botón "Ingresar"). Barra superior con imagen de fondo de concierto (branding OCESA).
2. **007_00m19s.png / 013_00m45s.png** — Pantalla **Pedidos** (`te_pedidow.aspx`), listado con columnas: `Id Pedido`, `Título`, `Estatus` (Vigente/Liberado), `Unidad de negocio`, `Sucursal`, `lugar`, `Responsable`. Barra de herramientas: botón "+" (nuevo), exportar XLS, exportar PDF, "Selecciona columnas", filtro "Buscar en" + "valor".
3. **019_01m02s.png** — Formulario **"Información General"** de un Pedido nuevo (`wp_pedido.aspx?INS,0`). Campos: Cliente*, Contacto, Sucursal*, Unidad de negocio*, PEP*, Evento*, Título, Lugar de cita*, Dirección lugar de cita, Otro (checkbox), Tipo de movimiento, Tipo de complejidad, Duración del evento (Días de show), Sociedad pagadora, **"Permitir cancelar confirmaciones"** (dropdown **SI/NO** — a nivel PEDIDO), Responsable*. Botones **Guardar** / **Regresar**.
   - Confirmado: el pedido de seguridad del escenario se crea con **"Permitir cancelar confirmaciones" = NO** (matching el guion: "indicando que no se puede cancelar el evento").
4. **025_01m19s.png / 031_01m52s.png** — Detalle de pedido (`wp_pedidodetalle.aspx`). Pestaña **"Detalles"**: Estatus, Evento Práctica (checkbox), Tipo personal* (Operativo), Título*, Producto (dropdown de puestos: Seguridad-IN, etc.), Lugar de Cita, Dirección cita, Otro, Indicaciones especiales, Bloque por producto, Facturable (SI/NO). Columna derecha: Cantidad, Turnos, Fecha cita*, Fecha liberación, Fecha final cita, Presentación por producto (dropdown de uniformes), Completar con similares (SI/NO), Fase del evento, **"Permitir cancelar" (dropdown SI/NO — a nivel DETALLE, independiente del flag del pedido)**. Botones "Agregar Detalle" / "Cancelar".
   - Confirmado: el flag de cancelación existe en **dos niveles**: Pedido ("Permitir cancelar confirmaciones") y Detalle ("Permitir cancelar"). El escenario manipula ambos de forma independiente, confirmando el texto de `ESCENARIOS_PRUEBA_FREELANCE.md` ("Marcar el detalle de pedido como que sí se puede cancelar" mientras el pedido dice que no).
5. **037_02m12s.png / 043_02m24s.png** — Portal del empleado (`gamexamplelogin1.aspx` tras login), pantalla de **"Confirmación de eventos"**: lista de eventos disponibles con botón de confirmar.
6. **049_02m39s.png / 055_03m15s.png / 061_03m30s.png / 067_03m50s.png** — Vista de "Detalles de pedido" ya liberado, con cabecera de acciones: **"Editar pedido" | "Liberar Pedido" | "Cancelar Pedido" | "Regresar"**, número de pedido ("PEDIDO No.: 775"), **Matriz de Puestos** (tabla Bloque/Productos/fecha con celda coloreada: verde = completo, naranja = parcial, rojo = vacío/pendiente, mostrando "Seguridad-IN N - T1"), Total Solicitados, Presupuesto por día.
7. **079_04m32s.png** — Captura de la hoja Excel **"Scripts de Prueba Freelance"** (pestaña "Escenario 13"), confirmando el guion de prueba real usado y empleados QA concretos:
   - 65690 **Egarcia** (Edwin Jael García Barranco…)
   - 64257 **Cjavier** (Javier Alejandro Cepeda…)
   - 63331 **Fsalvador** (Salvador Flores Alvarado)
   Esto son los 3 empleados de seguridad reales usados en las iteraciones del escenario (uno por cada intento de cancelación: >72h bloqueado por pedido, >72h bloqueado por detalle editado, >72h permitido).
8. **085_04m45s–119_07m05s** — Pestaña **"Reservaciones"** dentro de "MODIFICACION DETALLE DE PEDIDO": sub-panel **"Personal Confirmado"** con campo de búsqueda "Nombre completo / Alias", botones **"Confirmación Forzada"** y **"Confirmación Preasignada"**, enlace **"Imprimir lista de Asistencia"** (ícono impresora), y grid con columnas `IdContacto`, `Nombre completo`, `Estatus` (valores vistos: `CONFIRMADO`, `CONFIRMADO FORZADO`, `Cancelado` resaltado en rosa/rojo).
9. **133_07m56s.png** — Segundo detalle de pedido creado con fecha de cita **19/03/19 05:00** (menor a 72h respecto al momento de prueba), con botón **"Cancelar"** visible dentro del detalle de evento confirmado (vista del portal del empleado).
10. **142_08m47s.png** — Vista final del Pedido 775: Matriz de Puestos muestra dos columnas de fecha (19/03 y 30/03) cada una con su propio contador de "Seguridad-In" (rojo=1-T1, naranja=3-T1), Total Solicitados por columna (1, 3), Presupuesto por día (300, 1800).
11. **144_08m52s.png** — Estado final de Reservaciones del segundo detalle: empleado **63331 — Salvador Flores Alvarado** con Estatus **"Cancelado"** (resaltado en rosa). Esto corresponde al último paso del guion: tras sumar una hora a la fecha de la cita (cambio de horario), al empleado que había confirmado se le permitió cancelar.

## 2. Catálogos / valores de dropdown observados

- **Permitir cancelar confirmaciones** (nivel Pedido): `SI` / `NO`.
- **Permitir cancelar** (nivel Detalle): `SI` / `NO`.
- **Facturable**: `SI` / `NO`.
- **Completar con similares**: `SI` / `NO`.
- **Producto** (puesto, ejemplo visto): `Seguridad-IN`.
- **Estatus de reservación** visto en grid: `CONFIRMADO`, `CONFIRMADO FORZADO`, `Cancelado`.
- **Estatus de Pedido**: `Vigente`, `Liberado`.

## 3. Mensajes / textos exactos

No se capturó en la muestra revisada un cuadro de diálogo o alerta JS explícito con el texto de bloqueo de cancelación (p. ej. "no se puede cancelar"); es posible que el bloqueo se manifieste simplemente **ocultando o deshabilitando el botón "Cancelar"** en el portal del empleado cuando no corresponde, en vez de mostrar un mensaje de error. Esto es coherente con lo observado: en la pantalla 133 el botón "Cancelar" SÍ aparece visible para el evento con fecha <72h (el guion indica que en ese caso el sistema "no debe dejar" cancelar), sugiriendo que la validación podría ocurrir al enviar el formulario, no al renderizar el botón. Se recomienda revisión del video completo o un re-muestreo más denso entre 067–121 si se requiere el texto literal del mensaje de error del portal.

## 4. Reglas de negocio / campos NUEVOS no capturados explícitamente en el schema o en el texto del escenario

1. **Dos flags independientes de "permitir cancelar"**: uno a nivel `pedido` ("Permitir cancelar confirmaciones") y otro a nivel `detalle de pedido` ("Permitir cancelar"). El esquema actual (`reset_database.sql`) debe modelar ambos — confirmar si existen columnas equivalentes en `pedidos` y `detalle_pedido` (o tablas análogas); si no existen, es un hallazgo a incorporar.
2. **Ventana de 72 horas** para permitir cancelación aparece ligada al campo "Fecha cita" del detalle, calculada dinámicamente (no es un campo almacenado) — coincide con la decisión D4 del CLAUDE.md (`horas_lookahead_autocancel`), pero aquí se usa para habilitar/deshabilitar la cancelación manual del empleado, no solo para autocancelación de preasignados. Confirmar que el mismo parámetro se reutiliza para esta regla o si se requiere un segundo parámetro distinto (p. ej. `horas_minimas_cancelacion_manual`).
3. **Notificación por correo al cambiar el horario de un evento confirmado** ("Validar primero que se envía un correo electrónico a los confirmados avisando del cambio de horario") — no se visualizó el correo en las capturas muestreadas, pero el flujo de edición de "Fecha cita" en un detalle con confirmados ya existentes debe disparar un evento de notificación. Confirmar la existencia de esta notificación en el backlog de Netlify Functions.
4. **Botón sugerido en el propio guion**: "Agregar un botón de liberación inmediata" (anotación del QA junto al paso "Liberar el detalle del pedido") — sugiere que en la versión Lobo liberar un detalle no era inmediato/intuitivo; considerar UX explícita de "Liberar ahora" en PeopleMovil.
5. **Estatus de reservación `CONFIRMADO FORZADO`** visto explícitamente en el grid (coincide con el enum D7 del CLAUDE.md `forzada`, pero el label de UI combina "Confirmado" + "Forzado" en un solo estatus visual — revisar mapeo UI↔enum).
6. **Matriz de Puestos con color-coding** (verde=completo, naranja=parcial, rojo=vacío) por celda Bloque×Fecha — confirma que la UI de "cobertura de puesto" debe ser una matriz visual con semáforo, útil para el dashboard de PeopleMovil.

## 5. Archivos fuente citados

`001_00m00s.png`, `007_00m19s.png`, `013_00m45s.png`, `019_01m02s.png`, `025_01m19s.png`, `031_01m52s.png`, `037_02m12s.png`, `043_02m24s.png`, `049_02m39s.png`, `055_03m15s.png`, `061_03m30s.png`, `067_03m50s.png`, `073_04m08s.png`, `079_04m32s.png`, `085_04m45s.png`, `091_05m02s.png`, `097_05m40s.png`, `103_06m12s.png`, `109_06m34s.png`, `115_07m01s.png`, `116_07m02s.png`, `117_07m03s.png`, `118_07m04s.png`, `119_07m05s.png`, `121_07m10s.png`, `127_07m30s.png`, `133_07m56s.png`, `139_08m40s.png`, `142_08m47s.png`, `144_08m52s.png`
(todos dentro de `25 - P20190319_0000 Escenario 13 Validar que no se puedan cancelar reservaciones\`)
