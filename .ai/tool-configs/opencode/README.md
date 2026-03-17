# OpenCode

## Como funciona

OpenCode lee agentes directamente desde `.opencode/agents/` y skills desde `.opencode/skills/`.

`sync.sh` crea enlaces simbólicos que apuntan a los directorios fuente (`agents/` y `skills/`).

## Ficheros generados

| Fichero | Proposito |
|---|---|
| `.opencode/agents` | Enlace simbólico a `../.ai/agents` |
| `.opencode/skills` | Enlace simbólico a `../.ai/skills` |
| `.opencode/decisions.md` | Copia de `decisions.md` |

## Setup

1. Ejecutar `./sync.sh`
2. Los agentes se leen directamente (sin conversion)

## AGENTS.md

OpenCode tambien lee `AGENTS.md` en la raíz del proyecto. Usa `AGENTS.md.template` como punto de partida.
