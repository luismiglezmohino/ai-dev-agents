#!/usr/bin/env bash
#
# sync.sh
# Sincroniza agentes a todas las herramientas soportadas
#
# Estructura esperada (desde raiz del proyecto):
#   .ai/agents/          <- Fuente (formato OpenCode, kebab-case)
#   .ai/skills/          <- Fuente (compatible ambos)
#   .ai/decisions.md     <- Fuente (cross-tool)
#   .claude/agents/      <- Destino (formato Claude Code, generado)
#   .claude/skills       -> ../.ai/skills (enlace)
#   .claude/rules/       <- Generado (decisions.md, project-context.md)
#   .opencode/agents     -> ../.ai/agents (enlace)
#   .opencode/skills     -> ../.ai/skills (enlace)
#   .cursorrules         <- Generado (compacto)
#   .windsurfrules       <- Generado (compacto)
#   .github/copilot-instructions.md <- Generado (compacto)
#
# Uso: .ai/sync.sh [--dry-run] [--check]
#

set -euo pipefail

# .ai/ es donde vive este script; PROJECT_ROOT es el padre
AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AI_DIR/.." && pwd)"

# Modo
DRY_RUN=false
CHECK_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --check) CHECK_ONLY=true ;;
    esac
done

# Directorios fuente (dentro de .ai/)
AGENTS_SOURCE="$AI_DIR/agents"
SKILLS_SOURCE="$AI_DIR/skills"
DECISIONS_SOURCE="$AI_DIR/decisions.md"

# Directorios destino (en raiz del proyecto)
CLAUDE_AGENTS="$PROJECT_ROOT/.claude/agents"
CLAUDE_SKILLS="$PROJECT_ROOT/.claude/skills"
CLAUDE_RULES="$PROJECT_ROOT/.claude/rules"
OPENCODE_DIR="$PROJECT_ROOT/.opencode"
OPENCODE_AGENTS="$OPENCODE_DIR/agents"
OPENCODE_SKILLS="$OPENCODE_DIR/skills"

# Tools base para Claude Code (siempre disponibles: lectura + busqueda)
CLAUDE_READ_TOOLS="Read, Glob, Grep, WebFetch, WebSearch, Task"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
log_dry() { echo -e "${BLUE}[DRY-RUN]${NC} $1"; }
log_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# === VALIDACION ===

validate_agent() {
    local source_file="$1"
    local filename
    filename=$(basename "$source_file")
    local errors=0

    # Verificar frontmatter con description
    if ! grep -q "^description:" "$source_file"; then
        log_warn "$filename: falta 'description' en frontmatter"
        ((errors++)) || true
    fi

    # Verificar frontmatter con mode
    if ! grep -q "^mode:" "$source_file"; then
        log_warn "$filename: falta 'mode' en frontmatter"
        ((errors++)) || true
    else
        # Validar valor de mode
        local mode
        mode=$(grep -m1 "^mode:" "$source_file" | awk '{print $2}')
        case "$mode" in
            subagent|primary|context|base) ;;
            *) log_warn "$filename: mode invalido '$mode' (esperado: subagent|primary|context|base)"; ((errors++)) || true ;;
        esac
    fi

    # Validar temperature si existe
    if grep -q "^temperature:" "$source_file"; then
        local temp
        temp=$(grep -m1 "^temperature:" "$source_file" | awk '{print $2}')
        if ! awk "BEGIN{exit !($temp >= 0.0 && $temp <= 1.0)}" 2>/dev/null; then
            log_warn "$filename: temperature fuera de rango '$temp' (esperado: 0.0-1.0)"
            ((errors++)) || true
        fi
    fi

    # Verificar secciones obligatorias (solo subagents)
    local mode
    mode=$(grep -m1 "^mode:" "$source_file" | awk '{print $2}' 2>/dev/null || echo "")
    if [[ "$mode" == "subagent" ]]; then
        if ! grep -q "Quality Gates\|Protocolo" "$source_file"; then
            log_warn "$filename: falta seccion 'Quality Gates'"
            ((errors++)) || true
        fi
        if ! grep -q "Restricciones Fatales" "$source_file"; then
            log_warn "$filename: falta seccion 'Restricciones Fatales'"
            ((errors++)) || true
        fi
    fi

    return $errors
}

should_skip_agent() {
    local filename="$1"
    # Skip non-invocable agents and base files
    if [[ "$filename" =~ ^_ ]]; then
        return 0
    fi
    case "$filename" in
        orchestrator.md|project-context.md) return 0 ;;
        *) return 1 ;;
    esac
}

# === CONVERSION ===

build_claude_tools() {
    local source_file="$1"
    local tools="$CLAUDE_READ_TOOLS"

    # Extraer frontmatter (entre primer y segundo ---)
    local frontmatter
    frontmatter=$(awk '/^---$/{c++;if(c==2)exit;next}c==1' "$source_file")

    # Opt-in: solo incluir si el frontmatter dice explicitamente "tool: true"
    if echo "$frontmatter" | grep -q "write: true"; then
        tools="$tools, Write"
    fi

    if echo "$frontmatter" | grep -q "edit: true"; then
        tools="$tools, Edit"
    fi

    if echo "$frontmatter" | grep -q "bash: true"; then
        tools="$tools, Bash"
    fi

    echo "$tools"
}

process_agent() {
    local source_file="$1"
    local filename
    filename=$(basename "$source_file" .md)
    local agent_name="$filename"  # Ya son kebab-case

    # Extraer description del frontmatter
    local description
    description=$(grep -m1 "^description:" "$source_file" | sed 's/^description: *//' || echo "")

    # Construir lista de tools segun frontmatter del fuente
    local tools
    tools=$(build_claude_tools "$source_file")

    # Extraer contenido (todo despues del segundo ---), eliminando blank lines iniciales
    local content
    content=$(awk '/^---$/{c++;next}c>=2' "$source_file" | sed '/./,$!d')

    # Expandir referencia a _base.md con contenido real
    local base_file="$AGENTS_SOURCE/_base.md"
    if [[ -f "$base_file" ]] && echo "$content" | grep -q "_base.md"; then
        local base_content
        base_content=$(awk '/^---$/{c++;next}c>=2' "$base_file" | sed '1,/^$/d' | sed '/^Sections inherited by all subagents/d' | sed '/^# Base Agent Structure/d')
        # Si el agente ya tiene "Where You Operate", eliminar la sección genérica de _base.md para evitar duplicados
        if echo "$content" | grep -q "## Where You Operate"; then
            base_content=$(echo "$base_content" | awk '/^## Where You Operate \(Permisos\)/{skip=1} /^## [^W]/{skip=0} !skip')
        fi
        content=$(echo "$content" | sed '/Hereda de.*_base.md/d')
        content="$content"$'\n\n'"$base_content"
    fi

    local dest="$CLAUDE_AGENTS/$agent_name.md"

    if $DRY_RUN; then
        log_dry "Generaria $dest"
        return
    fi

    cat > "$dest" << EOFCLAUDE
---
name: $agent_name
description: $description
tools: $tools
---

$content
EOFCLAUDE

    log_info "$filename → .claude/agents/$agent_name.md"
}

# === SYMLINKS ===

create_symlink() {
    local target="$1"
    local link="$2"
    local name="$3"

    if $DRY_RUN; then
        log_dry "Crearia enlace $name"
        return
    fi

    if [[ -L "$link" ]]; then
        # Actualizar si apunta a otro sitio
        local current_target
        current_target=$(readlink "$link")
        if [[ "$current_target" != "$target" ]]; then
            rm "$link"
            ln -s "$target" "$link"
            log_info "$name (enlace actualizado)"
        else
            log_info "$name (enlace existe)"
        fi
    elif [[ -e "$link" ]]; then
        log_warn "$name (existe pero no es enlace)"
    else
        ln -s "$target" "$link"
        log_info "$name (enlace creado)"
    fi
}

# === COMPACT RULES ===

generate_compact_rules() {
    local output=""

    output+="# AI Dev Agents - Compact Rules\n"
    output+="# Auto-generated by .ai/sync.sh — DO NOT EDIT\n"
    output+="# Source: .ai/agents/ and .ai/decisions.md\n\n"

    # Agent roster
    output+="## Agents\n\n"
    for f in "$AGENTS_SOURCE"/*.md; do
        [[ -f "$f" ]] || continue
        local fname
        fname=$(basename "$f" .md)

        # Skip non-invocable
        if should_skip_agent "$(basename "$f")"; then
            continue
        fi

        local desc
        desc=$(grep -m1 "^description:" "$f" | sed 's/^description: *//' || echo "")

        # Extract gate summaries
        local gates=""
        while IFS= read -r line; do
            local gate_text
            gate_text=$(echo "$line" | sed 's/.*\(Previene:[^)]*\).*/\1/' 2>/dev/null || echo "")
            if [[ -n "$gate_text" && "$gate_text" != "$line" ]]; then
                [[ -n "$gates" ]] && gates+=", "
                gates+="$gate_text"
            fi
        done < <(grep "^\s*[0-9]*\. \[Gate" "$f" || true)

        output+="- **@${fname}**: ${desc}"
        [[ -n "$gates" ]] && output+=" [${gates}]"
        output+="\n"
    done

    # Global Guards
    output+="\n## Global Guards\n\n"
    output+="- **Zero Trust:** Valida todos los inputs.\n"
    output+="- **Clean Arch:** Domain > Application > Infrastructure.\n"
    output+="- **Logs:** JSON estructurado con correlationId.\n"
    output+="- **TDD:** No código de producción sin test que falle.\n"

    # Workflow
    output+="\n## Workflow\n\n"
    output+="1. @product-owner (requisitos) -> 2. @architect + @ux-designer (diseno)\n"
    output+="3. @database-engineer (si hay cambios de schema) -> 4. @tdd-developer (implementación)\n"
    output+="5. @security-auditor (OWASP) -> 6. @qa-engineer (coverage) -> 7. @devops (deploy)\n"
    output+="Transversales: @technical-writer, @observability-engineer, @performance-engineer\n"

    # Decisions
    if [[ -f "$DECISIONS_SOURCE" ]]; then
        output+="\n## Decisions\n\n"
        local decisions_content
        # Extraer desde la primera seccion (##), saltando el header
        decisions_content=$(awk '/^## /{found=1} found' "$DECISIONS_SOURCE")
        if [[ -n "$decisions_content" ]]; then
            output+="$decisions_content\n"
        fi
    fi

    # Skills
    output+="\n## Skills\n\n"
    output+="Read \`.ai/skills/{name}/SKILL.md\` before implementing with a specific framework.\n"
    output+="Agents say WHAT to verify. Skills say HOW.\n"

    # Memory (for tools without hooks)
    output+="\n## Memory\n\n"
    output+="Consultar Feature Specs en \`docs/specs/\` como memoria de proyecto.\n"
    output+="Decisiones cerradas en \`.ai/decisions.md\`.\n"

    echo -e "$output"
}

# === MAIN ===

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   .ai/sync.sh - Agent Sync                        ║${NC}"
    echo -e "${BLUE}║   Distribuye agentes a todas las herramientas      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"

    if $DRY_RUN; then
        echo -e "${YELLOW}Modo dry-run: no se escribiran archivos${NC}"
    fi
    if $CHECK_ONLY; then
        echo -e "${YELLOW}Modo check: solo validacion${NC}"
    fi

    # Verificar fuentes
    if [[ ! -d "$AGENTS_SOURCE" ]]; then
        log_error "No existe $AGENTS_SOURCE"
        exit 1
    fi
    if [[ ! -d "$SKILLS_SOURCE" ]]; then
        log_error "No existe $SKILLS_SOURCE"
        exit 1
    fi

    # === VALIDACION ===
    log_section "Validacion de agentes"
    local total_errors=0
    for f in "$AGENTS_SOURCE"/*.md; do
        [[ -f "$f" ]] || continue
        if ! validate_agent "$f"; then
            ((total_errors++)) || true
        fi
    done
    if [[ $total_errors -eq 0 ]]; then
        log_info "Todos los agentes validos"
    else
        log_warn "$total_errors agente(s) con warnings"
    fi

    if $CHECK_ONLY; then
        echo ""
        echo "Validacion completada. Errores: $total_errors"
        exit $total_errors
    fi

    # === OPENCODE: Enlaces simbolicos ===
    log_section "OpenCode (enlaces simbolicos)"
    mkdir -p "$OPENCODE_DIR"
    create_symlink "../.ai/agents" "$OPENCODE_AGENTS" ".opencode/agents -> ../.ai/agents"
    create_symlink "../.ai/skills" "$OPENCODE_SKILLS" ".opencode/skills -> ../.ai/skills"

    if [[ -f "$DECISIONS_SOURCE" ]]; then
        if $DRY_RUN; then
            log_dry "Copiaria decisions.md -> .opencode/decisions.md"
        else
            cp "$DECISIONS_SOURCE" "$OPENCODE_DIR/decisions.md"
            log_info "decisions.md -> .opencode/decisions.md"
        fi
    fi

    # === CLAUDE CODE: Conversion de agentes ===
    log_section "Claude Code (conversion de agentes)"
    if ! $DRY_RUN; then
        mkdir -p "$CLAUDE_AGENTS"
    fi

    local agent_count=0
    for f in "$AGENTS_SOURCE"/*.md; do
        [[ -f "$f" ]] || continue
        if should_skip_agent "$(basename "$f")"; then
            log_skip "$(basename "$f") (excluido)"
            continue
        fi
        process_agent "$f"
        ((agent_count++)) || true
    done

    # === CLAUDE CODE: Skills enlace ===
    log_section "Claude Code (skills + rules)"
    if ! $DRY_RUN; then
        mkdir -p "$PROJECT_ROOT/.claude"
    fi
    create_symlink "../.ai/skills" "$CLAUDE_SKILLS" ".claude/skills -> ../.ai/skills"

    # === CLAUDE CODE: Rules (auto-cargado) ===
    if ! $DRY_RUN; then
        mkdir -p "$CLAUDE_RULES"
    fi

    if [[ -f "$DECISIONS_SOURCE" ]]; then
        if $DRY_RUN; then
            log_dry "Copiaria decisions.md -> .claude/rules/decisions.md"
        else
            cp "$DECISIONS_SOURCE" "$CLAUDE_RULES/decisions.md"
            log_info "decisions.md -> .claude/rules/decisions.md"
        fi
    fi

    # Copiar project-context.md a rules (auto-cargado)
    local ctx_file="$AGENTS_SOURCE/project-context.md"
    if [[ -f "$ctx_file" ]]; then
        if $DRY_RUN; then
            log_dry "Copiaria project-context.md -> .claude/rules/project-context.md"
        else
            # Extraer solo contenido (sin frontmatter YAML)
            awk '/^---$/{c++;next}c>=2' "$ctx_file" > "$CLAUDE_RULES/project-context.md"
            log_info "project-context.md -> .claude/rules/project-context.md"
        fi
    fi

    # === COMPACT RULES ===
    log_section "Compact rules (Cursor, Windsurf, Copilot)"
    local compact_rules
    compact_rules=$(generate_compact_rules)

    if $DRY_RUN; then
        log_dry "Generaria .cursorrules, .windsurfrules, GEMINI.md, .github/copilot-instructions.md"
    else
        echo -e "$compact_rules" > "$PROJECT_ROOT/.cursorrules"
        log_info ".cursorrules (generado)"

        echo -e "$compact_rules" > "$PROJECT_ROOT/.windsurfrules"
        log_info ".windsurfrules (generado)"

        echo -e "$compact_rules" > "$PROJECT_ROOT/GEMINI.md"
        log_info "GEMINI.md (generado)"

        mkdir -p "$PROJECT_ROOT/.github"
        echo -e "$compact_rules" > "$PROJECT_ROOT/.github/copilot-instructions.md"
        log_info ".github/copilot-instructions.md (generado)"
    fi

    # === RESUMEN ===
    log_section "Resumen"
    echo -e "Agentes convertidos: ${GREEN}$agent_count${NC}"
    if [[ $total_errors -gt 0 ]]; then
        echo -e "Agentes con warnings: ${YELLOW}$total_errors${NC}"
    fi
    echo ""
    echo "Estructura generada:"
    echo "  .ai/agents/            Fuente (kebab-case)"
    echo "  .ai/skills/            Fuente"
    echo "  .ai/decisions.md       Fuente (cross-tool)"
    echo "  .opencode/agents       -> ../.ai/agents (enlace)"
    echo "  .opencode/skills       -> ../.ai/skills (enlace)"
    echo "  .opencode/decisions.md Copia"
    echo "  .claude/agents/        Generado (formato Claude Code)"
    echo "  .claude/skills         -> ../.ai/skills (enlace)"
    echo "  .claude/rules/         Generado (decisions.md, project-context.md)"
    echo "  .cursorrules           Generado (compacto)"
    echo "  .windsurfrules         Generado (compacto)"
    echo "  GEMINI.md              Generado (compacto)"
    echo "  .github/copilot-instructions.md  Generado (compacto)"
}

main "$@"
