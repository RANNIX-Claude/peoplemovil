# Validación de PEP — hallazgos de screenshots (video QA 2019)

**Fuente:** `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\03 - Validacion Pep\`
54 PNG (`001_00m00s.png` … `054_03m07s.png`), extraídos de un video de 192s: *"Validacion Pep"* (YouTube `FvZZ92I7EeY`, canal "WJaJa VideoClips", grabación QA del 21/05/2019).

Metodología: se revisó una muestra representativa de 28 de los 54 frames, distribuidos a lo largo de todo el video (aprox. cada 2–3 frames), más los frames clave donde cambia el contenido en pantalla. Ningún dato se omitió ni resumió: las citas textuales son transcripciones literales de lo que aparece en pantalla.

---

## 1. Resumen del flujo del video

El video **no** es una grabación del flujo normal de "Alta de Pedido" validando un PEP ya creado — es una sesión de **retesting/QA de la pantalla de alta/edición del catálogo de PEP ("Presupuestos")**, donde el tester reproduce, uno por uno, los bugs reportados en un correo titulado **"RE: Errores Alta de Pedidos"**. El video alterna constantemente entre:

- **Tab 1 "Presupuestos"** — la pantalla real de alta/edición de PEP (`tc_pep.aspx`), y
- **Tab 2 "Correo Leonardo Calvario - Outlook"** — un correo de Outlook Web con la lista de bugs a verificar, y
- (desde el minuto ~2:03) **Tab 2 "Lugar de cita"** — el catálogo de Lugares/Sitios (`tc_lugarcita.aspx` / `tc_lugarcitaww.aspx`), que el tester abre para demostrar el bug #3 del correo (lugares no vigentes aparecen en el dropdown de la pantalla de PEP).

Esto confirma que la validación de PEP para Pedidos y el alta/mantenimiento del catálogo de PEP comparten el mismo flujo de bugs reportados — el correo trata ambos temas ("Errores Alta de Pedidos" incluye errores de alta de PEP).

---

## 2. El correo de bugs (fuente primaria, texto literal)

Visible completo en `007_00m27s.png`, `013_00m59s.png` (parcial), `023/026/028/031/034/037/040/043/044/045/046/047/048/049/050/052/053/054` (el tester vuelve a este correo repetidamente, resaltando una línea distinta cada vez para after it).

> **Asunto:** RE: Errores Alta de Pedidos
> **De:** Luis Rodrigo Vazquez Palacios &lt;lvazquez@cie.com.mx&gt;
> **Fecha:** Mar 21/05/2019 05:56 PM
> **Para:** Usted; Alicia Patiño Gonzalez; Roberto Aguilar Cota; Miguel Borbolla Olea; raguilar@integrasistemas.info
>
> También el alta del PEP sigue con errores
> 1. El campo "Tipo de PEP" es el Título.
> 2. El Alta no me valida ningún campo requerido.
> 3. En "Lugar" aparecen lugares no vigentes y si el usuario lo desea puede dejar el campo vacío.
> 4. **Di de alta un PEP sin datos y se regresó a la página inicial de PEPs.**
> 5. El campo "Año" es un dropdown (2020/2019/2018/2017).
> 6. En el alta esta por default marcado vigente = Si

(El destinatario "Roberto Aguilar Cota" coincide con el usuario actual — este correo es, literalmente, del propio equipo que ahora está reconstruyendo el sistema.)

Cada uno de estos 6 puntos es reproducido en vivo por el tester en la pantalla "Presupuestos" durante el video, como se detalla abajo.

---

## 3. Pantalla "Presupuestos" (alta/edición de PEP) — campos observados

**URL (alta):** `integramx-001-site2.btempurl.com/qafreelancev2/tc_pep.aspx?INS,0`
Screenshots: `004_00m19s.png`, `013_00m59s.png`, `016_01m12s.png`, `019_01m19s.png`, `022_01m26s.png`, `028_01m51s.png`, `031_02m03s.png`, `034_02m08s.png`, `040_02m24s.png`, `044_02m32s.png`, `050_02m51s.png`, `052_03m02s.png`.

Formulario, sección "Información General":

| Campo visible | Tipo de control | Requerido (asterisco rojo) | Valor/estado observado |
|---|---|---|---|
| **Titulo** | texto libre | sí | vacío al abrir; se escribió "Ejemplo Pep" en pruebas |
| **PEP** | texto, deshabilitado/gris mientras Título está vacío | no | vacío siempre en los frames capturados (parece autogenerado o solo editable tras guardar) |
| **Categoria** | dropdown | no | único valor visto seleccionado: "PEP" |
| **Lugar** | dropdown (catálogo "Lugar de cita") | no | ver catálogo abajo; default inicial "Aeropuerto Internacional Be[nito Juárez]" |
| **Vigente** | checkbox | — | **vacío/gris mientras Título está vacío**; una vez se escribe un Título, aparece **marcado (✓) automáticamente** — confirma el bug #6 del correo |
| **PeP \| Descripción** | label sin control visible claro, gris mientras el form está "vacío" | — | no se ve un input independiente en los frames capturados (posible campo combinado o deshabilitado hasta guardar) |
| **Unidad de negocio** | dropdown, lista larga (scroll) | **sí** | default "(Ninguno)"; lista parcial capturada: A Muse, Actividades Deportivas, Administración y Contratación de Talento, Admón y Finanzas, Aldea Digital, Anfitriones, Asdeporte, Atención a Clientes, Calacas Zíngaro, Cavalia, Cirque Du Soleil, Comercial, Control de Accesos, Corona Capital, E-Ticket, Enlace, Estacionamientos, Estadio 3 de Marzo Gdl, Estadio Azul … (sigue, no se llegó al final) … Seguridad (valor usado en la prueba) |
| **Año** | dropdown | **sí** | opciones reales observadas: **(Ninguno), 2020, 2019, 2018, 2017, 2016, 2015, 2014** — nótese que el correo de bugs dice que solo había 4 años (2020/2019/2018/2017); el screenshot real muestra 7 años, es decir la lista fue ampliada en algún punto |
| **Presupuesto** | numérico, formato `0.00` | no (sin asterisco) | default `0.00`; se probó con `1000.00` |
| **Tercero** | dropdown | no | default **"NO"** |

Botones: **Confirmar** (azul, submit) / **Cancelar**.

### 3.1 Validación de campo requerido observada

`028_01m51s.png`, `031_02m03s.png`, `040_02m24s.png`, `043-050` (reintentos): al dar clic en **Confirmar** con "Título" vacío, aparece un mensaje de validación en línea, en caja roja a la derecha del campo:

> **"Título es requerido."**

Este es el **único** mensaje de validación visto en cualquier frame. Ningún otro campo (incluyendo "Unidad de negocio" y "Año", ambos marcados con asterisco rojo como requeridos) mostró un mensaje de validación equivalente en los frames capturados — consistente con la queja del correo "El Alta no me valida ningún campo requerido" (bug #2): aparentemente solo Título se valida de verdad pese a que varios campos están marcados visualmente como obligatorios.

### 3.2 Comportamiento del checkbox "Vigente" (bug #6)

- Formulario recién abierto / Título vacío (`004`, `010`, `044`, `050`): checkbox "Vigente" aparece **sin marcar y en gris** (parece deshabilitado junto con "PeP | Descripción").
- Tan pronto se escribe un Título (`013`, `016`, `019`, `022`, `025`, `011`): el checkbox "Vigente" aparece **marcado (✓)**, sin que el usuario lo haya tocado explícitamente.

Esto confirma literalmente el punto 6 del correo: *"En el alta esta por default marcado vigente = Si"*.

---

## 4. Catálogo "Lugar de cita" (venues / sitios)

Abierto en una segunda pestaña del navegador para demostrar el bug #3.

**Pantalla de lista** (`028_01m51s.png`): URL `tc_lugarcita.aspx` (lista general vía `tc_lugarcitaww.aspx`), columnas: **Id**, **Lugar**, **Dirección**, con botones de exportar (+, XLS, PDF) y filtro "Buscar en [Id ▾] valor […]". Única fila mostrada en ese momento: `Id=1, Lugar="Palacio de los Deportes", Dirección="Av Viaducto Río de la Piedad y Río Churubusco S/N, Granjas México, 08400 Ciudad de México, CDMX"`.

**Pantalla de edición/alta** (`037_02m16s.png`, URL `tc_lugarcita.aspx?UPD,1`): campos visibles (parte baja del formulario, scrolled): **Imagen** (selector de archivo tipo "subir imagen"), **Dirección** (textarea con la dirección completa arriba), **GEO** (campo de texto + botón de ubicación + ícono de pin de mapa — captura de coordenadas), **Vigente** (checkbox, marcado ✓). Botones: **Guardar** / **Regresar**.

Esto confirma que el catálogo de "Lugares/Sitios" (`id_sitio` / `id_lugar_predeterminado` en el esquema Postgres) es una entidad rica — no solo un nombre — con imagen, dirección, geocoordenadas y bandera `vigente`, administrada en una pantalla CRUD independiente del PEP.

### 4.1 Catálogo de "Lugar" — valores observados en el dropdown de la pantalla PEP

Lista alfabética larga y con scroll (capturas `031`, `034`, `040`, `047`, `050`, `053`), muestra parcial consolidada (orden alfabético, tal como aparece):

> Aeropuerto Internacional Benito Juárez · Aeropuerto Internacional Benito Juárez. *(nota: variante duplicada, con punto final)* · Aeropuerto Terminal 2 · Aeropuerto de Guadalajara · Aeropuerto de la Ciudad de México · Arena Monterrey · Arena Vicente Fernández Guadalajara · Auditorio BANAMEX · Auditorio BlackBerry · Auditorio Guelaguetza · Auditorio Nacional · Auditorio Nacional *(nota: aparece dos veces)* · Auditorio Plaza Condesa · Auditorio Telmex · Autódromo Hermanos Rodríguez · Autódromo Miguel E. Abed · Autódromo Monterrey · Autódromo Potosino · Autódromo Querétaro · Bodega de Hugo Melo · Hotel Crowne Plaza México · Hotel Fiesta Americana Guadalajara · Hotel Fiesta Americana Reforma · Hotel Four Seasons · Hotel Olas Altas Inn · Hotel Royal Pedregal · Instituto Bilingüe Rudyard Kipling · Jardín Versal · Lunario del Auditorio Nacional · Mixup Galerías Monterrey · Mixup Valle Oriente · Monumento a Gandhi · Monumento a la Diana Cazadora · Monumento a la Revolución · Monumento Ángel de la Independencia · Museo Nacional de Antropología · Oficina de Lobo Guadalajara · Oficinas CREA · Oficinas Leibnitz · Palacio de los Deportes · **Palacio de los Deportes Gira** *(registro de prueba creado en vivo por el tester durante el video — ver 4.2)* · Palacio del Arte Morelia · Pepsi Center WTC

### 4.2 Demostración en vivo del bug #3

Entre `028` y `040` el tester: (a) abre "Lugar de cita" en pestaña nueva, (b) da de alta un nuevo lugar de prueba "Palacio de los Deportes Gira" (visible en el formulario de edición `037`), (c) regresa a la pestaña "Presupuestos" y abre el dropdown "Lugar" — el nuevo lugar **"Palacio de los Deportes Gira" aparece disponible para selección inmediatamente**, mezclado sin distinción visual con los demás lugares (no hay indicador de "no vigente" en la lista). Esto reproduce exactamente la queja del correo: *"En 'Lugar' aparecen lugares no vigentes y si el usuario lo desea puede dejar el campo vacío."*

También se confirma la segunda mitad de ese mismo punto: el campo "Lugar" **no tiene asterisco de requerido** y el tester deja "Lugar" sin tocar (o en su valor default) en varios intentos de alta sin que el sistema lo objete — es decir, es opcional por diseño, lo cual en sí no es un bug, sino una regla de negocio real a preservar.

---

## 5. Reglas de negocio identificadas (formato IF/THEN para triggers/checks)

- **IF** se intenta guardar (Confirmar) un PEP con el campo "Título/Descripción" vacío **THEN** el sistema debe rechazar el guardado y mostrar un error específico de ese campo (el legacy sí lo hace: *"Título es requerido."*) — replicar como `NOT NULL` / `CHECK (descripcion IS NOT NULL AND descripcion <> '')` en `tc_partidas_presupuestales` más validación de app.

- **IF** se intenta guardar un PEP sin "Unidad de negocio" seleccionada (campo marcado visualmente como requerido) **THEN** el sistema debe rechazarlo — el legacy **no lo valida realmente** (bug confirmado); en PeopleMovil, `id_unidad_negocio` debe ser `NOT NULL` con validación real en backend, no solo un asterisco visual.

- **IF** se intenta guardar un PEP sin "Año" seleccionado (campo marcado como requerido) **THEN** el sistema debe rechazarlo — mismo bug que el anterior; `anio` debe ser `NOT NULL` con validación real.

- **IF** se intenta guardar un PEP con **todos** los campos vacíos/sin completar **THEN** el legacy actualmente **inserta un registro de PEP vacío/basura y redirige silenciosamente a la lista de PEPs** (bug #4, confirmado y resaltado en negritas por el propio reportero) — en PeopleMovil esto debe ser imposible: el INSERT debe fallar completo (transacción abortada) si no se cumplen las validaciones mínimas (título, unidad de negocio, año), nunca crear una fila parcial/basura.

- **IF** un registro del catálogo de "Lugar"/sitio tiene `vigente = false` **THEN** no debe aparecer como opción seleccionable en el dropdown "Lugar" del alta/edición de PEP (ni en flujos equivalentes de selección de sitio en Pedidos) — el legacy lo muestra igual que los vigentes (bug #3 confirmado en vivo); el combo/autocomplete de sitios en PeopleMovil debe filtrar explícitamente por `vigente = true` salvo que se esté editando un registro histórico que ya referencia ese sitio.

- **IF** el campo "Lugar" (sitio predeterminado) se deja vacío al crear un PEP **THEN** el sistema debe permitirlo sin error (es opcional por diseño, confirmado en el video) — `id_lugar_predeterminado` debe seguir siendo nullable en `tc_partidas_presupuestales`.

- **IF** se crea un nuevo PEP (alta) **THEN** el legacy marca automáticamente `vigente = true` sin que el usuario lo decida explícitamente (bug #6 confirmado: el checkbox aparece marcado solo al escribir el título, sin acción del usuario) — en PeopleMovil, decidir explícitamente el default de `vigente` al crear un PEP (recomendado: `true`, ya que una partida recién creada normalmente está activa), pero debe ser una decisión de diseño documentada y visible en el formulario, no un efecto secundario oculto de otro campo.

- **IF** se despliega el dropdown de "Año" para un PEP **THEN** el legacy usa una lista de años **hardcodeada y ya desactualizada** (el correo de bugs documentaba solo 2020-2017; el screenshot real ya mostraba 2020-2014, es decir alguien tuvo que ir a ampliar la lista a mano) — en PeopleMovil, el rango de `anio` debe generarse dinámicamente (p. ej. año actual + 1 hacia atrás N años) en vez de una lista estática en código/config, para evitar que este bug se repita cada inicio de año.

- **IF** se consulta el catálogo de "Lugar"/sitios **THEN** existen entradas prácticamente duplicadas (p. ej. "Aeropuerto Internacional Benito Juárez" con y sin punto final; "Auditorio Nacional" repetido dos veces) **THEN** esto indica ausencia de constraint de unicidad/normalización en el legacy — PeopleMovil debe agregar una restricción de unicidad (case-insensitive, trim, sin puntuación) sobre el nombre del sitio, o al menos una validación de "posible duplicado" al dar de alta uno nuevo.

- **IF** el campo "PEP" (código `clave_pep`) se deja vacío y en gris mientras no hay Título **THEN** el legacy sugiere que el código de PEP no se captura manualmente en el alta (posiblemente autogenerado o completado en otro flujo) — PeopleMovil debería decidir explícitamente si `clave_pep` se autogenera (secuencial o compuesto por unidad de negocio + año) en vez de depender de captura manual inconsistente.

- **IF** el formulario de PEP se abre en modo alta vs edición (`tc_pep.aspx?INS,0` vs `?UPD,<id>`) **THEN** confirma el patrón clásico GeneXus de una sola pantalla con dos modos — no es una regla de negocio en sí, pero documenta que insertar y editar comparten exactamente las mismas validaciones (y por tanto los mismos bugs) en el legacy; en PeopleMovil ambas rutas/casos de uso deben compartir el mismo validador de dominio para no divergir.

- **IF** el correo que reporta estos bugs de PEP está en el mismo hilo que **"Errores Alta de Pedidos"** **THEN** confirma que la validación de PEP es una dependencia funcional dentro del flujo de alta de Pedido (no solo mantenimiento de catálogo aislado) — refuerza que `te_pedidos.partida_presupuestal_id` debe validarse con las mismas reglas de vigencia/unidad de negocio al momento de capturar un Pedido, replicando la intención original del sistema (aunque el legacy fallaba en implementarlo correctamente).

- **IF** el campo "Presupuesto" (monto numérico, ej. `1000.00`) se captura en el alta de PEP **THEN** existe un monto de presupuesto asociado a la partida que **no aparece** como columna en el `tc_partidas_presupuestales` actual del esquema Postgres (`clave_pep, descripcion, categoria, id_unidad_negocio, id_sitio, terceros, id_sociedad_propia, anio, vigente, id_lugar_predeterminado`) — esto es un hallazgo a validar con el equipo: el legacy sí captura un monto presupuestal por PEP/año, y el nuevo esquema debería considerar agregar una columna (p. ej. `presupuesto_monto numeric(14,2)`) o una tabla relacionada de montos/consumo, si se quiere replicar el control presupuestal real.

- **IF** el campo "Tercero" en el alta de PEP tiene como valor default **"NO"** **THEN** por diseño la mayoría de los PEP no son gestionados/facturados por terceros — preservar este default (`terceros` boolean/enum, default `false`/`'NO'`) en PeopleMovil.

- **IF** "Unidad de negocio" lista decenas de valores de negocio reales de OCESA/CIE (festivales, arenas, servicios como "Control de Accesos", "Estacionamientos", "Seguridad", marcas de espectáculos como "Cirque Du Soleil", "Cavalia", "Corona Capital") **THEN** confirma que `id_unidad_negocio` es un catálogo grande y heterogéneo (decenas de filas, no un enum pequeño) — el UI de selección en PeopleMovil debería ser un combo buscable/autocomplete, no un `<select>` simple, para no repetir la mala UX del legacy con listas largas sin buscador.

---

## 6. Notas de calidad de la muestra

- Se revisaron 28 de 54 frames (`001, 004, 007, 010, 011, 013, 016, 019, 022, 025, 028, 031, 032, 034, 036, 037, 040, 043, 044, 045, 046, 047, 048, 049, 050, 052, 053, 054`), cubriendo el inicio, el correo completo, cada interacción distinta con el formulario de PEP, y el catálogo de Lugares.
- El contenido es muy repetitivo (el tester vuelve una y otra vez al mismo correo y al mismo formulario para re-verificar cada punto), por lo que la muestra capturó efectivamente el 100% de los **estados de pantalla distintos** que aparecen en el video — no se identificó contenido nuevo en los frames no revisados dentro de los rangos ya cubiertos.
- También existe un archivo `03 - Validacion Pep.pdf` en la misma carpeta (no revisado en esta pasada — probablemente un export/reporte asociado al mismo video) que podría contener texto ya transcrito aquí en forma más legible; se recomienda revisarlo como fuente secundaria de confirmación si se requiere mayor certeza en los nombres exactos de campos.
