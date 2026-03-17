# Windsurf

## How It Works

Windsurf reads rules from `.windsurfrules` at the project root.

`sync.sh` automatically generates a compact version of all agents in `.windsurfrules`.

## Generated Files

| File | Purpose |
|---|---|
| `.windsurfrules` | Compact rules (auto-generated) |

## Limitations

- Does not support individually invocable agents
- Does not support sub-agents or routing
- Rules are a single flat file
- Does not support skills as separate files

## Setup

1. Run `./sync.sh`
2. `.windsurfrules` is automatically generated
3. Windsurf reads it in every session
