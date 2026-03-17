# FEAT-XXX: [Nombre de la feature]

**Estado:** Propuesto | En Desarrollo | Completado
**Prioridad:** Alta | Media | Baja
**ADRs relacionados:**

## Contexto

Qué problema resuelve esta feature y por qué es necesaria.

## Criterios de Aceptación

- [ ] CA1:
- [ ] CA2:
- [ ] CA3:

## Diseño Técnico

### Endpoint / Componente

Método HTTP + ruta, o nombre del componente.

### Request / Input

Payload con tipos y validaciones. Límites (mínimo, máximo, formato).

### Response / Output

Respuesta esperada para cada caso: OK, cached, error.

### Errores

Cada código de error con su causa.

### Cache / Estado

Estrategia de cache (clave, TTL, invalidación) o gestión de estado.

### Seguridad

Validaciones de input, sanitización, permisos, rate limiting, datos sensibles.

### Schema / Base de Datos

Tablas nuevas o modificadas, índices necesarios, migración reversible (up/down), impacto en datos existentes.

## Agentes y Skills involucrados

### Agentes

| Agente | Responsabilidad en esta feature |
|---|---|
| @tdd-developer | Implementación con TDD |
| @database-engineer | Migración (si aplica) |
| @security-auditor | Revisión OWASP |
| @qa-engineer | Verificar coverage |
| @architect | Verificar contratos entre capas (si aplica) |

> Elimina los agentes que no apliquen a esta feature. Añade los que falten.

### Skills necesarios

| Skill | Para qué se necesita |
|---|---|
| `{stack-backend}` | Patrones de implementación del backend |
| `{stack-testing}` | Patrones de testing |
| `{otro-skill}` | ... |

> Consulta `.ai/skills/` para ver los skills disponibles en tu proyecto.

## Plan de Implementación

Pasos ordenados con el agente responsable de cada uno. Selecciona el flujo del orchestrator que mejor aplique (ver `.ai/agents/orchestrator.md`).

1. [ ] @database-engineer — Migración (si aplica)
2. [ ] @tdd-developer — Tests + implementación (RED-GREEN-REFACTOR)
3. [ ] @security-auditor — Revisión OWASP
4. [ ] @qa-engineer — Verificar coverage

## Testing

### Tests unitarios

Casos de test esperados para la lógica de negocio.

### Tests de integración

Flujos e2e que deben verificarse.

## Definition of Done

- [ ] Criterios de aceptación cumplidos
- [ ] Tests pasando (100% core, 80% features)
- [ ] Security audit (OWASP)
- [ ] Documentación actualizada
- [ ] Performance aceptable (si aplica)
