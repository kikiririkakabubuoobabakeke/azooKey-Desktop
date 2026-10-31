# このフォークの変更点

[azooKey/azooKey-Desktop](https://github.com/azooKey/azooKey-Desktop) の個人用フォークです。

## 1. USキーボードの Caps Lock で英数/かなを切り替え

- `Caps Lock` を押すと、azooKey内の「英数」と「かな」を切り替えます。
- `Shift + Caps Lock` を押すと、通常の Caps Lock（大文字固定）として動作します。
- 設定 > カスタマイズ > 入力オプション の「Caps Lockで英数/かなを切り替え」でオン/オフできます（デフォルト: オン）。

### 注意

macOSの「システム設定 > キーボード > 入力ソース > 編集...」にある
「Caps LockキーでABCと切り替え」は**オフ**にしてください。オンになっていると、
macOS側が先にCaps Lockを処理してしまい、このフォークの切り替えが動きません。

Caps Lockの状態はIOKitで監視し、ShiftなしでCaps Lockがオンになった場合は
即座にオフへ戻してから入力モードを切り替えます。追加のアクセシビリティ権限は不要です。

## 2. いい感じ変換で OpenCode Go を使う

「いい感じ変換」のバックエンドで「OpenAI互換API」を選び、プリセットの「OpenCode Go」を
選ぶと以下が設定されます。

- エンドポイント: `https://opencode.ai/inference/go/openai/v1/chat/completions`
- モデル: `glm-5.3-flash`

APIキーには [OpenCode Console](https://opencode.ai/console) で発行したOpenCode GoのAPIキーを入力してください。
モデル名を変えたい場合は `deepseek-v4.1-flash` や `kimi-k3` なども指定できます。

OpenCode GoはOpenAI互換APIなので、`response_format` のJSON Schemaに対応していない
モデルでも動くように、以下のフォールバックを追加しています。

- OpenCode Goのホストでは最初から `response_format` を付けず、プロンプトでJSONを指示
- `response_format` が400/422で拒否された場合は、自動で外して再試行
- レスポンスがJSONでなくプレーンテキストでも、行単位で候補として解釈
- コードフェンス（```json ... ```）や `{ "predictions": [...] }` 形式に対応

> OpenCode Goは本来コーディングエージェント向けのサービスです。IMEからの利用が
> 利用規約上・料金上どう扱われるかはOpenCode側のポリシーを確認してください。

## 既知の制限

- 「システム設定 > キーボード > キーボードショートカット > 修飾キー...」でCaps Lockを
  「Caps Lock」以外に割り当てている場合は、この機能は動きません。
- Caps Lockの状態を10ms間隔で監視しているため、押した瞬間にCaps Lockインジケータが
  一瞬表示されることがあります。
- ad-hoc署名でインストールした場合、既存のazooKeyの設定やKeychainのAPIキーが
  引き継がれないことがあります。その場合は設定を入力し直してください。

## ビルド済みアプリ

GitHub Actions の `Build Fork App` ワークフローで、署名なしの `.app` をビルドできます。
ActionsのArtifact、またはReleaseから `azooKeyMac-fork.zip` をダウンロードしてください。

```bash
unzip azooKeyMac-fork.zip
bash install-fork.sh ./azooKeyMac.app
```

`install-fork.sh` はad-hoc署名を付けて `/Library/Input Methods/` にコピーします。
インストール後、macOSからログアウトして再ログインし、入力ソースにazooKeyを追加してください。

ad-hoc署名とApp Sandboxの組み合わせでアプリが起動しない場合は、Sandboxなしで署名できます。

```bash
AZOOKEY_NO_SANDBOX=1 bash install-fork.sh ./azooKeyMac.app
```
