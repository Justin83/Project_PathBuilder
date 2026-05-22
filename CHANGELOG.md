# CHANGELOG — Project PathBuilder

Format: `YYYY-MM-DD | Change | Files affected`

---

2026-05-22 | 1Password silent startup protocol added — SA token bootstrap, MCP server wiring, PowerShell profile aliases | agentharness/1PASSWORD_STARTUP_PROTOCOL.md, agent-harness/AGENT_INSTRUCTIONS_MAP.md
2026-05-22 | Post-audit harness updates — 90-day token expiry noted, pathbuilder_app role captured, .gitignore created | agentharness/INFRASTRUCTURE.md, .gitignore
2026-05-22 | Relaxed git policy applied — agents drive full PR/squash-merge/comment cycle with Justin's awareness; hard no-merge conditions unchanged | CLAUDE.md, agentharness/GITHUB_WORKFLOW.md, agentharness/OPERATING_PROTOCOL.md
2026-05-22 | Initial agent harness scaffolded — CLAUDE.md, agentharness/, agent-harness/, agents/, config/project.yml | 19 files created
2026-05-22 | Documented DigitalOcean infrastructure reuse plan — schema isolation, Spaces prefix, token status | agentharness/INFRASTRUCTURE.md
2026-05-22 | Monday.com board confirmed: 18414133952 — Project PathBuilder Charter | config/project.yml, agent-harness/AGENT_INSTRUCTIONS.md
2026-05-22 | Confirmed DO REST API token broken (HTTP 401) — no infra changes made | agentharness/INFRASTRUCTURE.md
2026-05-22 | Confirmed Postgres accessible as doadmin — pathbuilder schema not yet created | agentharness/INFRASTRUCTURE.md, agentharness/DATABASE_SAFETY_PROTOCOL.md
