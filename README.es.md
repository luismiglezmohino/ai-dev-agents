# AI Dev Agents Template

[🇬🇧 Read in English](README.md)

Sistema de agentes especializados para desarrollo asistido por IA. Agnóstico al lenguaje, framework y herramienta de IA.

## Que es esto

11 agentes especializados + 1 orchestrator que guian a los asistentes de IA durante el desarrollo de software. Incluye patrón de verificación cruzada entre agentes para prevenir errores que un solo agente no detecta.

**Principio clave:** Los agentes definen QUE verificar (Quality Gates agnósticos). Los skills definen COMO hacerlo (framework-específico).

> **Nuevo aquí?** Empieza por la [guia de inicio rápido (5 minutos)](docs/guides/getting-started.md).

## Estructura (después del setup)

```
.ai/                                   # Todo el template aquí
├── agents/                            # 11 roles + orchestrator + context + base
│   ├── _base.md                       # Boilerplate compartido (no invocable)
│   ├── orchestrator.md                # Routing + verificación cruzada
│   ├── project-context.md             # Restricciones del proyecto (rellenar)
│   ├── product-owner.md               # User Stories, ROI
│   ├── architect.md                   # Clean Architecture, contratos
│   ├── tdd-developer.md               # RED-GREEN-REFACTOR + verificación
│   ├── database-engineer.md           # Schema, migraciones, ORM mapping
│   ├── security-auditor.md            # OWASP Top 10:2025 (read-only)
│   ├── qa-engineer.md                 # Coverage 100/80/0 (read-only)
│   ├── performance-engineer.md        # Core Web Vitals, p95
│   ├── devops.md                      # CI/CD, Git workflow, deployment readiness
│   ├── observability-engineer.md      # Metrics, logs, tracing
│   ├── technical-writer.md            # Docs, ADRs
│   └── ux-designer.md                 # WCAG 2.2 AA
├── skills/                            # Skills específicos del stack
│   ├── git/SKILL.md                   # Ejemplo: conventional commits, husky, PRs
│   └── README.md                      # Guia para crear skills
├── hooks/                             # Scripts de memoria automatica (Claude Code)
│   ├── session-start.sh               # Inyecta contexto al iniciar sesión
│   ├── pre-compact.sh                 # Guarda estado antes de compactar
│   ├── session-stop.sh                # Guarda resumen al terminar sesión
│   └── suggest-patterns.sh            # Sugiere patrones para skills (requiere aprobación)
├── prompts/                           # Prompts reutilizables (inglés)
│   ├── bootstrap.md                   # Onboarding: genera configs + skills
│   ├── feature-spec.md               # Genera spec técnico antes de implementar (opcional)
│   ├── refine-skills.md              # Refina skills con patrones reales
│   ├── legacy-audit.md              # Analiza código legacy y propone plan de modernización
│   └── es/                            # Versiones en español
├── templates/                         # Skeletons para CLAUDE.md / AGENTS.md
│   ├── CLAUDE.md.template
│   └── AGENTS.md.template
├── tool-configs/                      # Guias por herramienta
│   ├── claude-code/README.md
│   ├── opencode/README.md
│   ├── cursor/README.md
│   ├── windsurf/README.md
│   └── copilot/README.md
├── decisions.md                       # Decisiones técnicas rápidas (cross-tool)
├── sync.sh                            # Genera configs para TODAS las herramientas
└── test.sh                            # Valida estructura del template

docs/                                  # Documentación del proyecto (no del template)
├── specs/                             # Feature Specs (SDD)
│   └── FEAT-TEMPLATE.md
├── adrs/                              # Architecture Decision Records
├── stories/                           # User Stories
└── guides/                            # Guias de uso, onboarding

.claude/                               # Generado por .ai/sync.sh (gitignored)
├── agents/                            # Agentes convertidos (formato Claude Code)
├── rules/                             # Auto-cargado (decisions.md, project-context.md)
├── settings.json                      # Hooks + Engram MCP config (commitable)
└── skills -> ../.ai/skills

.opencode/                             # Generado por .ai/sync.sh (gitignored)
├── agents -> ../.ai/agents
├── skills -> ../.ai/skills
└── decisions.md

CLAUDE.md                              # Generado por bootstrap o copiado del template
AGENTS.md                              # Generado por bootstrap o copiado del template
.cursorrules                           # Generado (compacto, gitignored)
.windsurfrules                         # Generado (compacto, gitignored)
GEMINI.md                              # Generado (compacto, gitignored)
.github/copilot-instructions.md        # Generado (compacto, gitignored)
```

## Compatibilidad por herramienta

| Herramienta | Fichero siempre cargado | Agentes bajo demanda | Ahorro tokens |
|---|---|---|---|
| Claude Code | `CLAUDE.md` | `.claude/agents/` (sí) | Alto |
| OpenCode | `AGENTS.md` | `.opencode/agents/` (sí) | Alto |
| Codex (OpenAI) | `AGENTS.md` | No (contexto compartido) | Medio |
| Cursor | `.cursorrules` | No (todo inline) | Bajo |
| Windsurf | `.windsurfrules` | No (todo inline) | Bajo |
| Gemini | `GEMINI.md` | No (todo inline) | Bajo |
| GitHub Copilot | `.github/copilot-instructions.md` | No (todo inline) | Bajo |

### Herramientas con agentes bajo demanda (Claude Code, OpenCode)

Los agentes se cargan SOLO cuando se invoca el rol. El fichero principal (`CLAUDE.md` o `AGENTS.md`) debe ser compacto (~100 líneas) porque se carga en CADA mensaje.

```
CLAUDE.md (siempre)     → ~100 líneas (contexto + roles como lista)
.ai/agents/*.md (demanda) → sin limite (solo se carga el agente invocado)
.ai/skills/*.md (demanda) → sin limite (solo se carga el skill consultado)
```

### Herramientas sin agentes bajo demanda (Cursor, Windsurf, Gemini, Copilot)

Todo va en un solo fichero que se carga siempre. Hay que compilar los agentes en una versión compacta.

```
.cursorrules (siempre)  → roles como lista compacta + gates resumidos
                          NO incluir snippets, workflows, checklists
```

`.ai/sync.sh` genera automáticamente versiones compactas para estas herramientas con un roster de agentes, gates resumidos, workflow y decisions.

### Soporte real por herramienta

| Capacidad | Claude Code | OpenCode | Codex | Cursor | Windsurf | Gemini | Copilot |
|---|---|---|---|---|---|---|---|
| Sub-agentes | Sí (Task tool) | Sí (spawn) | No | No | No | No | No |
| Orquestador | No (routing auto) | Sí (orchestrator.md) | No | No | No | No | No |
| Model routing | No (1 modelo/sesión) | Sí (por agente) | No | Sí (por regla) | No | No | No |
| Agentes bajo demanda | Sí (.claude/agents/) | Sí (.opencode/agents/) | No | No | No | No | No |
| Agent teams | Experimental | No | No | No | No | No | No |
| MCPs | Sí | Sí | Sí | Sí | Parcial | Parcial | Parcial |

**Limitacion importante:** En Cursor, Windsurf, Gemini y Copilot los agentes son reglas contextuales que se cargan siempre. No hay routing: el modelo lee todas las reglas y decide que aplicar. Por eso `sync.sh` genera versiones compactas — meter 11 agentes completos en un solo fichero agotaria la ventana de contexto.

**Futuro:** El estándar [AGENTS.md](https://github.com/anthropics/agents-md) (Linux Foundation + Anthropic + OpenAI) apunta hacia un formato universal para agentes multi-herramienta. Cuando las herramientas lo adopten, los agentes de este template seran compatibles sin cambios.

## Uso rápido

### 1. Copiar al proyecto

```bash
# Opción A: GitHub "Use this template"
# Opción B: Manual
cp -r ai-dev-agents-template/.ai mi-proyecto/.ai
cp -r ai-dev-agents-template/docs mi-proyecto/docs
cp ai-dev-agents-template/AGENTS.md mi-proyecto/
cp ai-dev-agents-template/.claudeignore mi-proyecto/
cp ai-dev-agents-template/.gitignore mi-proyecto/  # Merge con el existente
cd mi-proyecto
```

### 2. Configurar proyecto

**Opción A: Bootstrap automático (recomendado)**

Abre tu herramienta de IA y pega el contenido de `.ai/prompts/es/bootstrap.md` (o `.ai/prompts/bootstrap.md` en inglés).
El LLM analiza tu proyecto (si ya tiene código) o te pregunta (si es nuevo) y genera automáticamente:
- `.ai/agents/project-context.md` — contexto del proyecto relleno
- `CLAUDE.md` — configuración principal rellena
- `AGENTS.md` — configuración OpenCode rellena (si aplica)
- `.ai/decisions.md` — decisiones iniciales del stack
- `.ai/skills/` — skills básicos del stack (marcados `> REVISAR`)

Funciona con cualquier herramienta (Claude Code, OpenCode, Cursor, ChatGPT, etc.).

**Opción B: Manual**

```bash
# Copiar templates a raíz
cp .ai/templates/CLAUDE.md.template CLAUDE.md
cp .ai/templates/AGENTS.md.template AGENTS.md   # Si usas OpenCode

# Editar con tu stack, dominio y restricciones
vim CLAUDE.md
vim .ai/agents/project-context.md
```

### 3. Crear skills para tu stack (solo Opción B)

Si usaste bootstrap, los skills básicos ya se crearon. Si elegiste la opción manual:

```bash
# Ejemplo: proyecto Django + React
mkdir -p .ai/skills/{django,django-pytest,react,react-testing,postgresql}

# Escribir SKILL.md en cada uno con:
# - Patrones del proyecto
# - Errores comunes y soluciones
# - Checklists
```

Ver `.ai/skills/README.md` para el formato obligatorio y ejemplos por stack.

### 4. Sincronizar

```bash
.ai/sync.sh
# Genera:
#   .claude/agents/            (formato Claude Code, tools granulares)
#   .claude/rules/             (decisions.md + project-context.md auto-cargados)
#   .opencode/agents/          (enlaces simbólicos)
#   .cursorrules               (compacto)
#   .windsurfrules             (compacto)
#   GEMINI.md                  (compacto)
#   .github/copilot-instructions.md (compacto)
```

### 5. Validar

```bash
.ai/test.sh
# Valida:
#   Directorios y archivos obligatorios
#   Frontmatter de agentes (description, mode, temperature)
#   Secciones obligatorias (Quality Gates, Restricciones Fatales)
#   Hooks ejecutables
#   Tools granulares en agentes generados
#   Expansión de _base.md en generados
```

### Qué commitear y qué gitignorear

Cuando adoptas este template en tu proyecto, algunos ficheros son **fuente** (commitear) y otros son **generados** por `sync.sh` (gitignorear). El `.gitignore` incluido en el template ya lo maneja, pero aquí tienes el detalle:

| Fichero/Directorio | ¿Commitear? | Por qué |
|---|---|---|
| `.ai/` (directorio completo) | **Sí** | Fuente de verdad: agentes, skills, hooks, prompts, templates |
| `CLAUDE.md` | **Sí** | Config principal, rellenado por bootstrap |
| `AGENTS.md` | **Sí** | Config OpenCode, rellenado por bootstrap |
| `.claude/settings.json` | **Sí** | Config de hooks + MCP (compartido con el equipo) |
| `.claudeignore` | **Sí** | Indica a Claude Code qué ignorar |
| `docs/` | **Sí** | Specs, ADRs, guías |
| `.claude/agents/` | **No** | Generado por `sync.sh` desde `.ai/agents/` |
| `.claude/rules/` | **No** | Copias generadas de decisions.md + project-context.md |
| `.claude/skills` | **No** | Enlace simbólico a `.ai/skills` |
| `.opencode/` | **No** | Enlaces simbólicos + copias, generado por `sync.sh` |
| `.cursorrules` | **No** | Reglas compactas generadas |
| `.windsurfrules` | **No** | Reglas compactas generadas |
| `GEMINI.md` | **No** | Reglas compactas generadas |
| `.github/copilot-instructions.md` | **No** | Reglas compactas generadas |
| `.ai/.local/` | **No** | Estado de sesión, local por desarrollador |

> **Regla:** si `sync.sh` lo genera, gitignórealo. Si lo editas a mano, commitéalo.

El `.gitignore` incluido ya tiene estas entradas. Si tu proyecto tiene un `.gitignore` existente, fusiona las entradas del template con las tuyas.

## Prompts reutilizables

| Prompt | Cuando usarlo | Obligatorio | Que genera |
|---|---|---|---|
| `prompts/es/bootstrap.md` | Al adoptar el template (día 0) | Sí | project-context.md, CLAUDE.md, AGENTS.md, decisions.md, skills |
| `prompts/es/feature-spec.md` | Antes de implementar una feature compleja | No | docs/specs/FEAT-XXX-nombre.md |
| `prompts/es/refine-skills.md` | Después de 2-3 features implementadas | No | Skills refinados con patrones reales del proyecto |
| `prompts/es/legacy-audit.md` | Antes de modernizar código legacy | No | docs/legacy-audit.md con inventario, riesgos y plan |

**Bootstrap** es el único obligatorio. **Feature Spec** es opcional (ver sección "Memoria persistente > Feature Specs"). **Refine Skills** mejora los skills genéricos del bootstrap con patrones reales de tu código. **Legacy Audit** analiza código existente y propone un plan de modernización incremental (Flujo 5 del orchestrator).

## Agentes incluidos

11 agentes especializados (subagent) + orchestrator (routing, solo OpenCode) + project-context (contexto compartido) + _base (boilerplate).

| Agente | Misión | Gates clave |
|---|---|---|
| product-owner | User Stories con ROI | Formato US, criterios medibles, valor claro |
| architect | Integridad arquitectonica, dependency rule | Domain puro, flujo e2e, contratos completos |
| tdd-developer | RED-GREEN-REFACTOR | Test falla primero, ambas suites, DI compila |
| database-engineer | Schema + migraciones | Reversibles, índices, mapeo ORM verificado |
| security-auditor | OWASP Top 10:2025 | Inputs validados, sin secrets, supply chain, excepciones + gates condicionales (auth, passwords, uploads, CSRF, cookies, SSRF) |
| qa-engineer | Coverage 100/80/0 | Piramide testing, sin tests ignorados |
| performance-engineer | Core Web Vitals | p95 < 200ms, LCP/FID/CLS, bundle < 100KB |
| devops | CI/CD + Git workflow | Pipeline verde, infra declarativa, deployment readiness, PR docs |
| observability-engineer | Metrics + logs | Metricas negocio, logs JSON, health checks |
| technical-writer | Docs vivas | Ejemplos funcionales, ADRs completos, setup < 15min |
| ux-designer | WCAG 2.2 AA | Contraste 4.5:1, targets 44x44px, teclado |

## Postura arquitectonica: Clean Architecture (opinionated)

Este template asume **Clean Architecture** (dependency rule, domain puro). Los Quality Gates del `@architect` validan:

- El Dominio no importa clases de Infraestructura
- La lógica de negocio vive en Domain, no en Controllers ni Models del framework
- Los contratos (interfaces) entre capas transportan todos los datos necesarios

Estos principios son compartidos por Clean Architecture, Hexagonal (Ports & Adapters) y Onion Architecture — los tres son compatibles con el template.

### Compatibilidad por patrón arquitectonico

| Patron | Compatible | Motivo |
|---|---|---|
| Clean Architecture | Si | Los gates estan disenados para este patrón |
| Hexagonal (Ports & Adapters) | Si | Mismo principio: dependency rule, domain al centro |
| Onion Architecture | Si | Predecesor de Clean Architecture, mismos principios |
| MVC puro (Laravel, Django, Rails) | **No** | El Model hereda del ORM, Domain y Infrastructure acoplados. Los gates del architect estarian en conflicto permanente |
| MVC + Clean Architecture (Laravel Beyond CRUD) | Si | Si separas Domain del ORM, los gates aplican |

### Por que no soportar MVC

En MVC puro, `User extends Model` — la entidad **es** el ORM. La lógica de negocio vive en Controllers o Models. No hay capas separadas. Esto contradice los gates fundamentales del template:

- **Architect Gate 1** (entidades sin dependencias externas) → en MVC, la entidad hereda del framework
- **Architect Gate 2** (lógica en Domain) → en MVC, vive en Controllers
- **TDD Gate 4** (DI compila) → MVC usa facades y auto-wiring implícito

**Conclusion:** Si tu proyecto usa MVC puro, este template no es para ti. Si usas cualquier variante con dependency rule y domain puro, funciona independientemente del framework.

## Por que existen estos gates

Los Quality Gates no son teoria. Nacieron de cadenas reales de PRs correctivos donde un error no detectado provoco múltiples fixes consecutivos:

| Cadena de error | PRs correctivos | Causa raíz | Gate que lo previene |
|---|---|---|---|
| Integracion ORM rota | 3 consecutivos | DI no verificado tras GREEN | tdd-developer Gate 4: verificar DI compila |
| Cascade de deployment | 9 consecutivos | Sin health check ni env vars | devops Gates 3-4: readiness check |
| Security/CSP headers | 5 consecutivos | Security y observability no coordinados | Verificación cruzada entre agentes |
| Auditoria reactiva | 6 consecutivos | Gates sin paso de verificación final | Verificación Final en cada agente |

Cada gate existe porque su ausencia causo trabajo repetido y evitable.

## Ahorro de tokens

### Estrategia de idiomas

Todos los ficheros que consume la IA (agentes, skills, decisions, templates, hooks) están escritos en **inglés** para minimizar el uso de tokens. El inglés es más eficiente en tokens que la mayoría de idiomas, lo que significa menor coste y más espacio en la ventana de contexto.

Los ficheros para el usuario (README, guías) son bilingües: inglés primario (`README.md`, `docs/guides/`) + español (`README.es.md`, `docs/guides/es/`). El output de proyecto (specs, ADRs, docs) puede estar en el idioma que prefiera el usuario.

### Decisiones de diseño

Cada decisión de diseño del template reduce el consumo de tokens:

| Mejora | Por qué ahorra tokens |
|---|---|
| Inglés para ficheros IA | ~20-30% menos tokens que español/otros idiomas para el mismo contenido |
| `project-context.md` | Restricciones del proyecto en 1 fichero. Sin él, cada agente las repite en su prompt |
| `decisions.md` | Decisiones rápidas (~30 líneas). Evita re-descubrir o preguntar lo ya decidido |
| Feature Specs | Un spec compartido reemplaza N explicaciones parciales a N agentes |
| Reglas compactas | `sync.sh` genera 1 fichero para Cursor/Windsurf/Gemini/Copilot vs 11 agentes completos |
| Agentes bajo demanda | Solo se carga el agente invocado, no los 11 |
| Sub-CLAUDE.md por módulo | `backend/CLAUDE.md` no se carga al trabajar en frontend |
| `_base.md` + expansión | Boilerplate compartido en fuente, expandido en generados |

## Optimización de tokens

### Jerarquía de carga

```
Siempre cargado (cada mensaje):
  └── CLAUDE.md / AGENTS.md         → MANTENER < 120 líneas

Bajo demanda (solo cuando se invoca):
  ├── .ai/agents/*.md               → Sin limite
  └── .ai/skills/*.md               → Sin limite

Por directorio (solo en ese contexto):
  ├── backend/CLAUDE.md             → Stack backend
  └── frontend/CLAUDE.md            → Stack frontend
```

### Recomendaciones
- El fichero principal NO debe incluir: templates, snippets, checklists, workflows detallados
- Los roles en el fichero principal son una lista compacta (1 línea por rol)
- Los detalles de cada rol van en `.ai/agents/{rol}.md`
- Los detalles del framework van en `.ai/skills/{skill}/SKILL.md`
- Crear sub-CLAUDE.md por módulo para contexto específico del stack

## Orchestrator y verificación cruzada

El `orchestrator.md` es el agente principal (mode: `primary`) que:
1. **Routing**: analiza la intención del usuario y enruta al agente correcto
2. **Verificación cruzada**: después de implementar, coordina rondas de revisión entre agentes

### El problema que resuelve

Sin verificación cruzada, cada agente trabaja aislado. El @tdd-developer puede escribir tests que pasan pero el @architect no verifica que los datos fluyen correctamente entre capas. El resultado: bugs que ningun agente individual detecta.

### Patron de verificación cruzada

```
@tdd-developer (implementa)
       |
       v
@architect (verifica flujo de datos e2e entre capas)
       |
   Problemas? --Si--> @tdd-developer (corrige) --> volver a @architect
       |
       No
       v
@security-auditor (revisa OWASP)
       |
   Problemas? --Si--> @tdd-developer (corrige) --> volver a @security-auditor
       |
       No
       v
Listo para commit
```

### Cuando aplicar
- Se modifican contratos (interfaces) entre capas
- Se añade un nuevo endpoint o servicio
- Se modifica la capa de Infrastructure (DI, persistencia)

### Cuando NO aplicar
- Fixes puntuales dentro de una sola capa
- Cambios de documentación
- Refactors que no alteran contratos

### Comportamiento segun herramienta

| Herramienta | Quien ejecuta el patrón |
|---|---|
| OpenCode | `orchestrator.md` (agente primary, lo ejecuta automáticamente) |
| Claude Code | La sesión principal (lee el Workflow en CLAUDE.md) + gates de cada agente |
| Agent Teams (experimental) | Los teammates se comunican directamente entre ellos |

**Nota sobre Claude Code:** no usa `orchestrator.md` (hace routing automático). El patrón de verificación cruzada se implementa via los Quality Gates de cada agente (ej: Gate 4 del @tdd-developer dice "verificar que el DI compila y ambas suites pasan") y el Workflow en `CLAUDE.md`. El `sync.sh` excluye el orchestrator al generar `.claude/agents/`.

**Nota sobre Agent Teams:** Claude Code tiene una feature experimental ([agent teams](https://code.claude.com/docs/en/agent-teams)) donde múltiples instancias se comunican directamente entre si. Con agent teams, la verificación cruzada seria nativa: el @architect teammate enviaria un mensaje al @tdd-developer teammate sin intermediario. Los agentes de este template son compatibles con agent teams (cada teammate carga su `agents/*.md` automáticamente).

## Donde implementar la verificación cruzada

La verificación cruzada se puede implementar de 3 formas. No son excluyentes, pero **no dupliques**:

### Opción 1: En los Quality Gates de cada agente (recomendado)

Los gates de cada agente ya incluyen verificaciones que fuerzan la coordinación:

```markdown
# tdd-developer.md - Gate 4
Verificar integración después de GREEN:
  - El contenedor de dependencias compila sin errores
  - Ambas suites de tests pasan (Unit + Functional)

# architect.md - Gate 3
Verificar flujo de datos e2e entre capas:
  - Los contratos definen TODOS los parámetros necesarios
  - El dato fluye completo entre capas sin perdida
```

**Ventaja:** La verificación esta embebida en el agente. No necesita coordinación externa.
**Coste tokens:** 0 extra (los gates ya se cargan con el agente).
**Compatible con:** Todas las herramientas.

### Opción 2: En el orchestrator (OpenCode)

El `orchestrator.md` ejecuta el flujo secuencial automáticamente. Util cuando la herramienta tiene un agente primary que coordina a los demas.

**Ventaja:** Flujo explícito, el orchestrator decide cuando lanzar cada verificación.
**Coste tokens:** Bajo (el orchestrator se carga una vez).
**Compatible con:** OpenCode y herramientas con agente primary.

### Opción 3: Agent Teams (Claude Code experimental)

Los teammates se envian mensajes directamente. La verificación es nativa y paralela.

```
@architect → mensaje a @tdd-developer: "el DTO necesita el campo label"
@tdd-developer → mensaje a @architect: "anadido, revisa el contrato"
@security-auditor → mensaje a ambos: "sanitizad el label contra injection"
```

**Ventaja:** Debate real en paralelo, sin intermediario.
**Coste tokens:** Alto (cada teammate es una instancia completa).
**Compatible con:** Solo Claude Code (experimental, requiere `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### Que NO hacer

- **No duplicar** el patrón en CLAUDE.md si ya esta en los gates de los agentes. El CLAUDE.md se carga en cada mensaje y duplicar la verificación desperdicia tokens sin beneficio.
- **No activar agent teams por defecto.** Usarlo puntualmente para features complejas que tocan múltiples capas simultaneamente (frontend + backend + tests).
- **No añadir verificación cruzada a todo.** Solo aplica cuando se modifican contratos entre capas, se añaden endpoints, o se toca Infrastructure. Un fix puntual no lo necesita.

### Resumen

| Estrategia | Tokens | Paralelismo | Complejidad | Cuando usar |
|---|---|---|---|---|
| Gates en agentes | 0 extra | No (secuencial) | Baja | Siempre (base) |
| Orchestrator | Bajo | No (secuencial) | Media | OpenCode / herramientas con primary agent |
| Agent Teams | Alto | Si (real) | Alta | Features complejas multi-capa, puntualmente |

Empieza con los gates (opción 1). Si necesitas coordinación explícita en OpenCode, usa el orchestrator (opción 2). Si una feature toca muchas capas y necesitas debate real, prueba agent teams (opción 3).

## Como funciona Claude Code (y por que importa para los agentes)

Claude Code es un agente que corre en tu terminal. Funciona en un bucle de 3 fases:

```
Tu prompt → Recopilar contexto → Actuar → Verificar → Repetir hasta completar
                   ↑                                          |
                   └──── Tu puedes interrumpir en cualquier punto
```

### Que puede acceder

| Recurso | Descripción |
|---------|-------------|
| Tu proyecto | Ficheros, estructura, dependencias |
| Terminal | Cualquier comando (git, npm, docker, etc.) |
| CLAUDE.md | Instrucciones persistentes (se carga en CADA mensaje) |
| .ai/agents/*.md | Agentes bajo demanda (se cargan solo cuando se invoca el rol) |
| .ai/skills/*.md | Skills bajo demanda (se cargan solo cuando se consultan) |
| MCP servers | Herramientas externas (BD, docs, error tracking, etc.) |

### Gestión del contexto

La ventana de contexto se llena con: historial de conversacion, ficheros leidos, outputs de comandos, CLAUDE.md, skills cargados y tool definitions de MCP.

```
Siempre en contexto (cada mensaje):
  ├── CLAUDE.md                    → MANTENER < 120 líneas
  ├── Tool definitions de MCP      → Cada MCP añade sus tools
  └── Historial de conversacion    → Se compacta automáticamente

Bajo demanda (solo cuando se usa):
  ├── .ai/agents/*.md              → Se carga al invocar el rol
  ├── .ai/skills/*.md              → Se carga al consultar
  └── Subagents                    → Contexto separado (no inflan el tuyo)
```

**Comandos útiles:**
- `/context` - Ver que esta usando espacio en la ventana de contexto
- `/compact` - Compactar manualmente (ej: `/compact focus on the API changes`)
- `/mcp` - Ver estado y coste en tokens de cada MCP server

**Implicacion para este template:** Por eso el CLAUDE.md debe ser compacto (~100 líneas). Los detalles van en `.ai/agents/` y `.ai/skills/` que solo se cargan cuando se necesitan. Si duplicas contenido de los agentes en el CLAUDE.md, desperdicias tokens en cada mensaje.

## MCP Servers recomendados

Los MCP (Model Context Protocol) servers extienden las capacidades de Claude Code conectandolo a herramientas externas. Se configuran una vez y estan disponibles en cada sesión.

### Para cualquier proyecto de desarrollo

| MCP | Que aporta | Comando |
|-----|-----------|---------|
| **Context7** | Documentación actualizada de cualquier libreria en tiempo real. Evita que Claude use APIs obsoletas o patrones deprecated. | `claude mcp add context7 -- npx -y @upstash/context7-mcp@latest` |

### Según tu stack (añadir si aplica)

| MCP | Que aporta | Comando |
|-----|-----------|---------|
| **PostgreSQL** | Consultar schema, tablas e índices desde la sesión | `claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "postgresql://user:pass@host:5432/db"` |
| **Sentry** | Debuggear errores de producción directamente | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |
| **GitHub** | PRs, issues, CI/CD sin salir de Claude | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| **Linear** | Gestión de issues y proyectos | `claude mcp add --transport http linear https://mcp.linear.app/mcp` |
| **Atlassian** | Jira + Confluence | `claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp` |

### MCPs que NO necesitas

| MCP | Razon |
|-----|-------|
| Filesystem | Claude Code ya tiene Read/Write/Edit/Glob/Grep nativos |
| Docker | Los comandos docker via Bash son suficientes |
| Git | Claude Code ya tiene integración nativa con git |

### Gestión de MCPs

```bash
# Instalar un MCP
claude mcp add <nombre> -- <comando>

# Listar MCPs configurados
claude mcp list

# Ver detalles de un MCP
claude mcp get context7

# Eliminar un MCP
claude mcp remove context7

# Dentro de Claude Code: ver estado y coste
/mcp

# Autenticar MCPs remotos que usan OAuth
/mcp → seleccionar servidor → Authenticate
```

### Scopes (donde se guarda la configuración)

| Scope | Flag | Donde se guarda | Para que |
|-------|------|-----------------|----------|
| `local` | (default) | `~/.claude.json` | Solo tu, solo este proyecto |
| `project` | `--scope project` | `.mcp.json` (raíz del proyecto) | Compartido con el equipo (committear a git) |
| `user` | `--scope user` | `~/.claude.json` | Tu, en todos tus proyectos |

```bash
# MCP disponible en todos tus proyectos
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest

# MCP compartido con el equipo (se guarda en .mcp.json)
claude mcp add --scope project --transport http sentry https://mcp.sentry.dev/mcp
```

### Coste en tokens de los MCPs

Cada MCP añade sus tool definitions al contexto de cada mensaje. Con 2-3 MCPs el impacto es bajo. Si tienes muchos, Claude Code activa **Tool Search** automáticamente: en vez de cargar todas las tools, las busca bajo demanda.

```bash
# Ver cuantos tokens consume cada MCP
/mcp

# Forzar Tool Search (si tienes muchos MCPs)
ENABLE_TOOL_SEARCH=true claude

# Desactivar Tool Search
ENABLE_TOOL_SEARCH=false claude
```

**Recomendación:** Instala solo los MCPs que uses activamente. Context7 es el único universalmente útil para desarrollo. El resto depende de tu stack y fase del proyecto.

## Ciclo de vida de un agente

Los agentes son **efímeros**: nacen limpios, ejecutan su tarea y mueren. No tienen memoria entre sesiones.

```
Orquestador invoca agente
       |
       v
  Nace limpio (carga solo su .md + skills relevantes)
       |
       v
  Ejecuta (trabaja con contexto mínimo)
       |
       v
  Reporta (devuelve summary al orquestador)
       |
       v
  Muere (contexto descartado)
```

**Input:** El agente recibe del orquestador solo el contexto necesario para su tarea.
**Ejecucion:** Carga sus Quality Gates y los skills relevantes. No hereda contexto de otros agentes.
**Output:** Devuelve un resumen. El orquestador decide el siguiente paso.

## Anti-patrón: el agente que hace todo

Un error comun es usar un solo agente para analizar, diseñar, implementar, testear y documentar. Esto falla porque:

- La ventana de contexto se llena al 80% antes de escribir la primera línea de código
- Los Quality Gates de distintos roles pueden entrar en conflicto
- El agente empieza a alucinar cuando el contexto se satura

**Regla:** Si la tarea requiere múltiples fases (diseño + implementación + testing), delegar a sub-agentes especializados. Cada uno trabaja con contexto limpio.

## Model routing por agente

Cada agente puede usar el modelo más adecuado para su tarea:

| Rol | Modelo sugerido | Razon |
|---|---|---|
| @architect, @product-owner | Razonamiento (Gemini, o1) | Analisis, diseño, decisiones |
| @tdd-developer | Código (Opus, Claude) | Mejor en implementación |
| @security-auditor | Código (Opus, Claude) | Analisis profundo de código |
| @technical-writer | General (Sonnet, GPT-4o) | Documentación, suficiente calidad |
| @devops | Rapido (Haiku, GPT-4o-mini) | Scripts, configs, tareas repetitivas |

**Estado actual:** Claude Code usa un modelo por sesión. OpenCode soporta model routing. Documentado como patrón futuro para cuando las herramientas lo soporten nativamente.

## Memoria persistente entre sesiones

Los agentes son efímeros, pero el conocimiento del proyecto debe persistir. Tres mecanismos complementarios:

### 1. `.claude/rules/` (siempre cargado, 0 esfuerzo)

`sync.sh` copia `decisions.md` y `project-context.md` a `.claude/rules/`. Claude Code los carga automáticamente en cada mensaje. Coste: ~50 líneas por mensaje. Beneficio: la IA siempre tiene contexto del proyecto sin que nadie se lo pida.

### 2. Feature Specs (`docs/specs/FEAT-XXX.md`) — opcional

Especificaciones técnicas antes de implementar. El sistema de agentes funciona sin specs, pero un spec añade valor en situaciones concretas:

| Situación | Sin spec | Con spec | Recomendación |
|---|---|---|---|
| Claude Code/OpenCode + agentes | Funciona bien (agentes tienen gates) | Mejor organizado | Opcional |
| Feature compleja (5+ endpoints) | Contexto se puede perder en sesiones largas | El spec ancla decisiones | Recomendado |
| Cursor/Windsurf/Gemini/Copilot | Cada prompt repite contexto parcialmente | El spec centraliza | Casi imprescindible |
| Equipo (varios devs o sesiones) | Cada sesión interpreta distinto | El spec alinea a todos | Recomendado |
| Feature con seguridad/privacidad | Se puede olvidar algun vector | Obliga a pensarlo antes | Recomendado |

**Regla simple:** Si puedes explicar la feature en 2 frases y afecta 1-2 archivos, no necesitas spec. Si necesitas pensar antes de codear, hazlo.

Para generar un spec, usar el prompt `.ai/prompts/es/feature-spec.md`. Cada agente extrae lo que necesita:

| Agente | Que extrae del spec |
|---|---|
| @tdd-developer | Endpoints, payloads, errores → tests |
| @security-auditor | Inputs, rate limits → validaciones |
| @architect | Capas, contratos → verificación |
| @database-engineer | Schema, índices → migraciones |

Template en `docs/specs/FEAT-TEMPLATE.md`.

#### Documentación en cada PR

La documentación se incluye en la misma PR que el código, no en PRs separadas:

| Aspecto | Docs en misma PR | Docs en PR separada |
|---|---|---|
| Contexto | El agente ya tiene el código cargado | Hay que re-cargar contexto |
| Coherencia | Docs reflejan el código exacto | Riesgo de drift |
| Review | Un solo review cubre código + docs | Dos reviews, doble coste |
| Tokens | 0 extra (mismo contexto) | Sesión adicional completa |

El `devops.md` Gate 5 incluye: "La PR incluye documentación actualizada (README, ADR si aplica, CHANGELOG)".

### 3. Hooks + Engram MCP (memoria automatica, Claude Code)

Para Claude Code, los hooks automatizan la gestión de memoria sin esfuerzo de la IA:

```
┌─────────────────────────────────────────────────────┐
│ Capa 1: .claude/rules/ (AUTO-CARGADO, siempre)      │
│ → decisions.md, project-context.md                   │
│ → 0 esfuerzo, 0 olvidos                             │
├─────────────────────────────────────────────────────┤
│ Capa 2: Hooks (AUTOMATICO, en eventos)               │
│ → SessionStart: inyecta ultimo contexto              │
│ → PreCompact: guarda estado antes de perder contexto │
│ → SessionEnd: guarda resumen de sesión                │
├─────────────────────────────────────────────────────┤
│ Capa 3: Engram MCP (BAJO DEMANDA)                    │
│ → mem_search, mem_save, mem_context                  │
│ → Solo cuando la IA necesita más contexto            │
└─────────────────────────────────────────────────────┘
```

[Engram](https://github.com/Gentleman-Programming/engram) es un binario Go con SQLite + FTS5 que ofrece memoria persistente via MCP. Cross-tool (Claude Code, OpenCode, Cursor, Windsurf, Gemini CLI). Local y privado.

**Sin Engram:** Los hooks guardan en archivos locales (`.ai/.local/`) como fallback.
**Con Engram:** Busqueda full-text, deduplicacion, multi-proyecto.

### Memoria por herramienta

| Herramienta | Memoria automatica | Memoria de proyecto | Nivel |
|---|---|---|---|
| Claude Code | `.claude/rules/` + Hooks + Engram MCP | Feature Specs + decisions.md | Idoneo |
| OpenCode | `AGENTS.md` + Engram MCP | Feature Specs + decisions.md | Aceptable |
| Cursor/Windsurf | compact rules + Engram MCP (si soporta) | Feature Specs + decisions.md | Limitado |
| Gemini | `GEMINI.md` + Engram MCP (si soporta) | Feature Specs + decisions.md | Limitado |
| Copilot | copilot-instructions.md | Feature Specs + decisions.md | Minimo |

## project-context.md

Fichero en `.ai/agents/` que contiene restricciones especificas del proyecto. Todos los agentes lo leen pero no es invocable (mode: context). Se copia automáticamente a `.claude/rules/` para ser auto-cargado.

Incluye sección "Rutas de Artefactos" para que los agentes sepan donde crear sus documentos (docs, ADRs, specs, stories, etc.).

Rellenar con: dominio, usuarios, restricciones no negociables, decisiones técnicas, límites de APIs, comandos de test.

## Guias adicionales

| Guia | Descripción |
|---|---|
| **[MCPs recomendados](docs/guides/recommended-mcps.md)** | MCPs básicos y opcionales por stack, con configuración para cada herramienta (Claude Code, OpenCode, Cursor, Copilot) |
| **[Git hooks recomendados](docs/guides/recommended-hooks.md)** | Hooks mínimos (commitlint, linter, formatter, secrets scan, tests), con ejemplos de Lefthook y Husky |
| **[GitHub Actions workflows](docs/guides/recommended-workflows.md)** | CI/CD mínimo (CI backend/frontend, commitlint, security review con Claude Code action, deploy, Dependabot), con branch strategy para agentes |
| **[Modelos recomendados](docs/guides/recommended-models.md)** | Que modelo usar para cada agente/tarea, estrategia de costes, modelos gratuitos y de pago |
| **[Inicio rápido](docs/guides/getting-started.md)** | De cero a agentes funcionando en 5 minutos |

## Inspiración y referencias

- **[Engram](https://github.com/Gentleman-Programming/engram)** — Memoria persistente cross-tool via MCP (Gentleman Programming)
- **[AGENTS.md](https://github.com/anthropics/agents-md)** — Estandar emergente para definición de agentes (Linux Foundation + Anthropic + OpenAI)
- **[LIDR ai-specs](https://github.com/LIDR-ai/ai-specs)** — Single source of truth multi-copilot, patrón plan-then-execute
- **[Anthropic Context Engineering](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)** — Principios de gestión de contexto para agentes
- **[OWASP Top 10:2025](https://owasp.org/Top10/)** — Base del @security-auditor (A03 Supply Chain, A10 Exception Handling)

## Licencia

Apache License 2.0 — Uso libre (incluido comercial) con atribución obligatoria.

Si usas este template en tu proyecto, debes mantener el fichero `NOTICE` con la atribución al autor original. Ver [LICENSE](LICENSE) para los términos completos.
