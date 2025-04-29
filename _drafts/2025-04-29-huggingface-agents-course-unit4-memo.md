---
title: "Unit4. Final Project - Create, Test, and Certify Your Agent"
date: "2025-04-29 14:13:19 +0900"
last_modified_at: "2025-04-29 14:13:19 +0900"
---

# Unit4. Final Project - Create, Test, and Certify Your Agent
このコースの最終課題では、GAIAベンチマークの一部を使って独自のAIエージェントを作成・評価します。コース修了には、ベンチマークで30%以上のスコアが必要です。達成すると修了証が授与されます。また、学生リーダーボードで他の受講生とスコアを比較できます。最終課題は実践的で高度なコーディング知識が必要となるため、これまでのユニットよりも難易度は高くなります。

## Welcome to the Final Unit
### What's the challenge?

## What is GAIA?
GAIAは、推論、マルチモーダル理解、ウェブブラウジング、ツール利用といった中核能力を組み合わせる必要がある現実世界タスクにおいて、AIアシスタントを評価するために設計されたベンチマークです。人間には概念的に簡単でありながら、現在のAIシステムにとっては非常に難しい466問の厳選された質問で構成されています。人間の正答率は約92%であるのに対し、プラグイン付きGPT-4は約15%、Deep Research（OpenAI）は検証セットで67.36%という結果が出ており、現在のAIモデルの限界を浮き彫りにしています。GAIAは、真の汎用AIアシスタントへの進捗を評価するための厳密なベンチマークを提供します。タスクは難易度に応じて3つのレベルに分けられ、レベル3では長期計画や様々なツールの高度な統合が求められます。難しい問題の例として、絵画に描かれた果物と、特定の船の過去の朝食メニューを関連付ける問題が挙げられています。これは、マルチモーダル推論、多段階の情報検索、正しい順序での処理など、AIシステムの課題を浮き彫りにしています。Hugging Faceには300問のテスト問題による公開リーダーボードがあり、継続的なベンチマーク評価を促進しています。

### 🌱 GAIA’s Core Principles
### Difficulty Levels
GAIA tasks are organized into three levels of increasing complexity, each testing specific skills:

Level 1: Requires less than 5 steps and minimal tool usage.
Level 2: Involves more complex reasoning and coordination between multiple tools and 5-10 steps.
Level 3: Demands long-term planning and advanced integration of various tools.

### Example of a Hard GAIA Question
2008年の絵画「ウズベキスタンの刺繍」に描かれた果物のうち、後に映画「最後の航海」の小道具として使用された豪華客船の1949年10月の朝食メニューに提供されたのはどれですか？ 項目をカンマ区切りのリストとして、絵画の12時の位置から時計回りに並べなさい。各果物は複数形を使用してください。

ご覧のとおり、この問題はAIシステムにいくつかの点で課題を与えます。

構造化された回答形式が必要です。

マルチモーダル推論（例：画像分析）が必要です。

相互に依存する事実のマルチホップ検索が必要です。

絵画に描かれた果物を特定する
「最後の航海」で使用された豪華客船を特定する
その船の1949年10月の朝食メニューを調べる
正しい順序で解くには、正しい順序付けと高度な計画が必要です。

### Live Evaluation

## Hands-On
このコンテンツは、GAIAベンチマークレベル1の質問20問を使ってエージェントを作成し、その性能を評価するための手順を説明しています。

**要点:**

* データセット：GAIA検証セットレベル1から抽出された20問。ツールとステップ数でフィルタリング済み。目標はレベル1で30%の正答率。
* API：質問取得と回答提出のためのAPIが提供されている。
  * `/questions`: 全質問リスト取得
  * `/random-question`: ランダムに1問取得
  * `/files/:`: 特定のタスクIDに関連付けられたファイルをダウンロード
  * `/submit`: 回答を提出し、スコア計算、リーダーボード更新
* 採点方法：完全一致。適切なプロンプトが重要。
* テンプレート：API操作のテンプレートが提供されているが、変更・追加・再構築は自由。
* 提出に必要な情報：Hugging Faceユーザー名、スペースのコードへのURL（公開設定必須）、エージェントの回答。
* リーダーボード：提出結果はリーダーボードに反映される。ただし、不正防止のため、公開されたコードがない高スコアはレビュー・調整・削除される可能性がある。
* 学生限定のリーダーボードのため、高スコアの場合はスペースを公開状態に保つように推奨。


簡単に言うと、提供されたAPIとテンプレートを使ってGAIAの質問に答えるエージェントを作成し、その性能をリーダーボードで競うという内容です。

### The Dataset
### The process
評価用の API のドキュメント
https://agents-course-unit4-scoring.hf.space/docs

## Claim Your Certificate
このコースはAIエージェント作成を学ぶためのものです。コース内容は、エージェントの基礎、主要フレームワーク(smolagents, LlamaIndex, LangGraph)、RAGへの応用、最終プロジェクト、そして追加でLLMのファインチューニング、エージェントの評価、ゲームへの応用を扱います。修了時には証明書が取得できます。

---

まずは GAIA の API を使えるクラスでも作ればよさそう。
この人は 95pt とっている。このファイルに GAIA Agent を実装している
https://huggingface.co/spaces/susmitsil/FinalAgenticAssessment/blob/main/main_agent.py

編集しやすくするためにローカルにクローンする方法が知りたいな。流石にローカルで動かせなくてもいいけど
