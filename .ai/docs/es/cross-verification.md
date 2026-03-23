# Verificación cruzada

[🇬🇧 Read in English](../cross-verification.md)

> Volver al [README](../../README.es.md)

## Orquestador y verificación cruzada

El `orchestrator.md` es el agente principal (mode: `primary`) que:
1. **Routing**: analiza la intención del usuario y redirige al agente correcto
2. **Verificación cruzada**: después de la implementación, coordina rondas de revisión entre agentes

### El problema que resuelve

Sin verificación cruzada, cada agente trabaja aislado. El @tdd-developer puede escribir tests que pasan pero el @architect no verifica que los datos fluyan correctamente entre capas. El resultado: bugs que ningún agente individual detecta.

### Patrón de verificación cruzada

```
@tdd-developer (implementa)
       |
       v
@architect (verifica flujo e2e de datos entre capas)
       |
   ¿Problemas? --Sí--> @tdd-developer (corrige) --> vuelve a @architect
       |
       No
       v
@security-auditor (revisa OWASP)
       |
   ¿Problemas? --Sí--> @tdd-developer (corrige) --> vuelve a @security-auditor
       |
       No
       v
Listo para commit
```

### Cuándo aplicarlo
- Se modifican contratos (interfaces) entre capas
- Se añade un nuevo endpoint o servicio
- Se modifica la capa de Infrastructure (DI, persistencia)

### Cuándo NO aplicarlo
- Correcciones aisladas dentro de una sola capa
- Cambios de documentación
- Refactors que no alteran contratos

### Comportamiento por herramienta

| Herramienta | Quién ejecuta el patrón |
|---|---|
| OpenCode | `orchestrator.md` (agente principal, ejecuta automáticamente) |
| Claude Code | La sesión principal (lee el Workflow en CLAUDE.md) + los gates de cada agente |
| Agent Teams (experimental) | Los teammates se comunican directamente entre sí |

**Nota sobre Claude Code:** no usa `orchestrator.md` (hace routing automático). El patrón de verificación cruzada se implementa a través de los Quality Gates de cada agente (ej.: @tdd-developer Gate 4 dice "verificar que DI compila y ambas suites pasan") y el Workflow en `CLAUDE.md`. `sync.sh` excluye al orquestador al generar `.claude/agents/`.

**Nota sobre Agent Teams:** Claude Code tiene una funcionalidad experimental ([agent teams](https://code.claude.com/docs/en/agent-teams)) donde múltiples instancias se comunican directamente entre sí. Con agent teams, la verificación cruzada sería nativa: el teammate @architect enviaría un mensaje al teammate @tdd-developer sin intermediario. Los agentes de este template son compatibles con agent teams (cada teammate carga su `agents/*.md` automáticamente).

## Dónde implementar la verificación cruzada

La verificación cruzada se puede implementar de 3 formas. No son mutuamente excluyentes, pero **no dupliques**:

### Opción 1: En los Quality Gates de cada agente (recomendado)

Los gates de cada agente ya incluyen verificaciones que fuerzan la coordinación:

```markdown
# tdd-developer.md - Gate 4
Verify integration after GREEN:
  - The dependency container compiles without errors
  - Both test suites pass (Unit + Functional)

# architect.md - Gate 3
Verify e2e data flow between layers:
  - Contracts define ALL necessary parameters
  - Data flows completely between layers without loss
```

**Ventaja:** La verificación está integrada en el agente. No necesita coordinación externa.
**Coste en tokens:** 0 extra (los gates ya se cargan con el agente).
**Compatible con:** Todas las herramientas.

### Opción 2: En el orquestador (OpenCode)

`orchestrator.md` ejecuta el flujo secuencial automáticamente. Útil cuando la herramienta tiene un agente principal que coordina a otros.

**Ventaja:** Flujo explícito, el orquestador decide cuándo lanzar cada verificación.
**Coste en tokens:** Bajo (el orquestador se carga una vez).
**Compatible con:** OpenCode y herramientas con agente principal.

### Opción 3: Agent Teams (Claude Code experimental)

Los teammates se envían mensajes directamente entre sí. La verificación es nativa y paralela.

```
@architect → mensaje a @tdd-developer: "the DTO needs the label field"
@tdd-developer → mensaje a @architect: "added, review the contract"
@security-auditor → mensaje a ambos: "sanitize the label against injection"
```

**Ventaja:** Debate paralelo real, sin intermediario.
**Coste en tokens:** Alto (cada teammate es una instancia completa).
**Compatible con:** Solo Claude Code (experimental, requiere `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### Qué NO hacer

- **No dupliques** el patrón en CLAUDE.md si ya está en los gates de los agentes. CLAUDE.md se carga en cada mensaje y duplicar la verificación desperdicia tokens sin beneficio.
- **No actives agent teams por defecto.** Úsalo ocasionalmente para features complejas que tocan múltiples capas simultáneamente (frontend + backend + tests).
- **No añadas verificación cruzada a todo.** Solo aplica cuando se modifican contratos entre capas, se añaden endpoints o se toca Infrastructure. Una corrección simple no lo necesita.

### Resumen

| Estrategia | Tokens | Paralelismo | Complejidad | Cuándo usarlo |
|---|---|---|---|---|
| Gates en agentes | 0 extra | No (secuencial) | Baja | Siempre (base) |
| Orquestador | Bajo | No (secuencial) | Media | OpenCode / herramientas con agente principal |
| Agent Teams | Alto | Sí (real) | Alta | Features complejas multi-capa, ocasionalmente |

Empieza con gates (opción 1). Si necesitas coordinación explícita en OpenCode, usa el orquestador (opción 2). Si una feature toca muchas capas y necesitas debate real, prueba agent teams (opción 3).
