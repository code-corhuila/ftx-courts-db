# ftx-courts-db

> Courts domain: schema, seed, roles and Flyway migrations

Part of **Futbolix**, the distributed system for reserving the four football courts of a
single sports facility. Governance and documentation live in
[`ftx-docs`](https://github.com/code-corhuila/ftx-docs). User story: HU-ADM-001.

## What this repository is (and what it is not)

Following **Annex J** of the course norm, Futbolix has **one PostgreSQL instance**, defined in
[`ftx-infra-postgres`](https://github.com/code-corhuila/ftx-infra-postgres) with its container
and its volume. This repository:

| Does | Does not |
|---|---|
| Own the structure of the `courts` schema: table, function, trigger, index, seed, roles | Define a database container or a volume |
| Ship the migration runner (`deploy/compose.yml`) that applies its migrations to the single instance | Create login users or extensions (that is `ftx-infra-postgres`) |
| Prove in CI that the schema builds from scratch, reverts and builds again | Contain application code (that is `ftx-courts-api`) |

## Structure

```
01_ddl/                     definition (DDL)
  01_schemas/  V001__create_schema_courts.sql
  03_tables/   V002__create_court.sql
  07_functions/V003__create_function_set_updated_at.sql
  09_triggers/ V004__create_trigger_court_updated_at.sql
  10_indexes/  V005__create_indexes.sql
02_dml/00_inserts/          V006__seed_court.sql               (the four courts)
03_dcl/                     access control (DCL)
  00_roles/    V007__create_roles.sql                          (courts_reader, courts_writer)
  01_grants/   V008__grants.sql                                (courts_writer -> courts_app)
04_tcl/                     reserved: transaction blocks, manual recoveries, release tags
05_rollbacks/               one U<n> per V<n>, same family path
deploy/compose.yml          migration runner only (courts-db-migrate)
tests/verify.sql            post-migration checks
tests/rebuild.sh            rebuild check used by the CI
flyway.toml                 Flyway configuration (own schema and control table)
.github/workflows/db-ci.yml CI on every PR to develop and qa
```

## Data model

Table `courts.court` — the four fixed football courts (`ftx-docs` `06-data/models.md`, table
`courts`; `07-api/contracts/openapi/court-service.yaml`, schema `Court`).

| Column | Type | Rule |
|---|---|---|
| `id` | `uuid` | `pk_court`, `gen_random_uuid()` |
| `name` | `varchar(100)` | `chk_court_name_not_blank`; unique whatever the case (`idx_court_name_lower`) |
| `sport` | `text` | `chk_court_sport`: `FOOTBALL` (CHECK, never ENUM) |
| `capacity` | `integer` | `chk_court_capacity`: more than 0 |
| `hourly_price` | `numeric(10,2)` | `chk_court_hourly_price`: more than 0 and whole pesos (the API exposes `Money` as an integer in COP) |
| `status` | `text` | `chk_court_status`: `ACTIVE`, `INACTIVE`, `UNDER_MAINTENANCE` |
| `created_at` / `updated_at` | `timestamptz` | `updated_at` maintained by `trg_court_updated_at` |

The allowed status transitions (`ACTIVE` ↔ `INACTIVE`, `ACTIVE` ↔ `UNDER_MAINTENANCE`) are a
domain rule enforced by `ftx-courts-api`, not by the table.

### Contract with ftx-schedules-db

The seed inserts the four courts with exactly the ids that `ftx-schedules-db` uses for their
opening hours. Changing an id breaks the schedules of that court.

| Court | id | Capacity | Price per hour |
|---|---|---|---|
| Cancha 1 | `c0000000-0000-4000-8000-000000000001` | 10 | 60 000 COP |
| Cancha 2 | `c0000000-0000-4000-8000-000000000002` | 10 | 60 000 COP |
| Cancha 3 | `c0000000-0000-4000-8000-000000000003` | 14 | 90 000 COP |
| Cancha 4 | `c0000000-0000-4000-8000-000000000004` | 14 | 90 000 COP |

The seed uses `ON CONFLICT DO NOTHING`: running it again never overwrites a price or status
that an administrator changed.

### Access (Annex J.7)

| Role | Kind | Can |
|---|---|---|
| `courts_reader` | `NOLOGIN` | `SELECT` on `court` |
| `courts_writer` | `NOLOGIN` | `SELECT, UPDATE` on `court`; never `INSERT` or `DELETE` (courts are never created or deleted, BR-001); never DDL |
| `courts_app` | `LOGIN`, created by `ftx-infra-postgres` | receives `courts_writer`; `ftx-courts-api` connects with it |

`ftx-courts-api` connects as `postgres://courts_app:<secret>@postgres:5432/ftx` and never with
the administrator. No application role can read `flyway_schema_history`.

## How to run the migrations

From `ftx-infra-postgres`, with the repositories cloned as siblings:

```bash
docker network create platform                                          # once per machine
docker compose --env-file env/dev.env up -d --wait postgres             # the single instance
docker compose --env-file env/dev.env run --rm courts-db-migrate        # apply what is pending
docker compose --env-file env/dev.env run --rm courts-db-migrate        # again: "No migration necessary"
docker compose --env-file env/dev.env run --rm courts-db-migrate info
docker compose --env-file env/dev.env run --rm courts-db-migrate validate
```

`ftx-infra-postgres` must add `courts_app` to its `postgres/init/01-instance.sh` and
`COURTS_APP_PASSWORD` to its env files (Annex J.5.5).

## Rollback

Flyway Community does not revert. Each `V<n>` has its `U<n>` in `05_rollbacks/`, applied with
`psql` from the highest number to the lowest, after deleting `courts.flyway_schema_history`
(Annex J.6). The CI does it on every Pull Request. In `qa` and `main` a mistake is fixed with a
**new** forward migration; the `U` scripts are used only in a recovery decided and recorded in
`04_tcl/`.

## Rules

- A migration that already ran in any environment is **never edited**: a fix is a new `V<n>`.
- The next migration takes the next number (`V009`), whatever its family.
- Every new `V<n>` comes with its `U<n>` and, if it adds a rule, a check in `tests/verify.sql`.
- In `qa` and `main`, never `docker compose down -v`: the volume is the history (Annex J.5.4).

## Branching

`develop`, `qa` and `main` accept no direct commits. Per user story:
`hu-<id>-dev → develop`, then `git cherry-pick -x` into `hu-<id>-qa → qa`, then into
`hu-<id>-release → release.x.y.z → main` with the instructor's approval and the tag.
