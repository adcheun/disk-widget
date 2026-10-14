#!/bin/sh
set -eu

mkdir -p DiskWidget.app/Contents/MacOS

if [ ! -f DiskWidget.app/Contents/Info.plist ]; then
  cat > DiskWidget.app/Contents/Info.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>DiskWidget</string>
  <key>CFBundleIdentifier</key>
  <string>local.diskwidget.app</string>
  <key>CFBundleName</key>
  <string>DiskWidget</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST
fi

swiftc DiskWidget.swift \
  -o DiskWidget.app/Contents/MacOS/DiskWidget \
  -framework AppKit

echo "Built DiskWidget.app"
