# Regresión — H-005 (tp_sueldos_matriciales sin tarifas para PRG y otras UN)

## Antes del fix

```sql
select count(*) from tp_sueldos_matriciales
where puesto_id = '8054f331-bcaa-43f8-afa1-4634c9c9cd16'; -- Asistente Operador PRG
-- resultado: 0
```

Consecuencia observada en UI: en "Agregar detalle al pedido", con Tipo de Personal = "Personal de planta"
(Staff) y Unidad de Negocio = PRG, el combo "Producto" quedaba vacío — ningún producto matricial de PRG
tenía ninguna fila de tarifa, así que el filtro de `SitiosAsignacion.jsx` (que cruza `tc_puestos.matricial`
con `tp_sueldos_matriciales.tipo_complejidad_id`) no encontraba nada que mostrar.

## Fuente real usada para el fix

`Catalogos Sueldos Matriciales.xlsx` (compartido por el usuario 2026-10-11, mismo archivo citado en las
Migraciones 022/031 de `Dev/CLAUDE.md`), hoja "Sueldos Matriciales". Se filtró a tarifas realmente vigentes
(`Activo=1`, sin `FechaFin`, y con `IdTipoComplejidad` en el esquema vigente 14-19 — las filas con IDs 1-6
corresponden al catálogo de complejidad **no vigente**, confirmado en la hoja "Tipos de Complejidad en
Eventos" del mismo Excel, y se excluyeron). Sin inventar montos: solo se insertaron filas con todos sus
valores tomados literalmente del Excel.

Migración aplicada: `033_sueldos_matriciales_prg_y_otras_un_reales` (vía `apply_migration`, 2026-10-11).
63 filas nuevas para 14 puestos matriciales (8 de PRG, 5 de Producción, 1 de Teatros y Salones) que tenían
0 tarifas; no se tocaron los 5 puestos (Runner, Runner con/sin coche, Productor A/B) ya sembrados en la
Migración 022.

**Gap real que queda documentado, no inventado**: 80 puestos matriciales del Excel (de los cuales 9 ya
existen en `tc_puestos` pero con nombre no resoluble de forma inequívoca contra el Excel, y el resto
simplemente no tiene ninguna tarifa vigente en el legado real) siguen sin tarifa — ver hallazgos.md H-005
actualizado para la lista completa.

## Después del fix

```sql
select count(*) from tp_sueldos_matriciales
where puesto_id = '8054f331-bcaa-43f8-afa1-4634c9c9cd16';
-- resultado: 6 (una por cada una de las 6 complejidades vigentes)
```

### Prueba end-to-end en el navegador (2026-10-11, https://peoplemovil00.netlify.app, admin.demo01)

Pedido #200 (folio 200, id `32c3119c-fbd8-4546-9ab7-a1b8b74346e2`, el mismo pedido de prueba del
Escenario ESC-02) → "Matriz de puestos" → "+ Agregar detalle":

1. Tipo de Personal = "Personal de planta" (Staff real, no el sustituto `freelance` del primer pase).
2. El combo "Producto" mostró exactamente los 2 productos reales de PRG ("Asistente Aux A PRG",
   "Asistente Operador PRG") — ya no vacío.
3. Se seleccionó "Asistente Operador PRG" → la UI mostró "Puesto: Asistente Operador PRG · se maneja
   1 turno = 12 horas" (resuelve el puesto real ligado).
4. Fecha de cita 21/12/2026, Lugar de cita = Foro Sol, click en "Agregar registro".
5. El modal se cerró sin error y "Matriz de puestos" pasó de (0) a (1).

**Verificado en BD** (`te_pedidos_detalle`, pedido 200): nueva fila con
`puesto_id=8054f331-bcaa-43f8-afa1-4634c9c9cd16` (Asistente Operador PRG),
`producto_id=b65351c0-d844-4652-a950-509ec5fdda7e`, `id_tipo_personal` = Personal de planta,
`lugar_cita_id` = Foro Sol, `fecha_cita=2026-12-21`, `fecha_final_cita` calculada correctamente
(2026-12-21 18:00, consistente con 1 turno de 12h).

**Conclusión**: el hallazgo original del primer pase ("bug crítico bloqueante", reclasificado durante
la propia corrida como falso positivo de interpretación — ver `bitacora.jsonl` paso 0 intento 5) queda
confirmado como GAP_MIGRACION real y ahora **resuelto para los 8 puestos matriciales de PRG existentes
en el catálogo** (incluidos los 2 productos reales de la prueba ESC-02). Pendiente re-ejecutar los pasos
16-26 de ESC-02 (jornada, presupuesto por día, bloques, 2 productos) que antes eran NO EJECUTABLE por
esta misma causa raíz.
