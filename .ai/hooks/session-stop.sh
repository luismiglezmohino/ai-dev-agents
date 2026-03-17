#!/usr/bin/env bash
#
# session-stop.sh - Saves session summary on exit
# Runs automatically via Claude Code hooks (SessionEnd)
#
# Receives JSON on stdin with: session_id, cwd, reason, etc.
# reason can be: "clear", "logout", "prompt_input_exit", etc.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"

# Parse JSON from stdin
hook_input=$(cat 2>/dev/null || echo "{}")
reason=$(echo "$hook_input" | jq -r '.reason // "unknown"' 2>/dev/null || echo "unknown")
session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Try to save to Engram if available
if command -v engram &>/dev/null; then
    engram store --project "$PROJECT_NAME" --tag "session-end" \
        --message "Session $session_id ended ($reason) at $timestamp" 2>/dev/null || true
fi

# Save local fallback
mkdir -p "$(dirname "$FALLBACK_FILE")"
cat > "$FALLBACK_FILE" << TEMPLATE
# Last Session
**Ended:** $timestamp
**Project:** $PROJECT_NAME
**Session:** $session_id
**Reason:** $reason
TEMPLATE

exit 0
