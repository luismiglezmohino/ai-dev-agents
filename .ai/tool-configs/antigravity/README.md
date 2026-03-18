# Google Antigravity

## How It Works

Antigravity reads Rules from `.agents/rules/` and Workflows from `.agents/workflows/` in the workspace root. It also supports MCP servers natively.

`sync.sh` generates workspace rules from `.ai/agents/` and workflows from `.ai/prompts/`.

## Generated Files

| File | Purpose |
|---|---|
| `.agents/rules/*.md` | Agent rules (1 per agent, Manual activation = @mentionable) |
| `.agents/rules/project-context.md` | Project context (Always On) |
| `.agents/workflows/*.md` | Prompts as invocable workflows (`/workflow-name`) |

## How Agents Map to Antigravity

| Template concept | Antigravity feature |
|---|---|
| Agents (`.ai/agents/`) | Rules with Manual activation (invoked via @mention) |
| Project context | Rule with Always On activation (loaded every message) |
| Prompts (`.ai/prompts/`) | Workflows (invoked via `/name`) |
| Skills (`.ai/skills/`) | Referenced from rules with `@.ai/skills/name/SKILL.md` |
| MCP servers | Supported natively (configure in Agent settings) |

## Activation Modes

Each rule has an activation mode:

| Mode | Used for |
|---|---|
| **Manual** | Agent rules (invoked via @architect, @tdd-developer, etc.) |
| **Always On** | Project context, decisions (loaded every message) |
| **Model Decision** | Not used by default |
| **Glob** | Not used by default (useful for per-module rules) |

## Limitations

- Rules and Workflows limited to 12,000 characters each
- No sub-agent spawning (single agent model)
- No native model routing per rule
- Skills referenced via @mention, not as separate invocable entities

## Setup

1. Run `.ai/sync.sh`
2. Rules appear in `.agents/rules/` (mentionable in chat)
3. Workflows appear in `.agents/workflows/` (invocable with `/name`)
4. Configure MCPs in Agent settings

## Compatibility with Template

| Capability | Supported |
|---|---|
| Agents as rules | Yes (@mention activation) |
| On-demand loading | Yes (Manual activation = only when mentioned) |
| Cross-verification | Manual (user invokes review agents or uses `/code-review` workflow) |
| Skills as context | Yes (referenced via @mention from rules) |
| Workflows (prompts) | Yes (invocable with `/name`) |
| Memory hooks | No |
| MCPs | Yes |
