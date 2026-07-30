#!/usr/bin/env bash
# PostToolUse (Read): verification hook for the context-budget rules.
# Tracks distinct security-standards reference files read per session and
# warns when more than 2 have been opened — the standards-mapper is supposed
# to work batch-by-category with at most 2 reference files at a time.
set -euo pipefail

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
  SESSION_ID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"')"
else
  FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
  SESSION_ID="$(printf '%s' "$INPUT" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
  SESSION_ID="${SESSION_ID:-unknown}"
fi

case "$FILE_PATH" in
  *skills/security-standards/references/*) ;;
  *) exit 0 ;;
esac

STATE_DIR="${TMPDIR:-/tmp}/security-review-refguard"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SESSION_ID}.reads"

BASENAME="$(basename "$FILE_PATH")"
touch "$STATE_FILE"
grep -qxF "$BASENAME" "$STATE_FILE" || printf '%s\n' "$BASENAME" >> "$STATE_FILE"

DISTINCT="$(sort -u "$STATE_FILE" | grep -c . || true)"

if [ "${DISTINCT:-0}" -gt 2 ] 2>/dev/null; then
  FILES="$(sort -u "$STATE_FILE" | tr '\n' ' ')"
  printf '{"systemMessage": "SECURITY-REVIEW CONTEXT-BUDGET WARNING: %s distinct reference files read in this session (%s). The budget is at most 2 per mapping batch — route via SKILL.md and finish the current category before opening another file."}\n' "$DISTINCT" "$FILES"
fi

exit 0
