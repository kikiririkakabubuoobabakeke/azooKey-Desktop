#!/bin/bash
set -euo pipefail

APP_PATH="${1:-}"

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
    echo "usage: $0 /path/to/azooKeyMac.app" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d -t azookey-install)"
trap 'rm -rf "$TMP_DIR"' EXIT

# ダウンロードしたアプリのquarantine属性を外す
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

# CODE_SIGNING_ALLOWED=NOでビルドしたアプリにad-hoc署名を付ける
if [[ "${AZOOKEY_NO_SANDBOX:-0}" == "1" ]]; then
    codesign --force --deep --sign - "$APP_PATH"
else
    ENTITLEMENTS="$TMP_DIR/entitlements.plist"
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

# アプリを置き換えると入力ソースが無効になることがあるため、再登録を試みる。
# swiftcがない環境では、システム設定から手動で追加してもらう。
if command -v swiftc >/dev/null 2>&1; then
    cat > "$TMP_DIR/register.swift" <<'SWIFT'
import Carbon
import Foundation

let bundleID = "dev.ensan.inputmethod.azooKeyMac"
let appURL = URL(fileURLWithPath: "/Library/Input Methods/azooKeyMac.app")

// すでに登録済みならTISRegisterInputSourceを繰り返さない（重複登録を避ける）
let bundleFilter = [kTISPropertyBundleID as String: bundleID] as CFDictionary
let registeredSources = TISCreateInputSourceList(bundleFilter, true)?.takeRetainedValue() as? [TISInputSource] ?? []
if registeredSources.isEmpty {
    _ = TISRegisterInputSource(appURL as CFURL)
}

let sourceID = "\(bundleID).Japanese"
let filter = [kTISPropertyInputSourceID as String: sourceID] as CFDictionary
if let sources = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource],
   let source = sources.first {
    _ = TISEnableInputSource(source)
    _ = TISSelectInputSource(source)
}
SWIFT
    if swiftc "$TMP_DIR/register.swift" -o "$TMP_DIR/register" >/dev/null 2>&1; then
        "$TMP_DIR/register" >/dev/null 2>&1 || true
    fi
fi

echo "azooKeyMacを/Library/Input Methodsにインストールしました。"
echo "入力ソースが表示されない場合は、macOSからログアウトして再ログインするか、"
echo "システム設定 > キーボード > 入力ソース からazooKeyを追加してください。"
