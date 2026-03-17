#!/usr/bin/env bash
#
# session-start.sh - Injects context from previous sessions on startup
# Runs automatically via Claude Code hooks (SessionStart)
#
# Receives JSON on stdin with: session_id, cwd, matcher (startup|resume|compact), etc.
# Whatever is printed to stdout is injected as context for Claude.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Try to use Engram if available
if command -v engram &>/dev/null; then
    context=$(engram recall --project "$PROJECT_NAME" --limit 5 --format text 2>/dev/null || echo "")
    if [[ -n "$context" ]]; then
        echo "## Previous session context (via Engram)"
        echo ""
        echo "$context"
        exit 0
    fi
fi

# Fallback: read local file if it exists
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"
if [[ -f "$FALLBACK_FILE" ]]; then
    echo "## Last session context (via local file)"
    echo ""
    cat "$FALLBACK_FILE"
    exit 0
fi

# No previous context available
exit 0
