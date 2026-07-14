-- =====================================================
-- NovaMente
-- Migration 003
-- Extend Identity Profiles
-- Version 1.1
-- =====================================================

ALTER TABLE identity.profiles

ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE,

ADD COLUMN IF NOT EXISTS locale VARCHAR(10) DEFAULT 'es-CO',

ADD COLUMN IF NOT EXISTS preferred_ai_language VARCHAR(10) DEFAULT 'es',

ADD COLUMN IF NOT EXISTS preferred_content_language VARCHAR(10) DEFAULT 'es',

ADD COLUMN IF NOT EXISTS theme VARCHAR(20) DEFAULT 'system',

ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ,

ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,

ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- =====================================================
-- Índices
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_profiles_locale
ON identity.profiles(locale);

CREATE INDEX IF NOT EXISTS idx_profiles_deleted
ON identity.profiles(deleted_at);

CREATE INDEX IF NOT EXISTS idx_profiles_last_login
ON identity.profiles(last_login_at);
