# CornerCal

[![Latest release](https://img.shields.io/github/v/release/tak-bro/CornerCal)](https://github.com/tak-bro/CornerCal/releases/latest)
![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue)
![Apple Silicon + Intel](https://img.shields.io/badge/arch-Apple%20Silicon%20%2B%20Intel-blue)
[![License: MIT](https://img.shields.io/github/license/tak-bro/CornerCal)](LICENSE)

A simple, clean clock and calendar for the macOS menu bar. Inspired by [Itsycal](https://github.com/sfsam/Itsycal), but deliberately simpler and true to macOS' native style.

**[Download the latest DMG](https://github.com/tak-bro/CornerCal/releases/latest)** — free, open source, runs natively on Apple Silicon and Intel Macs with macOS 12 or later.

![preview](screenshot-01.png)

CornerCal was created by [Emil Kreutzman](https://github.com/ekreutz/CornerCal) in 2017. Its last release, 1.1, is an Intel-only binary built with Xcode 10, so it no longer opens on Macs without Rosetta. This repository continues the project: same app, rebuilt as a universal binary for current macOS and signed with a Developer ID.

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
| "CornerCal can't be opened because Apple cannot check it" | The download isn't notarized yet. Right-click `CornerCal.app` › Open, or System Settings › Privacy & Security › Open Anyway. |
| Reset all settings | Quit CornerCal, then run `defaults delete com.ekreutz.CornerCal`. |

## FAQ

**Does CornerCal work on Apple Silicon (M-series) Macs?**
Yes. Since 1.2.0 the app is a universal binary and runs natively, without Rosetta.

**Why won't my old CornerCal open (`LSOpen` error `-10669`)?**
CornerCal 1.1 is Intel-only. macOS versions without Rosetta can't run it. Install 1.2.0 or later from [Releases](https://github.com/tak-bro/CornerCal/releases/latest); your settings carry over.

**Is the Homebrew cask (`brew install --cask cornercal`) this version?**
No. That cask still points to the original 1.1 build and is disabled. Use the DMG from Releases.

**How is CornerCal different from Itsycal?**
Itsycal shows calendar events. CornerCal is only a clock and a month view, with no events, accounts, or network access.

**Is it free?**
Yes, MIT-licensed. There is no telemetry and the app is sandboxed.

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

One-time: store notarization credentials in the keychain, either with an App Store Connect API key (Users and Access › Integrations › Keys) or an Apple ID with an [app-specific password](https://support.apple.com/en-us/102654).

```sh
# API key
xcrun notarytool store-credentials cornercal-notary \
  --key <path/to/AuthKey_XXXX.p8> --key-id <key-id> --issuer <issuer-id>
# or Apple ID
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
