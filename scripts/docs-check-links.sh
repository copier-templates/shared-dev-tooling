#!/usr/bin/env bash
# Check internal links in the built Starlight site.
# Usage: scripts/docs-check-links.sh [dist-dir]
#
# Verifies author-controlled relative hrefs in dist/**/*.html resolve to built
# files (directory routes expect index.html). Skips external URLs and
# absolute-path hrefs: those are framework-generated nav (sidebar, search),
# trusted via astro.config.mjs + Starlight, not author Markdown.
set -euo pipefail

if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 1))); then
  echo "error: bash 5.1+ required (found ${BASH_VERSION:-unknown})" >&2
  exit 1
fi

die() {
  echo "error: $*" >&2
  exit 1
}

DIST="${1:-dist}"
[[ -d "${DIST}" ]] || die "missing ${DIST}/ directory (run \"mise run docs:build\" first)"

fail=0
while IFS= read -r -d '' html; do
  dir=$(dirname "${html}")
  while IFS= read -r href; do
    url=${href#href=\"}
    url=${url%\"}
    case "${url}" in
    "" | \#* | http://* | https://* | mailto:* | tel:* | data:* | blob:* | javascript:* | /*) continue ;;
    esac
    target=${url%%\#*}
    target=${target%%\?*}
    [[ -z "${target}" ]] && continue
    candidate="${dir}/${target}"
    if [[ "${target}" == */ || -d "${candidate}" ]]; then
      # Directory route (GitHub Pages serves <dir>/index.html; a bare
      # directory path with no index page is a 404).
      candidate="${candidate%/}/index.html"
    elif [[ ! -e "${candidate}" ]]; then
      if [[ -e "${candidate}.html" ]]; then
        candidate="${candidate}.html"
      elif [[ -e "${candidate}/index.html" ]]; then
        candidate="${candidate}/index.html"
      fi
    fi
    if [[ ! -e "${candidate}" ]]; then
      echo "broken: ${html#"${DIST}"/} -> ${url}" >&2
      fail=1
    fi
  done < <(grep -o --color=never 'href="[^"]*"' "${html}" || true)
done < <(find "${DIST}" -name '*.html' -print0)

((fail)) && die "broken internal links found (fix the source Markdown or scripts/docs-sync.sh rewrites, then rebuild)"
echo "all internal links resolve in ${DIST}/"
