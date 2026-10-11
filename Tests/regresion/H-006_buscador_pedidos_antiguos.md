# Regresión — H-006 (buscador de "Pedidos y sitios" no encuentra pedidos fuera de los 100 más recientes)

## Causa raíz

`SitiosAsignacion.jsx` cargaba el listado completo de pedidos una sola vez al entrar al módulo:

```js
supabase.from('te_pedidos').select('*').order('fecha_evento', { ascending: false }).limit(100)
```

El cuadro de búsqueda ("Buscar por folio o título…") filtraba **solo sobre ese arreglo ya cargado**
(`pedidos.filter(...)` en un `useMemo`), nunca contra la base de datos. Cualquier pedido cuya
`fecha_evento` cayera fuera de los 100 más recientes —aunque existiera realmente en BD— era
"no encontrado" sin ningún aviso, dando la falsa impresión de que el registro no existía.

## Antes del fix

- Pedido #199 (`fecha_evento = 2018-09-01`, título "QA-R1-ESC02 - Dreamstate Mexico 2018") existe
  en `te_pedidos` pero **no aparecía** buscando "199", "Dreamstate" ni ningún texto relacionado.
- Prueba de control: buscar "Camila Cabello" sí encontraba resultados (folios con `fecha_evento`
  dentro de la ventana de los 100 más recientes), confirmando que el buscador en sí funcionaba —
  el problema era el universo de datos sobre el que buscaba, no la lógica de filtrado de texto.

## Fix aplicado

`SitiosAsignacion.jsx`: cuando el campo de búsqueda tiene texto, un `useEffect` (debounce 300ms)
dispara una consulta directa a `te_pedidos` con `.or('folio.eq.<n>,titulo.ilike.%texto%')` y usa
ese resultado (hasta 100 filas) en vez del listado precargado. Con el campo vacío, se mantiene el
comportamiento original (los 100 pedidos más recientes por `fecha_evento`). No se tocó el límite
de carga inicial ni se agregó paginación general — el buscador ahora sí llega a toda la tabla, que
era la queja real (un "no encontrado" falso en una función de búsqueda).

## Después del fix — probado end-to-end en el navegador (dev local, 2026-10-11)

1. Buscar "199" en "Pedidos y sitios" → aparece **#199 — "QA-R1-ESC02 - Dreamstate Mexico 2018"**,
   `fecha_evento 2018-09-01`, `borrador` (antes: 0 resultados).
2. Buscar "Camila Cabello" → sigue funcionando igual que antes (folios #16, #149, #121, todos con
   `fecha_evento` 2018, regresión negativa descartada).

## Fuera de alcance (documentado, no tocado)

"Árbol de reservaciones" (`ArbolReservaciones.jsx`) sigue sin mostrar pedido #199: su consulta
filtra explícitamente a `fecha_evento >= hoy-30días` (`.gte(...)`) y no tiene ningún cuadro de
búsqueda ni promesa de mostrar el histórico completo — es una vista jerárquica de "próximas
reservaciones", no un buscador. Se trata como alcance intencional, distinto del bug real del
buscador de "Pedidos y sitios" (que sí invita a buscar cualquier folio/título y fallaba en
silencio). No se modificó ese componente.
