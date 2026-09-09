#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

assert_expected_device
require_command ruby
package_installed org.es_de.frontend || die 'ES-DE is not installed'

ESDE_DIR='/sdcard/ES-DE'
MANIFEST="$ROOT_DIR/config/es-de/emulators.tsv"
temporary_dir="$(mktemp -d)"
esde_was_running="$("${ADB[@]}" shell pidof org.es_de.frontend 2>/dev/null | tr -d '\r' || true)"
cleanup() {
  find "$temporary_dir" -type f -delete
  rmdir "$temporary_dir"
}
trap cleanup EXIT

"${ADB[@]}" shell am force-stop org.es_de.frontend </dev/null

while IFS=$'\t' read -r system_name emulator_label; do
  [[ -n "$system_name" && "${system_name:0:1}" != '#' ]] || continue
  [[ -n "$emulator_label" ]] || die "missing emulator label for $system_name"

  local_file="$temporary_dir/${system_name}.xml"
  device_file="$ESDE_DIR/gamelists/$system_name/gamelist.xml"
  if "${ADB[@]}" shell test -f "$device_file" </dev/null; then
    "${ADB[@]}" pull "$device_file" "$local_file" >/dev/null
  fi
  ruby "$ROOT_DIR/scripts/set-es-de-emulator.rb" "$local_file" "$emulator_label"
  deploy_device_file "$local_file" "$device_file" "$ESDE_DIR"
done < "$MANIFEST"

note 'ES-DE system-wide emulator defaults installed.'
note 'Existing games, metadata, favourites and play history were preserved.'

if [[ -n "$esde_was_running" ]]; then
  "${ADB[@]}" shell monkey -p org.es_de.frontend \
    -c android.intent.category.LAUNCHER 1 >/dev/null
  note 'Restarted ES-DE because it was running before configuration.'
fi
