#!/bin/bash
# Build a signed and notarized DMG installer for HMSL on macOS.
#
# Usage: scripts/release.sh [--skip-notarize]
#
# Output: build/HMSL_{version}.dmg
#
# Requires a "Developer ID Application" certificate in the keychain and
# notarytool credentials stored with:
#     xcrun notarytool store-credentials NOTARY_PROFILE ...
# Override the defaults with the SIGN_IDENTITY and NOTARY_PROFILE variables.

set -euo pipefail

SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Philip Burk (9D2MR4L34E)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-NOTARY_PROFILE}"
NOTARIZE=1
if [ "${1:-}" == "--skip-notarize" ]; then
    NOTARIZE=0
fi

HMSL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$HMSL_DIR/build"
STAGE_DIR="$BUILD_DIR/dmg"
APP="$STAGE_DIR/HMSL.app"
RESOURCES="$APP/Contents/Resources"
ENTITLEMENTS="$HMSL_DIR/native/juce/Builds/MacOSX/JuceHMSL - App.entitlements"

# Version comes from "#define HMSL_VERSION "v0.6.1"" in Main.cpp.
VERSION=$(sed -n 's/^#define HMSL_VERSION "v\(.*\)"/\1/p' "$HMSL_DIR/native/juce/Source/Main.cpp")
DMG="$BUILD_DIR/HMSL_${VERSION//./_}.dmg"

# Folders from "hmsl/" that are copied to the user's work folder.
HMSL_FOLDERS="pieces tools amiga screens fth users"

"$HMSL_DIR/scripts/build.sh" Release

echo "=== Assemble HMSL.app version $VERSION"
rm -rf "$STAGE_DIR" "$DMG"
mkdir -p "$STAGE_DIR"
ditto "$BUILD_DIR/JuceHMSL.app" "$APP"
cp "$HMSL_DIR/hmsl/pforth.dic" "$RESOURCES/"
mkdir -p "$RESOURCES/hmsl"
for folder in $HMSL_FOLDERS; do
    rsync -a --exclude .DS_Store "$HMSL_DIR/hmsl/$folder" "$RESOURCES/hmsl/"
done
PLIST="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName HMSL" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName HMSL" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST"
xattr -cr "$APP"

echo "=== Sign HMSL.app"
codesign --force --options runtime --timestamp \
    --entitlements "$ENTITLEMENTS" \
    --sign "$SIGN_IDENTITY" \
    "$APP"
codesign --verify --strict --deep --verbose=2 "$APP"

echo "=== Create $(basename "$DMG")"
ln -s /Applications "$STAGE_DIR/Applications"
hdiutil create -quiet -volname "HMSL $VERSION" -srcfolder "$STAGE_DIR" \
    -fs HFS+ -format UDZO "$DMG"
codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG"

if [ $NOTARIZE == 0 ]; then
    echo "=== Skipped notarization. $DMG is signed but will be blocked by Gatekeeper."
    exit 0
fi

echo "=== Notarize (this usually takes a few minutes)"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait \
    | tee "$BUILD_DIR/notarize.log"
if ! grep -q "status: Accepted" "$BUILD_DIR/notarize.log"; then
    SUBMISSION_ID=$(sed -n 's/^ *id: //p' "$BUILD_DIR/notarize.log" | head -1)
    echo "ERROR - notarization failed. Details:"
    xcrun notarytool log "$SUBMISSION_ID" --keychain-profile "$NOTARY_PROFILE"
    exit 1
fi

echo "=== Staple and verify"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
spctl -a -vvv -t open --context context:primary-signature "$DMG"

echo "=== Done: $DMG"
