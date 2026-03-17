#!/usr/bin/env bash
#
# session-stop.sh - Guarda resumen de sesion al terminar
# Se ejecuta automaticamente via Claude Code hooks (SessionEnd)
#
# Recibe JSON en stdin con: session_id, cwd, reason, etc.
# reason puede ser: "clear", "logout", "prompt_input_exit", etc.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"

# Parsear JSON de stdin
hook_input=$(cat 2>/dev/null || echo "{}")
reason=$(echo "$hook_input" | jq -r '.reason // "unknown"' 2>/dev/null || echo "unknown")
session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Intentar guardar en Engram si esta disponible
if command -v engram &>/dev/null; then
    engram store --project "$PROJECT_NAME" --tag "session-end" \
        --message "Session $session_id ended ($reason) at $timestamp" 2>/dev/null || true
fi

# Guardar fallback local
mkdir -p "$(dirname "$FALLBACK_FILE")"
cat > "$FALLBACK_FILE" << TEMPLATE
# Last Session
**Ended:** $timestamp
**Project:** $PROJECT_NAME
**Session:** $session_id
**Reason:** $reason
TEMPLATE

exit 0
