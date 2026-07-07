---
description: "Step 2: Create the working branch from the Jira ID using the team naming convention"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
allowed-tools: ["Bash", "Read", "Grep"]
---

# /start — Create the branch for a Jira ticket

Jira ticket: **$1**

1. Verify the working tree is clean (`git status --porcelain`). If not, STOP and show
   the developer what is uncommitted — never stash or discard on their behalf.
2. Fetch the default branch: `git fetch origin <default-branch>`.
3. Derive a short kebab-case slug from the ticket summary in `specs/$1.md` (or from the
   Jira MCP if the spec does not exist yet).
4. Create the branch **from the up-to-date default branch**:
   `git checkout -b feature/$1-<slug> origin/<default-branch>`
   - Bugs use `bugfix/$1-<slug>`.
   - The Jira ID must appear verbatim in the branch name — GitLab/Jira integration and
     the push-guard hook both rely on it.
5. Confirm to the developer: branch name, base commit, and the next step (`/spec $1` if
   no approved spec exists yet, otherwise `/plan $1`).

Never create a branch from a stale local default branch, and never reuse a branch from
a merged MR — always restart from `origin/<default-branch>`.
