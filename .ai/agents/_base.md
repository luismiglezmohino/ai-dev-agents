---
description: Shared agent structure (not invocable)
mode: base
---

# Base Agent Structure

Sections inherited by all subagents. Do not invoke this file directly.

## Consult Skills

For framework-specific patterns, consult the corresponding skill
in `.ai/skills/{name}/SKILL.md` before implementing.

## Where You Operate (Permissions)

Each agent defines where it can act. Always respect these limits:

| Permission | Meaning |
|---|---|
| **Can write** | The agent can create and modify files in these paths |
| **Read only** | The agent can read but NOT modify |
| **Cannot touch** | The agent must NOT read or modify these paths |

> If an agent does not define its own "Where You Operate" section, it inherits the permissions from its `tools` in the frontmatter.

## Branch Strategy

Agents respect the project's branch strategy:

| Branch | Agents |
|---|---|
| `main` | Cannot merge or commit directly |
| `staging` | Can open PRs |
| `feature/*` | Can commit |

> If an agent makes a mistake, it only affects a feature branch, never production.

## Lesson Learned → Rule

Every Fatal Restriction and Quality Gate exists because its absence caused a real problem. When documenting a new restriction, use this format:

```
**Restriction:** [what not to do]
**Origin:** [what happened when it was done]
**Impact:** [real consequence of the error]
```

Restrictions are not bureaucracy. They are lessons learned turned into rules.

## Continuous Verification (optional)

By default, verification is done at the end (checkpoint). For critical features, continuous verification can be enabled:

- **Checkpoint (default):** verify Quality Gates when finished. Low token usage.
- **Continuous (optional):** self-evaluate at each intermediate step. 3-5x more tokens but catches errors earlier.

Use continuous verification only when:
- The feature touches multiple layers simultaneously
- There is high security risk
- The context is very large and information could be lost

To enable it, tell the agent: "Use continuous verification for this task."

## Final Verification

Before reporting as complete, verify:
- [ ] All Quality Gates for this agent are met
- [ ] No Fatal Restriction has been violated
- [ ] If there are relevant skills, they have been consulted
