# shell guidelines

Rules for every shell script in this repo. Scripts run as mise file tasks also follow [mise guidelines](mise.md#file-tasks).

## File and header

- Scripts start with `#!/usr/bin/env bash`, then `set -euo pipefail`.
- Gate bash 5.1+ at the top of every standalone script, right after `set -euo pipefail`:
  ```bash
  if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 1))); then
    echo "error: bash 5.1+ required (found ${BASH_VERSION:-unknown})" >&2
    exit 1
  fi
  ```
- The guard itself must parse under bash 3.2 and use plain `echo`, not `die`/gum (they are not set up yet).

## Portability

- Every script must run unchanged on modern macOS and modern Linux (including WSL2).
- Standalone scripts (`*.sh`) require bash 5.1+ and gate it (see File and header). They may use modern syntax (see Style).
- Avoid GNU-only and BSD-only flags: no `sort -V`, `date -d`/`date -j`, `stat -c`/`stat -f`, `find -printf`, `sed -r`, or `grep -P`. Use `sed -E`, which both support.
- Sort versions portably or git's own `--sort=-v:refname` for tag lists.
- Prefer mise-pinned tools (`git`, `gum`) where coreutils flags differ by OS.

## Errors

- Print errors to stderr and exit non-zero through one `die` helper.
- Error messages say how to recover, such as the flag that overrides a check or the `--help` command.

## Interactive output

- Use gum to make interactive scripts visually appealing: `gum choose`, `gum input`, `gum confirm` for prompts, `gum style` for messages. Follow the [gum guidelines](gum.md).
- Non-interactive scripts do not need gum.

## Lint and format

- `shellcheck` and `shfmt -d` must pass: run `mise run shell:validate`.
- prek runs `shellcheck-lint`, `shfmt-lint`, and `shfmt-fmt` on shell files; see [prek guidelines](prek.md).
- Suppress a shellcheck warning only with `# shellcheck disable=CODE # reason`.

## Style

- Quote every variable expansion. Use `[[ ]]` for tests.
- Use modern bash syntax: `[[ ]]` (not `[ ]`/`test`), `(( ))`/`$(( ))` (not `expr`/`let`/`$[]`), `$()` (not backticks), `printf` (not `echo -e`), `command -v` (not `which`).
- Prefer `[[ -z "${var:-}" ]]`, `[[ str == pat* ]]`, and `[[ str =~ re ]]`; quote variable expansions.
- Use `read -r`; use `IFS= read -r -d ''` for NUL-delimited loops. Never parse `ls`; use globs or `find ... -print0`.
- Enable `shopt -s nullglob` where a glob may match nothing.
- Standalone scripts target bash 5.1: assoc arrays, `mapfile`/`readarray`, namerefs (`declare -n`), `[[ -v ]]`, `${var^^}`, and `wait -n` are all allowed. `shellcheck` and `shfmt -d` must still pass.
- Inline `run` bodies in `*.tasks.toml` stay conservative (3.2-compatible): no assoc arrays, `mapfile`, or namerefs.
- Comment only code that needs clarification.
