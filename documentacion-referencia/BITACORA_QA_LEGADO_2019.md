# Bitácora de QA del legado (2019-03-19 / 2019-03-25) — 7 videos de regresión

Análisis de 7 videos cortos de regresión de QA sobre el sistema legado
(`integramx-001-site2...`), más uno adicional ya cubierto en
`SCREENSHOTS_ESCENARIO12.md` §7. Ninguno tiene transcripción de YouTube; se
recorrieron moviendo `video.currentTime` vía JS y tomando capturas en varios
puntos (no hay carpeta de frames extraídos para estos, a diferencia de los
videos más largos ya documentados).

Lo más valioso de este lote: **todos muestran, al inicio, la misma hoja de
cálculo `comentarios_freelance.xlsx`** — la bitácora real de bugs que el
equipo de QA de OCESA reportó sobre Lobo en marzo de 2019, escenario por
escenario. Cada video narra la fila correspondiente a "su" escenario y luego
muestra una repetición de la prueba en el sistema real. Juntando los frames
de los 7 videos se reconstruye casi toda la hoja (filas 1-29, escenarios 1-27).

## 1. Videos revisados

| Video | Título | Duración | Contenido confirmado |
|---|---|---|---|
| `https://youtu.be/KW84tG5iyPY` | R20190319 Escenario 08 | 0:28 | Hoja completa filas 1-14 (ver §2) |
| `https://youtu.be/VlMp3Lr4i-U` | R20190319 Escenario 05 | 1:30 | Reproduce "Escenario 05 Seriado_Con_Cancelación" — pantalla Detalles de pedido / Confirmación Forzada-Preasignada, caption "el segundo mensaje nos indica que el puesto no permite" |
| `https://youtu.be/h1IqworLK7M` | R20190319 Escenario 09 | 5:08 | Repite hoja filas 8-17; luego pantalla "Empleado" con alta manual (Tipo de empleado=Eventual, captura Apellidos/Nombre/Sexo/Régimen de pago/Banco) — confirma el bug de la fila 9 ("falta opción de crear empleado individual sin reclutamiento") |
| `https://youtu.be/TZA4CV4aSRg` | R20190319 Escenario 12 | 2:23 | Ya documentado en `SCREENSHOTS_ESCENARIO12.md` §7 |
| `https://youtu.be/eAa5oOgSGGQ` | R20190319 Escenario 20 | 2:44 | Hoja filas 18-26 + fila nueva "18 Escenario 17"; luego pantalla alta de Pedido ("Información General") con link "Agregar contacto" — confirma el bug de UX reportado en la fila de Escenario 20 |
| `https://youtu.be/dKN-sJJDRUs` | R20190319 Escenario 23 | 0:23 | Hoja filas 18-26 (mismo rango que el anterior, sin pantalla de sistema — video demasiado corto) |
| `https://youtu.be/9yg2k6PiJik` | R20190319 Escenario 25 | 1:33 | Pantalla "Asignación Folios" (`wp_asignacionfolios.aspx`) — empleado "Juan Pablo De La Torre Sánchez", coincide con lo ya documentado en `SCREENSHOTS_CICLO_COMPLETO.md` §2.18, sin hallazgos nuevos |
| `https://youtu.be/7hp0eQ9eEnE` | P20190325_0000 Escenario 27 Facturación | 5:44 | **Escenario nuevo, no documentado antes** — ver §3 |

## 2. Transcripción reconstruida de `comentarios_freelance.xlsx`

Columnas: # (B) · Fecha (C) · Escenario (D) · Comentario/bug (H) · Estado (col ~N).
Filas sin comentario visible se omiten. Texto tal cual aparece (incluye errores
de redacción del original).

| # | Fecha | Escenario | Comentario | Estado |
|---|---|---|---|---|
| 7 | 18/03/2019 | 5 — Escenario 05 | "Minuto 10:32. ¿Por qué al confirmar al empleado aparece el primer mensaje de error indicando que el empleado ya está asignado o se empalma con un evento? Siempre va a salir este error, porque no es correcto, solo debería aparecer el segundo mensaje de error." | Ocultar mensaje / Listo |
| 10 | 18/03/2019 | 8 — Escenario 08 | "Los nuevos empleados no deberían de ser confirmados forzosos hasta que se les marque como asistieron al evento de práctica. Tal cuál está en el sistema, si no asisten al evento se les va a pagar igual." | Listo |
| 11 | 18/03/2019 | 9 — Escenario 09 | "Sigue faltando la opción para crear un empleado de manera individual que no venga por reclutamiento." | Falta |
| 14 | 18/03/2019 | 12 — Escenario 12 | "Minuto 3:23: Al agregar el empleado sigue mostrando el error indicando que no cumple el perfil, el cuál no es correcto en este caso." | Ocultar mensaje / Listo |
| 18 | 19/03/2019 | 15 — Escenario 15 | "El mensaje de error al final es incorrecto. El sistema debe permitir reducir de 6 a 3 independientemente de las carteras de los empleados. Aquí sería para validar el cancelar a los de menor certeza, o veo de confirmación a los de último confirmo." | Cambiar mensaje para que cuando sea una modificación no aplique |
| — | — | — | "Es el mismo Escenario que aplica para el número 14." | — |
| (fila) | 19/03/2019 | 18 — Escenario 17 Pedido con 0.25 | "No aplica porque la diferencia entre las fechas de cita deben ser mayor a 4." | — |
| 34-35 | 19/03/2019 | 21 — Escenario 20 | "Sería bueno mejorar esta funcionalidad, ya que cuando se quiere agregar un contacto es para el cliente ya elegido en el pedido, es decir, no pedirle al usuario volver a buscar el cliente cuando se quiera asociar el contacto." | Listo |
| 37-38 | 19/03/2019 | 23 — Escenario 22 | "1) Minuto 4:44 - Corregir los mensajes de error. No tiene sentido que primero aparezcan dos diciendo que no cumple el perfil y luego le dejen agregarlo." | Ocultar mensaje / Listo |
| 39 | 19/03/2019 | 24 — Escenario 23 | "2) Escenario incompleto, falta la revisión de las pantallas de Pagos honorarios, así como entrar al detalle de los empleados para validar los import[es]. Escenario incompleto: De nuevo falta la validación sobre la pantalla de pagos honorarios." | (✓ verde, sin texto "Listo") |
| — | 19/03/2019 | 25 — Escenario 24 | "Escenario incompleto: 1) No hay revisión de la página de Pagos Honorarios. 2) ¿Dónde se valida que el detalle del pedido y folio aparece en las reservaciones procesadas con folio?" | Listo |
| — | 19/03/2019 | 26 — Escenario 25 | "En ningún video de nómina se alcanza a validar los conceptos de nómina que se van a pagar, que eran justo los escenarios que se quería revisar." | (amarillo, sin estado visible) |

## 3. Hallazgo nuevo: Escenario 27 — Facturación (sin documentar antes)

Video: `P20190325_0000 Escenario 27 Facturación` (5:44). No existe ningún
`SCREENSHOTS_ESCENARIO*.md` previo para este escenario ni para "Facturación"
en general fuera de lo ya modelado en el schema (`te_facturas_enc`,
`te_facturas_det`, Migración vista en `CLAUDE.md`).

### Pantallas vistas

1. **Pedidos (listado)** — columnas: Id Pedido, Título, Estatus, Unidad de
   negocio, Sucursal, Lugar, Responsable, Email, Teléfono Particular,
   **Folio Factura** (columna no documentada antes en los listados de
   Pedidos ya vistos — confirma que el folio de factura se puede ver desde
   el propio listado de pedidos, no solo entrando al detalle).
2. **Facturas (detalle)** — formulario con:
   - Status
   - **PeP | Descripción** (ej. "085-PD-2015-01-05 | Preventa Formula 1")
   - Fecha de movimiento
   - Sociedad propia
   - Unidad negocio (ej. "Seguridad")
   - Tipo (ej. "Factura")
   - Cliente (ej. "OCESA Promotora, S.A. de C.V.")
   - Lugar (ej. "Palacio de los Deportes")
   - **Pedido** (referencia directa al pedido origen, ej. "789 — Entrega 03
     Escenario 22 Validación de mensajes")
   - Grid de líneas: **Id producto**, **Producto**, **Cantidad**,
     **Precio Unitario**, **Sub Total** — captura muestra producto
     "Seguridad" con cantidad en edición.
   - Botones **Confirmar** / **Cancelar**.
   - Caption de narración en ese punto: "ahora está diciendo active una
     partida en mi producto la cantidad que se toma" — sugiere que hay una
     validación de que la línea de factura debe tener una cantidad > 0
     ("partida activa") antes de poder confirmarse.

### Relevancia para PeopleMovil

Confirma que el modelo `te_facturas_enc` (encabezado: cliente, pedido, PEP,
sociedad, unidad de negocio) + `te_facturas_det` (líneas: producto,
cantidad, precio unitario, subtotal) ya capturado en el schema **sí
corresponde fielmente** a la pantalla real "Facturas" del legado — no se
encontraron campos nuevos que falten en nuestro modelo, solo la columna
**"Folio Factura" visible en el listado de Pedidos** (UI, no dato nuevo:
`te_pedidos` ya puede unirse a `te_facturas_enc` para mostrarla) y la
validación de "partida activa" (cantidad > 0 por línea antes de confirmar),
que vale la pena confirmar si ya está implementada en el flujo de
facturación de PeopleMovil cuando se construya esa UI.

## 4. Patrón transversal detectado: mensajes de error en cascada, mal ordenados

Tres de las filas de la bitácora (Escenario 05, 12, 22) reportan **la misma
familia de bug**: el sistema legado mostraba un mensaje de error genérico
(traslape/empalme, o "no cumple el perfil") **antes** de evaluar la
condición real, y luego — a veces — dejaba continuar la acción de todos
modos, lo cual confundía al usuario con falsos positivos. Esto es
exactamente la clase de bug que se corrigió para el caso de "productos
similares" en la Migración 020 (ver `SCREENSHOTS_ESCENARIO12.md` §7):
**no reproducir este patrón** — la validación debe evaluarse una sola vez,
con la condición completa resuelta (incluida la cadena de similares/catálogo
cuando aplica), antes de decidir si bloquea o permite, en vez de mostrar
mensajes preliminares que luego se contradicen.

Recomendación para cuando se construyan las pantallas de "Confirmación
Forzada/Preasignada" más completas (fuera de Pre-asignación, si se llega a
replicar el flujo exacto "Detalles de pedido ▸ Reservaciones" del legado):
mantener el patrón ya usado en `tg_reservacion_valida()` — una sola
resolución, un solo mensaje, sin pasos intermedios que se autocontradigan.
