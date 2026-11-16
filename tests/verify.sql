
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

-- V006: the four contract courts are seeded.
DO $$
BEGIN
    IF (SELECT count(*) FROM courts.courts
         WHERE id IN ('c0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002',
                      'c0000000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000004')) <> 4 THEN
        RAISE EXCEPTION 'Missing the four contract courts';
    END IF;
END
$$;

-- V007: courts_writer can read and update, never insert or delete (BR-001).
DO $$
BEGIN
    IF NOT has_table_privilege('courts_writer', 'courts.courts', 'UPDATE')
       OR has_table_privilege('courts_writer', 'courts.courts', 'INSERT')
       OR has_table_privilege('courts_writer', 'courts.courts', 'DELETE') THEN
        RAISE EXCEPTION 'courts_writer must update and never insert or delete';
    END IF;
END
$$;

-- V008: a duplicate name in another case is rejected.
DO $$
BEGIN
    UPDATE courts.courts SET name = 'CANCHA 1' WHERE id = 'c0000000-0000-4000-8000-000000000002';
    RAISE EXCEPTION 'A duplicate name in another case was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END
$$;

-- V009: a price with cents is rejected.
DO $$
BEGIN
    UPDATE courts.courts SET hourly_price = 60000.50 WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'A price with cents was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END
$$;
