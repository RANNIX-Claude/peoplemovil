# Reconciliación te_pedidos/te_pedidos_detalle contra TE_Pedido/TE_Peddet (SQL Server real)

Comparación columna por columna de la tabla TRANSACCIONAL real (`TE_Pedido` 40 cols, `TE_Peddet` 67 cols, extraídas directo de `sql5063.site4now.net/db_a81e28_appscpfv2` vía conexión SQL) contra nuestro `te_pedidos`/`te_pedidos_detalle`. Aplicado como Migración 008.

## Decisión de arquitectura importante

`Pedidos`/`Pedidos2`/`Pedidos22` (que coinciden con `dbo_Pedidos` del Access y con lo que veníamos tratando como referencia) **no tienen ningún FK declarado en el motor** y usan IDs `int` con columnas de snapshot duplicadas (`Nombre_Cliente`, `Titulo_Sucursal`, etc.) — es casi seguro una tabla de **reporte/exportación desnormalizada**, no la fuente transaccional. `TE_Pedido` (IDs `decimal`, FKs reales a `TC_Sucursal`, `TC_UnidadNeg`, `TC_pep`, `TC_sociedadesPagadoras`...) es la tabla real, y coincide con las URLs vistas en capturas (`te_pedidoww.aspx`). A partir de ahora, `TE_Pedido`/`TE_Peddet` son la fuente de verdad para reconciliar el modelo, no `Pedidos`.

## Agregado en Migración 008 (gaps confirmados)

| Columna nueva | Tabla | Confirmado por |
|---|---|---|
| `sucursal_id` | te_pedidos | SQL Server (`TC_SucursalID`) **y** capturas (Escenario 1, 5, 5AB, 10) — doble confirmación |
| `sucursal_pagadora_id` | te_pedidos | SQL Server (`TC_SucursalPagId`) — distinto de `sociedad_pagadora_id` |
| `estatus_id` (+ catálogo `tc_estatus_pedido`) | te_pedidos | SQL Server (`TC_EstatusAutID`) — valores reales Vigente/Liberado/Cancelado/Procesado/Normal, confirmados también por capturas de Escenario 4. **No se reemplazó `status` (texto libre)** por riesgo de romper lógica ya construida — queda como catálogo documental en paralelo |
| `lugar_otro` + `lugar_otro_direccion` | te_pedidos | SQL Server (`TE_PedidoLugOtro`/`LugOtroDire`) |
| `titulo` (por línea) | te_pedidos_detalle | SQL Server (`TE_pedDetTitu`) **y** capturas (Escenario 1) |
| `lugar_cita_id` (por línea, distinto del de header) | te_pedidos_detalle | SQL Server (`ST_LugarId` → `TC_LugarCita`) |
| `lugar_otro` + `lugar_otro_descripcion` | te_pedidos_detalle | SQL Server (`TE_pedDetOtro`/`OtroDes`) — coincide con el checkbox "Otro" visto en Ciclo Completo |
| `fase_evento_id` (FK real, por línea) | te_pedidos_detalle | SQL Server (`TC_FaseEventoID`) — antes solo teníamos `fase_evento_str` (texto libre) a nivel detalle |
| `fecha_final_cita` | te_pedidos_detalle | SQL Server (`TE_PeddetFechafinal...`) **y** capturas (Escenario 1, 7) — el campo autocalculado que ya habíamos detectado visualmente |
| `fecha_fin_cita_oculta` | te_pedidos_detalle | SQL Server (`TE_PeddetFechafincitaoculta`) **y** capturas (Escenario 7: "Fecha Fin Cita Oculta") — campo interno/oculto distinto del visible |
| `completo` + `completo_con_preasignados` | te_pedidos_detalle | SQL Server (`TE_PeddetCompleto`/`CompletoConPreasigna`) **y** capturas (Escenario 4, popup de celda) — ahora se sincronizan automáticamente vía trigger desde los porcentajes ya calculados |
| `bloque` (flag booleano, distinto de `bloque_num`) | te_pedidos_detalle | SQL Server (`TE_pedDetBloque`, varchar2 Si/No) — el real tiene AMBOS: un flag Y un número de bloque (`TE_PeddetBloqueNum`, que además es texto/varchar12, no puramente numérico — ojo con eso si se usan códigos alfanuméricos de bloque) |

## Revisado pero NO agregado (baja prioridad / ambiguo, pendiente de decisión)

- `TE_PedidoTipo`, `TE_PedidoDes`, `TE_PedidoMonto`, `TE_Pedidoborrar` (soft-delete flag) — campos legacy de uso incierto, probablemente redundantes con `titulo`/`tipo_movimiento_id`/`subtotal`. No se replicaron.
- `TE_pedDetObser` (observaciones cortas, distinto de `indicaciones_especiales`), `TE_pedDetPuesFac` (posible "facturable por puesto" distinto de `facturable`), `TE_PeddetSegReser`, `TE_PeddetIdPuesto` (duplicado legacy sin FK de `puesto_id`), `TE_PeddetSucursal`/`TituloSucu`, `TE_PeddetUnidNegocio`/`TituloUnidadNego`, `TE_PeddetIdsociedad`/`TituloSociedad`, `TE_PeddetLugardireccion` (posible duplicado de `direccion_entrega`), `TE_PeddetPpagoEspecial` (flag booleano separado del monto `pago_especial`) — todos de utilidad incierta o redundantes; no replicados hasta confirmar con el usuario si se necesitan.
- Todas las columnas `TituloXxx`/`Nombre_Xxx` tipo snapshot (desnormalización legacy) — se resuelven con JOIN en el modelo nuevo, no se replican como columnas.

## Nota sobre tipos de datos legacy

Varias columnas "numéricas" en SQL Server usan tipos sueltos por convención GeneXus, no necesariamente con intención semántica (ej. `TE_pedDetTurnos` es `money`, no `decimal` — es solo cómo GeneXus tipó un valor decimal en ese momento). No se tomó esto como señal de diseño, solo se validó que nuestro tipo (`numeric`) sea compatible.
