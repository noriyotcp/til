---
title: "vim のインラインコードブロックのキーバインディング"
date: "2025-02-22 19:54:03 +0900"
last_modified_at: "2025-02-22 19:54:03 +0900"
tag:
  - Vim
---

## vim のインラインコードブロックのキーバインディング
https://github.com/tpope/vim-surround

```sh
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/surround.git
vim -u NONE -c "helptags surround/doc" -c q
```

例えば以下の文章の code にカーソルを合わせ `` ysiw` ``
This is the `code`.

### visual mode (charwise-visual) の場合

`v` 押して文字列を選択し `` S` ``

---

Markdown のコードの中にバッククォートを含めるには外側のバッククォートを2つずつにするの知らなかった

```
`` `code` ``
```

[Markdown のコードの中にバッククォートを含める方法](https://gotohayato.com/content/535/)

