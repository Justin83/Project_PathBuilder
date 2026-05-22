# CLAUDE.md — Project PathBuilder
> Auto-loaded by Claude CLI. Last updated: 2026-05-22

## This Repo
Project PathBuilder is a biology-focused homeschool/co-op curriculum and platform project
connected to ARSG. The first course is a 15-week biology co-op for mostly 9th graders.
Local path: `C:\xampp\htdocs\Project_PathBuilder`

## Start Here
Read these before doing anything:
- `agentharness/OPERATING_PROTOCOL.md`   — master rules for all agents
- `agentharness/INFRASTRUCTURE.md`       — DO/DB/Spaces reuse plan and known resources
- `agent-harness/MCP_TOOLS.md`           — available tools, auth, autonomous vs confirm
- `agent-harness/AGENT_INSTRUCTIONS.md`  — monday.com board workflow
- `agent-harness/AGENT_INSTRUCTIONS_MAP.md` — full inventory of all harness files

## Git Policy — Relaxed (PathBuilder only)
Agents open PRs, squash-merge, comment, and edit with Justin's awareness.
No per-PR approval needed unless a hard no-merge condition applies.
See `agentharness/GITHUB_WORKFLOW.md` for the full rules and hard stops.

- Branch → PR → squash-merge → delete branch. Agents drive the full cycle.
- Branch format: `[agent-id]/[task-description]`
- Commit format: `[agent-id]: description`
- Post PR URL + merge SHA to Monday item and Slack on every merge.
- Hard stops still apply: no secrets, no unapproved DB writes, no KYPF app changes.

## Hard Rules (always, regardless of relaxed policy)
- Never push directly to main.
- Credentials come from 1Password vault `agent-credentials` via op run — never hardcode.
  Load all credentials with:
    op run --env-file ./agents/[your-agent-name].env -- [command]
- Never overwrite a file without reading it first.
- Never commit `.env` files or secrets. See `agentharness/ENVIRONMENT_PROTOCOL.md`.
- Never write to the database without Justin's approval. See `agentharness/DATABASE_SAFETY_PROTOCOL.md`.
- Never modify KYPF production app settings (kentuckypathfinderapi, remote-rob).
  See `agentharness/INFRASTRUCTURE.md`.

## monday.com
Board ID: `18414133952` — Project PathBuilder Charter — Homeschool Biology Co-op
Board URL: https://arsg-squad.monday.com/boards/18414133952
Set **Build Status → Working on it** when you claim an item.
Post PR URL and commit SHA to the item update when done.
See `agent-harness/AGENT_INSTRUCTIONS.md` for the full column workflow.

## Slack
Session end → post to `#hand-off` (`C0ATQ81QA75`)
Shipped → post to `#changelog` (`C0ATANVNBBR`)
Blockers → post to `#debugging` (`C0ATS3QKPQE`)
No `---` horizontal rules in messages. Bold headers with blank lines instead.
Full channel routing and templates: `agentharness/SLACK_POSTING_PROTOCOL.md`

## Credentials — 1Password
All tokens live in 1Password vault `agent-credentials`.
Load per-agent credentials with:

    op run --env-file ./agents/[your-agent-name].env -- [command]
    Example: op run --env-file ./agents/claude-code.env -- gh auth status

Known agents: `claude-cli`, `claude-code`, `remote-rob`, `codex`, `chatgpt`
New agent? Ask Justin to create the item in `agent-credentials` vault and add
an env file in `agents/` before doing any work.

## Key Environment Variables (PathBuilder-specific)
    PATHBUILDER_DB_SCHEMA=pathbuilder
    PATHBUILDER_STORAGE_PREFIX=pathbuilder/

These are PathBuilder's logical isolation coordinates inside shared infrastructure.
Do not use `pathbuilder_*` table names in the public schema. See INFRASTRUCTURE.md.

## Infrastructure Boundary
PathBuilder reuses existing DigitalOcean infrastructure. Do not create paid resources
without Justin's approval. Do not touch kentuckypathfinderapi or remote-rob app settings.
The DigitalOcean REST/API MCP token may need refreshing — last audit returned HTTP 401.
Managed Postgres access via postgres MCP is confirmed working as doadmin.
