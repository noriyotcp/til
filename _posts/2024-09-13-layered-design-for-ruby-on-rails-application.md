---
date: "2024-09-13 00:37:58 +0900"
last_modified_at: "2024-10-24 12:57:39 +0900"
tags:
  - Ruby
  - Ruby on Rails
categories:
  - Books
---

# Part 1: Exploring Rails and Its Abstractions

## Chapter 1: Rails as a Web Application Framework

### The journey of a click through Rails abstraction layers
Railsアプリケーションにおけるクリックの処理を、以下の層を通じて説明します。
1. **Webリクエストとアーキテクチャ**: レイヤードアーキテクチャの適用理由とWebアプリケーションのライフサイクル。
2. **Rack**: HTTPリクエストとRubyアプリケーション間のインターフェース。
3. **Railsルーティング**: リクエストを適切なコントローラアクションにマッピング。
4. **コントローラ**: リクエストをビジネスロジックに変換し、UIを更新。
5. **リクエスト外の処理**: バックグラウンドジョブなどによる非同期処理。

### trace_locationとは
`trace_location` gemは、ライブラリやフレームワークの内部処理を追跡するためのツールで、RubyのTracePoint APIを使用。これは、メソッドの呼び出しや戻りをトレースし、Railsアプリケーションのリクエスト-レスポンスサイクル中のRubyメソッドコールを追跡するのに役立つ。

### Beyond requests – background and scheduled tasks
バックグラウンドジョブとスケジュールジョブにより、HTTPリクエスト以外の作業を効率的に処理する方法を説明。

- **背景ジョブの必要性**: スループットを向上させるための非同期処理。
- **ジョブとキューの抽象**: ジョブの定義とキューの利用。
- **スケジュールされたジョブ**: クロックトリガーによるジョブとそのスケジューリング方法。
- **バックグラウンドジョブのエコシステム**: SidekiqやActive Jobの使用。

### ActiveJobの導入の背景
ActiveJobは、さまざまなバックグラウンドジョブライブラリの統一されたインターフェースを提供し、ジョブのスケジューリングとエンキューイングをシンプルにする。

### The heart of a web application – the database
データベースがウェブアプリケーションの中心的な役割を果たし、パフォーマンスと抽象化のトレードオフについて説明。

- **データベースの重要性**: データベースの健全性がアプリケーションパフォーマンスに与える影響。
- **抽象化とパフォーマンスのトレードオフ**: 過度な抽象化がパフォーマンスに及ぼす影響。
  - 抽象化の目的: 抽象化は実装の詳細を隠すために使用されるが、必ずしもパフォーマンスの向上に繋がるわけではない。例えば、データベースに対する簡単なインサート操作も、抽象化が過度に使用されるとパフォーマンスに悪影響を及ぼすことがある。
  - データベースレイヤーでの処理: 一部の機能はデータベースレベルで処理する方がパフォーマンスと生産性の両方でメリットがある。例えば、監査記録の保持や論理削除（soft deletion, レコードを削除する代わりに「削除済み」とマークする）などの機能は、アプリケーションコードで実装するのではなく、データベースのトリガやカスタムタイプを使用する方が効率的である。
- **データベースアブストラクションの戦略**: 一貫性を保つためのビジネスロジックのデータベースレイヤーへの移行。

以上が概要で、各コンポーネントがどのように連携してWebアプリケーションを構築し、効率的に動作させるかについて学びます。

## Chapter 2: Active Models and Records


### 以下 AI による要約

この内容は、Ruby on Railsアプリケーションのモデル層に焦点を当てています。特にActive RecordおよびActive Modelの使用と潜在的な落とし穴に関する理解を深めることを目指しています。Active Recordは、データベーステーブルの名前で名付けられたクラスを使用することでプロセスを簡略化し、さらなる設定が不要です。一方、あまり知られていないActive Modelは、Active Recordのようなモデルを作成したり、Active Recordからドメインモデルを抽出するために使用できます。旧バージョンのソフトウェアに適用可能な様々なコードサンプルが提供されています。これには、状況遷移や整合性ルールのデモンストレーション、Active Recordの規約による設定(CoC)の利点などが含まれます。また、純粋なRubyオブジェクトがActive Modelにより強化されたクラスよりも優れているシナリオや、この知識をチャーン計算器と組み合わせて、チャーンと複雑さでトップNファイルを表示することが可能かどうかなど、重要な問いも提起します。

### Data-mapper model についての説明
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

