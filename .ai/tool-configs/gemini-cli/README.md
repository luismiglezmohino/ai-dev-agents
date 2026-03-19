# Gemini CLI

## How It Works

Gemini CLI reads project context from `GEMINI.md`, discovers skills from `.gemini/skills/` or `.agents/skills/`, and supports MCPs, hooks, subagents, and model routing natively.

`sync.sh` generates `GEMINI.md` (compact rules) and creates symlinks for skills.

## Generated Files

| File | Purpose |
|---|---|
| `GEMINI.md` | Project context + compact agent rules (auto-generated) |
| `.gemini/skills` | Symlink to `../../.ai/skills` (on-demand skills) |
| `.agents/skills` | Symlink to `../../.ai/skills` (alternative path, shared with Codex) |

## How Agents Map to Gemini CLI

| Template concept | Gemini CLI feature |
|---|---|
| Agents (`.ai/agents/`) | Compact rules in `GEMINI.md` + skills for on-demand expertise |
| Project context | `GEMINI.md` (always loaded) |
| Skills (`.ai/skills/`) | Agent Skills (`.gemini/skills/` or `.agents/skills/`, on-demand via `activate_skill`) |
| Prompts (`.ai/prompts/`) | Paste in chat or reference with `@` |
| MCP servers | Supported natively |
| Hooks | Supported natively |
| Subagents | Supported natively |

## Skills Discovery

Gemini CLI discovers skills from three locations (highest priority first):

1. **Workspace**: `.gemini/skills/` or `.agents/skills/` (committed to repo)
2. **User**: `~/.gemini/skills/` or `~/.agents/skills/` (personal)
3. **Extension**: Bundled with installed extensions

Skills use **progressive disclosure**: only name + description are loaded initially. Full `SKILL.md` content is loaded only when `activate_skill` is called.

## System Prompt Override (optional)

For advanced users, Gemini CLI supports replacing its entire system prompt:

```bash
# Enable with project file (.gemini/system.md)
GEMINI_SYSTEM_MD=1

# Use variable substitution to include skills/subagents
# ${AgentSkills} — injects all available skills
# ${SubAgents} — injects available sub-agents
# ${AvailableTools} — injects tool list
```

Best practice: `GEMINI.md` for project strategy, `SYSTEM.md` for operational rules.

## Limitations

- No per-agent model routing (model routing is for fallback, not per-role)
- Skills are loaded for the entire session once activated (not per-message)
- No native concept of "agent roles" — agents are implemented as skills

## Setup

1. Run `.ai/sync.sh`
2. `GEMINI.md` is generated (compact rules)
3. `.gemini/skills/` symlink is created (on-demand skills)
4. Configure MCPs in Gemini CLI settings

## Compatibility with Template

| Capability | Supported |
|---|---|
| Agents as compact rules | Yes (via GEMINI.md) |
| On-demand skills | Yes (activate_skill) |
| Cross-verification | Manual (user invokes skills) |
| Prompts as workflows | No (paste manually) |
| Memory hooks | Yes (native hooks) |
| MCPs | Yes |
| Subagents | Yes |
| Model routing | Fallback only (not per-agent) |
