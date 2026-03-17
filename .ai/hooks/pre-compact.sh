#!/usr/bin/env bash
#
# pre-compact.sh - Saves state before Claude Code compacts context
# Runs automatically via Claude Code hooks (PreCompact)
#
# Receives JSON on stdin with: session_id, transcript_path, trigger, cwd, etc.
# The full transcript is in the file pointed to by transcript_path.
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
FALLBACK_FILE="$PROJECT_DIR/.ai/.local/last-session.md"

# Parse JSON from stdin
hook_input=$(cat 2>/dev/null || echo "{}")
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Read transcript from file (not stdin)
transcript=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    transcript=$(tail -200 "$transcript_path" 2>/dev/null || echo "")
fi

# Try to save to Engram if available
if command -v engram &>/dev/null && [[ -n "$transcript" ]]; then
    echo "$transcript" | engram store --project "$PROJECT_NAME" --tag "pre-compact" 2>/dev/null || true
fi

# Always save local fallback (last lines to avoid filling disk)
mkdir -p "$(dirname "$FALLBACK_FILE")"
cat > "$FALLBACK_FILE" << TEMPLATE
# Session Context (pre-compact)
**Saved:** $timestamp
**Project:** $PROJECT_NAME

## Transcript (last lines)
${transcript:-No transcript available}
TEMPLATE

exit 0
