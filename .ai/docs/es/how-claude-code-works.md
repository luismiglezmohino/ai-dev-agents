# Cómo funciona Claude Code (y por qué importa para los agentes)

[🇬🇧 Read in English](../how-claude-code-works.md)

> Volver al [README](../../README.es.md)

Claude Code es un agente que se ejecuta en tu terminal. Funciona en un bucle de 3 fases:

```
Tu prompt → Recopilar contexto → Actuar → Verificar → Repetir hasta completar
                   ↑                                     |
                   └──── Puedes interrumpir en cualquier momento
```

## A qué tiene acceso

| Recurso | Descripción |
|----------|-------------|
| Tu proyecto | Ficheros, estructura, dependencias |
| Terminal | Cualquier comando (git, npm, docker, etc.) |
| CLAUDE.md | Instrucciones persistentes (se cargan en CADA mensaje) |
| .ai/agents/*.md | Agentes bajo demanda (se cargan solo cuando se invoca el rol) |
| .ai/skills/*.md | Skills bajo demanda (se cargan solo cuando se consultan) |
| MCP servers | Herramientas externas (BD, docs, error tracking, etc.) |

## Gestión de contexto

La ventana de contexto se llena con: historial de conversación, ficheros leídos, salidas de comandos, CLAUDE.md, skills cargadas y definiciones de herramientas MCP.

```
Siempre en contexto (cada mensaje):
  ├── CLAUDE.md                    → MANTENER < 120 líneas
  ├── Definiciones de herramientas MCP → Cada MCP añade sus herramientas
  └── Historial de conversación    → Auto-compactado

Bajo demanda (solo cuando se usa):
  ├── .ai/agents/*.md              → Se carga cuando se invoca el rol
  ├── .ai/skills/*.md              → Se carga cuando se consulta
  └── Subagentes                   → Contexto separado (no inflan el tuyo)
```

**Comandos útiles:**
- `/context` - Ver qué está ocupando espacio en la ventana de contexto
- `/compact` - Compactar manualmente (ej.: `/compact focus on the API changes`)
- `/mcp` - Ver estado y coste en tokens de cada servidor MCP

**Implicación para este template:** Por eso CLAUDE.md debe ser compacto (~100 líneas). Los detalles van en `.ai/agents/` y `.ai/skills/` que solo se cargan cuando se necesitan. Si duplicas contenido de agentes en CLAUDE.md, desperdicias tokens en cada mensaje.
