# Cursor

## How It Works

Cursor reads rules from `.cursorrules` at the project root.

`sync.sh` automatically generates a compact version of all agents in `.cursorrules`.

## Generated Files

| File | Purpose |
|---|---|
| `.cursorrules` | Compact rules (auto-generated) |

## Limitations

- Does not support individually invocable agents
- Does not support sub-agents or routing
- Rules are a single flat file
- Does not support skills as separate files

## Setup

1. Run `./sync.sh`
2. `.cursorrules` is automatically generated
3. Cursor reads it in every session
