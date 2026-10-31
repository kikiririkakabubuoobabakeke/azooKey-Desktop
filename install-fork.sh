#!/bin/bash
set -euo pipefail

APP_PATH="${1:-}"

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
    echo "usage: $0 /path/to/azooKeyMac.app" >&2
    exit 1
fi

# ダウンロードしたアプリのquarantine属性を外す
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# CODE_SIGNING_ALLOWED=NOでビルドしたアプリにad-hoc署名を付ける
if [[ "${AZOOKEY_NO_SANDBOX:-0}" == "1" ]]; then
    codesign --force --deep --sign - "$APP_PATH"
else
    ENTITLEMENTS="$(mktemp -t azookey-entitlements)"
    trap 'rm -f "$ENTITLEMENTS"' EXIT
    cat > "$ENTITLEMENTS" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.dev.ensan.inputmethod.azooKeyMac</string>
    </array>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.temporary-exception.mach-register.global-name</key>
    <string>dev.ensan.inputmethod.azooKeyMac_Connection</string>
</dict>
</plist>
PLIST
    codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"
fi
codesign --verify --deep --strict "$APP_PATH"

sudo rm -rf "/Library/Input Methods/azooKeyMac.app"
sudo cp -R "$APP_PATH" "/Library/Input Methods/"
pkill azooKeyMac 2>/dev/null || true

echo "azooKeyMacを/Library/Input Methodsにインストールしました。"
echo "macOSからログアウトして再ログインし、入力ソースにazooKeyを追加してください。"
