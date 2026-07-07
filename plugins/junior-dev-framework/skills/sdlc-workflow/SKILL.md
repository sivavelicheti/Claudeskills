---
name: sdlc-workflow
description: The team's mandatory Jira->spec->plan->TDD->MR workflow. Use whenever the developer asks to start a ticket, write code, fix a bug, push, create an MR, or asks "what's next" — this skill says which stage they are in and which command to run.
---

# Team SDLC workflow (mandatory)

All feature/bug work follows this pipeline. Each stage has a slash command; the stages
are enforced by hooks, so skipping them fails at push time anyway. When the developer
asks for work that belongs to a later stage, route them to the current stage first.

| Stage | Command | Gate to pass |
|---|---|---|
| 1. Spec from Jira | `/spec PROJ-123` | human sets `status: approved` in `specs/PROJ-123.md` |
| 2. Branch | `/start PROJ-123` | branch name contains the Jira ID |
| 3. Plan | `/plan PROJ-123` | human approves `specs/PROJ-123.plan.md`; traceability matrix complete |
| 4. Implement (TDD) | `/implement PROJ-123` | every task red->green->commit, via subagents |
| 5. Quality gate | `/quality-gate PROJ-123` | format + lint + full suite + 100% changed-line coverage; stamps `.claude-workflow/quality-gate-passed` |
| 6. Push + MR | `/ship PROJ-123` | push hook verifies spec approved + gate stamp == HEAD |
| 7. MR loop | `/mr-loop PROJ-123` | pipeline green, Duo comments addressed, Sonar gate passed |
| 8. Review (reviewer runs) | `/review PROJ-123` | requirement-by-requirement evidence report |

## How to find the current stage

- No `specs/<ID>.md`? -> stage 1.
- Spec `draft`? -> waiting for human approval, do not proceed.
- No plan / plan `draft`? -> stage 3.
- Unticked tasks in the plan? -> stage 4.
- Gate stamp missing or != HEAD? -> stage 5.
- Not pushed / no MR? -> stage 6. Otherwise -> stage 7.

## Non-negotiables (apply at every stage)

- The approved spec is the contract. Code that isn't traceable to a requirement does
  not get written; requirements that aren't covered by a test are not done.
- Never weaken/skip/delete a test, suppress a lint or Sonar rule, or touch
  `.gitlab-ci.yml` to get past a gate.
- Humans approve: specs, plans, spec changes, dependency additions, coverage
  exclusions, Sonar won't-fix, MR merge.
- Work happens on `feature/<JIRA-ID>-*` or `bugfix/<JIRA-ID>-*` only.
