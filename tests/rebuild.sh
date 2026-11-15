#!/usr/bin/env sh
set -eu
: "${FLYWAY:?Set FLYWAY command}"
: "${PSQL:=psql}"
$FLYWAY migrate
$FLYWAY migrate
$PSQL -v ON_ERROR_STOP=1 -f tests/verify.sql
$FLYWAY validate
