#!/usr/bin/env bash

# Netlify "ignore" command: decides whether to skip the deploy for a push.
# Exit 0 => Netlify skips the build. Exit 1 => Netlify builds.
#
# Skip the build when a push touches only repo-internal files that do not affect
# the rendered site (e.g. TODO.md). The commit is still pushed to the repo; only
# the Netlify deploy is cancelled. The decision defaults to "build"; only a
# confident "nothing but ignored files changed" flips it to "skip", and the exit
# code is always normalised to 0 or 1 (never a raw git error code).

set -uo pipefail

# Paths that never affect the published site. Add more here as needed.
ignored_paths=(
  ":!TODO.md"
  ":!README.md"
)

# No cached ref (first build, cleared cache, brand-new branch): build.
if [[ -z "${CACHED_COMMIT_REF:-}" ]]; then
  exit 1
fi

# Same commit already deployed (re-deploy, amend/force-push to the same tip):
# the range is empty, which would otherwise read as "no changes". Build.
if [[ "$CACHED_COMMIT_REF" == "$COMMIT_REF" ]]; then
  exit 1
fi

# Cached ref not reachable in this (shallow) clone: can't compare safely. Build.
if ! git cat-file -e "${CACHED_COMMIT_REF}^{commit}" 2>/dev/null; then
  exit 1
fi

# Skip only when every file changed since the last deploy is in ignored_paths.
# git diff --quiet exits 0 when there is no diff (=> skip), non-zero otherwise.
if git diff --quiet "$CACHED_COMMIT_REF" "$COMMIT_REF" -- . "${ignored_paths[@]}"; then
  exit 0
fi

exit 1
