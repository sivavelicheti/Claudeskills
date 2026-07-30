---
standard: NIST SP 800-53 Rev.5 (control-family mapping only)
covers: mapping from weakness classes/CWEs to 800-53 controls for the `nist_800_53` field and compliance-gap tables
use_when: deep scans — assigning NIST controls to findings; building the compliance-gap section of reports
---

# NIST 800-53 Rev.5 — control mapping for code findings

This is a *mapping table*, not control text. Populate `nist_800_53` with the
control ID whose objective the finding violates; `null` when no control
clearly applies. One control per finding (the dominant one).

## Family orientation (what lives where)

AC Access Control · AU Audit & Accountability · CM Configuration Management ·
IA Identification & Authentication · RA Risk Assessment · SA Services
Acquisition (supply chain w/ SR) · SC System & Communications Protection ·
SI System & Information Integrity.

## Weakness class → control

| Finding class (typical CWEs) | Control | Objective violated |
|---|---|---|
| Injection, XSS, missing input validation (89/78/79/20) | **SI-10** | Information input validation |
| Error messages leaking internals (209) | **SI-11** | Error handling |
| Missing authN on endpoints (306/287) | **IA-2** | User identification & authentication |
| Weak/hardcoded credentials (798/521) | **IA-5** | Authenticator management |
| Missing/incorrect authZ, IDOR (862/863/639) | **AC-3** | Access enforcement |
| Privilege escalation, over-broad permissions (269/732) | **AC-6** | Least privilege |
| CORS/trust-boundary misconfig (942) | **AC-4** | Information flow enforcement |
| Session fixation/expiry (384/613) | **AC-12** / IA-11 | Session termination / re-auth |
| Cleartext transmission, weak TLS (319/757/295) | **SC-8** | Transmission confidentiality & integrity |
| Weak crypto algorithms/keys (327/326/916) | **SC-13** | Cryptographic protection |
| Key management in source (321/798-keys) | **SC-12** | Key establishment & management |
| Cleartext storage of sensitive data (312) | **SC-28** | Protection of information at rest |
| Missing rate limits / resource exhaustion (770/799) | **SC-5** | Denial-of-service protection |
| Missing security logging (778) | **AU-2** / AU-3 | Event logging / content of records |
| Sensitive data in logs, log tampering (532/117) | **AU-9** | Protection of audit information |
| Insecure defaults, debug on, missing hardening (489/1188/16) | **CM-6** | Configuration settings |
| Unnecessary features/services enabled (561/1188) | **CM-7** | Least functionality |
| Vulnerable/outdated dependencies (1395/1104) | **SI-2** / RA-5 | Flaw remediation / vuln monitoring |
| Unverified updates/supply chain (494/829) | **SI-7** / SR-11 | Software integrity / component authenticity |
| Deserialization/XXE (502/611) | **SI-10** (input) | Input validation family |
| SSRF (918) | **SC-7** | Boundary protection |
| CSRF (352) | **SC-23** | Session authenticity |

## Compliance-gap table guidance

In reports, aggregate open findings per control: `Control | Family | Finding
IDs | Gap summary`. A control appears once regardless of finding count. Do
not claim "compliance" or "non-compliance" with 800-53 overall — the table
states which control objectives have code-level evidence of gaps, scoped to
the reviewed code.
