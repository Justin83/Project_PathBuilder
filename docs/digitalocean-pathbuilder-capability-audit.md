# DigitalOcean PathBuilder Capability Audit (v2)

_Audit date: 2026-05-22_
_Auditor: claude-code, via MCP (`digitalocean`, `postgres`) — no `doctl` installed locally_
_Branch: `claude-code/do-capability-reaudit-v2`_
_Supersedes: v1 audit produced earlier the same day under the same filename. v1 has been deleted._
_Governed by: [`agentharness/OPERATING_PROTOCOL.md`](../agentharness/OPERATING_PROTOCOL.md), [`agentharness/INFRASTRUCTURE.md`](../agentharness/INFRASTRUCTURE.md), [`agentharness/DATABASE_SAFETY_PROTOCOL.md`](../agentharness/DATABASE_SAFETY_PROTOCOL.md), [`agentharness/ENVIRONMENT_PROTOCOL.md`](../agentharness/ENVIRONMENT_PROTOCOL.md), [`agentharness/1PASSWORD_STARTUP_PROTOCOL.md`](../agentharness/1PASSWORD_STARTUP_PROTOCOL.md)._

---

## Summary

Three concrete things have changed since v1:

1. **The DigitalOcean REST API token is still 401 across the board.** Ten different endpoints were re-tried; every one returned `HTTP 401 — "Unable to authenticate you."` Fresh DO request IDs are captured in [Commands That Failed](#commands-that-failed). The MCP server is sending *something* to `api.digitalocean.com`, but whatever it's sending is not a valid PAT. This matches `agentharness/INFRASTRUCTURE.md` line 36 (`STATUS: BROKEN`) — no change.
2. **The 1Password loading pipeline has never been bootstrapped on this workstation.** `OP_SERVICE_ACCOUNT_TOKEN` is not set as a User env var. None of `SPACES_KEY / SPACES_SECRET / SPACES_REGION / SPACES_BUCKET / SPACES_ENDPOINT / DO_TOKEN / DB_HOST / DB_NAME / DB_USER` are set in either Process or User scope. `op` is installed but cannot resolve `op://…` references silently without the SA token. This is the **root cause** of the DO 401 — the MCP server has no way to receive a refreshed token without the SA token being set first. v1 missed this; v2 names it explicitly.
3. **The shared Postgres cluster is much quieter than v1 implied.** Activity-heat sampling shows `pathfinder_performance_dev` is effectively dormant (0 rows in every sampled table) and `transfer_poc.rob_*` is *lightly* active (32 rows in `rob_runs`, most recent run 2026-05-16 — six days ago). Adding a `pathbuilder` schema is therefore very low risk; the cluster is not under sustained write load.

Postgres MCP is still authenticated as `doadmin`, schema list is unchanged, and `pathbuilder` still does not exist. A draft migration is now committed at [`database/migrations/001_create_pathbuilder_schema.sql`](../database/migrations/001_create_pathbuilder_schema.sql), marked **DRAFT — DO NOT RUN WITHOUT JUSTIN'S APPROVAL**, with a `ROLLBACK` at the bottom that must be manually flipped to `COMMIT` after the dry-run output is approved per `DATABASE_SAFETY_PROTOCOL.md` lines 59–64.

No infrastructure was changed. No DDL was executed. No secrets are in this report or anywhere in the diff.

---

## Harness alignment

Each finding below ties back to the protocol doc that governs it. The first audit had to infer these; v2 cites them.

| Finding | Governing protocol | Where in protocol |
|---|---|---|
| Token loading must go through 1Password | `agentharness/1PASSWORD_STARTUP_PROTOCOL.md` | Whole file; especially lines 9–14 (silent loader rationale) and 15–32 (one-time SA-token setup) |
| `OP_SERVICE_ACCOUNT_TOKEN` must be a User env var | `agentharness/1PASSWORD_STARTUP_PROTOCOL.md` lines 17–25 | The exact PowerShell `[System.Environment]::SetEnvironmentVariable(...,'User')` recipe |
| Per-agent env files live at `agents/<agent-id>.env`, op:// refs only | `agentharness/ENVIRONMENT_PROTOCOL.md` lines 41–60 | Variable table; `claude-code.env` already conforms |
| Validate env vars by length, never echo | `agentharness/ENVIRONMENT_PROTOCOL.md` lines 65–79 | Used throughout this report |
| Spaces object access requires separate S3 keys | `agentharness/ENVIRONMENT_PROTOCOL.md` lines 53–57; `INFRASTRUCTURE.md` lines 109–120 | DO API token alone is insufficient |
| `pathbuilder` schema, not `pathbuilder_*` table prefixes | `agentharness/DATABASE_SAFETY_PROTOCOL.md` line 55; `INFRASTRUCTURE.md` lines 72–75 | Schema isolation pattern |
| DDL requires Justin approval, dry-run first | `agentharness/DATABASE_SAFETY_PROTOCOL.md` lines 27–64 | `BEGIN; … ROLLBACK;` → approval → `COMMIT` |
| Migration files at `database/migrations/NNN_description.sql` | `agentharness/DATABASE_SAFETY_PROTOCOL.md` lines 70–72 | This audit's migration follows the convention |
| KYPF apps are read-only | `agentharness/INFRASTRUCTURE.md` lines 24–27 | `kentuckypathfinderapi`, `remote-rob` |
| Branch / commit / PR conventions | `agentharness/GITHUB_WORKFLOW.md` lines 9–29, 48–76 | This audit's PR follows the template |
| Slack timestamp and channel routing | `agentharness/SLACK_POSTING_PROTOCOL.md` lines 7–12, 23–34 | Drafts in the handoff doc follow this |
| Don't push to main | `CLAUDE.md` line 29 | Hard rule |

---

## 1Password loading status (new in v2)

All checks are length-only. No values are printed.

| Variable | Scope checked | Result |
|---|---|---|
| `OP_SERVICE_ACCOUNT_TOKEN` | User | **NOT SET** |
| `DO_TOKEN` | Process and User | NOT SET |
| `SPACES_KEY` | Process and User | NOT SET |
| `SPACES_SECRET` | Process and User | NOT SET |
| `SPACES_REGION` | Process and User | NOT SET |
| `SPACES_BUCKET` | Process and User | NOT SET |
| `SPACES_ENDPOINT` | Process and User | NOT SET |
| `DB_HOST` / `DB_NAME` / `DB_USER` | Process and User | NOT SET |

CLI presence:
| Tool | Status | Path |
|---|---|---|
| `op` (1Password CLI) | ✅ Installed | `C:\Users\…\WinGet\Packages\AgileBits.1Password.CLI_*\op.exe` |
| `git` | ✅ Installed | `C:\Program Files\Git\cmd\git.exe` |
| `curl` | ✅ Installed | Windows built-in |
| `doctl` | ❌ Not installed | Suggested install (not run): `winget install --id DigitalOcean.Doctl` |
| `jq` | ❌ Not installed | Suggested install (not run): `winget install --id jqlang.jq` |
| `aws` | ❌ Not installed | Only needed for S3-compatible Spaces clients |

**Interpretation.** The postgres MCP works because it has its own connection configured in `claude_desktop_config.json` (independent of the agent env-file pattern). The DO MCP and any future Spaces tooling will not start picking up refreshed credentials until the 1Password startup protocol is actually executed on this workstation. The first remediation step is therefore the one-time SA-token setup in `1PASSWORD_STARTUP_PROTOCOL.md` lines 15–32, followed by a Claude Code restart so MCP servers pick up the SA-resolved env.

---

## Token capability matrix

Every DO API call below returned `HTTP 401 — Unable to authenticate you` from `api.digitalocean.com`. The matrix records what was attempted, the governing scope, and the remediation.

| Area | Command tested (MCP) | Result | Permission/scope notes | Risk | Recommended next step |
|---|---|---|---|---|---|
| Account | `account-get-information` | 401 | Any valid token | None | Bootstrap 1Password, then refresh `do-token` in `agent-credentials` vault, restart MCP. |
| Account (balance) | `balance-get` | 401 | Any valid token | None | Same. |
| Projects | (not retried — token known bad) | n/a | `project:read` | None | Same. |
| Apps | `apps-list` | 401 | `app:read` | None | After fix, `apps-get-info` for `71478695-…` and `27953397-…`. |
| Droplets | `droplet-list` | 401 | `droplet:read` | None | After fix. |
| Managed Databases | `db-cluster-list` | 401 | `database:read` | None | After fix; cluster ID can also be partially inferred from postgres MCP. |
| Spaces (control plane) | (not exposed by this MCP build) | n/a | `spaces_key:read` | None | List via `doctl spaces bucket list` after fix. |
| Spaces (object plane) | n/a | n/a | Separate S3 keys (`SPACES_KEY` / `SPACES_SECRET`) | None | Independent of DO API token; needed even after token is fixed. |
| Domains/DNS | `domain-list` | 401 | `domain:read` | None | After fix. |
| Certificates | `certificate-list` | 401 | `certificate:read` | None | After fix. |
| Firewalls | `firewall-list` | 401 | `firewall:read` | None | After fix. |
| VPCs | `vpc-list` | 401 | `vpc:read` | None | After fix. |
| Registry | (needs name to list; can't list without account access) | n/a | `registry:read` | None | After fix. |
| SSH Keys | `key-list` | 401 | `ssh_key:read` | None | After fix. |

**Diagnosis** (unchanged from v1, refined by v2's env-var check): every endpoint 401s, including those that work with the lowest-privilege scopes. This is *authentication*, not *scope*. The token the MCP server is using is unset, revoked, or expired. The fact that no `DO_TOKEN` is set in the workstation environment and the 1Password SA-token isn't bootstrapped means the MCP server is almost certainly running with a stale token baked into its config (or no token at all). The remediation order is:

1. Set `OP_SERVICE_ACCOUNT_TOKEN` as a Windows User env var per `1PASSWORD_STARTUP_PROTOCOL.md` lines 17–25.
2. Refresh the `do-token` field on the `claude-code` (or other agent) item in the `agent-credentials` vault if it's stale.
3. Wrap the DO MCP server with `op run --env-file C:\xampp\htdocs\Project_PathBuilder\agents\claude-code.env --` per `1PASSWORD_STARTUP_PROTOCOL.md` lines 44–63.
4. Restart Claude Code so the MCP server is re-spawned with the resolved env.
5. Re-run this audit's Phases 2–6.

---

## App Platform inspection

**Not possible from this session** — `apps-list` returned 401 (request `d15f1988-c226-4102-8ec4-6a57d607c76f`).

Once the token is refreshed, the planned read-only sequence is the same as v1:

1. `apps-list` → confirm IDs.
2. For each, `apps-get-info <APP_ID>` to capture name, default URL, GitHub repo/branch, services, routes, **env var names only**, DB bindings.
3. Decide per-app whether PathBuilder can ride along (new route/component) or needs its own app.

Both target apps are READ ONLY per `INFRASTRUCTURE.md` lines 24–27:

| App | App ID | URL | Touch policy |
|---|---|---|---|
| `kentuckypathfinderapi` | `71478695-2484-4d38-8a35-4977b5af524a` | https://kentuckypathfinderapi-yf658.ondigitalocean.app | READ ONLY |
| `remote-rob` | `27953397-1097-46d8-9b09-928a121208d` | https://remote-rob-nbhz2.ondigitalocean.app | READ ONLY |

No app spec was retrieved or modified.

---

## Managed Database inspection

The postgres MCP is authenticated as `doadmin` on the shared cluster. Schema list is unchanged from v1:

| Schema | Tables | Owner | Touch policy |
|---|---|---|---|
| `pathfinder_performance_dev` | 16 | `doadmin` | READ ONLY |
| `transfer_poc` | 35 | `doadmin` | READ ONLY |
| `public` | 0 | `pg_database_owner` | Safe but PathBuilder will not use it |
| `pathbuilder` | — | **DOES NOT EXIST** | To be created via migration 001 after approval |

### Activity heat (new in v2)

Sampled read-only `COUNT(*)` and `MAX(timestamp)` across representative tables, current as of 2026-05-22:

| Source | Row count | Most recent `created_at` | Most recent run/finish |
|---|---:|---|---|
| `transfer_poc.rob_runs` | 32 | 2026-05-16 01:05:23 UTC | run_at 2026-05-16 01:05:18 UTC |
| `transfer_poc.rob_memory` | 29 | 2026-05-14 04:14:09 UTC | run_at 2026-05-14 04:13:59 UTC |
| `transfer_poc.rob_milestone_state` | 0 | — | — |
| `transfer_poc.agent_event_log` | 39 | 2026-04-19 02:18:32 UTC | — |
| `transfer_poc.ingest_jobs` | 32 | started 2026-05-11 06:07:18 UTC | finished 2026-05-11 06:13:02 UTC |
| `transfer_poc.scrape_log` | 428 | started 2026-04-19 23:36:12 UTC | finished 2026-04-19 23:40:30 UTC |
| `pathfinder_performance_dev.activities` | 0 | — | — |
| `pathfinder_performance_dev.scrape_runs` | 0 | — | — |
| `pathfinder_performance_dev.users` | 0 | — | — |
| `pathfinder_performance_dev.documentation_files` | 0 | — | — |

**Interpretation.** `pathfinder_performance_dev` is effectively dormant on the rows sampled — the schema exists but isn't being populated. `transfer_poc` is lightly active: remote-rob has written occasional rows (last run six days ago) and ingest/scrape work is monthly-cadence at most. The cluster is not under sustained write pressure. Creating the `pathbuilder` schema and writing initial seed rows will not interfere with existing workloads.

No DDL was run.

---

## Spaces / Object Storage capability

**Not testable from this session.** Spaces access has two layers:

1. **Control plane** (list/create/delete buckets) — requires the DO API token, currently 401.
2. **Object plane** (read/write objects in a bucket) — requires the **separate** S3-compatible Spaces keys (`SPACES_KEY`, `SPACES_SECRET`, `SPACES_REGION`, `SPACES_BUCKET`, `SPACES_ENDPOINT`) per `ENVIRONMENT_PROTOCOL.md` lines 53–57.

Neither is configured locally on this workstation. All five Spaces env vars are NOT SET in both Process and User scopes.

**Proposed logical structure** (unchanged from `INFRASTRUCTURE.md` lines 122–135 — no upload performed):

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

No buckets were created. No object was uploaded. No new Spaces keys were generated.

---

## Domain / DNS capability

**Not testable from this session** — `domain-list` returned 401 (request `e03f8a0c-9bb1-43d5-befa-de40660e2ebf`). No DNS records were created or modified.

After the token is refreshed, the path forward is the same as v1: enumerate domains, then decide between subdomain (`pathbuilder.<existing-domain>`), separate name (`projectpathbuilder.<existing-domain>`), or path under existing host (`<existing-domain>/pathbuilder`).

---

## Existing resources found (this session)

Confirmed today via postgres MCP only — DO API is still locked out:

- **Shared managed Postgres cluster.** Authenticated as `doadmin`. Two non-system user schemas (`pathfinder_performance_dev`, `transfer_poc`), one empty `public`. Activity heat reported above.

Suspected but **unverified** today (will be confirmed after token refresh):

- App Platform apps `kentuckypathfinderapi` (`71478695-…`) and `remote-rob` (`27953397-…`) — named in `INFRASTRUCTURE.md`, not re-confirmed via API today.
- Spaces bucket name, region, endpoint.
- DigitalOcean DNS domains.

---

## Reuse recommendation

**Yes, with schema-level isolation.** The activity-heat numbers reinforce this: the cluster is lightly used, schemas are already used as the isolation pattern by the existing two projects, and `public` is empty. Adding a third schema is safe.

Reusing an existing App Platform app is still **deferred** — neither spec has been inspected, so the question "can PathBuilder be a route on `kentuckypathfinderapi`?" can't be answered without API access. Plan to add PathBuilder as a new component/service after the token is fixed, and revisit "merge into KYPF" only after a real spec inspection.

---

## Recommended logical separation

(Unchanged from v1; restated for completeness against the harness.)

| Layer | Pattern | Reference |
|---|---|---|
| Database | Schema `pathbuilder` | `INFRASTRUCTURE.md` line 70; `DATABASE_SAFETY_PROTOCOL.md` line 48 |
| Tables | `pathbuilder.courses`, `pathbuilder.units`, `pathbuilder.lessons`, `pathbuilder.lesson_resources`, `pathbuilder.weekly_plans`, `pathbuilder.labs`, `pathbuilder.assignments` | This audit's migration 001 |
| DB user | `pathbuilder_app` login role, granted only on the `pathbuilder` schema | `INFRASTRUCTURE.md` lines 77–89 |
| Spaces | Prefix `pathbuilder/` inside an existing bucket (no new bucket) | `INFRASTRUCTURE.md` line 93; `DECISION_LOG.md` D-003 |
| Routing | Subdomain `pathbuilder.<existing-domain>` preferred over path prefix | Decision deferred until domain list is visible |
| Env vars | `PATHBUILDER_DB_SCHEMA=pathbuilder`, `PATHBUILDER_STORAGE_PREFIX=pathbuilder/` | `ENVIRONMENT_PROTOCOL.md` lines 45–46; `DECISION_LOG.md` D-002 |

---

## Risks / things not to touch

- **`pathfinder_performance_dev`** — KYPF dev/staging schema. Read-only.
- **`transfer_poc`** — transfer/Rob schema. Read-only. Especially `rob_*`, `student_*`, `audit_log`, `scrape_log`.
- **`kentuckypathfinderapi` app spec and env vars.** Hard READ ONLY per `INFRASTRUCTURE.md` line 26.
- **`remote-rob` app spec and env vars.** Hard READ ONLY per `INFRASTRUCTURE.md` line 27.
- **Production DNS.** No record changes without explicit per-record approval.
- **The DigitalOcean API token in the control panel.** Do not rotate it as part of this work; if it must be replaced, do it interactively with Justin in the loop.
- **`main` branch.** Never push directly per `CLAUDE.md` line 29.

---

## Commands that failed

All ten calls below returned `401 Unable to authenticate you`. Request IDs are from this session (2026-05-22), useful if DO support is asked to look up rejected calls.

| MCP tool | HTTP | DigitalOcean request ID | Likely reason |
|---|---|---|---|
| `account-get-information` | 401 | `1b286230-4ade-47e4-9086-9e1a3702a7c9` | MCP token unset / expired / revoked. SA-token bootstrap not done. |
| `apps-list` | 401 | `d15f1988-c226-4102-8ec4-6a57d607c76f` | Same. |
| `db-cluster-list` | 401 | `5bd06e8c-60ee-4a09-b839-9604c1a5aa03` | Same. |
| `domain-list` | 401 | `e03f8a0c-9bb1-43d5-befa-de40660e2ebf` | Same. |
| `droplet-list` | 401 | `5c9ef7a6-177a-4758-9b6a-98d27a7ea25d` | Same. |
| `certificate-list` | 401 | `e31b8f9c-2672-4ff5-a6b4-fd5a46731fd0` | Same. |
| `firewall-list` | 401 | `e4d642a0-74f6-4888-8213-ad18c6fbc59c` | Same. |
| `vpc-list` | 401 | `59e31fae-de26-496a-8662-d6cf064fa9e7` | Same. |
| `balance-get` | 401 | `53ae290a-7d60-4177-a4df-037829c34b64` | Same. |
| `key-list` | 401 | `c83e0674-23a5-4f27-b177-02a7ce1b117b` | Same. |

V1 request IDs from earlier the same day are preserved in git history (commit prior to v1 deletion); they are no longer needed for triage.

Local commands not run because the tool is not installed: `doctl version`, `doctl auth list`, `doctl auth init --context pathbuilder-audit`, `doctl auth switch --context pathbuilder-audit`, `doctl account get`, `doctl projects list`, `doctl apps list`, `doctl databases list`, `doctl compute droplet list`, `doctl compute domain list`, `doctl compute certificate list`, `doctl compute firewall list`, `doctl vpcs list`, `doctl registry get`, `doctl spaces bucket list`.

---

## Proposed next actions

### Safe next actions (read-only — no infrastructure change)

1. **Bootstrap the 1Password SA token** per `1PASSWORD_STARTUP_PROTOCOL.md` lines 15–32. This unblocks every subsequent step. Verify with the length-only check on line 28 of that doc.
2. **Refresh the `do-token` field** on the `claude-code` item in the `agent-credentials` vault (or whichever agent the MCP server resolves through). If the token in the DO control panel is older than 90 days it is expired by default.
3. **Restart Claude Code** so the DO MCP server picks up the resolved token.
4. **Re-run Phases 2–6 of this audit** against the now-working API. The migration draft and handoff doc do not need to change unless the resolved findings contradict them.
5. **Confirm Spaces bucket identity** (`SPACES_BUCKET`, `SPACES_REGION`, `SPACES_ENDPOINT`) once the API works, so a future placeholder upload knows where to land.

### Requires Justin's approval before running

1. **Install `doctl` on this workstation** (`winget install --id DigitalOcean.Doctl`) — provides a CLI fallback when the MCP is down.
2. **Approve the dry-run of `database/migrations/001_create_pathbuilder_schema.sql`** per `DATABASE_SAFETY_PROTOCOL.md` lines 59–64. Process: run the file as written (it ends in `ROLLBACK;`), share the output, then flip `ROLLBACK;` to `COMMIT;` on Justin's "approved" reply and re-run.
3. **Create a Spaces "limited" Access Key** scoped to a single bucket/prefix for PathBuilder, instead of reusing another project's keys.
4. **Add the DNS record** for the chosen subdomain (after the domain list is visible).
5. **Decide whether PathBuilder lives as a route on an existing App Platform app or as a new app**, after spec inspection.

### Do not do yet

- Do not create a new Spaces bucket. Reuse with a `pathbuilder/` prefix.
- Do not modify `kentuckypathfinderapi` or `remote-rob` env vars or app specs.
- Do not run any DDL against `pathfinder_performance_dev` or `transfer_poc`.
- Do not generate a new DO **write-scoped** API token until the read-scoped path is end-to-end verified.
- Do not store student PII in any new table (per `INFRASTRUCTURE.md` line 180). User/enrollment tables are deferred.

---

## Possible next setup commands — NOT RUN

Documented for later approval. None were executed.

1. **One-time SA-token bootstrap** (replaces "refresh token somewhere"):
   ```powershell
   # NOT RUN — example only
   [System.Environment]::SetEnvironmentVariable(
     "OP_SERVICE_ACCOUNT_TOKEN",
     "<paste-SA-token-from-1Password>",
     "User"
   )
   # then restart Claude Code
   ```

2. **Load `claude-code` agent credentials via op run** (after SA token is set):
   ```powershell
   # NOT RUN — example only
   op run --env-file C:\xampp\htdocs\Project_PathBuilder\agents\claude-code.env -- doctl account get
   ```

3. **Dry-run the schema migration**:
   ```powershell
   # NOT RUN — example only
   # The migration file already ends in ROLLBACK. Just execute it; nothing persists.
   psql "$env:DATABASE_URL" -f database/migrations/001_create_pathbuilder_schema.sql
   ```

4. **Approved commit of the schema migration** (after Justin approves the dry run):
   ```
   # NOT RUN — example only
   # 1. Edit database/migrations/001_create_pathbuilder_schema.sql:
   #    change the final 'ROLLBACK;' to 'COMMIT;'
   # 2. Re-run.
   # 3. Set the pathbuilder_app password out-of-band:
   #      ALTER ROLE pathbuilder_app PASSWORD '<rotated-out-of-band>';
   ```

5. **Place the Spaces prefix marker** (requires S3 keys, not the API token):
   ```
   # NOT RUN — example only
   op run --env-file ./agents/claude-code.env -- aws \
     --endpoint-url "$SPACES_ENDPOINT" \
     s3 cp .keep "s3://$SPACES_BUCKET/pathbuilder/.keep"
   ```

6. **Add the subdomain** (after domain list is visible):
   ```
   # NOT RUN — example only
   doctl compute domain records create <existing-domain> \
     --record-type A --record-name pathbuilder --record-data <ip>
   ```

7. **Add app env vars** (after a PathBuilder route/component exists):
   ```
   # NOT RUN — example only
   # Spec-driven; no direct env-var mutation. See GITHUB_WORKFLOW.md hard
   # no-merge condition: DO App env vars require approval (line 100).
   ```

---

## What changed between v1 and v2

| Aspect | v1 | v2 |
|---|---|---|
| Token diagnosis | "Refresh the token in the DO control panel." | Names the 1Password vault, field, MCP-wrapping pattern, and SA-token bootstrap as the actual prerequisite. |
| 1Password loading | Not mentioned. | Length-only audit; identifies `OP_SERVICE_ACCOUNT_TOKEN` not set as the root blocker. |
| Cluster activity | Not measured. | Measured: `pathfinder_performance_dev` dormant; `transfer_poc.rob_*` lightly active (last write 2026-05-16). |
| Migration scaffold | Sketch in the report body. | Real file at `database/migrations/001_create_pathbuilder_schema.sql`, dry-run-guarded with `ROLLBACK`. |
| Env var naming | `PATHBUILDER_DB_TABLE_PREFIX` proposed; later corrected. | `PATHBUILDER_DB_SCHEMA` only — matches `ENVIRONMENT_PROTOCOL.md` and `DECISION_LOG.md` D-002. |
| Operational wrapper | None. | Feature branch, foundation commit + audit commit, PR per `GITHUB_WORKFLOW.md`, handoff doc per `SPRINT_HANDOFF_PROTOCOL.md`, drafted Slack posts. |
| References | None to harness (it didn't exist). | Every section cites the governing protocol with line numbers. |
