---
standard: CWE (curated subset) — cryptography, secrets storage, randomness
covers: CWE IDs for findings in categories crypto and secrets (storage/handling side)
use_when: assigning the `cwe` field for cryptographic and secret-handling findings
---

# CWE — cryptography & secrets weaknesses (curated)

**CWE-327 Broken or Risky Cryptographic Algorithm** — security decisions on
broken primitives: DES/3DES/RC4/Blowfish-small-block, MD5/SHA1 for
signatures, custom ciphers. *Detect:* algorithm names in crypto API calls
(`Cipher.getInstance("DES...")`, `hashlib.md5` for security use,
`crypto.createCipher` legacy). *X-refs:* A02, SANS #21 region, ASVS V6.2.2,
NIST SC-13, PCI 3.6/4.2.

**CWE-328 Weak Hash** — fast/broken hash where collision or preimage
resistance is needed. *Detect:* MD5/SHA1 for integrity of security data,
tokens, or dedup of secrets. *X-refs:* CWE-327, A02.

**CWE-916 Password Hash With Insufficient Computational Effort** — passwords
stored with fast hashes (MD5/SHA-family, single iteration) instead of
bcrypt/scrypt/argon2/PBKDF2. *Detect:* password fields hashed via generic
hash APIs; missing per-user salt. *X-refs:* A02, ASVS V2.4, PCI 8.3.2.

**CWE-759/760 Salt Issues** — hash without salt (759) or with predictable
salt (760). *Detect:* constant/static salt literals; hash(password) with no
salt argument. *X-refs:* CWE-916.

**CWE-326 Inadequate Encryption Strength** — correct algorithm, weak
parameters: RSA < 2048, ECC < 224, AES-128 where policy needs 256, low
PBKDF2 iterations. *Detect:* key-size literals in keygen calls. *X-refs:*
A02, ASVS V6.2.3, NIST SC-12.

**CWE-1204 / static IV misuse (ECB & IV reuse)** — ECB mode, or fixed/zero
IV/nonce with CBC/GCM. *Detect:* `"AES/ECB"`, IV built from constant bytes,
nonce reuse in loops. Map ECB itself to CWE-327; IV misuse to CWE-1204
(Generation of Weak IV) or CWE-323 (nonce reuse). *X-refs:* A02, ASVS V6.2.5.

**CWE-330/338 Insufficiently Random Values / Weak PRNG** — security tokens
from non-CSPRNG: `Math.random`, `java.util.Random`, Python `random`, `rand()`.
*Detect:* those APIs feeding session IDs, reset tokens, OTPs, keys. *X-refs:*
A02, CAPEC-59, ASVS V6.3, SANS-adjacent.

**CWE-321 Hardcoded Cryptographic Key** — encryption/signing key embedded in
source or repo config. *Detect:* byte-array/base64 literals passed to key
constructors; JWT secret literals. *X-refs:* A02, CWE-798, ASVS V6.4, PCI 3.6.

**CWE-319 Cleartext Transmission of Sensitive Information** — credentials or
sensitive data over http://, ftp://, unencrypted sockets; TLS optional or
downgradable. *Detect:* plain-http URLs to APIs carrying auth; missing
HSTS where in scope. *X-refs:* A02, SANS #14 region, ASVS V9.1, NIST SC-8,
PCI 4.2.1, ATT&CK T1040.

**CWE-312 Cleartext Storage of Sensitive Information** — secrets/PII stored
unencrypted in files, DB columns, localStorage. *Detect:* password/card/SSN
fields written without encryption; sensitive values in world-readable files.
*X-refs:* A02, ASVS V8.2, PCI 3.5, NIST SC-28.

**CWE-522 Insufficiently Protected Credentials** — credentials stored or
transmitted with inadequate protection (recoverable encryption for
passwords, creds in URLs). *Detect:* reversible encryption of passwords;
basic-auth creds in query strings or logs. *X-refs:* A04/A07, SANS #14,
ASVS V2.10.

**CWE-532 Sensitive Information in Log Files** — tokens, passwords, PII
written to logs. *Detect:* logger calls including password/token/card
variables; request-dump middleware in prod. *X-refs:* A09, ASVS V7.1, PCI
10.x, NIST AU-9. (Also routed from `logging` category via cwe-design.md.)

**CWE-208/203 Observable Timing/State Discrepancy** — non-constant-time
comparison of secrets (MACs, tokens, passwords). *Detect:* `==`/`equals` on
secret strings instead of constant-time compare. *X-refs:* A02, CAPEC-462.

**CWE-757 Algorithm Downgrade** — negotiation allows weakest option
(SSLv3/TLS1.0 enabled, `SECURITY_LEVEL=0`). *Detect:* TLS config enabling
legacy protocol versions or NULL/EXPORT cipher suites. *X-refs:* A02, ASVS
V9.1.3, PCI 4.2.

Selection notes: hardcoded *password/API key* → CWE-798 (cwe-authz.md);
hardcoded *cryptographic key material* → CWE-321. Password storage → prefer
CWE-916 over generic CWE-327. Token predictability → CWE-330/338 rather than
CWE-326.
