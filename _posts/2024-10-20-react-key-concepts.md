---
title: "React Key Concepts"
date: "2024-10-20 10:35:45 +0900"
last_modified_at: "2024-10-24 12:21:51 +0900"
tags:
  - React
categories:
  - Books
---

# React Key Concepts
[React Key Concepts - Second Edition](https://subscription.packtpub.com/book/web-development/9781836202271)

My Repository: https://github.com/noriyotcp/react-key-concepts-e2

Reactの仕組みとその使用理由を理解することで、高度な概念の学習が速くなるでしょう。  
ライブラリは時間と作業を節約できる機能の集まりのことを指します。  
バニラのJavaScriptを使用すると、ダウンロードするコード量は一般的に少なくなりますが、複雑なユーザーインタラクションを伴うユーザーインターフェースに対しては限界があります。  
また、JavaScriptを使ってユーザーインターフェース（UI）と技術的に対話するためにはより多くの手順が必要となります。  
また、JavaScriptとHTMLコードの「橋渡し役」を担うのがDocument Object Model（DOM）であり、エラーがないように常に更新することが重要です。  
コードの多くがDOMの操作に関連しており、実際のウェブサイトのロジック自体ではありません。  
ReactはDOM要素の選択、作成、挿入などの操作を必要としません。  
したがって、数行のバニラJavaScriptコードで問題を解決できる場合、Reactを組み込む強い理由はありません。  
React-domパッケージは、ReactコードとDOMの更新が必要な実際のDOMとの間の「翻訳橋渡し役」として作動します。  
ViteはページのURLパスの変更を処理し、更新が必要なページの部分を更新するために使用できるオープンソースツールです。  
コード作業では通常、開発サーバーを起動してコードの変更をプレビューし、テストする必要があります。  
React特有のコードの大部分はApp.jsxファイルに書かれます。  

Reactは、Vanilla JavaScriptプロジェクトに対して特定の利点を提供しています。具体的には、Reactを使うと、ユーザーインターフェース（UI）との技術的な相互作用をより少ない手順で行うことができます。  
JavaScriptとHTMLコードとの間の「橋渡し」役としてDocument Object Model（DOM）が存在しますが、これを更新し、エラーがない状態を維持することが重要です。多くのコードはDOMの操作に関連していますが、実際のウェブサイトのロジックとは異なります。 ReactはDOM要素の選択、作成、挿入を必要とせず、Vanilla JavaScriptの数行で問題が解決できる場合、Reactを統合する強力な理由は存在しないということです。

命令型コードとは、"どのように"特定のタスクを実行するかの詳細な手順をプログラムに指示するスタイルのことを言います。一方、宣言型コードは"何を"するべきかをプログラムに指示し、その"どのように"はプログラムが自動的に決定させるスタイルのことを指します。

シングルページアプリケーション（SPA）は、ブラウザにロードされると、ユーザーの対話に基づいて動的にページの内容を更新するWebアプリケーションです。ページ全体を更新せずに必要な部分だけを更新することで、ユーザーエクスペリエンスを向上させ、Webアプリケーションがデスクトップアプリケーションのように動作するのを助けます。

新しいReactプロジェクトを作成するには、一般的にCreate React App、Next.jsなどのフレームワークを利用します。これらは開発者がReactアプリケーションを作成し始める際の初期設定やツールを容易に提供します。  
なぜ複雑なプロジェクト設定が必要なのでしょうか。それはReactが、より高度なユーザインターフェースや複雑なユーザインタラクションを理解し管理するためのツールであるためです。また、プロジェクト設定が複雑な理由は、より具体的な問題を解決するために、React外のJavaScriptコードも読み込む可能性があるからです。  
したがって、プロジェクトのセットアップが複雑に見えるかもしれませんが、それは開発者が利用できる機能やツールの数が多いからです。

## 3. Understanding React Components and JSX
この内容は主に、Web開発におけるReactコンポーネントとJSX（JavaScript XML）コードの概念について述べています。これらの概念を使って基本的なウェブサイトがどのように作成されるかについて、具体的な例が提供されています。

Reactはコードを再利用可能なビルディングブロックまたはコンポーネントに分割することを可能にし、より管理しやすいコーディングを促進します。Reactはクラスベースのコンポーネントと関数コンポーネントを支援していますが、通常のJavaScript関数を通じて作成される関数コンポーネントはより普及しています。

コンポーネントの命名規則は通常、PascalCase形式に従います。内容の大部分はReactコンポーネントの書き方に関するもので、他のファイルでの使用のためにこれらをインポートおよびエクスポートする方法も含まれています。また、表示可能な値やReactのrender()メソッドといったコンポーネントのより技術的な側面も扱われています。これは、Reactがブラウザとどのように連携して動作するかの重要な部分です。

ユーザーインターフェースを定義するのに不可欠なJSXには、終了タグが必要であり、フラグメント( `<></>`)の使用が許可されているなどの特定のルールがあります。Reactを使用して画像などの動的な内容を表示する概念についても説明されています。最後に、単一のReactコンポーネントを複数のコンポーネントに分割すべきタイミングについての一般的な疑問に触れています。

---

1.コンポーネントの使用に背後にあるアイデアは何ですか

回答: コンポーネントの使用の考え方は、コードを再利用可能な構成要素またはコンポーネントに分割することにより、より管理しやすいコーディングを促進することです。

2.どのようにReactコンポーネントを作成できますか

回答: Reactコンポーネントは、クラスベースのコンポーネントと関数ベースのコンポーネントの両方をサポートしていますが、通常のJavaScript関数を介して作成される関数コンポーネントがより一般的です。

3.通常の関数をReactコンポーネント関数に変えるものは何ですか

回答: 通常の関数は、Reactコンポーネントを返すことでReactコンポーネント関数に変わります。

4.JSX要素に関してはどのような核心的な規則を念頭に置くべきですか

回答: JSXは、クロージングタグが必要であり、フラグメント( `<></>`)の使用を許可するなどの特定のルールがあります。

5.JSXコードはReactとReactDOMによってどのように処理されますか

回答: JSXコードは、Reactのrender()メソッドによって処理され、ブラウザと協調して動作します。これはReactがどのように動作するかのキーアスペクトです。