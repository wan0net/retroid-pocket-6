# Retroid Pocket 6, as code

Idempotent, reviewable provisioning for a Retroid Pocket 6 using ADB, shell and
Obtainium. ES-DE is the frontend. The normal posture is no Google account, no
Play Store dependency, and reversible disabling of optional Google apps.

The repository contains no ROMs, BIOS/firmware, console keys, paid APKs,
credentials or user data.

## What it does

- refuses to mutate a device unless its Android identity, API level and ABI
  match the committed RP6 policy;
- installs Obtainium from its latest upstream GitHub release after checking the
  publisher-provided SHA-256;
- stages a small, auditable Obtainium import for either a standard RP6 or the
  Retroid Dual Screen add-on;
- discovers one mounted microSD card and creates the empty ROM hierarchy there;
- uses ES-DE's canonical system directory names such as `n3ds`, `nds`, `gc`,
  `psx`, `ps2`, `psp`, `psvita` and `wii`;
- creates predictable internal BIOS/ES-DE working directories;
- installs reproducible RP6 controller profiles for Dolphin when Dolphin is
  present, including a sideways Wii Remote profile for supported games;
- reports installed apps and remaining manual work without scraping private
  account state;
- disables optional Google applications for the primary user without deleting
  their system APKs or touching core Android/Google runtime components;
- leaves launcher choice, permissions and logins alone.

## Requirements

On the host: Bash 3.2+, ADB, `curl` and `jq`. `ruby` and `shellcheck` are used
for complete local validation when available. On the RP6: enable Developer
options and USB debugging, then approve the host's debugging key.

## Quick start

```sh
git clone https://github.com/wan0net/retroid-pocket-6.git
cd retroid-pocket-6
make validate
make check-device
make bootstrap PROFILE=standard
make configure
make verify PROFILE=standard
```

For the Retroid Dual Screen add-on, substitute `PROFILE=dual-screen`. The
bootstrap stages `obtainium-import.json` in the device's
top-level `Download` directory so Android's document picker can expose it
reliably. Review and import it from Obtainium's
**Import/Export -> Obtainium Import** screen.

If more than one device is attached, select one explicitly:

```sh
ADB_SERIAL=0123456789ABCDEF make check-device
```

The serial is never stored. If a legitimate RP6 firmware reports an unexpected
identity, inspect `adb shell getprop` and update `config/device.env`; do not use
the break-glass override casually.

## App catalogue

Both profiles include GameNative (for games already owned on Steam/Epic/GOG),
RetroArch AArch64, Dolphin, Azahar, PPSSPP, Vita3K, ARMSX2 and Moonlight.

- Standard uses upstream melonDS.
- Dual-screen swaps in WatermelonDS and adds ES-DE Companion.
- ES-DE itself is manual because its Android build is paid and cannot be
  redistributed. The toolkit can install a locally supplied APK with
  `--es-de-apk`, but never downloads or commits it.

ARMSX2 is the open-source ARM64 PS2 choice. It is actively developed but less
mature than long-established emulators, so compatibility varies. NetherSX2 is
not bundled because its normal workflow patches a user-supplied proprietary
AetherSX2 APK; advanced users can add that workflow locally without publishing
the base APK.

ES-DE Companion is a semi-official dual-screen project and currently evolving
quickly. Its core workflow is viable, but treat upgrades as changes to test.

See [the manual checklist](docs/manual-steps.md) for ES-DE licensing/download,
Steam login, permission prompts, ROM/BIOS ownership and dual-screen onboarding.

## Commands and safety

`make bootstrap`, `make configure` and `make configure-dolphin` are safe to
repeat. `make configure`
requires exactly one mounted, writable public microSD volume and refuses to
guess if none or multiple are present. It disables the optional packages listed
in `config/optional-google-apps.txt` using Android's reversible `disable-user`
operation. Use `make restore-google-apps` to re-enable them. An existing Obtainium
install is left untouched; set `FORCE_OBTAINIUM_UPDATE=1` to reinstall the
current upstream version. Directories are created with `mkdir -p`. Existing
ES-DE configuration is never overwritten.

When Dolphin is installed, `make configure` also installs the committed RP6
controller mappings. Run `make configure-dolphin` to repeat only that step.
Before the first replacement, Dolphin's active controller files are preserved
beside them with a `.rp6-before-automation` suffix. The default Wii mapping is
Wii Remote + Nunchuk; New Super Mario Bros. Wii (`SMNP01`) automatically uses
the sideways profile. Other games can select `RP6-Wii-Nunchuk`,
`RP6-Wii-Sideways` or `RP6-Wii-Classic` from Dolphin's profiles screen.

`make verify` reports gaps but exits successfully after the device safety gate.
Use `make verify-strict` when every selected app and directory must exist.

`ALLOW_UNVERIFIED_DEVICE=1` bypasses the RP6 identity check. It exists only for
recovery and policy updates and is deliberately noisy.

## Layout

```text
apps.yaml                 Human-readable desired catalogue
obtainium/                Importable standard and dual-screen exports
config/device.env         Fail-closed RP6 identity and path policy
config/optional-google-apps.txt
                          Reversible, narrowly scoped debloat policy
config/es-de/             Non-destructive ES-DE extension hooks
config/dolphin/           RP6 controller profiles and per-game selections
scripts/                  Bootstrap, configure, verify and validation logic
docs/manual-steps.md      Work that remains intentionally interactive
```

## Licence

Toolkit code and documentation are available under the MIT License. Apps named
in the catalogue remain under their own licences and are downloaded from their
respective sources. See `THIRD_PARTY_NOTICES.md` for configuration provenance.
