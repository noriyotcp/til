---
title: 'Replit Agent 触ってみた'
date: '2025-01-03 10:44:33 +0900'
last_modified_at: '2025-03-12 23:55:19 +0900'
tags:
  - 'Replit'
  - 'Replit Agent'
draft: false
---

Black Friday Sale で [Replit Core](https://replit.com/pricing) を購入したので、Replit Agent を触ってみた

## Replit Agent とは

https://docs.replit.com/replitai/agent

> Replit Agentは、ユーザーがソフトウェアプロジェクトを構築するのを支援するために設計されたAI搭載ツールです。自然言語のプロンプトを理解し、アプリケーションをゼロから作成できるため、あらゆるスキルレベルのユーザーがソフトウェア開発にアクセスしやすくなります。

ふむなるほど。使い方は以下の通り（公式ドキュメントより翻訳）

1. Replitアカウントにログインします(Replit CoreまたはTeamsサブスクリプションを使用)
2. ホーム ページにアクセスするか、左側のナビゲーションで [Create Repl] を選択します
3. エージェントに何を構築したいかのプロンプトを入力します

- 適切なプロンプトは、説明的で詳細です。あなたが仕事中のチームメイトが完了すべきタスクを説明していると想像してください。仕事を成し遂げるためには、どのような情報が必要でしょうか?
- 特定の言語やフレームワークを指定するのではなく、使用するテクノロジーをエージェントに選択させることをお勧めします。
- このエージェントは現在、Webベースのアプリケーションの0〜>1のプロトタイピングに最適です。

4. エージェントが生成したプランを確認して反復します。エージェントが推奨するステップを自由に編集または削除してください。
5. エージェントの進行状況をフォローします。
6. エージェントと協力して、アプリケーションの構築が進行する際の API キー、フィードバック、または指示を提供します。
7. アプリケーションをテストし、必要に応じてフォローアップの質問をします
8. アプリケーションを本番環境にデプロイします。

## Replit 公式の動画に沿ってやってみる

<iframe width="560" height="315" src="https://www.youtube.com/embed/1JPvi48oVY8?si=JXmnGdIqafra4K1n" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

<div style="margin-bottom: 1em;"></div>

### 動画内容の要約

[Glarity](https://glarity.app/ja) で動画の内容を要約してもらった

---

Replit Agent は、AIを活用した仮想環境で、データベースやフロントエンドの構築、ファイルの編集、パッケージのインストールを可能にするもので、開発者にコーディングや構成の手間を省くことができます。このエージェントは、ユーザーの入力を解釈してアプリケーションを計画し、必要なコンポーネントをセットアップします。

#### ハイライト

- 🤖 **プランの作成:** ユーザーの指示に基づいて、アプリケーションの計画を作成し、必要なステップを提案します。
- 📦 **環境のセットアップ:** PythonやNode.jsなどの環境をワンクリックで設定し、パッケージをインストールします。
- 🔧 **ファイル編集:** ファイルシステム上でファイルを作成、編集、更新し、データベースやアプリケーションを実際に構築します。
- 🌐 **デプロイメントの簡略化:** アプリケーションの最適なデプロイメントタイプを提案し、リプリットのデプロイメントプロセスをガイドします。
- 💡 **学習の促進:** エージェントが操作するファイルやロジックを表示することで、ユーザーはアプリケーションの構成を理解できます。

#### キーワード

- AIアシスタント
- フルスタック開発
- 自動化コーディング

---

### ゲストブックというものを作る

以下の機能を持つ

- ユーザーが自分の名前とメッセージを残せるようにする
- それらはデータベースに保存される
- 各コメント（エントリ）に絵文字リアクションを付けることができる（追加機能）

というだけのシンプルなもの

以下動画。だいぶあたふたしているので2倍速

<div class="video-container">
  <video controls src="/images/2025-01-03-replit-agent-first-look/replit-agent-20250102-720p-high.mp4" title="replit-agent-first-look"></video>
</div>

- emoji reaction を付けれるようにした
  - ここは公式動画と違うところ
- 途中であたふたする
  - emoji reaction 機能ができるようになった時点で終了しようと思ったのだが、どうすればいいのかわからなくなった
  - エージェントはずーっとこちらの指示を待っている状態になっていた
  - `Looks good! Finish it.` と打ってしまった（笑）それでも解釈してくれて終了した（えらい）
  - 上の `Running` ボタンを押して停止すれば良かったのかもしれない
- Deploy のところで少しあたふたした

以下、スクショを載せていく

## スクショ

ファーストプロンプト。最初のプロトタイプを作っているところ

![スクリーンショット-2025-01-02-11.43.25](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.43.25.png)

### PostgreSQL

ポスグレのデータベースを作っているぞ

![スクリーンショット-2025-01-02-11.43.58](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.43.58.png)

### ファイル作成の様子

モリモリとファイルを作っていくぞ

![スクリーンショット-2025-01-02-11.46.28](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.46.28.png)

### 依存ライブラリのインストール

![スクリーンショット-2025-01-02-11.47.32](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.47.32.png)

### スクショとプレビュー画面

スクショ撮ってこんな感じやで？どや？と表示してくれる。自動的に開かれたプレビュー上でフォームに直接入力して試すことができる

![スクリーンショット-2025-01-02-11.47.56](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.47.56.png)

### 絵文字リアクション機能の実装

「絵文字リアクション機能つけよか？」と聞いてきたのでポチっとしたところ、以下のことを実行してくれた

- データベーススキーマに `reactions` テーブルを追加する
- リアクションの追加や取得処理を行うように API を更新する
- リアクションの追加や表示のためのフロントエンドコンポーネントを作成する
- そのコンポーネントを各エントリーの下部に組み込む

![スクリーンショット-2025-01-02-11.49.47](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.49.47.png)

### 絵文字リアクションコンポーネント

これがエントリーに対する絵文字リアクションのコンポーネント

![スクリーンショット-2025-01-02-11.52.26](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.52.26.png)

### GuestbookEntriesへのコンポーネント追加

![スクリーンショット-2025-01-02-11.52.53](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.52.53.png)

### 絵文字リアクションが組み込まれた画面

絵文字リアクションが組み込まれた画面が表示された（絵文字がうまく表示されていないようだが）  
プレビューを触ってみてこれで良さそうだなと思い、終了させようとしたのだがどうすればいいのかわからなくなってしまった  
なので苦し紛れに `Looks good! Finish it.` と打ってしまった（笑）

![スクリーンショット-2025-01-02-11.57.13](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.57.13.png)

---

とりあえずここで一旦終了し、念の為アプリを消した

- アプリの削除
  - `Deployments` から削除するとアクセスできなくなった
- 念の為データベースも `Detabase` タブにて消す
- `Usage` は1時間ごとに更新されるらしい

## その後色々みていく

`BlogGuestBook` というプロジェクト名になっていた。これも初回のプロンプトから推測してるのかな？

### プロジェクト構成

![スクリーンショット-2025-01-02-11.22.24](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.22.24.png)

![スクリーンショット-2025-01-02-11.22.43](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.22.43.png)

- server は `express`
- `hooks/use-toast.ts` が右下に出てくるトーストの処理か
- `drizzle.config.ts` がある
- UI は `radix-ui`

### package.json

```json
{
  "name": "rest-express",
  "version": "1.0.0",
  "type": "module",
  "license": "MIT",
  "scripts": {
    "dev": "tsx server/index.ts",
    "build": "vite build && esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist",
    "start": "NODE_ENV=production node dist/index.js",
    "check": "tsc",
    "db:push": "drizzle-kit push"
  },
  "dependencies": {
    "@hookform/resolvers": "^3.9.1",
    "@jridgewell/trace-mapping": "^0.3.25",
    "@radix-ui/react-accordion": "^1.2.1",
    "@radix-ui/react-alert-dialog": "^1.1.2",
    "@radix-ui/react-aspect-ratio": "^1.1.0",
    "@radix-ui/react-avatar": "^1.1.1",
    "@radix-ui/react-checkbox": "^1.1.2",
    "@radix-ui/react-collapsible": "^1.1.1",
    "@radix-ui/react-context-menu": "^2.2.2",
    "@radix-ui/react-dialog": "^1.1.2",
    "@radix-ui/react-dropdown-menu": "^2.1.2",
    "@radix-ui/react-hover-card": "^1.1.2",
    "@radix-ui/react-label": "^2.1.0",
    "@radix-ui/react-menubar": "^1.1.2",
    "@radix-ui/react-navigation-menu": "^1.2.1",
    "@radix-ui/react-popover": "^1.1.2",
    "@radix-ui/react-progress": "^1.1.0",
    "@radix-ui/react-radio-group": "^1.2.1",
    "@radix-ui/react-scroll-area": "^1.2.0",
    "@radix-ui/react-select": "^2.1.2",
    "@radix-ui/react-separator": "^1.1.0",
    "@radix-ui/react-slider": "^1.2.1",
    "@radix-ui/react-slot": "^1.1.0",
    "@radix-ui/react-switch": "^1.1.1",
    "@radix-ui/react-tabs": "^1.1.1",
    "@radix-ui/react-toast": "^1.2.2",
    "@radix-ui/react-toggle": "^1.1.0",
    "@radix-ui/react-toggle-group": "^1.1.0",
    "@radix-ui/react-tooltip": "^1.1.3",
    "@replit/vite-plugin-shadcn-theme-json": "^0.0.4",
    "@tanstack/react-query": "^5.60.5",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.1",
    "cmdk": "^1.0.0",
    "date-fns": "^3.6.0",
    "drizzle-orm": "^0.38.2",
    "drizzle-zod": "^0.6.0",
    "embla-carousel-react": "^8.3.0",
    "express": "^4.21.2",
    "express-session": "^1.18.1",
    "framer-motion": "^11.13.1",
    "input-otp": "^1.2.4",
    "lucide-react": "^0.453.0",
    "memorystore": "^1.6.7",
    "passport": "^0.7.0",
    "passport-local": "^1.0.0",
    "react": "^18.3.1",
    "react-day-picker": "^8.10.1",
    "react-dom": "^18.3.1",
    "react-hook-form": "^7.53.1",
    "react-icons": "^5.4.0",
    "react-resizable-panels": "^2.1.4",
    "recharts": "^2.13.0",
    "tailwind-merge": "^2.5.4",
    "tailwindcss-animate": "^1.0.7",
    "vaul": "^1.1.0",
    "wouter": "^3.3.5",
    "ws": "^8.18.0",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@replit/vite-plugin-runtime-error-modal": "^0.0.3",
    "@tailwindcss/typography": "^0.5.15",
    "@types/express": "4.17.21",
    "@types/express-session": "^1.18.0",
    "@types/node": "20.16.11",
    "@types/passport": "^1.0.16",
    "@types/passport-local": "^1.0.38",
    "@types/react": "^18.3.11",
    "@types/react-dom": "^18.3.1",
    "@types/ws": "^8.5.13",
    "@vitejs/plugin-react": "^4.3.2",
    "autoprefixer": "^10.4.20",
    "drizzle-kit": "^0.27.1",
    "esbuild": "^0.24.0",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.14",
    "tsx": "^4.19.1",
    "typescript": "5.6.3",
    "vite": "^5.4.9"
  },
  "optionalDependencies": {
    "bufferutil": "^4.0.8"
  }
}
```

routing は `wouter` というものを使っている

[molefrog/wouter: 🥢 A minimalist-friendly \~2.1KB routing for React and Preact](https://github.com/molefrog/wouter)

[葉桜の季節に君へルーティングライブラリ wouter を紹介するということ](https://zenn.dev/uttk/articles/introduction-of-wouter)

コードを眺めてるだけでも面白い

### git log

おもむろに Shell を開いて `git log` してみたが勝手に5回コミットされていた。なにこれ怖い

`Agent` タブ上では `Checkpoint made ...` と表示されている部分がちょうど5つあったのでその度にコミットするのだろう

![スクリーンショット-2025-01-02-12.00.22](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-12.00.22.png)

### Usage

https://docs.replit.com/replitai/agent#agent-billing

> The Replit Agent operates on a usage-based billing system where you pay 25 cents per checkpoint. A checkpoint occurs whenever the agent makes file changes while working on your request, regardless of whether the entire task is complete.

> Replitエージェントは、チェックポイントごとに25セントを支払う使用ベースの課金システムで動作します。 チェックポイントは、タスク全体が完了したかどうかに関係なく、エージェントがお客様のリクエストの作業中にファイルを変更するたびに発生します。

`Agent` タブ右上から `Usage` ページに飛ぶことができる

![スクリーンショット-2025-01-02-11.30.11](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.30.11.png)

`$0.25/per checkpoint` なので2回分しかお金はかかっていない。チェックポイントとしてコミットされたのは5回だったが、実際にファイルの変更があったのは2回しかないということか

```sh
~/BlogGuestBook$ git log --stat --oneline
30dcd8f (HEAD -> main) Agent step completed: Build the initial prototype
002ae63 Agent query: Can you see the emoji reaction buttons below each guestbook entry? Try clicking on them to add reactions.
 client/src/components/EntryReactions.tsx   | 67 ++++++++++++++++++++++++++++++++++++++
 client/src/components/GuestbookEntries.tsx |  4 ++-
 client/src/lib/types.ts                    |  8 +++++
 db/schema.ts                               | 26 ++++++++++++++-
 server/routes.ts                           | 55 ++++++++++++++++++++++++++++---
 5 files changed, 153 insertions(+), 7 deletions(-)
c4d3e63 Agent query: Can you test the guestbook by adding a message with your name? Please verify if the message appears in the list below and if the timestamp is correct.
 .gitignore                                   |    6 +
 .replit                                      |   42 +
 client/index.html                            |   11 +
 client/src/App.tsx                           |   12 +
 client/src/components/GuestbookEntries.tsx   |   64 +
 client/src/components/GuestbookForm.tsx      |  105 +
 client/src/components/ui/accordion.tsx       |   56 +
 client/src/components/ui/alert-dialog.tsx    |  139 +
 client/src/components/ui/alert.tsx           |   59 +
 client/src/components/ui/aspect-ratio.tsx    |    5 +
 client/src/components/ui/avatar.tsx          |   48 +
 client/src/components/ui/badge.tsx           |   36 +
 client/src/components/ui/breadcrumb.tsx      |  115 +
 client/src/components/ui/button.tsx          |   56 +
 client/src/components/ui/calendar.tsx        |   64 +
 client/src/components/ui/card.tsx            |   79 +
 client/src/components/ui/carousel.tsx        |  260 +
 client/src/components/ui/chart.tsx           |  363 ++
 client/src/components/ui/checkbox.tsx        |   28 +
 client/src/components/ui/collapsible.tsx     |    9 +
 client/src/components/ui/command.tsx         |  153 +
 client/src/components/ui/context-menu.tsx    |  198 +
 client/src/components/ui/dialog.tsx          |  120 +
 client/src/components/ui/drawer.tsx          |  116 +
 client/src/components/ui/dropdown-menu.tsx   |  198 +
 client/src/components/ui/form.tsx            |  176 +
 client/src/components/ui/hover-card.tsx      |   27 +
 client/src/components/ui/input-otp.tsx       |   69 +
 client/src/components/ui/input.tsx           |   25 +
 client/src/components/ui/label.tsx           |   24 +
 client/src/components/ui/menubar.tsx         |  234 +
 client/src/components/ui/navigation-menu.tsx |  128 +
 client/src/components/ui/pagination.tsx      |  117 +
 client/src/components/ui/popover.tsx         |   29 +
 client/src/components/ui/progress.tsx        |   26 +
 client/src/components/ui/radio-group.tsx     |   42 +
 client/src/components/ui/resizable.tsx       |   43 +
 client/src/components/ui/scroll-area.tsx     |   46 +
 client/src/components/ui/select.tsx          |  158 +
 client/src/components/ui/separator.tsx       |   29 +
 client/src/components/ui/sheet.tsx           |  138 +
 client/src/components/ui/sidebar.tsx         |  762 +++
 client/src/components/ui/skeleton.tsx        |   15 +
 client/src/components/ui/slider.tsx          |   26 +
 client/src/components/ui/switch.tsx          |   27 +
 client/src/components/ui/table.tsx           |  117 +
 client/src/components/ui/tabs.tsx            |   53 +
 client/src/components/ui/textarea.tsx        |   24 +
 client/src/components/ui/toast.tsx           |  127 +
 client/src/components/ui/toaster.tsx         |   33 +
 client/src/components/ui/toggle-group.tsx    |   59 +
 client/src/components/ui/toggle.tsx          |   43 +
 client/src/components/ui/tooltip.tsx         |   28 +
 client/src/hooks/use-mobile.tsx              |   19 +
 client/src/hooks/use-toast.ts                |  191 +
 client/src/index.css                         |   13 +
 client/src/lib/queryClient.ts                |   30 +
 client/src/lib/types.ts                      |   11 +
 client/src/lib/utils.ts                      |    6 +
 client/src/main.tsx                          |   16 +
 client/src/pages/.gitkeep                    |    0
 client/src/pages/Home.tsx                    |   28 +
 db/index.ts                                  |   15 +
 db/schema.ts                                 |   14 +
 drizzle.config.ts                            |   14 +
 package-lock.json                            | 8783 ++++++++++++++++++++++++++++++++++
 package.json                                 |   98 +
 postcss.config.js                            |    6 +
 server/index.ts                              |   65 +
 server/routes.ts                             |   46 +
 server/vite.ts                               |   93 +
 tailwind.config.ts                           |   90 +
 theme.json                                   |    6 +
 tsconfig.json                                |   24 +
 vite.config.ts                               |   23 +
 75 files changed, 14558 insertions(+)
ed24da8 Checkpoint after starting plan
0a44b28 Initial commit
 generated-icon.png | Bin 0 -> 380183 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)
```

### Deployments

![スクリーンショット-2025-01-02-11.35.30](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.35.30.png)

![スクリーンショット-2025-01-02-11.33.32](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-11.33.32.png)

---

### 感想

- とにかく凄くて怖い
- 公式動画のプロンプトをそのまま入れたのでまあまあ精度は高い
  - 違った点は、動画ではバックエンドは `Flask`, `Vanilla JS`, `PostgreSQL` だった
  - そこら辺はよくわからないが自分の時は `Express`, `React`, `PostgreSQL` だった
- 途中どうすれば良いかわからんくなったがなんとなくフィーリングでできるから良い
- まずければチェックポイントまでロールバックできるようだから安心
- 追加機能どうします？と聞いてくれるのは良い
  - ついつい emoji reaction 入れちゃったよね
  - 後から追加追加…とやっていくと破綻しないんだろうか？
    - 今回は emoji reaction の追加だけだったので `reactions` テーブルの追加やコンポーネントの作成くらいで済んだのだが
- 初回の時点でログイン機能 (Firebase login) など各種機能は選べるようだ
  - ![スクリーンショット-2025-01-02-12.27.28](/images/2025-01-03-replit-agent-first-look/スクリーンショット-2025-01-02-12.27.28.png)
- あらかじめ要件や仕様をある程度固めておくと良いのだろうなあ
  - プロンプトは日本語でもいけるのかな？
