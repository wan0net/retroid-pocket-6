#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

assert_expected_device
package_installed org.dolphinemu.dolphinemu \
  || die 'Dolphin is not installed (expected org.dolphinemu.dolphinemu)'

DOLPHIN_DIR='/sdcard/Android/data/org.dolphinemu.dolphinemu/files'
CONFIG_DIR="$DOLPHIN_DIR/Config"
BACKUP_SUFFIX='.rp6-before-automation'

deploy_file() {
  local source_path="$1" destination_path="$2" destination_dir temporary_path backup_path
  destination_dir="${destination_path%/*}"
  temporary_path="${destination_path}.rp6-new"
  backup_path="${destination_path}${BACKUP_SUFFIX}"

  ensure_device_dir "$destination_dir"
  "${ADB[@]}" push "$source_path" "$temporary_path" >/dev/null
  if "${ADB[@]}" shell test -f "$destination_path" </dev/null \
    && "${ADB[@]}" shell cmp -s "$temporary_path" "$destination_path" </dev/null; then
    "${ADB[@]}" shell rm "$temporary_path" </dev/null
    note "Unchanged: ${destination_path#"$DOLPHIN_DIR"/}"
  else
    if "${ADB[@]}" shell test -f "$destination_path" </dev/null \
      && ! "${ADB[@]}" shell test -f "$backup_path" </dev/null; then
      "${ADB[@]}" shell cp "$destination_path" "$backup_path" </dev/null
      note "Backed up ${destination_path#"$DOLPHIN_DIR"/}"
    fi
    "${ADB[@]}" shell mv "$temporary_path" "$destination_path" </dev/null
    note "Installed: ${destination_path#"$DOLPHIN_DIR"/}"
  fi
}

"${ADB[@]}" shell am force-stop org.dolphinemu.dolphinemu </dev/null

deploy_file "$ROOT_DIR/config/dolphin/GCPadNew.ini" "$CONFIG_DIR/GCPadNew.ini"
deploy_file "$ROOT_DIR/config/dolphin/WiimoteNew.ini" "$CONFIG_DIR/WiimoteNew.ini"

for profile in "$ROOT_DIR"/config/dolphin/Profiles/GCPad/*.ini; do
  deploy_file "$profile" "$CONFIG_DIR/Profiles/GCPad/${profile##*/}"
done
for profile in "$ROOT_DIR"/config/dolphin/Profiles/Wiimote/*.ini; do
  deploy_file "$profile" "$CONFIG_DIR/Profiles/Wiimote/${profile##*/}"
done
for game_settings in "$ROOT_DIR"/config/dolphin/GameSettings/*.ini; do
  deploy_file "$game_settings" "$DOLPHIN_DIR/GameSettings/${game_settings##*/}"
done

note 'Dolphin controller mappings installed.'
note 'NSMB Wii (SMNP01) will use the RP6 sideways profile automatically.'
