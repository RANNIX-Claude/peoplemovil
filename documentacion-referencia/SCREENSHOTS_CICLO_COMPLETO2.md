# Screenshots: Ciclo Completo 2 (carpeta "18 - Ciclo completo2")

Fuente: 34 capturas de pantalla extraídas de un video de YouTube ("Ciclo completo2", canal WJaJa VideoClips, id `_p-b1eWOi6g`, duración 263s). Carpeta: `18 - Ciclo completo2\`. Nombres de archivo codifican el tiempo transcurrido en el video (`NNN_MMmSSs.png`).

Este walkthrough es la **continuación** de `SCREENSHOTS_CICLO_COMPLETO1.md`: retoma exactamente en "Cursos de inducción" (donde el ciclo 1 deja a los 10 candidatos ya asignados vía Firma de Contratos) y cubre: confirmación de asistencia al curso → alta automática de Empleado + Plaza → confirmación forzada automática en el Pedido vinculado ("Evento Prueba") → email automático a RRHH con PDF adjunto.

## 1. Flujo real (secuencia de pantallas visitadas, en orden)

1. **Cursos de inducción** (`Recursos humanos > Proceso de Reclutamiento > Cursos de inducción`) — lista de cursos programados. (`001_00m00s`–`004_00m40s`)
2. Click en un curso → **Lista candidatos curso de inducción** — Información General + selector de cabecera **Evento prueba** (aplica a todos los renglones) + lista de candidatos con **Evento Prueba** por renglón. (`005_01m12s`–`012_01m31s`)
3. Selector de cabecera "Evento prueba" desplegado: opciones = eventos reales usados en otros escenarios de prueba (p.ej. "Jacob Whitesides 2019", "Green Day 2019", "Sidonie", "Futbol América vs Pumas", "Feria del Juguete 2017"). Se selecciona **"11/07/19 06:00 | JACOB WHI..."** y se aplica a los 10 candidatos. (`008_01m19s`–`012_01m31s`)
4. Marca **¿Asistido?** para los 10 candidatos. (`013_01m40s`, `014_01m41s`)
5. Click "Actualizar Lista" → diálogo **"ACTUALIZAR ASISTENCIA"** — *"¿Confirmar asistencia de : 10 Registros ?"* → Sí. (`015_01m42s`, `016_02m10s`)
6. El sistema abre automáticamente 4 pestañas nuevas: **Empleado**, **Plazas empleados**, **Pedidos**, **Detalles de pedido** — confirma que la confirmación de asistencia al curso de inducción dispara en cascada: alta de empleado + alta de plaza + confirmación forzada de reservación en el pedido ligado al "Evento Prueba" seleccionado. (`017_02m11s`–`024_02m41s`)
7. **Empleado** (grid): 10 empleados nuevos (Id 65877–65887), `Estatus = Activo`, `Certeza = 0.90` (default), Sucursal CDMX. (`019_02m23s`, `020_02m27s`)
8. **Plazas empleados** (grid): una plaza por empleado nuevo, con Puesto, Pago default, Unidad de negocio, fecha Inicio. (`021_02m29s`, `022_02m33s`)
9. **Pedidos** (grid) → **Detalles de pedido**: Pedido No. **1048**, título **"Jacob Whitesides 2019"** — el mismo evento elegido como "Evento Prueba" en el paso 3. Matriz Bloque/Producto: `Acomodador-MA` cantidad 10, turno 1.00, Total Solicitados 10/10. (`023_02m36s`–`026_02m45s`)
10. Pantalla de detalle de pedido: barra de acciones **Editar pedido / Liberar Pedido / Cancelar Pedido / Regresar**. Pestaña **Reservaciones** → sección **Personal Confirmado**. (`027_02m51s`, `028_02m52s`)
11. Grid "Personal Confirmado": los 10 empleados nuevos aparecen con `Estatus = CONFIRMADO FORZADO`; botones **Confirmación Forzada** / **Confirmación Preasignada** / imprimir lista de asistencia. (`029_02m55s`, `030_02m56s`)
12. **Email automático a RRHH** (Outlook), asunto de la notificación visible en bandeja: "Notificación del sistema" / cuerpo del correo **"Registro alta de empleados"**, con PDF adjunto. (`031_04m01s`–`033_04m05s`)
13. **PDF adjunto abierto**: "Relación de personal dado de alta con fecha: 22/07/19" — tabla de los 10 nuevos empleados. (`034_04m16s`)

## 2. Detalle por pantalla

### 2.1 Cursos de inducción (lista)
Columnas: `Descripción`, `Cita Curso`, `Tiempo de duración`, `Puesto`, `Nombre de vacante`, `Cupo`, `Integrantes`.

### 2.2 Lista candidatos curso de inducción
- **Información General**: Curso inducción, Cita, Puesto, Nombre de vacante.
- **Evento prueba** (selector de cabecera — mismo patrón "aplica a todos los renglones" visto en Firma de Contratos del ciclo 1): opciones = eventos de prueba reales precargados en el sistema (coinciden con nombres de "Escenario" del archivo `ESCENARIOS_PRUEBA_FREELANCE.md`: Jacob Whitesides 2019, Green Day 2019, Sidonie, Futbol América vs Pumas, Feria del Juguete 2017, etc.). Formato de opción: `DD/MM/AA HH:MM-NOMBRE_EVENTO`.
- **Lista Candidatos** (por renglón): Id, Publicación, Folios, Nombre completo, **¿Asistido?** (checkbox), **Evento Prueba** (dropdown por renglón, se llena al elegir valor de cabecera), **Cambiar grupo** (ícono engrane).
- Botones: **Actualizar Lista** / **Cancelar**.
- Diálogo de confirmación: **"ACTUALIZAR ASISTENCIA"** / texto **"¿Confirmar asistencia de : 10 Registros ?"** / botones **Sí** / **No**.

### 2.3 Empleado (grid, alta automática)
Columnas: `Id`, `Nombre Completo`, `Estatus`, `Sexo`, `Certeza`, `Correo electrónico`, `Sucursal`.
Los 10 registros nuevos (Id 65877–65887) corresponden 1 a 1 a los candidatos 208–217 de `SCREENSHOTS_CICLO_COMPLETO1.md`. Todos `Certeza = 0.90`, `Estatus = Activo`, `Sucursal = CDMX`, mismo email de prueba heredado de la base de candidatos.

### 2.4 Plazas empleados (grid, alta automática)
Columnas: `Id empleado`, `Nombre`, `Sexo`, `Certeza`, `Estatus`, `Pago`, `Id puesto`, `Puesto`, `Pago default`, `Unidad negocio`, `Inicio`.

### 2.5 Pedidos (grid)
Columnas: `Id`, `Título`, `Estatus`, `Unid.Neg.`, `Sucursal`, `lugar`, `Responsable`, `Complejidad`, `T.Mov`, `PeP|Descripción`.
Pedido de interés: **Id 1048**, Título "Jacob Whitesides 2019" — este es el pedido operativo real detrás del "Evento Prueba" elegido en la pantalla de Cursos de Inducción. Confirma que "Evento Prueba" en RRHH es en realidad una referencia a un Pedido existente del módulo de Operaciones (reutilizado como "sandbox" para practicar confirmaciones con empleados nuevos).

### 2.6 Detalles de pedido (Pedido 1048)
- Matriz Bloque/Producto: `Acomodador-MA | Jacob Whitesides 2019`, Cantidad 10, Turno 1.00, Total Solicitados 10/10, Presupuesto por día $1,000.00.
- Pestaña **"Movimientos detalles pedido" > Detalles**: `Estatus` (Vigente), checkbox **Evento Práctica**, `Tipo personal` (Operativo), `Título`, `Producto` (dropdown), `Cantidad`, `Turnos`, `Fecha cita`, `Fecha liberación`.
  - **Campo nuevo no documentado antes**: checkbox **"Evento Práctica"** en el detalle de pedido — marca el detalle como usado para prácticas/pruebas de confirmación de personal nuevo, distinto de un pedido operativo real. Candidato a columna `es_evento_practica boolean` en `pedido_detalle` (o tabla equivalente) del modelo de datos.
- Barra de acciones del pedido: **Editar pedido**, **Liberar Pedido**, **Cancelar Pedido**, **Regresar**.

### 2.7 Reservaciones > Personal Confirmado (dentro del detalle de pedido)
- Búsqueda por Nombre completo/Alias.
- Botones: **Confirmación Forzada**, **Confirmación Preasignada**, imprimir lista de asistencia (ícono impresora).
- Grid: `IdContacto`, `Nombre completo`, `Estatus`. Los 10 empleados recién creados aparecen con `Estatus = CONFIRMADO FORZADO` — confirma que la confirmación de asistencia al curso de inducción ejecuta automáticamente una Confirmación Forzada sobre el Evento Prueba/Pedido vinculado, sin pasar por el portal del empleado.

### 2.8 Email automático a RRHH "Registro alta de empleados"
- Remitente: `registro.sistema.freelance@gmail.com` (nombre para mostrar en bandeja: "Registro alta de empleados" / encabezado interno "Notificación del sistema").
- Firma del cuerpo del correo: **Erika Lara, Administración de personal**.
- Texto (resumen, visto parcialmente por scroll): *"Anexo la presente enviamos la relación de los candidatos que han sido seleccionados y dados de alta como personal Freelance de manera automática."*
- Adjunto: PDF `22072019_07_00.pdf` (~2 KB) — nombre de archivo codifica fecha+hora de generación (`DDMMYYYY_HH_MM`).

### 2.9 Contenido del PDF adjunto
- Título: **"Relación de personal dado de alta con fecha: 22/07/19"**.
- Tabla: columnas `Num.Empleado`, `Nombre`, `Puesto`, `Solicitud`.
- 10 filas (empleados 65877–65887), `Puesto = SEGURIDAD` para todos (**discrepancia notable**: el pedido/producto real era "Acomodador-MA", no Seguridad — posible bug legacy de generación de reporte, o el PDF usa el puesto "default"/genérico del catálogo de empleados en vez del puesto del detalle de pedido confirmado), `Solicitud` = folios de candidato (208–217).

## 3. Hallazgos nuevos vs. ESCENARIOS_PRUEBA_FREELANCE.md / schema

- **Cadena de automatización completa, no documentada en los escenarios QA existentes**: confirmar asistencia en "Cursos de inducción" dispara en una sola transacción: (a) alta de `Empleado`, (b) alta de `Plaza` asociada, (c) `Confirmación Forzada` de ese empleado sobre el pedido ligado al "Evento Prueba" seleccionado, (d) email a RRHH con PDF de relación de altas. Esto es una ruta de alta de personal completamente distinta a "Dar de alta un empleado" manual mencionado en los Escenarios 8/9/16 de `ESCENARIOS_PRUEBA_FREELANCE.md`.
- **"Evento Prueba" = referencia directa a un Pedido real** (no una entidad separada aislada): el pedido 1048 "Jacob Whitesides 2019" sirve como "pedido sandbox" reutilizado para probar el flujo de confirmación de personal nuevo. Relevante para decidir si en PeopleMovil el equivalente de "evento de práctica" debe ser un pedido normal marcado con una bandera, o una entidad aparte.
- **Campo "Evento Práctica"** (checkbox) en el detalle de pedido — no aparece en el schema `reset_database.sql` actual ni en los escenarios de prueba. Sugiere agregar un flag equivalente si se quiere replicar este flujo de "sandbox de confirmación" en PeopleMovil.
- **`Certeza` default = 0.90** para empleados dados de alta por este flujo automático — coincide con el valor usado en varios escenarios QA (Escenario 16 usa certeza 0.9 para 3 de 6 empleados), confirma que 0.90 es efectivamente un valor default general, no solo de un puesto específico (aunque el CLAUDE.md del proyecto documenta certeza por puesto vía `cat_puestos.porcentaje_certeza_inicial` — este dato de pantalla sugiere que además existe/existía un default global visible al usuario).
- **Posible bug legacy confirmado por evidencia documental**: el PDF de "Relación de personal dado de alta" reporta `Puesto = SEGURIDAD` para los 10 empleados aunque fueron confirmados contra un detalle de pedido de producto "Acomodador-MA". Vale la pena anotarlo como comportamiento a **no** replicar (o a decidir conscientemente) en PeopleMovil.
- **Patrón UX repetido**: selector de cabecera que aplica valor en lote a todos los renglones de una lista de candidatos (visto aquí para "Evento Prueba", y en el ciclo 1 para "Curso de inducción") — refuerza que es un patrón de interacción estándar del sistema Lobo para operaciones masivas sobre listas de candidatos/empleados.
- **Notificación transaccional a un rol interno (RRHH/Administración de personal) con adjunto PDF generado dinámicamente** — patrón de reporte no visto antes en la documentación existente (los escenarios solo mencionan notificaciones a empleados/candidatos, no reportes administrativos automáticos con adjunto).
