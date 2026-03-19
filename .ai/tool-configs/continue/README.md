# Continue (VS Code)

## How It Works

Continue reads rules from `.continue/rules/` in the workspace. Rules are markdown files with YAML frontmatter. It supports MCPs and multiple AI models (Ollama, Claude, GPT, Gemini, etc.).

`sync.sh` generates rules from `.ai/agents/` into `.continue/rules/`.

## Generated Files

| File | Purpose |
|---|---|
| `.continue/rules/*.md` | Agent rules (one per agent, with frontmatter) |

## How Agents Map to Continue

| Template concept | Continue feature |
|---|---|
| Agents (`.ai/agents/`) | Rules in `.continue/rules/` (individual markdown files) |
| Project context | Rule with `alwaysApply: true` |
| Skills (`.ai/skills/`) | Referenced from rules via file paths |
| Prompts (`.ai/prompts/`) | Paste in chat |
| MCP servers | Supported (configure in `config.yaml`) |

## Rule Format

```markdown
---
name: security-auditor
description: OWASP Top 10 security audit
alwaysApply: false
---

# AGENT ROLE: Security Auditor
[agent content here]
```

- `alwaysApply: true` — loaded every message (project-context, decisions)
- `alwaysApply: false` — loaded when Continue's agent matches the description to the task

## Rule Loading Order

1. Hub assistant rules
2. Referenced Hub rules (via `uses:` in `config.yaml`)
3. Local workspace rules (`.continue/rules/`)
4. Global rules (`~/.continue/rules/`)

## MCP Configuration

```yaml
# .continue/config.yaml
mcpServers:
  - name: context7
    command: npx
    args: ["-y", "@upstash/context7-mcp"]
```

## Limitations

- No native sub-agents or orchestrator
- No native skill activation (skills referenced as context, not invocable)
- Rule matching is implicit (based on description), not explicit (@mention)

## Setup

1. Run `.ai/sync.sh`
2. Rules appear in `.continue/rules/`
3. Configure models and MCPs in `.continue/config.yaml`

## Compatibility with Template

| Capability | Supported |
|---|---|
| Agents as rules | Yes (individual markdown files) |
| On-demand rules | Partial (implicit matching via description) |
| Cross-verification | Manual (user requests review) |
| Skills as context | Yes (referenced from rules) |
| Prompts | Paste in chat |
| Memory hooks | No |
| MCPs | Yes |
| Multi-model | Yes (Ollama, Claude, GPT, Gemini, etc.) |
