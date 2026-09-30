#!/bin/bash
# Build JuceHMSL.app and compile the HMSL dictionary "hmsl/pforth.dic".
#
# Usage: scripts/build.sh [Debug|Release]
#
# The app is placed in "build/JuceHMSL.app" and is signed ad hoc,
# which is fine for running locally. Use scripts/release.sh to make
# a signed and notarized release.

set -euo pipefail

CONFIG="${1:-Release}"
HMSL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$HMSL_DIR/build"
PROJECT="$HMSL_DIR/native/juce/Builds/MacOSX/JuceHMSL.xcodeproj"
APP="$BUILD_DIR/JuceHMSL.app"

echo "=== Update pForth submodule"
git -C "$HMSL_DIR" submodule update --init

echo "=== Build JuceHMSL.app ($CONFIG)"
rm -rf "$APP" # remove leftovers such as an old sanitizer library
xcodebuild -quiet \
    -project "$PROJECT" \
    -scheme "JuceHMSL - App" \
    -configuration "$CONFIG" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -enableAddressSanitizer NO \
    ENABLE_ADDRESS_SANITIZER=NO \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
    CODE_SIGN_IDENTITY=- \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM= \
    build

echo "=== Compile pForth and HMSL dictionary"
"$APP/Contents/MacOS/JuceHMSL" --build-dictionary

echo "=== Done. Run HMSL with:  open \"$APP\""
