# Skills

Crea un directorio por cada skill de tu stack.

## Estructura

```
skills/
  {nombre-skill}/
    SKILL.md          # Documentación del skill
```

## Estructura obligatoria de un SKILL.md

```markdown
---
name: nombre-skill
description: Descripción breve
license: MIT
compatibility: opencode
metadata:
  type: backend|frontend|testing|orm|infra
  framework: nombre
  language: lenguaje
---

# SKILL: Nombre

## Tech Stack
Versiones y dependencias del framework/libreria.

## Patrones del Proyecto
Snippets reales del proyecto: como se usa el framework, convenciones, estructura.

## Errores Conocidos y Soluciones
Problemas encontrados durante el desarrollo y como resolverlos.
Esta sección es OBLIGATORIA. Si no hay errores conocidos todavía, dejar:
- "Sin errores documentados todavía."

Formato por error:
- **Problema:** Descripción del error
- **Causa:** Por que ocurre
- **Solucion:** Como resolverlo

## Checklist
Lista de verificación para nuevas implementaciones con este skill.
```

## Principio

Los skills contienen el conocimiento **específico del framework/lenguaje**.
Los agentes contienen las reglas **agnosticas** (Quality Gates).

Los agentes dicen QUE verificar. Los skills dicen COMO hacerlo.

## Ejemplos por stack

### Backend + Frontend

| Stack | Skills sugeridos |
|---|---|
| Django + React | `django`, `django-pytest`, `react`, `react-testing`, `postgresql` |
| Spring + Angular | `spring-boot`, `spring-junit`, `angular`, `angular-jasmine`, `postgresql` |
| Node + Vue | `express`, `express-jest`, `vue`, `vue-vitest`, `postgresql` |
| Symfony + Vue | `symfony`, `symfony-pest`, `vue`, `vue-vitest`, `postgresql` |
| Laravel + React | `laravel`, `laravel-pest`, `react`, `react-testing`, `postgresql` |

### Transversales (recomendados en todo proyecto)

| Skill | Proposito |
|---|---|
| `docker` | Multi-stage builds, docker-compose, seguridad |
| `ci-cd` | GitHub Actions, pipelines, deploy |
| `accessibility` | WCAG 2.2 AA, navegación teclado, contraste |
| `observability` | Logging JSON, métricas, health checks |
| `typescript` | TypeScript strict, Zod, ESLint |
| `git` | Conventional commits, branch naming, PRs, GitHub Flow |
