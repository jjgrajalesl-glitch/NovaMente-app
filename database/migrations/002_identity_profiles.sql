-- =====================================================
-- NovaMente
-- Migration 002
-- Identity Module - Profiles
-- Version 1.0
-- =====================================================

CREATE TABLE IF NOT EXISTS identity.profiles (

    -- Relación directa con Supabase Auth
    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    -- Información pública
    username VARCHAR(50) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,

    -- Localización
    language_id UUID
        REFERENCES configuration.languages(id),

    country_id UUID
        REFERENCES configuration.countries(id),

    currency_id UUID
        REFERENCES configuration.currencies(id),

    timezone VARCHAR(100)
        DEFAULT 'UTC',

    -- Progreso del usuario
    cognitive_level INTEGER
        DEFAULT 1,

    experience_points INTEGER
        DEFAULT 0,

    streak_days INTEGER
        DEFAULT 0,

    -- Estado de la cuenta
    premium BOOLEAN
        DEFAULT FALSE,

    onboarding_completed BOOLEAN
        DEFAULT FALSE,

    ai_personality VARCHAR(50)
        DEFAULT 'coach',

    status VARCHAR(20)
        DEFAULT 'active',

    -- Auditoría
    created_at TIMESTAMPTZ
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        DEFAULT NOW()
);

-- =====================================================
-- Índices
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_profiles_username
ON identity.profiles(username);

CREATE INDEX IF NOT EXISTS idx_profiles_language
ON identity.profiles(language_id);

CREATE INDEX IF NOT EXISTS idx_profiles_country
ON identity.profiles(country_id);

CREATE INDEX IF NOT EXISTS idx_profiles_status
ON identity.profiles(status);

-- =====================================================
-- Trigger actualización automática
-- =====================================================

CREATE OR REPLACE FUNCTION identity.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profiles_updated_at
ON identity.profiles;

CREATE TRIGGER trg_profiles_updated_at

BEFORE UPDATE
ON identity.profiles

FOR EACH ROW

EXECUTE FUNCTION identity.update_timestamp();
