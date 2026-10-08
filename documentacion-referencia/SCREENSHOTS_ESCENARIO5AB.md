# Walkthrough de capturas — Escenario 5 A/B (Sistema Lobo/AppSCPF)

Fuente: `doc/Panttallas del sistema tomados desde varios video escvenarios de pruebas de pruebas/11 - EScenario5AB/`
Video origen: YouTube `V8pfxao0NoE` ("EScenario5AB"), 249s, 107 capturas (`001_00m00s.png` … `107_03m59s.png`).
Contraparte textual: `ESCENARIOS_PRUEBA_FREELANCE.md`, sección **"Hoja: Escenario 5"** — *"Seriado con cancelación de un día para que no deje forzar ese día de otro pedido"*.

Se revisó una muestra amplia y dispersa a lo largo de las 107 capturas (más de 50 imágenes distintas, cubriendo inicio, medio y final del video). Varias capturas intermedias alternan entre el navegador (sistema real) y Excel (`Scripts de Prueba Freelance.xlsx`, hoja "Escenario 5") donde el tester resalta en amarillo el paso que está ejecutando — esto confirma, paso a paso, que la grabación sigue fielmente el guion de Escenario 5.

---

## 0. Qué distingue "5A" de "5B"

A diferencia de lo que sugiere el nombre de la carpeta ("5AB" = dos sub-corridas consecutivas), la evidencia de las capturas apunta a lo siguiente:

- El pedido **1050** ("Jacob Whitesides 2019---Escenario 5", UN *Operaciones Inmuebles*, estatus **Liberado**) ya existe **antes** de que arranque la grabación. Es el pedido seriado de 5 días (lunes a viernes) con el miércoles cancelado, descrito en el guion original. Las primeras capturas (001-006) son una vista "recap" de su resultado ya consumado:
  - Captura **001** (`001_00m00s.png`) — pantalla de **portal del freelance** "Confirmación de eventos" (menú: Comunicados generales | Calendario de eventos | Saldos | **Confirmación de eventos** | Aclaraciones | Salir, usuario "Freelance"): muestra el bloque "Eventos confirmados" con exactamente **4 filas**: `ESPECIALISTA ESTRUCTURAS INMUEBLES..Jacob Whitesides 2019` en fechas **19/08/19, 20/08/19, 22/08/19, 23/08/19**, todas a las 06:00 — el miércoles 21/08 falta, confirmando literalmente el resultado esperado del guion: *"El bloque sigue existiendo, solo que ahora tiene 4 días (lunes, martes, jueves y viernes)"*.
  - Captura **005** (`005_00m25s.png`) — pantalla "Detalles de pedido" del pedido **No. 1050**, sección "Matriz de Puestos": columnas de fecha **19/08, 20/08, 22/08, 23/08** (todas 06:00), fila `Especialista Estructuras Inmuebles-IN | Jacob Whitesides 2019---Escenario 5` con `1 - T 1.00` en cada columna, "Total Solicitados" 1/1 y "Presupuesto por día" $100.00 en cada día. Confirma de nuevo el bloque de 4 días ya recortado.
  - Captura **003** (`003_00m18s.png`) — formulario vacío "Detalles de pedido" de ese mismo pedido 1050 (`wp_pedidodetalle.aspx?1050`) antes de llenarlo: `Lugar de Cita = Palacio de los Deportes`, `Fase del evento = No aplica`, `Facturable = NO`.

- A partir de la captura **007** (`007_00m31s.png`, pantalla de login vacía) el video graba **en vivo** la creación de un **nuevo pedido** (que termina siendo el **1051**), de la unidad de negocio **PRG**, con el producto **Rigger PRG-IN**, usando el **mismo evento** ("Jacob Whitesides 2019") y fecha de cita el **21/08/2019** — exactamente el miércoles que quedó cancelado en el pedido 1050. El propósito es forzar la asignación de la persona que confirmó el bloque anterior (1050) ese mismo miércoles, para validar que el sistema NO lo permita (regla de "no permitir forzar ese día de otro pedido").

- **Dato clave**: en la grilla de "Pedidos" (captura **060**, `060_02m33s.png`) el **Título** que el propio operador capturó para el pedido 1051 es literalmente:
  **`Jacob Whitesides 2019---Escenario5A`**
  mientras que el pedido 1050 conserva el título **`Jacob Whitesides 2019---Escenario 5`** (sin sufijo "A"/"B"). Es decir, dentro del propio sistema el tester etiquetó la corrida grabada en este video como **"Escenario5A"** (el intento de forzar asignación el día cancelado, que debe fallar). Esto es un hallazgo nuevo no documentado en el texto QA.

- El guion de texto termina con una línea adicional no capturada en video: *"Realizar la misma prueba, cambiando la propiedad del puesto para que sí permita la confirmación entre seriados"* — esto sería presumiblemente el caso "5B" (con el puesto reconfigurado para SÍ permitir la asignación). **Las 107 capturas del video (hasta 03m59s de 249s totales) NO llegan a mostrar esta segunda corrida**: la última parte del video (capturas 088-107) solo termina de llenar el formulario de detalle del pedido 1051 (producto Rigger PRG-IN, fecha de cita 21/08/2019, fase "Show") y alterna con Excel resaltando hasta el paso 22 ("Forzar la asignación…"), sin mostrar el resultado de la validación ni el repetir-con-puesto-reconfigurado. **Gap documentado**: el desenlace de "5A" (mensaje de error al forzar) y el escenario "5B" completo no están en este set de capturas.

---

## 1. Login (captura 007, `007_00m31s.png`)

Pantalla "Acceso" (`inicio.aspx`), fondo de concierto/escenario:
- Logo **RRHH**
- Campos: `Usuario`, `Contraseña`
- Botón **Ingresar**
- Mensaje naranja de validación: **"El usuario debe estar autenticado."**
- Usuario capturado en otra toma (014, `014_00m50s.png`): `svillanueva`

## 2. Listado de Pedidos (`te_pedidowoo.aspx`)

Captura **060** (`060_02m33s.png`) muestra la grilla completa de "Pedidos" con columnas:
**Id | Título | Estatus | Unid.Neg. | Sucursal | lugar | Responsable | Complejidad | T.Mov | PeP\|Descripción**

Controles de la grilla: botón "+" (nuevo), exportar a **XLS**, exportar a **PDF**, "Selecciona columnas", filtro "Buscar en" (combo: p.ej. "Id pedido") + operador + valor.

Valores de **Estatus** observados en los distintos renglones: `Vigente`, `Liberado`, `Cancelado`, `Procesado`.

Filas visibles (pedidos 1043–1051), útiles como catálogo de referencia de UN, complejidad y tipo de movimiento:

| Id | Título | Estatus | Unid.Neg. | Sucursal | lugar | Responsable | Complejidad | T.Mov |
|---|---|---|---|---|---|---|---|---|
| 1051 | Jacob Whitesides 2019---Escenario5A | Vigente | PRG | CDMX | Pepsi Center WTC | Jose Edgar Barrera Diaz | No aplica | Servicio interno |
| 1050 | Jacob Whitesides 2019---Escenario 5 | Liberado | Operaciones Inmuebles | CDMX | Palacio de los Deportes | Gerardo Martinez Morales | (vacío) | Servicio interno |
| 1049 | ...Escenario 4 | Liberado | Seguridad | CDMX | Estadio Azteca | Israel Benavid Solis Carrera | | Pedido |
| 1048 | ...Escenario3 | Vigente | PRG | CDMX | Palacio de los Deportes | Jose Edgar Barrera Diaz | No aplica | Servicio interno |
| 1047 | ...Escenario2 | Vigente | PRG | CDMX | Foro Sol | Julio Cesar Angeles Ibarra | Foro Sol, Festivales hasta 50,000 asistentes y... | Servicio interno |
| 1046 | ...Escenario1 | Cancelado | Seguridad | CDMX | Teatro Telcel | Jose Edgar Barrera Diaz | | Pedido |
| 1045 | Concierto especial 2019 Escenario 22 | Procesado | Seguridad | CDMX | Palacio de los Deportes | Israel Benavid Solis Carrera | | Pedido |
| 1044 | Jacob Whitesides 2019 Evento prueba | Procesado | Seguridad | CDMX | Foro Sol | Israel Benavid Solis Carrera | | Pedido |
| 1043 | Futbol América vs Pumas | Procesado | Produccion | CDMX | Oficinas Leibnitz | Gerardo Martinez Morales | Auditorio Nacional, Auditorio Guadalajara y Plazas Similares | Servicio interno |

Nota: columna "PeP\|Descripción" muestra valores tipo `Z-PEP-Temporal PRG`, `LT-AZ-2018-01-01N085LT-A-01-01N085LT-A`, `IT-PD-2018-12-19B085DA-E_pepPrg_1`, etc. — confirma que los PEP temporales llevan prefijo `Z-PEP-`.

## 3. Alta de Pedido — "Información General" (`te_pedido.aspx?INS,0`)

Formulario con enlaces superiores **Agregar Detalle** / **Agregar Factura** (visibles aunque el pedido aún no se guarda) y sección "Información General":

Campos observados, en orden:
1. **Cliente*** — combo editable/autocompletar. Al escribir aparece una lista alfabética larga con decenas de clientes (LiveMed, Logística Organizacional…, Los Publívoros, Luna Guarneros Karina Irene, Magnos Comercialización…, Maguen Team, Make Pro, Mandarina Marketing, Marketing Management México, Marketing y Tendencias, Martínez López Jorge, Mas Volumen, MC Show Business, Mex Tenis, Mint Creative Lab, Mixología B.S., MMS Comunicaciones, MTV Networks de México, Música Esencial, **Ocesa Anfiteatro, S.A. de C.V.**, **OCESA Comercial, S.A. de C.V.**, **Ocesa Presenta, S.A. de C.V.**, **OCESA Promotora, S. A. de C.V.**, …). No está filtrado solo a "Ocesa": el combo lista TODOS los clientes del catálogo, el usuario escribe para buscar. Se seleccionó **"OCESA Promotora, S. A. de C."**.
2. **Id Contacto*** — combo (ninguno) + checkbox lateral **"Agregar contacto"**. Al seleccionar el cliente, la lista de contactos se filtra correctamente a contactos de ese cliente (confirma el punto 3 del guion): `brenda Bueno Higuera, Contacto Nuevo, Diana Weber, Gabriela Flores, Heriberto Reyes Vasquez, Hugo Israel Villanueva Gallardo, Juan Torres Leyva, Lucas Vázquez, Marco Vitale, Mario Villa Vera (x2), Marisol Acelay, Marisol Marquez Pavón, Martín Alcalá Castañeda, Mauricio Alvarez (x3), Miguel Gutierrez Leal, Nestor Villegas Navarro…`. Se seleccionó **"Mario Villa Vera"**.
3. **Id sucursal*** — combo: **`(Ninguno), CDMX, Guadalajara, Monterrey, Otra, Queretaro`**. *(Campo no mencionado en el texto del guion de Escenario 5 — hallazgo nuevo.)* Se seleccionó **CDMX**.
4. **Unidad de negocio*** — combo largo, catálogo alfabético observado (parcial, scrolleado en dos tramos):
   `A Muse, Actividades Deportivas, Administración y Contratación de Talento, Admón y Finanzas, Aldea Digital, Anfitriones, Asdeporte, Atención a Clientes, Calacas Zíngaro, Cavalia, Cirque Du Soleil, Comercial, Control de Accesos, Corona Capital, E-Ticket, Enlace, Estacionamientos, Estadio 3 de Marzo Gdl, Estadio Azul, … Eventos Especiales, Eventos Internacionales, Ferias Populares, Fórmula 1, Juegos Centroamericanos y del Caribe 2014, Juegos Panamericanos 2011, Limpieza, Marketing Monterrey, Mercadotecnia, Modelos y Edecanes, Obras de Teatro, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, OCESA Promotora, **Operaciones Inmuebles**, Operaciones Inmuebles Auditorio Banamex Mty, Operaciones Inmuebles VFG, Plaza Condesa, Premios Oye, Prensa, **PRG**, …`.
   Primera corrida (pedido 1050, pre-existente): **Operaciones Inmuebles**. Corrida grabada (pedido 1051): **PRG**.
5. **Id PEP** — al elegir la UN se autoselecciona/filtra; se eligió **`Z-PEP-Temporal PRG`** (prefijo "Z-PEP-Temporal" confirmado, igual que en guion). Al elegirlo, **Lugar de cita** queda "Sin definir" (confirma el punto del guion: "el sistema por defecto no trae lugar de cita, ni inmueble").
6. **Id evento*** — combo: **`(Ninguno), Feria del Juguete 2017, Futbol América vs Pumas, Jacob Whitesides 2019, Tributo a Michael Jackson`**. Se eligió **Jacob Whitesides 2019**.
7. **Título*** — se autocompleta con el nombre del evento + `---` (p.ej. `Jacob Whitesides 2019---`) y el usuario añade texto libre (terminó en `Jacob Whitesides 2019---Escena[rio5A]`, truncado en pantalla).
8. **Lugar de cita** — combo, inicia en "Sin definir"; tras elegir PEP/evento se puede seleccionar manualmente, p.ej. **"Pepsi Center WTC"** (para 1050: **"Palacio de los Deportes"**).
9. **Dirección lugar** / campo duplicado llamado **"lugar"** (textarea, solo lectura) — se autollena con la dirección completa del sitio elegido, ej. *"Dakota sin num. Col. Napoles, Del. Benito Juarez, Mexico DF cp 03810"*.
10. **Otro** — checkbox.
11. **Tipo de movimiento*** — combo con exactamente **3 valores: `(Ninguno), Pedido, Servicio interno`** (contradice las observaciones de "bug" en otros escenarios del texto que decían que solo se mostraba "Pedido"; aquí el combo sí muestra ambas opciones correctamente). Se seleccionó **Servicio interno**.
12. **Tipo de complejidad*** — aparece **solo si aplica** a la UN. Catálogo completo observado (6 complejidades + "No Aplica" = 7 opciones), confirmando la observación del guion de Escenario 2 ("únicamente 6 complejidades"):
    - Auditorio Nacional, Auditorio Guadalajara y Plazas Similares
    - Estadios Foro y Plazas Similares en el Extranjero
    - Festivales de más de 50,000 asistentes
    - Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares
    - **No Aplica**
    - Palacio de los Deportes, Arena VFG y Plazas Similares
    - Teatro Metropolitan, Plaza Condesa y Plazas Similares
    Valor por defecto al abrir el combo: "Auditorio Nacional, Auditori…" (no es neutro); se cambió explícitamente a **No Aplica**, confirmando el paso 10 del guion ("En complejidad indicar que No Aplica").
13. **Duración del evento (Días de show)** — numérico, quedó en **0** (no se llenó, consistente con "No Aplica" complejidad).
14. **Sociedad pagadora*** — combo, valor visto: **"Operadora de Centros de Es..."** (truncado, probablemente "Operadora de Centros de Espectáculos" o similar) — por default, confirma el bug reportado en Escenario 1/3 del texto ("la sociedad pagadora por default está con ID 10").
15. **Permitir cancelar confirmaciones*** — combo **NO** / SI; se dejó **NO**.
16. **Responsable*** — combo, quedó en **(Ninguno)** en la corrida grabada (en la grilla de pedidos se ve que terminó asignado "Jose Edgar Barrera Diaz" para 1051).
17. Botones finales: **Confirmar** / **Regresar**.

## 4. Alta de Detalle de Pedido (`wp_pedidodetalle.aspx?<id>`)

Formulario "Detalles de pedido", dos columnas:

Columna izquierda:
- **Estatus** (solo lectura) — valor visto: **Vigente**
- **Evento Práctica** — checkbox
- **Tipo personal*** — combo; valor forzado a **Operativo** (resaltado en azul en pantalla, posiblemente única opción al no tener complejidad, confirmando el guion: "Validar que sólo se muestren Operativos al no tener complejidad")
- **Título*** — hereda el título del pedido, editable
- **Producto*** — combo largo de catálogo de productos PRG (ver lista abajo). Se seleccionó **Rigger PRG-IN**.
- **Lugar de Cita*** — combo (hereda del pedido, ej. "Pepsi Center WTC" / "Palacio de los Deportes")
- **Dirección cita** — texto, autollenado
- **Otro** — checkbox
- **Indicaciones especiales** — textarea libre
- **Bloque por producto** — combo, valor por defecto **"Ninguno"**
- **Facturable** — combo **NO** / SI

Columna derecha:
- **Cantidad** (numérico) + **Turnos** (numérico, ej. 1.00) con leyenda dinámica **"12 Horas por turno"** (se confirma que el sistema SÍ muestra la jornada/horas por turno junto al campo Turnos — contradice el "bug" reportado en Escenarios 1-3 del texto donde decía que el sistema no mostraba esta información; aquí si aparece, como texto a la derecha del campo Turnos).
- **Fecha cita*** — selector de fecha (dd/mm/aaaa) + dos combos de hora (HH / MM). Valor usado: **21/08/2019 06:00** (miércoles, el mismo día cancelado en el pedido 1050).
- **Fecha liberación** — selector de fecha + hora. Valor: **16/08/2019 06:00**.
- **Fecha final cita** — selector de fecha + hora, se autocalcula sumando el turno: **21/08/2019 18:00** (06:00 + 12h, consistente con "1 turno de 12 horas").
- **Presentación por producto** — combo, default **(Ninguno)**.
- **Completar con similares** — combo **NO** / SI.
- **Fase del evento** — combo; default **"No aplica"**, luego cambiado a **"Show"**.
- **Permitir cancelar** — combo **NO** / SI.
- Botones: **Agregar Detalle** / **Cancelar**.

### Catálogo de productos PRG (combo "Producto", observado parcialmente al hacer scroll)

```
Asistente Aux A PRG-IN
Asistente Aux B PRG-IN
Asistente Coordinador PRG-IN
Asistente de Produccion A PRG-MA / PRG-FE / PRG-IN
Asistente de Produccion B PRG-MA / PRG-FE / PRG-IN
Asistente de Produccion C PRG-MA / PRG-FE / PRG-IN
Asistente de Produccion D PRG-MA / PRG-FE / PRG-IN
Asistente de Produccion E PRG-MA / PRG-FE / PRG-IN
Asistente de Producción PRG Habitual 12.5-IN
...
Ingeniero de Luces A PRG-MA / PRG-FE / PRG-IN
Ingeniero de Luces B PRG-MA / PRG-FE / PRG-IN
Ingeniero de Luces C PRG-MA / PRG-FE / PRG-IN
Jefe de Bodega Habitual 16.5-IN
Logistica A / B / C / D / E PRG-MA (y variantes -IN)
Operador de Switcher-IN
Pre produccion A / B / C y atencion audio/luz PRG-MA
Rigger PRG-MA
Rigger PRG-FE
Rigger PRG-IN   <- seleccionado (nota: el guion de texto lo escribe "Riger", el nombre real en el sistema es "Rigger")
```
Patrón de sufijos de producto observado en todo el catálogo: **`-MA`** (matutino?), **`-FE`** (fecha evento / foráneo?), **`-IN`** (interno?) — múltiples variantes A/B/C/D/E del mismo puesto para cada sufijo. Vale la pena confirmar con el equipo el significado exacto de estos sufijos para el modelo de datos de PeopleMovil.

## 5. Confirmación por el portal del freelance (captura 001)

Pantalla separada (self-service del trabajador), menú superior: **Comunicados generales | Calendario de eventos | Saldos | Confirmación de eventos | Aclaraciones | Salir**, con el nombre de usuario mostrado como rol **"Freelance"**.
- Sección **"Eventos por confirmar"** (vacía en esta captura)
- Sección **"Eventos confirmados"**: lista de botones azules, cada uno con formato `PUESTO..EVENTO FECHA HORA`, ej.: `ESPECIALISTA ESTRUCTURAS INMUEBLES..Jacob Whitesides 2019 19/08/19 06:00`.

---

## 6. Comparación contra el texto de `ESCENARIOS_PRUEBA_FREELANCE.md` (Hoja "Escenario 5")

| Paso del guion | Confirmado / Contradicho / Detalle nuevo |
|---|---|
| 1-4 Crear pedido, cliente Ocesa, validar contactos, seleccionar evento | **Confirmado.** El combo Cliente no filtra a Ocesa (lista TODO el catálogo), pero el combo Contacto sí filtra correctamente por cliente una vez elegido. |
| 5. UN Operaciones Inmuebles → PEPs + sociedad pagadora | **Confirmado**, y además se ve el bug ya reportado en otros escenarios: sociedad pagadora llega preseleccionada por default (no vacía). |
| 6. PEP Temporal (Z-PEP) sin lugar de cita/inmueble por defecto | **Confirmado literalmente**: `Lugar de cita` queda en "Sin definir" al elegir `Z-PEP-Temporal PRG`. |
| 7. Seleccionar Lugar de Cita | **Confirmado**, combo con catálogo de sitios (Pepsi Center WTC, Palacio de los Deportes, etc.), autollena dirección. |
| 8. Tipo de movimiento muestra Pedido y Servicio Interno | **Confirmado sin bug** en esta corrida: el combo sí tiene las 3 opciones (Ninguno/Pedido/Servicio interno), a diferencia de lo reportado como bug en Escenarios 1-3. |
| 9. Servicio Interno | Confirmado. |
| 10. Complejidad "No Aplica" | **Confirmado**, y se ve el catálogo completo de 6 complejidades + No Aplica (dato nuevo: nombres exactos). |
| 11. Permitir Cancelar = NO | Confirmado. |
| 12. Aceptar → consecutivo de pedido | Confirmado: pedidos 1050 y 1051 correlativos. |
| 13. Tipo de personal solo Operativo | Confirmado (único valor disponible/forzado). |
| Producto: Especialistas Estructuras Inmuebles-IN / Riger | Para 1050 el producto fue "Especialista Estructuras Inmuebles-IN" (confirmado en la Matriz de Puestos). Para el pedido grabado (1051/PRG) el producto es **"Rigger PRG-IN"** — el guion lo escribe mal ("Riger"); el nombre real tiene doble "g". |
| Jornada "1 turno por 12 horas" | **Confirmado, y contradice el bug reportado en Escenarios 1-3**: aquí el sistema SÍ muestra la leyenda "12 Horas por turno" junto al campo Turnos. |
| Fecha de cita = miércoles cancelado | Confirmado: se usó 21/08/2019 (miércoles), la misma fecha que quedó libre tras cancelar el detalle del miércoles en el pedido 1050. |
| Presentación por producto "no se muestran" | Campo visible pero con único valor "(Ninguno)" en las capturas revisadas — consistente con "no hay presentaciones para mostrar". |
| Fase del evento — "Ninguno" vs "No aplica" (bug reportado) | En esta corrida el campo mostró explícitamente **"No aplica"** como valor por default (no "Ninguno"), lo que sugiere que ese bug específico ya fue corregido para cuando se grabó este video. |
| "Forzar la asignación de la persona que confirmó el bloque anterior... el sistema no debe dejar la asignación" | **No capturado**: el video termina (captura 107, 03m59s de 249s) justo después de llenar el detalle del pedido 1051 (producto, fechas, fase "Show"), sin mostrar el intento de forzar asignación ni el mensaje de error esperado. |
| "Realizar la misma prueba cambiando la propiedad del puesto..." (equivalente a "5B") | **No capturado en absoluto** en este set de 107 imágentes. |

---

## 7. Reglas de negocio NUEVAS o detalles no capturados en el texto QA

1. **Campo "Id sucursal"** en el alta de pedido (catálogo: CDMX, Guadalajara, Monterrey, Otra, Queretaro) — no mencionado en el guion de texto de ningún escenario revisado.
2. **Campo duplicado "lugar"** (textarea de solo-lectura con la dirección) además de "Dirección lugar" — posible artefacto de GeneXus (dos controles para el mismo dato).
3. El combo **Cliente** NO filtra por texto/tipo de cliente; muestra el catálogo completo alfabético y el usuario debe buscar escribiendo. Útil para el diseño de UX en PeopleMovil (quizás mejorar con autocomplete real).
4. Catálogo completo de **Tipo de complejidad** (6 + "No Aplica"): Auditorio Nacional/Guadalajara y Plazas Similares; Estadios Foro y Plazas Similares en el Extranjero; Festivales de más de 50,000 asistentes; Foro Sol, Festivales hasta 50,000 asistentes y Plazas Similares; Palacio de los Deportes, Arena VFG y Plazas Similares; Teatro Metropolitan, Plaza Condesa y Plazas Similares.
5. Catálogo parcial de **Unidades de Negocio** — incluye muchas que parecen más bien "eventos/marcas" que UN tradicionales: A Muse, Cirque Du Soleil, Corona Capital, Fórmula 1, Juegos Centroamericanos y del Caribe 2014, Juegos Panamericanos 2011, Premios Oye, Plaza Condesa, OCESA Colombia, OCESA Equipos, OCESA Negocios Digitales, etc. — sugiere que en Lobo "Unidad de Negocio" se usa también para marcas/franquicias de evento, no solo áreas operativas (Seguridad, PRG, Producción, Transportes...).
6. El prefijo de los PEP temporales es literalmente **`Z-PEP-Temporal <UN>`** (ej. `Z-PEP-Temporal PRG`, `Z-PEP-Temporal Operaciones Inmuebles`).
7. El nombre correcto del producto es **"Rigger"** (doble g), no "Riger" como aparece en el guion de texto — corregir en la documentación de catálogo de productos.
8. Sufijos de producto **-MA / -FE / -IN** se repiten sistemáticamente en casi todo el catálogo de PRG (cada puesto tiene hasta 3 variantes) — confirmar significado exacto para el esquema de catálogo de productos en PeopleMovil.
9. Estatus de pedido observados en la grilla: **Vigente, Liberado, Cancelado, Procesado** (más "Normal"/"Ninguno" mencionados como bug en otros escenarios del texto) — útil como enum candidato para `estado_pedido`.
10. Título del pedido se autogenera como `<Nombre del Evento>---` y el usuario anexa texto libre (en este caso anexó literalmente el identificador del escenario de prueba, "Escenario5A"), evidenciando que el campo "Título" se usaba informalmente por QA para marcar/trazar sus casos de prueba dentro del propio sistema.
11. El campo **Turnos** sí muestra dinámicamente la duración del turno del producto seleccionado (p.ej. "12 Horas por turno") junto al campo — en esta build el bug "no muestra información de turnos" reportado repetidamente en Escenarios 1-3 del texto parece resuelto.
12. **Gap de evidencia**: el desenlace de "Escenario 5A" (bloqueo de la asignación forzada) y la totalidad de "Escenario 5B" (repetir permitiendo la asignación) no están cubiertos por estas 107 capturas — el video se corta ~10s antes de su duración total (239s de 249s), justo tras completar el formulario de detalle sin haberlo guardado ni haber intentado la asignación forzada.
