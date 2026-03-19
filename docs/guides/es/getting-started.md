# Inicio rápido (5 minutos)

[🇬🇧 Read in English](../getting-started.md)


Esta guía te lleva de cero a tener el sistema de agentes funcionando en tu proyecto.

## Requisitos

- Un proyecto con Git inicializado
- Una herramienta de IA instalada (Claude Code, OpenCode, Cursor, o cualquier otra)
- 5 minutos

## Paso 1: Copiar el template

**Opción A:** Clic en "Use this template" en el repo de GitHub (recomendado).

**Opción B:** Copia manual

```bash
# macOS / Linux
cp -r ai-dev-agents-template/{.ai,.claudeignore,.gitignore,AGENTS.md,docs} tu-proyecto/

# Windows (PowerShell)
Copy-Item -Recurse ai-dev-agents-template\.ai, ai-dev-agents-template\docs, ai-dev-agents-template\AGENTS.md, ai-dev-agents-template\.claudeignore, ai-dev-agents-template\.gitignore tu-proyecto\
```

> Si tu proyecto ya tiene un `.gitignore`, fusiona las entradas en vez de sobreescribir.

## Paso 2: Bootstrap automático

Abre tu herramienta de IA en el proyecto y pega el contenido de `.ai/prompts/es/bootstrap.md` (o `.ai/prompts/bootstrap.md` en inglés).

La IA analizará tu proyecto y generará:
- `project-context.md` — contexto del proyecto
- `CLAUDE.md` — configuración principal
- `decisions.md` — decisiones del stack
- Skills básicos para tu stack

Si tu proyecto está vacío, te preguntará qué quieres construir.

## Paso 3: Sincronizar

```bash
.ai/sync.sh
```

Esto genera las configuraciones para tu herramienta (Claude Code, OpenCode, Cursor, etc.).

## Paso 4: Validar

```bash
.ai/test.sh
```

Si todo está verde, ya tienes el sistema de agentes funcionando.

> **Importante:** Edita siempre los ficheros en `.ai/` (la fuente), nunca en directorios generados (`.claude/`, `.continue/`, `.agents/`, `.gemini/`, `.cursorrules`, etc.). Los ficheros generados se sobreescriben cada vez que ejecutas `sync.sh`. Después de editar cualquier agente, skill o prompt en `.ai/`, re-ejecuta `.ai/sync.sh` para propagar los cambios a todas las herramientas.
>
> **¿Por qué sync.sh genera para todas las herramientas a la vez?** Puede crear directorios que no uses ahora, pero permite cambiar de herramienta sin reconfigurar (ej: Claude Code hoy, Gemini CLI mañana). Todos los directorios generados están gitignoreados y no interfieren con tu proyecto.

## Paso 5: Elegir modo de trabajo

El template soporta tres modos de trabajo. Elige el que mejor se adapte a tu situación:

### Modo A: Agentes directos (el más simple)

Invocas cada agente manualmente cuando lo necesitas:

```
@tdd implement el endpoint GET /api/users
@architect review la estructura de capas
@security audit-all
```

**Mejor para:** tareas puntuales, fixes rápidos, trabajo en una sola capa.
**Tú decides:** qué agente llamar y cuándo. La verificación cruzada la haces tú invocando los agentes de revisión manualmente.

### Modo B: Orchestrator (coordinación automática)

El orchestrator enruta automáticamente al agente correcto y coordina la verificación cruzada entre agentes:

```
"Necesito un nuevo endpoint para gestionar usuarios"
→ El orchestrator enruta a @tdd-developer
→ Después lanza @architect y @security-auditor automáticamente
```

**Mejor para:** features completas que tocan múltiples capas, proyectos donde quieres que la verificación cruzada sea automática.
**Disponible en:** OpenCode (agente primary). En Claude Code, el routing es automático pero sin orchestrator explícito.

### Modo C: Spec Driven Development (SDD) — el más completo

Defines una especificación técnica ANTES de implementar. Los agentes trabajan contra esa especificación:

```
1. Generas un Feature Spec (.ai/prompts/feature-spec.md)
2. Cada agente extrae lo que necesita del spec
3. Implementación guiada por la especificación
4. Verificación contra los criterios del spec
```

**Mejor para:** features complejas (5+ endpoints), equipos con varios desarrolladores, proyectos donde la calidad es crítica.
**Guía:** ver `docs/specs/FEAT-TEMPLATE.md` y el prompt `.ai/prompts/feature-spec.md`.

### ¿Cuál elegir?

| Situación | Modo recomendado |
|---|---|
| Fix rápido, tarea puntual | A (agentes directos) |
| Feature nueva estándar | B (orchestrator) |
| Feature compleja o crítica | C (SDD) |
| Proyecto nuevo (día 0) | C (SDD) para la primera feature, luego B |
| Hotfix en producción | A (agentes directos, flujo reducido) |
| Código legacy / modernización | C (SDD) — especificar antes de tocar |

Los tres modos son compatibles. Puedes usar A para fixes rápidos y C para features grandes en el mismo proyecto.

### Cómo trabajar con cada modo

**Modo A — Agentes directos:**

1. Abre tu herramienta de IA (Claude Code, OpenCode, Cursor...)
2. Escribe el comando del agente que necesitas: `@tdd implement <feature>`
3. El agente trabaja, tú revisas lo que genera
4. Si necesitas verificación, invoca manualmente: `@security audit-all`
5. Cuando estés satisfecho, commit y PR

**Modo B — Orchestrator:**

1. Abre OpenCode (el orchestrator funciona como agente primary)
2. Describe lo que necesitas en lenguaje natural: "Necesito un endpoint para crear usuarios"
3. El orchestrator decide qué agente usa y lo lanza
4. Cuando termina, el orchestrator lanza la verificación cruzada automáticamente
5. Tú revisas el resultado final. Si hay problemas, el orchestrator itera
6. Cuando estés satisfecho, commit y PR

> En Claude Code: no hay orchestrator explícito. Claude Code hace routing automático basado en el CLAUDE.md. La verificación cruzada la haces tú invocando agentes de revisión o se aplica via los Quality Gates de cada agente.

**Modo C — SDD (Spec Driven Development):**

1. Antes de escribir código, genera la especificación: pega `.ai/prompts/feature-spec.md` en tu herramienta de IA
2. La IA genera un fichero en `docs/specs/FEAT-XXX-nombre.md` con requisitos, contratos, errores esperados
3. Revisa y ajusta el spec — este es el momento de pensar, no cuando estés programando
4. Implementa: `@tdd implement según spec docs/specs/FEAT-XXX-nombre.md`
5. Cada agente extrae del spec lo que necesita (tests, seguridad, arquitectura)
6. Verificación cruzada contra los criterios del spec
7. Commit y PR

## Prompts disponibles

El template incluye prompts reutilizables en `.ai/prompts/es/` (español) y `.ai/prompts/` (inglés).

| Herramienta | Cómo usar los prompts |
|---|---|
| Claude Code / OpenCode / Gemini CLI / Codex CLI | Dile a la IA: `Lee .ai/prompts/es/code-review.md y ejecútalo` |
| Continue / Cursor / Windsurf / Copilot | Copia el contenido del `.md` y pégalo en el chat |
| ChatGPT / Gemini (web) | Copia el contenido del `.md` y pégalo |

| Prompt | Para qué | Cuándo usarlo |
|---|---|---|
| `bootstrap.md` | Configura el template en tu proyecto (genera context, skills, configs) | Día 0 — obligatorio |
| `feature-spec.md` | Genera especificación técnica antes de implementar (SDD) | Antes de features complejas |
| `refine-skills.md` | Mejora los skills con patrones reales de tu código | Después de 2-3 features implementadas |
| `legacy-audit.md` | Analiza código legacy y propone plan de modernización | Antes de refactorizar código antiguo |
| `code-review.md` | Revisión multi-agente (arquitectura + seguridad + testing + calidad) | Antes de abrir una PR |

## ¿Qué sigue?

| Siguiente paso | Cuándo | Guía |
|---|---|---|
| Configurar MCPs | Si necesitas conectar BD, Sentry, GitHub... | [MCPs recomendados](recommended-mcps.md) |
| Configurar Git hooks | Antes del primer PR | [Git hooks recomendados](recommended-hooks.md) |
| Configurar CI/CD | Antes de producción | [GitHub Actions workflows](recommended-workflows.md) |
| Elegir modelos | Si quieres optimizar coste/calidad | [Modelos recomendados](recommended-models.md) |
| Crear Feature Spec | Antes de una feature compleja | Ver `docs/specs/FEAT-TEMPLATE.md` |
| Refinar skills | Después de 2-3 features implementadas | Usar `.ai/prompts/refine-skills.md` |
| Auditar código legacy | Antes de modernizar | Usar `.ai/prompts/legacy-audit.md` |

## Estructura mínima después del setup

```
tu-proyecto/
├── .ai/
│   ├── agents/          # 11 agentes + orchestrator + context
│   ├── skills/          # Skills de tu stack (generados por bootstrap)
│   ├── hooks/           # Memoria automática (Claude Code)
│   ├── prompts/         # Prompts reutilizables
│   ├── sync.sh          # Genera configs para todas las herramientas
│   └── test.sh          # Valida la estructura
├── docs/
│   ├── specs/           # Feature Specs (opcional)
│   ├── adrs/            # Architecture Decision Records
│   └── guides/          # Guías adicionales
├── CLAUDE.md            # Config principal (generado)
└── AGENTS.md            # Config OpenCode (generado)
```

## CI/CD incluido

El template incluye un workflow de GitHub Actions (`.github/workflows/ci.yml`) que ejecuta `sync.sh + test.sh` en cada PR y push a master. Si adoptaste el template via "Use this template", ya lo tienes. Valida la estructura de agentes, frontmatter y ficheros generados automáticamente.

Si no lo quieres, borra `.github/workflows/ci.yml`. Si ya tienes tu propio CI, el workflow del template no entra en conflicto — se ejecuta independientemente.

## Usuarios Windows

`sync.sh` y `test.sh` son scripts bash. En Windows, necesitas uno de:
- **WSL** (Windows Subsystem for Linux) — recomendado
- **Git Bash** (incluido con Git for Windows)
- **MSYS2**

La mayoría de desarrolladores que usan CLIs de IA (Claude Code, Gemini CLI, Codex CLI) en Windows ya tienen WSL instalado.

## Problemas comunes

| Problema | Solución |
|---|---|
| `sync.sh` no genera nada | Verifica que `.ai/agents/` tiene los ficheros .md |
| La IA no usa los agentes | Verifica que `CLAUDE.md` o `AGENTS.md` existe en la raíz |
| El contexto se llena rápido | Mantén `CLAUDE.md` < 120 líneas. Usa `/compact` |
| Los skills no se cargan | Verifica la ruta en el agente y que el skill tiene `SKILL.md` |
| `test.sh` falla | Lee el error — suele ser un frontmatter incompleto o sección faltante |
