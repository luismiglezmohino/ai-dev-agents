# OpenCode

## How It Works

OpenCode reads agents directly from `.opencode/agents/` and skills from `.opencode/skills/`.

`sync.sh` creates symlinks pointing to the source directories (`agents/` and `skills/`).

## Generated Files

| File | Purpose |
|---|---|
| `.opencode/agents` | Symlink to `../.ai/agents` |
| `.opencode/skills` | Symlink to `../.ai/skills` |
| `.opencode/decisions.md` | Copy of `decisions.md` |

## Setup

1. Run `./sync.sh`
2. Agents are read directly (no conversion needed)

## AGENTS.md

OpenCode also reads `AGENTS.md` at the project root. Use `AGENTS.md.template` as a starting point.
