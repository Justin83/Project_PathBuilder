# Sprint Handoff Protocol — Project PathBuilder

Use this at the end of every session to leave a clean trail.

---

## Handoff Checklist

1. `git status` — confirm working tree is clean (or commit what's in progress)
2. Report what changed, what was verified, what is NOT done
3. Update monday.com item: set status, post PR URL and commit SHA
4. Post to `#hand-off` (`C0ATQ81QA75`) in Slack
5. Post to `#changelog` (`C0ATANVNBBR`) if a milestone was completed
6. Post to `#debugging` (`C0ATS3QKPQE`) if blockers remain
7. Post to `#todo` (`C0ATSHU0NUS`) for any tasks surfaced this session

---

## Handoff Template (post to #hand-off)

```
YYYY-MM-DD H:MM AM/PM EDT — PathBuilder Sprint Handoff

What changed: [2 sentences]
Files touched: [count and list]
Branch: [name]
PR: [URL or "not created"]
Commit: [short hash]

Blockers: [or "none"]
Decisions needed from Justin: [list or "none"]
Secrets / access notes: [any token issues, or "none"]
Monday.com: [item ID updated? yes/no]

Next recommended task: [one sentence]
```

---

## Full Handoff Document (for longer sessions)

Create `docs/handoff-YYYY-MM-DD-[sprint-name].md` if the session warrants it.

Include:

```markdown
# Handoff — [Sprint Name]
Date: YYYY-MM-DD
Agent: [agent-id]
Branch: [name]

## Summary
[2-3 sentences]

## Completed
- [item 1]
- [item 2]

## Changed Files
| File | Change |
|------|--------|
| ... | ... |

## Decisions Made
- D-[N]: [decision] — [rationale]

## Blockers
- [or "none"]

## Risks
- [or "none"]

## Infrastructure / Access Notes
- DO token status: [working / broken]
- DB status: [schema created / pending approval / not touched]
- Spaces status: [confirmed / unknown / not touched]

## Monday.com Status
- Item [ID] set to: [status]

## Next Recommended Task
[One sentence. What should the next worker pick up?]
```

---

## Handoff Rules

1. Do not claim a task is done unless you have verified the output.
2. If you ran out of time mid-task, set monday.com status to **In Progress** not **Done**.
3. If a blocker surfaced, post to `#debugging` and note it in the handoff.
4. If a decision was made this session, record it in `DECISION_LOG.md` and post to `#decisions` if it is significant.
5. The handoff is for the next worker — write it for someone who has zero context from this session.
