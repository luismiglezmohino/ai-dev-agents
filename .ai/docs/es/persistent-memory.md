# Memoria persistente entre sesiones

[🇬🇧 Read in English](../persistent-memory.md)

> Volver al [README](../../README.es.md)

## Memoria persistente entre sesiones

Los agentes son efímeros, pero el conocimiento del proyecto debe persistir. Tres mecanismos complementarios:

### 1. `.claude/rules/` (siempre cargado, 0 esfuerzo)

`sync.sh` copia `decisions.md` y `project-context.md` a `.claude/rules/`. Claude Code los carga automáticamente en cada mensaje. Coste: ~50 líneas por mensaje. Beneficio: la IA siempre tiene contexto del proyecto sin que nadie lo pida.

### 2. Feature Specs (`docs/specs/FEAT-XXX.md`) — opcional

Especificaciones técnicas antes de implementar. El sistema de agentes funciona sin specs, pero una spec aporta valor en situaciones específicas:

| Situación | Sin spec | Con spec | Recomendación |
|---|---|---|---|
| Claude Code/OpenCode + agentes | Funciona bien (los agentes tienen gates) | Mejor organizado | Opcional |
| Feature compleja (5+ endpoints) | El contexto se puede perder en sesiones largas | La spec ancla las decisiones | Recomendado |
| Cursor/Windsurf/Gemini/Copilot | Cada prompt repite parcialmente el contexto | La spec centraliza | Casi esencial |
| Equipo (múltiples devs o sesiones) | Cada sesión interpreta diferente | La spec alinea a todos | Recomendado |
| Feature con seguridad/privacidad | Podría olvidar un vector de ataque | Fuerza a pensar de antemano | Recomendado |

**Regla simple:** Si puedes explicar la feature en 2 frases y afecta 1-2 ficheros, no necesitas spec. Si necesitas pensar antes de codear, hazla.

Para generar una spec, usa el prompt `.ai/prompts/feature-spec.md`. Cada agente extrae lo que necesita:

| Agente | Qué extrae de la spec |
|---|---|
| @tdd-developer | Endpoints, payloads, errores → tests |
| @security-auditor | Inputs, rate limits → validaciones |
| @architect | Capas, contratos → verificación |
| @database-engineer | Schema, índices → migraciones |

Template en `.ai/templates/FEAT-TEMPLATE.md`.

#### Documentación en cada PR

La documentación se incluye en el mismo PR que el código, no en PRs separados:

| Aspecto | Docs en mismo PR | Docs en PR separado |
|---|---|---|
| Contexto | El agente ya tiene el código cargado | Debe recargar contexto |
| Coherencia | Los docs reflejan el código exacto | Riesgo de desincronización |
| Revisión | Una revisión cubre código + docs | Dos revisiones, doble coste |
| Tokens | 0 extra (mismo contexto) | Sesión completa adicional |

El `devops.md` Gate 5 incluye: "PR includes updated documentation (README, ADR if applicable, CHANGELOG)".

### 3. Hooks + Engram MCP (memoria automática, Claude Code)

Para Claude Code, los hooks automatizan la gestión de memoria sin esfuerzo de la IA:

```
┌─────────────────────────────────────────────────────┐
│ Capa 1: .claude/rules/ (AUTO-CARGADO, siempre)       │
│ → decisions.md, project-context.md                   │
│ → 0 esfuerzo, 0 olvidados                           │
├─────────────────────────────────────────────────────┤
│ Capa 2: Hooks (AUTOMÁTICO, por eventos)              │
│ → SessionStart: inyecta último contexto              │
│ → PreCompact: guarda estado antes de perder contexto │
│ → SessionEnd: guarda resumen de sesión               │
├─────────────────────────────────────────────────────┤
│ Capa 3: Engram MCP (BAJO DEMANDA)                    │
│ → mem_search, mem_save, mem_context                  │
│ → Solo cuando la IA necesita más contexto            │
└─────────────────────────────────────────────────────┘
```

[Engram](https://github.com/Gentleman-Programming/engram) es un binario en Go con SQLite + FTS5 que proporciona memoria persistente vía MCP. Multi-herramienta (Claude Code, OpenCode, Cursor, Windsurf, Gemini CLI). Local y privado.

**Sin Engram:** Los hooks guardan en ficheros locales (`.ai/.local/`) como fallback.
**Con Engram:** Búsqueda full-text, deduplicación, multi-proyecto.

### Memoria por herramienta

| Herramienta | Memoria automática | Memoria de proyecto | Nivel |
|---|---|---|---|
| Claude Code | `.claude/rules/` + Hooks + Engram MCP | Feature Specs + decisions.md | Ideal |
| OpenCode | `AGENTS.md` + Engram MCP | Feature Specs + decisions.md | Aceptable |
| Cursor/Windsurf | reglas compactas + Engram MCP (si lo soporta) | Feature Specs + decisions.md | Limitado |
| Gemini | `GEMINI.md` + Engram MCP (si lo soporta) | Feature Specs + decisions.md | Limitado |
| Copilot | copilot-instructions.md | Feature Specs + decisions.md | Mínimo |

## project-context.md

Fichero en `.ai/agents/` que contiene las restricciones específicas del proyecto. Todos los agentes lo leen pero no es invocable (mode: context). Se copia automáticamente a `.claude/rules/` para ser auto-cargado.

Incluye la sección "Artifact Paths" para que los agentes sepan dónde crear sus documentos (docs, ADRs, specs, stories, etc.).

Rellénalo con: dominio, usuarios, restricciones no negociables, decisiones técnicas, límites de APIs, comandos de test.
