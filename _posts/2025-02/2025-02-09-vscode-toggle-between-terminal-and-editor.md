---
title: "VS Code でターミナルとエディターを往復するキーバインディング"
date: "2025-02-09 13:50:49 +0900"
last_modified_at: "2025-03-12 23:57:55 +0900"
tags:
  - VS Code
---

- ターミナルにフォーカスが当たっているとき
  - `cmd+k e` でエディタグループにフォーカスする
- エディタ内にフォーカスが当たっているとき
  - `cmd+k t` でターミナルにフォーカスする
- サイドバーにフォーカスが当たっているとき
  - `cmd+k e` でエディタグループにフォーカスする
  - エディタグループとサイドバー間でスイッチしたい

```json
    {
        "key": "cmd+k e",
        "command": "workbench.action.focusActiveEditorGroup",
        "when": "terminalFocus || sideBarFocus"
    },
    {
        "key": "cmd+k t",
        "command": "workbench.action.terminal.focus",
        "when": "editorTextFocus"
    }
```

## 余談

GitHub Copilot Chat （モデルは `Claude 3.5 Sonnet`）でこのように聞いたらシュッと作ってくれた。便利

```
create a VS Code keybindings

- when focused on terminal, press command + K, E, switch to the active editor groups
- when focused on editor, press command + K, T, switch to the terminal

// さらに追加で質問
In addition, I want to add the keybindings like this:

- when focused on open edditors view, press command + K, E, switch to the active editor groups
```

---

元々 `cmd+k e` はエクスプローラーの `Open Editors` にフォーカスするようになっている

```
Explorer: Focus on Open Editors View
```

今回設定したものはあくまでターミナルにフォーカスしているときのみ。なので例えばエディタ内でフォーカスしているときは `cmd+k e` で元々の `Open Editors` へのフォーカスになる  
さらに `Open Editors` （サイドバー）からエディタに戻れるようにしたかったので `Cmd+k e` でスイッチできるようにした

## Copilot Chat にフォーカスを合わせる
以下のように設定すると `cmd+k l` で Copilot Chat にフォーカスを合わせることができる(Cursor の場合は `cmd+y`)

```json
  {
    "key": "cmd+k l",
    "command": "workbench.panel.chat.view.copilot.focus"
  }
```
