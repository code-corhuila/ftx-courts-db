# ftx-courts-db

> Base de datos del bounded context de canchas de Futbolix.

Este repositorio administra exclusivamente el esquema PostgreSQL del dominio `courts`.
La instancia PostgreSQL y su volumen pertenecen a `ftx-infra-postgres`. La API pertenece a
`ftx-courts-api`. Las migraciones se ejecutan con Flyway.

## Alcance del MVP

- Futbolix administra exactamente cuatro canchas fijas de fútbol.
- No existe operación de creación o eliminación de canchas desde la API.
- Cada cancha tiene nombre, deporte, capacidad, precio por hora y estado operativo.
- Estados permitidos: `ACTIVE`, `INACTIVE`, `UNDER_MAINTENANCE`.
- La moneda del sistema es COP.
- Los horarios se gestionan en `ftx-schedules-db`; las reservas en `ftx-reservations-db`.
- No se crean claves foráneas entre bounded contexts ni entre bases de datos de servicios distintos.

## Estructura

```text
01_ddl/01_schemas/       creación del esquema courts
01_ddl/03_tables/        tabla courts
01_ddl/10_indexes/       índices
02_dml/00_inserts/       seed de las cuatro canchas (pendiente de confirmar capacidad y tarifa)
03_dcl/                  roles y permisos del dominio
04_tcl/                  reservado para operaciones transaccionales documentadas
05_rollbacks/            rollback manual asociado a cada migración
deploy/                  runner de Flyway
tests/                   verificación y reconstrucción
.github/workflows/       CI de base de datos
flyway.toml              configuración Flyway
```

## Modelo de datos

### `courts.courts`

| Columna | Tipo | Regla |
|---|---|---|
| `id` | UUID | PK, `gen_random_uuid()` |
| `name` | VARCHAR(100) | Obligatorio y único |
| `sport` | VARCHAR(50) | Obligatorio, valor MVP `FOOTBALL` |
| `capacity` | INTEGER | Obligatorio, mayor que cero |
| `hourly_price` | DECIMAL(10,2) | Obligatorio, mayor que cero; COP |
| `status` | VARCHAR(30) | `ACTIVE`, `INACTIVE` o `UNDER_MAINTENANCE` |
| `created_at` | TIMESTAMPTZ | Obligatorio, `NOW()` |
| `updated_at` | TIMESTAMPTZ | Obligatorio, `NOW()` |

Los cuatro identificadores acordados con `ftx-schedules-db` son:

- `c0000000-0000-4000-8000-000000000001`
- `c0000000-0000-4000-8000-000000000002`
- `c0000000-0000-4000-8000-000000000003`
- `c0000000-0000-4000-8000-000000000004`

**Antes de crear el seed**, confirmar con el equipo los valores reales de `capacity` y
`hourly_price` para cada cancha. No se inventan datos comerciales en una migración.

## Reglas

1. Los nombres SQL usan `snake_case`.
2. Las tablas usan nombres plurales.
3. Las PK son UUID.
4. Las fechas de auditoría usan `TIMESTAMPTZ`.
5. Los estados se restringen con `CHECK`, no con tipos `ENUM`.
6. Cada migración `V<n>` es inmutable después de ejecutarse.
7. Cada `V<n>` debe tener su rollback manual `U<n>`.
8. Las relaciones entre servicios son UUID lógicos sin FK.
9. La aplicación se conecta con el usuario propio del dominio, nunca con el administrador.
10. No ejecutar `docker compose down -v` en QA o main.

## Ejecución

La instancia única se levanta desde `ftx-infra-postgres`. Este repositorio solo ejecuta
migraciones contra esa instancia. Los valores de conexión se suministran por variables
de entorno al runner; no se guardan contraseñas en Git.

## Gobernanza

Trabajar en ramas `feat/...`, `fix/...` o `chore/...` y abrir PR hacia `develop`.
Las promociones se hacen mediante ramas creadas desde `qa` y `main` y `git cherry-pick -x`,
según las normas Futbolix. No hacer commits directos a ramas permanentes.
