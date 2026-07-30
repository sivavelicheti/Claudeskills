#!/usr/bin/env bash
# PostToolUse (Write|Edit): when .security-review/findings.json is written,
# warn if it contains Critical findings so they are surfaced immediately.
set -euo pipefail

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  FILE_PATH="$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi

case "$FILE_PATH" in
  *.security-review/findings.json) ;;
  *) exit 0 ;;
esac

[ -f "$FILE_PATH" ] || exit 0

if command -v jq >/dev/null 2>&1; then
  CRITICALS="$(jq -r '[.findings[]? | select(.cvss.severity == "Critical" and .status == "open") | .id] | join(", ")' "$FILE_PATH" 2>/dev/null || true)"
  COUNT="$(printf '%s' "$CRITICALS" | awk -F', ' 'NF{print NF} !NF{print 0}')"
else
  COUNT="$(grep -c '"severity"[[:space:]]*:[[:space:]]*"Critical"' "$FILE_PATH" 2>/dev/null || true)"
  CRITICALS="(install jq for IDs)"
fi

if [ "${COUNT:-0}" -gt 0 ] 2>/dev/null; then
  printf '{"systemMessage": "SECURITY-REVIEW WARNING: findings.json contains %s open Critical finding(s): %s. Surface these to the user now and recommend /security-remediate before anything ships."}\n' "$COUNT" "$CRITICALS"
fi

exit 0
