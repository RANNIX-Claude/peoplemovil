# Screenshots: Ciclo Completo 1 (carpeta "19 - Ciclo completo 1")

Fuente: 40 capturas de pantalla extraídas de un video de YouTube ("Ciclo completo 1", canal WJaJa VideoClips, id `oKE4tu4rtKA`, duración 261s). Carpeta: `19 - Ciclo completo 1\`. Nombres de archivo codifican el tiempo transcurrido en el video (`NNN_MMmSSs.png`).

Este walkthrough cubre la **primera mitad** del ciclo de reclutamiento freelance: generación de datos de prueba → catálogo/publicación de vacantes → grupos de entrevista → asistencia a entrevista → firma de contrato → asignación a curso de inducción → email automático al candidato. Continúa en `SCREENSHOTS_CICLO_COMPLETO2.md` (que retoma justo en "Cursos de inducción").

## 1. Flujo real (secuencia de pantallas visitadas, en orden)

1. **Herramienta de datos de prueba (GeneXus dev tool)** — app interna `ImportarDatos`/generador de datos QA, NO parte del sistema productivo Lobo. Genera Vacantes, Pedidos, Candidatos sintéticos. (`001_00m00s`, `002_00m40s`)
2. **Catálogo de vacantes** (`Recursos humanos > Vacantes`) — lista maestra de vacantes con examen psicométrico. (`003_00m50s`, `004_00m56s`)
3. **Publicación vacantes** (`Recursos humanos > Vacantes > Publicación`, URL `te_pubvacanteww.aspx`) — lista de publicaciones de una vacante, con conteo de postulados y grupos. (`005_01m01s`, `006_01m03s`)
4. **Grupos a entrevistas** (vista "lista", URL `te_gpocitasww.aspx`) y **Base de candidatos** (`wp_basecandidatos.aspx`) — pestañas abiertas en paralelo. (`007_01m05s`, `008_01m07s`, `009_01m12s`)
5. **Grupos para entrevistas** (vista operativa, URL `wp_registroasistenciacandidatos.aspx`) con filtro "Hora cita". (`010_01m20s`)
6. Despliegue del menú **Recursos humanos** completo (ver sección 2). (`011_01m22s`–`014_01m33s`)
7. Click en un grupo → **Lista de candidatos en grupo** — marca ¿Asistió? / ¿Documentos Completos? por candidato. (`015_01m47s`–`018_01m55s`)
8. Click "Actualizar Lista" → diálogo de confirmación **"¿ ACTUALIZAR LISTA DE ASISTENCIA ?"** → Sí. (`019_01m56s`, `020_02m11s`)
9. Regresa a "Grupos para entrevistas": columna **"En proceso"** pasa de 0 a 10 para el grupo procesado. (`021_02m14s`, `022_02m19s`)
10. Navega a **Firma de contratos** (lista, mismo layout de columnas que Grupos a entrevistas). (`023_02m27s`, `024_02m35s`)
11. Click en el grupo → **Lista firma de contrato** — selector de **Curso inducción** a nivel de cabecera (aplica a todos los renglones), por candidato: ¿Asistió?, Doc.Com., Folios, Nombre completo, **Resultado** (dropdown, "Aceptado"), **Curso de inducción** (dropdown por renglón). (`025_02m48s`–`034_03m22s`)
12. Click "Actualizar Lista" → diálogo **"¿ ACTUALIZAR FIRMA DE CONTRATOS ?"** — *"Se registrarán en CURSOS DE INDUCCIÓN : 10 registros"* → Sí. (`035_03m26s`, `036_03m28s`)
13. Regresa a "Firma de contratos": **Estatus de grupo** del renglón procesado cambia de "Activo" a **"Concluido"**. (`037_03m30s`–`039_03m43s`)
14. **Email automático al candidato** (Outlook, remitente `registro.sistema.freelance@gmail.com`, nombre para mostrar "Registro portal freelance"), asunto **"Notificación curso de inducción"**. (`040_03m58s`)

## 2. Menú "Recursos humanos" (RRHH) — mapa completo observado

```
RRHH (logo) | Inicio | Recursos humanos ▾ | Operaciones ▾ | Nómina ▾ | Catálogos ▾ | Seguridad sistema ▾ | Salir | [Administrator ▾]

Recursos humanos ▾
├── Cartera de talento
├── Base de candidatos
├── Vacantes ▸ (submenú, no expandido en capturas)
├── Folios
├── Requisición de personal
└── Proceso de Reclutamiento ▸
    ├── Asistencia por Grupos
    ├── Firma de contratos
    ├── Cursos de inducción
    ├── Eventos prueba
    ├── Empleados
    ├── Baja empleado
    ├── Reactivación empleado
    └── Cambio de banco o clabe interbancaria
```

Nota: "Eventos prueba" es un catálogo formal del sistema (no solo un campo libre) — confirma que el concepto "Evento Prueba"/"Evento Práctica" visto en Cursos de Inducción (ver parte 2 del ciclo) tiene mantenimiento propio.

## 3. Detalle por pantalla

### 3.1 Herramienta generadora de datos (dev/QA, no Lobo productivo)
- Pantalla GeneXus con botones: `solocand`, `Vacante`, `Pedidos01`, `Cargar`, `Borrar`.
- Campos: Fecha Inicio Vacante, Fecha Fin Vacante, Lim Cand, Lim Pub Vacantes, Lim Gpocitas, Lim Post Va.
- Grid inferior "Vacantes": columnas `TE_Vacante_Id`, `TE_Vacante_Ctitulo`, `TE_Vacante_CtaDoc`, `TE_Vacante_Imagen`, `TE_Vacante_LigaPsi`, `TE_Vacante_Req`, `TE_Vacante_ReqExp`. Confirma prefijo de tabla GeneXus `TE_Vacante` (transacción "Vacante").

### 3.2 Catálogo de vacantes
Columnas: `Vacante`, `Nombre de vacante`, `Puesto`, `Experiencia laboral` (checkbox), `Requiere inglés` (checkbox), `Código de acceso`, `Examen psicométrico` (hipervínculo externo — algunas filas apuntan a `evaluatest.com/Ocesa/Evaluate/...`, otras a dominios placeholder tipo `www.direccion3a.com`, otras en blanco).

### 3.3 Publicación vacantes (`te_pubvacanteww.aspx`)
Columnas: `Id publicación`, `Nombre de vacante`, `Puesto`, `Fecha de publicación`, `Fecha de caducidad`, `Postulados`, `Grupos`, `¿Visible a candidatos?` (checkbox).
Toolbar estándar: botón "+", exportar XLS, exportar PDF, "Selecciona columnas", filtro "Buscar en [campo] / valor".
Datos de ejemplo: `VacanteTit00034` (Acomodador) con 29–30 postulados y 3 grupos; varias vacantes de "Seguridad" con 0 postulados.

### 3.4 Grupos a entrevistas (vista lista, `te_gpocitasww.aspx`)
Columnas: `Id`, `Cita Gpo` (fecha+hora), `Puesto`, `Nombre de vacante`, `Cupo`, `Candidatos`, `Estatus`, `Sucursal`, `En proceso`.

### 3.5 Base de candidatos (`wp_basecandidatos.aspx`)
Columnas: `Id`, `Folio`, `Paterno`, `Materno`, `Nombre`, `Email`, `Tel.Móvil`, `Fecha de nacimiento`, `Edad`, `Fuente` (p.ej. "Facebook", "Volante").
Candidatos sintéticos de prueba: IDs 208–217, todos con nombre patrón `CandNombre002NN / CandApPat002NN / CandApMat002NN`, mismo email de prueba reutilizado (`calvario.marron.leonardo@outlook.com`), mismo teléfono patrón `044550021N`, fecha de nacimiento `01/01/2001`, edad 18, Fuente "Facebook".
Candidato real de ejemplo (no sintético): Id 204, Folio 31, "Luis Vazquez", email `lvazquez2@cie.com.mx`, Fuente "Volante".

### 3.6 Grupos para entrevistas (vista operativa, `wp_registroasistenciacandidatos.aspx`)
Mismas columnas que 3.4 más filtro "Buscar en: Hora cita / valor / Comienza con". Grupo de interés: `Hora cita 01/10/19 10:00`, Puesto Acomodador, Vacante `VacanteTit00034`, Estatus "Activo", % Disponibilidad 50, Cupo 20, Sucursal CDMX, Núm.Candidatos 10.

### 3.7 Lista de candidatos en grupo
- **Información General**: Id, Hora cita, Puesto, Nombre de vacante, Cupo, Núm.Candidatos.
- **Lista Candidatos**: Folio, Nombre completo, Sexo, **¿Asistió?** (checkbox), **¿Documentos Completos?** (checkbox), **Cambiar grupo** (ícono engrane).
- Botones: **Actualizar Lista** / **Cancelar**.
- Diálogo de confirmación: **"¿ ACTUALIZAR LISTA DE ASISTENCIA ?"** / texto "Confirmar actualización de : 10" / botones **Sí** / **No**.

### 3.8 Firma de contratos (lista)
Mismas columnas que Grupos a entrevistas (`Hora cita`, `Puesto`, `Nombre de vacante`, `Estatus de grupo`, `Sucursal`, `% Disponibilidad`, `Cupo`, `Núm.Candidatos`, `En proceso`). El grupo recién procesado en 3.7 aparece aquí con `Estatus de grupo = Activo`, `Núm.Candidatos 10`, `En proceso 10`.

### 3.9 Lista firma de contrato
- **Información General**: Id, Hora cita, Puesto, Nombre de vacante, Cupo, Núm.Candidatos.
- **Curso inducción** (selector de cabecera, aplica el valor a todos los renglones al seleccionarlo): opciones observadas = `No asignado` (default), `16/07/19 07:00 | D-20` (formato: fecha/hora de cita del curso | código de grupo).
- **Lista Candidatos** (por renglón): ¿Asistió? (checkbox, ya marcado), Doc.Com. (checkbox), Folios, Nombre completo, **Resultado** (dropdown — valor visto: "Aceptado"), **Curso de inducción** (dropdown por renglón, default "(Ninguno)"; se llena al elegir el valor de cabecera).
- Botones: **Actualizar Lista** / **Cancelar**.
- Diálogo de confirmación: **"¿ ACTUALIZAR FIRMA DE CONTRATOS ?"** / texto **"Se registrarán en CURSOS DE INDUCCIÓN : 10 registros"** / botones **Sí** / **No**. (Confirma que el alta de candidatos en Cursos de Inducción se dispara automáticamente desde Firma de Contratos, no es una pantalla separada de captura manual.)

### 3.10 Email automático "Notificación curso de inducción"
- Cliente: Outlook web (outlook.live.com), cuenta "Leonardo Calvario".
- Remitente: `Registro portal freelance <registro.sistema.freelance@gmail.com>`.
- Asunto: **"Notificación curso de inducción"**.
- Cuerpo (texto completo observado):
  > Confirmación de curso de inducción
  >
  > Estimado(a) : CandNombre00209 CandApPat00209 CandApMat00209
  >
  > ¡Ya estás a un paso! Agradecemos tu interés y compromiso en tu proceso de selección.
  >
  > Te confirmamos los datos para tu curso de inducción:
  >
  > Día: **16/07/19**
  >
  > Hora: **07:00**
  >
  > Lugar: Av. Río Churubusco esq. con Añil s/n, Puerta 1. **Recepción Lobo**
  > Palacio de los Deportes, Col. Granjas México, Ciudad de México.
  >
  > Favor de presentar Identificación Oficial.
  >
  > Recuerda que debes asistir con el código de vestimenta: *(texto cortado por scroll, no visible completo)*
- Se observan múltiples copias del mismo correo en la bandeja (uno por candidato, enviado individualmente, no como un solo correo con 10 destinatarios).

## 4. Hallazgos nuevos vs. ESCENARIOS_PRUEBA_FREELANCE.md / schema

- **Pipeline de reclutamiento de 4 etapas encontrado end-to-end**, con nombres de pantalla exactos y URLs: `Asistencia por Grupos` (registro asistencia a entrevista) → `Firma de contratos` (registro resultado + asignación a curso de inducción) → `Cursos de inducción` (ver parte 2) → alta automática de `Empleado`. Esto no estaba documentado como flujo encadenado en los escenarios de prueba existentes (que empiezan directo en "Crear un nuevo pedido").
- **Catálogo "Eventos prueba"** es una entidad de menú propia bajo Proceso de Reclutamiento, separada de "Cursos de inducción" — sugiere tabla/catálogo propio en el modelo de datos, no solo un campo en pedido_detalle.
- **Patrón de selector de cabecera que aplica en lote a todos los renglones** (visto en "Curso inducción" de Firma de Contratos, y repetido para "Evento Prueba" en Cursos de Inducción — ver parte 2): UX recurrente para asignar un valor masivo a una lista de candidatos/detalles.
- **Cada actualización masiva dispara un modal de confirmación con conteo de registros afectados** (texto tipo "¿ ACTUALIZAR X ?" / "Confirmar actualización de : N" o "Se registrarán en Y: N registros") — patrón de confirmación reutilizable a replicar en PeopleMovil para operaciones de pedido_detalle en lote.
- **Transición de estatus de grupo**: "Activo" → "Concluido" cuando se completa el registro de Firma de Contratos del grupo. Sugiere un `estatus_grupo_entrevista` o similar con al menos estos dos valores (y posiblemente más, dado que algunos grupos de la lista nunca llegan a tener fecha ni candidatos).
- **Notificaciones por correo automatizadas, personalizadas por candidato** (no solo por evento/pedido): confirma que el sistema de notificaciones debe soportar plantillas con variables de candidato individual (nombre, fecha, hora, lugar) y envío 1-a-1, útil para diseñar el motor de notificaciones de PeopleMovil.
- **Datos de prueba generados vía herramienta GeneXus interna** (`TE_Vacante`, etc.) confirman convención de nombres de transacción GeneXus con prefijo `TE_` — puede ayudar a mapear otras pantallas/tablas legacy si aparecen.
- **Campo "Examen psicométrico"** en Catálogo de vacantes es un **link externo configurable por vacante** (URL a plataforma de terceros `evaluatest.com`), no un formulario interno — importante para decidir si PeopleMovil debe integrar o solo enlazar a un proveedor externo de evaluación psicométrica.
- **Candidato sintético reutiliza el mismo email/teléfono de prueba** para 10 registros: nota de calidad de datos de prueba legacy, no un hallazgo funcional, pero explica por qué el correo de notificación en folder 18 llega repetidamente a la misma bandeja.
