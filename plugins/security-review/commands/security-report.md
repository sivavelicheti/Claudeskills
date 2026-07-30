---
description: Generate SECURITY-REVIEW-REPORT.md from .security-review/findings.json
argument-hint: "[--format md|html] [--severity high+|critical] [--standard owasp|asvs|pci|cwe|nist|cis]"
---

# /security-report — generate the security review report

Read `.security-review/findings.json` and produce `SECURITY-REVIEW-REPORT.md`
in the repo root. Do NOT re-scan and do NOT read
`skills/security-standards/references/` — the findings already carry all
identifiers; the report uses IDs plus the one-line descriptions stored on
each finding.

If `findings.json` does not exist, tell the user to run `/security-review`
first and stop.

## Flags (parse from $ARGUMENTS)

- `--format md|html` — default `md`. For `html`, generate a single
  self-contained HTML file (`SECURITY-REVIEW-REPORT.html`, inline CSS, no
  external resources) with the same sections.
- `--severity high+` — include only High and Critical findings
  (`critical` = Critical only; `medium+` = Medium and above).
- `--standard owasp|asvs|pci|cwe|nist|cis` — single-standard view: skip the
  other per-standard groupings and render only that grouping plus the
  detailed findings that map to it.

## Report structure

1. **Executive summary** — total findings; counts by severity; top 3–5 risks
   (highest CVSS) each in one sentence; an overall posture statement
   (2–3 sentences, e.g. "authentication paths are the dominant risk area").
2. **Severity distribution table** — Critical (9.0–10.0) / High (7.0–8.9) /
   Medium (4.0–6.9) / Low (0.1–3.9) with counts and finding IDs.
3. **Per-standard views** (skip any where every finding is `null` for that field):
   - Findings grouped by OWASP Top 10 category.
   - Findings grouped by CWE.
   - Findings grouped by ASVS chapter (V1–V14, from the `asvs` field prefix).
   - **Compliance-gap table** — one row per NIST 800-53 control, CIS control,
     and PCI DSS requirement that has ≥1 open finding: `Framework | Control |
     Finding IDs | Gap summary (one line)`.
4. **Detailed findings** — one `###` section per finding, ordered by CVSS
   descending: title, ID, severity badge, file:lines, evidence, a short code
   excerpt (read ONLY the cited lines ±3 from the source file — never whole
   files), all non-null framework mappings as a compact table, and the CVSS
   breakdown (vector string with each metric spelled out, e.g. "AV:N — network
   attackable").
5. **SAMM note** — 2–3 process-level observations inferred from finding
   patterns (e.g. repeated missing input validation → no central validation
   library → SAMM Design/Security Requirements maturity gap; hardcoded
   secrets → SAMM Implementation/Secure Deployment gap). Keep it to patterns
   visible in the findings; do not audit the org.
6. **Metadata footer** — scan_id, scope, depth, app type, generation time,
   and a note that CVE data (if any) was fetched from OSV/NVD with the
   fetched-at date from `cve-cache.json`.

Style: identifiers and one-line descriptions only — never reproduce standard
text at length. Keep the report skimmable; tables over prose where possible.

Finish by printing where the report was written and the severity counts.
