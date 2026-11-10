-- V001 · Schema of the courts domain.
-- Annex J.4: every domain lives in its own schema inside the single PostgreSQL
-- instance defined in ftx-infra-postgres. Nothing of this domain lives in public.
-- Rollback: 05_rollbacks/01_ddl/01_schemas/U001__create_schema_courts.sql
CREATE SCHEMA IF NOT EXISTS courts;
