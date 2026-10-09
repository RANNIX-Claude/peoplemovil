# Árbol completo del menú — sistema legado Lobo/AppSCPF (OCESA, GeneXus)

Consolidado el 2026-10-09 a partir de **24 documentos** de `documentacion-referencia/`
(capturas de pantalla de distintos videos/escenarios de prueba, 2018-2019).
No es una sola captura: es la unión de todo lo que distintas sesiones de
análisis fueron encontrando. Donde dos fuentes se contradicen, **se listan
ambas versiones explícitamente** en vez de elegir una — ver §8.

Complementa a `MENU_Y_ROLES.md` (modelo de permisos GAM, roles, captura de
2018 con agrupación "por Sprint") y a `NOTIFICACIONES_RECLUTAMIENTO.md`
(flujo de reclutamiento con foco en notificaciones).

---

## 0. Resumen — navbar superior (rol Administrador, build 2019)

```
RRHH          Inicio | Recursos humanos | Operaciones | Nómina | Catálogos | Seguridad sistema | (Variables) | Salir
```

Confirmado en 7+ fuentes independientes. El ítem **"Variables"** solo aparece
en 2 de esas fuentes (`SCREENSHOTS_ESCENARIO14.md`, `_15.md`) — ver
contradicción #1 en §8. Nunca se vio su contenido expandido en ningún
documento.

El navbar **se filtra por rol** (confirmado en `SCREENSHOTS_ESCENARIO4.md`):
un usuario con rol "Operacion" solo ve `Inicio | Operaciones | Salir`.

Hay además **dos portales separados** con su propio navbar, no accesibles
desde este menú principal — ver §6 y §7.

---

## 1. Recursos humanos ▾

```
Recursos humanos
├── Cartera de talento
├── Base de candidatos
├── Vacantes ▸
│   ├── Perfil de puesto
│   ├── Publicación vacantes
│   ├── Grupos a entrevistas          ⚠️ ver contradicción #3
│   ├── Cursos de inducción           ⚠️ ver contradicción #3
│   └── Eventos prueba                ⚠️ ver contradicción #3
├── Folios
├── Requisición de personal
└── Proceso de Reclutamiento ▸
    ├── Asistencia por Grupos         ⚠️ ¿= "Grupos a entrevistas"?
    ├── Firma de contratos
    ├── Cursos de inducción           ⚠️ ver contradicción #3
    ├── Eventos prueba                ⚠️ ver contradicción #3
    ├── Empleados
    ├── Baja empleado
    ├── Reactivación empleado
    └── Cambio de banco o clabe interbancaria
```

Fuentes: `SCREENSHOTS_ALTA_VACANTES.md`, `SCREENSHOTS_CICLO_COMPLETO1.md`,
`SCREENSHOTS_CAMBIO_ETIQUETA.md`, `SCREENSHOTS_ESCENARIO18.md`,
`NOTIFICACIONES_RECLUTAMIENTO.md`.

Mapeo PeopleMovil ↔ este submenú: ver `NOTIFICACIONES_RECLUTAMIENTO.md` §2
(historia paso a paso) — `EntrevistaGrupal.jsx` ≈ "Asistencia por Grupos",
`FirmaContratos.jsx` ≈ "Firma de contratos", `CursoInduccion.jsx` ≈
"Cursos de inducción".

---

## 2. Operaciones ▾ (16 ítems — el único menú con listado completo confirmado)

```
Operaciones
├── Contactos
├── Clientes
├── Contactos clientes
├── Eventos
├── Lugares de Cita
├── Unidad de Negocio
├── Carga masiva Peps
├── Peps masivos
├── Peps y Centros de Costos
├── Pedidos
├── Facturación
├── Listas de asistencia
├── Registro manual de asistencia
├── Consulta reservaciones
├── Requisición de Personal
├── TimeScan por Empleado
└── TimeScan por Detalle Pedido
```

Fuente principal: `SCREENSHOTS_CICLO_COMPLETO.md`. Confirmación parcial
(subconjunto visto dentro del detalle de un pedido, sin contradicción):
`SCREENSHOTS_ESCENARIO5_ENTRESERIADOS.md`.

---

## 3. Nómina ▾ (18 ítems confirmados — lista probablemente incompleta)

```
Nómina
├── Alta masiva de empleados
├── Alta individual empleado
├── Listado de empleados              ⚠️ ver contradicción #4
├── Desactivación empleado
├── Reactivación empleado
├── Cambio de cuenta de banco
├── Observaciones empleado
├── Plazas empleados
├── Sueldos matriciales ▸             (contenido nunca capturado)
├── Listas de asistencia              ⚠️ ver contradicción #4
├── Alta Masiva extras
├── Extras
├── Autorización Extras
├── Asignación de folios
├── Pago de honorarios
├── Cierre de nómina
├── Dispersión nómina
├── Lista negra
└── Aclaraciones
    └── (el menú se corta aquí en el viewport en las 2 fuentes — puede
        haber más opciones abajo, nunca confirmado)
```

Fuentes: `SCREENSHOTS_CICLO_COMPLETO.md`, `SCREENSHOTS_CICLO_COMPLETO3.md`,
`SCREENSHOTS_ESCENARIO9.md` (con las variantes de nombre de la
contradicción #4).

---

## 4. Catálogos ▾ (contenido completo — única fuente: Escenario5_EntreSeriados)

```
Catálogos
├── Pedidos ▸
│   ├── Clientes                      ⚠️ ver contradicción #5 (solapa con Operaciones)
│   ├── Contactos clientes            ⚠️ ver contradicción #5
│   ├── Complejidad
│   ├── Eventos                       ⚠️ ver contradicción #5
│   ├── Estatus detalle pedido
│   ├── Estatus pedidos
│   ├── Fases de eventos
│   ├── Lugares de cita               ⚠️ ver contradicción #5
│   ├── Movimientos pedidos
│   ├── Pep                           (pantalla real se titula "Presupuestos", tc_pepww.aspx)
│   ├── Presentación de producto
│   ├── Sociedades pagadoras
│   ├── Sucursales
│   ├── Tipo de personal
│   └── Unidades de negocio           ⚠️ ver contradicción #5
└── Otros ▸
    ├── Ciudades
    ├── Códigos postales
    ├── Colonias códigos postales
    ├── Claves para Puestos
    ├── Estados
    ├── Medios
    ├── Parámetros del sistema
    ├── Periodicidad
    ├── Puestos
    ├── Productos
    ├── Reglas de asistencias
    └── Responsables
```

Fuente: `SCREENSHOTS_ESCENARIO5_ENTRESERIADOS.md` (única fuente con el
contenido expandido de ambos submenús).

---

## 5. Seguridad sistema ▾ (framework GAM estándar — casi sin documentar)

```
Seguridad sistema
├── Usuarios          (gamwwusers.aspx)
├── Roles             (gamwwroles.aspx)
└── Permissions of Role: <X>   (gamwwrolepermissions.aspx)
```

Es funcionalidad estándar de GeneXus Access Manager, sin reglas de negocio
propias — excluida a propósito del análisis funcional en su momento
(`MANUALES_OCESA_HALLAZGOS.md`). Ver `MENU_Y_ROLES.md` para el modelo de
permisos granular (`<objeto>_<Accion>: Insert/Update/Delete/Execute/FullControl`).

⚠️ Catálogo de roles con fuerte contradicción entre épocas — ver #6 en §8.

---

## 6. Portal "AdminPersonal" — navbar propio, independiente del menú principal

```
Inicio | Empleados ▾ | Otros procesos ▾ | Salir

Empleados ▾
├── Empleados
├── Alta masiva de empleados
├── Alta individual empleado
├── Baja empleado
├── Reactivación empleado
├── Observaciones empleado
├── Consulta registro TimeScan
└── Cambio de cuenta de banco

Otros procesos ▾
└── (contenido nunca capturado — se especula que podría vivir aquí la
    cancelación automática de preasignados, que en PeopleMovil sí existe
    como función/trigger pero en el legado no se le encontró pantalla
    propia en los menús navegados)
```

Fuentes: `SCREENSHOTS_ESCENARIO10.md`, `SCREENSHOTS_ESCENARIO11.md` (2
fuentes consistentes).

---

## 7. Portal "Freelance" (self-service externo, candidato/empleado)

```
Comunicados generales | Calendario de eventos | Saldos | Confirmación de eventos | Aclaraciones | Salir
```

Fuentes: `SCREENSHOTS_ESCENARIO5.md`, `_5AB.md`, `_7.md`, `_10.md` — 4
fuentes consistentes, sin contradicción. Equivale conceptualmente al portal
freelance ya construido en PeopleMovil (`/portal`), aunque con otros nombres
de pestaña (Publicaciones, Mis eventos, Mis pagos, Perfil).

---

## 8. Contradicciones encontradas (señaladas, no resueltas arbitrariamente)

| # | Contradicción | Fuentes en conflicto |
|---|---|---|
| 1 | ¿Existe "Variables" como 7º menú del navbar principal? | `SCREENSHOTS_ESCENARIO14.md`/`_15.md` (sí) vs `NOTIFICACIONES_RECLUTAMIENTO.md`/`CICLO_COMPLETO1.md` (no, solo 6) |
| 2 | Menú agrupado **por Sprint** (2018) vs **por área de negocio** (2019) | `MENU_Y_ROLES.md` vs todo lo demás — casi seguro son builds de épocas distintas, no verdadera contradicción, pero confirma que el menú cambió de estructura en el tiempo |
| 3 | "Cursos de inducción"/"Eventos prueba" aparecen tanto bajo `Vacantes ▸` como bajo `Proceso de Reclutamiento ▸`; "Grupos a entrevistas" (Vacantes) vs "Asistencia por Grupos" (Proceso de Reclutamiento) — ¿son la misma pantalla con 2 rutas de menú, o nombres mal transcritos? | `SCREENSHOTS_CAMBIO_ETIQUETA.md`/`_18.md` vs `CICLO_COMPLETO1.md`/`NOTIFICACIONES_RECLUTAMIENTO.md` |
| 4 | "Listado de empleados" vs "Lista de empleados"; y en la misma posición del menú Nómina aparece "Listas de asistencia" en una fuente y "Registro manual de asistencia" (que en otra fuente vive en el menú Operaciones) en otra | `CICLO_COMPLETO.md`/`_3.md` vs `ESCENARIO9.md` |
| 5 | Varios ítems de `Catálogos → Pedidos` (Clientes, Contactos clientes, Eventos, Lugares de cita, Unidades de negocio) tienen el mismo nombre que ítems del menú `Operaciones` directo — ¿accesos duplicados a la misma pantalla, o catálogos distintos con nombre igual? | Sección 2 vs sección 4 de este documento |
| 6 | Catálogo de Roles: **5 roles** en 2018 (`Unknown, Administrador, Lobo, Operacion, Candidato`) vs **9+ roles** en 2019, página 1 de 2 (`Unknown, Administrator, RRHH, Candidato, Operación, Administración de Personal, Freelance, Pedidos, Ventas`) — nombres no coinciden (mayúscula/idioma), el rol "Lobo" solo existe en la fuente de 2018, y la página 2 de 2019 nunca se capturó | `MENU_Y_ROLES.md` vs `SCREENSHOTS_ESCENARIO9.md` |
| 7 | "Seguimiento Candidato" (5 etapas, de manuales escritos) vs "Proceso de Reclutamiento" (8 opciones, de capturas de pantalla en vivo) — nombres no coinciden 1 a 1, no se puede mapear con certeza | `MANUALES_OCESA_HALLAZGOS.md` vs `SCREENSHOTS_CICLO_COMPLETO1.md` |

## 9. Lo que sigue sin documentar en ningún archivo (huecos confirmados, no omisión de esta pasada)

- Contenido expandido de **Variables ▸**.
- Contenido expandido de **Sueldos matriciales ▸** (dentro de Nómina).
- Contenido de **Seguridad sistema ▸** más allá de las 3 pantallas genéricas de GAM.
- Contenido de **Otros procesos ▾** (portal AdminPersonal).
- Página 2 completa del listado de Roles (`gamwwroles.aspx`).
- El resto del menú Nómina después de "Aclaraciones" (cortado en viewport en ambas fuentes que lo muestran).

## 10. Nota aparte — herramienta de QA, no parte del menú real

`ImportarDatos` (`SCREENSHOTS_CICLO_COMPLETO1.md`): app interna de GeneXus
para generar datos sintéticos de prueba (Vacantes, Pedidos, Candidatos). No
es parte del sistema productivo Lobo ni de su menú — se excluye a propósito
de este árbol.
