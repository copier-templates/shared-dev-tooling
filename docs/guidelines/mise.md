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

Why this matters: `mise outdated` and `mise upgrade --bump` only see `[tools]`, so versions declared on tasks drift silently. Keeping them in `[tools]` lets one command update everything. `mise run mise:bump` refreshes `mise.lock` within the declared ranges; `mise upgrade --bump` also raises the ranges in `[tools]`. When a task fails with `command not found` in a consumer, add the tool with `mise use <tool>@<version>`.

This repo's `[tools]` pins exactly the tools its own tasks and hooks call.

## File layout

```text
tasks/<category>/<tool>.tasks.toml   # e.g. tasks/toml/taplo.tasks.toml, tasks/py/ruff.tasks.toml
```

- One file per tool, grouped by category folder (`core`, `toml`, `release`, `py`, ...). Exception: `tasks/core/gates.tasks.toml` defines the `gate:lint`/`gate:fmt`/`gate:fix`/`gate:test`/`gate:audit`/`gate:setup`/`gate:ci` gates (aliased as bare `lint`/`fmt`/`fix`/`test`/`audit`/`setup`/`ci` for back-compat), not a tool.
- Always use the `.tasks.toml` suffix. A bare `<tool>.toml` collides with config files that tools auto-discover: mise ignores `mise.toml`, prek parses `prek.toml` as a hook config, and ruff and uv read `ruff.toml` and `uv.toml`.
- Folders organise files only; they do not prefix task names.

## Task definitions

- Name tasks `<tool>:<verb>`, with further `:` segments for sub-verbs (`taplo:lint`, `mise:lock:check`). Exception: tag-gate entry points use the `gate:` prefix (`gate:lint`, `gate:ci`) so they sort and group together in `mise tasks ls`.
- Every task file starts with `#:schema https://mise.jdx.dev/schema/mise-task.json` for IDE completion. Schema validation is enforced by `mise tasks validate` (strict unknown-field rejection), not `taplo lint` — taplo 0.10 cannot enforce this schema's `unevaluatedProperties`, and `.taplo.toml` excludes task files anyway.
- Every task has a `description` and at least one tag. Gate tasks (`gate:lint`, `gate:fmt`, `gate:fix`, `gate:test`, `gate:audit`, `gate:setup`) carry no tags themselves — they `depends` on the matching tag — and keep a bare-name `alias` so `mise run lint` still works. Lifecycle tags are `build`, `dev`, `clean`, `deps`, `info`, `ops`, `docs`, `changelog`, `check`, `hooks`, `release`. See [Task tags](../../README.md#task-tags) for listing and running by tag. Grouping tasks that only `depends` on other tagged tasks (e.g. `shell:validate`, `ruff:validate`) omit tags so `--tag` runs don't duplicate.
  - `lint`: static checks only (no network, no env-sync). Audits go to `audit`, hook runners to `hooks`, env-sync to `setup`+`check`.
  - `setup`: one-time local env setup only. Dev servers go to `dev`, remote mutations to `ops`.
  - No `maintenance`: use `build`, `dev`, `clean`, `deps`, `info`.
- Prefer `skip_if` over `if [ ! -f ... ]` shell boilerplate (evaluates before confirm/lock, reports as skipped).
- Tasks that wrap a tool with its own args set `raw_args = true` and use a single-line `run` so `-t/--help`/paths forward cleanly.
- Tasks that accept files take them as trailing arguments (`mise run taplo:lint a.toml b.toml` appends them to `run`), so prek hooks can pass filenames.
- Add `sources` for `--affected` support; mutually-mutating file writers share `lock` (e.g. `py-write`, `uv`); order-only edges use `wait_for`, required edges use `depends` (with `{ task = ..., optional = true }` when the dep may not be included).
- Tasks define workflows only. Project configuration (`prek.toml`, `.taplo.toml`, `cliff.toml`, linter configs) belongs to the consumer.

## Consumer includes

Consumers list `git::` URLs in `task_config.includes`, pinned with `?ref=<tag>` to match the prek `rev`. An entry can be:

| Entry | Loads |
| --- | --- |
| `//tasks` | every task |
| `//tasks/py` | one category |
| `//tasks/py/ruff.tasks.toml` | one tool (the `.toml` extension is required) |

Globs work only for local paths. An unresolvable entry makes every mise command in the consumer fail. Check `mise tasks ls` after editing includes.

## File tasks

Scripts under `tasks/` that mise runs as file tasks (for example `tasks/release/cut.sh`) follow the [shell guidelines](shell.md).

- Place scripts directly in `tasks/<category>/` and name each after its action: `tasks/release/cut.sh` is `release:cut`. The path sets the task name, so do not set `#MISE alias`.
- Put task metadata in `#MISE` lines right after the shebang: `description`, `tags` (see [task definitions](#task-definitions)), and `interactive=true` when the script prompts.
- Declare every option with `#USAGE flag` and give it a short and a long name: `#USAGE flag "-u --allow-unsynced" help="..."`.
- mise exports the long name as an environment variable with dashes replaced by underscores: `--allow-unsynced` is read as `usage_allow_unsynced`.
- Read that variable once at the top into a lowercase variable, with a default: `allow_unsynced=${usage_allow_unsynced:-false}`. Reference the lowercase variable everywhere else.
- Add `# shellcheck disable=SC2154` with a reason on that line, because shellcheck cannot see mise's variables.

## Validation

Every change passes `mise tasks validate` and `prek run --all-files`.
