#!/usr/bin/env bash
#
# sync.sh
# Syncs agents to all supported tools
#
# Expected structure (from project root):
#   .ai/agents/          <- Source (OpenCode format, kebab-case)
#   .ai/skills/          <- Source (compatible with both)
#   .ai/decisions.md     <- Source (cross-tool)
#   .claude/agents/      <- Destination (Claude Code format, generated)
#   .claude/skills       -> ../.ai/skills (symlink)
#   .claude/rules/       <- Generated (decisions.md, project-context.md)
#   .opencode/agents     -> ../.ai/agents (symlink)
#   .opencode/skills     -> ../.ai/skills (symlink)
#   .cursorrules         <- Generated (compact)
#   .windsurfrules       <- Generated (compact)
#   .github/copilot-instructions.md <- Generated (compact)
#
# Usage: .ai/sync.sh [--dry-run] [--check]
#

set -euo pipefail

# .ai/ is where this script lives; PROJECT_ROOT is the parent
AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AI_DIR/.." && pwd)"

# Mode
DRY_RUN=false
CHECK_ONLY=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --check) CHECK_ONLY=true ;;
    esac
done

# Source directories (inside .ai/)
AGENTS_SOURCE="$AI_DIR/agents"
SKILLS_SOURCE="$AI_DIR/skills"
DECISIONS_SOURCE="$AI_DIR/decisions.md"

# Destination directories (at project root)
CLAUDE_AGENTS="$PROJECT_ROOT/.claude/agents"
CLAUDE_SKILLS="$PROJECT_ROOT/.claude/skills"
CLAUDE_RULES="$PROJECT_ROOT/.claude/rules"
OPENCODE_DIR="$PROJECT_ROOT/.opencode"
OPENCODE_AGENTS="$OPENCODE_DIR/agents"
OPENCODE_SKILLS="$OPENCODE_DIR/skills"

# Antigravity (Google)
ANTIGRAVITY_RULES="$PROJECT_ROOT/.agents/rules"
ANTIGRAVITY_WORKFLOWS="$PROJECT_ROOT/.agents/workflows"

# Base tools for Claude Code (always available: read + search)
CLAUDE_READ_TOOLS="Read, Glob, Grep, WebFetch, WebSearch, Task"

# Colors
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

# === VALIDATION ===

validate_agent() {
    local source_file="$1"
    local filename
    filename=$(basename "$source_file")
    local errors=0

    # Verify frontmatter has description
    if ! grep -q "^description:" "$source_file"; then
        log_warn "$filename: missing 'description' in frontmatter"
        ((errors++)) || true
    fi

    # Verify frontmatter has mode
    if ! grep -q "^mode:" "$source_file"; then
        log_warn "$filename: missing 'mode' in frontmatter"
        ((errors++)) || true
    else
        # Validate mode value
        local mode
        mode=$(grep -m1 "^mode:" "$source_file" | awk '{print $2}')
        case "$mode" in
            subagent|primary|context|base) ;;
            *) log_warn "$filename: invalid mode '$mode' (expected: subagent|primary|context|base)"; ((errors++)) || true ;;
        esac
    fi

    # Validate temperature if present
    if grep -q "^temperature:" "$source_file"; then
        local temp
        temp=$(grep -m1 "^temperature:" "$source_file" | awk '{print $2}')
        if ! awk "BEGIN{exit !($temp >= 0.0 && $temp <= 1.0)}" 2>/dev/null; then
            log_warn "$filename: temperature out of range '$temp' (expected: 0.0-1.0)"
            ((errors++)) || true
        fi
    fi

    # Verify required sections (subagents only)
    local mode
    mode=$(grep -m1 "^mode:" "$source_file" | awk '{print $2}' 2>/dev/null || echo "")
    if [[ "$mode" == "subagent" ]]; then
        if ! grep -q "Quality Gates\|Protocol" "$source_file"; then
            log_warn "$filename: missing 'Quality Gates' section"
            ((errors++)) || true
        fi
        if ! grep -q "Fatal Restrictions" "$source_file"; then
            log_warn "$filename: missing 'Fatal Restrictions' section"
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

    # Extract frontmatter (between first and second ---)
    local frontmatter
    frontmatter=$(awk '/^---$/{c++;if(c==2)exit;next}c==1' "$source_file")

    # Opt-in: only include if frontmatter explicitly says "tool: true"
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
    local agent_name="$filename"  # Already kebab-case

    # Extract description from frontmatter
    local description
    description=$(grep -m1 "^description:" "$source_file" | sed 's/^description: *//' || echo "")

    # Build tools list from source frontmatter
    local tools
    tools=$(build_claude_tools "$source_file")

    # Extract content (everything after the second ---), removing initial blank lines
    local content
    content=$(awk '/^---$/{c++;next}c>=2' "$source_file" | sed '/./,$!d')

    # Expand _base.md reference with actual content
    local base_file="$AGENTS_SOURCE/_base.md"
    if [[ -f "$base_file" ]] && echo "$content" | grep -q "_base.md"; then
        local base_content
        base_content=$(awk '/^---$/{c++;next}c>=2' "$base_file" | sed '1,/^$/d' | sed '/^Sections inherited by all subagents/d' | sed '/^# Base Agent Structure/d')
        # If the agent already has "Where You Operate", remove the generic section from _base.md to avoid duplicates
        if echo "$content" | grep -q "## Where You Operate"; then
            base_content=$(echo "$base_content" | awk '/^## Where You Operate \(Permissions\)/{skip=1} /^## [^W]/{skip=0} !skip')
        fi
        content=$(echo "$content" | sed '/Inherits from.*_base.md/d')
        content="$content"$'\n\n'"$base_content"
    fi

    local dest="$CLAUDE_AGENTS/$agent_name.md"

    if $DRY_RUN; then
        log_dry "Would generate $dest"
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
        log_dry "Would create symlink $name"
        return
    fi

    if [[ -L "$link" ]]; then
        # Update if pointing elsewhere
        local current_target
        current_target=$(readlink "$link")
        if [[ "$current_target" != "$target" ]]; then
            rm "$link"
            ln -s "$target" "$link"
            log_info "$name (symlink updated)"
        else
            log_info "$name (symlink exists)"
        fi
    elif [[ -e "$link" ]]; then
        log_warn "$name (exists but is not a symlink)"
    else
        ln -s "$target" "$link"
        log_info "$name (symlink created)"
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
            gate_text=$(echo "$line" | sed 's/.*(\(Prevents:[^)]*\)).*/\1/' 2>/dev/null || echo "")
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
    output+="- **Zero Trust:** Validate all inputs.\n"
    output+="- **Clean Arch:** Domain > Application > Infrastructure.\n"
    output+="- **Logs:** Structured JSON with correlationId.\n"
    output+="- **TDD:** No production code without a failing test.\n"

    # Workflow
    output+="\n## Workflow\n\n"
    output+="1. @product-owner (requirements) -> 2. @architect + @ux-designer (design)\n"
    output+="3. @database-engineer (if schema changes) -> 4. @tdd-developer (implementation)\n"
    output+="5. @security-auditor (OWASP) -> 6. @qa-engineer (coverage) -> 7. @devops (deploy)\n"
    output+="Cross-cutting: @technical-writer, @observability-engineer, @performance-engineer\n"

    # Decisions
    if [[ -f "$DECISIONS_SOURCE" ]]; then
        output+="\n## Decisions\n\n"
        local decisions_content
        # Extract from the first section (##), skipping the header
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
    output+="Consult Feature Specs in \`docs/specs/\` as project memory.\n"
    output+="Closed decisions in \`.ai/decisions.md\`.\n"

    echo -e "$output"
}

# === MAIN ===

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   .ai/sync.sh - Agent Sync                        ║${NC}"
    echo -e "${BLUE}║   Distributes agents to all tools                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"

    if $DRY_RUN; then
        echo -e "${YELLOW}Dry-run mode: no files will be written${NC}"
    fi
    if $CHECK_ONLY; then
        echo -e "${YELLOW}Check mode: validation only${NC}"
    fi

    # Verify sources
    if [[ ! -d "$AGENTS_SOURCE" ]]; then
        log_error "$AGENTS_SOURCE does not exist"
        exit 1
    fi
    if [[ ! -d "$SKILLS_SOURCE" ]]; then
        log_error "$SKILLS_SOURCE does not exist"
        exit 1
    fi

    # === VALIDATION ===
    log_section "Agent validation"
    local total_errors=0
    for f in "$AGENTS_SOURCE"/*.md; do
        [[ -f "$f" ]] || continue
        if ! validate_agent "$f"; then
            ((total_errors++)) || true
        fi
    done
    if [[ $total_errors -eq 0 ]]; then
        log_info "All agents valid"
    else
        log_warn "$total_errors agent(s) with warnings"
    fi

    if $CHECK_ONLY; then
        echo ""
        echo "Validation complete. Errors: $total_errors"
        exit $total_errors
    fi

    # === OPENCODE: Symlinks ===
    log_section "OpenCode (symlinks)"
    mkdir -p "$OPENCODE_DIR"
    create_symlink "../.ai/agents" "$OPENCODE_AGENTS" ".opencode/agents -> ../.ai/agents"
    create_symlink "../.ai/skills" "$OPENCODE_SKILLS" ".opencode/skills -> ../.ai/skills"

    if [[ -f "$DECISIONS_SOURCE" ]]; then
        if $DRY_RUN; then
            log_dry "Would copy decisions.md -> .opencode/decisions.md"
        else
            cp "$DECISIONS_SOURCE" "$OPENCODE_DIR/decisions.md"
            log_info "decisions.md -> .opencode/decisions.md"
        fi
    fi

    # === CLAUDE CODE: Agent conversion ===
    log_section "Claude Code (agent conversion)"
    if ! $DRY_RUN; then
        mkdir -p "$CLAUDE_AGENTS"
    fi

    local agent_count=0
    for f in "$AGENTS_SOURCE"/*.md; do
        [[ -f "$f" ]] || continue
        if should_skip_agent "$(basename "$f")"; then
            log_skip "$(basename "$f") (excluded)"
            continue
        fi
        process_agent "$f"
        ((agent_count++)) || true
    done

    # === CLAUDE CODE: Skills symlink ===
    log_section "Claude Code (skills + rules)"
    if ! $DRY_RUN; then
        mkdir -p "$PROJECT_ROOT/.claude"
    fi
    create_symlink "../.ai/skills" "$CLAUDE_SKILLS" ".claude/skills -> ../.ai/skills"

    # === CLAUDE CODE: Rules (auto-loaded) ===
    if ! $DRY_RUN; then
        mkdir -p "$CLAUDE_RULES"
    fi

    if [[ -f "$DECISIONS_SOURCE" ]]; then
        if $DRY_RUN; then
            log_dry "Would copy decisions.md -> .claude/rules/decisions.md"
        else
            cp "$DECISIONS_SOURCE" "$CLAUDE_RULES/decisions.md"
            log_info "decisions.md -> .claude/rules/decisions.md"
        fi
    fi

    # Copy project-context.md to rules (auto-loaded)
    local ctx_file="$AGENTS_SOURCE/project-context.md"
    if [[ -f "$ctx_file" ]]; then
        if $DRY_RUN; then
            log_dry "Would copy project-context.md -> .claude/rules/project-context.md"
        else
            # Extract content only (without YAML frontmatter)
            awk '/^---$/{c++;next}c>=2' "$ctx_file" > "$CLAUDE_RULES/project-context.md"
            log_info "project-context.md -> .claude/rules/project-context.md"
        fi
    fi

    # === COMPACT RULES ===
    log_section "Compact rules (Cursor, Windsurf, Copilot)"
    local compact_rules
    compact_rules=$(generate_compact_rules)

    if $DRY_RUN; then
        log_dry "Would generate .cursorrules, .windsurfrules, GEMINI.md, .github/copilot-instructions.md"
    else
        echo -e "$compact_rules" > "$PROJECT_ROOT/.cursorrules"
        log_info ".cursorrules (generated)"

        echo -e "$compact_rules" > "$PROJECT_ROOT/.windsurfrules"
        log_info ".windsurfrules (generated)"

        echo -e "$compact_rules" > "$PROJECT_ROOT/GEMINI.md"
        log_info "GEMINI.md (generated)"

        mkdir -p "$PROJECT_ROOT/.github"
        echo -e "$compact_rules" > "$PROJECT_ROOT/.github/copilot-instructions.md"
        log_info ".github/copilot-instructions.md (generated)"
    fi

    # === SHARED: .agents/skills symlink (Codex + Gemini CLI + Antigravity) ===
    log_section "Shared skills (.agents/skills)"
    mkdir -p "$PROJECT_ROOT/.agents"
    create_symlink "../../.ai/skills" "$PROJECT_ROOT/.agents/skills" ".agents/skills -> ../../.ai/skills"

    # === GEMINI CLI: .gemini/skills symlink ===
    mkdir -p "$PROJECT_ROOT/.gemini"
    create_symlink "../../.ai/skills" "$PROJECT_ROOT/.gemini/skills" ".gemini/skills -> ../../.ai/skills"

    # === ANTIGRAVITY (Google): Rules + Workflows ===
    log_section "Antigravity (rules + workflows)"

    if $DRY_RUN; then
        log_dry "Would generate .agents/rules/ and .agents/workflows/"
    else
        mkdir -p "$ANTIGRAVITY_RULES" "$ANTIGRAVITY_WORKFLOWS"

        # Rules: agents as @mentionable rules (Manual activation)
        for f in "$AGENTS_SOURCE"/*.md; do
            [[ -f "$f" ]] || continue
            local fname
            fname=$(basename "$f")

            # Skip base file
            [[ "$fname" == _* ]] && continue

            # Extract content without YAML frontmatter
            local content
            content=$(awk '/^---$/{c++;next}c>=2' "$f" | sed '/./,$!d')

            # Project-context gets "Always On" note
            if [[ "$fname" == "project-context.md" ]]; then
                echo -e "<!-- Activation: Always On -->\n\n$content" > "$ANTIGRAVITY_RULES/$fname"
            else
                echo -e "<!-- Activation: Manual (@$(basename "$fname" .md)) -->\n\n$content" > "$ANTIGRAVITY_RULES/$fname"
            fi
        done
        log_info ".agents/rules/ ($(ls "$ANTIGRAVITY_RULES"/*.md 2>/dev/null | wc -l | tr -d ' ') rules)"

        # Workflows: prompts as /invocable workflows (English only)
        for f in "$AI_DIR/prompts"/*.md; do
            [[ -f "$f" ]] || continue
            local fname
            fname=$(basename "$f")
            cp "$f" "$ANTIGRAVITY_WORKFLOWS/$fname"
        done
        log_info ".agents/workflows/ ($(ls "$ANTIGRAVITY_WORKFLOWS"/*.md 2>/dev/null | wc -l | tr -d ' ') workflows)"

        # Decisions as Always On rule
        if [[ -f "$DECISIONS_SOURCE" ]]; then
            cp "$DECISIONS_SOURCE" "$ANTIGRAVITY_RULES/decisions.md"
            log_info "decisions.md -> .agents/rules/decisions.md"
        fi
    fi

    # === SUMMARY ===
    log_section "Summary"
    echo -e "Agents converted: ${GREEN}$agent_count${NC}"
    if [[ $total_errors -gt 0 ]]; then
        echo -e "Agents with warnings: ${YELLOW}$total_errors${NC}"
    fi
    echo ""
    echo "Generated structure:"
    echo "  .ai/agents/            Source (kebab-case)"
    echo "  .ai/skills/            Source"
    echo "  .ai/decisions.md       Source (cross-tool)"
    echo "  .opencode/agents       -> ../.ai/agents (symlink)"
    echo "  .opencode/skills       -> ../.ai/skills (symlink)"
    echo "  .opencode/decisions.md Copy"
    echo "  .claude/agents/        Generated (Claude Code format)"
    echo "  .claude/skills         -> ../.ai/skills (symlink)"
    echo "  .claude/rules/         Generated (decisions.md, project-context.md)"
    echo "  .agents/skills         -> ../../.ai/skills (shared: Codex + Gemini CLI + Antigravity)"
    echo "  .agents/rules/         Generated (Antigravity rules)"
    echo "  .agents/workflows/     Generated (Antigravity workflows)"
    echo "  .gemini/skills         -> ../../.ai/skills (Gemini CLI)"
    echo "  .cursorrules           Generated (compact)"
    echo "  .windsurfrules         Generated (compact)"
    echo "  GEMINI.md              Generated (compact)"
    echo "  .github/copilot-instructions.md  Generated (compact)"
}

main "$@"
