# Prompt: Legacy code audit

[🇪🇸 Leer en español](es/legacy-audit.md)

Paste this prompt in your AI tool when you need to analyze legacy code before modernizing it.

---

Analyze the legacy code of this project and generate a modernization report.

## What I need you to do

1. **Inventory**: List all current technologies, frameworks, versions and dependencies.

2. **Risks**: Identify:
   - Obsolete or unmaintained dependencies
   - Known security vulnerabilities
   - Code without tests (risk zones)
   - Strong coupling between modules
   - Anti-clean architecture patterns (business logic in controllers, entities coupled to ORM, etc.)

3. **Current test coverage**: What percentage of the code has tests? What critical areas are not covered?

4. **Modernization plan**: Propose a step-by-step plan:
   - Phase 1: Write tests for existing code (safety net)
   - Phase 2: Refactor module by module (lowest to highest risk)
   - Phase 3: Migrate to modern stack (if applicable)
   - For each phase: involved agents and required skills

5. **Prioritization**: Order by impact/risk. What to modernize first?

## Output format

Generate the report in `docs/legacy-audit.md` with the sections above.

## Constraints

- DO NOT modify any code. This prompt is for analysis only.
- DO NOT propose rewriting everything from scratch. Modernize incrementally.
- Follow the orchestrator's Flow 5 (legacy code) for subsequent implementation.
