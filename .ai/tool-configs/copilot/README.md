# GitHub Copilot

## How It Works

GitHub Copilot reads instructions from `.github/copilot-instructions.md`.

`sync.sh` automatically generates a compact version of all agents in this file.

## Generated Files

| File | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Compact rules (auto-generated) |

## Limitations

- Does not support individually invocable agents
- Does not support sub-agents or routing
- Instructions are a single flat file
- Does not support skills as separate files
- Copilot processes instructions as general context, not as roles

## Setup

1. Run `./sync.sh`
2. `.github/copilot-instructions.md` is automatically generated
3. Copilot reads it automatically in the repository
