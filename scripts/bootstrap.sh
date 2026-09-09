#!/usr/bin/env bash

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ROOT_DIR is resolved at runtime.
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

profile=standard
esde_apk=''
while (( $# )); do
  case "$1" in
    --profile) profile="${2:-}"; shift 2 ;;
    --es-de-apk) esde_apk="${2:-}"; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done
[[ "$profile" == standard || "$profile" == dual-screen ]] || die "profile must be standard or dual-screen"
[[ -z "$esde_apk" || -f "$esde_apk" ]] || die "ES-DE APK not found: $esde_apk"

require_command curl
require_command jq
assert_expected_device

cache_dir="$ROOT_DIR/work/downloads"
mkdir -p "$cache_dir"

if package_installed dev.imranr.obtainium && [[ "${FORCE_OBTAINIUM_UPDATE:-0}" != 1 ]]; then
  note 'Obtainium is already installed; leaving it unchanged.'
else
  note 'Downloading the latest upstream Obtainium arm64 APK...'
  api_url='https://api.github.com/repos/ImranR98/Obtainium/releases/latest'
  api_json="$(curl --fail --silent --show-error --location "$api_url")"
  apk_url="$(jq -r '.assets[] | select(.name == "app-arm64-v8a-release.apk") | .browser_download_url' <<<"$api_json" | head -1)"
  sum_url="$(jq -r '.assets[] | select(.name == "app-arm64-v8a-release.apk.sha256") | .browser_download_url' <<<"$api_json" | head -1)"
  [[ "$apk_url" == https://github.com/ImranR98/Obtainium/releases/download/* ]] || die 'could not resolve the upstream Obtainium APK'
  [[ "$sum_url" == https://github.com/ImranR98/Obtainium/releases/download/* ]] || die 'could not resolve the upstream Obtainium checksum'

  apk_path="$cache_dir/app-arm64-v8a-release.apk"
  sum_path="$cache_dir/app-arm64-v8a-release.apk.sha256"
  curl --fail --silent --show-error --location --output "$apk_path" "$apk_url"
  curl --fail --silent --show-error --location --output "$sum_path" "$sum_url"
  expected_sum="$(awk '{print $1; exit}' "$sum_path")"
  if command -v sha256sum >/dev/null 2>&1; then
    actual_sum="$(sha256sum "$apk_path" | awk '{print $1}')"
  else
    require_command shasum
    actual_sum="$(shasum -a 256 "$apk_path" | awk '{print $1}')"
  fi
  [[ "$actual_sum" == "$expected_sum" ]] || die 'Obtainium APK checksum verification failed'
  "${ADB[@]}" install -r "$apk_path"
fi

if [[ -n "$esde_apk" ]]; then
  note 'Installing the user-supplied ES-DE APK...'
  "${ADB[@]}" install -r "$esde_apk"
fi

ensure_device_dir "$DEVICE_PROJECT_DIR"
manifest="$ROOT_DIR/obtainium/apps.json"
[[ "$profile" == dual-screen ]] && manifest="$ROOT_DIR/obtainium/apps-dual-screen.json"
obtainium_import='/sdcard/Download/obtainium-import.json'
"${ADB[@]}" push "$manifest" "$obtainium_import" >/dev/null

note "Staged the $profile Obtainium import at $obtainium_import"
note 'Manual next step: Obtainium -> Import/Export -> Obtainium Import, then select that file.'
