CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS learning;
CREATE SCHEMA IF NOT EXISTS intelligence;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS gamification;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS content;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS automation;
CREATE SCHEMA IF NOT EXISTS configuration;

CREATE TABLE IF NOT EXISTS identity.profiles(
id uuid PRIMARY KEY,
email text UNIQUE NOT NULL,
first_name text,
last_name text,
language text DEFAULT 'es',
country text,
timezone text,
currency text,
created_at timestamptz DEFAULT now()
);
