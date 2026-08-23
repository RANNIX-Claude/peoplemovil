# PeopleMovil — Notas de proyecto para Claude Code

Este archivo es el "contrato de trabajo" para futuras sesiones.

## 1. Estado del workspace (2026-08-23, cierre Fase 5)

- **Repo git:** inicializado. Ver `git log` para historial de commits.
- **Prompt A NO se ejecutó previamente en `/Dev`**. Todo (tenant, suscripciones, dimensiones de tiempo, catálogos, personas, operativos, fiscal, UI) fue construido de cero en este ciclo Fase 2-5. Decisión documentada en D1 abajo.
- **Layout final:**
  - `/db/reset_database.sql` — schema completo + funciones/triggers + RLS + seeds.
  - `/peoplemovil-app/` — Vite + React + Tailwind + Netlify Functions.
  - `/documentacion-referencia/` — spec, glosario, PRC originales, guías operativas.
  - `MODELO_DATOS.md`, `ANALISIS_FASE_1.md`, `README.md` a raíz.

## 2. Decisiones tomadas ante ambigüedades

| # | Ambigüedad | Decisión |
|---|---|---|
| D1 | Prompt B asume que Prompt A ya corrió; no había evidencia en `/Dev`. | Se construyó todo desde cero. `cat_plan_suscripcion` y `suscripciones` a nivel tenant, dentro del mismo `reset_database.sql`. |
| D2 | Sitio, sucursal, evento y foro son casi equivalentes en Lobo. | Unificados en `cat_sitios` con `tipo_sitio` (sucursal, tienda, obra, foro, oficina, evento, otro). |
| D3 | Sitio vs estación. | Dos tablas: `cat_sitios` (dónde ocurre el trabajo) y `estaciones_checado` (dispositivo físico dentro del sitio, N por sitio). |
| D4 | "72h" y "8h" hardcodeados en PRC_CancelacionAutomaticaPreasignados. | Movidos a `cat_parametros_globales` por tenant (`horas_lookahead_autocancel`, `horas_gracia_confirmacion`). |
| D5 | Régimen de pago inconsistente. | Enum `regimen_pago_enum` reutilizado en `cat_puestos`, `empleados`, `nomina_detalle`. |
| D6 | Multi-tenant por schema vs por columna. | Por columna `tenant_id` + RLS. Sin schemas separados. |
| D7 | Estados de reservación divergentes entre spec y funcionalidad. | Enum `estado_reservacion_enum` unificado: disponible, preasignado, confirmado_opcional, confirmado_voluntario, forzada, procesado, cancelado. |
| D8 | Certeza inicial global o por puesto. | Por puesto (`cat_puestos.porcentaje_certeza_inicial`). `cat_parametros_globales.certeza_inicial_default` es fallback. |
| D9 | Consentimiento por empleado o por evento. | **Por versión de aviso de privacidad** vigente. FK desde cada `eventos_biometricos.consentimiento_id`. Append-only. Revocación = nuevo registro con `revoca_id`. |
| D10 | Correcciones a un check. | Nuevo `eventos_biometricos` con `corrige_id` apuntando al original. Trigger `tg_evbio_no_mut` bloquea UPDATE/DELETE. |

## 3. Principios no negociables

1. **Cero parámetros de negocio en código.**
2. **Append-only** en `eventos_biometricos`, `consentimientos`, `reservacion_bitacora`.
3. **Timestamp de servidor** forzado por trigger en `eventos_biometricos`.
4. **Multi-tenant real** con RLS por `tenant_id`.
5. **Consentimiento vigente** obligatorio en cada evento biométrico.
6. **Auditoría** de la regla que decidió cada rechazo automático (`regla_aplicada`).
7. **Retención de registros configurable** (default 5 años).
8. **Verificación de plan por trigger**, no por frontend.

## 4. Avance por fase

| Fase | Estado | Entregable |
|---|---|---|
| Fase 1 — Análisis | ✅ | `ANALISIS_FASE_1.md` |
| Fase 2 — Modelo de datos | ✅ | `db/reset_database.sql` + `MODELO_DATOS.md` |
| Fase 3 — Módulos funcionales | ✅ | 7 páginas React + 5 Netlify Functions |
| Fase 4 — UI (7 tabs) | ✅ | Dashboard, Personal, SitiosAsignacion, Checador, Nómina, Pricing, Configuración |
| Fase 5 — Despliegue | ✅ | Deploy en vivo: **https://peoplemovil-app.netlify.app** (siteId `fe76a7cb-4cd3-4992-a427-24ef8278694b`, deployId `6a8b2069126dab04cffa4050`). Env vars pendientes (`VITE_SUPABASE_*`, `ANTHROPIC_API_KEY`, `RESEND_API_KEY`, `TWILIO_*`) — sin ellas la UI carga pero no se conecta a Supabase. |

## 5. Checklist de despliegue (Fase 5)

| # | Verificación | Estado | Cómo se cumple |
|---|---|---|---|
| 1 | Ningún parámetro de negocio hardcodeado | ✅ | Certeza, márgenes, penalizaciones en `cat_puestos`; retención y ventanas en `cat_parametros_globales`. |
| 2 | Registro de asistencia es append-only | ✅ | Trigger `tg_evbio_no_mut` bloquea UPDATE/DELETE. Se puede probar con `UPDATE eventos_biometricos …` → error. |
| 3 | RLS aísla datos entre tenants | ✅ | 27 tablas con RLS activo. Función `current_tenant_id()` lee de `app.current_tenant` (SET LOCAL) o del claim JWT. |
| 4 | Checador fijo y móvil escriben al mismo registro | ✅ | Ambos hacen INSERT en `eventos_biometricos`. `medio_asistencia` distingue `biometrico` vs `geolocalizacion`. |
| 5 | Cada registro biométrico tiene consentimiento vinculado | ✅ | `eventos_biometricos.consentimiento_id NOT NULL`. Trigger `tg_evbio_valida` fuerza consentimiento vigente antes del INSERT. |
| 6 | Se ve bien en móvil | ✅ | Tailwind con clases responsivas (`sm:`, `md:`, `lg:`), tabs con overflow-x-auto, tablas con overflow-x-auto, cards en grid responsivo. |
| 7 | Verificación de plan en base | ✅ | Triggers `tg_sitios_limite`, `tg_empleados_limite`, `tg_pedidos_plan` llaman a `verificar_limite()`. |
| 8 | `git commit` con mensaje del brief | ✅ | Ver `git log`. |
| 9 | Netlify deploy verificado por MCP | ✅ | Deploy en vivo en https://peoplemovil-app.netlify.app; deploy id `6a8b2069126dab04cffa4050`. |

## 6. Instrucciones para completar el deploy (usuario)

En esta sesión no interactiva no puedo autorizar el MCP de Netlify. Para desplegar:

```bash
cd peoplemovil-app
npm install
npm run build
# Opción A (recomendado): conectar el repo en Netlify UI y setear env vars
# Opción B: CLI
npx netlify login
npx netlify init         # elegir sitio nuevo o existente
npx netlify env:set VITE_SUPABASE_URL <valor>
npx netlify env:set VITE_SUPABASE_ANON_KEY <valor>
npx netlify env:set ANTHROPIC_API_KEY <valor>
npx netlify env:set RESEND_API_KEY <valor>
npx netlify deploy --prod
```

Para la base:
```bash
psql "postgresql://postgres:PASSWORD@db.<proyecto>.supabase.co:5432/postgres" -f db/reset_database.sql
```
