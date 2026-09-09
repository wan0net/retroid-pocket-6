# Manual steps

Some state is intentionally not automated because it is licensed, secret, or
guarded by an Android confirmation screen.

1. On the RP6, enable Developer options and USB debugging, connect USB, and
   approve this computer's debugging key.
2. Run `make check-device`, then `make bootstrap PROFILE=dual-screen` if the
   Retroid Dual Screen add-on will be used.
3. In Obtainium, import
   `/sdcard/Download/retroid-pocket-6/obtainium-import.json`, review the list,
   and install the selected apps. Android may ask for permission to install
   unknown apps.
4. Buy/download your own Android copy of ES-DE. Either install it manually or
   run `./scripts/bootstrap.sh --profile dual-screen --es-de-apk local/ES-DE.apk`.
5. In ES-DE, select ROM and media locations, grant requested storage access,
   configure systems, scrape media, and choose ES-DE as the launcher only if
   desired.
6. Sign in to Steam inside GameNative. Credentials are entered on-device and
   never belong in this repository.
7. Supply only your own ROMs, BIOS/firmware, keys and game files. Nothing in
   this project downloads them.
8. For ES-DE Companion, follow its onboarding and grant all-files access. Enable
   Custom Event Scripts, Browsing Custom Event Scripts and Debug Mode in ES-DE.

No Google account is required. This project does not disable or remove Google
system packages; leaving them unsigned-in is the default posture.
