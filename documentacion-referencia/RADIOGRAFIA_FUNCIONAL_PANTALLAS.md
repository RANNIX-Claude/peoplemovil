# Radiografía funcional del sistema Lobo/AppSCPF

Síntesis de los 26 análisis de capturas de pantalla (`SCREENSHOTS_*.md`, ~4,900 líneas, 2,884 capturas revisadas por 23 agentes en paralelo) más los 4 videos "Ciclo Completo" que muestran el flujo de punta a punta en una sola sesión real.

**Cómo leer esto:** cada sección sigue el orden real en que el operador usa el sistema. En cada paso se indica QUÉ pantalla es, QUÉ campos tiene, y sobre todo **qué cambió respecto al paso anterior** (ese es el dato que revela la regla de negocio real, no solo el inventario de campos). Cada hallazgo cita el documento fuente con el detalle completo y las capturas exactas, para que se pueda verificar contra la imagen original.

---

## 0. El ciclo de negocio completo (vista de pájaro)

```
CANDIDATO (portal público)
   │ se registra, aplica a una vacante publicada
   ▼
GRUPO DE ENTREVISTA (cita grupal, con % disponibilidad / sobre-booking)
   │ asistió + documentos completos
   ▼
FIRMA DE CONTRATO (Resultado = Aceptado/Rechazado)
   │ dispara asignación a CURSO DE INDUCCIÓN + correo automático al candidato
   ▼
CURSO DE INDUCCIÓN (asignado a un "Evento Prueba" = un Pedido real reutilizado como sandbox)
   │ marcar ¿Asistido? dispara EN CASCADA, automáticamente:
   │   1. Alta de EMPLEADO (Certeza = 0.90 default)
   │   2. Alta de PLAZA (puesto + pago + unidad de negocio)
   │   3. CONFIRMACIÓN FORZADA del empleado en el Pedido/Evento Prueba
   │   4. Correo a RRHH con PDF "Relación de personal dado de alta"
   ▼
EMPLEADO / PLAZA ya existen → puede ser reservado en PEDIDOS reales
   │
   ▼
PEDIDO (Registro) → DETALLE (Matriz de Puestos) → RESERVACIÓN
   │ confirmación (preasignada / forzada / voluntaria vía portal freelance)
   │ cancelación (sujeta a flags "permitir cancelar" en 2 niveles)
   ▼
ASISTENCIA REAL (checador o Registro Manual: Asistencia/Retardo/Falta)
   ▼
PAGO DE HONORARIOS (por reservación) → ASIGNACIÓN DE FOLIO (por empleado)
   ▼
CIERRE DE NÓMINA (por periodo, valida fecha, bloquea si falta banco)
   ▼
DISPERSIÓN (4 Excel: Lobo/Otras × Asimilables/Normales, separado por Sociedad Propia)
   ▼
FACTURACIÓN (PEP, comisión 4%, IVA, fondeo)
```

Fuente primaria de este diagrama: `SCREENSHOTS_CICLO_COMPLETO.md`, `_1.md`, `_2.md`, `_3.md` (4 grabaciones independientes del mismo ciclo, en sesiones distintas — se validan entre sí).

---

## 1. Reclutamiento: de candidato a empleado

### Paso 1 — Vacante publicada
Pantalla: **Catálogo de vacantes** → **Publicación de vacantes**. Según `SCREENSHOTS_ALTA_VACANTES.md` y `SCREENSHOTS_CAMBIO_ETIQUETA.md`, el modelo real separa dos conceptos:
- **"Perfil de puesto"** (plantilla reutilizable): Nombre de vacante, Funciones, Requisitos, Id puesto (4 obligatorios) + Imagen (archivo o URL), Código de acceso, Examen psicométrico (**link externo a evaluatest.com**, no un formulario interno), Requiere inglés, Experiencia laboral.
- **"Publicación de vacante"** (instancia publicada, se crea eligiendo un perfil que autorellena esos campos): Fecha de publicación, Fecha de caducidad, ¿Visible a candidatos?, contadores de Postulados/Grupos.
- **Qué cambia:** al elegir un Id Puesto se autorellenan Funciones/Requisitos/Examen. El campo "Id puesto" en producción mezcla roles genéricos con variantes por cliente/gira (ej. "Runner con Coche A Muse", "Seguridad Coordinador Mty") — normalizar esto en PeopleMovil (separar rol genérico de evento/cliente).
- Grid de vacantes: columnas Vacante(ID)/Nombre/Puesto/Experiencia laboral/Requiere inglés/Código de acceso/Examen psicométrico, export XLS/PDF. Los IDs nunca se reutilizan tras borrar.

### Paso 2 — Grupo de entrevista
Pantalla: **Grupos para entrevistas** (listado) → click en grupo → **Lista de candidatos en grupo**.
- Columnas de la lista: Hora cita, Puesto, Nombre de vacante, Estatus de grupo (Activo/Concluido), Sucursal, **% Disponibilidad** (puede ser negativo, ej. -50 → indica sobre-booking intencional), Cupo, Núm.Candidatos, **En proceso**.
- Dentro del grupo: por candidato, dos checkboxes independientes **¿Asistió?** y **¿Documentos Completos?**.
- **Qué cambia al confirmar:** modal "¿ACTUALIZAR LISTA DE ASISTENCIA?" → "Confirmar actualización de: N" → Sí/No. Al confirmar, la columna "En proceso" del listado pasa de 0 a N.

### Paso 3 — Firma de contrato
Pantalla: **Firma de contratos** (mismo layout que grupos) → **Lista firma de contrato**.
- Por candidato: ¿Asistió?, Doc.Com., Folios, Nombre completo, **Resultado** (dropdown: Aceptado/Rechazado), **Curso de inducción** (dropdown — aquí aparece un patrón de UX repetido: un selector de cabecera aplica el mismo valor a TODOS los renglones de golpe).
- **Qué cambia al confirmar:** modal "¿ACTUALIZAR FIRMA DE CONTRATOS?" → *"Se registrarán en CURSOS DE INDUCCIÓN: N registros"* → el Estatus de grupo pasa de **Activo a Concluido**, y se dispara el correo automático "Notificación curso de inducción" (plantilla verbatim capturada en los 3 Ciclo Completo, remitente `registro.sistema.freelance@gmail.com`, incluye Día/Hora/Lugar/código de vestimenta).

### Paso 4 — Curso de inducción → alta automática (el hallazgo más importante de toda la revisión)
Pantalla: **Cursos de inducción** → **Lista candidatos curso de inducción**.
- Campo clave: **"Evento prueba"** — un dropdown que NO es un catálogo aislado, **es una referencia directa a un Pedido real** (confirmado en `SCREENSHOTS_CICLO_COMPLETO2.md`: el "Evento Prueba" elegido = Pedido 1048 "Jacob Whitesides 2019" visible después en el módulo de Operaciones). Mismo patrón de selector-de-cabecera-aplica-a-todos.
- Checkbox por candidato: **¿Asistido?**.
- **Qué cambia al confirmar asistencia** (modal "ACTUALIZAR ASISTENCIA" → *"¿Confirmar asistencia de: N Registros?"*) — **se dispara una cascada automática en una sola transacción**, confirmada de forma independiente en 3 videos distintos:
  1. Alta de **Empleado** (Estatus=Activo, **Certeza=0.90** por default — campo nuevo, no documentado antes, posible score antifraude/verificación de identidad)
  2. Alta de **Plaza** (Puesto + Pago default + Unidad de negocio + fecha Inicio)
  3. **Confirmación Forzada** automática de ese empleado en el Pedido/"Evento Prueba" (sin pasar por el portal freelance)
  4. Correo automático a RRHH ("Erika Lara, Administración de personal") con PDF **"Relación de personal dado de alta"** adjunto
- **Gap/bug detectado:** el PDF de alta reporta el Puesto genérico del catálogo de empleado (ej. "SEGURIDAD"), no el puesto real del detalle de pedido confirmado (ej. "Acomodador-MA") — anotar como comportamiento a NO replicar, o decidir conscientemente.
- Campo nuevo sin equivalente en el schema: checkbox **"Evento Práctica"** en `te_pedidos_detalle` — marca un detalle como usado para este sandbox de confirmación de personal nuevo.

**Implicación de diseño para PeopleMovil:** este flujo de alta-por-cascada es un camino de alta de personal **completamente distinto** al alta manual que describen los Escenarios 8/9/16 del texto original. Si se quiere replicar, hace falta un trigger/función que, al marcar asistencia de inducción, dé de alta empleado+plaza+reservación forzada en una sola transacción — ahora mismo el esquema no tiene ese automatismo.

Fuentes: `SCREENSHOTS_CICLO_COMPLETO1.md`, `SCREENSHOTS_CICLO_COMPLETO2.md`, `SCREENSHOTS_CICLO_COMPLETO3.md`, `SCREENSHOTS_CICLO_COMPLETO.md`.

---

## 2. Pedidos, detalle y reservaciones

### Paso 1 — Registro de pedido (header)
Pantalla: **Pedidos → Información General** (`te_pedidoww.aspx` / alta).
Campos confirmados visualmente, en orden (fuente: `SCREENSHOTS_ESCENARIO1.md`, cruzado con Escenarios 2, 3, 4, 5, 14):
Cliente → Contacto (validado contra el cliente) → **Id sucursal*** (CDMX/Guadalajara/Monterrey/Otra/Queretaro — **campo que NO está en nuestro React ni en el texto original**) → Evento → Unidad de Negocio → PEP (al elegirlo, el sistema muestra nombre+dirección del inmueble y la Sociedad Pagadora) → Lugar de Cita → Tipo de movimiento (Pedido/Servicio Interno/Ninguno) → Sociedad propia / Sociedad pagadora → **Tipo de complejidad*** → **Duración del evento (días de show)** — campo **numérico libre, NO un catálogo/FK** (contradice el patrón `tipo_duracion_id` que asumimos) → Permitir cancelaciones (combo SI/NO, no checkbox) → Responsable.

**Catálogo real de "Tipo de complejidad"** (7 valores, capturado con el dropdown abierto — muy distinto a nuestros placeholders genéricos):
`Auditorio Nacional/Auditorio Guadalajara y Plazas Similares` · `Estadios Foro y Plazas Similares en el Extranjero` · `Festivales de más de 50,000 asistentes` · `Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares` · `No Aplica` · `Palacio de los Deportes, Arena VFG y Plazas Similares` · `Teatro Metropolitan, Plaza Condesa y Plazas Similares`.

**Qué cambia al Aceptar:** se genera folio consecutivo, estatus inicial. Status reales observados en el grid: **Vigente / Liberado / Cancelado / Procesado / Normal** — no coinciden ni con nuestro `status` de texto libre ni con `estado_detalle_pedido_enum`. Hay que reconciliar.

### Paso 2 — Agregar Detalle
Pantalla: **Detalles de pedido** (modal/sub-formulario).
Tipo de personal (forzado a "Operativo" para pedidos de Seguridad, no un combo libre) → Producto (dropdown filtrado; derivar Puesto automáticamente) → se muestra el hint **"N Horas por turno"** del puesto elegido → Cantidad / Turnos → **Fecha de cita** (fecha+hora inicio/fin) → **Fecha de liberación** (fecha+hora independiente, calendario default "Hoy") → **Fecha final cita** (**se autocalcula** como Fecha cita + N horas/turno — campo que no existe ni en el texto ni en nuestro React) → Presentación por producto (autorellena desde el Producto) → Completar con similares (combo SI/NO) → Bloque por producto (autoincremental, agrupa varias fechas bajo un mismo bloque) → Facturable / Fase del evento / Permitir cancelar (**un segundo flag independiente del de header**) → Indicaciones especiales.

**Catálogo real de "Fase del evento"** (5 valores, dropdown capturado completamente abierto dos veces — **contradice el enum actual del schema**):
`No aplica, Preparación, Montaje, Show, Desmontaje` — el schema tiene `('montaje','evento','desmontaje','otro')`. **Acción: corregir el enum.**

**Mensajes de validación reales capturados** (textuales, de distintos escenarios):
- `"La Presentación del producto es requerida"` (bloquea guardar si falta)
- `"Duración del evento(Días de show) es requerido."`
- `"No existe información para formar Matriz."` (al no haber detalles)
- `"Registro Agregado Correctamente"` (éxito)
- `"El empleado no cumple con el perfil requerido."` (al forzar sin similares)

**Qué cambia:** cada detalle agregado aparece de inmediato en la **Matriz de Puestos**, que NO es una tabla plana — es una **tabla pivote real**: fechas como columnas (con fila de hora), Bloque+Producto como filas, celda = "Cantidad - T Turnos", con filas de pie **"Total Solicitados"** y **"Presupuesto por día"** (este último se calcula instantáneamente al agregar el primer detalle, antes de liberar).

### Paso 3 — Confirmación de personal (reservación)
Pantalla: pestaña **Reservaciones** dentro de Detalles de pedido, sección "Personal Confirmado".
Dos botones: **"Confirmación Forzada"** vs **"Confirmación Preasignada"** — son rutas distintas, y en todos los escenarios de prueba revisados la que efectivamente tiene éxito es "Forzada" (Preasignada nunca se vio completar un caso exitoso en las capturas).

**Reglas de bloqueo de confirmación forzada confirmadas** (cada una con su mensaje exacto):
| Regla | Mensaje real | Fuente |
|---|---|---|
| Puesto no permite confirmar entre seriados (`tc_puestos.confirmar_entre_seriados = NO`) | *"El puesto no permite Confirmación Entre Seriados"* | Escenario 5 Entre Seriados |
| Empleado sin certeza suficiente para el puesto | *"La cantidad solicitada es menor a igual a 3" + "El porcentaje de certeza del empleado es menor a 1"* (el primer renglón es un mensaje viejo/no relacionado pegado al segundo, que sí es la regla real) | Escenario 9, 11 |
| Empleado no cumple perfil (producto sin similares) | *"El empleado no cumple con el perfil requerido."* | Escenario 11, 12 |
| Empleado en lista negra para ese lugar | *"El empleado se encuentra vetado para el lugar"* | Escenario 18 |
| Sin plaza vigente para el puesto | — (no se vio mensaje específico; la función de validación actual tampoco lo checa) | Escenario 11 |

Al forzar con éxito: `"Registro agregado correctamente"`, estatus pasa a **"CONFIRMADO FORZADO"**.

**Elegibilidad para ver el pedido en el portal freelance** (acumulado de varios escenarios): Puesto + Certeza + Vigencia de plaza + no estar en Lista Negra (por sitio) + **Sucursal del empleado = Sucursal del pedido** (hallazgo nuevo de Escenario 10 — un empleado de Querétaro no veía un pedido de CDMX hasta que se le cambió la sucursal).

### Paso 4 — Cancelación
Dos flags **independientes** confirmados en 4 escenarios distintos (1, 5, 13, 15):
- **A nivel Pedido:** "Permitir cancelar confirmaciones" (SI/NO)
- **A nivel Detalle:** "Permitir cancelar" (SI/NO)

Ambos deben permitir (AND lógico) para que el freelance pueda cancelar su propia confirmación desde el portal. **Comportamiento de UX inconsistente observado:**
- Escenario 13: al bloquear, el sistema **falla en silencio** — ningún mensaje de error, la página recarga y el evento sigue confirmado.
- Escenario 15: el control de cancelar parece **ocultarse** en vez de mostrarse-y-bloquear.
(Decidir conscientemente el comportamiento para PeopleMovil — lo razonable es mostrar un mensaje claro, mejor que ambas variantes legadas.)

Al cancelar una reservación confirmada, el sistema **genera un ID de reservación nuevo en vez de revertir el anterior** (comportamiento append-only) — coincide con el diseño ya elegido para `te_reservacion_bitacora`.

**Cancelación de un día dentro de un bloque/seriado** (Escenario 5): cancelar un solo día de un bloque de 5 **quita esa columna de la matriz pero el bloque sigue vigente con los demás días** — no se cancela el bloque completo. El cupo liberado puede reasignarse a otro pedido ese mismo día.

### Paso 5 — Reducción de cantidad con auto-cancelación por certeza (Escenario 16)
Reducir la cantidad solicitada de un detalle dispara una validación incremental:
- Reducir de 6→3 de un golpe: **rechazado** — *"Imposible realizar el cambio, se tienen reservaciones con certeza valor menor a 1"*
- Reducir de 6→4: **aceptado**, y el sistema **auto-cancela automáticamente a los 2 empleados de menor certeza** (0.7 y 0.8), dejando a los de certeza 0.9 y 1.0.

Esta es una regla de negocio real no documentada en el texto original: hay un límite de cuánto se puede reducir de golpe, ligado a cuántas reservaciones de baja certeza existen.

Fuentes de la sección 2: `SCREENSHOTS_ESCENARIO1.md`, `_2.md`, `_3.md`, `_4.md`, `_5.md`, `_5AB.md`, `_5_ENTRESERIADOS.md`, `_7.md`, `_9.md`, `_10.md`, `_11.md`, `_12.md`, `_13_A.md`, `_13_B.md`, `_14.md`, `_15.md`, `_16.md`, `_18.md`, `_VALIDACION_PEP.md`.

---

## 3. Asistencia real → Nómina → Dispersión → Facturación

### Paso 1 — Registro de asistencia
Dos vías confirmadas:
- **Checador** (biométrico/geolocalización, ya modelado como `te_eventos_biometricos`)
- **Registro asistencia manual** (`wp_regasistman.aspx`): busca por Pedido Detalle → tab Reservaciones → por persona, botones **[Asistencia] [Retardo] [Falta]** (3 estados, no binario) → "Confirmar Lista" → modal *"Procesar N con registro de asistencia"*.

### Paso 2 — Pago de honorarios
Pantalla de consulta (`wp_consultahonorarios.aspx`): Régimen (Normales/Asimilables), Periodo pago (0 antes del cierre), Banco, Cuenta, Pago bruto, Pago neto, Empresa pagadora, Unidad de negocio. Empleados nuevos aparecen con **Banco = "No definido"** hasta corregirlo en "Cuentas de banco empleados" (catálogo de bancos confirmado **sucio**: entradas basura "13".."17", "Doce", "once" mezcladas con bancos reales — limpiar en PeopleMovil).

Se vieron casos de **pago bruto negativo** forzado a neto $0.00 — posible ajuste/descuento, a confirmar con negocio antes de replicar la lógica.

### Paso 3 — Asignación de folio
Cada reservación debe "amarrarse" a un **folio alfanumérico** (ej. "KGIFJRU67") capturado manualmente por el operador, por empleado, antes de poder cerrar nómina. Modal de confirmación por cada asignación.

### Paso 4 — Cierre de nómina
Campo **Fecha** obligatorio (validación: *"Debe ingresar una fecha correcta"* si se deja vacío). Filas con banco "No definido" se resaltan en **rojo** (advertencia visual, no bloqueo duro confirmado). Modal: *"Se Confirman N REGISTRO(S) a procesar para el periodo: XXXX"*.

### Paso 5 — Dispersión
Se generan **4 archivos Excel independientes** por combinación Marca (Lobo / Otras) × Régimen fiscal (Asimilables / Normales), y además separados por **Sociedad Propia** (ej. "085-Lobo" vs "OCTR-Ocesa Corhum") — relevante para el diseño multi-tenant/multi-empresa.

Cada Excel trae 5-6 pestañas: **Datos Empleados** (IdContacto, RFC, CURP, Banco, Teléfonos), **Desglose Dispersión** (Regimen, DiasLaborados, **SDP, IM, CF, SA, CG, ID** — ya mapeados en la Migración 006 del schema —, Pago Bruto, Impuesto Total, Pago Neto), **Reservaciones Pagos Desglosado**, **Facturación**, **Dispersión Columnas**.

### Paso 6 — Facturación
Pestaña "Facturacion" del Excel: NombrePep, DescripcionPep, Inmueble, PagoReal, **Comisión 4%** (calculada), Subtotal factura, IVA, **Total a fondear**. Confirma modelo de negocio: comisión del operador sobre el pago real + traspaso de nómina a terceros (Sociedad Propia = razón social legal, PEP = centro de costos del cliente final).

Fuentes de la sección 3: los 4 `SCREENSHOTS_CICLO_COMPLETO*.md`.

---

## 4. Hallazgos transversales (aplican a todo el sistema)

- **Patrón de UX recurrente:** selector de cabecera que aplica un valor a TODOS los renglones de una lista de golpe (visto en "Curso de inducción", "Evento prueba") — vale la pena replicarlo como componente reutilizable en PeopleMovil para operaciones en lote.
- **Patrón de confirmación:** toda acción masiva muestra un modal con el conteo exacto de registros afectados antes de ejecutar (*"¿Confirmar actualización de: N?"*) — replicar como estándar de UX.
- **Catálogos "sucios"** confirmados en banco y en lugares de cita (duplicados: "Auditorio Nacional" dos veces, "Aeropuerto Internacional Benito Juárez" con/sin punto final) — limpiar antes de migrar datos semilla.
- **Validación de campos requeridos muy inconsistente** en el sistema legado: algunos campos marcados con asterisco (*) rojo en realidad NO bloquean el guardado (ej. Unidad de Negocio y Año en el alta de PEP) — decisión consciente para PeopleMovil: validar de verdad lo que se marca como requerido.
- **RBAC confirmado por nombre real de rol:** "Nomina" (bloqueado para cierta acción) vs. "Gerente-Nomina" (permitido) — consistente con el sistema granular de permisos por módulo+acción ya diseñado en la Migración 005.

---

## 5. Lista consolidada de correcciones al esquema (accionable)

| # | Corrección | Detalle | Prioridad |
|---|---|---|---|
| 1 | **Corregir `fase_evento_enum`** | De `('montaje','evento','desmontaje','otro')` a `('no_aplica','preparacion','montaje','show','desmontaje')` | Alta — confirmado en 2 escenarios independientes |
| 2 | **Agregar `id_sucursal` a `te_pedidos`** | Catálogo: CDMX, Guadalajara, Monterrey, Otra, Querétaro — campo real obligatorio que no capturamos | Alta |
| 3 | **Agregar `fecha_final_cita` a `te_pedidos_detalle`** | Autocalculada (fecha_cita + horas_turno del puesto), hoy no existe el concepto | Alta |
| 4 | **Revisar/corregir valores reales de `status` de pedido** | Vigente / Liberado / Cancelado / Procesado / Normal — no coincide con nuestro texto libre actual | Alta |
| 5 | **`te_lista_negra_empleados` necesita alcance por sitio** | Hoy es global; el real es por "Lugar de evento" (+ checkbox "Todos") y tiene campo "Hasta" (expiración) que no existe | Alta |
| 6 | **Crear tabla de tasas/rangos para certeza-reducción incremental** | Regla: no se puede reducir cantidad de golpe si implica cancelar reservaciones de certeza < 1 en más de X paso — formalizar como función/trigger | Media |
| 7 | **Agregar `fase_evento_id` opcional a `tp_sueldos_matriciales`** | Evidencia de que la fase también afecta el sueldo matricial para ciertos puestos (ej. Runner) | Media |
| 8 | **Agregar flag `es_evento_practica` a `te_pedidos_detalle`** | Para soportar el patrón "Evento Prueba" (pedido real reutilizado como sandbox de confirmación) | Media |
| 9 | **Automatizar cascada Inducción→Empleado→Plaza→Reservación forzada→Email** | Hoy no existe ningún trigger/función equivalente; es una ruta de alta de personal completa | Media |
| 10 | **Revisar función `valida_emp_puesto()`** | No verifica si existe una plaza del todo antes de chequear certeza/sexo — debería rechazar antes con mensaje claro | Media |
| 11 | **Limpiar catálogo de bancos al migrar datos semilla** | Quitar entradas basura, usar catálogo estándar SPEI | Baja |
| 12 | **Decidir comportamiento UX de cancelación bloqueada** | El legado falla en silencio o esconde el botón — en PeopleMovil mostrar mensaje explícito | Baja (decisión de producto) |

## 6. Gaps confirmados en la pantalla React ya construida (`SitiosAsignacion.jsx`)

Ver tabla completa en `SCREENSHOTS_ESCENARIO1.md` sección 7. Resumen:
- Falta campo "Id sucursal" por completo
- Fechas de cita/liberación sin hora/minuto (el real sí los captura)
- Falta concepto "Fecha final cita"
- "Tipo personal" debería forzarse read-only para ciertos tipos de pedido, no ser combo libre
- Al detalle le faltan: Bloque por producto, Facturable, Fase del evento, Permitir cancelar por detalle
- "Completar con similares"/"Permitir cancelaciones" son combos SI/NO en producción (implementamos checkbox — funcionalmente equivalente, pero vale igualar la UI)
- "Presentación" debería ser obligatorio de verdad
- La Matriz de Puestos real es una tabla **pivote** por fecha con totales — la nuestra es una tabla plana simple
- Al listado de pedidos le faltan columnas Sucursal/Responsable/Complejidad/T.Mov/PEP y export a PDF

---

## 7. Índice de documentos fuente

| Documento | Cubre |
|---|---|
| `SCREENSHOTS_ALTA_VACANTES.md` | Perfil de puesto + publicación de vacante |
| `SCREENSHOTS_VALIDACION_PEP.md` | Bugs reales de alta de PEP (presupuestos), catálogo de lugares |
| `SCREENSHOTS_ALTA_EMPLEADO.md` | Formulario completo de alta de empleado (44 campos) |
| `SCREENSHOTS_CAMBIO_ETIQUETA.md` | Confirma diseño perfil-de-puesto vs publicación |
| `SCREENSHOTS_ESCENARIO1.md` | Pedido completo + comparación campo-a-campo contra React |
| `SCREENSHOTS_ESCENARIO2.md` | Complejidad y días de show |
| `SCREENSHOTS_ESCENARIO3.md` | Fase del evento (catálogo real) |
| `SCREENSHOTS_ESCENARIO4.md` | Varios detalles mismo día, matriz pivote real (vs. producción) |
| `SCREENSHOTS_ESCENARIO5.md` | Seriado/bloque, cancelación de un día |
| `SCREENSHOTS_ESCENARIO5AB.md` | Colisión de forzado en día liberado de un seriado |
| `SCREENSHOTS_ESCENARIO5_ENTRESERIADOS.md` | Flag `confirmar_entre_seriados` |
| `SCREENSHOTS_ESCENARIO7.md` | Fecha/hora de liberación, validado empíricamente |
| `SCREENSHOTS_ESCENARIO9.md` | Certeza valor, mensajes de error imprecisos |
| `SCREENSHOTS_ESCENARIO10.md` | Regla de sucursal, proceso de auto-cancelación (no existe en UI) |
| `SCREENSHOTS_ESCENARIO11.md` | Confirmación sin puesto vigente, gap en `valida_emp_puesto()` |
| `SCREENSHOTS_ESCENARIO12.md` | Productos similares |
| `SCREENSHOTS_ESCENARIO13_A.md` / `_B.md` | Cancelación bloqueada, 2 grabaciones independientes |
| `SCREENSHOTS_ESCENARIO14.md` | Sueldos matriciales |
| `SCREENSHOTS_ESCENARIO15.md` | Cancelación de asignación forzada |
| `SCREENSHOTS_ESCENARIO16.md` | Reducción incremental + certeza |
| `SCREENSHOTS_ESCENARIO18.md` | Lista negra por sitio |
| `SCREENSHOTS_CICLO_COMPLETO.md` / `_1.md` / `_2.md` / `_3.md` | Flujo end-to-end completo (4 grabaciones) |
| `ESCENARIOS_PRUEBA_FREELANCE.md` | Transcripción literal del Excel de QA (texto, sin capturas) |

---

*Generado por síntesis de 23 agentes de análisis visual trabajando en paralelo sobre 2,884 capturas de pantalla reales del sistema Lobo/AppSCPF en producción/QA (2019). Cada afirmación en este documento es trazable a una captura de pantalla específica citada en el documento fuente correspondiente.*
