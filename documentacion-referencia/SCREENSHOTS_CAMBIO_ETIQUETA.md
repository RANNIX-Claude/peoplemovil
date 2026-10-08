# Escenario 22 — "Cambio Etiqueta Actualizado" (26 screenshots, video QA 2019)

Fuente: `C:\work\PeopleMovil\doc\Panttallas del sistema tomados desde varios video escvenarios de pruebas de pruebas\22 - Cambio Etiqueta Actualizado\`

## Qué es este escenario

No es un cambio de "etiqueta/tag" de negocio (como una etiqueta de estatus). Es una prueba de
QA de un **cambio de caption/label de un campo en el Knowledge Base de GeneXus**, verificando que
el nuevo texto se propaga correctamente al formulario web en producción/QA y que la
funcionalidad del campo (combo de selección, auto-llenado de campos relacionados) sigue
funcionando después del rename.

Concretamente: el campo que aparecía rotulado **"Vacante"** en el formulario de alta de
publicación de vacantes fue renombrado a **"Perfil del puesto"**, porque ese campo en realidad
no captura el nombre libre de una vacante sino que es un combo que selecciona un **Perfil de
puesto** (catálogo/plantilla) predefinido.

## Mecanismo técnico (GeneXus) — capturas 2–7

- Herramienta: GeneXus 15, KB `AppSCPF` (módulo AppSCPFV2), objeto transacción **`TE_PubVacante`**
  ("Publicación vacantes"), dentro de `Root Module > WWPBaseObjects`.
- En el árbol de estructura de la transacción (panel "Información General - View Detail Data" /
  tabla `TableContent` / `tablImagen`) se selecciona el atributo **`TE_VacanteId`**.
- Panel de Properties del atributo:
  - `Attribute`: `TE_VacanteId`
  - `Description` (la propiedad que define el caption/etiqueta por defecto en todos los
    formularios que usan el atributo): se edita de **"Vacante"** a **"Perfil del puesto"**.
  - Otras propiedades visibles: `Right Text`, `Help Text`, `Auto Prompt = <default>`,
    `Invite Message`, `Link > Autolink = True`, `Form > Theme class`, `Description Then`,
    `Visible = True`, `Visible Condition`, `Control Info > Custom`.
  - Atributo hermano `TE_VacanteImagen` (imagen del perfil): `Description = =Attribute.Title`
    (fórmula que hereda el título del atributo relacionado), `Theme class = ImageAttribute`,
    `Control Info > Based on`.
- Tras guardar el cambio, se dispara un **Build**: output muestra
  `Processing inferred calls... Specification Success` (build/rebuild para propagar el cambio al
  deploy web).
- Conclusión técnica: en GeneXus, la propiedad `Description` del atributo actúa como etiqueta
  (label) por defecto en todos los Web Panels/Transactions que usan ese atributo, salvo que el
  control la sobreescriba. Cambiarla centralmente y rebuildear propaga el nuevo texto a toda la
  UI sin tocar cada formulario individualmente — este es el "cambio de etiqueta" que se está
  probando, y el QA confirma que no rompe nada (el combo, el autollenado y el guardado siguen
  funcionando igual).

## Validación en el sistema web (capturas 8–26)

### Login — capturas 8–10
- URL QA: `integramx-001-site2.btempurl.com/qafreelance/inicio.aspx`
- Pantalla de acceso con branding **"RRHH"**, fondo de escenario/concierto (branding OCESA).
- Campos: `Usuario`, `Contraseña`.
- Checkboxes: `Mantenerme Conectado`, `Recordar`.
- Botón: `Ingresar`.
- Login con usuario `admin`.
- Página de inicio (`wwpbaseobjects.home.aspx`) muestra imagen de escenario con crédito
  "OCESA - copyright 2018".

### Menú principal — capturas 11–12
Barra de navegación superior del portal RRHH:
- **Recursos humanos** (submenú desplegado):
  - Cartera de talento
  - Base de candidatos
  - **Vacantes** ▸ (submenú anidado):
    - **Perfil de puesto**
    - **Publicación vacantes**
    - Grupos a entrevistas
    - Cursos de inducción
    - Eventos prueba
  - Folios
  - Requisición de personal
  - Proceso de Reclutamiento ▸ (tiene submenú propio, no explorado en este set)
- Operaciones
- Nómina
- Catálogos
- Seguridad sistema
- Salir

Nota: el ítem de menú "Perfil de puesto" ya existe como pantalla propia separada (catálogo de
perfiles/plantillas de puesto); "Publicación vacantes" es la pantalla donde se instancia una
vacante concreta a partir de un perfil.

### Listado "Publicación vacantes" — capturas 13, 23–24
URL: `te_pubvacanteww.aspx`

Columnas de la grilla:
- `Id publicación`
- `Nombre de vacante`
- `Puesto`
- `Fecha de publicación`
- `Fecha de caducidad`
- `Postulados` (contador de candidatos postulados)
- `Grupos` (contador de grupos de entrevista asociados)
- `¿Visible a candidatos?` (checkbox/flag)

Toolbar: botón `+` (alta), exportar `XLS`, exportar `PDF`, `Selecciona columnas`, buscador
("Buscar en" `Id publicación`, campo `valor`, selector de operador `<`, paginador).

Datos de ejemplo visibles en la grilla (ids 10–20), todas vacantes de staffing para eventos/
conciertos (consistente con el negocio OCESA):
Locutor de evento, Prueba Perfil Puesto Seguridad, Head Rigger, LOCAL CREW, Taquillas Chayanne,
Taquilleros para Playa Limbo, Stage Hand para evento, Meseros para Luis Miguel Tour VIP,
Seguridad de accesos (x2), Chef para evento (nuevo registro creado en este escenario, id 20).

### Alta de nueva publicación de vacante — capturas 14–22, 25–26
URL: `te_pubvacante.aspx?INS,0`

Encabezado de panel: **"Información General"**.

**Columna izquierda:**
- **`Perfil del puesto`** (antes `Vacante`) — combo desplegable, valor por defecto `(Ninguno)`.
  Opciones observadas en el combo (catálogo de Perfiles de puesto):
  - Seguridad de accesos
  - Analista capacitador
  - Asistente de luces
  - Chef para evento
  - Head Rigger
  - LOCAL CREW
  - Local Crew nocturno
  - Locutor de evento
  - Meseros para Luis Miguel Tour VIP
  - Personal de taquilla
  - Personal para control de accesos
  - Prueba Perfil Puesto Seguridad
  - Seguridad Nocturna
  - Stage Hand para evento
  - Taquillas Chayanne
  - Taquilleros para Playa Limbo
- `Imagen` — miniatura/foto asociada al perfil (se auto-carga al elegir el perfil).
- `Puesto` — texto de solo lectura, auto-llenado desde el perfil (ej. "Chef").
- `Fecha de publicación` — campo fecha con ícono de calendario; abre un **date picker**
  (mes/año navegable con `«` `‹` `Hoy` `›` `»`, grilla Dom-Lun-Mar-Mié-Jue-Vie-Sáb).
- `Fecha de caducidad` — mismo tipo de campo/picker.

**Columna derecha:**
- `Nombre de vacante` — auto-llenado desde el perfil elegido (ej. "Chef para evento").
- `Examen psicométrico` — URL al examen (auto-llenado, ej. `www.examen.com/psicologico`).
- `Código de acceso` — código (auto-llenado, ej. `2323`).
- `Experiencia laboral` — checkbox (visto en la vista previa inicial del diseñador, captura 1/5).
- `Requiere inglés` — checkbox (ídem).
- `¿Visible a candidatos?` — checkbox que controla si la vacante es visible para postulantes.
- `Requisitos` — texto libre, auto-llenado desde el perfil (ej. "Contar con 5 años de
  experiencia en gastronomía.").
- `Funciones` — texto libre, auto-llenado desde el perfil (ej. "Realizar el control de todas
  las actividades que se realizarán en cocina.").

**Botones:** `Confirmar`, `Cancelar`, y `Eliminar` (este último solo en modo edición de un
registro existente, no en alta nueva).

### Flujo de prueba ejecutado
1. Abrir "Publicación vacantes" → grilla con registros existentes (ids hasta 19).
2. Clic en `+` → formulario en blanco; se confirma visualmente que la etiqueta ya dice
   **"Perfil del puesto"** (no "Vacante") — validación del cambio de label.
3. Seleccionar perfil **"Chef para evento"** del combo → se auto-llenan: Imagen, Puesto (Chef),
   Nombre de vacante (Chef para evento), Examen psicométrico, Código de acceso, Requisitos,
   Funciones.
4. Capturar `Fecha de publicación = 20/05/19` usando el date picker.
5. Capturar `Fecha de caducidad = 31/05/19` usando el date picker.
6. `Confirmar` → vuelve a la grilla, aparece el nuevo registro **id 20, "Chef para evento",
   Puesto "Chef", 20/05/19 → 31/05/19**.
7. Se reabre el formulario de alta (`+`) una vez más y se confirma que la etiqueta
   "Perfil del puesto" persiste.

## Regla de negocio implícita (relevante para PeopleMovil)

El modelo distingue dos entidades:
- **Perfil de puesto** (catálogo/plantilla, pantalla propia en el menú "Vacantes > Perfil de
  puesto"): define Puesto, examen psicométrico, código de acceso, requisitos y funciones
  estándar para un tipo de rol.
- **Publicación de vacante** (instancia concreta, pantalla "Vacantes > Publicación vacantes"):
  se crea seleccionando un Perfil de puesto existente; hereda/copia los datos del perfil
  (puesto, examen, código de acceso, requisitos, funciones, imagen) y añade datos propios de la
  instancia: nombre de vacante (editable), fechas de publicación/caducidad, visibilidad a
  candidatos, y contadores de postulados/grupos de entrevista.

Este patrón "perfil plantilla → vacante publicada por evento" es genérico para cualquier empresa
de staffing (no específico de OCESA) y debería mapearse en PeopleMovil como dos tablas/entidades
relacionadas (algo así como `job_profile` / `job_posting`) con copia de valores por defecto al
crear la publicación, en vez de una única tabla de "vacante".
