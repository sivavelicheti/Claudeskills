---
standard: CWE (curated subset) — misconfiguration, logging, dependencies, design
covers: CWE IDs for findings in categories misconfig, logging, vulnerable-dependency, other
use_when: assigning the `cwe` field for configuration, operational, and design findings
---

# CWE — misconfiguration, logging, dependency & design weaknesses (curated)

## Misconfiguration & information exposure

**CWE-16 Configuration (category)** — generic config weakness; prefer a
specific child below.

**CWE-489 Active Debug Code** — debug mode/endpoints enabled in production
paths. *Detect:* `DEBUG=True`, Werkzeug debugger, Spring devtools/actuator
open, source maps + verbose errors in prod builds. *X-refs:* A05, ASVS
V14.3.2.

**CWE-209 Error Message with Sensitive Information** — stack traces, SQL
errors, paths returned to clients. *Detect:* exception handlers echoing
`e.getMessage()`/tracebacks into responses; default error pages. *X-refs:*
A05/A04, ASVS V14.3, NIST SI-11, CAPEC-215.

**CWE-200 Exposure of Sensitive Information (parent)** — data exposed to
unauthorized actors; use when no child (209/532/548) fits. *X-refs:* A01,
SANS #12 region.

**CWE-548 Directory Listing** — web server lists directory contents.
*X-refs:* A05.

**CWE-693 Protection Mechanism Failure (parent)** — missing security
headers/CSP/frame protection when no narrower ID fits (CWE-1021 for missing
clickjacking defense). *Detect:* absent CSP/X-Frame-Options/HSTS
configuration in server/middleware setup. *X-refs:* A05, ASVS V14.4.

**CWE-1188 Insecure Default Initialization** — shipped defaults insecure:
default accounts/passwords active, sample apps deployed, permissive IaC
defaults (0.0.0.0/0 ingress, public buckets, `privileged: true`,
`runAsRoot`). *Detect:* IaC resources with public access or wildcard
security groups; default admin creds in seed data. *X-refs:* A05, CIS 4.x,
NIST CM-6, ATT&CK T1078.001.

**CWE-732 Incorrect Permission Assignment for Critical Resource** —
world-writable files, chmod 777, over-broad IAM policies (`Action: *`).
*Detect:* permission literals in code/IaC; `iam:*` on `Resource: *`.
*X-refs:* A01/A05, SANS #25 region, NIST AC-6, CIS 3.3.

## Logging & monitoring

**CWE-778 Insufficient Logging** — security events (authN failures, authZ
denials, privilege changes) not logged. *Detect:* auth/authz code paths with
no audit call. *X-refs:* A09, ASVS V7.1/V7.2, NIST AU-2, PCI 10.2, CIS 8.x.

**CWE-532 Sensitive Information in Logs** — see cwe-crypto.md entry; route
here when the finding is logging-centric. *X-refs:* A09, PCI 10.x.

**CWE-117 Log Injection** — see cwe-injection.md; logging-side alias.

## Dependencies & integrity

**CWE-1104 Use of Unmaintained Third-Party Components** — EOL/abandoned
libraries or runtimes. *Detect:* manifests pinning archived/EOL versions.
*X-refs:* A06, CIS 2.2, NIST SA-22.

**CWE-1395 Dependency on Vulnerable Third-Party Component** — dependency
version with known CVEs (attach `cve_refs`). *Detect:* OSV/NVD hits for
pinned versions. *X-refs:* A06, PCI 6.3.3, CIS 7.x, ATT&CK T1195.

**CWE-494 Download of Code Without Integrity Check** — fetching
scripts/artifacts at runtime or build without hash/signature verification.
*Detect:* `curl | sh`, CDN scripts without SRI, unpinned CI actions/images.
*X-refs:* A08, CAPEC-185, NIST SI-7.

**CWE-829 Inclusion of Functionality from Untrusted Sphere** — loading
code/config from user-influenced locations (remote includes, dynamic
require paths). *X-refs:* A08, SANS-adjacent.

**CWE-426 Untrusted Search Path** — resolving executables/libraries from
attacker-influenceable paths (PATH, DLL search order, relative imports).
*X-refs:* A08, CAPEC-471.

## Design & logic

**CWE-840 Business Logic Errors (category)** — abuse-able flows (negative
quantities, replayable coupons, race on balance checks). *Detect:*
state-changing flows lacking invariant checks server-side. *X-refs:* A04,
ASVS V11, CAPEC-25.

**CWE-367 TOCTOU Race Condition** — check and use of a resource are not
atomic (file checks, balance checks, double-spend). *Detect:*
check-then-act on shared state without locking/transaction. *X-refs:* A04,
SANS #22 region, CAPEC-27.

**CWE-799 / CWE-307 Missing Rate Limiting** — no throttle on expensive or
sensitive operations (307 for auth attempts — see cwe-authz.md; 799 for
general interaction frequency). *X-refs:* A04, ASVS V11.1.4, NIST SC-5.

**CWE-451 UI Misrepresentation / CWE-1021 Improper Restriction of Rendered
UI Layers** — clickjacking-enabling absence of frame controls. *Detect:* no
X-Frame-Options/frame-ancestors on sensitive pages. *X-refs:* A05, CAPEC-103.

Selection notes: IaC exposure findings → prefer CWE-1188 or CWE-732 over
generic CWE-16. Dependency findings with concrete CVEs → CWE-1395; merely
outdated/EOL → CWE-1104.
