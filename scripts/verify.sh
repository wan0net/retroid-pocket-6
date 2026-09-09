#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

profile=standard
strict=0
while (( $# )); do
  case "$1" in
    --profile) profile="${2:-}"; shift 2 ;;
    --strict) strict=1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done
[[ "$profile" == standard || "$profile" == dual-screen ]] || die "profile must be standard or dual-screen"

assert_expected_device
microsd_mount="$(find_microsd_mount)"
roms_dir="$microsd_mount/$MICROSD_ROMS_DIR_NAME"

missing=0
check_package() {
  local package="$1" label="$2" required="${3:-1}"
  if package_installed "$package"; then
    printf 'installed  %-24s %s\n' "$package" "$label"
  else
    printf 'missing    %-24s %s\n' "$package" "$label"
    (( required )) && missing=$((missing + 1))
  fi
}

check_package dev.imranr.obtainium Obtainium
check_package app.gamenative GameNative
check_package com.retroarch.aarch64 'RetroArch AArch64'
check_package org.dolphinemu.dolphinemu Dolphin
check_package org.azahar_emu.azahar Azahar
if [[ "$profile" == dual-screen ]]; then
  check_package me.magnum.melondualds WatermelonDS
  check_package com.esde.companion 'ES-DE Companion'
else
  check_package me.magnum.melonds melonDS
fi
check_package org.ppsspp.ppsspp PPSSPP
check_package org.vita3k.emulator Vita3K
check_package com.armsx2 ARMSX2
check_package com.limelight Moonlight

check_managed_file() {
  local local_path="$1" device_path="$2" label="$3"
  if "${ADB[@]}" exec-out cat "$device_path" 2>/dev/null | cmp -s "$local_path" -; then
    printf 'configured %-24s %s\n' "$label" "$device_path"
  else
    printf 'drifted    %-24s %s (run make configure-controls)\n' "$label" "$device_path"
    missing=$((missing + 1))
  fi
}

if package_installed com.retroarch.aarch64; then
  check_managed_file "$ROOT_DIR/config/retroarch/retroarch.cfg" \
    /sdcard/Android/data/com.retroarch.aarch64/files/retroarch.cfg RetroArch
  check_managed_file \
    "$ROOT_DIR/config/retroarch/autoconfig/android/Retroid_Pocket_Controller.cfg" \
    /sdcard/RetroArch/autoconfig/android/Retroid_Pocket_Controller.cfg 'RP6 RetroPad'
fi

if package_installed org.dolphinemu.dolphinemu; then
  check_managed_file "$ROOT_DIR/config/dolphin/GCPadNew.ini" \
    /sdcard/Android/data/org.dolphinemu.dolphinemu/files/Config/GCPadNew.ini 'Dolphin GC'
  check_managed_file "$ROOT_DIR/config/dolphin/WiimoteNew.ini" \
    /sdcard/Android/data/org.dolphinemu.dolphinemu/files/Config/WiimoteNew.ini 'Dolphin Wii'
fi

if package_installed org.es_de.frontend || package_installed com.es_de.frontend; then
  printf 'installed  %-24s %s\n' '(detected)' 'ES-DE (manual distribution)'
  while IFS=$'\t' read -r system_name emulator_label; do
    [[ -n "$system_name" && "${system_name:0:1}" != '#' ]] || continue
    gamelist="/sdcard/ES-DE/gamelists/$system_name/gamelist.xml"
    if "${ADB[@]}" exec-out cat "$gamelist" 2>/dev/null \
      | grep -Fq "<label>$emulator_label</label>"; then
      printf 'configured %-24s %s\n' "ES-DE $system_name" "$emulator_label"
    else
      printf 'drifted    %-24s %s (run make configure-es-de)\n' \
        "ES-DE $system_name" "$emulator_label"
      missing=$((missing + 1))
    fi
  done < "$ROOT_DIR/config/es-de/emulators.tsv"
else
  printf 'manual     %-24s %s\n' '(not detected)' 'ES-DE APK must be supplied by its owner'
  missing=$((missing + 1))
fi

for device_dir in "$DEVICE_PROJECT_DIR" "$roms_dir" "$DEVICE_BIOS_DIR" /sdcard/ES-DE; do
  if "${ADB[@]}" shell test -d "$device_dir"; then
    printf 'ready      %s\n' "$device_dir"
  else
    printf 'missing    %s (run make configure)\n' "$device_dir"
    missing=$((missing + 1))
  fi
done

if (( missing )); then
  note "$missing selected app(s) or directory check(s) remain."
  (( strict )) && exit 1
else
  note 'All selected app and directory checks passed.'
fi
