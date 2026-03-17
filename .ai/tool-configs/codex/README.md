# Codex (OpenAI)

## Cómo funciona

Codex lee instrucciones desde `AGENTS.md` en la raíz del proyecto (igual que OpenCode). También soporta un directorio `.codex/` para configuración adicional.

`sync.sh` ya genera `AGENTS.md` que Codex puede leer directamente.

## Ficheros que usa

| Fichero | Propósito |
|---|---|
| `AGENTS.md` | Instrucciones principales (compartido con OpenCode) |
| `.codex/` | Configuración adicional de Codex (opcional) |

## Limitaciones

- Soporta agentes como contexto pero no como entidades invocables por separado
- No soporta sub-agentes nativos
- No soporta model routing por agente
- Skills se leen como ficheros de contexto, no como módulos invocables

## Setup

1. Ejecutar `.ai/sync.sh`
2. `AGENTS.md` se genera automáticamente en la raíz
3. Codex lo lee al iniciar sesión
4. Opcionalmente, crear `.codex/` con configuración específica

## MCPs en Codex

Codex soporta MCPs. Configurar en `.codex/config.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

## Compatibilidad con el template

| Capacidad | Soportado |
|---|---|
| Agentes como contexto | Sí (via AGENTS.md) |
| Agentes invocables | No |
| Skills como contexto | Sí (referenciados en AGENTS.md) |
| Verificación cruzada | Manual (el usuario invoca los agentes de revisión) |
| Hooks de memoria | No |
| MCPs | Sí |
