#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Building Divide (release, arm64)…"
swift build -c release --arch arm64

APP_NAME="Divide.app"
DIST_DIR="dist"
APP_DIR="$DIST_DIR/$APP_NAME"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp ".build/release/Divide" "$APP_DIR/Contents/MacOS/Divide"
cp "Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

echo "Ad-hoc code signing (required for Apple Silicon to run the binary)…"
codesign --force --deep --sign - "$APP_DIR"

echo "Built $APP_DIR"
echo "Install with: cp -R \"$APP_DIR\" /Applications/"
