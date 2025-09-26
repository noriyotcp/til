---
title: "KaigiOnRails 2025 Day1"
date: "2025-09-26 02:43:12 +0900"
last_modified_at: "2025-09-26 02:43:12 +0900"
draft: true
---

## memo

### Keynote - dynamic!
moro3 は SMS 所属なのか  

なぜ動的でありたいか。最初から「正解」を選ぶのは難しい  
変えるようにする仕組み作りも大事。外的環境もどんどん変わる。  

memo: これをどうRuby に繋げていくのかなあ  

#### Ruby で動的に開発する
irb で気軽に調べることができる。仮説検証の最小単位
動かしながら自分が欲しいプログラムに近づく -> memo: ここら辺も AI によってガッとできる時代になってしまうのでは？-> つまり真逆のアプローチが主流になっていくのではないかなあと

#### Rails で動的に開発する
分割する。パッピーパス。普通の利用者が期待する最もシンプルな操作ができる。スキャフォールドに近い  

ハッピーパスにおいては DB&resource 設計ができていればよし。それが大事

- DB 設計に集中する
  - 全てのスキーマを定義する必要はない
- 本番リリース前にいろんなステージを作れる
- ハッピーパスの価値
  - 最重要エンティティを定義すること。大事
- もっともシンプルでうまくいくものに留めておく。間の使い方
  - これも AI agent 時代だと真逆かなあ。でも審美眼は必要
- 「そのとき」がきたらコードを書く
- 2つ以上のテーブルを同時に更新したい
  - どんなリソースか、考える
  - 利用者からの捉え方「リソース」としては1つのプロフィール
    - 利用者から見えるものをresourceと定義しているのだな
  - Rails の気持ちになって考える
    - エントリポイントに mass-assignment
    - CurrentAttributes も再評価されているのかな？
      - 2018 年導入だったのか
- happy path を作成したので、ダメな部分に早く気づける
- メールをコントローラーから送る
- プロフィール変更のFormObject を作ったら他の場合のFO もつくる？
- メアド変更操作の監査ログは？IP adress が欲しい
  - となるとFO にメール送信を書かない方が良い？

最重要エンティティを見出す。  
最もシンプルで、うまくいく範囲で進める。作りすぎない  

#### プロダクト開発も動的にする
- Document 中心でコミュニケーションするけど、それぞれが自分の文脈で解釈しないといけない
- 動くソフトウェアで会話する
- feedback を受けて変化する
- リリースからの学びを次のリリースに反映できる
  - memo: リリースがたくさんあるからなあ。しかしその内容が連続的なものではない
    - 今回の学びを次のプロジェクトに活かせるとは限らない

- アジャイルマニフェストじゃん。それはそう

### [高度なUI/UXこそHotwireで作ろう | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/naofumi/#day1)
bio 関係の人なのか。  
Turbo しょっちゅうやることを定型にする  
Stimulus event 処理を定型化

React - state更新一本に絞る -> パスが1つしかないのでそこを最適化する

state を挟むとReact に近いことができる。 value state  

JS で書いた方がもっさり感がなくなる

SWR - Stale While Revalidate  

Turbo Frames は prefetch
-> Next.js でもやっているが動的サイトだとローディングが出てくる。実装も面倒 Turbo Frames のほうは簡単

React をHotwire に埋め込むことができるのか？
Turbo Mount これ知らなかった！React を埋め込めるの？

memo: React は元々リアルタイムダッシュボード用だったのか

Mediator pattern  

React one way data flow -> memo: それが強みなんだよね。けど他のライブラリでできないものではなさそう。  
-> これを意識する

zustand を使う。グローバルステートを扱いやすくなる

Basecamp の無料版面白そう  

JSON を扱う部分が React では大変  

### [入門 FormObject | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/expajp/#day1)
確かに導入の基準はなんなんだろな。結局 FormObject とは何か

1. データベースに紐づかない Ruby Object
2. モデルと同じI/F を持ちcontroller から呼ばれる
  2-1. 入力バリデーション
3. 独自のライフサイクルを持つことができる
4. ビューの状態を保持できる

#### vs FormObject を使わない実装
FormObject は何を返すんだろな  
同じコントローラーから別の FormObject を呼んでもいいのか。

1. モデルを操作しない
2. 2個以上のモデルを操作する
3. ライフサイクル処理をアクションごとに分ける

1 -> メール送信とか。となるとFormOject のなかでメール送信してもいいことになるか

3 -> 作成と編集でライフサイクルを分けたりする

---

Rails way の制約があるとユーザーの要求を満たせない  

### [もう並列実行は怖くない コネクション枯渇とデッドロック解決の実践的アプローチ | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/katakyo/#day1)

AI workflow は時間がかかる  

connection pool が枯渇する -> app から DB に接続する。ある程度接続しておいて使い回すのがコネクションプール  

#### 安全に並列処理をする
1. パラメータ設定の考え方
max_connections parameter
コネクションプールの設定の確認は愚直にログを取るのかな？


2. コネクションプールを枯渇させない
長時間のトランザクションに気をつける  

範囲を最小限に  
重たい処理は外に出す

3. （これはなんだったけな）

### [Web Componentsで実現する Hotwire とフロントエンドフレームワークの橋渡し | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/kudoas/#day1)

社内共通のUI component うっ頭が  

Rails, Hotwire -> そのままテンプレートに埋め込んでも動かない  
Web components をブリッジにする  
Web 標準なのがいいんだよなー。カスタム要素を利用する。HTML 要素なので Hotwire とも共存できる  

#### Custom Element へのデータの渡し方
HTML 属性でデータを渡す。文字列のみ  
DOM property で渡す

XSS の脆弱性に対して  
カスタムデータ属性

form builder をカスタマイズして form helper を作ったりできる  
`form_with` の builder option

### [5年間のFintech × Rails実践に学ぶ - 基本に忠実な運用で築く高信頼性システム | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/ohbarye/#day1)

memo: Smartbank のプロダクトも1000モデルを超えているのか…

規制産業は足しに大変そう。　品質特性の話

#### 信頼性とは
- 明示された機能を実行する度合い  
- 要求通りに遂行できる能力  
- 目標をどれだけ達成しているか

#### 運用とは
ビジネスを可能にすること

#### アーキテクチャ設計

システムコンポーネントってどんなもので作っているんだろう。-> Citadel

module で分割している。まあそうだろね

コードの責務の整理や明確化を重視。良さそう。

「もしデータがこうなったらビジネスが毀損されるな」を想像して備える

パフォーマンスミーティングをやっている。人数が多くなり効率的な運用を模索している

バッチ仕様書。アラートを受け取ったエンジニアが誰でも対応をできるようにする

旗振り役が最初は頑張る、やっぱり大事よね。。。

インシデントコマンダーの役割 -> うちらで言うとインシデント時の隊長みたいなものかな

Runbook -> 手順書。  

なんというかうちらよりまだまだ規模も人数も小さいのにしっかりとやっている印象。逆にうちらがテキトーなのよ

LoC が増加傾向なのに障害はピークの2023 年から６割減か！すごい

### [2分台で1500examples完走！爆速CIを支える環境構築術 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/falcon8823/#day1)
（疲れたのでスキップ）

### [Railsによる人工的「設計」入門 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/nay/#day1)

### [今改めてServiceクラスについて考える 〜あるRails開発者の10年〜 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/joker1007/#day1)

