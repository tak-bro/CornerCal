# CornerCal - a better clock app for macOS

A simple, clean calendar and clock app for the macOS menu bar. Inspired by [Itsycal](https://github.com/sfsam/Itsycal), but purposefully constructed to be a lot simpler and adhere to macOS' native styles.

![preview](screenshot-01.png)

This is a maintained fork of [ekreutz/CornerCal](https://github.com/ekreutz/CornerCal). The original 1.1 release is an Intel-only binary built with Xcode 10, so it no longer launches on macOS versions without Rosetta (`LSOpen` error `-10669`). This fork rebuilds it as a universal (Apple Silicon + Intel) app for current macOS.

## Download

Get `CornerCal-<version>.dmg` from the [latest release](https://github.com/tak-bro/CornerCal/releases/latest).

1. Open the DMG and drag `CornerCal.app` into `Applications`.
2. Launch CornerCal. The clock appears in the menu bar; it has no Dock icon.
3. To start it at login, add it in System Settings › General › Login Items.

Requirements: macOS 12 Monterey or later, Apple Silicon or Intel.

The app is signed with a Developer ID and notarized by Apple, so Gatekeeper opens it without warnings. Your existing settings carry over from the original app because the bundle identifier (`com.ekreutz.CornerCal`) is unchanged.

*Pro tip:* hold `⌘` and drag menu bar items to reorder them. You can hide the native clock in System Settings › Control Center › Clock Options to avoid clutter.

## Changes from upstream

- Builds with current Xcode: Swift 5, deployment target macOS 12.0.
- Universal binary (`arm64` + `x86_64`).
- Replaced APIs removed or deprecated since Swift 4 (`NSAttributedString.Key`, `RunLoop.Mode.common`, `NSStatusItem.button`).
- Hardened runtime, Developer ID signing, and notarization through `scripts/release.sh`.
- Prebuilt binaries moved from `builds/` to GitHub Releases.

## Build from source

Requirements: Xcode 15 or later.

```sh
git clone https://github.com/tak-bro/CornerCal.git
cd CornerCal
open CornerCal.xcodeproj   # then Product › Run
```

Or from the command line, unsigned:

```sh
xcodebuild -project CornerCal.xcodeproj -scheme CornerCal -configuration Release \
  -derivedDataPath build/DerivedData CODE_SIGN_IDENTITY=- build
open build/DerivedData/Build/Products/Release/CornerCal.app
```

## Release

`scripts/release.sh` builds a universal Release app, signs it with hardened runtime, packages `build/CornerCal-<version>.dmg`, then notarizes and staples it.

One-time setup, storing notarization credentials in the keychain (use an [app-specific password](https://support.apple.com/en-us/102654)):

```sh
xcrun notarytool store-credentials cornercal-notary \
  --apple-id <apple-id> --team-id <team-id>
```

Then:

```sh
SIGN_IDENTITY="Developer ID Application: <name> (<team-id>)" TEAM_ID=<team-id> \
  scripts/release.sh
gh release create v<version> build/CornerCal-<version>.dmg
```

`NOTARIZE=0 scripts/release.sh` skips notarization for a local test build. The version comes from `CFBundleShortVersionString` in `CornerCal/Info.plist`.

## Scope

Features that you won't see in CornerCal:

- Custom calendar features such as events and reminders.
- Heavy themes that don't fit the style of macOS.

## License

MIT. Original work © 2017 Emil Kreutzman; see [LICENSE](LICENSE).
