---
standard: CIS Critical Security Controls v8 (code-review-relevant safeguards)
covers: mapping from finding classes to CIS v8 safeguards for the `cis_control` field
use_when: deep scans — assigning CIS safeguards to findings; CIS rows of the compliance-gap table
---

# CIS Controls v8 — safeguard mapping for code findings

CIS Controls are enterprise safeguards; only a subset is observable in code
review. Populate `cis_control` with the safeguard ID (e.g. `16.1`); `null`
when the control isn't evidenced by this finding class.

## Most-used controls for code findings

**Control 16 — Application Software Security** (primary home for app findings)
| Safeguard | Scope | Typical findings |
|---|---|---|
| 16.1 | Establish secure application development process | pervasive issues: no validation layer, no secure defaults (also SAMM note) |
| 16.2 | Establish process to accept/address software vulnerabilities | absent SECURITY.md / no triage path (process observation) |
| 16.4 | Establish and manage secure application design standards | design flaws: missing rate limits, business-logic abuse (840/770) |
| 16.5 | Use up-to-date and trusted third-party components | vulnerable/EOL dependencies (1395/1104) |
| 16.7 | Use standard hardening configuration templates for app infra | debug on, default configs (489/1188/16) |
| 16.9 | Train developers in secure coding | recurring same-class flaws (report-level observation) |
| 16.10 | Apply secure design principles | trust-boundary errors, client-side enforcement (602) |
| 16.11 | Leverage vetted modules for auth/crypto | hand-rolled crypto/session code (327/330/384) |
| 16.12 | Implement code-level security checks (SAST) | absence of tooling (process observation) |

**Other controls with code-visible evidence**
| Safeguard | Control | Typical findings |
|---|---|---|
| 3.3 | Data Protection — configure access control lists | over-broad permissions, public buckets (732) |
| 3.10 | Encrypt sensitive data in transit | cleartext HTTP, weak TLS (319/757) |
| 3.11 | Encrypt sensitive data at rest | cleartext storage (312) |
| 4.1 | Secure configuration process (enterprise assets & software) | insecure defaults in IaC/app config (1188) |
| 4.7 | Manage default accounts | default creds active (798-default/1188) |
| 5.2 | Use unique passwords / password policy | weak password requirements (521) |
| 6.1/6.2 | Access granting/revoking process | orphaned privileged paths (269) |
| 6.3 | Require MFA for externally-exposed applications | auth flows with no MFA hook (287-adjacent) |
| 6.8 | Define and maintain role-based access control | missing authZ model (862/863/639) |
| 8.2 | Collect audit logs | missing security logging (778) |
| 8.3 | Ensure adequate audit log storage / 8.9 centralize | log handling gaps (process) |
| 12.2 | Establish secure network architecture | SSRF reach into internal segments (918 — pair with 16.x) |

Selection rule: prefer the Control-16 safeguard when the finding is an
application defect; use the other controls when the finding is about data
protection, accounts, or logging posture. Report gap table: `CIS Safeguard |
Finding IDs | Gap summary`, one row per safeguard.
