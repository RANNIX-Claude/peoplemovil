# Reglas reales: Fase del Evento, Tipo de Complejidad y tarifas por día de show

Investigación disparada por las capturas de `apoyo.rh.ocesa.mx/Pedidos` (2017) que
mostraban un dropdown "Fase del Evento" con 8 valores en vez de los 5 ya modelados
(Migración 011). Fuentes cruzadas:

1. `C:\work\PeopleMovil\doc\_freelance\RQ_ID_FREELANCELOBO_20180306 V2.7_.docx` — sin
   mención del tema (es el requerimiento del portal freelance/confirmaciones, no de Pedidos).
2. `C:\work\PeopleMovil\doc\Panttallas del sistema .../Scripts de Prueba Freelance.xlsx`
   — guiones de prueba QA reales (2018-2019), hojas "Escenario 1-29".
3. `Dev\freelance\Ocesa03_j_m.accdb` (1.3GB, backend SQL Server real exportado a Access,
   45 tablas, datos de producción con nombres anonimizados) — consultado vía ODBC.

**Nota de privacidad**: este documento solo usa conteos agregados y valores de catálogo,
sin filas con datos personales.

---

## 1. "Fase del Evento" — confirmado con datos reales de producción

Consulta `SELECT [Fase del Evento], COUNT(*) FROM [dbo_Pedidos Detalle] GROUP BY ...`
sobre **159,248 filas reales**:

| Valor | Filas | % del total |
|---|---|---|
| *(vacío/NULL)* | 149,427 | 93.8% |
| Montaje | 4,535 | 2.8% |
| Show | 2,088 | 1.3% |
| Preparacion | 988 | 0.6% |
| **Fase 1 (de 1 a 4 días)** | 902 | 0.6% |
| Desmontaje | 775 | 0.5% |
| **Fase 3 (Sexto Día)** | 125 | 0.08% |
| **Fase 4 (Septimo Día en adelante)** | 111 | 0.07% |
| Fase 1 Runner (Dia 1) | 78 | — |
| **Fase 2 (Quinto Día)** | 75 | 0.05% |
| Fase 2 Runner (Dia 2) | 44 | — |
| Fase 5 Runner (Día 5), Fase 3 Runner (Dia 3), Fase 7 Runner (Día 7), Fase 4 Runner (Dia 4), ... hasta **Fase 30 Runner (Día 30)** | 1-21 c/u | — |

**Conclusiones:**

- **El catálogo base de 5 valores (No aplica/Preparación/Montaje/Show/Desmontaje) es
  correcto y domina el uso real** (~8,400 filas de las ~9,800 con valor) → confirma que
  Migración 011 no perdió nada relevante.
- **"Fase 1 (de 1 a 4 días)/Quinto Día/Sexto Día/Séptimo Día en adelante" sí se usó en
  producción** (902+125+111+75 = 1,213 filas) pero es minoritario (~12% de las filas con
  valor, ~0.76% del total). No es ruido, pero tampoco es el caso general.
- **Hallazgo nuevo no documentado antes**: existe un tercer patrón, **"Fase N Runner
  (Día N)"**, generado dinámicamente día por día para un puesto específico llamado
  "Runner" en eventos muy largos (visto hasta Día 30). Esto confirma que en el sistema
  real, "Fase del Evento" **no era un enum cerrado**: para casos de producciones
  extendidas, se daban de alta valores nuevos sobre la marcha (texto libre con patrón
  "Fase N <Puesto> (Día N)"), no seleccionados de una lista fija.
- **Por qué el esquema actual de PeopleMovil ya está bien preparado para esto**: `te_pedidos_detalle`
  tiene tanto `fase_evento_id` (FK al catálogo limpio de 5 valores, `tc_fases_evento`)
  como `fase_evento_str` (texto libre) — ese diseño dual, aunque no estaba documentado
  el porqué, es exactamente lo necesario para separar el 88% de uso estructurado del
  ~12% de valores ad-hoc tipo "Fase N Runner".

## 2. El verdadero mecanismo de tarifa graduada por día de show: "Tipo de Complejidad"

Los *Scripts de Prueba Freelance.xlsx* (Escenario 29, "Prorrateo de sueldos matriciales")
revelan que el prorrateo por día **no vive en "Fase del Evento"**, vive en
**Tipo de Complejidad × Días de Show**:

> *"Generar un pedido de producción con complejidad 'Auditorio Nacional' y con 3 días de
> Show. Validar que en la cuadrícula se muestra el importe total correspondiente a los 3
> días Show (**100%-50%-50%**)."*

Y el Access real lo confirma estructuralmente: `dbo_Pedidos` tiene `IdTipoDeComplejidad` +
`Duracion del Evento (Numero de Dias)` + `IdTipoDuracionDelEvento` como columnas propias
del pedido (no del detalle) — el "Tipo de Complejidad" ya filtra qué catálogo de
6 complejidades aplica (confirmado también en el escenario de prueba: *"Validar que el
sistema sólo muestra las 6 complejidades del catálogo"*, y en la base real
`tc_tipos_complejidad` tiene exactamente **6 filas**).

**El prorrateo mismo (100%-50%-50%) estaba marcado "PENDIENTE TIGRE"** en el Escenario 17
del propio QA de OCESA (2018) — ni el equipo original lo tenía completamente cerrado/probado.

### Qué ya existe en PeopleMovil para esto — y qué falta

| Pieza | Estado en PeopleMovil |
|---|---|
| `tc_tipos_complejidad` | ✅ 6 filas, coincide con el real |
| `tc_tipos_duracion_evento` | ✅ 6 filas |
| `tp_duraciones_evento` (rangos `dias_desde`/`dias_hasta` + `factor_sueldo` por complejidad) | ⚠️ Tabla ya diseñada correctamente (parametrizada, sin hardcodear "Fase 1/2/3/4"), **pero 0 filas sembradas** |
| `tp_sueldos_matriciales` (tabulador base por puesto × complejidad × duración) | ⚠️ Tabla ya diseñada, **0 filas sembradas** |
| Uso de `factor_sueldo` en el cálculo real de presupuesto (`matriz_puestos_pedido()` u otra función) | ❌ No encontrado ninguna referencia — el campo no está cableado a ningún cálculo todavía |

**Conclusión**: el diseño de esquema anticipó correctamente el mecanismo real (mejor que
replicar "Fase 1-4" como enum fijo), pero **es scaffolding sin sembrar ni conectar al
cálculo de "Presupuesto por Día"** que hoy se ve en `SitiosAsignacion.jsx` / `matriz_puestos_pedido()`.

## 3. "Periodo de Pago" — campo confirmado muerto en producción

`dbo_Pedidos Detalle.[Periodo de Pago]`: **0 de 159,248 filas tienen valor** (100% NULL).
El campo equivalente en PeopleMovil (`te_pedidos_detalle.periodo_pago`) no tenía
documentado su propósito — ahora está confirmado: **nunca se usó en el sistema real**, no
hay regla de negocio que recuperar de ahí. No requiere acción.

## 4. "Pago Especial" — el verdadero mecanismo de excepción (sí se usó)

`dbo_Pedidos Detalle.[Pago Especial]`: **47,789 de 159,248 filas tienen valor (30%)** —
masivamente usado. Lectura más probable, cruzando con el punto 2: en la práctica, OCESA
no confiaba en un cálculo automático de prorrateo por día — el personal de operaciones
**capturaba manualmente un monto especial** cuando el pago de un día no coincidía con la
tarifa estándar (incluyendo, probablemente, los casos de "Fase N Runner" vistos arriba).

PeopleMovil ya tiene el campo equivalente: `te_pedidos_detalle.pago_especial numeric(12,2)`
— sin acción pendiente aquí, solo queda confirmado que es un campo vivo y no vestigial.

## 5. `IdSueldoLobo` — referencia externa, no resoluble desde este Access

`dbo_Plazas.IdSueldoLobo`: **87,810 de 87,810 filas (100%) tienen valor** — cada plaza
reservada está ligada a un "sueldo" del sistema Lobo. Es una referencia externa a una
tabla que vive en el backend SQL Server de Lobo/GeneXus, no incluida en este export de
Access — no se puede inspeccionar su contenido desde aquí. Confirma que el tabulador de
sueldos era un componente central (100% de uso), consistente con que PeopleMovil ya tenga
`tp_sueldos_matriciales` modelada, aunque su contenido real no se pudo recuperar de esta
fuente.

## 6. Pendientes que quedan abiertos (estado al 2026-10-08)

- Sembrar `tp_duraciones_evento` / `tp_sueldos_matriciales` con datos reales (o
  representativos) y conectar `factor_sueldo` al cálculo de presupuesto — hoy es
  esquema sin uso.
- Decidir si se quiere replicar el patrón "Fase N <Puesto> (Día N)" generado
  dinámicamente (vía `fase_evento_str` libre, ya soportado) o si se considera fuera de
  alcance por ser un caso minoritario (~0.1% de las filas).
- El contenido real del tabulador `IdSueldoLobo` no se pudo recuperar — si se necesita,
  habría que buscarlo en el backend de Lobo directamente (no en este Access).

---

## 7. Actualización 2026-10-09 — datos REALES del tabulador (ya no son representativos)

El usuario compartió 3 documentos nuevos que resuelven o corrigen varios puntos de
arriba. **Migración 021 (datos inventados) fue reemplazada por Migración 022 (datos
reales)** — ver `db/reset_database.sql`.

### 7.1 `Catalogos Sueldos Matriciales.xlsx` — el tabulador real completo

Export directo del legado, 5 hojas: `Puestos` (986 filas), `Sueldos Matriciales`
(1000 filas), `Tipos de Complejidad en Eventos` (12 filas), `Sueldos Matriciales
Duracion` (3 filas), `Sueldos Mat Duracion Detalle` (8 filas).

**Hallazgos que corrigen lo que se había inventado:**

- **`Tipo de Complejidad` NO lleva el número de días en el nombre.** Mi catálogo
  inventado ("Foro Sol - 1 Día", "Foro Sol - 2 Días") era arquitectónicamente
  incorrecto. El real son 6 complejidades vigentes, por aforo (PAX), totalmente
  independientes de la duración: *Teatro Metropolitan/Plaza Condesa*, *Auditorio
  Nacional/Guadalajara*, *Palacio de los Deportes/Arena VFG*, *Foro Sol — hasta
  50,000*, *Estadios/Foro en el extranjero*, *Festivales +50,000*. (Hay 6 más,
  histórico pre-2018, no vigentes — no se insertaron.)
- **`Tipo de Duración` real tiene solo 3 valores**, no 6: *Shows Sueltos* (días 1-3),
  *Tarifa por Semana* (días 4-29), *Tarifa por Mes* (días 30-365, **prorrateado**:
  `sueldo_base / 30 × días del periodo`, no usa un factor fijo). Se agregaron las
  columnas `prorrateado`/`divisor_prorrateo` a `tp_duraciones_evento` para esto.
- **El patrón de factor por día real es mucho más simple** que lo que inventé: Shows
  Sueltos = día 1 100%, días 2-3 50%. Tarifa por Semana = días 4-7 100%, 8-29 50%.
  Nada de tramos "Quinto día/Sexto día" graduados — esos SÍ existen pero viven en
  otro lado (ver siguiente punto).
- **El tabulador real tiene una CUARTA dimensión que el esquema no tenía:
  `Fase de Evento`.** Para puestos como Runner, Runner con/sin coche, el sueldo se
  fija por fase (Preparación/Montaje/Show/Desmontaje, o el patrón libre "Fase N (de
  1 a 4 días)/Quinto Día/Sexto Día/Séptimo Día en adelante", o "Fase N Runner (Día
  N)"), con `IdTipoComplejidad`/`IdTipoDuracion` en `NULL` — es decir, para esos
  puestos la complejidad/duración del pedido NO importan, solo la fase. Se agregaron
  `fase_evento_id`/`fase_evento_str` a `tp_sueldos_matriciales` (mismo patrón dual
  ya usado en `te_pedidos_detalle`).
- **Confirmado con datos reales: Runner migró de tarifa por tramos a tarifa por día
  exacto el 2018-02-12.** Las 4 filas "Fase 1-4 (días)" de Runner tienen
  `FechaFin='2018-02-11'` (ya no vigentes); las 30 filas "Fase N Runner (Día N)"
  arrancan `FechaInicio='2018-02-12'` y son las vigentes hoy. Runner con/sin coche
  **nunca migraron** — para ellos siguen vigentes tanto el patrón de 4 tramos como
  el de Preparación/Montaje/Show/Desmontaje, simultáneamente.
- **Gap real descubierto, no inventado**: filtrando por "vigente hoy" (`Activo=1 AND
  FechaFin IS NULL`), **Productor C y los 3 Stage Manager (A/B/C) no tienen NINGUNA
  fila de tarifa vigente** en el legado real — solo tienen histórico expirado
  (`FechaFin='2017-12-31'`). Es decir, en el sistema real, a partir de 2018 esos 4
  puestos se quedaron sin tarifa matricial configurada. Migración 022 refleja esto
  tal cual: no se inventó una tarifa para ellos. `tc_puestos.matricial=true` se
  mantiene en los 9 (confirmado correcto contra el flag real `dbo_Puestos.Matricial`
  — la Migración 021 ya había acertado esto sin saberlo).
- Se cargaron **54 filas reales** en `tp_sueldos_matriciales` (Productor A: 5,
  Productor B: 4, Runner: 30, Runner con coche: 8, Runner sin coche: 7) y **8 filas
  reales** en `tp_duraciones_evento`, reemplazando las 54+17 filas inventadas de la
  Migración 021.

### 7.2 `Reglas de negocio pedidos.docx` — confirma el mecanismo y agrega reglas nuevas

- **Confirma textualmente el mecanismo de arriba**: *"En base a los días de evento
  indicados se busca el rango en el catálogo 'Sueldos Matriciales Duración Detalle',
  se obtiene el IdTipoDuracion (se usa al momento de calcular el sueldo)."*
- **Regla nueva no documentada antes**: los campos "Tipo de Complejidad" y
  "Duración del evento" en Alta de Pedido **solo se habilitan y son obligatorios si
  la Sociedad Propia del PEP es "Ocesa RH"**; para cualquier otra sociedad propia se
  deshabilitan. Esto no está implementado en `SitiosAsignacion.jsx` (hoy esos campos
  siempre están visibles/opcionales, sin depender de la sociedad propia).
- Edición de pedido: no se puede editar un pedido Cancelado o Procesado; si tiene
  algún detalle PROCESADO, no se puede cambiar PEP/Tipo de Complejidad/Días de
  Show. No implementado todavía como validación.
- **Detalle nuevo sobre "Liberar"**: al liberar un pedido, cada detalle en estatus
  "Normal" pasa a LIBERADO y **su `fecha_liberacion` se limpia a NULL** (no se fija
  a la fecha actual). Nuestro `liberarPedido()`/`liberarDetalleLinea()` actuales solo
  cambian `status_detalle`, sin tocar `fecha_liberacion` — diferencia de
  comportamiento a revisar si se quiere fidelidad total.

### 7.3 `reglas de negocio_cancelaciones.docx` — pseudocódigo real de 6 reglas

- **Corregido en Migración 022**: *"Cada 3 hrs se ejecuta un proceso que revisa la
  vigencia de las preasignaciones... Este proceso **no aplica** para las unidades de
  negocio de Producción y PRG."* `cancelacion_automatica_preasignados()` no tenía
  esta excepción — ya se agregó (excluye reservaciones de puestos cuya
  `tc_unidades_negocio.titulo` sea `Produccion` o `PRG`).
- **Pendiente, no implementado**: si se cancela una reservación que pertenece a un
  **bloque**, se cancela **toda la serie de reservaciones de ese empleado en ese
  bloque** (mismo `empleado_id`+`bloque_num`+`pedido_id`), no solo la reservación
  puntual. Nuestro `cancelarDetalleLinea()` actual solo cancela las reservaciones del
  detalle específico.
- **Pendiente, no implementado**: cancelación automática por disminución de cantidad
  solicitada — si se reduce `cantidad` en un `pedido_detalle` con más reservados que
  el nuevo cupo, el sistema cancela el excedente, priorizando cancelar primero a
  quien tenga **peor certeza** (más faltas), y en empate, al último en confirmar. No
  hay trigger equivalente hoy.
- **Ambigüedad en la fuente, no resuelta**: la regla de cancelación desde el portal
  freelance dice *"se puede cancelar... si NOW()-Detalle.Cita >= Puesto.TiempoParaCancelar"*
  — literalmente esto permitiría cancelar solo cuando la cita YA PASÓ hace rato, lo
  opuesto a la intención operativa obvia (cancelar ANTES de la cita, respetando una
  ventana mínima). Es casi seguro un error de signo en el documento original
  (debería ser `Detalle.Cita - NOW() >= TiempoParaCancelar`, coherente con D4/las 72h
  ya modeladas). No se "corrigió" silenciosamente — queda para confirmar con el
  usuario antes de tocar `valida_no_empalme`/reglas de cancelación del portal.
- Confirmado (ya replicado correctamente): cancelar un pedido cancela todos sus
  detalles y reservaciones no procesados; cancelar vía Confirmación Forzada no tiene
  restricción salvo que la reservación ya esté Procesada.
