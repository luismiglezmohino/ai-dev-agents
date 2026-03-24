# Herramientas Soportadas

Descarga e instala la herramienta de IA que prefieras. AI Dev Agents funciona con todas.

## Agentes de Terminal (Soporte Completo)

| Herramienta | Descarga | Fichero de instrucciones | Agentes bajo demanda |
|---|---|---|---|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | `CLAUDE.md` | `.claude/agents/` (sí) |
| [OpenCode](https://github.com/opencode-ai/opencode) | `go install github.com/opencode-ai/opencode@latest` | `AGENTS.md` | `.opencode/agents/` (sí) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @anthropic-ai/gemini-cli` | `GEMINI.md` | `.gemini/skills/` (sí) |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` | `AGENTS.md` | `.agents/skills/` (sí) |
| [GitHub Copilot CLI](https://docs.github.com/en/copilot/github-copilot-in-the-cli) | `gh extension install github/gh-copilot` | `AGENTS.md`, `.github/copilot-instructions.md` | Sí (lee AGENTS.md) |
| [Antigravity](https://antigravity.google) | Descargar desde la web | `GEMINI.md` | `.agents/rules/` (sí, @mention) |

## Extensiones IDE (Soporte Básico)

| Herramienta | Descarga | Fichero de instrucciones | Agentes bajo demanda |
|---|---|---|---|
| [GitHub Copilot (IDE)](https://github.com/features/copilot) | Extensión VS Code / JetBrains | `.github/copilot-instructions.md` | No (solo contexto) |
| [Continue](https://continue.dev/) | Extensión VS Code | `.continue/rules/` | Parcial (matching implícito) |
| [Cursor](https://cursor.com/) | Descargar desde la web | `.cursorrules` | No (todo inline) |
| [Windsurf](https://codeium.com/windsurf) | Descargar desde la web | `.windsurfrules` | No (todo inline) |

## Notas

- Los **agentes de terminal** leen `AGENTS.md` y soportan el sistema completo de agentes (roles, gates, skills)
- Las **extensiones IDE** reciben una versión compacta de todas las reglas en un solo fichero
- `sync.sh` genera los ficheros de configuración correctos para todas las herramientas automáticamente
- Solo necesitas UNA herramienta — elige la que encaje con tu flujo de trabajo
