# AI Dev Agents Template

Reusable template for AI-assisted development with specialized agents. Language, framework and AI tool agnostic. Supports Clean Architecture, MVC, MVVM and None (~90% of all software projects).

## Structure

```
.ai/
├── agents/         # 11 agents + orchestrator + project-context + _base (canonical source)
├── skills/         # Stack-specific skills (framework-specific)
├── hooks/          # Automatic memory scripts (Claude Code)
├── prompts/        # Reusable prompts (bootstrap, etc.)
├── templates/      # CLAUDE.md.template and AGENTS.md.template
├── tool-configs/   # Per-tool documentation
├── decisions.md    # Quick technical decisions
├── sync.sh         # Generates files for all tools
└── test.sh         # Validates template structure
```

## Quick Start

### Option A: Automatic bootstrap (recommended)

1. Copy `.ai/` to your project
2. Open your AI tool (Claude Code, OpenCode, Cursor, etc.)
3. Paste the content of `.ai/prompts/bootstrap.md` as a prompt
4. The LLM analyzes your project (or asks if it's new) and generates:
   - `.ai/agents/project-context.md` (filled)
   - `CLAUDE.md` (filled)
   - `AGENTS.md` (filled, if using OpenCode)
   - `.ai/decisions.md` (with initial decisions)
   - `.ai/skills/` (basic stack skills, marked `> REVIEW`)
5. Run `.ai/sync.sh`
6. Run `.ai/test.sh` to validate

### Option B: Manual

1. Copy `.ai/` to your project
2. Fill `.ai/agents/project-context.md` with your project context
3. Copy `.ai/templates/CLAUDE.md.template` to `CLAUDE.md` at the root and fill it
4. Copy `.ai/templates/AGENTS.md.template` to `AGENTS.md` at the root (if using OpenCode)
5. Create skills in `.ai/skills/{name}/SKILL.md`
6. Run `.ai/sync.sh`

## Agents

| Agent | Mission | Mode |
|-------|---------|------|
| orchestrator | Routing + cross-verification | primary |
| project-context | Shared project context | context |
| product-owner | User Stories with ROI | subagent |
| architect | Clean Architecture (read-only) | subagent |
| tdd-developer | RED-GREEN-REFACTOR | subagent |
| database-engineer | Schema, migrations, optimization | subagent |
| security-auditor | OWASP Top 10 (audit-only) | subagent |
| qa-engineer | Coverage 100/80/0 (audit-only) | subagent |
| performance-engineer | Data-driven optimization | subagent |
| devops | CI/CD, Docker, Git workflow | subagent |
| observability-engineer | Metrics, logs, tracing | subagent |
| technical-writer | Living documentation | subagent |
| ux-designer | Accessibility and inclusion | subagent |

## Memory per Tool

| Tool | Automatic Memory | Project Memory | Level |
|------|-----------------|----------------|-------|
| Claude Code | .claude/rules/ + Hooks + Engram MCP | Feature Specs + decisions.md | Ideal |
| OpenCode | AGENTS.md + Engram MCP | Feature Specs + decisions.md | Acceptable |
| Cursor/Windsurf | compact rules + Engram MCP (if supported) | Feature Specs + decisions.md | Limited |
| Gemini | GEMINI.md + Engram MCP (if supported) | Feature Specs + decisions.md | Limited |
| Copilot | copilot-instructions.md | Feature Specs + decisions.md | Minimal |

## Per-module Conventions

For multi-module projects (backend + frontend, monorepo, etc.):

| Tool | Mechanism | Example |
|---|---|---|
| Claude Code | `CLAUDE.md` in subfolder | `backend/CLAUDE.md` (hierarchical, native) |
| Cursor | `.cursor/rules/*.mdc` with globs | `globs: backend/**/*.php` |
| Others | Per-module skills | `.ai/skills/symfony/SKILL.md` |

## Reusable Prompts

| Prompt | When to use | Required | What it generates |
|--------|-------------|----------|-------------------|
| `prompts/bootstrap.md` | When adopting the template (day 0) | Yes | project-context.md, CLAUDE.md, AGENTS.md, decisions.md, skills |
| `prompts/feature-spec.md` | Before implementing a feature | No | docs/specs/FEAT-XXX-name.md |
| `prompts/refine-skills.md` | After 2-3 features | No | Refined skills with real patterns |
| `prompts/legacy-audit.md` | Before modernizing legacy code | No | docs/legacy-audit.md with inventory, risks and plan |
| `prompts/code-review.md` | Before opening a PR | No | Multi-agent review (architecture + security + testing + quality) |

**Feature Specs (optional):** With Claude Code/OpenCode + agents, the system works without specs.
But for complex features, teams, or tools without agents (Cursor, Windsurf), a spec centralizes
context and avoids repetition. See `prompts/feature-spec.md` for when and why to use them.

**Skill lifecycle:**
1. **Bootstrap** generates skills with generic best practices (marked `> REVIEW`)
2. Features are implemented using the agents and generic skills
3. **Refine-skills** analyzes real code and rewrites skills with project patterns
4. Refined skills no longer carry the `> REVIEW` notice

## Key Principle

**Agents define WHAT to verify** (agnostic Quality Gates).
**Skills define HOW to do it** (framework-specific knowledge).
