# MCP Security Harness — High-Level Design

Status: PROPOSED / DEFERRED — build when a trigger fires (Wiz API access
materializes, a second MCP client such as Cursor/CI needs these capabilities,
or org-wide rollout begins). Near-term direction instead: harden the
security-review plugin with stdlib helper scripts for the deterministic work
(CVSS arithmetic, CVE queries + cache, findings-store ID stability, report
rendering); those scripts later lift unchanged into this server's core modules.
Owner: security-review plugin

## 1. Context and goal

The `security-review` plugin v0.1 runs entirely LLM-side: a scanner subagent
reads code and detects vulnerabilities; a standards-mapper subagent loads
curated markdown reference files to map findings to frameworks; commands
write `findings.json` and render reports.

This design moves the **deterministic** half of that pipeline into code,
exposed to Claude Code (or any MCP client) through a local MCP server —
while keeping the **judgment** half in the LLM. No external SAST tool
(Semgrep etc.) is assumed today; a commercial platform (Wiz) may be
integrated later as an additional findings source.

## 2. Division of labor (the core decision)

| Concern | Owner | Why |
|---|---|---|
| Scanning code for weaknesses | **LLM** (scanner subagent) | semantic detection: IDOR, authz, logic flaws — no tool dependency |
| Choosing the CWE for a finding | **LLM** | judgment over code intent |
| CWE → OWASP/SANS/ASVS/NIST/CIS/PCI/CAPEC/ATT&CK crosswalk | **MCP server** | deterministic lookup table |
| CVSS score from a metric vector | **MCP server** | pure arithmetic; LLM picks the metrics, server computes |
| CVE data for dependencies | **MCP server** | live OSV queries, 7-day cache, stale-cache fallback — works offline |
| Maintaining/updating security data files | **MCP server** | versioned data, refresh tooling, no prompt drift |
| Findings persistence, stable IDs, dedupe | **MCP server** | fingerprint-based `SR-nnn` stability across scans |
| Report generation (md/html/SARIF) | **MCP server** | deterministic rendering from the store |
| Fix suggestions / remediation diffs | **LLM** (remediation-engineer) | language + codebase idiom work |
| Applying fixes | **LLM + human confirmation** | privilege separation |

Everything the LLM used to *look up* becomes a tool call; everything the LLM
*judges* stays a prompt. The curated reference files remain in the plugin as
(a) the compile source for the server's crosswalk data and (b) the fallback
when the server is not running.

## 3. Architecture

```
┌───────────────────────── Claude Code (orchestration client) ─────────────────────────┐
│  /security-review        /security-report          /security-remediate              │
│  scanner agent (LLM scan) · standards-mapper (CWE judgment + metric selection)      │
│  remediation-engineer (fix suggestions) · skills/references (fallback knowledge)    │
└────────────┬─────────────────────────────────────────────────────────────────────────┘
             │ MCP (stdio, local process)
┌────────────▼──────────────── security-scan MCP server (Python, stdlib core) ─────────┐
│ Knowledge tools                     State tools                Report tools          │
│  lookup_standards(cwe)               submit_findings(...)       generate_report(...) │
│  compute_cvss(vector)                list_findings(filter)                           │
│  query_cve(pkg,ver,eco)              get_finding(id)                                 │
│  refresh_security_data()             update_finding_status(...)                      │
│                                                                                      │
│  data/crosswalk.json  ← compiled from plugin reference files (versioned)             │
│  cvss.py              ← CVSS v3.1 base-score arithmetic                              │
│  cve.py               ← OSV client + .security-review/cve-cache.json (7-day TTL,     │
│                          stale-fallback, offline-degradation)                        │
│  store.py             ← .security-review/findings.json (canonical, same schema as    │
│                          plugin v0.1) + id-map.json fingerprint→SR-nnn               │
│  report.py            ← md / html / SARIF renderers, jailed code-excerpt reader      │
│  adapters/wiz.py      ← FUTURE: ingest Wiz issues → normalize → same store           │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

## 4. Tool contracts (v1 — 9 tools)

| Tool | Input | Output | Notes |
|---|---|---|---|
| `lookup_standards` | `cwe` (e.g. "CWE-89") | crosswalk row: name, owasp, sans25, asvs, nist_800_53, cis_control, pci_dss, capec, mitre_attack (nulls where N/A) | replaces LLM reading 5+ reference files per finding |
| `compute_cvss` | `vector` (CVSS:3.1 string) | `{score, severity, breakdown}` | validates metrics; LLM chooses metrics via its rubric, server does arithmetic |
| `query_cve` | `name, version, ecosystem` | `{vulns[], source, fetched_at, stale?}` | cache-first; stale cache on network failure; explicit `checked:false` when impossible |
| `refresh_security_data` | `force?` | refreshed/expired counts, data versions | maintains the data files; reports crosswalk + cache version info |
| `submit_findings` | scan meta + findings[] | assigned IDs, validation errors | enforces schema (CWE + CVSS vector required), computes score authoritatively, fingerprint-dedupes, merges into findings.json |
| `list_findings` | severity_min?, status?, standard?, page? | compact finding cards | paginated; never dumps full detail |
| `get_finding` | `id` | full record | progressive disclosure |
| `update_finding_status` | ids[], status?/remediation_status? | updated ids | used by /security-remediate |
| `generate_report` | format (md/html/sarif), severity_min?, standard? | path of written report + summary counts | renders deterministically from the store; returns a summary, not the report body |

Deliberately **absent** from the surface: raw shell, unrestricted file read,
PR-comment/ticket writers (stay client-side with human confirmation), and
scan execution (the LLM scans; future Wiz ingest is a pull, not a scan).

## 5. Data & state

- **`.security-review/findings.json`** — canonical store, byte-compatible with
  the plugin v0.1 schema, so all commands work with or without the server.
- **`.security-review/id-map.json`** — fingerprint → `SR-nnn`. Fingerprint =
  sha256(category | file | normalized title), so re-scans keep IDs stable even
  when line numbers shift; new findings get the next free number.
- **`.security-review/cve-cache.json`** — OSV responses with `fetched_at`,
  7-day TTL. Degradation ladder: fresh cache → live query → stale cache
  (marked `stale: true`) → `checked: false` recorded, report footer notes the gap.
- **`mcp-server/security_scan_mcp/data/crosswalk.json`** — versioned standards
  crosswalk compiled from the plugin's reference files. Updating a standard =
  edit reference file → regenerate/patch crosswalk → bump data version.

## 6. Security boundaries

- Server is local, stdio-only, spawned by the client; no listening port.
- All file access jailed to the repo root (resolved, symlink-safe) with deny
  globs: `.env*`, `*.pem`, `*.key`, `id_rsa*`, `secrets/**`, `.git/**`.
- Network egress limited to OSV/NVD endpoints, dependency name+version only —
  never source code. Honors proxy env; fails closed to cache.
- Structured output only; findings carry identifiers and one-line evidence,
  never bulk source dumps.
- Report/code-excerpt reader returns cited lines ±3 max per finding.

## 7. Future: Wiz (and other platform) integration

Wiz is not a scanner the server runs — it is an external findings *source*.
Integration = one adapter (`adapters/wiz.py`):

1. `ingest_wiz_findings(project?)` tool (enabled only when `WIZ_CLIENT_ID`/
   `WIZ_CLIENT_SECRET` configured) pulls Issues via the Wiz GraphQL API.
2. Normalizer maps Wiz issue → the same finding schema (Wiz provides CVE/CWE
   and severity; crosswalk fills the rest) with `source: "wiz"`.
3. Fingerprint dedupe merges overlap between LLM-scan findings and Wiz
   findings; reports gain a per-source column.

The same pattern later admits Semgrep/Trivy/etc. — each is an adapter
emitting normalized findings into the one store; nothing else changes.

## 8. Failure modes & degradation

| Failure | Behavior |
|---|---|
| MCP server not running/installed | Commands fall back to v0.1 pure-LLM path (reference files, LLM-computed CVSS, direct findings.json writes) |
| No network | `query_cve` serves stale cache or records `checked:false`; scan proceeds; report notes the gap — degraded is never silently "clean" |
| Invalid finding submitted | `submit_findings` returns per-item validation errors; nothing partial is written |
| Unknown CWE in lookup | Row of nulls + `known:false` — the LLM must not invent mappings |

## 9. Rollout

1. v0.2 (this change): server skeleton + 9 tools + tests; plugin `.mcp.json`;
   commands prefer MCP tools with explicit fallback.
2. v0.3: `refresh_security_data` gains standards-version checking; SARIF
   upload guidance for GitHub code scanning.
3. v0.4: Wiz adapter behind env-gated tool.
