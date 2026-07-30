---
standard: CWE (curated subset) — authentication, authorization, session, validation, upload
covers: CWE IDs for findings in categories auth, authz, input-validation, file-upload, csrf
use_when: assigning the `cwe` field for access-control and identity findings; pick the most specific ID
---

# CWE — authN / authZ / session weaknesses (curated)

## Authentication

**CWE-287 Improper Authentication (parent)** — actor identity not correctly
proven; use when no child fits. *Detect:* endpoints trusting client-supplied
identity headers; auth bypass via alternate path. *X-refs:* A07, SANS #13,
ASVS V2.

**CWE-306 Missing Authentication for Critical Function** — sensitive
endpoint reachable with no auth at all. *Detect:* admin/mutating routes
absent from auth middleware; actuator/debug endpoints exposed. *X-refs:*
A07, SANS #20, CAPEC-115, NIST IA-2.

**CWE-798 Hardcoded Credentials** — passwords/keys embedded in code or
config in repo. *Detect:* literals assigned to password/secret/apiKey vars;
connection strings with passwords; committed .env. *X-refs:* A07, SANS #18,
CAPEC-191, ASVS V2.10, PCI 8.6.

**CWE-521 Weak Password Requirements** — policy permits trivial passwords.
*Detect:* length < 8 or no policy at registration. *X-refs:* A07, ASVS V2.1.

**CWE-307 Improper Restriction of Authentication Attempts** — no
lockout/throttle on login, OTP, recovery. *Detect:* login handlers without
rate limiting/captcha/lockout counters. *X-refs:* A07, CAPEC-49, ASVS V2.2.1.

**CWE-640 Weak Password Recovery** — recovery flow weaker than login
(guessable questions, predictable tokens, no expiry). *X-refs:* A07, ASVS V2.5.

**CWE-347 Improper Verification of Cryptographic Signature** — JWT/SAML
signature unverified or `alg:none` accepted. *Detect:* `decode(...,
verify=False)`, algorithm list including none/HS-RS confusion. *X-refs:*
A02/A07, ASVS V3.5.3.

**CWE-295 Improper Certificate Validation** — TLS cert/hostname checks
disabled. *Detect:* `verify=False`, TrustAllCerts, `NODE_TLS_REJECT_UNAUTHORIZED=0`.
*X-refs:* A02/A07, SANS #24, ASVS V9.2.

## Session

**CWE-384 Session Fixation** — session ID not rotated at login. *Detect:* no
regenerate/invalidate call in login flow. *X-refs:* A07, CAPEC-593, ASVS V3.2.1.

**CWE-613 Insufficient Session Expiration** — no absolute/idle timeout, no
server-side invalidation on logout. *X-refs:* A07, ASVS V3.3.

**CWE-1004 Sensitive Cookie Without HttpOnly / CWE-614 Without Secure** —
session cookies missing flags. *Detect:* cookie set calls lacking
httpOnly/secure/SameSite. *X-refs:* A05, ASVS V3.4.

**CWE-352 CSRF** — state-changing request accepted without origin proof.
*Detect:* CSRF protection disabled/exempted on mutating routes; token absent
with cookie-based sessions. *X-refs:* A01, SANS #9, CAPEC-62, ASVS V4.2.2.

## Authorization

**CWE-862 Missing Authorization** — no permission check at all on an
operation. *Detect:* handler does auth (who) but never checks role/ownership
(may). *X-refs:* A01, SANS #11, ASVS V4.1, NIST AC-3.

**CWE-863 Incorrect Authorization** — check exists but is wrong (client-side
role, wrong comparison, TOCTOU). *X-refs:* A01, SANS #17.

**CWE-639 IDOR / Authorization Bypass Through User-Controlled Key** — object
key from request used without ownership check. *Detect:* `findById(req.id)`
then act, no owner/tenant comparison. *X-refs:* A01, CAPEC-122, ASVS V4.2.1.

**CWE-285 Improper Authorization (parent)** — generic; prefer 862/863/639.

**CWE-269 Improper Privilege Management** — privilege escalation via
grant/drop logic errors. *Detect:* role assignment from request data (mass
assignment of `isAdmin`); missing drop after privileged step. *X-refs:* A01,
SANS #16, NIST AC-6.

**CWE-915 Mass Assignment** — request body bound wholesale to model incl.
protected fields. *Detect:* `Object.assign(user, req.body)`, unfiltered
binder without allowlist. *X-refs:* A08/A01, ASVS V5.1.2.

**CWE-425 Forced Browsing / Direct Request** — protected pages served when
requested directly. *X-refs:* A01, CAPEC-87.

**CWE-942 Permissive CORS** — cross-origin policy allows untrusted origins
with credentials. *Detect:* `Access-Control-Allow-Origin` reflected or `*`
plus allow-credentials. *X-refs:* A05/A01, ASVS V14.5.3.

## Validation & upload

**CWE-20 Improper Input Validation (parent)** — inputs consumed without
type/length/range/allowlist checks. Use for pure missing-validation findings.
*X-refs:* A03, SANS #6, ASVS V5.1, NIST SI-10.

**CWE-434 Unrestricted Dangerous File Upload** — see also cwe-injection.md;
uploads without server-side type/size/name validation or stored under web
root. *X-refs:* A04, SANS #10, ASVS V12.2, CAPEC-1.

**CWE-770 Allocation Without Limits** — no size/rate caps on
uploads/requests enabling DoS. *X-refs:* A04, ASVS V12.1.1, NIST SC-5.
