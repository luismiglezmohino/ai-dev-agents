# Contributing

[🇪🇸 Leer en español](#contribuir)

Thanks for your interest in contributing to AI Dev Agents!

## How to Contribute

1. **Fork** the repository
2. **Create a branch** from `main`: `git checkout -b feature/your-change`
3. **Make your changes** following the conventions below
4. **Run validation**: `.ai/test.sh`
5. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, etc.
6. **Open a PR** with a clear description of what and why

## Language Conventions

This project uses a bilingual structure to optimize AI token usage:

| File type | Language | Why |
|---|---|---|
| Agents, skills, decisions, templates, hooks | **English only** | Consumed by AI — ~20-30% fewer tokens |
| Prompts | **Bilingual** (EN in `prompts/`, ES in `prompts/es/`) | User-facing |
| README, guides | **Bilingual** (EN primary, ES in `es/` or `.es.md`) | User-facing |
| Docs output (specs, ADRs) | **User's choice** | Project-specific |

**Rule:** If the AI reads it, write it in English. If the user reads it, provide both languages.

## What to Contribute

| Area | Examples |
|---|---|
| **Agents** | Improve Quality Gates, add conditional gates, fix edge cases |
| **Skills** | Improve `git` skill, contribute refined skills as reference examples |
| **Prompts** | Improve existing prompts or add new ones (both languages) |
| **Guides** | Add guides for new tools or workflows (both languages) |
| **sync.sh / test.sh** | Bug fixes, new validations, new tool support |
| **Documentation** | Fix errors, clarify sections, improve examples |

## Conventions

- **Agents are agnostic** — they define WHAT to verify, not HOW. Framework-specific knowledge goes in skills
- **Keep files concise** — agents ~50-70 lines, skills ~40-80 lines, CLAUDE.md < 120 lines
- **Quality Gates must be justified** — every gate exists because its absence caused a real problem. Use the "Lesson Learned → Rule" format from `_base.md`
- **Conventional Commits** — `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- **Test before submitting** — run `.ai/test.sh` and `.ai/sync.sh` to verify nothing breaks

## About Skills

The template only ships `git` as a built-in skill. Stack-specific skills (Django, Vue, Symfony, etc.) are **not included** because:

- They go outdated fast (versions, deprecated APIs, new patterns)
- The `bootstrap.md` prompt already generates personalized skills for the user's stack with current best practices
- The `refine-skills.md` prompt improves them with real project patterns after 2-3 features

Skills are loaded on demand — unused skills consume **0 tokens**. But shipping outdated skills would mislead the AI into using deprecated patterns, which is worse than having no skill at all.

**How to contribute to skills:** improve the `git` skill or improve the bootstrap/refine-skills prompts so they generate better skills.

## Adding a New Agent

This is rarely needed — the 11 existing agents cover most development workflows. If you think a new agent is needed, open an issue first to discuss.

## Questions?

Open an issue. We'll respond as quickly as possible.

---

# Contribuir

Gracias por tu interés en contribuir a AI Dev Agents.

## Cómo Contribuir

1. **Fork** del repositorio
2. **Crea una rama** desde `main`: `git checkout -b feature/tu-cambio`
3. **Haz tus cambios** siguiendo las convenciones de abajo
4. **Ejecuta la validación**: `.ai/test.sh`
5. **Commit** usando [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, etc.
6. **Abre una PR** con una descripción clara de qué y por qué

## Convenciones de Idioma

Este proyecto usa una estructura bilingüe para optimizar el uso de tokens de la IA:

| Tipo de fichero | Idioma | Por qué |
|---|---|---|
| Agentes, skills, decisions, templates, hooks | **Solo inglés** | Los consume la IA — ~20-30% menos tokens |
| Prompts | **Bilingüe** (EN en `prompts/`, ES en `prompts/es/`) | Los lee el usuario |
| README, guías | **Bilingüe** (EN primario, ES en `es/` o `.es.md`) | Los lee el usuario |
| Output de docs (specs, ADRs) | **A elección del usuario** | Específico del proyecto |

**Regla:** Si lo lee la IA, en inglés. Si lo lee el usuario, en ambos idiomas.

## Qué Contribuir

| Área | Ejemplos |
|---|---|
| **Agentes** | Mejorar Quality Gates, añadir conditional gates, corregir edge cases |
| **Skills** | Mejorar skill `git`, contribuir skills refinados como ejemplos de referencia |
| **Prompts** | Mejorar prompts existentes o añadir nuevos (ambos idiomas) |
| **Guías** | Añadir guías para nuevas herramientas o workflows (ambos idiomas) |
| **sync.sh / test.sh** | Bug fixes, nuevas validaciones, soporte de nuevas herramientas |
| **Documentación** | Corregir errores, clarificar secciones, mejorar ejemplos |

## Convenciones

- **Los agentes son agnósticos** — definen QUÉ verificar, no CÓMO. El conocimiento específico del framework va en skills
- **Ficheros concisos** — agentes ~50-70 líneas, skills ~40-80 líneas, CLAUDE.md < 120 líneas
- **Quality Gates justificados** — cada gate existe porque su ausencia causó un problema real. Usa el formato "Lesson Learned → Rule" de `_base.md`
- **Conventional Commits** — `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- **Testea antes de enviar** — ejecuta `.ai/test.sh` y `.ai/sync.sh` para verificar que nada se rompe

## Sobre los Skills

El template solo incluye `git` como skill integrado. Los skills específicos de stack (Django, Vue, Symfony, etc.) **no se incluyen** porque:

- Se quedan obsoletos rápido (versiones, APIs deprecated, nuevos patrones)
- El prompt `bootstrap.md` ya genera skills personalizados para el stack del usuario con best practices actuales
- El prompt `refine-skills.md` los mejora con patrones reales del proyecto después de 2-3 features

Los skills se cargan bajo demanda — los no usados consumen **0 tokens**. Pero incluir skills desactualizados induciría a la IA a usar patrones deprecated, que es peor que no tener skill.

**Cómo contribuir a skills:** mejorar el skill `git` o mejorar los prompts bootstrap/refine-skills para que generen mejores skills.

## Añadir un Nuevo Agente

Esto rara vez es necesario — los 11 agentes existentes cubren la mayoría de flujos de desarrollo. Si crees que hace falta uno nuevo, abre un issue primero para discutirlo.

## ¿Preguntas?

Abre un issue. Responderemos lo antes posible.
