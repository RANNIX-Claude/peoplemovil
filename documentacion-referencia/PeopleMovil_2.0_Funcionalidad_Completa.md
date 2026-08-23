# PeopleMovil 2.0 — Listado completo de funcionalidad

Leyenda: **[L]** = heredado y confirmado en el sistema Lobo/AppSCPF (código o catálogos reales) · **[N]** = nuevo, requerido por la reforma legal 2026-2027 o por decisiones de esta conversación · **[G]** = generalización necesaria para que sirva a cualquier vertical (eventos, retail/impulsadoras, construcción, seguridad), no solo a OCESA.

---

## 1. Catálogos maestros

- **[L]** Puestos/Plazas — título, unidad de negocio, duración de turno, pago default, régimen de pago (nómina / honorarios normales / honorarios asimilados), ciclo de pago
- **[L]** Parámetros por puesto: certeza inicial, porcentaje mínimo para reservar, horas entre turnos, horas antes para cancelar, penalización por retardo, penalización por falta, si requiere biométrico, tipo de registro requerido (entrada/salida)
- **[L]** Sociedades Propias (razón social, si genera factura, si genera orden de servicio)
- **[L]** Sociedades Pagadoras (empresa pagadora ligada a cada sociedad propia)
- **[L]** Clientes / Marcas
- **[L]** Contactos / Candidatos (perfil completo: identidad, domicilio, características físicas relevantes al puesto)
- **[L]** Uniformes por producto/unidad de negocio
- **[L]** Bancos (para dispersión de pago)
- **[L]** Productos (línea de producto/evento a la que pertenece un pedido)
- **[L]** Lugares de cita (puntos de encuentro/estaciones físicas)
- **[L]** PEPs (personas políticamente expuestas) — cumplimiento AML en el reclutamiento
- **[N][G]** Catálogo de "sitios" genérico (sucursal, tienda, obra, foro) desacoplado del vocabulario de eventos
- **[N]** Catálogo de dispositivos biométricos por estación (número de serie, tipo — fijo o agente móvil)

---

## 2. Reclutamiento

- **[L]** Alta de candidato (formulario de registro)
- **[L]** Validación de RFC/CURP duplicado antes de guardar
- **[L]** Calendario de entrevistas
- **[L]** Publicación de vacante
- **[L]** Revisión de perfiles
- **[L]** Registro de resultado de evaluaciones
- **[L]** Seguimiento a proceso de selección
- **[L]** Control de asistencia a inducción
- **[L]** Control de asistencia a "evento prueba" (filtro adicional antes del alta definitiva)
- **[L]** Promoción automática candidato → empleado (copia de expediente completo, asignación de folio consecutivo) al confirmarse inducción
- **[L]** Entrega/recepción de uniformes
- **[L]** Registro de baja de personal
- **[N]** Captura y almacenamiento del aviso de privacidad / consentimiento aceptado por el candidato como parte del alta

---

## 3. Plazas y asignación de personal (rol múltiple por persona)

- **[L]** Un empleado puede tener varias "plazas" (roles) simultáneas, cada una con su propia certeza
- **[L]** Requisición de personal (pedido)
- **[L]** Desglose de pedido por puesto requerido (pedido_detalle)
- **[L]** Jerarquía de organización: sucursal/sitio → unidad de negocio → evento/periodo → fecha → producto
- **[L]** Semáforo visual de cobertura por nivel (verde >80% confirmado, rojo <80%)
- **[L]** Preasignación de personal a un pedido
- **[L]** Confirmación de asistencia/disponibilidad por parte del trabajador
- **[L]** Estados de reservación: disponible → preasignado → confirmado (voluntario u opcional) → forzada → procesado → cancelado
- **[L]** Validación automática de que el empleado califica para el puesto (certeza mínima + género requerido cuando aplica)
- **[L]** Validación automática de no-traslape / margen mínimo entre turnos (por puesto, considerando duración total + margen de seguridad)
- **[L]** Ventana de cancelación configurable por puesto (bloquea cancelar si faltan menos horas que el mínimo)
- **[L]** Cancelación automática de preasignados que no confirmaron a tiempo (libera el cupo)
- **[L]** Cancelación forzada por el coordinador
- **[L]** Manejo de notificaciones a los trabajadores sobre asignación/cambios de evento
- **[L]** Bitácora de todos los movimientos de una reservación
- **[G]** Rotación por periodo (semanal, quincenal) entre distintos sitios para el mismo trabajador — mismo motor que la asignación por evento, catálogo de duración distinto

---

## 4. Checador / registro de asistencia

- **[L]** Registro de estación de entrada y de salida por reservación
- **[L]** Registro de medio de asistencia (biométrico vs. manual)
- **[L]** Registro de hora de entrada/salida real vs. la programada
- **[L]** Integración con dispositivo biométrico (heredado: "Timescan"; moderno: lector U.are.U/ZKTeco + agente local)
- **[L]** Cálculo de puntualidad por reservación, que alimenta la certeza acumulada del empleado
- **[N]** **Modo fijo**: lector USB + agente local (DigitalPersona/ZKFinger) para personal en sitio fijo
- **[N]** **Modo móvil**: app con geolocalización + selfie/reconocimiento facial para personal distribuido (guardias, impulsadoras, cuadrillas)
- **[N]** Registro append-only — nunca `UPDATE`/`DELETE` sobre el registro crudo; correcciones = nuevo registro enlazado
- **[N]** Timestamp de servidor, no del dispositivo cliente
- **[N]** Campo de auditoría "regla aplicada" en cada registro (qué validación disparó una decisión automática — patrón heredado del campo `ReglaAplicada` de Lobo)
- **[N]** Vínculo obligatorio entre cada registro biométrico y un consentimiento vigente

---

## 5. Consentimiento y cumplimiento de datos personales

- **[N]** Flujo de autorización explícita: notificación al trabajador de qué dato se captura y para qué, con opción de aceptar/rechazar
- **[N]** Registro histórico de consentimientos (append-only, revocable)
- **[N]** Aislamiento total de datos biométricos y personales entre tenants/clientes distintos, aunque compartan el mismo motor
- **[N]** Aviso de privacidad específico para biometría, versionado

---

## 6. Nómina y pagos

- **[L]** Cálculo de nómina general por periodo, basado en asistencia real (asistencia, retardo o falta — no en lo programado)
- **[L]** Cálculo de nómina individual (recálculo puntual de una persona)
- **[L]** Salario diario promedio calculado a partir del historial del periodo
- **[L]** Aplicación automática de penalización por retardo/falta al monto a pagar
- **[L]** Dispersión de nómina diferenciada: nómina tradicional vs. honorarios normales vs. honorarios asimilados
- **[L]** Folios consecutivos independientes por tipo de entidad (empleado, factura de honorarios, etc.)
- **[L]** Asignación de folio de honorarios a cada reservación pagada
- **[L]** Reporte de precauciones antes del cierre de nómina (cuenta bancaria faltante, régimen de pago incompleto, pagadora no asignada)
- **[L]** Consulta de saldo y pagos por trabajador
- **[L]** Registro y seguimiento a aclaraciones de pago
- **[L]** Interfaz con sistema contable/ERP (heredado: SAP)
- **[N]** Registro fiscal explícito por sociedad propia y sociedad pagadora (multi-empresa dentro del mismo grupo, como en la estructura real de OCESA)

---

## 7. Cumplimiento legal específico 2026-2027

- **[N]** Registro electrónico de jornada conforme al artículo 132 fracción XXXIV LFT
- **[N]** Retención configurable de registros (sugerido 5 años, no hardcodeado — pendiente de reglas técnicas STPS)
- **[N]** Reportes de evidencia listos para auditoría STPS/IMSS
- **[N]** Campo de registro REPSE por asignación, cuando el personal se pone a disposición de un tercero fuera del objeto social de la empresa receptora
- **[N]** Vinculación de cada registro de asistencia a su consentimiento correspondiente (requisito para que el registro tenga "prueba plena" en juicio laboral)

---

## 8. Seguridad y accesos

- **[L]** Roles y perfiles de usuario (heredado: GAM de GeneXus, con autenticación local y basada en roles)
- **[L]** Autorización por objeto (qué pantallas/transacciones puede ver cada rol) y por operación (insertar/editar/eliminar/consultar)
- **[N]** Migración a Supabase Auth + Row Level Security (RLS) por tenant
- **[N]** Multi-tenant real: mismo código, cero cruce de datos entre clientes/negocios no relacionados

---

## 9. Reportes y consultas

- **[L]** Consulta e impresión de personal por evento/pedido
- **[L]** Consulta de calendario de eventos
- **[L]** Reportes de empleados
- **[L]** Reporte de personal externo por evento
- **[L]** Reporte de personal con recibo
- **[L]** Registro de comunicados y su consulta
- **[G]** Reporte de cobertura por sitio/rol en tiempo real (el semáforo verde/rojo aplicado a cualquier vertical)

---

## 10. Administración del sistema

- **[L]** Administración de catálogos
- **[L]** Administración de bitácora
- **[L]** Manuales técnico, de operación y de instalación
- **[L]** Migración de datos históricos (de un sistema legado a este)
- **[N]** Panel de configuración de parámetros por puesto/vertical sin tocar código (preservar el principio de diseño heredado: nada de umbrales de negocio hardcodeados)

---

## Nota sobre alcance para el MVP

No todo lo anterior debe construirse en la primera versión. La secuencia sugerida en la especificación principal (`PeopleMovil_2.0_Spec_para_ClaudeCode.md`) prioriza: núcleo de datos + checador fijo → checador móvil → pedidos/asignación → certeza/penalizaciones → nómina/honorarios → REPSE/cumplimiento. Este listado es el mapa completo del territorio, no la ruta de construcción.
