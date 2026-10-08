# Contexto: el sistema anterior (OCESA, desde 2010) que fue la base de Lobo/AppSCPF

Fuentes:
- `C:\work\PeopleMovil\doc\base sql\parte1-5\` — 4 grabaciones únicas del Grabador
  de pasos de Windows (`.mht`, no son respaldos de SQL Server como se pensó inicialmente),
  2 sesiones de febrero/marzo 2018.
- `C:\work\PeopleMovil\doc\Pantallas de Lobo\` — 27 fotos tomadas el 09/08/2017 de
  pantalla real en uso.

**Confirmado por el usuario:** este es el sistema que OCESA tenía desde **2010**
(SharePoint + una app ASP.NET propia en `apoyo.rh.ocesa.mx`), que el usuario usó como
base para diseñar y construir el sistema nuevo (GeneXus, "Sistema Integra"/Lobo) en
**2018**. No es el sistema que se construyó — es su antecesor directo y la referencia
de diseño real. Varias pantallas de este sistema anterior son prácticamente el
"prototipo de papel" de lo que luego se replicó en GeneXus.

**Nota de privacidad:** este documento NO incluye nombres de personas, fotos, datos
bancarios ni cualquier otro dato personal visible en las capturas — solo la estructura
de sitios/listas de SharePoint y el proceso de negocio que describen, que es lo
relevante para entender el "antes".

---

## 1. Qué era el sistema anterior

Un conjunto de sitios de **SharePoint** (no una aplicación a medida), con SharePoint
Lists como si fueran tablas de base de datos, operado manualmente por RH:

- **`sistema.lobo.com.mx`** — sitio "Operaciones Personal Eventual" / "Sistema Ocesa RH"
  - Lista **Contactos** (vista "Empleados Freelance") — el registro maestro de cada
    freelance, con ficha de detalle por contacto
  - Lista **Contactos_Cuenta_Banco** — cuenta bancaria capturada a mano, ligada por
    `IdContacto` a la lista Contactos (formulario nuevo por cada cuenta)
  - Lista **Bancos** — catálogo de bancos
  - Lista **Solicitud de Alta Personal Staff** — la solicitud/requisición de personal
    (formulario con selección de puesto desde un listado largo, ej. "Acreditacion EE
    Carreras", "Art Handlers")
  - Lista **Contraseñas para portal de confirmaciones** — credenciales del portal donde
    los freelance confirmaban asistencia (gestionadas a mano en una lista, no un sistema
    de autenticación real)
  - Lista **Centro de Comunicación** — bitácora/mensajería interna
- **`rh.expedientes.ocesa.mx`** — sitio SEPARADO solo para expedientes de RH:
  - Biblioteca **Expedientes Empleados** (una carpeta numérica por empleado)
  - Biblioteca **Expedientes Personal Eventual**
  - Biblioteca **Expedientes Empleados - Archivos Confidenciales**
  - Biblioteca **Expedientes Empleados - Archivos de Nómina**
  - Biblioteca **Documentos Solicitantes Eventuales**
  - Dentro de cada carpeta de empleado: subcarpeta **"Poligrafo Resultados"** (examen
    de confianza/poligráfico, típico de personal de seguridad) y fotos del empleado

## 2. El proceso que describía (reconstruido de la secuencia de clics)

1. Llega una necesidad de personal → se captura en **Solicitud de Alta Personal Staff**
   (selección manual de puesto desde un catálogo largo sin estructura clara)
2. El candidato/freelance queda registrado en **Contactos**, con su cuenta bancaria
   capturada por separado en otra lista (**Contactos_Cuenta_Banco**) — sin validación
   cruzada automática
3. Su expediente (identificación, resultados de polígrafo, fotos, documentos
   confidenciales, archivos de nómina) vive en un **sitio de SharePoint completamente
   distinto** (`rh.expedientes.ocesa.mx`), organizado en carpetas numéricas por ID —
   hay que saltar entre dos sitios y recordar el ID de carpeta
4. Para encontrar documentación histórica de un proceso, el operador termina
   **buscando en su propio correo de Outlook** (búsquedas por asunto/adjunto) en vez
   de tener todo centralizado
5. Las contraseñas del "portal de confirmaciones" (donde los freelance confirmaban su
   asistencia) se gestionaban en una **lista de SharePoint**, no en un sistema de
   autenticación propiamente dicho

## 3. Por qué importa para PeopleMovil

Esto NO es un modelo de datos a replicar — es exactamente el tipo de fragmentación
(contactos en un lado, cuentas bancarias en otro, expedientes en un tercer sitio,
credenciales en una lista, búsqueda de histórico vía correo personal) que Lobo/AppSCPF
(y ahora PeopleMovil) existen para resolver con un solo modelo relacional y RLS por
tenant. Confirma además, desde el lado del cliente/requerimiento original (no solo
desde el código ya construido), varios conceptos que ya están en el esquema:

- `tc_bancos` / cuenta bancaria del empleado → viene de "Bancos" + "Contactos Cuenta Banco"
- El concepto de expediente documental por empleado (ya cubierto por los campos de
  documentos en Alta de Candidatos: IFE/INE, CURP, etc.)
- Examen de confianza/poligráfico como parte del expediente de seguridad — **no
  modelado todavía** en el esquema actual; si se requiere para el vertical de
  seguridad/staffing de alto riesgo, sería un campo o tabla nueva
  (`te_examenes_confianza` o similar) — pendiente de decisión, no se agrega sin
  confirmar que aplica al alcance actual

## 4. `apoyo.rh.ocesa.mx` — el antecesor directo de Pedidos/Detalle (validación fuerte)

A diferencia de las listas de SharePoint (sección 1), esto es una app ASP.NET propia
("Ocesa RH") con una pantalla de Pedido casi idéntica en estructura a la que ya
construimos en GeneXus/React. Ejemplo real visto: **Pedido No. 253230**, "Garbage &
Blondie Luces PRG", Evento "Garbage & Blondie 2017", Lugar de Cita "Palacio de los
Deportes", Unidad de Negocio "PRG", Sucursal "México".

### 4.1 Matriz de Puestos — confirma el diseño exacto que ya construimos

La sección "Personal Operativo" es **la misma matriz pivote** que `matriz_puestos_pedido()`
genera hoy: fechas como columnas (con sub-columna de hora, y hasta 2 turnos el mismo
día — vgr. 14/08 09:00 y 14/08 21:00), Productos como filas, celda = `cantidad - T turnos`,
fila **Total Solicitados**, fila **Presupuesto por Día** (calculado en vivo). Ejemplo real:

| | 10/08 10:00 | 13/08 07:00 | 14/08 09:00 | 14/08 21:00 | 15/08 11:00 |
|---|---|---|---|---|---|
| Encargado de Luces PRG | | 1-T1 | 1-T1 | 1-T1 | |
| Especialista de Iluminación B | | | 1-T1 | | |
| Stage Hand A Luces PRG | | 2-T1 | 2-T1 | 2-T1 | |
| Tecnico de Luces PRG | 5-T1 | 4-T1 | 4-T1 | 4-T1 | 5-T1 |
| **Total Solicitados** | 5 | 7 | 8 | 7 | 5 |
| **Presupuesto por Día** | $2,050 | $3,270 | $13,890 | $2,050 | |

Al hacer clic en una celda, se abre un popup con el detalle real de esa línea —
coincide campo por campo con `te_pedidos_detalle`: **ID** (741270), Lugar de Cita,
**Fecha Cita**, **Fecha Fin Cita**, **Fecha Liberación**, **Completar con Similares**,
**Cantidad Reservados**, **Cantidad Reservados Real**, **Cantidad Reservados con
Preasignados**, **Porcentaje Completo**, **Fase del Evento**.

### 4.2 Fase del Evento — más rica de lo que ya teníamos documentado

El dropdown real de "Fase del Evento" en Agregar Detalle tenía **8 valores**, no 5:
`Preparacion, Montaje, Show, Desmontaje, Fase 1 (de 1 a 4 días), Fase 2 (Quinto Día),
Fase 3 (Sexto Día), Fase 4 (Séptimo Día en adelante)`.

Esto es más granular que lo confirmado antes en las capturas de GeneXus (`No aplica,
Preparación, Montaje, Show, Desmontaje` — 5 valores). Lectura más probable: el sistema
2018 (GeneXus) **simplificó intencionalmente** esta enumeración, dejando fuera el
desglose por día de show (Fase 1-4) que sí existía en el sistema 2017. **No se agrega
automáticamente al esquema** — queda como hallazgo a confirmar con el usuario: ¿la
simplificación fue deliberada (y por tanto correcta replicarla tal cual en PeopleMovil),
o es algo que convendría recuperar?

Otros campos confirmados en "Agregar Detalle": **Turnos** con ayuda en línea
"1 turno por 12 hrs" (confirma el default `duracion_turno_horas = 12` que ya usamos),
**Indicaciones Especiales (Voice y página de internet)** — sugiere que ese campo se usa
para canal de radio/voice del evento, no solo texto libre genérico — y **Bloque por
Producto** / **Facturable** como dropdowns independientes junto a Cantidad/Turnos.

### 4.3 Solicitud de Personal (hoja impresa) — confirma el feature "Imprimir lista de Asistencia"

Una foto muestra la hoja impresa real de "SOLICITUD DE PERSONAL" para el Pedido 253230:
encabezado con Evento, PEP, Inmueble, Día de Show, Sociedad Pagadora, Sucursal,
**Solicitante** (nombre de quien pidió el personal), Complejidad; y una tabla con
**Preparación / Montaje / Show / Desmontaje / Check In** como columnas (cada una con su
fecha y hora) y una fila por empleado asignado, con el puesto que cubre en cada fase y
una columna de "Observaciones" por fase para marcar asistencia a mano. Confirma en papel
el botón "Imprimir lista de Asistencia" ya documentado en `RADIOGRAFIA_FUNCIONAL_PANTALLAS.md`.

## 4.4 Pantalla de edición de PEP — campos completos confirmados

La lista "Peps y Centros de Costos" (`operaciones.pe.ocesa.mx`) tiene un formulario de
edición con estos campos exactos: **IdPep** (auto), **Título** (la clave, ej.
"EI-PD-2017-08-14T009PP-A"), **Descripción**, **Categoria** (dropdown, valor "Pep"),
**Unidad De Negocio\*** (requerido), **Lugar Predeterminado**, **Terceros** (Si/No),
**Sociedad\*** (requerido, ej. "Ocesa RH"), **Año\*** (requerido), **Vigente** (Si/No).
Coincide 1:1 con `tc_partidas_presupuestales` (clave_pep, descripcion, categoria,
id_unidad_negocio, id_lugar_predeterminado, terceros, id_sociedad_propia, anio, vigente).

## 4.5 Lista "Eventos" — confirma `fecha_inicio`/`fecha_fin` explícitos

La lista real "Eventos" (`operaciones.pe.ocesa.mx/Lists/Eventos`) trae **IdEvento**,
**Título**, **Fecha Inicio**, **Fecha Fin** como columnas directas (no derivadas). Ejemplo
real: "Garbage & Blondie 2017", Fecha Inicio **13/03/2017**, Fecha Fin **14/08/2017** — un
proyecto de 5 meses. Confirma que `tc_eventos.fecha_inicio`/`fecha_fin` son campos reales
capturados directamente, no inferidos de los pedidos (como hice al sembrar los 75 eventos
reales — válido como aproximación, pero la fuente real los captura explícitamente).

## 4.6 Lista "Sociedades Pagadoras" — catálogo más amplio de lo sembrado

Columnas: **IdSociedadPagadora**, **Número de Sociedad**, **Título**,
**IdEmpresaPagadora**. Trae razones sociales de terceros (As Deporte, Car Sport Racing,
ETK Boletos, Grupo Automovilístico Nacional y Deportivo, ICESA, Make Pro, Ocesa
Anfiteatro, Ocesa Comercial, Ocesa Presenta, ...) además de las entidades propias de
OCESA — confirma que `tc_sociedades_pagadoras` (hoy 18 filas) es un catálogo
potencialmente más grande que lo ya sembrado desde los 180 pedidos.

## 4.7 Pantalla de Reservaciones — confirmación de campos y de un status nuevo

`apoyo.rh.ocesa.mx/Pedidos/ReservacionesPorDetalle.aspx` (accesible desde el menú
contextual de una celda de la matriz: **Editar / Reservaciones / Cancelar / Liberar**).
Campos: Pedido Detalle (selector), Título, Producto, Fecha de Entrega, Completo %,
Cantidad Solicitados, Cantidad Reservados Real, Cantidad Reservados, Cantidad Reservados
con Preasignados; campo **Empleado** (buscador por Id+Nombre) + botones **Confirmación
Forzada** / **Confirmación Preasignada**; grid "Personal Confirmado" (IdContacto, Nombre,
Status, link Cancelar); link "Imprimir lista de Asistencia".

**Status nuevo confirmado:** al usar "Confirmación Preasignada" el resultado real fue
**`CONFIRMADO OPCIONAL`** (no "CONFIRMADO FORZADO", que ya estaba documentado desde las
capturas de 2018 al usar la otra vía). Son dos flujos con dos estatus de reservación
distintos. **Verificado: `estado_reservacion_enum` ya tiene `confirmado_opcional` entre
sus 7 valores** (`disponible, preasignado, confirmado_opcional, confirmado_voluntario,
forzada, procesado, cancelado`) — sin gap, ya estaba bien modelado.

Además: al **Liberar** un pedido, la matriz completa cambia visualmente — todas las
celdas numéricas pasan de texto negro a **texto rojo**, y el encabezado muestra
"**Pedido Liberado**" en rojo en vez de "Registro Agregado" — señal visual de estado que
vale la pena replicar en la UI de PeopleMovil.

## 5. Fuera de alcance / no extraído

No se extrajeron capturas de pantalla embebidas (contienen nombres reales, fotos de
personas y datos bancarios/confidenciales). Si se necesita revisar el contenido visual
exacto de alguna pantalla específica, se puede abrir el `.mht` directamente en un
navegador local bajo supervisión del usuario.
