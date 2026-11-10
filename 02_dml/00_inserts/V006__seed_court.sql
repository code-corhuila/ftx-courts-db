-- V006 · The four fixed courts (BR-001: they are seeded, never created through the API).
--
-- Ids are a CONTRACT with ftx-schedules-db: its seed V006__seed_court_schedule.sql
-- inserts the opening hours of exactly these four ids.
-- Names, capacity and price are the values the ftx-front catalogue already shows
-- (Cancha 1 and 2: 10 players, 60 000 COP; Cancha 3 and 4: 14 players, 90 000 COP).
-- All start ACTIVE: maintenance or inactivity is an operational state that an
-- administrator sets later (PATCH /admin/courts/{id}), not part of the catalogue.
-- Idempotent seed (Annex A, rule 11). ON CONFLICT DO NOTHING on purpose: running it
-- again must never overwrite a price or status an administrator already changed.
-- Rollback: 05_rollbacks/02_dml/00_inserts/U006__seed_court.sql
INSERT INTO courts.court (id, name, sport, capacity, hourly_price, status)
VALUES
    ('c0000000-0000-4000-8000-000000000001', 'Cancha 1', 'FOOTBALL', 10, 60000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000002', 'Cancha 2', 'FOOTBALL', 10, 60000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000003', 'Cancha 3', 'FOOTBALL', 14, 90000, 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000004', 'Cancha 4', 'FOOTBALL', 14, 90000, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;
