---
name: security-standards
description: Routing index for curated security-standards reference files (OWASP, CWE, CVSS, CAPEC, SANS 25, ASVS, MASVS, NIST 800-53, MITRE ATT&CK, CIS, PCI DSS, SAMM). Use when mapping security findings to standards or looking up fix guidance; route by finding category and load only the named file(s).
---

# security-standards — routing index

## Routing table: finding category → reference file(s)

| Finding category | Reference file(s) |
|---|---|
| injection-* (sql/cmd/ldap/template/other), xss, deserialization, ssrf, path-traversal | `references/cwe-injection.md` |
| auth, authz, secrets (access-control side), file-upload, input-validation | `references/cwe-authz.md` |
| crypto, secrets (storage side) | `references/cwe-crypto.md` |
| misconfig, logging, vulnerable-dependency, other | `references/cwe-design.md` |
| Any finding needing a CVSS vector/score | `references/cvss-scoring.md` |
| OWASP Top 10 category assignment | `references/owasp-top10.md` |
| SANS/CWE Top 25 rank | `references/sans-top25.md` |
| Attack-pattern (CAPEC) or ATT&CK technique ID | `references/capec-patterns.md`, `references/mitre-attack-map.md` |
| ASVS verification item (web/API) | `references/asvs-checklist.md` |
| MASVS item — MOBILE app type ONLY | `references/masvs-checklist.md` |
| NIST 800-53 control family | `references/nist-800-53-map.md` |
| CIS Controls v8 safeguard | `references/cis-controls.md` |
| PCI DSS v4 requirement | `references/pci-dss-map.md` |
| Process/maturity observations (reports) | `references/samm-notes.md` |

One-line file summaries: `owasp-top10.md` A01–A10 2021 categories + detection cues; `cwe-injection.md` CWEs for injection/XSS/SSRF/deserialization/traversal; `cwe-authz.md` CWEs for authN/authZ/session/validation/upload; `cwe-crypto.md` CWEs for crypto/secrets/randomness; `cwe-design.md` CWEs for misconfig/logging/dependencies/design; `cvss-scoring.md` CVSS v3.1 metric rubric + score arithmetic + v4 deltas; `capec-patterns.md` common CAPEC attack patterns keyed by CWE; `mitre-attack-map.md` ATT&CK techniques relevant to app weaknesses; `sans25.md → sans-top25.md` 2023 Top 25 ranks by CWE; `asvs-checklist.md` ASVS v4 L1/L2 items by chapter; `masvs-checklist.md` MASVS v2 controls (mobile only); `nist-800-53-map.md` control families ↔ weakness classes; `cis-controls.md` CIS v8 safeguards ↔ findings; `pci-dss-map.md` PCI DSS v4 reqs 3/4/6/8/10 ↔ findings; `samm-notes.md` SAMM practices for process observations.

## Instructions

Load ONLY the reference file(s) the routing table names for the current
finding category. Maximum 2 open at once. Never read the entire
`references/` directory. If unsure which file applies, use this table — do
not open files to check. Prefer grepping a file for the specific identifier
you need and reading the surrounding section over loading the whole file.
Every reference file begins with 3 YAML lines (`standard:`, `covers:`,
`use_when:`) that confirm relevance from the head of the file alone.
