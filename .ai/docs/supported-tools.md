# Supported Tools

Download and install the AI coding tool of your choice. AI Dev Agents works with all of them.

## Terminal Agents (Full Support)

| Tool | Download | Instructions File | On-demand Agents |
|---|---|---|---|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | `CLAUDE.md` | `.claude/agents/` (yes) |
| [OpenCode](https://opencode.ai) | Download from website | `AGENTS.md` | `.opencode/agents/` (yes) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @google/gemini-cli` | `GEMINI.md` | `.gemini/skills/` (yes) |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` | `AGENTS.md` | `.agents/skills/` (yes) |
| [GitHub Copilot CLI](https://github.com/features/copilot/cli) | `gh extension install github/gh-copilot` | `AGENTS.md`, `.github/copilot-instructions.md` | Yes (reads AGENTS.md) |
| [Antigravity](https://antigravity.google) | Download from website | `GEMINI.md` | `.agents/rules/` (yes, @mention) |

## IDEs (Basic Support)

| Tool | Download | Instructions File | On-demand Agents |
|---|---|---|---|
| [Cursor](https://cursor.com/) | Download from website | `.cursorrules` | No (all inline) |
| [Windsurf](https://windsurf.com/editor) | Download from website | `.windsurfrules` | No (all inline) |

## IDE Extensions (Basic Support)

| Tool | Download | Instructions File | On-demand Agents |
|---|---|---|---|
| [GitHub Copilot (IDE)](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) | VS Code / JetBrains extension | `.github/copilot-instructions.md` | No (context only) |
| [Continue](https://marketplace.visualstudio.com/items?itemName=Continue.continue) | VS Code extension | `.continue/rules/` | Partial (implicit matching) |

## Notes

- **Terminal agents** read `AGENTS.md` and support the full agent system (roles, gates, skills)
- **IDEs and extensions** receive a compact version of all rules in a single file
- `sync.sh` generates the correct config files for all tools automatically
- You only need ONE tool — choose whichever fits your workflow
