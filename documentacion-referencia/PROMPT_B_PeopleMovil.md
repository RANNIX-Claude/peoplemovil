# PROMPT B — PeopleMovil 2.0
### Para pegar en Claude Code DESPUÉS de correr el PROMPT A del Súper Prompt Maestro (plataforma base ya desplegada con credenciales, identidad visual y módulo de suscripción funcionando)

---

```
ROL: Arquitecto de datos y desarrollador fullstack senior.
Sin preguntas. Decide razonablemente y avanza.

LEE PRIMERO, en este orden, antes de tocar código:
1. CLAUDE.md — las dimensiones de tiempo y el módulo de suscripciones
   YA EXISTEN (los creó el Prompt A). No los recrees.
2. La carpeta /documentacion-referencia completa:
   - PeopleMovil_2.0_Spec_para_ClaudeCode.md
   - PeopleMovil_2.0_Funcionalidad_Completa.md
   - Glosario_Reglas_de_Negocio_PeopleMovil.md
   - reglas_negocio_PRC_completo.txt
   - reglas_transacciones_nucleo.txt
   - Catalogo Puestos.xlsx, Sociedades Pagadoras.xlsx, Catalogo Sociedades
     Propias.xlsx, Catalogo Uniformes.xlsx (y el resto de catálogos de la carpeta)
   - Documentos operativos originales (propuesta OCESA, guías de nómina/
     reservaciones/alta masiva)

Si algo se contradice entre estos documentos, decide con el criterio que
más se acerque a los principios no negociables de abajo y avanza — igual
que harías con cualquier otra ambigüedad. Documenta la decisión en
CLAUDE.md, no la preguntes.

EL PRODUCTO ES:
PeopleMovil — un motor de gestión de personal rotativo multi-rol para
empresas con trabajadores distribuidos por sitio/turno (seguridad,
construcción, eventos, retail/impulsadoras). Resuelve dos problemas:
(1) el registro electrónico de jornada que exige la reforma laboral
mexicana vigente desde mayo 2026 con obligatoriedad plena en enero 2027,
y (2) la asignación diaria de personal a distintos sitios/roles con
control de certeza, traslapes y nómina/honorarios — heredado y probado
en un sistema real (GeneXus) que operó años en producción para gestión
de personal freelance de eventos masivos.

Planes de suscripción (adapta cat_plan_suscripcion y suscripciones,
que ya existen del Prompt A, a nivel EMPRESA/TENANT, no a nivel usuario
individual — cada empresa cliente tiene una suscripción y dentro de ella
múltiples usuarios/empleados):
- FREE / piloto: 1 sitio, hasta 15 trabajadores, solo checador fijo.
- PRO: sitios y trabajadores ilimitados, checador fijo + móvil,
  asignación/pedidos, certeza y penalizaciones, nómina/honorarios, REPSE.

━━━ FASE 1: ANÁLISIS ━━━
Documenta a partir de los documentos de referencia (no inventes desde
cero, ya está resuelto en ellos):
- Entidades principales (empleados, plazas/puestos, sitios, pedidos/
  asignaciones, reservaciones/registros de asistencia, consentimientos,
  folios de pago).
- Procesos clave: alta de candidato → inducción → promoción a empleado;
  pedido → preasignación → confirmación → checado → nómina.
- Qué automatiza Claude/el sistema: validación de traslape entre turnos,
  validación de certeza mínima por plaza, cancelación automática de
  preasignados sin confirmar, cálculo de nómina por asistencia real.
- Qué límite tiene cada plan (FREE vs PRO), según la lista de arriba.

Muéstrame el análisis. Espera mi confirmación antes de la Fase 2 — esta
es la única pausa del proceso, tal como indica el método.

━━━ FASE 2: MODELO DE DATOS (3FN) ━━━
Una vez confirmada la Fase 1, construye sin volver a preguntar:

Catálogos del negocio (semilla con los valores REALES de los archivos
.xlsx de la carpeta de referencia, no valores de ejemplo inventados):
- cat_puestos (con certeza_inicial, porcentaje_minimo, horas_entre_turnos,
  horas_antes_cancelar, penalizacion_retardo, penalizacion_falta,
  requiere_biometrico, regimen_pago, ciclo_pago — todo como columnas
  editables desde catálogo, NUNCA hardcodeadas en código)
- cat_sitios (generaliza "sucursal/evento" a cualquier tipo de sitio:
  tienda, obra, foro, oficina)
- cat_sociedades_pagadoras, cat_sociedades_propias
- cat_uniformes, cat_bancos

Tablas principales con auditoría completa (created_at, created_by,
updated_at, updated_by, tenant_id en TODAS):
- empleados (con relación N:N a plazas — una persona puede tener varias)
- pedidos y pedidos_detalle
- reservaciones (tabla central: estación entrada/salida, medio de
  asistencia, hora entrada/salida real, estado de asistencia, estado de
  reservación, penalización aplicada, folio de pago, regla_aplicada
  como campo de auditoría de qué validación disparó cada decisión)
- consentimientos (append-only, ligado a cada registro biométrico)
- dispositivos_biometricos (serie, tipo: fijo/móvil, sitio asignado)

Reglas a implementar como funciones/triggers de Postgres, traducidas
con fidelidad del código real en reglas_negocio_PRC_completo.txt y
reglas_transacciones_nucleo.txt — no las reinterpretes libremente:
- Validación de traslape/margen entre turnos por puesto
  (equivalente a PRC_Noempalmereservacion)
- Validación de certeza mínima por plaza antes de reservar
  (equivalente a PRC_ValidaEmpPuesto + PRC_ObtenerCertezaPuesto)
- Ventana de cancelación por puesto (equivalente a
  PRC_ValidacionesCancelarReservacion)
- Cancelación automática de preasignados sin confirmar
  (equivalente a PRC_CancelacionAutomaticaPreasignados)
- Folios consecutivos independientes por tipo de entidad
  (equivalente a PRC_FoliosConsecutivos)
- Registro append-only para reservaciones/asistencia: solo INSERT,
  las correcciones son registros nuevos enlazados al original

Entrega también: reset_database.sql y MODELO_DATOS.md documentando cada
tabla y su relación con la regla de negocio de origen.

Cada tabla con límite por plan debe verificar el plan activo del TENANT
(no del usuario individual) antes de permitir la operación.

━━━ FASE 3: MÓDULOS FUNCIONALES ━━━
1. Core del negocio — CRUD de empleados, plazas, sitios, pedidos, con
   límites según plan del tenant
2. Checador fijo — captura vía lector USB + agente local, registro
   append-only con estación/dispositivo/consentimiento
3. Checador móvil — app con geolocalización + selfie, mismo registro
   central que el checador fijo
4. Asignación y certeza — flujo de pedido → preasignación →
   confirmación → validación automática de traslape y certeza
5. Nómina/honorarios — cálculo por asistencia real, dispersión
   diferenciada (nómina/honorarios normales/honorarios asimilados),
   reporte de precauciones antes de cierre
6. Onboarding — flujo de bienvenida + email de Resend para nuevas
   empresas cliente (tenants)
7. Notificaciones — email (Resend) + WhatsApp (Twilio) para: asignación
   de turno, recordatorio de checado, resultado de nómina
8. Agentes IA — actualiza los system prompts de chat-operativo.js y
   chat-analitico.js con contexto real de PeopleMovil (dudas sobre
   checador, asignaciones, nómina)

━━━ FASE 4: UI ━━━
Tabs: Dashboard | Personal | Sitios y Asignación | Checador |
Nómina | Pricing | Configuración

Dashboard: KPIs de cobertura por sitio (semáforo verde >80% / rojo <80%,
heredado del sistema original), alertas de traslapes rechazados,
próximos vencimientos de consentimiento.

━━━ FASE 5: VERIFICA Y DESPLIEGA ━━━
Antes de desplegar, confirma en checklist propio (no me preguntes,
repórtalo al terminar):
  ✅/❌ Ningún parámetro de negocio (certeza, márgenes, penalizaciones)
        está hardcodeado — todos viven en catálogos editables
  ✅/❌ Registro de asistencia es append-only verificado con prueba real
  ✅/❌ RLS aísla datos entre tenants (prueba con 2 tenants de ejemplo)
  ✅/❌ Checador fijo y móvil escriben al mismo registro central
  ✅/❌ Cada registro biométrico tiene consentimiento vinculado
  ✅/❌ Se ve bien en móvil

  git add .
  git commit -m "feat: PeopleMovil - checador y asignación de personal multi-tenant"
  git push origin main

Verifica el deploy vía MCP Netlify. Muestra la URL pública.
Actualiza CLAUDE.md con el estado de avance por fase.
```
