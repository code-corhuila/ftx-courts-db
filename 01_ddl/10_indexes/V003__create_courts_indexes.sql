-- V003: indexes for court listing and filtering.
CREATE UNIQUE INDEX idx_courts_name ON courts.courts (name);
CREATE INDEX idx_courts_status ON courts.courts (status);
