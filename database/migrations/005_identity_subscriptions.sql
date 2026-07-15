-- ==========================================================
-- NovaMente
-- Migration 005
-- Identity Subscriptions
-- ==========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS identity.subscriptions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES identity.profiles(id)
        ON DELETE CASCADE,

    provider VARCHAR(30) NOT NULL DEFAULT 'hotmart',

    external_subscription_id TEXT,

    plan VARCHAR(50) NOT NULL,

    status billing.subscription_status
        DEFAULT 'free',

    started_at TIMESTAMPTZ DEFAULT now(),

    expires_at TIMESTAMPTZ,

    auto_renew BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT subscriptions_unique
        UNIQUE(user_id)

);

CREATE INDEX IF NOT EXISTS idx_subscription_status

ON identity.subscriptions(status);

CREATE INDEX IF NOT EXISTS idx_subscription_expires

ON identity.subscriptions(expires_at);

CREATE TRIGGER trg_subscription_updated_at

BEFORE UPDATE

ON identity.subscriptions

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMIT;
