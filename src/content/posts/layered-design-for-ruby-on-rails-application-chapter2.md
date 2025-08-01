---
title: "Layered Design for Ruby on Rails Applications - Chapter 2: Active Models and Records"
date: "2024-09-13 00:37:58 +0900"
last_modified_at: "2024-12-22 00:52:15 +0900"
tags:
  - "Ruby"
  - "Ruby on Rails"
  - "Books"
draft: false
---
注：以下の文章は、機械翻訳や Packt に備わっている Assistant AI による要約から成り立っている

# Part 1: Exploring Rails and Its Abstractions - Chapter 2: Active Models and Records
## 以下 AI による要約

この内容は、Ruby on Railsアプリケーションのモデル層に焦点を当てています。特にActive RecordおよびActive Modelの使用と潜在的な落とし穴に関する理解を深めることを目指しています。Active Recordは、データベーステーブルの名前で名付けられたクラスを使用することでプロセスを簡略化し、さらなる設定が不要です。一方、あまり知られていないActive Modelは、Active Recordのようなモデルを作成したり、Active Recordからドメインモデルを抽出するために使用できます。旧バージョンのソフトウェアに適用可能な様々なコードサンプルが提供されています。これには、状況遷移や整合性ルールのデモンストレーション、Active Recordの規約による設定(CoC)の利点などが含まれます。また、純粋なRubyオブジェクトがActive Modelにより強化されたクラスよりも優れているシナリオや、この知識をチャーン計算器と組み合わせて、チャーンと複雑さでトップNファイルを表示することが可能かどうかなど、重要な問いも提起します。

## Data-mapper model についての説明
Hanami での実装例が紹介されている。

```rb
class PostRepository < Hanami::Repository
  associations do
    has_many :comments
  end
  def latest_for_user(user_id)
    posts.where(user_id:).order { id.desc }.limit(1).one
  end
end
class CommentRepository < Hanami::Repository
  def latest_for_post(post_id, count:)
    comments.where(post_id:)
        .order { id.desc }
        .limit(count).to_a
    end
  end
latest_post = PostRepository.new.latest_for_user(user_id)
latest_comments = CommentRepository.new.latest_for_post
  (latest_post.id, count: 3)
```

基本的に、私たちはActive Recordが裏でやってくれていたすべてのことを、最初から書き直しました。一方では、より多くの（退屈な）コードを書く必要がありました。他方では、クエリの完全な制御を手に入れ、データベース通信APIについて考える必要があります。そして、考えることは決して損ではありません。

Data-mapper patternの主な利点は、データベースとビジネスロジックの分離です。このパターンを使用すると、データベースアクセスコードはリポジトリクラスにカプセル化され、ビジネスロジックから独立した形で管理・再利用できます。結果として、ビジネスロジックはデータベースの詳細を知らずに、データへのアクセスや操作を行うことができます。これにより、コードの読みやすさ、保守性、テストの容易さが向上します。また、リポジトリがデータアクセスの詳細を抽象化しているため、後々データベースの変更が必要になった場合でも、ビジネスロジックのコード変更は最小限で済む可能性があります。

このコードでは、リポジトリパターンを使用してデータベース操作を抽象化しています。これにより、データへのアクセスとその操作を疎結合に保つことができ、テストや保守が容易になります。また、`PostRepository` と `CommentRepository` に動作を集中させることで、コードの再利用が容易になります。具体的なメソッドでは、ユーザーの最新の投稿を取得するための `latest_for_user(user_id)` と、指定した投稿に対する最新のコメントを取得するための `latest_for_post(post_id, count:)` を提供しています。これにより、最新の投稿やコメントを簡単に取得する事ができます。

## From mapping to the model
セクション「From mapping to the model」では、アプリケーションの状態またはモデルが永続化のスキーマだけでなく、データベーススキーマがアプリケーションモデルの反映であると述べています。さらに、モデルは遷移規則と一貫性の規則も記述します。遷移規則は状態をどのように変更できるかを定義し、一貫性の規則は可能な状態の制約を定義します。例えば、遷移規則として「投稿は公開後に下書きに戻すことができません」、一貫性規則として「タイトルが空でない場合のみ投稿を作成できる」といった例があります

```rb
class Post < ApplicationRecord
  validates_with PublishingValidator, on: :publish
  def publish
    self.status = :published
    save!(context: :publish)
  end
end
```

このテクニックは、モデルの保守性をきちんと保ちながら、Rails Wayにできるだけ近づけるのに役立ちます。 しかし、コンテキストの数が増えるにつれて、単一のモデルクラス内でそれらすべてを追跡することは難しくなります。 バリデーションとルールに関するモデルレイヤーの複雑さに対処するために使用できる抽象化については、第7章「モデルの外側でユーザー入力を処理する」と第8章「表現レイヤーを引き出す」で説明します。

## Seeking God Objects
この章で述べられている "churn" とは、特定のファイルがどのくらい頻繁に変更されたかを示す指標です。高い変更率は、コードデザインの欠陥を示している可能性があります。それは、新たな責任を追加したり、初期の実装の欠点を修正しようとしている場合があります。Churnを測定するために、Gitのようなバージョン管理システムを使用して、それぞれのファイルが影響を受けたコミットの総数を計算することができます

```
$ git log --format=oneline -- app/models/user.rb | wc -l
408
```

`app/models/user.rb` に変更を加えたコミット数をカウントするコマンド。408回の変更があることがわかる。

[flog](https://github.com/seattlerb/flog) や [attractor](https://github.com/julianrubisch/attractor) といった gem でコードの複雑度を測定したりする

1. Active RecordパターンとData Mapperパターンの主な違いは何ですか？
Active RecordパターンとData Mapperパターンの主な違いは、Data Mapperパターンがモデルと永続化を分離する点です。Active Recordはデータベースのレコードを表現し、読み書き操作を内包しますが、Data Mapperはクエリやデータの保存には別のオブジェクトを要求し、ドメインレイヤーとドメインサービス間の明確な分離を提供します。

2. モデルバリデーションはいつ使用すべきで、データベース制約はいつ使用すべきですか？
モデルバリデーションは、主にアプリケーションレベルでのデータ整合性を確保するために使用され、より説明的なエラーメッセージや、条件やコンテキストに応じた柔軟なバリデーションが可能です。一方、データベース制約は、プログラミングエラーや予期せぬ状況でもデータベースレベルでの強固な保証を提供します。

3. ダックタイピングとは何ですか、そしてRailsではどのように利用されていますか？
ダックタイピングは、オブジェクトの型やクラスをそのメソッドやプロパティによって判断する技術です。Railsでは主にActive Modelインターフェースを通じて、具体的なタイプを要求せずに特定の動作セットを持つオブジェクトとやり取りするためにダックタイピングが利用されています。

4. どんな場合に、純粋なRubyオブジェクト（Structインスタンスのようなもの）がActive Model強化クラスよりも優先されますか？
純粋なRubyオブジェクトは、データベースとのやり取りが不要な場合のシンプルなデータ構造が必要なときに優先されます。これは、軽量で管理やテストが容易なソリューションを提供します。

5. チャーンとは何ですか、そしてそれはコードの複雑さとどのように関係していますか？
チャーンは、コードの一部（例えばファイル）が時間の経過とともにどれくらい頻繁に変更されるかを示す指標です。これは、コードデザインの潜在的な問題を示す指標として使われます。高い変更率は、設計上の弱点を示しており、複雑さが増し維持が難しくなる可能性があります。

