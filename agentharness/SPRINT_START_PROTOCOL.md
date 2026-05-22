# Sprint Start Protocol — Project PathBuilder

Run this checklist at the top of every sprint. Do not skip steps.

---

## Step 1 — Confirm Repo and Branch

```bash
git status
git branch --show-current
git pull --ff-only origin main
```

State: machine, repo path, current branch, working tree status.

---

## Step 2 — Read Core Harness Docs

Read these before doing any work:
- `CLAUDE.md`
- `config/project.yml`
- `agentharness/OPERATING_PROTOCOL.md`
- `agentharness/INFRASTRUCTURE.md` (if any DO/DB/Spaces work is planned)

---

## Step 3 — Check Monday.com Board

Open board `18414133952` — Project PathBuilder Charter — Homeschool Biology Co-op.
Identify your assigned item(s) or confirm what Justin wants done this sprint.
Set **Build Status → Working on it** on the item you are claiming.

---

## Step 4 — Check Slack

Read in this order:
1. `#changelog` (`C0ATANVNBBR`) — last 7 days
2. `#hand-off` (`C0ATQ81QA75`) — most recent post
3. `#debugging` (`C0ATS3QKPQE`) — any open blockers

---

## Step 5 — Check Environment

Confirm your credentials load correctly:
```bash
op run --env-file ./agents/[your-agent-name].env -- [validation command]
```
Validate presence by length — do not print values.

If DO API token is needed: note that last audit returned HTTP 401. Confirm token works before assuming DO access.

---

## Step 6 — Identify Safety Risks

Before writing any code, list:
- Will this sprint touch the database? → DB approval gate applies
- Will this sprint touch DO infrastructure? → Confirm token works first; get approval for writes
- Will this sprint touch Spaces? → Confirm S3 credentials first; get approval for uploads
- Will this sprint touch KYPF production apps? → Stop and ask Justin

---

## Step 7 — Post Sprint Start to Slack (if posting is enabled)

Post to `#remote-rob-is-at-work` (`C0ATL7VFPT5`):

```
YYYY-MM-DD H:MM AM/PM EDT — PathBuilder Sprint Started

Goal: [one sentence]
Repo: Project_PathBuilder | Branch: [agent-id]/[task-description]

Planned deliverables:
- [deliverable 1]
- [deliverable 2]

Safety gates: [list active gates]
```

---

## Step 8 — State the First Action

Before writing any code or modifying any file, state:
> "First action: [exactly what I will do first]. Proceeding."

---

## Step 9 — Proceed

Work in small increments. Commit as you go. Report blockers immediately.
