# PeopleMovil — Modelo de Datos (v2)

Documento de referencia del schema `public` de `db/reset_database.sql`.

## Convención de nombres (adoptada del sistema Lobo/AppSCPF)

| Prefijo | Significado | Ejemplos |
|---|---|---|
| `tc_` | Tabla de **Catálogo** — valores maestros semi-estáticos | `tc_bancos`, `tc_puestos`, `tc_sitios`, `tc_uniformes`, `tc_turnos` |
| `te_` | Tabla de **Entidad/Negocio** — datos transaccionales operativos | `te_candidatos`, `te_empleados`, `te_pedidos`, `te_reservaciones`, `te_eventos_biometricos` |
| `tp_` | Tabla de **Parámetros** — configuración por tenant, versionable o histórica | `tp_parametros_globales`, `tp_folios`, `tp_precios_producto`, `tp_avisos_privacidad` |
| `tr_` | Tabla de **Relación** N:N | `tr_empleado_plaza`, `tr_asistencia_curso`, `tr_postulacion_candidato_vacante`, `tr_comunicado_destinatario` |

**Reservado para etapa Data Warehouse:** `dw_dim_*` (dimensiones), `dw_hecho_*` (hechos). No entra en el schema actual — es otro pase.

## Convención de auditoría (aplicada a TODAS las tablas)

- `tenant_id uuid NOT NULL REFERENCES te_tenants(id)` — multi-tenant obligatorio (excepto `tc_planes_suscripcion`, catálogo compartido).
- `creado_en timestamptz` — fecha de alta.
- `creado_por uuid` — usuario que creó el registro.
- `modificado_en timestamptz` — última actualización.
- `modificado_por uuid` — quién modificó por última vez.
- Trigger `tg_auditoria` los rellena automáticamente en INSERT/UPDATE.
- **Append-only** (`te_eventos_biometricos`, `te_consentimientos`, `te_reservacion_bitacora`): trigger `tg_deny_mutations` bloquea UPDATE/DELETE.

## RLS

Toda tabla lleva 4 policies (SELECT/INSERT/UPDATE/DELETE) que filtran por `tenant_id = current_tenant_id()`. `current_tenant_id()` resuelve en este orden: `SET LOCAL app.current_tenant` → header `x-tenant-id` (PostgREST) → claim `sub` del JWT.

---

## Índice de tablas (54 en total)

### Multi-tenant + suscripción (3)
| Tabla | Rol | PRC origen / Notas |
|---|---|---|
| `te_tenants` | Empresa cliente | [N] Nuevo — raíz de multi-tenancy |
| `tc_planes_suscripcion` | FREE / PRO con capacidades como columnas booleanas | [N] Nuevo |
| `te_suscripciones` | Plan activo por tenant + vigencia | [N] Nuevo |

### Parámetros (5)
| Tabla | Rol | PRC origen |
|---|---|---|
| `tp_parametros_globales` | Por tenant: retención, `horas_lookahead_autocancel`, `horas_gracia_confirmacion`, `certeza_inicial_default` | Reemplaza los únicos números hardcodeados del KB (72h y 8h de `PRC_CancelacionAutomaticaPreasignados`) |
| `tp_folios` | Contadores consecutivos por tipo de entidad | `PRC_FoliosConsecutivos` / `TC_folios` |
| `tp_avisos_privacidad` | Aviso de privacidad versionado | [N] LFPDPPP 2026 |
| `tp_terminos_condiciones` | T&C versionables | `TC_termycond` |
| `tp_precios_producto` | Tarifario histórico por producto/puesto/cliente | `TP_PreciosProductos` |
| `tp_pensiones_alimenticias` | Descuento por orden judicial | `TP_Pensiones` |

### Catálogos maestros (20)
| Tabla | Rol | GeneXus origen |
|---|---|---|
| `tc_estados_mx` | Estados de la República | `TC_Estados` |
| `tc_bancos` | Catálogo bancos MX | `TC_bancos` |
| `tc_sociedades_pagadoras` | Empresas pagadoras (19 seed) | `TC_sociedadesPagadoras` / `TC_EmpresaPagadora` |
| `tc_sociedades_propias` | Razones sociales del grupo (6 seed) | `TC_Sociedad` / `TC_socidad` |
| `tc_unidades_negocio` | Subdivisión organizacional | `TC_UnidadNeg` |
| `tc_sitios` | **Generaliza** sucursal/foro/tienda/obra/oficina/evento | `TC_Sucursal + TC_Complejo + TC_Inmueble + TC_LugarCita` |
| `tc_puestos` | **Todos los parámetros de negocio por rol** | `TC_Puestos` + `TP_ReglasAsistTimeScan` |
| `tc_turnos` | Plantillas de turno (mañana/tarde/noche/12h) | `TC_turnos` |
| `tc_tipos_personal` | freelance / staff / interno | `TC_tipoPersonal` |
| `tc_responsables` | Coordinadores por sitio/evento | `TC_Responsable` |
| `tc_fases_evento` | montaje / evento / desmontaje | `TC_FaseEvento` |
| `tc_causas_aclaracion` | Motivos de aclaraciones de pago | `TC_CausasAclara` |
| `tc_tipos_documento` | INE, CV, comprobante, contrato | `TC_docuemp` |
| `tc_uniformes` | Uniformes por producto/UN (29 seed) | Legacy `.xlsx` |
| `tc_clientes` | Clientes finales / marcas | `TE_CClientes` |
| `tc_productos` | Líneas de producto | `TC_Productos` |
| `tc_repse_registros` | REPSE por cliente/tenant | [N] Reforma 2021 |
| `tc_estaciones` | Estación de checado dentro de sitio | `TC_EstacionNACS` |
| `tc_dispositivos` | Serie del lector, tipo fijo/móvil | `TC_EquipoBiometrico` + `TE_Dispositivo` |
| `tc_planes_suscripcion` | Planes FREE/PRO (compartida) | [N] |

### Personas + documentos (10)
| Tabla | Rol | GeneXus origen |
|---|---|---|
| `te_candidatos` | Persona en reclutamiento (UNIQUE por rfc/curp) | `TE_Cand01` + `PRC_ValidaRfcCurp` |
| `te_empleados` | Persona activa con folio consecutivo | `TE_Empleado` + `PRC_AltaEmpleadosCursoInduccion` |
| `tr_empleado_plaza` | **N:N** empleado ↔ puesto con `porcentaje_puntualidad` por puesto | `TE_Plazas` |
| `te_consentimientos` | Append-only, `revoca_id` para revocaciones | [N] LFPDPPP |
| `te_documentos_candidato` | Documentos del candidato (INE, CV, etc.) | `TE_docCand` |
| `te_documentos_empleado` | Documentos del empleado (contrato firmado) | `TE_Docemp` |
| `te_movimientos_empleado` | Log de cambios de puesto/sueldo/sitio | `TL_Movempleados` + `TE_LogEmp` |
| `te_agenda_freelance` | Disponibilidad declarada por el freelance | `TE_AgendaFreelance` |
| `te_cursos_induccion` | Cursos impartidos | `TE_CurInducc` |
| `tr_asistencia_curso` | N:N candidato ↔ curso, asistió/calificación | `PRC_ActualizaAsistenciaCursoInduccion` |

### Reclutamiento (2)
| Tabla | Rol | GeneXus origen |
|---|---|---|
| `te_vacantes` | Vacantes publicadas | `TE_PubVacante` + `TE_vacante` |
| `tr_postulacion_candidato_vacante` | N:N candidato ↔ vacante | `TE_PostVaCan1` |

### Operativo (7)
| Tabla | Rol | GeneXus origen |
|---|---|---|
| `te_pedidos` | Requisición de personal (folio, sitio, cliente, responsable, fase) | `TE_Pedido` + `TE_reqPer` |
| `te_pedidos_detalle` | Desglose por puesto y cantidad, ligado a turno | `TE_Peddet` + `TE_DetPedPuesto` |
| `te_reservaciones` | **Tabla central** — una fila por persona-turno, con `regla_aplicada` | `TE_Reservacion` |
| `te_eventos_biometricos` | Append-only, timestamp de servidor forzado, `corrige_id` | `TE_RegistroBiometrico` + `TE_RegistroNACS` |
| `te_reservacion_bitacora` | Bitácora append-only de cambios de estado | Nuevo, patrón heredado |
| `te_comunicados` | Comunicados internos | `TE_Comunicados` + `TE_comPer` |
| `tr_comunicado_destinatario` | N:N comunicado ↔ empleado/candidato con `enviado_en`, `leido_en`, canal | Nuevo |

### Fiscal (7)
| Tabla | Rol | GeneXus origen |
|---|---|---|
| `te_nominas_periodo` | Periodo cerrado por tenant | `TL_CierreNomina` + `TP_Periodos` |
| `te_nomina_detalle` | Cálculo por empleado con `precauciones` jsonb | `PRC_CalculoNomina` + `PRC_ReportePrecaucionesNomina` |
| `te_extras_nomina` | Bonos / deducciones / ajustes | `TE_Extras` + `TE_ExtrasMasivos` |
| `te_facturas_enc` | Encabezado de CFDI de honorarios | `TE_FacturaEnc` |
| `te_facturas_det` | Detalle de CFDI ligado a reservación | `TE_FacturaDet` |
| `te_pagos_dispersion` | Dispersión ejecutada, referencia bancaria | `TE_pagos` |
| `te_aclaraciones` | Aclaraciones de pago con causa y ajuste | `TE_Aclaraciones` + `PRC_ValidacionAclaraciones` |

---

## Reglas de negocio (funciones/triggers)

| Función | Traduce | Descripción |
|---|---|---|
| `plan_activo(tenant)` | — | Plan vigente del tenant |
| `verificar_limite(tenant, recurso)` | — | Enforcement de plan por trigger |
| `siguiente_folio(tenant, tipo)` | `PRC_FoliosConsecutivos` | Folios independientes por tipo de entidad |
| `obtener_certeza_puesto(emp, puesto)` | `PRC_ObtenerCertezaPuesto` | Certeza por puesto (no global) |
| `valida_emp_puesto(emp, puesto)` | `PRC_ValidaEmpPuesto` | Certeza mínima + sexo requerido |
| `valida_no_empalme(emp, puesto, ini, fin)` | `PRC_Noempalmereservacion` | Margen `horas_entre_turnos` por puesto |
| `valida_cancelacion(reservacion)` | `PRC_ValidacionesCancelarReservacion` | Ventana `horas_antes_cancelar` |
| `cancelacion_automatica_preasignados()` | `PRC_CancelacionAutomaticaPreasignados` | Job periódico, usa `tp_parametros_globales` |
| `calcular_nomina_periodo(nomina)` | `PRC_CalculoNomina` + `PRC_CalculoNominaIndividual` | Cálculo por asistencia real |
| `reporte_precauciones_nomina(tenant)` | `PRC_ReportePrecaucionesNomina` | Alertas antes del cierre |
| `promover_candidato_a_empleado(cand)` | `PRC_AltaEmpleadosCursoInduccion` | Copia expediente + asigna folio |
| `consentimiento_vigente(empleado)` | — | Último consentimiento no revocado |
| `tg_reservacion_valida` | — | Valida plan + certeza + traslape antes de INSERT en `te_reservaciones` |
| `tg_evbio_force_ts` | — | Fuerza timestamp de servidor |
| `tg_evbio_valida_pre` | — | Valida consentimiento vigente + plan si móvil |
| `tg_evbio_no_mut` | — | Bloquea UPDATE/DELETE (append-only) |
| `tg_sitios_limite` | — | Verifica plan al crear sitio |
| `tg_emp_limite` | — | Verifica plan al crear empleado |
| `tg_ped_plan` | — | Verifica módulo asignación al crear pedido |

---

## 3NF y decisiones deliberadas de desnormalización

El schema respeta 3NF: sin grupos repetidos (los N:N son `tr_*`), sin dependencia transitiva. **Dos desnormalizaciones deliberadas** para preservar exactitud histórica:

1. `regimen_pago` duplicado en `tc_puestos`, `te_empleados` y `te_nomina_detalle` — permite que el régimen del pago quede congelado aunque después cambie el del empleado o del puesto.
2. `id_*_legacy` (columnas int) — conservan los IDs originales del sistema Lobo para trazabilidad de migración; no son claves foráneas activas.

---

## Etapa Data Warehouse (futura, no en este pase)

Cuando se construya el DW se usará el prefijo `dw_` para distinguirlo:

- **`dw_dim_*`** dimensiones — tiempo, empleado, puesto, sitio, cliente, tenant.
- **`dw_hecho_*`** hechos — asistencia diaria, reservaciones ejecutadas, cobertura por sitio/día, penalizaciones aplicadas, pagos dispersados.

Se poblarán con jobs desde las `te_*` con lógica ETL propia, sin tocar las operativas. Esa etapa incluye modelado en estrella y catálogos de dimensiones compartidos.
