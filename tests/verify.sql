
\set ON_ERROR_STOP on

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.schemata
        WHERE schema_name = 'courts'
    ) THEN
        RAISE EXCEPTION 'Missing courts schema';
    END IF;

    IF to_regclass('courts.courts') IS NULL THEN
        RAISE EXCEPTION 'Missing courts.courts table';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM pg_constraint
        WHERE conrelid = 'courts.courts'::regclass
          AND contype IN ('p', 'u', 'c')
    ) < 6 THEN
        RAISE EXCEPTION 'Expected primary key, unique constraint and business checks';
    END IF;
END
$$;
