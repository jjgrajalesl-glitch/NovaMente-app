-- =====================================================
-- NovaMente
-- Migration 004
-- Identity Preferences
-- Version 1.0
-- =====================================================

CREATE TABLE IF NOT EXISTS identity.preferences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES identity.profiles(id)
        ON DELETE CASCADE,

    -----------------------------------------------------
    -- Idioma
    -----------------------------------------------------

    interface_language_id UUID
        REFERENCES configuration.languages(id),

    content_language_id UUID
        REFERENCES configuration.languages(id),

    ai_language_id UUID
        REFERENCES configuration.languages(id),

    -----------------------------------------------------
    -- Apariencia
    -----------------------------------------------------

    theme VARCHAR(20)
        DEFAULT 'system',

    font_size VARCHAR(20)
        DEFAULT 'medium',

    animations_enabled BOOLEAN
        DEFAULT TRUE,

    sound_enabled BOOLEAN
        DEFAULT TRUE,

    accessibility_mode BOOLEAN
        DEFAULT FALSE,

    -----------------------------------------------------
    -- Notificaciones
    -----------------------------------------------------

    email_notifications BOOLEAN
        DEFAULT TRUE,

    push_notifications BOOLEAN
        DEFAULT TRUE,

    daily_reminders BOOLEAN
        DEFAULT TRUE,

    reminder_time TIME,

    weekly_summary BOOLEAN
        DEFAULT TRUE,

    -----------------------------------------------------
    -- IA
    -----------------------------------------------------

    ai_personality VARCHAR(50)
        DEFAULT 'coach',

    ai_proactivity_level SMALLINT
        DEFAULT 3,

    auto_translate_content BOOLEAN
        DEFAULT TRUE,

    adaptive_learning BOOLEAN
        DEFAULT TRUE,

    -----------------------------------------------------
    -- Gamificación
    -----------------------------------------------------

    show_leaderboard BOOLEAN
        DEFAULT TRUE,

    public_profile BOOLEAN
        DEFAULT FALSE,

    show_streak BOOLEAN
        DEFAULT TRUE,

    difficulty_auto_adjust BOOLEAN
        DEFAULT TRUE,

    -----------------------------------------------------
    -- Privacidad
    -----------------------------------------------------

    analytics_enabled BOOLEAN
        DEFAULT TRUE,

    personalized_recommendations BOOLEAN
        DEFAULT TRUE,

    share_anonymous_statistics BOOLEAN
        DEFAULT TRUE,

    -----------------------------------------------------
    -- Auditoría
    -----------------------------------------------------

    created_at TIMESTAMPTZ
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        DEFAULT NOW(),

    CONSTRAINT preferences_user_unique
        UNIQUE(user_id)

);

-- =====================================================
-- Índices
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_preferences_user

ON identity.preferences(user_id);

-- =====================================================
-- Trigger
-- =====================================================

DROP TRIGGER IF EXISTS trg_preferences_updated_at

ON identity.preferences;

CREATE TRIGGER trg_preferences_updated_at

BEFORE UPDATE

ON identity.preferences

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE identity.preferences IS
'Configuración personal del usuario.';
