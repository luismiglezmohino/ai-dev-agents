#!/usr/bin/env bash
#
# pre-compact.sh - Guarda estado antes de que Claude Code compacte contexto
# Se ejecuta automaticamente via Claude Code hooks (PreCompact)
#
# Recibe JSON en stdin con: session_id, transcript_path, trigger, cwd, etc.
# El transcript completo esta en el archivo apuntado por transcript_path.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"

# Parsear JSON de stdin
hook_input=$(cat 2>/dev/null || echo "{}")
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Leer transcript desde archivo (no stdin)
transcript=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    transcript=$(tail -200 "$transcript_path" 2>/dev/null || echo "")
fi

# Intentar guardar en Engram si esta disponible
if command -v engram &>/dev/null && [[ -n "$transcript" ]]; then
    echo "$transcript" | engram store --project "$PROJECT_NAME" --tag "pre-compact" 2>/dev/null || true
fi

# Siempre guardar fallback local (ultimas lineas para no llenar disco)
mkdir -p "$(dirname "$FALLBACK_FILE")"
cat > "$FALLBACK_FILE" << TEMPLATE
# Session Context (pre-compact)
**Saved:** $timestamp
**Project:** $PROJECT_NAME

## Transcript (ultimas lineas)
${transcript:-No transcript available}
TEMPLATE

exit 0
