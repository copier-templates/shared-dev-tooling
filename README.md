<div align="center">

[![mise](https://img.shields.io/badge/mise-enabled-purple)](https://mise.jdx.dev/)
[![prek](https://raw.githubusercontent.com/j178/prek/main/docs/assets/badge.svg)](https://github.com/j178/prek)
[![License](https://img.shields.io/github/license/copier-templates/mise-tasks)](LICENSE)

</div>

# Shared Mise Tasks

This repository contains shared tasks for the Mise task runner, which can be reused across different projects.

## Scope

Shared tasks define workflows only — commands, scripts, and tool dependencies.
They never ship project configuration (e.g. `prek.toml`, linter/formatter configs), because configuration varies per target project and tech stack. Each target project must maintain its own config files.

For example, `tasks/hooks-prek.toml` provides `hooks:*` workflows, but does not provide `prek.toml`. See this repo's `prek.toml` as a starter reference for your own project.

## Usage

Include shared tasks via `task_config.includes` with a `git::` URL. See [mise docs](https://mise.jdx.dev/tasks/task-discovery.html#remote-git-includes).

In your `mise.toml`:

```toml
[task_config]
includes = [
  "git::https://github.com/copier-templates/mise-tasks.git//tasks?ref=0.1.0",
]
```

Notes:

- `//tasks` loads all task files in `tasks/`; use `//tasks/<filename>.toml` to load a single file.
- Pin `?ref=<tag>` for reproducibility. Without it the default branch is used from cache — run `mise cache clear` or set `task.remote_no_cache` to refresh.
- To override a shared task, list a local directory after the remote entry.
