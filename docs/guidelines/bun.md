# bun guidelines

Rules for Bun 1.4+ as runtime, package manager, and test runner. Tasks live in `tasks/bun/bun.tasks.toml`; run them with `mise run bun:<verb>`, never bare `bun` in hooks or CI.

## Toolchain

- Pin Bun in the consumer's `[tools]` (for example `bun = "1.4"`). Shared tasks never set task-level `tools`; `mise.lock` owns the exact version (see [mise guidelines](mise.md)).
- Require Bun 1.4+: Rust runtime, text `bun.lock`, `trustedDependencies` gate, `isolated` linker default for workspaces.
- Use `mise run bun:install`, `bun:test`, `bun:audit`, and so on. The task is the single source for flags.

## Project files

- `package.json` is the source of truth: `dependencies`, `scripts`, `workspaces`, `trustedDependencies`, `overrides`. `bun.lock` is the resolved snapshot. Commit both.
- Keep `bunfig.toml` minimal. Prefer defaults; set `[install]` keys only when the project needs them (`linker`, `minimumReleaseAge`, `minimumReleaseAgeExcludes`).
- Do not commit `node_modules/`, `dist/`, `build/`, or `coverage/`. `bun:clean` removes them.
- New workspaces default to `linker = "isolated"` (no phantom dependencies). Single-package projects default to `hoisted`. Do not mix linkers in one repo.
- All `bun:*` tasks except `bun:clean` skip when `package.json` is absent (this repo has one only for the docs site). `bun:clean` always runs. Consumers with JS/TS must have one.

## Install, update, audit

- Install with `bun:install` (`bun install --frozen-lockfile`). It installs exact locked versions and fails on `package.json` / `bun.lock` drift. Fix drift with `bun install`, then commit the updated `bun.lock`.
- Add or remove packages with `bun add` / `bun remove`, never by hand-editing `bun.lock`.
- Update within ranges with `bun:update` (`bun update`); inspect with `bun:outdated` before bumping ranges in `package.json`.
- Bun does not run dependency lifecycle scripts unless the package is listed in `trustedDependencies`. Keep that list explicit and minimal (for example `esbuild`, `sharp`).
- Audit with `bun:audit` (`bun audit`). For supply-chain cooldown set `minimumReleaseAge` in `bunfig.toml` (for example `3d`) with narrow `minimumReleaseAgeExcludes`.
- Prune dev-only installs for production images with `bun prune --production` after a `--frozen-lockfile` install.

## Scripts

- Run `package.json` scripts with `bun run <script>`. `bun run <script>` runs the script; `bun test` starts the test runner; `bunx <pkg>` runs a one-off package binary.
- Prefer `bun run --parallel --filter` over `concurrently` / `npm-run-all`. Prefix behavior and `pre` / `post` hooks are built in.
- Pass file or filter arguments as trailing args so tasks and hooks can forward them (`mise run bun:test ./pkg -t "pattern"`).

## Tests

- Name tests `*.test.ts` next to the code. Run all with `bun:test` (`bun test`).
- Filter with an explicit path (`bun test ./pkg/foo.test.ts`) or `-t "pattern"` (`--test-name-pattern`). Do not use Playwright/Mocha `--grep` flags.
- Use `describe` / `it` / `expect` and `mock from "bun:test"`. Do not use `jest.fn()` / `jest.mock()` shims in new code.
- For CI sharding use `bun test --shard`, for per-file isolation `--isolate`, for speed `--parallel`. Keep the default task invocation unflagged; add flags at the call site.

## Style and runtime

- Bun runs TypeScript natively. Prefer `node:` imports (`node:fs`, `node:path`), ESM `import` / `export`, and explicit file extensions where the bundler requires them.
- Prefer built-ins over extra tools: `bun build` for bundling, `bun test` for tests, `Bun.file` / `Bun.serve` where they replace a dependency. Add a dependency only when a built-in cannot do the job.
- Do not load `.env` implicitly in CI/production (`--no-env-file` or `env = false` in `bunfig.toml`); pass secrets via the environment.

## Validation

Every change passes `mise tasks validate` and `prek run --all-files`.
