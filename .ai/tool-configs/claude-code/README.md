# Claude Code

## How It Works

Claude Code reads agents from `.claude/agents/` (proprietary format with `name`, `description`, `tools` frontmatter).

`sync.sh` automatically converts agents from `agents/` (OpenCode format) to Claude Code format.

## Generated Files

| File | Purpose |
|---|---|
| `.claude/agents/*.md` | Converted agents (1 per agent) |
| `.claude/skills` | Symlink to `../.ai/skills` |
| `.claude/rules/decisions.md` | Copy of `decisions.md` (auto-loaded) |
| `.claude/rules/project-context.md` | Project context without frontmatter (auto-loaded) |

## Hooks

Configured in `.claude/settings.json`:

| Hook | Script | When it runs |
|---|---|---|
| `SessionStart` | `.ai/hooks/session-start.sh` | On session start, resume or compact |
| `PreCompact` | `.ai/hooks/pre-compact.sh` | Before compressing context |
| `SessionEnd` | `.ai/hooks/session-stop.sh` | On session end |

Hooks receive JSON on stdin (not plain text). They use `$CLAUDE_PROJECT_DIR` for paths.

## Setup

1. Run `.ai/sync.sh`
2. Agents appear automatically in Claude Code

## CLAUDE.md

Claude Code reads `CLAUDE.md` at the project root and in subdirectories (hierarchical). Use `CLAUDE.md.template` as a starting point. Supports imports with `@path/to/file`.

## .claude/rules/

`.md` files in `.claude/rules/` are auto-loaded in every message. They support `paths` frontmatter for conditional loading by glob pattern.

## MCP

Claude Code supports MCP servers to extend functionality (Engram, Context7, Sentry, etc). Configure in `.claude/settings.json`.
