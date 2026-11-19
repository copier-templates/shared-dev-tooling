<div align="center">

[![mise](https://img.shields.io/badge/mise-enabled-purple)](https://mise.jdx.dev/)
[![prek](https://raw.githubusercontent.com/j178/prek/main/docs/assets/badge.svg)](https://github.com/j178/prek)
[![License](https://img.shields.io/github/license/copier-templates/shared-dev-tooling)](LICENSE)

</div>

# Shared Dev Tooling

Shared [mise](https://mise.jdx.dev/) tasks and [prek](https://prek.j178.dev) hooks, reusable across projects. mise installs every tool; prek hooks are thin wrappers that call the mise tasks (`mise run <task>`), so hooks, CI, and manual runs behave the same. Tasks and hooks are released together under one semver tag.

## Scope

This repo ships workflows only: task definitions and hook definitions. It never ships project configuration (`prek.toml`, `.taplo.toml`, `cliff.toml`, linter configs) or tool versions. Each consumer owns those. This repo's own config files are a reference.

## Layout

```text
.pre-commit-hooks.yaml               # prek hook manifest
tasks/<category>/<tool>-tasks.toml   # shared mise tasks, named <tool>:<verb>
docs/                                # contributor guidelines
```

## Usage

A consumer wires up three things, all pinned to the same release tag:

1. The mise include, so the tasks exist: every hook runs `mise run <task>`.
2. The tools those tasks call, pinned in `[tools]`.
3. This repo in `prek.toml` with a `rev`; prek reads hook definitions (`entry`, `language`, `files`) from `.pre-commit-hooks.yaml` at that tag, so the consumer lists hooks by `id` only.

In your `mise.toml`:

```toml
min_version = "2026.11.10"

[settings]
experimental = true # required for git:: task includes
lockfile = true
minimum_release_age = "7d"

[task_config]
includes = [
  "git::https://github.com/copier-templates/shared-dev-tooling.git//tasks?ref=<tag>",
]

[tools]
# pin every tool the included tasks call, e.g.
"cargo:taplo-cli" = "0.10"
```

In your `prek.toml`:

```toml
[[repos]]
repo = "https://github.com/copier-templates/shared-dev-tooling"
rev = "<tag>"
hooks = [
  { id = "mise-lock-check" },
  { id = "taplo-lint" },
]
```

Notes:

- Include granularity: `//tasks` (everything), `//tasks/<category>` (one category), or `//tasks/<category>/<tool>-tasks.toml` (one tool; the `.toml` extension is required). Globs only work for local paths.
- Shared tasks do not declare tool versions. If a task fails with `command not found`, add the tool with `mise use <tool>@<version>`. Upgrade all tools at once with `mise run mise:bump` (within ranges) or `mise upgrade --bump` (raises ranges).
- Without `?ref=` the default branch is used from cache. Run `mise run mise:cache:clear` to refetch it.
- To override a shared task, list a local directory after the remote entry.
- Hooks can be tuned per consumer (`args`, `files`, `exclude`, `priority`, `stages`) next to their `id` without copying the definition.
- Bump the hook `rev` with `prek update` (respects `[update] cooldown_days`) and move the mise `ref` to the same tag.

## Contributing

Follow [docs/mise-guidelines.md](docs/mise-guidelines.md) for tasks and [docs/prek-guidelines.md](docs/prek-guidelines.md) for hooks.
