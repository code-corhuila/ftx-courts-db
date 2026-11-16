-- V007: courts are never created or deleted (BR-001, 01-context/scope.md: four fixed courts), so the
-- role that ftx-courts-api uses keeps SELECT and UPDATE only.
-- Rollback: 05_rollbacks/03_dcl/01_grants/U007__revoke_insert_delete_from_courts_writer.sql
REVOKE INSERT, DELETE ON courts.courts FROM courts_writer;
