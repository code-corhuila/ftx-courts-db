-- V007 · Permission roles of the courts domain.
-- NOLOGIN and without password (Annex A, rule 10): they only carry permissions.
-- Roles belong to the whole instance, so their names start with the domain (Annex J.4).
-- The login user courts_app is created by ftx-infra-postgres, never here.
-- Rollback: 05_rollbacks/03_dcl/00_roles/U007__create_roles.sql
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'courts_reader') THEN
        CREATE ROLE courts_reader NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'courts_writer') THEN
        CREATE ROLE courts_writer NOLOGIN;
    END IF;
END
$$;
