# Codex CLI (OpenAI)

## How It Works

Codex CLI reads instructions from `AGENTS.md`, discovers skills from `.agents/skills/`, supports MCPs, subagents, and sandbox rules natively.

`sync.sh` generates `AGENTS.md` and creates a symlink for skills.

## Generated Files

| File | Purpose |
|---|---|
| `AGENTS.md` | Main instructions (shared with OpenCode) |
| `.agents/skills` | Symlink to `../../.ai/skills` (on-demand skills, shared with Gemini CLI) |

## How Agents Map to Codex

| Template concept | Codex feature |
|---|---|
| Agents (`.ai/agents/`) | Compact rules in `AGENTS.md` + skills for on-demand expertise |
| Project context | `AGENTS.md` (always loaded) |
| Skills (`.ai/skills/`) | Agent Skills (`.agents/skills/`, on-demand via `/skills` or `$skill-name`) |
| Prompts (`.ai/prompts/`) | Paste in chat |
| MCP servers | Supported (`config.toml`, STDIO + HTTP streamable) |
| Subagents | Supported natively |
| Sandbox rules | `.codex/rules/` (Starlark format, command-level control) |

## Skills Discovery

Codex discovers skills from multiple scopes:

| Scope | Location | Purpose |
|---|---|---|
| REPO | `$CWD/.agents/skills` | Team skills, committed to repo |
| USER | `$HOME/.agents/skills` | Personal skills across projects |
| ADMIN | `/etc/codex/skills` | Machine-wide skills |
| SYSTEM | Bundled with Codex | Built-in skills |

Skills use **progressive disclosure**: only metadata (name, description) is loaded initially. Full `SKILL.md` is loaded only when Codex decides to use the skill.

Activation modes:
- **Explicit**: `/skills` or `$skill-name` in prompt
- **Implicit**: Codex matches task to skill description automatically

## MCP Configuration

```toml
# ~/.codex/config.toml (or .codex/config.toml for project scope)
[mcp.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
```

## Limitations

- Sandbox rules use Starlark format (not markdown) — different from our agents
- No native concept of "agent roles" — agents are implemented as skills
- `AGENTS.md` is a single flat file (no per-agent routing)

## Setup

1. Run `.ai/sync.sh`
2. `AGENTS.md` is generated at the root
3. `.agents/skills/` symlink is created (on-demand skills)
4. Configure MCPs via `codex mcp add` or `config.toml`

## Compatibility with Template

| Capability | Supported |
|---|---|
| Agents as context | Yes (via AGENTS.md) |
| On-demand skills | Yes (/skills, $skill-name, implicit) |
| Cross-verification | Manual (user invokes skills) |
| Prompts as workflows | No (paste manually) |
| Memory hooks | No |
| MCPs | Yes (STDIO + HTTP streamable) |
| Subagents | Yes |
| Sandbox rules | Yes (.codex/rules/, Starlark) |
