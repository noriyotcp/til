---
title: "Layered Design for Ruby on Rails Applications - Chapter 6: Data Layer Abstractions"
date: "2024-12-21 18:10:37 +0900"
last_modified_at: "2024-12-22 16:58:58 +0900"
tags:
  - Ruby
  - Ruby on Rails
categories:
  - Books
---

# Part 2: Extracting Layers from Models - Chapter 6: Data Layer Abstractions

注：以下の文章は、機械翻訳や Packt に備わっている Assistant AI による要約から成り立っている

## Using query objects to extract (complex) queries from models

### 要約

このコンテンツは、ドメインレイヤー抽象化について教育し、Active Recordモデルの肥大化を低減することに重点を置くものである。
これには、モデルから複雑なクエリを抽出するためのクエリオブジェクトの使用と、リポジトリによるドメインと永続性の区分化の価値について学ぶことが含まれる。ここでは、コードの量を最小限に抑え、デザインプロセスを簡単にするため、既存の規約に準拠することの利点を強調する。
新たなエンティティの追加ごとに新たなアプローチを考え出さなければならない必要をなくすのである。

また、コンテンツは、`#find` メソッドがどのように動作するかについても探求する。これは、レコードが見つからない場合に例外をトリガーせず、nullを出力する。見つからないオブジェクトに対する行動のコースは、呼び出しを開始するコードに委ねられるのである。
次の章では、プレゼンテーションレイヤーなどの上位のアーキテクチャレイヤーからの抽象化を用いて、Active Recordモデルの責任を減らす戦略について深く掘り下げる予定である。

- クエリオブジェクトを使用してモデルから (複雑な) クエリを抽出する
- ドメインとリポジトリによる永続性の分離

---

重要な保守性の特性の1つは、チャーンレート（第2章「アクティブなモデルとレコード」を参照）、つまりコードを変更する必要がある頻度である。コードの変更はビジネスロジックの変更によって引き起こされる可能性があるが、これを避けることはできない。ただし、依存関係における互換性のない変更を処理するために必要な変更もあるのである。

コードのもう1つの重要な特性は、テストのしやすさである。Active Recordクエリチェーン内のほぼすべてのメソッド呼び出しはロジックの分岐を表すため、（理想的には）テストでカバーする必要がある。また、コントローラーでコードをクエリする場合は、より遅い統合テストを作成する必要があるため、テストの実行時間が長くなり（生産性に悪影響を及ぼす）、これが必要になる。

クエリが複雑になればなるほど、周囲のコードの保守性、ひいてはアプリケーションの安定性への影響が大きくなるのである。Railsには、複雑なクエリをモデルクラスのメソッドまたはスコープに移動するという一般的なパターンがある。クエリをリファクタリングする方法は次のとおりである。

```rb
class User < ApplicationRecord
  def self.with_bookmarked_posts(period = :previous_week)
    bookmarked_posts =
      Post.kept.public_send(period)
          .where.associated(:bookmarks)
          .select(:user_id).distinct
    with(bookmarked_posts:).joins(:bookmarked_posts)
  end
end
# Now we can use this query as follows
User.with_bookmarked_posts
```

クエリをモデルに抽出すると、コードの重複排除と分離の向上に役立つが、モデルクラスが神のオブジェクトになりがちである。また、モデルは、非常に不安定なユーザー向けのさまざまな機能を担当することになり、チャーンレートも増加する。

新しい抽象化レイヤーであるクエリオブジェクトを導入することで、モデルの肥大化を回避する方法を見てみるのである。

### Extracting query objects

`User.with_bookmarked_posts` は、別のオブジェクトに抽出される良い候補である。まず、このメソッドは自己完結型であり、モデル定義自体とは結合されていない。第2に、ロジックはコンテキスト固有である。つまり、単一（または少数）のアプリケーションコンポーネントによってのみ使用されるため、モデルクラスには汎用ロジックのみを保持することを好む必要があるのである。

```rb
class UserWithBookmarkedPostsQuery
  def call(period = :previous_week)
    bookmarked_posts =
      Post.public_send(period)
          .where.associated(:bookmarks)
          .select(:user_id).distinct
    User.with(bookmarked_posts:).joins(:bookmarked_posts)
  end
end

UserWithBookmarkedPostsQuery.new.call
```

### Pattern - query object

クエリオブジェクトは、ドメインレベルのオブジェクトを入力として使用してクエリ（通常はSQLだが、必須ではない）を構築するオブジェクトである。したがって、クエリオブジェクトの主な役割は、永続層をドメインから分離することである。

単純な抽出でも有益であるが、新しい抽象化レイヤーを導入するには十分ではない。

そのためには、シグネチャか規約が必要である。一般的な問題に対する解決策も提供する必要がある（たとえば、新しいオブジェクトを作成するときの定型句を減らすなど）。

### From pattern to abstraction

まずはシグネチャから始める。クエリオブジェクトにとって意味のあるAPIはどれであろうか？これらのオブジェクトは単一目的であり、データストアに対するクエリを構築して解決するものである。したがって、単一のパブリックインターフェイスメソッドが必要である。良い名前を付けよう。

前の例では、`#call` メソッドを使用した。RubyとRailsでは、唯一のAPIメソッド `call` （いわゆる呼び出し可能インターフェイス）に名前を付けるのが一般的である。ただし、この名前ではオブジェクトの目的があまり伝わらない。これは一般的すぎる。#resolve など、抽象化にもっとわかりやすいインターフェイスを使用してみるのである。

```rb
class ApplicationQuery
  def resolve(...) = raise NotImplementedError
end
```

シグネチャを完成させるには、パブリックメソッドのパラメーターと戻り値を決定する必要がある。メソッドは `#initialize` （コンストラクター）と `#resolve` の2つだけである。コンストラクターに渡される引数は、初期状態またはコンテキストを表す必要がある。Active Recordのクエリオブジェクトを構築しているため、適切な初期状態はActive Recordリレーションオブジェクトになる可能性がある。

これにより、`Model.all` だけでなく、任意のスコープにクエリオブジェクトを適用できるようになる。同様に、`#resolve` メソッドの戻り値も、他のクエリオブジェクトまたはActive Recordメソッドでさらに変更できるように、Active Recordリレーションである必要がある。次のアイデアに従って基本クラスを更新しよう。

```rb
class ApplicationQuery
  private attr_reader :relation
  def initialize(relation) = @relation = relation
  def resolve(...) = relation # resolve はリレーションを返す
end
```

```rb
class UserWithBookmarkedPostsQuery < ApplicationQuery
  def resolve(period: :previous_week)
    bookmarked_posts = build_bookmarked_posts_scope(period)
    relation.with(bookmarked_posts:)
            .joins(:bookmarked_posts)
  end

  private

  def build_bookmarked_posts_scope(period)
    return Post.none unless Post.respond_to?(period)

    Post.public_send(period)
        .where.associated(:bookmarks)
        .select(:user_id).distinct
  end
end

UserWithBookmarkedPostsQuery.new(User.all).resolve
UserWithBookmarkedPostsQuery.new(User.where(name: "Vova")).resolve(period: :previous_month)
# resolve はリレーションオブジェクトを返すので、次のように書き直すこともできる
UserWithBookmarkedPostsQuery.new(User.all).resolve(period: :previous_month).where(name: "Vova")
```

### Updated query object

```rb
# default relation を設定する
class UserWithBookmarkedPostsQuery < ApplicationQuery
  def initialize(relation = User.all) = super(relation)
end

UserWithBookmarkedPostsQuery.new.resolve
```

クラスからインスタンスへの委任を追加することで、`.new` 呼び出しを削除することもできる。

```rb
class ApplicationQuery
  class << self
    def resolve(...) = new.resolve(...)
  end
end
UserWithBookmarkedPostsQuery.resolve
```

### クエリオブジェクトに規約を導入する
規約とは、もの (コードやファイルなど) に名前を付け、編成する方法に関する一連のルールであり、プログラムが機能を暗黙的に推測するために使用できる。言い換えれば、規則に従うことは、コードの量を削減し、設計プロセスを簡素化するのに役立つ (新しいエンティティを追加するたびに車輪の再発明をする必要がないため)。

まず `UserWithBookmarkedPostsQuery` とそのコンストラクターを見る。

```rb
# before
class UserWithBookmarkedPostsQuery < ApplicationQuery
  def initialize(relation = User.all) = super(relation)
  # …
end
```

私たち人間は、クエリ オブジェクトのクラス名から、このクエリ オブジェクトがUserモデルを処理していると推測できる。いくつかの命名規則を追加することでそれを行うことができる。たとえば、クエリ オブジェクト クラスを対応するモデル名前空間に保存するように要求できる。

```rb
# after
class User
  class WithBookmarkedPostsQuery < ApplicationQuery
  end
end
```

次に、ベースクラスを更新してクラス名からデフォルトのリレーションを自動的に推測できるようにしている。

```rb

class ApplicationQuery
  class << self
    def query_model
      name.sub(/::[^\:]+$/, "").safe_constantize
    end
  end
  def initialize(relation = self.class.query_model.all)
    @relation = relation
  end
end

class User
  class WithBookmarkedPostsQuery < ApplicationQuery
    # …
  end
end

User::WithBookmarkedPostsQuery.query_model
=> User

# うーん、別にこれでもいいのでは？ cf. https://www.writesoftwarewell.com/how-to-get-objects-class-name-in-ruby-rails/
class ApplicationQuery
  class << self
    def query_model
      name.split("::").first.safe_constantize
    end
  end
  def initialize(relation = self.class.query_model.all)
    @relation = relation
  end
end

User::WithBookmarkedPostsQuery.query_model
=> User
```

