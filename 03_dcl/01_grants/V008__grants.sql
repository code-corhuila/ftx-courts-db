-- V008 · Permissions of the courts domain.
--   courts_reader: read only.
--   courts_writer: read and UPDATE only. Never INSERT or DELETE: the four courts are
--                  seeded and cannot be created or deleted (BR-001), so the role that
--                  ftx-courts-api uses cannot do it either. Never DDL.
-- The domain grants its writer role to its own user (Annex J.7). courts_app is
-- created by ftx-infra-postgres; if it does not exist yet (for example in CI with an
-- empty database), the grant is skipped and applied when infra creates the user
-- and this repo adds a new migration, or by running U008/V008 by hand.
-- Rollback: 05_rollbacks/03_dcl/01_grants/U008__grants.sql
GRANT USAGE ON SCHEMA courts TO courts_reader, courts_writer;

-- Table by table, never ON ALL TABLES: the schema also holds flyway_schema_history,
-- and no application user may read or alter the migration history.
GRANT SELECT ON courts.court TO courts_reader;
GRANT SELECT, UPDATE ON courts.court TO courts_writer;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'courts_app') THEN
        GRANT courts_writer TO courts_app;
    ELSE
        RAISE NOTICE 'courts_app does not exist yet: grant skipped (created by ftx-infra-postgres)';
    END IF;
END
$$;
