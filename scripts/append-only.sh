#!/usr/bin/env bash
# Fails if anything under entries/ or moods/ was modified, renamed or deleted
# between BASE and HEAD. Additions are the only allowed change.
set -euo pipefail
BASE="${1:?usage: append-only.sh <base-ref> [head-ref]}"
HEAD="${2:-HEAD}"
bad=$(git diff --name-status --no-renames "$BASE" "$HEAD" -- entries moods | grep -v '^A' || true)
if [ -n "$bad" ]; then
  echo "❌ append-only violated (only additions allowed in entries/ and moods/):"
  echo "$bad"
  exit 1
fi
echo "✅ append-only: $(git diff --name-only --diff-filter=A "$BASE" "$HEAD" -- entries moods | wc -l) new file(s), nothing changed"
