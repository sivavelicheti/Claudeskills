---
standard: OWASP ASVS v4.0.3 (curated L1/L2 items)
covers: verification items by chapter for web/API findings, keyed to CWE
use_when: populating the `asvs` field (deep scans, web/API app types) or grouping report sections by ASVS chapter
---

# ASVS v4.0.3 — curated L1/L2 verification items

Populate `asvs` with the most specific item ID whose requirement the finding
violates; `null` if none fits. Chapter prefix (V1–V14) drives report grouping.

## V2 Authentication
- **V2.1.1** (L1) Passwords ≥ 12 chars permitted/required — weak policy → CWE-521.
- **V2.2.1** (L1) Anti-automation on auth: throttling/lockout — CWE-307.
- **V2.4.1** (L2) Passwords stored via approved KDF (bcrypt/argon2/PBKDF2) — CWE-916.
- **V2.5.2** (L1) Recovery does not reveal current password / use hints — CWE-640.
- **V2.10.4** (L2) No hardcoded service credentials; use a secrets vault — CWE-798.

## V3 Session Management
- **V3.2.1** (L1) New session token generated on login — CWE-384.
- **V3.3.1** (L1) Logout invalidates session server-side — CWE-613.
- **V3.4.1/V3.4.2** (L1) Cookies Secure + HttpOnly — CWE-614/1004.
- **V3.5.3** (L2) Stateless tokens use verified signatures; reject `alg:none` — CWE-347.

## V4 Access Control
- **V4.1.1** (L1) Access control enforced on a trusted layer (server) — CWE-602/863.
- **V4.1.3** (L1) Least privilege; deny by default — CWE-862.
- **V4.2.1** (L1) Direct object references verified for ownership (IDOR) — CWE-639.
- **V4.2.2** (L1) Anti-CSRF for state-changing operations — CWE-352.
- **V4.3.1** (L1) Admin interfaces require appropriate authorization — CWE-306.

## V5 Validation, Sanitization & Encoding
- **V5.1.2** (L1) Frameworks protect against mass assignment — CWE-915.
- **V5.1.3** (L1) All input validated (allowlist: type/length/range) — CWE-20.
- **V5.2.6** (L1) SSRF: outbound URLs restricted to allowlist — CWE-918.
- **V5.3.3** (L1) Context-aware output encoding (XSS) — CWE-79.
- **V5.3.4** (L1) Parameterized queries / safe APIs for SQL — CWE-89.
- **V5.3.8** (L1) OS command injection protection (escaping/parametrization) — CWE-78.
- **V5.3.10** (L1) XPath/XML injection protection — CWE-643/91.
- **V5.5.1** (L1) Deserialization of untrusted data avoided or strictly constrained — CWE-502.
- **V5.5.2** (L1) XML parsers configured against XXE — CWE-611.

## V6 Cryptography
- **V6.2.2** (L2) Approved algorithms only (no MD5/SHA1/DES/ECB) — CWE-327/328.
- **V6.2.3** (L2) Adequate key lengths (RSA ≥ 2048, AES ≥ 128) — CWE-326.
- **V6.3.1** (L2) Security tokens from CSPRNG — CWE-330/338.
- **V6.4.1** (L2) Keys/secrets managed via vault, not source — CWE-321.

## V7 Error Handling & Logging
- **V7.1.1** (L1) No credentials/payment data in logs — CWE-532.
- **V7.1.2** (L1) No sensitive data in logs; log injection prevented — CWE-117/532.
- **V7.2.1** (L2) Auth decisions (success/failure) logged — CWE-778.
- **V7.4.1** (L1) Generic error messages to clients — CWE-209.

## V8 Data Protection
- **V8.2.1** (L1) No sensitive data cached/stored client-side unprotected — CWE-312/525.
- **V8.3.4** (L2) Sensitive data at rest encrypted — CWE-312.

## V9 Communication
- **V9.1.1** (L1) TLS for all client connectivity; no fallback to cleartext — CWE-319.
- **V9.1.3** (L1) Only strong TLS versions/ciphers enabled — CWE-757.
- **V9.2.1** (L2) Server certificates validated (no trust-all) — CWE-295.

## V10 Malicious Code / V12 Files / V13 API / V14 Config
- **V10.3.2** (L1) Integrity of updates/dependencies verified — CWE-494.
- **V12.1.1** (L1) Upload size/quota limits — CWE-770.
- **V12.2.1** (L1) Uploaded file type validated against allowlist — CWE-434.
- **V12.3.1** (L1) Filename input cannot traverse directories — CWE-22.
- **V13.1.4** (L2) API authorization at controller/route level — CWE-862.
- **V14.2.1** (L1) Components up to date; unused features removed — CWE-1104/1395.
- **V14.3.2** (L1) Debug modes disabled in production — CWE-489.
- **V14.4.x** (L1) Security headers (CSP V14.4.3, frame-ancestors V14.4.7) — CWE-693/1021.
- **V14.5.3** (L1) CORS origin allowlist strict — CWE-942.

L1 = minimum for all apps (quick-depth relevant); L2 = standard for apps
handling sensitive data (deep scans verify both).
