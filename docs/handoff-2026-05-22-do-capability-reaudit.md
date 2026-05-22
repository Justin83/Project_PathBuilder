# Handoff — DigitalOcean Capability Re-Audit (v2)

Date: 2026-05-22
Agent: claude-code
Branch: `claude-code/do-capability-reaudit-v2`
Intended next reader: **the GPT planner** (ChatGPT acting as PathBuilder project planner)

---

## Summary

The DO capability audit was re-run under the new agent harness. v1 was deleted; v2 lives at `docs/digitalocean-pathbuilder-capability-audit.md` and is the single source of truth. The DigitalOcean REST API is still 401 across every endpoint (ten fresh request IDs captured in the audit), but the root cause is now identified: `OP_SERVICE_ACCOUNT_TOKEN` has never been set on this workstation, so `op run` cannot resolve `agent-credentials` vault values silently and the DO MCP server has no path to a refreshed token. The postgres MCP is unaffected (it has its own connection in `claude_desktop_config.json`) and confirms the shared cluster is lightly used — `pathbuilder` schema does not exist, `pathfinder_performance_dev` is dormant on every sampled table, `transfer_poc.rob_*` shows small activity (last write 2026-05-16). A dry-run-guarded schema migration is committed at `database/migrations/001_create_pathbuilder_schema.sql` ready for approval.

## Completed

- Created feature branch `claude-code/do-capability-reaudit-v2` (not yet pushed; not yet PR'd — see Decisions Needed below).
- Committed previously-untracked foundation: `CLAUDE.md`, `agentharness/`, `agent-harness/`, `agents/`, `config/project.yml`, `.gitignore`, `CHANGELOG.md`, `DECISION_LOG.md`. Commit SHA: see `git log --oneline`. No secrets in the diff; all `agents/*.env` files are op:// references only.
- Re-ran the read-only DigitalOcean inventory via the `digitalocean` MCP — ten endpoints, ten 401s, request IDs in the audit.
- Length-only audited every relevant env var: `OP_SERVICE_ACCOUNT_TOKEN`, `DO_TOKEN`, `SPACES_*`, `DB_*`, `DATABASE_URL`. All NOT SET. `op` CLI is installed.
- Measured Postgres activity heat across both user schemas (queries in audit). Cluster is lightly used.
- Drafted `database/migrations/001_create_pathbuilder_schema.sql` per `DATABASE_SAFETY_PROTOCOL.md` lines 70–72 with header (purpose/author/date/rollback) and a final `ROLLBACK;` so executing it as-is is a no-op.
- Deleted v1 audit doc and wrote v2 replacement at the same path.
- Appended a row to `CHANGELOG.md` for the v2 audit.
- Added `D-005` (migration-file-as-gate) and `D-006` (defer student/PII tables) to `DECISION_LOG.md`.
- Drafted Slack posts (below — none have been sent).

## Changed files

| File | Change |
|---|---|
| `docs/digitalocean-pathbuilder-capability-audit.md` | Deleted v1, wrote v2 (harness-aligned) at same path |
| `docs/handoff-2026-05-22-do-capability-reaudit.md` | New — this file |
| `database/migrations/001_create_pathbuilder_schema.sql` | New — dry-run-guarded schema + role + initial tables |
| `CHANGELOG.md` | Appended row for v2 audit |
| `DECISION_LOG.md` | Added D-005 and D-006 |
| `.gitignore`, `CLAUDE.md`, `agentharness/*`, `agent-harness/*`, `agents/*`, `config/project.yml` | First commit on branch (foundation) — content authored prior to this session |

## Decisions made

- **D-005** — Schema creation will go through `database/migrations/001_create_pathbuilder_schema.sql` rather than ad-hoc DDL in the postgres MCP. Reason: matches the harness convention; the dry-run / approval / flip-ROLLBACK-to-COMMIT cycle is the visible audit-trail moment.
- **D-006** — Migration 001 intentionally does **not** include `students`, `enrollments`, or any PII-bearing table. Reason: `INFRASTRUCTURE.md` calls out "Do not do yet: Store student PII"; co-op population includes minors; the PII handling story should be decided before any PII table lands.

## Blockers

- **DigitalOcean API is locked out (HTTP 401, all endpoints).** Root cause: `OP_SERVICE_ACCOUNT_TOKEN` is not set on this workstation, so the MCP server cannot pick up a refreshed `do-token` from the `agent-credentials` vault. Remediation steps are in `agentharness/1PASSWORD_STARTUP_PROTOCOL.md` lines 15–32 (one-time SA-token bootstrap), then refresh `do-token` in 1Password, then restart Claude Code.
- **Spaces (object plane) is locked out** for a separate reason: requires `SPACES_KEY` / `SPACES_SECRET` / `SPACES_REGION` / `SPACES_BUCKET` / `SPACES_ENDPOINT` independent of the DO API token. None are set.

## Risks

- The branch has **not been pushed and no PR has been opened** — see Decisions Needed below for why I stopped before pushing.
- The migration draft assumes a `BIGSERIAL` PK pattern and `TIMESTAMPTZ` timestamps. If PathBuilder needs UUID PKs or different timestamp semantics, the file should be edited before the dry run, not after.
- The `pathbuilder_app` role's password in the migration is the placeholder string `'CHANGE_ME_BEFORE_COMMIT'`. The header comment instructs setting the real password out of band before flipping `ROLLBACK` to `COMMIT`. If the file is run as-is *after* the flip, the role will exist with the placeholder password.

## Infrastructure / access notes

- **DO token status:** BROKEN (HTTP 401, all endpoints). Root cause: 1Password SA-token bootstrap not done.
- **DB status:** postgres MCP authenticated as `doadmin`; `pathbuilder` schema absent; no DDL executed; migration 001 committed as DRAFT.
- **Spaces status:** UNKNOWN. All five Spaces env vars NOT SET. Bucket name/region/endpoint not yet confirmed.
- **Domain/DNS:** Not enumerated (API 401).
- **App Platform:** Not enumerated (API 401). `kentuckypathfinderapi` and `remote-rob` remain READ ONLY per `INFRASTRUCTURE.md`.

## Monday.com status

No Monday item was claimed or updated this session. Reason: posting authorization for this session is implicit at best ("prompt the GPT planner") and the SPRINT_START protocol says "post to `#remote-rob-is-at-work` if Slack posting is enabled." I drafted the posts (below) but did not send them, and did not touch Monday.

If Justin wants this surfaced on the Monday board, an item like the following would be appropriate:

```
Title: DO capability re-audit (v2) under new harness
Group: infrastructure
Area: Infrastructure
Status: Needs Review
Approval Required: ✓
Notes: see docs/digitalocean-pathbuilder-capability-audit.md and
       docs/handoff-2026-05-22-do-capability-reaudit.md
```

## Next recommended task — for the GPT planner

GPT planner: pick this up by reading, in order:

1. `docs/digitalocean-pathbuilder-capability-audit.md` — the full audit.
2. `agentharness/INFRASTRUCTURE.md` — the canonical infrastructure state.
3. `database/migrations/001_create_pathbuilder_schema.sql` — the proposed schema.
4. `agentharness/DATABASE_SAFETY_PROTOCOL.md` — the dry-run gate that governs the migration.

Then, **pick exactly one** of the two branches:

**Branch A (recommended — unblock infrastructure):** plan and execute the 1Password SA-token bootstrap on Justin's workstation per `1PASSWORD_STARTUP_PROTOCOL.md` lines 15–32, then refresh the `do-token` field in the `agent-credentials` vault, then restart Claude Code, then re-run the audit's Phases 2–6 (apps, Spaces, DNS, certs, firewalls, VPCs, registry) against the now-working API. This is the highest-leverage next step because it unblocks everything downstream.

**Branch B (parallel — unblock data):** review the `database/migrations/001_create_pathbuilder_schema.sql` schema design; either approve it as-is for a dry run or propose specific changes (PK strategy, timestamp semantics, additional columns, additional tables) **before** the dry run runs. If approved, request Justin's "approved for dry run" reply, run the file as-is (it ends in `ROLLBACK;` so it's a no-op), share the output, get Justin's "approved for commit" reply, flip `ROLLBACK` to `COMMIT`, and re-run. This can happen in parallel with Branch A; it does not depend on the DO API working.

If both branches feel premature, the safest standalone action is: open the PR for what's already on this branch so the work is reviewable in GitHub even before any token refresh or schema creation.

## Drafted Slack posts — NOT SENT

Posting is gated on Justin's explicit "post it" per `SLACK_POSTING_PROTOCOL.md` lines 37–40. The drafts below are the intended messages; nothing has been sent.

### Draft 1 — `#hand-off` (`C0ATQ81QA75`)

```
2026-05-22 5:00 PM EDT — PathBuilder Handoff: DO Capability Re-Audit v2

What changed: DO capability audit was re-run under the new harness; v1 deleted and replaced by v2 at docs/digitalocean-pathbuilder-capability-audit.md. Migration 001 drafted (dry-run-guarded) for the pathbuilder schema. Audit is harness-aligned with line-number citations.

Files: 5 new/changed (audit, handoff doc, migration, CHANGELOG row, DECISION_LOG D-005/D-006). Plus a foundation commit bringing the agent harness into version control on this branch.

Branch: claude-code/do-capability-reaudit-v2
PR: not opened yet — awaiting your go.

Blockers:
 - DigitalOcean REST API still returns HTTP 401 on every endpoint.
 - Root cause identified: OP_SERVICE_ACCOUNT_TOKEN is not set on this workstation, so the MCP server has no path to a refreshed do-token from the agent-credentials vault.
 - Remediation: follow 1PASSWORD_STARTUP_PROTOCOL.md lines 15–32, then refresh do-token, then restart Claude Code.

Next: GPT planner picks up. See docs/handoff-2026-05-22-do-capability-reaudit.md for the two branches (token unblock vs schema review).
```

### Draft 2 — `#actual-planning` (`C0B5FT7SUM6`)

```
2026-05-22 5:00 PM EDT — For the GPT planner: DO Re-Audit v2 Ready

The DO capability audit has been re-run under the new harness. Two things are ready for you:

1) docs/digitalocean-pathbuilder-capability-audit.md — full audit, harness-aligned.
2) database/migrations/001_create_pathbuilder_schema.sql — dry-run-guarded schema for the pathbuilder namespace (courses, units, lessons, lesson_resources, weekly_plans, labs, assignments). Ends in ROLLBACK so executing it as-is is a no-op.

Two ways to move us forward — pick one:

 A) Unblock infrastructure — plan the 1Password SA-token bootstrap so the DO MCP can pick up a fresh token, then re-run the API-blocked phases (apps, Spaces, DNS).
 B) Unblock data — review migration 001's schema, propose changes if needed, then run the dry run and report output to Justin for the COMMIT approval.

Full context: docs/handoff-2026-05-22-do-capability-reaudit.md
```

### Draft 3 — `#debugging` (`C0ATS3QKPQE`)

```
2026-05-22 5:00 PM EDT — Blocker: DO MCP Token Resolves to 401

What is blocked: every DigitalOcean REST API call (account, apps, databases, droplets, domains, certs, firewalls, vpcs, balance, keys) — 10 calls, 10 fresh 401s today.

Why: the DO MCP server is sending something that DO does not accept as a valid PAT. Length-only audit confirms OP_SERVICE_ACCOUNT_TOKEN is not set on this workstation, so op run cannot resolve agent-credentials vault values for the MCP wrapper.

What you need to do: follow agentharness/1PASSWORD_STARTUP_PROTOCOL.md lines 15–32 (set OP_SERVICE_ACCOUNT_TOKEN as a Windows User env var, restart Claude Code), then refresh the do-token field on the claude-code item in the agent-credentials vault if it's stale. Then I can re-run the API phases.
```

## Verification checklist (run before merging the PR)

- [ ] `Test-Path docs/digitalocean-pathbuilder-capability-audit.md` returns true and the first 30 lines name "v2" and cite the harness.
- [ ] `database/migrations/001_create_pathbuilder_schema.sql` exists and ends in `ROLLBACK;` (not `COMMIT;`).
- [ ] `git diff main...HEAD` shows no token, password, DSN, real Spaces key, or `.env` file. All `agents/*.env` contain only `op://…` references.
- [ ] `mcp__postgres__list_objects schema_name=pathbuilder` returns `[]` (empty schema or schema absent). No DDL was executed.
- [ ] `INFRASTRUCTURE.md` is unchanged unless the DO token was actually fixed this session (it was not).
- [ ] All `GITHUB_WORKFLOW.md` hard no-merge conditions (lines 94–106) are clear.
