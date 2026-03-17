# GitHub Copilot

## Como funciona

GitHub Copilot lee instrucciones desde `.github/copilot-instructions.md`.

`sync.sh` genera automáticamente una versión compacta de todos los agentes en este fichero.

## Ficheros generados

| Fichero | Proposito |
|---|---|
| `.github/copilot-instructions.md` | Reglas compactas (auto-generado) |

## Limitaciones

- No soporta agentes individuales invocables
- No soporta sub-agentes ni routing
- Las instrucciones son un único fichero plano
- No soporta skills como ficheros separados
- Copilot procesa las instrucciones como contexto general, no como roles

## Setup

1. Ejecutar `./sync.sh`
2. `.github/copilot-instructions.md` se genera automáticamente
3. Copilot lo lee automáticamente en el repositorio
