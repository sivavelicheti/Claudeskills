# <Project name>

<!-- Copy into <repo>/CLAUDE.md and fill in. The junior-dev-framework commands read
     these values; keep them accurate or the quality gate will guess. -->

## Commands
- Build: `<e.g. mvn -q compile | npm run build>`
- Test (full suite): `<e.g. mvn test | npm test | pytest>`
- Coverage: `<e.g. mvn verify (JaCoCo) | pytest --cov --cov-branch | npm run test:coverage>`
- Format (check / write): `<e.g. mvn spotless:check / spotless:apply | prettier --check . / --write .>`
- Lint: `<e.g. npm run lint | ruff check>`

## Conventions
- Default branch: `main`
- Branch naming: `feature/<JIRA-ID>-<slug>` / `bugfix/<JIRA-ID>-<slug>`
- Commit messages: `<JIRA-ID>: <imperative summary>`
- Test layout: `<e.g. src/test mirrors src/main | tests/ mirrors package layout>`

## Workflow
This repo uses the junior-dev-framework plugin. All ticket work goes through:
`/spec` -> `/start` -> `/plan` -> `/implement` -> `/quality-gate` -> `/ship` -> `/mr-loop`.
Specs live in `specs/` and are the contract; approved specs are locked.

## Project notes
<!-- Architecture pointers, gotchas, directories that must not be touched, etc. -->
