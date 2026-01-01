---
title: "Claude Code での GPG 署名トラブルシューティング"
date: "2026-01-01 15:42:00 +0900"
last_modified_at: "2026-01-01 15:42:00 +0900"
tags: ["Troubleshooting", "GPG"]
draft: false
---

## 問題

Claude Code から `git commit` を実行すると GPG 署名に失敗する。

```
error: gpg failed to sign the data:
gpg: cannot open `/dev/tty': Device not configured
fatal: failed to write commit object
```

## 原因

1. **Claude Code は TTY を持たない環境で実行される**
   - `tty` コマンド → `not a tty`
   - GPG がパスフレーズ入力のために `/dev/tty` を開こうとして失敗

2. **GPG Suite が古いバージョンだった**
   - gpg 2.0.30 (2015年)
   - pinentry-mac 0.9.7 (2016年)
   - 現在の macOS との互換性に問題

3. **pinentry-mac のダイアログが表示されなかった**
   - パスフレーズがキャッシュされていない
   - Keychain にも保存されていない

## 解決策

### 1. GPG Suite を最新版に更新

```bash
# 古いバージョンの確認
gpg --version
# gpg (GnuPG/MacGPG2) 2.0.30 ← 古い！

# 公式アンインストーラーで削除
# https://gpgtools.tenderapp.com/kb/faq/uninstall-gpg-suite

# brew で最新版をインストール
brew install --cask gpg-suite

# 新しいバージョンの確認
gpg --version
# gpg (GnuPG/MacGPG2) 2.2.41 ← 新しい！
```

**Note:** インストール後、「ログイン項目と機能拡張」に `shutdown-gpg-agent` が追加される。これは macOS シャットダウン時に gpg-agent を安全に終了させるためのもの。そのまま有効にしておく。

### 2. パスフレーズを Keychain に保存

```bash
# ターミナルで署名テストを実行
echo "test" | gpg --clearsign > /dev/null
```

pinentry-mac のダイアログが表示されたら：
- パスフレーズを入力
- **「Save in Keychain」にチェック** ← 重要！

### 3. 動作確認

```bash
# Claude Code から git commit を実行
git commit -m "test commit"

# 署名を確認
git log --show-signature -1
# gpg: "Your Name <email>"からの正しい署名 [究極]
```

## ポイント

| 設定 | 説明 |
|-----|------|
| `~/.gnupg/gpg-agent.conf` | gpg-agent の設定ファイル |
| `default-cache-ttl` | パスフレーズのキャッシュ時間（秒） |
| `pinentry-program` | パスフレーズ入力プログラムのパス |
| **Save in Keychain** | macOS Keychain に永続保存（再起動後も有効） |

## gpg-agent.conf の例

```
default-cache-ttl 28800
max-cache-ttl 86400
pinentry-program /usr/local/MacGPG2/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac
```

## 便利なコマンド

```bash
# GPG バージョン確認
gpg --version

# キャッシュされた鍵を確認
gpg-connect-agent 'keyinfo --list' /bye

# gpg-agent を再起動
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# コミットの署名を確認
git log --show-signature -1

# git の GPG 設定確認
git config --global commit.gpgsign
git config --global user.signingkey
```

## 環境

- macOS (Sequoia 15.7, Darwin 24.6.0)
- GPG Suite 2023.3 (via Homebrew)
- gpg 2.2.41
- Claude Code

## 参考

- [GPG Suite](https://gpgtools.org/)
- [Uninstall GPG Suite](https://gpgtools.tenderapp.com/kb/faq/uninstall-gpg-suite)
- [Homebrew Cask - gpg-suite](https://formulae.brew.sh/cask/gpg-suite)
