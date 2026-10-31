#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    sed 's/$(PRODUCT_BUNDLE_IDENTIFIER)/dev.ensan.inputmethod.azooKeyMac/g' \
        "$REPO_ROOT/azooKeyMac/azooKeyMac.entitlements" > "$ENTITLEMENTS"
    codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_PATH"
fi
codesign --verify --deep --strict "$APP_PATH"

sudo rm -rf "/Library/Input Methods/azooKeyMac.app"
sudo cp -R "$APP_PATH" "/Library/Input Methods/"
pkill azooKeyMac 2>/dev/null || true

echo "azooKeyMacを/Library/Input Methodsにインストールしました。"
echo "macOSからログアウトして再ログインし、入力ソースにazooKeyを追加してください。"
