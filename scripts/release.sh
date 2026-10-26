#!/usr/bin/env bash
# Build, sign, package, notarize and staple CornerCal.dmg.
#
# Usage:
#   scripts/release.sh                 # build + sign + dmg + notarize + staple
#   NOTARIZE=0 scripts/release.sh      # skip notarization (local test build)
#
# Environment:
#   SIGN_IDENTITY   codesign identity (default: Developer ID Application: Hyungtak Jin (B6JKGK3DTK))
#   TEAM_ID         Apple developer team id (default: B6JKGK3DTK)
#   NOTARY_PROFILE  notarytool keychain profile (default: cornercal-notary)
#                   create once with: xcrun notarytool store-credentials cornercal-notary \
#                     --apple-id <apple-id> --team-id <team-id>
set -euo pipefail

cd "$(dirname "$0")/.."

SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Hyungtak Jin (B6JKGK3DTK)}"
TEAM_ID="${TEAM_ID:-B6JKGK3DTK}"
NOTARY_PROFILE="${NOTARY_PROFILE:-cornercal-notary}"
NOTARIZE="${NOTARIZE:-1}"

BUILD_DIR="build"
DERIVED="$BUILD_DIR/DerivedData"
APP="$DERIVED/Build/Products/Release/CornerCal.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' CornerCal/Info.plist)"
DMG="$BUILD_DIR/CornerCal-$VERSION.dmg"
STAGE="$BUILD_DIR/dmg-stage"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Building CornerCal $VERSION (universal)"
# CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO keeps com.apple.security.get-task-allow
# out of the release signature; notarization rejects it.
xcodebuild \
  -project CornerCal.xcodeproj \
  -scheme CornerCal \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_IDENTITY="$SIGN_IDENTITY" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  ENABLE_HARDENED_RUNTIME=YES \
  OTHER_CODE_SIGN_FLAGS=--timestamp \
  clean build | grep -E '^\*\*|error:|warning:' || true

[ -d "$APP" ] || { echo "build failed: $APP missing" >&2; exit 1; }
codesign --verify --deep --strict "$APP"
if codesign -d --entitlements - "$APP" 2>/dev/null | grep -q get-task-allow; then
  echo "get-task-allow present in release signature" >&2
  exit 1
fi

echo "==> Packaging $DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
# `diskutil image` replaces the deprecated `hdiutil create` on macOS 27+.
if diskutil image create from --help >/dev/null 2>&1; then
  diskutil image create from --format UDZO --volumeName CornerCal "$STAGE" "$DMG" >/dev/null
else
  hdiutil create -volname CornerCal -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
fi
rm -rf "$STAGE"
codesign --sign "$SIGN_IDENTITY" --timestamp "$DMG"

if [ "$NOTARIZE" = "1" ]; then
  echo "==> Notarizing (profile: $NOTARY_PROFILE)"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
  spctl -a -t open --context context:primary-signature -vv "$DMG"
fi

shasum -a 256 "$DMG"
echo "==> Done: $DMG"
