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

"${ADB[@]}" shell am force-stop org.dolphinemu.dolphinemu </dev/null

deploy_device_file "$ROOT_DIR/config/dolphin/GCPadNew.ini" "$CONFIG_DIR/GCPadNew.ini" "$DOLPHIN_DIR"
deploy_device_file "$ROOT_DIR/config/dolphin/WiimoteNew.ini" "$CONFIG_DIR/WiimoteNew.ini" "$DOLPHIN_DIR"

for profile in "$ROOT_DIR"/config/dolphin/Profiles/GCPad/*.ini; do
  deploy_device_file "$profile" "$CONFIG_DIR/Profiles/GCPad/${profile##*/}" "$DOLPHIN_DIR"
done
for profile in "$ROOT_DIR"/config/dolphin/Profiles/Wiimote/*.ini; do
  deploy_device_file "$profile" "$CONFIG_DIR/Profiles/Wiimote/${profile##*/}" "$DOLPHIN_DIR"
done
for game_settings in "$ROOT_DIR"/config/dolphin/GameSettings/*.ini; do
  deploy_device_file "$game_settings" "$DOLPHIN_DIR/GameSettings/${game_settings##*/}" "$DOLPHIN_DIR"
done

note 'Dolphin controller mappings installed.'
note 'NSMB Wii (SMNP01) will use the RP6 sideways profile automatically.'
