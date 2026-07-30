---
standard: CWE/SANS Top 25 Most Dangerous Software Weaknesses (2023)
covers: rank list keyed by CWE, for populating the `sans25` field
use_when: assigning a Top 25 rank to a finding from its CWE (quick and deep scans)
---

# CWE/SANS Top 25 (2023) — rank by CWE

Populate `sans25` as `"Rank n"` when the finding's CWE is on the list;
otherwise `null`. Match on the exact CWE (or its direct child — e.g. CWE-95
counts under CWE-94's rank 23 only if you recorded the parent; prefer exact).

| Rank | CWE | Weakness |
|---|---|---|
| 1 | CWE-787 | Out-of-bounds Write |
| 2 | CWE-79 | Cross-site Scripting |
| 3 | CWE-89 | SQL Injection |
| 4 | CWE-416 | Use After Free |
| 5 | CWE-78 | OS Command Injection |
| 6 | CWE-20 | Improper Input Validation |
| 7 | CWE-125 | Out-of-bounds Read |
| 8 | CWE-22 | Path Traversal |
| 9 | CWE-352 | Cross-Site Request Forgery |
| 10 | CWE-434 | Unrestricted Upload of Dangerous File Type |
| 11 | CWE-862 | Missing Authorization |
| 12 | CWE-476 | NULL Pointer Dereference |
| 13 | CWE-287 | Improper Authentication |
| 14 | CWE-190 | Integer Overflow or Wraparound |
| 15 | CWE-502 | Deserialization of Untrusted Data |
| 16 | CWE-77 | Command Injection |
| 17 | CWE-119 | Improper Restriction of Memory Buffer Operations |
| 18 | CWE-798 | Use of Hard-coded Credentials |
| 19 | CWE-918 | Server-Side Request Forgery |
| 20 | CWE-306 | Missing Authentication for Critical Function |
| 21 | CWE-362 | Race Condition (concurrent execution) |
| 22 | CWE-269 | Improper Privilege Management |
| 23 | CWE-94 | Code Injection |
| 24 | CWE-863 | Incorrect Authorization |
| 25 | CWE-276 | Incorrect Default Permissions |

Memory-safety entries (787/416/125/476/190/119) apply mostly to C/C++/unsafe
code; for managed-language apps they will rarely appear.

Quick-depth note: a "quick" scan's checklist = OWASP Top 10 categories +
these 25 CWEs. A finding on neither list can still be recorded, but flag it
`sans25: null` and let CVSS carry the severity.

Related CWEs that inherit no rank (set null): CWE-639 (IDOR — related to 862
but distinct), CWE-521, CWE-327/916 (crypto — not on 2023 list), CWE-918 is
rank 19 (exact), CWE-611 (not on 2023 list).
