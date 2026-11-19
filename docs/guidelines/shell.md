# shell guidelines

Rules for every shell script in this repo. Scripts run as mise file tasks also follow [mise guidelines](mise.md#file-tasks).

## File and header

- Start with `#!/usr/bin/env bash`, then `set -euo pipefail`.
- Name the file after its action, for example `tasks/release/cut.sh` (`release:cut`).

## Errors

- Print errors to stderr and exit non-zero through one `die` helper.
- Error messages say how to recover, such as the flag that overrides a check or the `--help` command.

## Interactive output

- Use gum for prompts and styled output in interactive scripts: `gum choose`, `gum input`, `gum confirm` for prompts, `gum style` for messages. gum is pinned in `mise.toml`.
- Keep the palette consistent: errors `196` (red), warnings `214` (orange), hints `244` (grey), frames `39` (blue).
- Route styled messages to stderr with `>&2`, the same as plain errors.
- Non-interactive scripts do not need gum.

## Lint and format

- `shellcheck` and `shfmt -d` must pass: run `mise run shell:validate`.
- prek runs `shellcheck-lint`, `shfmt-lint`, and `shfmt-fmt` on shell files; see [prek guidelines](prek.md).
- Suppress a shellcheck warning only with `# shellcheck disable=CODE # reason`. Never suppress without a reason.

## Style

- Quote every variable expansion. Use `[[ ]]` for tests.
- Comment only code that needs clarification.
