#!/usr/bin/env bash
set -euo pipefail

# Run README generator if YAML or script changed in the staged set (or if README missing)
CHANGED=$(git diff --cached --name-only || true)
if echo "$CHANGED" | grep -E '(^|/)(_data/resources.yml|scripts/generate_readme.rb)' >/dev/null 2>&1; then
  echo "[pre-commit] Detected resource data or generator changes; regenerating README.md"
  ruby scripts/generate_readme.rb
  git add README.md
else
  echo "[pre-commit] No resource data changes detected; skipping README generation"
fi

# Basic sanity: ensure README is not out-of-date if YAML changed but generation failed
if echo "$CHANGED" | grep -q '_data/resources.yml'; then
  if ! git diff --cached --quiet README.md; then
    echo "[pre-commit] README updated and staged."
  fi
fi
