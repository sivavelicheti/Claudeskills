---
description: "Steps 9-11: Check GitLab pipeline, GitLab Duo review comments and Sonar issues; fix, re-gate, and push until clean"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
---

# /mr-loop — pipeline, Duo review and Sonar remediation loop

Jira ticket: **$1**

Iterate until: pipeline green, Duo comments addressed, Sonar quality gate passed.
Cap at 5 iterations — if still failing, summarise where you are stuck and hand back
to the developer.

## Each iteration

1. **Pipeline (step 9)**: via the GitLab MCP, get the MR for this branch and its
   latest pipeline. For each failed job pull the trace log, diagnose, and fix the
   root cause. Never fix a failure by deleting the failing test or editing CI config
   to skip a stage — config changes to `.gitlab-ci.yml` require developer approval.
2. **GitLab Duo / reviewer comments (step 9)**: list MR discussions. For each unresolved
   comment: if the fix is unambiguous and in scope of `specs/$1.md`, apply it; if it
   conflicts with the spec or is ambiguous, do NOT apply it — draft a polite reply
   explaining the spec constraint and show it to the developer before posting.
3. **Sonar (steps 10-11)**: via the SonarQube MCP, fetch open issues and quality-gate
   status for this branch/MR. Fix bugs, vulnerabilities and code smells in the code
   itself. Rules:
   - Never mark issues "won't fix" / "false positive" — only a human does that.
   - Security hotspots: propose the fix, but the developer reviews it before commit.
   - Duplication findings: refactor, don't suppress.
4. **Re-verify (step 11)**: after any fix, run `/quality-gate $1` (tests, formatting,
   coverage must still hold — Sonar fixes love to break tests).
5. **Push**: `git push -u origin <branch>` (backoff retries as in `/ship`), then wait
   for the new pipeline and start the next iteration.

Finish with a status table: pipeline, Duo comments (resolved/replied/needs-human),
Sonar quality gate, coverage.
