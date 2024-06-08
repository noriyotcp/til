# https://zenn.dev/vim_jp/articles/2024-06-05-vim-middle-class-features

## 検索結果を次々と置き換える
Configuration of VimL,
by VimL, for VimL

```
1. /VimL<CR> で VimL という文字列を検索
2. cgn で検索結果にマッチする範囲 (gn) を削除しつつ挿入モードに入る (c)
3. Vim script と入力して挿入モードを抜ける
4. . で直前の置換を繰り返す
```

`<CR>` は carriage return

## 引用符で囲まれた箇所全体を選択する

def add_suffix(fname: str, extension: str) -> str:
    return fname + extension


先にオペレータ(v, c（置き換え） とか）を押した上で  
- i" で "..." の中
- a" で "..." 全体
  - 周囲の空白を巻き込んでしまう
- 2i" で "..." 全体
  - 周囲の空白を巻き込まない

## 連番を簡単に作成する
0. Something.

```
1. 0. Something. と書かれたテキストを10行並べる
2.<C-v> で矩形ビジュアルモードに入り、数字を選択
3.g<C-a> を押す
```

## 挿入モード内でインデントを増減する
通常は > / <

<C-t> / <C-d>

メリットはカーソルが行頭になくても動作する

- indent
  - indent in INSERT mode

ついでにインデントの設定もした  
[vimで言語ごとにインデントの大きさを変えてみた #Vim - Qiita](https://qiita.com/daiki44/items/8da9d4f89bb295f1399d)
マークダウンではスペース2文字

