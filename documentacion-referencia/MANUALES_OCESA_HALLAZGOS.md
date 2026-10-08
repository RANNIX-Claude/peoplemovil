# Hallazgos de los Manuales de Usuario OCESA (Sprint 01-03)

Fuente: `C:\work\PeopleMovil\Dev\Compartir OCESA\Entregas\Manual Usuario\Manual Usuario\` — 16 documentos Word reales (manuales + "funcionalidad desarrollada") organizados por Sprint y por número de historia de usuario (HU), ej. "2.01 Registro de pedido", "9.03 Usuarios, Roles y perfiles".

**Nota metodológica importante:** la mayoría de estos documentos son narrativa de navegación a nivel UI ("dar clic en el botón X", "pulsar Confirmar") con capturas de pantalla embebidas como imágenes (no extraíbles como texto) — varios incluso traen la nota literal sin terminar **"(Nota: Realizar una descripción)"** dejada por el propio equipo de documentación de OCESA. No tienen el nivel de detalle de campos/reglas de negocio que sí dan las capturas de los 26 escenarios de prueba ya analizados (`SCREENSHOTS_*.md`). Su valor está en confirmar la estructura de módulos/pestañas y en unos pocos datos nuevos genuinamente útiles, listados abajo.

**Carpetas que solo tienen `desktop.ini` (manual nunca se escribió):** Sprint 03 → "2.04 Pre asignación de personal", "2.05 Confirmación de asistencia", "3.11 Registro manual de asistencia y anexos", "9.80 Migración de datos de Catálogos", "9.82 Migración de datos Históricos de pagos". Confirma que la documentación formal de esos módulos quedó incompleta — para esos ya dependemos enteramente de las capturas de escenarios de prueba.

---

## 1. Pedido ≈ Proyecto — confirmado el concepto, PERO Sector/Entidad Federativa/Promotor son texto de intención, NO implementado

De "Funcionalidad desarrollada 2.01" (Sprint 01), primer párrafo:

> "El módulo de pedidos tiene como objetivo permitir el registro de los datos referentes a cada **proyecto**, es decir el nombre, **el sector**, en qué **Entidad Federativa** se desarrolla, quién es el **promotor**, quién es el **responsable ante la Unidad de Negocio**, entre otros datos."

Esto confirma el concepto que el usuario explicó sobre Fórmula 1 como "proyecto/evento". **Pero verificado contra las fuentes reales (`TE_Pedido` 40 columnas SQL Server, `dbo_Pedidos` 46 columnas Access, y los 26 escenarios de capturas de pantalla), ninguno de los 3 campos existe realmente:**
- **Sector**: no existe en `TE_Pedido` ni `dbo_Pedidos`. Lo único parecido en todo el XPZ es `TE_FacturaEncSector`, un campo de **Facturación** sin relación con Pedidos.
- **Entidad Federativa**: no existe en ninguna tabla real de Pedido (sí existe el campo `Id sucursal`/`TC_SucursalID`, que es lo más cercano, pero es un catálogo fijo de 5 sucursales, no un campo libre de estado).
- **Promotor**: no existe como campo. Los "hits" al buscarlo en las capturas eran falsos positivos — la palabra "Promotora" dentro del nombre del cliente real "OCESA Promotora, S.A. de C.V.", no un campo de formulario.

**Conclusión:** esta frase es texto de intención/planeación del sprint, escrito antes de que se definiera bien el alcance real — nunca se implementó. No se agrega al esquema. El resto de la descripción del módulo (Cliente, Unidad de Negocio, PEP, Responsable, etc.) sí está confirmada por las fuentes reales y ya está modelada.

## 2. Requisición de Personal — módulo separado, upstream de Pedidos

De "Funcion desarrollada 1.11" + "Manual Requisición de personal" (Sprint 01, idénticos en contenido):

Campos confirmados: **Fecha de requisición**, **Fecha Requerida**, **Estatus** (catálogo), **Puesto** (tabla de renglones — botón "Nueva Fila" para agregar más puestos a la misma requisición).

Esto encaja exactamente con lo que el usuario describió: el correo donde el cliente interno dice "voy a necesitar tantos guardias, tantos meseros" — **Requisición de Personal parece ser la versión formal/sistematizada de esa solicitud**, anterior y distinta del Pedido real. Ya existe como módulo separado en el dashboard React (`Requisiciones de personal`), pero no tengo confirmado si hay una relación formal (FK) entre una Requisición y los Pedidos que de ahí se generan — los manuales no lo aclaran, solo describen el CRUD de la requisición en aislado. **Pendiente de validar con capturas de pantalla reales si existe esa conversión Requisición→Pedido, o si son procesos independientes que solo coinciden en los mismos puestos/fechas.**

## 3. Pedido — estructura de pestañas confirmada (coincide con lo ya construido)

Detalle de un pedido = 3 pestañas: **Información principal de pedido**, **Matriz de puestos**, **Movimientos Detalles pedido** — coincide 1:1 con las pestañas ya implementadas en `SitiosAsignacion.jsx` ("general" / "Matriz de puestos" / "Movimientos/Reservaciones"). Buena señal de que la estructura de la UI ya está bien encaminada.

Acciones de pedido confirmadas en la barra superior: **Editar**, **Liberar**, **Cancelar**, **Eliminar** (doble clic para eliminar — confirma el patrón de "doble clic para acciones destructivas" ya visto en otros módulos).

## 4. Alta de Candidatos — estructura de pestañas y documentos

Candidato tiene 3 pestañas al visualizar: **General**, **Postulación vacante candidato** (con 3 sub-pestañas: Datos generales, Recepción [asistencia+documentación con hora/fecha], Entrevista [archivos+observaciones]), y **Seguimiento candidatos**.

Documentos que se suben (solo jpg/png): **IFE/INE**, **CURP**, **Comprobante de Domicilio**, **Acta de nacimiento**. Aparte, en la pestaña de evaluación se sube un archivo de **"Reporte de evaluación"**. Campos médicos: sección de "estudios médicos" donde se puede omitir si no hay enfermedades (sugiere un campo de condiciones médicas opcional, no obligatorio).

## 5. Seguimiento Candidato — submenú completo con las 5 etapas reales

Confirmado desde "funcionalidad desarrollada 1.15" (la más completa, 168 líneas) + "1.14":

1. **Candidatos postulados** — confirmar asistencia + validar documentación completa
2. **Grupos para citas** — activar/desactivar para continuar en el proceso
3. **Candidatos para entrevista** — captura: **Examen Psicométrico**, **Observaciones de Examen**, **Observaciones de entrevista**, **Asignación de Curso de inducción y evento prueba**, **Resultado de la solicitud**
4. **Candidatos Curso de inducción** — **Observaciones del Curso**, **Calificación al Curso**, **Confirmación de Asistencia al Curso**
5. **Candidatos Evento Prueba** — mismos 3 campos que el paso anterior (Calificación, Observaciones, Confirmación de Asistencia), aplicados ahora al evento prueba en vez del curso

Campos nuevos no vistos antes en capturas: **Examen Psicométrico** (como campo de captura, no solo el examen en sí) y **Calificación al Curso** (nota/score del curso de inducción, distinto del solo booleano de asistencia).

## 6. Portal candidato (lado público) — flujo de postulación confirmado

De "funcionalidad desarrollada 1.02" (Calendario de entrevistas):

Candidato ve la Publicación de vacante → botón **"Consultar"** → pantalla con datos generales de la vacante → botón **"Postularme"** → calendario de fechas/horas disponibles (agrupadas, según disponibilidad) → botón **"Agendar"** → correo de confirmación con los datos de la vacante, documentos, requisitos y funciones.

Esto es el flujo público real de postulación — confirma que "Publicación de vacantes" (que ya habíamos visto como pantalla admin en `SCREENSHOTS_ALTA_VACANTES.md`) tiene su contraparte candidata, con un paso de auto-agendado de cita grupal que coincide con "Grupos para entrevistas" visto en `SCREENSHOTS_CICLO_COMPLETO.md`.

## 7. Usuarios y Roles — nada nuevo relevante al negocio

Confirma solo funcionalidad GAM estándar (bloqueo de usuario, expiración de contraseña, herencia/copia de roles, asignación de permisos por aplicación) — ya excluido del análisis de negocio por instrucción del usuario (es framework interno de GeneXus).

---

## 8. Preguntas abiertas para el usuario

1. ¿Existe una relación formal Requisición de Personal → Pedido (conversión 1:1 o 1:N), o son procesos independientes?
3. Dado que varios manuales de Sprint 03 nunca se escribieron (Pre-asignación, Confirmación de asistencia, Registro manual de asistencia, Migraciones), ¿hay otra fuente para esos módulos además de las capturas de pantalla ya analizadas?
