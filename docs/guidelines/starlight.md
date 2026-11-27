# starlight guidelines

Rules for this repo's Starlight docs site. The site renders `docs/`, `README.md`, `AGENTS.md`, `GLOSSARY.md`, and `CHANGELOG.md` as static HTML on GitHub Pages.

## Source vs generated

- Author in `docs/` and the repo-root Markdown files. Never edit `src/content/docs/`; it is generated and gitignored.
- `scripts/docs-sync.sh` is the single source for the mapping: `README.md` → `index.md`, `AGENTS.md` → `agents.md`, `GLOSSARY.md` → `glossary.md`, `CHANGELOG.md` → `changelog.md`, `docs/guidelines/*.md` → `guidelines/*.md` (single level, non-recursive). It injects `title`/`description` frontmatter (first `#` line becomes `title` and is stripped from the body, since Starlight already renders `title` as the page H1) and rewrites `../../README.md` → `../..`, `docs/guidelines/` → `guidelines/`, `CHANGELOG.md` → `changelog.md`, `GLOSSARY.md` → `glossary.md`, `AGENTS.md` → `agents.md`, `LICENSE` → GitHub URL, and the README `<picture>` logo block into Astro-bundled Markdown images. It also normalizes `.md` links to directory-style relative URLs per page depth (`sibling.md` → `../sibling/`, `guidelines/x.md` → `../guidelines/x/`), because Starlight serves directory routes and passes `.md` hrefs through unresolved.
- Run `mise run docs:sync` directly or via `docs:dev` / `docs:check` / `docs:build` (they depend on it).

## Toolchain and tasks

- Pin `bun` in `mise.toml` `[tools]` (see [mise guidelines](mise.md)). `mise.lock` owns exact versions.
- Docs tasks are shared `docs:*` workflows in `tasks/docs/starlight.tasks.toml`, consumable via `git::` includes (`//tasks/docs` or the single file). The file is named for the implementation (Starlight); the `docs:*` names are the stable workflow interface.
- Run everything through `mise run docs:<verb>`, never bare `bunx astro` in hooks or CI. Tasks: `docs:sync` (runs the consumer's `scripts/docs-sync.sh`), `docs:dev`, `docs:check` (`astro check`), `docs:build` (static `dist/` + Pagefind), `docs:links` (fail on broken internal links in `dist/`, runs the consumer's `scripts/docs-check-links.sh`), `docs:preview`, `docs:clean`, `docs:pages:enable`, `docs:deploy`. Install dependencies with `bun:install`.
- Consumers adopting this group must provide their own docs site (`package.json`, `astro.config.mjs`, gitignored `src/content/docs/`) and their own `scripts/docs-sync.sh` mapping when they need generated content.
- `package.json` is the source of truth (`astro`, `@astrojs/starlight`, `sharp`, `typescript`, `@astrojs/check`); `bun.lock` is the snapshot. Commit both.

## Theming

- Dark and light themes ship via the `starlight-theme-rose-pine` plugin (`astro.config.mjs`), with local tweaks in `src/styles/custom.css` (content width, badge layout). Do not set `--sl-color-accent-*` in `custom.css` unlayered — it would override the plugin's `rose-pine` cascade layer.
- The header switcher is a one-click sun/moon button, not Starlight's Dark/Light/Auto select. It is the `ThemeSelect` override in `src/components/ThemeToggle.astro`. It flips `document.documentElement.dataset.theme` and stores the explicit choice in the same `starlight-theme` localStorage key Starlight uses. It follows system changes until the first click.
- To add a theme: copy `src/styles/themes/_example.css` to `<name>.css` and set `:root[data-theme='<name>']` vars. Append to `customCss` in `astro.config.mjs`, then extend the toggle (or restore the select / use a community theme plugin) so the new theme is reachable.

## Deployment

- `astro.config.mjs` sets `site` + `base: '/shared-dev-tooling/'` for project Pages. `.github/workflows/docs.yml` builds with `mise run bun:install` / `docs:build` and deploys `dist/` via `deploy-pages`.
- Enable once with `mise run docs:pages:enable` (`gh`), deploy on every `main` push or manually with `mise run docs:deploy`.

## Validation

Every change passes `mise tasks validate`, `mise run docs:check`, `mise run docs:build`, and `prek run --all-files`.
