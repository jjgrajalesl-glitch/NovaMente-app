-- =============================================================================
-- NovaMente OS
-- Sprint 08A
-- File: 002_configuration.sql
-- Version: 1.0.0
--
-- Tablas maestras de configuración
-- =============================================================================

BEGIN;

-- ===========================================================
-- LANGUAGES
-- ===========================================================

CREATE TABLE IF NOT EXISTS configuration.languages (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(10) NOT NULL UNIQUE,

    name VARCHAR(120) NOT NULL,

    native_name VARCHAR(120),

    direction configuration.language_direction NOT NULL DEFAULT 'ltr',

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

CREATE TRIGGER trg_languages_updated_at

BEFORE UPDATE

ON configuration.languages

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE configuration.languages IS
'Idiomas soportados por NovaMente.';

-- ===========================================================
-- COUNTRIES
-- ===========================================================

CREATE TABLE IF NOT EXISTS configuration.countries (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    iso2 CHAR(2) UNIQUE NOT NULL,

    iso3 CHAR(3),

    name VARCHAR(150) NOT NULL,

    language_code VARCHAR(10),

    currency_code VARCHAR(10),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

CREATE TRIGGER trg_countries_updated_at

BEFORE UPDATE

ON configuration.countries

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE configuration.countries IS
'Catálogo de países.';

-- ===========================================================
-- CURRENCIES
-- ===========================================================

CREATE TABLE IF NOT EXISTS configuration.currencies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(10) UNIQUE NOT NULL,

    symbol VARCHAR(10),

    name VARCHAR(120),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

CREATE TRIGGER trg_currencies_updated_at

BEFORE UPDATE

ON configuration.currencies

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE configuration.currencies IS
'Monedas soportadas.';

-- ===========================================================
-- ROLES
-- ===========================================================

CREATE TABLE IF NOT EXISTS configuration.roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(50) UNIQUE NOT NULL,

    name VARCHAR(100) NOT NULL,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

CREATE TRIGGER trg_roles_updated_at

BEFORE UPDATE

ON configuration.roles

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE configuration.roles IS
'Roles del sistema.';

-- ===========================================================
-- CATEGORIES
-- ===========================================================

CREATE TABLE IF NOT EXISTS configuration.categories (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(80) UNIQUE NOT NULL,

    name VARCHAR(120),

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

CREATE TRIGGER trg_categories_updated_at

BEFORE UPDATE

ON configuration.categories

FOR EACH ROW

EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE configuration.categories IS
'Categorías cognitivas del sistema.';

COMMIT;
