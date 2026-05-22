# Database Safety Protocol — Project PathBuilder

This is a hard gate. Do not skip it.

---

## The Rule

**Never write to, create, alter, drop, truncate, or delete from the database
without Justin's explicit approval in this conversation.**

---

## What "DB work" means

Any of the following require the approval gate:
- `CREATE SCHEMA`
- `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`
- `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`
- Any migration script execution
- Any schema diff or patch

Read-only operations (`SELECT`, `SHOW`, `DESCRIBE`, `\dt`, `\dn`) are always allowed.

---

## Before Any DB Write — Stop and Report

State all of the following before touching anything:

1. **Host** — (redacted, do not print the full connection string)
2. **Schema** — which schema will be modified
3. **User** — which DB user is executing
4. **What will change** — exact SQL, in full
5. **What already exists** — schemas/tables currently present
6. **Rollback SQL** — how to undo the change
7. **Migration file location** — which file contains the SQL

Then say:
> "Ready for DB approval. No changes made. Awaiting Justin's confirmation."

Do not proceed until Justin explicitly replies with approval.

---

## PathBuilder Schema Context

Target schema: `pathbuilder` (does not exist yet as of 2026-05-22)

The shared Postgres cluster currently has:
- `pathfinder_performance_dev` — 16 tables (KYPF dev/staging) — READ ONLY
- `transfer_poc` — 35 tables (rob_* tables) — READ ONLY
- `public` — empty

Do NOT create `pathbuilder_*` tables in `public`. Use the `pathbuilder` schema only.

---

## Dry-Run Rule

All migration scripts must be tested as a dry run first:
1. Run in a transaction: `BEGIN; [SQL]; ROLLBACK;` — confirm no errors before committing.
2. Report results of the dry run to Justin.
3. Only run `BEGIN; [SQL]; COMMIT;` after Justin approves the dry run output.

---

## Migration File Convention

Migration files live in: `database/migrations/`
File naming: `NNN_description.sql` (e.g., `001_create_pathbuilder_schema.sql`)
Each migration file includes a header comment with: purpose, author (agent ID), date, rollback SQL.

---

## What Never Requires Approval

- `SELECT` queries (read-only)
- `\dt`, `\dn`, `SHOW TABLES`, schema inspection
- Reading `information_schema`
- Drafting SQL migration files (writing the file is fine; running it is not)
