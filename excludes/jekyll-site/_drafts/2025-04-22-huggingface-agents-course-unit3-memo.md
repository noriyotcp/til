---
title: "Unit3. Use Case For Agentic RAG"
date: "2025-04-22 23:34:31 +0900"
last_modified_at: "2025-04-22 23:34:31 +0900"
---

# Unit3. Use Case For Agentic RAG
Introduction to Use Case for Agentic RAG

## Introduction to Use Case for Agentic RAG
Alfredというエージェントが主催する盛大なガラパーティーの準備を手伝うために、エージェントRAGを活用します。Alfredはパーティーのあらゆる側面（メニュー、ゲスト情報、スケジュール、天気など）を管理し、ゲストの質問に答え、予期せぬ事態にも対応する必要があります。そのため、必要な情報とツールへのアクセスをAlfredに提供することが目的です。

ガラには、ルネサンス期の教養人のように、スポーツ、文化、科学の深い知識が求められます。ただし、政治や宗教といった論争になりやすい話題は避けるべきです。さらに、良いホストとして、ゲストの経歴や興味、活動などを把握し、ゲスト同士で話題を共有できるようにする必要があります。最後に、花火の打ち上げタイミングを完璧にするために、天気予報もリアルタイムで確認できる必要があります。

この要件を満たすため、AlfredにRetrieval Augmented Generation (RAG)トレーニングを実施し、必要なツールを作成します。

### A Gala to Remember
### The Gala Requirements

## Agentic Retrieval Augmented Generation (RAG)
このコースは、エージェントとRetrieval Augmented Generation (RAG)について学ぶためのものです。コースの内容は以下の通りです。

* エージェントの概要
* AIエージェントのフレームワーク (smolagents, LlamaIndex, LangGraph)
* エージェントRAGのユースケース
* LLMのファインチューニング（ボーナスユニット）
* エージェントの可観測性と評価（ボーナスユニット）

## Creating a RAG Tool for Guest Stories
特に、エージェントRAGは、LLMの知識を最新の情報で補完するために、関連データを取得しLLMに提供する手法です。コースでは、Alfredというエージェントを例に、ガラプランニングというユースケースを通して、招待客情報、ウェブ検索、天気予報、Hugging Face Hubモデルのダウンロード統計などのツールをRAGで活用する方法を学びます。

このコンテンツは、ゲスト情報に迅速にアクセスできるRAG(Retrieval-Augmented Generation)ツールを作成する方法を説明しています。架空の執事Alfredが華やかなパーティーを円滑に進めるために、ゲスト情報を即座に取得できるツールが必要という設定です。

**ハイライト:**

* **RAGツールの目的:** ゲストリストはイベント固有のものであり、LLMの学習データには含まれていないため、通常のLLMでは対応が難しい。RAGは検索システムとLLMを組み合わせることで、正確で最新のゲスト情報をオンデマンドでアクセスできるようにする。
* **データセット:** `agents-course/unit3-invitees`というデータセットを使用。ゲストの名前、ホストとの関係、簡単な経歴、メールアドレスが含まれている。
* **ツールの実装:**  3つのステップで実装。1. データセットの読み込みと準備、2. 検索ツールの作成(BM25Retrieverを使用)、3. Alfred(CodeAgent)との統合。
* **ツール使用方法:** Alfredに質問すると、ツールがゲストデータベースを検索し、関連情報を返す。
* **拡張性:** より高度な検索アルゴリズム(Sentence Transformersなど)の利用、会話履歴の保存、Web検索との連携、複数のインデックスの統合など、ツールの改善策が示唆されている。


**要約:**

ゲスト情報検索ツールをRAGを用いて作成する方法を、具体的なコード例とともに解説しています。BM25Retrieverを用いた基本的な実装から、より高度な機能拡張まで、段階的に説明されているため、RAGツール構築の入門として有用な内容です。

### Why RAG for a Gala?
### Setting up our application
#### Project Structure
### Dataset Overview
### Building the Guestbook Tool
#### Step 1: Load and Prepare the Dataset
smolagents, llama-index, langgraph それぞれやり方がある  
だが基本的には huggingface の `datasets` を使い、`Document` objects に変換する

- Load the dataset
- Convert each guest entry into a Document object with formatted content
- Store the Document objects in a list

#### Step 2: Create the Retriever Tool
- The name and description help the agent understand when and how to use this tool
- The inputs define what parameters the tool expects (in this case, a search query)
- We’re using a BM25Retriever, which is a powerful text retrieval algorithm that doesn’t require embeddings
- The forward method processes the query and returns the most relevant guest information

#### Step 3: Integrate the Tool with Alfred
- We initialize a Hugging Face model using the HuggingFaceEndpoint class. We also generate a chat interface and append the tools.
- We create our agent (Alfred) as a StateGraph, that combines 2 nodes (assistant, tools) using an edge
- We ask Alfred to retrieve information about a guest named “Lady Ada Lovelace”

### Example Interaction
### Taking It Further
1. Improve the retriever to use a more sophisticated algorithm like sentence-transformers
2. Implement a conversation memory so Alfred remembers previous interactions
3. Combine with web search to get the latest information on unfamiliar guests
4. Integrate multiple indexes to get more complete information from verified sources

## Building and Integrating Tools for Your Agent
Alfredというエージェントに、Web検索、天気情報取得、Hugging Face Hubの統計情報取得といったツールを統合する方法が説明されています。

Web検索ツールはDuckDuckGoを使用し、天気情報はダミーAPIを用いて実装、Hugging Face Hubの統計情報は、指定したユーザーのダウンロード数が多いモデルを取得します。

これらのツールは`smolagents`ライブラリを使って実装され、Alfred（`CodeAgent`）に統合することで、多様なタスクをこなせるようにしています。最終的には、Facebookに関する質問に対して、Web検索で得たFacebookの説明と、Hub Statsツールで取得した人気モデル情報を組み合わせて回答できるようになります。

（注）`smolagents` だけではなく、`langgraph` や `llama-index` などのフレームワークも使用されている。

最後に、読者に対して、特定のトピックに関する最新ニュースを取得するツールの実装を課題として提示しています。

### Give Your Agent Access to the Web
Web にアクセスして検索するための `search_tool` を作成する方法を説明しています。具体的には、DuckDuckGoのAPIを使用して、AlfredがWeb検索を行えるようにします。

### Creating a Custom Tool for Weather Information to Schedule the Fireworks
花火大会をやるという想定で、その日の天候を調べるためのツールを作成する。外部の天気 API を使用する。知りたい地点の天気を教えてくれる。
ここではダミーの API と天気のデータを用意する。実際に使うには `OpenWeatherMap` などの API を使う。

### Creating a Hub Stats Tool for Influential AI Builders
Hugging Face Hubの統計情報を取得するためのツールを作成します。特定のユーザーが公開したモデルの中で、最もダウンロード数が多いモデルを取得します。

### Integrating Tools with Alfred
### Conclusion

## Creating Your Gala Agent
このドキュメントでは、Alfredという名のAIエージェントを作成する方法を解説しています。Alfredは、ガラパーティーの主催を支援するために、ゲスト情報検索、Web検索、天気情報取得、Hub統計ツールといった複数の機能を備えています。

**Alfredの機能概要:**

* **ゲスト情報検索:** ゲストの名前や関係性などの詳細情報を提供します。
* **天気情報取得:** 特定の場所の天気情報を取得し、花火の打ち上げ可否などの判断を支援します。
* **AI情報提供:** 影響力のあるAI開発者やそのモデルに関する情報を提供します。
* **Web検索:** 最新の情報を得るためにWeb検索を実行できます。
* **会話記憶:** 過去の会話内容を記憶し、より自然な会話を実現します (明示的に`reset=False`を設定する必要があります)。


**Alfredの使い方:**

1. 必要なツールを`tools.py`と`retriever.py`に実装し、インポートします。
2. `CodeAgent`を使ってツールを統合し、Alfredを作成します。
3. `alfred.run(query)`でクエリを実行し、Alfredからのレスポンスを取得します。

**会話記憶の利用:**

`reset=False`を設定することで、Alfredに会話の記憶を保持させることができます。これにより、以前の会話内容を踏まえた応答が可能になります。ただし、この機能は明示的に設定する必要があります。

**重要なポイント:**

* smolagents、LlamaIndex、LangGraphのいずれも、エージェントとメモリを直接結合していません。メモリ管理は明示的に行う必要があります。


このドキュメントに従うことで、多機能なAIエージェントAlfredを作成し、ガラパーティーを成功させるための様々なサポートを受けることができます。

### Assembling Alfred: The Complete Agent
どのライブラリも tools を用意して、エージェントに渡す

### Using Alfred: End-to-End Examples
#### Example 1: Finding Guest Information
#### Example 2: Checking the Weather for Fireworks
#### Example 3: Impressing AI Researchers
#### Example 4: Combining Multiple Tools
### Advanced Features: Conversation Memory
### Conclusion
このユニットでは、盛大なパーティーを主催するAlfredというエージェントを支援するための、RAGとエージェント機能を組み合わせたシステムの作成方法を学びました。

Alfredは、構造化知識（ゲスト情報）、リアルタイム情報（ウェブ検索）、特定分野のツール（天気情報など）、過去の会話の記憶へのアクセスを持つことで、ゲストへの対応、最新情報の提供、花火のタイミング調整など、完璧なホスト役をこなせるようになりました。

今後の学習として、独自のツール作成、より高度なRAGシステム構築、複数エージェントの連携、エージェントサービスとしての展開などが挙げられます。
