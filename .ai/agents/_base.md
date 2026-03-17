---
description: Shared agent structure (not invocable)
mode: base
---

# Base Agent Structure

Sections inherited by all subagents. Do not invoke this file directly.

## Consultar Skills

Para patrones específicos del framework, consultar el skill correspondiente
en `.ai/skills/{nombre}/SKILL.md` antes de implementar.

## Where You Operate (Permisos)

Cada agente define donde puede actuar. Respetar siempre estos límites:

| Permiso | Significado |
|---|---|
| **Can write** | El agente puede crear y modificar ficheros en estas rutas |
| **Read only** | El agente puede leer pero NO modificar |
| **Cannot touch** | El agente NO debe leer ni modificar estas rutas |

> Si un agente no define su sección "Where You Operate", hereda los permisos de sus `tools` en el frontmatter.

## Branch Strategy

Los agentes respetan la estrategia de ramas del proyecto:

| Branch | Agentes |
|---|---|
| `main` | No pueden mergear ni commitear directamente |
| `staging` | Pueden abrir PRs |
| `feature/*` | Pueden commitear |

> Si un agente la lia, solo afecta a una feature branch, nunca a producción.

## Lección aprendida → Regla

Cada Restricción Fatal y Quality Gate existe porque su ausencia causó un problema real. Cuando documentes una nueva restricción, usa este formato:

```
**Restricción:** [qué no hacer]
**Origen:** [qué pasó cuando se hizo]
**Impacto:** [consecuencia real del error]
```

Las restricciones no son burocracia. Son lecciones aprendidas convertidas en reglas.

## Verificación Continua (opcional)

Por defecto, la verificación se hace al final (checkpoint). Para features críticas, se puede activar verificación continua:

- **Checkpoint (por defecto):** verificar Quality Gates al terminar. Bajo consumo de tokens.
- **Continua (opcional):** autoevaluar en cada paso intermedio. 3-5x más tokens pero detecta errores antes.

Usar verificación continua solo cuando:
- La feature toca múltiples capas simultáneamente
- Hay riesgo de seguridad alto
- El contexto es muy grande y se puede perder información

Para activarla, indicar al agente: "Usa verificación continua para esta tarea."

## Verificación Final

Antes de reportar como completado, verificar:
- [ ] Todos los Quality Gates de este agente se cumplen
- [ ] Ninguna Restricción Fatal se ha violado
- [ ] Si hay skills relevantes, se han consultado
