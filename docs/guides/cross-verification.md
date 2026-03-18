# Cross-Verification

[🇪🇸 Leer en español](es/cross-verification.md)

> Back to [README](../../README.md)

## Orchestrator and Cross-Verification

The `orchestrator.md` is the main agent (mode: `primary`) that:
1. **Routing**: analyzes the user's intent and routes to the correct agent
2. **Cross-verification**: after implementation, coordinates review rounds between agents

### The Problem It Solves

Without cross-verification, each agent works in isolation. The @tdd-developer can write passing tests but the @architect doesn't verify that data flows correctly between layers. The result: bugs that no individual agent detects.

### Cross-Verification Pattern

```
@tdd-developer (implements)
       |
       v
@architect (verifies e2e data flow between layers)
       |
   Issues? --Yes--> @tdd-developer (fixes) --> back to @architect
       |
       No
       v
@security-auditor (reviews OWASP)
       |
   Issues? --Yes--> @tdd-developer (fixes) --> back to @security-auditor
       |
       No
       v
Ready for commit
```

### When to Apply
- Contracts (interfaces) between layers are modified
- A new endpoint or service is added
- The Infrastructure layer is modified (DI, persistence)

### When NOT to Apply
- Isolated fixes within a single layer
- Documentation changes
- Refactors that don't alter contracts

### Behavior per Tool

| Tool | Who executes the pattern |
|---|---|
| OpenCode | `orchestrator.md` (primary agent, executes automatically) |
| Claude Code | The main session (reads Workflow in CLAUDE.md) + each agent's gates |
| Agent Teams (experimental) | Teammates communicate directly with each other |

**Note on Claude Code:** it doesn't use `orchestrator.md` (it does automatic routing). The cross-verification pattern is implemented via each agent's Quality Gates (e.g.: @tdd-developer Gate 4 says "verify DI compiles and both suites pass") and the Workflow in `CLAUDE.md`. `sync.sh` excludes the orchestrator when generating `.claude/agents/`.

**Note on Agent Teams:** Claude Code has an experimental feature ([agent teams](https://code.claude.com/docs/en/agent-teams)) where multiple instances communicate directly with each other. With agent teams, cross-verification would be native: the @architect teammate would send a message to the @tdd-developer teammate without an intermediary. The agents in this template are compatible with agent teams (each teammate loads its `agents/*.md` automatically).

## Where to Implement Cross-Verification

Cross-verification can be implemented in 3 ways. They are not mutually exclusive, but **don't duplicate**:

### Option 1: In each agent's Quality Gates (recommended)

Each agent's gates already include verifications that force coordination:

```markdown
# tdd-developer.md - Gate 4
Verify integration after GREEN:
  - The dependency container compiles without errors
  - Both test suites pass (Unit + Functional)

# architect.md - Gate 3
Verify e2e data flow between layers:
  - Contracts define ALL necessary parameters
  - Data flows completely between layers without loss
```

**Advantage:** Verification is embedded in the agent. No external coordination needed.
**Token cost:** 0 extra (gates are already loaded with the agent).
**Compatible with:** All tools.

### Option 2: In the orchestrator (OpenCode)

`orchestrator.md` executes the sequential flow automatically. Useful when the tool has a primary agent that coordinates others.

**Advantage:** Explicit flow, the orchestrator decides when to launch each verification.
**Token cost:** Low (orchestrator is loaded once).
**Compatible with:** OpenCode and tools with a primary agent.

### Option 3: Agent Teams (Claude Code experimental)

Teammates send messages directly to each other. Verification is native and parallel.

```
@architect → message to @tdd-developer: "the DTO needs the label field"
@tdd-developer → message to @architect: "added, review the contract"
@security-auditor → message to both: "sanitize the label against injection"
```

**Advantage:** Real parallel debate, no intermediary.
**Token cost:** High (each teammate is a full instance).
**Compatible with:** Claude Code only (experimental, requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### What NOT to Do

- **Don't duplicate** the pattern in CLAUDE.md if it's already in the agents' gates. CLAUDE.md is loaded in every message and duplicating verification wastes tokens with no benefit.
- **Don't enable agent teams by default.** Use it occasionally for complex features that touch multiple layers simultaneously (frontend + backend + tests).
- **Don't add cross-verification to everything.** Only applies when modifying contracts between layers, adding endpoints, or touching Infrastructure. A simple fix doesn't need it.

### Summary

| Strategy | Tokens | Parallelism | Complexity | When to use |
|---|---|---|---|---|
| Gates in agents | 0 extra | No (sequential) | Low | Always (base) |
| Orchestrator | Low | No (sequential) | Medium | OpenCode / tools with primary agent |
| Agent Teams | High | Yes (real) | High | Complex multi-layer features, occasionally |

Start with gates (option 1). If you need explicit coordination in OpenCode, use the orchestrator (option 2). If a feature touches many layers and you need real debate, try agent teams (option 3).
