-- ==========================================================
-- NovaMente
-- Sprint 10
-- Identity Core
-- File: 002_identity_profiles.sql
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS identity;

-- ==========================================================
-- USER PROFILES
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.user_profiles (

    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    username VARCHAR(50) UNIQUE,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    avatar_url TEXT,

    birth_date DATE,

    gender VARCHAR(30),

    country_id UUID,

    language_id UUID,

    currency_id UUID,

    timezone VARCHAR(80),

    cognitive_level SMALLINT DEFAULT 1,

    onboarding_completed BOOLEAN DEFAULT FALSE,

    premium BOOLEAN DEFAULT FALSE,

    premium_until TIMESTAMPTZ,

    active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now()

);

-- ==========================================================
-- USER PREFERENCES
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.user_preferences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    theme VARCHAR(20) DEFAULT 'system',

    language_code VARCHAR(10) DEFAULT 'en',

    notifications BOOLEAN DEFAULT TRUE,

    reminder_time TIME,

    daily_goal SMALLINT DEFAULT 15,

    auto_translate BOOLEAN DEFAULT TRUE,

    ai_voice BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT unique_preferences
        UNIQUE(user_id)

);

-- ==========================================================
-- USER ROLES
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.user_roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    role_code VARCHAR(30) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT unique_role
        UNIQUE(user_id, role_code)

);

-- ==========================================================
-- SUBSCRIPTIONS
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.subscription_status (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    provider VARCHAR(40),

    plan VARCHAR(50),

    status VARCHAR(30),

    starts_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    external_id TEXT,

    auto_renew BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT unique_subscription
        UNIQUE(user_id)

);

-- ==========================================================
-- USER DEVICES
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.user_devices (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    platform VARCHAR(30),

    browser VARCHAR(50),

    os VARCHAR(50),

    language VARCHAR(20),

    last_login TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT now()

);

-- ==========================================================
-- LOGIN HISTORY
-- ==========================================================

CREATE TABLE IF NOT EXISTS identity.login_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    ip_address TEXT,

    country TEXT,

    city TEXT,

    device TEXT,

    successful BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now()

);
