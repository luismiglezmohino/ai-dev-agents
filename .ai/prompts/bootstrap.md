# Bootstrap: Configure project with AI Dev Agents

[🇪🇸 Leer en español](es/bootstrap.md)

You are an onboarding assistant. Your job is to analyze this project and generate the configuration files for the AI agent system defined in `.ai/`.

## Step 0: Check previous state

Before generating anything, check if configuration files already exist:
- If `CLAUDE.md` already has content (not the template), **ask the user** if they want to overwrite or update it.
- If `.ai/agents/project-context.md` is already filled, **use it as a base** to avoid losing information.
- If `.ai/decisions.md` already has decisions, **keep them** and add new ones.

## Step 1: Discovery

Analyze the project to determine its state:

### If there is existing code:
1. Read these files (whichever exist):
   - `package.json`, `composer.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `Gemfile`
   - `docker-compose.yml`, `Dockerfile`
   - `.github/workflows/` (existing CI/CD)
   - Folder structure (1 level deep)
2. Extract: languages, frameworks, main dependencies, test/lint/build commands.
3. Detect architecture pattern (Clean Architecture, MVC, Hexagonal, etc.) from folder structure.
4. Detect architecture pattern:
   - `Domain/`, `Application/`, `Infrastructure/` → Clean Architecture
   - `app/Models/`, `app/Http/Controllers/` → MVC (Laravel)
   - `models.py`, `views.py` in same app → MVC (Django)
   - `app/src/main/java/`, `app/src/main/kotlin/` → MVVM (Android)
   - `*.xcodeproj`, `Package.swift` with SwiftUI/UIKit → MVVM (iOS)
   - `lib/` with `pubspec.yaml` → MVVM (Flutter)
   - Frontend-only SPA without backend → None
   - If unclear, ask the user
5. Detect project type by root folders:
   - `src/` without module subfolders → monolith
   - `backend/` + `frontend/` → multi-module
   - `packages/` or `apps/` → monorepo

### If it's a new project (no code):
Ask the user:
1. Project name
2. What problem it solves and for whom (domain + users)
3. Chosen stack (backend, frontend, DB, infra)
4. Architecture (Clean Architecture, Hexagonal, MVC, or None)
5. Non-negotiable constraints (license, privacy, accessibility, performance)
6. Whether it's a monolith, multi-module or monorepo

**IMPORTANT:** Ask ALL questions together, not one by one. The user answers once.

## Step 2: Generation

With the information obtained, generate EXACTLY these 4 files:

---

### File 1: `.ai/agents/project-context.md`

Fill in the sections of the existing template. Format:

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

### File 2: `CLAUDE.md`

Use `.ai/templates/CLAUDE.md.template` as base. Fill ALL placeholders `[...]`:

- Project name, stack, architecture
- Domain, end user, objective
- Skills list (deduce from stack: e.g. if using Vue -> skill `vue`, if using PostgreSQL -> skill `postgresql`)
- Real project folder structure
- Naming, quality, security standards (deduce from stack)
- Real commands

**Rules:**
- Maximum 80-150 lines. Be concise but complete.
- Don't duplicate what's already in `project-context.md` (reference instead).
- The Roles and Workflow sections are NOT modified (already complete in the template).

---

### File 3: `AGENTS.md`

Use `.ai/templates/AGENTS.md.template` as base. Fill:

- Project name, stack
- Skills by category (deduce from stack)

**Rules:**
- Maximum 80-100 lines.
- The Agent Structure and Workflow sections are NOT modified (already complete).

---

### File 4: `.ai/decisions.md`

Update the existing `.ai/decisions.md` file (DO NOT overwrite if it already has content).
Add initial stack decisions in the corresponding sections:

- **Conventions:** stack naming (e.g.: `PascalCase for classes, camelCase for methods`)
- **Dependencies:** DB, main framework, with `DO NOT REVISIT`
- **Patterns:** chosen architecture
- **Infrastructure:** Docker, CI/CD if applicable

Use format: `YYYY-MM-DD: decision — reason`

---

## Step 3: Generate basic skills

For each stack technology, generate a skill in `.ai/skills/{name}/SKILL.md`.

Each skill MUST:
- Reflect **current best practices** and modern framework/tool versions.
- Include a review notice at the top.
- Be concise (~40-80 lines).

Skill format:

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

**Skill naming** (kebab-case, separate testing from framework):
- Framework: `symfony`, `vue`, `django`, `react`, `nestjs`
- Testing: `symfony-pest`, `vue-vitest`, `django-pytest`, `react-testing`
- DB: `postgresql`, `mongodb`, `mysql`
- Infra/CSS: `docker`, `tailwind`, `accessibility`
- Integrations: `openai-integration`, `stripe-integration`

**Rules for generating skills:**
- ALWAYS use the most recent and stable framework version (e.g.: Vue 3 Composition API, not Options API).
- If there's a modern and a legacy way to do something, document ONLY the modern one.
- Patterns must be concrete with short snippets, not generic theory.
- Include the official documentation URL as reference.
- Generate one skill per main stack technology (backend framework, frontend framework, DB, backend testing, frontend testing, CSS framework if applicable, infra if applicable).

---

## Step 3.5: Adapt agents by architecture

The template ships with **Clean Architecture** gates by default. Adapt based on what was detected or chosen:

- **Clean / Hexagonal / Onion** → no changes needed, agents are ready
- **MVC** → edit 4 agents (see below)
- **MVVM** → edit 3 agents (see below) — for mobile apps (Android, iOS, Flutter)
- **None** (frontend-only, no backend, or no formal architecture) → add `Architecture: None` to project-context.md Technical Decisions section. Do NOT modify any agents. The architect agent simply won't be invoked since there are no layers to verify

### If Architecture: MVC

Read `.ai/prompts/gates-mvc.md` and apply the gate replacements described there.

### If Architecture: MVVM (mobile)

Read `.ai/prompts/gates-mvvm.md` and apply the gate replacements described there.

> **If your AI tool cannot read files** (e.g. ChatGPT/Gemini web): copy the content of the corresponding gates file and paste it after this prompt.

---

## Step 4: Post-generation

Tell the user the next steps:

1. Review and adjust the generated files (especially `project-context.md` and `CLAUDE.md`)
2. **Review each skill** in `.ai/skills/` — adapt patterns and conventions to the project
3. **Check `.gitignore`** — if the project already has one, add entries for generated files:
   `.claude/`, `.opencode/`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, `.ai/.local/*`
4. Run `.ai/sync.sh` to distribute to all tools
5. Run `.ai/test.sh` to validate the structure
6. If using Claude Code: verify `.claude/settings.json` has the hooks configured

---

## Notes for the LLM

- Be CONCISE. project-context.md should fit in ~50 lines (auto-loaded in every message).
- CLAUDE.md should fit in ~100 lines. Every extra line consumes tokens in EVERY interaction.
- Skills should fit in ~40-80 lines each. Just enough to be useful without being a manual.
- Don't invent information. If you don't detect something, ask or leave the placeholder.
- Artifact paths must reflect the project's REAL structure, not the generic one.
- Use today's date for decisions.
- For skills, search official documentation for current best practices if you have web access.
- **All generated output must be in English** (CLAUDE.md, AGENTS.md, project-context.md, decisions.md, skills — all consumed by the AI directly).
