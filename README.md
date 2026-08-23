# PeopleMovil 2.0

Motor de gestión de personal rotativo multi-tenant. Resuelve (a) el registro electrónico de jornada de la Reforma LFT vigente desde mayo 2026 y obligatoriedad plena enero 2027, y (b) la asignación diaria de personal por sitio/rol con certeza, penalizaciones y nómina/honorarios — heredado del sistema real Lobo/AppSCPF de OCESA (GeneXus).

## Estructura del repo

```
/db
  reset_database.sql       — schema completo + funciones/triggers + RLS + seeds reales
/peoplemovil-app           — Vite + React + Tailwind, deploy Netlify
  /src/pages               — Dashboard, Personal, SitiosAsignacion, Checador, Nómina, Pricing, Configuración
  /netlify/functions       — chat-operativo, chat-analitico, notificacion-resend, notificacion-whatsapp, onboarding-tenant
/documentacion-referencia  — spec, glosario, PRC originales
CLAUDE.md                  — contrato de trabajo (decisiones, principios, avance por fase)
ANALISIS_FASE_1.md         — análisis del dominio
MODELO_DATOS.md            — cada tabla y su regla PRC de origen
```

## Setup local

```bash
# 1. Base de datos (Supabase o Postgres local)
psql <URL> -f db/reset_database.sql

# 2. Frontend
cd peoplemovil-app
cp .env.example .env    # completa con tus credenciales Supabase
npm install
npm run dev             # http://localhost:5173

# 3. Netlify Functions (opcional en local)
npx netlify dev
```

## Deploy

Netlify autodetecta desde `netlify.toml`. Variables de entorno a setear en el panel: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE`, `ANTHROPIC_API_KEY`, `RESEND_API_KEY`, `TWILIO_*`.

## Principios no negociables

- Ningún parámetro de negocio hardcodeado en código.
- Registros de asistencia y consentimientos son append-only (RLS bloquea UPDATE/DELETE).
- Timestamp de servidor forzado; nunca del cliente.
- Multi-tenant real con RLS por `tenant_id` en TODAS las tablas.
- Cada evento biométrico vinculado a un consentimiento vigente.
- Cada decisión automática deja constancia en `regla_aplicada`.
- Límites por plan verificados en la base (trigger), no en frontend.

## Planes

| Capacidad | FREE | PRO |
|---|---|---|
| Sitios | 1 | Ilimitado |
| Empleados | 15 | Ilimitado |
| Checador fijo (USB) | ✅ | ✅ |
| Checador móvil (GPS) | ❌ | ✅ |
| Asignación/pedidos | ❌ | ✅ |
| Nómina/honorarios | ❌ | ✅ |
| REPSE | ❌ | ✅ |
