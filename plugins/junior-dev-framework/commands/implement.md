---
description: "Step 5: Implement the approved plan with strict TDD, using subagents so the main context stays small"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
---

# /implement — TDD implementation of the approved plan

Jira ticket: **$1**

## Preconditions (check, and STOP if unmet)

- `specs/$1.md` and `specs/$1.plan.md` both exist with `status: approved`.
- Current branch contains `$1`. Working tree is clean or contains only work for `$1`.

## Execution model — keep the orchestrator context lean

You (the main conversation) are the **orchestrator**. You do not write tests or
production code yourself. For each task in the plan, in order:

1. Spawn the `test-engineer` subagent with ONLY: the task description, the requirement
   IDs it covers, and the relevant spec excerpt. It writes failing tests and reports
   the test file paths and the failure output.
2. Run the tests yourself to confirm they FAIL for the right reason. A test that passes
   before implementation is invalid — send it back.
3. Spawn the `tdd-implementer` subagent with ONLY: the failing test paths, the task
   description, and file locations from the plan. It makes the tests pass with the
   minimal change. It is forbidden from editing test files — if it claims a test is
   wrong, it must stop and report; you decide (and re-engage `test-engineer` if the
   test truly is wrong).
4. Run the FULL test suite. Green -> commit with message `$1: <task summary>` -> tick
   the task checkbox in `specs/$1.plan.md` -> next task.
5. Every ~3 tasks, note progress in one short paragraph to the developer.

## Hard rules

- Never pass whole files between agents through your own context — pass paths.
- Never weaken, skip, or delete a test to get to green.
- If the plan turns out to be wrong mid-implementation, STOP, explain the mismatch,
  and tell the developer to re-run `/plan $1` — do not silently deviate from the spec.
- No drive-by refactors of code the plan does not touch.
