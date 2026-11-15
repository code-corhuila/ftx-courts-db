
-- V004: permission roles. Login user is provisioned by ftx-infra-postgres.
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
