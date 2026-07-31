# security-scan-mcp — High-Level Design

MCP server that runs real security scanners in code and exposes them to any
MCP client (Claude Code, Cursor, CI) as a small set of bounded, versioned
tools. It is the deterministic half of the security-review architecture; the
LLM client keeps the judgment half.

## 1. Design assessment

### The core idea (and why it is right)

> MCP is not the scanner itself; it is the tool interface layer that exposes
> capabilities to the client in a standard way.

This is the correct mental model, and the resulting split is the
industry-consensus pattern for LLM-assisted security review:

| Deterministic (server, code) | Judgment (client, LLM) |
|---|---|
| Run Semgrep / osv-scanner / Gitleaks / IaC scanners | Semantic review of business logic, authz, trust boundaries |
| Parse SARIF/XML/JSON scanner output | Triage: false-positive analysis, exploitability reasoning |
| Normalize into one findings schema | CVSS vector judgment calls (server computes score from vector) |
| Standards crosswalk lookups (CWE → OWASP/ASVS/NIST/PCI/…) | Explaining findings in the project's own terms |
| Dedup, baseline suppression, rank, filter, paginate | Proposing fixes in the project's idioms |
| CVE lookups with caching | Deciding what is worth the team's attention |

The existing plugin (`agents/scanner.md` et al.) puts *detection* on the LLM.
That works, but detection is exactly where LLMs are weakest relative to
tools: recall varies run to run, coverage is unverifiable, and a scan cannot
be reproduced or diffed. Moving detection into code and keeping the LLM for
triage/explanation/remediation plays each side to its strength.

### Advantages

1. **Determinism and reproducibility.** Same commit + same rules = same
   findings. Enables baselines, regression detection ("new finding since last
   scan"), and CI gating — none of which an LLM-only scan can honestly offer.
2. **Token economy.** The server pre-aggregates: the model sees a compact,
   filtered, deduplicated findings list, never raw SARIF or full-repo dumps.
   A monorepo scan producing 3,000 raw hits becomes "42 findings above
   threshold, top 10 attached, cursor for the rest."
3. **Client portability.** The same server serves Claude Code, Cursor, a CI
   job, or a nightly cron. Skills/subagents are Claude-Code-only; the tool
   contracts are not.
4. **A real security boundary.** Bounded tools with validated inputs replace
   "LLM with a shell." The server can enforce repo-scope allowlists, secret
   denylists, and network egress limits in code, where they are auditable.
5. **Stable contracts, evolvable internals.** Swap Semgrep rulesets, add
   detectors, change parsers — prompts and clients do not change.
6. **Scanner recall + LLM precision.** Tools have high recall on
   pattern-matchable bugs and drown users in false positives; the LLM is a
   good FP filter. The combination outperforms either alone.

### Disadvantages and costs (honest list)

1. **You now run infrastructure.** Scanner installs, rule updates, schema
   versioning, packaging, cross-platform quirks. The skills-only plugin was
   zero-infra. This is the single biggest cost.
2. **SAST has a detection ceiling.** Semgrep will never find "this endpoint
   skips the tenant check that every sibling endpoint has." If tool-based
   detection *replaces* LLM code reading, a class of findings is lost.
   → Mitigation: hybrid mode (§4) — keep the semantic-review agent as one
   detector among several; the server merges and dedupes.
3. **Long-running tools don't fit request/response.** A full monorepo scan
   takes minutes; MCP tools are synchronous calls. A single blocking
   `security_review_codebase` tool is opaque and un-interruptible.
   → Mitigation: async job pattern — `start_scan` returns a `scan_id`
   immediately; `get_scan` polls; results are pulled via paginated
   `list_findings`.
4. **Scale still bites.** Normalization doesn't shrink 3,000 findings into
   something a model can reason over. Aggregation, severity thresholds,
   baseline suppression, and pagination are not optional features — they are
   the product.
5. **The server is itself a privileged component.** It reads the whole repo
   and talks to the network (advisory DBs). It must be treated as attack
   surface: scoped, sandboxed, secrets excluded (§6).
6. **Coarser feedback loop during development.** With the skills approach the
   user watches the LLM reason file-by-file; behind a façade tool, the scan
   is a black box until results return. Progress reporting (`get_scan`
   status with per-detector progress) matters for UX.

### Verdict — is it a good value-add?

**Yes, if** any of these hold: you want reproducible/CI-usable scans, you
want the capability outside Claude Code (Cursor, pipelines), or you scan
repos large enough that LLM-only detection is unreliable or token-expensive.

**Marginal, if** the only consumer is one developer interactively running
`/security-review` in Claude Code on small repos — the existing plugin
already does that with zero infrastructure.

The recommendation is **not to replace the plugin but to re-base it**: the
plugin's commands, standards skill, and remediation agent stay as the Claude
Code UX; its detection layer moves into this server; the plugin's
`.mcp.json` registers the server so installation stays one step.

## 2. Architecture

```
┌────────────────────────────────────────────────────────────────┐
│  MCP clients: Claude Code (/security-review), Cursor, CI job   │
└───────────────────────────┬────────────────────────────────────┘
                            │ MCP (stdio locally; streamable HTTP for CI)
┌───────────────────────────▼────────────────────────────────────┐
│  security-scan-mcp server                                      │
│                                                                │
│  Tool layer        contracts, input validation, response caps  │
│  Orchestrator      scan pipelines (diff | full), job manager   │
│  Detector adapters                                             │
│    ├─ SAST        semgrep (multi-language; SpotBugs/Bandit     │
│    │              pluggable behind the same adapter interface) │
│    ├─ SCA         osv-scanner (lockfiles → OSV.dev)            │
│    ├─ Secrets     gitleaks                                     │
│    ├─ IaC/K8s     checkov or trivy-config (phase 3)            │
│    └─ Semantic    LLM-review ingest (client submits findings   │
│                   from its own code reading; server dedupes)   │
│  Normalizer        SARIF/JSON/XML → unified Finding schema     │
│  Enricher          crosswalk.json (CWE↔OWASP/SANS/ASVS/NIST/   │
│                    CIS/PCI/CAPEC), CVSS score-from-vector,     │
│                    OSV/NVD lookups (cached, 7-day expiry)      │
│  Aggregator        fingerprint dedup, baseline suppression,    │
│                    rank, filter, paginate, summarize           │
│  Store             .security-review/ (scans, findings.json,    │
│                    baseline.json, cve-cache.json)              │
│  Emitters          SARIF export, Markdown report               │
│                    (PR comments / tickets stay client-side)    │
└────────────────────────────────────────────────────────────────┘
```

Detector adapters share one interface: `available() -> bool`,
`run(scope) -> list[RawResult]`, `normalize(raw) -> list[Finding]`. A
missing scanner binary degrades that detector to "skipped" (reported in scan
status), never a hard failure.

## 3. Tool surface (v1)

Bounded and small on purpose. No shell tool, no free filesystem tool.

### Scan
- `start_scan(mode: "diff"|"full", base_ref?, head_ref?, paths?, detectors?, severity_threshold?) -> {scan_id}`
  — diff mode is the default posture; full scans are explicit.
- `get_scan(scan_id) -> {status, per-detector progress, counts by severity, new-vs-baseline}`

### Results
- `list_findings(scan_id?, severity?, category?, path_glob?, status?, cursor?) -> {summary, findings[], next_cursor}`
  — always aggregated: capped page size, deduped, baseline-suppressed unless
  `include_suppressed`.
- `get_finding(finding_id) -> Finding` — full evidence: code excerpt with
  surrounding lines, standard references (identifiers + one-line names, not
  prose), CVE refs, dedup fingerprint.
- `get_standard_reference(id)` — crosswalk row for a CWE/OWASP/ASVS/… ID;
  replaces the client loading whole reference files for mapping lookups.

### Triage & fix support (LLM writes back)
- `update_finding_status(finding_id, status: confirmed|false_positive|accepted_risk, reason)`
  — triage decisions persist; `false_positive` feeds the baseline.
- `get_fix_context(finding_id) -> {file segment, related tests, imports}`
  — bounded read: only the finding's file, capped line span.
- `submit_semantic_findings(scan_id, findings[])` — hybrid mode: the client's
  own code review is ingested through the same normalize/dedup path.

### Export
- `export_report(scan_id, format: md|sarif, severity_threshold?) -> path`

Outward actions (PR comments, tickets) are deliberately **not** server tools
in v1 — the client already has gated GitHub tooling, and keeping the scan
server write-only-to-`.security-review/` keeps its privilege story simple.

## 4. Key data flows

**PR review (default):** client calls `start_scan(mode=diff, base_ref=main)`
→ server runs semgrep on changed files, osv-scanner if lockfiles changed,
gitleaks on the diff → normalize → enrich → dedupe vs baseline →
`get_scan` shows "7 new findings" → client `list_findings`, triages each
(marking FPs via `update_finding_status`), optionally reads the changed
files itself and `submit_semantic_findings` → `export_report`.

**Baseline audit:** `start_scan(mode=full)` async; client polls `get_scan`;
findings paged through in severity order; surviving findings become
`baseline.json` so future diff scans report only deltas.

## 5. Findings schema

Reuse the plugin's existing model (stable `SR-nnn` id, file/lines/evidence,
required `cwe`, `cvss` vector+score, nullable `owasp`/`sans25`/`asvs`/
`nist_800_53`/`mitre_attack`/`cis_control`/`pci_dss`/`capec`, `cve_refs`,
`status`, `remediation_status`) with three additions:

- `fingerprint` — hash of (rule id, path, normalized snippet) for dedup and
  baseline matching across line-number drift,
- `detector` — which adapter produced it (`semgrep`, `osv`, `gitleaks`,
  `semantic`),
- `first_seen` / `scan_id` provenance.

SARIF is the interchange format internally (ingest and export); the compact
schema above is what crosses the MCP boundary.

## 6. Security boundaries

The server is privileged automation and is treated as such:

- **Repo scope allowlist.** Root directory fixed at startup (config, not
  tool input); every path parameter is resolved and must stay inside it.
- **Secrets stay out of the capability surface.** `.env*`, key material,
  and credential-pattern paths are excluded from every read/scan response;
  gitleaks findings redact the matched secret (report location + rule only).
- **No raw dumps.** Responses are structured findings with capped excerpt
  sizes and page sizes — never whole files or whole-project listings.
- **Network egress limited** to OSV.dev/NVD for dependency lookups; nothing
  else, and only package name+version leave the machine (source never does).
- **No shell/exec tool.** Scanners run as fixed argv invocations built by
  the server; tool inputs never reach a shell string.
- **Diff-by-default.** Full-repo scans are an explicit mode, matching the
  principle of least surprise for reviewers and least cost for the model.

## 7. Delivery phases

1. **MVP** — stdio server; `start_scan`(diff)/`get_scan`/`list_findings`/
   `get_finding`; semgrep + osv-scanner adapters; normalizer; crosswalk
   enrichment; findings.json store. Plugin's `/security-review` rewired to
   call these tools.
2. **Triage loop** — `update_finding_status`, baseline suppression,
   fingerprint dedup, `get_fix_context`, `export_report`.
3. **Coverage** — gitleaks, IaC adapter, full-scan async jobs with progress.
4. **Hybrid** — `submit_semantic_findings`; scanner agent becomes a
   semantic detector whose output merges with tool findings.
5. **CI mode** — streamable HTTP transport, SARIF upload, severity gate
   exit codes.
