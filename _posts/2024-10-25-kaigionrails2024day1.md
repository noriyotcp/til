---
title: "Kaigi on Rails 2024 Day1"
date: "2024-10-25 11:26:42 +0900"
last_modified_at: "2024-10-25 14:32:34 +0900"
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
