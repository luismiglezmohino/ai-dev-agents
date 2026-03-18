# MVC Architecture Gates

Apply these gates when the project uses MVC (Laravel, Django, Rails, Spring MVC, ASP.NET MVC).

**IMPORTANT:** REPLACE the Clean gates with these. The agent must have only ONE set of gates.

## architect.md — Replace Protocol (Quality Gates)

```markdown
## Protocol (Quality Gates)
1. [Gate 1] (Prevents: fat controllers) Business logic lives in Models or Services, not in Controllers. Controllers only handle HTTP request/response.
2. [Gate 2] (Prevents: scattered validation) Input validation is centralized (Form Requests, Validators, Serializers), not duplicated across controllers.
3. [Gate 3] (Prevents: broken relationships) Model relationships are correctly defined, routes map to the right controllers, and database queries use the ORM properly.

## Fatal Restrictions
- NEVER put business logic in Controllers (queries, calculations, conditionals beyond routing).
- NEVER bypass the ORM with raw SQL unless there is a documented performance reason.
```

## tdd-developer.md — Replace Gate 4 only

```markdown
4. [Gate 4] (Prevents: broken integration after changes) Verify integration after GREEN:
   - Routes respond correctly (no 404/500 on defined endpoints).
   - Database queries execute without errors.
   - Both test suites pass (unit AND feature/integration).
```

## qa-engineer.md — Replace Gate 1 only

```markdown
1. [Gate 1] (Prevents: uncovered critical business logic) Coverage: 100% Models/Services (business logic), 80% Controllers, integration tests on critical flows.
```

## orchestrator.md — Replace Flow 1 verification steps

In Flow 1 (Code Implementation), replace:
- `@architect (verifies e2e data flow between layers)` → `@architect (verifies thin controllers and correct model relationships)`
- `@architect (verifies e2e data flow is still complete)` in Flow 2 → `@architect (verifies model relationships are correct after schema change)`

## project-context.md — Add architecture field

Add to the Technical Decisions section:
```markdown
- Architecture: MVC — [framework] standard patterns, no separate Domain layer
```
