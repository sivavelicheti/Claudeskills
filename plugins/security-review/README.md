# security-review

Standards-based static security review for Claude Code. Scans a codebase,
maps every finding to recognized frameworks (OWASP Top 10, CWE, CVSS, CAPEC,
SANS Top 25, ASVS/MASVS, NIST 800-53, MITRE ATT&CK, CIS v8, PCI DSS v4,
SAMM), generates reports, and produces remediation plans with sample fixes —
including for user-selected subsets of findings.

Built entirely from native Claude Code primitives: slash commands, subagents,
a skill with lazy-loaded reference files, file-based state, and hooks.

## Commands

| Command | Purpose |
|---|---|
| `/security-review [path] [--depth quick\|deep] [--type web\|api\|mobile\|iac\|mixed]` | Scope prompt → inventory → scan → CVE cross-check → standards mapping → `.security-review/findings.json` |
| `/security-report [--format md\|html] [--severity high+] [--standard owasp\|asvs\|pci\|...]` | (Re)generate `SECURITY-REVIEW-REPORT.md` from findings.json |
| `/security-remediate [SR-001,SR-004 \| --severity critical+high \| --standard pci \| --all]` | Remediation plan (`REMEDIATION-PLAN.md`) + sample fixes; optional confirmed apply |

## Architecture

- **`agents/scanner.md`** — static analysis; detection only. Never reads
  reference files.
- **`agents/standards-mapper.md`** — enriches findings with framework IDs and
  computes CVSS from the rubric. Processes findings batch-by-category,
  loading at most 2 reference files at a time via the routing table in
  `skills/security-standards/SKILL.md`.
- **`agents/remediation-engineer.md`** — root cause, strategy, before/after
  fix in the project's idioms, effort, regression tests. At most 1 reference
  file per finding.
- **`skills/security-standards/`** — SKILL.md is a routing index (<500
  tokens); `references/` holds curated per-standard files (~2k tokens each,
  3-line YAML head for grep-able relevance checks). CWE is split by category
  (`cwe-injection`, `cwe-authz`, `cwe-crypto`, `cwe-design`).
- **State** — `.security-review/inventory.json`, `findings.json`,
  `cve-cache.json` (CVE data fetched live from OSV/NVD, 7-day expiry).
  Findings carry identifiers, never standard prose.
- **Hooks** — `post-scan-critical-check.sh` warns when findings.json contains
  open Critical items; `reference-budget-guard.sh` warns when a session reads
  more than 2 distinct reference files.

## Guardrails

- Static review and defensive remediation only — never generates exploit code.
- Source code never leaves the machine; only dependency name/version go to
  OSV.dev / NVD.
- Code is only modified in `/security-remediate` Step 4 with explicit
  per-fix or per-batch confirmation, and relevant tests are re-run.
- `.security-review/` is offered for `.gitignore` on first scan.

## Findings data model

Each finding in `.security-review/findings.json`: stable `SR-nnn` ID, title,
category, file, lines, evidence, `cwe` (required), `cvss` vector/score/
severity (required, computed from `references/cvss-scoring.md`), plus
`owasp`, `capec`, `sans25`, `asvs`, `nist_800_53`, `mitre_attack`,
`cis_control`, `pci_dss` (null when not applicable — never invented),
`cve_refs`, `status`, `remediation_status`.
