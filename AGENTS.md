# AI Dev Agents

Agents, skills, and configuration live in `.ai/`.
See `.ai/README.md` for template documentation.

- **Agents:** `.ai/agents/` (source of truth, kebab-case)
- **Skills:** `.ai/skills/` (framework-specific)
- **Decisions:** `.ai/decisions.md` (auto-loaded)
- **Feature Specs:** `docs/specs/` (project documentation)
- **Hooks:** `.ai/hooks/` (automatic memory for Claude Code)

Run `.ai/sync.sh` after modifying agents.
Run `.ai/sync.sh --check` to validate without generating.
