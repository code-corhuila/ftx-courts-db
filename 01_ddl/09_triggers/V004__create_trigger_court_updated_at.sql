-- V004 · Fires set_updated_at on every update of court.
-- Rollback: 05_rollbacks/01_ddl/09_triggers/U004__create_trigger_court_updated_at.sql
CREATE TRIGGER trg_court_updated_at
    BEFORE UPDATE ON courts.court
    FOR EACH ROW
    EXECUTE FUNCTION courts.set_updated_at();
