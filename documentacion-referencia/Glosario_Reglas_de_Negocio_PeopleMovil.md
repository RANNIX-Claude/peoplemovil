# Glosario de reglas de negocio — Sistema Lobo / AppSCPF

Cada regla listada aquí viene de código real encontrado en el GeneXus KB (`AppSCPF_05_11_19.xpz`), no de una interpretación. Se cita el procedimiento de origen para que puedas verificarlo en `reglas_negocio_PRC_completo.txt` si quieres el detalle línea por línea.

---

## 1. Certeza requerida por puesto
**Procedimientos:** `PRC_ObtenerCertezaPuesto`, `PRC_ValidaEmpPuesto`

**Qué resuelve:** que no cualquier freelance pueda tomar cualquier rol — solo quienes ya demostraron ser puntuales/confiables al nivel que ese puesto específico exige.

**Cómo funciona:** cada puesto tiene una **certeza mínima requerida** (`TC_PuestosPorCerIni`). Cada empleado acumula un **% de puntualidad** propio (`TE_EmpPorPuntualidad`) basado en su historial. Al intentar reservar a alguien para un puesto, el sistema compara: si el % del empleado es mayor o igual al mínimo del puesto, puede reservarse; si no, se rechaza. También valida género requerido cuando el puesto lo especifica (`SexoRequerido`).

**Ejemplo concreto:**
- El puesto "Jefe de Seguridad VIP" exige certeza mínima de **90%**.
- Juan Pérez tiene un histórico de puntualidad de **85%** → el sistema **no permite** reservarlo para ese puesto, aunque sí podría tomar el puesto "Acomodador" que solo exige 60%.
- María López tiene **93%** → sí califica para el puesto VIP.

**Parámetro configurable por puesto, no global** — cada rol define su propio umbral.

---

## 2. Margen mínimo entre turnos (traslape/traslado)
**Procedimiento:** `PRC_Noempalmereservacion`

**Qué resuelve:** evitar asignar a una persona a dos compromisos que en la práctica no podría cumplir por falta de tiempo entre uno y otro (para descansar, trasladarse, etc.) — pero de forma automática, no manual.

**Cómo funciona:** el sistema calcula las **horas totales necesarias** para el nuevo compromiso como:
```
horas_totales = (número de turnos × horas por turno) + margen_de_seguridad_del_puesto
```
Luego busca, entre las reservaciones activas de esa misma persona, la más cercana **antes** y **después** de la fecha que se quiere asignar, y calcula la diferencia real en horas. Si esa diferencia es menor a las horas totales requeridas, la asignación se rechaza.

**Ejemplo concreto:**
- Puesto "Cargador de escenario" tiene un margen de seguridad de **6 horas** (`TC_PuestosHrasEntrTur`), y el nuevo compromiso son 2 turnos de 8 horas → horas totales = 2×8 + 6 = **22 horas**.
- El empleado ya tiene un turno confirmado que termina el jueves a las 22:00.
- Se quiere asignar el nuevo turno el viernes a las 08:00 → solo hay **10 horas** de diferencia → **se rechaza automáticamente**, sin que nadie tenga que revisarlo a mano.
- Si el nuevo turno fuera hasta el sábado a las 06:00 (32 horas de diferencia), sí se permitiría.

**Importante:** el margen es un número de horas configurable **por tipo de puesto**, no una distancia real calculada con mapas — el sistema no sabe si dos eventos están en la misma ciudad o en ciudades distintas, solo aplica el margen que alguien definió a mano para ese puesto.

---

## 3. Ventana de cancelación por puesto
**Procedimiento:** `PRC_ValidacionesCancelarReservacion`

**Qué resuelve:** que alguien no pueda cancelar un compromiso ya confirmado a última hora sin consecuencia, pero tampoco que quede atado para siempre a un compromiso lejano.

**Cómo funciona:** el sistema calcula cuántas horas faltan desde ahora hasta el inicio de la cita (`tdiff` entre `now()` y la hora de inicio de la reservación). Si esas horas son **mayores o iguales** al umbral mínimo definido para ese puesto (`TC_PuestosHrasAntesCanPed`), se permite cancelar; si no, se bloquea. También hay una excepción: si el status es "ConfirmadoForzado" (una asignación forzada por el sistema, no elegida voluntariamente), aplica una lógica distinta.

**Ejemplo concreto:**
- Puesto "Mesero de evento corporativo" exige mínimo **48 horas** de anticipación para cancelar.
- Faltan 60 horas para el evento → el freelance **sí puede** cancelar.
- Faltan 30 horas → el sistema **bloquea** la cancelación (tendría que negociar una excepción con el coordinador).

---

## 4. Cancelación automática de "preasignados" que no confirman a tiempo
**Procedimiento:** `PRC_CancelacionAutomaticaPreasignados`

**Qué resuelve:** liberar espacios reservados que nadie terminó de confirmar, para que no se queden "atorados" y se puedan ofrecer a otra persona antes de que sea demasiado tarde.

**Cómo funciona:** busca reservaciones en estado "Confirmado Opcional" (una especie de apartado, no confirmación firme) donde:
- Falten **menos de 72 horas** para el evento, **y**
- Hayan pasado **más de 8 horas** desde que se ofreció esa reservación sin que la persona la confirmara.

Si se cumplen esas condiciones, el sistema la cancela automáticamente — sin intervención humana — para que el coordinador pueda reasignar el lugar a tiempo.

**Ejemplo concreto:**
- Se le ofrece a Pedro un turno para el sábado. Hoy es martes (faltan 96 horas) → todavía no aplica el auto-cancelado, tiene tiempo de decidir.
- El jueves a las 10am (faltan 48 horas, ya pasaron más de 8 horas desde que se le ofreció) Pedro sigue sin confirmar → el sistema **cancela automáticamente su preasignación** y libera el cupo.

---

## 5. Folios consecutivos por tipo de entidad (no un solo contador global)
**Procedimientos:** `PRC_FoliosConsecutivos`, usado también dentro de `PRC_AltaEmpleadosCursoInduccion`

**Qué resuelve:** que cada tipo de documento/registro (empleado, factura, pedido) tenga su propia numeración consecutiva, sin mezclarse entre sí.

**Cómo funciona:** el sistema busca el último folio usado **para ese nombre de transacción específico** (por ejemplo, "Empleado") y le suma 1. Si nunca se ha usado ese tipo, arranca en 1.

**Ejemplo concreto:**
- El último empleado dado de alta tiene folio **1,204** → el siguiente candidato promovido a empleado recibe folio **1,205**.
- Esto es independiente del folio de facturas de honorarios, que lleva su propio contador (por ejemplo, folio 3,890 en ese momento) — nunca se cruzan.

---

## 6. Validación de identidad duplicada (RFC/CURP)
**Procedimiento:** `PRC_ValidaRfcCurp`

**Qué resuelve:** evitar que la misma persona se registre dos veces como candidato distinto, o que se capture mal un RFC/CURP que ya pertenece a alguien más en la base.

**Cómo funciona:** antes de guardar un candidato nuevo, busca si ya existe ese mismo RFC o CURP en la tabla de candidatos. Si existe, marca `&existe=True` y el alta se detiene.

**Ejemplo concreto:**
- Alguien intenta registrarse con el CURP `PEGJ850101HDFRZN01`, que ya pertenece a otro candidato en el sistema → el alta se rechaza antes de crear un registro duplicado.

---

## 7. Promoción de candidato a empleado (alta definitiva)
**Procedimiento:** `PRC_AltaEmpleadosCursoInduccion`

**Qué resuelve:** que nadie entre a trabajar como freelance formal sin haber completado el proceso de inducción, y que sus datos completos (identidad, domicilio, características físicas relevantes al puesto) queden copiados correctamente del expediente de candidato al expediente de empleado.

**Cómo funciona:** toma todos los campos capturados durante el reclutamiento (nombre completo, RFC, CURP, género, estado civil, fecha de nacimiento, estatura, talla, domicilio, número de INE, etc.) y los transfiere en bloque a la tabla de empleados, asignando el folio consecutivo correspondiente (regla #5). Esto ocurre en el punto del proceso donde ya se confirmó su asistencia al curso de inducción — no antes.

**Ejemplo concreto:**
- Ana se registró como candidata y asistió al curso de inducción del martes.
- Al confirmarse su asistencia, el sistema la promueve automáticamente a empleado con folio nuevo, copiando su RFC, CURP, domicilio y demás datos — ya puede empezar a recibir asignaciones de reservación.

---

## 8. Cálculo de nómina basado en asistencia real, no en lo programado
**Procedimientos:** `PRC_CalculoNomina`, `PRC_CalculoNominaIndividual`

**Qué resuelve:** pagar por lo que realmente ocurrió (asistencia, retardo o falta), no por lo que se planeó originalmente — y calcular un salario diario promedio por persona a partir de su historial del periodo.

**Cómo funciona:** recorre las reservaciones en estado "Procesado" (ya cerradas) cuyo estado de asistencia sea Asistencia, Retardo **o Falta** (las tres entran al cálculo — la falta también se procesa, probablemente para aplicar la penalización correspondiente), las agrupa por empleado, suma los montos, y divide entre el número de reservaciones contadas para obtener el **salario diario promedio** de esa persona en ese periodo.

**Ejemplo concreto:**
- Roberto (freelance) tuvo en la quincena: 5 reservaciones con asistencia completa, 1 con retardo, 1 falta.
- El sistema procesa las 7, suma los montos correspondientes (la falta probablemente en $0 o con penalización), y calcula: `salario_diario_promedio = total_monto / 7`.
- Ese promedio es lo que alimenta el reporte de dispersión de nómina para ese periodo.

---

## Patrón general que se repite en casi todas las reglas

Algo que vale la pena que veas de un vistazo, porque es el principio de diseño que hace que este sistema haya funcionado bien durante años: **casi ningún umbral está escrito directamente en el código** (con la única excepción confirmada del "72 horas" y "8 horas" en la regla de cancelación automática, que sí aparecen como números fijos). Todo lo demás — certeza mínima, margen entre turnos, ventana de cancelación — vive en una tabla de configuración por puesto (`TC_Puestos...`). Eso significa que quien administraba el sistema podía ajustar las reglas de negocio **sin tocar código**, solo cambiando un valor en un catálogo. Es el mismo principio que deberíamos preservar en la versión moderna: parámetros en base de datos, no constantes en el código de Claude Code.
