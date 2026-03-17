# Windsurf

## Como funciona

Windsurf lee reglas desde `.windsurfrules` en la raíz del proyecto.

`sync.sh` genera automáticamente una versión compacta de todos los agentes en `.windsurfrules`.

## Ficheros generados

| Fichero | Proposito |
|---|---|
| `.windsurfrules` | Reglas compactas (auto-generado) |

## Limitaciones

- No soporta agentes individuales invocables
- No soporta sub-agentes ni routing
- Las reglas son un único fichero plano
- No soporta skills como ficheros separados

## Setup

1. Ejecutar `./sync.sh`
2. `.windsurfrules` se genera automáticamente
3. Windsurf lo lee en cada sesión
