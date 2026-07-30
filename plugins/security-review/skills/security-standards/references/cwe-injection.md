---
standard: CWE (curated subset) — injection, XSS, SSRF, deserialization, traversal
covers: CWE IDs for findings in categories injection-*, xss, ssrf, deserialization, path-traversal
use_when: assigning the `cwe` field for injection-class findings; pick the most specific ID
---

# CWE — injection & data-flow weaknesses (curated)

Pick the MOST specific CWE. Parent IDs (CWE-74, CWE-20) only when nothing
narrower fits. Format: **ID Name** — description. *Detect:* heuristics.
*X-refs:* siblings.

**CWE-89 SQL Injection** — SQL built from unneutralized user input alters
query logic. *Detect:* string concat/interpolation/format into query text;
dynamic ORDER BY/table names; ORM `raw()`/native-query with variables.
*X-refs:* OWASP A03, CAPEC-66, SANS #3, ASVS V5.3.4.

**CWE-943 Improper Neutralization in Data Query Logic** — NoSQL/generic query
injection (e.g. Mongo operator injection via unvalidated JSON). *Detect:*
request objects passed straight into `find()`/query builders; `$where`.
*X-refs:* CWE-89 sibling, OWASP A03.

**CWE-78 OS Command Injection** — command lines built from user input.
*Detect:* `exec/system/popen/spawn/backticks` with concatenated variables;
`shell=True` with dynamic strings. *X-refs:* A03, CAPEC-88, SANS #5, ASVS V5.3.8.

**CWE-77 Command Injection (generic)** — command/argument injection where a
full shell isn't invoked but arguments alter behavior (argument injection).
*Detect:* user input as leading `-` arguments; unquoted args. *X-refs:* CWE-78.

**CWE-90 LDAP Injection** — LDAP filters concatenated from input. *Detect:*
`(&(uid=" + user + "))` patterns without escaping. *X-refs:* A03, CAPEC-136.

**CWE-91 XML Injection / CWE-643 XPath Injection** — user input in XML docs
or XPath queries. *Detect:* XPath strings with concatenation. *X-refs:* A03.

**CWE-1336 Template Injection** — user input evaluated by a template engine
(SSTI). *Detect:* `render_template_string`, `new Function`, template source
built from input; `{{`-bearing input reaching render. *X-refs:* A03, CWE-94.

**CWE-94 Code Injection / CWE-95 Eval Injection** — dynamic code evaluation
of user input (`eval`, `exec`, `vm.runInContext`). *Detect:* eval-family
calls with non-literal arguments. *X-refs:* A03, CAPEC-242, SANS #23.

**CWE-79 Cross-site Scripting** — user input in web output without
context-appropriate encoding. Subtypes: reflected, stored, DOM-based.
*Detect:* `innerHTML`/`dangerouslySetInnerHTML`/`v-html`/`document.write`
with dynamic data; autoescape disabled (`| safe`, `{!! !!}`, `mark_safe`);
unencoded output in server templates. *X-refs:* A03, CAPEC-63, SANS #1/#2
region, ASVS V5.3.3.

**CWE-918 SSRF** — server-side fetch of user-influenced URL. *Detect:* HTTP
client target from request param/body; image/webhook/URL-preview features;
no allowlist or IP-range block (169.254.169.254, RFC1918). *X-refs:* A10,
CAPEC-664, ASVS V5.2.6, ATT&CK T1190.

**CWE-601 Open Redirect** — redirect target from user input. *Detect:*
`redirect(request.args['next'])` without allowlist. *X-refs:* A01, CAPEC-178.

**CWE-502 Deserialization of Untrusted Data** — native deserialization of
external input enabling gadget chains. *Detect:* `pickle.loads`,
`ObjectInputStream.readObject`, PHP `unserialize`, Ruby `Marshal.load`,
`yaml.load` without SafeLoader, Java `XMLDecoder`, .NET `BinaryFormatter`.
*X-refs:* A08, CAPEC-586, SANS #15, ASVS V5.5.

**CWE-611 XXE** — XML parser resolves external entities in untrusted XML.
*Detect:* DocumentBuilder/SAX/lxml/libxml with default or explicitly enabled
DTD/external entities. *X-refs:* A05, CAPEC-221, ASVS V5.5.2.

**CWE-22 Path Traversal** — file path from user input escapes intended
directory. *Detect:* `open(base + userInput)`; filename params with no
canonicalize+prefix check; `../` filtering done by naive replace. *X-refs:*
A01, CAPEC-126, SANS #8, ASVS V12.3.

**CWE-434 Unrestricted Upload of Dangerous File Type** — upload endpoints
accepting executable/served types. *Detect:* extension/content-type checks
missing or client-side only; uploads stored under web root with original
names. *X-refs:* A04, CAPEC-1, SANS #10, ASVS V12.2. (Also listed in
cwe-authz.md file-upload routing.)

**CWE-74 Injection (parent)** / **CWE-20 Improper Input Validation (parent)**
— use only when no specific child fits; prefer CWE-20 for pure
missing-validation findings with no identified sink. *X-refs:* A03, SANS #6
(CWE-20).

**CWE-117 Log Injection** — unneutralized user input written to logs (CRLF
forging). *Detect:* logger calls concatenating raw request data. *X-refs:* A09.

**CWE-113 HTTP Response Splitting / CWE-93 CRLF Injection** — user input in
response headers. *Detect:* `setHeader(name, userInput)` without stripping
CR/LF. *X-refs:* A03.
