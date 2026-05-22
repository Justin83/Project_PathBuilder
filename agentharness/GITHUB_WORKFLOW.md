# GitHub Workflow — Project PathBuilder
> **Relaxed merge policy:** Agents may open PRs, squash-merge, comment, and edit
> with Justin's awareness — explicit per-PR approval is not required unless a
> hard no-merge condition applies. See Hard No-Merge Conditions below.

---

## Branch Naming

    [agent-id]/[task-description]

Examples:
    claude-code/create-pathbuilder-schema
    claude-cli/week-01-student-handout
    remote-rob/db-schema-inspection
    codex/landing-page-structure

---

## Commit Format

    [agent-id]: description

Examples:
    claude-code: add 001_create_pathbuilder_schema.sql draft
    claude-cli: update INFRASTRUCTURE.md with confirmed Spaces bucket
    remote-rob: log DO capability re-audit results

---

## Workflow

1. `git checkout main && git pull --ff-only origin main`
2. `git checkout -b [agent-id]/[task-description]`
3. Work. Commit incrementally with clear messages.
4. `git status` — confirm working tree is clean before PR.
5. Open PR with full PR body (see template below).
6. Post PR URL to monday.com item update and to `#changelog` or `#hand-off` as appropriate.
7. **Squash-merge the PR** once all safety checks pass — no per-PR approval needed from Justin.
8. Delete the branch after merge.
9. Post the merge commit SHA to the monday.com item update.

**Justin stays informed, not in the way.** Agents notify via Slack and Monday —
Justin can inspect any PR before merge, but the default is agent-driven.

---

## PR Body Template

```
## Summary
[One sentence: what this PR does]

## Changes
- [file or system] — [what changed]
- ...

## Why
[Context — which task or monday.com item this closes]

## Monday.com
Item ID: [ID]
Board: 18414133952

## Safety Checks
- [ ] No secrets committed
- [ ] No .env files committed
- [ ] No DB writes performed without approval
- [ ] No KYPF production app settings modified
- [ ] Read all modified files before editing
- [ ] All hard no-merge conditions verified clear

## Merge Plan
Squash-merge. Branch deleted after merge.
Commit message: [agent-id]: [summary]
```

---

## PR Comments and Edits

Agents may:
- Add review comments to their own PRs before merging
- Edit the PR description to reflect late changes
- Request changes on PRs opened by other agents
- Leave inline comments on any file in the diff

Agents must not:
- Approve their own PR using the GitHub review approval mechanism (use squash-merge directly)
- Edit another agent's already-merged commits

---

## Hard No-Merge Conditions

These are absolute stops regardless of the relaxed policy. Do not merge if any apply:

1. A `.env` file or real secret is in the diff
2. DB migration SQL is included and was not approved as a dry run by Justin
3. DigitalOcean App Platform env vars were changed without Justin's approval
4. Tests are failing
5. The PR touches `kentuckypathfinderapi` or `remote-rob` settings
6. Branch protection rules would be bypassed
7. A force-push was used on the branch

If a hard condition applies: stop, post to `#debugging`, and wait for Justin.
