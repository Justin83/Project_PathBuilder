# DECISION LOG — Project PathBuilder

Format: D-[N] | Decision | Rationale | Alternatives considered | Date

---

D-001 | Use schema-level isolation in Postgres (`pathbuilder` schema) rather than `pathbuilder_*` table prefixes in `public` | Matches existing cluster pattern (pathfinder_performance_dev, transfer_poc); cleaner migration path; easier to dump/export independently | Table-name prefixes in public schema | 2026-05-22

D-002 | Use `PATHBUILDER_DB_SCHEMA=pathbuilder` env var instead of `PATHBUILDER_DB_TABLE_PREFIX` | Schema-level isolation makes the prefix env var redundant and confusing | Table prefix env var | 2026-05-22

D-003 | Reuse existing DigitalOcean Spaces with `pathbuilder/` prefix rather than creating a new bucket | Avoids new paid resource; logical separation sufficient for now | New dedicated Spaces bucket | 2026-05-22

D-004 | Do not create new App Platform apps for PathBuilder until routing/subdomain decision is made | Avoids unnecessary paid resources; existing kentuckypathfinderapi or a new app TBD | Immediate new App Platform app | 2026-05-22

D-005 | Land the pathbuilder schema via a dry-run-guarded SQL file (`database/migrations/001_create_pathbuilder_schema.sql`) rather than ad-hoc DDL in the postgres MCP | Matches DATABASE_SAFETY_PROTOCOL.md migration-file convention; the file ends in ROLLBACK so executing it as-is is a no-op; approval-flip from ROLLBACK to COMMIT is the visible audit-trail moment | Direct CREATE SCHEMA via MCP; pgAdmin manual session | 2026-05-22

D-006 | Defer creating user/enrollment/PII-bearing tables until the PII handling story is approved | INFRASTRUCTURE.md "Do not do yet: Store student PII" + co-op population includes minors; better to scaffold curriculum core (courses, units, lessons, labs, assignments) first and add students separately under a documented policy | Include students table in migration 001 | 2026-05-22
