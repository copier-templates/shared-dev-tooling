# gum guidelines

Rules for using gum for interactive prompts and styled output. gum is pinned in `mise.toml`. Run `gum --help` or `gum <command> --help` for full flags.

## When to use

- Interactive scripts only: prompts and styled output. Non-interactive scripts do not need gum.
- `gum choose` to pick from a list, `gum input` for short input, `gum confirm` for yes/no questions, `gum style` for messages, `gum spin -- <command>` around slow commands instead of silent waits.
- Mark interactive file tasks `#MISE interactive=true` (see [mise guidelines](mise.md#file-tasks)). Never prompt from hooks or CI-run tasks: `choose`, `input`, and `confirm` wait for input and block without a TTY.

## Style

- Keep prompts short: one `--header` or prompt string, no banners.
- Keep the palette consistent: errors `196` (red), warnings `214` (orange), hints `244` (grey), frames `39` (blue).
- Route styled messages to stderr with `>&2`, the same as plain errors.
