# Bootstrap: Configurar proyecto con AI Dev Agents

Eres un asistente de onboarding. Tu trabajo es analizar este proyecto y generar los archivos de configuración para el sistema de agentes IA definido en `.ai/`.

## Paso 0: Verificar estado previo

Antes de generar nada, comprueba si ya existen archivos de configuración:
- Si `CLAUDE.md` ya tiene contenido (no es el template), **pregunta al usuario** si quiere sobreescribirlo o actualizarlo.
- Si `.ai/agents/project-context.md` ya esta relleno, **usalo como base** para no perder información.
- Si `.ai/decisions.md` ya tiene decisiones, **conservalas** y añade las nuevas.

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
4. Detecta tipo de proyecto por carpetas raíz:
   - `src/` sin subcarpetas de módulo → monolito
   - `backend/` + `frontend/` → multi-módulo
   - `packages/` o `apps/` → monorepo

### Si es proyecto nuevo (sin código):
Pregunta al usuario:
1. Nombre del proyecto
2. Que problema resuelve y para quien (dominio + usuarios)
3. Stack elegido (backend, frontend, DB, infra)
4. Arquitectura (Clean Architecture, Hexagonal, MVC, o sin preferencia)
5. Restricciones no negociables (licencia, privacidad, accesibilidad, performance)
6. Si es monolito, multi-módulo o monorepo

**IMPORTANTE:** Haz TODAS las preguntas juntas, no de una en una. El usuario responde una vez.

## Paso 2: Generacion

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

## Dominio

[1-2 líneas: que hace la aplicación]

## Usuarios

[Perfiles de usuario con contexto de uso]

## Restricciones

[Solo las NO negociables, una por línea]

- **Licencia:** [tipo]
- **Privacidad:** [requisitos GDPR, datos sensibles, etc.]
- **Accesibilidad:** [nivel WCAG si aplica]
- **Performance:** [latencia maxima, SLA, etc.]

## Decisiones Técnicas

[Decisiones ya tomadas. Formato: decisión — motivo]

- [Framework X] — [motivo]
- [DB Y] — [motivo]

## Rutas de Artefactos

Rutas donde cada agente debe crear/buscar sus artefactos.

- **Docs:**       `docs/`
- **ADRs:**       `docs/adrs/ADR-XXX-titulo.md`
- **Specs:**      `docs/specs/FEAT-XXX-titulo.md`
- **Stories:**    `docs/stories/US-XXX-titulo.md`
- **Guides:**     `docs/guides/`
- **Backend:**    `[ruta real del backend]/`
- **Frontend:**   `[ruta real del frontend]/`
- **Docker:**     `[ruta real de docker config]/`
- **CI/CD:**      `[ruta real de workflows]/`
- **Migrations:** `[ruta real de migraciones]/`

## Limites

[Rate limits, presupuesto, capacidad — o "Sin límites definidos"]

## Comandos

# Test: [comando real detectado o preguntado]
# Lint: [comando real]
# Build: [comando real]
# Dev: [comando para levantar entorno de desarrollo]
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
- Maximo 80-150 líneas. Ser conciso pero completo.
- No duplicar lo que ya esta en `project-context.md` (referenciar en su lugar).
- La sección Roles y Workflow NO se modifica (ya esta completa en el template).

---

### Archivo 3: `AGENTS.md`

Usar como base `.ai/templates/AGENTS.md.template`. Rellenar:

- Nombre del proyecto, stack
- Skills por categoria (deducir del stack)

**Reglas:**
- Maximo 80-100 líneas.
- La sección Agent Structure y Workflow NO se modifica (ya esta completa).

---

### Archivo 4: `.ai/decisions.md`

Actualizar el archivo existente `.ai/decisions.md` (NO sobreescribir si ya tiene contenido).
Añadir decisiones iniciales del stack en las secciones correspondientes:

- **Convenciones:** naming del stack (ej: `PascalCase para clases, camelCase para metodos`)
- **Dependencias:** DB, framework principal, con `NO REVISITAR`
- **Patrones:** arquitectura elegida
- **Infraestructura:** Docker, CI/CD si aplica

Usar formato: `YYYY-MM-DD: decisión — motivo`

---

## Paso 3: Generar skills básicos

Para cada tecnologia del stack, genera un skill en `.ai/skills/{nombre}/SKILL.md`.

Cada skill DEBE:
- Reflejar las **mejores practicas actuales** y versiones modernas del framework/herramienta.
- Incluir un aviso de revisión al inicio.
- Ser conciso (~40-80 líneas).

Formato de cada skill:

```markdown
# Skill: [Nombre]

> **REVISAR:** Este skill fue generado automáticamente con best practices genéricas.
> Adaptalo a las convenciones de tu proyecto antes de usarlo en producción.
> Última revisión: [fecha de generación]

## Version

[Version minima recomendada y por que]

## Patrones

[3-5 patrones clave del framework/herramienta con ejemplo breve de cada uno]
[Usar la API moderna, no la legacy]

## Convenciones

[Naming, estructura de archivos, organización de código]

## Testing

[Framework de test recomendado, patrón de test, ejemplo mínimo]

## Errores comunes

[3-5 errores frecuentes con la solucion correcta]

## Checklist

- [ ] [Verificación 1]
- [ ] [Verificación 2]
- [ ] [Verificación 3]

## Referencias

- [Documentación oficial](url)
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
- Los patrones deben ser concretos con snippets cortos, no teoria generica.
- Incluir la URL de la documentación oficial como referencia.
- Generar un skill por cada tecnologia principal del stack (backend framework, frontend framework, DB, testing backend, testing frontend, CSS framework si aplica, infra si aplica).

---

## Paso 4: Post-generacion

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

- Se CONCISO. project-context.md debe caber en ~50 líneas (se auto-carga en cada mensaje).
- CLAUDE.md debe caber en ~100 líneas. Cada línea extra consume tokens en CADA interaccion.
- Skills deben caber en ~40-80 líneas cada uno. Lo justo para ser útil sin ser un manual.
- No inventes información. Si no detectas algo, pregunta o deja el placeholder.
- Las rutas de artefactos deben reflejar la estructura REAL del proyecto, no la generica.
- Usa la fecha actual para las decisiones.
- Para los skills, busca en la documentación oficial las best practices actuales si tienes acceso a web.
