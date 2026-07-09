# Junior Dev Framework — User Guide

A step-by-step guide to shipping a Jira ticket with Claude Code using the
`junior-dev-framework` plugin. Written for your **first ticket** — after two or three
tickets this will be muscle memory.

**The short version:** you run 7 slash commands in order, and you personally approve
two documents (the spec and the plan). Everything else — tests, code, coverage,
pipeline fixes, Sonar cleanup — Claude does under a harness that physically blocks it
from skipping steps.

```
/spec ──▶ YOU approve ──▶ /start ──▶ /plan ──▶ YOU approve ──▶ /implement
      ──▶ /quality-gate ──▶ /ship ──▶ /mr-loop ──▶ reviewer runs /review ──▶ merge
```

---

## 1. One-time setup (15 minutes)

Do this once per machine.

### 1.1 Install the plugins

Open Claude Code in any terminal and run:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin marketplace add sivavelicheti/Claudeskills
/plugin install junior-dev-framework@claudeskills
```

> If your project repo already has `.claude/settings.json` committed (most do), both
> plugins install automatically the first time you open the repo and accept the
> prompt — you can skip this step.

Verify: type `/` and check that `/spec`, `/start`, `/plan`, `/implement`,
`/quality-gate`, `/ship`, `/mr-loop`, `/review` appear in the command list.

### 1.2 Connect the tools (MCP servers)

| Tool | What to do |
|---|---|
| **Jira** | Run `/mcp`, select `atlassian`, complete the browser OAuth login with your work Atlassian account. |
| **GitLab** | Create a Personal Access Token in GitLab (*Preferences -> Access tokens*, scope: `api`). Export it in your shell profile: `export GITLAB_TOKEN=glpat-...` and, for self-hosted GitLab, `export GITLAB_API_URL=https://gitlab.yourcompany.com/api/v4` |
| **Sonar** | Get a token from SonarQube (*My Account -> Security*). Export: `export SONARQUBE_TOKEN=...` and `export SONARQUBE_URL=https://sonar.yourcompany.com`. Requires Docker running locally. |

Verify: run `/mcp` — all three servers should show as connected.

### 1.3 Sanity check

Ask Claude: *"What stage of the workflow am I in?"* — the `sdlc-workflow` skill should
answer with the pipeline table. If it doesn't know what you mean, the plugin isn't
loaded; re-check 1.1.

---

## 2. Shipping a ticket — the golden path

Worked example: ticket **PROJ-142, "Rate-limit the password reset endpoint"**. Open
Claude Code in the project repo and follow along with your own ticket.

### Step 1 — `/spec PROJ-142` (create the spec)

Claude pulls the ticket from Jira and then **interviews you**, one question at a time:
"What should happen on the 6th attempt — 429, or silent drop? Is the limit per user or
per IP? Does the ticket owner expect a Retry-After header?"

Answer honestly; say "I don't know, ask the ticket owner" when you don't — those go
into the spec's *Open questions* section instead of becoming guesses.

Claude writes `specs/PROJ-142.md`: numbered requirements (R1, R2, ...), error cases,
non-functional requirements, and an explicit **Out of scope** list.

**YOUR JOB — approve the spec.** This is the most important 10 minutes of the ticket.
Read the file and check:

- [ ] Every requirement matches what the ticket actually asks for
- [ ] Every requirement is testable (concrete inputs, outputs, limits — no "should be robust")
- [ ] *Open questions* is empty (chase the answers first — Jira comments, ticket owner)
- [ ] *Out of scope* covers the things you're deliberately not doing

Then edit the file: change `status: draft` to `status: approved`, save, and tell
Claude to continue. **From this moment the spec is locked — Claude cannot edit it.**

> Why you, not Claude? Because the spec is the contract everything downstream is
> checked against. If it's wrong, everything after it is precisely, verifiably wrong.

### Step 2 — `/start PROJ-142` (create the branch)

Claude checks your tree is clean, fetches the latest default branch, and creates
`feature/PROJ-142-rate-limit-password-reset`. Nothing to review.

Working on two tickets at once? Say so — Claude will offer git worktrees so the
tickets get separate directories and can't contaminate each other.

### Step 3 — `/plan PROJ-142` (create the plan)

Claude explores the codebase and writes `specs/PROJ-142.plan.md`:

- a **traceability matrix** — every R-number mapped to the tests that will prove it
  and the tasks that will implement it,
- an ordered task list of small TDD increments,
- test strategy and regression risks.

**YOUR JOB — approve the plan.** Check:

- [ ] Every requirement appears in the matrix (no orphan requirements)
- [ ] Every task points back at a requirement (no freelance work)
- [ ] The files it plans to touch make sense to you (ask Claude "why file X?" if not)

Flip `status: draft` -> `status: approved`, save. The plan is now locked too.

### Step 4 — `/implement PROJ-142` (TDD implementation)

Claude orchestrates, but doesn't write code in your chat window. For each task it
dispatches two specialist subagents:

1. **test-engineer** writes a failing test for the requirement (and may not touch
   production code),
2. the orchestrator confirms the test fails *for the right reason*,
3. **tdd-implementer** writes the minimal code to pass (and may not touch tests),
4. full suite runs, then one commit per task: `PROJ-142: <task summary>`.

You'll get a one-paragraph progress note every few tasks. You can walk away — if the
plan turns out not to survive contact with the code, Claude stops and tells you
instead of improvising.

### Step 5 — `/quality-gate PROJ-142` (format, lint, tests, coverage)

Claude runs the project formatter, linter, the full test suite, and coverage — and
requires **100% line + branch coverage on every file changed on this branch**. Gaps
get closed with real tests, not exclusions. Every claim in the report is backed by
command output from this run — the framework forbids "it passed earlier".

On success it stamps the commit SHA into `.claude-workflow/quality-gate-passed`.
That stamp is what the push guard checks.

### Step 6 — `/ship PROJ-142` (push + MR)

Claude pushes the branch and opens the GitLab MR: Jira ID in the title, spec summary +
traceability matrix + coverage report in the description.

If it pushed without the gate, the hook would have blocked it — you'll never see a
half-done branch reach GitLab from this workflow.

### Step 7 — `/mr-loop PROJ-142` (pipeline, Duo, Sonar)

Run this after the pipeline has had a few minutes. Claude iterates (max 5 rounds):

- **Pipeline red?** Reproduces locally, root-causes, fixes. It will not delete a
  failing test or touch `.gitlab-ci.yml` to get green.
- **GitLab Duo / reviewer comments?** Verifies each claim against the code first —
  Duo is a bot and is sometimes wrong. Verified + in-spec fixes get applied;
  anything ambiguous or spec-conflicting comes back to you with a drafted reply.
- **Sonar issues?** Fixes bugs, vulnerabilities and code smells in the code. It never
  marks anything "won't fix" — that's a human decision. Security hotspot fixes are
  shown to you before commit.
- After every fix: quality gate re-runs, then push, then next round.

You get a final status table: pipeline / Duo comments / Sonar gate / coverage.

### Step 8 — review and merge (the reviewer's step)

Your **reviewer** opens the branch and runs `/review PROJ-142`. They get a
requirement-by-requirement verdict table (implemented / partial / missing /
contradicts spec) with file:line evidence, a scope-creep list, and test-adequacy
notes. The human reviewer — never Claude — clicks approve and merge.

---

## 3. When Claude gets BLOCKED (this is normal)

The hooks are guardrails, not errors. What each message means:

| Message starts with | It means | Do this |
|---|---|---|
| `BLOCKED: branch '...' contains no Jira ID` | Work started on a hand-made branch | `/start PROJ-142` and cherry-pick/move the work over |
| `BLOCKED: no spec found` | Spec step skipped | `/spec PROJ-142` |
| `BLOCKED: ... is not approved` | You haven't reviewed the spec yet | Read `specs/PROJ-142.md`, set `status: approved` |
| `BLOCKED: quality gate has not passed for HEAD` | New commits since the last gate | `/quality-gate PROJ-142` again |
| `BLOCKED: force-push is not allowed` | Something tried `git push -f` | Ask Claude to explain the remote conflict instead |
| `BLOCKED: pushing to a protected branch` | Push targeted main/master/develop | Push goes to your feature branch only |
| `BLOCKED: ... is an APPROVED spec and is locked` | Claude tried to edit an approved spec/plan | If the change is legitimate, YOU set `status: draft`, let Claude edit, then re-approve |

The last one matters most: **specs change by human decision, visibly — never silently
during implementation.** If halfway through you both realise requirement R3 is wrong,
that's fine and normal: unlock the spec, fix R3, re-approve, re-run `/plan` for the
affected part.

---

## 4. Rules Claude will not break (so don't ask)

- No code before an approved spec; no implementation before an approved plan.
- Never weaken, skip or delete a test to get to green.
- Never suppress a lint/Sonar rule or mark Sonar issues "won't fix".
- Never edit `.gitlab-ci.yml` to make a pipeline pass.
- Never force-push, never push to main, never merge, never approve an MR.
- Dependencies, coverage exclusions and spec changes all need your explicit OK.

If you genuinely need an exception, that's a conversation with your team lead, not a
prompt.

---

## 5. FAQ / Troubleshooting

**"Skill superpowers:... unavailable" in output** — the superpowers plugin isn't
installed. Run the two `/plugin` commands from §1.1. The workflow still functions on
inline fallback rules, but install it; that's where the TDD/debugging depth lives.

**Jira/GitLab/Sonar tool calls fail** — run `/mcp` and check connection status.
Jira: redo the OAuth login. GitLab/Sonar: your token env vars aren't set in this
shell (restart the terminal after editing your profile). Sonar also needs Docker up.

**"No coverage tool found" at the quality gate** — the repo's `CLAUDE.md` is missing
its Commands section. Tell your team lead; the template is at
`plugins/junior-dev-framework/templates/CLAUDE-md-template.md`.

**My MR merged, and now I have a follow-up ticket** — new ticket, new `/spec`, new
`/start`. Never stack commits on a branch whose MR already merged.

**Claude says the plan doesn't fit the code it found** — good, that's the framework
working. Re-run `/plan PROJ-142` (unlock it first if approved), re-approve, continue.

**Can I just ask Claude to "fix the bug real quick"?** — You can ask; the
`sdlc-workflow` skill will route you to `/spec`. For genuine non-ticket trivia
(a typo in a README), use your judgement — the hooks only bite at push time, and
your team's rules about ticketless changes still apply.

**Where does work stand right now?** — Ask *"what stage am I in?"* Claude derives it
from the files: no spec -> stage 1; spec draft -> awaiting your approval; plan has
unticked tasks -> implementing; stamp != HEAD -> needs quality gate; and so on.

---

## 6. Command reference

| Command | Stage | You approve? |
|---|---|---|
| `/spec PROJ-142` | Tight spec from Jira (steps 1+3) | **Yes — spec** |
| `/start PROJ-142` | Branch from Jira ID (step 2) | no |
| `/plan PROJ-142` | Implementation plan (steps 4+5) | **Yes — plan** |
| `/implement PROJ-142` | TDD via subagents (step 5) | no |
| `/quality-gate PROJ-142` | Format + lint + tests + 100% changed-line coverage (steps 6+7) | no |
| `/ship PROJ-142` | Push + create MR (step 8) | no |
| `/mr-loop PROJ-142` | Pipeline + Duo + Sonar loop (steps 9-11) | hotspots & ambiguous comments |
| `/review PROJ-142` | Reviewer's spec-compliance audit (step 12) | reviewer merges |
