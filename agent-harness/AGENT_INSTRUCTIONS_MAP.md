# Agent Instructions Map — Project PathBuilder
**Purpose:** Inventory of every agent instruction file in this repo.

---

## Summary

- **Total harness files:** 13 (initial scaffold)
- **`agentharness/`** — master rules and protocols (7 files)
- **`agent-harness/`** — MCP tools and Monday workflow (3 files)
- **Root** — `CLAUDE.md` (1 file)
- **`config/`** — `project.yml` (1 file)
- **`agents/`** — per-agent env files (5 files + README)

---

## File Index

| Location | File | Purpose |
|----------|------|---------|
| root | `CLAUDE.md` | Auto-loaded by Claude CLI — project identity, hard rules, board ID, channel IDs |
| `config/` | `project.yml` | All IDs — Monday board, Slack channels, infra context, agents, toolstack |
| `agentharness/` | `1PASSWORD_STARTUP_PROTOCOL.md` | Silent op run setup — SA token bootstrap, MCP wiring, no-prompt pattern |
| `agentharness/` | `OPERATING_PROTOCOL.md` | **Master rules** — governs all workers (9 sections + 4 non-negotiables) |
| `agentharness/` | `INFRASTRUCTURE.md` | DO/DB/Spaces reuse plan, known resources, token status, next steps |
| `agentharness/` | `ENVIRONMENT_PROTOCOL.md` | `.env` strategy, op run pattern, PathBuilder-specific variables |
| `agentharness/` | `DATABASE_SAFETY_PROTOCOL.md` | Hard gate — DB writes require Justin approval, dry-run rule |
| `agentharness/` | `GITHUB_WORKFLOW.md` | Branch naming, commit format, PR template, no-merge conditions |
| `agentharness/` | `SPRINT_START_PROTOCOL.md` | 9-step checklist — run at the top of every sprint |
| `agentharness/` | `SPRINT_HANDOFF_PROTOCOL.md` | End-of-session handoff format + Slack post templates |
| `agentharness/` | `SLACK_POSTING_PROTOCOL.md` | Channel routing, timestamp rule, post templates |
| `agent-harness/` | `MCP_TOOLS.md` | MCP servers, CLI tools, autonomous vs confirm boundaries |
| `agent-harness/` | `AGENT_INSTRUCTIONS.md` | Monday board workflow — board ID, proposed structure, item lifecycle |
| `agent-harness/` | `AGENT_INSTRUCTIONS_MAP.md` | This file |
| `agents/` | `README.md` | How to load per-agent credentials |
| `agents/` | `claude-cli.env` | Claude CLI op:// references |
| `agents/` | `claude-code.env` | Claude Code op:// references |
| `agents/` | `remote-rob.env` | Remote Rob op:// references |
| `agents/` | `codex.env` | Codex op:// references |
| `agents/` | `chatgpt.env` | ChatGPT op:// references |

---

## File Summaries

**`CLAUDE.md`** — Auto-loaded by Claude CLI. Board ID, repo path, hard rules, credential loading pattern, Slack channel IDs, infra boundary note.

**`config/project.yml`** — Source of truth for all project IDs. Monday board ID, Slack channel IDs with names and purposes, DO infrastructure state, agent list, toolstack.

**`agentharness/OPERATING_PROTOCOL.md`** — Master rules. 9 sections: session start, reading-before-editing, logging, git workflow, secrets, Slack, DB safety, infrastructure boundary, environment variables. Four non-negotiables at bottom.

**`agentharness/INFRASTRUCTURE.md`** — The most PathBuilder-specific file. DO app IDs, token status, Postgres schema state, Spaces access requirements, related repos, ordered next steps.

**`agentharness/ENVIRONMENT_PROTOCOL.md`** — File locations, op run pattern, PathBuilder-specific variable table with op:// references, validation without printing, 1Password SA token location.

**`agentharness/DATABASE_SAFETY_PROTOCOL.md`** — Hard gate. Read-only always allowed. Writes require stop-and-report + Justin approval. Dry-run rule. Migration file convention.

**`agentharness/GITHUB_WORKFLOW.md`** — Branch format `[agent-id]/[task]`, commit format `[agent-id]: description`, full PR body template, 7 hard no-merge conditions.

**`agentharness/SPRINT_START_PROTOCOL.md`** — 9-step checklist: confirm repo/branch, read core docs, check Monday, check Slack, check environment, identify safety risks, post sprint start, state first action, proceed.

**`agentharness/SPRINT_HANDOFF_PROTOCOL.md`** — End-of-session checklist, short Slack template, full handoff document template, 5 handoff rules.

**`agentharness/SLACK_POSTING_PROTOCOL.md`** — Timestamp rule, channel routing table with IDs, when to post, what never to post, 4 post templates.

**`agent-harness/MCP_TOOLS.md`** — 4 MCP servers with auth and status, CLI tool inventory with install status, autonomous vs confirm boundary tables for each.

**`agent-harness/AGENT_INSTRUCTIONS.md`** — Monday board ID and URL, proposed group/column structure, item lifecycle (start/finish/blocked), confirm-with-Justin list, guidance for pre-structure period.

---

## Maintenance

When adding a new protocol or instruction file:
1. Place it in `agentharness/` (master rules) or `agent-harness/` (tools/Monday).
2. Add a row to the file index above.
3. Add a summary to File Summaries.
4. Reference it from `CLAUDE.md` or `OPERATING_PROTOCOL.md` if every session should read it.
