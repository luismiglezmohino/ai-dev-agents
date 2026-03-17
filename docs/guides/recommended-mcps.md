# Recommended MCPs

[🇪🇸 Leer en español](es/recommended-mcps.md)

Model Context Protocol (MCP) servers extend your agents' context by connecting them with external tools and services. Without MCPs, agents only see your code. With MCPs, they can query up-to-date documentation, manage PRs, read your database, etc.

## Basic (recommended for any project)

| MCP | Purpose | Who uses it most |
|---|---|---|
| **[Context7](https://github.com/upstash/context7)** | Up-to-date library documentation. Prevents the AI from suggesting obsolete APIs | All agents, especially tdd-developer and architect |
| **[GitHub](https://github.com/modelcontextprotocol/servers/tree/main/src/github)** | PRs, issues, repos. Allows creating PRs, reading issues and managing the repository from the agent | devops, qa-engineer |

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
