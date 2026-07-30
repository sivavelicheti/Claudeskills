---
standard: CVSS v3.1 (with v4.0 deltas)
covers: base-metric rubric, numeric weights, score formula, severity bands
use_when: computing the `cvss` field (vector, score, severity) for any finding — never guess scores
---

# CVSS v3.1 scoring rubric

Vector format: `CVSS:3.1/AV:_/AC:_/PR:_/UI:_/S:_/C:_/I:_/A:_`

## Metric rubric (choose from the finding's evidence)

**AV — Attack Vector**: `N` Network (reachable via network request — most
web/API findings) | `A` Adjacent (same LAN/segment only) | `L` Local
(requires local account/shell or user-opened file) | `P` Physical.

**AC — Attack Complexity**: `L` Low (no special conditions — default for
straightforward injection/authz flaws) | `H` High (needs race win, MITM
position, non-default config, or target-specific secrets gathering).

**PR — Privileges Required**: `N` None (unauthenticated endpoint) | `L` Low
(any normal authenticated user) | `H` High (admin-level account needed to
reach the flaw).

**UI — User Interaction**: `N` None | `R` Required (victim must click/visit/
open — reflected & stored XSS = R, CSRF = R).

**S — Scope**: `U` Unchanged (impact confined to the vulnerable component's
authority) | `C` Changed (crosses authority: XSS executing in victim
browser, SSRF reaching other internal services, container escape).

**C / I / A — Confidentiality, Integrity, Availability impact**: each
`H` High (total or serious loss: all rows readable, arbitrary write, service
down) | `L` Low (limited disclosure/modification, degraded performance) |
`N` None.

Typical anchors: SQLi on unauth endpoint = AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
→ 9.8. Stored XSS = AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N → 5.4 (PR:N → 6.1).
Hardcoded secret in private repo = AV:L or N per exposure, usually C:H only.
IDOR reading other users' records = AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N → 6.5.

## Numeric weights

| Metric | Value → weight |
|---|---|
| AV | N 0.85, A 0.62, L 0.55, P 0.2 |
| AC | L 0.77, H 0.44 |
| PR (S:U) | N 0.85, L 0.62, H 0.27 |
| PR (S:C) | N 0.85, L 0.68, H 0.50 |
| UI | N 0.85, R 0.62 |
| C/I/A | H 0.56, L 0.22, N 0 |

## Base score formula (v3.1)

```
ISS  = 1 − (1−C)(1−I)(1−A)
Impact:
  S:U → 6.42 × ISS
  S:C → 7.52 × (ISS − 0.029) − 3.25 × (ISS − 0.02)^15
Exploitability = 8.22 × AV × AC × PR × UI
If Impact ≤ 0 → score = 0. Else:
  S:U → score = Roundup(min(Impact + Exploitability, 10))
  S:C → score = Roundup(min(1.08 × (Impact + Exploitability), 10))
Roundup = smallest number, to 1 decimal, ≥ the value.
```

Show your work: record the chosen metric values, then the computed score to
one decimal. Do not eyeball the number.

## Severity bands

| Score | Severity |
|---|---|
| 9.0–10.0 | Critical |
| 7.0–8.9 | High |
| 4.0–6.9 | Medium |
| 0.1–3.9 | Low |
| 0.0 | None |

## Worked example

Command injection in an admin-only endpoint: AV:N (HTTP), AC:L, PR:H (admin
auth needed), UI:N, S:U, C:H/I:H/A:H.
ISS = 1−(0.44×0.44×0.44) ≈ 0.9148; Impact = 6.42×0.9148 ≈ 5.873;
Exploitability = 8.22×0.85×0.77×0.27×0.85 ≈ 1.235; sum ≈ 7.108 → **7.2 High**.
Vector: `CVSS:3.1/AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:H`.

## CVSS v4.0 deltas (only if v4 output is explicitly requested)

v4 prefix `CVSS:4.0`; drops Scope, splits impact into Vulnerable System
(VC/VI/VA) and Subsequent System (SC/SI/SA); adds AT (Attack Requirements:
N/P) after AC; UI becomes N/P/A. v4 scoring uses macro-vector lookup, not a
closed formula — if v4 is requested, emit the v4 vector with metrics chosen
by this rubric's logic (former S:C → rate SC/SI/SA) but compute the numeric
score with the v3.1 formula above and label it "v3.1-equivalent score".
Default output for this plugin is v3.1.
