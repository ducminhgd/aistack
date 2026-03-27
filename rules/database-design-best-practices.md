# Database Design Best Practices — RDBMS (PostgreSQL & MySQL/MariaDB)

## Schema Design

1. **Normalize to 3NF by default**: Eliminate data redundancy and update anomalies. Denormalize only for proven, measured performance needs.
2. **Every table must have a primary key**: Use surrogate keys (`BIGINT` or `UUID`) as the PK. Never use natural keys (email, username, phone) as PKs — they change.
3. **Prefer `BIGINT` surrogate keys for most tables**: Fast, compact index. Use `UUID` (`uuid_generate_v4()` in PostgreSQL, `UUID()` in MySQL) when distributed generation or external exposure is needed.
4. **Use `SERIAL` / `BIGSERIAL` (PostgreSQL) or `AUTO_INCREMENT BIGINT` (MySQL)** for auto-incrementing integer PKs.
5. **Consistent naming conventions**:

   | Element | Convention | Example |
   |---|---|---|
   | Tables | `snake_case`, plural nouns | `users`, `order_items` |
   | Columns | `snake_case` | `first_name`, `created_at` |
   | Primary key | `id` | `id BIGINT` |
   | Foreign keys | `{referenced_table_singular}_id` | `user_id`, `order_id` |
   | Indexes | `idx_{table}_{columns}` | `idx_users_email` |
   | Unique constraints | `uq_{table}_{columns}` | `uq_users_email` |
   | Check constraints | `chk_{table}_{column}` | `chk_orders_status` |

6. **Use explicit foreign key constraints**: Define `FOREIGN KEY ... REFERENCES` — do not rely on application-level enforcement alone.
7. **Define `ON DELETE` and `ON UPDATE` behavior explicitly**: Default to `RESTRICT` and document any deviation (`CASCADE`, `SET NULL`).

## Column Design

8. **Choose the smallest sufficient data type**: `INT` over `BIGINT` when values fit; `VARCHAR(n)` over `TEXT` when length is bounded (PostgreSQL `TEXT` is fine without a length; MySQL `TEXT` has different storage rules).
9. **Use `NOT NULL` by default**: A column should be nullable only when `NULL` has a specific, distinct meaning from an empty value or zero.
10. **Avoid storing `NULL` and empty string for the same column**: Pick one representation and enforce it with a check constraint.
11. **Use `TEXT` / `VARCHAR` for strings, not `CHAR(n)`** unless fixed-length padding is explicitly required.
12. **Use `BOOLEAN` for boolean values** (PostgreSQL native; MySQL `TINYINT(1)` — prefer `BOOLEAN` alias).
13. **Use `TIMESTAMPTZ` (PostgreSQL) or `DATETIME` with explicit UTC (MySQL)** for all timestamps. Never store local time. Store and retrieve in UTC.
14. **Use `NUMERIC(precision, scale)` for money/financial values** — never `FLOAT` or `DOUBLE` (floating-point rounding errors).
15. **Use `JSONB` (PostgreSQL) for semi-structured data** that must be queried. Use `JSON` only for opaque storage. Avoid storing structured data that should be columns as JSON.
16. **Enums**: Use a `VARCHAR` with a `CHECK` constraint or a lookup/reference table rather than a database `ENUM` type — `ENUM` is expensive to alter in MySQL and inflexible in both engines.

## Constraints and Integrity

17. **Enforce uniqueness at the database level** with `UNIQUE` constraints, not only in application code.
18. **Use `CHECK` constraints** to enforce valid domain values at the DB level:
    ```sql
    CHECK (status IN ('pending', 'active', 'cancelled'))
    CHECK (amount > 0)
    CHECK (end_date > start_date)
    ```
19. **Do not store derived data** that can be computed from existing columns unless it is a measured performance necessity.
20. **Use junction/association tables** for many-to-many relationships with a composite PK on both FK columns:
    ```sql
    CREATE TABLE user_roles (
        user_id BIGINT NOT NULL REFERENCES users(id),
        role_id BIGINT NOT NULL REFERENCES roles(id),
        PRIMARY KEY (user_id, role_id)
    );
    ```

## Indexing

21. **Index every foreign key column**: Joins and cascade operations on unindexed FKs cause full-table scans.
22. **Index columns used in `WHERE`, `JOIN ON`, and `ORDER BY`** clauses that appear in frequent queries.
23. **Use composite indexes in the correct column order**: The leading column must match the most selective or most common filter. `(a, b)` satisfies queries on `a` and `(a, b)` but not on `b` alone.
24. **Use partial indexes (PostgreSQL)** to index only the rows that matter:
    ```sql
    CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';
    ```
25. **Use covering indexes** to avoid table heap fetches for hot read paths:
    ```sql
    CREATE INDEX idx_users_email_name ON users(email) INCLUDE (first_name, last_name);
    ```
26. **Remove unused indexes**: They slow down writes and consume disk. Use `pg_stat_user_indexes` (PostgreSQL) or `sys.schema_unused_indexes` (MySQL) to identify them.
27. **Avoid indexing low-cardinality columns** (e.g. a boolean column with 90% `true`) — the query planner will prefer a full scan.

## Migrations

28. **Every schema change must be a versioned migration file**: Use Flyway, Liquibase, Alembic, or `golang-migrate`. Never apply ad-hoc SQL to production.
29. **Migrations must be idempotent or versioned**: Use `IF NOT EXISTS`, `IF EXISTS`, or migration version tracking so re-runs are safe.
30. **Separate DDL from DML migrations**: Schema changes (`ALTER TABLE`) and data backfills are separate migration steps.
31. **Large table migrations must be online/non-blocking**: Use `pt-online-schema-change` (MySQL) or PostgreSQL's `ADD COLUMN ... DEFAULT` (PostgreSQL 11+, which is instant for non-volatile defaults). Never lock large tables in production.
32. **Always write a rollback migration** alongside the forward migration.
33. **Test migrations on a production-size data copy** before applying to production.

## Soft Deletes and Audit Trails

34. **Use soft deletes where appropriate**: Add `deleted_at TIMESTAMPTZ` (nullable). Query with `WHERE deleted_at IS NULL`. Use a partial index:
    ```sql
    CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;
    ```
35. **Add audit columns to every mutable table**:
    ```sql
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id)
    ```
36. **Use a trigger or application layer to maintain `updated_at`** automatically.

## Transactions

37. **Keep transactions short**: Long-running transactions hold locks, block vacuuming (PostgreSQL), and reduce throughput.
38. **Use the appropriate isolation level**: Default (`READ COMMITTED`) is correct for most OLTP workloads. Use `REPEATABLE READ` or `SERIALIZABLE` only when necessary and understand the performance implications.
39. **Retry on serialization failures**: Transactions at `REPEATABLE READ` or `SERIALIZABLE` can fail with a serialization error and must be retried by the application.
40. **Never issue user-facing HTTP calls inside a transaction**: External calls can be slow or fail, holding DB locks open.

## Performance

41. **Use `EXPLAIN ANALYZE`** to understand query plans before optimizing. Never guess.
42. **Use connection pooling**: PgBouncer (PostgreSQL) or ProxySQL (MySQL). Never open a direct connection from each application process.
43. **Set appropriate `work_mem`, `shared_buffers`, `max_connections`** (PostgreSQL) or `innodb_buffer_pool_size`, `max_connections` (MySQL) based on workload and available memory.
44. **Run `VACUUM ANALYZE` regularly (PostgreSQL)**: Enable `autovacuum`. Monitor for bloat.
45. **Use `RETURNING` (PostgreSQL)** to retrieve inserted/updated rows without a second query:
    ```sql
    INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id, created_at;
    ```
46. **Avoid `SELECT *`**: Select only the columns needed. Prevents accidental large column fetches and breaks less when the schema changes.

## PostgreSQL-Specific

47. **Use schemas (`search_path`) to namespace objects**: Separate application tables (`app`), audit tables (`audit`), extensions (`extensions`).
48. **Install extensions in a dedicated schema**: `CREATE EXTENSION pgcrypto SCHEMA extensions`.
49. **Use `GENERATED ALWAYS AS IDENTITY`** (SQL standard) instead of `SERIAL` for new tables (PostgreSQL 10+).
50. **Use `pg_partman` or declarative partitioning** for tables projected to exceed ~50M rows.
51. **Row-Level Security (RLS)**: Use for multi-tenant databases to enforce data isolation at the database level.

## MySQL/MariaDB-Specific

52. **Always use the `InnoDB` storage engine**: Never use `MyISAM` for application data — it lacks transactions and FK support.
53. **Character set and collation**: Use `utf8mb4` charset and `utf8mb4_unicode_ci` (or `utf8mb4_0900_ai_ci` for MySQL 8) collation on every table and column that stores text. Set as the server default.
54. **Use `DATETIME` for timestamps that must survive timezone changes** and store values explicitly in UTC. Use `TIMESTAMP` only when automatic UTC conversion behavior is desired and understood.
55. **`BIGINT UNSIGNED AUTO_INCREMENT`** for PK IDs to maximize the available range.
56. **Be explicit about `STRICT_TRANS_TABLES` mode**: Ensure SQL mode includes strict mode to prevent silent data truncation.
57. **`SHOW ENGINE INNODB STATUS`**: Use to diagnose lock waits and deadlocks.
