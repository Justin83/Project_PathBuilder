# Infrastructure — Project PathBuilder
**Source of truth for all infrastructure knowledge in this repo.**
Last updated: 2026-05-22

---

## Overview

PathBuilder reuses existing DigitalOcean infrastructure rather than provisioning
new paid resources. Logical isolation is achieved through:

- **Database:** dedicated `pathbuilder` schema inside the shared Managed Postgres cluster
- **Object Storage:** `pathbuilder/` prefix inside the existing Spaces bucket
- **App Platform:** a route or subdomain added to an existing app (future, not yet done)

**Do not create new paid resources without Justin's explicit approval.**

---

## DigitalOcean App Platform — Existing Apps

These apps exist and serve KYPF production/staging traffic. Do not modify them.

| App | App ID | URL | Touch Policy |
|-----|--------|-----|-------------|
| kentuckypathfinderapi | `71478695-2484-4d38-8a35-4977b5af524a` | https://kentuckypathfinderapi-yf658.ondigitalocean.app | READ ONLY |
| remote-rob | `27953397-1097-46d8-9b09-928a121208d` | https://remote-rob-nbhz2.ondigitalocean.app | READ ONLY |

PathBuilder does not yet have its own App Platform app. A future option is to
add a `/pathbuilder` route or a subdomain to an existing app after approval.

---

## DigitalOcean API Token — Current Status

**STATUS: BROKEN**
A capability audit (2026-05-22) confirmed every DO REST API call returns:
> HTTP 401 — "Unable to authenticate you."

This is an **authentication failure**, not a scope failure. Most likely causes (in order):
1. The MCP server's token env var (`DIGITALOCEAN_API_TOKEN`) is unset or a placeholder.
2. The token was rotated or revoked in the DO control panel after MCP was configured.
3. The token expired — DigitalOcean now defaults personal access tokens to a **90-day expiry**.

Failed request IDs (for DO support lookup if needed) are in `docs/digitalocean-pathbuilder-capability-audit.md`.

**Before any DO API work:**
1. Refresh the token in the `agent-credentials` vault under `do-token`.
2. Re-run the read-only inventory (see `docs/digitalocean-pathbuilder-capability-audit.md`).
3. Confirm `doctl account get` succeeds before any further DO commands.
4. Use `doctl auth init --context pathbuilder-audit` for a named context.

**Tools not installed on this workstation (as of audit):**
`doctl`, `jq`, `aws` — only `git` and `curl` are confirmed present.

---

## Managed Postgres — Current Status

**STATUS: WORKING**
Postgres MCP authenticated as `doadmin` (DO managed-Postgres default).

**Shared cluster schemas:**

| Schema | Tables | Owner | Touch Policy |
|--------|--------|-------|-------------|
| `pathfinder_performance_dev` | 16 | KYPF dev/staging | READ ONLY |
| `transfer_poc` | 35 | KYPF / rob_* tables | READ ONLY |
| `public` | 0 | empty | Safe to use |
| `pathbuilder` | — | **DOES NOT EXIST YET** | Create after approval |

**PathBuilder isolation decision:**
Use schema-level isolation matching the existing cluster pattern.
Schema: `pathbuilder`
Do NOT use `pathbuilder_*` prefixed tables in `public`.

**Recommended DB role (audit recommendation — not yet created):**
Create a dedicated `pathbuilder_app` role scoped only to the `pathbuilder` schema.
This prevents PathBuilder app code from accidentally reading/writing KYPF or transfer_poc data.

```sql
-- DRAFT — do not run without Justin's approval
CREATE SCHEMA IF NOT EXISTS pathbuilder;
CREATE ROLE pathbuilder_app LOGIN PASSWORD '<set-out-of-band>';
GRANT USAGE ON SCHEMA pathbuilder TO pathbuilder_app;
GRANT CREATE ON SCHEMA pathbuilder TO pathbuilder_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA pathbuilder
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pathbuilder_app;
```

Full initial table migration draft:

```sql
-- DRAFT — do not run without Justin's approval
CREATE TABLE pathbuilder.courses (...);
CREATE TABLE pathbuilder.units (...);
CREATE TABLE pathbuilder.lessons (...);
CREATE TABLE pathbuilder.lesson_resources (...);
CREATE TABLE pathbuilder.labs (...);
CREATE TABLE pathbuilder.assignments (...);
CREATE TABLE pathbuilder.weekly_plans (...);
```

**Key env var:**
    PATHBUILDER_DB_SCHEMA=pathbuilder

---

## DigitalOcean Spaces — Current Status

**STATUS: UNKNOWN**
Spaces object access requires S3-compatible credentials separate from the DO API token:
- `SPACES_KEY`
- `SPACES_SECRET`
- `SPACES_REGION`
- `SPACES_BUCKET`
- `SPACES_ENDPOINT`

The DO API token alone cannot read/write Spaces objects even when it is working.
Bucket name, region, and endpoint are not yet confirmed.

**Proposed logical structure (not yet created):**
```
pathbuilder/
  biology/
    2026-fall/
      week-01/ ... week-15/
      labs/
      parent-guides/
      student-handouts/
  rendered-pdfs/
  images/
  downloads/
  source-exports/
```

Documents should be linked via storage_key values like:
    pathbuilder/biology/2026-fall/week-01/student-handout.pdf

**Key env var:**
    PATHBUILDER_STORAGE_PREFIX=pathbuilder/

**Before creating the pathbuilder/ prefix:**
1. Confirm bucket name and region.
2. Confirm S3 credentials exist in `agent-credentials` vault.
3. Get Justin's approval.
4. Upload a placeholder file to establish the prefix.

---

## Related Repos and Local Paths

| Repo / Path | Purpose | Relationship |
|-------------|---------|--------------|
| `C:\xampp\htdocs\kentuckypathfinder_API` | KYPF API — production | Sibling project — do not touch |
| `C:\xampp\htdocs\course_forge` | Course content build system | May provide rendered content for PathBuilder |
| `C:\Users\jhoward0193\OneDrive - KCTCS\course_forge` | OneDrive sync of course_forge | Source for BIO 152/153 content |
| `https://github.com/jhoward0193/lecture_notes_and_images.git` | Lecture notes and images repo | Reference source for course materials |

---

## Next Infrastructure Steps (ordered by priority)

**Safe — no approval needed:**
1. Refresh DO API token and confirm `doctl account get` works.
2. Re-run read-only DO inventory.
3. Confirm Spaces bucket name, region, and endpoint.
4. Confirm whether Spaces S3 keys exist in `agent-credentials`.

**Requires Justin's approval:**
5. Create `pathbuilder` schema in shared Postgres.
6. Run database migration.
7. Create `pathbuilder/` Spaces prefix (upload placeholder).
8. Add PathBuilder app route or subdomain to App Platform.
9. Add environment variables (`PATHBUILDER_DB_SCHEMA`, `PATHBUILDER_STORAGE_PREFIX`) to any deployed app.

**Do not do yet:**
- Create new DigitalOcean droplets or databases.
- Modify KYPF production app settings.
- Store student PII in any table.
- Create user/enrollment tables (deferred).
