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
   latest pipeline. For each failed job pull the trace log, then **invoke
   `superpowers:systematic-debugging`** and follow it: reproduce locally, form a
   hypothesis, trace to root cause — no shotgun fixes, no "try this and re-push" churn.
   Never fix a failure by deleting the failing test or editing CI config to skip a
   stage — changes to `.gitlab-ci.yml` require developer approval.
2. **GitLab Duo / reviewer comments (step 9)**: list MR discussions, then **invoke
   `superpowers:receiving-code-review`** and process each unresolved comment with it:
   verify the reviewer's claim against the code before acting — comments are input, not
   orders; Duo is a bot and is sometimes wrong. If the fix is verified, unambiguous and
   in scope of `specs/$1.md`, apply it; if it conflicts with the spec, is ambiguous, or
   the claim doesn't check out, do NOT apply it — draft a polite reply with evidence
   and show it to the developer before posting.
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
