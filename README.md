<div align="center">

[![mise](https://img.shields.io/badge/mise-enabled-purple)](https://mise.jdx.dev/)
[![prek](https://raw.githubusercontent.com/j178/prek/main/docs/assets/badge.svg)](https://github.com/j178/prek)
[![License](https://img.shields.io/github/license/copier-templates/shared-dev-tooling)](LICENSE)

# Shared Dev Tooling

</div>

[mise](https://mise.jdx.dev/) tasks and [prek](https://prek.j178.dev) hooks shared across projects. mise installs every tool. prek hooks are thin wrappers that call the mise tasks (`mise run <task>`), so hooks, CI, and manual runs behave the same. Tasks and hooks are released together under one semver tag.

## Scope

This repo ships workflows only: task and hook definitions. It never ships project configuration (`prek.toml`, `.taplo.toml`, `cliff.toml`, linter configs) or tool versions. Each consumer owns those. This repo's own config files serve only as a reference.

## Layout

```text
.pre-commit-hooks.yaml               # prek hook manifest
tasks/<category>/<tool>.tasks.toml   # shared mise tasks, named <tool>:<verb> (except tasks/core/gates.tasks.toml, which defines the gate:* entry points, each aliased to its bare name)
tasks/<category>/<name>.sh           # shared file tasks, e.g. release:cut
docs/guidelines/                     # contributor guidelines (also rendered to the docs site)
tasks/docs/starlight.tasks.toml      # shared docs site tasks (docs:*), powered by Astro/Starlight
astro.config.mjs                     # Starlight site config (repo-only)
src/content.config.ts                # docs collection schema (repo-only)
src/styles/                          # site themes: dark + light, extensible (repo-only)
scripts/docs-sync.sh                 # syncs docs/ + root Markdown into src/content/docs/ (consumers provide their own)
mise.toml                            # toolchain + task includes (no local tasks)
```

## Docs

This repo hosts its own docs as a static Starlight site from `docs/`, plus `README.md`, `AGENTS.md`, `GLOSSARY.md`, and `CHANGELOG.md`. See [starlight guidelines](docs/guidelines/starlight.md) for the full rules.

```sh
mise run bun:install # one-time install from bun.lock
mise run docs:dev     # local preview with hot reload
mise run docs:check   # astro check
mise run docs:build   # static dist/ + Pagefind index
mise run docs:preview # preview the production build
```

Dark and light themes ship via the `starlight-theme-rose-pine` plugin, with local tweaks in `src/styles/custom.css`. Switch with the one-click sun/moon button. Add more with `src/styles/themes/<name>.css` (see the starlight guideline). The site deploys to GitHub Pages from `.github/workflows/docs.yml` on every `main` push. Enable once with `mise run docs:pages:enable`.

## Usage

A consumer wires up three things, all pinned to the same release tag:

1. The mise include, so the tasks exist. Every hook runs `mise run <task>`.
2. The tools those tasks call, pinned in `[tools]`.
3. This repo in `prek.toml` with a `rev`. Prek reads hook definitions (`entry`, `language`, `files`) from `.pre-commit-hooks.yaml` at that tag, so the consumer lists hooks by `id` only.

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

- Include granularity: `//tasks` (everything), `//tasks/<category>` (one category), or `//tasks/<category>/<tool>.tasks.toml` (one tool; the `.toml` extension is required). Globs only work for local paths.
- Shared tasks do not declare tool versions. If a task fails with `command not found`, add the tool with `mise use <tool>@<version>`. Upgrade all tools at once with `mise run mise:update` (within ranges) or `mise upgrade --bump` (raises ranges).
- Without `?ref=` the default branch is used from cache. Run `mise run mise:cache:clear` to refetch the branch (wipes the entire mise cache, not just the git include).
- To override a shared task, list a local directory after the remote entry.
- Hooks can be tuned per consumer (`args`, `files`, `exclude`, `priority`, `stages`) next to their `id` without copying the definition.
- Bump the hook `rev` with `prek update` (respects `[update] cooldown_days`) and move the mise `ref` to the same tag.

## Task tags

Every task has at least one tag, except grouping tasks that only `depends` on other tagged tasks (e.g. `shell:validate`, `gate:lint`). Gates: `gate:lint`, `gate:fmt`, `gate:fix` (includes `gate:fmt`), `gate:test`, `gate:audit`, `gate:setup`, `gate:clean` (run every task with the matching tag), plus `gate:ci` entry point (runs `gate:lint` + `gate:test`, not a tag). Bare `lint`/`fmt`/`fix`/`test`/`audit`/`setup`/`clean`/`ci` remain as aliases. Lifecycle: `build`, `dev`, `clean`, `deps`, `info`, `docs`, `changelog`, `hooks`, `release` (`maintenance` is split into `build`/`dev`/`clean`/`deps`/`info`).

List all tags (sorted, unique):

```sh
mise run mise:tags
```

List tasks with a tag:

```sh
mise tasks ls --tag lint
```

Run every task with a tag (e.g. all checks, all formatters):

```sh
mise run --tag lint
mise run --tag fmt
mise run --tag test
```

Repeat `--tag` to accept any of several tags; dependencies run regardless of their tags:

```sh
mise run --tag lint --tag fmt
```

## Contributing

Follow the guidelines in [docs/guidelines/](docs/guidelines/): [mise](docs/guidelines/mise.md) for tasks, [prek](docs/guidelines/prek.md) for hooks, [shell](docs/guidelines/shell.md) for scripts, and [starlight](docs/guidelines/starlight.md) for the Starlight site.

## Releasing

Run `mise run release:cut` from `main` (add `-u` to release while `main` differs from `origin/main`). It picks a bump, regenerates [CHANGELOG.md](CHANGELOG.md), commits `chore(release): bump version <version>`, tags, and optionally pushes.

## Changelog

Release notes are in [CHANGELOG.md](CHANGELOG.md), generated by git-cliff from Conventional Commits.
