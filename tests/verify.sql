-- =============================================================================
-- ftx-courts-db · Post-migration checks (run by db-ci.yml after migrate)
--
-- Every failed check raises an exception, so psql (ON_ERROR_STOP=1) exits
-- non-zero and the CI turns red. Test rows are rolled back, so the database is
-- left exactly as the migrations created it.
-- =============================================================================

-- 1. Seed: the four contract ids, ACTIVE, with their catalogue values.
DO $$
DECLARE total int; matching int;
BEGIN
    SELECT count(*) INTO total FROM courts.court;
    SELECT count(*) INTO matching FROM courts.court c
      JOIN (VALUES ('c0000000-0000-4000-8000-000000000001'::uuid, 'Cancha 1', 10, 60000),
                   ('c0000000-0000-4000-8000-000000000002'::uuid, 'Cancha 2', 10, 60000),
                   ('c0000000-0000-4000-8000-000000000003'::uuid, 'Cancha 3', 14, 90000),
                   ('c0000000-0000-4000-8000-000000000004'::uuid, 'Cancha 4', 14, 90000))
           AS s(id, name, capacity, price)
        ON c.id = s.id AND c.name = s.name AND c.capacity = s.capacity
       AND c.hourly_price = s.price AND c.sport = 'FOOTBALL' AND c.status = 'ACTIVE';
    IF total <> 4 OR matching <> 4 THEN
        RAISE EXCEPTION 'FAIL seed: total=%, matching the contract=%', total, matching;
    END IF;
    RAISE NOTICE 'OK  seed: 4 courts with the ids shared with ftx-schedules-db';
END $$;

-- 2. Names are unique whatever the case.
DO $$
BEGIN
    UPDATE courts.court SET name = 'CANCHA 1' WHERE id = 'c0000000-0000-4000-8000-000000000002';
    RAISE EXCEPTION 'FAIL a duplicate name (different case) was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'OK  duplicate name rejected';
END $$;

-- 3. Capacity must be positive.
DO $$
BEGIN
    UPDATE courts.court SET capacity = 0 WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL capacity 0 was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  capacity 0 rejected';
END $$;

-- 4. Price must be positive and in whole pesos.
DO $$
BEGIN
    UPDATE courts.court SET hourly_price = 60000.50 WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL a price with cents was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  price with cents rejected';
END $$;

DO $$
BEGIN
    UPDATE courts.court SET hourly_price = 0 WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL price 0 was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  price 0 rejected';
END $$;

-- 5. Only the three documented statuses, and only FOOTBALL.
DO $$
BEGIN
    UPDATE courts.court SET status = 'CLOSED' WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL an unknown status was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  unknown status rejected';
END $$;

DO $$
BEGIN
    UPDATE courts.court SET sport = 'TENNIS' WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL an unknown sport was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  unknown sport rejected';
END $$;

-- 6. A blank name is rejected.
DO $$
BEGIN
    UPDATE courts.court SET name = '   ' WHERE id = 'c0000000-0000-4000-8000-000000000001';
    RAISE EXCEPTION 'FAIL a blank name was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK  blank name rejected';
END $$;

-- 7. A valid change is accepted and updated_at is maintained by the trigger (rolled back).
DO $$
DECLARE after_ts timestamptz;
BEGIN
    UPDATE courts.court
       SET updated_at = now() - interval '1 day', status = 'UNDER_MAINTENANCE', hourly_price = 70000
     WHERE id = 'c0000000-0000-4000-8000-000000000004'
    RETURNING updated_at INTO after_ts;
    IF after_ts < now() THEN
        RAISE EXCEPTION 'FAIL updated_at trigger did not fire';
    END IF;
    RAISE EXCEPTION USING ERRCODE = 'P0099', MESSAGE = 'rollback';
EXCEPTION WHEN SQLSTATE 'P0099' THEN
    RAISE NOTICE 'OK  valid change accepted and updated_at refreshed (rolled back)';
END $$;

-- 8. No foreign key: other domains reference courts by contract (Annex J.3.4).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints
                WHERE table_schema = 'courts' AND constraint_type = 'FOREIGN KEY') THEN
        RAISE EXCEPTION 'FAIL the courts schema has a foreign key';
    END IF;
    RAISE NOTICE 'OK  no cross-domain foreign key';
END $$;

-- 9. Nothing of this domain lives in public (Annex A, rule 9).
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE '%court%') THEN
        RAISE EXCEPTION 'FAIL a courts table lives in public';
    END IF;
    RAISE NOTICE 'OK  nothing in public';
END $$;

-- 10. Roles exist, cannot log in, and follow least privilege.
--     The writer can update courts but never create or delete them (BR-001).
DO $$
BEGIN
    IF (SELECT count(*) FROM pg_roles
         WHERE rolname IN ('courts_reader', 'courts_writer') AND NOT rolcanlogin) <> 2 THEN
        RAISE EXCEPTION 'FAIL courts_reader / courts_writer missing or LOGIN';
    END IF;
    IF NOT has_table_privilege('courts_reader', 'courts.court', 'SELECT')
       OR has_table_privilege('courts_reader', 'courts.court', 'UPDATE') THEN
        RAISE EXCEPTION 'FAIL courts_reader must read and never write';
    END IF;
    IF NOT has_table_privilege('courts_writer', 'courts.court', 'UPDATE')
       OR has_table_privilege('courts_writer', 'courts.court', 'INSERT')
       OR has_table_privilege('courts_writer', 'courts.court', 'DELETE')
       OR has_schema_privilege('courts_writer', 'courts', 'CREATE') THEN
        RAISE EXCEPTION 'FAIL courts_writer must update rows and never insert, delete or create objects';
    END IF;
    RAISE NOTICE 'OK  roles NOLOGIN with least privilege (no INSERT, no DELETE)';
END $$;

-- 11. No application role can touch the migration history.
DO $$
BEGIN
    IF to_regclass('courts.flyway_schema_history') IS NOT NULL
       AND (has_table_privilege('courts_writer', 'courts.flyway_schema_history', 'SELECT')
         OR has_table_privilege('courts_reader', 'courts.flyway_schema_history', 'SELECT')) THEN
        RAISE EXCEPTION 'FAIL an application role can read flyway_schema_history';
    END IF;
    RAISE NOTICE 'OK  migration history is private';
END $$;
