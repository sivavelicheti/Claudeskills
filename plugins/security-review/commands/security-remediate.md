---
description: Build a remediation plan with sample fixes for selected findings; optionally apply fixes with confirmation
argument-hint: "[SR-001,SR-004 | --severity critical+high | --standard pci | --all]"
---

# /security-remediate — remediation plan + sample fixes

Read `.security-review/findings.json`. If missing, tell the user to run
`/security-review` first and stop.

Guardrails: defensive fixes only — never produce exploit code. Never send
source code to external services. Only modify project code in Step 4, with
explicit confirmation.

## Step 1 — Selection

Show the open findings (`status: "open"`) as a table: `ID | Title | Severity |
File`. Parse `$ARGUMENTS`; if it already specifies a selection (ID list,
`--severity`, `--standard`, `--all`), use it. Otherwise ask the user
(AskUserQuestion) which to remediate:

- **All** open findings
- **By severity** — e.g. Critical + High only
- **By ID subset** — e.g. `SR-001, SR-004, SR-007`
- **By standard** — e.g. everything with a non-null `pci_dss` mapping

Resolve the selection to an exact ID list and echo it back
("Remediating: SR-002, SR-005"). If an explicitly requested ID does not
exist, say so and continue with the ones that do. Remediate exactly the
selected findings — no more, no fewer.

## Step 2 — Remediation engineering (subagent)

Launch the `remediation-engineer` subagent (one call for the whole selection;
if more than ~10 findings, batch by file or category). Pass it the selected
findings' full JSON records. For each finding it returns:

1. **Root cause** — 1–2 sentences.
2. **Remediation strategy** — referencing authoritative guidance by name
   (e.g. "OWASP SQL Injection Prevention Cheat Sheet; ASVS V5.3.4"),
   consistent with the finding's mapped identifiers.
3. **Sample fix** — a concrete before/after code diff in the project's actual
   language and framework idioms. The subagent inspects the cited file and
   neighboring code to match existing conventions (e.g. parameterized query
   via the project's existing DAO pattern), and reads at most 1 reference
   file per finding, only when it needs fix guidance.
4. **Effort estimate** — S / M / L, with a phrase of justification.
5. **Regression-test suggestions** — which existing tests to run, plus 1–2
   new test cases that would have caught the issue.

## Step 3 — Write the plan and update state

Write `REMEDIATION-PLAN.md` in the repo root:

- Header: scan_id, date, selected IDs, count by severity.
- One section per finding (ordered by CVSS descending) with the five items
  above; diffs in fenced code blocks.
- A closing summary table: `ID | Fix summary | Effort | Status`.

Then update `.security-review/findings.json`: set
`remediation_status: "planned"` for exactly the selected IDs. Leave all other
fields untouched.

## Step 4 — Optional apply (explicit confirmation required)

Ask the user whether to apply any fixes now: per fix, per batch, or none.
Never modify code without a yes for that fix/batch. For each approved fix:

1. Apply the diff with Edit, adapting to the current file state.
2. Run the project's relevant tests (detect the test command from the
   project; ask if ambiguous). Report pass/fail honestly.
3. On success, set that finding's `remediation_status: "fixed"` (keep
   `status: "open"` until a re-scan verifies). On failure, revert or fix
   forward per the user's choice, and report exactly what happened.

Finish with a summary: planned N, applied M, tests status, and suggest
re-running `/security-review` on the touched scope to verify closure.
