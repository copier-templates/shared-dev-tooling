# AGENTS.md

Shared mise tasks (`tasks/`) and prek hooks (`.pre-commit-hooks.yaml`) consumed by other repos via `git::` includes and prek `repos`. Hooks wrap tasks with `mise run <task>`; both ship under one semver tag.

## Rules

| When | Follow |
| --- | --- |
| Editing a task, a `mise.toml`, or adding a tool | [mise guidelines](docs/guidelines/mise.md) |
| Editing `.pre-commit-hooks.yaml` or `prek.toml` | [prek guidelines](docs/guidelines/prek.md) |
| Editing any shell script | [shell guidelines](docs/guidelines/shell.md). A file task also follows the [file tasks section](docs/guidelines/mise.md#file-tasks). |
| Writing interactive shell output | use gum, per [gum guidelines](docs/guidelines/gum.md) |
| Working with Bun, JS/TS, or editing `tasks/bun/*` | [bun guidelines](docs/guidelines/bun.md) |
| Working with Python or editing `tasks/py/*` | [py guidelines](docs/guidelines/py.md) |
| Editing the docs site (`astro.config.mjs`, `src/`, `scripts/docs-sync.sh`, `tasks/docs/*`) | [starlight guidelines](docs/guidelines/starlight.md) |

## Example commands

- `mise run prek:install`: set up git hooks.
- `mise run mise:tasks:validate`: validate task definitions.
- `mise run shell:validate`: lint and format-check shell scripts.
- `mise run docs:dev`: preview the docs site locally.
- `mise run docs:check`: type-check the docs site.
- `mise run docs:build`: build the static docs site.

Commits follow Conventional Commits.
