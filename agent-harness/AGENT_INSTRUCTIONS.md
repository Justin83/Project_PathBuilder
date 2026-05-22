# Agent Instructions — monday.com Board Workflow
**Board ID:** `18414133952`
**Board Name:** Project PathBuilder Charter — Homeschool Biology Co-op
**Board URL:** https://arsg-squad.monday.com/boards/18414133952

---

## Board Structure

The board currently has one item ("Doc Comments"). Groups and columns need to be
built out before the board becomes a full tracking tool.

**Proposed group structure** (get Justin's approval before creating groups):

| Group Key | Purpose |
|-----------|---------|
| `intake_ideas` | New ideas, backlog items, unassigned tasks |
| `infrastructure` | DO token, DB schema, Spaces, app routes |
| `curriculum_planning` | 15-week plan, activity outlines, pacing |
| `documents_handouts` | Student handouts, parent guides, checklists |
| `labs_equipment` | Lab plans, supply lists, campus days |
| `website_app` | Landing page, downloads page, routing |
| `review_approval` | Items awaiting Justin's review or approval |
| `done` | Completed items |

**Proposed column structure** (get Justin's approval before creating columns):

| Column | Type | Purpose |
|--------|------|---------|
| Task | name | Item title |
| Status | status | Backlog / Ready / In Progress / Blocked / Needs Review / Done |
| Priority | status | Critical / High / Medium / Low |
| Area | dropdown | Infrastructure / Curriculum / Documents / Labs / Website |
| Owner | text | Agent or human responsible |
| Due Date | date | Target completion |
| Repo Path | text | File or folder in repo |
| Last Agent | text | Which agent last touched this |
| Approval Required | checkbox | Needs Justin's sign-off before proceeding |
| Notes | long_text | Free-form context |

---

## When You START a Session

1. Check the board for your assigned item or confirm the sprint goal with Justin.
2. Set **Status → In Progress** on the item you are claiming.
3. Add your agent ID to the **Last Agent** column.

---

## When You FINISH a Session

1. Update your item: set **Status → Needs Review** (if Justin needs to review) or **Done** (if confirmed complete).
2. Post PR URL and commit SHA in the item's update/comment section.
3. Update **Last Agent** column with your agent ID.

---

## If You Are Blocked

1. Set **Status → Blocked** on the affected item.
2. Add a note explaining what is blocked and why.
3. Post to `#debugging` (`C0ATS3QKPQE`).

---

## Always Confirm with Justin Before

| Action | Why |
|--------|-----|
| Creating new groups | Changes board structure |
| Creating new columns | May affect all existing items |
| Deleting items or groups | Loses history |
| Marking infrastructure items Done | May imply paid resources were created |
| Any item requiring Approval Required = checked | Justin must explicitly sign off |

---

## Before the Board Has Full Structure

Until groups and columns are built out, use the board for high-level status only.
Add items with clear names and leave column values minimal.
Do not create 40+ items before the board structure is confirmed.
