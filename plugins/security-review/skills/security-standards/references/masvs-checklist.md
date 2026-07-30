---
standard: OWASP MASVS v2.1 (curated controls)
covers: mobile app security verification controls, keyed to CWE — MOBILE app type ONLY
use_when: app type includes mobile — populating ASVS-equivalent mappings for mobile findings; NEVER load for web/API/iac scans
---

# MASVS v2.1 — curated controls (mobile projects only)

For mobile findings, record the MASVS control in the `asvs` field prefixed
`MASVS-` (e.g. `MASVS-STORAGE-1`). Groups: STORAGE, CRYPTO, AUTH, NETWORK,
PLATFORM, CODE, RESILIENCE, PRIVACY.

## MASVS-STORAGE
- **STORAGE-1** Sensitive data stored securely (Keychain/Keystore, not
  SharedPreferences/NSUserDefaults/SQLite in cleartext). *Detect:* tokens/PII
  written to prefs, unencrypted DBs, external/shared storage. → CWE-312/922.
- **STORAGE-2** No leakage via logs, backups, keyboards, screenshots,
  clipboard. *Detect:* `Log.d` with secrets, `allowBackup="true"` with
  sensitive data, no FLAG_SECURE on sensitive screens. → CWE-532/200.

## MASVS-CRYPTO
- **CRYPTO-1** Current strong crypto; no MD5/SHA1/DES/ECB, no hardcoded IVs.
  *Detect:* weak algorithm names in crypto calls. → CWE-327/1204.
- **CRYPTO-2** Keys managed in platform keystore; not hardcoded or in assets.
  *Detect:* key literals, keys in strings.xml/plist/assets. → CWE-321.

## MASVS-AUTH
- **AUTH-1** Appropriate authentication protocols; tokens validated
  server-side. *Detect:* client-side-only auth decisions. → CWE-287/602.
- **AUTH-2** Local (biometric/PIN) auth implemented via platform APIs and not
  bypassable. *Detect:* boolean-gate biometrics (`onAuthSucceeded` flipping a
  flag with no crypto binding). → CWE-287.
- **AUTH-3** Session/token lifecycle secure: expiry, revocation, no tokens in
  URLs or logs. → CWE-613/532.

## MASVS-NETWORK
- **NETWORK-1** TLS for all traffic; no cleartext. *Detect:*
  `usesCleartextTraffic="true"`, `NSAllowsArbitraryLoads`, http:// endpoints.
  → CWE-319.
- **NETWORK-2** Certificate validation correct; pinning where required.
  *Detect:* custom TrustManager accepting all, `ALLOW_ALL_HOSTNAME_VERIFIER`.
  → CWE-295.

## MASVS-PLATFORM
- **PLATFORM-1** IPC use secured: exported activities/services/receivers
  protected, intents validated, no unprotected deep links performing
  sensitive actions. *Detect:* `exported="true"` without permission;
  unvalidated `getIntent()` data. → CWE-926/927.
- **PLATFORM-2** WebViews configured securely: JS only if needed, no
  `addJavascriptInterface` to untrusted content, file access off. → CWE-749/79.
- **PLATFORM-3** No sensitive functionality exposed via URL schemes /
  app links without verification. → CWE-939.

## MASVS-CODE
- **CODE-1** App signed and built in release mode without debug symbols.
  *Detect:* `debuggable="true"` in release config. → CWE-489.
- **CODE-2** Platform security features enabled (ASLR/PIE by default; avoid
  disabling). Third-party libs current. → CWE-1395.
- **CODE-3** Input from external sources (deep links, IPC, files) validated —
  the injection CWEs from cwe-injection.md apply on-device too. → CWE-20.

## MASVS-RESILIENCE & PRIVACY (note-level)
- **RESILIENCE-1..4** Anti-tampering/root-detection/obfuscation — record as
  informational (L2/R profile), not vulnerabilities, unless the app's threat
  model demands them (e.g. payments).
- **PRIVACY-1** Minimize collection/sharing of personal data; check SDKs
  receiving PII. → CWE-359.

Severity note: mobile client findings usually score CVSS AV:L or AV:P unless
the flaw is network-reachable (NETWORK-*, server-trusting-client AUTH-1 →
AV:N). Use the cvss-scoring.md rubric as usual.
