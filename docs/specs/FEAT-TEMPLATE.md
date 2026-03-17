# FEAT-XXX: [Feature Name]

**Status:** Proposed | In Development | Completed
**Priority:** High | Medium | Low
**Related ADRs:**

## Context

What problem this feature solves and why it's needed.

## Acceptance Criteria

- [ ] AC1:
- [ ] AC2:
- [ ] AC3:

## Technical Design

### Endpoint / Component

HTTP method + path, or component name.

### Request / Input

Payload with types and validations. Limits (min, max, format).

### Response / Output

Expected response for each case: OK, cached, error.

### Errors

Each error code with its cause.

### Cache / State

Cache strategy (key, TTL, invalidation) or state management.

### Security

Input validations, sanitization, permissions, rate limiting, sensitive data.

### Schema / Database

New or modified tables, required indexes, reversible migration (up/down), impact on existing data.

## Agents and Skills Involved

### Agents

| Agent | Responsibility in this feature |
|---|---|
| @tdd-developer | TDD implementation |
| @database-engineer | Migration (if applicable) |
| @security-auditor | OWASP review |
| @qa-engineer | Verify coverage |
| @architect | Verify contracts between layers (if applicable) |

> Remove agents that don't apply to this feature. Add missing ones.

### Required Skills

| Skill | Why it's needed |
|---|---|
| `{stack-backend}` | Backend implementation patterns |
| `{stack-testing}` | Testing patterns |
| `{other-skill}` | ... |

> Check `.ai/skills/` to see available skills in your project.

## Implementation Plan

Ordered steps with the responsible agent. Select the orchestrator flow that best applies (see `.ai/agents/orchestrator.md`).

1. [ ] @database-engineer — Migration (if applicable)
2. [ ] @tdd-developer — Tests + implementation (RED-GREEN-REFACTOR)
3. [ ] @security-auditor — OWASP review
4. [ ] @qa-engineer — Verify coverage

## Testing

### Unit Tests

Expected test cases for business logic.

### Integration Tests

E2E flows to verify.

## Definition of Done

- [ ] Acceptance criteria met
- [ ] Tests passing (100% core, 80% features)
- [ ] Security audit (OWASP)
- [ ] Documentation updated
- [ ] Performance acceptable (if applicable)
