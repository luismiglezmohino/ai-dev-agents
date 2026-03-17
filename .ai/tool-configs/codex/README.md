# Codex (OpenAI)

## How It Works

Codex reads instructions from `AGENTS.md` in the project root (same as OpenCode). It also supports a `.codex/` directory for additional configuration.

`sync.sh` already generates `AGENTS.md` that Codex can read directly.

## Files Used

| File | Purpose |
|---|---|
| `AGENTS.md` | Main instructions (shared with OpenCode) |
| `.codex/` | Additional Codex configuration (optional) |

## Limitations

- Supports agents as context but not as separately invocable entities
- No native sub-agent support
- No per-agent model routing
- Skills are read as context files, not invocable modules

## Setup

1. Run `.ai/sync.sh`
2. `AGENTS.md` is automatically generated in the root
3. Codex reads it on session start
4. Optionally, create `.codex/` with specific configuration

## MCPs in Codex

Codex supports MCPs. Configure in `.codex/config.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

## Template Compatibility

| Capability | Supported |
|---|---|
| Agents as context | Yes (via AGENTS.md) |
| Invocable agents | No |
| Skills as context | Yes (referenced in AGENTS.md) |
| Cross-verification | Manual (user invokes review agents) |
| Memory hooks | No |
| MCPs | Yes |
