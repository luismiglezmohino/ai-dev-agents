# Claude Code

## Como funciona

Claude Code lee agentes desde `.claude/agents/` (formato propio con frontmatter `name`, `description`, `tools`).

`sync.sh` convierte automáticamente los agentes de `agents/` (formato OpenCode) al formato Claude Code.

## Ficheros generados

| Fichero | Proposito |
|---|---|
| `.claude/agents/*.md` | Agentes convertidos (1 por agente) |
| `.claude/skills` | Enlace simbólico a `../.ai/skills` |
| `.claude/rules/decisions.md` | Copia de `decisions.md` (auto-cargado) |
| `.claude/rules/project-context.md` | Contexto del proyecto sin frontmatter (auto-cargado) |

## Hooks

Configurados en `.claude/settings.json`:

| Hook | Script | Cuando se ejecuta |
|---|---|---|
| `SessionStart` | `.ai/hooks/session-start.sh` | Al iniciar, resumir o compactar sesión |
| `PreCompact` | `.ai/hooks/pre-compact.sh` | Antes de comprimir contexto |
| `SessionEnd` | `.ai/hooks/session-stop.sh` | Al terminar la sesión |

Los hooks reciben JSON en stdin (no texto plano). Usan `$CLAUDE_PROJECT_DIR` para rutas.

## Setup

1. Ejecutar `.ai/sync.sh`
2. Los agentes aparecen automáticamente en Claude Code

## CLAUDE.md

Claude Code lee `CLAUDE.md` en la raíz del proyecto y en subdirectorios (jerarquico). Usa `CLAUDE.md.template` como punto de partida. Soporta imports con `@path/to/file`.

## .claude/rules/

Archivos `.md` en `.claude/rules/` se auto-cargan en cada mensaje. Soportan frontmatter `paths` para carga condicional por glob pattern.

## MCP

Claude Code soporta MCP servers para extender funcionalidad (Engram, Context7, Sentry, etc). Configurar en `.claude/settings.json`.
