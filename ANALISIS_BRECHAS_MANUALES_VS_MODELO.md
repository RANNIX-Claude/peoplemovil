# Análisis de brechas — Manuales de usuario vs. modelo de datos

Auditoría de las pantallas descritas en `documentacion-referencia/Manual Usuario/` (sistema legado "Lobo"/SCPF/OCESA) y en las guías de `documentacion-referencia/*_guia.docx` contra el esquema actual en `db/reset_database.sql`. Objetivo: identificar qué datos captura cada pantalla, si el modelo de datos ya los contempla, y qué falta.

Metodología: se extrajo el texto de cada `.docx` y, donde el texto era vago ("llenar los campos solicitados"), se extrajeron y revisaron las capturas de pantalla embebidas para leer las etiquetas de campo reales. Cada campo se contrastó contra un resumen condensado de las ~90 tablas del esquema (`tc_`=catálogo, `te_`=entidad/transaccional, `tr_`=relación, `tp_`=parámetros/precios, `tl_`=log).

---

## 1. Secciones/módulos cubiertos por los manuales

| # | Módulo | Manuales fuente |
|---|---|---|
| 1 | Alta de candidatos | Sprint 01 — 1.01 |
| 2 | Requisición de personal | Sprint 01 — 1.11 |
| 3 | Administración de catálogos | Sprint 01 — 9.01 |
| 4 | Usuarios, roles y perfiles | Sprint 01 — 9.03 |
| 5 | Calendario de entrevistas | Sprint 02 — 1.02 |
| 6 | Reporte de candidatos registrados / Revisión de perfiles | Sprint 02 — 1.03 / 1.13 (misma pantalla) |
| 7 | Publicación de vacantes | Sprint 02 — 1.12 |
| 8 | Registro de resultado de evaluaciones | Sprint 02 — 1.14 |
| 9 | Seguimiento a proceso de selección | Sprint 02 — 1.15 |
| 10 | Registro y validación de pedidos | Sprint 01/03 — 2.01, 2.02 |
| 11 | Consulta y confirmación de reservaciones | `pedidos_reglas.docx`, `consulta_reservaciones_guia.docx` |
| 12 | Nómina (extras, folios, cálculo, cierre) | `Nómina_guia.docx` |
| 13 | Alta masiva de empleados (inducción → plaza) | `Alta_masiva_empleados_guia.docx` |

Duplicados detectados sin contenido nuevo: `funcionalidad desarrollada 1.02.docx` y `1.02 (1).docx` (idénticos); `consulta_reservaciones_guia.docx` y `(1)` (idénticos); `1.13` resultó ser la misma pantalla que `1.03` pese al nombre distinto — confirmar con el equipo si de verdad son la misma vista o si falta documentar "Revisión de perfiles" como algo distinto.

---

## 2. Hallazgo más crítico: no existe módulo de Usuarios/Roles/Permisos — ✅ RESUELTO (Migración 005)

El manual 9.03 describe un módulo completo (usuarios internos, roles jerárquicos, permisos por aplicación — framework tipo GAM). El esquema no tenía ninguna tabla para esto: no había `te_usuarios`, `tc_roles`, `tr_usuario_rol`, `tc_permisos`, `tr_rol_permiso`, ni columnas de autenticación (password hash, bloqueo, expiración, último login).

Esto era grave porque decenas de tablas (`te_tenants`, `te_candidatos`, `te_empleados`, `te_pedidos`, `te_extras_nomina`, `te_aclaraciones`, etc.) ya tienen columnas `creado_por uuid`, `modificado_por uuid`, `actor_id uuid`, `autorizado_por uuid` sin tabla a la que referenciar.

**Resuelto en `db/reset_database.sql` (Migración 005, al final del archivo):** se agregaron `te_usuarios`, `tc_roles`, `tr_usuario_rol`, `tc_permisos`, `tr_rol_permiso` y la función `tiene_permiso()`, con los 5 roles reales confirmados en capturas de GAM (`Administrador`, `Lobo`, `Operacion` como roles internos con RBAC granular por módulo+acción; `Candidato` es público/prospecto y se resuelve vía `te_magic_links` + `te_candidatos` -- no vía `te_empleados`, ver nota en Migración 005 -- no necesita fila en `te_usuarios`; `Unknown` es el default implícito sin asignación). Ver `documentacion-referencia/MENU_Y_ROLES.md` para el detalle capturado del sistema real.

**Decisión importante:** `creado_por`/`modificado_por`/`actor_id`/`autorizado_por` se dejaron **sin FK duro** (igual que `te_empleados.auth_user_id`) porque esas columnas pueden apuntar a dos poblaciones distintas de `auth.users.id` de Supabase según el contexto: personal interno (`te_usuarios`) o freelancer autoinscribiéndose desde su propio portal (`te_empleados`) — un FK simple hacia una sola tabla rompería la otra población. Ver el comentario en la Migración 005 para el detalle.

---

## 3. Brechas consolidadas por módulo

### Candidatos y reclutamiento

| Dato faltante | Dónde se vio | Nota |
|---|---|---|
| Estado civil, nacionalidad, ¿extranjero?, cartilla militar | 1.01, 1.03/1.13 | Agregar columnas a `te_candidatos` |
| Dirección estructurada (calle, num. ext., colonia_id/cp_id, ciudad_id, estado_id) | 1.01, 1.03/1.13, Alta masiva | Los catálogos ya existen (`tc_estados_mx`, `tc_ciudades`, `tc_codigos_postales`, `tc_colonias_cp`); falta el FK desde `te_candidatos` (hoy solo `direccion` texto libre) |
| Contacto de emergencia (nombre, apellidos, teléfono, parentesco) | 1.01, Alta masiva | No existe ninguna tabla en todo el esquema — crear `te_contacto_emergencia` (candidato_id/empleado_id, nombre, apellido_paterno, apellido_materno, telefono, parentesco) |
| Datos médicos (enfermedad crónica, cirugía, tratamiento, tipo de sangre) | 1.01, 1.03/1.13 | No hay columnas en `te_candidatos` |
| Datos escolares (último grado de estudios, estatus, otro idioma, institución) | 1.01, 1.03/1.13 | No hay columnas ni tabla |
| Celular diferenciado, WhatsApp, Facebook, Twitter, Instagram | 1.03/1.13 | Solo existe `telefono`/`correo` en `te_candidatos` |
| % de perfil completado | 1.01 | Nice-to-have, calculable en runtime |
| Seguimiento/bitácora de candidato (tipo movimiento, fecha, observaciones) | 1.01 | Existe `te_movimientos_empleado` (solo empleados) y `tl_log_altas_bajas`; falta equivalente a nivel candidato |
| `fuente_reclutamiento` como texto libre | 1.01 | Ya existe catálogo `tc_como_se_entero`; convertir a FK |
| Nombre/clave del grupo de citas | 1.02 | `te_grupos_citas` no tiene columna `nombre`/`clave` |
| Examen psicométrico (URL) e imagen de vacante | 1.02, 1.12 | No existen en `te_vacantes`/`te_vacante_plantilla` |
| FK publicación → plantilla de vacante | 1.12 | `te_vacantes` no referencia `te_vacante_plantilla` |
| Contadores "Postulados"/"Grupos" | 1.12 | Derivables por COUNT, no requiere columna nueva |
| Observaciones estructuradas de examen psicométrico/entrevista | 1.14 | Hoy solo `tr_postulacion_candidato_vacante.evaluacion` (jsonb) — evaluar columnas dedicadas si se necesita reportar/filtrar |
| Cobertura de `estado_postulacion_enum` | 1.14, 1.15 | Verificar que incluya todas las etapas vistas (Recepción, Entrevista, Curso Inducción, Evento Prueba, En Proceso, Aceptado) |
| Tabla de asistencia/calificación/observaciones de Evento Prueba | 1.15 | No existe equivalente a `tr_asistencia_curso` para `te_eventos_prueba` — crear `tr_asistencia_evento_prueba` |
| `te_eventos_prueba` incompleta | 1.15, Alta masiva | Faltan `imagen_url`, `fecha_presentacion`, `hora_presentacion`, `lugar`, `presentacion_producto`, `como_llegar`, `indicaciones` |
| Asignación candidato↔evento prueba | Alta masiva | `te_candidatos.paso_evento_prueba` es solo booleano; falta tabla relacional explícita (puede resolverse junto con `tr_asistencia_evento_prueba` de arriba) |
| `te_cursos_induccion` sin `puesto_id`/`vacante_id` | 1.15, Alta masiva | Confirmado por dos auditorías independientes — inconsistente con `te_eventos_prueba`, que sí los tiene |
| Firma de contrato (prerrequisito de alta masiva) | Alta masiva | No existe tabla/estado dedicado; se podría reusar `te_documentos_candidato` con tipo "Contrato" pero sin estado de firma explícito |
| Lugar de nacimiento | Alta masiva | Nice-to-have |

### Requisición de personal

| Dato faltante | Nota |
|---|---|
| Detalle multi-fila de puestos + cantidad por requisición | `te_requisicion_personal` solo tiene `cantidad_estimada` agregado; falta `te_requisicion_personal_detalle` (requisicion_id, puesto_id, cantidad) |
| Responsable como FK | Hoy es texto libre (`solicitante_nombre/correo/telefono`); `te_pedidos` ya usa `responsable_id → tc_responsables`, conviene unificar |
| Contacto por pedido en el listado de requisiciones | Nice-to-have |

### Administración de catálogos

| Dato faltante | Nota |
|---|---|
| Campo "Imagen" en catálogos (Lugar de Cita, Unidad de Negocio) | Resoluble con el patrón genérico `te_adjuntos`, falta definir la convención |
| Catálogo de "Estatus Detalle Pedido" | `te_pedidos.status` es texto libre y `te_pedidos_detalle` no tiene estatus en absoluto |
| "Lugar de Cita" como catálogo independiente de `tc_sitios` | Aclarar si es distinto de sitio operativo; si sí, falta tabla propia con domicilio/imagen |

El patrón genérico de catálogo (clave/título + activo) ya está bien soportado por la arquitectura actual (decenas de tablas `tc_*`).

### Pedidos y reservaciones — ✅ ACTUALIZADO (Migraciones 003 + 006)

**Corrección importante (2026-10-05):** esta sección estaba desactualizada. Auditó solo el `CREATE TABLE` inicial de `te_pedidos`/`te_pedidos_detalle`, sin ver que una migración posterior en el mismo archivo ("Expandir te_pedidos/te_pedidos_detalle con los campos del Lobo") ya había agregado casi todo lo que aquí se listaba como faltante. Se re-verificó contra el esquema **efectivo** (CREATE + todos los ALTER) y contra datos reales del backend (`Ocesa03_j_m.accdb`, ver `HALLAZGOS_ACCDB_DATOS_REALES.md`). Resultado:

**Ya estaba resuelto** (confirmado campo por campo contra `dbo_Pedidos`/`dbo_Pedidos Detalle` reales): `tipo_movimiento_id`, `tipo_complejidad_id`, `tipo_duracion_id` + `duracion_dias`, `partida_presupuestal_id`, `permitir_cancelaciones`, `status_facturacion` (enum), `status_detalle` por línea (enum), `fecha_cita`/`fecha_liberacion`/`fecha_vigencia_preasignados`/`fecha_fin_bloque`, `producto_id`, `facturable`, `pago_especial`, `facturar_servicio_interno` (`factura_servicio_interno`), `bloque_num`, `completar_productos_similares`, `turnos`, `indicaciones_especiales`.

**Resuelto ahora en Migración 006** (confirmado contra el Access real, no estaba cubierto):
- `te_pedidos.sociedad_pagadora_id → tc_sociedades_pagadoras` (antes solo `id_sociedad_propia`)
- `te_pedidos.evento_id → tc_eventos` (catálogo nuevo: agrupa varios pedidos bajo un mismo evento/show, confirmado por `IdEvento`/`Titulo Evento` en `dbo_Pedidos`)
- `te_pedidos.lugar_cita_id → tc_lugares_cita` (catálogo nuevo, confirmado distinto de `tc_sitios` por `dbo_Lugares de Cita`)
- `te_pedidos.contacto_id` ya existía como columna pero sin FK — ahora referencia `tc_contactos_cliente` (catálogo nuevo)
- `te_pedidos_detalle.presentacion_id → tc_presentaciones_producto` (el catálogo ya existía, solo faltaba conectarlo)

**Pendiente, no resuelto todavía:**
- Bitácora propia a nivel pedido (hoy solo existe `te_reservacion_bitacora` para reservaciones)
- `tc_sociedades_pagadoras` sin FK UUID a `tc_sociedades_propias` (solo campos legacy enteros)
- Permisos granulares por usuario+Unidad de Negocio+Sucursal (`dbo_PermisosPaginasInternas` del Access real) — más fino que el RBAC por rol de la Migración 005, ver `HALLAZGOS_ACCDB_DATOS_REALES.md` sección 7

### Nómina y empleados — ✅ Desglose fiscal resuelto (Migración 006)

El desglose fiscal del recibo de honorarios (**el hallazgo "crítico" de esta sección**) ya se agregó a `te_nomina_detalle` con los nombres y significados reales confirmados contra `dbo_Pagos Honorarios`: `impuesto_marginal` (IM), `cuota_fija` (CF), `subsidio_acreditable` (SA), `credito_general` (CG), `impuesto_diario` (ID), `impuesto_total` (IT), `iva`, `retencion_iva` (RIVA), `retencion_isr` (RISR), `dias_laborados`, más 3 banderas de validación (`cumple_regla_cuenta_banco`, `cumple_regla_ultimo_pago_reciente`, `cumple_regla_recibe_pago_periodo_actual`). `salario_diario_promedio` ya existía y corresponde a SDP.

Pendiente, no resuelto: catálogo de conceptos de "Extras" (hoy `te_extras_nomina.concepto` es texto libre) y columna "Turnos Extra" en `te_extras_nomina`.

El resto del flujo de nómina (periodo, cierre, precauciones, dispersión, cuentas bancarias, bitácora de operaciones) ya está bien cubierto por `te_nominas_periodo`, `te_nomina_detalle`, `te_extras_nomina`, `te_cuentas_bancarias_empleado`, `tp_nomina_precauciones_catalogo`, `te_proceso_cierre_nomina`, `tl_log_cierre_nomina`, `tl_detalle_operacion`.

---

## 4. Lista priorizada de acciones

**Crítico (bloquea integridad referencial o funcionalidad base):**
1. ✅ RESUELTO — Crear módulo de Usuarios/Roles/Permisos (`te_usuarios`, `tc_roles`, `tr_usuario_rol`, `tc_permisos`, `tr_rol_permiso`). Ver sección 2 arriba y Migración 005 en `db/reset_database.sql`.
2. ✅ RESUELTO (ya estaba, migración previa) — `te_pedidos_detalle` completo: estatus por línea, `producto_id`, fechas por renglón, flags de facturación/cancelación. Ver sección "Pedidos y reservaciones" arriba.
3. ✅ RESUELTO (Migración 006) — `te_pedidos` con FK a sociedad pagadora, evento y lugar de cita. Tipo de movimiento/complejidad/duración/partida presupuestal ya estaban de una migración previa.
4. Crear tabla `te_requisicion_personal_detalle` (puesto + cantidad por línea). -- sigue pendiente.
5. Crear tabla de contacto de emergencia (candidato/empleado). -- sigue pendiente.
6. Crear tabla `tr_asistencia_evento_prueba` y completar `te_eventos_prueba` (imagen, fechas de presentación, lugar, indicaciones). -- sigue pendiente.
7. ✅ RESUELTO (Migración 006) — desglose fiscal del recibo de nómina agregado a `te_nomina_detalle` con nombres reales confirmados.
8. ✅ RESUELTO (Migración 006) — catálogos `tc_contactos_cliente` y `tc_eventos` creados y conectados desde `te_pedidos`.

**Importante:**
9. Dirección estructurada (candidato/empleado) enlazada a los catálogos geográficos ya existentes.
10. Datos médicos y escolares del candidato.
11. Estado civil, nacionalidad, cartilla militar en `te_candidatos`.
12. `te_cursos_induccion` sin `puesto_id`/`vacante_id`.
13. Imagen y URL de examen psicométrico en vacantes; FK publicación→plantilla.
14. ~~`fecha_liberacion`~~ ✅ ya existía a nivel detalle. Bitácora propia a nivel pedido -- sigue pendiente.
15. Catálogo de conceptos de Extras de nómina.
16. `tc_sociedades_pagadoras` sin FK a `tc_sociedades_propias`.
17. Verificar cobertura completa de `estado_reservacion_enum` y `estado_postulacion_enum`.

**Nice-to-have:**
18. `fuente_reclutamiento` como FK en vez de texto libre.
19. % de perfil completado, folios en listados de inducción, lugar de nacimiento, campo "Imagen" en catálogos genéricos, columna "Turnos Extra" en Extras, campo "Contacto" por pedido en listados de requisición.

---

*Generado a partir de la auditoría de 20 manuales/guías de usuario contra `db/reset_database.sql` (≈90 tablas). Ver `documentacion-referencia/Manual Usuario/` y `documentacion-referencia/*_guia.docx` para el detalle original de cada pantalla.*
