#!/usr/bin/env bash
# Run from the BASE revision (see workflow), never from the change under test.
# 1) entries/ and moods/: only additions allowed.
# 2) scripts/ and .github/: any change fails here and needs its own PR,
#    reviewed by someone else (Kiro, 13.10.).
set -euo pipefail
BASE="${1:?usage: append-only.sh <base-ref> [head-ref]}"
HEAD="${2:-HEAD}"
fail=0
bad=$(git diff --name-status --no-renames "$BASE" "$HEAD" -- entries moods | grep -v '^A' || true)
if [ -n "$bad" ]; then
  echo "❌ append-only violated (only additions allowed in entries/ and moods/):"
  echo "$bad"; fail=1
fi
guard=$(git diff --name-status --no-renames "$BASE" "$HEAD" -- scripts .github || true)
if [ -n "$guard" ]; then
  echo "❌ this change touches the guard itself (scripts/ or .github/). Own PR, reviewed by someone else:"
  echo "$guard"; fail=1
fi
[ $fail -eq 0 ] || exit 1
echo "✅ append-only: $(git diff --name-only --diff-filter=A "$BASE" "$HEAD" -- entries moods | wc -l) new file(s), nothing changed"
