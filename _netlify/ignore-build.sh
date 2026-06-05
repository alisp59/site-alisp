#!/usr/bin/env bash

# Netlify "ignore" command: decides whether to skip the deploy for a push.
# Exit 0 => Netlify skips the build. Exit 1 => Netlify builds.
#
# Skip the build when a push touches only repo-internal files that do not affect
# the rendered site (e.g. TODO.md). The commit is still pushed to the repo; only
# the Netlify deploy is cancelled.

set -uo pipefail

# Paths that never affect the published site. Add more here as needed.
ignored_paths=(
	":!TODO.md"
)

# No cached ref (first build, cleared cache, brand-new branch): always build.
if [[ -z "${CACHED_COMMIT_REF:-}" ]]; then
	exit 1
fi

# Build unless every changed file is in ignored_paths.
# git diff --quiet exits 0 when there is no diff (=> skip), 1 when there is.
git diff --quiet "$CACHED_COMMIT_REF" "$COMMIT_REF" -- . "${ignored_paths[@]}"
