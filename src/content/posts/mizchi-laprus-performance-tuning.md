---
title: "【再-増枠】mizchiさんによる 「LAPRAS 公開パフォーマンスチューニング 」~調査編~"
date: "2024-12-03 00:22:31 +0900"
last_modified_at: "2024-12-03 00:34:54 +0900"
tags:
  - "Frontend"
  - "Events"
draft: false
---
# 【再-増枠】mizchiさんによる 「LAPRAS 公開パフォーマンスチューニング 」~調査編~
[【再-増枠】mizchiさんによる 「LAPRAS 公開パフォーマンスチューニング 」\~調査編\~ - connpass](https://lapras.connpass.com/event/337670/)

## はじめに
- CPU/Network をスロットリングする 体験を揃えるため
- 安易な先読みは毒薬
  - リソースの上限は変化しない
  - preload を使いすぎない。HTML が膨らむ

フロントエンドの計測 -> UX の計測  
UX は RTT に依存。ユーザーで起こる問題は目視できることが多い  

## Lighthouse
Device はモバイルしか見てない  
ホバーすると内訳が見れる
score は相互依存  

LCP はモバイルをエミュレートしている。設定は一番下にある  

View treemap でバンドルアナライザーみたいな結果が見れる  

プライベートモードだとローカルストレージがない  
診断結果はあいまい  

footer が先に読み込まれていた。そこにある画像が読み込まれている  

## パフォーマンス計測
chunk を多くするとネットワーク回数が増える  


録音ボタンは押さない。ロードしながら計測する

Lighthouse を先に見るのは予想を立てておくため  

CPU は 16ms 以内  
レイアウトジャンク。スクロールする時に JavaScript が降ってきて止まっちゃうとか

parse HTML がボトルネックになったりする  

Network, Main の2つをみる  

Waterfall でリクエスト傾向がわかる  
TBTが重い時とか  

sourcemap: hidden sourcemap を埋め込まない  

devtools 開いていると重いとかメモリリークするとか

webfont は重たい

アプリ動作に関わるもの以外は一旦ブロックする

