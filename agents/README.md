# Agent Environment Files

Each .env file loads credentials for a specific agent from
the 1Password `agent-credentials` vault using op:// secret references.

## Starting a session
    op run --env-file ./agents/[agent-name].env -- [command]

## Agents

| File | Agent | DO Access | Postgres | Spaces | Monday |
|------|-------|-----------|----------|--------|--------|
| claude-cli.env | Claude CLI (MCP/chat) | Read+Write | Read | Read | Read+Write |
| claude-code.env | Claude Code (terminal) | Read+Write | Read | Read | Read+Write |
| remote-rob.env | Remote Rob (Python) | Read only | Read | Read | Read+Write |
| codex.env | Codex (OpenAI) | Read+Write | Read | Read | Read+Write |
| chatgpt.env | ChatGPT | Read+Write | Read | Read | Read+Write |

## 1Password SA Token
Field: `credential` (not `password`)
Item: `1password Service Account`
Vault: `agent-credentials`

## Adding a new agent
1. Ask Justin to create the item in `agent-credentials` vault
2. Copy an existing .env file, update the item name references
3. Add a row to the table above
4. Update CLAUDE.md known agents list
5. Update `config/project.yml` → agents.known list
