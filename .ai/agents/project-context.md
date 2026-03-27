---
description: Project-specific constraints shared across all agents
mode: context
---

# PROJECT CONTEXT

## Domain

Describe the business domain in 1-2 lines.

## Users

End-user profile. Roles, special needs, usage context.

## Constraints

One constraint per line. Only the NON-negotiable ones.

- **License:**
- **Privacy:**
- **Accessibility:**
- **Performance:**

## Technical Decisions

Decisions already made that agents must respect. Format: decision — reason.

## Artifact Paths

Paths where each agent should create/find its artifacts.

- **Docs:**       `docs/`
- **ADRs:**       `docs/adrs/ADR-XXX-title.md`
- **Specs:**      `docs/specs/FEAT-XXX-title.md`
- **Stories:**    `docs/stories/US-XXX-title.md`
- **Guides:**     `.ai/docs/`

## Limits

API rate limits, budget, server capacity.

## Commands

```bash
# Test:
# Lint:
# Build:
```

## Learn & Persist

If you detect a recurring pattern (3+ occurrences), evaluate it:
- **Good pattern** → propose adding it to this file under Technical Decisions
- **Anti-pattern** → propose a constraint or restriction that prevents it
