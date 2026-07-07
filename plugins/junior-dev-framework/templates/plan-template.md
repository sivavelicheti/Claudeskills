---
jira: PROJ-123
spec: specs/PROJ-123.md
status: draft   # draft -> approved (human only; approved plans are locked)
---

# PROJ-123 — Implementation plan

## Traceability matrix
<!-- EVERY requirement from the spec appears here. No orphan tasks, no orphan requirements. -->
| Req | Proven by (tests) | Implemented by (tasks) |
|---|---|---|
| R1 | test_x_does_y | T1 |
| R2 | ... | T2, T3 |

## Tasks (TDD order — each task is one red->green cycle)
- [ ] **T1** (R1): test: <failing test to write> | code: <minimal change> | files: <paths>
- [ ] **T2** (R2): ...

## Test strategy
- Levels: <unit/integration/e2e per requirement>
- Reuse: <existing fixtures/harnesses>
- Coverage: how 100% changed-line coverage will be reached

## Risks & regression guards
- <existing behaviour at risk> — guarded by <existing test / new task>
