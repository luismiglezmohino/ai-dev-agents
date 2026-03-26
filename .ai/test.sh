#!/usr/bin/env bash
#
# test.sh - Template structure validation
# Usage: .ai/test.sh
#

set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AI_DIR/.." && pwd)"

ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { echo -e "${RED}[FAIL]${NC} $1"; ((ERRORS++)) || true; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARNINGS++)) || true; }
pass() { echo -e "${GREEN}[PASS]${NC} $1"; }

echo "=== Test 1: Required directories ==="

for dir in "$AI_DIR/agents" "$AI_DIR/skills" "$AI_DIR/hooks"; do
    if [[ -d "$dir" ]]; then
        pass "$(basename "$dir")/ exists"
    else
        fail "$(basename "$dir")/ does not exist"
    fi
done

echo ""
echo "=== Test 2: Required files ==="

for file in "$AI_DIR/decisions.md" "$AI_DIR/sync.sh"; do
    if [[ -f "$file" ]]; then
        pass "File $(basename "$file") exists"
    else
        fail "File $(basename "$file") does not exist"
    fi
done

echo ""
echo "=== Test 3: Agent validation ==="

for agent in "$AI_DIR"/agents/*.md; do
    [[ -f "$agent" ]] || continue
    fname=$(basename "$agent")

    # Skip base and files with _ prefix
    [[ "$fname" == _* ]] && continue

    # Required frontmatter: description
    if ! grep -q "^description:" "$agent"; then
        fail "$fname: missing 'description'"
    fi

    # Required frontmatter: mode
    if ! grep -q "^mode:" "$agent"; then
        fail "$fname: missing 'mode'"
    else
        mode=$(grep -m1 "^mode:" "$agent" | awk '{print $2}')
        case "$mode" in
            subagent|primary|context|base) ;;
            *) fail "$fname: invalid mode '$mode'" ;;
        esac
    fi

    # Temperature in range (if present)
    if grep -q "^temperature:" "$agent"; then
        temp=$(grep -m1 "^temperature:" "$agent" | awk '{print $2}')
        if ! awk "BEGIN{exit !($temp >= 0.0 && $temp <= 1.0)}" 2>/dev/null; then
            fail "$fname: temperature out of range '$temp'"
        fi
    fi

    # Required sections for subagents
    mode=$(grep -m1 "^mode:" "$agent" | awk '{print $2}' 2>/dev/null || echo "")
    if [[ "$mode" == "subagent" ]]; then
        grep -q "Quality Gates\|Protocol" "$agent" || fail "$fname: missing Quality Gates"
        grep -q "Fatal Restrictions" "$agent" || fail "$fname: missing Fatal Restrictions"
    fi
done
pass "Agents validated"

echo ""
echo "=== Test 4: Executable hooks ==="

for hook in "$AI_DIR"/hooks/*.sh; do
    [[ -f "$hook" ]] || continue
    if [[ -x "$hook" ]]; then
        pass "$(basename "$hook") is executable"
    else
        fail "$(basename "$hook") is not executable (chmod +x)"
    fi
done

echo ""
echo "=== Test 5: sync.sh executable ==="

if [[ -x "$AI_DIR/sync.sh" ]]; then
    pass "sync.sh is executable"
else
    fail "sync.sh is not executable"
fi

echo ""
echo "=== Test 6: Generated files ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    agent_count=$(ls "$PROJECT_ROOT/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    pass ".claude/agents/ has $agent_count agents"
else
    warn ".claude/agents/ does not exist (run .ai/sync.sh)"
fi

if [[ -f "$PROJECT_ROOT/.claude/rules/decisions.md" ]]; then
    pass ".claude/rules/decisions.md exists"
else
    warn ".claude/rules/decisions.md does not exist (run .ai/sync.sh)"
fi

echo ""
echo "=== Test 7: Granular tools in generated agents ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    for generated in "$PROJECT_ROOT/.claude/agents/"*.md; do
        [[ -f "$generated" ]] || continue
        gname=$(basename "$generated" .md)
        source_file="$AI_DIR/agents/$gname.md"
        [[ -f "$source_file" ]] || continue

        # Verify opt-in: agents WITHOUT write: true must NOT have Write in generated
        if ! grep -q "write: true" "$source_file"; then
            if grep -q "^tools:.*Write" "$generated"; then
                fail "$gname: has Write in generated but NOT write: true in source"
            else
                pass "$gname: no write: true → no Write (opt-in correct)"
            fi
        fi

        # Verify opt-in: agents WITHOUT edit: true must NOT have Edit in generated
        if ! grep -q "edit: true" "$source_file"; then
            if grep -q "^tools:.*Edit" "$generated"; then
                fail "$gname: has Edit in generated but NOT edit: true in source"
            else
                pass "$gname: no edit: true → no Edit (opt-in correct)"
            fi
        fi

        # Verify opt-in: agents WITHOUT bash: true must NOT have Bash in generated
        if ! grep -q "bash: true" "$source_file"; then
            if grep -q "^tools:.*Bash" "$generated"; then
                fail "$gname: has Bash in generated but NOT bash: true in source"
            else
                pass "$gname: no bash: true → no Bash (opt-in correct)"
            fi
        fi
        # Verify no double blank line after frontmatter
        if awk '/^---$/{c++;next}c==2{if(/^$/){blanks++;if(blanks>1){exit 1}}else{exit 0}}' "$generated"; then
            pass "$gname: no double blank line after frontmatter"
        else
            fail "$gname: double blank line after frontmatter"
        fi

        # Verify _base.md is expanded (no orphan reference remains)
        if grep -q "_base.md" "$source_file"; then
            if grep -q "Inherits from.*_base.md" "$generated"; then
                fail "$gname: _base.md reference not expanded in generated"
            fi
            if grep -q "Final Verification" "$generated"; then
                pass "$gname: _base.md expanded correctly"
            else
                fail "$gname: _base.md not expanded (missing Final Verification)"
            fi
        fi
    done
fi

echo ""
echo "=== Test 8: Generated files (compact rules + symlinks) ==="

# Compact rules: verify they exist and are not empty
for compact in ".cursorrules" ".windsurfrules" "GEMINI.md" ".github/copilot-instructions.md"; do
    filepath="$PROJECT_ROOT/$compact"
    if [[ -f "$filepath" ]]; then
        if [[ -s "$filepath" ]]; then
            pass "$compact exists and is not empty"
        else
            fail "$compact exists but is empty"
        fi
    else
        warn "$compact does not exist (run .ai/sync.sh)"
    fi
done

# Symlinks: verify they point to the correct target
for link_target in ".claude/skills:../.ai/skills" ".opencode/agents:../.ai/agents" ".opencode/skills:../.ai/skills" ".agents/skills:../.ai/skills" ".gemini/skills:../.ai/skills"; do
    link="${link_target%%:*}"
    target="${link_target##*:}"
    filepath="$PROJECT_ROOT/$link"
    if [[ -L "$filepath" ]]; then
        actual=$(readlink "$filepath")
        if [[ "$actual" == "$target" ]]; then
            pass "$link -> $target (correct symlink)"
        else
            fail "$link points to '$actual' instead of '$target'"
        fi
    else
        warn "$link is not a symlink (run .ai/sync.sh)"
    fi
done

# OpenCode decisions.md
if [[ -f "$PROJECT_ROOT/.opencode/decisions.md" ]]; then
    pass ".opencode/decisions.md exists"
else
    warn ".opencode/decisions.md does not exist (run .ai/sync.sh)"
fi

# Claude rules/project-context.md
if [[ -f "$PROJECT_ROOT/.claude/rules/project-context.md" ]]; then
    # Verify it does NOT have frontmatter (should be stripped)
    if head -1 "$PROJECT_ROOT/.claude/rules/project-context.md" | grep -q "^---$"; then
        fail ".claude/rules/project-context.md has frontmatter (should be without it)"
    else
        pass ".claude/rules/project-context.md exists (no frontmatter)"
    fi
else
    warn ".claude/rules/project-context.md does not exist (run .ai/sync.sh)"
fi

echo ""
echo "=== Test 9: Positive opt-in (agents WITH tools DO have them) ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    for generated in "$PROJECT_ROOT/.claude/agents/"*.md; do
        [[ -f "$generated" ]] || continue
        gname=$(basename "$generated" .md)
        source_file="$AI_DIR/agents/$gname.md"
        [[ -f "$source_file" ]] || continue

        # Verify agents WITH write: true DO have Write in generated
        if grep -q "write: true" "$source_file"; then
            if grep -q "^tools:.*Write" "$generated"; then
                pass "$gname: write: true → Write present"
            else
                fail "$gname: has write: true but NOT Write in generated"
            fi
        fi

        # Verify agents WITH edit: true DO have Edit in generated
        if grep -q "edit: true" "$source_file"; then
            if grep -q "^tools:.*Edit" "$generated"; then
                pass "$gname: edit: true → Edit present"
            else
                fail "$gname: has edit: true but NOT Edit in generated"
            fi
        fi

        # Verify agents WITH bash: true DO have Bash in generated
        if grep -q "bash: true" "$source_file"; then
            if grep -q "^tools:.*Bash" "$generated"; then
                pass "$gname: bash: true → Bash present"
            else
                fail "$gname: has bash: true but NOT Bash in generated"
            fi
        fi
    done
fi

echo ""
echo "=== Test 10: docs/ structure ==="

for dir in "$PROJECT_ROOT/docs/specs" "$PROJECT_ROOT/docs/adrs" "$PROJECT_ROOT/docs/stories" "$AI_DIR/docs"; do
    if [[ -d "$dir" ]]; then
        pass "$(echo "$dir" | sed "s|$PROJECT_ROOT/||") exists"
    else
        warn "$(echo "$dir" | sed "s|$PROJECT_ROOT/||") does not exist"
    fi
done

echo ""
echo "=== Test 11: Skills have SKILL.md ==="

for skill_dir in "$AI_DIR"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        pass "skills/$skill_name/SKILL.md exists"
    else
        fail "skills/$skill_name/ is missing SKILL.md"
    fi
done

echo ""
echo "=== Test 12: Semantic validation ==="

for agent in "$AI_DIR"/agents/*.md; do
    [[ -f "$agent" ]] || continue
    fname=$(basename "$agent")

    # Skip non-subagent files
    [[ "$fname" == _* ]] && continue
    [[ "$fname" == "project-context.md" ]] && continue
    [[ "$fname" == "orchestrator.md" ]] && continue
    mode=$(grep -m1 "^mode:" "$agent" | awk '{print $2}' 2>/dev/null || echo "")
    [[ "$mode" != "subagent" ]] && continue

    # Check: at least 1 gate with content
    gate_count=$(grep -c "\[Gate [0-9]" "$agent" 2>/dev/null || echo "0")
    if [[ "$gate_count" -ge 1 ]]; then
        pass "$fname: has $gate_count gate(s)"
    else
        fail "$fname: no Quality Gates found (expected [Gate N] format)"
    fi

    # Check: gates must be framework-agnostic (no specific framework names)
    # PHP: laravel, symfony, codeigniter, cakephp, yii, slim, lumen, drupal, wordpress
    # Python: django, flask, fastapi, tornado, bottle, sanic, starlette (pyramid excluded: conflicts with "testing pyramid")
    # JavaScript/TypeScript: react, angular, vue, svelte, nextjs, nuxt, remix, astro, express, nestjs, fastify, koa, hapi, adonis, hono, meteor, ember, backbone
    # Ruby: rails
    # Go: gin, fiber, echo, chi, beego
    # Rust: actix, rocket, axum, warp
    # Elixir: phoenix
    # Java/Kotlin: spring, quarkus, micronaut, ktor, play
    # .NET: blazor, aspnet
    # Mobile: flutter, swiftui, jetpack compose
    if grep -i "\[Gate" "$agent" | grep -iqE "\b(laravel|symfony|codeigniter|cakephp|yii|slim|lumen|drupal|wordpress|django|flask|fastapi|tornado|bottle|sanic|starlette|react|angular|vue|svelte|nextjs|nuxt|remix|astro|express|nestjs|fastify|koa|hapi|adonis|hono|meteor|ember|backbone|rails|gin|fiber|echo|chi|beego|actix|rocket|axum|warp|phoenix|spring|quarkus|micronaut|ktor|play|blazor|aspnet|flutter|swiftui|jetpack)\b"; then
        fail "$fname: gates reference a specific framework (gates must be agnostic)"
    else
        pass "$fname: gates are framework-agnostic"
    fi

    # Check: has Where You Operate section
    if grep -q "## Where You Operate" "$agent"; then
        pass "$fname: has Where You Operate"
    else
        warn "$fname: missing '## Where You Operate' section"
    fi

    # Check: has Mission section
    if grep -q "## Mission" "$agent"; then
        pass "$fname: has Mission"
    else
        warn "$fname: missing '## Mission' section"
    fi

    # Check: description is not empty
    desc=$(grep -m1 "^description:" "$agent" | sed 's/^description: *//')
    if [[ -n "$desc" && "$desc" != "\"\"" ]]; then
        pass "$fname: description is not empty"
    else
        fail "$fname: description is empty"
    fi
done

echo ""
echo "==================================="
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo "==================================="
exit $ERRORS
