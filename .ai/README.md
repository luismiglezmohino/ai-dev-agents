# AI Dev Agents Template

Template reutilizable y agnóstico para desarrollo asistido por IA con agentes especializados.

## Estructura

```
.ai/
├── agents/         # 11 agentes + orchestrator + project-context + _base (fuente canonica)
├── skills/         # Skills específicos del stack (framework-specific)
├── hooks/          # Scripts de memoria automatica (Claude Code)
├── prompts/        # Prompts reutilizables (bootstrap, etc.)
├── templates/      # CLAUDE.md.template y AGENTS.md.template
├── tool-configs/   # Documentación por herramienta
├── decisions.md    # Decisiones técnicas rápidas
├── sync.sh         # Genera archivos para todas las herramientas
└── test.sh         # Valida estructura del template
```

## Uso rápido

### Opción A: Bootstrap automático (recomendado)

1. Copiar `.ai/` a tu proyecto
2. Abrir tu herramienta de IA (Claude Code, OpenCode, Cursor, etc.)
3. Pegar el contenido de `.ai/prompts/bootstrap.md` como prompt
4. El LLM analiza tu proyecto (o te pregunta si es nuevo) y genera:
   - `.ai/agents/project-context.md` (relleno)
   - `CLAUDE.md` (relleno)
   - `AGENTS.md` (relleno, si usas OpenCode)
   - `.ai/decisions.md` (con decisiones iniciales)
   - `.ai/skills/` (skills básicos del stack, marcados `> REVISAR`)
5. Ejecutar `.ai/sync.sh`
6. Ejecutar `.ai/test.sh` para validar

### Opción B: Manual

1. Copiar `.ai/` a tu proyecto
2. Rellenar `.ai/agents/project-context.md` con el contexto de tu proyecto
3. Copiar `.ai/templates/CLAUDE.md.template` a `CLAUDE.md` en la raíz y rellenar
4. Copiar `.ai/templates/AGENTS.md.template` a `AGENTS.md` en la raíz (si usas OpenCode)
5. Crear skills en `.ai/skills/{nombre}/SKILL.md`
6. Ejecutar `.ai/sync.sh`

## Agentes

| Agente | Misión | Mode |
|--------|--------|------|
| orchestrator | Routing + verificación cruzada | primary |
| project-context | Contexto compartido del proyecto | context |
| product-owner | User Stories con ROI | subagent |
| architect | Clean Architecture (read-only) | subagent |
| tdd-developer | RED-GREEN-REFACTOR | subagent |
| database-engineer | Schema, migraciones, optimización | subagent |
| security-auditor | OWASP Top 10 (audit-only) | subagent |
| qa-engineer | Coverage 100/80/0 (audit-only) | subagent |
| performance-engineer | Optimización con datos reales | subagent |
| devops | CI/CD, Docker, Git workflow | subagent |
| observability-engineer | Metricas, logs, tracing | subagent |
| technical-writer | Documentación viva | subagent |
| ux-designer | Accesibilidad e inclusión | subagent |

## Memoria por herramienta

| Herramienta | Memoria automatica | Memoria de proyecto | Nivel |
|-------------|-------------------|-------------------|-------|
| Claude Code | .claude/rules/ + Hooks + Engram MCP | Feature Specs + decisions.md | Idoneo |
| OpenCode | AGENTS.md + Engram MCP | Feature Specs + decisions.md | Aceptable |
| Cursor/Windsurf | compact rules + Engram MCP (si soporta) | Feature Specs + decisions.md | Limitado |
| Gemini | GEMINI.md + Engram MCP (si soporta) | Feature Specs + decisions.md | Limitado |
| Copilot | copilot-instructions.md | Feature Specs + decisions.md | Minimo |

## Convenciones por módulo

Para proyectos multi-módulo (backend + frontend, monorepo, etc.):

| Herramienta | Mecanismo | Ejemplo |
|---|---|---|
| Claude Code | `CLAUDE.md` en subcarpeta | `backend/CLAUDE.md` (jerarquico, nativo) |
| Cursor | `.cursor/rules/*.mdc` con globs | `globs: backend/**/*.php` |
| Resto | Skills por módulo | `.ai/skills/symfony/SKILL.md` |

## Prompts reutilizables

| Prompt | Cuando usarlo | Obligatorio | Que genera |
|--------|---------------|-------------|------------|
| `prompts/bootstrap.md` | Al adoptar el template (día 0) | Si | project-context.md, CLAUDE.md, AGENTS.md, decisions.md, skills |
| `prompts/feature-spec.md` | Antes de implementar una feature | No | docs/specs/FEAT-XXX-nombre.md |
| `prompts/refine-skills.md` | Después de 2-3 features | No | Skills refinados con patrones reales |
| `prompts/legacy-audit.md` | Antes de modernizar código legacy | No | docs/legacy-audit.md con inventario, riesgos y plan |

**Feature Specs (opcional):** Con Claude Code/OpenCode + agentes, el sistema funciona sin specs.
Pero para features complejas, equipos, o herramientas sin agentes (Cursor, Windsurf), un spec centraliza
el contexto y evita repetición. Ver `prompts/feature-spec.md` para cuando y por que usarlos.

**Ciclo de vida de los skills:**
1. **Bootstrap** genera skills con best practices genéricas (marcados `> REVISAR`)
2. Se implementan features usando los agentes y skills genéricos
3. **Refine-skills** analiza el código real y reescribe los skills con patrones del proyecto
4. Los skills refinados ya no llevan el aviso `> REVISAR`

## Principio clave

**Agentes definen QUE verificar** (Quality Gates agnósticos).
**Skills definen COMO hacerlo** (conocimiento específico del framework).
