---
jira: PROJ-123
title: <ticket summary>
status: draft   # draft -> approved (set by a human only; approved specs are locked)
author: <developer>
date: <YYYY-MM-DD>
---

# PROJ-123 — <title>

## Context
<2-4 sentences: why this work exists, from the ticket. Link the Jira ticket.>

## Functional requirements
<!-- Every requirement: stable ID, testable, with concrete values from the ticket -->
- **R1**: <observable behaviour — given/when/then, exact inputs/outputs>
- **R2**: ...

## Error handling & edge cases
- **R10**: <what happens on invalid input / timeout / empty state — from the ticket or agreed with the team>

## Non-functional requirements
- **N1**: <performance/security/compat constraints, with numbers>

## Out of scope
<!-- Everything the ticket does NOT ask for. Prevents scope creep. -->
- ...

## Open questions
<!-- Ambiguities to resolve with the human BEFORE approval. Must be empty when approved. -->
- [ ] ...

## Acceptance checklist
- [ ] Every R* has at least one test referencing its ID
- [ ] Demo path: <how a human verifies this works end-to-end>
