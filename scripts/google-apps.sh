#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

action="${1:-}"
[[ "$action" == disable || "$action" == enable ]] \
  || die 'usage: scripts/google-apps.sh disable|enable'

assert_expected_device

changed=0
skipped=0
disabled_packages="$("${ADB[@]}" shell pm list packages -d --user 0 </dev/null | tr -d '\r')"
while IFS= read -r package_id; do
  [[ -z "$package_id" || "$package_id" == \#* ]] && continue

  if ! package_installed "$package_id"; then
    printf 'absent     %s\n' "$package_id"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$action" == disable ]]; then
    if grep -Fxq "package:$package_id" <<<"$disabled_packages"; then
      printf 'disabled   %s (already)\n' "$package_id"
      continue
    fi
    "${ADB[@]}" shell pm disable-user --user 0 "$package_id" </dev/null
    disabled_packages="$("${ADB[@]}" shell pm list packages -d --user 0 </dev/null | tr -d '\r')"
    grep -Fxq "package:$package_id" <<<"$disabled_packages" \
      || die "package did not become disabled: $package_id"
    printf 'disabled   %s\n' "$package_id"
  else
    "${ADB[@]}" shell pm enable --user 0 "$package_id" </dev/null
    printf 'enabled    %s\n' "$package_id"
  fi
  changed=$((changed + 1))
done <"$ROOT_DIR/config/optional-google-apps.txt"

note "$action complete: $changed changed, $skipped not present on this firmware."
