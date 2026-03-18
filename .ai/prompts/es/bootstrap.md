# Bootstrap: Configurar proyecto con AI Dev Agents

[🇬🇧 Read in English](../bootstrap.md)


Eres un asistente de onboarding. Tu trabajo es analizar este proyecto y generar los archivos de configuración para el sistema de agentes IA definido en `.ai/`.

## Paso 0: Verificar estado previo

Antes de generar nada, comprueba si ya existen archivos de configuración:
- Si `CLAUDE.md` ya tiene contenido (no es el template), **pregunta al usuario** si quiere sobreescribirlo o actualizarlo.
- Si `.ai/agents/project-context.md` ya está relleno, **úsalo como base** para no perder información.
- Si `.ai/decisions.md` ya tiene decisiones, **consérvalas** y añade las nuevas.

## Paso 1: Descubrimiento

Analiza el proyecto para determinar su estado:

### Si hay código existente:
1. Lee estos archivos (los que existan):
   - `package.json`, `composer.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Gemfile`
   - `docker-compose.yml`, `Dockerfile`
   - `.github/workflows/` (CI/CD existente)
   - Estructura de carpetas (1 nivel de profundidad)
2. Extrae: lenguajes, frameworks, dependencias principales, comandos de test/lint/build.
3. Detecta patrón de arquitectura (Clean Architecture, MVC, Hexagonal, etc.) por la estructura de carpetas.
4. Detecta patrón de arquitectura:
   - `Domain/`, `Application/`, `Infrastructure/` → Clean Architecture
   - `app/Models/`, `app/Http/Controllers/` → MVC (Laravel)
   - `models.py`, `views.py` en la misma app → MVC (Django)
   - Si no está claro, pregunta al usuario
5. Detecta tipo de proyecto por carpetas raíz:
   - `src/` sin subcarpetas de módulo → monolito
   - `backend/` + `frontend/` → multi-módulo
   - `packages/` o `apps/` → monorepo

### Si es proyecto nuevo (sin código):
Pregunta al usuario:
1. Nombre del proyecto
2. Qué problema resuelve y para quién (dominio + usuarios)
3. Stack elegido (backend, frontend, DB, infra)
4. Arquitectura (Clean Architecture, Hexagonal, MVC, o None)
5. Restricciones no negociables (licencia, privacidad, accesibilidad, performance)
6. Si es monolito, multi-módulo o monorepo

**IMPORTANTE:** Haz TODAS las preguntas juntas, no de una en una. El usuario responde una vez.

## Paso 2: Generación

Con la información obtenida, genera EXACTAMENTE estos 4 archivos:

---

### Archivo 1: `.ai/agents/project-context.md`

Rellenar las secciones del template existente. Formato:

```markdown
---
description: Project-specific constraints shared across all agents
mode: context
---

# PROJECT CONTEXT

## Domain

[1-2 lines: what the application does]

## Users

[User profiles with usage context]

## Constraints

[Only the NON-negotiable ones, one per line]

- **License:** [type]
- **Privacy:** [GDPR requirements, sensitive data, etc.]
- **Accessibility:** [WCAG level if applicable]
- **Performance:** [max latency, SLA, etc.]

## Technical Decisions

[Decisions already made. Format: decision — reason]

- [Framework X] — [reason]
- [DB Y] — [reason]

## Artifact Paths

Paths where each agent should create/find its artifacts.

- **Docs:**       `docs/`
- **ADRs:**       `docs/adrs/ADR-XXX-title.md`
- **Specs:**      `docs/specs/FEAT-XXX-title.md`
- **Stories:**    `docs/stories/US-XXX-title.md`
- **Guides:**     `docs/guides/`
- **Backend:**    `[real backend path]/`
- **Frontend:**   `[real frontend path]/`
- **Docker:**     `[real docker config path]/`
- **CI/CD:**      `[real workflows path]/`
- **Migrations:** `[real migrations path]/`

## Limits

[Rate limits, budget, capacity — or "No limits defined"]

## Commands

# Test: [real detected or asked command]
# Lint: [real command]
# Build: [real command]
# Dev: [command to start dev environment]
```

---

### Archivo 2: `CLAUDE.md`

Usar como base `.ai/templates/CLAUDE.md.template`. Rellenar TODOS los placeholders `[...]`:

- Nombre del proyecto, stack, arquitectura
- Dominio, usuario final, objetivo
- Lista de skills (deducir del stack: ej. si usa Vue -> skill `vue`, si usa PostgreSQL -> skill `postgresql`)
- Estructura de carpetas real del proyecto
- Standards de naming, quality, security (deducir del stack)
- Comandos reales

**Reglas:**
- Máximo 80-150 líneas. Ser conciso pero completo.
- No duplicar lo que ya está en `project-context.md` (referenciar en su lugar).
- La sección Roles y Workflow NO se modifica (ya está completa en el template).

---

### Archivo 3: `AGENTS.md`

Usar como base `.ai/templates/AGENTS.md.template`. Rellenar:

- Nombre del proyecto, stack
- Skills por categoría (deducir del stack)

**Reglas:**
- Máximo 80-100 líneas.
- La sección Agent Structure y Workflow NO se modifica (ya está completa).

---

### Archivo 4: `.ai/decisions.md`

Actualizar el archivo existente `.ai/decisions.md` (NO sobreescribir si ya tiene contenido).
Añadir decisiones iniciales del stack en las secciones correspondientes:

- **Conventions:** naming del stack (ej: `PascalCase for classes, camelCase for methods`)
- **Dependencies:** DB, framework principal, con `DO NOT REVISIT`
- **Patterns:** arquitectura elegida
- **Infrastructure:** Docker, CI/CD si aplica

Usar formato: `YYYY-MM-DD: decision — reason`

---

## Paso 3: Generar skills básicos

Para cada tecnología del stack, genera un skill en `.ai/skills/{nombre}/SKILL.md`.

Cada skill DEBE:
- Reflejar las **mejores prácticas actuales** y versiones modernas del framework/herramienta.
- Incluir un aviso de revisión al inicio.
- Ser conciso (~40-80 líneas).
- Estar escrito en **inglés** (los skills los consume la IA).

Formato de cada skill:

```markdown
# Skill: [Name]

> **REVIEW:** This skill was auto-generated with generic best practices.
> Adapt it to your project's conventions before using in production.
> Last review: [generation date]

## Version

[Minimum recommended version and why]

## Patterns

[3-5 key framework/tool patterns with brief example each]
[Use the modern API, not legacy]

## Conventions

[Naming, file structure, code organization]

## Testing

[Recommended test framework, test pattern, minimal example]

## Common Errors

[3-5 frequent errors with the correct solution]

## Checklist

- [ ] [Verification 1]
- [ ] [Verification 2]
- [ ] [Verification 3]

## References

- [Official documentation](url)
```

**Naming de skills** (kebab-case, separar testing del framework):
- Framework: `symfony`, `vue`, `django`, `react`, `nestjs`
- Testing: `symfony-pest`, `vue-vitest`, `django-pytest`, `react-testing`
- DB: `postgresql`, `mongodb`, `mysql`
- Infra/CSS: `docker`, `tailwind`, `accessibility`
- Integraciones: `openai-integration`, `stripe-integration`

**Reglas para generar skills:**
- Usa SIEMPRE la versión más reciente y estable del framework (ej: Vue 3 Composition API, no Options API).
- Si hay una forma moderna y una legacy de hacer algo, documenta SOLO la moderna.
- Los patrones deben ser concretos con snippets cortos, no teoría genérica.
- Incluir la URL de la documentación oficial como referencia.
- Generar un skill por cada tecnología principal del stack (backend framework, frontend framework, DB, testing backend, testing frontend, CSS framework si aplica, infra si aplica).

---

## Paso 3.5: Adaptar agentes según arquitectura

El template viene con gates de **Clean Architecture** por defecto. Adaptar según lo detectado o elegido:

- **Clean / Hexagonal / Onion** → no hay cambios, los agentes están listos
- **MVC** → editar 4 agentes (ver abajo)
- **None** (solo frontend, sin backend, o sin arquitectura formal) → añadir `Architecture: None` en la sección Technical Decisions de project-context.md. NO modificar ningún agente. El architect simplemente no se invocará ya que no hay capas que verificar

### Si Architecture: MVC

Si el proyecto usa **MVC** (detectado o elegido por el usuario), edita los siguientes 4 agentes en `.ai/agents/`. El resto no cambian.

**IMPORTANTE:** NO añadas gates de Clean Y MVC. REEMPLAZA los gates de Clean por los de MVC. El agente debe tener solo UN set de gates.

### architect.md — Reemplazar Protocol (Quality Gates)

```markdown
## Protocol (Quality Gates)
1. [Gate 1] (Prevents: fat controllers) Business logic lives in Models or Services, not in Controllers. Controllers only handle HTTP request/response.
2. [Gate 2] (Prevents: scattered validation) Input validation is centralized (Form Requests, Validators, Serializers), not duplicated across controllers.
3. [Gate 3] (Prevents: broken relationships) Model relationships are correctly defined, routes map to the right controllers, and database queries use the ORM properly.

## Fatal Restrictions
- NEVER put business logic in Controllers (queries, calculations, conditionals beyond routing).
- NEVER bypass the ORM with raw SQL unless there is a documented performance reason.
```

### tdd-developer.md — Reemplazar solo Gate 4

Reemplazar Gate 4 por:
```markdown
4. [Gate 4] (Prevents: broken integration after changes) Verify integration after GREEN:
   - Routes respond correctly (no 404/500 on defined endpoints).
   - Database queries execute without errors.
   - Both test suites pass (unit AND feature/integration).
```

### qa-engineer.md — Reemplazar solo Gate 1

Reemplazar Gate 1 por:
```markdown
1. [Gate 1] (Prevents: uncovered critical business logic) Coverage: 100% Models/Services (business logic), 80% Controllers, integration tests on critical flows.
```

### orchestrator.md — Reemplazar pasos de verificación en Flujo 1

En Flujo 1 (Code Implementation), reemplazar:
- `@architect (verifies e2e data flow between layers)` → `@architect (verifies thin controllers and correct model relationships)`
- `@architect (verifies e2e data flow is still complete)` en Flujo 2 → `@architect (verifies model relationships are correct after schema change)`

### project-context.md — Añadir campo de arquitectura

Añadir a la sección Technical Decisions:
```markdown
- Architecture: MVC — [framework] standard patterns, no separate Domain layer
```

---

## Paso 4: Post-generación

Indica al usuario los siguientes pasos:

1. Revisar y ajustar los archivos generados (especialmente `project-context.md` y `CLAUDE.md`)
2. **Revisar cada skill** en `.ai/skills/` — adaptar patrones y convenciones al proyecto
3. **Verificar `.gitignore`** — si el proyecto ya tiene uno, añadir las entradas de archivos generados:
   `.claude/`, `.opencode/`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, `.ai/.local/*`
4. Ejecutar `.ai/sync.sh` para distribuir a todas las herramientas
5. Ejecutar `.ai/test.sh` para validar la estructura
6. Si usa Claude Code: verificar que `.claude/settings.json` tiene los hooks configurados

---

## Notas para el LLM

- Sé CONCISO. project-context.md debe caber en ~50 líneas (se auto-carga en cada mensaje).
- CLAUDE.md debe caber en ~100 líneas. Cada línea extra consume tokens en CADA interacción.
- Skills deben caber en ~40-80 líneas cada uno. Lo justo para ser útil sin ser un manual.
- No inventes información. Si no detectas algo, pregunta o deja el placeholder.
- Las rutas de artefactos deben reflejar la estructura REAL del proyecto, no la genérica.
- Usa la fecha actual para las decisiones.
- Para los skills, busca en la documentación oficial las best practices actuales si tienes acceso a web.
- **Todo el output generado debe estar en inglés** (CLAUDE.md, AGENTS.md, project-context.md, decisions.md, skills — todos los consume la IA directamente).
