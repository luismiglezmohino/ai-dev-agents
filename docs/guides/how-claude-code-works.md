# How Claude Code Works (and why it matters for agents)

[🇪🇸 Leer en español](es/how-claude-code-works.md)

> Back to [README](../../README.md)

Claude Code is an agent that runs in your terminal. It works in a 3-phase loop:

```
Your prompt → Gather context → Act → Verify → Repeat until complete
                   ↑                                     |
                   └──── You can interrupt at any point
```

## What It Can Access

| Resource | Description |
|----------|-------------|
| Your project | Files, structure, dependencies |
| Terminal | Any command (git, npm, docker, etc.) |
| CLAUDE.md | Persistent instructions (loaded in EVERY message) |
| .ai/agents/*.md | On-demand agents (loaded only when role is invoked) |
| .ai/skills/*.md | On-demand skills (loaded only when consulted) |
| MCP servers | External tools (DB, docs, error tracking, etc.) |

## Context Management

The context window fills with: conversation history, read files, command outputs, CLAUDE.md, loaded skills and MCP tool definitions.

```
Always in context (every message):
  ├── CLAUDE.md                    → KEEP < 120 lines
  ├── MCP tool definitions         → Each MCP adds its tools
  └── Conversation history         → Auto-compacted

On demand (only when used):
  ├── .ai/agents/*.md              → Loaded when role is invoked
  ├── .ai/skills/*.md              → Loaded when consulted
  └── Subagents                    → Separate context (don't inflate yours)
```

**Useful commands:**
- `/context` - See what's using space in the context window
- `/compact` - Manually compact (e.g.: `/compact focus on the API changes`)
- `/mcp` - See status and token cost of each MCP server

**Implication for this template:** That's why CLAUDE.md must be compact (~100 lines). Details go in `.ai/agents/` and `.ai/skills/` which are only loaded when needed. If you duplicate agent content in CLAUDE.md, you waste tokens on every message.
