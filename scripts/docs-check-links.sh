#!/usr/bin/env bash
# Check internal links in the built Starlight site.
# Usage: scripts/docs-check-links.sh [dist-dir]
#
# Verifies relative and site-absolute href/src URLs in dist/**/*.html resolve
# to built files (directory routes expect index.html). Skips external URLs
# (http, mailto, data, ...). Site-absolute paths are resolved against DIST
# after stripping the astro base (e.g. /shared-dev-tooling/), so nav,
# sidebar, and bundled _astro assets are checked too.
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

# Site base from astro.config.mjs (e.g. /shared-dev-tooling/) so absolute
# paths resolve against DIST. Falls back to / when unparseable.
BASE="$(sed -nE 's/^[[:space:]]*base:[[:space:]]*['\''"]([^'\''"]+)['\''"].*/\1/p' astro.config.mjs 2>/dev/null | head -n 1)"
BASE="${BASE:-/}"
[[ "${BASE}" != */ ]] && BASE="${BASE}/"

check_url() {
  local url="$1" html="$2" dir="$3"
  local target candidate
  case "${url}" in
  "" | \#* | http://* | https://* | mailto:* | tel:* | data:* | blob:* | javascript:*) return 0 ;;
  esac
  target=${url%%\#*}
  target=${target%%\?*}
  [[ -z "${target}" ]] && return 0
  if [[ "${target}" == /* ]]; then
    # Site-absolute: strip the astro base, resolve against DIST.
    local rel="${target}"
    if [[ "${BASE}" != "/" && "${rel}" == "${BASE}"* ]]; then
      rel="${rel#"${BASE}"}"
    else
      rel="${rel#/}"
    fi
    [[ -z "${rel}" ]] && return 0
    candidate="${DIST}/${rel}"
  else
    candidate="${dir}/${target}"
  fi
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
}

fail=0
while IFS= read -r -d '' html; do
  dir=$(dirname "${html}")
  while IFS= read -r attr; do
    url=${attr#*=\"}
    url=${url%\"}
    check_url "${url}" "${html}" "${dir}"
  done < <(grep -o --color=never -E '(href|src)="[^"]*"' "${html}" || true)
  while IFS= read -r attr; do
    srcset=${attr#*=\"}
    srcset=${srcset%\"}
    IFS=',' read -r -a parts <<<"${srcset}" || true
    for part in "${parts[@]}"; do
      # srcset entry: URL followed by optional descriptor ("img.png 2x").
      url=$(printf '%s' "${part}" | awk '{print $1}')
      [[ -z "${url}" ]] && continue
      check_url "${url}" "${html}" "${dir}"
    done
  done < <(grep -o --color=never -E 'srcset="[^"]*"' "${html}" || true)
done < <(find "${DIST}" -name '*.html' -print0)

((fail)) && die "broken internal links found (fix the source Markdown or scripts/docs-sync.sh rewrites, then rebuild)"
echo "all internal links resolve in ${DIST}/"
