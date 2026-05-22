# Environment Protocol — Project PathBuilder
**Pattern:** 1Password `op run --env-file` — same as all KYPF/jnh-dev-kit projects.

---

## Principles

1. Real `.env` files never go in git.
2. Only `.env.example` and `agents/*.env` (op:// references) are committed.
3. Secrets come from 1Password vault `agent-credentials`. Never paste a real value anywhere.
4. Validate presence by testing length — never by echoing the value.

---

## Standard Loading Pattern

```bash
op run --env-file ./agents/[your-agent-name].env -- [command]
```

Examples:
```bash
op run --env-file ./agents/claude-code.env -- gh auth status
op run --env-file ./agents/remote-rob.env -- python scripts/some-script.py
```

---

## File Locations

| File | Committed | Purpose |
|------|-----------|---------|
| `config/.env.example` | Yes | Full variable template with placeholder values |
| `agents/[agent].env` | Yes | op:// references only — no real secrets |
| `.env` | **Never** | Real local environment |
| `config/.env.local` | **Never** | Real local environment |
| `config/.env.production` | **Never** | Real production environment |

---

## PathBuilder-Specific Variables

| Variable | op:// Reference | Purpose |
|----------|----------------|---------|
| `PATHBUILDER_DB_SCHEMA` | `pathbuilder` (not a secret — hardcode in .env.example) | Postgres schema name |
| `PATHBUILDER_STORAGE_PREFIX` | `pathbuilder/` (not a secret — hardcode in .env.example) | Spaces object prefix |
| `DB_HOST` | `op://agent-credentials/[agent]/db-host` | Postgres host |
| `DB_PORT` | `op://agent-credentials/[agent]/db-port` | Postgres port |
| `DB_NAME` | `op://agent-credentials/[agent]/db-name` | Database name |
| `DB_USER` | `op://agent-credentials/[agent]/db-user` | Database user |
| `DB_PASSWORD` | `op://agent-credentials/[agent]/db-password` | Database password |
| `DO_TOKEN` | `op://agent-credentials/[agent]/do-token` | DigitalOcean API token |
| `SPACES_KEY` | `op://agent-credentials/[agent]/spaces-key` | Spaces S3 access key |
| `SPACES_SECRET` | `op://agent-credentials/[agent]/spaces-secret` | Spaces S3 secret |
| `SPACES_REGION` | `op://agent-credentials/[agent]/spaces-region` | Spaces region |
| `SPACES_BUCKET` | `op://agent-credentials/[agent]/spaces-bucket` | Spaces bucket name |
| `SPACES_ENDPOINT` | `op://agent-credentials/[agent]/spaces-endpoint` | Spaces endpoint URL |
| `GITHUB_TOKEN` | `op://agent-credentials/[agent]/github-pat` | GitHub PAT |
| `MONDAY_TOKEN` | `op://agent-credentials/[agent]/monday-token` | Monday.com API token |

---

## Validating Without Printing

```powershell
# PowerShell
if ($env:DO_TOKEN) {
  "DO_TOKEN SET length=$($env:DO_TOKEN.Length)"
} else {
  "DO_TOKEN NOT SET"
}
```

```bash
# Bash
[ -n "$DO_TOKEN" ] && echo "SET (len=${#DO_TOKEN})" || echo "NOT SET"
```

Never run `echo $DO_TOKEN` or equivalent.

---

## 1Password SA Token
Field: `credential` (not `password`)
Item: `1password Service Account`
Vault: `agent-credentials`

---

## Security Rules
1. Never paste a real token into any markdown, YAML, JSON, or env file.
2. Never include a real connection string in any committed doc.
3. If a secret is accidentally committed, rotate it immediately and remove from git history.
4. If a secret appears in a PR diff, stop the merge immediately and alert Justin.
