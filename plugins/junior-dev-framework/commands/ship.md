---
description: "Step 8: Push the branch to origin (guarded by the quality-gate hook) and open/refresh the GitLab MR"
argument-hint: "<JIRA-ID e.g. PROJ-123>"
allowed-tools: ["Bash", "Read"]
---

# /ship — push to origin and raise the MR

Jira ticket: **$1**

1. Preconditions: clean tree, branch contains `$1`,
   `.claude-workflow/quality-gate-passed` contains the current HEAD sha
   (otherwise run `/quality-gate $1` first — the push hook will block you anyway).
   Consult `superpowers:finishing-a-development-branch` for the pre-handoff checklist
   (final full-suite run, no leftover debug artifacts, plan tasks all ticked) — but its
   merge/cleanup options do NOT apply here: this workflow always ends in a GitLab MR,
   never a local merge.
2. Push: `git push -u origin <branch>`. On network failure retry up to 4 times with
   exponential backoff (2s, 4s, 8s, 16s). Never `--force` — if the remote rejects the
   push, show the developer why.
3. If no MR exists yet for this branch, create one via the GitLab MCP (or print the
   `glab mr create` command if the MCP is unavailable):
   - Title: `$1: <ticket summary>`  (Jira ID first — links the MR to the ticket)
   - Description: what/why from `specs/$1.md`, the traceability matrix from
     `specs/$1.plan.md`, test + coverage summary from the quality gate, and
     `Closes $1` / the Jira link.
   - Target: the default branch. Mark as draft if the plan has unticked tasks.
4. Tell the developer the MR URL and the next step: `/mr-loop $1` once the pipeline
   has had a chance to run.
