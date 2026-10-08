# Hallazgos del Access real (Ocesa03_j_m.accdb)

Fuente: `Dev/freelance/Ocesa03_j_m.accdb` (1.3GB) -- backend SQL Server exportado a Access (tablas `dbo_*`), con datos reales de producción (nombres anonimizados por el usuario, pero estructura, volúmenes y valores de catálogo son reales). Revisado vía ODBC (`Microsoft Access Driver *.accdb`) con PowerShell: 45 tablas, conteo de filas + muestra de columnas y 3-5 filas por tabla clave.

**Nota de privacidad:** este documento NO incluye filas crudas con datos personales (nombres, RFC, CURP, teléfonos, domicilios) -- solo estructura de columnas, conteos agregados y valores de catálogo/enum. Las filas de muestra completas quedaron únicamente en el scratchpad de la sesión (temporal, no versionado).

---

## 1. Volumen real (confirma que esto NO es un sistema de juguete)

| Tabla | Filas |
|---|---|
| `dbo_Empleados` | 56,593 |
| `dbo_Pedidos` (+ `_Archivo`) | 16,892 + 34,807 |
| `dbo_Pedidos Detalle` (+ `_Archivo` + `_Log`) | 159,248 + 646,997 + 374,681 |
| `dbo_Plazas` | 87,810 |
| `dbo_Plazas Historico` | 53,190 |
| `dbo_Pagos Honorarios` (+ `_Lista`) | 71,457 + 139,967 |
| `dbo_Observaciones Empleados` | 138,491 |
| `dbo_LogAltasBajas_Lista` / `_Lobo` | 149,819 / 135,660 |
| `dbo_IntentosAccesoPaginaConfirmaciones` | 101,051 |
| `dbo_PermisosPaginasInternas` | 12,727 |

Confirma lo que dijo el usuario: reclutamiento masivo y constante, altísima rotación, y un sistema que efectivamente operó a escala real (no es un prototipo).

---

## 2. `dbo_Pedidos` (46 columnas) -- confirma 1:1 los campos que el análisis de brechas decía que faltaban

Columnas reales: `IdCliente`, `IdContacto`, `IdEvento`, `IdSucursal`, `IdUnidadDeNegocio`, `IdPEP`, `IdLugarCita`, `Tipo de Movimiento`, `IdSociedad`, **`IdSociedadPagadora`**, **`IdTipoDeComplejidad`**, **`Duracion del Evento (Numero de Dias)`**, **`IdTipoDuracionDelEvento`**, **`Permitir Cancelaciones`**, `Status Facturacion`, `SubTotal`/`IVA`/`Total Con IVA`, `Costo Por Nomina`, `IdResponsable`, `Version Vigente`.

Esto es exactamente lo que `ANALISIS_BRECHAS_MANUALES_VS_MODELO.md` (sección "Pedidos y reservaciones") decía que faltaba en `te_pedidos` -- ya no es una suposición, es la estructura real confirmada.

Valores reales de `Status` vistos: `Normal`, `Procesado`. De `Tipo de Movimiento`: `Servicio Interno`, `Pedido`.

## 3. `dbo_Pedidos Detalle` (58 columnas) -- la tabla que el análisis marcó como "la más incompleta del esquema"

Confirma TODOS los campos que faltaban en `te_pedidos_detalle`:
- Estatus por línea (`Status`: `Procesado`, etc.)
- `Producto`, `Titulo Producto`, `Producto Matricial`, `Presentación`
- Fechas por renglón: `Fecha Entrega`, `Fecha Fin Cita`, `Fecha Liberacion`, `Fecha Fin Bloque`, `Fecha Vigencia Preasignados`
- `Completar Productos Similares`, `Bloque`
- Métricas de cupo: `Porcentaje Completo`, `Completo`, `Porcentaje/Cantidad Completo con Preasignados`, `Cantidad Reservados`, `Cantidad Reservados Real`, `Cantidad Que Asistieron`
- `Fase del Evento`, `Facturable`, `FolioFactura`, `Factura / Servicio Interno`
- `Pago Especial`, `Permitir Cancelar Confirmaciones`
- Notificaciones: `Fecha Envio SMS`, `Status Envio SMS`, `Envio SMS Preasignados`, `CorreoEnviado_Faltas`, `CorreoEnviado_PEP_Temporal`

Acción: cuando se actualice el esquema, usar esta lista de columnas reales como la definición autoritativa de `te_pedidos_detalle`, en vez de la lista parcial que ya teníamos.

## 4. `dbo_Puestos` (24 columnas) -- confirma de dónde salen las reglas de negocio ya documentadas

`Duración Turno`, `Horas Entre Turnos`, **`Horas Antes Para Cancelar Pedido`** (la regla de 72h, aquí confirmada como parámetro **por puesto**, no global -- coincide con la decisión D4/D8 ya tomada), `Porcentaje Certeza Inicial`, `Porcentaje Mínimo`, `Confirmar Entre Seriados`, `Dias sin Confirmar`, `Matricial`, `Requiere TimeScan`, `Penalizacion Retardo`, `Penalizacion Falta`, `Ciclo de Pago`, `Regimen de Pago`, `IdEmpresaPagadora`.

## 5. `dbo_Pagos Honorarios` (41 columnas) -- resuelve el gap crítico de nómina

El análisis de brechas decía: *"Desglose fiscal del recibo de honorarios ... crítico si se necesita auditar o reimprimir el recibo tal como en el legado"*. Aquí está completo:

`Pago Bruto`, **`SDP`** (salario diario promedio), **`IM`** (impuesto marginal), **`CF`** (cuota fija), **`SA`** (subsidio acreditable), **`CG`** (crédito general), **`ID`** (impuesto diario), **`IT`** (impuesto total), `IVA`, **`RIVA`** (retención IVA), **`RISR`** (retención ISR), `Pago Neto`. Más banderas de validación: `Cumple Regla Posee Cuenta de Banco`, `Cumple Regla Ultimo Pago en Periodos Recientes`, `Cumple Regla Recibe Pago en el Periodo Actual`.

Acción: agregar estas columnas a `te_nomina_detalle` (o una tabla `te_nomina_detalle_fiscal` como ya sugería el análisis de brechas) usando estos nombres/significados reales.

## 6. `dbo_Empleados` (57 columnas) -- confirma los campos de candidatos/empleados que faltaban

`Tipo de Empleado` (valor visto: `Eventual`), dirección completamente estructurada (`Calle`, `Número Exterior/Interior`, `Colonia`, `Código postal`, `Delegación o Municipio`, `Estado/Provincia`), `Grado de Estudios`, `Status de grado de estudio`, `Licenciatura o Curso`, `Idiomas`, `En Caso de Accidente avisar A` (contacto de emergencia como texto libre, no tabla separada), `Cirugias, Tratamientos y Padecimientos`, `Tipo de Sangre`, `Recomendado Por`, `Estado Civil`, `Cartilla`, `Credencial Elector`.

## 7. `dbo_PermisosPaginasInternas` -- capa de permisos MÁS granular de lo que vimos en GAM

Columnas: `TipoPermiso`, `IdUnidadDeNegocio`, `IdSucursal`, `Usuario`. Valores reales de `TipoPermiso`: `Pedidos Detalles Editar`, `Pedidos Detalles Editar Forzado`.

Esto es una capa de permisos **adicional** a los roles de GAM: overrides por usuario individual, acotados a una Unidad de Negocio + Sucursal específica (ej. el usuario `ocesa\amecalco` puede "editar forzado" en Pedidos Detalle solo para ciertas sucursales). Es más fino que el RBAC por rol que ya implementamos en la Migración 005. **No se incorporó todavía al esquema nuevo** -- si se requiere este nivel de control (permiso + alcance geográfico/organizacional por usuario individual), habría que agregar una tabla tipo `tr_usuario_permiso_alcance` (usuario_id, permiso_codigo, unidad_negocio_id, sucursal_id). Queda pendiente de decisión.

## 8. Otros hallazgos relevantes

- `dbo_IntentosAccesoPaginaConfirmaciones` (101k filas, solo `IdContacto`+`FechaRegistro`+`IP`) -- bitácora de accesos a la página de confirmaciones del portal freelance, con geolocalización por IP. Equivalente moderno: ya existe `te_magic_links` + se podría loggear el IP de uso.
- `dbo_Informacion General Internet` -- tabla de contenido tipo CMS (HTML) para el portal público: aviso de privacidad, requisitos por puesto, descripción de puesto. Confirma que el portal candidato mostraba contenido editable por puesto/categoría -- no está contemplado todavía en el esquema nuevo.
- `dbo_Pensiones` -- pensión alimenticia: beneficiario, cuenta, banco, porcentaje. Ya existe `tp_pensiones_alimenticias` en el esquema actual, revisar que tenga estos campos.
- `dbo_Proceso Cierre Nomina` -- máquina de estados textual (`Reiniciar`/`Iniciada`) para el cierre de nómina -- coincide con `te_proceso_cierre_nomina` ya creado.
- `dbo_Procesar Por Lista Manual` -- cola de pedidos-detalle marcados para registrar asistencia manualmente (ej. "no pasa el Time[Scan]"), con observación libre. Coincide con `te_procesar_lista_manual` ya creado.
- `dbo_LogAltasBajas_Lobo` -- log de verdad desde 1999 (!) -- el sistema tiene más historia de la que pensábamos; confirma `DeEstado`/`AEstado`/`Observaciones`/usuario que hizo el cambio.

---

*Generado por inspección directa vía ODBC del archivo `.accdb` real compartido por el usuario -- no es texto de manuales, son datos de producción.*
