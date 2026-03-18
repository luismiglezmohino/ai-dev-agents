# Token Optimization

[🇪🇸 Leer en español](es/token-optimization.md)

> Back to [README](../../README.md)

## Token Savings

### Language strategy

All files consumed by the AI (agents, skills, decisions, templates, hooks) are written in **English** to minimize token usage. English is more token-efficient than most languages, which means lower cost and more room in the context window.

User-facing files (README, guides) are bilingual: English primary (`README.md`, `docs/guides/`) + Spanish (`README.es.md`, `docs/guides/es/`). Project output (specs, ADRs, docs) can be in whatever language the user prefers.

### Design decisions

Every design decision in the template reduces token consumption:

| Improvement | Why it saves tokens |
|---|---|
| English for AI files | ~20-30% fewer tokens than Spanish/other languages for the same content |
| `project-context.md` | Project constraints in 1 file. Without it, each agent repeats them in its prompt |
| `decisions.md` | Quick decisions (~30 lines). Avoids re-discovering or asking about what's already decided |
| Feature Specs | A shared spec replaces N partial explanations to N agents |
| Compact rules | `sync.sh` generates 1 file for Cursor/Windsurf/Gemini/Copilot vs 11 complete agents |
| On-demand agents | Only the invoked agent is loaded, not all 11 |
| Sub-CLAUDE.md per module | `backend/CLAUDE.md` is not loaded when working on frontend |
| `_base.md` + expansion | Shared boilerplate in source, expanded in generated files |

## Token Optimization

### Loading Hierarchy

```
Always loaded (every message):
  └── CLAUDE.md / AGENTS.md         → KEEP < 120 lines

On demand (only when invoked):
  ├── .ai/agents/*.md               → No limit
  └── .ai/skills/*.md               → No limit

Per directory (only in that context):
  ├── backend/CLAUDE.md             → Backend stack
  └── frontend/CLAUDE.md            → Frontend stack
```

### Recommendations
- The main file should NOT include: templates, snippets, checklists, detailed workflows
- Roles in the main file are a compact list (1 line per role)
- Details of each role go in `.ai/agents/{role}.md`
- Framework details go in `.ai/skills/{skill}/SKILL.md`
- Create sub-CLAUDE.md per module for stack-specific context
