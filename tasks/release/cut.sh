#!/usr/bin/env bash
#MISE description="Pick a version with gum, regenerate CHANGELOG.md, commit, tag, push and optionally publish a GitHub Release from main"
#MISE tags=["release"]
#MISE interactive=true
#USAGE flag "-u --allow-unsynced" help="Release even if main is behind origin/main"
#USAGE flag "-N --no-github-release" help="Skip the GitHub Release step (also auto-skipped when origin is not on github.com)"
# Cuts a release from main: choose a bump with gum, regenerate CHANGELOG.md with
# git-cliff, commit it as chore(release), tag, push, and optionally publish a
# GitHub Release (GitHub remotes only).
set -euo pipefail

# Gate bash 5.1+. This check itself parses under bash 3.2; plain echo because die/gum are not set up yet.
if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 1))); then
  echo "error: bash 5.1+ required (found ${BASH_VERSION:-unknown})" >&2
  exit 1
fi

# shellcheck disable=SC2154 # set by mise from the --allow-unsynced #USAGE flag
allow_unsynced=${usage_allow_unsynced:-false}
# shellcheck disable=SC2154 # set by mise from the --no-github-release #USAGE flag
no_github_release=${usage_no_github_release:-false}

die() {
  gum style --foreground 196 "error: $*" >&2
  gum style --foreground 244 'run "mise run release:cut --help" to see the options' >&2
  exit 1
}

branch=$(git branch --show-current)
[[ "$branch" == "main" ]] || die "release must run from main (current: ${branch:-detached HEAD})"
[[ -z "$(git status --porcelain)" ]] || die "working tree is not clean"
git fetch --quiet --tags origin main
read -r ahead behind <<<"$(git rev-list --left-right --count HEAD...origin/main)"
if ((behind > 0)); then
  [[ "$allow_unsynced" == "true" ]] || die "main is $behind commit(s) behind origin/main (pull, or pass --allow-unsynced to override)"
  gum style --foreground 214 "warning: releasing with main $behind behind origin/main" >&2
elif ((ahead > 0)); then
  gum style --foreground 214 "warning: releasing with main $ahead ahead of origin/main" >&2
fi

last_local=$(git tag --list '[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | sed -n '1p')
last_remote=$(git ls-remote --tags --refs origin | sed 's#.*refs/tags/##' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -t . -k 1,1n -k 2,2n -k 3,3n | tail -n 1)
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

git-cliff --tag "$version" -o CHANGELOG.md
git --no-pager diff --stat -- CHANGELOG.md

if ! gum confirm "Commit CHANGELOG.md and tag $version?"; then
  if git ls-files --error-unmatch CHANGELOG.md >/dev/null 2>&1; then
    git checkout -- CHANGELOG.md
  else
    rm -f CHANGELOG.md
  fi
  die "release cancelled"
fi

git add CHANGELOG.md
git commit -m "chore(release): bump version $version"
git tag -a "$version" -m "$version"

if gum confirm "Push main and tag $version to origin?"; then
  git push --atomic origin main "refs/tags/$version"
else
  printf 'Not pushed. Run: git push --atomic origin main refs/tags/%s\n' "$version"
  exit 0
fi

if [[ "$no_github_release" == "true" ]]; then
  exit 0
fi

origin_url=$(git remote get-url origin 2>/dev/null || true)
if [[ "$origin_url" != *github.com* ]]; then
  gum style --foreground 214 "non-GitHub remote, skipping GitHub Release" >&2
  exit 0
fi

if ! gum confirm "Create GitHub Release $version?"; then
  printf 'Skipped GitHub Release. Run: gh release create %s --title %s --notes-file - --verify-tag <notes>\n' "$version" "$version"
  exit 0
fi

command -v gh >/dev/null 2>&1 || die "gh CLI not found (run mise run gate:setup)"
if gh release view "$version" >/dev/null 2>&1; then
  die "GitHub Release $version already exists"
fi

notes=$(awk -v header="## [$version]" 'index($0, header) == 1 { found=1; next } found && /^## / { exit } found' CHANGELOG.md)
[[ -n "${notes:-}" ]] || die "no CHANGELOG.md entry found for $version"

printf '%s\n' "$notes" | gh release create "$version" --title "$version" --notes-file - --verify-tag
