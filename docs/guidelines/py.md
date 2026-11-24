# py guidelines

Rules for Python 3.15+ with uv as package manager. Tasks live in `tasks/py/*.tasks.toml`. Run them with `mise run <task>`, never bare `uv`/`pytest`/`ruff`/`ty` in hooks or CI.

## Toolchain

- Pin `uv` in the consumer's `[tools]` (for example `uv = "0.13"`). Shared tasks never set task-level `tools`; `mise.lock` owns the exact version (see [mise guidelines](mise.md)).
- Pin Python with `.python-version` (for example `3.15`). `requires-python` in `pyproject.toml` must agree.
- Run everything through `uv run --frozen`. It uses the locked `uv.lock` and fails on drift instead of resolving anew. The task is the single source for flags.

## Project files

- `pyproject.toml` is the source of truth: `[project]`, `[dependency-groups]`, `[tool.pytest.ini_options]`. `uv.lock` is the resolved snapshot. Commit both plus `.python-version`.
- Keep runtime `dependencies` and the `dev` group separate. `pytest`, `ruff`, and `ty` belong in `dev`, so consumers without Python keep resolving `uv run --frozen` after adding the group.
- Do not commit `.venv/`, `build/`, `dist/`, `.pytest_cache/`, `.ruff_cache/`, `htmlcov/`, `.coverage/`, `__pycache__/`, `*.egg-info/`, or `*.pyc`. `uv:clean` removes the build/cache artifacts; `uv:clean:venv` removes `.venv/`.
- This repo has no `pyproject.toml`, so every `py` task except `uv:clean`, `uv:clean:venv`, and `uv:cache:prune` skips when it is absent. Consumers with Python must have one.

## Install, update, audit

- Install with `uv:install` (`uv sync --locked --all-groups`). Update within ranges with `uv:update` (`uv sync --all-groups --upgrade`).
- Manage the lockfile with `uv:lock` (`uv lock`) and gate CI with `uv:lock:check` (`uv lock --check`) plus `uv:sync:check` (`uv sync --locked --check --all-groups`).
- Audit with `uv:audit` (`uv audit --locked --preview-features audit-command`). Inspect with `uv:tree`, prune the cache with `uv:cache:prune`.

## Lint, format, typecheck

- Lint with `ruff:lint` (`ruff check`, check-only). Autofix safe fixes with `ruff:fix` (`ruff check --fix`).
- Format in place with `ruff:fmt` (`ruff format`). Gate CI with `ruff:fmt:check` (`ruff format --check`), which never writes.
- Typecheck with `ty:check` (`ty check`, check-only). Autofix with `ty:fix` (`ty check --fix`).
- Pass files as trailing args so tasks and hooks can forward them (`mise run ruff:lint foo.py`). Keep the default task invocation unflagged. Add `--statistics`, `--output-format`, or `--error-on-warning` at the call site.

## Tests

- Layout is `tests/unit/` and `tests/integration/`, or flat `tests/` (`test:all`). `testpaths = ["tests"]` with `unit` / `integration` markers (see `pyproject.toml`).
- Run with `test:unit` / `test:integration` (nested) or `test:all` (flat). Each skips with exit 0 when `pyproject.toml` or its test directory is absent, so non-Python consumers stay green.
- Pass filters as trailing args (`mise run test:unit -- -k "pattern" -x --lf --tb=short -q`). Keep the default task invocation unflagged. Put `--collect-only`, `--junitxml`, `--durations`, and `-m` at the call site.

## Validation

Every change passes `mise tasks validate` and `prek run --all-files`.
