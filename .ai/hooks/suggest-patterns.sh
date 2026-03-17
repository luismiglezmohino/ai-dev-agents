#!/usr/bin/env bash
#
# suggest-patterns.sh - Detecta patrones de la sesión y los sugiere para guardar
# Se ejecuta automáticamente via Claude Code hooks (SessionEnd)
# A diferencia de session-stop.sh, este hook analiza el transcript
# y sugiere patrones para los skills. El usuario debe aprobarlos manualmente.
#
# Funciona con Engram si está disponible, sino guarda en .ai/.local/suggested-patterns.md
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
SUGGESTIONS_FILE="$PROJECT_DIR/.ai/.local/suggested-patterns.md"
SKILLS_DIR="$PROJECT_DIR/.ai/skills"

# Parsear JSON de stdin
hook_input=$(cat 2>/dev/null || echo "{}")
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Necesitamos el transcript para analizar
transcript=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    transcript=$(tail -300 "$transcript_path" 2>/dev/null || echo "")
fi

# Sin transcript no hay nada que analizar
if [[ -z "$transcript" ]]; then
    exit 0
fi

# Detectar patrones básicos en el transcript
patterns=""

# Patrón: errores corregidos (fix, error, bug)
error_fixes=$(echo "$transcript" | grep -ci "fix\|error\|bug\|corrig" 2>/dev/null || echo "0")
if [[ "$error_fixes" -gt 2 ]]; then
    patterns+="- **Errores corregidos:** $error_fixes correcciones detectadas en esta sesión. Revisar si alguna debería ser una Restricción Fatal o un Quality Gate.\n"
fi

# Patrón: tests añadidos
tests_added=$(echo "$transcript" | grep -ci "test\|spec\|describe\|it(" 2>/dev/null || echo "0")
if [[ "$tests_added" -gt 3 ]]; then
    patterns+="- **Tests:** $tests_added referencias a tests. Revisar si los patrones de testing se reflejan en los skills.\n"
fi

# Patrón: refactoring
refactors=$(echo "$transcript" | grep -ci "refactor\|extract\|rename\|move" 2>/dev/null || echo "0")
if [[ "$refactors" -gt 2 ]]; then
    patterns+="- **Refactoring:** $refactors operaciones de refactoring. Revisar si el patrón se repite y debería documentarse.\n"
fi

# Patrón: nuevos ficheros creados
new_files=$(echo "$transcript" | grep -ci "Write\|create.*file\|nuevo.*fichero" 2>/dev/null || echo "0")
if [[ "$new_files" -gt 3 ]]; then
    patterns+="- **Ficheros nuevos:** $new_files ficheros creados. Revisar si la estructura sigue las convenciones del proyecto.\n"
fi

# Sin patrones detectados, no generar sugerencias
if [[ -z "$patterns" ]]; then
    exit 0
fi

# Guardar sugerencias (NO aplicarlas automáticamente)
mkdir -p "$(dirname "$SUGGESTIONS_FILE")"
cat >> "$SUGGESTIONS_FILE" << TEMPLATE

---

## Sesión $session_id ($timestamp)

**Patrones detectados (pendientes de aprobación):**

$(echo -e "$patterns")

**Acción requerida:** Revisa estos patrones. Si son válidos (se repiten en 2+ sesiones), añádelos al skill correspondiente en \`.ai/skills/\` usando \`.ai/prompts/refine-skills.md\`.

TEMPLATE

# Guardar en Engram si está disponible
if command -v engram &>/dev/null; then
    echo -e "$patterns" | engram store --project "$PROJECT_NAME" --tag "suggested-patterns" 2>/dev/null || true
fi

exit 0
