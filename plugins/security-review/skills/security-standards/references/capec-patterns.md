---
standard: CAPEC (curated common attack patterns)
covers: CAPEC IDs for common application weaknesses, keyed by CWE
use_when: populating the `capec` field of a mapped finding from its CWE
---

# CAPEC — common attack patterns (curated, keyed by CWE)

Assign the CAPEC whose *attack* most directly exercises the finding's CWE.
If none clearly applies, set `capec: null` — do not stretch.

| CWE | CAPEC | Pattern name — one-line gist |
|---|---|---|
| CWE-89 | CAPEC-66 | SQL Injection — craft input altering query logic |
| CWE-943 | CAPEC-676 | NoSQL Injection — operator/JSON query manipulation |
| CWE-78/77 | CAPEC-88 | OS Command Injection via crafted parameters |
| CWE-90 | CAPEC-136 | LDAP Injection — filter manipulation |
| CWE-643 | CAPEC-83 | XPath Injection |
| CWE-1336/94 | CAPEC-242 | Code/Template Injection — inject evaluated code |
| CWE-79 | CAPEC-63 | Cross-Site Scripting; stored: CAPEC-592; DOM: CAPEC-588 |
| CWE-918 | CAPEC-664 | Server-Side Request Forgery |
| CWE-601 | CAPEC-178 | Cross-Site Flashing/redirect abuse for phishing |
| CWE-502 | CAPEC-586 | Object Injection — malicious serialized objects |
| CWE-611 | CAPEC-221 | XML External Entities — data exfil via DTD |
| CWE-22 | CAPEC-126 | Path Traversal — ../ sequences to escape root |
| CWE-434 | CAPEC-1 | Accessing Functionality Not Properly Constrained (upload → execute) |
| CWE-352 | CAPEC-62 | Cross-Site Request Forgery |
| CWE-306/287 | CAPEC-115 | Authentication Bypass |
| CWE-307 | CAPEC-49 | Password Brute Forcing; stuffing: CAPEC-600 |
| CWE-798/321 | CAPEC-191 | Read Sensitive Data from Code (embedded secrets) |
| CWE-384 | CAPEC-593 | Session Hijacking via fixation |
| CWE-613 | CAPEC-60 | Reusing Session IDs (replay) |
| CWE-347 | CAPEC-473 | Signature Spoof — unverified/none-alg tokens |
| CWE-295 | CAPEC-94 | Adversary-in-the-Middle via accepted bad certs |
| CWE-319 | CAPEC-158 | Sniffing Network Traffic for cleartext creds |
| CWE-639 | CAPEC-122 | Privilege Abuse — enumerate object keys (IDOR) |
| CWE-862/863 | CAPEC-122 | Privilege Abuse; forced browsing: CAPEC-87 |
| CWE-269/915 | CAPEC-233 | Privilege Escalation (incl. mass-assignment paths) |
| CWE-942 | CAPEC-467 | Cross-Site Identification via permissive CORS |
| CWE-330/338 | CAPEC-59 | Session Credential Prediction (weak randomness) |
| CWE-327/328/916 | CAPEC-97 | Cryptanalysis of weak algorithms/hashes |
| CWE-208 | CAPEC-462 | Cross-Domain Search Timing (timing side channel) |
| CWE-209/200 | CAPEC-215 | Fuzzing for error-message information leaks |
| CWE-117 | CAPEC-93 | Log Injection-Tampering-Forging |
| CWE-367 | CAPEC-27 | Leveraging Race Conditions via Symbolic Links / TOCTOU |
| CWE-840 | CAPEC-25 | Forced Deadlock / business-flow abuse family |
| CWE-494/829/426/1395 | CAPEC-185 | Malicious Software Update / supply-chain insertion; T-party CVEs: CAPEC-538 |
| CWE-1021 | CAPEC-103 | Clickjacking |
| CWE-770 | CAPEC-125 | Flooding — resource exhaustion |
| CWE-732/1188 | CAPEC-1 | Access uncontrolled functionality/resources |

Notes: CAPEC describes *how an attacker exploits* the weakness — use it in
reports to explain realistic abuse, not to generate attack steps. When a
finding maps to a parent CWE with no row here, inherit the nearest child row
only if the attack genuinely matches; else `null`.
