# prek guidelines

Rules for the published hook manifest `.pre-commit-hooks.yaml` and this repo's own `prek.toml`.

## Manifest

- `.pre-commit-hooks.yaml` sits at the repo root; prek has no other manifest location or format.
- A hook wraps a shared mise task by default: `language: system`, `entry: mise run <task>`. The task stays the single source of command and tool version (see [mise guidelines](mise-guidelines.md)).
- Another prek `language` (`python`, `rust`, `script`, ...) is allowed when it brings real value, such as an isolated environment. The hook's `description` then states why.
- Hook `id` equals its task name with `:` replaced by `-` (`taplo:lint` → `taplo-lint`).
- Every hook has a `description` naming the task it runs.
- Whole-repo checks set `pass_filenames: false`; file-based hooks narrow input with `types` or `files`.
- Hooks using prek-only fields (`shell`, `env`, glob `files`) set `minimum_prek_version`.

## This repo's `prek.toml`

Every manifest hook is mirrored as a `repo = "local"` hook with the same `id` and `entry`, so this repo runs its own hooks. Project-specific fields (`priority`, `stages`) live only there.

## Consumers

Consumers reference the repo in their `prek.toml` with `rev` set to the same tag as the mise include `ref`, and must also include the tasks the hooks call.

## Testing

Run the manifest as a consumer would; prek clones the repo, so stage the manifest first:

```sh
git add .pre-commit-hooks.yaml && prek try-repo . --all-files
```
