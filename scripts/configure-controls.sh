#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

assert_expected_device

input_dump="$("${ADB[@]}" shell dumpsys input | tr -d '\r')"
controller_block="$(grep -A 12 -m 1 ': Retroid Pocket Controller$' <<<"$input_dump" || true)"
[[ -n "$controller_block" ]] || die 'RP6 built-in controller was not detected'
grep -q 'vendor=0x2022, product=0x3001' <<<"$controller_block" \
  || die 'built-in controller identity changed; refusing to apply RP6 mappings'
note 'Controller: Retroid Pocket Controller (vendor 0x2022, product 0x3001)'

if package_installed com.retroarch.aarch64; then
  RETROARCH_DIR='/sdcard/Android/data/com.retroarch.aarch64/files'
  "${ADB[@]}" shell am force-stop com.retroarch.aarch64 </dev/null
  deploy_device_file "$ROOT_DIR/config/retroarch/retroarch.cfg" \
    "$RETROARCH_DIR/retroarch.cfg" "$RETROARCH_DIR"
  deploy_device_file \
    "$ROOT_DIR/config/retroarch/autoconfig/android/Retroid_Pocket_Controller.cfg" \
    '/sdcard/RetroArch/autoconfig/android/Retroid_Pocket_Controller.cfg' \
    '/sdcard/RetroArch'
else
  note 'RetroArch is not installed; skipped its RP6 profile.'
fi

if package_installed org.dolphinemu.dolphinemu; then
  "$ROOT_DIR/scripts/configure-dolphin.sh"
else
  note 'Dolphin is not installed; skipped its RP6 profiles.'
fi

for package_name in \
  org.azahar_emu.azahar \
  me.magnum.melondualds \
  org.ppsspp.ppsspp \
  org.vita3k.emulator \
  com.armsx2 \
  com.izzy2lost.x1box \
  xendroid.compose \
  dev.eden.eden_emulator; do
  if package_installed "$package_name"; then
    note "Native Android gamepad input available: $package_name"
  fi
done

note 'Controller configuration complete.'
note 'RetroArch hotkeys: Select+R3 menu, Select+Start quit, Select+R1 save, Select+L1 load.'
