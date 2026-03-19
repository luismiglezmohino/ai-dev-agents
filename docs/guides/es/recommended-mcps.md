# MCPs recomendados

[🇬🇧 Read in English](../recommended-mcps.md)


Los Model Context Protocol (MCP) extienden el contexto de tus agentes conectándolos con herramientas y servicios externos. Sin MCPs, los agentes solo ven tu código. Con MCPs, pueden consultar documentación actualizada, gestionar PRs, leer tu base de datos, etc.

## Básicos (recomendados para cualquier proyecto)

| MCP | Para qué | Quién lo usa más |
|---|---|---|
| **[Context7](https://github.com/upstash/context7)** | Documentación actualizada de librerías. Evita que la IA sugiera APIs obsoletas | Todos los agentes, especialmente tdd-developer y architect |
| **[GitHub](https://github.com/modelcontextprotocol/servers/tree/main/src/github)** | PRs, issues, repos. Permite crear PRs, leer issues y gestionar el repositorio desde el agente | devops, qa-engineer |

## Opcionales (según tu stack)

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
| **[Engram](https://github.com/Gentleman-Programming/engram)** | Si quieres memoria persistente entre sesiones y herramientas | Todos los agentes |
| **[Figma](https://github.com/nicholasgriffintn/figma-mcp-server)** | Si diseñas en Figma y quieres que los agentes lean diseños | ux-designer |
| **[Supabase](https://github.com/supabase-community/supabase-mcp)** | Si usas Supabase (BD + Auth + Storage) | database-engineer |

## Buscar más MCPs

| Directorio | Descripción |
|---|---|
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | Implementaciones oficiales del equipo MCP |
| [mcpservers.org](https://mcpservers.org) | Directorio comunitario con búsqueda y filtros |

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

## MCPs que NO necesitas

| MCP | Razón |
|-----|--------|
| Filesystem | Claude Code ya tiene Read/Write/Edit/Glob/Grep nativos |
| Docker | Los comandos de Docker vía Bash son suficientes |
| Git | Claude Code ya tiene integración nativa con git |

## Gestión de MCPs

```bash
# Instalar un MCP
claude mcp add <nombre> -- <comando>

# Listar MCPs configurados
claude mcp list

# Ver detalles de un MCP
claude mcp get context7

# Eliminar un MCP
claude mcp remove context7

# Dentro de Claude Code: ver estado y coste en tokens
/mcp

# Autenticar MCPs remotos usando OAuth
/mcp → seleccionar servidor → Authenticate
```

## Scopes (dónde se guarda la configuración)

| Scope | Flag | Dónde se guarda | Propósito |
|-------|------|------------------|---------|
| `local` | (por defecto) | `~/.claude.json` | Solo tú, solo este proyecto |
| `project` | `--scope project` | `.mcp.json` (raíz del proyecto) | Compartido con el equipo (commitear a git) |
| `user` | `--scope user` | `~/.claude.json` | Tú, en todos tus proyectos |

```bash
# MCP disponible en todos tus proyectos
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest

# MCP compartido con el equipo (guardado en .mcp.json)
claude mcp add --scope project --transport http sentry https://mcp.sentry.dev/mcp
```

## Coste en tokens de los MCPs

Cada MCP añade sus definiciones de herramientas al contexto de cada mensaje. Con 2-3 MCPs el impacto es bajo. Si tienes muchos, Claude Code activa **Tool Search** automáticamente: en vez de cargar todas las herramientas, las busca bajo demanda.

```bash
# Ver cuántos tokens consume cada MCP
/mcp

# Forzar Tool Search (si tienes muchos MCPs)
ENABLE_TOOL_SEARCH=true claude

# Desactivar Tool Search
ENABLE_TOOL_SEARCH=false claude
```

**Recomendación:** Instala solo los MCPs que uses activamente. Context7 es el único universalmente útil para desarrollo. El resto depende de tu stack y fase del proyecto.
