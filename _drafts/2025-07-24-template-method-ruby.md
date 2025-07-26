---
title: "RubyにおけるTemplate Methodパターン"
date: "2025-07-24 00:17:45 +0900"
last_modified_at: "2025-07-24 00:17:45 +0900"
tags: 
  - "Design Patterns"
  - "Ruby"
  - "Template Method"
---

これは Gemini CLI に調査と解説を依頼した結果です。

## 概要

Template Method パターンは、GoF(Gang of Four)によって定義されたデザインパターンの1つです。アルゴリズムの骨格をスーパークラスのメソッドとして定義し、具体的な処理のステップをサブクラスに委譲（オーバーライドさせる）します。

このパターンを利用することで、アルゴリズムの構造を変えることなく、特定の実装だけを柔軟に変更できます。

## 実装例

以下に、レポート生成を題材とした Template Method パターンの実装例を示します。

- `Report`クラス: 抽象クラス。レポート生成のアルゴリズムを `generate` メソッドとして定義（これがTemplate Method）。
- `HTMLReport`, `PlainTextReport`クラス: 具体的なクラス。それぞれのフォーマットに合わせて、`Report`クラスのメソッドをオーバーライド。

```ruby
# report_generator.rb

# 抽象クラス: レポート生成の骨格を定義
class Report
  def initialize(title, text)
    @title = title
    @text = text
  end

  # これがTemplate Method
  def generate
    output_start
    output_head
    output_body_start
    @text.each do |line|
      output_line(line)
    end
    output_body_end
    output_end
  end

  # サブクラスに実装を強制する抽象メソッド
  def output_start
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end

  def output_head
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end

  def output_body_start
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end

  def output_line(_line)
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end

  def output_body_end
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end

  def output_end
    raise NotImplementedError, "サブクラスで #{self.class}##{__method__} を実装してください"
  end
end

# 具体的なクラス: HTML形式でレポートを出力
class HTMLReport < Report
  def output_start
    puts '<html>'
  end

  def output_head
    puts "  <head>"
    puts "    <title>#{@title}</title>"
    puts "  </head>"
  end

  def output_body_start
    puts '  <body>'
  end

  def output_line(line)
    puts "    <p>#{line}</p>"
  end

  def output_body_end
    puts '  </body>'
  end

  def output_end
    puts '</html>'
  end
end

# 具体的なクラス: プレーンテキスト形式でレポートを出力
class PlainTextReport < Report
  def output_start; end
  def output_head
    puts "**** #{@title} ****"
    puts
  end
  def output_body_start; end
  def output_line(line)
    puts line
  end
  def output_body_end; end
  def output_end; end
end
```

## 抽象メソッドの実装方法に関する考察

Rubyには `abstract` のようなキーワードがないため、サブクラスに実装を強制する抽象メソッドは、慣習的に `raise` 文を使って表現されます。

### `raise NotImplementedError` の問題点

最も一般的なのは `raise NotImplementedError` を使う方法ですが、注意が必要です。

`NotImplementedError` は `StandardError` のサブクラスでは**なく**、`ScriptError` のサブクラスです。そのため、`rescue => e` のような一般的な例外捕捉ではキャッチされず、意図せずプログラムが停止する可能性があります。

これは、`NotImplementedError` が元々「サブクラスでの実装忘れ」ではなく、「実行中のプラットフォーム（OSなど）で機能がサポートされていない」ことを示すために設計された例外だからです。

### 推奨される代替案

より堅牢な設計のためには、以下の方法が推奨されます。

1.  **独自の例外クラスを定義する**
    `StandardError` を継承した独自の例外クラスを定義することで、意図通りに `rescue` できるようになります。

    ```ruby
    class AbstractMethodError < StandardError; end

    class MyBaseClass
      def my_method
        raise AbstractMethodError, "This method must be implemented by a subclass"
      end
    end
    ```

2.  **ダックタイピングに任せる**
    基底クラスではメソッドを定義せず、サブクラスでの実装に任せます。もし実装されていなければ、呼び出し時に自然と `NoMethodError` が発生します。これは非常にRubyらしいアプローチです。

## 参考資料

- **Template Method パターン全般**
  - [Refactoring.Guru - Template Method](https://refactoring.guru/ja/design-patterns/template-method/ruby/example)
- **Rubyにおける抽象メソッドと `NotImplementedError` について**
  - [Abstract Methods and NotImplementedError in Ruby - Nithin Bekal](https://nithinbekal.com/posts/abstract-methods-notimplementederror-ruby/)
- **Ruby公式ドキュメント**
  - [class NotImplementedError (Ruby 3.3.0)](https://docs.ruby-lang.org/ja/latest/class/NotImplementedError.html)
