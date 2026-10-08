# PeopleMovil — Notas de proyecto para Claude Code

Este archivo es el "contrato de trabajo" para futuras sesiones.

## 1. Estado del workspace (2026-10-08)

- **Repo git:** conectado a `github.com/irpdesarrollo/peoplemovil`. Ver `git log` para historial de commits.
- **Netlify:** sitio **https://peoplemovil-app.netlify.app** ligado por Git (push a la rama principal dispara deploy automático). Ya no requiere `netlify deploy` manual.
- **Prompt A NO se ejecutó previamente en `/Dev`**. Todo (tenant, suscripciones, dimensiones de tiempo, catálogos, personas, operativos, fiscal, UI) fue construido de cero en este ciclo Fase 2-5. Decisión documentada en D1 abajo.
- **Layout final:**
  - `/db/reset_database.sql` — schema completo + funciones/triggers + RLS + seeds + migraciones 001-017 (ver §7).
  - `/db/seed_demo_usuarios_multiempresa.sql` — script aparte (no se corre con el reset) para dar de alta las 6 cuentas de prueba de los 3 tenants nuevos de la Migración 017 (ver §12).
  - `/peoplemovil-app/` — Vite + React + Tailwind + Netlify Functions. Incluye portal admin (interno, con login+permisos), portal público de vacantes, y portal freelance (bolsa + reservación).
  - `/documentacion-referencia/` — spec, glosario, PRC originales, guías operativas, hallazgos de manuales OCESA y del sistema anterior (ASP.NET "Ocesa RH" / Lobo 2017-2018).
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
| D11 | Demostrar multi-tenant con verticales fuera de eventos (pedido 2026-10-08: construcción, seguridad privada, BTL/promotoras). | Se agregaron como datos (Migración 017), **cero cambios de esquema**: mismos `tc_sitios`/`tc_puestos`/`tc_turnos`/`tc_clientes` por `tenant_id`. Confirma que D6 (tenant por columna) sí generaliza a otros giros. |
| D12 | Requisitos ad-hoc de un pedido (ej. "requiere modelo, no impulsadora genérica, 1.70m+") -- ¿columna nueva o campo libre? | Se usa `te_pedidos_detalle.indicaciones_especiales` (ya existía). El único requisito *estructural* de puesto (sexo) usa `tc_puestos.sexo_requerido`, que ya existía en el esquema -- mismo mecanismo que el legado Lobo con "Modelo Star 1-5" (ver pendiente §11 de `tc_productos.id_puesto`). |
| D13 | Fotos de empleados demo ("rostros para poder cargarlos"). | Se usó `te_empleados.foto_url` (ya existía) con avatares sintéticos de DiceBear (`api.dicebear.com`, determinista por seed) en vez de generar o subir rostros fotorrealistas de personas inexistentes -- evita cualquier ambigüedad de "foto real vs. fake" en datos de prueba. |

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
| Fase 5 — Despliegue | ✅ | Deploy en vivo: **https://peoplemovil-app.netlify.app**, ahora vía Git integration (push a main = deploy automático). Env vars de Supabase configuradas en Netlify. |
| Fase 6 — Bolsa de freelance + portal de reservación | ✅ | Portal `/portal` (login propio, Publicaciones, Mis eventos, Mis pagos, Perfil). Migraciones 012-016 (ver §7). Validado con cuenta real del usuario. |
| Fase 7 — Autenticación y permisos en el admin | ✅ | Login `/admin/login` + `AdminAuthProvider` + `RequireAdminAuth` + menú lateral filtrado por permiso (`tc_permisos`/`tr_rol_permiso`). Gating de botones (ejemplo: Catálogos) ver §8. |
| Fase 8 — Demo multi-vertical (3 tenants nuevos) | ✅ Aplicado a la base real (2026-10-08) | Construcción, Seguridad privada y BTL/Promotoras (Migración 017): catálogos completos + empleados + pedidos de ejemplo por tenant. 6 cuentas de prueba (`db/seed_demo_usuarios_multiempresa.sql`) creadas y ligadas. Verificado: 4 tenants, empleados 11/20/10/12, pedidos 192/1/4/3 por tenant — ver §12. |

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

## 7. Migraciones recientes (011-016, en `db/reset_database.sql`)

| # | Qué hace |
|---|---|
| 011 | Corrige `tc_fases_evento` a los 5 valores reales de Lobo 2018: No aplica(0), Preparación(1), Montaje(2), Show(3), Desmontaje(4). Simplificación intencional vs. las 8 fases de 2017 (confirmado por el usuario). |
| 012 | Bolsa de freelance: agrega `te_empleados.sucursal_id`, `tr_empleado_plaza.certeza`, `te_lista_negra_empleados.sitio_id`/`fecha_expiracion`. Reescribe `v_publicaciones_para_freelance` y `v_agenda_freelance` para que cada freelance solo vea/gestione **lo suyo** (`mi_empleado_id()`), filtrado por elegibilidad (ver §9). |
| 013 | **Fix crítico**: `current_user_id()`/`current_tenant_id()` leían el GUC obsoleto `request.jwt.claim.sub`, que este PostgREST no expone. Se corrige para leer `request.jwt.claims::json->>'sub'` (con el claim viejo como fallback). Sin esto, ningún usuario autenticado resolvía su identidad. |
| 014 | `inscribirme_a_publicacion()`: quita un cast inválido `time with time zone → interval`. |
| 015 | `inscribirme_a_publicacion()`: usa la fecha/hora real de la línea de pedido (`te_pedidos_detalle.fecha_cita/hora_cita_inicio/hora_cita_fin`, con fallback a `te_pedido_fechas` y al header) en vez de `te_pedidos.hora_inicio/hora_fin` (casi siempre NULL) — corrige falsos rechazos por "traslape". |
| 016 | `mi_usuario()` y `mis_permisos()` — RPCs que usa el admin para resolver usuario interno + permisos tras login. |
| 017 | Tenants demo multi-vertical: Construcción, Seguridad privada y BTL/Promotoras. Catálogos completos (sitios, puestos, turnos, clientes, unidades de negocio, roles/permisos) + empleados + pedidos de ejemplo por tenant. **Cero columnas nuevas** — ver D11/D12/D13. |

## 8. Autenticación y permisos (admin interno)

- `src/lib/AdminAuthContext.jsx` — contexto React: `session`, `usuario` (via RPC `mi_usuario`), `permisos` (Set, via RPC `mis_permisos`), `hasPermiso(codigo)`, `signOut`.
- `src/components/admin/RequireAdminAuth.jsx` — guard de ruta: sin sesión → redirige a `/admin/login`; con sesión pero sin usuario interno vinculado (`te_usuarios.auth_user_id`) → mensaje de cuenta no vinculada.
- `src/components/admin/AdminShell.jsx` — cada item del menú tiene `requiere: '<codigo_permiso>'|null`; el menú se filtra con `hasPermiso`. En modo demo (sin Supabase) muestra todo.
- **Patrón de gating de botones** (ejemplo en `CatalogosAdmin.jsx`): `const puedeEditar = hasPermiso('catalogos.editar')`, oculta "Agregar"/"Eliminar" si no aplica. **Pendiente**: extender este mismo patrón a los demás módulos admin (hoy solo Catálogos lo tiene).
- **Importante — RLS no es permission-aware todavía**: hoy el RLS solo filtra por `tenant_id`. El gating de `hasPermiso()` es solo de UI. Si se expone la API directamente (sin pasar por la UI), un usuario autenticado del tenant puede escribir en tablas para las que su rol no tiene permiso. No se ha pedido todavía cerrar esta brecha — mencionarlo si el usuario pregunta por seguridad de la API.
- **Importante — un solo cliente Supabase compartido**: `src/lib/supabase.js` es una única instancia para admin y freelance. Iniciar sesión en un portal pisa la sesión del otro en el mismo navegador/`localStorage` (clave `sb-<proyecto>-auth-token`). Si una prueba de login "no muestra nada", primero verificar con qué cuenta quedó la sesión activa antes de asumir un bug de datos.

## 9. Portal freelance — reglas de negocio confirmadas

- **Modelo "bolsa abierta", no asignación individual**: `Publicaciones` es un tablero tipo bolsa de trabajo — cualquier freelance cuyo perfil (puesto/plaza) cumpla la elegibilidad puede ver la oferta y auto-inscribirse (`inscribirme_a_publicacion()`), primero en llegar. No hay asignación 1 a 1 por el sistema. (Confirmado por el usuario 2026-10-08: "es un portal de publicaciones de ofertas de las vacantes entonces esta libre al público".)
- **Filtros de elegibilidad** aplicados en `v_publicaciones_para_freelance` (no restringen la visibilidad "pública" de la bolsa en sí, sino qué ofertas específicas le aplican a cada freelance según su perfil):
  - `certeza >= tc_puestos.porcentaje_minimo` (umbral mínimo de confiabilidad por puesto).
  - Coincidencia de `sucursal_id` (si ambos la tienen definida).
  - Exclusión por lista negra (`te_lista_negra_empleados`), acotada por sitio + fecha de expiración.
- Cuentas de prueba (10 freelance sintéticos, ver `scratchpad/demo_freelance/demo_freelancers.json`): 8 califican, 1 bloqueado por certeza baja (0.5 vs mínimo), 1 bloqueado por sucursal distinta (GDL vs CDMX) — diseñado así a propósito para validar el filtro.

## 10. Cuentas de prueba

| Cuenta | Rol | Contraseña |
|---|---|---|
| `roberto.aguilar.cota@gmail.com` | Freelance (cuenta real del usuario, vinculada a `te_empleados`) | `PortalDemo2026!` |
| `admin.demo01@peoplemovil.demo` / `admin.demo02@peoplemovil.demo` | Administrador | `AdminDemo2026!` |
| `lobo.demo01@peoplemovil.demo` / `lobo.demo02@peoplemovil.demo` | Lobo | `AdminDemo2026!` |
| `operacion.demo01@peoplemovil.demo` / `operacion.demo02@peoplemovil.demo` | Operación | `AdminDemo2026!` |
| `freelance.demo01..10@peoplemovil.demo` | Freelance sintéticos | ver `scratchpad/demo_freelance/` (contraseña generada junto con las cuentas; regenerar con `build.py` si se pierde) |
| `admin.construccion01@peoplemovil.demo` | Administrador — tenant Construcción | `Multiempresa2026!` |
| `freelance.construccion01@peoplemovil.demo` | Freelance (ligada a empleado folio 1, Albañil) — tenant Construcción | `Multiempresa2026!` |
| `admin.seguridad01@peoplemovil.demo` | Administrador — tenant Seguridad privada | `Multiempresa2026!` |
| `freelance.seguridad01@peoplemovil.demo` | Freelance (ligada a empleado folio 1, Vigilante) — tenant Seguridad privada | `Multiempresa2026!` |
| `admin.btl01@peoplemovil.demo` | Administrador — tenant BTL/Promotoras | `Multiempresa2026!` |
| `freelance.btl01@peoplemovil.demo` | Freelance (ligada a empleado folio 1, Promotora) — tenant BTL/Promotoras | `Multiempresa2026!` |

Todas las cuentas de prueba se crearon con `INSERT` directo en `auth.users` (bypass del formulario de signup, que rechaza dominios `.demo`/`.test`) — ver scripts en `scratchpad/demo_freelance/` (no versionados en git). Las 6 cuentas multi-empresa de la Fase 8 están en `db/seed_demo_usuarios_multiempresa.sql` (sí versionado) — **pendiente de correr**, ver §11.

## 12. Fase 8 — Demo multi-vertical (construcción / seguridad / BTL)

Pedido del usuario (2026-10-08): demostrar que PeopleMovil generaliza a giros fuera de eventos/OCESA. Se agregaron 3 tenants nuevos, cada uno con catálogos propios (mismo esquema, cero columnas nuevas — D11):

- **`00000000-0000-0000-0000-000000000002` — Edifica Talento Obra Civil** (construcción): 14 puestos de obra (Albañil, Plomero, Carpintero, Electricista, Operador de maquinaria, Supervisor/Residente de obra, etc.), 3 obras como sitios, 20 empleados demo (10 albañiles/2 plomeros/3 carpinteros + soporte, el ejemplo exacto que se pidió), 1 pedido liberado con ese staffing en "Residencial Las Lomas — Torre A".
- **`00000000-0000-0000-0000-000000000003` — Guardia Total Seguridad Privada** (seguridad): 7 puestos (Vigilante de acceso/piso, Guardia de CEDIS 24x24, Monitorista, Supervisor de turno, Jefe de zona, Escolta), 5 sitios (2 Walmart, 1 CEDIS, 1 sucursal bancaria, 1 oficina de gobierno), 10 empleados, 4 pedidos liberados: Walmart Satélite cubierto con 3 relevos de 8h (matutino/vespertino/nocturno), CEDIS Cuautitlán con 1 solo guardia en turno 24x24, banco y gobierno con matutino+vespertino (sin nocturno, horario bancario).
- **`00000000-0000-0000-0000-000000000004` — Impacto BTL Promotoras y Activaciones**: 7 puestos (Promotora/Impulsadora, Demostrador(a), Edecán, Supervisor de piso, Coordinador, + 2 puestos "Modelo Evento Premium" con `sexo_requerido` explícito, F y M), 5 sitios (Walmart Félix Cuevas, Walmart Universidad, Chedraui Toreo, La Comer Del Valle, Salón Diamante Polanco), 12 empleados, 3 pedidos: activación Colgate en Walmart Félix Cuevas y Chedraui Toreo (cobertura **solo sábado y domingo**, vía `indicaciones_especiales`, no hay columna de recurrencia — D12), y lanzamiento de una marca de lujo (ficticia: "Joyería Diamante & Platino") que requiere modelos profesionales mixtos, no impulsadoras genéricas.

**Aplicado a la base real (2026-10-08):** en esta sesión el MCP de Supabase conectado sí apuntaba al proyecto PeopleMovil (`https://ysyeidudlvdkqpckspcy.supabase.co`) — la base ya tenía datos reales (192 pedidos, 11 empleados, 85 eventos, 6 usuarios del tenant original), por lo que correr `reset_database.sql` completo (empieza con `DROP SCHEMA public CASCADE`) habría borrado todo. En vez de eso se extrajo solo el bloque de la Migración 017 (líneas 4849-5265, puro `INSERT`, sin DDL) y se aplicó como migración incremental vía `apply_migration` (`017_tenants_demo_multivertical`), y luego se corrió `db/seed_demo_usuarios_multiempresa.sql` completo contra `auth.users`/`auth.identities`.

Verificado tras aplicar: `te_tenants` tiene 4 filas (eventos, construccion, seguridad_privada, btl_activaciones); `te_empleados` 11/20/10/12 por tenant; `te_pedidos` 192/1/4/3 por tenant; las 6 cuentas demo (`admin.construccion01`, `freelance.construccion01`, `admin.seguridad01`, `freelance.seguridad01`, `admin.btl01`, `freelance.btl01`, todas `@peoplemovil.demo`) quedaron en `auth.users`+`auth.identities` y correctamente ligadas (las 3 admin a `te_usuarios`+rol `administrador`; las 3 freelance a `te_empleados.auth_user_id` del folio 1 de su tenant). Pendiente: probar en vivo (login real) que cada tenant solo ve sus propios catálogos vía RLS — no se probó el login real en esta sesión, solo se verificó el estado de la base.

**Nota de seguridad aparte (no relacionada a esta migración):** el advisor de Supabase reporta que `tc_planes_suscripcion` y `tc_permisos` tienen RLS deshabilitado — ambas quedan expuestas por completo a `anon`/`authenticated`. No se aplicó corrección automática (activar RLS sin políticas bloquearía el acceso); queda pendiente que el usuario decida las políticas.

## 11. Pendientes conocidos (deuda técnica)

- **`tc_productos.id_puesto`**: vinculación incompleta. Se mejoró de 8→28→53 (de 81 productos) cruzando contra `dbo_ProductosPorPuesto` (Access, 1186 filas), pero quedó inconcluso — el último conteo de "sin resolver" no cuadraba contra el total y no se reverificó. Algunos puestos referenciados en el Access real (p.ej. "Cajero Estacionamientos", "Control Vehicular", "Valet Parking", "Modelo Star 1-5") posiblemente no existen aún en `tc_puestos` y requerirían alta nueva, no solo match. Síntoma visible: en el admin, "Agregar detalle al pedido" falla con "Elegí un producto (define el puesto)" para productos sin `id_puesto`.
- RLS no es permission-aware (solo tenant-aware) — ver §8.
- El patrón de gating de permisos por botón solo está implementado en `CatalogosAdmin.jsx`; falta extenderlo a los demás módulos admin.
- **RLS deshabilitado en 2 tablas** (`tc_planes_suscripcion`, `tc_permisos`) — flaggeado por el advisor de Supabase 2026-10-08, sin corregir (ver §12, nota de seguridad). Requiere que el usuario decida las políticas antes de activar RLS.
- **Fase 8 aplicada (ver §12), falta prueba de login en vivo**: los 3 tenants nuevos y las 6 cuentas demo ya están en la base real, pero nadie inició sesión todavía con `admin.construccion01@peoplemovil.demo` (ni las otras 5) para confirmar en la UI que el aislamiento por RLS/tenant_id funciona end-to-end.
