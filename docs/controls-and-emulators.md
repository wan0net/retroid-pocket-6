# Controls and emulator defaults

`make configure` applies both the controller configuration and the ES-DE
system-wide emulator choices. They can also be repeated independently:

```sh
make configure-controls
make configure-es-de
```

The scripts stop an affected app before replacing a configuration file. The
first displaced file is retained beside it with the suffix
`.rp6-before-automation`. A repeat run compares content and makes no change
when the desired file is already present.

## Controller behavior

- **RetroArch:** the RP6 is committed as an Android RetroPad profile, including
  both sticks, D-pad, face buttons, shoulders, triggers, stick clicks, Start and
  Select. Hold Select with R3 for the RetroArch menu, Start to quit, R1 to save
  state, or L1 to load state. Saving the global configuration on exit is
  disabled so RetroArch does not rewrite the managed file; make global changes
  in the repository instead.
- **Dolphin:** GameCube, Wii Remote + Nunchuk, sideways Wii Remote and Wii
  Classic Controller profiles are installed. `SMNP01` selects the sideways
  profile automatically.
- **Azahar, WatermelonDS/melonDS, PPSSPP, Vita3K, ARMSX2, X1 BOX, XenDroid and
  Eden:** these consume the
  RP6's standard Android gamepad interface. Their Android releases store most
  control preferences in private app storage, which ADB cannot safely replace
  on an unrooted device. Defaults are therefore used unless a particular game
  needs an emulator-specific override.
- **Moonlight and GameNative:** Android gamepad input is passed through to the
  streamed or translated game. Game-specific PC bindings remain the game's
  responsibility.

The physical controller identity expected by the RetroArch profile is
`Retroid Pocket Controller`, USB vendor `0x2022`, product `0x3001`. A firmware
change that reports a different identity should fail verification rather than
silently apply a mismatched profile.

## ES-DE choices

The complete mapping is stored in `config/es-de/emulators.tsv`. Standalone
apps are selected for GameCube/Wii, Nintendo 3DS, Nintendo DS, PlayStation 2,
PSP and Vita. Systems supported by RetroArch use a curated core appropriate to
the RP6:

| Systems | Emulator/core |
| --- | --- |
| GameCube, Wii | Dolphin (Standalone) |
| Nintendo 3DS | Azahar (Standalone) |
| Nintendo DS | melonDS (Standalone) |
| PlayStation 2 | ARMSX2 (Standalone) |
| PSP | PPSSPP (Standalone) |
| PlayStation Vita | Vita3K (Standalone) |
| Nintendo Switch | Eden (Standalone) |
| Microsoft Xbox | X1 BOX (Standalone) |
| Microsoft Xbox 360 | XenDroid (Standalone) |
| Arcade | MAME - Current |
| Atari 2600 | Stella |
| Dreamcast | Flycast |
| Game Boy, Game Boy Color | Gambatte |
| Game Boy Advance | mGBA |
| Genesis, Master System | Genesis Plus GX |
| Nintendo 64 | Mupen64Plus-Next |
| NES | Mesen |
| PC Engine | Beetle PCE |
| PlayStation | SwanStation |
| Saturn | Beetle Saturn |
| SNES | Snes9x - Current |

ES-DE stores a system-wide choice in that system's `gamelist.xml`. The script
changes only its `alternativeEmulator` block. Existing game entries, scraped
metadata, favourites, play counts and play time remain untouched.

ES-DE 3.4.1 does not bundle all three launch definitions, so the toolkit also
manages `custom_systems/es_find_rules.xml` and `custom_systems/es_systems.xml`.
These define the package activities and Android intents used for direct game
launches. Restart ES-DE after changing or upgrading these emulators.

RetroArch cores themselves must be installed using RetroArch's **Online
Updater -> Core Downloader**. Android keeps the core directory private, so a
non-root ADB process cannot safely populate it. Install the core named in the
table before launching that system from ES-DE.
