-- =============================================================================
-- NovaMente
-- Migration 006
-- Identity Auth Trigger
-- Version 1.0
-- =============================================================================

BEGIN;

-- =============================================================================
-- FUNCIÓN: Crear perfil automáticamente cuando un usuario se registra
-- =============================================================================

CREATE OR REPLACE FUNCTION identity.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, identity, configuration
AS
$$
DECLARE
    v_language UUID;
    v_country UUID;
    v_currency UUID;
BEGIN

    --------------------------------------------------------------------------
    -- Valores por defecto
    --------------------------------------------------------------------------

    SELECT id
      INTO v_language
      FROM configuration.languages
     WHERE code = 'es'
     LIMIT 1;

    SELECT id
      INTO v_country
      FROM configuration.countries
     WHERE iso2 = 'CO'
     LIMIT 1;

    SELECT id
      INTO v_currency
      FROM configuration.currencies
     WHERE code = 'COP'
     LIMIT 1;

    --------------------------------------------------------------------------
    -- Crear perfil
    --------------------------------------------------------------------------

    INSERT INTO identity.profiles (

        id,
        username,
        first_name,
        last_name,
        avatar_url,
        language_id,
        country_id,
        currency_id,
        timezone,
        cognitive_level,
        experience_points,
        streak_days,
        premium,
        onboarding_completed,
        ai_personality,
        status

    )

    VALUES (

        NEW.id,

        split_part(NEW.email,'@',1),

        COALESCE(
            NEW.raw_user_meta_data ->> 'first_name',
            ''
        ),

        COALESCE(
            NEW.raw_user_meta_data ->> 'last_name',
            ''
        ),

        NEW.raw_user_meta_data ->> 'avatar_url',

        v_language,

        v_country,

        v_currency,

        'UTC',

        1,

        0,

        0,

        FALSE,

        FALSE,

        'coach',

        'active'

    );

    --------------------------------------------------------------------------
    -- Preferencias
    --------------------------------------------------------------------------

    INSERT INTO identity.preferences (

        user_id

    )

    VALUES (

        NEW.id

    );

    --------------------------------------------------------------------------
    -- Suscripción FREE
    --------------------------------------------------------------------------

    INSERT INTO identity.subscriptions (

        user_id,

        provider,

        plan,

        status

    )

    VALUES (

        NEW.id,

        'NovaMente',

        'FREE',

        'free'

    );

    RETURN NEW;

END;

$$;

-- =============================================================================
-- ELIMINAR TRIGGER ANTERIOR SI EXISTE
-- =============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created
ON auth.users;

-- =============================================================================
-- CREAR TRIGGER
-- =============================================================================

CREATE TRIGGER on_auth_user_created

AFTER INSERT

ON auth.users

FOR EACH ROW

EXECUTE FUNCTION identity.handle_new_user();

COMMIT;
