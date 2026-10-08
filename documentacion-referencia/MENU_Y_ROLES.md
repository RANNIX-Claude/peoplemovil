# Menú y roles reales del sistema (capturas de pantalla, 2018)

Fuente: capturas embebidas en `Manual Usuario/Sprint 01/9.03 Usuarios, Roles y perfiles/funcionalidad detallada 9.03 (1).docx`, mas una captura de la pantalla real de Pedidos (`localhost/AppFreelanceTempLocal` y `rintegra-001-site1.atempurl.com`). Esto es GAM (el framework de seguridad de GeneXus), confirmado por las URLs `gamwwusers.aspx`, `gamwwroles.aspx`, `gamwwrolepermissions.aspx`.

## Roles definidos

De la pantalla "Roles" (`gamwwroles.aspx`), los 5 roles reales del sistema eran:

| Rol | Uso probable (por contexto de las demas capturas) |
|---|---|
| **Unknown** | Rol por defecto de GAM para usuario no autenticado/no asignado |
| **Administrador** | Control total -- usuario "Roberto Aguilar" (admin) tenia este rol |
| **Lobo** | Nombre interno del sistema/operador -- probablemente staff interno de OCESA/Lobo con acceso operativo amplio |
| **Operacion** | Personal operativo -- gestion dia a dia de pedidos, asignacion, checador |
| **Candidato** | Portal público -- gente de internet que se registra para aplicar a una vacante publicada. Son prospectos, NO empleados todavía: reclutamiento masivo y constante (hasta ~4000 candidatos vigentes simultáneos para cubrir eventos), la mayoría nunca pasa del registro. Solo un porcentaje bajo pasa el proceso y es promovido a empleado/freelance. |

No se encontraron roles adicionales tipo "Supervisor de Sitio" o "RH" por separado -- es posible que esas funciones vivan dentro de "Operacion" o "Lobo". Esto hay que confirmarlo con el usuario si se requiere mas granularidad en la version nueva.

## Modelo de permisos (confirmado en pantalla "Permissions of Role: Administrador")

Los permisos son **por pantalla y por accion CRUD**, con este patron de nombre: `<objeto>_<Accion>`, acciones: `Insert`, `Update`, `Delete`, `Execute`, `FullControl`. Ejemplo real visto para el objeto Pedidos:

- `te_pedido_Insert` -- Pedidos Insert
- `te_pedido_Update` -- Pedidos Update
- `te_pedido_Delete` -- Pedidos Delete
- `te_pedido_Execute` -- Pedidos (ejecutar/abrir la pantalla)
- `te_pedido_FullControl` -- Pedidos FullControl
- `te_pedidogeneral_Execute` -- TE_Pedido General
- `te_pedidoprompt_Execute` -- Selecciona Pedidos
- `te_pedidote_peddetwc_Execute` -- TE_Pedido TE_Peddet WC (subform detalle)
- `te_pedidote_puentewc_Execute` -- TE_Pedido TE_Puente WC (subform puente)

Es decir: cada pantalla/transaccion genera automaticamente su propio set de permisos granulares (incluyendo los sub-objetos/WC embebidos), y cada Rol se configura marcando cuales permisos tiene en cuales pantallas. Esto es el patron estandar de GAM y asi es como hay que replicar el RBAC en la version nueva (permisos granulares por pantalla+accion, no solo "puede ver modulo X").

## Menú principal (vista real, rol Administrador)

Capturado del sistema real en operacion (`rintegra-001-site1.atempurl.com/app/te_pedidoww.aspx`), usuario "Roberto Aguilar - Administrador":

```
[Buscar opción del menú...]
🏠 Inicio
🔍 Spring uno  ▾
     Alta Candidatos
     Pedidos                 <- pantalla activa en la captura
     Requisición de Personal
     Catálogos               ▸
     🔍 Seguridad Sistema    <- Usuarios y Roles (GAM)
🔍 Spring Dos  ▾             <- colapsado en la captura, no se vio su contenido
```

El menu esta agrupado **por Sprint de desarrollo** (coincide exactamente con la estructura de carpetas `Manual Usuario/Sprint 01`, `Sprint 02`, `Sprint 03` que ya teniamos). "Spring uno" contiene exactamente los temas de Sprint 01: Alta Candidatos (1.01), Pedidos (2.01), Requisición de Personal (1.11), Catálogos (9.01), Seguridad Sistema (9.03).

**Pendiente:** no se capturo el contenido expandido de "Spring Dos" (deberia corresponder a los temas de Sprint 02: Calendario de entrevistas, Publicación de vacantes, Revisión de perfiles, Registro de resultado de evaluaciones, Seguimiento a proceso de selección) ni de "Catálogos" expandido. Si aparece en otras capturas de los manuales, se puede completar.

**Recomendacion para la version nueva:** no replicar el agrupamiento "por Sprint" (es un artefacto de como se desarrollo, no tiene sentido para el usuario final) -- agrupar el menu por **proceso de negocio** (Reclutamiento, Pedidos/Reservaciones, Nómina, Catálogos, Administración/Seguridad), conservando el mismo modelo de permisos granular por pantalla+accion.
