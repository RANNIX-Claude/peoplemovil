# PeopleMovil — Notas de proyecto para Claude Code

Este archivo es el "contrato de trabajo" para futuras sesiones.

## 1. Estado del workspace (2026-10-08)

- **Repo git:** remoto `origin` cambiado el 2026-10-08 a `github.com/RANNIX-Claude/peoplemovil` (antes `github.com/irpdesarrollo/peoplemovil`, que sigue existiendo con toda la historia hasta ese punto, renombrado localmente a `irpdesarrollo-antiguo`). El cambio fue porque el token embebido en el remoto viejo expiraba a media sesión y bloqueaba el push; `RANNIX-Claude/peoplemovil` usa el login interactivo de Git Credential Manager de la máquina, más estable. Se migró toda la historia con `git push`. Ver `git remote -v` para confirmar.
- **Netlify — sitio vigente: `https://peoplemovil00.netlify.app`** (2026-10-08). El sitio viejo `https://peoplemovil-app.netlify.app` seguía ligado por Git al repo VIEJO (`irpdesarrollo/peoplemovil`) y el conector de Netlify de esta sesión no tenía acceso a él (pertenece a otra cuenta/equipo). Se usó en su lugar `peoplemovil00` (ya existente en la cuenta/equipo conectado — id de proyecto `3774b5da-9bba-4ff1-a1e8-fe9e32f70911`), **confirmado ligado a `github.com/RANNIX-Claude/peoplemovil`** (Developer settings → Repository, verificado en pantalla por el usuario) — push a `origin`/`main` dispara deploy automático ahí. Se configuraron `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` vía API de Netlify (apuntan al proyecto real `ysyeidudlvdkqpckspcy.supabase.co`). **Pendiente:** confirmar login funcionando en vivo tras este cambio, y setear el resto de env vars (`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE`, `ANTHROPIC_API_KEY`, `RESEND_API_KEY`, `TWILIO_*`) que aún no se han puesto en este sitio — necesarias para que las Netlify Functions (notificaciones, chat, etc.) funcionen, no solo el login. Hay otros sitios sueltos en la misma cuenta (`peoplemovil`, `peoplemovil01`, `peoplemovil02`) que no se usan — ignorarlos, no son el sitio real.
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

## 7. Migraciones recientes (011-020, en `db/reset_database.sql`)

| # | Qué hace |
|---|---|
| 011 | Corrige `tc_fases_evento` a los 5 valores reales de Lobo 2018: No aplica(0), Preparación(1), Montaje(2), Show(3), Desmontaje(4). Simplificación intencional vs. las 8 fases de 2017 (confirmado por el usuario). |
| 012 | Bolsa de freelance: agrega `te_empleados.sucursal_id`, `tr_empleado_plaza.certeza`, `te_lista_negra_empleados.sitio_id`/`fecha_expiracion`. Reescribe `v_publicaciones_para_freelance` y `v_agenda_freelance` para que cada freelance solo vea/gestione **lo suyo** (`mi_empleado_id()`), filtrado por elegibilidad (ver §9). |
| 013 | **Fix crítico**: `current_user_id()`/`current_tenant_id()` leían el GUC obsoleto `request.jwt.claim.sub`, que este PostgREST no expone. Se corrige para leer `request.jwt.claims::json->>'sub'` (con el claim viejo como fallback). Sin esto, ningún usuario autenticado resolvía su identidad. |
| 014 | `inscribirme_a_publicacion()`: quita un cast inválido `time with time zone → interval`. |
| 015 | `inscribirme_a_publicacion()`: usa la fecha/hora real de la línea de pedido (`te_pedidos_detalle.fecha_cita/hora_cita_inicio/hora_cita_fin`, con fallback a `te_pedido_fechas` y al header) en vez de `te_pedidos.hora_inicio/hora_fin` (casi siempre NULL) — corrige falsos rechazos por "traslape". |
| 016 | `mi_usuario()` y `mis_permisos()` — RPCs que usa el admin para resolver usuario interno + permisos tras login. |
| 017 | Tenants demo multi-vertical: Construcción, Seguridad privada y BTL/Promotoras. Catálogos completos (sitios, puestos, turnos, clientes, unidades de negocio, roles/permisos) + empleados + pedidos de ejemplo por tenant. **Cero columnas nuevas** — ver D11/D12/D13. |
| 018 | Expedientes completos (RFC/CURP/domicilio/etc.) + ampliación a 30 empleados/tenant en los 3 tenants demo multi-vertical. Ver §12. |
| 019 | **Acciones de reclutamiento** (2026-10-08, ver `documentacion-referencia/NOTIFICACIONES_RECLUTAMIENTO.md`): 3 RPCs nuevas que completan el funnel de reclutamiento, que ya tenía schema (Migración 003b) pero ninguna función que avanzara las etapas — `confirmar_asistencia_grupo()`, `registrar_firma_contrato()` (asigna curso de inducción, selector de cabecera que propaga a todas las filas igual que el legado), `confirmar_asistencia_curso()` (encadena automáticamente `promover_candidato_a_empleado()`, antes un botón manual suelto). Analizado contra las 225 capturas del video legado "Ciclo completo". **Aplicada a la base real (2026-10-08)** vía `apply_migration` — ver nota en §13 sobre el MCP correcto de Supabase. |
| 021 | **Siembra representativa de `tp_duraciones_evento`/`tp_sueldos_matriciales`** (2026-10-08) — **reemplazada por la Migración 022** al día siguiente al aparecer el Excel real del tabulador; se deja la fila por historial pero los datos ya no están en la base (ver 022). |
| 022 | **Tarifas REALES del tabulador legado + excepción Producción/PRG en cancelación automática** (2026-10-09, ver `REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md` §7): reemplaza por completo los datos inventados de la Migración 021 con datos reales de `Catalogos Sueldos Matriciales.xlsx` (hojas Puestos/Sueldos Matriciales/Tipos de Complejidad en Eventos/Sueldos Matriciales Duracion/Sueldos Mat Duracion Detalle). Corrige `tc_tipos_complejidad` a los 6 valores reales vigentes (por aforo, sin días en el nombre — el catálogo inventado era arquitectónicamente incorrecto), reemplaza `tc_tipos_duracion_evento` por los 3 valores reales (Shows Sueltos/Tarifa por Semana/Tarifa por Mes, este último prorrateado — se agregaron columnas `prorrateado`/`divisor_prorrateo`), agrega la 4ª dimensión que faltaba (`fase_evento_id`/`fase_evento_str` en `tp_sueldos_matriciales`, para puestos como Runner que se tarifan por fase y no por complejidad/duración), y siembra 8 filas reales en `tp_duraciones_evento` + 54 filas reales en `tp_sueldos_matriciales` (filtradas por "vigente hoy" en el Excel: `Activo=1 AND FechaFin IS NULL` — Productor C y los 3 Stage Manager quedaron sin ninguna fila, gap real del legado, no inventado). También analizó `Reglas de negocio pedidos.docx` y `reglas de negocio_cancelaciones.docx` (ver §11 para los hallazgos pendientes de implementar) y corrigió `cancelacion_automatica_preasignados()` para excluir las unidades de negocio Producción/PRG (regla real confirmada en el docx de cancelaciones, antes no se respetaba). Aplicada a la base real vía `apply_migration`. |
| 020 | **Productos similares en Confirmación Forzada/Preasignada** (2026-10-08, Escenario 12 del QA legado — ver `documentacion-referencia/SCREENSHOTS_ESCENARIO12.md`): `te_pedidos_detalle.completar_productos_similares`, `tr_producto_puesto` y `tr_productos_similares`/`tr_puestos_similares` ya existían pero nada los leía — el trigger `tg_reservacion_valida` no bloqueaba empleados de puesto distinto (`obtener_certeza_puesto()` cae al default del puesto cuando el empleado no tiene esa plaza, así que en la práctica no bloqueaba nada). Se agregó `puesto_aceptado_por_detalle()` (cadena: puesto exacto → catálogo producto→puestos → si "completar_productos_similares"=SÍ → puesto similar o producto similar→sus puestos) y se modificó `tg_reservacion_valida` para usarla cuando `pedido_detalle_id` está presente, bloqueando con el mensaje exacto del legado **"El empleado no cumple con el perfil requerido"**. Se completó `tr_producto_puesto` desde `tc_productos.id_puesto` (catálogo real, todos los tenants) y se cargó el par Seguridad↔Control de Accesos como productos similares (tenant eventos). **Aplicada a la base real y probada end-to-end en el navegador** (local dev apuntando a producción): pedido #193 "Escenario 12 - Productos similares", bloqueado correctamente con similares=NO, permitido correctamente con similares=SÍ — se dejó como dato de ejemplo en la base, no se borró. También se actualizó `Preasignacion.jsx` para buscar cualquier empleado por nombre (antes solo listaba quienes ya tenían la plaza exacta, por lo que el escenario ni se podía intentar), y se corrigió un comentario incorrecto en esa pantalla que decía que "forzada" bypassa la validación de certeza (nunca lo hizo). |
| — | **Formulario "Agregar detalle" incompleto en `SitiosAsignacion.jsx`** (2026-10-09, validado contra foto real de `apoyo.rh.ocesa.mx/Pedidos/AgregarPedidoDetalle`, pedido 253230): el formulario solo capturaba 9 de ~16 campos reales de `te_pedidos_detalle` — faltaban `lugar_cita_id`/`lugar_otro`/`lugar_otro_descripcion` (Lugar de Cita con opción "Otro"), `hora_cita_inicio`/`hora_cita_fin`, `fecha_final_cita`, `fase_evento_id`, `facturable`, `permitir_cancelar_confirmaciones` — todas columnas que **ya existían en el schema** (confirmado por `information_schema`), así que **no hubo migración de SQL, solo frontend**. Probado end-to-end contra la base real: insert con los 9 campos nuevos confirmado por SQL tras usar el formulario en el navegador. **Nota de corrección propia**: durante esta misma tarea se creyó por error que `tc_fases_evento` estaba vacía (mala lectura de un resultado multi-sentencia) y se aplicó una migración `apply_migration` llamada `021_seed_fases_evento` — resultó ser un no-op (`ON CONFLICT DO NOTHING`, las 5 filas ya existían desde la Migración 011, creadas 2026-10-07/08). Queda en el historial de migraciones de Supabase sin efecto real; no requiere limpieza. |

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

- **`00000000-0000-0000-0000-000000000002` — Edifica Talento Obra Civil** (construcción): 14 puestos de obra (Albañil, Plomero, Carpintero, Electricista, Operador de maquinaria, Supervisor/Residente de obra, etc.), 3 obras como sitios, **30 empleados demo** (los 10 albañiles/2 plomeros/3 carpinteros + soporte originales, más 10 nuevos con expediente completo — Migración 018, ver abajo), 1 pedido liberado con ese staffing en "Residencial Las Lomas — Torre A".
- **`00000000-0000-0000-0000-000000000003` — Guardia Total Seguridad Privada** (seguridad): 7 puestos (Vigilante de acceso/piso, Guardia de CEDIS 24x24, Monitorista, Supervisor de turno, Jefe de zona, Escolta), 5 sitios (2 Walmart, 1 CEDIS, 1 sucursal bancaria, 1 oficina de gobierno), **30 empleados** (10 originales + 20 nuevos, ahora con presencia real en los 5 sitios), 4 pedidos liberados: Walmart Satélite cubierto con 3 relevos de 8h (matutino/vespertino/nocturno), CEDIS Cuautitlán con 1 solo guardia en turno 24x24, banco y gobierno con matutino+vespertino (sin nocturno, horario bancario).
- **`00000000-0000-0000-0000-000000000004` — Impacto BTL Promotoras y Activaciones**: 7 puestos (Promotora/Impulsadora, Demostrador(a), Edecán, Supervisor de piso, Coordinador, + 2 puestos "Modelo Evento Premium" con `sexo_requerido` explícito, F y M), 5 sitios (Walmart Félix Cuevas, Walmart Universidad, Chedraui Toreo, La Comer Del Valle, Salón Diamante Polanco), **30 empleados** (12 originales + 18 nuevos), 3 pedidos: activación Colgate en Walmart Félix Cuevas y Chedraui Toreo (cobertura **solo sábado y domingo**, vía `indicaciones_especiales`, no hay columna de recurrencia — D12), y lanzamiento de una marca de lujo (ficticia: "Joyería Diamante & Platino") que requiere modelos profesionales mixtos, no impulsadoras genéricas.

**Migración 018 (2026-10-08) — expedientes completos + ampliación a 30/tenant:** pedido explícito del usuario ("que tengan expedientes completos... más empleados... que se vea más carnita"). Se sumaron 10+20+18 = 48 empleados nuevos (folios continuando la secuencia existente) para llegar a 30 por tenant, cada uno con RFC/CURP (aproximaciones de formato, no checksums reales — son datos ficticios), fecha de nacimiento, teléfono (10 dígitos, lada real de su ciudad), correo `@personal.peoplemovil.demo`, domicilio completo (calle/colonia/CP/municipio/estado, coherente con la ciudad de su sitio asignado), estado civil, estatura/talla (con mínimos de estatura reales para los puestos "Modelo Evento Premium"), grado de estudios, contacto de emergencia (parentesco coherente con el sexo del contacto), tipo de sangre, banco/cuenta/CLABE. Fotos: mismo esquema DiceBear que la Migración 017 (D13) — nunca rostros realistas. Se repartieron entre los sitios y puestos que antes no tenían empleados (p.ej. ahora sí hay vigilantes en Banregio Polanco y Gobierno Edo. Méx, que antes tenían pedido pero nadie asignado). Generado con un script Python (`scratchpad/gen_empleados_018.py`, no versionado) y revisado a mano — se corrigieron dos bugs antes de aplicar: teléfonos con lada de 2 dígitos que quedaban en 9 dígitos en vez de 10, y parentesco del contacto de emergencia que no concordaba con el sexo generado del contacto. Aplicado vía `apply_migration` (`018_empleados_expedientes_completos_demo_multivertical`) y append al final de `reset_database.sql`. Los 42 empleados originales (del tenant eventos y los 3 nuevos tenants antes de esta migración) se quedan sin estos campos — mismo gap que ya existía, no se tocaron.

**Aplicado a la base real (2026-10-08):** en esta sesión el MCP de Supabase conectado sí apuntaba al proyecto PeopleMovil (`https://ysyeidudlvdkqpckspcy.supabase.co`) — la base ya tenía datos reales (192 pedidos, 11 empleados, 85 eventos, 6 usuarios del tenant original), por lo que correr `reset_database.sql` completo (empieza con `DROP SCHEMA public CASCADE`) habría borrado todo. En vez de eso se extrajo solo el bloque de la Migración 017 (líneas 4849-5265, puro `INSERT`, sin DDL) y se aplicó como migración incremental vía `apply_migration` (`017_tenants_demo_multivertical`), y luego se corrió `db/seed_demo_usuarios_multiempresa.sql` completo contra `auth.users`/`auth.identities`.

Verificado tras aplicar: `te_tenants` tiene 4 filas (eventos, construccion, seguridad_privada, btl_activaciones); `te_empleados` 11/20/10/12 por tenant; `te_pedidos` 192/1/4/3 por tenant; las 6 cuentas demo (`admin.construccion01`, `freelance.construccion01`, `admin.seguridad01`, `freelance.seguridad01`, `admin.btl01`, `freelance.btl01`, todas `@peoplemovil.demo`) quedaron en `auth.users`+`auth.identities` y correctamente ligadas (las 3 admin a `te_usuarios`+rol `administrador`; las 3 freelance a `te_empleados.auth_user_id` del folio 1 de su tenant). Pendiente: probar en vivo (login real) que cada tenant solo ve sus propios catálogos vía RLS — no se probó el login real en esta sesión, solo se verificó el estado de la base.

**Nota de seguridad aparte (no relacionada a esta migración):** el advisor de Supabase reporta que `tc_planes_suscripcion` y `tc_permisos` tienen RLS deshabilitado — ambas quedan expuestas por completo a `anon`/`authenticated`. No se aplicó corrección automática (activar RLS sin políticas bloquearía el acceso); queda pendiente que el usuario decida las políticas.

## 11. Pendientes conocidos (deuda técnica)

- **Tarifa graduada por día de show (`tp_duraciones_evento`/`tp_sueldos_matriciales`)**: esquema correcto, **sembrado con datos REALES del legado** (Migración 022, 2026-10-09, reemplazó los datos inventados de la Migración 021 — ver §7 y §13 de [REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md](documentacion-referencia/REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md)) — fuente: `Catalogos Sueldos Matriciales.xlsx` real del legado. Catálogo de complejidad corregido a los 6 valores reales (por aforo/PAX, sin días en el nombre), duración reducida a 3 valores reales (Shows Sueltos/Tarifa por Semana/Tarifa por Mes con prorrateo), y se agregó la 4ª dimensión que faltaba (`fase_evento_id`/`fase_evento_str` en `tp_sueldos_matriciales`, para puestos como Runner que se tarifan por fase, no por complejidad/duración). **Gap real confirmado, no inventado**: Productor C y los 3 Stage Manager no tienen ninguna tarifa vigente en el legado real desde 2018 — se dejó así. **Sigue pendiente**: `factor_sueldo`/`sueldo_base` no están cableados a ningún cálculo real todavía (ni `matriz_puestos_pedido()` ni el "Presupuesto por Día" de `SitiosAsignacion.jsx`).
- **Reglas de Pedidos/Cancelaciones sin implementar** (fuente: `Reglas de negocio pedidos.docx` y `reglas de negocio_cancelaciones.docx`, analizados 2026-10-09, ver §7.2/§7.3 de REGLAS_FASE_EVENTO_COMPLEJIDAD_TARIFAS.md): (a) "Tipo de Complejidad"/"Duración del evento" en Alta de Pedido deberían habilitarse solo si la Sociedad Propia del PEP es "Ocesa RH" — hoy siempre están visibles; (b) no se valida que un pedido Cancelado/Procesado no se pueda editar, ni que un pedido con algún detalle Procesado no pueda cambiar PEP/Complejidad/Días de Show; (c) cancelar una reservación de un bloque debería cascadear a toda la serie de ese empleado en ese bloque — hoy solo cancela el detalle puntual; (d) no existe cancelación automática por disminución de `cantidad` en un detalle (debería cancelar el excedente priorizando peor certeza); (e) "Liberar" debería limpiar `fecha_liberacion` a NULL en cada detalle, hoy no se toca. **Sí corregido**: `cancelacion_automatica_preasignados()` ahora excluye unidades de negocio Producción/PRG (Migración 022), regla confirmada en el docx de cancelaciones que antes no se respetaba.
- **`tc_productos.id_puesto`**: vinculación incompleta. Se mejoró de 8→28→53 (de 81 productos) cruzando contra `dbo_ProductosPorPuesto` (Access, 1186 filas), pero quedó inconcluso — el último conteo de "sin resolver" no cuadraba contra el total y no se reverificó. Algunos puestos referenciados en el Access real (p.ej. "Cajero Estacionamientos", "Control Vehicular", "Valet Parking", "Modelo Star 1-5") posiblemente no existen aún en `tc_puestos` y requerirían alta nueva, no solo match. Síntoma visible: en el admin, "Agregar detalle al pedido" falla con "Elegí un producto (define el puesto)" para productos sin `id_puesto`.
- RLS no es permission-aware (solo tenant-aware) — ver §8.
- El patrón de gating de permisos por botón solo está implementado en `CatalogosAdmin.jsx`; falta extenderlo a los demás módulos admin.
- **RLS deshabilitado en 2 tablas** (`tc_planes_suscripcion`, `tc_permisos`) — flaggeado por el advisor de Supabase 2026-10-08, sin corregir (ver §12, nota de seguridad). Requiere que el usuario decida las políticas antes de activar RLS.
- **Fase 8 aplicada (ver §12), falta prueba de login en vivo**: los 3 tenants nuevos y las 6 cuentas demo ya están en la base real, pero nadie inició sesión todavía con `admin.construccion01@peoplemovil.demo` (ni las otras 5) para confirmar en la UI que el aislamiento por RLS/tenant_id funciona end-to-end.
- **Migración 019 aplicada a la base real (2026-10-08)** — ver §7, §13 y `NOTIFICACIONES_RECLUTAMIENTO.md`. Falta: (a) probar end-to-end las 3 pantallas nuevas (`EntrevistaGrupal.jsx`, `FirmaContratos.jsx`, `CursoInduccion.jsx`) con datos reales, (b) confirmar que `RESEND_API_KEY` esté seteada en Netlify para que los 2 correos de reclutamiento salgan de verdad (sin ella la función responde en modo `dry:true`). Paso 4 del funnel (entrevista individual + psicométrico) sigue sin pantalla de captura — columnas ya existen, no se tocó en esta sesión.
- **Migración 020 (productos similares, Escenario 12) aplicada y probada end-to-end (2026-10-08)** — ver §7 y `SCREENSHOTS_ESCENARIO12.md`. Falta: no existe pantalla "Modificar detalle" en `SitiosAsignacion.jsx` para editar `completar_productos_similares` (u otros campos) de un detalle ya creado — en la prueba se cambió por SQL directo. El alta inicial sí captura el campo.

## 13. Dos conexiones MCP de Supabase distintas — no confundirlas

Este entorno (Claude Code) puede tener **dos servers MCP de Supabase activos a la vez**, con nombres casi idénticos pero alcance distinto:

- **`supabase`** (tipo "user" — configurado a nivel de este proyecto/máquina, sin `project_id` en sus herramientas porque ya viene amarrado a un solo proyecto). **Este es el que apunta al proyecto real de PeopleMovil** (`ysyeidudlvdkqpckspcy.supabase.co` — confirmado con `get_project_url`). Úsalo para todo lo de este repo: `apply_migration`, `execute_sql`, `list_tables`, etc.
- **`Supabase`** (tipo "connector" — Connector de la cuenta de claude.ai del usuario, compartido entre **todas** sus sesiones que lo tengan habilitado). Este apunta a una cuenta/organización de Supabase distinta, con otros proyectos del usuario (JurisControl, LuisaDB, iwolpark, iwolpark-produccion) — **ninguno es PeopleMovil**. Sus herramientas sí piden `project_id` porque maneja varios proyectos.

**Error cometido en la sesión del 2026-10-08**: se usó por default el conector tipo "connector" (`mcp__873a95b9-...`), se vio que no tenía el proyecto de PeopleMovil, y se construyó innecesariamente una función de Netlify (`admin-migracion-019.js`, con `pg` como dependencia nueva) para poder aplicar una migración contra Postgres directo — cuando el server `supabase` (tipo "user") ya tenía acceso directo al proyecto real desde el principio. Esa función ya se borró del repo (ver git history si hace falta recuperarla como referencia). **Antes de concluir "no tengo acceso a la base real", probar `mcp__supabase__get_project_url()` (sin `873a95b9` en el nombre) — si el server no aparece listado, recién ahí es cierto que no hay acceso.**

**Confirmado 2026-10-08**: `git remote -v` en `/Dev` muestra `origin` → `https://github.com/RANNIX-Claude/peoplemovil.git` (sin token en la URL, usa Git Credential Manager de la máquina) y `irpdesarrollo-antiguo` → el repo viejo con el token embebido que causaba el bloqueo "Credential Leakage" del clasificador de auto-mode. **El bloqueo de push ya no debería repetirse** usando `origin`.

## 14. Carpeta `Dev/genexus/web` — export compilado del sistema Lobo (hallazgo 2026-10-08)

Es el **output compilado** de la app GeneXus original (.NET/ASP.NET), no el código fuente `.aspx` legible. No hay `.aspx` (0 archivos) — son `.cs`/`.js`/`.dll` generados.

- **El menú real de la app NO está en ningún archivo legible**: es GAM (GeneXus Access Manager), manejado por datos en tablas (`gamwwappmenus`/`gam_appmenuentry`/`gam_appmenuoptionentry`), no en código. `DeveloperMenu.xml` es el menú del **IDE** (para el programador), no el de la app. `GAM_Backend.zip` solo trae CSS/imágenes, no datos. **No tenemos la base de datos de GAM** — sin eso no se puede reconstruir el árbol de navegación exacto.
- **Pero sí se puede contar el inventario de objetos compilados**, que es mucho más completo que los 29 identificados antes vía las 26 capturas de pantalla analizadas:
  - **624 transacciones/catálogos** (`te_`/`tc_`/`tp_`/`tr_`/`tl_`, dedupe de variantes `ww`)
  - **104 web panels** (`wp_`)
  - Filtrando helpers auto-generados que no son pantallas navegables (sufijos `exportreport`/`getfilterdata`/`loaddvcombo`) quedan **≈496 pantallas reales** (417 + 79).
- **Nombres sin guiones bajos** (`te_listanegra`, `wp_cambiocuentabancaria`) vs. nuestro esquema con nombres descriptivos (`te_lista_negra_empleados`, `te_cambio_cuenta_bancaria`) — **un diff de texto literal no los empareja**, requiere mapeo semántico manual.
- Pantallas nuevas detectadas aquí que no habíamos visto en ningún documento anterior: `wp_cambiocuentabancaria`, `wp_cursosdeinduccioncandidatos_lista`, `wp_asignacionfolios`, `wp_carteratalento`, `wp_comunicadospersonal`, `wp_terminosycondiciones`, `wp_uneequipo` (+tabs), `wp_pubofer`/`wp_pubofercand`.
- **Pendiente**: catalogar sistemáticamente los ~496 objetos contra lo que ya existe en PeopleMovil (decisión de alcance pendiente con el usuario — no se ha lanzado ese análisis completo todavía).

## 15. Prueba de login en vivo — Fase 8 + reclutamiento (en progreso, 2026-10-08)

Pedido explícito del usuario: validar en el navegador (no solo en SQL) que (a) las cuentas demo multi-vertical de la Migración 017 aíslan correctamente por tenant vía RLS, y (b) el funnel de reclutamiento de la Migración 019 funciona end-to-end. **Arrancado, sin terminar** — dev server levantado (`localhost:5173`), en `/admin/login`. Falta: iniciar sesión real con `admin.construccion01@peoplemovil.demo` / `Multiempresa2026!` (y las otras cuentas de §10), confirmar que el menú/datos mostrados sean solo del tenant construcción, y repetir con seguridad/BTL. Para el funnel de reclutamiento: **`te_candidatos` tiene 0 filas** en la base real — antes de poder probar `EntrevistaGrupal.jsx`/`FirmaContratos.jsx`/`CursoInduccion.jsx` end-to-end hace falta crear datos de candidatos/vacante/grupo de citas de prueba.
