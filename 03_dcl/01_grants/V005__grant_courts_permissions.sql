-- V005: least-privilege permissions for the courts domain.
-- courts_app is provisioned by ftx-infra-postgres.
GRANT USAGE ON SCHEMA courts TO courts_reader, courts_writer;

GRANT SELECT ON courts.courts TO courts_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON courts.courts TO courts_writer;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'courts_app') THEN
        GRANT courts_writer TO courts_app;
    ELSE
        RAISE NOTICE 'courts_app does not exist yet: grant skipped.';
    END IF;
END
$$;
