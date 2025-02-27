---
title: "Hugging Face Agents Course Unit2"
date: "2025-02-27 21:45:44 +0900"
last_modified_at: "2025-02-27 21:45:44 +0900"
---

## Hugging Face Agents Course Unit2
https://huggingface.co/learn/agents-course/unit2/introduction

### 要約
この内容は、エージェントのフレームワークに関するコースの概要です。コースは、エージェントの基本、AIエージェントのフレームワークについて説明しています。特に、smolagents、LlamaIndex、LangGraphのような異なるエージェントフレームワークを学び、複雑なワークフローを効率的に処理する方法を探ります。フレームワークの利用が必ずしも必要ではなく、シンプルなアプローチも可能であることが説明されていますが、複雑なタスクにはフレームワークが役立つことが強調されています。

### Introduction to Agentic Frameworks
このモジュールは、軽量AIエージェントフレームワークである`smolagents`ライブラリの使い方を学ぶための入門です。Alfred（Unit 1のエージェント）がWayne Manorでのパーティー準備を通して、`smolagents`を使った様々なタスクの実行例を示します。

**学習内容:**

* `smolagents`を使う理由 (LlamaIndex, LangGraphとの比較)
* CodeAgents (Pythonコード生成エージェント)
* ToolCallingAgents (JSON/テキストベースのエージェント)
* ツールの作成と使用方法 (Toolクラス、@toolデコレータ、コミュニティツール)
* Retrieval Agents (知識ベースへのアクセス、RAGパターン)
* マルチエージェントシステムの構築と管理
* Vision Agents (視覚情報処理、VLM活用) と Browser Agents (Webブラウジング)

`smolagents`ドキュメントや関連リソースへのリンクも提供されます。要するに、`smolagents`を使って様々な種類のエージェントを構築し、ツールや知識ベースと連携させ、複雑なタスクを実行する方法を学ぶことができます。

#### When to Use an Agentic Framework
#### Agentic Frameworks Units

### Introduction to smolagents
#### Module Overview
#### Contents
##### 1️⃣ Why Use smolagents
##### 2️⃣ CodeAgents
> CodeAgentsは、smolagents の主要なエージェント タイプです。これらのエージェントは、JSON やテキストを生成する代わりに、アクションを実行する Python コードを生成します。

##### 3️⃣ ToolCallingAgents
> `ToolCallingAgents` は、`smolagents`でサポートされている 2番目のタイプのエージェントです。Python コードを生成する CodeAgents とは異なり、これらのエージェントは、システムがアクションを実行するために解析および解釈する必要がある JSON/テキスト BLOB に依存します。

##### 4️⃣ Tools
> ユニット 1 で説明したように、ツールは LLM がエージェント システム内で使用できる関数であり、エージェントの動作に不可欠な構成要素として機能します。このモジュールでは、ツールの作成方法、その構造、Toolクラスまたは@toolデコレータを使用したさまざまな実装方法について説明します。また、デフォルトのツールボックス、コミュニティとツールを共有する方法、エージェントで使用するためにコミュニティが提供したツールを読み込む方法についても学習します。

##### 5️⃣ Retrieval Agents
> 検索エージェントを使用すると、モデルが知識ベースにアクセスできるため、複数のソースから情報を検索、統合、取得できます。検索エージェントは、ベクター ストアを活用して効率的な検索を行い、検索拡張生成 (RAG)パターンを実装します。これらのエージェントは、メモリ システムを通じて会話のコンテキストを維持しながら、Web 検索とカスタム知識ベースを統合するのに特に役立ちます。

##### 6️⃣ Multi-Agent Systems
> 複数のエージェントを効果的にオーケストレーションすることは、強力なマルチエージェント システムを構築する上で非常に重要です。Web 検索エージェントとコード実行エージェントなど、異なる機能を持つエージェントを組み合わせることで、より洗練されたソリューションを作成できます。

##### 7️⃣ Vision and Browser agents
> ビジョンエージェントは、ビジョン言語モデル (VLMs Vision-Langauge Models)を組み込むことで従来のエージェントの機能を拡張し、視覚情報の処理と解釈を可能にします。このモジュールでは、VLM を利用したエージェントを設計および統合し、画像ベースの推論、視覚データ分析、マルチモーダルインタラクションなどの高度な機能を実現する方法を探ります。また、ビジョンエージェントを使用して、Web を閲覧してそこから情報を抽出できるブラウザエージェントを構築します。

#### Resources

### Why use smolagents
#### 要約
smolagentsはシンプルながらも強力なAIエージェント構築フレームワークです。Hugging Faceツールや外部APIとの連携を通じて、LLMが検索や画像生成といった実世界の操作を可能にします。

**主な利点:**

* **シンプル:** コードの複雑さと抽象化を最小限に抑え、理解、採用、拡張が容易。
* **柔軟なLLMサポート:** Hugging Faceツールと外部APIとの統合により、あらゆるLLMで動作。
* **コードファーストアプローチ:** コードで直接アクションを記述するコードエージェントを最優先でサポートし、解析の必要性をなくし、ツール呼び出しを簡素化。
* **HF Hub統合:** Hugging Face Hubとのシームレスな統合により、Gradio Spacesをツールとして使用可能。

**smolagentsの使用が適している場合:**

* 軽量で最小限のソリューションが必要な場合。
* 複雑な設定なしで迅速に実験を行いたい場合。
* アプリケーションロジックが単純な場合。

**smolagentsの特徴:**

* JSONではなくコードでアクションを記述するため、実行プロセスが簡素化。
* マルチステップエージェントを採用し、「思考」→「ツール呼び出しと実行」を繰り返す。
* `@tool`デコレータでPython関数をラップしてツールを定義。
* TransformersModel、HfApiModel、LiteLLMModel、OpenAIServerModel、AzureOpenAIServerModelなど、多様なモデル統合をサポート。


つまり、シンプルで柔軟性が高く、コード中心のアプローチを採用したAIエージェントフレームワークがsmolagentsです。特に、手軽に実験を始めたい場合や、複雑な設定を避けたい場合に最適です。

#### What is smolagents ?
smolagentsは、AIエージェントを構築するためのシンプルかつ強力なフレームワークである。 ユニット1で学んだように、AIエージェントは、LLMを使って「観察」に基づいて「思考」を生成し、「行動」を実行するプログラムです。 これがsmolagentsでどのように実装されているかを探ってみよう。 


##### Key Advantages of smolagents
**smolagentsの主な利点**

- シンプルさ： 最小限のコードの複雑さと抽象化により、フレームワークを理解しやすく、採用しやすく、拡張しやすくしている。 
- 柔軟なLLMサポート： Hugging Faceツールや外部APIとの統合により、どのようなLLMでも動作
- コードファーストアプローチ： コードで直接アクションを記述するコードエージェントをファーストクラスでサポートし、解析の必要性を取り除き、ツールの呼び出しを簡素化
- HFハブの統合： Hugging Face Hubとのシームレスな統合により、Gradio Spacesをツールとして使用することができます。

##### When to use smolagents?
これらの利点を念頭に置いて、他のフレームワークではなくsmolagentsを使用するのはどのような場合でしょうか？ 

smolagentsは、次のような場合に理想的です。

- 軽量で最小限のソリューションが必要な場合。
- 複雑な設定をせずに、迅速に実験を行いたい場合。
- アプリケーション・ロジックが単純な場合。

##### Code vs. JSON Actions
エージェントがJSONでアクションを記述する他のフレームワークとは異なり、smolagentsはコードでのツール呼び出しにフォーカスし、実行プロセスを簡素化します。 これは、ツールを呼び出すコードをビルドするためにJSONをパースする必要がないからです。

##### Agent Types in smolagents
##### Model Integration in smolagents
#### Resources


### Building Agents That Use Code

smolagents はPythonコードスニペットを記述・実行するエージェント構築に特化した軽量フレームワーク（約1000行のコード）で、安全なサンドボックス実行環境を提供します。コードエージェントは、smolagents のデフォルトのエージェントタイプであり、効率的で表現力豊かで正確なアクション表現を実現します。

**コードエージェントの利点:**

* **構成性:** アクションの組み合わせと再利用が容易
* **オブジェクト管理:** 画像などの複雑な構造を直接操作可能
* **汎用性:** 計算可能なタスクを表現可能
* **LLMとの親和性:** 高品質なコードはLLMの学習データに既に存在

**コードエージェントの動作:**

ReActフレームワークに基づき、`CodeAgent.run()`で実行。`MultiStepAgent`を基本とし、実行ログに記録される変数と知識をコンテキストとして利用しながら、以下のループを繰り返します。

1. エージェントのログをLLMが読めるチャットメッセージに変換。
2. メッセージをモデルに送信し、コードスニペットを生成。
3. 生成されたコードスニペットを解析し、実行。
4. 結果を実行ログに記録。
5. 各ステップの最後に、`agent.step_callback`に定義された関数を必要に応じて実行。

**コード例:**

チュートリアルでは、パーティー準備を例に、DuckDuckGo検索、カスタムツール、Pythonモジュールのインポートなどを用いたコードエージェントの作成方法を紹介しています。また、作成したエージェントをHugging Face Hubで共有する方法も示されています。

**OpenTelemetryとLangfuseによる監視:**

OpenTelemetryとLangfuseを用いてエージェントの実行状況を監視・分析する方法も解説されています。

**まとめ:**

smolagents を使用することで、コードによるアクションを効率的に実行するエージェントを容易に構築し、共有することができます。さらに、OpenTelemetryとLangfuseを組み合わせることで、エージェントの動作を詳細に監視・分析することが可能です。

#### Why Code Agents?
#### How Does a Code Agent Work?
#### Let’s See Some Examples
### Selecting a Playlist for the Party Using smolagents
### Using a Custom Tool to Prepare the Menu
### Using Python Imports Inside the Agent
### Sharing Our Custom Party Preparator Agent to the Hub
### Inspecting Our Party Preparator Agent with OpenTelemetry and Langfuse 📡
#### Resources
