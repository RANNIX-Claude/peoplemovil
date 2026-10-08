# Escenario 9 — Validación certeza valor — Evidencia visual (frames del video QA)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\08 - Escenario9\`
Video: YouTube `sPnFLyeBMGk` ("Escenario9"), 487s, 125 frames extraídos (`001_00m00s.png` … `125_07m58s.png`).
Sistema: **GeneXus "RRHH" / AppSCPF** (Lobo), ambiente QA: `integramx-001-site2.btempurl.com/qafreelancev1/`.
Nota: el folder cubre tanto Escenario 9 como el final de la preparación de datos que reutilizan otros escenarios (7, 16, etc.) — el tenant QA comparte catálogo de pedidos/empleados entre todos los escenarios grabados en la sesión.

Muestreo: 36 frames inspeccionados, aproximadamente cada 4 frames (~16s) a lo largo de todo el rango 000s–478s, más 2 crops ampliados para leer texto pequeño (mensaje de error y campo "Puntualidad").

---

## 1. Pantalla de login (001_00m00s.png, 061_04m07s.png)

- Título del módulo: **"RRHH"** (logo azul rectangular).
- Campos: **Usuario**, **Contraseña** (ambos text input simples, sin placeholder).
- Botón: **Ingresar** (azul).
- Mensaje de estado inicial (no es error, aparece siempre al cargar sin sesión): *"El usuario debe estar autenticado."* (banner naranja/amarillo con ícono "!").
- Fondo: foto de concierto/festival (branding OCESA).

## 2. Alta de Empleado — formulario "Información General" (005_00m14s.png, 009…057)

Ruta: menú **Empleados → (Alta individual empleado)** → `te_empleado.aspx?INS.0`
Encabezado del formulario: sección **"Información General"**.

Campos observados, en orden, con tipo de control:

| Campo | Control | Notas |
|---|---|---|
| Foto | upload de imagen (ícono placeholder) | |
| Tipo de empleado * | dropdown | observado valor **"Eventual"** |
| Apellidos * | texto | |
| Materno | texto (no obligatorio) | |
| Nombre * | texto | |
| Estatus | dropdown | valores vistos: **Inactivo**, **Activo** |
| Sexo | dropdown | valor visto: **Masculino** |
| **Puntualidad** * | numérico **de solo lectura** + ícono **"?"** de ayuda | **Este es el campo de "certeza valor"** (ver sección 4) |
| Régimen de pago | dropdown | opciones: **(Ninguno)**, **Honorarios Asimilables**, **Honorarios Normales** |
| Ciclo de pago | dropdown | opciones: **(Ninguno)**, **Catorcenal**, **Semanal** |
| Correo electrónico * | texto/email | |
| Bancos * | combo con buscador (ícono lupa) | |
| Nombre (del banco) | texto, solo lectura tras selección | |
| Cuenta Banco | texto | ejemplo capturado: `02847584958` |
| Fecha nacimiento * | date picker (dd/mm/aaaa) | |
| Estado de nacimiento | texto | |
| RFC | texto | |
| CURP | texto | |
| IFE/INE | texto | |
| Cartilla | texto | |
| Estatura | numérico (m) | ejemplo: `1.65` |
| Estado civil | dropdown | |
| Talla * | texto | |
| Calle * | texto | |
| Num ext * | texto | |
| Num int | texto | |
| Código postal * | texto + botón lupa (autocompleta Municipio/Ciudad/Estado) | ejemplo: `56625` → Chalco / Chalco de Díaz Covarrubias / México |
| Municipio / Ciudad / Estado / Colonia | solo lectura (derivados del CP) | |
| Móvil / Tél. particular | texto | |
| Fecha ingreso * | date picker con calendario desplegable (mes "Agosto, 2019", con botón "Hoy") | |
| Solicitud | numérico (oculto detrás de calendario en el frame) | |
| Grado de estudios / Estatus estudios / Idiomas / Accidente / Cirugías-Tratamientos | aparecen más abajo (no se alcanzó a leer el detalle completo de estos controles) | |

Validación capturada (021_01m22s / 081…): al guardar con campos incompletos aparece un **modal "Not Authorized" / "UNAUTHORIZED ACCESS"** (pantalla de sesión expirada, con opciones "TO LOGIN AGAIN, CLICK HERE" / "TO RETURN, CLICK HERE") — esto ocurrió una vez durante la grabación por timeout de sesión, no es un mensaje de negocio.

Mensaje de validación de campo obligatorio capturado (029_01m52s.png): recuadro naranja sobre la foto:
> **"Puntualidad es requerido."**

Esto confirma que el campo interno/técnico para la certeza valor del empleado se llama **"Puntualidad"** en la UI de alta de empleado (no "Certeza valor"), aunque conceptualmente es el mismo dato que alimenta `porcentaje_certeza_inicial`.

## 3. Grid/listado de Empleados (057_03m43s.png, 117, 120, 122_07m48s.png)

Ruta: **Empleados → Lista de empleados** (`te_empleadoww.aspx`)

Columnas de la grilla: **Id | Nombre Completo | Estatus | Sexo | Certeza | Correo electrónico | Sucursal**

- **Importante:** en el listado la columna se llama **"Certeza"** (no "Puntualidad", no "Certeza valor") — inconsistencia de nomenclatura entre el formulario de alta ("Puntualidad") y el grid ("Certeza"). Ambos muestran el mismo valor numérico (0.00–1.00).
- Filtro superior: selector "Buscar en" → **Nombre Completo** (dropdown de criterio) + campo "valor" + botón limpiar (+).
- Botones de exportación: **+ (nuevo)**, **XLS**, **PDF**, **Selecciona columnas** (dropdown de columnas visibles).
- Orden de columna: clic en header despliega menú **"Ordenar de A a Z" / "Ordenar de Z a A" / "Limpiar búsqueda"** + rango **"Desde" / "Hasta"** + botón **Buscar**.

Empleados de prueba creados específicamente para este escenario (122_07m48s.png), todos con certeza **0.90** salvo uno (0.80):

| Id | Nombre | Certeza | Correo |
|---|---|---|---|
| 65858 | Huerta Danilo Santos | 0.90 | danilo@gmail.com |
| 65857 | Berenice Lucas Nieves | 0.90 | let_lizmer@hotmail.com |
| 65856 | Carlos Flores Montes Montes | 0.90 | calvario.marron.leonardo@gmail.com |
| 65855 | Guillermo Lopez Ruiz | 0.90 | calvario.marron.leonardo@outlook.com |
| 65854 | Juan Perez Sanchez | 0.90 | (vacío, solo ".") |
| 65853 | seguridad 1 1 | 0.90 | seg1@gmail.com |
| 65852 | Valentin Belarde jaime Belarde jaime | 0.90 | vbelar@gmail.com |
| 65851 | Tomás Torres Dominguez Torres Dominguez | 0.90 | ttorres@gmail.com |
| 65850 | Migel Reyes Torres Reyes Torres | **0.80** | manuel_alonso@icloud.com |
| 65849 | GONZALO GONZALO rodriguez GONZALO rodriguez | 0.90 | GGONZALO@GMAIL.COM |
| 65848 | Rodrigo calvo Gomez calvo Gomez | 0.90 | rcalvo@gmail.com |

El empleado principal usado en la asignación forzada del escenario es **Id 65858 "Huerta Danilo Santos"**, con **certeza 0.90**, puesto **Seguridad**. (Nota: el ID de texto del script dice "ID(57231)" pero el ID real generado en este ambiente QA fue 65858 — los IDs del documento de escenarios son de otro ambiente/corrida; lo relevante es la certeza 0.9 del puesto Seguridad, que sí coincide exactamente.)

## 4. Campo "certeza valor" — detalle visual (030_01m53s / 031 / 033 / 037)

Zoom del campo Puntualidad dentro del formulario de Empleado:

```
0.90  [?]  Seguridad || Seguridad
```

- El valor `0.90` se muestra en un **input numérico de solo lectura/deshabilitado** (fondo gris), es decir, **no editable manualmente por el usuario**: se calcula/hereda automáticamente a partir del puesto asignado.
- Junto al valor hay un **ícono de ayuda "?"** (tooltip, no se pudo capturar el texto del tooltip porque no fue abierto en el video).
- A la derecha aparece el texto **"Seguridad || Seguridad"** — el nombre del puesto repetido dos veces separado por `||`. Esto es casi con certeza un patrón de concatenación tipo `{puesto} || {puesto}` del lado GeneXus (posible variable mal poblada o diseño que concatena "puesto principal" y "puesto actual" cuando el empleado tiene un solo puesto). Vale la pena replicarlo o corregirlo conscientemente en PeopleMovil, documentando que NO es un error de captura sino comportamiento real observado en producción QA.

## 5. Alta de Pedido (073_04m56s.png … 101)

Ruta: **Operaciones → Pedidos** → `te_pedido.aspx?INS,0`
Sección: **"Información General"**

Campos y combos, en orden:

| Campo | Control |
|---|---|
| Cliente * | dropdown con buscador tipo-ahead; catálogo largo de razones sociales OCESA/clientes (ej. "2 Hands Production Services, S.A. de C.V.", "OCESA Promotora, S. A. de C.V.", etc.) |
| Id Contacto * | dropdown (depende de Cliente), ej. "Heriberto Reyes Vasquez" |
| Id sucursal * | dropdown, ej. "CDMX" |
| **Unidad de negocio** * | dropdown — catálogo completo observado: *Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, Operaciones Inmuebles, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, PRG, PRG_Complejidad, Produccion, Publicidad, Recursos Humanos Operaciones, Renta de Equipos, RRHH, **Seguridad**...* (lista con scroll, alfabética) |
| Id PEP * | dropdown, ej. "Alejandro Sanz EL-HR-2019-..." |
| Id evento * | dropdown, ej. "Jacob Whitesides 2019" |
| Título * | texto (autogenerado a partir del evento, editable); ejemplo final: `Jacob Whitesides 2019--Escenario9` |
| Lugar de cita | dropdown, ej. "Foro Sol" |
| Dirección lugar | textarea, autocompletada por el lugar ("Av. Viaducto Rio de la Piedad S/N, Granjas México, 08400 Iztacalco, CDMX") |
| Otro | checkbox |
| Tipo de movimiento * | dropdown, valor "Pedido" |
| Sociedad pagadora * | dropdown, ej. "Operadora de Centros de Es..." |
| **Permitir cancelar confirmaciones** | dropdown **SI/NO**, valor visto "NO" |
| Responsable * | dropdown |

Botones al final: **Confirmar** / **Regresar**.
Links superiores del formulario: **"Agregar Detalle"** / **"Agregar Factura"**.

## 6. Grid de Pedidos (093_05m57s.png, 072_04m52s.png)

Ruta `te_pedidoww.aspx`. Columnas: **Id | Título | Estatus | Unid.Neg. | Sucursal | lugar | Responsable | Complejidad | T.Mov | PeP\|Descripción**
Estatus observados en los datos de prueba: **Vigente, Liberado, Cancelado, Procesado**.
El pedido de Escenario 9 es el **Id 1054**, título `Jacob Whitesides 2019--Escenario9`, Unid.Neg. **Seguridad**, Sucursal CDMX, lugar **Foro Sol**.
Otros pedidos visibles en la misma grilla corresponden a Escenario1…Escenario7, Escenario 5A, Escenario 6, confirmando que todos comparten el mismo evento "Jacob Whitesides 2019" como dataset de pruebas.

## 7. Detalle de Pedido / "Agregar Detalle" (097_06m14s.png, 101_06m34s.png)

Ruta: `wp_pedidodetalle.aspx?<id>`

Campo **Producto** (= catálogo de **puestos**, dropdown): opciones visibles con scroll —
`Control de Accesos-MA, Control de Accesos-FE, Control de Accesos-IN, Control de Accesos 4-MA, Control de Accesos 4-FE, Instructor de Capacitación-IN, Local Crew-FE, Local Crew-MA, Local Crew-FE, Local Crew-MA, Local Crew-IN, Local Crew Asistente de Supervisor-FE, Local Crew Asistente de Supervisor-MA, Local Crew Supervisor-FE, Local Crew Supervisor-MA, Seguridad-IN, Seguridad-MA, Seguridad-FE, Seguridad Coordinador-MA, Seguridad Mty-FE`

(Nota: el sufijo -IN/-MA/-FE probablemente indica turno/tipo: IN=Interno?, MA=Matutino, FE=?/Festivo — no verificado en el video; se recomienda confirmarlo contra el catálogo `cat_puestos`.)

Resto de campos del detalle: **Estatus** (solo lectura: Vigente/Liberado), **Evento Práctica** (checkbox), **Tipo personal** (solo lectura: "Operativo"), **Título**, **Producto**, **Lugar de Cita**, **Dirección cita**, **Otro** (checkbox), **Indicaciones especiales** (textarea), **Bloque por producto** (dropdown, "Ninguno"), **Facturable** (dropdown SI/NO); columna derecha: **Cantidad** (numérico), **Turnos** (numérico, con texto auxiliar "8 Horas por turno"), **Fecha cita** / **Fecha liberación** / **Fecha final cita** (date+hora HH:MM en selects separados), **Presentación por producto** (dropdown), **Completar con similares** (dropdown SI/NO), **Fase del evento** (dropdown, "No aplica"), **Permitir cancelar** (dropdown SI/NO).
Botones: **Agregar Detalle** / **Cancelar**.

Para el escenario 9 se usó: **Cantidad = 1**, **Turnos = 1.00**, Producto = **Seguridad-IN**, Fecha cita 20/08/2019 06:00–14:00.

## 8. Matriz de Puestos / Liberar Pedido (105_06m49s, 106_06m52s, 109…114)

Pantalla "Detalles de pedido" (`wp_pedidodetalle.aspx?1054`):

- Tabs superiores: **Editar pedido | Liberar Pedido | Cancelar Pedido** (antes de liberar) → después de liberar cambian a **Editar pedido | Cancelar Pedido** (ya no se puede volver a liberar).
- Sección **"Matriz de Puestos"**: tabla con columnas **Bloque | Productos | <fecha bloque>**; fila ejemplo: `Seguridad-IN | Jacob Whitesides 2019--Escenario9` con valor **"1 - T 1.00"** (cantidad - turnos). Totales: **Total Solicitados = 1**, **Presupuesto por día = $300.00**.
- Modal de confirmación al liberar (106_06m52s.png): título **"LIBERAR PEDIDO"**, cuerpo vacío/en blanco, botones **Sí / No**.
- Popup de detalle rápido "Editar Liberar Cancelar Pedido" (105, 067_04m32s en pedido 1053 similar): muestra **ID, Lugar de cita, Fecha cita, Fecha fin cita, Fecha liberación, Completar con similares, Cantidad reservados, Cantidad reservados real, Cantidad reservados con preasignación, Porcentaje completo, Fase de evento, Presentación producto, Indicaciones especiales**.
  - Dato relevante: **"Porcentaje completo"** es un campo DISTINTO de la "certeza valor" — representa el % de cobertura de personal confirmado vs solicitado (ejemplo en pedido 1053: 90.00 = 1 reservado real / 1 solicitado... realmente mostraba valores de otro pedido con cantidad distinta). No confundir con `porcentaje_certeza_inicial`/`porcentaje_minimo`.

## 9. Tab "Reservaciones" — Confirmación Forzada / Preasignada (109_07m06s, 113, 114, 123, 124, 125)

Dentro de "MODIFICACION DETALLE DE PEDIDO", tabs: **Detalles | Reservaciones**.

Sección **"Personal Confirmado"**:
- Campo **Nombre** (autocomplete, placeholder **"Nombre completo / Alias"**).
- Botones: **Confirmación Forzada** (azul oscuro) y **Confirmación Preasignada** (azul), lado a lado — mapean exactamente a los conceptos de texto "asignación forzada" y "preasignación".
- Link **"Imprimir lista de Asistencia"** (ícono impresora).
- Grid resultado: columnas **IdContacto | Nombre completo | Estatus**, con botón "x" (quitar) por fila. Estatus observado en otra captura (069_04m38s, pedido distinto): **CONFIRMADO**.

### Mensaje de error de la validación de certeza (125_07m58s.png) — EL HALLAZGO CLAVE

Al escribir el nombre **"65858-Huerta Danilo Santos"** en el campo y pulsar **Confirmación Forzada**, aparece un **toast/notificación naranja** en la esquina superior derecha con ícono "!" y botón "x" para cerrar, con el siguiente texto exacto (dos líneas, confirmado con zoom x3 del frame):

> **"La cantidad solicitada es menor a igual a 3"**
> **"El porcentaje de certeza del empleado es menor a 1"**

Interpretación:
- La segunda línea es la que aplica al escenario: el puesto "Seguridad-IN" de este pedido exige una **certeza mínima = 1.00** (100%), y el empleado tiene **0.90**, por lo que el sistema **rechaza la asignación forzada**. Esto confirma textualmente, con nombre de regla de negocio, el comportamiento esperado descrito en el escenario de texto ("El sistema no debe dejar realizar la asignación forzada") y liga directamente con el campo `porcentaje_minimo` de `tc_puestos`/`cat_puestos` del schema Postgres.
- La primera línea ("La cantidad solicitada es menor a igual a 3") **no corresponde al contexto de este pedido** (cuya cantidad solicitada es 1, no 3) — aparenta ser un mensaje de validación genérico/reciclado de otra regla (posiblemente relacionado al Escenario 16 "Disminución de personal" que sí maneja cantidades de 5→3→2) que quedó concatenado en el mismo control de mensajes. Esto **corrobora literalmente la observación ya registrada en el Escenario 11** del documento de texto: *"Las ventanas emergentes deben ser más precisas al indicar el error para ubicarlo... no fue posible identificar la falla."* — el sistema legado junta varios mensajes de validación posibles en un solo toast sin indicar cuál aplica realmente.

## 10. Pantallas administrativas tangenciales (115_07m32s, 116, 117, 119_07m42s)

Durante el escenario el analista QA también revisó (probablemente para verificar permisos, no es parte del flujo de negocio en sí):
- Menú superior con rol **Administrator**: **Inicio | Recursos humanos | Operaciones | Nómina | Catálogos | Seguridad sistema | Salir**.
- Submenú **Nómina**: *Alta masiva de empleados, Alta individual empleado, Lista de empleados, Desactivación empleado, Reactivación empleado, Cambio de cuenta de banco, Observaciones empleado, Plazas empleados, Sueldos matriciales (submenú), Registro manual de asistencia, Alta Masiva extras, Extras, Autorización Extras, Asignación de folios, Pago de honorarios, Cierre de nómina, Dispersión nómina, Lista negra...*
- Pantalla **"Roles"** (`gamwwroles.aspx`): grid con columnas Children/Permissions/Copy/Name; roles listados: **Unknown, Administrator, RRHH, Candidato, Operación, Administración de Personal, Freelance, Pedidos, Ventas** (pág. 1 de 2).
- Pantalla **"Permissions of Role: Administración de Personal"** (`gamwwrolepermissions.aspx`): grid de permisos técnicos (`home_Execute`, `prc_credencial_Execute`, `tc_catbajrein_*`, etc.) con columnas **Access Type** (Allow) e **Inherited** (checkbox), y filtros **Application / Name / Type / Inherited?**.

No es información de negocio de "certeza valor" pero documenta el modelo de roles/permisos de Lobo, útil para el diseño de RBAC de PeopleMovil.

## 11. Menú "Operaciones" completo (063_04m15s.png)

Para el rol Operación: **Eventos, Lugares de Cita, Unidad de Negocio, Peps y Centros de Costos, Pedidos, Requisición de Personal**.

## Limitación de la muestra

No se localizó en los frames muestreados la vista del **portal del freelance/empleado** (la pestaña de navegador `https://member3-3.smarterasp.net/...` estuvo abierta durante toda la grabación pero nunca quedó en primer plano en los 36 frames inspeccionados). Por lo tanto **no se pudo confirmar visualmente** el paso del texto "Validar que en la página de confirmación del empleado no le aparezca el evento" ni el look exacto de esa pantalla de portal. Si se requiere, habría que revisar frames adicionales no muestreados en este pase (candidatos: entre 070_04m44s y 092_05m55s, donde el pedido ya estaba liberado y pudo haberse revisado el portal antes de la asignación forzada final).

---

## Reglas de negocio / campos NUEVOS o que agregan detalle no capturado en el texto

1. **Nomenclatura inconsistente del campo "certeza valor" en la UI real**: se llama **"Puntualidad"** en el formulario de alta de empleado (solo lectura, con ícono de ayuda "?"), pero **"Certeza"** en el listado/grid de empleados. Ninguna pantalla usa literalmente "certeza valor" como etiqueta — ese es el término del documento de pruebas/negocio, no el label de UI.
2. El campo Puntualidad/Certeza es **calculado y no editable** directamente desde el alta de empleado — se deriva del/los puesto(s) asignados ("Seguridad || Seguridad"); confirma el diseño de `cat_puestos.porcentaje_certeza_inicial` como fuente del valor por defecto.
3. Posible bug/placeholder de UI: el texto junto al valor de certeza se concatena como **"{puesto} || {puesto}"** (puesto repetido), sugiere una plantilla GeneXus con dos variables que, para empleados con un solo puesto, muestran el mismo valor dos veces.
4. El **mensaje de error real** de rechazo de asignación forzada por certeza insuficiente es:
   **"El porcentaje de certeza del empleado es menor a 1"**
   — confirma que el "1" corresponde al `porcentaje_minimo` configurado para el puesto Seguridad-IN en este pedido (100%), mientras el empleado de prueba tenía certeza 0.90. Este mensaje aparece **junto con otro mensaje no relacionado** ("La cantidad solicitada es menor a igual a 3"), evidencia visual directa de la queja ya registrada en el Escenario 11 del documento de texto sobre mensajes de error poco precisos/genéricos.
5. **"Porcentaje completo"** es un campo distinto (cobertura de cantidad de personal vs solicitado), visible en el popup "Editar Liberar Cancelar Pedido" — no debe confundirse con el porcentaje de certeza del empleado; útil tenerlo como campo separado en el modelo de datos de PeopleMovil (p. ej. columna calculada en `pedido_detalle`).
6. Catálogo completo de **"Producto" (= Puesto)** usado en el detalle de pedido de Seguridad, con sufijos de turno/tipo (-IN, -MA, -FE) que no estaban documentados en el texto: Control de Accesos (MA/FE/IN), Control de Accesos 4 (MA/FE), Instructor de Capacitación-IN, Local Crew (FE/MA/IN), Local Crew Asistente de Supervisor (FE/MA), Local Crew Supervisor (FE/MA), Seguridad (IN/MA/FE), Seguridad Coordinador-MA, Seguridad Mty-FE.
7. Catálogo completo de **"Unidad de Negocio"** (no existía lista completa en el texto): Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, Operaciones Inmuebles, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, PRG, PRG_Complejidad, Produccion, Publicidad, Recursos Humanos Operaciones, Renta de Equipos, RRHH, Seguridad (y más, lista alfabética con scroll — no se alcanzó a ver completa).
8. Campo de pedido **"Permitir cancelar confirmaciones"** (SI/NO) a nivel cabecera de pedido, adicional al "permitir cancelar" a nivel detalle — confirma que existe el flag en dos niveles (pedido y detalle), relevante para el Escenario 13 del documento de texto.
9. Catálogo de **Roles** del sistema (para diseño de RBAC): Unknown, Administrator, RRHH, Candidato, Operación, Administración de Personal, Freelance, Pedidos, Ventas (+ más en página 2, no vista).
