---
title: "公式から kiro をダウンロードしたので brew の管理対象から外す"
date: "2025-08-16 17:17:46 +0900"
last_modified_at: "2025-08-16 17:17:46 +0900"
tags: ['kiro', 'homebrew']
draft: false
---

ウェイトリストに登録していた kiro からメールが来たので、[ダウンロードページ](https://kiro.dev/downloads/) からダウンロードした。そしてすでに brew でインストールしていたほうを置き換えた。  

brew で入れたほうはどうやら Intel ver. のようで、Rosetta2 でエミュレートされていた。今までのセッションは保持されているのでデータはちゃんと移行されているようだ。

そして brew の管理対象からは外したい。もちろんアンインストールせずに。

## kiro を brew の管理対象から外す

```sh
# kiro があることを確認
brew list --cask

# caskroom のパスを確認する
brew --caskroom
/usr/local/Caskroom

# caskroom に kiro があることを確認
ls -la $(brew --caskroom)
drwxr-xr-x   4 noriyo_tcp  wheel  128  7 21 22:57 kiro

# metadata がある
ls -la $(brew --caskroom)/kiro
total 0
drwxr-xr-x   4 noriyo_tcp  wheel  128  7 21 22:57 .
drwxrwxr-x@ 16 noriyo_tcp  wheel  512  7 21 22:57 ..
drwxr-xr-x   5 noriyo_tcp  wheel  160  7 21 22:57 .metadata
drwxr-xr-x@  3 noriyo_tcp  wheel   96  7 21 22:57 0.1.15,202507180243
```

kiro を caskroom から削除する

```sh
rm -rf $(brew --caskroom)/kiro
```

caskroom から無くなった。リストからも消えている

```sh
ls -la $(brew --caskroom)
brew list --cask
```

これでダウンロードした kiro のほうを使用していく。
