---
title: "TypeScriptを活用した型安全なチーム開発 2024"
date: "2024-12-23 19:07:58 +0900"
last_modified_at: "2024-12-23 22:16:33 +0900"
tags:
  - "TypeScript"
  - "Events"
draft: false
---
# TypeScriptを活用した型安全なチーム開発 2024
https://sansan.connpass.com/event/337268/

## TypeScript開発にモジュラーモノリスを持ち込む
### モジュラモノリス
デプロイのたびに結合する

### 1. モジュールにDBデータを占有させる
アプリやインフラだけでなくデータベースのテーブル分割もする -> まあ共有しないほうがいいだろうなあ

共有しているとテーブルのスキーマが変わると参照している箇所で複数のアプリ間で対応が必要

一番低い結合はメッセージ結合

Firestore を使っていた。JOIN がないという制約がモジュラモノリスと相性がいい

- src
  - modules
    - hoge
      - domains とか

eslint のルールだけで制約を実現した。明示的に export しているものだけを import できる

#### Step 1. 単一のエイリアスを設定する
単一エイリアスだけを設定。モジュール作りたいなという時に便利

#### Step 2. 自作ルール
モジュール外からは module/index.ts だけ import が可能

chatGPT とかで簡単に作れる

#### Step 3. モジュールに切り出す
開発の時、まずモジュール化を検討する

ガイドラインみたいなのを用意しているのは良いなあ

## Denoで作るチーム開発生産性向上のためのCLIツール
（個人的にも）Deno はいいぞ

様々な周辺コード（スクリプトのことかな）が必要になる

- 定型的
- 突発的

管理が煩雑になりがち（あるある）

Repository はあったけどメンテもあまりされない。周知もされないのでメリットを享受できない

全員が共通して使える実行環境  
CLI tool として配布する

引数をパースするのも楽ちんなんだよな〜

思いついた時にすぐに書いて他の開発者に提供できる。サクッとしてるところがいいよね

### Deno の採用理由
- 標準機能が充実している
- CLI に必要な機能はほとんど標準ライブラリで実装できる
- 標準ライブラリ以外の機能も依存関係が少ないのでメンテコストが低い

`dax` って使ったことないなあ  
https://github.com/dsherret/dax

CLI ツールにはあっている

#### Global Installation
ファイルを編集しても再インストールが必要ない

開発生産性向上のためには全ての開発者が能動的に開発に向き合えることが大事


## React Routerで実現する型安全なSPAルーティング
TanStack router のほうが型安全性についてはいいという話を聞いたことある
https://zenn.dev/bitkey_dev/articles/react-router-to-tanstack-router

### 課題１
不正な URL への遷移

- 文字列を直接書いていると不正なURL の指定に気づきづらい
- 個別に対応すると URL 生成のロジックが点在してしまう

#### URL 生成ロジックをまとめる
パターンとパラメータを元に URLを生成してくれる

### 課題２

v6.4 から loader, action など Remix の概念が入った

v7 から Remixと統合

## 型情報を用いたLintでコード品質を向上させる
（Bill One Engineering Unit Core Business APグループ / 江川 綾）

### Typed Linting
typescript-eslint を用いて行う

できること

- 型情報を元に静的解析する

問題点
- Lint の実行時間が増加する

### Rust 製 Linter
- Biome
- oxlint

これらでは型情報を用いた Lint ができない

### Typed Lintingとどう付き合っていくか
#### 1. typescript-eslint でできるパフォチュを行う
- ビルド時間の改善は大切だなあ
- 3rd party のプラグインの設定を見直す

eslint のキャッシュはファイル単位だが Typed Linting はファイルを跨いで解析を行うので相性が悪い

#### 2. typescript-eslint のルールを環境ごとに切り替える
環境ごとに違うのはうーむ？

#### 3. Lint ツールを併用する

ツールごとに思想が違うので難しい面もあるかあ。複雑性も増加するし

