#!/usr/bin/env bash
#
# test.sh - Validacion de estructura del template
# Uso: .ai/test.sh
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

echo "=== Test 1: Directorios obligatorios ==="

for dir in "$AI_DIR/agents" "$AI_DIR/skills" "$AI_DIR/hooks"; do
    if [[ -d "$dir" ]]; then
        pass "$(basename "$dir")/ existe"
    else
        fail "$(basename "$dir")/ no existe"
    fi
done

echo ""
echo "=== Test 2: Archivos obligatorios ==="

for file in "$AI_DIR/decisions.md" "$AI_DIR/sync.sh"; do
    if [[ -f "$file" ]]; then
        pass "Archivo $(basename "$file") existe"
    else
        fail "Archivo $(basename "$file") no existe"
    fi
done

echo ""
echo "=== Test 3: Validacion de agentes ==="

for agent in "$AI_DIR"/agents/*.md; do
    [[ -f "$agent" ]] || continue
    fname=$(basename "$agent")

    # Skip base y archivos con prefijo _
    [[ "$fname" == _* ]] && continue

    # Frontmatter obligatorio: description
    if ! grep -q "^description:" "$agent"; then
        fail "$fname: falta 'description'"
    fi

    # Frontmatter obligatorio: mode
    if ! grep -q "^mode:" "$agent"; then
        fail "$fname: falta 'mode'"
    else
        mode=$(grep -m1 "^mode:" "$agent" | awk '{print $2}')
        case "$mode" in
            subagent|primary|context|base) ;;
            *) fail "$fname: mode invalido '$mode'" ;;
        esac
    fi

    # Temperature en rango (si existe)
    if grep -q "^temperature:" "$agent"; then
        temp=$(grep -m1 "^temperature:" "$agent" | awk '{print $2}')
        if ! awk "BEGIN{exit !($temp >= 0.0 && $temp <= 1.0)}" 2>/dev/null; then
            fail "$fname: temperature fuera de rango '$temp'"
        fi
    fi

    # Secciones obligatorias para subagents
    mode=$(grep -m1 "^mode:" "$agent" | awk '{print $2}' 2>/dev/null || echo "")
    if [[ "$mode" == "subagent" ]]; then
        grep -q "Quality Gates\|Protocolo" "$agent" || fail "$fname: falta Quality Gates"
        grep -q "Restricciones Fatales" "$agent" || fail "$fname: falta Restricciones Fatales"
    fi
done
pass "Agentes validados"

echo ""
echo "=== Test 4: Hooks ejecutables ==="

for hook in "$AI_DIR"/hooks/*.sh; do
    [[ -f "$hook" ]] || continue
    if [[ -x "$hook" ]]; then
        pass "$(basename "$hook") es ejecutable"
    else
        fail "$(basename "$hook") no es ejecutable (chmod +x)"
    fi
done

echo ""
echo "=== Test 5: sync.sh ejecutable ==="

if [[ -x "$AI_DIR/sync.sh" ]]; then
    pass "sync.sh es ejecutable"
else
    fail "sync.sh no es ejecutable"
fi

echo ""
echo "=== Test 6: Archivos generados ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    agent_count=$(ls "$PROJECT_ROOT/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    pass ".claude/agents/ tiene $agent_count agentes"
else
    warn ".claude/agents/ no existe (ejecutar .ai/sync.sh)"
fi

if [[ -f "$PROJECT_ROOT/.claude/rules/decisions.md" ]]; then
    pass ".claude/rules/decisions.md existe"
else
    warn ".claude/rules/decisions.md no existe (ejecutar .ai/sync.sh)"
fi

echo ""
echo "=== Test 7: Tools granulares en agentes generados ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    for generated in "$PROJECT_ROOT/.claude/agents/"*.md; do
        [[ -f "$generated" ]] || continue
        gname=$(basename "$generated" .md)
        source_file="$AI_DIR/agents/$gname.md"
        [[ -f "$source_file" ]] || continue

        # Verificar opt-in: agentes SIN write: true NO deben tener Write en generado
        if ! grep -q "write: true" "$source_file"; then
            if grep -q "^tools:.*Write" "$generated"; then
                fail "$gname: tiene Write en generado pero NO tiene write: true en fuente"
            else
                pass "$gname: sin write: true → sin Write (opt-in correcto)"
            fi
        fi

        # Verificar opt-in: agentes SIN edit: true NO deben tener Edit en generado
        if ! grep -q "edit: true" "$source_file"; then
            if grep -q "^tools:.*Edit" "$generated"; then
                fail "$gname: tiene Edit en generado pero NO tiene edit: true en fuente"
            else
                pass "$gname: sin edit: true → sin Edit (opt-in correcto)"
            fi
        fi

        # Verificar opt-in: agentes SIN bash: true NO deben tener Bash en generado
        if ! grep -q "bash: true" "$source_file"; then
            if grep -q "^tools:.*Bash" "$generated"; then
                fail "$gname: tiene Bash en generado pero NO tiene bash: true en fuente"
            else
                pass "$gname: sin bash: true → sin Bash (opt-in correcto)"
            fi
        fi
        # Verificar que no hay doble linea en blanco despues del frontmatter
        if awk '/^---$/{c++;next}c==2{if(/^$/){blanks++;if(blanks>1){exit 1}}else{exit 0}}' "$generated"; then
            pass "$gname: sin doble linea en blanco tras frontmatter"
        else
            fail "$gname: doble linea en blanco tras frontmatter"
        fi

        # Verificar que _base.md se expande (no queda referencia huerfana)
        if grep -q "_base.md" "$source_file"; then
            if grep -q "Hereda de.*_base.md" "$generated"; then
                fail "$gname: referencia a _base.md no expandida en generado"
            fi
            if grep -q "Verificacion Final" "$generated"; then
                pass "$gname: _base.md expandido correctamente"
            else
                fail "$gname: _base.md no expandido (falta Verificacion Final)"
            fi
        fi
    done
fi

echo ""
echo "=== Test 8: Archivos generados (compact rules + symlinks) ==="

# Compact rules: verificar que existen y no estan vacios
for compact in ".cursorrules" ".windsurfrules" "GEMINI.md" ".github/copilot-instructions.md"; do
    filepath="$PROJECT_ROOT/$compact"
    if [[ -f "$filepath" ]]; then
        if [[ -s "$filepath" ]]; then
            pass "$compact existe y no esta vacio"
        else
            fail "$compact existe pero esta vacio"
        fi
    else
        warn "$compact no existe (ejecutar .ai/sync.sh)"
    fi
done

# Symlinks: verificar que apuntan al destino correcto
for link_target in ".claude/skills:../.ai/skills" ".opencode/agents:../.ai/agents" ".opencode/skills:../.ai/skills"; do
    link="${link_target%%:*}"
    target="${link_target##*:}"
    filepath="$PROJECT_ROOT/$link"
    if [[ -L "$filepath" ]]; then
        actual=$(readlink "$filepath")
        if [[ "$actual" == "$target" ]]; then
            pass "$link -> $target (symlink correcto)"
        else
            fail "$link apunta a '$actual' en vez de '$target'"
        fi
    else
        warn "$link no es symlink (ejecutar .ai/sync.sh)"
    fi
done

# OpenCode decisions.md
if [[ -f "$PROJECT_ROOT/.opencode/decisions.md" ]]; then
    pass ".opencode/decisions.md existe"
else
    warn ".opencode/decisions.md no existe (ejecutar .ai/sync.sh)"
fi

# Claude rules/project-context.md
if [[ -f "$PROJECT_ROOT/.claude/rules/project-context.md" ]]; then
    # Verificar que NO tiene frontmatter (debe estar stripped)
    if head -1 "$PROJECT_ROOT/.claude/rules/project-context.md" | grep -q "^---$"; then
        fail ".claude/rules/project-context.md tiene frontmatter (deberia estar sin el)"
    else
        pass ".claude/rules/project-context.md existe (sin frontmatter)"
    fi
else
    warn ".claude/rules/project-context.md no existe (ejecutar .ai/sync.sh)"
fi

echo ""
echo "=== Test 9: Opt-in positivo (agentes CON tools SI los tienen) ==="

if [[ -d "$PROJECT_ROOT/.claude/agents" ]]; then
    for generated in "$PROJECT_ROOT/.claude/agents/"*.md; do
        [[ -f "$generated" ]] || continue
        gname=$(basename "$generated" .md)
        source_file="$AI_DIR/agents/$gname.md"
        [[ -f "$source_file" ]] || continue

        # Verificar que agentes CON write: true SI tienen Write en generado
        if grep -q "write: true" "$source_file"; then
            if grep -q "^tools:.*Write" "$generated"; then
                pass "$gname: write: true → Write presente"
            else
                fail "$gname: tiene write: true pero NO tiene Write en generado"
            fi
        fi

        # Verificar que agentes CON edit: true SI tienen Edit en generado
        if grep -q "edit: true" "$source_file"; then
            if grep -q "^tools:.*Edit" "$generated"; then
                pass "$gname: edit: true → Edit presente"
            else
                fail "$gname: tiene edit: true pero NO tiene Edit en generado"
            fi
        fi

        # Verificar que agentes CON bash: true SI tienen Bash en generado
        if grep -q "bash: true" "$source_file"; then
            if grep -q "^tools:.*Bash" "$generated"; then
                pass "$gname: bash: true → Bash presente"
            else
                fail "$gname: tiene bash: true pero NO tiene Bash en generado"
            fi
        fi
    done
fi

echo ""
echo "=== Test 10: Estructura docs/ ==="

for dir in "$PROJECT_ROOT/docs/specs" "$PROJECT_ROOT/docs/adrs" "$PROJECT_ROOT/docs/stories" "$PROJECT_ROOT/docs/guides"; do
    if [[ -d "$dir" ]]; then
        pass "$(echo "$dir" | sed "s|$PROJECT_ROOT/||") existe"
    else
        warn "$(echo "$dir" | sed "s|$PROJECT_ROOT/||") no existe"
    fi
done

echo ""
echo "==================================="
echo -e "Errores: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo "==================================="
exit $ERRORS
