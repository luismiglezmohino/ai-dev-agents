# Supported Tools

Download and install the AI coding tool of your choice. AI Dev Agents works with all of them.

## Terminal Agents (Full Support)

| Tool | Download | Instructions File | On-demand Agents |
|---|---|---|---|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | `CLAUDE.md` | `.claude/agents/` (yes) |
| [OpenCode](https://github.com/opencode-ai/opencode) | `go install github.com/opencode-ai/opencode@latest` | `AGENTS.md` | `.opencode/agents/` (yes) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @anthropic-ai/gemini-cli` | `GEMINI.md` | `.gemini/skills/` (yes) |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` | `AGENTS.md` | `.agents/skills/` (yes) |
| [GitHub Copilot CLI](https://docs.github.com/en/copilot/github-copilot-in-the-cli) | `gh extension install github/gh-copilot` | `AGENTS.md`, `.github/copilot-instructions.md` | Yes (reads AGENTS.md) |
| [Antigravity](https://antigravity.google) | Download from website | `GEMINI.md` | `.agents/rules/` (yes, @mention) |

## IDE Extensions (Basic Support)

| Tool | Download | Instructions File | On-demand Agents |
|---|---|---|---|
| [GitHub Copilot (IDE)](https://github.com/features/copilot) | VS Code / JetBrains extension | `.github/copilot-instructions.md` | No (context only) |
| [Continue](https://continue.dev/) | VS Code extension | `.continue/rules/` | Partial (implicit matching) |
| [Cursor](https://cursor.com/) | Download from website | `.cursorrules` | No (all inline) |
| [Windsurf](https://codeium.com/windsurf) | Download from website | `.windsurfrules` | No (all inline) |

## Notes

- **Terminal agents** read `AGENTS.md` and support the full agent system (roles, gates, skills)
- **IDE extensions** receive a compact version of all rules in a single file
- `sync.sh` generates the correct config files for all tools automatically
- You only need ONE tool — choose whichever fits your workflow
