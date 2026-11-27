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

REPO_URL="https://github.com/copier-templates/shared-dev-tooling"
REF="main"
OUT="src/content/docs"
SRC_DOCS="docs"

[[ -d "${SRC_DOCS}" ]] || die "missing ${SRC_DOCS}/ directory"
[[ -f "README.md" ]] || die "missing README.md"

rm -rf "${OUT}"
mkdir -p "${OUT}/guidelines"

# $1: route depth of the page (0 = site root index, 1 = agents/glossary/
# changelog/404, 2 = guidelines/*). Starlight serves directory-style routes,
# so a same-directory `sibling.md` link is `./sibling/` at the root but
# `../sibling/` one level down; docs-root-relative targets need one `../`
# per route level.
#
# The awk pass converts authoring syntax to site syntax before link rewriting:
#   - On the homepage (depth 0) it drops the README hero between the
#     `docs-site-hero` markers; Starlight renders its own hero from the
#     frontmatter injected in sync_file.
#   - GitHub-style alerts (`> [!NOTE]`) become Starlight asides (`:::note`),
#     so the same Markdown is styled on GitHub and on the site.
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
  awk -v home="${depth}" '
    function aside(tag,    variant, title) {
      if (tag == "TIP") variant = "tip"
      else if (tag == "WARNING" || tag == "CAUTION") variant = "caution"
      else if (tag == "IMPORTANT") { variant = "note"; title = "[Important]" }
      else { variant = "note"; title = "" }
      printf ":::%s%s\n", variant, title
    }
    BEGIN { in_hero = 0; in_alert = 0 }
    {
      if (home == 0 && $0 == "<!-- docs-site-hero:start -->") { in_hero = 1; next }
      if (in_hero) {
        if ($0 == "<!-- docs-site-hero:end -->") in_hero = 0
        next
      }
      if (!in_alert && $0 ~ /^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\][[:space:]]*$/) {
        tag = $0
        sub(/^> \[!/, "", tag)
        sub(/\].*$/, "", tag)
        aside(tag)
        in_alert = 1
        next
      }
      if (in_alert) {
        if ($0 ~ /^>/) {
          line = $0
          sub(/^> ?/, "", line)
          print line
          next
        }
        print ":::"
        print ""
        in_alert = 0
      }
      print
    }
    END { if (in_alert) print ":::" }
  ' | sed -E \
    -e 's|\(docs/guidelines/|\(guidelines/|g' \
    -e 's|\(CHANGELOG\.md|\(changelog.md|g' \
    -e 's|\(GLOSSARY\.md|\(glossary.md|g' \
    -e 's|\(AGENTS\.md|\(agents.md|g' \
    -e 's|]\(LICENSE\)|](https://github.com/copier-templates/shared-dev-tooling/blob/main/LICENSE)|g' \
    -e "s|\]\( *\.\./\.\./README\.md(#[^)]*)?\)|](${up}\1)|g" \
    -e "s|\]\( *\.\./README\.md(#[^)]*)?\)|](${up}\1)|g" \
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

first_h1() {
  sed -nE 's/^# ([^#].*)/\1/p' "$1" | head -n 1
}

# First prose paragraph after the hero/H1, used as the page meta description
# (search results, social cards). Skips HTML, badges, headings, lists, tables,
# code fences and blockquotes, then strips inline Markdown and truncates.
derive_description() {
  local src="$1" text
  text=$(awk '
    /^<!-- docs-site-hero:start -->$/ { hero = 1; next }
    /^<!-- docs-site-hero:end -->$/ { hero = 0; next }
    hero { next }
    /^# / { next }
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*</ { next }
    /^\[!\[/ { next }
    /^[[:space:]]*(#|[-*+][[:space:]]|[0-9]+[.][[:space:]]|[|>`])/ { next }
    { print; exit }
  ' "${src}")
  text=$(printf '%s' "${text}" | sed -E \
    -e 's/\[([^]]+)\]\([^)]*\)/\1/g' \
    -e 's/`//g' \
    -e 's/\*\*//g' \
    -e 's/[[:space:]]+/ /g' \
    -e 's/^ //' \
    -e 's/ $//')
  if ((${#text} > 160)); then
    text="${text:0:157}"
    text="${text% *}"
    text+="..."
  fi
  printf '%s' "${text}"
}

hero_frontmatter() {
  cat <<'EOF'
hero:
  title: "Shared Dev Tooling"
  tagline: "Shared mise tasks and prek hooks, released as one semver tag."
  actions:
    - text: "Read the guidelines"
      link: "guidelines/mise/"
      variant: "primary"
    - text: "View on GitHub"
      link: "https://github.com/copier-templates/shared-dev-tooling"
      variant: "minimal"
      icon: "external"
EOF
}

render_frontmatter() {
  local src="$1" title="$2" description="$3" home="$4"
  local last_updated
  printf -- '---\ntitle: %s\n' "$(yaml_quote "${title}")"
  if [[ -n "${description}" ]]; then
    printf -- 'description: %s\n' "$(yaml_quote "${description}")"
  fi
  # The 404 page is not edited like a content page; match Starlight's default
  # (editUrl: false) instead of linking docs/404.md.
  if [[ "${src}" != "${SRC_DOCS}/404.md" ]]; then
    printf -- 'editUrl: %s\n' "$(yaml_quote "${REPO_URL}/blob/${REF}/${src}")"
  fi
  last_updated=$(git log -1 --format=%cs -- "${src}" 2>/dev/null || true)
  if [[ -n "${last_updated}" ]]; then
    printf -- 'lastUpdated: %s\n' "${last_updated}"
  fi
  if [[ "${home}" -eq 1 ]]; then
    hero_frontmatter
  fi
  printf -- '---\n\n'
}

sync_file() {
  local src="$1"
  local dst="$2"
  local fallback_title="$3"
  local depth="${4:-0}"
  local description="${5:-}"
  local title=""
  local home=0

  [[ -f "${src}" ]] || die "missing source ${src}"
  title=$(first_h1 "${src}")
  if [[ -z "${title}" ]]; then
    title="${fallback_title}"
  fi
  if [[ -z "${description}" ]]; then
    description=$(derive_description "${src}")
  fi
  [[ "${src}" == "README.md" ]] && home=1

  mkdir -p "$(dirname "${dst}")"
  {
    render_frontmatter "${src}" "${title}" "${description}" "${home}"
    rewrite_links "${depth}" <"${src}" | strip_first_h1
  } >"${dst}"
}

sync_file "README.md" "${OUT}/index.md" "Shared Dev Tooling" 0
[[ -f "AGENTS.md" ]] && sync_file "AGENTS.md" "${OUT}/agents.md" "Agents" 1
[[ -f "GLOSSARY.md" ]] && sync_file "GLOSSARY.md" "${OUT}/glossary.md" "Glossary" 1
[[ -f "CHANGELOG.md" ]] && sync_file "CHANGELOG.md" "${OUT}/changelog.md" "Changelog" 1 \
  "Release notes generated by git-cliff from Conventional Commits."
sync_file "${SRC_DOCS}/404.md" "${OUT}/404.md" "404" 0

shopt -s nullglob
for src in "${SRC_DOCS}"/guidelines/*.md; do
  base=$(basename "${src}")
  sync_file "${src}" "${OUT}/guidelines/${base}" "${base%.md}" 2
done
shopt -u nullglob

echo "synced docs site content into ${OUT}/"
