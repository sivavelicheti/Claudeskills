#!/usr/bin/env bash
# PreToolUse guard on Bash: enforces the workflow at push time.
# Blocks (exit 2, stderr goes back to Claude) when:
#   - pushing from a branch whose name has no Jira ID
#   - pushing without an approved spec for that Jira ID
#   - pushing a commit the quality gate has not stamped
#   - force-pushing, or pushing directly to main/master/develop
set -euo pipefail

INPUT="$(cat)"

command=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)

# Only care about git push
case "$command" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

deny() {
  echo "$1" >&2
  exit 2
}

case "$command" in
  *"--force"*|*"-f "*|*" -f"*) deny "BLOCKED: force-push is not allowed in this workflow. If the remote rejected your push, explain the situation to the developer instead." ;;
esac

case "$command" in
  *" main"*|*" master"*|*" develop"*|*":main"*|*":master"*) deny "BLOCKED: pushing to a protected branch. Push only to your feature/bugfix branch with 'git push -u origin <branch>'." ;;
esac

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
[ -z "$branch" ] && exit 0

jira_id=$(printf '%s' "$branch" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -n1 || true)
if [ -z "$jira_id" ]; then
  deny "BLOCKED: branch '$branch' contains no Jira ID. Branches must be created with /start <JIRA-ID> (e.g. feature/PROJ-123-slug)."
fi

spec_file="specs/${jira_id}.md"
if [ ! -f "$spec_file" ]; then
  deny "BLOCKED: no spec found at $spec_file. Run /spec $jira_id and get it approved before pushing."
fi
if ! grep -qiE '^status:[[:space:]]*approved' "$spec_file"; then
  deny "BLOCKED: $spec_file is not approved (frontmatter 'status: approved' missing). The developer must review and approve the spec."
fi

stamp_file=".claude-workflow/quality-gate-passed"
head_sha=$(git rev-parse HEAD 2>/dev/null || true)
if [ ! -f "$stamp_file" ] || [ "$(cat "$stamp_file" 2>/dev/null | tr -d '[:space:]')" != "$head_sha" ]; then
  deny "BLOCKED: quality gate has not passed for HEAD ($head_sha). Run /quality-gate $jira_id (formatting, lint, full tests, 100% changed-line coverage) and try again."
fi

exit 0
