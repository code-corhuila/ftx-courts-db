-- U009: reverts V009
ALTER TABLE courts.courts DROP CONSTRAINT IF EXISTS chk_courts_hourly_price_whole_pesos;
