# Slack Posting Protocol — Project PathBuilder
**Channel IDs:** See `config/project.yml` → slack.channels

---

## Timestamp Rule

Every Slack post must begin with:
```
YYYY-MM-DD H:MM AM/PM EDT — [Short title]
```
Never post without the timestamp. Never use UTC.

---

## Formatting Rules
- No `---` horizontal rules. Use bold headers with blank lines instead.
- Top-level message is always the summary.
- Use threads for detail — investigation notes, line-by-line breakdowns, vault activity.

---

## Channel Routing

| Event | Channel | ID |
|-------|---------|-----|
| Sprint start | `#remote-rob-is-at-work` | C0ATL7VFPT5 |
| Completed milestone / shipped | `#changelog` | C0ATANVNBBR |
| Session handoff | `#hand-off` | C0ATQ81QA75 |
| Blocker or error | `#debugging` | C0ATS3QKPQE |
| New task surfaced | `#todo` | C0ATSHU0NUS |
| Confirmed decision | `#decisions` (if channel exists) | — |
| Curriculum planning coordination | `#actual-planning` | C0B5FT7SUM6 |

---

## When to Post
Post only when the sprint prompt explicitly instructs posting.
Default: workers draft the Slack message and describe where to post it.
Justin or the prompt gives authorization to actually send.

---

## What Must Never Appear in a Slack Post
- API keys, tokens, passwords
- Database connection strings or passwords
- Full `.env` file contents
- DigitalOcean App Platform env var values
- 1Password vault paths with credentials embedded
- Student names or personal data

---

## Post Templates

**Sprint Start** (`#remote-rob-is-at-work`)
```
YYYY-MM-DD H:MM AM/PM EDT — PathBuilder Sprint Started

Goal: [one sentence]
Branch: [agent-id]/[task-description]

Planned:
- [deliverable 1]
- [deliverable 2]

Gates: [active safety gates]
```

**Sprint Complete** (`#changelog`)
```
YYYY-MM-DD H:MM AM/PM EDT — PathBuilder Sprint Completed

Files changed: [N]
Key outcomes:
- [outcome 1]
- [outcome 2]

Commit: [short hash]
PR: [URL or "not created"]
```

**Handoff** (`#hand-off`)
```
YYYY-MM-DD H:MM AM/PM EDT — PathBuilder Handoff

What changed: [2 sentences]
Files: [N]
PR: [URL]
Blockers: [or "none"]
Next: [next sprint]
```

**Blocker** (`#debugging`)
```
YYYY-MM-DD H:MM AM/PM EDT — Blocker: [Short description]

What is blocked: [description]
Why: [reason]
What Justin needs to do: [action]
```
