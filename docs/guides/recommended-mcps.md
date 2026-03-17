# MCPs recomendados

Los Model Context Protocol (MCP) extienden el contexto de tus agentes conectándolos con herramientas y servicios externos. Sin MCPs, los agentes solo ven tu código. Con MCPs, pueden consultar documentación actualizada, gestiónar PRs, leer tu base de datos, etc.

## Básicos (recomendados para cualquier proyecto)

| MCP | Para qué | Quién lo usa más |
|---|---|---|
| **[Context7](https://github.com/upstash/context7)** | Documentación actualizada de librerías. Evita que la IA sugiera APIs obsoletas | Todos los agentes, especialmente tdd-developer y architect |
| **[GitHub](https://github.com/modelcontextprotocol/servers/tree/main/src/github)** | PRs, issues, repos. Permite crear PRs, leer issues y gestiónar el repositorio desde el agente | devops, qa-engineer |

## Opciónales (según tu stack)

| MCP | Cuándo usarlo | Agente principal |
|---|---|---|
| **[PostgreSQL](https://github.com/modelcontextprotocol/servers/tree/main/src/postgres)** | Si usas PostgreSQL | database-engineer |
| **[MySQL](https://github.com/modelcontextprotocol/servers)** | Si usas MySQL | database-engineer |
| **[Sentry](https://github.com/getsentry/sentry-mcp)** | Si tienes Sentry para observabilidad | observability-engineer |
| **[Notion](https://github.com/modelcontextprotocol/servers/tree/main/src/notion)** | Si usas Notion para documentación/gestión | technical-writer, product-owner |
| **[Linear](https://github.com/modelcontextprotocol/servers)** | Si usas Linear para gestión de tareas | product-owner, devops |
| **[Jira](https://github.com/modelcontextprotocol/servers)** | Si usas Jira para gestión de proyectos | product-owner, devops |
| **[Docker](https://github.com/modelcontextprotocol/servers)** | Si trabajas con contenedores | devops |
| **[Playwright](https://github.com/modelcontextprotocol/servers)** | Si haces E2E testing | qa-engineer |

## Cómo configurarlos

La configuración depende de la herramienta que uses:

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
# En el frontmatter del agente (.github/agents/nombre.agent.md)
---
mcp-servers:
  context7:
    command: npx
    args: ["-y", "@upstash/context7-mcp"]
---
```

## Criterios para añadir un MCP

Antes de añadir un MCP a tu proyecto, pregúntate:

1. **¿Lo necesitan los agentes?** Si solo tú consultas esa herramienta, no hace falta MCP
2. **¿Es de una fuente oficial?** Descárgalo siempre de la página oficial del proveedor
3. **¿Qué datos expone?** Un MCP de BD da acceso a tus datos. Revisa los permisos
4. **¿Añade valor real?** Context7 casi siempre vale la pena. Un MCP de Notion solo si tu documentación está ahí

## Seguridad

- Los MCPs se ejecutan en tu máquina local
- Necesitan credenciales (API keys, tokens) — guárdalas en variables de entorno, nunca en el código
- Revisa qué permisos pide cada MCP antes de configurarlo
- Usa solo MCPs de fuentes oficiales o repositorios verificados
