# AI Dev Agents

[🇬🇧 Read in English](README.md)

Sistema de agentes especializados para desarrollo asistido por IA. Agnóstico al lenguaje, framework y herramienta de IA. Soporta Clean Architecture, MVC, MVVM y None (~90% de todos los proyectos de software).

## Qué es esto

12 agentes especializados + 1 orchestrator que guían a los asistentes de IA durante el desarrollo de software. Incluye patrón de verificación cruzada entre agentes para prevenir errores que un solo agente no detecta.

**Principio clave:** Los agentes definen QUÉ verificar (Quality Gates agnósticos). Los skills definen CÓMO hacerlo (framework-específico).

<details>
<summary><strong>¿Nuevo aquí? Empieza aquí</strong></summary>

### Paso 1: Prueba un agente

Elige una tarea que ya estés haciendo (ej. escribir un test) e invoca `@tdd-developer`. Observa si los gates detectan algo que habrías pasado por alto. No necesitas más que el Quick Start.

### Paso 2: Añade el contexto de tu proyecto

Ejecuta el prompt de bootstrap (`.ai/prompts/es/bootstrap.md`) en tu herramienta de IA. Genera `project-context.md`, `CLAUDE.md`, `decisions.md` y skills de tu stack automáticamente. Los agentes pasan de genéricos a conscientes de tu proyecto.

### Paso 3: Combina agentes

- **Herramientas con agentes bajo demanda** (Claude Code, OpenCode, Antigravity, Gemini CLI, Codex CLI): invoca agentes individualmente o usa `@orchestrator` para enrutar y coordinar verificación cruzada automáticamente.
- **Herramientas sin agentes bajo demanda** (Cursor, Windsurf, Copilot): los agentes se cargan inline — invócalos por nombre en tu prompt.

### Paso 4: Feature Specs (SDD)

Genera un spec con `.ai/prompts/es/feature-spec.md` antes de implementar. Cada agente extrae lo que necesita del spec. Recomendado para todas las herramientas — casi esencial para Cursor/Windsurf/Copilot donde centraliza el contexto que los agentes inline no pueden cargar bajo demanda. Ver [cuándo usar specs](.ai/docs/es/persistent-memory.md).

> Guía completa: [guía de inicio rápido](.ai/docs/es/getting-started.md) (5 minutos).

</details>

## Compatibilidad por herramienta

| Herramienta | Fichero siempre cargado | Agentes bajo demanda | Ahorro tokens |
|---|---|---|---|
| Claude Code | `CLAUDE.md` | `.claude/agents/` (sí) | Alto |
| OpenCode | `AGENTS.md` | `.opencode/agents/` (sí) | Alto |
| Antigravity (Google) | `GEMINI.md` | `.agents/rules/` (sí, @mention) | Alto |
| Gemini CLI | `GEMINI.md` | `.gemini/skills/` (sí, activate_skill) | Alto |
| Codex CLI (OpenAI) | `AGENTS.md` | `.agents/skills/` (sí, /skills) | Alto |
| Continue (VS Code) | `.continue/rules/` | Parcial (matching implícito) | Medio |
| Cursor | `.cursorrules` | No (todo inline) | Bajo |
| Windsurf | `.windsurfrules` | No (todo inline) | Bajo |
| GitHub Copilot / Copilot CLI | `.github/copilot-instructions.md`, `AGENTS.md` | CLI: sí (AGENTS.md) / IDE: no | CLI: Alto / IDE: Bajo |

Las herramientas con agentes/skills bajo demanda (Claude Code, OpenCode, Antigravity, Gemini CLI, Codex CLI) cargan agentes SOLO cuando se invocan — alto ahorro de tokens. Las herramientas sin agentes bajo demanda cargan todo en un fichero compacto. Para esas, **se recomienda [SDD (Feature Specs)](.ai/templates/FEAT-TEMPLATE.md)** para centralizar contexto.

> Ver [herramientas soportadas y descargas](.ai/docs/es/supported-tools.md), [capacidades detalladas por herramienta](.ai/docs/es/how-claude-code-works.md) y [patrones de verificación cruzada](.ai/docs/es/cross-verification.md).

## Inicio rápido

### 1. Añadir `.ai/` a tu proyecto

**Opción A:** Clic en "Use this template" en el repo de GitHub (repo completo).

**Opción B:** Descargar solo `.ai/` en un proyecto existente (requiere Node.js)

```bash
npx degit luismiglezmohino/ai-dev-agents/.ai .ai
```

**Opción C:** Sin Node.js

```bash
curl -sL https://github.com/luismiglezmohino/ai-dev-agents/archive/main.tar.gz \
  | tar xz && mv ai-dev-agents-main/.ai . && rm -rf ai-dev-agents-main
```

> Solo necesitas [`.ai/`](.ai/) — todo lo demás lo genera `sync.sh` en el paso 3.

### 2. Configurar proyecto

**Opción A: Bootstrap automático (recomendado)**

Abre tu herramienta de IA y pega el contenido de `.ai/prompts/es/bootstrap.md`.
El LLM analiza tu proyecto (o pregunta si es nuevo) y genera automáticamente:
- `.ai/agents/project-context.md` — contexto del proyecto
- `CLAUDE.md` — configuración principal
- `.ai/decisions.md` — decisiones del stack
- `.ai/skills/` — skills básicos del stack

**Opción B: Manual** — copiar templates y rellenar placeholders.

### 3. Sincronizar y validar

```bash
.ai/sync.sh   # Genera configs para las 9 herramientas
.ai/test.sh   # Valida estructura (0 errores = listo)
```

> Ejecuta siempre `sync.sh` después de cualquier cambio en `.ai/`. Genera `AGENTS.md`, `.claudeignore`, estructura `docs/`, entradas `.gitignore` y configs por herramienta.

### Qué commitear y qué gitignorear

| Fichero/Directorio | ¿Commitear? | Por qué |
|---|---|---|
| `.ai/` (directorio completo) | **Sí** | Fuente de verdad |
| `CLAUDE.md` | **Sí** | Config principal |
| `AGENTS.md` | **Sí** | Generado por sync.sh, pero commitéalo |
| `.claude/settings.json` | **Sí** | Config de hooks + MCP |
| `docs/` | **Sí** | Specs, ADRs (creados por sync.sh) |
| `.claude/agents/`, `.claude/rules/`, `.opencode/` | **No** | Generado por `sync.sh` |
| `.cursorrules`, `.windsurfrules`, `GEMINI.md` | **No** | Generado por `sync.sh` |
| `.agents/` | **No** | Generado por `sync.sh` (Codex, Gemini CLI, Antigravity) |
| `.continue/rules/` | **No** | Generado por `sync.sh` (Continue) |
| `.gemini/skills` | **No** | Generado por `sync.sh` (Gemini CLI) |
| `.ai/.local/` | **No** | Estado de sesión |

> **Regla:** si `sync.sh` lo genera, gitignórealo. Si lo editas a mano, commitéalo. Edita siempre en `.ai/` y re-ejecuta `sync.sh` para propagar cambios. Sync genera para las 9 herramientas a la vez — esto permite cambiar de herramienta sin reconfigurar.

## Agentes incluidos

| Agente | Misión | Gates clave |
|---|---|---|
| product-owner | User Stories con ROI | Formato US, criterios medibles, valor claro |
| architect | Integridad arquitectónica | Domain puro, flujo e2e, contratos completos |
| tdd-developer | RED-GREEN-REFACTOR | Test falla primero, ambas suites, DI compila |
| database-engineer | Schema + migraciones | Reversibles, índices, mapeo ORM verificado |
| security-auditor | OWASP Top 10:2025 | Inputs validados, sin secrets, supply chain + gates condicionales (auth, passwords, uploads, CSRF, cookies, SSRF) |
| qa-engineer | Coverage 100/80/0 | Pirámide testing, sin tests ignorados |
| performance-engineer | Core Web Vitals | p95 < 200ms, LCP/FID/CLS, bundle < 100KB |
| devops | CI/CD + Git workflow | Pipeline verde, infra declarativa, PR docs |
| observability-engineer | Metrics + logs | Métricas negocio, logs JSON, health checks |
| incident-responder | Respuesta a incidentes | Severidad clasificada, causa raíz, postmortem, monitorización actualizada |
| technical-writer | Docs vivas | Ejemplos funcionales, ADRs completos, setup < 15min |
| ux-designer | WCAG 2.2 AA | Contraste 4.5:1, targets 44x44px, teclado |

Cada gate existe porque su ausencia causó problemas reales y repetidos. Ver [por qué existen estos gates](.ai/docs/es/why-these-gates.md).

## Soporte de Arquitectura

El template soporta **4 modos de arquitectura** (~90% de todos los proyectos de software):

| Flag | Cuándo usarlo | Agentes adaptados |
|---|---|---|
| `Clean` (por defecto) | Backend con capas separadas (Domain/Application/Infrastructure) | Ninguno (gates por defecto) |
| `MVC` | Framework MVC (Laravel, Django, Rails, Spring MVC...) | architect, tdd-developer, qa-engineer, orchestrator |
| `MVVM` | Apps mobile (Android, iOS, Flutter) | architect, ux-designer, performance-engineer, orchestrator |
| `None` | Frontend-only SPA, herramientas CLI, o sin arquitectura formal | Architect no se invoca |

El bootstrap detecta la arquitectura por la estructura de carpetas o pregunta. Adapta los agentes relevantes — el resto no cambian.

> El frontend web (Vue/React) usa `None` — lo cubren ux-designer + skills, no los gates del architect.

## Prompts reutilizables

| Prompt | Cuándo usarlo | Obligatorio |
|---|---|---|
| `es/bootstrap.md` | Día 0 — genera configs + skills | Sí |
| `es/feature-spec.md` | Antes de features complejas (SDD) | No |
| `es/code-review.md` | Antes de abrir una PR | No |
| `es/refine-skills.md` | Después de 2-3 features | No |
| `es/legacy-audit.md` | Antes de modernizar código legacy | No |

Todos los prompts disponibles en español (`.ai/prompts/es/`) e inglés (`.ai/prompts/`). Los gates específicos de arquitectura (`gates-mvc.md`, `gates-mvvm.md`) se cargan bajo demanda por el bootstrap — no hace falta pegarlos por separado.

## Modos de trabajo

Estos son flujos de trabajo recomendados, no restricciones. Los agentes son flexibles — úsalos como encaje en tu proyecto. Los tres modos son compatibles — puedes usar A para fixes rápidos y C para features grandes en el mismo proyecto.

### Modo A: Agentes directos (el más simple)

Invoca cada agente manualmente cuando lo necesites:

```
@tdd implement the GET /api/users endpoint
@architect review the layer structure
@security audit-all
```

**Ideal para:** tareas puntuales, fixes rápidos, trabajo en una sola capa.

### Modo B: Orchestrator (coordinación automática)

El orchestrator enruta al agente correcto y coordina verificación cruzada:

```
"Necesito un nuevo endpoint para gestionar usuarios"
→ Enruta a @tdd-developer
→ Luego lanza @architect y @security-auditor automáticamente
```

**Ideal para:** features completas que tocan varias capas. Disponible en herramientas con agentes bajo demanda (Claude Code, OpenCode, Antigravity, Gemini CLI, Codex CLI).

### Modo C: Spec Driven Development (SDD) — el más completo

Define una especificación técnica ANTES de implementar. Los agentes trabajan contra esa especificación:

1. Genera un Feature Spec con `.ai/prompts/es/feature-spec.md`
2. Cada agente extrae lo que necesita del spec
3. Implementación guiada por la especificación
4. Verificación contra los criterios del spec

**Ideal para:** features complejas (5+ endpoints), equipos, proyectos críticos. Recomendado para todas las herramientas — casi esencial para Cursor/Windsurf/Copilot.

### Cuándo usar cada modo

| Situación | Modo recomendado |
|---|---|
| Fix rápido, tarea puntual | A (agentes directos) |
| Feature nueva estándar | B (orchestrator) |
| Feature compleja o crítica | C (SDD) |
| Proyecto nuevo (día 0) | C (SDD) para la primera feature, luego B |
| Hotfix en producción | A (directo) + @incident-responder |
| Código legacy / modernización | C (SDD) — especificar antes de tocar |

### Cómo trabajar con cada modo

**Modo A — Agentes directos:**

1. Abre tu herramienta de IA (Claude Code, OpenCode, Cursor...)
2. Escribe el comando del agente que necesitas: `@tdd implement <feature>`
3. El agente trabaja, tú revisas lo que genera
4. Si necesitas verificación, invoca manualmente: `@security audit-all`
5. Cuando estés satisfecho, commit y PR

**Modo B — Orchestrator:**

1. Describe lo que necesitas en lenguaje natural: "Necesito un endpoint para crear usuarios"
2. El orchestrator decide qué agente usar y lo lanza
3. Al terminar, el orchestrator lanza verificación cruzada automáticamente
4. Revisas el resultado final. Si hay problemas, el orchestrator itera
5. Cuando estés satisfecho, commit y PR

**Modo C — SDD (Spec Driven Development):**

1. Antes de escribir código, genera la especificación: pega `.ai/prompts/es/feature-spec.md` en tu herramienta de IA
2. La IA genera un fichero en `docs/specs/FEAT-XXX-name.md` con requisitos, contratos, errores esperados
3. Revisa y ajusta el spec — este es el momento de pensar, no cuando estás programando
4. Implementa: `@tdd implement according to spec docs/specs/FEAT-XXX-name.md`
5. Cada agente extrae lo que necesita del spec (tests, seguridad, arquitectura)
6. Verificación cruzada contra los criterios del spec
7. Commit y PR

## Guías

| Guía | Descripción |
|---|---|
| **[Inicio rápido](.ai/docs/es/getting-started.md)** | De cero a agentes funcionando en 5 minutos |
| **[Verificación cruzada](.ai/docs/es/cross-verification.md)** | Flujos del orchestrator, cuándo aplicar, estrategias |
| **[Optimización de tokens](.ai/docs/es/token-optimization.md)** | Estrategia de idiomas, jerarquía de carga, decisiones |
| **[Cómo funciona Claude Code](.ai/docs/es/how-claude-code-works.md)** | Gestión de contexto, qué puede acceder, implicaciones |
| **[Ciclo de vida de agentes](.ai/docs/es/agent-lifecycle.md)** | Agentes efímeros, anti-patrones, gestión de contexto |
| **[Memoria persistente](.ai/docs/es/persistent-memory.md)** | Rules, hooks, Engram, Feature Specs, memoria por herramienta |
| **[Por qué existen estos gates](.ai/docs/es/why-these-gates.md)** | Cadenas de error reales que motivaron cada Quality Gate |
| **[MCPs recomendados](.ai/docs/es/recommended-mcps.md)** | MCPs básicos y opcionales por stack |
| **[Git hooks recomendados](.ai/docs/es/recommended-hooks.md)** | Hooks con Lefthook y Husky |
| **[GitHub Actions workflows](.ai/docs/es/recommended-workflows.md)** | CI/CD, estrategia de ramas |
| **[Modelos recomendados](.ai/docs/es/recommended-models.md)** | Modelo por agente/tarea, estrategia de costes, modelos locales |

## Inspiración y referencias

- **[Engram](https://github.com/Gentleman-Programming/engram)** — Memoria persistente cross-tool via MCP (MIT)
- **[github/spec-kit](https://github.com/github/spec-kit)** — Toolkit de Spec-Driven Development por GitHub (MIT)
- **[OWASP Top 10:2025](https://owasp.org/Top10/)** — Base del @security-auditor (CC BY-SA 4.0)

## Licencia

Apache License 2.0 — Uso libre (incluido comercial) con atribución obligatoria. Ver [LICENSE](LICENSE).
