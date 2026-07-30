---
standard: PCI DSS v4.0 (code-review-relevant requirements: 3, 4, 6, 8, 10)
covers: mapping from finding classes to PCI DSS requirements for the `pci_dss` field
use_when: deep scans of systems that store/process/transmit cardholder data, or --standard pci report views
---

# PCI DSS v4.0 — requirement mapping for code review

Only requirements observable in code review are listed (Req 3, 4, 6, 8, 10).
Populate `pci_dss` when the codebase plausibly touches cardholder data (CHD)
or is in a CDE; otherwise `null` for all findings. Cite requirement numbers;
this is a mapping aid, not the standard text.

## Req 3 — Protect stored account data
| Requirement | Gist | Typical findings |
|---|---|---|
| 3.3.1 | SAD (CVV/track/PIN) not stored after auth | card-verification fields persisted (312) |
| 3.5.1 | PAN unreadable wherever stored (hash/truncate/encrypt) | cleartext PAN in DB/files/logs (312/532) |
| 3.6.1 | Protect keys securing stored data | hardcoded keys (321), keys beside data |
| 3.7.x | Key lifecycle management | static keys, no rotation hooks |

## Req 4 — Protect CHD in transit over open networks
| 4.2.1 | Strong crypto for PAN transmission | cleartext HTTP for card flows (319); weak TLS versions/ciphers (757); trust-all certs (295) |

## Req 6 — Develop and maintain secure systems and software
| Requirement | Gist | Typical findings |
|---|---|---|
| 6.2.1 | Bespoke software developed securely | pervasive insecure patterns (process) |
| 6.2.4 | Prevent common attack classes: injection, XSS, CSRF, authz bypass, etc. | SQLi (89), XSS (79), CSRF (352), IDOR (639), SSRF (918), deserialization (502), traversal (22) — the default home for exploit-class code findings |
| 6.3.1 | Identify vulnerabilities in bespoke & third-party software | unmonitored dependencies (process) |
| 6.3.3 | Patch known vulnerabilities timely | dependencies with known CVEs (1395/1104) |
| 6.4.x | Protect public-facing web apps against attacks | missing WAF/automated protection (infra observation) |
| 6.5.5 | No live PANs in test/dev | real card numbers in fixtures/tests |
| 6.5.6 | Remove test data/accounts before production | seeded test/admin accounts (1188) |

## Req 8 — Identify users and authenticate access
| Requirement | Gist | Typical findings |
|---|---|---|
| 8.3.1/8.3.2 | Strong auth; creds unreadable in storage & transit | weak password hashing (916), cleartext creds (319/312) |
| 8.3.4 | Lockout after failed attempts | no throttle/lockout (307) |
| 8.3.6 | Password minimum 12 chars, complexity | weak policy (521) |
| 8.6.2 | No hardcoded app/system account credentials in scripts/source | hardcoded credentials (798) |
| 8.2.x | Unique IDs; no shared/generic accounts | shared service accounts in code |

## Req 10 — Log and monitor all access
| Requirement | Gist | Typical findings |
|---|---|---|
| 10.2.x | Audit logs for access to CHD, auth events, privilege changes | missing security logging (778) |
| 10.3.x | Protect logs from tampering | log injection (117), world-writable logs |
| — | (Also:) no PAN/SAD in logs → maps to 3.5.1 not 10 | card data logged (532) |

Default pick: exploit-class code flaw → **6.2.4**; dependency CVE → **6.3.3**;
auth storage/policy → **8.3.x**; hardcoded creds → **8.6.2**; logging gap →
**10.2.1**. Gap-table rows: `PCI Req | Finding IDs | Gap summary`.
