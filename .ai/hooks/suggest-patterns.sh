#!/usr/bin/env bash
#
# suggest-patterns.sh - Detects session patterns and suggests them for saving
# Runs automatically via Claude Code hooks (SessionEnd)
# Unlike session-stop.sh, this hook analyzes the transcript
# and suggests patterns for skills. The user must approve them manually.
#
# Uses Engram if available, otherwise saves to .ai/.local/suggested-patterns.md
#

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_NAME=$(basename "$PROJECT_DIR")
SUGGESTIONS_FILE="$PROJECT_DIR/.ai/.local/suggested-patterns.md"
SKILLS_DIR="$PROJECT_DIR/.ai/skills"

# Parse JSON from stdin
hook_input=$(cat 2>/dev/null || echo "{}")
transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Need the transcript to analyze
transcript=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    transcript=$(tail -300 "$transcript_path" 2>/dev/null || echo "")
fi

# No transcript, nothing to analyze
if [[ -z "$transcript" ]]; then
    exit 0
fi

# Detect basic patterns in the transcript
patterns=""

# Pattern: corrected errors (fix, error, bug)
error_fixes=$(echo "$transcript" | grep -ci "fix\|error\|bug\|corrected" 2>/dev/null || echo "0")
if [[ "$error_fixes" -gt 2 ]]; then
    patterns+="- **Errors fixed:** $error_fixes fixes detected in this session. Review if any should become a Fatal Restriction or Quality Gate.\n"
fi

# Pattern: tests added
tests_added=$(echo "$transcript" | grep -ci "test\|spec\|describe\|it(" 2>/dev/null || echo "0")
if [[ "$tests_added" -gt 3 ]]; then
    patterns+="- **Tests:** $tests_added test references. Review if testing patterns are reflected in skills.\n"
fi

# Pattern: refactoring
refactors=$(echo "$transcript" | grep -ci "refactor\|extract\|rename\|move" 2>/dev/null || echo "0")
if [[ "$refactors" -gt 2 ]]; then
    patterns+="- **Refactoring:** $refactors refactoring operations. Review if the pattern recurs and should be documented.\n"
fi

# Pattern: new files created
new_files=$(echo "$transcript" | grep -ci "Write\|create.*file\|new.*file" 2>/dev/null || echo "0")
if [[ "$new_files" -gt 3 ]]; then
    patterns+="- **New files:** $new_files files created. Review if the structure follows project conventions.\n"
fi

# No patterns detected, don't generate suggestions
if [[ -z "$patterns" ]]; then
    exit 0
fi

# Save suggestions (DO NOT apply them automatically)
mkdir -p "$(dirname "$SUGGESTIONS_FILE")"
cat >> "$SUGGESTIONS_FILE" << TEMPLATE

---

## Session $session_id ($timestamp)

**Detected patterns (pending approval):**

$(echo -e "$patterns")

**Action required:** Review these patterns. If valid (repeated in 2+ sessions), add them to the corresponding skill in \`.ai/skills/\` using \`.ai/prompts/refine-skills.md\`.

TEMPLATE

# Save to Engram if available
if command -v engram &>/dev/null; then
    echo -e "$patterns" | engram store --project "$PROJECT_NAME" --tag "suggested-patterns" 2>/dev/null || true
fi

exit 0
