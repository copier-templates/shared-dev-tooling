# mise guidelines

Rules for every shared mise task in `tasks/` and every `mise.toml` (this repo's and consumers').

## Required `mise.toml` header

Every `mise.toml` pins `min_version` and sets these settings:

```toml
min_version = "2026.11.10"

[settings]
experimental = true          # required: git:: task includes are skipped without it
lockfile = true              # mise.lock pins exact versions and checksums
minimum_release_age = "7d"   # supply-chain cooldown for new tool releases
```

## Tool versions live in `[tools]`

Shared tasks never set the task-level `tools` property. The consumer's `[tools]` and `mise.lock` own every version.

Why: `mise outdated` and `mise upgrade --bump` only see `[tools]`, so versions declared on tasks drift silently. Keeping them in `[tools]` lets one command update everything: `mise run mise:bump` refreshes `mise.lock` within the declared ranges, `mise upgrade --bump` also raises the ranges in `[tools]`. When a task fails with `command not found` in a consumer, add the tool with `mise use <tool>@<version>`.

This repo's `[tools]` pins exactly the tools its own tasks and hooks call.

## File layout

```text
tasks/<category>/<tool>.tasks.toml   # e.g. tasks/toml/taplo.tasks.toml, tasks/py/ruff.tasks.toml
```

- One file per tool, grouped by category folder (`core`, `toml`, `release`, `py`, ...).
- Always use the `.tasks.toml` suffix. A bare `<tool>.toml` collides with config files tools auto-discover: mise ignores `mise.toml`, prek parses `prek.toml` as a hook config, ruff and uv read `ruff.toml` and `uv.toml`.
- Folders organise files only; they do not prefix task names.

## Task definitions

- Name tasks `<tool>:<verb>`, with further `:` segments for sub-verbs (`taplo:lint`, `mise:lock:check`).
- Every task has a `description` and at least one tag from: `lint`, `fmt`, `fix`, `test`, `setup`, `release`, `maintenance`. Tags let `mise run --tag lint` select checks across tools.
- Tasks that accept files take them as trailing arguments (`mise run taplo:lint a.toml b.toml` appends them to `run`), so prek hooks can pass filenames.
- Tasks define workflows only. Project configuration (`prek.toml`, `.taplo.toml`, `cliff.toml`, linter configs) belongs to the consumer.

## Consumer includes

Consumers list `git::` URLs in `task_config.includes`, pinned with `?ref=<tag>` to the same tag as the prek `rev`. An entry can be:

| Entry | Loads |
| --- | --- |
| `//tasks` | every task |
| `//tasks/py` | one category |
| `//tasks/py/ruff.tasks.toml` | one tool (the `.toml` extension is required) |

Globs work only for local paths. An unresolvable entry makes every mise command in the consumer fail, so check `mise tasks ls` after editing includes.

## File tasks

Scripts under `tasks/` that mise runs as file tasks (for example `tasks/release/cut.sh`). Shell rules: [shell guidelines](shell.md).

- Place scripts directly in `tasks/<category>/` and name each after its action: `tasks/release/cut.sh` is `release:cut`. The path sets the task name, so do not set `#MISE alias`.
- Put task metadata in `#MISE` lines right after the shebang: `description`, `tags` (see [task definitions](#task-definitions)), and `interactive=true` when the script prompts.
- Declare every option with `#USAGE flag` and give it a short and a long name: `#USAGE flag "-u --allow-unsynced" help="..."`.
- mise exports the long name as an environment variable with dashes replaced by underscores: `--allow-unsynced` is read as `usage_allow_unsynced`.
- Read that variable once at the top into a lowercase variable, with a default: `allow_unsynced=${usage_allow_unsynced:-false}`. Reference the lowercase variable everywhere else.
- Add `# shellcheck disable=SC2154` with a reason on that line, because shellcheck cannot see mise's variables.

## Validation

Every change passes `mise tasks validate` and `prek run --all-files`.
