#!/usr/bin/env bash
#
# session-start.sh - Inyecta contexto de sesiones anteriores al iniciar
# Se ejecuta automaticamente via Claude Code hooks (SessionStart)
#
# Recibe JSON en stdin con: session_id, cwd, matcher (startup|resume|compact), etc.
# Lo que se imprime por stdout se inyecta como contexto para Claude.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Intentar usar Engram si esta disponible
if command -v engram &>/dev/null; then
    context=$(engram recall --project "$PROJECT_NAME" --limit 5 --format text 2>/dev/null || echo "")
    if [[ -n "$context" ]]; then
        echo "## Contexto de sesiones anteriores (via Engram)"
        echo ""
        echo "$context"
        exit 0
    fi
fi

# Fallback: leer archivo local si existe
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"
if [[ -f "$FALLBACK_FILE" ]]; then
    echo "## Contexto de ultima sesion (via archivo local)"
    echo ""
    cat "$FALLBACK_FILE"
    exit 0
fi

# Sin contexto previo disponible
exit 0
