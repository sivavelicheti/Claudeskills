"""security-scan-mcp: bounded security-scanning tools behind MCP.

The server is the deterministic half of the security-review architecture:
it runs real scanners, normalizes their output into one schema, applies the
standards crosswalk (CWE -> OWASP/SANS/ASVS/NIST/CIS/PCI/CAPEC), and persists
findings. Judgment tasks (semantic review, CVSS scoring, triage, remediation)
stay with the LLM client.
"""

__version__ = "0.2.0"
