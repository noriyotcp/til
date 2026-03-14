---
title: "Claude Code で Ctrl + J で改行する"
date: "2026-03-14 10:16:57 +0900"
last_modified_at: "2026-03-14 10:16:57 +0900"
tags:
  - "Claude Code"
draft: false
---

## いつの間にかできなくなっていた

iTerm2 上で Claude Code を起動したとき、今までは `Ctrl + J` で改行ができていたような気がするのですが、いつの間にかできなくなっていました。

## keybindings の設定

`~/.claude/keybindings.json` に以下のように設定しました。

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+j": "chat:newline"
      }
    }
  ]
}
```

`chat:newline` は現在 [ドキュメント](https://code.claude.com/docs/en/keybindings#chat-actions) には記載がなさそう？ [こちらの issue](https://github.com/anthropics/claude-code/issues/26708) でも指摘されています。

これで `Ctrl + J` でも改行できるようになりました。`Shift + Return` でも改行できるのは変わらず。
