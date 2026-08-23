# PeopleMovil — Modelo de Datos

Documento de referencia del schema `public` de `db/reset_database.sql`. Cada tabla lista aquí su columna clave y el PRC/regla del sistema Lobo/AppSCPF que la origina, para trazar cada campo hasta código real, no interpretación.

---

## Convenciones globales

- Toda tabla tiene `tenant_id uuid` (excepto `cat_plan_suscripcion`, catálogo compartido) + auditoría (`created_at/by`, `updated_at/by`).
- RLS activo en TODAS las tablas: solo filas del tenant activo en `app.current_tenant`.
- Tablas append-only (bloquean UPDATE/DELETE por trigger): `eventos_biometricos`, `consentimientos`, `reservacion_bitacora`.
- Timestamps de servidor forzados en `eventos_biometricos` (nunca se confía en el reloj del cliente).
- Todos los parámetros de negocio (certeza, márgenes, penalizaciones) viven en catálogos, **nunca** en código.

---

## Multi-tenant + suscripciones

| Tabla | Rol | PRC origen |
|---|---|---|
| `tenants` | Cada empresa cliente de PeopleMovil | [N] Nuevo |
| `cat_plan_suscripcion` | Catálogo FREE / PRO con capacidades como columnas booleanas | [N] Nuevo |
| `suscripciones` | Plan activo por tenant (fecha_desde, fecha_hasta) | [N] Nuevo |
| `cat_parametros_globales` | Parámetros por tenant: retención, `horas_lookahead_autocancel`, `horas_gracia_confirmacion`, `certeza_inicial_default` | Reemplaza los únicos números hardcodeados del KB (72h y 8h del PRC_CancelacionAutomaticaPreasignados) |

Función `plan_activo(tenant)` devuelve el plan vigente. Función `verificar_limite(tenant, recurso)` es la que llaman los triggers de `cat_sitios`, `empleados`, `pedidos` y `eventos_biometricos` antes de aceptar la operación — el enforcement de plan vive en la base, no en frontend.

---

## Catálogos

| Tabla | Contenido | PRC / origen |
|---|---|---|
| `cat_bancos` | Bancos para dispersión | [L] Lista mexicana estándar |
| `cat_sociedades_pagadoras` | Empresas pagadoras (19 reales seed) | [L] KB Lobo |
| `cat_sociedades_propias` | Razones sociales del grupo (6 reales seed) | [L] KB Lobo |
| `cat_unidades_negocio` | Subdivisión organizacional | [L] KB Lobo |
| `cat_sitios` | **Generaliza `[G]`** sucursal/foro/tienda/obra/oficina/evento. `tipo_sitio` es el discriminador. | [L]+[G] |
| `cat_puestos` | **Todos los parámetros de negocio por rol**: `porcentaje_certeza_inicial`, `porcentaje_minimo`, `horas_entre_turnos`, `horas_antes_cancelar`, `penalizacion_retardo`, `penalizacion_falta`, `requiere_biometrico`, `regimen_pago`, `ciclo_pago`, `sexo_requerido` | TC_Puestos*, PRC_ObtenerCertezaPuesto, PRC_ValidaEmpPuesto, PRC_Noempalmereservacion |
| `cat_uniformes` | Uniformes por producto/UN (29 reales seed) | [L] KB Lobo |
| `cat_clientes` | Clientes finales / marcas | [L] KB Lobo |
| `cat_productos` | Líneas de producto/evento | [L] KB Lobo |

---

## Personas y consentimiento

| Tabla | Rol | PRC origen |
|---|---|---|
| `candidatos` | Persona en reclutamiento. UNIQUE por (tenant, rfc) y (tenant, curp) → duplicado bloqueado | PRC_ValidaRfcCurp |
| `empleados` | Persona activa. Folio consecutivo por tenant (siguiente_folio) | PRC_AltaEmpleadosCursoInduccion + PRC_FoliosConsecutivos |
| `empleados_plazas` | **N:N** empleado ↔ puesto. `porcentaje_puntualidad` es la certeza acumulada **por puesto** — no global. | PRC_ObtenerCertezaPuesto |
| `avisos_privacidad` | Versión del aviso publicada por tenant | [N] Nuevo (LFPDPPP 2026) |
| `consentimientos` | Append-only. `revoca_id` permite marcar revocaciones sin borrar | [N] Nuevo. `consentimiento_vigente(empleado)` devuelve el último no revocado |
| `estaciones_checado` | Punto físico dentro de un sitio | [L] TC_LugarCita/estación |
| `dispositivos_biometricos` | Serie + tipo (fijo/móvil) + estación | [N] Nuevo — la serie es lo que le da trazabilidad legal al registro |

Función `promover_candidato_a_empleado(candidato_id)` implementa PRC_AltaEmpleadosCursoInduccion.

---

## Operativo (asignación + asistencia)

| Tabla | Rol | PRC origen |
|---|---|---|
| `pedidos` | Requisición de personal por evento/proyecto. Trigger `tg_pedidos_plan` verifica que el tenant tiene plan con módulo asignación. | [L] |
| `pedidos_detalle` | Desglose del pedido por puesto y cantidad | [L] |
| `reservaciones` | **Tabla central del sistema.** Una fila por persona-turno. Concentra asignación + asistencia + pago + `regla_aplicada` (auditoría de qué validación disparó). | [L] TE_Reservacion + PRC_Noempalmereservacion + PRC_ValidaEmpPuesto |
| `eventos_biometricos` | Append-only. Un INSERT por cada lectura del lector. Timestamp de servidor forzado. Correcciones = nuevo registro con `corrige_id` al original. | [N] |
| `reservacion_bitacora` | Bitácora append-only de cambios de estado | [L] |

### Triggers de reservación
- `tg_res_valida`: **antes de INSERT** verifica `verificar_limite(tenant, 'asignacion')`, luego `valida_emp_puesto` (PRC_ValidaEmpPuesto), luego `valida_no_empalme` (PRC_Noempalmereservacion). Rellena `regla_aplicada` con la regla que decidió el rechazo o `reservacion_creada_ok`.
- `tg_evbio_force_ts`: fuerza `ts_servidor = now()` sin importar lo que envíe el cliente.
- `tg_evbio_valida`: fuerza consentimiento vigente + verifica `checador_movil` en plan si `medio_asistencia = 'geolocalizacion'`.
- `tg_evbio_no_mut`: bloquea `UPDATE`/`DELETE`.

---

## Fiscal (folios, nómina, REPSE)

| Tabla | Rol | PRC origen |
|---|---|---|
| `folios` | Contador consecutivo **por tipo de entidad** (empleado, factura_honorarios, pedido…). Nunca un global. | PRC_FoliosConsecutivos |
| `repse_registros` | Número REPSE por cliente/tenant. `reservaciones.repse_registro_id` liga cada asignación al registro que aplica. | [N] Reforma 2021 |
| `nominas_periodo` | Periodo cerrado (semanal/quincenal/mensual) por tenant | PRC_CalculoNomina |
| `nomina_detalle` | Cálculo por empleado dentro del periodo: `reservaciones_cnt`, `monto_bruto`, `penalizaciones_aplicadas`, `monto_neto`, `salario_diario_promedio`, `precauciones` (jsonb con banderas antes de dispersar) | PRC_CalculoNomina, PRC_CalculoNominaIndividual, PRC_ReportePrecaucionesNomina, PRC_Dispersion* |

Funciones:
- `siguiente_folio(tenant, tipo)`: PRC_FoliosConsecutivos.
- `calcular_nomina_periodo(nomina_id)`: PRC_CalculoNomina + PRC_CalculoNominaIndividual + agregación de `PRC_ReportePrecaucionesNomina` en `precauciones` jsonb.
- `reporte_precauciones_nomina(tenant)`: lista empleados sin banco, sin CLABE, sin pagadora, sin régimen.
- `cancelacion_automatica_preasignados()`: job periódico que implementa PRC_CancelacionAutomaticaPreasignados sobre todos los tenants.

---

## Enums

| Enum | Valores | Uso |
|---|---|---|
| `regimen_pago_enum` | Nomina, Honorarios Normales, Honorarios Asimilables | `cat_puestos`, `empleados`, `nomina_detalle` |
| `ciclo_pago_enum` | Semanal, Quincenal, Mensual | `cat_puestos`, `empleados`, `nominas_periodo` |
| `tipo_sitio_enum` | sucursal, tienda, obra, foro, oficina, evento, otro | `cat_sitios` |
| `tipo_dispositivo_enum` | fijo, movil | `dispositivos_biometricos` |
| `medio_asistencia_enum` | biometrico, manual, geolocalizacion | `reservaciones`, `eventos_biometricos` |
| `estado_reservacion_enum` | disponible, preasignado, confirmado_opcional, confirmado_voluntario, forzada, procesado, cancelado | `reservaciones` |
| `estado_asistencia_enum` | pendiente, asistencia, retardo, falta | `reservaciones` |
| `estatus_pago_enum` | pendiente, calculado, dispersado, pagado, cancelado | `reservaciones`, `nomina_detalle` |
| `sexo_enum` | M, F, X | `cat_puestos.sexo_requerido`, `candidatos.sexo`, `empleados.sexo` |
| `plan_codigo_enum` | FREE, PRO | `cat_plan_suscripcion`, `suscripciones` |

---

## Checklist de principios respetados

- ✅ Ningún parámetro de negocio hardcodeado — todos en catálogos editables (`cat_puestos.*` + `cat_parametros_globales.*`).
- ✅ `eventos_biometricos` append-only (trigger `tg_evbio_no_mut`).
- ✅ `consentimientos` append-only.
- ✅ `reservacion_bitacora` append-only.
- ✅ Timestamp forzado a servidor en `eventos_biometricos`.
- ✅ RLS por `tenant_id` en 27 tablas.
- ✅ Trigger de plan por tenant (no bypasseable desde API).
- ✅ Consentimiento vigente vinculado a cada evento biométrico (trigger `tg_evbio_valida`).
- ✅ `regla_aplicada` documentado en cada rechazo automático.
- ✅ Folios consecutivos por tipo de entidad, no un global.
