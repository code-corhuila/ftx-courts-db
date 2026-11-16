-- V009: the API exposes Money as an integer amount in COP (court-service.yaml), so a price with
-- cents could never be shown back without rounding. Only whole pesos are accepted.
-- Rollback: 05_rollbacks/01_ddl/03_tables/U009__add_check_courts_hourly_price_whole_pesos.sql
ALTER TABLE courts.courts
    ADD CONSTRAINT chk_courts_hourly_price_whole_pesos CHECK (hourly_price = trunc(hourly_price));
