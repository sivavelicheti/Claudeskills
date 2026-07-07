# Claudeskills

Internal **Claude Code plugin marketplace** — team standards, workflows and guardrails
packaged as installable plugins.

## Plugins

| Plugin | What it does |
|---|---|
| [`junior-dev-framework`](plugins/junior-dev-framework/) | Enforced SDLC pipeline for developers new to Claude Code: Jira -> tight spec -> plan -> TDD implementation via subagents -> quality gate (format, lint, 100% changed-line coverage) -> GitLab MR -> pipeline/Duo/Sonar remediation loop -> spec-compliance review. Hooks block pushes that skipped the gates. Builds on [obra/superpowers](https://github.com/obra/superpowers) for the process discipline (strict TDD, plan quality, systematic debugging, evidence-based verification). |

## Install

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin marketplace add sivavelicheti/Claudeskills
/plugin install junior-dev-framework@claudeskills
```

Or commit the plugin into a project for everyone via `.claude/settings.json` — see
[`plugins/junior-dev-framework/templates/project-settings-template.json`](plugins/junior-dev-framework/templates/project-settings-template.json).

## Workflow at a glance

| Step | Command | Who |
|---|---|---|
| 1+3. Tight spec from Jira (Jira MCP) | `/spec PROJ-123` | dev + Claude, human approves |
| 2. Branch from Jira ID | `/start PROJ-123` | Claude |
| 4+5. Plan traced to spec | `/plan PROJ-123` | Claude, human approves |
| 5. TDD implementation (subagents) | `/implement PROJ-123` | Claude |
| 6+7. Formatting + 100% coverage gate | `/quality-gate PROJ-123` | Claude |
| 8. Push + MR | `/ship PROJ-123` | Claude (push hook enforces gates) |
| 9-11. Pipeline, GitLab Duo, Sonar loop | `/mr-loop PROJ-123` | Claude |
| 12. Spec-compliance review | `/review PROJ-123` | reviewer + Claude |

## Repository layout

```
.claude-plugin/marketplace.json      # marketplace manifest
plugins/
  junior-dev-framework/
    .claude-plugin/plugin.json       # plugin manifest
    commands/                        # /spec /start /plan /implement /quality-gate /ship /mr-loop /review
    agents/                          # spec-writer, planner, test-engineer, tdd-implementer, spec-compliance-reviewer
    skills/sdlc-workflow/            # always-on pipeline map + non-negotiables
    hooks/                           # push guard + approved-spec lock
    templates/                       # spec, plan, CLAUDE.md, project settings
    .mcp.json                        # Jira (Atlassian), GitLab, SonarQube MCP servers
```

## Contributing a new plugin

1. Branch, add `plugins/<name>/` with a `.claude-plugin/plugin.json`.
2. Register it in `.claude-plugin/marketplace.json`.
3. Test locally: `/plugin marketplace add ./` from your checkout.
4. Open an MR/PR; another maintainer reviews before merge.
