#!/usr/bin/env bash
#MISE description="Pick a version with gum, regenerate CHANGELOG.md, commit, tag and push from main"
#MISE tags=["release"]
#MISE interactive=true
#USAGE flag "-u --allow-unsynced" help="Release even if main differs from origin/main"
# Cuts a release from main: choose a bump with gum, regenerate CHANGELOG.md with
# git-cliff, commit it as chore(release), tag, and optionally push.
set -euo pipefail

# Gate bash 5.1+. This check itself parses under bash 3.2; plain echo because die/gum are not set up yet.
if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 1))); then
  echo "error: bash 5.1+ required (found ${BASH_VERSION:-unknown})" >&2
  exit 1
fi

# shellcheck disable=SC2154 # set by mise from the --allow-unsynced #USAGE flag
allow_unsynced=${usage_allow_unsynced:-false}

die() {
  gum style --foreground 196 "error: $*" >&2
  gum style --foreground 244 'run "mise run release:cut --help" to see the options' >&2
  exit 1
}

branch=$(git branch --show-current)
[[ "$branch" == "main" ]] || die "release must run from main (current: ${branch:-detached HEAD})"
[[ -z "$(git status --porcelain)" ]] || die "working tree is not clean"
git fetch --quiet origin main
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
  [[ "$allow_unsynced" == "true" ]] || die "main is not in sync with origin/main (pass --allow-unsynced to override)"
  gum style --foreground 214 "warning: releasing with main out of sync with origin/main" >&2
fi

last_local=$(git tag --list --sort=-v:refname | sed -n '1p')
last_remote=$(git ls-remote --tags --refs origin | sed 's#.*refs/tags/##' | sort -t . -k 1,1n -k 2,2n -k 3,3n | tail -n 1)
read -r ahead behind <<<"$(git rev-list --left-right --count HEAD...origin/main)"
gum style --border rounded --border-foreground 39 --padding "0 1" --margin "1 0" \
  "$(printf 'Last tag (local):  %s\nLast tag (remote): %s\nmain (local):      %s\nmain (remote):     %s\nDrift:             %s ahead, %s behind origin/main' \
    "${last_local:-none}" "${last_remote:-none}" "$(git rev-parse --short HEAD)" "$(git rev-parse --short origin/main)" "$ahead" "$behind")"
kind=$(gum choose --header "Bump which part?" patch minor major custom)

bump() {
  local major minor patch
  IFS=. read -r major minor patch <<<"${last_local:-0.0.0}"
  case "$1" in
  major) major=$((major + 1)) minor=0 patch=0 ;;
  minor) minor=$((minor + 1)) patch=0 ;;
  patch) patch=$((patch + 1)) ;;
  esac
  printf '%s.%s.%s\n' "$major" "$minor" "$patch"
}

if [[ "$kind" == "custom" ]]; then
  version=$(gum input --placeholder "X.Y.Z")
else
  version=$(bump "$kind")
fi

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "invalid version: $version"
if git rev-parse -q --verify "refs/tags/$version" >/dev/null; then
  die "tag $version already exists"
fi

git cliff --tag "$version" -o CHANGELOG.md
git --no-pager diff --stat -- CHANGELOG.md

if ! gum confirm "Commit CHANGELOG.md and tag $version?"; then
  git checkout -- CHANGELOG.md
  die "release cancelled"
fi

git add CHANGELOG.md
git commit -m "chore(release): bump version $version"
git tag -a "$version" -m "$version"

if gum confirm "Push main and tag $version to origin?"; then
  git push --atomic origin main "refs/tags/$version"
else
  printf 'Not pushed. Run: git push --atomic origin main refs/tags/%s\n' "$version"
fi
