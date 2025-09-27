---
title: "KaigiOnRails 2025 Day2"
date: "2025-09-27 02:43:12 +0900"
last_modified_at: "2025-09-27 02:43:12 +0900"
draft: true
---

## memo
### [2重リクエスト完全攻略HANDBOOK | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/ShoheiMitani/#day2)

はい、皆さんおはようございますさえます。
2日目のこんな朝早い時間に皆さん来ていただいて非常に嬉しく思っております。
はい。
ということで二重リクエスト攻略ハンドブックっていうえ発表させていただきます。
はじめにあの二重リクエストとは何なのかっていうところから行こうかなと思うんですけど、えっとこれはこう誤って複数回同じリクエストが送られてしまって、ま重複して処理が行われることみたいなものを二重リクエストと今日は呼ぼうかなというふうに思ってます。
これはあのーサブミットボタンが似回されたとか、登録画面がリロードされたとか、あとはなんか外部サービス連携してる時に複数回同じあのデータがリトライとかで送られてきたとか、あるいはなんか自分が作っているバッジに不具合があって、2回こう実行だとか、まいろんなケースがあるかなというふうに思います。
で、ネットとかで見ると、なんか二重サブミットみたいな言い方もあるんですけど、今回はこうウェブブラウザ以外でも起こりうる問題として扱いたいので、二重リクエストっていう風な感じで、この発表の中では、えー喋っていこうかなと思います。
あと2回以上リクリクエストするケースもあると思うんですけど、ま便宜上分かりやすいので、二重リクエストっていう感じで喋っていきたいなと思います。
で、もしこう二重リクエストが発生したらどうなるかっていうと、ま分かりやすいとこでいくと、ま掲示板に同じ内容が2回投稿されてしまうとか、あとは同じ商品が2回購入されて、2回こう残高かが減るとか、ま、決済じゃなくても送金とか予約とか出品とか、あと報酬付与とか申請とか、まこういうのっていろいろ起こり得る問題かなというふうに思ってます。
で、まー自分たちの中だけの問題だったらいいんですけど、そういうなんかバグみたいなものを悪用されて、不正攻撃を受けるまセキュリティフォールみたいになるものもあるかなというふうに思ってます。
で、この二重リクエストの対策って意外と難しくて、クライアントだけで制御すればいいんじゃないかっていうとそうじゃないんですよね。
なんかクリック連打するとか、戻ってから再送信するとか、なんかいろんなユーザーさんのこうアクションをどれだけカバーできるかとか、せっかく対策した内容がブラウザのディベロッパーツーで変えられるみたいのもあると思いますし、複数タブとか、あとは複数端末で、なんか意図的にこうやってくる人もいるなとか、あとは外部サービスからの自動載送とかっていうのは、クライアント側の制御はできないとかもあるし、バックエンドでテーブル設計うまくやればなんか大丈夫でしょうっていう、ま感じで思われる方もいらっしゃるかもしんないんですけど、ま必ずしも、あのいいテーブル設計が毎回できるわけじゃなかったりとか、なんかロックが取れない状況もあったりとか、あと意図した複数回の操作と悪意ある複数回の操作、そういう二重リクエストを判別そもそもできんのかとか、考えると結構奥が深いんですよね。
とはいえこうわざわざ改言レーズで発表するほどのテーマなのかっていうと、まこれだけ皆さん来てもらってるってことは、それだけなんか皆なさん興味があるのかなと思っているますけど、なんかウェブで検索して出てくる方法って、なんかウェブブラウザを前提としているものが多いんですよね。
なんかjavascriプトでとか確認ダイアログ出してとか、まその中でもここに挙げて20サブミットを許出さない友の会ですごいいいタイトルのブログがあるんですけど、これはなんかよくまとまっていると思います。
ただ現実のアプリケーションは複雑こう本当に色んなケースがあって、毎回対策を調べたり、なんか独自に方法を編み出すっていうのをそろそろ個人的に疲れまして、まこれだけ見てればだいたい大丈夫でしょうみたいなものを作りたいっていうのが今回の動機ですね。
ということで今日の発表テーマは、こう誰にとっても身近でこう重要な二重リクエストの問題に、もう悩まなくていい世界を作りたいなと思ってて、ま二重リクエストの問題が何なのかっていう話と、あとそれに対しての対策って何があるのか、あとはユースケースに応じてどういう風に使い分ければいいかっていうところを、えっとこの30分間で喋っていきたいなと思ってます。
まー令和七年時点での情報をまとめたハンドブックみたいな感じにしたくて、結構ちょっと強めなタイトルを付けたつもりではありますね。
なので業務で遭遇した時にこう見返せでようになればいいかなというふうに思っていて、ただ、えっと自分が知らない対策とかもいっぱいあると思うので、ぜひ皆さんの中で今日を挙げた方法以外に、こういうことをやってますっていうのがあったら、この後x上げてもらったりとか、あと、この後自分にいろいろ教えてもらえと嬉しいです。
で、えーそれなりのパターン説明するので、個々の詳細をしゃべっている時間がないので、結構割愛してスイスイ行こうかなというふうに思ってます。
はい、でちょっとここで自己紹介を改めてしますと、えースマートバンクでエンジニアリングマネージャーやってる三谷と言います。
エンジニア歴は11年目ですね。
で、レイルズはここにあるファブリックって二社目の時から触ってるので、ま七年ぐらいずっとレイルズで開発してる感じになります。
結構個人的にこう日常で使ってるサービスを、なんかの裏側みたいなものを、できるだけま企業秘密とかもいろいろあるんですけど、公開可能な形に落とし込んでこう発表していくのが好きで、ま去年だとekycとか、これはオンラインの本人確認ですね。
あとはカード決済みたいな話をビルダーズコンとヤプシーでさせてもらって、今年の11月はあの会社では競馬全くやってないんですけど、機械学習までは触ってるんで、競馬を使ってこう機械学習を皆さんにお伝えするみたいな発表もしようかなというふうに思っているのえっともしやっぱ福岡行かれる方はこのトークも聞きに来てください。
であとは開発現場での実践値をこう抽象化したり汎用化して学びにあの変えていく活動も好きなので、改元レジだとかこうなんか監視についてあのさせてもらったりとか、えっと状態管理についてとか、テーブルて義変更とか、そういう話もさせていただきました。
今日はどっちかっていうと、こっちの観点でまだトークを持ってきたて感じになります。
はい、ということで、えっと話を戻しまして、二重リクエストの防御策について話していこうかなと思います。
えまず前提の擦り合わせですね。
えー今日紹介する防御策のスコープが何かっていくと、ポストとかプットとかデリートとかの更新系の操作をま中心に扱おうかなというふうに思います。
まーもちろんここであのー紹介する内容は、ゲット系の参照系のapaにも使えるんですけど、まー主にはえっと恒系のものを対象に喋っていこうかなと思います。
まー具体的にはこう送信者にこう悪意はないんですけど、まー自己的に起きてしまう二重陸エストの防御策とか、例えばなんかサブミットボタン何度も押せるみたいな、なんか実装萌えとかバグが入ってきた時の対応とか、あとはバックエンドがタイムアウトしてクライアントがリトライしてきたみたいなケースですね。
で、もう一方は、えっと送信者はこう悪意を持って二重リクエストを行うような問題への防御策も喋っていこうかなっていうふうに思います。
まー脆弱性をついてリプレイ講義してくるとか、複数端末でこう意図的にデータをおかしくしてやろうみたいな気持ちでやるケースですね。
あとは仕様として同じ内容の操作が、あの許容されているケースって全然あると思うんですよね。
同じ商品を短時間で何回も買うとか、xに何回もと同じ投稿するみたいな、そういうものをこう区別して、えハンドリングするみたいな話もしていこうかなというふうに思います。
で、物としては、えっと複数の防御策を複数のこう防御網で考えるのが、えっといいかなっていうふうに思っていまして、これから紹介する中では、こうクライアント側でえやる対応についてはこの左側の印をつけて、バックエンド側でやる、えー対策についてはこの右側の印を付けながら紹介していこうかなと思います。
で、今日は全部で9個ですね、意外とあると思い、思うのか、こんなもんかって思うのかどうでしょうかね。
はい。
まちょっとこの9個について、順を追って説明していこうかなというふうに思います。
ひとつ目がですね、えっとーサブミットボタンの制御っていうことで、ま最も基本的で、なんか一番最初に知るであろう二重リクエスト対策かなというふうに思います。
えっとー右側のえこのアニメーションみたいな感じで、えっとボタンを押したら完了するまでで非活性化するみたいな、まー超シンプルな方法ですね。
レイズ五.0から6.1までだったら、レイルズujsがあの標準ライブラに入ったんで、まデータディスウェイbウィズっていうのを付けると、これができたって感じですけど、今はそれがえっと外れたので、スティミラスで自作するみたいな感じになるかなと思います。
まーこれはもうやらないっていう選択肢はないんじゃないかなって思うぐらいのものですかね。
はい、あんまりこれをやってないサービスは見たことがない気がします。
で、二つ目の対策がですね、えっとポストリダイレクトゲットパターンっていうprgパターンっていう方法があります。
これはブラウザのリロードによるこう二重リクエストを防ぐ方法としてあって、ポストンのリクエストが完了した時に、ま直接htmlを返すんじゃなくて、まー結果表示ページこうリダイレクトしてくださいというレスポンスを返す方法ですね。
で、こうすることによって、処理完了終わった後にブラウザでリロードボタン押されても、リダイレクト先がこう、リロードされるだけなんで、もともとのポスト処理は、えっと二重リクエストにならないって。
いうふうな対策ですね。
ただこう戻るボタンを押して、前画面に戻ってからもう一回サブミットボタンを押すみたいな、そういうケースには対応できてないんですけど、まー単純なこうリロードに対しては、えっといいアプローチかなというふうに思っています。
まーこんな感じで、あの対策をこれから9個説明していくと思うので、お付き合いください。
で、三つ目がえっと排他制御を使って、えー対策する方法ですね。
まー排他制御っていうのは、あるプロセスだけがリソースのアクセス権を独占することで、ま同時に操作できるプロセスをひとつに制限する仕組みのことで、まクライアントでどんだけ対策しても二重リクエストは絶対に防げないんで、サーバー側でこうできるだけ安全に処理して防御するっていう風な考え方のアプローチですね。
で、同時に同じリソースをま操作すると、まデータの不整合って起こりやすいと思うんですよね。
まーデータベースで言うとファントムリードとかファジーリードとか、まそこら辺の問題ありますし、まロストアップデートとかのなんか問題もあったりする感じですね。
で、同時実行を防ぐことで、ま処理内部で考慮しなければならないことが減らせるんで、まこうしておくと簡単だよねみたいな感じの考えです。
で、rdbを利用している時に最も簡単に利用できるのは主観的ロックかなというふうに思っていて、まアクティブレコードだとウィズロックってやつを使うと、このロックが取れるって感じです。
で、一方なんか捜査対象に対して適切なロックを必ずしも取れるケースがあるかっていうと、まそうではないケースもあるかなというふうに思います。
その時になんか、使えるものとしては、えっとアドバイザリーロックっていうものがあって、レイルズで言うとゲットアドバイザリーロックっていうメソッドがあって、この第一引数に渡している文字列に対してこうロックを取得できるみたいな感じですね。
なのでレコード自体がなくても、えロックは取ることができます。
あとはなんかロック専用のテーブルをあえて作ったりとか、まレディスを使って、えロックトルみたいな方法で、えー悲観的ロックっていうのは実現できるかなと思いますし、もしあの非同期的に処理してもいいケースの場合には、急に逃がすっていう方法もあります。
あのファイフォっていうファーストインファーストアウトっていうので、ま一番最初に入れた球が一番最初に処理されるっていう気を使うことで、ま実質的に排たて制御しているような形が取ることができるって感じですね。
一方でなんか注意点もあって、えっと排他制御ってなんか同時に操作されることをこう防いでるだけなんで、なんかロック解放された後の対応は別途考えて対策しなきゃいけないっていうものになってます。
で、即座にあのロック待ちになったら、えっとエラーにしたい場合には、ウィズロックの後ろにフォーアップデートノーウイトってあの引数を渡せるんで、これでエラーを発生させることもできます。
ただ即時エラーさせるみたいな考え方も、なんか二つのプロセスが同時にロックをした場合に限るんで、なんかタイムラグがあって、二重リクエストが来た時みたいなのは、この対策はあんまり意味がないので、そこは注意が必要って感じですね。
あと何でもドック取っていいかっていうとそうでもなくて、二重リクエストを防ぎたいapi以外にも関係するリソースに対してこうロックを取ってしまうと、そっち側のapiに影響があるので、そこも考える必要があるかなって感じですね。
ということで、えっと排他制御とセットでやっぱ考えた方がいいのは、テーブル設計をうまくするってやつですね。
まーこれも二重リクエストが発生しても、データの整合性を保てるようこうテーブル設計しておくことで、ま防御する方法です。
で、排他制御とは異なって、あの同時にま来なくてもテーブル設計さえうまくやっていれば、あるべきデータの姿が保てるので、二重リクエスト対策になるみたいな感じですね。
で、テーブル設計ってま本当にいろんな方法があるかなというふうに思っていて、ま全部を紹介することはできないので、ま個人的によく使う二つの方法を紹介したいと思います。
ひとつがま状態遷移をルール化するっていう方法で、ま状態間の遷移ルールっていうのを定義することで、二重リクエストを受け取った時に、この状態ルールの遷移はエラーですよっていうふうな、えっとはエラーの発生のさせ方ですね。
ここの右上に書いてあるやつだと、ま注文ってテーブルがあって、一番下に注文状態っていうまイナムのカラムがあるって感じですね。
ここに注文キャンセル、請求発送みたいな状態が記録されるみたいな感じです。
ここに対して状態遷移のルールを定義するイメージで、まキャンセル状態は注文からしか遷移できないみたいな感じですね。
デイルズだとあのasmっていうジェムがあって、ま右下に書いてある漢字で、まイベントドゥーみたいな感じでトランジションを定義するみたいなことができるっていう感じになってます。
で、もうひとつのアプローチはユニーク制約をつける方法かなと思っていて、えっとユニーク制約をつけることで、同じように状態遷移を起きた時にエラーを発生させるみたいな感じですね。
まー右の例だと注文状態ごとにテーブルを分割して、注文idにこうユニークの制約を付ける感じになっているので、まさっきあったナの各ステータスを、ま注文キャンセル、請求発送テーブルに分けていて、その注文id、えーと外部機に対してユニーク制約を付けているっていう感じですね。
なので、注文キャンセルってリクエストと、ま2回送ったとしたら、1位制約でエラーが起きるみたいな、そういうガードの仕方になっています。
まどっちを選べばいいのかなっていうふうなのはあるかなって思うんですけど、えっとー状態遷移のルール化みたいな方法って、えデータベースだとロストアップデートに対しての注意が必要かなというふうに思っています。
えっとここでトランザクションまー二つこう書いてるんですけど、トラン一っていうので、えテーブル一に対して、えっと注文家で請求って状態変更しましたと。
で、トランザクション二つ目のやつが回収した時はテーブル、えー一番最初の状態はまだトランザクション一が更新してないので、ま注文状態でもう一回請求に変えましたみたいなやつって、状態遷移のルールを、えっと請求から請求に変えないっていうふうなことを定義したとしても、まトランザクション分けた時に、えっと更新内容は読み取れないんで、そういうルールがすり抜けちゃうんですよね。
なので、トランザクションを貼る場合には、排他制御とセットにして考えるべきかなと思いますし、まただしこう、後勝ち仕様みたいな感じにしていいんだったら、まーこれは考えなくていいかなというふうに思います。
一方ユニーク製薬の場合には、えっとトランザクションをコミットしたタイミングで、あの一位制約エラーが発生するんで、そこら辺を考えなくていいみたいな利点があるかなというふうに思います。
というので、なんか最後の障壁をデータベースに寄せるっていうのは結構便利かなと思いますね。
で、打って変わって全然違うあの対応方法なんですけど、レートリミットを付けるっていうのも、二重リクエストにはま一定有効な方法かなと思います。
まー排他制御とか状態制移のル化とかユニーク制約っていずれもこうアプリケーションの中でデータベースと三つ結合にこう対応するアプローチなんですけど、例えばなんか、クレジットカードに申し込むみたいな、現実的に1秒間におんなじクレジットカード2回申し込めてないと思うんですよね。
そういう仕上割り切れる時には、あのアプリケーションよりもう少し上のレイヤーで、あの防御することは可能かなと思っていて、デートリミットっていうのは、あのシステムへのこう過度な負荷を防ぐために、一定期間に処理できるリクエスト数をまー制限する方法なんですけど、例えばユーザーidとかをキーにして、apiにレートリミット導入して、ま一定期間、ま1時間でも1日でも10秒でもいいんですけど、一回しかリクエストできないようにしておけば、二重リクエスト来た時には、後から来たやつがエラーになるみたいな感じのことを仕込むことができます。
イメージとしてはこんな感じですね。
えっとポストペイメンツでアイテムidをこうリクエストした時に、urlとアイテムidを指定しておいて、えー保存しておいて、えっともしなかったら、えーそのまま成功を返す。
で、もし、えっと過去に同じリクエストを受けて取っていて、カウントが一以上だったらもうエラーを返すみたいな、まこういうか単純なアプローチになります。
で、レートリミット自体はアマゾンのapiゲートウェイとか、まーそういうところで標準的な機能として提供されているものもあるので、えーそこでのあの例えば、アマゾンのレートリミマだとまスロットリングか、だとなんか適用範囲をリージョンとかエピアキーとかメソッドとか、なんかそのうち制限があるので、その中で、あの仕様として作れるんだったら、そういうの簡単に使えるかなというふうに思います。
一方でなんか細かい制御で、制御、細かい単位でこう制御が必要な時っていうのは、こういうレートリミットみたいなのは自前で実装する必要があるかなみたいな感じですね。
税率だとなんか調べた感じ、ラックアタックとかスロットリングみたいなジェムがあるので、そこら辺が使えるかなというふうに思います。
でも次がこうapiキャッシュですね。
一度受け付けたリクエストのレスポンスを保存しておいて、同じリクエストが来た場合にはキャッシュを返してま正常として、えー戻すと、そういうことでこうべき当性を担保するアプローチがあります。
クライアント側から見ると、二重で送信した時にどっちも成功扱いでハンドリングできるっていうところが、まレートリミットとの違いで、まいいところですね。
まーこれもamazonapiゲートウェイとかのえー機能を利用することで、まあアプリケーションの外側で対策することは可能かなというふうに思います。
これも簡単にだけいくと、まポストでペイメンツなんちゃらってやつを、えーキャッシュとして保存しておいて、えーもし、えー過去に一件もなかったら、そのまま処理して成功を開始して、えーその後にレスポンスボディーを保存しておくって感じですね。
で、もしある場合には保存されているレスポンスボディーを取ってきて、えキャッシュとして返すみたいな、そういう方法です。
で、キャッシュを使うことの一般的なこう困難さに、これはえ立ち向かわなきゃいけないアプローチになっていて、まそもそもキーをうまく設計できるのかとか、えーキャッシュの有効期限どうするかとか、そもそもレスポンスボディのサイズがキャッシュできるサイズの枠内に収まっているのかとか、まゲットとかだったら結構皆さんこれ行けるんじゃないかなと思うんですけど、本当にポスト系系のapiに対して副作用がないかっていうのは、本当にちゃんと考えなきゃいけない。
あとはキャッシュが保存されるまでの間に2回リクエスト来ちゃうと、これは全然あの意味がない対策になっちゃうので、そこも考える必要があるって感じですね。
ということでもう少しポストによって、あのちゃんとした対策を考えられているのがアイデンポテンシーキーヘッダーってやつです。
これはあのクライアントがリクエストにこう1位に識別できるキーをえ裁判して、それを減った情報にこう送っていくことで、そのキーをもとに適当なapiを構築するアプローチで、えーこれはえー同僚の大場さんが2021年の開業例率と24年のヤプシーでかなり深く話しているので、興味がある方はこっちの資料も覗いてみてください。
ざっくり言うとクライアントがキーを裁判して、アイデンポテンシーキーっていうヘッダーを入れて、で、それをキャッシュのキーとして保存するって感じですね。
で、これもけば普通に処理して、えレスポンスボディーを保存して、え返す。
で、2回目来た時にこのキーがあればレスポンスボディー取ってきて、えーそのままキャッシュとして返すみたいな感じです。
じゃあapiキャッシュとアイ伝ポテンシーキーヘッダー何が違うかっていうと、まーi伝波テンシーキーヘッダーっていうのは、キャッシュ、apiキャッシュより複雑なんですよね。
か、なので、ま柔軟かつ堅牢なべ、あのapiサーバーが作れるかなというふうに思っていて、クライアントが値を裁判して送ってくるっていうことは、同じ端末での操作っていうのは、なんか区別できるし、同じ端末の中でも、なんかリトライ同じキーだったらリトライ操作だし、別のキーだったら、一からまたやり直したなみたいなことを判別ので、そこら辺がすごくメリットとしてあったり、あとは未処理とか処理中とか処理済みみたいな細かくステータス管理することもできるので、えっとー、apiキャッシュの方で説明したキャッシュが保存されるまでは意味がないみたいなところへの対応もまきめ細マイクできるって感じですね。
で、危険な更新系の操作に対してこう安全にえ適当性を持たせるっていう意味だと、y伝ポテ式ヘッダーの方が優れていると思いますし、まーあんまり副作用がなくて、ここまで作り込まなくていいってやつだったら、apiキャッシュで十分なケースもあるかなというふうに思います。
で、また別のアプローチとして、eタグとiフマッチっていうものを組み合わせた方法があります。
eタグっていうなんか更新対象のなんかバージョンをタグ管理して、えっとクライアント側がiフマッチヘッダーで、えーそれを送ることで、条件付き更新リクエストをやるみたいなアプローチですね。
これはまー一般的には楽観的ロックみたいな感じの方法です。
まーサーバー側ではクライアントから送られてきたキーをもとに、一致してたら処理して、一致してなかったら、これはもう古いんでリクエストしませんってエラー返すみたいな感じです。
ま右のテーブルルの例だったら、あのバージョンカラムを言いタグとして利用することもできれば、あと内容ってそのテキスト自体からハッシュ値を求めて、えーそれをバージョン管理するみたいな方法もまいろいろあるかなというふうに思います。
これもざっくりいくと一番最初にゲットしてえ言いタグのバージョンを取ってきて、それをiフマッチのヘッダーに設定して、でそのバージョンをサーバー側で見てハンドリングするって感じですね。
で、もし送られてきたバージョンが今のバージョンと違ったらエラーを返すみたいな、そういうアプローチです。
でこれはなんか楽観的ロックで防いでる方法なんで、こう変更されやすい理想性の導入にはちょっと不向きかなというふうに思ってます。
例えばecサイトで商品購入するみたいな複数人が同時で購入するケースって、画面開いたタイムでバージョンを取ってきて、で、それをもとにやっちゃうと、ま結構更新頻度が増えるんで、エラーになりがちかなというふうに思います。
逆にこうユーザーのプロフィール変更みたいな一人しか変更しないし、めったに変更しないみたいなケースには結構向いてるかなというふうに思いますね。
で、クライアントがヘッダーを付与するっていう意味だと、遺伝ポテンシーキーヘッダーとおんなじなんですけど、ま違いとしてはアイデンポテンシー機ヘッダーって、ま名前がイ伝ポテン主義でベトっていうことなんで、ま適当なapiを提供するところが大きな目的になっていて、言いたのifマッチはまー同時更新を防ぐっていうのが、大きな目的になっているので、まーえっとーアプリケーションの特性によって使い分けるのがいいかなと思っています。
でようやく最後ですね、えっとーワンタイムトークンっていう方法を紹介しようと思います。
これは一度だけ使用可能なトークンを発行することで、二重リクエストを防ぐアプローチになっていて、まこれ自体は、こう二重リクエストを防ぐって目的以外に、なんか正当なリクエストであることをなんか保証するみたいな、不正対策目的でも結構使われるアプローチかなと思います。
あとネットで調べると、あのトランザクショントークンチェックみたいな感じで紹介されたりもしていて、えーまーそれに近しい感じですね。
あとcsrfってシーサーフトークン自体も同じようなえートークで管理する手法なんですけど、シーサーフの文脈だとトークがこうワンタイムであるってことはあんまり、あの必須化されてないので、ちょっと分けてワンタイムトークンっていうものを紹介します。
これも流れ的にはすごく単純で、一番最初にこうトークンを取得して、で、そのトークをヘッターなり、リクエストボディーに入れるみたいな感じですね。
で、そのトークンが有効だったら処理するし、もし、えーおちょっと変な感じになってるけど、もし、えっとー有効じゃなかったらエラーを返すみたいな、そういうアプローチになってます。
ということで防御策のまとめをしていきたいかなと思います。
今日紹介したのがえっとここの都こういうのがありましたと、えもう少し分かりやすく言うと、えクライアントで防御する方法がサブミットボタンで、バックエンドだけで防御するっていう方法が、prgパターンとか、排他制御テーブル設計レトリミット、apiキャッシュみたいな。
で、クライアントと一緒にバックエンドが連携して防御する方法としてアイデンポテンシキーとか、eタグとかワンタイムトークンがあったみたいな感じになってます。
で、自分の考えとしてはですね、基本はサブミットボタンで制御を、あ等drgパターンと、排他制御プラステーブル設計を行っていれば、ほぼほぼなんか十分なケースが多いかなっていうふうに思っていて、まーデータの整合性が確保される予をテーブル設計していれば、仮に発生したとしても致命的な問題にはならないので、あーまー大丈夫かなと思うんですね。
で二重リクエスト自体、なんか全体のリクエストから見ると、結構エケースだなと思うんですよね。
あんまり計測したことはないですけど、まあ数パーセントぐらいしか起こらないんじゃないかなというふうに思っていて、まそこに対してどれだけ対策をするかっていう話で、まそれはなんか二重リクエストが発生した時にどういう被害が出るのか、例えば決済とかだったらユーザーさんからお金が引き落とされてしまうので、それはやばいよねとか、ま得られるメリットを想定して、まー適切なアプローチを選択するのがいいかなというふうに思ってます。
残りこうなん分ぐらいなんで、あのワンバンクで実際に利用している防御策を、それをなんか理由と一緒に最後説明していこうかなと思います。
えっとワンバンク改めて説明すると、あ自分が作っているサービスですね。
あのai家計簿アプリになっていて、まプリペイドカードを発行しているので、そこにこう入金したりとか、そこに入金したお金を出金したりとかできます。
で、マイクロサービスまではいかないんですけど、舌出るっていうキテクチャーになってたりとか、ま外部サービスをよく使ってるっていうサービスになってます。
でアイデンポテンシーキーヘッダーは結構使ってまして、えっとこれ改めて説明すると、クライアント側で裁判したキーを使って適当なapi構築する方法ですね。
特にえっとー外部サービスえ重要な操作をする処理で、結構使っていて、まコンビニとかペイジーとかで、えっとレジで支払ってもらうための情報を取得する処理とか、クレジットカード入金してもらう時のスリーdsの処理とか、あと銀行口座から引き落としすることができるんで、そこのための処理とかですね。
で、外部サービスとの連携処ってめっちゃ複雑なんですよね。
あの前段でなんか前処理して、外部サービスリクエストしてそれを結果コミットするみたいな、トランザクションが複数に分かれるんで、排他制限も複雑になるし、自社側と外部サービスが両方でデータ不整合になる可能性があるんで、もし発生したリカバリ処理が大変ですと。
で、リカあのアイデンポ電子ヘッダー利用することで、本処理のこう前段で、この二重リクエスト対策できるっていうのは、データ不整合が発生するリスクを減らすことができるんで、すごくいいかなと思ってます。
あとはまー自己的な二重リクエストと、意図的な別のリクエストを区別できるっていうのも魅力的で、例えばプリペイドカードの入金って、同じ金額であの何回も入金されても、まそんなにおかしくはないんですよね。
なので、キーが同じであれば、自己的な方法なので、入金処理は行わない。
キーが違うんだったらこれは意図的だから、通すみたいな感じのハンドリングがすごくやりやすいです。
なんか一方でこうキーのチェック処理とか、登録処理とかのオーバーヘッドは増えてしまうっていうのは現実だし、クライアント側でのキー裁判処理とか実装コストもやっぱ一定かかるので、導入箇所はこういう重要な処理に絞って使ってるって感じです。
あとはワンタイムトークも使ってまして、アプリの中で特に重要な処理ですね。
パスコード登録するとか、あとカード番号を表示するとか、あと、あの後払いチャージとか銀行引き落としとかの入金処理で使ってる感じになってますまーこの右の例でいうとこのパスコードを入力した時にトークに取ってきて、それをもとにリクエストするみたいな感じですね。
でこれはま自己的なえ二重リクエストを防止する目的はまもちろんあるんですけど、主にはこうリクエスト内容の登調とかリプレイ攻撃を防ぐ目的のために使ってます。
リプレイ攻って何かっていうと、まーサイバー交易の一種で、まー一回送信された情報を盗聴しておいて、それをもう一回送ることで不正なえー行為をするみたいなやつですね。
まー入金処理がこう盗聴されて、何回もあの入金されてしまうと、まユーザー的にもかなり不利益があるし、体験も悪いので、えーそれを防ぐ目的ですね。
ただ一方なんか自己的な入金、あー二重リクエストも防ぎたいので、あのアイデンポテンシーキーとこう組み合わせて、ワンタイムトークンを使うみたいな、えー実装しているapiも多いです。
まートークンを取得するとの実装コストとか、ユーザーの手間が発生する方法なんで、これも実装箇所はセキュリティ強度を上げたい箇所のみで、こう限定してるって感じですね。
であとはレートリミットって紹介したやつも実際に使っていて、えっと我々の中で、物理的なカードは手に入らないんだけど、カード番号だけ入手できるっていうサービスがあって、それはなんかバーチャルカードっていうものがあります。
で、バーチャルカードは、えっと別に何回再発行してもらってもいいんですけど、まー基本なんか数秒とか1分間に何回も再発行する人っていうのは、あんまりいないし、正常な状態ではないかなっていう風な感じです。
で、間違えてカード発行起きた時って、この一番下にある外部サービス側にもその発行された情報が残っちゃうんで、それを取り、取り消すと結構大変なんですよね。
なので、ユーザーごとに発行回数を制限し、あの保存していて、指定回数を超えたらエラーする、エラーにするみたいな、そういう仕様にしています。
で、排他制御できるようにこう既存の仕組みを修正したりとか、アドバイザーリロックとかもいろいろ検討したんですけど、コスパ観点で不採用にしていて、まレートリミットの制御ってテーブル1個追加する程度で実現できるんで、ますごく簡単に導入できましたって感じですね。
まーめったに発生しないんだけど、もし発生したらみたいなやつを低コストで解決できた方法のひとつです。
あとはテーブル設計プラスキャッシュみたいな考え方で対処してるやつも多くて、コンビニとかペイジーとかの入金方法って、ユーザーさんがレジでお金を払った後に、官僚情報が非同期でウェブフックが送られてくるんですよね。
で、このウェブフックはあの外部サービス側でリトライ機能を提供されていることが多くて、タイムアウトが仮に発生した場合には、あの外部サービス側はエラーと思ってんだけど、自社側は実はなんか成功になってますみたいな、データ不整合状態があって、その時にリトライされた時に、もうこっちが成功してるから、これ不当なリクエストですってエラー返すと、延々とリトライされてエラーループになっちゃいますと。
で、外部サービスなんでアイデンポテンシーキーみたいなそういうものを使えないって感じですね。
それどうしてるかっていうと、テーブル設計和中製薬入れるみたいな感じで整合性確保しておいて、リクエスト来た時に、その状態を見て、処理完了してたら、えっとー、不当なリクエストじゃなくて、もう完了してますよみたいな感じのリクエストを返すみたいな感じですね。
で、まこれも外部リクエスト側の、そのリクエストにとあのベトを特定できるidが含まれてないと実現できないので、ま使えるかどうかは外部サービスの設計次第かなと思います。
ということで最後まとめに入ります。
今日はなんか誰にとっても身近で重要な二重リクエスト問題に悩まなくていい世界作りたいと思ってて、問題の構造と防御策とユースケースを説明してきました。
ので、もし業務でどうしようってなった時に、ぜひ見返してもらえるとありがたいです。
で、この後ブースとかにもいるので、なんかいろいろコメントあったらそこでお話ししましょう。
ありがとうございました。

Yes, good morning everyone.I'm extremely pleased that you all have come so early on this second day. Yes. So, I will present the "Double Request Strategy Handbook."First, I think we should start with what this double request is. Well, it's like when the same request is mistakenly sent multiple times, and the processing is duplicated. Today, I'm thinking of calling this a double request. This can happen when a submit button is pressed multiple times, or a registration screen is reloaded, or when connecting with an external service and the same data is sent multiple times due to retries, or when there's a bug in the badge you're creating, causing it to be executed twiceand so on, I think there could be various cases like these.So, when you look online, there's this term like "double submit," but since I want to treat this as an issue that can occur outside of web browsers too, I'm thinking of talking about it as "double request" in this presentation. I know there might be cases of more than two requests, but for simplicity and clarity, I think I'd like to talk about it as "double request."So, if a double request occurs, what happens is, well, in an easy-to-understand example, the same content might be posted twice on a bulletin board, or the same item might be purchased twice, reducing the balance twice, well,Even if it's not about payments, I think these kinds of issues can occur with things like money transfers, reservations, listings, reward distributions, or applications. It'd be fine if it was just our internal problem, but I think there might be some security flaws that could be exploited like bugs, leading to malicious attacks.So, dealing with these double requests is surprisingly difficult, and it's not just a matter of controlling it on the client-side. There are various user actions to consider, like rapid clicking or going back and resubmitting, and it's about how much we can cover these. Also, the countermeasures we implement might be changeable through browser developer tools, and there are issues with multiple tabs or devices, people intentionally trying to bypass the system, and automatic submissions from external services that can't be controlled client-side.That being said, I wonder if this is really a theme worth presenting in a revised phrase like this. Given that so many of you have come here, I think you all must be interested in it somehow. But when you search for methods online, many of them assume you're using a web browser, right? Like using JavaScript or showing confirmation dialogs. Among those, there's a blog with a great title called "The Society for Not Allowing 20 Submits" that I think is well-organized. However, in reality, applications are complexSo, today's presentation topic is about creating a world where we no longer have to worry about the problem of double requests, which is familiar and important to everyone. I want to talk about what the double request problem is, what countermeasures are available, and how to use them depending on the use case, all within these 30 minutes. I wanted to make it like a handbook summarizing information as of 2025, so I intentionally gave it a rather strong title. So, when encountered in business, you can refer back toYes, so let me reintroduce myself here. I'm Mitani, working as an Engineering Manager at Smart Bank. I've been an engineer for 11 years now. As for Rails, I've been working with it since my second company, Fabric, which is listed here, so I've been developing with Rails for about seven years continuously.I like to present the behind-the-scenes aspects of services I personally use daily, as much as possible, while respecting corporate secrets, in a form that can be made public. Last year, for example, I talked about eKYC, which is online identity verification. I also gave presentations on card payments at BuildersConf and Yappli. This November, although our company doesn't do horse racing at all, we do work with machine learning, so I'm thinking I might give a presentation on using horse racing to explain machine learning to everyone.Um, so if you're going to Fukuoka after all, please come and listen to this talk too.So, first, let's align our premises. Um, regarding the scope of the defense measures I'll introduce today, I'm thinking of mainly dealing with update operations like POST, PUT, or DELETE. Of course, the content I'll introduce here can also be used for GET-type reference APIs, but I'm mainly planning to talk about things related to updates. Specifically, I'll discuss defense measures against accidental double requests that occur unintentionally, even when the sender has no malicious intent, such as when a submit button can be pressed multiple times.Like, you know, dealing with implementation moe or when bugs come in, or cases where the backend times out and the client retries, that kind of thing.So, as for the approach, I think it's good to consider multiple defense strategies in multiple defense layers, and in the introduction I'm going to make, I'll mark the client-side measures with this left mark, and the backend measures with this right mark while introducing them, I think.So, today we have 9 in total, surprisinglyI wonder if I think it exists, if I wonder, or if I think this is about it or not.Yes. I think I'll go through and explain these 9 items in order.I think it might feel like creating it yourself with Stimulus. Well, it's probably something where you can't really choose not to do it anymore. Yeah, I don't think I've seen any services that don't do this.So, the second countermeasure is, well, there's a method called the Post/Redirect/Get pattern, or PRG pattern. This is a way to prevent double requests caused by browser reloads, and when a POST request is completed, instead of directly returning HTML, it's a method that returns a response saying "please redirect to the result display page." By doing this, even if the reload button is pressed in the browser after the process is completed, only the redirect destination is reloaded, so the original POST process doesn't result in a double request.That's the kind of countermeasure it is.Well, it can't handle cases like pressing the back button, returning to the previous screen, and then pressing the submit button again, but I think it's a good approach for simple reloads. I'll be explaining 9 countermeasures like this, so please bear with me.And, the third one is, um, a method to address it using exclusive control. Well, exclusive control is a mechanism that limits the number of processes that can operate simultaneously to one by allowing only one process to monopolize the access rights to a resource. No matter how much you try to prevent it on the client side, you can't absolutely prevent double requests, so it's an approach of processing as safely as possible and defending on the server side.It's the idea that, you know, by preventing concurrent execution, it reduces what needs to be considered within the process, making it simple.So, when using RDB, I think the easiest thing to use is probably optimistic locking, and with Active Record, you use something called "with_lock", and it feels like you can get this lock.So, on the other hand, when you ask if there are cases where you can always take appropriate locks on the investigation target, I think there might be cases where that's not possible. In such situations, what you can use is something called an advisory lock. In Rails, there's a method called 'get_advisory_lock', and it's like you can acquire a lock for the string passed as the first argument. So even if the record itself doesn't exist, you can still get a lock.Also, you could intentionally create a dedicated lock table, or use something like Redis to implement a lock control method. I think pessimistic locking could be achieved this way. And in cases where asynchronous processing is acceptable, there's also the option of suddenly releasing. Using FIFO (First In First Out), where the first ball entered is processed first, you can effectively achieve exclusion control, it seems, you know.On the other hand, there's like a point to be careful about, um, exclusive control is just preventing simultaneous operations, so you gotta think about and deal with what happens after the lock is released separately, you know.So, if you want to immediately make it an error when it goes into that lock wait, you can pass that argument called "for update nowait" after "with lock", and this will allow you to cause an error as well.The idea of just causing an immediate error is only applicable when two processes lock simultaneously, so it's not very effective for cases with a time lag, like when double requests come in. That's something to be careful about. Also, it's not always good to lock everything. If you lock resources related to APIs other than the ones you want to prevent double requests for, it can affect those other APIs, so that's another thing to consider.So, um, what you should definitely consider along with exclusive control is, you know, designing the tables well. Well, this is also a method of defense by designing the tables in a way that maintains data consistency even if double requests occur.One method is to formalize state transitions as rules, defining transition rules between states. This way, when a double request is received, we can say "this state rule transition is an error," which is how we generate errors. As shown in the top right, there's an "order" table with an enum column called "order status" at the bottom. It records states like order cancellation and invoice shipping. The idea is to define state transition rules for this, like the cancelled state can only transition from orderIt's like that, you see.In Dales, there's this gem called asm, and with the kanji written in the bottom right, you can define transitions in a way that's like an event do, that's how it's set up.I'm wondering which one to choose, but I think that for methods like rule-based state transitions, we need to be careful about lost updates in databases. Here, I've written two transactions, where in the first one, we changed the state to "billed" for the order in Table 1. Then, for the second transaction, when it's collected, the table's initial state is still transactionSince one hasn't been updated, for something like changing it back to billing status when it's still in order status, even if we define a rule that prevents changing from billing to billing in the state transition, when we split the transactions, we can't read the update content, so such rules can slip through. Therefore, when applying transactions, I think we should consider it in conjunction with exclusive control. However, if it's okay to have a "last one wins" specification, then we probably don't need to worry about this.So, switching gears to a completely different approach, I think adding a rate limit could be an effective method for dealing with duplicate requests. While approaches like exclusive control, state transition rules, and unique constraints all deal with this within the application in conjunction with the database, consider something like applying for a credit card. Realistically, you can't apply for the same credit card twice in one second, right? In cases where we can make such clear-cut distinctions, at a layer slightly above the application, um, defendingThe image is like this, you see. Um, when you request an item ID with post payments like this, you specify the URL and item ID, um, save it, and if it doesn't happen, um, just return success.So, if, um, we've received the same request in the past and the count is more than one, then we'll return an error, like, well, it's this kind of simple approach.For example, with Amazon's rate limiter, it's like throttling, and there are restrictions on things like regions, API keys, or methods. If you can create it within those specifications, I think it could be easy to use. On the other hand, when you need fine-grained control, you might need to implement rate limiting yourself. For Rails, I've found that there are gems like Rack::Attack or throttling, so I think those might be usable.But next is the API cache, right? There's an approach to ensure idempotency by storing the response of a request once it's been processed, and if the same request comes in again, returning the cached response as successful. From the client's perspective, the good thing about this, compared to rate limiting, is that when sending duplicate requests, both can be handled as successful. I think it's possible to implement this outside the application using features like Amazon API Gateway.To put it simply, you save that payments whatchamacallit thing from the POST as a cache, and if there's never been one before, you process it as is, start the success, and then save the response body, kinda like that, you know?So, this approach needs to address the general difficulties of using cache. Can we design the keys well? How do we handle cache expiration? Is the response body size within the cacheable size limit? For GET requests, I think most people can handle this, but for POST-type APIs, we really need to carefully consider if there are any side effects. Also, if 2 requests come in during the time until the cache is savedIf it comes to that, this will become a completely meaningless measure, so it feels like we need to consider that as well, don't you think?So, to elaborate a bit more on the post, there's a proper countermeasure called the idempotency key header. This is an approach where the client includes an identifiable key in the request, sends it along with the reduced information, and then builds an appropriate API based on that key. My colleague, Mr. Oba, has talked about this in great depth in the 2021 business case study and the 2024 Yappsy, so if you're interested, please take a look at those materials as well.Roughly speaking, the client judges the key, inserts a header called an idempotency key, and then saves it as a cache key. If this is present, it processes normally, saves the response body, and returns it.So, when it comes the second time, if this key exists, it gets the response body, uh, and it's like it returns it as a cache, you know.So, if you ask what's the difference between API cache and idempotency key header, well, the idempotency key header is more complex than the API cache, you know. So, I think we can create a flexible and robust API server. The fact that the client sends a value after judging it means that operations on the same device can be distinguished, and even within the same device, if it's the same key, it's a retry operation, and if it's a different key, it's starting from

----

### [小規模から中規模開発へ、構造化ログからはじめる信頼性の担保 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/kakudou3/#day2)

Kaigi on Rails Conference App

Hall Red (Venue sound)
Hall Red (JA)
Hall Blue
ハッシュタグを付けて投稿、またはハッシュタグを共有

𝕏

その事例のひとつとしてレルザアプリケーションにえ構造化ロゴを導入する際、私たちが実際にえー実践した内容を紹介します。
最後に取り組んだ課題からレイルズと構造化ロギングのこれからについて少し触れていきたいと思います。
この発表で想定する規定としては、スタートアップや新規サービスなどのえー小規模から中規模のサービス開発に関わっている方や、これから監視をはじめとした信頼性の担保を考え始めている方。
ログはなんとなく収集できているが、カツオまで踏み出せてない方に何かしら気づきになれば嬉しいと思っています。
まずログについて簡単に整理させていただきます。
ログとは何かということについてですが、いつどこで何が起こったかという詳細情報を持つ文字列データです。
まあ数値であるメトリックスよりも、多くの情報を持たせることができます。
ログは大きく二つのフォーマットに分類されます。
一とつ目が非構造化ログです。
最高、先ほどの例にも出しましたが、こちら馴染みのあるフォーマットかと思います。
レルゾデベロップメントモードで起動した際、デフォルトでコンソロールに流れるものがこれにあたります。
二つ目が構造化ログです。
こちらは今日の本題です。
各フィールドがえジェソンのようなキーバリュー形式のデータ構造をえー持つ形式であり、プログラムから機械的に解釈がしやすいものとなります。
まどちらがより良いかっていうものではなくて、えっと人間が目視さするためのものか、えーツールやプログラムからパースされるものかという用途によってフォーマットを決めることになります。
ま続いてえログの用途についてです。
この分類ははてなさんのブログを参考にさせていただいています。
ログの用途を大きく四つに分類します。
それぞれ監視調査、分析監査です。
今回は、今回はシステム障害やパフォーマンスの低下などの問題が発生したことに気づくための監視と、エラーやパフォーマンス定下など、え原因特定や不害発生時の影響範囲を把握するための調査についてお話しします。
ログについて簡単にイメージを持っていただいたところで、私たちがログ語を活用できていたのかについてえーお話ししていきたいと思います。
前提として私たちの運用しているアプリケーションの構成を簡単にえー説明させていただきます。
冒頭でお伝えしたhrプラットフォーム事業部では、え求人サイトやatsをはじめ、え複数のサービスを開発しています。
各サービスはレールズがapiモードで使用されており、モノリシックなよくあるウェブアプリケーション構成となっています。
サービスも立ち上げ期から成長期に入り、ユーザー数の増加やドメインの拡張によりシステムが複雑化してきました。
まーそのためえー不具合が発生した場合の損失や、早急な復旧に向けての調査や事後対応をはじめとした運用コストがま徐々に大きくなってきました。
まシステムのフェーズとしても複雑性と信頼性の要求が同時に高まるフェーズにえ当たります。
まこのフェーズでは仕様やアトラフィックが複雑する複雑化するアプリケーションの状態を、モーラー性高くかつ詳細に把握することが重要になってくるのではないかなと考えております。
で、あのアプリケーションの状態を網羅性ター学詳細に把握するにはどうすればいいかと言いますと、えーまーログは冒頭話ししたように、詳細度の高い情報であって、またあのアプリケーションからは通常、エラーログをはじめとした重要なイベントがえログとして出力されていることが多いかと思いますよってまーか網羅性が高いと言えます。
まーこのようなことからログはアプリケーションの状態を知るために適したデータであると言えます。
そういったところからもうロゴを活用したアプリケーションの監視調査に取り組むことは、信頼性の担保において有効な手段のひとつと言えます。
では、私たちのアプリケーション監視がどうだったかについて見ていきたいと思います。
弊社ではすでに監視するとしてデータドックが使用されていました。
メトリックスとレース、ログのそれぞれは収集されており、一部の機能は活用することができていました。
ただえっと録画ツールから正しく認識されておらず、例えば調査時にログをまー全文検索してえ頑張って検索するぐらいのえー活用にとどまっていました。
なぜデータドックをはじめとする関数ルでは、機械がパース容易な構造化ログを取り込むことへこそ、えーログを対象したとしたえアラートやエラー検知、検索などをはじめとした、ま便利なえー機能を有効化できるものだからです。
データドックを例に出していますが、え本番運用を行っているシステムであれば、何かしらログをまあのしゅ集約するツールをえー使ってロゴを送信していることも多いはずなので、まーツール勝ち時代と同じことが言えるのかなというふうに。
持っています。
まーつまりログは収集しているものの非構造化ログのため、えー監視の機能を有効化、えー有効に活用しきれていませんでした。
ということでログを構造化して信頼性の向上につなげていくことが必要となります。
ログをま最大限活用していくたびにすべきことは大きく二つあります。
えー一つ目がレイルズアプリケーションを構成する各プロセスで構造化ログが出力されている状態にすること。
二つ目が構造化ログをツールに合わせてフォーマットするの二点です。
それぞれについて私たちが実践した内容を紹介していきたいと思います。
ひとつ目のレイルズアプリケーションのログを構造化するです。
まー構造化の対象としては、アプリケーションコードからのえーレルズロガンの呼び出しと、えー内部フレームワークで出力される各種イベントログとなります。
内部フレームワークについてですが、レイルズはリクエストからレスポンスや非同期処理の一連の処理の中で、まーイベントを各所で標準でログ出力されるようになっていて、ま例のようにそれを指します。
まこれらを満たすためにレルズロガーを拡張する必要が、えーあってまいろいろやることがあります。
これでもまー一部ですね。
でまレイルズロガーを自分たちでまカスタマイズして拡張していくことは、柔軟性はあるかもしれませんが、考慮すべきことも多いです。
まーつまりまー実装や保守のコストは高くついていきます。
エルズロガーを拡張して構造化に対応させてくれる便利なジムもいくつか存在します。
ログの構造化という観点でよく挙げられるものと氏は、ログレージとえレイルセマンティックロガーではないかと思います。
まずログレッジについてですが、関数ールの格子ドキュメントで推奨されていることもあったりするので、えーご存知の方も多いのかなと思います。
リクエストログを一行にまとめることを目的としているため、構造化対象のログイベントは限定的です。
またメンテナンスの継続性についてもやや心配なところがあります。
まー続いてレイルsマンティックロガーです。
レルー全体のイベントを構造化するための多機能なものとなります。
lール全体のイベントを構造化することを目的としているので、まーフレームワークから出力される各シログを丸と構造化してくれるところが特徴ではないかなと、えー思います。
また、メンテナンスについては継続的にされているかなと思います。
で、私たちはどうしたかと言いますと、レadsemicロガーを採用しました。
私たちのようにリソースが限られた中においては、レイルズから出力される各シログを簡単に丸っと構造化してくれるところが大きいのと、合わせてメンテナンスが継続的にされていることが決め手となりました。
レイルセマンティックローガーを導入し、あ少しの設定を加えることで、構造化ロギングに対応とはまーいきませんでした。
あ運用始めてみたところ、一部のログが構造化されていませんでした。
私たちは定期実行するバッチをレイクタスクを使って実装しています。
エクタスク内で例外処理されずまあのランタイメラーとなった場合に出力されるエラーログが構造化されていないことに気づきました。
まーどういうことかと言いますと、まず、タスクを実行します。
レクタスク内で例外が発生したとしましょう。
まー特に例外を補足くししない場合、ランタイムエラーとなります。
その場合レイク独自のログ機構で非構造化ログが出力されてしまいます。
私たちの場合レイルズロガーを拡張して構造化ログに対応させるという方針で進めているので、え困りました。
レイクノンソースコードを見つつ、もう少し理解を深めたいと思います。
レイクタスクはレイルズコマンドで実行することが可能ですが、例外処理についてはレールズのエコシステムで行われてる訳ではありません。
例外時の挙動については、レイク独自の機能を持っており、スタンダードエクセプションハンドリックというメソッドで例外を補足して、ディスプレイラーメッセージのトレースメソッドでエラーログが出力されるようなえー実装になっています。
まログする、ログ収集の網羅性をまー上げていくことが目的ですので、まーレイクタスクで発生した例外時のログについても構造化したいです。
まー調査したところ、三つほど方法がありそうだったので、まーそれぞれについて検討することにしました。
一つ目がビギンレスクエンドブロックへレクタスク内の処理を丸っと囲むっていうもので、まー例外時はレイルズロガーをま呼び出すっていうものですね。
まーシンプルでま理解もしやすいんですが、まー情長ですし、実装漏れとかはミスとか、まーそういうのを防ぐのも難しいかなと思ってます。
まー二つ目がアットエグジットブロックを定義するっていうものですね。
えーアットエグジットブロックを定義してランタイムの終了時に呼び出される処理として、レイルズロガーによるログ出力を登録しておくというものです。
まーあのー監視ツールのsdkとかでもこういう方法で、エラーログの収集をしていたりします。
で導入はブロックを定義するだけなので、簡単で一回定義するとログの構造化をまー達成することができるんですが、まーあの登録と呼び出しの順番関係といった副作用に注意する必要があったりします。
三つ目がレイクにパッチを当てるです。
レイクアプリケーションモジュールに定義されているディスプレイラーメッッッセージメソッドに、えモンキーパッチを当てます。
一度実装すると目的を達成することや、まーアトエグジットブロックを使った場合と比較して、副作用も限定的です。
まー今回はこのバランスのこのの方法を採用することにしました。
ここまででレイルズの各プロセスを構造化することができました。
ここまでを少し整理しておきます。
レイルセマンティックローガーを採用し、構造化対象の大部分を網羅、それでも不足しているものは自分たちで補うという方針で、今回は私たちは進めました。
レルズアプリケーションのログを構造化することができたので、次にログのフォーマットについて見ていきたいと思います。
まーログは構造化するだけでもツールやプログラムからのパースを容易にすることはできるんですが、まーツールによってはさらに特定の仕様を満たす、まーこのようなあの例のように、あのーkcフォーマットすることが必要となります。
ま例えばデータドックでは、エラートラックイン機というものがあって、まログから類似のエラーを自動で集計したり、チケット化したり、メトリック化してくれる便利な機能だったりします。
まーエラートラッキン機能を有効化するためには、図のようなスキーマでま構造化ロゴを収集する必要があるということですね。
でログのフォーマットにおいてアプリケーション側で行うか、ツール側で行うかについても検討が必要だったりします。
まー私たちの場合はソフトエンジニアを中心としたチームなので、まなるべくアプリケーション側で要件に合わせてフォーマッターを作成することに振り切りました。
まこちらについては弊社ブログもちょっと参考にしていただけると良いかなと思います。
ここまでで活用を見据えたログの構造化が一と通り完了しました。
アプリケーションから収集するログを構造化することにより、えー監視ツールでこれまで使用することができていなかった監視や調査用途の機能を有効化することができました。
監視面だとエラー検知アラートなど、アプリケーションの重要イベントを補足することができるようになりましたし、えー調査面だとログの検索性の向上や問題のあるリクエストの詳細情報をログから得ることで、原因特定や復旧に向けて、まー通じ、通路を通じて、ま作業の民主化がえー進んだかなというふうに思います。
最後に今回の取り組みを通じて例立に期待することについて、少しお話ししたいと思います。
えっとレイルズ8.1に向けて、こうざ、構造化ロギングがサポートされようとしています。
えーストラクチャーイベントレポーティングというインターフェースや、構造化イベント用のサブスクライバーがメインブランチにえ直近マージされていってます。
先ほどま紹介した事例のように、これまでなんか独自の解決方法とか、まジムで対応してきた部分が、ま標準化されていくところはちょっと楽しみだなというふうに思っています。
また私たちのレイクタスクでバッチ処理や運用上のスクリプトを実装しているえー方も多いのかなと思っていて、ベルゼまレイクのエラーレポーティング機能がサポートされてもいいのかなというふうに考えています。
まーこのあたりについてはレイルズディスカッションにちょっとスレッドを立ててみたので、もしちょっとこの辺詳しい方いれば、えっとご意見などいただきたいなと思います。
でこれらのことがサポートされてくると、まー今回行ったような対応の多くは不要となりますし、まレールズのユーザーとしても関心事がのではないかなというふうに思っています。
今回のまとめです。
まず構造化ロギングのすすめです。
えー監視に対する知見の有無によって、ログの構造化は見逃されがちです。
実際私たちのように活用されやすい形でログが収集されていないこともありますが、えー信頼性の向上においてとてもコストパフォーマンスの良い打ち手となります。
ツールやえプログラムをはじめとした機械的な後工程が少しでも考えられるのであれば、成長期とは言わず、ま運用開始するタイミングで本番環境のログを構造化しておくと、何かと役立ちます。
続いてレイルズアプリケーションのログの構造化にあたっては、まーいくつか課題があり、状況に合わせて選定を行う必要があるということです。
今回私たちはシステムやチームの規模が小から中に差し掛かるタイミングを前提として、なるべくコ室や認知負荷をかけずにログを構造化し、いくことを意識しました。
このあたりについては規模や体制に応じた設計を行う必要があると考えています。
最後にレルズ8.1以降で構造化ロギングの機能が組み込まれる可能性が高いということです。
これからえー構造化に取り組む場合は、レールズでのえーサポート状況を確認しながら、えー導入をえー進める必要があるあります。
それではご清聴ありがとうございました。

As one example, I will introduce what we actually practiced when implementing structured logging in Rails applications. From the challenges we tackled at the end, I'd like to touch a little on the future of Rails and structured logging.As for the provisions assumed in this announcement, those involved in small to medium-scale service development such as startups and new services, and those who are beginning to consider ensuring reliability, starting with monitoring.I'm hoping this can provide some insight for those who are somehow collecting logs but haven't taken the step towards katsuobushi yet.First, allow me to briefly summarize the concept of logs.Regarding what a log is, it's string data containing detailed information about what happened when and where. Well, it can hold more information than metrics, which are numerical values.Logs are broadly classified into two formats. The first is unstructured logs. As I mentioned in the previous example, this is probably a familiar format. This is what flows to the console by default when started in Rails development mode. The second is structured logs. This is today's main topic. It's a format where each field has a key-value data structure like JSON, making it easy for programs to interpret mechanically.Next, let's talk about the purposes of logs. This classification is based on Hatena's blog. We categorize log purposes into four main types: monitoring, investigation, analysis, and auditing. This time, we'll discuss monitoring to detect system failures and performance degradation, and investigation to identify causes and assess the impact of errors and performance issues.Now that you have a basic image of logs, I'd like to talk about whether we were able to effectively utilize log language.As a premise, let me briefly explain the structure of the applications we operate. As mentioned at the beginning, the HR Platform Division develops multiple services, including job sites and ATS. Each service uses Rails in API mode, and has a monolithic typical web application structure.As our service has moved from the startup phase to the growth phase, the system has become more complex due to an increase in users and domain expansion. Well, um, because of this, the potential losses from system failures, and the operational costs, including urgent investigations for quick recovery and follow-up responses, have gradually increased.So, if you ask how to comprehensively and academically understand the state of that application in detail, well, as I mentioned at the beginning, logs are highly detailed information, and usually, important events such as error logs are often output as logs from that application, so we can say they have high comprehensiveness. Therefore, we can say that logs are suitable data for understanding the state of an application.From that perspective, engaging in monitoring and investigation of applications using logos can be said to be one effective means of ensuring reliability.I have it.Um, so while logs were being collected, due to them being unstructured logs, uh, we couldn't effectively utilize them even after enabling the monitoring function.Well, in other words, the costs of implementation and maintenance will end up being high.There are several useful gems that extend Elzlogger to support structuring. From the perspective of log structuring, he thinks that Logreage and Rail Semantic Logger are often mentioned. First, regarding Logreage, it's sometimes recommended in the function's lattice documentation, so I think many of you may be familiar with it. Since it aims to summarize request logs into a single line, the log events targeted for structuring are limited.There are also some concerns about the continuity of maintenance. Next is Rails Semantic Logger. It's a multifunctional tool for structuring events across Rails. Since it aims to structure events across Rails, I think its key feature is that it structures each log output from the framework. As for maintenance, I think it's being continuously maintained.So, what we did was adopt Rails Semantic Logger. For those of us with limited resources, the fact that it easily structures all the logs output from Rails was a big factor, and the continuous maintenance it receives was the deciding factor.By introducing Rail Semantic Logger and adding a few settings, we couldn't quite say it supports structured logging.Oh, after starting the operation, I found that some of the logs were not structured.Well, to explain what I mean, first we execute the task. Let's say an exception occurs within the task. If we don't specifically catch the exception, it becomes a runtime error. In that case, unstructured logs are output through Rake's own logging mechanism. In our case, we're proceeding with a policy to extend the Rails logger to support structured logs, so, uh, it's troublesome.While looking at Rake's source code, I'd like to deepen my understanding a bit more. Rake tasks can be executed with Rails commands, but exception handling is not done within the Rails ecosystem.The goal is to increase the comprehensiveness of log collection, so I want to structure the logs for exceptions that occur during lake tasks as well. After investigating, there seem to be about three methods, so I've decided to consider each of them.The first one is to wrap the entire process within the rector task in a begin-rescue-end block, which basically calls the Rails logger in case of exceptions. It's simple and easy to understand, but it's verbose, and it might be difficult to prevent implementation omissions or mistakes.Well, the second one is defining an at_exit block. It's about defining an at_exit block and registering Rails logger output as a process to be called at runtime termination. This method is used for error log collection in monitoring tool SDKs and such.So the introduction is just defining a block, which is simple and once defined, it can achieve log structuring, but you need to be careful of side effects such as the order of registration and calling. The third is applying a patch to Rake. We apply a monkey patch to the display error message method defined in the Rake application module.We were able to structure each Rails process up to this point.Let me summarize up to this point. We adopted Rail Semantic Logger, covered most of the structuring targets, and proceeded with the policy of supplementing what was still lacking ourselves.Now that we've been able to structure the logs of Rails applications, I'd like to look at log formatting next. Well, just structuring logs can make parsing from tools and programs easier, but depending on the tool, it may be necessary to meet specific requirements, like, um, KC formatting as in that example we saw.Consideration is also needed regarding whether to handle log formatting on the application side or the tool side. Well, in our case, with software engineers at the core


### [Sidekiq その前に：Webアプリケーションにおける非同期ジョブ設計原則 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/morihirok/#day2)
  - morihirokさん。
  STORES のウェブエンジニア

失敗時の再試行についても、ウェブサーバーと同じように考えられます。
長時間上部が失敗すると、どの段階で落ちたのか、切り分けが難しいと、処理が途中で止まって一部のデータだけが更新されるみたいな複整合が起きやすくなって、悩ましい問題になってきます。
一方で、小さくシンプルなジョブであれば、何も考えずにリトライすれば解消できるケースが大きくなります。
多くなります。
もちろんこれはジョブが適当に設計されていることが前提です。
前提ですが、その前提を満たしていれば、リドライっていうのが強力な回復手段になる。
まリトライは簡単ですので、強力になるっていうか感じですね。
非同期ジョブの監視という観点でも小さくシンプルにしておく利点があります。
非同期ジョブは実行状況が見えにくく、今どこまで、なんの、すいません。
長時間のジョブですね。
長時間のジョブっていうのは、実行状況が見えにくくて、今どこまで進んでるのか知るためには、行動の中にログを書いたりとか、外部の何だろうな、いわゆるデータドックとかニューレリックみたいなapmに細かくデータを送ったりみたいなことをやらないといけなくなります。
一方で、短時間で終わるジョブであれば開始した、終わったというイベントさえ取れれば十分で、まあそれだけで処理時間だったりとか、失敗率だったりとかも簡単に測れるので、監視の仕組み自体をシンプルに保つことができますで、まおそらく多くのapmで開始終了っていうのは簡単に取得できるかなと思いますし、ま少なくも私が使っているデータドックとかだったら簡単に取れます。
で、まデプロイアメンテナンスの時も影響もなくなります。
非同期処分のワーカーは多くの場合、ウェブサーバーと同じようにデプロイジに古いプロセスを止めて、新しいプロセスに入れ替える必要があります。
この時、いつまで経っても終わらない長時間ジブが動いていると、まこう、最初の例にあったように、デプロイ自体が止まってしまうっていうことがあります。
さらになんかこう、ファーゲットみたいな、awレスファーゲットみたいなのを使っていると、まサービス側の指定役があっても、それでそっちから強制終了されてしまうみたいなこともあるので、まこうそういったことに何とか対処しなければいけないっていうことがあります。
まーこう一方で、短時間で終わるシンプルな処理にできていれば、こうした心配をが不要になります。
教室医療される前に処理が終わるので、ま安心してデプロやメンテナンスができるようになって、まこう深夜時にあの途方に暮れていた私も救われるようになるっていうことができるようになるわけですね。
はい、ここまでの話をまとめると、非同期助部は短時間で終わるシンプルな処理にするっていうのは設計原則としても良いのではないかというふうに思えてきます。
長時間上部は性能を下げ、リトライを難しくし、監視やデプロイの運用も複雑にしてしまいます。
逆に短いジョブにしておけば性能信頼性、運用性、まこう様々な面でシンプルに保てるかなと思っています。
ですので、非同期女房を設計するときには、まずこの非同期序部は短時間で終わるシンプルな処理にするっていうのを思い出してもらえればなと思います。
はい、ということで、ここまで原則の話をしてきたんですけれども、ここからは楽しい楽しい、原則を破る話に突入していこうかなと思います。
実際のウェブアプリケーション開発では、それでも長時間上部でやるしかないっていうケースっていうのは、まああるかなと思っています。
例えば、なるべくリアルタイムに処理を進めたい一件ずつ順番に処理必要があるすべての処理を終わった後にまとめて次の処理をしたいみたいな、そういうケースですね。
まあなんかこう、結構、なんかcsvでインポートしたいんですとか、なんかcsvで情報エクスポートしたいんですってああそうですかみたいな機能ってあると思っていて、やっぱこういうのを避け、なんか特にsasあるあるだと思うんですけど、避けられないんですよね。
こういうものをやっていくっていう時には、やっぱこう長時間ジョブっていうのは考慮に入ってくるかなと思いますし、まあなんか、そもそもプロジェクトに参加した時に歴史的になんかこうこれ別に長時間ジョブである必要ないよねみたいなものが鎮座しているみたいなことっていうのはあるかなと思っていて、まあそういったものと向き合っていくっていうことはあるかなと思っています。
まこうそういう、じゃあ運用しなければならないよねって時に考えなきゃいけないのが、ま先ほどもお話ししたデプロの時に途中で終了してしまう問題ですね。
サーバーの入れ替えやコンテナの再起動の時にまだ処理が終わってないジョブが強制的に止められてしまうと、まあこう結局失敗になっちゃって困る。
これはあの長時間序文を運用するでは、どういうふうに防ぐかっていうのは事前に考えなければいけないポイントかなと思います。
まあとこう長時間ジブの中でこう特定の一気がエラーを起こしたときにどういう風にハンドリングするのか、みたいなことっていうのも事前に考えておく必要があるかなと思っています。
ま現代ではこうした長時間ジョブを扱う、安全に扱うための便利なライブラリって提供されていて、ま例えばショピファイのジョブイテレーションだったり、サイドキックのあのイテレーションだったりとか、なんかそういう機能はあるかなと思います。
これらはあの大量のデータを少しずつ区切って繰り返し処理するための仕組みを提供していて、まデブロイで中断されても中断前の状態からま再度再開できるみたいな機能を提供しているので、まこれに乗っかるのが、あの長時間ジブを運用する上ではまずはいいのかなというふうに思っております。
あとは今こう、アクティブジョブとかサイドキックの標準的なエラーハンドリングの。
仕組みにも乗れるので、まなんかまずはそこを書き手に考えるみたいなこともできるので、あの悩ましいポイントをだいぶ解決してくれるんじゃないかなというふうに思っています。
とレイルズ8.1からはあの標準でアクティブジョオブコンティニエーションっていうのが導入されるようになっていて、まこう長時間、標準で長時間乗を扱うことができるようになっています。
まーこう、これも、こう大きなステ大きな処理を大きなジョブをステップっていう単位で区切って少しずつ進めるみたいな、なんかそういう仕組みなんですけれども、まこう途中で再開できるっていうところで言うと、先ほど壊したジョブイテレーションだったりとか、サイドキックのイテレーションだったりとかと、ま同じ発想だし、なんか影響を受けているっていうふうに書いていました。
まーこう追加でsimを入れることなくレルズが用意しているものに乗れるっていうのはこう安心して運用できる要素の一つになるかなと思います。
で、これはまサイドキックプロの優勝のサイドキックプロの機能ではあるんですけど、バッチーズっていうものもあります。
これは複数のジョブをひとつのグループにまとめて扱える仕組みです。
それぞれのジョブは小さい単位で、あの小さいジョブとして実行できていて、で、まあそれ、その中のどこまで終わったかとか、ま全部終わったらメールを送るみたいなっていうことが、まこう差し込むみたいなことができるので、まこう、短時間ジョブの利点を生かしつつ、大きい処理を行うということが可能になるので、特に順序保証が不要みたいなケースであれば、有力な選択肢になり得るかなと思っています。
ちなみに私が働いているストーズでも、長時間ジョブがいて、まこいつはやる長時間でやる必要ないし分割したいんだけど、処理がごちゃごちゃしてて切り分けるのが大変だなみたいなことがあって、まなんかそういった時に、一旦awsのステップファンクション経由でecsタスクに処理を逃がすみたいなことをやりました。
これによって、ま非同期ジョブとは分離された場所で序文を動かすことによって、デプロイので殺されるとか、なんかそういうところから逃げたところで一旦タスクを動かすことができるみたいなものですね。
これはあの先日ユーロコから帰ってきた同僚のシムさんがアクティブジョブからステップパンクを呼び出せるあのライブラリをかと書いてあの実現してくれましたっていうものです。
あのこれの話をしたいっていうふうにシムさんに言ったらですね、非常に苦い顔されたぐらいにはですね、あの成功法ではないんですけれども、まこういったことをやったこともありますという紹介でした。
はい、で、まーこういう原則を破っていく話っていうのは、いろんなやり方があって、面白いんで盛り上がるんですけれども、盛り上がりすぎると私の発表の趣旨がおかしくなってしまうので、その前に今日のまとめをしたいと思います。
はい。
まず非同期女房を設計するってなった場合、それは本当に非常規ジョブで考え、作るべきかっていうのを考えましょう。
なんかひど他の処理も非同期所部で作られてるっぽいから、これもひどきジョブデーじゃなくて、本当にそれが規準部である必要があるのかっていうのはまずは立ち止まって考えましょう。
立ち止まって考えた後、まバッチ処理で代替できないかっていうものをちゃんと考えていきましょう。
その上で、最初に考えるのは、なんかこう短時間のジョブで終了できないか、そういうふうに作りきれないかっていうことを考えましょう。
で、それでも作りきれないなってなった場合に、まアクティブジョブコンティネエーションだったりとか、まサイドキックインテレーションだったりとか、ああいうライブラリーを導入して、あの実現してるっていうことを考えていきましょう。
少なくともこう最初からアクティブジオブコンティネーションにいきなりバンと行くっていうことを、あの、は、まこう避けるのが大事かなと思っております。
はい、まで、非同期処は短時間で終わるシンプルにし処認するっていうのを改めてここでお話しできればなと思っております。
なんですかね、そのまやっぱこう、なんとかシンプルでこう標準の道具に乗っかって作れないかっていうことを考えるっていうのが何事も重要かなと思っていて、ま昨日の話があったサービスクラスとかもそういうものかなと思っていて、やっぱこうちゃんと標準の道具で作れきれないかっていうとこを考えて作りきれないなってなった場合に、そういったものを導入するっていうのは、こう何の、何においても大事のことかなと思っております。
ということで、ま非同期条文については、なんかこう、立ち返る場所が、非ければは短時間で終わるシンプルな処理するっていうのは、あのいい場所なんじゃないかなというふうに思っております。
っていうところで、なんか私の話したいことを発表以上とます。
すいません。
最後にちょっとだけ宣伝させてください。
あの11月26日水曜日にストアーズのジスティックカンファレンスを開催します。
まちょっと今年一年いろいろ正直ハードな変化がいっぱいあってですね、その中でソフトウェアエンジニアとしてこうやっていくっていうものが強く醸成された信念だと思っていて、すごい面白い発表がいっぱいできるかなと思っています。
なんかレイルズ道場っていうレイルズのワークショップを開催予定で、なんかうん、これはサービスクラスでやるのかみたいな、いうものを、いや、これはサービスクラスを使うべきではないみたいな、なんかそういう、あのワークショップをやれればいいなと思っているので、ぜひあのお越しいただければなと思っております。
招待制ではあるんですけれども、あの今日開音レーゼに参加している方は、あのピンクの集団だったりとか、なんか私に声かけけてもらえればあの招待させていただければと思っておりますのでよろしくお願いします。
すいません。
最後宣伝でした。
あの以上で私の発表を終わります。
ご清聴ありがとうございました。

Before explaining why one job per item is desirable here, let me briefly summarize how asynchronous jobs work. When running asynchronous jobs, we first urgently stack the jobs we want to run. As shown in this diagram, it's like lining up in a queue, realized by stacking information on which job to execute with what arguments. I think Redis or RDBMS are often used for the urgent stack. Basically, jobs are taken out from the front of the stack in order, and one process/thread processes one item at a time. And then when the processing is finished,it moves on to the next job. That's how it works.It becomes a movement where, just like how a web server processes requests, it takes from the next row when there's an opening in the preface.For example, I mentioned that when long-running requests increase on a web server, the overall performance drops, um, the same thing happens even in non-synchronous departments.Retrying after failures can be thought of in the same way as web servers. When long-running processes fail, it becomes difficult to determine at which stage they failed, leading to inconsistencies where processing stops midway and only some data gets updated, becoming a troublesome issue. On the other hand, for small and simple jobs, cases where retrying without much thought can resolve the issue become more common. Of course, this assumes that the jobs are properly designed. If this prerequisite is met, retrying becomes a powerful recovery method. Since retrying is easy, it becomes powerful, or ratherThat's how it feels.From the perspective of monitoring asynchronous jobs, there are advantages to keeping things small and simple. Asynchronous jobs are difficult to track in terms of execution status, and it's hard to see... I'm sorry. For long-running jobs, right? Long-running jobs are difficult to monitor, and to know how far they've progressed, you need to write logs within the actions or send detailed data to external services like, what would it be, DataDog or New Relic APM. On the other hand, for short-duration jobs, it's sufficient to just capture the start and end events, and with just that, you can measure processing time and failure rates and suchSo, there's no impact even during deployment maintenance. In many cases, asynchronous disposal workers need to stop old processes and replace them with new ones during deployment, just like web servers. At this time, if long-running jobs that never end are still running, as in the first example, the deployment itself might stop. Furthermore, if you're using something like Fargate or AWS Lambda, even if there's a service-side specification, it might be forcibly terminated from that end, so we need to somehow deal with such things.Yes, summarizing the discussion so far, it seems that making asynchronous tasks simple processes that finish quickly could be a good design principle. Long-running tasks reduce performance, make retries difficult, and complicate monitoring and deployment operations. Conversely, keeping jobs short can maintain simplicity in terms of performance reliability, operability, and various other aspects, I think.Yes, so, up until now we've been talking about principles, but from here on, I think we'll dive into the fun, fun topic of breaking those principles.In actual web application development, I think there are still cases where you have to do long-running tasks in the foreground. For example, cases where you want to process things as real-time as possible, need to process items one by one in order, or want to batch process the next step after completing all previous processes. Well, I think there are features like "I want to import from CSV" or "I want to export information to CSV," and these are particularly common in SaaS, and you can't really avoid them. When dealing with these, you have to consider long-running jobs.I think it might come, and well, when I joined the project, there's this historical notion that it doesn't necessarily need to be a long-term job, and I think we'll have to face that kind of thing.So, when you think, "Okay, we have to operate it," what you need to consider is the problem of jobs terminating midway during deployment, which I mentioned earlier. When servers are replaced or containers are restarted, jobs that haven't finished processing are forcibly stopped, which ultimately leads to failures and causes trouble. I think this is a point that needs to be considered in advance when operating long-running jobs: how to prevent this from happening.Well, how to handle when a specific part suddenly causes an error during long-term operation in the jib

### [Railsアプリから何を切り出す？機能分離の判断基準 / yumu | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/myumura/#day2)
memo: 分離の判断基準はまあ難しいよね  

1. ビジネスロジックとの関連度
2. インフラリソースとの依存関係
- 認証基盤への依存
3. 機能の複雑さ
- 単一責任だと分離しやすい
4. 運用工数 vs 開発スピード
人数が少ないと属人化するよなあ。マイクロサービスを少人数はまあ厳しいよね  
5. ビジネス上の柔軟性が求められるか


はい、ではレイルズアプリから何を切り出す機能分離の判断基準というテーマでお話しさせていただきます。
よろしくお願いします。
はい、えgmoペパボでミンネというプロダクトを開発しているユムと言います。
え新卒三年目でエンジニアとしては五年目ルビーストとしても五年目です。
え昨年の開業レールズでスポンサーltをさせていただいて、あの時の体験がすごく良かったので、今回登壇できてすごく嬉しいです。
え押しているジェムは小流拳です。
はい、でえーさて私が開発しているミンネというサービスなんですけれども、国内最大級のハンドメイド作品の売買ができるプラットフォームで、現在リリースから13年目になりますで作家の数が95万件以上、登録作品数は1,800万件以上ということで、歴史も結構長くなってきて、大きなサービスになっています。
でミンネのものすごくざっくりなアーキテクチャーはこんな感じでえaws上で動いているんですが、コアとなるレイルズアプリケーションがあって、一部の画面はネクストjs化されているという構成になっています。
でモバイルアプリとウェブアプリが両方ありまして、apiやグラフql化を進めているんですが、レストapiが残っているところもあります。
で、認証については独立したオーセンティケーションのコンポネットを持っています。
でこのように部分的にコンポーネント分離は行っているんですけれど、今回お話しするのはコアとなるレイルズアプリケーション内で処理可能な機能をさらに分離するかどうかっていうような判断基準のお話になります。
でここから何回も出てくるので、これ以降このコアとなるレイルズアプリケーションをみんなアップと表現します。
えっとミンネもかなり大規模なecサイトとなってきたので、開発において様々な問題が出てきています。
えまずコードベースの複雑化ですね。
で、ミヌのレイルズアプリケーションはモデルだけで300近くあるんですけども、行動の全体像が把握しづらいですし、ライブラリーのアップデートなどの変更を加えた時に思わぬところに影響が出てしまったりします。
またデータベースのパフォーマンスの悪化の問題もあって、レコード数がかなり多くなってきているので、なんでもかんでもスケールに入れていると結構苦しくなってきました。
であと開発速度の低下っていう問題もあって、ちょっとした改修でも巨大なテストスイートを全部回さないと安心できないので、ciの実行時間も長くなって、開発のサイクルが遅くなってしまっています。
えーこういった課題に直面するとまデータベースの設計を見直した方がいいだろうとか、ciの高速化を頑張った方がいいだろうっていうのはまそれはその通りなんですけれども、別の解決策として、みんなアップから切り出せる機能は切り出したいなっていう気持ちになってきます。
なんですけど、ま実際に分離すべきかどうかの判断基準はこれまでチーム内で明文化されていなくて、その時々の機能開発でディスカッションして、これはまー分離した方がいいだろう。
これは分離しない方がいいだろうみたいな感じで、あのそれぞれ結論を出してきました。
なんで今回は機能分離の結構事例も溜まってきたので、適切に機能を分離するための判断基準を改めてまとめてみようと思いました。
で、えっとミンネではま実際にこれらのいろんな機能を分離検討したり分離を実施したりしてまして、えっと独立した小流拳ワーカーを立ってたりとか、クラウドラウンファンクションを使ったりとか、ラムダ関数を使ったりとかして、みんなアップから分離をしています。
で本当はちょっとそれぞれの機能をどういうアクティクチャーでやってるかっていうのをお話ししたいんですが、時間がないので他のカンファレンスで発表した時の資料があるので、詳しくはそちらを見ていただけるとです。
で、これ以外にも他にあのプライベートジムにしたりだとか、ecsファーゲットで別サービス化にしたりだとか、あのいろんな機能でウアップから分離を実現しています。
でこれらの分離事例の中でま成功したなっていうのもあれば、ちょっとミスったかもなっていうのもあって、今日はこれらの体験から体系化した実践的な機能分離の判断基準をお話ししようと思っています。
あんまり理論的な話ではなくって、できるだけ具体的に明日から使える内容をあのおしゃべりできるといいなと思います。
でえー今背景と課題までお話ししたので、ここから機能分離の五つの判断軸について説明していきます。
でその後じ実践事例ということで三つのパターンを判断のマトリックスで分析した後まとめっていう感じでいこうと思います。
で、えー早速軸なんですけれども、今回紹介する五つの軸はこちらです。
えービジネスロジックとの関連度合い、他のインフラリソースとの依存度合い、機能の複雑性えー運用コストと開発スピードのトレードオフ、そしてビジネス上の柔軟性が求められるかどうかっていう三つ、あ三つじゃない、五つです。
でえー最初の三つは技術的な観点でえー後の二つは組織とか運用の観点です。
で、えーひとつずつ解説していくんですけど、えまずえー1個目がビジネスロジックとの関連度でえー高関連の場合は分離を避けるべきだと思っています。
ミンネで言うと商品管理とか注文とか決済はまさにビジネスの中核となっているので、これらを分離するのはあまり現実的ではありませんでした。
また複数のテーブルとかモデルと強い関連がある機能も同じようにえー分離を避けた方がいいかなっていう判断をしています。
でまさにサブスクリプションの機能はこのタイプでした。
で一方低関連の機能は分離の候補になってくるんですけど、動画変換のような技術的な処理だとか、アクセス解析のような分析系の機能はこれに当たります。
で二つ目の軸は他のインフラリソースとの依存関係です。
えー依存が強い場合は分離が難しいです。
えーマイsqlの直接参照が必要な機能だとか、認証基盤への依存がある機能などはこれに当たります。
特に認証基盤については前述の通りあのミンネでは認証システムが分離されてるんですけれども、これは現在の構成だとみんなネアップからしか呼び出せないようになっています。
なのでユーザー認証が必要な機能を分離するときは、この制約を考慮し分離する必要があります。
で、依存が弱い場合は分離可能でえーエスリー経由でデータの受け渡しが可能だったりとか、api経由で初結合が実現できている場合とか、マイsql以外のデータベースをま選択できる、選択したい場合などです。
で動画変換機能はまさに依存が弱いパターンでした。
で、三つ目が機能の複雑さで、複雑な機能は要検討ということで、えー複数サービス間の連携が必要だったりとか、データフローが複雑になる機能は分離することで、逆にアーキテクチャ全体の把握が難しくなってしまいます。
でシンプルな機能は分離しやすくて、単一責任で外部依存が少ない機能っていうのがこれに当たります。
これはソフトウェア設計でいう単一スキニの原則と同じ考え方で、ひとつの機能がひとつの明確なに持っている状態だと分離がスムーズに行えます。
でアナリティクス機能とか動画変換機能はとてもシンプルで、まさに無理に向いていると言えると思います。
で4個目の軸は運用コストと開発スピードのトレードオフっていうところで、えー運用コストが高いことを許容できない場合は分離が難しいです。
分離すると複数のデプロイパイプラインの管理が必要ですし、ログとか管理士のシステムが分散して、障害児の影響範囲調査が難しくなったりとかいう課題があります。
で一方で運用コストより開発スピードを重視するっていう場合は分離のメリットがあって、えー独立したリリースサイクルはみんなアップにかかわらず素早いリリースができますし、技術スタックもみんなアップの技術スタックに引っ張られることなく、比較的自由に選択することができます。
で運用コストの話で大事なこととして、これを考える時にはチーム規模を考慮する必要があるなと思っていて、特にみんなンネはですねあの正社員のエンジニアが10名前後で運営しているので、の運用工数の拡大が結構クリティカルな問題になってきます。
人が少ないので分離した機能のアーキテクチャ全体を把握している人があの機能を開発した本人ぐらいしかいなくって、結構族人化してしまっています。
でドキュメント化はしてはいるんですけど、まみんなあんま読むだけで実態はその人しか面倒を見てくれないみたいなのが結構あります。
で、これはそうですね、今ウェイの法則そのもので10名前後の小規模なチームで複数のマイクロサービスを管理するっていうのはちょっと組織構造的に厳しいのがあるなと思っています。
デート最後の軸がビジネス上の柔軟性が求められるかどうかっていうところで、え柔軟性が求められないものは単純な機能改善とか他に応用する可能性のない単一の用途ののみのものです。
でこれは軸の三つ目の機能の複雑さの軸と相反するように思えるかもしれませんが、これはあくまであの私とじゃあビジネス上の用途っていう話でえ例えば動画変換機能だと、技術的には単一的にでシンプルなんですけど、ビジネス的には将来的に社内の他のサービスでも活用したいっていう構想があったので、その場合は柔軟性が求められるっていう判断になって、分離のメリットが大きくなります。
でこれらの軸を整理したのがこの判断マトリックスで各軸を分離推奨用検討分量を避けるの三段階で評価します。
で特に軸四と軸五はあごめんなさい。
チック四だけですね。
はトレードオフの関係なので、あの単純な良し悪しっていうよりは、その各機能の開発状況とかにおいて重視する視点っていうところで評価します。
で判断基準としては三つ以上が分離推奨なら積極的に分離を検討して、二つが分量を避けるんだったら慎重に判断するっていうような基準にしました。
でこの基準はこれまでのその分離の事例の成功をしたやつと失敗したやつを振り返ってみて決めたっていうような感じです。
でこの判断基準は実際の事例で検証してみようと思うんですけど、まずえー成功パターンで動画変換の機能とアナリティクスの機能です。
え動画変換機能は小流圏ワーカーとしてあの分離していて、これは作家さんのが作品の動画をアップロードするっていう機能でえー動画を変換する処理をみんなアップとは別の専用の省流拳ワーカーで分離しているっていうような感じです。
でアナリティクスの方はえークラウドランファンクションにしていて、これはユーザーの行動ログを集計するっていうような機能コードログがビッグクエリに保存されるっていう既存のシステムを活用したかったので、クラウドランファンクションズで集計を行ってクラウドファイアスターに集計データを保存しています。
で判断マトリックスで評価すると二つの機能のいずれも五つの軸のうち四つが分離推奨、ひとつが要検討っていう結果になっています。
で結果はどうだったかっていうと、どちらもかなり成功していて、あの両方ともあんまり頻繁に回収が必要な機能ではないので、レイルズアプリケーションの複雑性を緩和しながら安定して稼働が実現できています。
で次に要注意パターンのリワード広告の機能なんですけど、これはユーザーが広告を閲覧するとスタンプが獲得できるっていうような機能で、スタンプのデータはダイナモdbに格納していて、みんなアップからダイナモディebをクエリするラムダを叩くっていうような形で分離しています。
でえーハ断マトリックス上はちょっとこのどっちだろうっていうような感じなんですけど、えっと実際に分離してみて結構あの大変になっちゃったなと思っていて、えっととみんなアップからダイナムdbをクエリするラマダを呼び出すっていう構成なので、仕様変更の際にラムダとミアップをどちらも変更する必要があるっていうのと、あとま度々バグが発生するんですけど、その時にま作った人、私しかあの全容を把握してないので、私しかあのインシデント対応ができないみたいな感じになってしまっています。
でまー一方でこの機論はあのチャレンジングな試みだったっていうところがあって、ビジネス上の柔軟性の確保をかなり重視してたっていうのがありました。
なのでま運用コストとのトレードをふわったんですけど、柔軟性を重視して分離を継続するっていうような判断にしています。
はい。
であとはえー分離回避パターンのサブスクリプションの機能で、これはあのミンネの作家さん向けに有料で一部の機能を解放するっていうようなサブスクなんですけど、これはユーザーの権限制御とか決済の処理とか、あのかなりたくさんのそのミニアップの機能と密接に関わっているので分離するっていうのは現実的ではありませんでした。
なんで代わりにデータベースやモデルの設計に時間をかけてレイルズ内での最適化に注力しました。
結果としてスから一年以上経ってるんですけど、運用コストもまそこまで大きくはなく、あの大きな障害もなくいい感じに動いてるんじゃないかなと思います。
でまとめです。
えっと一応五つの判断軸を再計しておきます。
で最後に考え方のポイントっていうところでお話ししたいんですけど、一つ目はあの完璧な分離はなかなかないっていうところで、私たちの分離事例のすべてに何かしらのトレードオフがあって、それを受け入れた上で総合的にメリットが大きいかどうかっていうところを判断する必要があります。
で、二つ目はチームの状況によって各軸の重みは結構変わってくるっていうところで、私たちのような小規模なチームとエンジニアが潤沢ニールチームではどの軸項を重視するかは結構変わってくるんじゃないかなと思います。
ここはチーム内で話し合ってどの軸に重みがあるのかっていうのを決めたいところです。
で三つ目はこれは結構最近特に感じることなんですが、分離された機能はあのaiが理解活用しやすいっていう観点も重要になってきているんじゃないかなと思います。
え単一責任で粗結合な機能はaiが行動を解析したり自動化する際にも扱いやすいです。
将来的なai活用を考えると適切な機能分離は価値があるんじゃないかなと思います。
で四つ目あの一番大事なこととしてまやっぱり失敗から学んで判断基準を磨いていくのが大事だなと思ってます。
今日お話しした軸も失敗を重ねながら改良してきたものですし、ま今の軸も別に完璧じゃないなと思っていて、昨日のセッションでも何度もその継続的に変化とか改善をし続けるのが大事だよっていうお話があったと思うんですけど、ま本当にその通りだなと思っていて、あのこれがま正解っていうよりは皆さんも今回のお伝えした基準を参考に自分たちのチームに合ったあの基準を作っていっていただけるといいんじゃないかなと思っています。
はい、以上です。
ご清聴ありがとうございました。


Yes, then I will talk about the criteria for deciding what functionality to extract from a Rails application. Thank you for your attention.Yes, I'm Yumu, developing a product called Minne at GMO Pepabo. I'm in my third year as a new graduate and fifth year as an engineer and Rubyist. I was a sponsor at last year's Rails conference, and that experience was so great that I'm really happy to be speaking this time. The gem I'm pushing is Koryu-ken.Yes, well, the service I'm developing called Minne is Japan's largest platform for buying and selling handmade items. It's now in its 13th year since release, with over 950,000 creators and more than 18 million registered works, so it has quite a long history and has become a large service.So, Minne's very rough architecture is like this, running on AWS, with a core Rails application, and some screens have been converted to Next.js. We have both mobile and web apps, and while we're moving towards API and GraphQL, some REST APIs still remain. For authentication, we have an independent authentication component. While we're implementing partial component separation like this,Today, we'll be discussing the criteria for deciding whether to further separate functions that can be processed within the core Rails application.Since it appears many times from here on, this core Rails application will be referred to as "app" by everyone.Well, as Minne has become quite a large-scale e-commerce site, various problems have arisen in development. First, there's the increasing complexity of the codebase. You see, Minne's Rails application has nearly 300 models alone, which makes it difficult to grasp the overall picture of behavior, and when we make changes like library updates, it can unexpectedly affect other areas. There's also the issue of database performance degradation, as the number of records has become quite large, so everythingIt's getting quite tough when put into scale. There's also the problem of decreased development speed, where even for small modifications, we can't feel at ease without running the entire huge test suite, so CI execution time gets longer, and the development cycle has been slowing down.Uh, when facing such challenges, it's true that we should reconsider the database design or work on speeding up CI, but as another solution, we're starting to feel like we want to extract any features that can be extracted from the app.So, at Minne, we've actually been considering and implementing the separation of these various functions. We've set up independent small-scale workers, used cloud functions, used Lambda functions, and separated everything from the app. I'd like to talk about the architecture we're using for each function, but since we don't have time, there are materials from presentations at other conferences, so for more details, please look at those if you'd likeThat's it.And besides this, we've achieved separation from the app through various functions, such as making it a private gym or creating a separate service on ECS Fargate.Among these separation cases, there are some that were successful and some that might have been a bit of a mistake. Today, I'd like to talk about the practical criteria for functional separation that I've systematized from these experiences. Rather than a theoretical discussion, I hope to chat about content that you can use from tomorrow, as concretely as possible.So, now that I've talked about the background and issues, I'll explain the five criteria for functional separation. Then, as practical examples, I'll analyze three patterns using a decision matrix, and then wrap it up like that.Um, so, for the first one, I think we should avoid separation if it's highly related to business logic. For Minne, product management, orders, and payments are at the core of the business, so separating these wasn't very practical. Also, we've decided that it's better to avoid separating functions that have strong connections to multiple tables or models. And the subscription feature was exactly this type. So on the other hand, lowRelated functions are becoming candidates for separation, but technical processes like video conversion and analytical functions like access analysis fall into this category.The second axis is the dependency on other infrastructure resources. Um, if the dependency is strong, separation becomes difficult. This applies to functions that require direct reference to MySQL or functions that depend on the authentication infrastructure. Especially regarding the authentication infrastructure, as mentioned earlier, in Minne, the authentication system is separated, but with the current configuration, it can only be called from Minne App. So, when separating functions that require user authentication, considering this constraintIt needs to be separated.And, the third is the complexity of functions, where complex functions need to be considered carefully. Um, functions that require coordination between multiple services or have complex data flows can make it harder to grasp the overall architecture when separated. Simple functions are easier to separate, and this applies to functions with single responsibility and low external dependencies. This is the same concept as the Single Responsibility Principle in software design, where one function has one clearWhen held in this position, separation can be performed smoothly.The analytics and video conversion features are very simple, I think it can be said that it's absolutely geared towards the impossible.The fourth axis is the trade-off between operational costs and development speed, and if high operational costs cannot be tolerated, separation becomes difficult. Separation requires managing multiple deployment pipelines, and systems for logs and administration become distributed, making it challenging to investigate the scope of impact during incidents. On the other hand, if development speed is prioritized over operational costs, there are benefits to separation, such as independent release cycles that everyoneWhen it comes to operational costs, I think it's important to consider team size. Especially for us, since we're operating with about 10 full-time engineers, the expansion of operational man-hours becomes quite a critical issue. With so few people, only the person who developed a particular feature understands the overall architecture of that separated function, leading to a significant silo effect. SoWe do document things, but it seems like people just skim through it, and in reality, only that one person ends up taking care of it.The final axis of the date is whether business flexibility is required or not. Things that don't require flexibility are simple functional improvements or those with a single purpose that can't be applied elsewhere. This might seem to contradict the third axis of functional complexity, but this is strictly in terms of business applications. For example, video conversion functionality is technically simpleIt's simple in terms of goals, but from a business perspective, there was a plan to utilize it in other internal services in the future, so in that case, it was decided that flexibility would be required, the benefits of separation become significant.So, organizing these axes is this decision matrix, where each axis is evaluated in three stages to avoid the recommended amount of separation for consideration. Particularly for axes four and five, oh sorry, just tick four. There's a trade-off relationship, so rather than a simple good or bad, the perspective we prioritize in the development status of each function
動画や字幕に不具合がある場合は、しばらく待ってからページを再読み込みしてください。


### [非同期処理実行基盤、Delayed脱出〜SolidQueue完全移行への旅路。
 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/srockstyle/#day2)
  - studist のエンジニアさんだ
  
### [非同期jobをtransaction内で呼ぶなよ！絶対に呼ぶなよ！ | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/alstrocrack/#day2)

### [ドメイン指定Cookieとサービス間共有Redisで作る認証基盤サービス | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/kokuyouwind/#day2)

### ["複雑なデータ処理 × 静的サイト" を両立させる、楽をするRails運用 | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/hogelog/#day2)
  - STORES の VPoE
### [「技術負債にならない・間違えない」権限管理の設計と実装 / naro143 (Yusuke Ishimi) | Kaigi on Rails 2025](https://kaigionrails.org/2025/talks/naro143/#day2)
  - 裏の willnet さんのも気になるが。
