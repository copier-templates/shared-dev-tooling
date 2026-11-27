# starlight guidelines

Rules for this repo's Starlight docs site. The site renders `docs/`, `README.md`, `AGENTS.md`, `GLOSSARY.md`, and `CHANGELOG.md` as static HTML on GitHub Pages.

## Source vs generated

- Author in `docs/` and the repo-root Markdown files. Never edit `src/content/docs/`; it is generated and gitignored.
- `scripts/docs-sync.sh` is the single source for the mapping: `README.md` → `index.md`, `AGENTS.md` → `agents.md`, `GLOSSARY.md` → `glossary.md`, `CHANGELOG.md` → `changelog.md`, `docs/404.md` → `404.md`, and `docs/guidelines/*.md` → `guidelines/*.md` (single level, non-recursive).
- The script injects frontmatter:
  - `title` from the first `#` line, which is stripped from the body (Starlight renders `title` as the page H1).
  - `description` from the first prose paragraph, stripped of inline Markdown and truncated to 160 characters. It feeds search results and social cards; keep the opening paragraph of each page self-contained.
  - `editUrl` pointing at the source file on `main`, because the generated file has no upstream history.
  - `lastUpdated` from the source file's last commit date.
- The homepage hero is the README block between `<!-- docs-site-hero:start -->` and `<!-- docs-site-hero:end -->` (logo, H1, tagline). The script strips it for the site and injects Starlight `hero` frontmatter (`hero_frontmatter`); keep the tagline in both places in sync. Badges sit outside the markers so they render on GitHub and on the site.
- Link rewriting targets Starlight's directory routes: `../../README.md` → the homepage, `docs/guidelines/` → `guidelines/`, root files to their site routes, and `.md` links to directory-style relative URLs per page depth (`sibling.md` → `../sibling/`, `guidelines/x.md` → `../guidelines/x/`).
- GitHub-style alerts are translated to Starlight asides: `> [!NOTE]` → `:::note`, `> [!TIP]` → `:::tip`, `> [!WARNING]`/`> [!CAUTION]` → `:::caution`, and `> [!IMPORTANT]` → `:::note[Important]`. Author alerts, never `:::` directives: GitHub styles alerts natively, while directives leak as literal text on GitHub.
- `mermaid` fenced blocks render client-side (see Diagrams). GitHub renders them natively; other images are not rewritten, so do not add image files to the generation pipeline without extending the script.
- Run `mise run docs:sync` directly or via `docs:dev` / `docs:check` / `docs:build` (they depend on it).

## Page files

- `docs/404.md` is the custom 404 page. It is built as `404.html` at the site root, not as a directory route, so its relative links are written from the site root (`./`, never `../`); the link checker resolves them there.
- Root Markdown files render at route depth 1 and `docs/guidelines/*` at depth 2. Link rewriting depends on that depth; adding a page at a new depth means extending the `rewrite_links` cases.

## Toolchain and tasks

- Pin `bun` in `mise.toml` `[tools]` (see [mise guidelines](mise.md)). `mise.lock` owns exact versions.
- Docs tasks are shared `docs:*` workflows in `tasks/docs/starlight.tasks.toml`, consumable via `git::` includes (`//tasks/docs` or the single file). The file is named for the implementation (Starlight); the `docs:*` names are the stable workflow interface.
- Run everything through `mise run docs:<verb>`, never bare `bunx astro` in hooks or CI. Tasks: `docs:sync` (runs the consumer's `scripts/docs-sync.sh`), `docs:dev`, `docs:check` (`astro check`), `docs:build` (static `dist/` + Pagefind), `docs:links` (fail on broken internal links in `dist/`, runs the consumer's `scripts/docs-check-links.sh`), `docs:preview`, `docs:clean`, `docs:pages:enable`, `docs:deploy`. Install dependencies with `bun:install`.
- Consumers adopting this group must provide their own docs site (`package.json`, `astro.config.mjs`, gitignored `src/content/docs/`) and their own `scripts/docs-sync.sh` mapping when they need generated content.
- `package.json` is the source of truth (`astro`, `@astrojs/starlight`, `sharp`, `typescript`, `@astrojs/check`, `mermaid`); `bun.lock` is the snapshot. Commit both.

## Theming

- Dark and light themes ship via the `starlight-theme-rose-pine` plugin (`astro.config.mjs`), with local tweaks in `src/styles/custom.css` (content width, badge rows, mermaid). Do not set `--sl-color-accent-*` in `custom.css` unlayered. It would override the plugin's `rose-pine` cascade layer.
- The homepage hero lives in frontmatter. Starlight centers it; do not add CSS that centers content headings or the README logo.
- The header switcher is a one-click sun/moon button, not Starlight's Dark/Light/Auto select. It is the `ThemeSelect` override in `src/components/ThemeToggle.astro`. It flips `document.documentElement.dataset.theme` and stores the explicit choice in the same `starlight-theme` localStorage key Starlight uses. It follows system changes until the first click.
- To add a theme: copy `src/styles/themes/_example.css` to `<name>.css` and set `:root[data-theme='<name>']` vars. Append to `customCss` in `astro.config.mjs`, then extend the toggle (or restore the select / use a community theme plugin) so the new theme is reachable.

## Diagrams

- `src/components/Mermaid.astro` is loaded globally through the `Head` override (`src/components/Head.astro`). It replaces each Expressive Code `mermaid` block with the rendered SVG, lazily imports the `mermaid` bundle only on pages that contain a diagram, and re-renders on `data-theme` changes.
- Build-time mermaid plugins are not used: they need a headless browser (Playwright) in CI. Keep diagrams small and let the client renderer handle them; the source stays visible if rendering fails.

## Deployment

- `astro.config.mjs` sets `site` + `base: '/shared-dev-tooling/'` for project Pages. `.github/workflows/docs.yml` builds with `mise run bun:install` / `docs:build` and deploys `dist/` via `deploy-pages`.
- Enable once with `mise run docs:pages:enable` (`gh`), deploy on every `main` push or manually with `mise run docs:deploy`.

## Validation

Every change passes `mise tasks validate`, `mise run docs:check`, `mise run docs:build`, and `prek run --all-files`.
