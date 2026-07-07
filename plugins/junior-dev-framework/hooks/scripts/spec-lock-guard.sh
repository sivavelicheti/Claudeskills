#!/usr/bin/env bash
# PreToolUse guard on Edit/Write: an approved spec or plan is the contract.
# Claude may not modify specs/*.md files whose frontmatter says 'status: approved'.
# Humans can still edit them in their editor; to let Claude amend one, the developer
# flips it back to 'status: draft' first (a deliberate, visible act).
set -euo pipefail

INPUT="$(cat)"

file_path=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)

case "$file_path" in
  */specs/*.md|specs/*.md) ;;
  *) exit 0 ;;
esac

if [ -f "$file_path" ] && grep -qiE '^status:[[:space:]]*approved' "$file_path"; then
  echo "BLOCKED: $file_path is an APPROVED spec/plan and is locked. If it genuinely needs to change, ask the developer to set 'status: draft' (and re-approve afterwards) — the spec changes by human decision, not silently during implementation." >&2
  exit 2
fi

exit 0
