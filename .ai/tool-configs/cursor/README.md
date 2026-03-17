# Cursor

## Como funciona

Cursor lee reglas desde `.cursorrules` en la raíz del proyecto.

`sync.sh` genera automáticamente una versión compacta de todos los agentes en `.cursorrules`.

## Ficheros generados

| Fichero | Proposito |
|---|---|
| `.cursorrules` | Reglas compactas (auto-generado) |

## Limitaciones

- No soporta agentes individuales invocables
- No soporta sub-agentes ni routing
- Las reglas son un único fichero plano
- No soporta skills como ficheros separados

## Setup

1. Ejecutar `./sync.sh`
2. `.cursorrules` se genera automáticamente
3. Cursor lo lee en cada sesión
