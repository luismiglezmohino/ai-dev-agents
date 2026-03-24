# GitHub Copilot / Copilot CLI

## Two Modes

### Copilot CLI (terminal agent — full support)

GitHub Copilot CLI is a terminal-native AI coding agent (like Claude Code). It reads:

| File | Scope |
|---|---|
| `~/.copilot/copilot-instructions.md` | Global |
| `.github/copilot-instructions.md` | Repository |
| `.github/instructions/**/*.instructions.md` | Repository (modular) |
| `AGENTS.md` (in Git root or cwd) | Repository |
| `Copilot.md`, `GEMINI.md`, `CODEX.md` | Repository |

**Copilot CLI reads AGENTS.md** — all agents and skills from this template work natively.

Features: `/plan`, `/compact`, `/clear`, `/delegate`, `/fleet` (parallel subtasks), multi-model (Claude Opus, Sonnet, GPT Codex), multi-repository, infinite sessions.

### Copilot IDE (autocomplete — basic support)

GitHub Copilot in VS Code/Cursor reads `.github/copilot-instructions.md` as general context. Does not support individually invocable agents.

## Generated Files

| File | Purpose | Used by |
|---|---|---|
| `.github/copilot-instructions.md` | Compact rules (auto-generated) | Both IDE and CLI |
| `AGENTS.md` | Agent definitions (auto-generated) | CLI only |

## Setup

1. Run `./sync.sh`
2. `.github/copilot-instructions.md` and `AGENTS.md` are automatically generated
3. **CLI:** Run `copilot` in the project root — reads AGENTS.md automatically
4. **IDE:** Copilot reads `.github/copilot-instructions.md` automatically
