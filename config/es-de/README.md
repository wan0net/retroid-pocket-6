# ES-DE configuration boundary

ES-DE is the frontend, but its Android APK is not redistributed here. The
Android build is paid software. Supply your own APK to `bootstrap.sh` or install
it manually, then complete its first-run storage selection on the device.

The reviewed custom-system files under `custom_systems/` are deployed by
`make configure-es-de`. They add direct launch support for Eden, X1 BOX and
XenDroid alongside the ARMSX2 compatibility rule. Before replacing either
managed file, the toolkit retains the original once with the suffix
`.rp6-before-automation`.

For the dual-screen profile, enable **Custom Event Scripts**, **Browsing Custom
Event Scripts**, and **Debug Mode** in ES-DE before completing ES-DE Companion's
onboarding. These settings and Android's all-files permission remain manual.
