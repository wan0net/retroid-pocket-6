#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

assert_expected_device

microsd_mount="$(find_microsd_mount)"
roms_dir="$microsd_mount/$MICROSD_ROMS_DIR_NAME"

"$ROOT_DIR/scripts/google-apps.sh" disable

while IFS= read -r device_dir; do
  [[ -n "$device_dir" ]] && ensure_device_dir "$device_dir"
done <<EOF
$DEVICE_PROJECT_DIR
$roms_dir
$roms_dir/arcade
$roms_dir/atari2600
$roms_dir/dreamcast
$roms_dir/gb
$roms_dir/gba
$roms_dir/gbc
$roms_dir/gc
$roms_dir/genesis
$roms_dir/mastersystem
$roms_dir/n3ds
$roms_dir/n64
$roms_dir/nds
$roms_dir/nes
$roms_dir/pcengine
$roms_dir/ps2
$roms_dir/psp
$roms_dir/psvita
$roms_dir/psx
$roms_dir/saturn
$roms_dir/snes
$roms_dir/wii
$DEVICE_BIOS_DIR
/sdcard/ES-DE
EOF

note "Created the ROM hierarchy on microSD at $roms_dir."
note 'Created the internal BIOS, ES-DE and project directories.'
note 'No ROMs, BIOS files, console keys, accounts or credentials were copied.'

if package_installed org.dolphinemu.dolphinemu; then
  "$ROOT_DIR/scripts/configure-dolphin.sh"
else
  note 'Dolphin is not installed yet; run make configure-dolphin after installing it.'
fi
