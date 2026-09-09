# Cocoon configuration boundary

Cocoon Shell is the preferred visible launcher, while ES-DE remains installed
as a fallback and metadata source. Android's Storage Access Framework and Home
app confirmation dialogs require on-device approval, so the toolkit does not
inject Cocoon's private application data or force a default launcher.

Use these values during Cocoon's setup wizard:

- ROM root: the `ROMs` directory on the mounted microSD card
- ES-DE integration folder: `/sdcard/ES-DE`
- organization mode: Smart Folders

Before making Cocoon the default Home app, confirm that controller navigation
works and launch at least one game from RetroArch, Dolphin and a standalone
emulator. Leave credentials and optional ScreenScraper, SteamGridDB and Discord
tokens on the device; never add them to this repository.

To return to the Android launcher, open Android Settings, search for **Home
app**, and select the system launcher or ES-DE. Cocoon's package name is
`rip.moth.cocoonshell`.
