---
title: "簡単なプロフィールページを作った"
date: "2025-09-20 11:43:02 +0900"
last_modified_at: "2025-09-20 11:43:02 +0900"
draft: false
tags: ["GitHub Pages", "NFC", "shields.io"]
---

## noriyotcp.github.io を作成した

NFC に書き込むプロフィールページでも作ろうかなと思い https://noriyotcp.github.io/ を作成した。

GitHub Pages の作りかたは割愛するが、`README.md` を作成するのに https://rahuldkjain.github.io/gh-profile-readme-generator/ を使った。

フォームに入力して、生成されたマークダウンを利用すればいいだけ。楽チンだった。

## バッジを作る

X.com 用に [shields.io](https://shields.io/) のバッジを作成したが、公式サイトが使いづらかったので [Badge Maker](https://si-badge-maker.heyfe.org/en) を使った。

### バッジのパスパラメータ
- 基本形式：`ラベル-メッセージ-色`
- 簡略形式：`ラベル-色`（メッセージ不要の場合）
- 例：`badge/%40noriyotcp-black`

このように表示される。

<a href="https://x.com/noriyo_tcp" target="blank"><img src="https://img.shields.io/badge/%40noriyotcp-black?style=for-the-badge&labelColor=black&logo=x" alt="Badge"></a>

```html
<a href="https://x.com/noriyo_tcp" target="blank"><img src="https://img.shields.io/badge/%40noriyotcp-black?style=for-the-badge&labelColor=black&logo=x" alt="Badge"></a>
```

## 勘違いしていた点
GitHub のプロフィールページに載せる README.md は、まずユーザー名と同じ名前のリポジトリを作成する。その中に `README.md` を置くとプロフィールページに表示されるわけだ。

それに対し GitHub Pages は、`<ユーザー名>.github.io` というリポジトリを作成する。そこに HTML や CSS、JavaScript を置くとウェブサイトとして公開される。

GitHub のプロフィールページに載せるのはやめておいた。少々邪魔になるかなと思ったので。
