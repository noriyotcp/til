---
title: "Kaigi on Rails 2024 Day2"
date: "2024-10-26 10:33:45 +0900"
last_modified_at: "2024-10-27 19:57:59 +0900"
tags:
  - Ruby
  - Ruby on Rails
categories:
  - Events
  - KaigiOnRails2024
---

# Kaigi on Rails 2024 Day2
## Cache to Your Advantage: フラグメントキャッシュの基本と応用
[Cache to Your Advantage: フラグメントキャッシュの基本と応用 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/tkawa/)

key-value

```rb
cache @product
```

### 不安
- キャッシュの消し忘れ
  - キーベースのキャッシュ失効
  - `[model_name]/id-updated_at`
  - `model_name/query-sqlhash-個数-最新のupdated_at`
- 他のユーザーに見えてしまう

ページ全体をキャッシュすればいいのでは？ということでスピーカー本人の gem が紹介されている

https://github.com/tkawa/rendering_caching

model 更新時にキャッシュも更新される

### 注意点
キャッシュ内で session, cookies を使わないように

## OmniAuthから学ぶOAuth 2.0
[OmniAuthから学ぶOAuth 2.0 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/ykpythemind/)

OIDCによる認証フローの概要

1. クライアントから ID　プロバイダに認証リクエストを送る
- リダイレクト

GoogleOAuth2 strategy -> OAuth2 strategy

2. 認証レスポンスが返ってきたらトークンリクエストを送る
3. 返ってきた ID token を検証して認証。必要に応じてアクセストークンを発行

`OmuniAuth.config.test_mode`

## 入門『状態』
[入門『状態』 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/shinkufencer/)

### オブジェクトと状態について
電球の例  

内部に持つインスタンス変数で表現できる

### 辛くなるポイント
表現される幅が増えると辛い

インスタンス変数を適宜再代入している -> 読みづらい

考慮しないといけない点が増える

1. 可能な限り変化させない
再代入をさせないように

2. 限定的にする
`attr_accessor` になっているとどこからでも変更できちゃう  
専用のメソッドを用意する

3. シンプルに少なく保つ

### Rails では？
コントローラーでのインスタンス変数への再代入  
状態を決定するメソッドを用意する

長い判定式は辛いね

状態として定義されることで読みやすくなる

## Hotwire光の道とStimulus
[Hotwire光の道とStimulus | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/nay/)

Stimulus が増えるとあまり旨みはないよねえ  

コンポーネントっぽくやると  
画面がそれをオーガナイズしなければならない  
現在の画面の状態をコンポーネントが知らない

なるべく制御をサーバに集める

### クライアントサイドの設計指針
Stimulus は画面別にはしない。必然性がない

何をやりたいかを考えて汎用的に作る

### パラダイムの違い
Hotwire は Rails との組み合わせで React っぽくなっている  

画面を変更するのも Rails の役目

### Stimulus の担当領域
1. htmlブラウザの拡張
2. サーバ処理を待つ処理
3. サーバによらない画面変更
4. 描画の拡張


### 何を担当すべきでないか
画面の変更

---

汎用的な機能としてやりたいことをデザインしていく

惰性でコントローラーを作らない  
目的とかをちゃんと考える

Ghost Form Pattern -> 万葉さんのプロブにあるそうな

- 設計段階で汎用的に考える
- サーバーから与えられたものを使う

## The One Person Framework 実践編
[The One Person Framework 実践編 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/asonas/)

Rails8 がかなり面白い

1人分の脳に収まるフレームワーク

居住可能性(habitable) 心地よくかつ自信を持って変更できる

1人じゃなくてもチーム単位で考える  

認知負荷
- 課題内在性負荷
- 課題外在性負荷
- 学習関連負荷

## Data Migration on Rails
[Data Migration on Rails | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/ohbarye/)

今回はデータの移行や変更に焦点を当てる 狭義のマイグレーション  
schema migration とは違う。data migration

One-Person Framework は時代と逆行している

### data migration で起きがちな問題
- 手作業によるオペミス
- 長時間の data migration による障害

01 ~ IPO までの間で避けて通れない

### 代表的なアプローチ
1. SQLによる直接データ操作
- ActiveRecord::Base.connection とか
- callbacks, validation は実行されない
- data の整合性が担保されているのか？
- 権限管理の問題
- オペミスを防ぐ機構

2. rails console, rails runner(one liner)
- データを眺めたり、対話的に実行可能
- validations, callbacks が適用される
- スクリプトをコピペで貼るのが怖い

3. db:migrate と同時に実行
- schema migration, data migration を同時に行いたいときに便利
- 既存のデプロイや schema migration に乗っかりやすい
- schema migraiton -> 後世に残る
- data migration -> 一時的なもの。ライフサイクルが違う
- data migrationは特定の環境以外では不要な時がある

4. rake task, ruby script
- テスト記述が比較的容易
- rails runner でも同様のことができる

5. 専用gem の活用
いっぱい gem がある…

- `maintenance_tasks`
  - GUI がついているのか！  
  - Job が一時停止・再開が可能

rails g script -> Rails 8 から  
script/ に .rb ファイルが作られる

Rails Guides 7.2 ~ データの変更とスキーマの変更を分離しましょう  

seed script は全環境で通用する冪等なものにすると捗る  

## Identifying User Identity
[Identifying User Identity | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/moro/)

### ユーザーとは何か
色々な「ユーザー」がいる

サービスを利用する目的や利用方法が違う  

identify したい単位がユーザーである

ユーザーアイデンティティ

基本的には主キー id だけのテーブル

human_id 人間向け

### id  だけのテーブル
ユーザーが「いる」ことを表現できる

```
users <- user_profiles
users <- user_credentials
```

秘匿性の高い情報の入るテーブルを分析環境から見えなくする

fk 制約とユニーク制約を忘れずに  

### ユーザーログイン
- ログインしているユーザーを判別する
- ログイン操作そのものの機能

### #current_user
`session[:user_id]` に `users.id` が保存されている

- ユーザー本人の所有物にアクセスできる
- ユーザーとしてサービスを利用できている

ユーザーIDを指定してセッションに入れる -> ログイン機能の構築の前に開発を始められる

#### ログイン操作そのもの
IDaaS やライブラリも使える。OmniAuth 便利  

#### 自前でやる場合も
- 本人だけが入力できる情報を突合、本人確認
- 確認できたユーザーのID をセッションに入れる

### ユーザーとしてサービスを利用したい
登録フローを完了したときにアイデンティティが生まれる

```rb
class UserRegistration

belongs_to :user, optional: true
```

メールアドレスや事前聴取のアンケードなども保存できる
各項目を空白可にしておくと長いフォームにも対応できる

最終ステップでバリデーションする

ここでそのサービスにおけるユーザーアイデンティティが生まれる

users table にいるのは登録完了したユーザーのみ

登録部分も複雑に育っていく -> users table と分けておくと便利

### 退会したい
退会しても「いたこと」の事実は残す必要がある

credential を消すこともできる。消したらログインもできない  
users table 以外の情報を消せる

### 管理スタッフが特別な権限でログインしたい
アイデンティティプールを分ける

権限の違いではなく、そもそも別機能にできる

---

ユーザー管理周りは複雑だが、原則に沿って整理できる

大事なエンティティ

## 基調講演
[基調講演 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/snoozer05/)

これは感動しかなかった。よくプログラミング言語やフレームワークは単なる「道具」だと言われるが、それよりもはるかに大きいものになり得るのだ

