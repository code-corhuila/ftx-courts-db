-- V005 · Indexes of court.
-- idx_court_name_lower
--   * Rule: two courts cannot share a name, whatever the case ("Cancha 1" and
--     "cancha 1" are the same court for a customer). Unique on lower(name).
--   * PATCH /admin/courts/{id} answers 409 CONFLICT when it is violated.
-- No index on status: the table holds four rows, a sequential scan is cheaper.
-- The table is empty when this runs, so CONCURRENTLY is not needed (Annex A, rule 14).
-- Rollback: 05_rollbacks/01_ddl/10_indexes/U005__create_indexes.sql
CREATE UNIQUE INDEX idx_court_name_lower
    ON courts.court (lower(name));
