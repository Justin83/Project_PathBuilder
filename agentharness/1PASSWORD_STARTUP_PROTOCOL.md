# 1Password Startup Protocol — PathBuilder
**Canonical doc:** `jnh-dev-kit/agentharness/1PASSWORD_STARTUP_PROTOCOL.md`
**This file:** PathBuilder-specific reference. Read the canonical doc for full setup steps.

---

## Summary

Without `OP_SERVICE_ACCOUNT_TOKEN` set as a system env var, every `op` call
prompts for interactive auth. With it set, `op run` resolves all vault entries
silently in one batch — no prompts, no password entry mid-session.

---

## One-Time Setup (if not already done system-wide)

1. Open 1Password → vault `agent-credentials` → item `1password Service Account` → copy `credential` field
2. Set as Windows User env var (run once in PowerShell):
```powershell
[System.Environment]::SetEnvironmentVariable(
    "OP_SERVICE_ACCOUNT_TOKEN",
    "<paste-here>",
    "User"
)
```
3. Open a new terminal. Verify:
```powershell
$t = [System.Environment]::GetEnvironmentVariable("OP_SERVICE_ACCOUNT_TOKEN","User")
if ($t) { "SET len=$($t.Length)" } else { "NOT SET" }
```
4. Restart Claude Desktop/Code so MCP servers pick it up.

---

## PathBuilder Agent Startup

```powershell
# Load all PathBuilder agent tokens silently, then run a command
op run --env-file C:\xampp\htdocs\Project_PathBuilder\agents\claude-cli.env -- [command]
```

---

## MCP Server Wiring

In `%APPDATA%\Claude\claude_desktop_config.json`, wrap each PathBuilder-relevant
MCP server with `op run` pointing to the PathBuilder `agents/claude-cli.env`:

```json
{
  "mcpServers": {
    "digitalocean": {
      "command": "op",
      "args": [
        "run",
        "--env-file", "C:\\xampp\\htdocs\\Project_PathBuilder\\agents\\claude-cli.env",
        "--",
        "[do-mcp-server-command]", "[args]"
      ]
    }
  }
}
```

See the canonical doc in jnh-dev-kit for the full MCP wiring pattern and
PowerShell profile aliases (`claude-op`, `check-creds`).

---

## Vault: agent-credentials

All PathBuilder tokens live here. Items: `claude-cli`, `claude-code`,
`remote-rob`, `codex`, `chatgpt`, `1password Service Account`.

The `agents/*.env` files in this repo reference them via `op://` URIs — safe to
commit; no real values are stored in git.
