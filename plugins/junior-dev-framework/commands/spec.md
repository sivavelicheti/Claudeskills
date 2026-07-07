---
description: "Step 1+3: Pull a Jira ticket via the Jira MCP and turn it into a tight, testable spec (requires human approval before any code)"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
---

# /spec — Create a tight spec from Jira

Jira ticket: **$1**

You are creating the single source of truth for this piece of work. No code may be
written until this spec exists and a human has approved it.

## Steps

1. Fetch the ticket `$1` using the Atlassian/Jira MCP tools (issue summary, description,
   acceptance criteria, linked issues, comments, attachments). If the Jira MCP is not
   available, STOP and tell the developer to run `/mcp` and authenticate — do NOT invent
   ticket content.
2. **Requirements refinement — invoke the `superpowers:brainstorming` skill** and run it
   against the ticket content with the developer: one question at a time, explore edge
   cases, error paths and hidden assumptions until the requirements are unambiguous.
   (If superpowers is not installed, note that in your output and ask the clarifying
   questions yourself via AskUserQuestion — one at a time, never a wall of questions.)
3. Delegate spec drafting to the `spec-writer` subagent. Give it the raw ticket content,
   the answers from the brainstorming session, and the template at
   `${CLAUDE_PLUGIN_ROOT}/templates/spec-template.md`.
4. Write the result to `specs/$1.md` in the repository, with frontmatter
   `status: draft`.
5. Every requirement in the spec must be objectively testable — if you cannot state how
   a requirement would be verified by a test, it is not a requirement yet; take it back
   to step 2.
6. Print the spec summary and any remaining open questions, then STOP.

## Hard rules

- Do not write, edit or scaffold any production code in this command.
- Do not mark the spec `status: approved` yourself. Only the developer does that,
  after reading it. Tell them: change `status: draft` to `status: approved` in
  `specs/$1.md` and commit it. Once approved, the file is locked by a hook.
- Anything the ticket does not ask for goes in the **Out of scope** section.
