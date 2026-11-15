
-- V002: catálogo fijo de canchas de Futbolix.
CREATE TABLE courts.courts (
    id           UUID          NOT NULL DEFAULT gen_random_uuid(),
    name         VARCHAR(100)  NOT NULL,
    sport        VARCHAR(50)   NOT NULL DEFAULT 'FOOTBALL',
    capacity     INTEGER       NOT NULL,
    hourly_price DECIMAL(10,2) NOT NULL,
    status       VARCHAR(30)   NOT NULL DEFAULT 'ACTIVE',
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_courts PRIMARY KEY (id),
    CONSTRAINT uq_courts_name UNIQUE (name),
    CONSTRAINT chk_courts_capacity CHECK (capacity > 0),
    CONSTRAINT chk_courts_hourly_price CHECK (hourly_price > 0),
    CONSTRAINT chk_courts_sport CHECK (sport = 'FOOTBALL'),
    CONSTRAINT chk_courts_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'UNDER_MAINTENANCE'))
);

COMMENT ON TABLE courts.courts IS
    'Four fixed football courts managed by the Futbolix courts bounded context.';
COMMENT ON COLUMN courts.courts.hourly_price IS
    'Hourly rental price in Colombian pesos (COP).';
