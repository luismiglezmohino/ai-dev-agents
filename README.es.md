# AI Dev Agents

[🇬🇧 Read in English](README.md)

Sistema de agentes especializados para desarrollo asistido por IA. Agnóstico al lenguaje, framework y herramienta de IA. Soporta Clean Architecture, MVC, MVVM y None (~90% de todos los proyectos de software).

## Qué es esto

11 agentes especializados + 1 orchestrator que guían a los asistentes de IA durante el desarrollo de software. Incluye patrón de verificación cruzada entre agentes para prevenir errores que un solo agente no detecta.

**Principio clave:** Los agentes definen QUÉ verificar (Quality Gates agnósticos). Los skills definen CÓMO hacerlo (framework-específico).

> **¿Nuevo aquí?** Empieza por la [guía de inicio rápido (5 minutos)](docs/guides/es/getting-started.md).

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
| GitHub Copilot | `.github/copilot-instructions.md` | No (todo inline) | Bajo |

Las herramientas con agentes/skills bajo demanda (Claude Code, OpenCode, Antigravity, Gemini CLI, Codex CLI) cargan agentes SOLO cuando se invocan — alto ahorro de tokens. Las herramientas sin agentes bajo demanda cargan todo en un fichero compacto. Para esas, **se recomienda [SDD (Feature Specs)](docs/specs/FEAT-TEMPLATE.md)** para centralizar contexto.

> Ver [capacidades detalladas por herramienta](docs/guides/es/how-claude-code-works.md) y [patrones de verificación cruzada](docs/guides/es/cross-verification.md).

## Inicio rápido

### 1. Copiar al proyecto

**Opción A:** Clic en "Use this template" en el repo de GitHub (recomendado).

**Opción B:** Copia manual

```bash
# macOS / Linux
cp -r ai-dev-agents/{.ai,.claudeignore,AGENTS.md,docs} mi-proyecto/

# Windows (PowerShell)
Copy-Item -Recurse ai-dev-agents\.ai, ai-dev-agents\docs, ai-dev-agents\AGENTS.md, ai-dev-agents\.claudeignore mi-proyecto\
```

> `.gitignore` se gestiona automáticamente con `sync.sh` — añade las entradas necesarias sin sobreescribir tu fichero existente.

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
.ai/sync.sh   # Genera configs para todas las herramientas
.ai/test.sh   # Valida estructura (0 errores = listo)
```

### Qué commitear y qué gitignorear

| Fichero/Directorio | ¿Commitear? | Por qué |
|---|---|---|
| `.ai/` (directorio completo) | **Sí** | Fuente de verdad |
| `CLAUDE.md`, `AGENTS.md` | **Sí** | Configs principales |
| `.claude/settings.json` | **Sí** | Config de hooks + MCP |
| `docs/` | **Sí** | Specs, ADRs, guías |
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
| technical-writer | Docs vivas | Ejemplos funcionales, ADRs completos, setup < 15min |
| ux-designer | WCAG 2.2 AA | Contraste 4.5:1, targets 44x44px, teclado |

Cada gate existe porque su ausencia causó problemas reales y repetidos. Ver [por qué existen estos gates](docs/guides/es/why-these-gates.md).

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

## Guías

| Guía | Descripción |
|---|---|
| **[Inicio rápido](docs/guides/es/getting-started.md)** | De cero a agentes funcionando en 5 minutos |
| **[Verificación cruzada](docs/guides/es/cross-verification.md)** | Flujos del orchestrator, cuándo aplicar, estrategias |
| **[Optimización de tokens](docs/guides/es/token-optimization.md)** | Estrategia de idiomas, jerarquía de carga, decisiones |
| **[Cómo funciona Claude Code](docs/guides/es/how-claude-code-works.md)** | Gestión de contexto, qué puede acceder, implicaciones |
| **[Ciclo de vida de agentes](docs/guides/es/agent-lifecycle.md)** | Agentes efímeros, anti-patrones, gestión de contexto |
| **[Memoria persistente](docs/guides/es/persistent-memory.md)** | Rules, hooks, Engram, Feature Specs, memoria por herramienta |
| **[Por qué existen estos gates](docs/guides/es/why-these-gates.md)** | Cadenas de error reales que motivaron cada Quality Gate |
| **[MCPs recomendados](docs/guides/es/recommended-mcps.md)** | MCPs básicos y opcionales por stack |
| **[Git hooks recomendados](docs/guides/es/recommended-hooks.md)** | Hooks con Lefthook y Husky |
| **[GitHub Actions workflows](docs/guides/es/recommended-workflows.md)** | CI/CD, estrategia de ramas |
| **[Modelos recomendados](docs/guides/es/recommended-models.md)** | Modelo por agente/tarea, estrategia de costes, modelos locales |

## Inspiración y referencias

- **[Engram](https://github.com/Gentleman-Programming/engram)** — Memoria persistente cross-tool via MCP (MIT)
- **[github/spec-kit](https://github.com/github/spec-kit)** — Toolkit de Spec-Driven Development por GitHub (MIT)
- **[OWASP Top 10:2025](https://owasp.org/Top10/)** — Base del @security-auditor (CC BY-SA 4.0)

## Licencia

Apache License 2.0 — Uso libre (incluido comercial) con atribución obligatoria. Ver [LICENSE](LICENSE).
