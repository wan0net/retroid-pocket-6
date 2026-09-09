#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/config/device.env"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

select_device() {
  require_command adb

  local state serials count
  if [[ -n "${ADB_SERIAL:-}" ]]; then
    state="$(adb -s "$ADB_SERIAL" get-state 2>/dev/null || true)"
    [[ "$state" == device ]] || die "ADB_SERIAL '$ADB_SERIAL' is not connected and authorised"
    DEVICE_SERIAL="$ADB_SERIAL"
  else
    serials="$(adb devices | awk 'NR > 1 && $2 == "device" {print $1}')"
    count="$(awk 'NF {count++} END {print count+0}' <<<"$serials")"
    [[ "$count" -eq 1 ]] || die "expected exactly one authorised ADB device; found $count (set ADB_SERIAL if needed)"
    DEVICE_SERIAL="$serials"
  fi

  ADB=(adb -s "$DEVICE_SERIAL")
}

prop() {
  "${ADB[@]}" shell getprop "$1" | tr -d '\r'
}

assert_expected_device() {
  select_device

  local model device product display abi api identity mismatch=0
  model="$(prop ro.product.model)"
  device="$(prop ro.product.device)"
  product="$(prop ro.product.name)"
  display="$(prop ro.build.display.id)"
  abi="$(prop ro.product.cpu.abi)"
  api="$(prop ro.build.version.sdk)"
  identity="$model $device $product $display"

  note "Device: $model (serial $DEVICE_SERIAL, Android API $api, ABI $abi)"

  [[ "$identity" =~ $EXPECTED_IDENTITY_REGEX ]] || mismatch=1
  [[ "$abi" =~ $EXPECTED_ABI_REGEX ]] || mismatch=1
  [[ "$api" =~ ^[0-9]+$ ]] && (( api >= MIN_ANDROID_API )) || mismatch=1

  if (( mismatch )); then
    if [[ "${ALLOW_UNVERIFIED_DEVICE:-0}" == 1 ]]; then
      note 'WARNING: device identity policy failed; continuing because ALLOW_UNVERIFIED_DEVICE=1'
    else
      die "device does not match config/device.env; refusing to make changes"
    fi
  fi
}

package_installed() {
  "${ADB[@]}" shell pm path "$1" </dev/null >/dev/null 2>&1
}

ensure_device_dir() {
  # Do not let adb consume a caller's loop or pipeline input.
  "${ADB[@]}" shell mkdir -p "$1" </dev/null
}

find_microsd_mount() {
  local volume_ids count volume_id mount_path
  volume_ids="$("${ADB[@]}" shell sm list-volumes public \
    | tr -d '\r' \
    | awk '$2 == "mounted" && $3 != "null" {print $3}')"
  count="$(awk 'NF {count++} END {print count+0}' <<<"$volume_ids")"
  [[ "$count" -eq 1 ]] || die "expected exactly one mounted public microSD volume; found $count"

  volume_id="$volume_ids"
  [[ "$volume_id" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*-[A-Za-z0-9_-]+$ ]] \
    || die "refusing unexpected microSD volume identifier: $volume_id"
  mount_path="/storage/$volume_id"
  "${ADB[@]}" shell test -d "$mount_path" \
    || die "microSD mount does not exist: $mount_path"
  "${ADB[@]}" shell test -w "$mount_path" \
    || die "microSD mount is not writable: $mount_path"

  printf '%s\n' "$mount_path"
}
