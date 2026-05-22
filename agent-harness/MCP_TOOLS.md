# MCP Tools — Project PathBuilder

---

## Available MCP Servers

| Server | Purpose | Auth |
|--------|---------|------|
| `monday.com` | Board tracking, item management | `MONDAY_TOKEN` via op run |
| `Slack` | Channel reads, posts, search | `SLACK_TOKEN` via op run |
| `postgres` | Read Postgres schemas and data | Connection string via op run |
| `digitalocean` | DO API (apps, databases, Spaces) | `DO_TOKEN` via op run — **currently broken (401)** |

---

## Available CLI Tools (confirmed on this workstation)

| Tool | Status | Use |
|------|--------|-----|
| `git` | ✅ Installed | Version control |
| `curl` | ✅ Installed | HTTP requests, DO API testing |
| `op` | ✅ Assumed (per project pattern) | Load credentials from 1Password |
| `gh` | ✅ Assumed (per project pattern) | GitHub CLI — PRs, issues |
| `doctl` | ❌ Not installed (as of 2026-05-22) | DigitalOcean CLI |
| `jq` | ❌ Not installed (as of 2026-05-22) | JSON parsing |
| `aws` | ❌ Not installed (as of 2026-05-22) | S3-compatible Spaces access |

**To install doctl:** `winget install --id DigitalOcean.doctl -e`
**To install jq:** `winget install --id stedolan.jq -e`
Get Justin's approval before installing system-wide tools.

---

## Autonomous vs Confirm Boundaries

### monday.com
| Operation | Boundary |
|-----------|---------|
| Read items, boards, groups | ✅ Autonomous |
| Create items in existing groups | ✅ Autonomous (for session tracking) |
| Update item status and notes | ✅ Autonomous |
| Create new groups or columns | ⚠️ Confirm with Justin first |
| Delete items or groups | 🚫 Never without explicit instruction |

### Slack
| Operation | Boundary |
|-----------|---------|
| Read channels, threads | ✅ Autonomous |
| Search messages | ✅ Autonomous |
| Post messages (when sprint prompt authorizes) | ✅ Autonomous |
| Post messages (when sprint prompt does NOT authorize) | ⚠️ Draft only — describe and ask |
| DM Justin | ⚠️ Confirm before sending |

### postgres MCP
| Operation | Boundary |
|-----------|---------|
| SELECT, SHOW, \dt, \dn, schema inspection | ✅ Autonomous |
| CREATE SCHEMA, CREATE TABLE, INSERT, UPDATE, DELETE | 🚫 DB approval gate — full stop |

### digitalocean MCP
| Operation | Boundary |
|-----------|---------|
| Read-only inventory (apps list, databases list, etc.) | ✅ Autonomous (once token is working) |
| Create apps, databases, droplets | 🚫 Never without Justin's approval |
| Modify app env vars or settings | 🚫 Never without Justin's approval |
| Rotate or delete tokens | 🚫 Never |
| Touch KYPF production apps | 🚫 Never |

---

## Credential Loading

All credentials via 1Password:
```bash
op run --env-file ./agents/[agent-name].env -- [command]
```

Validate presence, never print values:
```powershell
if ($env:MONDAY_TOKEN) { "MONDAY_TOKEN SET" } else { "MONDAY_TOKEN NOT SET" }
```
