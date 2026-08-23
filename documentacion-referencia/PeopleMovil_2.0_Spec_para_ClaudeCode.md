# PeopleMovil 2.0 — Especificación para Claude Code

**Origen:** Este documento consolida (a) la base de conocimiento real de GeneXus del sistema "AppSCPF" (sucesor documentado del "Sistema Lobo" de OCESA, campo `TE_ReservacionIdReservacion_Lobo` confirma la migración), (b) el análisis legal de la reforma de jornada laboral 2026-2027, y (c) las decisiones de arquitectura acordadas para la reconstrucción moderna bajo estándares RANNIX.

**Objetivo del documento:** dar a Claude Code el contexto suficiente para construir el sistema bien desde el primer sprint, sin necesidad de que Roberto reexplique el dominio de negocio.

---

## 1. Visión del producto

Sistema de gestión de personal (fijo y freelance/distribuido) con checador de cumplimiento legal como módulo de entrada, expandible a ciclo completo de RH: reclutamiento → asignación a pedidos/eventos → asistencia → nómina/honorarios → cumplimiento.

Dos mercados objetivo con el mismo motor:
1. **Empresas con personal fijo en oficina/sede** — checador de cumplimiento (reforma LFT).
2. **Empresas con personal distribuido por evento/proyecto** (productoras de eventos, constructoras, seguridad) — asignación diaria persona-rol-sitio con tarifa variable, heredado del modelo real de OCESA/Lobo.

---

## 2. Marco legal y de cumplimiento (obligatorio en el diseño, no opcional)

### 2.1 Reforma de jornada laboral (LFT)
- Decreto DOF 1 de mayo 2026, artículo 132 fracción XXXIV: registro electrónico de jornada obligatorio (hora de entrada y salida).
- Vigencia plena y sanciones: **1 de enero de 2027**. Multas de 250 a 5,000 UMA.
- La STPS **aún no publica** (a la fecha de este documento) las disposiciones técnicas específicas — el diseño debe ser flexible, no asumir un formato fijo.
- El registro tiene "prueba plena" en juicio laboral **solo si consta que el mecanismo fue acordado con el trabajador** → el flujo de consentimiento (sección 4) no es un nice-to-have, es lo que le da valor legal al registro.

### 2.2 Requisitos de un registro "confiable"
- **Append-only.** Nunca `UPDATE`/`DELETE` sobre el registro crudo del checador. Correcciones = nuevo registro enlazado, nunca sobrescritura.
- **Timestamp de servidor**, nunca del dispositivo cliente.
- **Origen trazable**: estación/dispositivo, número de serie del lector, empleado, y consentimiento vinculado.
- **Retención sugerida: 5 años** (cubre prescripción laboral de 1 año + auditorías IMSS/SAT que suelen pedir hasta 5). Dejarlo **configurable**, no hardcodeado — la STPS podría fijar su propio plazo.

### 2.3 Biometría (dato sensible bajo LFPDPPP)
- Consentimiento **expreso**, no tácito. Aviso de privacidad específico para biometría.
- El flujo de autorización debe registrar: qué se pide, para qué, quién autorizó, cuándo, y debe ser revocable.
- Multi-tenant: **cero cruce de datos biométricos entre negocios distintos** aunque compartan el mismo motor/código.

### 2.4 REPSE (subcontratación especializada)
- Aplica cuando se pone personal propio a disposición de un tercero para actividades fuera del objeto social de ese tercero. Sanciones concentradas en construcción (32%) y seguridad privada (18%) — exactamente los verticales de personal distribuido de este sistema.
- Cada asignación (`reservacion`) debería poder registrar bajo qué número de registro REPSE opera, cuando aplique.

---

## 3. Arquitectura objetivo

**Stack (estándar RANNIX):** React/Vite/Tailwind en Netlify · Supabase/Postgres con RLS · Netlify Functions como proxy de APIs sensibles (nunca exponer llaves en frontend) · PWA-ready.

**Dos modos de captura de asistencia, mismo registro central:**
1. **Fijo** — lector biométrico USB (U.are.U 4500 / clones ZKTeco) + agente local (DigitalPersona Lite Client + `@digitalpersona/websdk`, o ZKFinger SDK según el hardware real) → app web → Supabase.
2. **Móvil** — app con geolocalización + selfie/reconocimiento facial, para personal distribuido (guardias, freelance de eventos, cuadrillas de obra).

Ambos modos alimentan la misma tabla de registros con el mismo estándar de trazabilidad (ver sección 2.2).

**Multi-tenant real:** mismo código y mismo motor de matching/validación, pero **aislamiento total de datos por cliente/tenant** — nunca un banco de identidad compartido entre negocios no relacionados (decisión ya cerrada tras el análisis de riesgo legal/seguridad de esta conversación).

---

## 4. Modelo de datos — heredado de AppSCPF (GeneXus), modernizado a Postgres/Supabase

> Nomenclatura GeneXus original entre paréntesis, para que Claude Code entienda de dónde viene cada campo si encuentra referencias cruzadas en el KB original.

### 4.1 `empleados` (Empleados)
Campos identificados en el KB real: identificador, banco (`IdBanco`), empresa pagadora (`IdEmpresaPagadora` — ligado a listas, confirma que puede haber más de una pagadora por empleado histórico), puesto (`IdPuesto`), sucursal (`IdSucursal`), ciclo de pago (`Ciclo_de_Pago`), status, timestamps de creación/modificación.

Campos nuevos a agregar para 2026:
- `consentimiento_biometrico_id` (FK a tabla de consentimientos, sección 4.6)
- `regimen_fiscal` (nómina vs honorarios/asimilados — ver 4.5)
- `tenant_id`

### 4.2 `puestos` (Puestos)
Catálogo de roles/posiciones: título, unidad de negocio, ciclo de pago, empresa pagadora asociada. **Un empleado puede tener certeza distinta por puesto** (ver `PRC_ObtenerCertezaPuesto` en 5.1) — el scoring de confiabilidad no es global a la persona, es por rol que desempeña.

### 4.3 `pedidos` y `pedidos_detalle` (Pedidos / Pedidos_Detalle)
Un `pedido` es la solicitud de personal para un evento/proyecto (equivalente a "requisición"). Campos reales: sucursal, unidad de negocio, sociedad, costo por nómina, status, título, creado/modificado por.

`pedidos_detalle` desglosa el pedido por puesto requerido: puesto, costo por nómina, status, título, unidad de negocio.

**Jerarquía de organización confirmada en la documentación operativa:** sucursal → unidad de negocio → evento → fecha → producto. Reconstruir como estructura de nodos, no como tabla plana — el UI original coloreaba por % de cobertura (verde >80%, rojo <80%) en cada nivel.

### 4.4 `reservaciones` (TE_Reservacion) — tabla central, la más rica del sistema heredado

Esta es la tabla que une asistencia + asignación + pago + cumplimiento en un solo registro por persona-turno. Campos reales identificados (traducidos):

| Campo original | Propósito |
|---|---|
| `IdPedido`, `IdProductoEvento`, `IdPuestoEvento` | a qué pedido/evento/puesto pertenece |
| `EstacionEntrada`, `EstacionSalida` | punto físico de checado — mapea directo a nuestro concepto de "estación" |
| `MedioAsistencia` | biométrico vs manual — trazabilidad de origen |
| `HoraEntradaAsistencia`, `HoraSalidaAsistencia` | timestamps reales de checado |
| `IdTimescanSalida` | referencia al sistema biométrico (Timescan, el equivalente de nuestro lector) |
| `EstadoAsistencia`, `EstatusPago` | dos máquinas de estado independientes: asistencia y pago |
| `PorcentajePuntualidad` | input directo al score de certeza |
| `PenalizacionDias`, `PenalizacionSueldo` | penalización automática ligada a incumplimiento |
| `FolioHonorarios`, `IdPagoHonorario` | liga fiscal a factura de honorarios (ver 4.5) |
| `SaldoVencido` | control de cobranza/pago pendiente |
| `ReglaAplicada` | **campo de auditoría de qué regla de negocio disparó** — replicar este patrón es clave para explicabilidad legal |
| `CitaInicio`, `CitaFin`, `DuracionEnTurnos` | ventana de tiempo del turno asignado |
| `Status` (Reservación) | disponible → preasignado → confirmado → forzada (ver 5.2) |

**Agregar para 2026:** `dispositivo_id` (número de serie del lector, no solo la estación), `consentimiento_id`, `repse_registro_id` (nullable, cuando aplique), `tenant_id`, `geolocalizacion` (lat/lng, solo para modo móvil).

### 4.5 Tratamiento fiscal — honorarios, no nómina tradicional
El personal freelance se paga vía **folios de factura de honorarios** ligados a reservaciones (`PRC_ActFolios`, `PRC_ValidacionFoliosHN`, `PRC_FoliosConsecutivos`), no como nómina asalariada estándar. Esto es una decisión de diseño fiscal real y probada: la tabla de pago debe distinguir claramente régimen nómina vs régimen honorarios/asimilados desde el modelo de datos, no como un flag genérico.

### 4.6 Nueva tabla: `consentimientos` (no existe en el KB original — requisito 2026)
Registro append-only de autorizaciones: qué dato/uso se autorizó, cuándo, revocado o no. Cada registro de asistencia biométrica debe poder rastrearse hasta un consentimiento vigente.

---

## 5. Reglas de negocio identificadas en el KB (procedimientos GeneXus reales)

### 5.1 Certeza / confiabilidad del empleado
- `PRC_ObtenerCertezaPuesto` — calcula certeza **por puesto**, no global
- `PRC_ValidaEmpPuesto` — valida que el empleado califica para el puesto antes de asignar
- `PRC_PorcentajeRetardosFaltas`, `PRC_ActuValoAsisCand` — el score se alimenta de retardos/faltas históricos
- Parámetro `Porcentaje_Certeza_Inicial` — todo empleado nuevo arranca con un valor base configurable, no en cero

### 5.2 Cancelaciones y traslapes
- `Horas_Antes_Para_Cancelar_Pedido` (parámetro numérico configurable — el "72 horas" es un valor de parámetro, no una regla fija en código)
- `Horas_Entre_Turnos` (parámetro numérico configurable — confirma que el margen de seguridad entre turnos que Roberto describió sí existía, y era configurable, no calculado por distancia/API de mapas)
- `PRC_Noempalmereservacion`, `PRC_NoEmpalmeFechasEnBloque` — detección de traslape de horarios
- `PRC_CancelacionAutomaticaPreasignados`, `PRC_CancelacionReservacionesBloque` — cancelación masiva/automática
- `PRC_ValidacionesCancelarReservacion` — reglas de validación antes de permitir cancelar
- Parámetros `Permitir_Cancelaciones`, `Permitir_Cancelar_Confirmaciones` — toggles de política, no hardcoded

### 5.3 Nómina y dispersión
- `PRC_CalculoNomina`, `PRC_CalculoNominaIndividual` — cálculo de nómina general e individual
- `PRC_DispersionNomina`, `PRC_DispersionNomHA`, `PRC_DispersionHN` — dispersión diferenciada (nómina normal vs honorarios)
- `PRC_ReportePrecaucionesNomina` — reporte de inconsistencias antes de cerrar (cuenta bancaria faltante, régimen de pago, pagadora — mencionado también en la guía operativa de "Cierre de nómina")
- `PRC_RecalculoSueldo`, `PRC_CalculaPagoHonorariosExtra` — ajustes y pagos extraordinarios

### 5.4 Reclutamiento y alta masiva
- `PRC_AltaEmpleadosCursoInduccion`, `PRC_ActualizaAsistenciaCursoInduccion` — el alta a empleado solo ocurre tras confirmar asistencia a inducción (documentado también en la guía "Alta masiva de empleados")
- `PRC_ContarIntegrantesEventoPrueba` — el "evento prueba" como filtro adicional antes del alta definitiva
- `PRC_ValidaRfcCurp`, `PRC_ValidarRFC` — validación de identidad fiscal desde el alta

---

## 6. Brechas a modernizar respecto al sistema heredado

| Componente heredado (2018-2019) | Reemplazo moderno |
|---|---|
| Seguridad GAM (GeneXus Access Manager) | Supabase Auth + RLS por tenant |
| Sin mención de REPSE (es anterior a la reforma 2021) | Agregar campo/flujo REPSE desde el modelo de datos |
| Biométrico "Timescan" mal aprovechado (mencionado explícitamente como problema en la documentación operativa) | Arquitectura dual fijo/móvil bien integrada desde el diseño, no como parche |
| Sin flujo de consentimiento explícito | Tabla `consentimientos` append-only, requisito para valor legal del registro (sección 2.1) |
| Arquitectura on-premise / servidor propio | Cloud-first: Netlify + Supabase, sin dependencia de máquina física |

---

## 7. Plan de fases sugerido

1. **Núcleo de datos + checador fijo** — `empleados`, `puestos`, tabla de registros de asistencia (versión simplificada de `reservaciones`), consentimientos, multi-tenant desde el día uno.
2. **Checador móvil** — mismo registro central, captura por GPS + selfie para personal distribuido.
3. **Pedidos/eventos + asignación diaria** — jerarquía sucursal→unidad→evento→fecha→producto, estados de reservación (disponible/preasignado/confirmado/forzada).
4. **Certeza y penalizaciones** — score por puesto, reglas de cancelación/traslape con parámetros configurables.
5. **Nómina/honorarios** — dispersión diferenciada, folios fiscales, reportes de inconsistencias antes de cierre.
6. **REPSE y reportes de cumplimiento** — evidencia lista para auditoría STPS/IMSS.

Cada fase debe ser demostrable a un cliente piloto real antes de avanzar a la siguiente — no construir todo antes de validar con uso real (ver discusión sobre MVP en esta conversación: la calidad del código con Claude Code ya no es el cuello de botella; el aprendizaje de uso real sigue siéndolo).
