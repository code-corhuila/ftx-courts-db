-- V006: the four fixed courts of the facility, with the ids of the shared contract.
-- ftx-schedules-db stores the opening hours of these same ids, and ftx-courts-api and
-- ftx-schedules-api use them; changing an id breaks the schedules of that court.
-- ON CONFLICT DO NOTHING: running it again never overwrites a price or a status that an
-- administrator changed.
-- Rollback: 05_rollbacks/02_dml/00_inserts/U006__seed_courts.sql
INSERT INTO courts.courts (id, name, capacity, hourly_price, status) VALUES
    ('c0000000-0000-4000-8000-000000000001', 'Cancha 1', 10, 60000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000002', 'Cancha 2', 10, 60000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000003', 'Cancha 3', 14, 90000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000004', 'Cancha 4', 14, 90000, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;
