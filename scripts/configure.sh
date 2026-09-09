#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

assert_expected_device

while IFS= read -r device_dir; do
  [[ -n "$device_dir" ]] && ensure_device_dir "$device_dir"
done <<EOF
$DEVICE_PROJECT_DIR
$DEVICE_ROMS_DIR
$DEVICE_ROMS_DIR/3ds
$DEVICE_ROMS_DIR/ds
$DEVICE_ROMS_DIR/gamecube
$DEVICE_ROMS_DIR/ps2
$DEVICE_ROMS_DIR/psp
$DEVICE_ROMS_DIR/psvita
$DEVICE_ROMS_DIR/retroarch
$DEVICE_ROMS_DIR/wii
$DEVICE_BIOS_DIR
/sdcard/ES-DE
EOF

note 'Created the non-sensitive ROM, BIOS, ES-DE and project directories.'
note 'No ROMs, BIOS files, console keys, accounts or credentials were copied.'
