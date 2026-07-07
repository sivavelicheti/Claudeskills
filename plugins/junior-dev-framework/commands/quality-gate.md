---
description: "Steps 6+7: Verify formatting, lint, run the full suite and enforce 100% coverage on changed code; stamps the gate marker the push hook checks"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
allowed-tools: ["Bash", "Read", "Grep", "Glob", "Agent"]
---

# /quality-gate — formatting, tests and coverage gate

Jira ticket: **$1**

Run this AFTER all work is committed. The `git push` guard hook refuses to push unless
this gate passed on the exact commit being pushed.

## Steps

1. Verify the working tree is clean. If not, tell the developer to commit first — the
   gate stamps a specific commit, not a dirty tree.
2. **Formatting**: run the project formatter in check mode (from CLAUDE.md /
   `package.json` / `Makefile` — e.g. `prettier --check`, `black --check`, `gofmt -l`,
   `mvn spotless:check`). If it fails: apply formatting, commit `"$1: formatting"`,
   and continue.
3. **Lint**: run the project linter. Fix real findings; never disable rules or add
   suppression comments without telling the developer.
4. **Tests**: run the FULL suite. Any failure -> fix (respecting TDD rules from
   `/implement`) -> rerun.
5. **Coverage**: run the suite with coverage enabled and enforce the policy:
   - **100% line + branch coverage on all files changed on this branch**
     (`git diff --name-only origin/<default-branch>...HEAD`).
   - Report overall project coverage as information.
   - Coverage gaps are closed by engaging the `test-engineer` subagent with the
     uncovered lines and the requirement they belong to. If a line is genuinely
     unreachable, that is a code smell — simplify the code instead of excluding it.
     Exclusions require the developer's explicit OK, stated in the MR description.
6. **Spec re-check**: re-read `specs/$1.md`; confirm every requirement ID has at least
   one test referencing it (test name or comment mentions R-id). List any orphans.
7. **Verification discipline — invoke `superpowers:verification-before-completion`**
   before stamping: every claim in your report ("tests pass", "coverage 100%") must be
   backed by command output you actually ran in THIS gate run — never from memory of an
   earlier run, and never inferred. If superpowers is not installed, apply the same
   rule manually: no evidence, no claim.
8. **Stamp the gate** (this is what the push hook verifies):
   `mkdir -p .claude-workflow && git rev-parse HEAD > .claude-workflow/quality-gate-passed`
9. Report: formatter result, lint result, test counts, coverage per changed file,
   requirement->test map. Next step: `/ship $1`.

If ANY check cannot be run (no test runner found, no coverage tool), STOP and say so
explicitly. Never stamp the gate on a partial run.
