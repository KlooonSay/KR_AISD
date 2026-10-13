#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP="КР АиСД.app"
BIN="KRAiSD"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

xcrun swiftc \
  macOS/App.swift macOS/ContentView.swift macOS/TaskEngine.swift \
  -O -o "$APP/Contents/MacOS/$BIN" \
  -framework SwiftUI -framework AppKit

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>КР АиСД</string>
<key>CFBundleDisplayName</key><string>КР АиСД</string>
<key>CFBundleIdentifier</key><string>ru.student.aisd.kr15</string>
<key>CFBundleVersion</key><string>2</string>
<key>CFBundleShortVersionString</key><string>1.1</string>
<key>CFBundleExecutable</key><string>KRAiSD</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

chmod +x "$APP/Contents/MacOS/$BIN"
xattr -cr "$APP" 2>/dev/null || true

echo "Готово: $APP"
echo "Открыть: open '$APP'"
