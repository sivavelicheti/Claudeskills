---
description: "Step 4+5: Create an implementation plan traced line-by-line to the approved spec (requires human approval)"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
---

# /plan — Implementation plan from the approved spec

Jira ticket: **$1**

## Preconditions (check, and STOP if unmet)

- `specs/$1.md` exists and its frontmatter says `status: approved`. If it is still
  `draft`, tell the developer to review and approve it first.
- Current branch name contains `$1`.

## Steps

1. Delegate to the `planner` subagent: give it the spec path and ask for an
   implementation plan using `${CLAUDE_PLUGIN_ROOT}/templates/plan-template.md`.
   The planner explores the codebase itself; do not paste large amounts of code into
   its prompt. The planner is required to follow the `superpowers:writing-plans` skill
   (bite-sized steps, exact file paths, complete code direction, no ambiguity) — the
   team template ADDS the traceability matrix on top of that discipline.
2. Write the plan to `specs/$1.plan.md` with frontmatter `status: draft`.
3. **Traceability check (the whole point of this framework):** the plan must contain a
   traceability matrix — every requirement ID from the spec (R1, R2, ...) maps to at
   least one planned test and one implementation task. Every planned task maps back to
   a requirement. If a task has no requirement, delete the task or take the gap back
   to Jira; if a requirement has no task, the plan is incomplete.
4. Order the tasks as small TDD increments (each one: failing test -> code -> green).
5. Show the developer the plan summary + traceability matrix, then STOP for approval
   (`status: approved` in `specs/$1.plan.md`, same as the spec).

Do not write any production code in this command.
