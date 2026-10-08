# Alta de Empleado — walkthrough desde video QA 2019 (fuente: screenshots)

**Fuente:** `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\21 - Alta empleado\`
(46 capturas, video YouTube "Alta empleado", id `J0bCP9Gk77Q`, canal WJaJa VideoClips, 164s, grabado 21/05/2019, sistema **AppSCPF / Lobo**, URL interna `integramx-001-site2.btempurl.com/qafreelancev2/`).

Se revisaron las 46 capturas (cobertura completa, no solo muestreo) porque esta pantalla es núcleo del sistema. A continuación el walkthrough en el orden exacto en que aparecen los campos durante el alta.

---

## 0. Pantalla previa: Listado de Empleados (`te_empleadoww.aspx`)

*Capturas: 001, 002*

- Grid "Empleado" con columnas: **Id | Nombre | Estatus | Sexo | Certeza | Correo electrónico | Sucursal**.
- Barra de herramientas: botón **"+"** (alta), exportar **XLS**, exportar **PDF**, filtro "Buscar en" (dropdown de columna, ej. "Id Emp.") + operador + campo valor + botón limpiar.
- Columna **Certeza** muestra valores decimales tipo 0.80 / 0.90 / 15.00 (outlier) — es el % de puntualidad/certeza del empleado.
- Menú superior: **RRHH** | Inicio | Recursos humanos | Operaciones | **Nómina** | Catálogos | Seguridad sistema | Salir | usuario "Administrator".
- El alta de empleado individual vive dentro del menú **Nómina** (ver sección de navegación al final), no bajo "Recursos humanos" como cabría esperar.

---

## 1. Formulario "Información General" (alta, `te_empleadoww.aspx?INS.0`)

Orden exacto de los campos tal como aparecen al hacer scroll hacia abajo (una sola columna de campos, etiqueta a la izquierda, control a la derecha; `*` rojo = obligatorio):

| # | Campo (label exacto) | Tipo de control | Obligatorio | Capturas |
|---|---|---|---|---|
| 1 | **Foto** | Upload de imagen (placeholder con ícono "+") | No | 003 |
| 2 | **Tipo de empleado** | Dropdown catálogo. Opciones vistas: `(Ninguno)`, **Eventual** | Sí | 003, 004 |
| 3 | **Apellidos** | Texto | Sí | 004 |
| 4 | **Materno** | Texto | No | 005 |
| 5 | **Nombre** | Texto | Sí | 005 |
| 6 | **Estatus** | Dropdown. Opciones: **Inactivo, Activo, Alta, Baja temporal, Baja definitiva, Reactivación** | No (default Inactivo) | 007, 008 |
| 7 | **Sexo** | Dropdown. Opciones: `(Ninguno)`, **Femenino**, **Masculino** | No | 008, 009 |
| 8 | **Puntualidad** | Numérico de solo lectura (0.00), con ícono "?" de ayuda; se auto-rellena al elegir un **Puesto** en un modal de selección | **Sí** — bloquea el guardado | 010 (y validación en 012) |
| 9 | **Régimen de pago** | Dropdown catálogo. Valor visto: **Honorarios Normales** | No | 016 |
| 10 | **Ciclo de pago** | Dropdown catálogo. Valor visto: **Catorcenal** | No | 017 |
| 11 | **Correo electrónico** | Texto (email) | Sí | 018, 019 |
| 12 | **Bancos** | Buscador con lupa; abre valor numérico (id) + autocompleta campo "Nombre" de solo lectura, ej. `Banamex CCC` | Sí | 019, 020 |
| 13 | **Nombre** (del banco, solo lectura, debajo de Bancos) | Texto solo lectura (derivado) | — | 020 |
| 14 | **Cuenta Banco** | Texto numérico | No | 020, 021 |
| 15 | **Fecha nacimiento** | Date picker (dd/mm/aaaa) con ícono calendario | Sí | 021, 022 |
| 16 | **Estado de nacimiento** | Texto | No | 022 |
| 17 | **RFC** | Texto | No (sin asterisco en esta captura) | 022 |
| 18 | **CURP** | Texto | No | 022 |
| 19 | **IFE/INE** | Texto | No | 022, 023 |
| 20 | **Cartilla** | Texto (cartilla militar) | No | 023 |
| 21 | **Estatura** | Numérico (0.00) | No | 023 |
| 22 | **Estado civil** | Dropdown. Valor visto: **Soltero** | No | 025 |
| 23 | **Talla** | Texto/numérico (valor visto: `28`) | Sí | 026 |
| 24 | **Calle** | Texto | Sí | 027 |
| 25 | **Num ext** | Texto | Sí | 028 |
| 26 | **Num int** | Texto | No | 029 |
| 27 | **Código postal** | Buscador con lupa → modal "Selecciona Códigos postales" | Sí | 030, 031 |
| 28 | **Municipio** | Texto solo lectura, autocompletado desde el CP | No | 032 |
| 29 | **Ciudad** | Texto solo lectura, autocompletado desde el CP (puede diferir del Municipio, ej. CP 56623 → Municipio "Chalco", Ciudad "Chalco de Díaz Covarrubias") | No | 032 |
| 30 | **Estado** | Texto solo lectura, autocompletado desde el CP (ej. "México") | Sí | 032 |
| 31 | **Colonia** | Texto (no se autocompletó en la demo; campo editable) | No | 032, 033 |
| 32 | **Móvil** | Texto (teléfono celular) | No | 033, 034 |
| 33 | **Tél. particular** | Texto (teléfono fijo/casa, **campo separado del Móvil**) | No | 034, 035 |
| 34 | **Fecha ingreso** | Date picker con mini-calendario inline (mes/año navegable) | Sí | 035, 036 |
| 35 | **Solicitud** | Numérico (id de referencia a una requisición, default 0) | No | 036, 037 |
| 36 | **Grado de estudios** | Texto | No | 037 |
| 37 | **Estatus estudios** | Texto (ej. truncado/concluido/en curso) | No | 037 |
| 38 | **Idiomas** | Texto | No | 037 |
| 39 | **Accidente** | Texto (antecedentes de accidentes) | No | 037, 038 |
| 40 | **Cirugias Tratamiento** | Texto | No | 038 |
| 41 | **Tipo sangre** | Texto | Sí | 038 |
| 42 | **Recomendado por** | Texto | No | 038 |
| 43 | **Alias** | Texto | No | 038 |
| 44 | **Sucursal** | Dropdown catálogo. Valor visto: **CDMX** | Sí | 038 |

**Botones del formulario:** `Confirmar` (primary, azul) y `Cancelar` (secondary) — captura 038.

### Validación observada
- Al intentar confirmar sin capturar **Puntualidad**, aparece un banner rojo superpuesto al menú: **"Puntualidad es requerido."** (captura 012). El campo se llena indirectamente al elegir un puesto en el modal "Selecciona Puestos".
- Los campos obligatorios llevan asterisco rojo `*` junto a la etiqueta (visible de forma consistente en todo el formulario).

---

## 2. Modal "Selecciona Puestos" (se dispara automáticamente tras el error de Puntualidad)

*Capturas: 013, 014*

Grid de selección con filtro "Buscar en" (Puesto / Comienza con / valor) y columnas:

**Id puesto | Puesto | Negocio | % Certeza Inicial | Pago | Matricial (checkbox) | Régimen de pago | Nombre (razón social pagadora)**

Ejemplos de filas vistas (búsqueda "seguridad"):
- `16` — Seguridad | Seguridad\|\|Seguridad | 0.90 | 300.00 | ☐ | Honorarios Asimilables | Tecno Inter, S.A. De C.V.
- `190` — Seguridad Coordinador | 0.90 | 100.00 | Honorarios Asimilables | Tecno Inter, S.A. De C.V.
- `430` — Seguridad Coordinador Mty
- `428` — Seguridad Mty
- `17` — Seguridad Supervisor | 0.90 | 200.00
- `429` — Seguridad Supervisor Mty

Al seleccionar un puesto (checkbox), el modal cierra y rellena en el formulario: **Puntualidad = 0.90** con etiqueta descriptiva "Seguridad || Seguridad" junto al valor.

---

## 3. Modal "Selecciona Códigos postales"

*Captura: 031*

Grid con filtro "Buscar en" (Ciudad / Comienza con / valor) y columnas:

**Código postal | Ciudad | Municipio | Estado**

Paginado: "Página 1 de 244", controles Ant/1/2/3/4/5/Sig.

Ejemplos de filas:
- `50900` Almoloya de Juárez | Almoloya de Juárez | México
- `51500` Amatepec | Amatepec | México
- `52700` Capulhuac | Capulhuac | México
- `56620`–`56641` Chalco de Díaz Covarrubias | Chalco | México

Confirma que el catálogo de CP mexicano distingue **Ciudad** de **Municipio** (ambos ya modelados en `tc_codigos_postales` vía `ciudad_id`/`municipio`, ver sección de diff).

---

## 4. Guardado y resultado

*Capturas: 039, 040*

- Tras "Confirmar", la app regresa al listado (`te_empleadoww.aspx`), con el nuevo registro en la primera fila: **Id 65837 — "Lucas Santos Leal" — Activo — Masculino — Certeza 0.90 — lucas@gmail.com — CDMX**.
- Confirma que "Apellidos" + "Materno" + "Nombre" se concatenan para el display "Nombre" del listado como `Apellidos Materno Nombre` (orden distinto al de captura: "Santos" apellido paterno, "Leal" materno, "Lucas" nombre → se muestra "Lucas Santos Leal").

---

## 5. Navegación / menú "Nómina" (contexto del flujo)

*Capturas: 041, 042*

Submenú completo de **Nómina** (donde vive el alta de empleado):

Alta masiva de empleados · **Alta individual empleado** · Listado de empleados · Baja empleado · Plazas empleados · Listas de asistencia Manual · Alta Masiva extras · Extras · Autorización Extras · Asignación de folios · Pago de honorarios · Cierre de nómina · Dispersión nómina · Lista negra · Aclaraciones · Archivos para prestadoras

Esto confirma que existe un flujo separado de **alta masiva** (import) además del individual documentado arriba, y una pantalla de **Baja empleado** (probablemente con motivo/estatus — relevante para el ciclo de vida "Baja temporal" vs "Baja definitiva" visto en el dropdown Estatus).

---

## 6. Pantalla "Plazas empleados" (bonus, no es parte del alta pero aparece al final del video)

*Capturas: 044–046*

Grid con columnas: **Id empleado | Nombre | Sexo | Certeza | Estatus | Pago | Id puesto | Puesto | Pago default | Unidad negocio | Inicio | Vigente (checkbox)**

Esto es el equivalente visual de la tabla `tr_empleado_plaza` (relación empleado↔puesto), pero expone campos que hoy esa tabla **no tiene**: `Pago` / `Pago default` (monto de pago por plaza) y `Inicio` (fecha de inicio de la plaza, distinta de `creado_en`).

---

## Diff: campos vistos en el video que NO están claramente en el esquema actual (`te_empleados` en `db/reset_database.sql`)

Se revisó `CREATE TABLE te_empleados` (línea 605) y los dos bloques `ALTER TABLE te_empleados` (líneas 697 y 1607, y el bloque grande de línea 3130 que añade ~25 columnas Lobo: `tipo_empleado`, `calle`, `numero_exterior`, `numero_interior`, `colonia`, `codigo_postal`, `delegacion_municipio`, `estado_provincia`, `estado_nacimiento`, `credencial_elector`, `cartilla`, `estado_civil`, `estatura`, `talla`, `grado_estudios`, `licenciatura_curso`, `idiomas`, `contacto_emergencia`, `datos_medicos`, `tipo_sangre`, `recomendado_por`, `fecha_antiguedad`, `status_oculto`, `requisicion_origen_id`).

La mayoría de los campos del video **ya están cubiertos**. Los siguientes son los gaps reales o ambigüedades detectadas:

1. **Teléfono duplicado — falta separar Móvil de Teléfono particular.** El video muestra dos campos distintos ("Móvil" y "Tél. particular"), pero `te_empleados` solo tiene una columna `telefono text`. Sugerencia: agregar `telefono_movil` y/o renombrar/añadir `telefono_particular`.

2. **Falta campo `alias`/apodo.** El video tiene un campo "Alias" explícito, no existe ninguna columna equivalente en el esquema.

3. **Estatus del empleado es más rico que un booleano.** El esquema modela el ciclo de vida con `activo boolean` + `fecha_baja` + `motivo_baja`. El video muestra un dropdown con 6 estados: `Inactivo, Activo, Alta, Baja temporal, Baja definitiva, Reactivación`. Esto sugiere un estado intermedio real ("Baja temporal" vs "Baja definitiva" vs "Reactivación") que un booleano no distingue. Sugerencia: considerar un `estatus_empleado_enum` o al menos un campo `tipo_baja` (temporal/definitiva).

4. **Falta campo "Estatus estudios"** (distinto de `grado_estudios` y `licenciatura_curso`) — el video lo muestra como campo separado (probablemente catálogo: cursando / concluido / trunco).

5. **"Accidente" y "Cirugias Tratamiento" son campos separados en la UI**, mientras el esquema solo tiene un único `datos_medicos text` genérico. Si se requiere la misma granularidad, convendría separarlos (o documentar que se consolidan a propósito).

6. **Duplicidad `tipo_empleado` (texto libre) vs `id_tipo_personal` (FK a `tc_tipos_personal`).** El `CREATE TABLE te_empleados` original ya tiene `id_tipo_personal uuid REFERENCES tc_tipos_personal(id)`, pero el ALTER posterior añadió también `tipo_empleado text` con el comentario "freelance | staff | interno | eventual". El video confirma que el dropdown "Tipo de empleado" es un catálogo real (mostró "Eventual" como opción de una lista), por lo que `id_tipo_personal` (FK) es la representación correcta; `tipo_empleado` (texto libre) parece redundante/legacy y debería eliminarse o quedar solo como campo de solo-lectura derivado.

7. **Falta columna `ciudad` propia en `te_empleados`** (hoy solo hay `delegacion_municipio` y `estado_provincia`). El catálogo `tc_codigos_postales` sí distingue `ciudad_id` de `municipio` (confirmado por el modal del video: CP 56623 → Municipio "Chalco" vs Ciudad "Chalco de Díaz Covarrubias" — son valores distintos). Si el alta de empleado solo guarda `codigo_postal` como texto plano (sin FK a `tc_codigos_postales`), se pierde la trazabilidad a `ciudad_id`; conviene evaluar agregar `codigo_postal_id uuid REFERENCES tc_codigos_postales(id)` o al menos una columna `ciudad text` espejo de `delegacion_municipio`.

8. **`tr_empleado_plaza` no tiene monto de pago ni fecha de inicio de la plaza.** La pantalla "Plazas empleados" (fuera del alta, pero relacionada) expone `Pago`/`Pago default` e `Inicio` por cada relación empleado-puesto; la tabla actual solo tiene `porcentaje_puntualidad` y `activo`. Sugerido: agregar `pago_default numeric` y `fecha_inicio date` a `tr_empleado_plaza`.

9. **Campo "Solicitud" (id numérico, referencia a una requisición de personal) ya tiene equivalente** (`requisicion_origen_id uuid REFERENCES te_requisicion_personal(id)`) — **no es gap**, solo se documenta para confirmar el mapeo.

10. **Campo "Foto"** ya tiene equivalente (`foto_url text`, añadido en el bloque de línea 1607) — **no es gap**.

11. El campo **RFC no mostraba asterisco de obligatorio** en esta captura (a diferencia de CURP, también sin asterisco) — contradice la expectativa típica de "RFC obligatorio"; confirmar con más escenarios si en Lobo el RFC/CURP son realmente opcionales al alta (se completan después) antes de forzar `NOT NULL` en Postgres.

Campos del video que coinciden 1:1 con columnas ya existentes (para referencia, no requieren acción): Tipo de empleado→`id_tipo_personal`/`tipo_empleado`, Apellidos/Materno/Nombre→`apellido_paterno`/`apellido_materno`/`nombres`, Sexo→`sexo`, Puntualidad→`porcentaje_puntualidad_global` (+ `tr_empleado_plaza.porcentaje_puntualidad`), Régimen de pago→`regimen_pago`, Ciclo de pago→`ciclo_pago`, Correo electrónico→`correo`, Bancos/Cuenta Banco→`id_banco`/`cuenta_bancaria`, Fecha nacimiento→`fecha_nacimiento`, Estado de nacimiento→`estado_nacimiento`, RFC/CURP→`rfc`/`curp`, IFE/INE→`credencial_elector`, Cartilla→`cartilla`, Estatura/Talla→`estatura`/`talla`, Estado civil→`estado_civil`, Calle/Num ext/Num int/Código postal/Municipio/Estado/Colonia→`calle`/`numero_exterior`/`numero_interior`/`codigo_postal`/`delegacion_municipio`/`estado_provincia`/`colonia`, Fecha ingreso→`fecha_alta`, Grado de estudios→`grado_estudios`, Idiomas→`idiomas`, Tipo sangre→`tipo_sangre`, Recomendado por→`recomendado_por`.
