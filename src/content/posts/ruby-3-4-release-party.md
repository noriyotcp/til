---
title: "Ruby 3.4 リリースパーティー presented by STORES / アンドパッド"
date: "2024-12-26 18:46:23 +0900"
last_modified_at: "2024-12-26 23:41:37 +0900"
tags:
  - "Ruby"
  - "Events"
---
# Ruby 3.4 リリースパーティー presented by STORES / アンドパッド
https://andpad.connpass.com/event/336742/

## `it` が目玉機能w

この位置で `it` が使える

```rb
"foo".then do
  p "bar".then { it.upcase }
  p it # ここ
end
"BAR"
"foo"
=> "foo"
```

ナンパラだと使えない

```rb
"foo".then do
  p "bar".then { _1.upcase }
  p _1
end
<internal:kernel>:168:in 'Kernel#loop': (irb):11: syntax error found (SyntaxError)
   9 | "foo".then do
  10 |   p "bar".then { _1.upcase }
> 11 |   p _1
     |     ^~ numbered parameter is already used in inner block
  12 | end
```


## `frozon_string_literal` がデフォルトの方向になる  
なくなるわけではない。もっと後のバージョンアップでデフォルトになる  

明示的に書く人は少ないのか？ linter で怒られるんじゃないかなあ？

## キーワード引数の `**nil` を渡せるようになった
空ハッシュを渡したのと同じ

```rb
def hello(name: "default")
  puts "Hello, #{name}"
end

h = { name: "noriyo" }
hello(**h)
Hello, noriyo

h = nil
hello(**h)
Hello, default
```

## `Array#fetch_values` が追加された

```rb
> ["foo", "bar", "baz"].fetch_values(1, 2)
=> ["bar", "baz"]

# 境界外のアクセスには IndexError
["foo", "bar", "baz"].fetch_values(1, 4)
<internal:array>:211:in 'Array#fetch': index 4 outside of array bounds: -3...3 (IndexError)
	from <internal:array>:211:in 'block in Array#fetch_values'
	from <internal:array>:211:in 'Array#map!'
	from <internal:array>:211:in 'Array#fetch_values'
	from (irb):10:in '<main>'
	from <internal:kernel>:168:in 'Kernel#loop'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/lib/ruby/gems/3.4.0/gems/irb-1.14.3/exe/irb:9:in '<top (required)>'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in 'Kernel#load'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in '<main>'

# block がある場合はそれを呼ぶ
["foo", "bar", "baz"].fetch_values(1, 4) { 42 }
=> ["bar", 42]


# values_at は境界外アクセスには nilを返す
> ["foo", "bar", "baz"].values_at(1, 4)
=> ["bar", nil]
```

## Hash 生成時に必要な容量を指定できるようになった
`capacity:` で指定できるようになった

```zsh
 ❯ time ruby -e 'n = 10_000_000; h = Hash.new; n.times{ h[it] = it }'
ruby -e 'n = 10_000_000; h = Hash.new; n.times{ h[it] = it }'  2.63s user 0.29s system 85% cpu 3.421 total

 ❯ time ruby -e 'n = 10_000_000; h = Hash.new(capacity: n); n.times{ h[it] = it }'
ruby -e 'n = 10_000_000; h = Hash.new(capacity: n); n.times{ h[it] = it }'  1.90s user 0.16s system 82% cpu 2.485 total
```

## 整数の整数乗が `Float::INIFINITY` を返さないようになった

```rb
# Before
> 2**136279841 - 1
(irb):2: warning: in a**b, b may be too big
=> Infinity

# after
# 時間がかかるが素直に計算している
> 2**136279841 - 1
=> 88169432750383326555393910037811735897120735450906604106715637641242263069475684144172599034772328310883750973995977687416411861067989576855>
# 結果はデカすぎて見切れている
```
## each できない Range に対して `Range#size` が例外を投げるようになった

```rb
# before

(0.1..1).size
=> 1 # 今まで1を返していたのがびっくり
(...0).size
=> Infinity

# after
(0.1..1).size
(irb):1:in 'Range#size': can't iterate from Float (TypeError)
	from (irb):1:in '<main>'
	from <internal:kernel>:168:in 'Kernel#loop'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/lib/ruby/gems/3.4.0/gems/irb-1.14.3/exe/irb:9:in '<top (required)>'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in 'Kernel#load'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in '<main>'

(...0).size
(irb):2:in 'Range#size': can't iterate from NilClass (TypeError)
	from (irb):2:in '<main>'
	from <internal:kernel>:168:in 'Kernel#loop'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/lib/ruby/gems/3.4.0/gems/irb-1.14.3/exe/irb:9:in '<top (required)>'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in 'Kernel#load'
	from /Users/noriyo_tcp/.rbenv/versions/3.4.1/bin/irb:25:in '<main>'
```

## Time の Range に対して `Range#step` が使える
これは捗りそう

```rb
> pp (Time.new(2000, 1, 1)...).step(86400).take(3)
[2000-01-01 00:00:00 +0900, 2000-01-02 00:00:00 +0900, 2000-01-03 00:00:00 +0900]
```

## Hash#inspect の結果が変わった

```rb
# before
h = { user: 1 }
=> {:user=>1} # この時点でファットアロー
p h
=> {:user=>1}

# after
h = { user: 1 }
=> {user: 1}
p h
{user: 1}
```

テストで `=>` を使った文字列が返ってくるのを期待するとこけるかも  
そもそも inspect の結果をテストの期待値に使うべきではないのか。 request の結果なんかに使ったりするかなあ？どうなんだろ

## 小数から文字列への変換時に、小数部なし文字列を解釈するようになった

```rb
# before
Float("1.")
<internal:kernel>:214:in `Float': invalid value for Float(): "1." (ArgumentError)
	from (irb):7:in `<main>'
	from <internal:kernel>:187:in `loop'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/lib/ruby/gems/3.3.0/gems/irb-1.13.1/exe/irb:9:in `<top (required)>'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/bin/irb:25:in `load'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/bin/irb:25:in `<main>'

Float("1.E-1")
<internal:kernel>:214:in `Float': invalid value for Float(): "1.E-1" (ArgumentError)
	from (irb):8:in `<main>'
	from <internal:kernel>:187:in `loop'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/lib/ruby/gems/3.3.0/gems/irb-1.13.1/exe/irb:9:in `<top (required)>'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/bin/irb:25:in `load'
	from /Users/noriyo_tcp/.rbenv/versions/3.3.4/bin/irb:25:in `<main>'

# after
Float("1.")
=> 1.0
Float("1.E-1")
=> 0.1
```

## Happy Eyebools v2
IPv4, IPv6 に同時並行で接続しにいって、先に応答があったほうで接続を開始する

## `katakata_irb` -> `repl_type_completor` が `bundled gem` になった  
名前が変わったの知らなかった

## JSON の性能が向上
これは嬉しい！

## Ruby のリリースについて
CI が通っていればリリース可能とみなす。実務で問題が出るかはまた別  
チケットはたくさんあるけどそれを気にしていたらリリースできない（それはそう）

参考記事：  
[プロと読み解くRuby 3.4 NEWS - STORES Product Blog](https://product.st.inc/entry/2024/12/25/154728)

