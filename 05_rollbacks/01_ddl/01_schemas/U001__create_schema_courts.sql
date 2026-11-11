-- U001 · Reverts V001__create_schema_courts.sql
-- RESTRICT on purpose: if anything is left in the schema, this fails and shows
-- that a previous rollback is missing. Delete courts.flyway_schema_history
-- before running it (Annex J.6).
DROP SCHEMA IF EXISTS courts RESTRICT;
