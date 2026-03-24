# Herramientas Soportadas

Descarga e instala la herramienta de IA que prefieras. AI Dev Agents funciona con todas.

## Agentes de Terminal (Soporte Completo)

| Herramienta | Descarga | Fichero de instrucciones | Agentes bajo demanda |
|---|---|---|---|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | `CLAUDE.md` | `.claude/agents/` (sí) |
| [OpenCode](https://opencode.ai) | Descargar desde la web | `AGENTS.md` | `.opencode/agents/` (sí) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @google/gemini-cli` | `GEMINI.md` | `.gemini/skills/` (sí) |
| [Codex CLI](https://github.com/openai/codex) | `npm install -g @openai/codex` | `AGENTS.md` | `.agents/skills/` (sí) |
| [GitHub Copilot CLI](https://github.com/features/copilot/cli) | `gh extension install github/gh-copilot` | `AGENTS.md`, `.github/copilot-instructions.md` | Sí (lee AGENTS.md) |
| [Antigravity](https://antigravity.google) | Descargar desde la web | `GEMINI.md` | `.agents/rules/` (sí, @mention) |

## IDEs (Soporte Básico)

| Herramienta | Descarga | Fichero de instrucciones | Agentes bajo demanda |
|---|---|---|---|
| [Cursor](https://cursor.com/) | Descargar desde la web | `.cursorrules` | No (todo inline) |
| [Windsurf](https://windsurf.com/editor) | Descargar desde la web | `.windsurfrules` | No (todo inline) |

## Extensiones IDE (Soporte Básico)

| Herramienta | Descarga | Fichero de instrucciones | Agentes bajo demanda |
|---|---|---|---|
| [GitHub Copilot (IDE)](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) | Extensión VS Code / JetBrains | `.github/copilot-instructions.md` | No (solo contexto) |
| [Continue](https://marketplace.visualstudio.com/items?itemName=Continue.continue) | Extensión VS Code | `.continue/rules/` | Parcial (matching implícito) |

## Notas

- Los **agentes de terminal** leen `AGENTS.md` y soportan el sistema completo de agentes (roles, gates, skills)
- Los **IDEs y extensiones** reciben una versión compacta de todas las reglas en un solo fichero
- `sync.sh` genera los ficheros de configuración correctos para todas las herramientas automáticamente
- Solo necesitas UNA herramienta — elige la que encaje con tu flujo de trabajo
