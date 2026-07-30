---
standard: OWASP SAMM v2 (selected practices for process observations)
covers: mapping recurring finding patterns to SAMM practice/maturity gaps for the report's SAMM note
use_when: writing the 2-3 process-level observations in /security-report — never for per-finding fields
---

# SAMM v2 — process observations from finding patterns

SAMM measures *process maturity*, not code. Use this file only to write the
report's short "SAMM note": pick the 2–3 strongest patterns across all
findings and phrase each as `observed pattern → SAMM practice gap`. Never
attach SAMM to individual findings.

## Business functions & practices (orientation)

- **Governance**: Strategy & Metrics, Policy & Compliance, Education & Guidance
- **Design**: Threat Assessment, Security Requirements, Security Architecture
- **Implementation**: Secure Build, Secure Deployment, Defect Management
- **Verification**: Architecture Assessment, Requirements-driven Testing, Security Testing
- **Operations**: Incident Management, Environment Management, Operational Management

## Pattern → practice gap

| Observed pattern in findings | SAMM practice gap (phrase for report) |
|---|---|
| Repeated missing input validation across modules; no shared validation library | Design / Security Requirements — validation requirements not defined or standardized (maturity ≤ 1) |
| Ad-hoc, hand-rolled auth/session/crypto code instead of vetted frameworks | Design / Security Architecture — no reference architecture or approved-component list |
| Injection/XSS in many endpoints of the same shape | Governance / Education & Guidance — secure-coding guidance not reaching developers |
| Hardcoded secrets in source and config | Implementation / Secure Deployment — no secrets-management process in the deployment pipeline |
| Dependencies far behind with known CVEs; no lockfile hygiene | Implementation / Defect Management + Secure Build — no dependency-update or vulnerability-triage cadence |
| Debug modes, default accounts, sample configs reachable | Operations / Environment Management — hardening baseline absent or unenforced |
| No security logging around auth/authz decisions | Operations / Incident Management — insufficient telemetry to detect or investigate abuse |
| No tests asserting security behavior (authz, validation) | Verification / Requirements-driven Testing — security requirements not expressed as tests |
| Same CWE reappearing after prior fixes elsewhere | Implementation / Defect Management — findings fixed point-wise, root causes not fed back |
| No threat model artifacts; trust boundaries unclear in design | Design / Threat Assessment — threat modeling not practiced |

## Writing rules

- 2–3 observations maximum; each one sentence of evidence + one practice gap.
- Only claim what the findings evidence. Code review cannot see tickets,
  training, or pipelines — say "suggests", not "the organization lacks".
- Example: "11 of 14 findings involve unvalidated request input and no
  shared validation utility exists → suggests a Design/Security Requirements
  maturity gap (SAMM ≤ 1): input-validation requirements are not defined
  centrally."
