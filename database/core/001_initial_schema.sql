-- =============================================================================
-- NovaMente OS
-- Sprint 08A
-- File: 001_initial_schema.sql
-- Version: 1.0.0
--
-- Descripción:
-- Crea la estructura base de la base de datos.
-- Este archivo NO crea tablas.
-- Solo prepara la infraestructura inicial.
--
-- IMPORTANTE:
-- Ejecutar únicamente una vez.
-- =============================================================================

BEGIN;

-- ============================================================================
-- EXTENSIONES
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ESQUEMAS
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS identity;

CREATE SCHEMA IF NOT EXISTS learning;

CREATE SCHEMA IF NOT EXISTS gamification;

CREATE SCHEMA IF NOT EXISTS billing;

CREATE SCHEMA IF NOT EXISTS intelligence;

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE SCHEMA IF NOT EXISTS content;

CREATE SCHEMA IF NOT EXISTS automation;

CREATE SCHEMA IF NOT EXISTS configuration;

-- ============================================================================
-- COMENTARIOS
-- ============================================================================

COMMENT ON SCHEMA identity IS
'Gestión de identidad de usuarios, perfiles, sesiones y preferencias.';

COMMENT ON SCHEMA learning IS
'Motor de aprendizaje: juegos, preguntas, progreso y rutas.';

COMMENT ON SCHEMA gamification IS
'Sistema de niveles, experiencia, insignias y misiones.';

COMMENT ON SCHEMA billing IS
'Suscripciones, pagos e integración con Hotmart.';

COMMENT ON SCHEMA intelligence IS
'Motor de IA: memoria, recomendaciones y personalización.';

COMMENT ON SCHEMA analytics IS
'Métricas, eventos y analítica del sistema.';

COMMENT ON SCHEMA content IS
'Contenido publicado y traducciones automáticas.';

COMMENT ON SCHEMA automation IS
'Procesos automatizados y registros de integración.';

COMMENT ON SCHEMA configuration IS
'Configuración global del sistema.';

-- ============================================================================
-- FUNCIÓN GLOBAL updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS
$$
BEGIN

NEW.updated_at = NOW();

RETURN NEW;

END;
$$;

COMMENT ON FUNCTION public.set_updated_at()
IS 'Actualiza automáticamente el campo updated_at.';

-- ============================================================================
-- ENUMS GLOBALES
-- ============================================================================

DO $$

BEGIN

IF NOT EXISTS (

SELECT 1
FROM pg_type
WHERE typname = 'subscription_status'

) THEN

CREATE TYPE billing.subscription_status AS ENUM (

'free',

'trial',

'premium',

'expired',

'cancelled'

);

END IF;

END $$;

DO $$

BEGIN

IF NOT EXISTS (

SELECT 1
FROM pg_type
WHERE typname = 'difficulty_level'

) THEN

CREATE TYPE learning.difficulty_level AS ENUM (

'beginner',

'easy',

'medium',

'hard',

'expert'

);

END IF;

END $$;

DO $$

BEGIN

IF NOT EXISTS (

SELECT 1
FROM pg_type
WHERE typname = 'language_direction'

) THEN

CREATE TYPE configuration.language_direction AS ENUM (

'ltr',

'rtl'

);

END IF;

END $$;

-- ============================================================================
-- FINALIZAR
-- ============================================================================

COMMIT;
