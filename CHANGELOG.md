# Changelog

## 1.2.0

- Universal binary (Apple Silicon + Intel). The 1.1 build was Intel-only and fails to open without Rosetta (`LSOpen` error `-10669`).
- Requires macOS 12 Monterey or later (was 10.12 Sierra).
- Built with Swift 5 and current Xcode; replaced APIs removed since Swift 4.
- Fixed: the menu bar clock froze until clicked on current macOS.
- Signed with a Developer ID, hardened runtime, notarized.
- Distributed as a DMG on GitHub Releases instead of zip files in the repository.

## 1.1

Last release by Emil Kreutzman, [ekreutz/CornerCal](https://github.com/ekreutz/CornerCal).
