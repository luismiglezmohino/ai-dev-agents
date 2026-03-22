# Quick Start (5 minutes)

[🇪🇸 Leer en español](es/getting-started.md)

This guide takes you from zero to having the agent system working in your project.

## Requirements

- A project with Git initialized
- An AI tool installed (Claude Code, OpenCode, Cursor, or any other)
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated (`gh auth login`) — recommended for managing PRs, issues, workflows and releases directly from your AI tool
- 5 minutes

## Step 1: Copy the template

**Option A:** Click "Use this template" on the GitHub repo (recommended).

**Option B:** Manual copy

```bash
# macOS / Linux
cp -r ai-dev-agents/{.ai,.claudeignore,AGENTS.md,docs} your-project/

# Windows (PowerShell)
Copy-Item -Recurse ai-dev-agents\.ai, ai-dev-agents\docs, ai-dev-agents\AGENTS.md, ai-dev-agents\.claudeignore your-project\
```

> `.gitignore` is handled automatically by `sync.sh` — it adds the required entries without overwriting your existing file.

## Step 2: Automatic bootstrap

Open your AI tool in the project and paste the content of `.ai/prompts/bootstrap.md`.

The AI will analyze your project and generate:
- `project-context.md` — project context
- `CLAUDE.md` — main configuration
- `decisions.md` — stack decisions
- Basic skills for your stack

If your project is empty, it will ask you what you want to build.

## Step 3: Sync

```bash
.ai/sync.sh
```

This generates configurations for your tool (Claude Code, OpenCode, Cursor, etc.).

## Step 4: Validate

```bash
.ai/test.sh
```

If everything is green, you have the agent system working.

> **Important:** Always edit files in `.ai/` (the source), never in generated directories (`.claude/`, `.continue/`, `.agents/`, `.gemini/`, `.cursorrules`, etc.). Generated files are overwritten every time you run `sync.sh`. After editing any agent, skill or prompt in `.ai/`, re-run `.ai/sync.sh` to propagate changes to all tools.
>
> **Why does sync.sh generate for all tools at once?** It may create directories you don't use right now, but it allows you to switch between tools without reconfiguring (e.g. Claude Code today, Gemini CLI tomorrow). All generated directories are gitignored and don't interfere with your project.

## Step 5: Choose your working mode

The template supports three working modes. Choose the one that best fits your situation:

### Mode A: Direct agents (the simplest)

You invoke each agent manually when you need it:

```
@tdd implement the GET /api/users endpoint
@architect review the layer structure
@security audit-all
```

**Best for:** one-off tasks, quick fixes, single-layer work.
**You decide:** which agent to call and when. Cross-verification is done by you manually invoking review agents.

### Mode B: Orchestrator (automatic coordination)

The orchestrator automatically routes to the correct agent and coordinates cross-verification between agents:

```
"I need a new endpoint to manage users"
→ The orchestrator routes to @tdd-developer
→ Then launches @architect and @security-auditor automatically
```

**Best for:** complete features that touch multiple layers, projects where you want automatic cross-verification.
**Available in:** OpenCode (primary agent). In Claude Code, routing is automatic but without an explicit orchestrator.

### Mode C: Spec Driven Development (SDD) — the most complete

You define a technical specification BEFORE implementing. Agents work against that specification:

```
1. Generate a Feature Spec (.ai/prompts/feature-spec.md)
2. Each agent extracts what it needs from the spec
3. Implementation guided by the specification
4. Verification against spec criteria
```

**Best for:** complex features (5+ endpoints), teams with multiple developers, projects where quality is critical.
**Guide:** see `docs/specs/FEAT-TEMPLATE.md` and the prompt `.ai/prompts/feature-spec.md`.

### Which one to choose?

| Situation | Recommended mode |
|---|---|
| Quick fix, one-off task | A (direct agents) |
| Standard new feature | B (orchestrator) |
| Complex or critical feature | C (SDD) |
| New project (day 0) | C (SDD) for the first feature, then B |
| Production hotfix | A (direct agents, reduced flow) |
| Legacy code / modernization | C (SDD) — specify before touching |

All three modes are compatible. You can use A for quick fixes and C for large features in the same project.

### How to work with each mode

**Mode A — Direct agents:**

1. Open your AI tool (Claude Code, OpenCode, Cursor...)
2. Type the command for the agent you need: `@tdd implement <feature>`
3. The agent works, you review what it generates
4. If you need verification, invoke manually: `@security audit-all`
5. When satisfied, commit and PR

**Mode B — Orchestrator:**

1. Open OpenCode (the orchestrator works as a primary agent)
2. Describe what you need in natural language: "I need an endpoint to create users"
3. The orchestrator decides which agent to use and launches it
4. When finished, the orchestrator launches cross-verification automatically
5. You review the final result. If there are issues, the orchestrator iterates
6. When satisfied, commit and PR

> In Claude Code: there is no explicit orchestrator. Claude Code does automatic routing based on CLAUDE.md. Cross-verification is done by you invoking review agents or applied via each agent's Quality Gates.

**Mode C — SDD (Spec Driven Development):**

1. Before writing code, generate the specification: paste `.ai/prompts/feature-spec.md` in your AI tool
2. The AI generates a file at `docs/specs/FEAT-XXX-name.md` with requirements, contracts, expected errors
3. Review and adjust the spec — this is the time to think, not when you're coding
4. Implement: `@tdd implement according to spec docs/specs/FEAT-XXX-name.md`
5. Each agent extracts what it needs from the spec (tests, security, architecture)
6. Cross-verification against spec criteria
7. Commit and PR

## Available Prompts

The template includes reusable prompts in `.ai/prompts/` (English) and `.ai/prompts/es/` (Spanish).

| Tool | How to use prompts |
|---|---|
| Claude Code / OpenCode / Gemini CLI / Codex CLI | Tell the AI: `Read .ai/prompts/code-review.md and execute it` |
| Continue / Cursor / Windsurf / Copilot | Copy the `.md` file content and paste it in the chat |
| ChatGPT / Gemini (web) | Copy the `.md` file content and paste it |

| Prompt | Purpose | When to use |
|---|---|---|
| `bootstrap.md` | Configures the template in your project (generates context, skills, configs) | Day 0 — required |
| `feature-spec.md` | Generates technical specification before implementing (SDD) | Before complex features |
| `refine-skills.md` | Improves skills with real patterns from your code | After 2-3 implemented features |
| `legacy-audit.md` | Analyzes legacy code and proposes modernization plan | Before refactoring old code |
| `code-review.md` | Multi-agent review (architecture + security + testing + quality) | Before opening a PR |

## What's Next?

| Next step | When | Guide |
|---|---|---|
| Configure MCPs | If you need to connect DB, Sentry, GitHub... | [Recommended MCPs](recommended-mcps.md) |
| Configure Git hooks | Before the first PR | [Recommended Git hooks](recommended-hooks.md) |
| Configure CI/CD | Before production | [GitHub Actions workflows](recommended-workflows.md) |
| Choose models | If you want to optimize cost/quality | [Recommended models](recommended-models.md) |
| Create Feature Spec | Before a complex feature | See `docs/specs/FEAT-TEMPLATE.md` |
| Refine skills | After 2-3 implemented features | Use `.ai/prompts/refine-skills.md` |
| Audit legacy code | Before modernizing | Use `.ai/prompts/legacy-audit.md` |

## Minimum Structure After Setup

```
your-project/
├── .ai/
│   ├── agents/          # 11 agents + orchestrator + context
│   ├── skills/          # Stack skills (generated by bootstrap)
│   ├── hooks/           # Automatic memory (Claude Code)
│   ├── prompts/         # Reusable prompts
│   ├── sync.sh          # Generates configs for all tools
│   └── test.sh          # Validates structure
├── docs/
│   ├── specs/           # Feature Specs (optional)
│   ├── adrs/            # Architecture Decision Records
│   └── guides/          # Additional guides
├── CLAUDE.md            # Main config (generated)
└── AGENTS.md            # OpenCode config (generated)
```

## Included CI/CD

The template includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs `sync.sh + test.sh` on every PR and push to master. If you adopted the template via "Use this template", you already have it. It validates agent structure, frontmatter, and generated files automatically.

If you don't want it, delete `.github/workflows/ci.yml`. If you already have your own CI, the template's workflow won't conflict — it runs independently.

## Windows Users

`sync.sh` and `test.sh` are bash scripts. On Windows, you need one of:
- **WSL** (Windows Subsystem for Linux) — recommended
- **Git Bash** (included with Git for Windows)
- **MSYS2**

Most developers using AI CLIs (Claude Code, Gemini CLI, Codex CLI) on Windows already have WSL installed.

## Common Issues

| Problem | Solution |
|---|---|
| `sync.sh` generates nothing | Verify `.ai/agents/` has the .md files |
| AI doesn't use agents | Verify `CLAUDE.md` or `AGENTS.md` exists at the root |
| Context fills up quickly | Keep `CLAUDE.md` < 120 lines. Use `/compact` |
| Skills don't load | Verify the path in the agent and that the skill has `SKILL.md` |
| `test.sh` fails | Read the error — usually an incomplete frontmatter or missing section |
