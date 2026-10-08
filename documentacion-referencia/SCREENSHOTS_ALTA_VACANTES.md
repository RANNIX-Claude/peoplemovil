# Hallazgos: Screenshots "Alta Vacantes" (video QA 2019)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios  video escvenarios de pruebas de pruebas\02 - Alta Vacantes\`
(100 PNG, `001_00m00s.png` ... `100_05m07s.png`). Fecha de la grabación visible en la barra de tareas de Windows: **17/05/2019**.

Sistema: GeneXus Web app, pantalla **"Perfil de puesto"** (módulo RRHH > Recursos humanos > Vacantes). URL base:
`integramx-001-site2.btempurl.com/qafreelancev1/te_vacante...aspx` (nombre de objeto GeneXus: `te_vacante` / listado `te_vacanteww`).

Muestra revisada (~26 frames, distribuidos a lo largo de todo el video, frames: 001, 002, 004, 005, 006, 007, 008, 009, 011, 012, 013, 014, 015, 016, 017, 018, 021, 022, 024, 025, 029, 033, 037, 041, 045, 049, 053, 057, 061, 065, 069, 073, 077, 081, 085, 089, 091, 093, 095, 096, 097, 100).

---

## 1. Navegación / menú (contexto, no es el formulario en sí)

Barra superior azul, de izquierda a derecha: logo "RRHI" (RRHH), menús **Recursos humanos**, **Operaciones**, **Nómina**, **Catálogos**, **Seguridad sistema**, y a la derecha **Salir** + ícono de usuario.
(frame `001_00m00s.png`)

Submenú de **Recursos humanos** (frame `002_00m01s.png`):
- Cartera de talento
- Base de candidatos
- Vacantes ▸ (submenú, de aquí se llega a esta pantalla)
- Folios
- Requisición de personal
- Proceso de Reclutamiento ▸ (submenú)

---

## 2. Pantalla de LISTADO ("Perfil de puesto" — grid, modo Work-With)

URL: `te_vacanteww.aspx` o `te_vacante.aspx` sin query string. (frames `001`, `007`, `029`, `049`, `057`, `065`, `096`, etc.)

### 2.1 Barra de herramientas (sobre el grid)
- Ícono **"+"** = botón **Agregar** (tooltip visible "Agregar" en frame `006_00m16s.png`) → abre el formulario de alta.
- Ícono **XLS** (verde) = **Exportar a Excel** (tooltip "Exportar a Excel" visible en frame `005_00m12s.png` mientras carga).
- Ícono **PDF** (rojo) = exportar a PDF.
- Filtro de búsqueda, a la derecha:
  - Ícono de embudo (filtro avanzado, no se exploró su contenido desplegado).
  - Label **"Buscar en"** + combo con el campo a buscar (por defecto: **"Nombre de vacante"**, presumiblemente permite elegir cualquier columna).
  - Label **"valor"** + combo de operador (por defecto: **"Comienza con"**).
  - Textbox vacío para el valor de búsqueda.
  - Ícono circular con "x" = limpiar filtro.

### 2.2 Columnas del grid
| Columna | Tipo visual | Notas |
|---|---|---|
| (3 íconos por fila, sin encabezado) | lupa / lápiz / "x" | Ver detalle / Editar / Eliminar por registro |
| Vacante | número, con flecha de orden ascendente | ID autonumérico, es el PK |
| Nombre de vacante | texto, con flecha de orden | ej. "Seguridad Nocturna", "Chef para evento" |
| Puesto | texto, con flecha de orden | catálogo genérico (ver sección 4) |
| Experiencia laboral | checkbox (solo lectura) | tilde azul si aplica |
| Requiere inglés | checkbox (solo lectura) | tilde azul si aplica |
| Código de acceso | texto/alfanumérico | ej. "2sem", "1234", "QRTS", "9878", "ABC" — puede estar vacío (fila 23 "Seguridad palacio") |
| Examen psicométrico | **hipervínculo** (URL) | ej. www.examen.com, www.examen.com/pruebas, www.examen.com/psicologico, www.examen.com/stagehand, www.direccion3a.com — puede estar vacío |

Pie de página: **"Página 1 de 1"**, botones **"Ant"** / **"1"** (página activa) / **"Sig"**.

### 2.3 Datos de ejemplo visibles en el grid (fila = Vacante #, Nombre de vacante — Puesto)
1. Seguridad Nocturna — Seguridad (Exp. ✓, Inglés ✓, código 2sem, examen www.google.com)
2. Local Crew nocturno — Local Crew (Exp. ✓, Inglés ✓, código 1234, examen www.examen.com/pruebas)
3. Chef para evento — Chef (código 2323, examen www.examen.com/psicologico)
4. Stage Hand para evento — Stage Hand (código QRTS, examen www.examen.com/stagehand)
5. Analista capacitador — Seguridad (Exp. ✓, código 123)
6. Personal de taquilla — Taquillas (código 123)
7. Personal para control de accesos — Seguridad (código 1234)
8. Meseros para Luis Miguel Tour VIP — Local Crew (código 123) *(nombre de vacante ligado a gira/evento específico)*
9. Asistente de luces — Stage Hand (código 9878)
10. Seguridad de accesos — Seguridad (código 123)
11. Locutor de evento — Locutor (Exp. ✓, código 9378, examen http://examen.com)
14. Taquilleros para Playa Limbo — Taquillas (Exp. ✓, Inglés ✓, código 3421, examen http://www.examen.com.mx) *(evento "Playa Limbo")*
15. Taquillas Chayanne — Taquillas (código 123) *(ligado a artista "Chayanne")*
16. LOCAL CREW — Local Crew (código 56565, examen www.google.com)
17. Head Rigger — Head Rigger (código 0089, examen http://www.examen.com)
18. Prueba Perfil Puesto Seguridad — Seguridad (Exp. ✓, Inglés ✓, código 1234)
19. Local Crew F1 2019 — Local Crew (Exp. ✓, Inglés ✓, código ABC) *(ligado a "F1" = Fórmula 1)*
20. Seguridad General — Seguridad (Exp. ✓, código 2sem, examen www.direccion3a.com)
23. Seguridad palacio — **Scar** (sin código ni examen) *(nota: el "Puesto" asociado es "Scar", inconsistente/llamativo — posible dato de prueba erróneo)*
24. Staff Cirque Du Solei — Seguridad (código 2sem, examen www.direccion3a.com) *("Cirque Du Soleil", typo en captura original)*
27. Seguridad estadio azteca — Seguridad (código 2sem, examen www.direccion3a.com) *(registro creado durante esta grabación, ver sección 3)*

**Nota importante:** los números de Vacante **saltan** (faltan 12, 13, 21, 22, 25, 26) — evidencia de que esos registros fueron **eliminados** durante la sesión de pruebas y el ID autonumérico **no se reutiliza**.

### 2.4 Exportación a Excel (frames `096_04m57s.png`, `097_04m59s.png`, `100_05m07s.png`)
Archivo generado: **"TE_VacanteWWExport-3553"** (xls), abre en Excel con banner **"VISTA PROTEGIDA"** ("Tenga cuidado: los archivos de Internet pueden contener virus...", botón "Habilitar edición").
Columnas de la hoja (fila de encabezado = fila 3 de la hoja, hay 2 filas en blanco arriba):
`Vacante | Nombre de vacante | Puesto | Experiencia laboral | Requiere inglés | Código de acceso | Examen psicométrico`
Los checkboxes se exportan como texto **`true` / `false`** (no como ✓/vacío).

---

## 3. Formulario de ALTA / EDICIÓN ("Perfil de puesto" — detalle)

### 3.1 Modo alta (INS) — URL `te_vacante.aspx?INS.0`
Frame `007_00m20s.png` (formulario recién abierto, vacío) — **no** tiene el encabezado azul "Información General" (ese aparece solo en modo edición, ver 3.2).

### 3.2 Modo edición (UPD) — URL `te_vacante.aspx?UPD.27`
Frame `021_01m07s.png` en adelante muestra una franja de título azul **"Información General"** sobre el formulario, que no está presente en modo alta pura.

### 3.3 Campos del formulario (orden de aparición, columna izquierda y derecha)

| Campo (label exacto) | Obligatorio (*) | Tipo de control | Notas / valores de ejemplo |
|---|---|---|---|
| **Nombre de vacante** | Sí (*) | textbox de una línea | ej. "Seguridad estadio azteca" |
| **Funciones** | Sí (*) | textarea multilínea | descripción de funciones del puesto |
| **Id puesto** | Sí (*) | combo/dropdown (catálogo largo, scrollable) | placeholder inicial **"cero"**; ver catálogo completo en sección 4 |
| **Requisitos** | Sí (*) | textarea multilínea | requisitos del puesto |
| **Imagen** | No | control de carga de imagen (ver 3.4) | thumbnail con ícono "+" de placeholder si está vacío |
| **Código de acceso** | No | textbox de una línea | ej. "2sem" — código que probablemente usan los candidatos para postularse/acceder |
| **Examen psicométrico** | No | textbox de una línea (acepta URL) | ej. "www.direccion3a.com" — se muestra como link en el grid |
| **Requiere inglés** | No | checkbox | |
| **Experiencia laboral** | No | checkbox | |

Botones de acción (parte inferior del formulario): **"Confirmar"** (azul, primario) y **"Cancelar"** (blanco/outline).

### 3.4 Control de Imagen — modal de carga (frames `029_01m52s.png`, `033_02m08s.png`, `073_03m32s.png`, `077_03m43s.png`)
Al hacer clic en el thumbnail de Imagen se abre un modal (sin título visible) con:
- Radio button **"Subir archivo"** (seleccionado por defecto)
- Radio button **"Dirección web (URL)"** (alternativa — permite usar una URL externa en vez de subir el archivo)
- Botón **"Seleccionar archivo"** + texto **"Ningún archivo seleccionado"**
- Botón **"Confirmar"** (azul)
- Al pulsar "Seleccionar archivo" se abre el diálogo estándar de Windows "Abrir" apuntando a la carpeta Documentos del usuario de pruebas (archivos vistos: anuncio02.bmp, giphy.gif, anuncio02.jpg, dia_cancelacion.jpg, GL.jpg).
- Una vez subida la imagen, el thumbnail muestra un overlay con el link **"Modificar"** (lápiz) y un ícono de basura (eliminar) al pasar el mouse por encima (frames `057_03m03s.png`, `085_04m14s.png`).

---

## 4. Catálogo "Id puesto" (combo de puesto genérico)

Es una lista larga, en apariencia ordenada alfabéticamente, con muchísimas entradas **específicas por artista/gira/evento**, no solo roles genéricos. Fragmento observado (orden alfabético, alrededor de la letra R-S), frames `009`, `013`, `014`, `016`, `017`, `018`, `022`:

```
Road Manager Eventos Especiales
Road Manager Kumbia All Starz
Road Manager La Nueva Banda Timbiriche
Road Manager Massapan
Road Manager Molotov
Road Manager Nigga
Road Manager Reventour
Road Manager Yak
Runner
Runner con coche
Runner con Coche A Muse
Runner con coche Cavalia
Runner con Coche CDS
Runner con Coche Circo
Runner con coche CZ
Runner con coche PRG
Runner sin coche
Ruta de Camiones F1
Salvavidas
Scar
Segidorista PRG   (posible typo de "Seguidorista PRG")
Seguidorista
Seguidorista 1 Función
Seguidorista 2 Funciones
Seguidorista CDS
Seguidorista Circo
Seguridad
Seguridad Coordinador
Seguridad Coordinador Mty
```

Otros valores de "Puesto" vistos en el grid (sección 2.3): Local Crew, Chef, Stage Hand, Taquillas, Locutor, Head Rigger.

**Hallazgo relevante:** el catálogo de "puesto" no es una lista genérica de roles (seguridad, chef, etc.) sino que incluye variantes **atadas a artistas/giras/clientes concretos** (Muse, Cavalia, Kumbia All Starz, La Nueva Banda Timbiriche, Massapan, Molotov, Reventour, Yak, F1/Fórmula 1, Circo). Esto sugiere que en el sistema legado el catálogo de puestos se infla con una entrada nueva por cada evento/cliente en vez de usar un rol genérico + referencia al evento. Es una señal fuerte de diseño a mejorar en PeopleMovil (normalizar puesto genérico vs. evento/cliente como entidades separadas).

El combo permite tipeo rápido para saltar en la lista (se ve el resaltado azul moviéndose según la letra tecleada, ej. saltando a "Seguidorista" al escribir "S").

---

## 5. Flujo general observado

1. Usuario entra a **Recursos humanos > Vacantes** → pantalla listado "Perfil de puesto" (grid).
2. Pulsa **"+" (Agregar)** → formulario en blanco, modo alta (`INS.0`), sin encabezado "Información General".
3. Llena **Nombre de vacante**, **Funciones**, **Requisitos** (campos obligatorios de texto), selecciona **Id puesto** del catálogo (obligatorio, inicia en "cero").
4. Opcionalmente sube **Imagen** (modal con subir archivo o URL), llena **Código de acceso**, **Examen psicométrico**, marca **Requiere inglés** / **Experiencia laboral**.
5. Pulsa **Confirmar** → vuelve al listado, el nuevo registro aparece con el siguiente ID autonumérico disponible.
6. Desde el listado puede **ver/editar** (ícono lápiz) un registro existente → entra en modo edición (`UPD.<id>`), ahora sí con el encabezado "Información General"; puede modificar la imagen (aparece link "Modificar").
7. Puede **eliminar** registros (ícono "x" en el grid) — confirmado indirectamente por los huecos en la numeración de "Vacante".
8. Puede **exportar** el listado completo a Excel o PDF, y **filtrar/buscar** por cualquier columna usando "Buscar en" + operador + valor.

No se observaron mensajes de validación de error (p. ej. al dejar vacío un campo obligatorio) en los frames muestreados — los asteriscos rojos son la única señal de obligatoriedad visible.

---

## 6. Reglas de negocio / comportamientos a resaltar

1. **Campos obligatorios**: Nombre de vacante, Funciones, Requisitos, Id puesto (marcados con asterisco rojo). Imagen, Código de acceso, Examen psicométrico, Requiere inglés y Experiencia laboral son opcionales.
2. **Id puesto** no tiene valor vacío real — el placeholder al crear es el texto **"cero"**, no un combo realmente vacío; hay que seleccionar explícitamente un valor del catálogo.
3. El listado **no reutiliza IDs** tras eliminar un registro (autonumérico puro, no reindexado) — confirmado por los huecos 12,13,21,22,25,26 en la columna "Vacante".
4. El formulario cambia de apariencia entre **alta** (sin franja "Información General") y **edición** (con franja "Información General") aunque los campos sean idénticos — posible artefacto de la generación GeneXus (panel de inserción vs. panel de actualización) más que una regla de negocio intencional.
5. **Imagen** admite dos orígenes: archivo subido desde disco o una URL externa ("Dirección web (URL)") — no está limitado a upload.
6. El campo **Examen psicométrico** es, en la práctica, una URL libre hacia un sitio externo de evaluación psicométrica (no hay integración embebida, es solo un link).
7. El campo **Código de acceso** parece funcionar como una clave que el candidato usaría para acceder/aplicar a esa vacante específica (valor corto alfanumérico tipo "2sem", "1234", "QRTS").
8. El catálogo de "Id puesto" mezcla roles genéricos con variantes específicas por artista/gira/cliente, lo que en la práctica vuelve el catálogo enorme y poco reutilizable — relevante para el diseño de PeopleMovil (separar Rol genérico de Evento/Cliente).
9. El grid soporta exportación (Excel/PDF), búsqueda por columna con operador tipo "Comienza con", y paginación (aunque con pocos registros muestra "Página 1 de 1").
