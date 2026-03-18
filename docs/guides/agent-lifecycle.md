# Agent Lifecycle

[🇪🇸 Leer en español](es/agent-lifecycle.md)

> Back to [README](../../README.md)

## Agent Lifecycle

Agents are **ephemeral**: they are born clean, execute their task and die. They have no memory between sessions.

```
Orchestrator invokes agent
       |
       v
  Born clean (loads only its .md + relevant skills)
       |
       v
  Executes (works with minimal context)
       |
       v
  Reports (returns summary to orchestrator)
       |
       v
  Dies (context discarded)
```

**Input:** The agent receives from the orchestrator only the context needed for its task.
**Execution:** Loads its Quality Gates and relevant skills. Does not inherit context from other agents.
**Output:** Returns a summary. The orchestrator decides the next step.

## Anti-pattern: The Agent That Does Everything

A common mistake is using a single agent to analyze, design, implement, test and document. This fails because:

- The context window fills to 80% before writing the first line of code
- Quality Gates from different roles can conflict
- The agent starts hallucinating when the context is saturated

**Rule:** If the task requires multiple phases (design + implementation + testing), delegate to specialized sub-agents. Each one works with clean context.
