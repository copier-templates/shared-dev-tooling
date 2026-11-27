# prek guidelines

Rules for the published hook manifest `.pre-commit-hooks.yaml` and this repo's own `prek.toml`.

## Manifest

- `.pre-commit-hooks.yaml` sits at the repo root; prek has no other manifest location or format.
- A hook wraps a shared mise task by default: `language: system`, `entry: mise run <task>`. The task remains the single source for the command and the tool version (see [mise guidelines](mise.md)).
- Another prek `language` (`python`, `rust`, `script`, ...) is allowed when the task alone is not enough, such as an isolated environment. The hook's `description` then states why.
- Hook `id` equals its task name with `:` replaced by `-` (`taplo:lint` → `taplo-lint`).
- Every hook has a `description` naming the task it runs.
- Whole-repo checks set `pass_filenames: false`; file-based hooks narrow input with `types` or `files`.
- Hooks using prek-only fields (`shell`, `env`, glob `files`) set `minimum_prek_version`.

## This repo's `prek.toml`

Every manifest hook is mirrored as a `repo = "local"` hook with the same `id`, `entry`, `language` and filters, so this repo runs its own hooks. Project-specific fields (`priority`, `stages`) live only there.

> [!IMPORTANT]
> prek's only special `repo` values are `local`, `meta` and `builtin`. Any other `repo` is cloned at a fixed `rev`, so a repo cannot run its own working-tree manifest: pointing at the GitHub URL tests the last published tag, not the change under review. Change the manifest and its mirror together and verify the manifest with `prek try-repo` (below).

## Consumers

The manifest is the reuse mechanism. Consumers reference this repo in their `prek.toml` with `rev` set to the same tag as the mise include `ref` and list hooks by `id`. A hook works in a consumer only when the task it runs is included and the tool it calls is pinned in `[tools]`. See the README's Usage section.

## Testing

Run the manifest as a consumer would; prek clones the repo, so stage the manifest first:

```sh
git add .pre-commit-hooks.yaml && prek try-repo . --all-files
```
