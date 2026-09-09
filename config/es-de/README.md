# ES-DE configuration boundary

ES-DE is the frontend, but its Android APK is not redistributed here. The
Android build is paid software. Supply your own APK to `bootstrap.sh` or install
it manually, then complete its first-run storage selection on the device.

This directory is intentionally a hook point rather than a copy of one person's
home setup. Place reviewed custom-system fragments under `custom_systems/` and
add an explicit deployment step before automating them. The toolkit will not
overwrite an existing ES-DE configuration by default.

For the dual-screen profile, enable **Custom Event Scripts**, **Browsing Custom
Event Scripts**, and **Debug Mode** in ES-DE before completing ES-DE Companion's
onboarding. These settings and Android's all-files permission remain manual.
