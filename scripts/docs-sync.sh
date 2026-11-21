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

rewrite_links() {
  sed -E \
    -e 's|\(\.\./\.\./README\.md|\(..|g' \
    -e 's|\(docs/guidelines/|\(guidelines/|g' \
    -e 's|\(CHANGELOG\.md|\(changelog.md|g' \
    -e 's|\(GLOSSARY\.md|\(glossary.md|g' \
    -e 's|\(AGENTS\.md|\(agents.md|g' \
    -e 's|]\(LICENSE\)|](https://github.com/copier-templates/shared-dev-tooling/blob/main/LICENSE)|g'
}

sync_file() {
  local src="$1"
  local dst="$2"
  local fallback_title="$3"
  local title=""

  [[ -f "${src}" ]] || die "missing source ${src}"
  title=$(sed -nE 's/^# ([^#].*)/\1/p' "${src}" | head -n 1)
  if [[ -z "${title}" ]]; then
    title="${fallback_title}"
  fi

  mkdir -p "$(dirname "${dst}")"
  {
    printf -- '---\ntitle: %s\ndescription: Shared Dev Tooling documentation.\n---\n\n' "${title}"
    rewrite_links <"${src}"
  } >"${dst}"
}

sync_file "README.md" "${OUT}/index.md" "Shared Dev Tooling"
[[ -f "AGENTS.md" ]] && sync_file "AGENTS.md" "${OUT}/agents.md" "Agents"
[[ -f "GLOSSARY.md" ]] && sync_file "GLOSSARY.md" "${OUT}/glossary.md" "Glossary"
[[ -f "CHANGELOG.md" ]] && sync_file "CHANGELOG.md" "${OUT}/changelog.md" "Changelog"

shopt -s nullglob
for src in "${SRC_DOCS}"/guidelines/*.md; do
  base=$(basename "${src}")
  sync_file "${src}" "${OUT}/guidelines/${base}" "${base%.md}"
done
shopt -u nullglob

echo "synced docs site content into ${OUT}/"
