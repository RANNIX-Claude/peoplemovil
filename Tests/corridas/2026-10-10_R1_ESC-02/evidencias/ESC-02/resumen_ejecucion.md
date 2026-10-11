# Resumen de ejecución — Corrida R1, Escenario ESC-02

**Fecha:** 2026-10-10/11
**Ambiente:** https://peoplemovil00.netlify.app (tenant "eventos", cuenta admin.demo01@peoplemovil.demo, rol Administrador)
**Ejecutor:** qa-tester (sin lectura de código fuente; solo navegador + BD vía Supabase MCP)
**Bitácora completa (JSONL, append-only):** `Tests/corridas/2026-10-10_R1_ESC-02/bitacora.jsonl`
**Evidencias (capturas):** `Tests/corridas/2026-10-10_R1_ESC-02/evidencias/ESC-02/`

## Folios de prueba creados

- **Pedido #199** — `te_pedidos.id = edf2f107-0c9e-4274-9bb8-dd3578e1ee94` — título "QA-R1-ESC02 - Dreamstate Mexico 2018", fecha_evento = 2018-09-01 (fecha real del evento en BD). **Se dejó en BD como evidencia de un hallazgo colateral** (ver abajo): quedó invisible en la pantalla Pedidos y sitios por su fecha_evento antigua.
- **Pedido #200** — `te_pedidos.id = 32c3119c-fbd8-4546-9ab7-a1b8b74346e2` — título "QA-R1-ESC02b - Dreamstate Mexico 2018 (fecha futura)", idéntico al #199 en todos los campos salvo fecha_evento = 2026-12-21 (para poder continuar probando Pedido Detalle). **Este es el pedido usado para los pasos 13 en adelante.**

Ambos son datos de prueba legítimos del flujo normal de la app, no se borraron.

## Hallazgos colaterales (fuera de los 26 pasos, encontrados en el camino)

1. **El pedido #199 quedó invisible en la pantalla "Pedidos y sitios"** (lista y buscador) porque su `fecha_evento` (2018-09-01, la fecha real del evento en BD) cae fuera de la ventana de datos que la pantalla carga — la tabla, ordenada por fecha_evento descendente, se corta en el registro más antiguo con fecha 2018-09-21 sin cargar más atrás (sin paginación ni "cargar más" visible), aunque la BD tiene 199 pedidos en total. Confirmado con prueba de control (buscar "Camila Cabello Fotografo", sí encontrado) y reproducido también en el módulo "Árbol de reservaciones". Por eso se creó el pedido #200 con fecha futura para continuar la prueba.
2. **CRÍTICO — el combo "Producto" del modal "Agregar detalle al pedido" solo ofrece productos con `id_puesto` NULL.** Verificado en BD: de 83 productos vigentes del tenant, 30 tienen `id_puesto` asignado (incluyendo los 2 productos reales de esta prueba, ambos `vigente=true` y correctamente ligados a UN PRG) y **ninguno de esos 30 aparece en el combo**; el combo muestra en su lugar exactamente los 53 productos con `id_puesto` NULL. Al elegir cualquiera de esos productos (los únicos seleccionables) y pulsar "Agregar registro" con el formulario completo, no pasa nada: sin mensaje de error, sin cierre de modal, sin fila nueva en `te_pedidos_detalle` (confirmado por SQL, 2 intentos). **Esto bloquea por completo la posibilidad de agregar cualquier renglón a la matriz de puestos de cualquier pedido en el estado actual de la app**, y es la causa raíz de que los pasos 15 y 20-26 no se pudieran ejecutar literalmente.

## Resultado por paso

| # | Resultado | Observado | Verificación BD |
|---|---|---|---|
| 1 | CUMPLE | Click en "+ Nuevo pedido" abrió el modal "Registro de pedido" con todos los campos esperados. | — |
| 2 | CUMPLE | Combo Cliente mostró "Ocesa Promotora, S.A. de C.V." entre la lista alfabética (también existe "Ocesa Presenta, S.A. de C.V." como opción distinta). Se seleccionó. | — |
| 3 | CUMPLE | Combo Contacto quedó habilitado con 1 sola opción: "Laura Méndez Ruiz · 5555123401". | `tc_contactos_cliente`: único contacto del cliente, nombre y teléfono coinciden exactamente. |
| 4 | CUMPLE | Combo Evento mostró 10 eventos de Ocesa Promotora; se eligió "Dreamstate Mexico 2018". El título del pedido SÍ se autocompletó (confirma que es editable). El campo Fecha del Evento (obligatorio) NO se autocompletó con la fecha real del evento — se capturó a mano 01/09/2018 (fecha real en BD), dato no especificado por el caso. | `tc_eventos.fecha_inicio = 2018-09-01` |
| 5 | CUMPLE | Al elegir UN PRG, el combo PEP se habilitó con 9 PEPs reales de esa UN. | — |
| 6 | PARCIAL | Tras elegir el PEP, Sitio/Inmueble y Lugar de Cita quedaron vacíos (sin autocompletar nombre/dirección). Coincide con el aviso del caso: ningún PEP de PRG tiene sociedad propia ni lugar predeterminado en BD. | — |
| 7 | NO CUMPLE | El caso esperaba 2 tipos de movimiento (Pedido y Servicio Interno). La UI real muestra 3: "Orden de servicio (se factura)", "Pedido facturable a cliente (se factura)", "Servicio interno (no factura)". Ninguno se llama literalmente "Pedido". | — |
| 8 | PARCIAL | Se seleccionó "Servicio interno (no factura)". No existe un campo "Facturable" editable separado; el estado va embebido en el texto de la opción. No se pudo validar el punto "El tipo Pedido se factura" porque no existe una opción llamada "Pedido". | — |
| 9 | CUMPLE | Combo Tipo de complejidad mostró exactamente 6 opciones sin duplicados. Se usó "Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares" como equivalente aprobado. | — |
| 10 | CUMPLE | No hay un campo único "Duración del Evento": son 2 campos, Tipo de duración (3 valores reales: Shows Sueltos / Tarifa por Mes / Tarifa por Semana) y Duración (días) numérico. Se usó Shows Sueltos + 1 día. | — |
| 11 | CUMPLE | Click real en el checkbox "Permitir cancelaciones" (estaba marcado por default) lo dejó desmarcado. | — |
| 12 | **CUMPLE** | Al pulsar Aceptar, la UI mostró "✓ Pedido #200 creado" (folio consecutivo real). | **VERIFICADO EN BD** (`te_pedidos` folio=200): `tipo_complejidad_id`, `tipo_duracion_id`, `duracion_dias=1` y `permitir_cancelaciones=false` quedaron guardados exactamente como se capturaron — **las 3 precondiciones críticas del paso 12 se cumplen**. `sociedad_pagadora_id` y `lugar_cita_id` quedaron NULL (esperado, sin dato predeterminado). `contacto_nombre` (columna snapshot) quedó NULL pese a que `contacto_id` sí se guardó correctamente — la ficha de "Información principal" sí mostró el contacto igual (resuelve por `contacto_id`, no por el snapshot). |
| 13 | NO CUMPLE | El caso esperaba que "Tipo de Personal" mostrara "Staff" y "Operativo". La UI real muestra: "Personal freelance / eventual", "Personal interno de oficina", "Personal de planta". Ningún valor literal "Staff" ni "Operativo" en ningún campo del modal. | — |
| 14 | NO EJECUTABLE | No existe la opción "Staff". Se usó "Personal freelance / eventual" como sustituto funcional más cercano para poder continuar. | — |
| 15 | **NO CUMPLE** | El producto "Asistente Operador PRG" NO aparece en el combo Producto (probado 2 veces, incl. recarga completa de página). El catálogo mostrado NO está filtrado por PRG ni por ninguna UN — es la misma lista de 53 productos sin puesto ligado en cualquier caso. | **VERIFICADO EN BD**: el producto existe, `vigente=true`, `id_unidad_negocio=PRG`, `matricial=true` — pero tiene `id_puesto` NULL en los únicos productos que el combo SÍ muestra... en realidad el producto real sí tiene id_puesto asignado, por eso queda excluido del combo (ver hallazgo crítico). |
| 16 | NO EJECUTABLE | No se pudo asociar la jornada al producto real. Con el producto sustituto usado (sin puesto ligado) no hay duración de turno que mostrar. | — |
| 17 | PARCIAL | La UI sí permite capturar Fecha de cita, Fecha final de cita y Fecha de liberación sin error de validación visible. No se pudo verificar en BD porque el registro nunca se persiste. | 0 filas en `te_pedidos_detalle` |
| 18 | CUMPLE | El combo "Presentación por producto" solo tiene "— sin presentación —", sin ninguna opción real. Cumple literalmente "NO se muestran presentaciones". | — |
| 19 | NO CUMPLE | El combo "Fase del evento" quedó en "— sin fase —" (no auto-seleccionado), pese a que el pedido sí tiene complejidad y duración de días de show guardados. Probado con producto sustituto, no con el real. | — |
| 20 | NO EJECUTABLE | "Agregar Registro" no crea el renglón para ningún producto del combo (ver hallazgo crítico #2). No se puede distinguir si el bloqueo es la regla de negocio esperada o el bug de catálogo. | 0 filas en `te_pedidos_detalle` |
| 21 | NO EJECUTABLE | No se encontró ningún control de "Bloque" independiente — solo "+ Agregar fecha al bloque" dentro del mismo renglón. | — |
| 22 | NO EJECUTABLE | Bloqueado por la misma causa raíz; no hay presupuesto que leer. | 0 filas |
| 23 | NO EJECUTABLE | El modal sí abre correctamente, pero ningún alta se completa. | — |
| 24 | NO CUMPLE | "Asistente Aux A PRG" tampoco aparece en el combo Producto, misma causa raíz. | Verificado: `vigente=true`, UN=PRG, `matricial=true` en BD, pero excluido del combo. |
| 25 | NO EJECUTABLE | Mismo hallazgo que el paso 21. | — |
| 26 | NO EJECUTABLE | **VERIFICADO EN BD**: `te_pedidos_detalle` tiene 0 filas para folio 200 y 0 filas para folio 199. No se pudo crear ningún bloque ni producto en la matriz — no hay 2 bloques que comparar. | 0 filas |

## Conclusión

El alta de pedido (pasos 1-12) funciona correctamente y las 3 precondiciones críticas del paso 12 (complejidad, duración/días de show, permitir_cancelaciones) se verificaron guardadas correctamente en BD. A partir del paso 13, el caso de prueba presenta varias discrepancias de nomenclatura ya esperadas (Tipo de Personal, Tipo de Movimiento) y, de forma más grave, un **bug confirmado y reproducible que bloquea por completo el alta de cualquier detalle de pedido** (matriz de puestos): el selector de Producto del modal "Agregar detalle al pedido" excluye sistemáticamente cualquier producto con puesto ligado — exactamente los productos que se necesitan para operar el sistema, incluidos los 2 productos reales de esta prueba. Esto impidió ejecutar literalmente los pasos 15 y 20-26.
