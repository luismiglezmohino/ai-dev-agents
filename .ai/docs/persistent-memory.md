# Persistent Memory Between Sessions

[🇪🇸 Leer en español](es/persistent-memory.md)

> Back to [README](../../README.md)

## Persistent Memory Between Sessions

Agents are ephemeral, but project knowledge must persist. Three complementary mechanisms:

### 1. `.claude/rules/` (always loaded, 0 effort)

`sync.sh` copies `decisions.md` and `project-context.md` to `.claude/rules/`. Claude Code loads them automatically in every message. Cost: ~50 lines per message. Benefit: the AI always has project context without anyone asking.

### 2. Feature Specs (`docs/specs/FEAT-XXX.md`) — optional

Technical specifications before implementing. The agent system works without specs, but a spec adds value in specific situations:

| Situation | Without spec | With spec | Recommendation |
|---|---|---|---|
| Claude Code/OpenCode + agents | Works well (agents have gates) | Better organized | Optional |
| Complex feature (5+ endpoints) | Context can be lost in long sessions | Spec anchors decisions | Recommended |
| Cursor/Windsurf/Gemini/Copilot | Each prompt partially repeats context | Spec centralizes | Nearly essential |
| Team (multiple devs or sessions) | Each session interprets differently | Spec aligns everyone | Recommended |
| Feature with security/privacy | Could forget an attack vector | Forces thinking beforehand | Recommended |

**Simple rule:** If you can explain the feature in 2 sentences and it affects 1-2 files, you don't need a spec. If you need to think before coding, do it.

To generate a spec, use the prompt `.ai/prompts/feature-spec.md`. Each agent extracts what it needs:

| Agent | What it extracts from the spec |
|---|---|
| @tdd-developer | Endpoints, payloads, errors → tests |
| @security-auditor | Inputs, rate limits → validations |
| @architect | Layers, contracts → verification |
| @database-engineer | Schema, indexes → migrations |

Template in `.ai/templates/FEAT-TEMPLATE.md`.

#### Documentation in Each PR

Documentation is included in the same PR as the code, not in separate PRs:

| Aspect | Docs in same PR | Docs in separate PR |
|---|---|---|
| Context | Agent already has code loaded | Must reload context |
| Coherence | Docs reflect the exact code | Drift risk |
| Review | One review covers code + docs | Two reviews, double cost |
| Tokens | 0 extra (same context) | Additional full session |

The `devops.md` Gate 5 includes: "PR includes updated documentation (README, ADR if applicable, CHANGELOG)".

### 3. Hooks + Engram MCP (automatic memory, Claude Code)

For Claude Code, hooks automate memory management without AI effort. The template includes pre-configured hooks in `.claude/settings.json` and scripts in `.ai/hooks/`:

| Hook | Script | What it does |
|---|---|---|
| `SessionStart` | `session-start.sh` | Injects previous session context (Engram if available, local file fallback) |
| `PreCompact` | `pre-compact.sh` | Saves state before context is compacted |
| `SessionEnd` | `session-stop.sh` | Saves session summary for next startup |

These work out of the box after running `sync.sh`. If Engram is installed, hooks use it automatically. Otherwise, they fall back to local files in `.ai/.local/`.

```
┌─────────────────────────────────────────────────────┐
│ Layer 1: .claude/rules/ (AUTO-LOADED, always)        │
│ → decisions.md, project-context.md                   │
│ → 0 effort, 0 forgotten                             │
├─────────────────────────────────────────────────────┤
│ Layer 2: Hooks (AUTOMATIC, on events)                │
│ → SessionStart: injects last context                 │
│ → PreCompact: saves state before losing context      │
│ → SessionEnd: saves session summary                  │
├─────────────────────────────────────────────────────┤
│ Layer 3: Engram MCP (ON DEMAND)                      │
│ → mem_search, mem_save, mem_context                  │
│ → Only when AI needs more context                    │
└─────────────────────────────────────────────────────┘
```

[Engram](https://github.com/Gentleman-Programming/engram) is a Go binary with SQLite + FTS5 that provides persistent memory via MCP. Cross-tool (Claude Code, OpenCode, Cursor, Windsurf, Gemini CLI). Local and private.

**Without Engram:** Hooks save to local files (`.ai/.local/`) as fallback.
**With Engram:** Full-text search, deduplication, multi-project.

### Memory per Tool

| Tool | Automatic Memory | Project Memory | Level |
|---|---|---|---|
| Claude Code | `.claude/rules/` + Hooks + Engram MCP | Feature Specs + decisions.md | Ideal |
| OpenCode | `AGENTS.md` + Engram MCP | Feature Specs + decisions.md | Acceptable |
| Cursor/Windsurf | compact rules + Engram MCP (if supported) | Feature Specs + decisions.md | Limited |
| Gemini | `GEMINI.md` + Engram MCP (if supported) | Feature Specs + decisions.md | Limited |
| Copilot | copilot-instructions.md | Feature Specs + decisions.md | Minimal |

## project-context.md

File in `.ai/agents/` containing project-specific constraints. All agents read it but it's not invocable (mode: context). Automatically copied to `.claude/rules/` to be auto-loaded.

Includes "Artifact Paths" section so agents know where to create their documents (docs, ADRs, specs, stories, etc.).

Fill with: domain, users, non-negotiable constraints, technical decisions, API limits, test commands.
