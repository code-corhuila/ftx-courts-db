-- V008: two courts cannot share a name whatever the case ("Cancha 1" and "cancha 1" are the same
-- court for a customer). PATCH /admin/courts/{id} answers 409 CONFLICT when it is violated.
-- Rollback: 05_rollbacks/01_ddl/10_indexes/U008__create_index_courts_name_lower.sql
CREATE UNIQUE INDEX idx_courts_name_lower ON courts.courts (lower(name));
