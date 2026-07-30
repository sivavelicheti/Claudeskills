---
description: Run a standards-based static security scan and write findings to .security-review/findings.json
argument-hint: "[path|module|glob] [--depth quick|deep] [--type web|api|mobile|iac|mixed]"
---

# /security-review — standards-based security scan

You are orchestrating a security review. You coordinate subagents and manage
file-based state; you do NOT read `skills/security-standards/references/`
yourself — only the `standards-mapper` subagent loads reference files
(and `remediation-engineer`, at most 1 per finding). This keeps standard text
out of the main conversation.

## Guardrails (apply to the whole flow)

- Static review and defensive remediation only. NEVER generate working exploit
  code, proof-of-concept payloads, or attack tooling — identify weaknesses and fixes.
- NEVER send source code to external services. Only dependency names/versions
  may be sent to NVD/OSV for CVE lookup.
- All state lives in `.security-review/` in the project root.

## Step 1 — Scope prompt (required, never skip)

Parse `$ARGUMENTS` for a path/glob, `--depth`, and `--type`. For anything not
provided, ask the user (use AskUserQuestion) before touching any code:

1. **Scope**: whole codebase, or a specific component (accept a path, module
   name, or glob, e.g. `src/auth/**`).
2. **Depth**:
   - `quick` — OWASP Top 10 + SANS Top 25 checks only.
   - `deep` — full standards sweep incl. ASVS L2, CIS Controls, NIST 800-53
     control mapping, PCI DSS mapping.
3. **Application type**: `web` / `api` / `mobile` / `iac` / `mixed`. This
   decides which reference files are in scope (e.g. `masvs-checklist.md` is
   ONLY in scope for `mobile` or `mixed`-with-mobile projects).

## Step 2 — Inventory

Build a compact inventory of the in-scope code yourself (Glob/Grep/Read on
manifests only — do not read every source file):

- Languages and frameworks (from manifests: package.json, pom.xml,
  build.gradle, requirements.txt, go.mod, Gemfile, *.csproj, Dockerfile, …)
- Entry points (HTTP routes/controllers, CLI mains, message consumers)
- Auth layers (middleware, filters, decorators, session/JWT handling)
- Data stores and how they are accessed (ORM, raw SQL, drivers)
- Secrets-handling patterns (env vars, config files, vaults)
- Dependency list with pinned versions (for CVE cross-check)

Create `.security-review/` if missing, then write
`.security-review/inventory.json`:

```json
{
  "scan_id": "<UTC timestamp YYYY-MM-DDTHH-MM>",
  "scope": "<path or glob>",
  "depth": "quick|deep",
  "app_type": "web|api|mobile|iac|mixed",
  "languages": [], "frameworks": [], "entry_points": [],
  "auth_layers": [], "data_stores": [], "secrets_patterns": [],
  "dependencies": [{"name": "", "version": "", "ecosystem": ""}]
}
```

If `.security-review/` is not in `.gitignore`, ask the user once whether to
add it (recommend yes) and add it if they agree.

## Step 3 — Scan (scanner subagent)

Launch the `scanner` subagent (Agent tool, subagent_type `scanner`). Pass in
the prompt: the scope, depth, app type, and the inventory JSON content. If the
in-scope code is large (> ~50 source files), chunk by module/directory: run
the scanner once per chunk and merge results, keeping finding IDs unique
(`SR-001`, `SR-002`, … numbered across the whole scan — tell each chunk's
scanner the starting ID number).

The scanner returns raw findings (JSON array). It does NOT assign standards
mappings or CVSS — only detection evidence and a provisional severity guess.

## Step 4 — CVE cross-check for dependencies

For each pinned dependency from the inventory, check `.security-review/cve-cache.json`
first (entries expire after 7 days — compare `fetched_at`). On cache miss,
query OSV.dev via WebFetch: POST-style query to
`https://api.osv.dev/v1/query` with `{"package": {"name": "...", "ecosystem": "..."}, "version": "..."}`
(fall back to the NVD API `https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=<name>+<version>`
if OSV is unreachable). Send ONLY dependency name/version — never code.
Update the cache with `fetched_at` timestamps. Turn any hits into raw
findings (category `vulnerable-dependency`, with `cve_refs` populated).

## Step 5 — Standards mapping (standards-mapper subagent)

Group raw findings by category, then launch the `standards-mapper` subagent
with the full raw-findings JSON. It maps each finding to CWE, OWASP, CAPEC,
SANS 25, ASVS, NIST 800-53, MITRE ATT&CK, CIS, PCI DSS (as applicable) and
computes a CVSS vector/score per finding, loading at most 2 reference files
at a time per category batch via the `security-standards` skill. Tell it the
app type so it knows whether MASVS is in scope, and the depth so it knows
which frameworks to populate (quick = CWE/OWASP/SANS/CVSS only; deep = all).

## Step 6 — Persist findings

Write `.security-review/findings.json` in exactly this shape:

```json
{
  "scan_id": "…", "scope": "…", "depth": "…", "app_type": "…",
  "findings": [
    {
      "id": "SR-001", "title": "…", "category": "…",
      "file": "…", "lines": [0, 0], "evidence": "…",
      "cwe": "CWE-89", "owasp": "A03:2021 Injection", "capec": "CAPEC-66",
      "sans25": "Rank 3", "asvs": "V5.3.4", "nist_800_53": "SI-10",
      "mitre_attack": "T1190", "cis_control": "16.1", "pci_dss": "6.2.4",
      "cvss": {"vector": "CVSS:3.1/…", "score": 9.8, "severity": "Critical"},
      "cve_refs": [], "status": "open", "remediation_status": "not_planned"
    }
  ]
}
```

Rules:
- Every finding MUST have `cwe` and a computed `cvss` (vector + score + severity).
- Any framework field that does not genuinely apply is `null` — never invent mappings.
- IDs are stable `SR-nnn`; never renumber on re-scan — a re-scan of the same
  scope updates matching findings in place (same file+category+lines ≈ same
  finding) and appends new ones with fresh IDs.
- Store identifiers and one-line descriptions only — never copy reference
  prose into findings.

## Step 7 — Summarize and hand off

Print a compact summary table (ID, severity, CWE, title, file) sorted by CVSS
score descending, plus counts by severity. Then tell the user:
- `/security-report` to generate the full report
- `/security-remediate` to plan and apply fixes
