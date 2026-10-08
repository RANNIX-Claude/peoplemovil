# Walkthrough de pantallas — Escenario 18: Lista Negra

> Fuente: `27 - P20190319 _0000 Escenario 18 Lista Negra\` (92 PNGs). Esta carpeta no incluye `info.json` ni PDF resumen (a diferencia de las carpetas 25 y 26).

Muestra revisada: ~25 imágenes distribuidas uniformemente (001, 005, 009, 013, 017, 021, 025, 029, 033, 037, 041, 045, 049, 053, 057, 061, 065, 069, 073, 077, 078, 080, 081, 082, 085, 087, 088, 090, 091).

## 1. Flujo observado

1. **001_00m00s.png / 005_00m15s.png** — Login RRHH. Usuario escrito: **"admin"** primero (luego borrado), más adelante (017) se ve el intento con usuario **"arturoperez"**.
2. **009_00m45s.png** — Pantalla **"Empleados vetados"** (URL: `te_listanegraw.aspx`). Esta es la pantalla de administración de Lista Negra. Columnas del listado: **Negra Id**, **Id Emp.**, **Nombre**, **Fecha desde**, **Hasta**, **Lugar de evento**, **Todos** (checkbox por fila). Dos registros preexistentes en el ambiente QA:
   - Negra Id 3 — Id Emp. 1 — Víctor N. Galindo Ramírez — Fecha desde 21/02/19 22:51 — Lugar de evento: Palacio de los Deportes.
   - Negra Id 5 — Id Emp. 65776 — Juan Iglesias Mercado Iglesias Mercado — Fecha desde 14/03/19 11:33 — Lugar de evento: Palacio de los Deportes.
   Toolbar: exportar XLS, exportar PDF, "Selecciona columnas", filtro "Buscar en Nombre" con operador "Comienza con".
3. **013_01m05s.png** — Menú de usuario desplegado mostrando el usuario logueado: **"Julio Angeles"** con opción "Salir" — este parece ser el usuario que accedió inicialmente (antes del cambio a "arturoperez"), posiblemente representando al "usuario de operación" sin accesos al módulo (el escenario pide primero probar con un usuario SIN permiso).
4. **017_01m16s.png** — Pantalla de login con usuario **"arturoperez"** siendo tecleado — confirma el nombre de usuario real ligado a "Arturo Pérez" mencionado en el texto del escenario.
5. **021_01m40s – 029_02m01s** — Formulario de alta **"Empleados vetados"** (`te_listanegra.aspx?INS,0`), sección **"Información General"**:
   - **Id Emp.** (campo numérico + ícono de lupa/buscador).
   - **Nombre** (de solo lectura, se autocompleta al capturar/seleccionar el Id Emp.).
   - **Fecha desde** (fecha + hora, con selector de calendario).
   - **Hasta** (fecha + hora, opcional — queda vacío en el caso de prueba).
   - **Lugar de evento** (dropdown de sitios/sucursales; default "Academia Maddox Satélite", cambiado a **"Palacio de los Deportes"**).
   - **Todos** (checkbox, sin marcar en la prueba) — sugiere una opción para vetar al empleado en **todos los lugares** en vez de uno específico.
   - Botones **Guardar** / **Regresar**.
   - Empleado capturado: **Id Emp. 29564 — Modesto Perdomo Montoya**, Fecha desde auto-rellenada al guardar con la fecha/hora actual del sistema (**15/03/19 18:16**, coincide con "fecha inicial del día en curso" del guion).
6. **045_02m46s.png** — Tras pulsar "Guardar", el registro persiste con **Lugar de evento = "Palacio de los Deportes"** (confirmado) y el formulario pasa a modo edición (URL cambia a `...aspx?UPD,6` — Negra Id 6 nuevo).
7. **049_02m56s – 057_03m32s** — Navegación a **Recursos Humanos** (menú con submenús: Cartera de talento, Base de candidatos, Vacantes→Perfil de puesto/Publicación vacantes/Grupos a entrevistas/Cursos de inducción/Eventos prueba, Folios, Requisición de personal, Proceso de Reclutamiento) y luego a **Pedidos**, donde se crea el **Pedido 779 "Entrega 03 Escenario 18"**:
   - Cliente: "OCESA Promotora, S.A. de C.V.". Contacto: "Gutierrez Leal Miguel".
   - **Unidad de negocio: "Seguridad"**.
   - **PEP: "N/085-PD-2015-03-09 | Preventa Formula 1"**.
   - **Evento**: dropdown con catálogo (Ninguno, Club VIP 2018, **Entrega 03** [seleccionado], Feria del Juguete 2017, Futbol América vs Pumas, Green Day 2019, Jacob Whitesides, SIdonie, Tributo a Michael Jackson) — mensaje de validación en rojo "Evento es requerido." si se intenta guardar sin seleccionarlo.
   - Lugar de cita: **"Palacio de los Deportes"** (con dirección auto-rellenada "Av Viaducto Río de la Piedad y Río Churubuco S/N, Granjas México, 08400 Ciudad de México, CDMX") — mismo sitio donde el empleado fue vetado, conforme al guion.
8. **061_03m41s – 069_04m05s** — Detalle de pedido: Producto = Seguridad-IN, Cantidad = 1, Fecha cita = **19/03/2019** (posterior al día en curso 15/03/19, conforme al guion), Fecha final cita 19/03/19 23:00, Presentación por producto = "Pantalón Negro de Vestir, Playera Lobo y Chamarra Lobo". Botón "Agregar Detalle" → luego "Modificar detalle" tras liberar.
9. **077_04m24s / 078_04m27s** — Pedido 779 liberado (acciones de cabecera "Editar pedido | Liberar Pedido | Cancelar Pedido | Regresar"), Matriz de Puestos muestra "19/03 15:00, Seguridad-In 1-T1" en rojo (0 de 1 cubierto), Total Solicitados = 1, Presupuesto por día = 300.
10. **080_04m30s / 081_04m32s** — Pestaña Reservaciones del detalle: campo "Nombre completo / Alias" con texto escrito **"29564-Modesto Perdomo Montoya"**, botones "Confirmación Forzada" / "Confirmación Preasignada".
11. **082_04m35s.png — HALLAZGO CLAVE**: Al pulsar **"Confirmación Forzada"** para el empleado vetado, el sistema muestra un **banner naranja de error** en la parte superior:
    > **"El empleado se encuentra vetado para el lugar"**
    La asignación **NO se realiza** (el grid de "Personal Confirmado" permanece vacío).
    Esto confirma que el veto es **específico por "Lugar de evento"** (no global salvo que se marque "Todos"), coherente con el campo "Lugar de evento" visto en el alta de la Lista Negra.
12. **085_04m55s – 090_05m04s** — El usuario QA cambia de ventana (selector de tareas de Windows con pestañas: "Acceso - Google Chrome", "Detalles de pedido", "Scripts de Prueba Freelance", Zoom, Controles de reunión, TeamViewer, Plazas empleados, Adobe Premiere, SQL7002.DB, APPSCF-ftps) para ir al **portal de acceso del empleado** (probablemente para intentar la "Confirmación Preasignada" y luego revisar "Reservaciones" como el empleado vetado), y vuelve brevemente a la hoja Excel de guion de prueba.
13. **088_05m00s / 091_05m06s.png** — Captura de la hoja Excel **"Scripts de Prueba Freelance_leonardo"**, pestaña "Otros Escenarios Pedidos", filas 171-186, que transcribe el guion real ejecutado para Escenario 18 **con los usuarios/roles QA reales anotados**:
    | Paso | Usuario QA | Rol |
    |---|---|---|
    | Acceder con usuario de operación (debe ser rechazado) | **jangeles** | **Nomina** |
    | Acceder con usuario con accesos (debe ser permitido) | **arturoperez** | **Gerente-Nomina** |
    | Empleado vetado | **29564 — Modesto Perdomo Montoya** | — |
    Pasos listados explícitamente en la hoja (coinciden con `ESCENARIOS_PRUEBA_FREELANCE.md` Escenario 18 casi palabra por palabra): "Acceder a la pantalla de administración de Lista Negra con usuario de operación" → "Validar que el sistema no permita el acceso" → "...con usuario con accesos (Arturo Pérez)" → "...permita el acceso" → "Incluir a un empleado de seguridad, fecha inicial del día en curso, y como inmueble Palacio de los Deportes" → "Crear un pedido de seguridad en el Palacio de los deportes (con un PEP de Palacio) y un detalle de pedido posterior al día en curso" → "Guardar el detalle" → "Realizar una asignación forzada del empleado vetado al detalle creado" → "Validar que el sistema no permite realizar la asignación" → "Realizar una preasignación del empleado vetado" → "Validar que el sistema no permite realizar la pre-asignación" → "Libero el pedido" → "Entrar en la pantalla de reservaciones del empleado vetado" → "Validar que no se muestra el evento creado".
    - **HALLAZGO**: el rol que SÍ tiene acceso al módulo de Lista Negra se llama explícitamente **"Gerente-Nomina"** en el sistema (no un rol genérico de "administración" o "seguridad"); el rol sin acceso usado en la prueba es **"Nomina"** (a secas). Esto implica un control de acceso (RBAC) granular dentro del mismo dominio de Nómina/RRHH, no solo una separación Operación vs. RRHH.

## 2. Catálogos / valores de dropdown observados

- **Lugar de evento** (en alta de Lista Negra): dropdown de sitios — valores vistos: "Academia Maddox Satélite" (default), "Palacio de los Deportes" (usado).
- **Evento** (en Pedido): (Ninguno), Club VIP 2018, Entrega 03, Feria del Juguete 2017, Futbol América vs Pumas, Green Day 2019, Jacob Whitesides, SIdonie, Tributo a Michael Jackson.
- **Unidad de negocio**: catálogo extenso (ver también Escenario 16) — "Seguridad" usado aquí.
- **Permitir cancelar confirmaciones**: SI/NO (no se tocó directamente en este escenario, pero visible en el formulario de pedido).
- **Todos** (checkbox en alta de veto): sin marcar → veto específico a un lugar; marcado presumiblemente → veto global (no probado en la muestra revisada).

## 3. Mensajes exactos capturados

- **Bloqueo de Confirmación Forzada a empleado vetado** (imagen 082):
  > **"El empleado se encuentra vetado para el lugar"**
- **Validación de campo requerido al crear pedido** (imagen ~057):
  > "Evento es requerido."
- No se capturó en la muestra el mensaje exacto del intento de **"Confirmación Preasignada"** (se presume un mensaje equivalente, p. ej. "El empleado se encuentra vetado para el lugar", pero no quedó en los fotogramas muestreados); se recomienda revisar directamente el video si se requiere el texto literal de ese segundo bloqueo.
- No se capturó el mensaje de "acceso denegado" al intentar entrar al módulo de Lista Negra con el usuario sin permisos (jangeles) — probablemente el menú "Catálogos" o la opción correspondiente simplemente no aparece/está deshabilitada para ese rol, en vez de mostrar un error explícito (similar a lo observado en el Escenario 13 con el botón de cancelar).

## 4. Reglas de negocio / campos NUEVOS no capturados en el schema actual

1. **Lista negra con alcance por sitio/lugar**: el esquema actual `te_lista_negra_empleados` (en `db/reset_database.sql`, líneas ~3196-3216) **NO tiene columna para el sitio/lugar de evento** (`sitio_id` o similar) ni un flag equivalente a "Todos". Solo tiene: `id`, `tenant_id`, `rfc`, `curp`, `nombre_completo`, `motivo`, `autorizado_por`, `fecha_bloqueo`, `activo`, `observaciones`. La pantalla real de Lobo demuestra que el veto se aplica **por combinación empleado + lugar de evento** (con fecha desde/hasta y opción "Todos" para veto global). **Esto es una brecha significativa del modelo de datos**: se recomienda agregar a `te_lista_negra_empleados` (o a una tabla relacionada `te_lista_negra_sitios`) campos como `sitio_id uuid REFERENCES cat_sitios(id)` (nullable = aplica a todos los sitios) y posiblemente `fecha_hasta` (la UI de Lobo tiene "Hasta" además de "Fecha desde", mientras el schema solo tiene `fecha_bloqueo` sin fecha de fin).
2. **Campo "Hasta" (fecha de expiración del veto)**: el formulario de Lobo permite capturar una fecha/hora de fin de veto, ausente en el schema actual (solo hay `fecha_bloqueo DATE` sin equivalente de expiración). Añadir `fecha_hasta timestamptz` (nullable = veto indefinido).
3. **Mensaje de bloqueo ligado al lugar, no al empleado en general**: confirma que la validación de negocio al hacer una asignación forzada o preasignación debe cruzar `(empleado, sitio_del_pedido, fecha_vigente)` contra la lista negra, no solo `(empleado)`.
4. **Control de acceso por rol "Gerente-Nomina" vs "Nomina"**: el módulo de administración de Lista Negra requiere un rol/permiso específico (**Gerente-Nomina**) distinto del rol operativo general de Nómina (**Nomina**). Esto sugiere que el RBAC de PeopleMovil necesita granularidad de permisos dentro del dominio de RRHH/Nómina (p. ej. permiso `lista_negra.administrar` asignable solo a roles gerenciales), no solo una separación binaria Operación/RRHH.
5. **Catálogo de "Evento" obligatorio al crear pedido**, separado de PEP/Unidad de negocio/Sitio (igual hallazgo que en Escenario 16) — confirma que el pedido requiere FK a un catálogo de "Evento" (nombre de la producción/concierto/feria), reutilizado consistentemente en todos los escenarios de este set QA bajo el valor de prueba "Entrega 03".
6. **Registro de veto incluye fecha/hora de captura automática** ("Fecha desde" se auto-rellenó con la fecha/hora del sistema al guardar, 15/03/19 18:16) — comportamiento de auditoría consistente con el principio general del proyecto (timestamp de servidor forzado), aplicable también a `te_lista_negra_empleados.creado_en`.

## 5. Archivos fuente citados

`001_00m00s.png`, `005_00m28s.png`, `009_00m45s.png`, `013_01m05s.png`, `017_01m16s.png`, `021_01m40s.png`, `025_01m48s.png`, `029_02m01s.png`, `033_02m07s.png`, `037_02m26s.png`, `041_02m33s.png`, `045_02m46s.png`, `049_02m56s.png`, `053_03m22s.png`, `057_03m32s.png`, `061_03m41s.png`, `065_03m54s.png`, `069_04m05s.png`, `073_04m11s.png`, `077_04m24s.png`, `078_04m27s.png`, `080_04m30s.png`, `081_04m32s.png`, `082_04m35s.png`, `085_04m55s.png`, `087_04m59s.png`, `088_05m00s.png`, `090_05m04s.png`, `091_05m06s.png`
(todos dentro de `27 - P20190319 _0000 Escenario 18 Lista Negra\`)
