# Operating Protocol — All Workers and Agents
**Repo:** Project PathBuilder
**Canonical source:** Derived from jnh-dev-kit OPERATING_PROTOCOL v1

This document defines how any worker — Claude CLI, Claude Code, Codex, ChatGPT,
Remote Rob, or deployment script — must operate in this repository.

---

## 1. Before Starting Any Session

1. Read `CLAUDE.md` and `config/project.yml`. Know the repo and project identity.
2. Run `git status`. Confirm branch, confirm working tree is clean.
3. Inspect bearing files relevant to your task before changing anything.
4. Check the monday.com board (ID: `18414133952`) for current task state.
5. Check `#changelog` (last 7 days) and `#hand-off` (most recent) in Slack.
6. Post a session-start note to `#remote-rob-is-at-work` if Slack posting is enabled.

---

## 2. Reading Before Editing

1. Always read a file before editing — never overwrite blind.
2. Report what you found before modifying. Describe unexpected content first.
3. Prefer editing existing files over creating new ones.
4. Never delete files without explicit instruction from Justin.

---

## 3. Logging and Documentation

1. Log significant changes in `CHANGELOG.md`. Format: `YYYY-MM-DD | Change | Files affected`
2. Record major decisions in `DECISION_LOG.md`. Format: D-number, decision, rationale, alternatives.
3. Do not create temp planning files. If a doc is worth keeping, it belongs in `docs/`.

---

## 4. Git Workflow

**PathBuilder uses a relaxed merge policy.** Agents open PRs, squash-merge them,
comment, and edit with Justin's awareness — no per-PR approval needed unless a
hard no-merge condition applies. See `agentharness/GITHUB_WORKFLOW.md`.

1. Run `git status` before starting and after finishing.
2. Doc-only small changes may commit to `main` only when Justin explicitly authorizes.
3. All other changes use a branch. Branch format: `[agent-id]/[task-description]`
4. Commit format: `[agent-id]: description`
5. Open a PR with the standard PR body. Post URL to Monday and Slack.
6. Verify all hard no-merge conditions are clear.
7. Squash-merge. Delete branch. Post merge commit SHA to Monday item.
8. Never force-push under any circumstances.

---

## 5. Secrets and Security

1. Never write API keys, passwords, tokens, or credentials into any tracked file.
2. Never commit `.env` files. Only `.env.example` and `agents/*.env` (op:// refs) belong in the repo.
3. Never print secrets in reports, logs, Slack, or PR bodies.
4. All credentials come from 1Password vault `agent-credentials` via `op run --env-file`.
5. See `agentharness/ENVIRONMENT_PROTOCOL.md` for the full pattern.

---

## 6. Slack Posting

1. Post to Slack only when the sprint prompt explicitly says to post.
2. Use correct channel per message type. See `agentharness/SLACK_POSTING_PROTOCOL.md`.
3. All Slack posts begin with: `YYYY-MM-DD H:MM AM/PM EDT — [Short title]`
4. Never post secrets, env file contents, or private data to Slack.

---

## 7. Database Safety — Hard Gate

1. All DB work must be dry-run first.
2. Never write, create, alter, drop, or delete without Justin's explicit approval.
3. Before any DB write, stop and report: host, schema name, proposed SQL, rollback SQL.
4. Say: "Ready for DB test run. Approval required before creating schema or writing rows."
5. Full protocol: `agentharness/DATABASE_SAFETY_PROTOCOL.md`

---

## 8. Infrastructure Boundary

1. Do not create paid DigitalOcean resources without Justin's approval.
2. Do not modify `kentuckypathfinderapi` or `remote-rob` app settings.
3. The DO REST/API MCP token is currently broken (HTTP 401) — do not assume it works.
4. Postgres access via postgres MCP is confirmed working as doadmin.
5. Full context: `agentharness/INFRASTRUCTURE.md`

---

## 9. Environment Variables

1. Real `.env` files stay out of git — always.
2. Only `.env.example` and `agents/*.env` (op:// refs) are committed.
3. Validate env var presence by checking length, never by printing value.
4. See `agentharness/ENVIRONMENT_PROTOCOL.md`.

---

## The Four Non-Negotiables

1. **Never overwrite without reading first.**
2. **Never mark done without verifying done criteria.**
3. **Never commit secrets.**
4. **Never write to the database without Justin's approval.**
