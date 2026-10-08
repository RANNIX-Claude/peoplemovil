# Escenarios de prueba del sistema Freelance/Lobo (QA real)

Volcado literal del archivo `Scripts de Prueba Freelance.xlsx` compartido por el usuario. Son pruebas QA reales ejecutadas sobre el sistema en operacion -- incluyen pasos, resultado esperado, si cumplio o no, y observaciones/bugs encontrados en su momento. Es una de las mejores fuentes para entender el comportamiento real pantalla por pantalla.

## Hoja: Resultado Pruebas

Escenario | Resultado | Observaciones |  |  |  |  |  |  |  |  |  |  |  |  | Pasa
1 |  |  |  |  |  |  |  |  |  |  |  |  |  |  | Error
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29

---

## Hoja: Escenario 1

Escenario 1 | Pedido para Metropólitan (Seguridad) - Sin Cancelación
PASOS | DESCRIPCIÓN | RESULTADO ESPERADO | Cumple  | No cumple | Observación | Corregido | Listo
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Ocesa |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente Ocesa | x
4 | Seleccionar un evento |  | X
5 | Seleccionar UN Seguridad | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora (en este caso Lobo) |  | X | Antes de seleccionar la UN la sociedad pagadora está por default con ID 10  | x
6 | Seleccionar el PEPS asociado a la UN | El sistema me muestra el nombre y la dirección del  inmueble | x
7 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movimiento (Pedido y Servicio Interno) |  | x | Únicamnete muestra "pedido" | x | x
8 | Seleccionar Tipo de movimiento Pedido | EL tipo Pedido se factura (validar posteriormente) | x
9 | En el campo Permitir Cancelar, seleccionar NO |  | x
10 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | x
 | Pedido Detalle
11 | Validar Estatus del Pedido | Debe estar en estado Normal |  | x | El estatus del pedido aparece como: NINGUNO | x
12 | Seleccionar Tipo de Personal Operativo | Validar que sólo se muestre Operativo por default ser un pedido de seguridad | x
13 | Validar que Tïtulo, Lugar de Cita, Facturable vienen prerellenos | Validar que se muestran todos los productos de Seguridad |  | x | Revisar filtros en el catálogo de productos para facilitar la consulta. El campo de facturable no viene prerelleno | x
14 | Seleccionar Producto Seguridad-MA |  | x
15 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas |  | x | No muestra la infromación | x | x
16 | Poner Cantidad 2 y Turnos 3 |  | x
17 | Seleccionar cualquier Fecha de Cita |  | x
18 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita | x
19 | Seleccionar una fecha correcta de liberación |  | x
20 | En presentación por producto, validar que sólo muentren las de la unidad de negocio |  | x
21 | Completar con similares - Marcar SI |  | x
22 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto)) | x |  | Revisar la validación de turnos por cantidad y si el nombre de producto está  en la matriz en la parte de descripción | EN PROCESO
23 | Al posicionarse sobre el producto debe mostrar | ID, Lugar de Cita, Fecha Cita, Fecha Fin Cita, Fecha Liberación, Completar con Similares, Cantidad Reservados, Cantidad Reservados Real, Cantidad Reservados con preasignación, Porcentaje Completo, Fase del Evento, Presentación |  | x | Revisar que estén en las tres pestañas todos los conceptos mencioandos, algunos los encontré, otros no. | EN PROCESO 
24 | En la flecha con los turnos debe mostrar | Editar, Reservaciones, Cancelar y Liberar |  | x | revisar punto una vez más con ayuda de Leo.. | EN PROCESO
25 | Pulsar sobre Cancelar Pedido | Validar que el estatus pasa a estado Cancelado |  | x | Se realizó correctamente la cancelación, sin emabrgo, nos mostro un error al querer regresar al menu de pedidos. Favor de revisar.  | x

---

## Hoja: Escenario 2

 | Pedido PRG-Producción con complejidad y días show
PASOS | DESCRIPCIÓN | RESULTADO ESPERADO | Cumple  | No cumple | Observación | Corregido | Listo
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Ocesa |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente Ocesa | x
4 | Seleccionar un evento |  | x
5 | Seleccionar UN PRG | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora (en este caso Lobo) | x
6 | Seleccionar el PEPS asociado a la UN | El sistema me muestra el nombre y la dirección del  inmueble | x
7 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movi+E10:F10miento (Pedido y Servicio Interno) |  | x | Únicamnete muestra "pedido" | x
8 | Seleccionar Tipo de movimiento Servicio Interno | EL tipo Pedido se factura (validar posteriormente) |  | x | Al no poder seleccionar el tipo de movimiento no sabemos si afecta en el procedimiento.  Nos aparece que no es facturable, pero se puede cambiar. | x
9 | Seleccionar Complejidad Foro Sol - 1 Día de Show | Validar que el sistema sólo muestra las 6 complejidades del catálogo |  | x | únicamnete muestra 3 opciones del foro sol, y dos son iguales.  | x
10 | Indicar 1 día de show en el campo Duración del Evento |  | x
11 | En el campo Permitir Cancelar, seleccionar NO |  | X
12 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | X
 | Pedido Detalle
13 | Tipo de personal | Validar que muestra Staff y Operativo | x
14 | Seleccionar Staff como Tipo de Personal |  | x
15 | Producto: Asistente Operador PRG - IN | Validar que el catálogo mostrado es el de PRG |  | x | El producto asistente operador PRG-IN no aparece si tomamos el tipo de personal staff, pero si tomamos el tipo de personal operativo sí aparece la opción  | BASE DE DATOS 
16 | Validar la jornada | Debe mostrar 1 turno por 12 horas, que es el turno asociado al producto |  | x | En ninguna parte aparece los turnos y las horas.  | x
17 | Seleccionar una fecha de cita y de liberación |  | x
18 | Presentación por producto | Validar que nos se muestran presentaciones | x |  | Aumo que en vez de "nos" hace referecnia a no 
19 | Fase del evento | Al ser Staff con complejidad y días de show debe mostrar No Aplica |  | x | En efecto noa plica, pero tanto en el escenario 1 y 2 aparecía así. Además se continuó conpersonal operativo y no de staff | EN PROCESO
20 | Agregar Registro | El sistema no lo permite, ya que al ser puestos de Staff, cada producto debe ir en un bloque nuevo
21 | Seleccionar nuevo Bloque
22 | Agregar Registro | Validar que el presupuesto día va ligado a la complejidad y los días de show
23 | Agregar nuevo pedido detalle
24 | Seleccionar producto: Asistente Auxiliar A
25 | Seleccionar nuevo Bloque
26 | Agregar Registro | Validar que se ha creado el nuevo bloque con el producto y los montos

---

## Hoja: Escenario 3

Escenario | Pedido PRG-Producción con complejidad y fase de evento
PASOS | DESCRIPCIÓN | RESULTADO ESPERADO | Cumple  | No cumple | Observación
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Ocesa |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente Ocesa | x
4 | Seleccionar un evento |  | x
5 | Seleccionar UN PRG | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora (en este caso Lobo) | x | x | La sociedad pagadora por dafult está con ID 10 | x
6 | Seleccionar el PEPS asociado a la UN | El sistema me muestra el nombre y la dirección del  inmueble | x
7 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movimiento (Pedido y Servicio Interno) |  | x | Únicamnete muestra "pedido" | x
8 | Seleccionar Tipo de movimiento Servicio Interno | EL tipo Pedido se factura (validar posteriormente) |  | x | Factura está determinado como de No por default  | x
9 | En complejidad indicar que No Aplica |  | x
10 | En el campo Permitir Cancelar, seleccionar NO
11 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | x
 | Pedido Detalle
12 | Tipo de personal | Validad que sólo se muestren Operativos al no tener complejidad | x
13 | Seleccionar Operativo |  | x
14 | Producto: Técnico Audio PRG - IN | Validar que el catálogo mostrado es el de PRG | x
15 | Validar la jornada | Debe mostrar 1 turno por 12 horas | x
16 | Seleccionar una fecha de cita y de liberación |  | x
17 | Presentación por producto | Validar que nos se muestran presentaciones | x
18 | Fase del evento | Validar que se muestran todos los valores del catálogo de Fase de evento | x
19 | Seleccionar Preparación como fase de evento |  | x
20 | Agregar Registro |  | x
21 | Agregar nuevo pedido detalle |  | x
22 | Producto: Técnico Audio PRG - IN | El sistema debe guardar el valor introducido anteriormente | x |  | Se guarda todo, a excepción de los turnos y la cantidad 
23 | Fase del evento: Montaje |  |  | x |  | EN PROCESO
24 | Agregar Registro | Validar que se ha creado el nuevo bloque con el producto y los montos |  | x |  | EN PROCESO
25 | Agregar nuevo pedido detalle |  |  | x |  | EN PROCESO
26 | Producto: Técnico Audio PRG - IN | El sistema debe guardar el valor introducido anteriormente |  | x |  | EN PROCESO
27 | Fase del evento: Show |  |  | x |  | EN PROCESO
28 | Agregar Registro | Validar que se ha creado el nuevo bloque con el producto y los montos |  | x |  | EN PROCESO
29 | Agregar nuevo pedido detalle |  |  | x |  | EN PROCESO
30 | Producto: Técnico Audio PRG - IN | El sistema debe guardar el valor introducido anteriormente |  | x |  | EN PROCESO
31 | Fase del evento: Desmontaje |  |  | x |  | EN PROCESO
32 | Agregar Registro | Validar que se ha creado el nuevo bloque con el producto y los montos |  | x |  | EN PROCESO

---

## Hoja: Escenario 4

Escenario 4 | Pedido para Azteca (Seguridad) - Futbol América vs Pumas
PASOS | DESCRIPCIÓN | RESULTADO ESPERADO | Cumple  | No cumple | Observación
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Coisa Consultores Industriales |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente | x
4 | Seleccionar un evento (Si no está crear uno) |  | x
5 | Seleccionar UN Seguridad | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora | x
6 | Seleccionar el PEPS LT-AZ-2018-01-01N085LT-A | El sistema me muestra el nombre y la dirección del  inmueble. Validar también que el lugar de cita es el Estadio Azteca | x
7 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movimiento (Pedido y Servicio Interno) |  | x |  | x
8 | Seleccionar Tipo de movimiento Pedido | EL tipo Pedido se factura (validar posteriormente) |  | x | Factura está determinado como de No por default  | x
9 | En el campo Permitir Cancelar, seleccionar NO |  | x
10 | Incluir un Responsable del Pedido |  | x
11 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | x
 | Pedido Detalle
12 | Validar Estatus del Pedido | Debe estar en estado Normal |  | x |  | x
13 | Seleccionar Tipo de Personal Operativo | Validar que sólo se muestre Operativo por default ser un pedido de seguridad | x
14 | Validar que Tïtulo, Lugar de Cita, Facturable vienen prerellenos | Validar que se muestran todos los productos de Seguridad | x
15 | Editar el Título | Validar que se puda editar el Título | x
16 | Seleccionar Producto Anfitrion-IN |  |  | x | Se seleccionó Anfitrión incluyente-IN
17 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas |  | x | En ningún momento se muestra esa información | x
18 | Poner Cantidad 40 y Turnos 1 |  | x
19 | Seleccionar cualquier Fecha de Cita |  | x
20 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita | x
21 | Seleccionar una fecha correcta de liberación |  | x
22 | En presentación por producto, validar que sólo muentren las de la unidad de negocio |  | x
23 | Completar con similares - Marcar NO |  | x
24 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido | x
25 | Seleccionar Producto Anfitrion Uncluyente-IN
26 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas |  | x
27 | Poner Cantidad 40 y Turnos 1 |  | x
28 | Seleccionar La misma fecha de cita que en el caso anterior |  | x
29 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita | x
30 | Seleccionar una fecha correcta de liberación |  | x
31 | En presentación por producto, validar que sólo muentren las de la unidad de negocio |  | x
32 | Completar con similares - Marcar NO |  | x
33 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
34 | Seleccionar Producto Control de Accesos - FE
35 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
36 | Poner Cantidad 30 y Turnos 1
37 | Seleccionar La misma fecha de cita que en el caso anterior
38 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
39 | Seleccionar una fecha correcta de liberación
40 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
41 | Completar con similares - Marcar NO
42 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
43 | Seleccionar Producto Control de Accesos - MA
44 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
45 | Poner Cantidad 30 y Turnos 1
46 | Seleccionar La misma fecha de cita que en el caso anterior
47 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
48 | Seleccionar una fecha correcta de liberación
49 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
50 | Completar con similares - Marcar NO
51 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
52 | Seleccionar Producto Local Crew - FE
53 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
54 | Poner Cantidad 40 y Turnos 1
55 | Seleccionar La misma fecha de cita que en el caso anterior
56 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
57 | Seleccionar una fecha correcta de liberación
58 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
59 | Completar con similares - Marcar NO
60 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
61 | Seleccionar Producto Local Crew - MA
62 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
63 | Poner Cantidad 100 y Turnos 1
64 | Seleccionar La misma fecha de cita que en el caso anterior
65 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
66 | Seleccionar una fecha correcta de liberación
67 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
68 | Completar con similares - Marcar NO
69 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
70 | Seleccionar Producto Seguridad - FE
71 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
72 | Poner Cantidad 50 y Turnos 1
73 | Seleccionar La misma fecha de cita que en el caso anterior
74 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
75 | Seleccionar una fecha correcta de liberación
76 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
77 | Completar con similares - Marcar NO
78 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
79 | Seleccionar Producto Seguridad - MA
80 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
81 | Poner Cantidad 70 y Turnos 1
82 | Seleccionar La misma fecha de cita que en el caso anterior
83 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
84 | Seleccionar una fecha correcta de liberación
85 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
86 | Completar con similares - Marcar NO
87 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
88 | Seleccionar Producto Seguridad Coordinador - MA
89 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
90 | Poner Cantidad 1 y Turnos 1
91 | Seleccionar La misma fecha de cita que en el caso anterior
92 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
93 | Seleccionar una fecha correcta de liberación
94 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
95 | Completar con similares - Marcar NO
96 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
97 | Seleccionar Producto Seguridad Supervisores - IN
98 | Validar que el sistema muestra las horas por turno de ese producto | Se muestra 1 turno por 8 horas
99 | Poner Cantidad 7 y Turnos 1
100 | Seleccionar La misma fecha de cita que en el caso anterior
101 | Seleccionar una fecha de liberación posterior | El sistema debe de mostrar una alerta por que no puede ser la fecha de liberación posterior a la fecha de cita
102 | Seleccionar una fecha correcta de liberación
103 | En presentación por producto, validar que sólo muentren las de la unidad de negocio
104 | Completar con similares - Marcar NO
105 | Agregar registro | Validamos que se muestra la Matriz de información (Fecha, hora, productos, Turnos, Totales (personal y monto))
Validar el ID del Detalle del pedido
El pedido debe quedar de la siguiente forma:

---

## Hoja: Escenario 5

 | Seriado con cancelación de un día para que no deje forzar ese día de otro pedido
PASOS | DESCRIPCIÓN | RESULTADO ESPERADO | Cumple  | No cumple | Observación
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Ocesa |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente Ocesa | x
4 | Seleccionar un evento |  | x
5 | Seleccionar UN Operaciones Inmuebles | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora  | x
6 | Seleccionar un PEP Temporal (Se identifican con Z-PEP) | Validar que el sistema por defecto no trae lugar de cita, ni inmueble | x
7 | Seleccionar un Lugar de Cita |  | x
8 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movimiento (Pedido y Servicio Interno) | x
9 | Seleccionar Tipo de movimiento Servicio Interno | EL tipo Pedido se factura (validar posteriormente) | x
10 | En complejidad indicar que No Aplica | Validar que para esta UN no aplica Complejidad (sólo muestra esa opción) | x
11 | En el campo Permitir Cancelar, seleccionar NO |  | x
12 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | x
 | Pedido Detalle
13 | Tipo de personal | Validad que sólo se muestren Operativos al no tener complejidad | x
13 | Seleccionar Operativo |  | x
13 | Producto: Especialistas Estructuras Inmuebles - IN | Validar que el catálogo mostrado es el de PRG | x
 | Cantidad 1 - Turno 1 |  | x
13 | Validar la jornada | Debe mostrar 1 turno por 12 horas |  | x
13 | Seleccionar una fecha de cita (debe ser un lunes) y de liberación |  | x
13 | Presentación por producto | Validar que nos se muestran presentaciones | x
13 | Fase del evento | Por Default pone No Aplica debido a la UN | x |  | El campo dice "Ninguno" en vez de "No aplica"
 | En Bloque por Producto seleccionar Nuevo Bloque |  | x
 | Agregar Registro |  | x
 | Incluir 4 detalles de pedido adicionales para completar la semana con las mismas caraterísticas | Confirmar que se crea todo en el mismo bloque | x
 | Será necesario liberar el pedido y que alguien confirme el bloque para el escenario
 | Cancelar el detalle de pedido del miércoles | El bloque sigue existiendo, solo que ahora tiene 4 días (lunes, martes, jueves y viernes)
1 | Crear un nuevo pedido |  | x
2 | Seleccionar cliente Ocesa |  | x
3 | Validar lista de contactos | Los contactos mostrados deben pertenecer al cliente Ocesa | x
4 | Seleccionar un evento |  | x
5 | Seleccionar UN PRG | El sistema despliega los PEPS de la UN de seguridad, y la sociedad pagadora  | x
6 | Seleccionar un PEP Temporal (Se identifican con Z-PEP) | Validar que el sistema por defecto no trae lugar de cita, ni inmueble | x
7 | Seleccionar un Lugar de Cita |  | x
8 | Validar tipo de movimiento | El sistema debe mostrar dos tipos de movimiento (Pedido y Servicio Interno) | x
9 | Seleccionar Tipo de movimiento Servicio Interno | EL tipo Pedido se factura (validar posteriormente) | x
10 | En complejidad indicar que No Aplica | Validar que para esta UN no aplica Complejidad (sólo muestra esa opción) | x
11 | En el campo Permitir Cancelar, seleccionar NO |  | x
12 | Pulsar Aceptar | El sistema genera un número consecutivo de pedido. | x
 | Pedido Detalle
13 | Tipo de personal | Validad que sólo se muestren Operativos al no tener complejidad | x
14 | Seleccionar Operativo |  | x
15 | Producto: Riger | Validar que el catálogo mostrado es el de PRG | x
16 | Cantidad 1 - Turno 1 |  | x
17 | Validar la jornada | Debe mostrar 1 turno por 12 horas | x
18 | Seleccionar una fecha de cita (debe ser el miércoles que se canceló) y de liberación |  | x
19 | Presentación por producto | Validar que nos se muestran presentaciones | x
20 | Fase del evento - Show |  | x
21 | No poner Bloque |  | x
22 | Forzar la asignación de la persona que confirmó el bloque anterior | El sistema no debe de dejar la asignación (en función del Puesto)
 | Realizar la misma prueba, cambiando la propiedad del puesto para que sí permita la confirmación entre seriados

---

## Hoja: Otros Escenarios Pedidos

Escenario 6: | Pedido de Transporte con empalme de horario |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un pedido con la UN Transportes |  |  |  |  |  |  |  |  | x
 | Crear un detalle con fecha de cita un día laborable a las 9am, con medio turno |  |  |  |  |  |  |  |  | x
 | Crear otro detalle con fecha de cita a las 10 am |  |  |  |  |  |  |  |  |  | x | Se puede realizar sin nignún prblema 
 | Validar que el sistema no permite generar el segundo detalle ya que el turno para el primer detalle es de 4 horas |  |  |  |  |  |  |  |  |  | x | El sistema no realiza ningún aviso
 | Validar que el sistema avisa de los detalles (Ids) con los que se está empalmando.
 |  |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
Escenario 7: | Comprobar fecha y hora  de liberación
 | Crear un pedido de UN Seguridad |  |  |  |  |  |  |  |  | x
 | Crear un detalle pedido con fecha de cita posterior al día en curso |  |  |  |  |  |  |  |  | x
 | Agregar una fecha  y hora de liberación del día en curso, con 1 hora posterior a la prueba
 | Validar en la página de reservaciones que el pedido se liberó a la hora programada.
 | Validar que el semáforo de los detalles de pedido se actualiza de color.
Escenario 8: | Validación de plazas |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Dar de alta un empleado de seguridad con fecha de incicio de puesto 15 de Febrero de 2019 ID(54943)
 | Validar que el sistema le asigna el sueldo por default correspondiente a su puesto. ($285)
 | Agregar  al empleado otra plaza del mismo puesto con fecha inicial del 20 de Febrero 2019 con $300 pesos
 | Crear un pedido de seguridad con dos detalles.
 | El primer detalle ponerle fecha de cita 10 de Febero de 2019
 | El segundo detalle ponerle fecha de cita del 21 de Febrero del 2019
 | Liberar el Pedido
 | El nuevo empleado, confirma el primer detalle del pedido
 | Validar que el sueldo va a salir en cero (ya que no tiene plaza vigente para esa fecha)
 | El nuevo emplealdo confirma el segundo detalle del pedido
 | Validar que el sueldo sale en $300 pesos
 | Entrar como administrador de nómina, y recorrer la fecha de inicio de puesto al 9 de Febrero
 | Validar que en pagos & honorarios se recalculó el monto del empleado y ya sale los $285
Escenario 9: | Validación de certeza valor |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un nuevo empleado de seguridad ID(57231)
 | Validar que su certeza valor es 0.9, que es la que tiene el puesto por default
 | Crear un pedido de seguridad con un detalle con cantidad 1.
 | Liberar el pedido
 | Validar que en la página de confirmación del empleado no le aparezca el evento
 | Volver a pedido y realizar una asignación forzada o preasignada del empleado.
 | El sistema no debe dejar realizar la asignación forzada.
Escenario 10: | Cancelación de preasignación forzada por no confirmación |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un pedido de seguridad |  |  |  |  |  |  |  |  | x
 | Crear un detalle de pedido con fecha del día siguiente a las 7pm solicitando 4 personas ID(3891,16338,33817,46486,54501)
 | Preasignar a cuatro empleados al pedido
 | Liberar el detalle
 | Entrar a la página de reservaciones con otro empleado de seguridad (ninguno de los 4 asignados) y validar que no pueden ver el pedido
 | Correr manualmente el proceso de cancelación de preasignados
 | Validar que el otro empleado de seguridad ya pueda ver el pedido
Escenario 11:  | Confirmación de personal sin puesto asignado vigente |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un empleado de seguridad ID(58172) |  |  |  |  |  |  |  |  | x
 | Crear un Pedido de control de accesos con un único detalle |  |  |  |  |  |  |  |  | x
 | Realizar una Pre-asignación del empleado de seguridad para el pedido de control de accesos |  |  |  |  |  |  |  |  | x
 | Validar que el sistema no permita la pre-asignación ya que el empleado no cuenta con el puesto requerido |  |  |  |  |  |  |  |  | x
 | Agregar el puesto de control de accesos al Empleado, con una fecha fin de puesto anterior al a fecha del evento |  |  |  |  |  |  |  |  | x
 | Realizar una Pre-asignación del empleado para el pedido de control de accesos |  |  |  |  |  |  |  |  | Las ventanas emergentes deben ser más precisas al indicar el error para ubicarlo. En este caso cumplió con certeza valor, perfil, vigencia y no fue posible identificar la falla.
 | Validar que el sistema no permita la pre-asignación ya que el empleado no cuenta con el puesto requerido
NOTA: Las pruebas de validación con pre-asignaciones se realizarán también en la página de reservaciones, ya que aplican las mismas reglas.
Escenario 12: | Productos similares |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Para el escenario se debe contar al menos con un empleado de control de accesos
 | Crear un pedido de seguridad |  |  |  |  |  |  |  |  | x
 | Crear un detalle indicando que no permita productos similares |  |  |  |  |  |  |  |  | x
 | Guardar y liberar el pedido |  |  |  |  |  |  |  |  | x
 | Realizar una asignación forzada de un empleado de control de acceso |  |  |  |  |  |  |  |  | x
 | Validar que el sistema no permite realizar esta asignación |  |  |  |  |  |  |  |  | x
 | Entrar a la página de reservaciones del empleado de control de accesos
 | Validar que no se muestra el pedido creado
 | Volver al detalle del pedido y editar para que permita productos similares
 | Realizar una asignación forzada de un empleado de control de acceso
 | Validar que el sistema permite realizar esta asignación
 | Entrar a la página de reservaciones del empleado de control de accesos
 | Validar que se muestra el pedido creado
Escenario 13: | Validar que no se puedan cancelar reservaciones |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un Pedido de Seguridad indicando que no se puede cancelar el evento
 | Crear un detalle de pedido, con fecha de cita  nás de 72 horas a partir de la hora actual
 | Marcar el detalle de pedido como que sí se puede cancelar
 | Guardar el detalle
 | Entrar al portal con un empleado de seguridad al portal
 | Confirmar el pedido
 | Cancelar la confirmación
 | El sistema no debe permitir realizar la cancelación
 | Editar el pedido para que permita cancelar
 | Editar el detalle para que no permita cancelar
 | Entrar  al portal con otro empleado de seguridad y confirmar el evento
 | Cancelar la confirmación
 | El sistema no debe permitir realizar la cancelación
 | Editar el detalle para que permita cancelar
 | Entrar a portal con otro empleado de seguridad
 | Confirmar el pedido
 | Cancelar la confirmación
 | El sistema debe permitir la cancelación
 | Crear un nuevo detalle con fecha de cita al día siguiente (menor a 72 horas)
 | Liberar el detalle del pedido |  |  |  |  |  |  |  |  | Agregar un botón de liberación inmediata
 | Entrar al portal con el empleado que canceló su confirmación
 | Confirmar el nuevo detalle
 | Cancelar la confirmación
 | El sistema no le debe dejar, ya que la fecha de cita es menor a 72 horas
 | Editar el segundo detalle creado (el último), y le sumo una hora a la fecha de la cita
 | Validar primero que se envia un correo electrónico a los confirmados avisando del cambio de horario
 | Entrar al portal con el último empleado que confirmó
 | Cancelar la confirmación
 | El sistema le debe permitir, ya que hubo un cambio en el horario
NOTA: Se realizará un escenario similar cambiando el lugar de cita y turnos, ya que el sistema se debe comportar de forma similar.
Escenario 14: | Pedido de matriciales para validar los sueldos |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Crear un pedido de Producción |  |  |  |  |  |  |  |  | x
 | La complejidad debe ser: "Foro Sol, Festivales hasta 50000 asistientes y plazas similares" |  |  |  |  |  |  |  |  | x
 | Duración de 2 días |  |  |  |  |  |  |  |  | x
 | Crear un detalle de Pedido con Puesto: "Asistente Operador - IN" |  |  |  |  |  |  |  |  | x
 | Liberar el pedido |  |  |  |  |  |  |  |  | x
 | Entrar al portal con un empleado que tenga ese puesto y confirmar el evento
 | Dentro del portal, ir a "Saldos"
 | Pulsar sobre el vínculo "Ver eventos por procesar"
 | Validar que aparezca los eventos confirmados no procesados
 | Validar que el importe para el pedido creado en este ecenario sea $24,525
Escenario 15: | Cancelación de asignación forzada
 | Crear un pedido de seguridad que permita la cancelación
 | Crear un detalle de pedido que permita la cancelación
 | Que la fecha de cita sea mayor a 72 horas
 | Realizar una asignación forzada para cualquier empleado (anotar ID)
 | Liberar pedido
 | Entrar al portal con el empleado al que se le realizó la asignación forzosa
 | Cancelar el evento
 | Validar que el sistema no permita la cancelación
Escenario 16: | Disminución de personal solicitado + Certeza valor
 | Para este escenario se necesitarán 6 empleados |  |  |  |  |  |  |  |  | x
 | Tres empleados con la misma certeza valor (0.9) ID(1,1962,2074) |  |  |  |  |  |  |  |  | x
 | Un Empleado con certeza (0.7) ID(2116) |  |  |  |  |  |  |  |  | x
 | Un Empleado con certeza (0.8) ID(2790) |  |  |  |  |  |  |  |  | x
 | Un empleado con certeza (1) ID( 2795) |  |  |  |  |  |  |  |  | x
 | Crear un pedido de seguridad |  |  |  |  |  |  |  |  | x
 | Crear un detalle con cantidad 5 |  |  |  |  |  |  |  |  | x
 | Realizar las siguientes asignaciones forzadas:
 | Primero dos empleados que valgan 0.9
 | Segundo el empleado 0.8
 | Tercero el empleado 0.7
 | Cuarto el otro empleado 0.9
 | Quinto el empleado que vale 1
 | Editar el detalle de pedido y reducir la cantidad de 5 a 3
 | En automático el sistema debe cancelar a los empleados que valen 0.7 y 0.8 (Los de menor certeza valor), y el último que confirmó de valor 0.9
 | Editar el detalle de pedido y reducir la cantidad de 3 a 2
 | En automático el sistema debe cancelar al último que confirmó con certeza valor 0.9
Escenario 17: | Prorrateo (PENDIENTE TIGRE)
 | Crear un pedido de Producción
 | La complejidad debe ser: "Foro Sol, Festivales hasta 50000 asistientes y plazas similares"
 | Duración de 2 días
 | Crear un detalle de Pedido con Puesto: "Asistente Operador - IN"
 | Liberar el pedido
 | Entrar al portal con un empleado que tenga ese puesto y confirmar el evento
 | Dentro del portal, ir a "Saldos"
 | Pulsar sobre el vínculo "Ver eventos por procesar"
 | Validar que aparezca los eventos confirmados no procesados
 | Validar que el importe para el pedido creado en este ecenario sea $24,525
Escenario 17: | Pedido con 0.25 Turnos
 | Creo un pedido de seguridad |  |  |  |  |  |  |  |  | x
 | Creo un detalle de pedido con turno 0.25, cantidad 1 y puesto "Seguridad - IN" |  |  |  |  |  |  |  |  | x
 | Poner una fecha inicial del día siguiente a las 9am |  |  |  |  |  |  |  |  | x
 | No poner fecha fin |  |  |  |  |  |  |  |  | x
 | Guardar el Detalle |  |  |  |  |  |  |  |  | x
 | Validar que en la cuadrícula se muestra 71.25 como costo de la nómina (Cantidad*Turno*SueldoBase) |  |  |  |  |  |  |  |  |  | x
 | Validar que al situar el cursor sobre la cuadrícula muestra fecha fin el día siguiente 11am |  |  |  |  |  |  |  |  |  | x
Escenario 18: | Lista Negra
 | Acceder a la pantalla de administración de Lista Negra con usuario de operación
 | Validar que el sistema no permita el acceso
 | Acceder a la pantalla de administración de Lista Negra con usuario con accesos (Arturo Pérez)
 | Validar que el sistema permita el acceso
 | Incluir a un empleado de seguridad, fecha inicial del día en curso, y como inmuble Palacio de los Deportes
 | Crear un pedido de seguridad en el Palacio de los deportes (con un PEP de Palacio) y un detalle de pedido posterior al día en curso
 | Guardar el detalle
 | Realizar una asignación forzada del empleado vetado al detalle creado
 | Validar que el sistema no permite realizar la asignación
 | Realizar una preasignación del empleado vetado
 | Validar que el sistema no permite realizar la pre-asignación
 | Libero el pedido
 | Entrar en la pantalla de reservaciones del empleado vetado
 | Validar que no se muestra el evento creado
Escenario 19: | Crear pedidos de fechas pasadas
 | Crear un pedido (da igual el tipo)  |  |  |  |  |  |  |  |  | x
 | Elegir cualquier PEP para el pedido |  |  |  |  |  |  |  |  | x
 | Crear un detalle de pedido con fecha inicio la semana anterior, y fecha fin dos días después |  |  |  |  |  |  |  |  | x
 | Guardar el detalle del pedido |  |  |  |  |  |  |  |  | x
 | Realizar una asignación forzada de cualquier empleado |  |  |  |  |  |  |  |  |  | x
 | El sistema debe permitir realizar la asignación forzada |  |  |  |  |  |  |  |  |  | x
 | Crear un nuevo pedido con las mismas fechas de inicio y fin |  |  |  |  |  |  |  |  |  | x
 | Guardar el detalle del pedido |  |  |  |  |  |  |  |  |  | x
 | Realizar una asignación forzada del mismo empleado |  |  |  |  |  |  |  |  |  | x
 | Validar que el sistema no permita realizar la asignación ya que tiene confirmado un evento para esas fechas (Mostrando el detalle que causa conflicto) |  |  |  |  |  |  |  |  |  | x
Escenario 20: | Relación de contacto-cliente
 | Aceeder a la pantalla de creación de contactos (sólo con el usuario de Axel)
 | Crear un nuevo contacto
 | Crear un nuevo pedido
 | Seleccionar un cliente 
 | Validar que no existe el nuevo contacto en el listado
 | Pulsar sobre agregar contacto
 | Validar que aparece el nuevo contacto creado
 | Agregar el nuevo contacto al cliente
Escenario 21: | Validar funcionalidad pantalla interna de reservaciones (Igual a la actual)
 | Buscar un empleado
 | Validar que muestra la siguiente información del empleado:
 |  | Puestos asignados vigentes
 |  | Sucursal
 |  | Género
 |  | % de puntualidad
 |  | Estatus
 |  | Nombre del empleado (Validar que sea un vínculo al catálogo de empleados)
 |  | Eventos disponibles (Color Verde)
 |  | Eventos disponibles no liberados (Color Negro)
 |  | Eventos Pre-Asignados (Color Naranja)
 |  | Eventos Confirmados (Color Morado)
 |  | Eventos en los que actualmente está trabajando (Color verde)
 | Validar que pulsando sobre cualquier evento (disponible o confirmado) muetra el detalle del pedido
 | A parte del detale del pedido, validar que se muetra un listado con los empleados confirmados y los empleados disponibles (Por puesto y empalme)
 | Pulsar sobre un evento disponible
 | Validar que en función de los permisos se muestra el botón de confirmación forzada o confirmación pre-asignada
 | Realizar una asignación forzada (evento-Empleado)
 | Pulsar sobre un evento confirmado
 | Validar que en función de los permisos, se muestra el botón de cancelar
 | Cancelar confirmación (Validar que sigue la misma lógica de las cancelaciones)
 | Validar que aparezca el árbol con las sucursales, eventos, y estado los pedidos
Validación de Visibilidad por sucursal/puesto
Justificación de Faltas (Validar que el porcentaje de asistencia se modifica)

---

## Hoja: Escenarios Nómina

Escenario 22: | Captura de lista manual de asistencia |  |  |  |  |  |  |  |  |  |  | Cumple  | No cumple | Observación
 | Para este escenario, será necesario crear un pedido de seguridad con fecha anterior al día en curso con un detalle, y que acepte productos similares. |  |  |  |  |  |  |  |  |  |  | x
 | Acceder a la pantalla para la captura de lista manual de asistencia |  |  |  |  |  |  |  |  |  |  | x
 | Se deben visualizar los 10 empleados a los que se le realizó la asignación forzada
 | Todos deben tener por defecto "Asistencia"
 | Marcar a dos de los empleados como "Falta"
 | Marcar a uno de los empleados como "Retardo"
 | Todos los demás deben tener "Asistencia"
 | Guardar la lista de asistencia
 | Ir a la pantalla de "Pagos Honorarios
 | Validar que los 10 empleados a los que se le ha procesado el pago aparecen los primeros y con "Periodo de Pago" 0
 | Validar que en la pantalla se muestre el Régimen , Número de Cuenta, Pago Bruto, Pago Neto, Unidad de Negocio, Solicitud de Pago, Empresa Pagadora
 | Entrar al detalle del empleado de Control de Accesos y/o Anfitrión con Asistencia
 | Validar los siguientes valores:
 |  | Pago Bruto | 285
 |  | SDP | 285
 |  | IM | 0.18
 |  | CF | 22.79
 |  | SA | 0
 |  | CG | 0
 |  | Impuesto Diario | 22.98
 |  | IT | 22.98
 |  | IVA | 0
 |  | RIVA | 0
 |  | RISR | 0
 | Entrar al detalle del empleado de Seguridad con Asistencia | Pago Neto | 262.02
 | Validar los siguientes valores:
 |  | Pago Bruto | 300
 |  | SDP | 300
 |  | IM | 2.58
 |  | CF | 22.79
 |  | SA | 0
 |  | CG | 0
 |  | Impuesto Diario | 25.38
 |  | IT | 25.38
 |  | IVA | 0
 |  | RIVA | 0
 |  | RISR | 0
 | Entrar al detalle del empleado de Seguridad con "Falta" | Pago Neto | 274.62
 | Validar los siguientes valores:
 |  | Pago Bruto | -300
 |  | SDP | 0
 |  | IM | 0
 |  | CF | 0
 |  | SA | 0
 |  | CG | 0
 |  | Impuesto Diario | 0
 |  | IT | 0
 |  | IVA | 0
 |  | RIVA | 0
 |  | RISR | 0
 | Entrar al detalle del empleado de Seguridad con "Retardo" | Pago Neto | 0
 | Validar los siguientes valores:
 |  | Pago Bruto | 150 | (*0.5 turnos por penalización de retardo) |  |  |  | Se validarán también combinaciones con los campos de los puestos:
 |  | SDP | 150 |  |  |  |  | "Penalización Retardo"
 |  | IM | 8.38 |  |  |  |  | "Penalización Falta"
 |  | CF | 0.37
 |  | SA | 0
 |  | CG | 0
 |  | Impuesto Diario | 8.75
 |  | IT | 8.75
 |  | IVA | 0
 |  | RIVA | 0
 |  | RISR | 0
 |  | Pago Neto | 141.25
 | Extas
Escenario 23: | Se toma como base el resultado del escenario anterior
 | Entrar a la pantalla de Extras
 | Crear un nuevo Extra
 | Introducir los siguientes valores:
 |  | IdEmpleado | El empleado de seguridad al que se validó el resultado del cálculo
 |  | IdEventoDetalle | El generado en el escenario anterior |  |  |  | En base a este ID, el sistema captura 
 |  | Turnos | 0.5
 | Dar a guardar | Concepto Extra | Pago Turno Extra |  | Aquí se validará el catálogo de Conceptos de Extra
 | Validar que Julio (o su perfil) no pueda Autorizar el Extra (sólo modificarlo)
 | Acceder con un usuario de Gerente de Nóminas (Arturo Pérez)
 | Ir a la pantalla de Extras
 | Filtrar por Estatus "En Espera"
 | Realizar una aprobación masiva de todos los extras "En Espera"
 | Volver a la pantalla de "Pagos Honorarios"
 | Busco el ID de empleado al que se le aplicó el Extra
 | Validar que el Pago Bruto pasa de $300 a $450
 | Dispersión de nómina y Validación de Lista de Precauciones
Escenario 24: | En base a los escenarios anteriores, y antes de continuar con los pasos, validar que al menos un empleado no tenga Empresa Pagadora
 | Entrar a la pantalla de Proceso Cierre de Nómina
 | Crear un nuevo elemento
 | Introducir Título y Periodo
 | Seleccionar que se ejecute la "Lista de Precauciones Previas al Cierre"
 | Dar a Guardar
 | Validar que al menos aparezca la precaución del empleado no tiene Empresa Pagadora
 | Validar el fichero de dispersión, donde deben estar 9 de los 10 empleados (el que no tiene empresa, no sale en el fichero)
 | Validar que los montos que se muestran son los revisados anteriormente
 | Validar que se actualizó el periodo de nómina
 | Asignación de folio para empleados con Honorarios Normales
Escenario 25: | Crear un pedido de producción con complejidad "Teatro Metropótinan" y días de show 1
 | Crear un detalle de pedido "Productor B"
 | La fecha de cita debe ser de al menos un día anterior al día en curso
 | Cantidad 1
 | Realizar una asignación forzada  de un empleado que tenga régimen honorarios normales
 | Acceder a la pantalla para la captura de lista manual de asistencia 
 | Validar que aparece el empleado asigando, como que asistió
 | Acceder a la pantalla de pagos honorarios
 | Validar que aparece el empleado asignado con periodo 0, pero que no muestra importe a pagar
 | Acceder a la pantalla de Asignación de Folios
 | Buscar al empleado asignado
 | Validar que en la pantalla aparecen los datos del empleado, reservaciones procesadas sin folio, y  las reservaciones procesadas con folio
 | En el apartado de reservacioens procesadas sin folio, aparece el detalle del pedido con un monto bruto a pagar
 | Asignar un número de folio fiscal y guardar.
 | Refrescar la pantalla, y validar que el detalle del pedido y folio aparece en las reservaciones procesadas con folio.
 | Regresar a la pantalla de pagos honorarios
 | Validar que el empleado aparece con periodo 0, pero en este caso ya cuenta con importe a pagar.
 | Pedidos de runners para validar los sueldos
Escenario 26: | Crear un pedido de producción con complejidad "Teatro Metropólitan" y 1 día de show
 | Crear un detalle de pedido con las siguientes características:
 |  | Puesto: "Runner"
 |  | Cantidad: 1 Turnos:1
 |  | Fase de Evento: Fase 4 Runner (Dia 4)
 | Agregar el Detalle | Fecha de Cita: Una semana antes a la fecha actual
 | Realizar una asignación forzada  de un empleado que tenga régimen honorarios normales
 | Acceder a la pantalla para la captura de lista manual de asistencia 
 | Validar que aparece el empleado asigando, como que asistió
 | Acceder a la pantalla de pagos honorarios
 | Validar que aparece el empleado asignado con periodo 0, pero que no muestra importe a pagar
 | Acceder a la pantalla de Asignación de Folios
 | Buscar al empleado asignado
 | Validar que en la pantalla aparecen los datos del empleado, reservaciones procesadas sin folio, y  las reservaciones procesadas con folio
 | En el apartado de reservacioens procesadas sin folio, aparece el detalle del pedido con un monto bruto a pagar
 | Asignar un número de folio fiscal y guardar.
 | Refrescar la pantalla, y validar que el detalle del pedido y folio aparece en las reservaciones procesadas con folio.
 | Regresar a la pantalla de pagos honorarios
 | Validar que el empleado aparece con periodo 0, pero en este caso ya cuenta con importe. Acceder al detalle del empleado
 | Validar los siguientes conceptos:
 |  | Días Laborados | 4
 |  | Pago Bruto | 5600
 |  | SDP | 0
 |  | IM | 0
 |  | CF | 0
 |  | SA | 0
 |  | CG | 0
 |  | Impuesto Diario | 0
 |  | IT | 0
 |  | IVA | 896
 |  | RIVA | 596.96
 |  | RISR | 560
 |  | Pago Neto | 5339.04

---

## Hoja: Escenario Facturación

Escenario 28: | Facturación
 | Tomar como base el resultado del Escenario 22
 | Agregar 4 detalles (para este escenario se puede poner cualquier valor para el detalle)
 | Sobre el pedido, Agregar una Factura
 | En la pantalla de nueva Factura
 | Validar que en la pantalla se muestran los siguientes campos (Tanto los prerrellenos como los no editables)
 | Seleccionar el primer detalle de pedido para facturar y generar la factura
 | Validar que se genera un folio para la factura
 | Validad que se puedan modificar la cantidad y el precio que aparecerá en la factura
 | Validar que se puedan agregar nuevas partidas
 | Volver a la pantalla de generación de factura
 | Validar que no te permite seleccionar el detalle ya procesado
 | Seleccionar los otros 4 detalles
 | Validar que se ha generado un nuevo folio de factura con 4 rubros correspondientes a los 4 detalles seleccionados
 | Validar que se puedan agrupar varios detalles en un rubro, y seleccionar un Producto
 | Validar que se pueda mostrar el detalle de rubros que se agruparon
 | Validar que el txt que se envía a SAP contiene la información requerida.
Escenario 28: | Validar que en el txt sólo se generan facturas (Y no servicios internos)
 | Facturar el pedido del escenario 26
 | Seleccionar como Tipo de Movimiento "Servicios Internos"
 | Generar un fólio para la factura (Validar que no es consecutivo de las facturas)
 | Generar el txt para este folio de factura
 | Validar que no se generó ningún txt

---

## Hoja: Escenario Prorrateo

Escenario 29: | Prorrateo de sueldos matriciales
 | Generar un pedido de producción con complejidad "Autorio Nacional" y con 3 días de Show
 | Dar de alta 1 detalle con 1 puesto de "Productor A"
 | Agregar detalle
 | Validar que en la cuadrícula se muestra el importe total correspondiente a los 3 días Show (100%-50%-50%)
 | Agregar un nuevo detalle con fecha cita al día siguiente
 | Validar que en la cuadrícula se muestra el importe total correspondiente a los 3 días Show (100%-50%-50%), pero repartidos en los dos detalles (50%-50%)
 | Agragar dos nuevos detalle con fecha cita consecutiva
 | Validar que en la cuadrícula se muestra el importe total correspondiente a los 3 días Show (100%-50%-50%), pero repartidos en los cuatro detalles (25%-25%-25%-25%)

---
