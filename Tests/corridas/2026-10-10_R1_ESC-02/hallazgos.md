# Hallazgos — Corrida R1, Escenario ESC-02

### H-002 — "Tipo de movimiento" no coincide con el caso (3 valores reales, no 2)
- Escenario / paso: ESC-02 / P7, P8
- Clasificación: CAMBIO_NOMENCLATURA
- Descripción: la UI real muestra "Orden de servicio (se factura)", "Pedido facturable a cliente (se factura)", "Servicio interno (no factura)". El caso esperaba 2 opciones ("Pedido"/"Servicio Interno") y un campo "Facturable" editable separado, que no existe como tal (el estado facturable va embebido en el texto de la opción).
- Evidencia: `bitacora.jsonl` pasos 7-8; `evidencias/ESC-02/resumen_ejecucion.md`
- Causa raíz: nomenclatura de catálogo/UI, no es un defecto de código.
- **Decisión: Aceptado (se versiona el caso)** · Aprobó: Roberto Aguilar Cota (usuario) · Fecha: 2026-10-11 — no se agrega opción literal "Pedido" ni campo "Facturable" separado; la UI real (3 opciones, estado facturable embebido en el texto) queda como comportamiento válido.
- Caso versionado en `Tests/escenarios/ESC-02_pedido_prg_complejidad_dias_show.yaml` (pasos 7-8, bloque `decision_negocio`).
- Estado: **Resuelto (versionado)**

### H-003 — "Tipo de Personal" no usa los textos "Staff"/"Operativo"
- Escenario / paso: ESC-02 / P13, P14
- Clasificación: CAMBIO_NOMENCLATURA
- Descripción: `tc_tipos_personal` tiene 3 claves reales (freelance/interno/staff) con descripciones "Personal freelance / eventual" / "Personal interno de oficina" / "Personal de planta". El texto literal "Staff"/"Operativo" no existe en ningún campo, pero la clave `staff` sí implementa correctamente el gating de negocio real (Staff solo visible si el pedido tiene complejidad — `SitiosAsignacion.jsx` línea 350) — verificado releyendo el código y re-probando en vivo tras un primer pase que usó el sustituto incorrecto (`freelance`).
- Evidencia: `bitacora.jsonl` pasos 13-14, entrada de corrección (paso 0, intento 5)
- Causa raíz: nomenclatura de catálogo (`tc_tipos_personal.descripcion`), no de código.
- **Decisión: Aceptado (se versiona el caso)** · Aprobó: Roberto Aguilar Cota (usuario) · Fecha: 2026-10-11 — no se renombran las descripciones; "Personal de planta"/"Personal freelance / eventual"/"Personal interno de oficina" quedan como la nomenclatura real vigente para Staff/Operativo/Interno.
- Caso versionado en `Tests/escenarios/ESC-02_pedido_prg_complejidad_dias_show.yaml` (paso 13, bloque `decision_negocio`).
- Estado: **Resuelto (versionado)**

### H-004 — Catálogo `tc_tipos_personal` triplicado
- Escenario / paso: ESC-02 / P13
- Clasificación: ~~BUG~~ → **Falso positivo de diagnóstico** (reclasificado 2026-10-11)
- Descripción original: 9 filas en BD para solo 3 claves reales, interpretado como duplicado dentro del tenant.
- **Decisión: Aprobado (limpieza) — NO ejecutada tras reverificar.** Aprobó: Roberto Aguilar Cota (usuario) · Fecha: 2026-10-11. Al preparar la limpieza se encontró que la consulta SQL original del hallazgo (`select id, clave, descripcion from tc_tipos_personal`) se corrió **sin filtro de `tenant_id`**, vía el MCP de Supabase (que usa el rol de servicio y no aplica RLS). Las 9 filas son correctas y esperadas: 4 tenants distintos (eventos/construcción/seguridad/BTL), cada uno con su propia fila por clave (D6 — multi-tenant por columna `tenant_id`, ver `CLAUDE.md`). Dentro de un mismo tenant no hay duplicados (eventos: 3 filas, una por clave). Ejecutar la "limpieza" aprobada (dejar 1 fila global por clave) habría **mezclado catálogos de tenants distintos y roto el aislamiento multi-tenant** — no se ejecutó.
- Evidencia: `select id, tenant_id, clave, descripcion from tc_tipos_personal order by clave, tenant_id` (2026-10-11) — 9 filas, agrupadas correctamente por tenant.
- **Hallazgo residual real, de severidad mucho menor, informativo**: los tenants construcción/seguridad/BTL (002/003/004) solo tienen 2 de las 3 claves (`freelance`/`staff`), les falta la fila `interno` ("Personal interno de oficina") que sí tiene el tenant eventos — gap de datos menor, no un bug de aislamiento. Se deja documentado en `CLAUDE.md` §11; no se actúa sin que el usuario decida si aplica a esos giros (construcción/seguridad/BTL pueden legítimamente no tener "personal interno de oficina" como categoría).
- Estado: **Cerrado — reclasificado como falso positivo; no se tocó la base**

### H-005 — Ningún puesto matricial de PRG tiene tarifa (bloquea todo el flujo Staff)
- Escenario / paso: ESC-02 / P15-P26
- Clasificación: GAP_MIGRACION · Severidad: Alta
- Descripción: `tp_sueldos_matriciales` tenía 0 filas para cualquier puesto de la UN PRG (los 6 preexistentes y los 2 insertados para esta prueba — "Asistente Operador PRG" y "Asistente Aux A PRG"). Esto dejaba vacío el combo de Producto al elegir Tipo de Personal=Staff para cualquier pedido de PRG, bloqueando el alta de todo el bloque de personal Staff de esa unidad de negocio.
- Evidencia: SQL (0 filas); captura del combo vacío; `bitacora.jsonl`
- Causa raíz: migración de datos incompleta. La Migración 022 solo sembró 54 filas (de las 652 vigentes reales que trae el Excel) para 5 puestos de la UN "Producción" (Runner/Productor) — PRG y las otras ~37 unidades de negocio quedaron en 0, pese a que la fuente real sí traía sus tarifas.
- **Decisión: Aprobado** · Aprobó: Roberto Aguilar Cota (usuario) · Fecha: 2026-10-11 — alcance elegido: catálogo completo (todas las UN con tarifa real disponible, no solo PRG).
- **Corrección aplicada**: el usuario compartió `Catalogos Sueldos Matriciales.xlsx` (el mismo citado en 022/031). Se cruzó contra `tc_puestos`/`tc_unidades_negocio`/`tc_tipos_complejidad`/`tc_tipos_duracion_evento`/`tc_fases_evento` reales y se aplicó la Migración `033_sueldos_matriciales_prg_y_otras_un_reales` (`apply_migration`, 2026-10-11): 63 filas nuevas para 14 puestos matriciales (8 de PRG — incluidos los 2 productos reales de esta prueba —, 5 de Producción, 1 de Teatros y Salones), tomadas literalmente del Excel, sin inventar montos. Se excluyeron explícitamente las tarifas que usan el esquema de complejidad viejo (IDs 1-6, no vigente) para no mezclar catálogos.
- **Verificado end-to-end en el navegador** (https://peoplemovil00.netlify.app, admin.demo01, pedido #200 folio 32c3119c-fbd8-4546-9ab7-a1b8b74346e2): con Tipo de Personal="Personal de planta" (Staff real) el combo Producto ahora muestra los 2 productos reales de PRG; se agregó un renglón real a la matriz de puestos (verificado en `te_pedidos_detalle`). Detalle completo en `Tests/regresion/H-005_sueldos_matriciales_prg.md`.
- **Gap residual, documentado no inventado**: quedan sin tarifa 80 puestos matriciales del Excel — algunos porque el legado real nunca les asignó una tarifa vigente (p.ej. Productor C, los 3 Stage Manager restantes, varios Ingeniero de Audio/Luces de PRG), y otros porque aún no existen en `tc_puestos` de este proyecto (13 puestos reales de la UN "Asdeporte" del legado, y ~9 variantes de nomenclatura ambigua en PRG/Producción como "Encargado de Luces" vs "Encargado de Iluminación"). No se crearon puestos nuevos ni se forzaron matches ambiguos — fuera del alcance aprobado de este hallazgo.
- Estado: **Resuelto** (alcance aprobado: PRG + Producción + Teatros y Salones con tarifa real disponible)

### H-006 — Pedidos con fecha de evento antigua desaparecen de las listas (colateral)
- Escenario / paso: ESC-02 / colateral (no asociado a un paso numerado)
- Clasificación: BUG · Severidad: Media
- Descripción: "Pedidos y sitios" y "Árbol de reservaciones" no muestran pedidos con `fecha_evento` antigua (confirmado invisible: pedido #199, `fecha_evento`=2018-09-01) pese a existir en BD — corte aparente sin paginación alrededor de 2018-09-21.
- Evidencia: `bitacora.jsonl` paso 0, intentos 1-2; prueba de control con un folio antiguo sí localizable por buscador exacto
- **Decisión: Aprobado** · Aprobó: Roberto Aguilar Cota (usuario) · Fecha: 2026-10-11
- **Causa raíz confirmada**: `SitiosAsignacion.jsx` cargaba una sola vez los 100 pedidos más recientes por `fecha_evento` y el buscador (`busqueda`) filtraba solo sobre ese arreglo ya cargado en memoria — nunca contra la base de datos. Cualquier folio/título fuera de esos 100 era "no encontrado" sin aviso, aunque existiera.
- **Corrección aplicada**: cuando el campo de búsqueda tiene texto, se dispara (debounce 300ms) una consulta directa a `te_pedidos` con `folio.eq.<n> OR titulo.ilike.%texto%`, hasta 100 resultados. Con el campo vacío se mantiene el listado original de los 100 más recientes.
- **Verificado end-to-end** (dev local): buscar "199" ahora encuentra el pedido #199 (antes 0 resultados); buscar "Camila Cabello" sigue funcionando igual que antes (sin regresión). Detalle en `Tests/regresion/H-006_buscador_pedidos_antiguos.md`.
- **Fuera de alcance, documentado**: "Árbol de reservaciones" sigue limitado a `fecha_evento >= hoy-30días` — es una vista jerárquica de próximas reservaciones sin cuadro de búsqueda ni promesa de histórico completo, no comparte la causa raíz del buscador roto. No se modificó.
- Estado: **Resuelto**

---

**Nota de corrección metodológica:** el primer pase de ejecución (qa-tester, subagente ciego sin lectura de código) reportó un "bug crítico bloqueante" en el paso de Agregar Registro. Al re-verificar como qa-analista (con lectura de código, releyendo `SitiosAsignacion.jsx`), se determinó que ese hallazgo original era un **falso positivo de interpretación**: el sistema sí muestra un mensaje de validación claro ("Elegí un producto (define el puesto)."), que el primer pase no capturó en su evidencia. La causa raíz real quedó documentada en H-005.
