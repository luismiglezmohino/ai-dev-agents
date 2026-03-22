# Recommended MCPs

[🇪🇸 Leer en español](es/recommended-mcps.md)

Model Context Protocol (MCP) servers extend your agents' context by connecting them with external tools and services. Without MCPs, agents only see your code. With MCPs, they can query up-to-date documentation, manage PRs, read your database, etc.

## Basic (recommended for any project)

| MCP | Purpose | Who uses it most |
|---|---|---|
| **[Context7](https://github.com/upstash/context7)** | Up-to-date library documentation. Prevents the AI from suggesting obsolete APIs | All agents, especially tdd-developer and architect |

> **GitHub access: prefer `gh` CLI over GitHub MCP.** The [GitHub CLI (`gh`)](https://cli.github.com/) works in every AI tool that has terminal access (all 9 supported tools), requires no MCP setup, and is already the recommended approach by Claude Code. Install it with your package manager and run `gh auth login`. It covers PRs (`gh pr`), issues (`gh issue`), workflows (`gh workflow`), releases (`gh release`), and the full GitHub API (`gh api`). Only consider the GitHub MCP if your tool lacks terminal access.

## Optional (based on your stack)

| MCP | When to use | Primary agent |
|---|---|---|
| **[PostgreSQL](https://github.com/modelcontextprotocol/servers/tree/main/src/postgres)** | If you use PostgreSQL | database-engineer |
| **[MySQL](https://github.com/modelcontextprotocol/servers)** | If you use MySQL | database-engineer |
| **[Sentry](https://github.com/getsentry/sentry-mcp)** | If you have Sentry for observability | observability-engineer |
| **[Notion](https://github.com/modelcontextprotocol/servers/tree/main/src/notion)** | If you use Notion for documentation/management | technical-writer, product-owner |
| **[Linear](https://github.com/modelcontextprotocol/servers)** | If you use Linear for task management | product-owner, devops |
| **[Jira](https://github.com/modelcontextprotocol/servers)** | If you use Jira for project management | product-owner, devops |
| **[Docker](https://github.com/modelcontextprotocol/servers)** | If you work with containers | devops |
| **[Playwright](https://github.com/modelcontextprotocol/servers)** | If you do E2E testing | qa-engineer |
| **[Engram](https://github.com/Gentleman-Programming/engram)** | If you want persistent memory across sessions and tools | All agents |
| **[Figma](https://github.com/nicholasgriffintn/figma-mcp-server)** | If you design in Figma and want agents to read designs | ux-designer |
| **[Supabase](https://github.com/supabase-community/supabase-mcp)** | If you use Supabase (DB + Auth + Storage) | database-engineer |

## Find More MCPs

| Directory | Description |
|---|---|
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | Official reference implementations by the MCP team |
| [mcpservers.org](https://mcpservers.org) | Community directory with search and filtering |

## How to Configure Them

Configuration depends on the tool you use:

### Claude Code

```json
// .claude/settings.json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### OpenCode

```json
// .opencode/config.json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Cursor

```json
// .cursor/mcp.json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### GitHub Copilot

```yaml
# In the agent frontmatter (.github/agents/name.agent.md)
---
mcp-servers:
  context7:
    command: npx
    args: ["-y", "@upstash/context7-mcp"]
---
```

## Criteria for Adding an MCP

Before adding an MCP to your project, ask yourself:

1. **Do agents need it?** If only you query that tool, no MCP needed
2. **Is it from an official source?** Always download from the provider's official page
3. **What data does it expose?** A DB MCP gives access to your data. Review permissions
4. **Does it add real value?** Context7 is almost always worth it. A Notion MCP only if your documentation lives there

## Security

- MCPs run on your local machine
- They need credentials (API keys, tokens) — store them in environment variables, never in code
- Review what permissions each MCP requests before configuring
- Only use MCPs from official sources or verified repositories

### Data exposure per recommended tool

| Tool | Runs locally | Sends data externally | What it sends | Risk |
|---|---|---|---|---|
| **Engram** | Yes (SQLite) | No | Nothing | Low |
| **Context7** | No (cloud) | Yes | Library names (e.g. "Vue 3 docs") | Low — only public docs, not your code |
| **PostgreSQL/MySQL MCP** | Yes | No | Nothing (connects to your DB) | Medium — agent can read/write your data |
| **Sentry MCP** | No (cloud) | Yes | Reads your Sentry errors | Low — data already in Sentry |
| **Figma MCP** | No (cloud) | Yes | Reads your Figma designs | Low — data already in Figma |
| **Supabase MCP** | No (cloud) | Yes | Reads/writes your Supabase data | Medium — agent has DB access |

**Rule:** If your project handles sensitive data (health, financial, PII), verify what each MCP sends before installing. Local-only MCPs (Engram, DB direct) are always safer.

## MCPs You DON'T Need

| MCP | Reason |
|-----|--------|
| Filesystem | Claude Code already has native Read/Write/Edit/Glob/Grep |
| Docker | Docker commands via Bash are sufficient |
| Git | Claude Code already has native git integration |
| GitHub | `gh` CLI is universal (works in all 9 tools), faster to set up, and recommended by Claude Code — see note above |

## MCP Management

```bash
# Install an MCP
claude mcp add <name> -- <command>

# List configured MCPs
claude mcp list

# View MCP details
claude mcp get context7

# Remove an MCP
claude mcp remove context7

# Inside Claude Code: view status and token cost
/mcp

# Authenticate remote MCPs using OAuth
/mcp → select server → Authenticate
```

## Scopes (where configuration is saved)

| Scope | Flag | Where it's saved | Purpose |
|-------|------|------------------|---------|
| `local` | (default) | `~/.claude.json` | Only you, only this project |
| `project` | `--scope project` | `.mcp.json` (project root) | Shared with the team (commit to git) |
| `user` | `--scope user` | `~/.claude.json` | You, across all your projects |

```bash
# MCP available in all your projects
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest

# MCP shared with the team (saved in .mcp.json)
claude mcp add --scope project --transport http sentry https://mcp.sentry.dev/mcp
```

## Token Cost of MCPs

Each MCP adds its tool definitions to every message's context. With 2-3 MCPs the impact is low. If you have many, Claude Code enables **Tool Search** automatically: instead of loading all tools, it searches them on demand.

```bash
# See how many tokens each MCP consumes
/mcp

# Force Tool Search (if you have many MCPs)
ENABLE_TOOL_SEARCH=true claude

# Disable Tool Search
ENABLE_TOOL_SEARCH=false claude
```

**Recommendation:** Only install MCPs you actively use. Context7 is the only universally useful one for development. The rest depends on your stack and project phase.
