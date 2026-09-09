#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

for script in scripts/*.sh; do
  bash -n "$script"
done

for manifest in obtainium/apps.json obtainium/apps-dual-screen.json; do
  jq -e '
    (.apps | type == "array" and length >= 9) and
    (.settings | type == "object") and
    ([.apps[] | has("id") and has("url") and has("author") and has("name")] | all)
  ' "$manifest" >/dev/null
  duplicates="$(jq -r '.apps[].id' "$manifest" | sort | uniq -d)"
  [[ -z "$duplicates" ]] || { printf 'duplicate package IDs in %s: %s\n' "$manifest" "$duplicates" >&2; exit 1; }
done

if command -v ruby >/dev/null 2>&1; then
  ruby -e 'require "yaml"; YAML.load_file("apps.yaml")'
  ruby -c scripts/set-es-de-emulator.rb >/dev/null
else
  printf '%s\n' 'warning: ruby unavailable; skipped YAML parse check' >&2
fi

awk -F '\t' '
  /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
  NF != 2 || $1 == "" || $2 == "" { exit 1 }
' config/es-de/emulators.tsv \
  || { printf '%s\n' 'invalid ES-DE emulator manifest' >&2; exit 1; }

duplicates="$(awk -F '\t' '!/^[[:space:]]*(#|$)/ {print $1}' \
  config/es-de/emulators.tsv | sort | uniq -d)"
[[ -z "$duplicates" ]] \
  || { printf 'duplicate ES-DE systems: %s\n' "$duplicates" >&2; exit 1; }

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/*.sh
else
  printf '%s\n' 'warning: shellcheck unavailable; skipped lint check' >&2
fi

printf '%s\n' 'Validation passed.'
