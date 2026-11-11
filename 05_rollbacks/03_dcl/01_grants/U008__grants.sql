-- U008 · Reverts V008__grants.sql
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'courts_app') THEN
        REVOKE courts_writer FROM courts_app;
    END IF;
END
$$;

REVOKE SELECT, UPDATE ON courts.court FROM courts_writer;
REVOKE SELECT ON courts.court FROM courts_reader;
REVOKE USAGE ON SCHEMA courts FROM courts_reader, courts_writer;
