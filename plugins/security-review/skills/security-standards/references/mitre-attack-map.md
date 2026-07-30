---
standard: MITRE ATT&CK (Enterprise, curated techniques)
covers: technique IDs relevant to application-code weaknesses, keyed by finding class
use_when: populating the `mitre_attack` field on deep scans — how an adversary would leverage the weakness
---

# MITRE ATT&CK — technique mapping for code findings

ATT&CK describes adversary behavior, so map by *what the weakness enables*.
Many pure code-quality findings have no honest technique — use `null` freely.
One technique per finding (the most direct).

| Weakness class (typical CWEs) | Technique | Name / relevance |
|---|---|---|
| Any internet-facing exploitable flaw (SQLi, RCE, SSRF, deserialization — 89/78/94/502/918) | **T1190** | Exploit Public-Facing Application |
| XSS / content injection driving victim browsers (79) | **T1189** / T1204 | Drive-by Compromise / User Execution |
| Hardcoded or default credentials (798/1188) | **T1078.001** | Valid Accounts: Default Accounts |
| Stolen/replayable sessions, fixation (384/613) | **T1550.004** | Use Alternate Auth Material: Web Session Cookie |
| Brute-forceable auth (307/521) | **T1110** | Brute Force (.003 spraying, .004 stuffing) |
| Weak token randomness (330/338) | **T1552** adjac. | Forge/predict credentials — prefer T1552.001 if secrets on disk |
| Secrets in code/config/logs (798/321/532/312) | **T1552.001** | Unsecured Credentials: Credentials in Files |
| Cleartext transmission (319/295 MITM) | **T1040** / T1557 | Network Sniffing / Adversary-in-the-Middle |
| Privilege escalation via authZ flaws (269/862/863/639/915) | **T1068** | Exploitation for Privilege Escalation (app-level) |
| Path traversal / arbitrary file read (22) | **T1005** | Data from Local System |
| Unrestricted upload → webshell (434) | **T1505.003** | Server Software Component: Web Shell |
| SSRF to cloud metadata (918) | **T1552.005** | Cloud Instance Metadata API |
| Vulnerable dependencies (1395/1104) | **T1195.001** | Supply Chain: Software Dependencies |
| Unverified downloads/updates (494/829/426) | **T1195.002** | Supply Chain: Software Supply Chain |
| Missing logging/monitoring (778) | **T1562.008-adjacent** | Impair Defenses (gap eases evasion) — often better `null` |
| Log injection/tampering paths (117, writable logs) | **T1070** | Indicator Removal |
| Open redirect (601) | **T1566.002** | Phishing: Spearphishing Link (enabler) |
| Debug endpoints / info disclosure (489/209/200) | **T1592/T1595-adjacent** | Recon enablers — usually `null`; use T1082 only if system info exposed |
| DoS via missing limits (770/799) | **T1499** | Endpoint Denial of Service |
| Permissive IaC exposure (732/1188 cloud) | **T1530** | Data from Cloud Storage (public buckets) |

Report usage: cite the technique to explain adversary value ("this IDOR gives
an authenticated attacker T1068-style privilege abuse over other tenants'
data"), never as a how-to. Techniques marked "adjacent" or "usually null" —
prefer `null` unless the connection is concrete in this codebase.
