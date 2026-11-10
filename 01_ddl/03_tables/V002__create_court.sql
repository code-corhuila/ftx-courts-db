-- V002 · court: the four fixed football courts of the facility.
--
-- Source model: ftx-docs 06-data/models.md (table "courts") and the Court schema of
-- 07-api/contracts/openapi/court-service.yaml, adapted to the norm:
--   * Singular snake_case name (Annex A, rule 1).
--   * Closed sets of values are CHECK constraints, never ENUM (Annex A, rule 5).
--   * Constraints have explicit names (Annex A, rule 4).
--   * The unique index on the name lives in 10_indexes (V005).
-- hourly_price keeps the DECIMAL of the model, but only whole pesos are accepted:
-- the API exposes Money as an integer amount in COP, so a stored fraction could
-- never be shown back without rounding.
-- Rollback: 05_rollbacks/01_ddl/03_tables/U002__create_court.sql
CREATE TABLE courts.court (
    id            uuid          NOT NULL DEFAULT gen_random_uuid(),
    name          varchar(100)  NOT NULL,
    sport         text          NOT NULL DEFAULT 'FOOTBALL',
    capacity      integer       NOT NULL,
    hourly_price  numeric(10,2) NOT NULL,
    status        text          NOT NULL DEFAULT 'ACTIVE',
    created_at    timestamptz   NOT NULL DEFAULT now(),
    updated_at    timestamptz   NOT NULL DEFAULT now(),

    CONSTRAINT pk_court PRIMARY KEY (id),

    CONSTRAINT chk_court_name_not_blank
        CHECK (length(btrim(name)) > 0),

    CONSTRAINT chk_court_sport
        CHECK (sport IN ('FOOTBALL')),

    CONSTRAINT chk_court_capacity
        CHECK (capacity > 0),

    CONSTRAINT chk_court_hourly_price
        CHECK (hourly_price > 0 AND hourly_price = trunc(hourly_price)),

    CONSTRAINT chk_court_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE'))
);

COMMENT ON TABLE  courts.court              IS 'The four fixed football courts. Owned by the courts domain; never created or deleted through the API (BR-001).';
COMMENT ON COLUMN courts.court.hourly_price IS 'Price of one reservation hour in whole Colombian pesos.';
COMMENT ON COLUMN courts.court.status       IS 'ACTIVE can be reserved; INACTIVE and UNDER_MAINTENANCE cannot (02-domain/entities-and-rules.md).';
