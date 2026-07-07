---
description: "Step 12: For the MR reviewer — verify the implementation is correct and complete against the Jira ticket / approved spec"
argument-hint: "<JIRA-ID or MR URL>"
---

# /review — spec-compliance review for the MR reviewer

Target: **$1**

You are assisting the human REVIEWER, not the author. Your job is evidence, not
approval — the human makes the merge decision.

1. Locate the MR (GitLab MCP) and the spec `specs/<JIRA-ID>.md` on the source branch.
   Fetch the Jira ticket too and diff spec-vs-ticket: flag anything the spec quietly
   dropped or added relative to Jira.
2. **Invoke `superpowers:requesting-code-review`** for the general code-quality pass
   (its reviewer subagent checks correctness, robustness and maintainability of the
   diff on its own terms), and in parallel delegate the spec-compliance pass to the
   `spec-compliance-reviewer` subagent with: the MR diff, the spec path, and the plan
   path. If superpowers ships `dispatching-parallel-agents`, use it to fan the
   requirement verification out — one verifier per group of requirements on large MRs.
   The compliance pass returns a verdict per requirement ID:
   **implemented / partially implemented / missing / contradicts spec**, each with
   file:line evidence and the covering test.
3. Independently check for **scope creep**: changes in the diff that map to no
   requirement. List them — they either need a new Jira ticket or removal.
4. Check the tests prove the requirements (not just execute the code): would each test
   fail if the requirement were broken? Sample the 3 riskiest requirements and reason
   through mutation-style.
5. Verify the hygiene gates from the MR itself: pipeline status, coverage report,
   Sonar quality gate, unresolved discussions.
6. Produce the review report:
   - Requirement-by-requirement verdict table with evidence
   - Scope creep list
   - Test adequacy concerns
   - Suggested MR comments (draft only — post via GitLab MCP ONLY if the reviewer
     explicitly says to)

Never click approve/merge yourself under any circumstances.
