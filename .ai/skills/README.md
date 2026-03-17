# Skills

Create a directory for each skill in your stack.

## Structure

```
skills/
  {skill-name}/
    SKILL.md          # Skill documentation
```

## Required SKILL.md Structure

```markdown
---
name: skill-name
description: Brief description
license: MIT
compatibility: opencode
metadata:
  type: backend|frontend|testing|orm|infra
  framework: name
  language: language
---

# SKILL: Name

## Tech Stack
Framework/library versions and dependencies.

## Project Patterns
Real project snippets: how the framework is used, conventions, structure.

## Known Errors and Solutions
Problems found during development and how to solve them.
This section is MANDATORY. If there are no known errors yet, leave:
- "No documented errors yet."

Format per error:
- **Problem:** Error description
- **Cause:** Why it happens
- **Solution:** How to fix it

## Checklist
Verification list for new implementations with this skill.
```

## Principle

Skills contain **framework/language-specific** knowledge.
Agents contain the **agnostic** rules (Quality Gates).

Agents say WHAT to verify. Skills say HOW to do it.

## Stack Examples

### Backend + Frontend

| Stack | Suggested Skills |
|---|---|
| Django + React | `django`, `django-pytest`, `react`, `react-testing`, `postgresql` |
| Spring + Angular | `spring-boot`, `spring-junit`, `angular`, `angular-jasmine`, `postgresql` |
| Node + Vue | `express`, `express-jest`, `vue`, `vue-vitest`, `postgresql` |
| Symfony + Vue | `symfony`, `symfony-pest`, `vue`, `vue-vitest`, `postgresql` |
| Laravel + React | `laravel`, `laravel-pest`, `react`, `react-testing`, `postgresql` |

### Cross-cutting (recommended for every project)

| Skill | Purpose |
|---|---|
| `docker` | Multi-stage builds, docker-compose, security |
| `ci-cd` | GitHub Actions, pipelines, deploy |
| `accessibility` | WCAG 2.2 AA, keyboard navigation, contrast |
| `observability` | JSON logging, metrics, health checks |
| `typescript` | TypeScript strict, Zod, ESLint |
| `git` | Conventional commits, branch naming, PRs, GitHub Flow |
