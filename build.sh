#!/bin/sh
set -eu

APP_DIR="DiskWidget.app"
APPEX_DIR="$APP_DIR/Contents/PlugIns/DiskWidgetWidget.appex"
APPEX_RES_DIR="$APPEX_DIR/Contents/Resources"

mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"
mkdir -p "$APPEX_DIR/Contents/MacOS"
mkdir -p "$APPEX_RES_DIR"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key><string>磁盘小组件</string>
  <key>CFBundleExecutable</key><string>DiskWidget</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleIdentifier</key><string>local.adc.disk-widget</string>
  <key>CFBundleName</key><string>DiskWidget</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.1.0</string>
  <key>CFBundleVersion</key><string>110</string>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>local.adc.disk-widget.url</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>diskwidget</string>
      </array>
    </dict>
  </array>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

if [ -f "Assets/AppIcon.icns" ]; then
  cp "Assets/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

cp WidgetExtension/Info.plist "$APPEX_DIR/Contents/Info.plist"

TMP_BUILD=$(mktemp -d)
trap 'rm -rf "$TMP_BUILD"' EXIT

# Build host app (copy DiskWidget.swift to main.swift in temp dir so Swift allows top-level entry alongside Shared/)
cp DiskWidget.swift "$TMP_BUILD/main.swift"

swiftc -target arm64-apple-macos13.0 \
  "$TMP_BUILD/main.swift" \
  Shared/DiskWidgetSnapshot.swift \
  -o "$APP_DIR/Contents/MacOS/DiskWidget" \
  -framework AppKit \
  -framework WidgetKit

# Build native WidgetKit extension (.appex) for macOS 14+ desktop & notification center widgets
swiftc -module-name DiskWidgetWidget -parse-as-library -application-extension -target arm64-apple-macos14.0 \
  -Xlinker -e -Xlinker _NSExtensionMain \
  WidgetExtension/DiskWidgetExtension.swift \
  Shared/DiskWidgetSnapshot.swift \
  -o "$APPEX_DIR/Contents/MacOS/DiskWidgetWidget" \
  -framework WidgetKit \
  -framework SwiftUI \
  -framework AppIntents \
  -framework Foundation

# Extract AppIntents metadata (Metadata.appintents/extract.actionsdata) so WidgetConfigurationIntent & Button(intent:)
# register cleanly with macOS ChronoCore / WidgetKit (just like Xcode-built WidgetKit extensions).
METADATA_PROC=$(xcrun --find appintentsmetadataprocessor 2>/dev/null || true)
if [ -n "$METADATA_PROC" ] && [ -x "$METADATA_PROC" ]; then
  cat > "$TMP_BUILD/protocols.json" <<'JSON'
["AppEntity","AppEnum","AppIntent","AppIntentsPackage","DynamicOptionsProvider","EntityQuery","IntentValueQuery","WidgetConfigurationIntent"]
JSON
  cat > "$TMP_BUILD/output_map.json" <<JSON
{
  "WidgetExtension/DiskWidgetExtension.swift": {
    "const-values": "$TMP_BUILD/DiskWidgetExtension.swiftconstvalues",
    "object": "$TMP_BUILD/DiskWidgetExtension.o"
  },
  "Shared/DiskWidgetSnapshot.swift": {
    "const-values": "$TMP_BUILD/DiskWidgetSnapshot.swiftconstvalues",
    "object": "$TMP_BUILD/DiskWidgetSnapshot.o"
  }
}
JSON
  echo "$TMP_BUILD/DiskWidgetExtension.swiftconstvalues" > "$TMP_BUILD/const_list.txt"
  echo "$TMP_BUILD/DiskWidgetSnapshot.swiftconstvalues" >> "$TMP_BUILD/const_list.txt"
  echo "$PWD/WidgetExtension/DiskWidgetExtension.swift" > "$TMP_BUILD/src_list.txt"
  echo "$PWD/Shared/DiskWidgetSnapshot.swift" >> "$TMP_BUILD/src_list.txt"

  swiftc -module-name DiskWidgetWidget -parse-as-library -application-extension -target arm64-apple-macos14.0 \
    -Xfrontend -const-gather-protocols-file -Xfrontend "$TMP_BUILD/protocols.json" \
    -emit-const-values -output-file-map "$TMP_BUILD/output_map.json" \
    -c WidgetExtension/DiskWidgetExtension.swift Shared/DiskWidgetSnapshot.swift

  rm -rf "$APPEX_RES_DIR/Metadata.appintents"
  "$METADATA_PROC" \
    --output "$APPEX_RES_DIR" \
    --toolchain-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain \
    --module-name DiskWidgetWidget \
    --sdk-root "$(xcrun --show-sdk-path)" \
    --xcode-version 17B52 \
    --platform-family macOS \
    --deployment-target 14.0 \
    --target-triple arm64-apple-macosx14.0 \
    --source-file-list "$TMP_BUILD/src_list.txt" \
    --swift-const-vals-list "$TMP_BUILD/const_list.txt" \
    --force >/dev/null
fi

# Sign embedded WidgetKit extension first, then host app.
# Prefer Apple Development (for TeamID-backed App Group containers), then local cert, then ad-hoc.
SIGN_IDENTITY=""
APPLE_DEV_ID=$(security find-identity -v -p codesigning 2>/dev/null | sed -n 's/.*"\(Apple Development:[^"]*\)".*/\1/p' | head -n 1 || true)
if [ -n "$APPLE_DEV_ID" ]; then
  SIGN_IDENTITY="$APPLE_DEV_ID"
elif security find-identity -v -p codesigning 2>/dev/null | grep -Fq 'DiskWidget Local Signing'; then
  SIGN_IDENTITY="DiskWidget Local Signing"
fi

if [ -n "$SIGN_IDENTITY" ]; then
  codesign --force --options runtime \
    --entitlements Entitlements/WidgetExtension.entitlements \
    --sign "$SIGN_IDENTITY" "$APPEX_DIR"
  codesign --force --options runtime \
    --entitlements Entitlements/Host.entitlements \
    --sign "$SIGN_IDENTITY" "$APP_DIR"
else
  codesign --force \
    --entitlements Entitlements/WidgetExtension.entitlements \
    --sign - "$APPEX_DIR"
  codesign --force \
    --entitlements Entitlements/Host.entitlements \
    --sign - "$APP_DIR"
fi

# Register bundle and embedded WidgetKit extension with LaunchServices/pluginkit when available
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
  "$LSREGISTER" -f "$APP_DIR" >/dev/null 2>&1 || true
fi
if command -v pluginkit >/dev/null 2>&1; then
  pluginkit -a "$PWD/$APPEX_DIR" >/dev/null 2>&1 || true
fi

echo "Built DiskWidget.app (with DiskWidgetWidget.appex + Metadata.appintents, signed with: ${SIGN_IDENTITY:-ad-hoc})"
