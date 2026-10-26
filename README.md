# CornerCal

A simple, clean clock and calendar for the macOS menu bar. Inspired by [Itsycal](https://github.com/sfsam/Itsycal), but deliberately simpler and true to macOS' native style.

![preview](screenshot-01.png)

CornerCal was created by [Emil Kreutzman](https://github.com/ekreutz/CornerCal) in 2017. Its last release, 1.1, is an Intel-only binary built with Xcode 10, so it no longer opens on Macs without Rosetta. This repository continues the project: same app, rebuilt as a universal binary for current macOS, signed and notarized.

## Features

- Clock in the menu bar. Click it to open a month calendar with today highlighted.
- `◀` / `▶` step through months; click the month title to jump back to today.
- Settings (menu › Settings):
  - Time: show seconds, 24-hour clock, AM/PM (12-hour clock only)
  - Date: show date, show day of the week
- Follows the system appearance, including Dark Mode.
- No Dock icon, no network access, sandboxed.

Out of scope on purpose: events, reminders, and custom themes.

## Install

1. Download `CornerCal-<version>.dmg` from the [latest release](https://github.com/tak-bro/CornerCal/releases/latest).
2. Open the DMG and drag `CornerCal.app` into `Applications`.
3. Launch CornerCal from Applications. The clock appears in the menu bar.
4. Optional: start at login via System Settings › General › Login Items.

Requires macOS 12 Monterey or later, on Apple Silicon or Intel.

Tips:

- Hold `⌘` and drag menu bar items to reorder them.
- Hide the built-in clock in System Settings › Control Center › Clock Options to avoid showing the time twice.

### Upgrading from CornerCal 1.1

Replace the old `CornerCal.app` in Applications with the new one. Your settings carry over: the bundle identifier (`com.ekreutz.CornerCal`) is unchanged. Add it to Login Items again if it was there before, since the signature changed.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| Old CornerCal won't open, `LSOpen` error `-10669` | You're running the Intel-only 1.1 build. Install the current release. |
| Clock not visible after launch | The menu bar is full or the item is hidden by a menu bar manager (Hidden Bar, Bartender, Ice). Expand it, or `⌘`-drag CornerCal to the right. |
| Reset all settings | Quit CornerCal, then run `defaults delete com.ekreutz.CornerCal`. |

## Build from source

Requires Xcode 15 or later.

```sh
git clone https://github.com/tak-bro/CornerCal.git
cd CornerCal
open CornerCal.xcodeproj   # Product › Run
```

Unsigned command-line build:

```sh
xcodebuild -project CornerCal.xcodeproj -scheme CornerCal -configuration Release \
  -derivedDataPath build/DerivedData CODE_SIGN_IDENTITY=- build
open build/DerivedData/Build/Products/Release/CornerCal.app
```

## Releasing

`scripts/release.sh` builds a universal Release app with hardened runtime, signs it with a Developer ID, packages `build/CornerCal-<version>.dmg`, then notarizes and staples it. It fails if the signature carries `get-task-allow`, which notarization rejects. The version comes from `CFBundleShortVersionString` in `CornerCal/Info.plist`.

One-time: store notarization credentials in the keychain, using an [app-specific password](https://support.apple.com/en-us/102654).

```sh
xcrun notarytool store-credentials cornercal-notary \
  --apple-id <apple-id> --team-id <team-id>
```

Each release:

```sh
SIGN_IDENTITY="Developer ID Application: <name> (<team-id>)" TEAM_ID=<team-id> \
  scripts/release.sh
gh release create v<version> build/CornerCal-<version>.dmg --notes-file <notes>
```

`NOTARIZE=0 scripts/release.sh` skips notarization for a local test build.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. Original work © 2017 Emil Kreutzman, see [LICENSE](LICENSE).
