---
title: "Kaigi on Rails 2024 Day1"
date: "2024-10-25 11:26:42 +0900"
last_modified_at: "2024-10-26 07:11:26 +0900"
---

# Kaigi on Rails 2024 Day1
## 基調講演
[基調講演 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/palkan/)

Rails way は哲学  

おまかせは完全じゃない  

その隙間を埋めると歪んでしまう  

ある程度までは構造を提供するのだがその先  

Rails を拡張する  
他のものと混ぜ合わせるのではない

既存のコード内から抽出して抽象化する  

全ての抽象化にはベースクラスが必要  

## Railsの仕組みを理解してモデルを上手に育てる - モデルを見つける、モデルを分割する良いタイミング
[Railsの仕組みを理解してモデルを上手に育てる - モデルを見つける、モデルを分割する良いタイミング - | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/igaiga/)

https://speakerdeck.com/igaiga/kaigionrails2024

### モデルの見つけ方
メインとなるテーブル名を名詞で出す

誰が・何を

#### イベント型モデル
名詞であるモデル名に「〜する」

複数モデルで迷った場合に捗る

複数のモデルにまたがる処理

Rails way に乗っているので楽ちん

#### PORO
何も継承していない。テーブルと結びついていない

まずイベント型モデルを探すこと。
テーブルに保存しなくても良いが、モデルっぽいオブジェクトを発見した時

app/models 以下におく ビジネスロジックですよ〜〜〜

##### 命名
返ってくるオブジェクトの名前を名詞でつける

Service 層を入れるのはおすすめしない

Rails は層を減らして高い生産性を得ている  
登場人物が少ない

### モデルを分割する良いタイミング
コード行数が多すぎるは気にしない

そのまま書き続けるとしんどくなる時 and そのタイミングで良い分割方法がある時
-> しんどい、というのも人によるからむずい :memo:

#### 例
モデルとフォームのバリデーションは最初は共有されている

DB と違う検証をしたい時はフォームオブジェクト

#### タイミングまとめ
バリデーションを条件分岐したくなった時

アプリ初期で分割してしまうと共有のメリットが得られなくなる

### フォームオブジェクトのつくりかた
- `ActiveModel::Attributes`
  - 型を指定した attributes を作れる
- `ActiveModel::Model`  

`ActiveModel::Model` = `ActiveModel::API` + `ActiveModel::Access`

## そのカラム追加、ちょっと待って！カラム追加で増えるActiveRecordのメモリサイズ、イメージできますか?
[そのカラム追加、ちょっと待って！カラム追加で増えるActiveRecordのメモリサイズ、イメージできますか? | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/asayamakk/)

AR instance ってどれくらいメモリ使ってるんだろなっと

`add_column` するとどのくらい増えるのか 224 bytes

PK + timestamps の AR instance でも 3.4KB くらいかー

4つのオブジェクトが増えている。ActiveModel::Attribute::FromDatabaseはDBからの結果をラップしている。typeを持っていて型変換もする

## Sidekiqで実現する長時間非同期処理の中断と再開 | Kaigi on Rails 2024
[Sidekiqで実現する長時間非同期処理の中断と再開 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/hypermkt/)

非同期処理の中断と再開、世間一般に意外と知見がないかもしれない  

### 長時間のジョブが抱える課題
それを停止するの怖い

1. 進捗を保存しながら処理を進行
2. 全て処理終了
3. 中断処理
4. 再起動
5. 再開処理

### 中断処理
設定ファイルにイベントハンドリングを設定  
処理終了と停止を検知したらフラグをあげる  

Sidekiq の停止を検知したら例外を送出する  

### 再開処理
中断した箇所から処理を継続する

### 行番号保持方式
停止・再開のための情報を Redis に保存する

CSV のインポートなどに使われる。1行に複数のエラーが発生したりするから大変よね

### ユースケース別実装パターン
- 実行時間短い＆ファイル容量が小さい
  - 処理が冪等なので中断処理のみでおk
- 実行時間長い＆ファイル容量が大きい
  - 数時間以上
  - 数百MB
  - デプロイに影響
  - ユーザーへの業務影響が大きい
  - 中断時に大きいファイルをどこに保存する？

### 保存先
- Redis
  - メモリ容量を超える危険性
- オブジェクトストレージ GCS
  - 容量が大きくても保存できる
  - 暗号化やセキュリティもおk

### 中断・再開処理のテスト
再開の時 worker.perform を2回呼び出すことによって再開処理を再現する

### Sidekiq Iteration
まだベータだがある

## リリース8年目のサービスの1800個のERBファイルをViewComponentに移行した方法とその結果
[リリース8年目のサービスの1800個のERBファイルをViewComponentに移行した方法とその結果 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/katty0324/)

- パラメータ定義の曖昧さ
  - 仕様に従って使うべきだがコードベースにそれらはない
- 一貫性のないパラメータの渡し方
  - インスタンス変数でもローカル変数でも渡せる

### ViewComponent

React インスパイアかどうかはワイはわからん

テストは erb でもかけるんだなあ

置き換えするためにパースして抽象構文木にした上で erb の render メソッドを探す

ViewComponent では content が予約されているのか

- 別系統の生成
  - app/views2
  - こちらが ViewComponent を使用した別系統
- view_path の分岐

prepend_viewpath を使って view_path の依存関係の一番トップに持ってくる

- コンポーネント呼び出しのインターフェースがわかりやすい
- コードジャンプがしやすい
- View のテストが可能になり、実装ミスに気づきやすくなった

## Rails APIモードのためのシンプルで効果的なCSRF対策
[Rails APIモードのためのシンプルで効果的なCSRF対策 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/corocn/)

Cookie が自動送信されることに起因する

### Rails での対策
CSRF token を発行する

Rails way に乗っかる場合は View, Controller の数行で終わる  

### Rails API + SPA

トークン送受を自前で書くことになる

もっとシンプルに対策できないか？標準機能に引っ張られないように  

- 許可したサイトからのリクエストのみ受け付ける
- Cookie が自動で送られないようにする

### 実際の対策
- リクエストの出所を確認
  - origin header の確認
  - Form POST でオリジンが送られなかった時代もあった
     - 現在では全てのブラウザで対応済み
- Featch metadata
  - Sec-FetchSite
  - リクエスト発生元と先の関係性
- Samesite
  - Lax or Strict を指定する

## 現実のRuby/Railsアップグレード
[現実のRuby/Railsアップグレード | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/takeyuweb/)

### 当時の課題
テストカバレッジ0%

- テストを書く
  - まあそうですよね
  - テストをパスしないとレビューに進めないようにする
- エラーを通知する仕組みづくり
- 非推奨警告をなくす
- upgrade 作業は問題発生リスクがある
  - ビジネス側との信頼関係を構築しておく
- ここまでやってようやくアップグレード
- Rails ごとにサポートしている Ruby のバージョンを確認する

`rails app:update` は基本的に上書き

### 保守されていない gem
つら。。。

### Rails をモンキーパッチしている gem
一見標準ぽいインターフェースでオーバーライドしているものは辛いな

### Ruby の非互換な変更

### sprockets から propshaft
#### Propshaft
アセットファイルを扱うことに集中する

JavaScript build は sprockets から独立させる
-> build 時間を2分から2秒

CSS のプリコンパイルも独立させる

業務領域に対する理解って大切よね


賢そうなコードを書かない -> はい。。。

エンジニアの説明責任

## Hotwire or React? 〜Reactの録画機能をHotwireに置き換えて得られた知見〜
[Hotwire or React? 〜Reactの録画機能をHotwireに置き換えて得られた知見〜 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/haruna-tsujita/)

- RoR / 部分的に React で SPA

React は本当に必要？ -> あるある

Stimulus で実装していったが。。。ゴリゴリにJavaScript を書くことになった。じゃあ React でいいか。。。

Hotwire ならゴリゴリ JS を書かずに済みそう

「紙芝居」のように画面を切り替える

Hotwireで実装できそうか？ -> 実装を CRUD に集中できそうか？

