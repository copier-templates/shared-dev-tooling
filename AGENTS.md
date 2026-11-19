# AGENTS.md

Shared mise tasks (`tasks/`) and prek hooks (`.pre-commit-hooks.yaml`) consumed by other repos via `git::` includes and prek `repos`. Hooks wrap tasks with `mise run <task>`; both ship under one semver tag.

## Rules

- Editing a task, a `mise.toml`, or adding a tool: follow [docs/mise-guidelines.md](docs/mise-guidelines.md).
- Editing `.pre-commit-hooks.yaml` or `prek.toml`: follow [docs/prek-guidelines.md](docs/prek-guidelines.md).

## Example commands

- `mise run prek:install`: set up git hooks.
- `mise run mise:tasks:validate`: validate task definitions.

Commits should always follow Conventional Commits.
