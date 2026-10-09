# Notificaciones del proceso de reclutamiento — historia completa + gap vs. PeopleMovil

Pedido del usuario (2026-10-08): revisar **todas** las 225 capturas de `20 - Ciclo completo` (no solo la muestra de ~52 frames del análisis previo en `SCREENSHOTS_CICLO_COMPLETO.md`), armar la historia cronológica del proceso de reclutamiento, y marcar explícitamente cada punto donde el sistema legado (Lobo) notifica al candidato o a RH por correo — esa parte no estaba suficientemente marcada.

Método: se revisaron con Read, frame por frame, los 173 frames que el análisis previo se había saltado (4 agentes en paralelo cubriendo 2-40, 42-80, 82-150, 152-224), cruzando con los 52 ya documentados. Cobertura: **225/225 frames, 100%**.

---

## 1. Resultado principal: solo hay 2 plantillas de correo en todo el ciclo, y una de ellas es una SERIE

Tras revisar los 225 frames, la pestaña de Outlook ("Correo: Leonardo Calvario") está abierta de fondo durante *todo* el video, pero el operador solo la trae al frente en dos momentos del tramo de reclutamiento (minuto ~1:17 y ~3:19-3:45). **En el resto del video (nómina, folios, cierre, dispersión, facturación — minutos 4:55 a 13:32, 173 de los 225 frames) nunca se vuelve a abrir el correo.** Es decir: en el sistema legado, **las notificaciones por correo existen únicamente en la etapa de reclutamiento**, no en nómina/pago/dispersión.

### 1.1 Correo 1 — al candidato: confirmación de curso de inducción

- **Frame:** `021_01m17s.png`
- **Remitente mostrado:** "Registro portal freelance" `<registro.sistema.freelance@gmail.com>`
- **Categoría Outlook aplicada:** "Reclutamiento"
- **Asunto:** "Notificación curso de inducción"
- **Cuerpo (texto íntegro visible):**
  > Confirmación de curso de inducción
  > Estimado(a): \<Nombre Candidato>
  > ¡Ya estás a un paso! Agradecemos tu interés y compromiso en tu proceso de selección.
  > Te confirmamos los datos para tu curso de inducción:
  > **Día:** 16/07/19 **Hora:** 07:00
  > **Lugar:** Av. Río Churubusco esq. con Añil s/n, Puerta 1. Recepción Lobo. Palacio de los Deportes, Col. Granjas México, Ciudad de México.
  > Favor de presentar Identificación Oficial.
  > Recuerda que debes asistir con el código de vestimenta: *(texto cortado en el frame, no se alcanzó a capturar completo)*
- **Qué lo dispara:** el modal "¿ACTUALIZAR FIRMA DE CONTRATOS?" (ver §2, paso 4) — al confirmar ahí "Se registrarán en CURSOS DE INDUCCIÓN: N registros", el sistema manda este correo a cada uno de los N candidatos.
- **Confirmado (captura adicional del usuario, correo abierto en Outlook): es un correo individual y personalizado, no uno grupal.** El encabezado dice "Estimado(a): CandNombre00217 CandApPat00217 CandApMat00217" — se genera y envía uno por candidato del lote (10 correos separados para el ejemplo de 10 registros), cada uno dirigido a su propio nombre. Remitente confirmado en esa captura: "Registro portal freelance <registro.sistema.freelance@gmail.com>", enviado Lun 15/07/2019 03:23 PM — coincide con el timestamp de la bandeja ya documentado.

### 1.2 Correo 2 — interno a RH: alta automática de personal (SE REPITE EN SERIE)

- **Frames:** `052_03m19s.png` (bandeja), `054_03m28s.png`/`055`/`057` (popup abierto), `062_03m44s.png`/`063` (PDF adjunto renderizado completo), más la vista original ya documentada en `056_03m32s.png`/`061_03m41s.png`.
- **Remitente mostrado:** "Registro alta de empleados" `<registro.sistema.freelance@gmail.com>`
- **Categoría Outlook aplicada:** "Reclutamiento"
- **Asunto:** "Notificación del sistema"
- **Cuerpo íntegro:**
  > Anexo la presente enviamos la relación de los candidatos que han sido seleccionados y dados de alta como personal Freelance de manera automática.
  > — Erika Lara / Administración de personal
- **Adjunto:** PDF `15072019_15_19.pdf` (2 KB), título **"Relación de personal dado de alta con fecha: 15/07/19"**, tabla completa:

  | Num.Empleado | Nombre | Puesto | Solicitud |
  |---|---|---|---|
  | 65858 | CandNombre00208 CandApPat00208 CandApMat... | SEGURIDAD | 208 |
  | 65859 | CandNombre00209 ... | SEGURIDAD | 209 |
  | 65860 | CandNombre00210 ... | SEGURIDAD | 210 |
  | 65861 | CandNombre00211 ... | SEGURIDAD | 211 |
  | 65862 | CandNombre00212 ... | SEGURIDAD | 212 |
  | 65863 | CandNombre00213 ... | SEGURIDAD | 213 |
  | 65864 | CandNombre00214 ... | SEGURIDAD | 214 |
  | 65865 | CandNombre00215 ... | SEGURIDAD | 215 |
  | 65866 | CandNombre00216 ... | SEGURIDAD | 216 |
  | 65867 | CandNombre00217 ... | SEGURIDAD | 217 |

  (Los 10 folios coinciden exactamente con el pedido 1048, 10 plazas "Acomodador-MA"/Seguridad — el PDF generaliza el puesto a "SEGURIDAD" aunque el pedido decía "Acomodador-MA", a confirmar con el usuario si es simplificación intencional del reporte o inconsistencia.)

- **CRÍTICO — es una serie, no un correo único:** la bandeja de Outlook en `052_03m19s.png` muestra el **mismo asunto "Notificación del sistema" / mismo remitente, repetido 5 veces en una sola tarde** (15/07/2019): **15:43, 15:54, 16:14, 16:24, 17:18**. Cada instancia trae su propio PDF con la fecha/hora en el nombre de archivo (`15072019_HH_MM.pdf`). Esto confirma literalmente lo que señalaste: **"hay una serie de correos"** — el sistema dispara este correo **una vez por cada lote de altas automáticas procesado** (es decir, cada vez que se confirma asistencia a un grupo del curso de inducción — ver §2 paso 6 — dispara un lote y su propio correo con su propio PDF, no se consolida en un solo aviso diario).

### 1.3 Lo que NO existe (confirmado por ausencia tras revisar 225/225 frames)

- No hay correo de confirmación de postulación al candidato.
- No hay correo de confirmación de cita de entrevista grupal.
- No hay correo de resultado de entrevista individual (aceptado/rechazado) aparte del que ya viene empaquetado en el de curso de inducción.
- No hay ningún correo en nómina, folios, cierre de nómina, dispersión o facturación (aviso de pago, recibo de nómina, etc.) — si existe en el sistema real, no se usó/mostró en este video de prueba.

---

## 2. La historia completa, paso a paso, con cada notificación marcada 📧

1. **Candidato se postula** a una vacante (portal público). *(Fuera del alcance de este video — no se vio esta pantalla en "Ciclo completo"; en PeopleMovil ya existe como `postular_a_vacante()` + `Postularme.jsx`.)*
2. **Agendado a un "Grupo para entrevista"** (cita grupal): pantalla lista con Hora cita, Puesto, Nombre de vacante, Estatus de grupo, Sucursal, % Disponibilidad (puede ser negativo → sobre-booking intencional), Cupo, Núm.Candidatos.
3. **Lista de candidatos en grupo**: por candidato se marca ¿Asistió? y ¿Documentos Completos? (dos checkboxes independientes) → botón "Actualizar Lista" → modal **"¿ACTUALIZAR LISTA DE ASISTENCIA?"**: "Confirmar actualización de: N" → Sí.
4. Pasa al módulo **"Firma de contratos"** (separado, no solo un estatus): por candidato se captura **Resultado** (dropdown, "Aceptado") y se asigna el **Curso de inducción** — vía un selector en la cabecera que, al elegirse, propaga el valor a todas las filas del grid (patrón de edición en lote) → botón "Actualizar Lista" → modal **"¿ACTUALIZAR FIRMA DE CONTRATOS?"**: **"Se registrarán en CURSOS DE INDUCCIÓN: N registros"** → Sí.
   - Este modal es la pieza clave que el análisis anterior no había conectado: **firmar el contrato es el evento que de verdad inscribe al candidato al curso**, no un paso posterior separado.
5. 📧 **Se dispara el Correo 1** (confirmación de curso de inducción) a cada uno de los N candidatos recién inscritos.
6. Candidato asiste. En **"Lista candidatos curso de inducción"**: se asigna un **Evento Prueba** (mismo patrón de selector-de-cabecera-propaga-a-filas; el catálogo de eventos reutiliza los eventos operativos reales, p.ej. "Jacob Whitesides 2019") y se marca ¿Asistió? → botón "Actualizar Lista" → modal **"ACTUALIZAR ASISTENCIA"**: "¿Confirmar asistencia de: N Registros?" → Sí.
   - Este paso **dispara automáticamente el alta de empleado** — aparecen de inmediato en el listado de "Empleado" con Estatus Activo y Certeza 0.90.
7. 📧 **Se dispara el Correo 2** (serie) — aviso interno a RH con el PDF de altas de ese lote. Si en el mismo día se confirman varios grupos/lotes, se dispara un correo por cada lote (confirmado: 5 veces en una tarde).
8. Se asigna la **plaza** del empleado (Puesto, Pago, Unidad de negocio).
9. El empleado queda **confirmado** (forzado o preasignado) a un Pedido/evento concreto — pantalla "Detalles de pedido", con **Matriz de Puestos** (control de cupo por bloque/fecha/hora) y botones "Confirmación Forzada"/"Confirmación Preasignada" (origen real del estatus "CONFIRMADO FORZADO").
10. Resto del ciclo (asistencia manual, asignación de folios, pago de honorarios, cierre de nómina, dispersión) — **sin correos**, confirmado revisando los 173 frames restantes.

---

## 3. Tabla: etapa → acción → modal de confirmación → notificación → destinatario

| Etapa | Pantalla legado | Modal de confirmación | ¿Dispara correo? | Destinatario |
|---|---|---|---|---|
| 1. Postulación | Portal público | — | No visto en este video | — |
| 2. Cita grupal | Grupos para entrevistas | — | No | — |
| 3. Asistencia a entrevista | Lista de candidatos en grupo | "¿ACTUALIZAR LISTA DE ASISTENCIA?" | No | — |
| 4. Firma de contrato + asignación de curso | Firma de contratos (detalle) | "¿ACTUALIZAR FIRMA DE CONTRATOS?" | **Sí → Correo 1** | Candidato |
| 5. Asistencia a curso de inducción | Lista candidatos curso de inducción | "ACTUALIZAR ASISTENCIA" | **Sí → Correo 2 (serie, 1 por lote)** | RH interno (buzón genérico) |
| 6. Alta de empleado | (automática, sin pantalla propia) | — | (incluido en Correo 2) | — |
| 7. Asignación de plaza | Plazas empleados | — | No | — |
| 8. Confirmación a pedido | Detalles de pedido (Confirmación Forzada/Preasignada) | — | No | — |
| 9+. Asistencia, folios, nómina, dispersión | (6 pantallas) | Varios (asistencia, folio, cierre de nómina) | No | — |

---

## 4. Gap: qué de esto ya existe en PeopleMovil y qué falta

Revisé el schema (`db/reset_database.sql`) y el frontend (`peoplemovil-app/src`) antes de proponer nada, siguiendo el principio de no asumir sin investigar.

### 4.1 Ya construido (más de lo que esperaba)

- **Schema completo del funnel**: `te_candidatos`, `te_vacantes`, `te_grupos_citas`, `tr_cita_grupo_candidato`, `te_cursos_induccion`, `tr_asistencia_curso`, `te_eventos_prueba`, `tr_postulacion_candidato_vacante` (con `estatus_full` — enum de 12 estados que mapea casi 1:1 al funnel del legado, `resultado`, `doc_completa`, `asis_curso_induccion`, `calif_curso_induccion`, `asis_evento_prueba`, etc.) — Migración 003b.
- **RPCs ya implementadas**: `postular_a_vacante()`, `agendar_entrevista_grupal()`, `promover_candidato_a_empleado()`.
- **UI ya implementada**: [Postularme.jsx](../peoplemovil-app/src/pages/public/Postularme.jsx) (portal público: postularse + agendar cita grupal), [FunnelReclutamiento.jsx](../peoplemovil-app/src/pages/admin/FunnelReclutamiento.jsx) (vista de solo lectura de las 7 etapas), [Personal.jsx](../peoplemovil-app/src/pages/Personal.jsx) y [AltaMasivaEmpleados.jsx](../peoplemovil-app/src/pages/admin/AltaMasivaEmpleados.jsx) (botón manual que llama a `promover_candidato_a_empleado`).
- **Log de comunicaciones genérico ya existe**: `te_comunicados` / `tr_comunicado_destinatario` (soporta `candidato_id`, `enviado_en`, `leido_en`, `canal`) — es la pieza de datos correcta para registrar el envío de estos correos, solo falta poblarla.
- **Infra de envío de correo ya existe**: [notificacion-resend.js](../peoplemovil-app/netlify/functions/notificacion-resend.js), con 4 plantillas (`onboarding`, `asignacion`, `recordatorio_checado`, `nomina_resultado`) vía Resend. **Ninguna de las 4 es de reclutamiento.**
- Patrón de digest por lote ya existe como referencia: [digest-diario.js](../peoplemovil-app/netlify/functions/digest-diario.js).

### 4.2 Construido en esta sesión (2026-10-08)

Los 5 pasos que faltaban (3, 5, 6, 8, 10 del §2) ya están implementados:

1. **Migración 019** (`db/reset_database.sql`) — 3 RPCs nuevas que mueven el funnel entre etapas, siguiendo el mismo patrón de lote + confirmación que el legado:
   - `confirmar_asistencia_grupo(p_grupo_cita_id, p_candidatos)` — paso 3. Avanza a `entrevista_individual` solo si asistió Y trae documentos completos.
   - `registrar_firma_contrato(p_candidatos, p_resultado, p_curso_induccion_id)` — paso 5. Si `resultado='aceptado_curso'`, fija el curso y pre-inscribe en `tr_asistencia_curso`; devuelve los datos (nombre, correo, día/hora/lugar del curso) que el frontend usa para el Correo 1.
   - `confirmar_asistencia_curso(p_curso_induccion_id, p_candidatos)` — pasos 8+9. Si asistió, marca `te_candidatos.paso_induccion=true` y llama automáticamente a `promover_candidato_a_empleado()` en la misma operación (antes era un botón manual separado); devuelve folio/puesto/resultado por candidato para armar el lote del Correo 2.
2. **2 plantillas nuevas en `notificacion-resend.js`**: `curso_induccion_confirmacion` (individual, un correo por candidato) y `alta_empleados_rh` (con PDF adjunto, generado server-side con `pdf-lib` en [`_lib/pdf-alta-empleados.js`](../peoplemovil-app/netlify/functions/_lib/pdf-alta-empleados.js) — mismas columnas que el PDF original: Num.Empleado, Nombre, Puesto, Solicitud).
3. **3 pantallas de acción nuevas** (antes el funnel era de solo lectura): [EntrevistaGrupal.jsx](../peoplemovil-app/src/pages/admin/EntrevistaGrupal.jsx), [FirmaContratos.jsx](../peoplemovil-app/src/pages/admin/FirmaContratos.jsx) (selector de cabecera que propaga Resultado/Curso a todas las filas, igual que el legado, y dispara el Correo 1 por cada aceptado), [CursoInduccion.jsx](../peoplemovil-app/src/pages/admin/CursoInduccion.jsx) (confirma asistencia → alta automática → botón para enviar el Correo 2 con PDF, con el correo de RH destino capturado a mano en vez de asumir un campo de configuración que no existía).
4. **Decisión tomada sobre la serie de correos**: se replicó fiel — 1 correo por lote confirmado (no se consolidó en un digest), porque es lo que hace el legado y es lo más simple de implementar: se dispara desde la misma pantalla que procesa el lote.
5. **Bitácora**: `notificacion-resend.js` ahora escribe en `te_comunicados`/`tr_comunicado_destinatario` cuando el envío fue exitoso (antes esas tablas existían pero no se usaban).

**Build verificado** (`npm run build` sin errores, `node --check` + ejecución de prueba de ambas plantillas y del PDF en modo dry-run). **Migración 019 aplicada a la base real de PeopleMovil** (`ysyeidudlvdkqpckspcy.supabase.co`) el 2026-10-08 vía `apply_migration` — se confirmaron las 3 funciones creadas (`confirmar_asistencia_grupo`, `registrar_firma_contrato`, `confirmar_asistencia_curso`) consultando `pg_proc`. Resultó que esta misma sesión sí tenía acceso al proyecto real desde el principio, a través de un segundo server MCP de Supabase (`supabase`, tipo "user") distinto del Connector de cuenta que se había probado primero — ver CLAUDE.md §13 para no repetir la confusión en sesiones futuras.

### 4.2b Pendiente real restante

- Paso 4 (entrevista individual + psicométrico) sigue **parcial**: las columnas existen (`doc_psicometrico_url`, `psicometrico_obs`, `entrevista_obs`) pero no hay pantalla de captura — no se tocó en esta sesión porque no era uno de los 5 pasos pedidos.
- Probar el flujo end-to-end con datos reales (crear un grupo de cita, postular candidatos de prueba, correr las 3 pantallas nuevas en orden).
- Configurar `RESEND_API_KEY` si aún no está seteada en Netlify (sin ella, la función responde en modo `dry:true` sin enviar correo real — útil para probar sin gastar cuota, pero hay que confirmar la key esté puesta en producción).

### 4.3 Las "áreas"/roles reales del legado (confirmado por captura adicional del usuario)

La barra de menú superior del sistema legado confirma las áreas organizacionales reales, cada una un menú de primer nivel propio: **Inicio | Recursos humanos | Operaciones | Nómina | Catálogos | Seguridad sistema | Salir**. Esto importa para el diseño de roles/permisos en PeopleMovil (ver `AdminAuthContext.jsx`/`hasPermiso()` en CLAUDE.md §8):

- **Recursos humanos** — todo el funnel de reclutamiento (§2 de este documento) vive aquí, no en un módulo aparte.
- **Operaciones** — pedidos, contactos, clientes, eventos, lugares de cita, asistencia manual, TimeScan.
- **Nómina** — plazas, folios, pago de honorarios, cierre, dispersión.
- **Catálogos** — (contenido no explorado en este video, pero existe como área separada de RH/Operaciones/Nómina — probablemente catálogos maestros compartidos entre áreas).
- **Seguridad sistema** — administración de usuarios/permisos (no explorado en este video, pero confirma que el legado ya separaba la gestión de accesos como su propia área, igual que el gating de `hasPermiso()` que ya existe en PeopleMovil).

Es decir, los "roles" que pediste reflejar no son una invención del análisis — están definidos por el propio legado como áreas de menú, y **Reclutamiento es una sub-sección de Recursos Humanos**, no un área independiente.

### 4.4 Nota de fidelidad (no simplificar sin más)

El enum `estado_postulacion_full_enum` no tiene un valor explícito `'firma_contrato'` — salta de `'entrevista_individual'` a `'aceptado'` a `'en_curso_induccion'`. Según el video, "Firma de contratos" es un **módulo separado** con su propia pantalla, no solo un estatus intermedio invisible. Antes de construir la UI, vale la pena confirmar contigo si `'aceptado'` ya representa ese paso adecuadamente o si realmente falta un estado dedicado — en el legado es ahí donde se captura el Resultado Y se asigna el curso en la misma acción, así que probablemente `'aceptado'` + la asignación de `curso_induccion_id` en la misma transacción sea fiel, pero quería dejarlo marcado explícitamente en vez de asumir.

---

## 5. Hallazgos adicionales relevantes (no relacionados a correo, pero nuevos vs. el doc previo)

- **Menú "Recursos humanos ▸ Proceso de Reclutamiento"** (8 opciones: Asistencia por Grupos, Firma de contratos, Cursos de inducción, Eventos prueba, Empleados, Baja empleado, Reactivación empleado, Cambio de banco) — no estaba documentado antes.
- **Patrón UX "selector de cabecera que propaga a todas las filas"** — usado dos veces (asignar curso de inducción, asignar evento prueba) para edición en lote.
- Pantalla nueva **"Cursos de inducción" (catálogo maestro de sesiones)** — columnas Descripción, Cita Curso, Tiempo de duración, Puesto, Nombre de vacante, Cupo, Integrantes.
- **"Matriz de Puestos"** en Detalles de pedido — control de cupo por bloque/fecha/hora, con Total Solicitados vs. cubierto.
- Pedido tiene ciclo de vida de estatus explícito: botones **"Editar pedido" / "Liberar Pedido" / "Cancelar Pedido"** (estatus visto: "Liberado", además del ya conocido "Vigente").
- Botones **"Confirmación Forzada"** y **"Confirmación Preasignada"** — origen real del estatus "CONFIRMADO FORZADO" ya documentado.
- **Fórmula confirmada de las columnas de nómina sin leyenda**: `ID = IM + CF` (= "Impuesto Total a Retener"), `SDP = Pago Bruto` cuando Días Laborados=1 — consistente con estructura de tarifa ISR por tramos (marginal + cuota fija). Pendiente confirmar nombres oficiales con el usuario.
- Pestaña Excel **"Datos Empleados"** confirma que el legado sí contemplaba RFC/CURP/Fecha de Nacimiento/Género como columnas de nómina (vacías en los datos de prueba) — coherente con el expediente completo que PeopleMovil ya agregó en la Migración 018.
- La partición de archivos de dispersión es **por Sociedad Propia (entidad legal pagadora)**, no por Unidad de Negocio como decía el hallazgo #14 del doc anterior — un mismo archivo puede agrupar varias unidades de negocio si comparten sociedad propia.
- Caso a investigar en datos reales: un empleado (Arturo Flores Hurtado, Id 39115) cuyo Pago Real de folio ($300.00) no coincide con su Pago bruto final en "Pago honorarios" ($100.00) — posible bug del legado o dato incompleto en el tramo grabado, no asumir una regla de cálculo de esto sin más evidencia.

---

## 6. Archivos fuente

`C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\20 - Ciclo completo\` — 225 frames (`001_00m00s.png` a `225_13m32s.png`), video `https://youtu.be/8_uJAljE3-M`, 13m32s. Ver también `SCREENSHOTS_CICLO_COMPLETO.md` (análisis técnico pantalla-por-pantalla, complementario a este documento centrado en la historia y las notificaciones).
