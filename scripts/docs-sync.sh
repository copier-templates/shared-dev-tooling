#!/usr/bin/env bash
set -euo pipefail

if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 1))); then
  echo "error: bash 5.1+ required (found ${BASH_VERSION:-unknown})" >&2
  exit 1
fi

die() {
  echo "error: $*" >&2
  echo 'run "mise run docs:sync" to rebuild the generated content' >&2
  exit 1
}

OUT="src/content/docs"
SRC_DOCS="docs"

[[ -d "${SRC_DOCS}" ]] || die "missing ${SRC_DOCS}/ directory"
[[ -f "README.md" ]] || die "missing README.md"

rm -rf "${OUT}"
mkdir -p "${OUT}/guidelines"

# $1: route depth of the page (0 = site root index, 1 = agents/glossary/
# changelog, 2 = guidelines/*). Starlight serves directory-style routes, so a
# same-directory `sibling.md` link is `./sibling/` at the root but
# `../sibling/` one level down; docs-root-relative targets need one `../`
# per route level.
rewrite_links() {
  local depth="${1:-0}"
  local up sib
  case "${depth}" in
  0)
    up="./"
    sib="./"
    ;;
  1)
    up="../"
    sib="../"
    ;;
  *)
    up="../../"
    sib="../"
    ;;
  esac
  if ((depth == 0)); then
    # Homepage only: the source links the docs/guidelines/ directory (repo
    # tree on GitHub). The site has no directory pages, so point at the
    # Contributing section, which enumerates every guideline with links.
    sed -E -e 's|]\( *docs/guidelines/\)|](./#contributing)|g'
  else
    cat
  fi | sed -E \
    -e 's|\(docs/guidelines/|\(guidelines/|g' \
    -e 's|\(CHANGELOG\.md|\(changelog.md|g' \
    -e 's|\(GLOSSARY\.md|\(glossary.md|g' \
    -e 's|\(AGENTS\.md|\(agents.md|g' \
    -e 's|]\(LICENSE\)|](https://github.com/copier-templates/shared-dev-tooling/blob/main/LICENSE)|g' \
    -e '/^[[:space:]]*<\/?picture>[[:space:]]*$/d' \
    -e '/^[[:space:]]*<img[^>]*src="assets\/logo-[^"]+"[^>]*>[[:space:]]*$/d' \
    -e 's|^[[:space:]]*<source[^>]*srcset="(assets/logo-[^"]+)"[^>]*>[[:space:]]*$|![Shared Dev Tooling logo](../../../\1)|' \
    -e "s|\]\( *\.\./\.\./README\.md(#[^)]*)?\)|](${up}\1)|g" \
    -e "s|\]\((\./)?([A-Za-z0-9_~-]+)\.md(#[^)]*)?\)|](${sib}\2/\3)|g" \
    -e "s|\]\((\./)?([A-Za-z0-9_~-]+/[A-Za-z0-9_~./-]+)\.md(#[^)]*)?\)|](${up}\2/\3)|g"
}

strip_first_h1() {
  # Starlight renders frontmatter `title` as the page H1, so drop the
  # source H1 (the same line `sync_file` uses for the title).
  awk 'BEGIN { skipped = 0 } !skipped && /^# [^#]/ { skipped = 1; next } { print }'
}

yaml_quote() {
  # Double-quote a scalar for YAML frontmatter (escape \ and ").
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '"%s"' "${s}"
}

sync_file() {
  local src="$1"
  local dst="$2"
  local fallback_title="$3"
  local depth="${4:-0}"
  local title=""

  [[ -f "${src}" ]] || die "missing source ${src}"
  title=$(sed -nE 's/^# ([^#].*)/\1/p' "${src}" | head -n 1)
  if [[ -z "${title}" ]]; then
    title="${fallback_title}"
  fi

  mkdir -p "$(dirname "${dst}")"
  {
    printf -- '---\ntitle: %s\ndescription: Shared Dev Tooling documentation.\n---\n\n' "$(yaml_quote "${title}")"
    rewrite_links "${depth}" <"${src}" | strip_first_h1
  } >"${dst}"
}

sync_file "README.md" "${OUT}/index.md" "Shared Dev Tooling" 0
[[ -f "AGENTS.md" ]] && sync_file "AGENTS.md" "${OUT}/agents.md" "Agents" 1
[[ -f "GLOSSARY.md" ]] && sync_file "GLOSSARY.md" "${OUT}/glossary.md" "Glossary" 1
[[ -f "CHANGELOG.md" ]] && sync_file "CHANGELOG.md" "${OUT}/changelog.md" "Changelog" 1

shopt -s nullglob
for src in "${SRC_DOCS}"/guidelines/*.md; do
  base=$(basename "${src}")
  sync_file "${src}" "${OUT}/guidelines/${base}" "${base%.md}" 2
done
shopt -u nullglob

echo "synced docs site content into ${OUT}/"
