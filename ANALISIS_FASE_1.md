# PeopleMovil — Fase 1: Análisis del dominio

**Fuente:** todo lo aquí descrito viene destilado de la documentación de referencia (`PeopleMovil_2.0_Spec_para_ClaudeCode.md`, `PeopleMovil_2.0_Funcionalidad_Completa.md`, `Glosario_Reglas_de_Negocio_PeopleMovil.md`, `reglas_negocio_PRC_completo.txt`, `reglas_transacciones_nucleo.txt`, catálogos `.xlsx` reales del sistema Lobo/AppSCPF). Nada inventado.

Leyenda de origen: **[L]** heredado del sistema Lobo/AppSCPF · **[N]** nuevo por reforma 2026-2027 · **[G]** generalización para servir a cualquier vertical.

---

## 1. Entidades principales

### 1.1 Núcleo de personas
- **`candidatos` [L]** — persona en proceso de reclutamiento. Datos completos de identidad, domicilio, características físicas relevantes al puesto, resultado de evaluación, asistencia a inducción y a evento prueba. Se promueve a `empleados` cuando confirma inducción (`PRC_AltaEmpleadosCursoInduccion`).
- **`empleados` [L]** — persona ya activa. Ligada a banco (`IdBanco`), sociedad pagadora (`IdEmpresaPagadora`), puesto principal (`IdPuesto`), sitio (`IdSucursal`), ciclo de pago, régimen fiscal, tenant.
- **`empleados_plazas` [L]** — relación N:N: un empleado puede desempeñar varios puestos, cada uno con su propia certeza histórica. La certeza **no es global** a la persona, es **por rol** (regla del glosario #1).
- **`consentimientos` [N]** — append-only. Autorización explícita del titular para tratar sus datos biométricos, versionada por aviso de privacidad vigente. Es lo que da valor legal al registro (spec sec. 2.1).
- **`peps` [L]** — personas políticamente expuestas, para AML en reclutamiento.

### 1.2 Estructura organizacional
- **`cat_sitios` [L][G]** — dónde ocurre el trabajo. `tipo_sitio`: tienda, obra, foro, oficina, sucursal, evento. Generaliza el `Sucursal` heredado.
- **`cat_unidades_negocio` [L]** — subdivisión organizacional dentro del sitio.
- **`cat_sociedades_propias` [L]** — razones sociales del grupo (con flag `genera_factura`, `genera_orden_servicio`).
- **`cat_sociedades_pagadoras` [L]** — quién efectivamente paga a cada empleado.
- **`cat_clientes` [L]** — clientes finales / marcas para las que se opera.
- **`cat_productos` [L]** — línea de producto/evento a la que pertenece un pedido.

### 1.3 Catálogos de puesto y operación
- **`cat_puestos` [L]** — todos los parámetros de negocio por rol viven aquí: `certeza_inicial`, `porcentaje_minimo_para_reservar`, `horas_entre_turnos` (margen), `horas_antes_para_cancelar`, `penalizacion_retardo`, `penalizacion_falta`, `requiere_biometrico`, `regimen_pago`, `ciclo_pago`, `sexo_requerido` (nullable), duración de turno, pago default.
- **`cat_uniformes` [L]** — asignación por producto/unidad de negocio.
- **`cat_bancos` [L]** — para dispersión de pago.
- **`cat_lugares_cita` [L]** — puntos físicos de encuentro/checado.
- **`cat_parametros_globales` [N]** — parámetros a nivel tenant que no son por puesto (retención de registros, `horas_lookahead_autocancel` = 72h, `horas_gracia_confirmacion` = 8h — únicos números que aparecían hardcodeados en el KB original y que aquí se mueven a catálogo).

### 1.4 Trabajo asignado y ejecutado
- **`pedidos` [L]** — requisición de personal para un evento/proyecto. Sitio, unidad de negocio, sociedad, costo total esperado, status, título.
- **`pedidos_detalle` [L]** — un pedido desglosado por puesto requerido: puesto, cantidad, costo, status, título.
- **`reservaciones` [L]** — **tabla central del sistema.** Una fila por persona-turno. Concentra asignación + asistencia + pago + cumplimiento. Campos clave: pedido/producto/puesto, estación entrada/salida, medio de asistencia (biométrico vs manual), hora entrada/salida real, estado de asistencia, estado de reservación, penalización aplicada, folio de pago, regla aplicada, cita inicio/fin, duración en turnos, dispositivo id, consentimiento id, geolocalización (solo móvil), tenant id.
- **`reservacion_bitacora` [L]** — todos los movimientos de una reservación, para auditoría.
- **`eventos_biometricos` [N]** — registro **append-only** crudo de cada lectura del lector (fijo o móvil). Timestamp de servidor. FK a estación, dispositivo, consentimiento vigente. Correcciones = nuevo registro con `corrige_id` al original.

### 1.5 Dispositivos y estaciones
- **`estaciones_checado` [L]** — punto físico dentro de un sitio donde se checa.
- **`dispositivos_biometricos` [N]** — número de serie, modelo, tipo (fijo/móvil), estación asignada, tenant.

### 1.6 Fiscal y pago
- **`folios` [L]** — contador consecutivo **por tipo de entidad** (empleado, factura honorarios, pedido, etc.). Nunca un solo global (`PRC_FoliosConsecutivos`, glosario #5).
- **`nominas_periodo` [L]** — periodo de nómina cerrado (quincenal, semanal, según ciclo).
- **`nomina_detalle` [L]** — cálculo por empleado en el periodo, régimen aplicado, monto, penalizaciones, folio de pago asignado, estatus de dispersión.
- **`repse_registros` [N]** — número REPSE que aplica a una asignación cuando se pone personal a disposición de un tercero fuera de su objeto social.

### 1.7 Multi-tenant + suscripción
- **`tenants` [N]** — cada empresa cliente de PeopleMovil.
- **`cat_plan_suscripcion` [N]** — FREE y PRO, con límites codificados como filas (no en código).
- **`suscripciones` [N]** — plan activo por tenant, con vigencia. La validación de límites lee de aquí, siempre.
- **`usuarios` [L→N]** — usuarios de la app (coordinadores, capturistas, admins). Auth por Supabase Auth. `rol` y `permisos` por tenant.

---

## 2. Procesos clave

### 2.1 Ciclo de reclutamiento
```
Alta candidato
  → validación RFC/CURP duplicado (PRC_ValidaRfcCurp)
  → publicación de vacante / calendario de entrevistas
  → revisión de perfil + evaluación
  → asistencia a inducción (PRC_ActualizaAsistenciaCursoInduccion)
  → asistencia a "evento prueba" (PRC_ContarIntegrantesEventoPrueba)
  → promoción a empleado (PRC_AltaEmpleadosCursoInduccion)
      · copia expediente completo
      · asigna folio consecutivo (PRC_FoliosConsecutivos)
      · captura y persiste consentimiento biométrico si aplica
  → entrega de uniformes
  → empleado activo, elegible para reservación
```

### 2.2 Ciclo operativo (pedido → nómina)
```
Coordinador crea pedido
  → desglose por puesto (pedido_detalle)
  → jerarquía: sitio → unidad de negocio → evento/periodo → fecha → producto
  → coordinador preasigna candidatos elegibles
      · valida certeza mínima por puesto (PRC_ValidaEmpPuesto + PRC_ObtenerCertezaPuesto)
      · valida no-traslape/margen (PRC_Noempalmereservacion)
      · valida sexo requerido si aplica
      · si algo falla → reservación se rechaza y se registra la regla aplicada
  → trabajador confirma
      · si no confirma en la ventana → cancelación automática (PRC_CancelacionAutomaticaPreasignados)
  → cita → trabajador se presenta y checa
      · fijo: lector USB + agente local (DigitalPersona/ZKFinger)
      · móvil: geolocalización + selfie
      · en ambos casos: INSERT en eventos_biometricos con timestamp de servidor + consentimiento vinculado
      · reservación actualiza estado de asistencia (asistencia/retardo/falta)
      · si retardo/falta → aplica penalización configurada por puesto
  → cierre de periodo
      · PRC_ReportePrecaucionesNomina detecta faltas de cuenta bancaria, régimen, pagadora
      · coordinador resuelve precauciones
      · PRC_CalculoNomina calcula por asistencia real (no por lo programado)
      · dispersión diferenciada por régimen (PRC_DispersionNomina/HA/HN)
      · folios de honorarios asignados a cada reservación pagada
      · notificación al trabajador
```

### 2.3 Ciclo de consentimiento biométrico
```
Publicación de aviso de privacidad v.N (por tenant)
  → cada empleado firma consentimiento v.N (append-only)
  → cada evento biométrico apunta al consentimiento vigente
  → revocación = nuevo registro apuntando al original (sin borrar)
  → si consentimiento revocado + intento de checado biométrico → se rechaza y se ofrece captura manual con auditoría
```

---

## 3. Qué automatiza el sistema (sin intervención humana)

Traducciones directas de PRCs GeneXus, implementadas como funciones/triggers en Postgres en Fase 2.

| Automatismo | PRC origen | Efecto |
|---|---|---|
| Validación de traslape entre turnos | `PRC_Noempalmereservacion`, `PRC_NoEmpalmeFechasEnBloque` | Rechaza reservación si el empleado no tiene el margen configurado por su puesto entre otros turnos activos. |
| Validación de certeza mínima por plaza | `PRC_ValidaEmpPuesto` + `PRC_ObtenerCertezaPuesto` | Rechaza reservación si el % de puntualidad del empleado en ese puesto es menor al mínimo definido para el puesto. |
| Validación de sexo requerido | `PRC_ValidaEmpPuesto` (sexo requerido en `TC_Puestos`) | Rechaza si el puesto exige sexo y el empleado no cumple. |
| Ventana de cancelación por puesto | `PRC_ValidacionesCancelarReservacion` | Bloquea cancelación si faltan menos horas que `horas_antes_para_cancelar` del puesto (con excepción de `ConfirmadoForzado`). |
| Cancelación automática de preasignados sin confirmar | `PRC_CancelacionAutomaticaPreasignados` | Libera cupos que llevan >8h sin confirmar cuando faltan <72h al evento. Corre como job programado. |
| Cálculo de puntualidad acumulada | `PRC_PorcentajeRetardosFaltas`, `PRC_ActuValoAsisCand` | Recalcula certeza tras cada reservación cerrada. |
| Cálculo de nómina por asistencia real | `PRC_CalculoNomina`, `PRC_CalculoNominaIndividual` | Salario diario promedio = suma de montos / reservaciones (asistencia + retardo + falta). |
| Dispersión diferenciada por régimen | `PRC_DispersionNomina`, `PRC_DispersionHN`, `PRC_DispersionNomHA` | Nómina normal vs honorarios normales vs asimilados van por rutas separadas. |
| Reporte de precauciones antes de cierre | `PRC_ReportePrecaucionesNomina` | Detecta cuenta bancaria faltante, régimen no capturado, pagadora no asignada — antes de dispersar. |
| Folios consecutivos por tipo | `PRC_FoliosConsecutivos` | Contadores independientes; nunca un contador global. |
| Validación de duplicado RFC/CURP | `PRC_ValidaRfcCurp` | Bloquea alta si ya existe. |
| Registro de "regla aplicada" | patrón `ReglaAplicada` heredado | Cada rechazo automático guarda **qué regla lo disparó** — clave para explicabilidad legal ante STPS/juicio laboral. |

Además, **automatismos nuevos [N]** que no venían del sistema Lobo:

| Automatismo nuevo | Efecto |
|---|---|
| Enforcement append-only vía RLS | Postgres RLS niega `UPDATE`/`DELETE` sobre `eventos_biometricos`, `consentimientos`, `reservacion_bitacora`. |
| Timestamp forzado a servidor | Triggers `BEFORE INSERT` en tablas de asistencia sobrescriben cualquier timestamp cliente con `now()`. |
| Verificación de plan del tenant | Trigger `BEFORE INSERT` en `cat_sitios` y `empleados` valida el plan activo del tenant contra `cat_plan_suscripcion` antes de permitir la operación. |
| Bloqueo biométrico sin consentimiento vigente | Trigger `BEFORE INSERT` en `eventos_biometricos` valida FK a consentimiento no revocado; si no hay, rechaza. |

---

## 4. Límites por plan de suscripción

Se aplican a nivel **tenant** (empresa cliente), no a nivel usuario. La suscripción vive en `suscripciones` y se lee cada vez que se dispara un límite.

| Capacidad | FREE / Piloto | PRO |
|---|---|---|
| Sitios máximos | **1** | Ilimitado |
| Trabajadores activos máximos | **15** | Ilimitado |
| Usuarios de la app | 1 admin + 1 capturista | Ilimitado |
| Checador fijo (lector USB + agente local) | ✅ | ✅ |
| Checador móvil (GPS + selfie) | ❌ | ✅ |
| Módulo de pedidos/asignación | ❌ | ✅ |
| Motor de certeza y penalizaciones | ❌ (se registra checado; sin scoring) | ✅ |
| Nómina/honorarios | ❌ | ✅ |
| REPSE (registro por reservación) | ❌ | ✅ |
| Dispersión diferenciada nómina/honorarios/asimilados | ❌ | ✅ |
| Reportes de cumplimiento (STPS/IMSS ready) | Básico (registros crudos) | Completo (evidencia lista para auditoría) |
| Retención mínima de registros | 5 años configurable | 5 años configurable |
| Multi-tenant + RLS | ✅ (obligatorio en todos los planes) | ✅ |
| Consentimiento biométrico append-only | ✅ (obligatorio) | ✅ |

**Enforcement:** cada operación que consume cuota (crear sitio, dar de alta empleado, activar módulo) hace un `SELECT` a `suscripciones` del tenant, verifica el plan y su límite en `cat_plan_suscripcion`, y rechaza con mensaje claro si se rebasa. La verificación es un trigger de Postgres, no una condición en frontend, para que no se pueda bypassar desde la API directa.

---

## 5. Lo que sigue (si confirmas)

**Fase 2 — Modelo de datos (3FN):**
1. Generar `reset_database.sql` con:
   - Extensiones (`pgcrypto`, `pg_trgm`).
   - Enums (`regimen_pago`, `estado_reservacion`, `medio_asistencia`, `tipo_sitio`, `tipo_dispositivo`, etc.).
   - 30+ tablas normalizadas con auditoría (`created_at`, `created_by`, `updated_at`, `updated_by`, `tenant_id` obligatorios).
   - Semillas reales de los `.xlsx` (Puestos, Sociedades Propias, Sociedades Pagadoras, Uniformes, Bancos, etc.).
   - `cat_plan_suscripcion` + `suscripciones` a nivel tenant.
   - Funciones/triggers para las 10+ reglas de negocio traducidas de los PRCs.
   - Políticas RLS por tenant + bloqueo `UPDATE`/`DELETE` en tablas append-only.
2. `MODELO_DATOS.md` explicando cada tabla con su regla de negocio de origen.

**Espero tu confirmación para proceder con Fase 2.**
