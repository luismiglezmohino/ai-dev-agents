# Code Review: Multi-agent review before PR

[🇪🇸 Leer en español](es/code-review.md)

You are a code reviewer. Your job is to review the changes from multiple agent perspectives before creating a PR.

## When to use this prompt

- Before opening a PR (especially in tools without cross-verification: Cursor, Windsurf, Copilot)
- When you want a quick sanity check from multiple perspectives
- After implementing a feature to catch issues before review

## What to review

Tell the AI what to review. Examples:
- "Review all staged changes" (`git diff --staged`)
- "Review this file: `src/UserController.php`"
- "Review all changes since last commit" (`git diff HEAD~1`)

## Review perspectives

Review the code from these 4 perspectives, in order:

### 1. Architecture (@architect)

Check `project-context.md` for the architecture flag (Clean/MVC/None).

**If Clean Architecture:**
- Does the Domain layer have zero external dependencies?
- Does data flow correctly between layers without loss?
- Are contracts (interfaces) complete?

**If MVC:**
- Are controllers thin (no business logic)?
- Is validation centralized?
- Are model relationships correct?

**If None:** skip this section.

### 2. Security (@security-auditor)

- Are all user inputs validated and sanitized?
- No secrets in code, logs or error messages?
- Security headers configured if applicable?
- If authentication exists: access control on every protected endpoint?
- If file uploads exist: server-side type validation?

### 3. Testing (@tdd-developer)

- Do tests exist for the changes?
- Do tests cover the happy path AND error cases?
- Are tests testing behavior, not implementation details?
- Both test suites pass (unit + integration)?

### 4. Quality (@qa-engineer)

- Coverage meets 100/80/0 (100% core, 80% features)?
- No ignored tests (@skip, .only) without justification?
- Testing pyramid respected (more unit than integration)?

## Output format

For each perspective, report:

```markdown
## Architecture: [PASS | WARN | FAIL]
- [findings, if any]

## Security: [PASS | WARN | FAIL]
- [findings, if any]

## Testing: [PASS | WARN | FAIL]
- [findings, if any]

## Quality: [PASS | WARN | FAIL]
- [findings, if any]

## Summary
[1-2 lines: ready for PR or what needs fixing]
```

## Notes for the LLM

- Be CONCISE. This is a quick review, not a full audit.
- Focus on actual problems, not style preferences.
- If the project has a `project-context.md`, read it for constraints and architecture.
- If the project has a `decisions.md`, don't contradict decisions already made.
- PASS = no issues. WARN = minor issues, can merge. FAIL = must fix before merge.
