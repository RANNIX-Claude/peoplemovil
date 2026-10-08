-- ============================================================================
-- Seed: cuentas de prueba para "brincar" entre las 3 empresas demo nuevas
-- (construcción, seguridad privada, BTL/promotoras -- ver Migración 017 en
-- reset_database.sql) y confirmar que cada una solo ve sus propios catálogos
-- (RLS por tenant_id).
--
-- NO es parte de reset_database.sql a propósito -- mismo criterio que las
-- cuentas de §10 del CLAUDE.md: requiere escribir directo en el esquema
-- `auth` de Supabase (bypass del formulario de signup, que además rechaza
-- dominios @peoplemovil.demo). Correr esto DESPUÉS de reset_database.sql,
-- conectado al proyecto Supabase real de PeopleMovil (requiere permisos
-- sobre el esquema auth -- normalmente service_role / conexión directa a
-- Postgres, no el API REST).
--
-- Contraseña única para las 6 cuentas: Multiempresa2026!
-- (mismo patrón legible que admin.demoNN@peoplemovil.demo / AdminDemo2026!)
--
-- ADVERTENCIA: las columnas exactas de auth.users/auth.identities dependen
-- de la versión de GoTrue que use el proyecto. Esto se escribió sin una
-- conexión activa al proyecto Supabase real de PeopleMovil para probarlo --
-- revisar que corra limpio una vez conectado; si alguna columna no existe,
-- Postgres lo dirá de inmediato (ALTER/INSERT fallará con "column does not
-- exist", no hay riesgo de corrupción silenciosa).
-- ============================================================================

DO $$
DECLARE
  v_pass text := crypt('Multiempresa2026!', gen_salt('bf'));
  v_uid  uuid;
  v_tenant uuid;
  v_email text;
  rec record;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('00000000-0000-0000-0000-000000000002'::uuid, 'admin.construccion01@peoplemovil.demo', 'administrador', NULL::int),
    ('00000000-0000-0000-0000-000000000002'::uuid, 'freelance.construccion01@peoplemovil.demo', NULL, 1),
    ('00000000-0000-0000-0000-000000000003'::uuid, 'admin.seguridad01@peoplemovil.demo', 'administrador', NULL::int),
    ('00000000-0000-0000-0000-000000000003'::uuid, 'freelance.seguridad01@peoplemovil.demo', NULL, 1),
    ('00000000-0000-0000-0000-000000000004'::uuid, 'admin.btl01@peoplemovil.demo', 'administrador', NULL::int),
    ('00000000-0000-0000-0000-000000000004'::uuid, 'freelance.btl01@peoplemovil.demo', NULL, 1)
  ) AS v(tenant_id, email, rol_codigo, folio_empleado)
  LOOP
    v_tenant := rec.tenant_id;
    v_email  := rec.email;
    v_uid := gen_random_uuid();

    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', v_uid, 'authenticated', 'authenticated',
      v_email, v_pass, now(), now(),
      '{"provider":"email","providers":["email"]}', '{}',
      now(), now(), '', '', '', ''
    );

    INSERT INTO auth.identities (
      id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) VALUES (
      gen_random_uuid(), v_uid, v_uid::text,
      jsonb_build_object('sub', v_uid::text, 'email', v_email),
      'email', now(), now(), now()
    );

    IF rec.rol_codigo IS NOT NULL THEN
      -- Cuenta de admin: alta en te_usuarios + rol
      INSERT INTO te_usuarios (tenant_id, auth_user_id, nombre_usuario, correo, nombre)
      VALUES (v_tenant, v_uid, split_part(v_email,'@',1), v_email, 'Admin demo')
      ON CONFLICT (tenant_id, nombre_usuario) DO NOTHING;

      INSERT INTO tr_usuario_rol (tenant_id, usuario_id, rol_id)
      SELECT v_tenant, u.id, r.id
      FROM te_usuarios u, tc_roles r
      WHERE u.tenant_id = v_tenant AND u.auth_user_id = v_uid
        AND r.tenant_id = v_tenant AND r.codigo = rec.rol_codigo
      ON CONFLICT DO NOTHING;
    ELSE
      -- Cuenta freelance: liga el auth_user_id al empleado demo folio=1 del tenant
      UPDATE te_empleados SET auth_user_id = v_uid
      WHERE tenant_id = v_tenant AND folio = rec.folio_empleado;
    END IF;
  END LOOP;
END $$;

-- Verificación rápida: debe regresar 6 filas, una por cuenta, con su tenant y rol/empleado ligado.
-- SELECT u.email, t.vertical,
--        (SELECT nombre_usuario FROM te_usuarios WHERE auth_user_id = u.id) AS usuario_admin,
--        (SELECT folio FROM te_empleados WHERE auth_user_id = u.id) AS folio_empleado_freelance
-- FROM auth.users u
-- JOIN (VALUES ('00000000-0000-0000-0000-000000000002'::uuid,'construccion'),
--              ('00000000-0000-0000-0000-000000000003'::uuid,'seguridad_privada'),
--              ('00000000-0000-0000-0000-000000000004'::uuid,'btl_activaciones')) AS t(id,vertical) ON true
-- WHERE u.email LIKE '%@peoplemovil.demo' AND u.email LIKE '%construccion%' OR u.email LIKE '%seguridad%' OR u.email LIKE '%btl%'
-- ORDER BY u.email;
