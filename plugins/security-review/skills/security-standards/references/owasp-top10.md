---
standard: OWASP Top 10 (2021)
covers: A01-A10 risk categories, detection cues, cross-references to CWE/ASVS/CAPEC
use_when: assigning the `owasp` field to a finding, or grouping report sections by OWASP category
---

# OWASP Top 10 — 2021

**A01:2021 Broken Access Control.** Users can act outside their intended
permissions: IDOR, missing function-level checks, privilege escalation, CORS
misconfig, force-browsing, JWT/cookie tampering, mass assignment.
Detect: object IDs from requests used without ownership checks; mutating or
admin endpoints without role checks; `Access-Control-Allow-Origin: *` with
credentials. Cross-refs: CWE-284/285/639/862/863/352; ASVS V4; CAPEC-122.

**A02:2021 Cryptographic Failures.** Sensitive data exposed via weak or
absent crypto: cleartext transmission/storage, MD5/SHA1, DES/RC4, ECB, static
IVs/keys, weak randomness for tokens, disabled cert validation.
Detect: crypto API calls naming weak algorithms; `verify=False`/
`TrustAllCerts`; passwords hashed without bcrypt/scrypt/argon2/PBKDF2.
Cross-refs: CWE-256/261/310/319/321/326/327/328/330/916; ASVS V6/V9; CAPEC-97.

**A03:2021 Injection.** Untrusted data interpreted as code/commands: SQL,
NoSQL, OS command, LDAP, expression language, template injection — and XSS
(folded into A03 in 2021). Detect: string concatenation/interpolation into
queries, shells, filters, templates; unescaped output of user data.
Cross-refs: CWE-79/89/77/78/90/94/1336; ASVS V5; CAPEC-66/88/136.

**A04:2021 Insecure Design.** Missing or ineffective control design (not
implementation bugs): no rate limiting on sensitive flows, trust-boundary
errors, missing threat modeling artifacts, business-logic abuse paths.
Detect: security-relevant flows (recovery, checkout, invites) with no abuse
controls; unlimited resource consumption. Cross-refs: CWE-209/256/501/522/840;
ASVS V1; CAPEC-25.

**A05:2021 Security Misconfiguration.** Insecure defaults, verbose errors,
debug enabled, unnecessary features, missing hardening/headers, XXE (folded
in). Detect: `DEBUG=True`, stack traces to clients, directory listing,
default creds, permissive CSP/missing headers, XML parsers with external
entities enabled, permissive cloud/IaC settings. Cross-refs:
CWE-16/611/1004/1032; ASVS V14; CAPEC-176.

**A06:2021 Vulnerable and Outdated Components.** Dependencies/platforms with
known CVEs or out of support; unmonitored versions. Detect: manifest/lockfile
versions with known advisories (cross-check OSV/NVD); EOL runtimes; vendored
copies of old libraries. Cross-refs: CWE-1104/937/1035; ASVS V1.10/V14.2.

**A07:2021 Identification and Authentication Failures.** Weak login/session
handling: credential stuffing not resisted, weak/default passwords permitted,
missing MFA hooks, session IDs in URLs, no rotation/expiry, JWT signature
not verified. Detect: login endpoints without lockout/throttling; permissive
password policy; session fixation; `alg:none`. Cross-refs:
CWE-287/297/384/521/613/620/798; ASVS V2/V3; CAPEC-49/560.

**A08:2021 Software and Data Integrity Failures.** Trusting
integrity-unverified code/data: insecure deserialization, unsigned updates,
CI/CD pulling unpinned artifacts. Detect: native deserialization of external
input (pickle, ObjectInputStream, unserialize, unsafe YAML); unpinned
plugin/dependency fetching in pipelines. Cross-refs: CWE-345/353/426/494/502/
829/915; ASVS V1.14/V10; CAPEC-586.

**A09:2021 Security Logging and Monitoring Failures.** Auditable events not
logged, logs not protected/monitored, sensitive data in logs. Detect: auth
failures/privilege changes without log statements; passwords/tokens/PII
logged; log output built from raw user input (log injection). Cross-refs:
CWE-117/223/532/778; ASVS V7; CAPEC-93.

**A10:2021 Server-Side Request Forgery.** Server fetches URLs derived from
user input without allowlisting, reaching internal services/metadata
endpoints. Detect: HTTP client calls whose target host/path comes from
request data; webhook/preview/import features without URL validation.
Cross-refs: CWE-918; ASVS V5.2.6/V12.6; CAPEC-664.

Category selection rule: pick the category matching the *weakness*, not the
impact (e.g. SQL injection → A03 even if it dumps credentials). If two apply,
prefer the more specific (SSRF → A10, not A05).
