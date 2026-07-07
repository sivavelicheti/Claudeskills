# junior-dev-framework

A Claude Code plugin that turns the team SDLC into a guided, **enforced** pipeline:

```
Jira ticket ──/spec──▶ approved spec ──/start──▶ branch ──/plan──▶ approved plan
   ──/implement──▶ TDD via subagents ──/quality-gate──▶ format+lint+100% coverage
   ──/ship──▶ push + GitLab MR ──/mr-loop──▶ pipeline+Duo+Sonar clean ──/review──▶ merge
```

## Why it works for first-time Claude Code users

- **One command per stage.** A junior developer never has to know how to prompt; they
  run `/spec PROJ-123`, `/start PROJ-123`, `/plan`, `/implement`, `/quality-gate`,
  `/ship`, `/mr-loop`. The reviewer runs `/review`.
- **Humans hold the pen at the two decision points.** Specs and plans are files in the
  repo with `status: draft|approved` frontmatter. Only a human flips them to
  `approved` — and from that moment a hook makes them read-only to Claude.
- **Hooks, not hope.** Prompts can be ignored; hooks cannot. The `git push` guard
  refuses to push unless the branch has a Jira ID, the spec is approved, and the
  quality-gate stamp matches the exact commit being pushed. Force-pushes and pushes
  to main are blocked outright.
- **Subagents keep context small.** `/implement` runs each TDD cycle in fresh
  `test-engineer` / `tdd-implementer` subagents that receive only the task at hand and
  report back paths + results — the orchestrating conversation never bloats with file
  contents, so quality doesn't degrade on long tickets.
- **Traceability end to end.** Requirements get IDs in the spec; the plan maps
  ID -> test -> task; tests reference IDs; `/review` verdicts every ID with
  file:line evidence. "Is this what the ticket asked for?" becomes a table, not a vibe.

## What's inside

| Piece | Files | Purpose |
|---|---|---|
| Commands | `commands/*.md` | One per pipeline stage (steps 1-12) |
| Agents | `agents/*.md` | `spec-writer`, `planner`, `test-engineer`, `tdd-implementer`, `spec-compliance-reviewer` |
| Skill | `skills/sdlc-workflow/` | Always-available map of the pipeline; routes "just write the code" requests back to the right stage |
| Hooks | `hooks/` | `git-push-guard.sh` (workflow gates at push), `spec-lock-guard.sh` (approved specs immutable to Claude) |
| Templates | `templates/` | Spec + plan templates with traceability built in |
| MCP servers | `.mcp.json` | Atlassian (Jira), GitLab, SonarQube |

## Companion plugin: superpowers (required)

This framework is designed to run on top of [obra/superpowers](https://github.com/obra/superpowers).
Division of labour:

- **superpowers = the HOW.** Process discipline as skills: `test-driven-development`
  (strict RED/GREEN/REFACTOR), `writing-plans`, `executing-plans`,
  `subagent-driven-development`, `systematic-debugging` (root-cause, no shotgun fixes),
  `verification-before-completion` (no claim without fresh evidence),
  `brainstorming`, `requesting-code-review` / `receiving-code-review`.
- **junior-dev-framework = the WHAT and the GATES.** The Jira->spec->plan->MR pipeline,
  the traceability requirements, the approval points, and the hooks that block pushes
  which skipped any of it.

Every stage command invokes the matching superpowers skill by name (see the table in
`skills/sdlc-workflow/SKILL.md`), and the `test-engineer` / `tdd-implementer` /
`planner` agents are required to load their skill as their first action. Commands
degrade gracefully with inline fallback rules if superpowers is missing, but install
it — that's where the process depth lives, and it's maintained upstream so the
discipline improves without us editing this plugin.

## Installation

Per developer:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin marketplace add sivavelicheti/Claudeskills
/plugin install junior-dev-framework@claudeskills
```

Per repository (recommended — zero-setup for every clone), commit
[`templates/project-settings-template.json`](templates/project-settings-template.json)
as `.claude/settings.json` — it registers both marketplaces and enables both plugins
for everyone who opens the repo.

Org-wide enforcement (developers cannot disable it): put the same two keys in the
**managed settings** file deployed by IT
(`/Library/Application Support/ClaudeCode/managed-settings.json` on macOS,
`/etc/claude-code/managed-settings.json` on Linux). Managed settings also let you
pin `permissions.deny` rules (e.g. `Bash(git push --force*)`) centrally.

### MCP credentials

- **Jira**: the bundled Atlassian remote MCP uses OAuth — each developer runs `/mcp`
  once and signs in.
- **GitLab**: set `GITLAB_API_URL` (self-hosted) and `GITLAB_TOKEN` (PAT with `api`
  scope). On GitLab 18.x+ you can instead point a `type: http` server at your
  instance's native MCP endpoint (`https://gitlab.example.com/api/v4/mcp`).
- **Sonar**: set `SONARQUBE_URL` + `SONARQUBE_TOKEN` (or use SonarCloud's hosted MCP).
  The bundled config runs SonarSource's official `mcp/sonarqube` Docker image.

## Repo prerequisites (each project that adopts the framework)

1. A `specs/` directory (created on first `/spec`).
2. `.claude-workflow/` in `.gitignore` (the gate stamp is local state, not code).
3. A `CLAUDE.md` that states: build command, test command, coverage command +
   threshold config, formatter/linter commands, default branch name. The quality gate
   reads these instead of guessing.
4. CI as the backstop: the GitLab pipeline must independently run the same
   format/lint/test/coverage checks, and Sonar runs on every MR. The plugin makes
   Claude converge fast; CI is the gate that doesn't run on the developer's machine.

## The trust model

Client-side hooks are a strong harness, not a security boundary — a developer who
edits files outside Claude Code bypasses them. That's fine: the framework's job is to
make the golden path the easy path. The *authoritative* gates stay server-side:

- GitLab protected branches + merge checks (pipeline must pass, discussions resolved)
- Coverage enforced in CI (e.g. JaCoCo/pytest-cov threshold, `coverage: /.../` regex)
- Sonar quality gate as a required MR check
- Human MR approval, assisted by `/review`
