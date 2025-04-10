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
> LLM を中心としたアプリケーションを構築する場合、エージェントフレームワークは必ずしも必要ではありません。エージェントフレームワークはワークフローに柔軟性をもたらし、特定のタスクを効率的に解決するのに役立ちますが、必ずしも必要というわけではありません。
> 
> 場合によっては、事前定義されたワークフローだけでユーザーのリクエストを満たすことができ、エージェントフレームワークは実際には必要ありません。エージェントの構築方法がプロンプトの連鎖のようにシンプルな場合は、プレーンコードで十分な場合もあります。その利点は、開発者が抽象化することなくシステムを完全に制御し、理解できることです。
> 
> ただし、LLM に関数を呼び出させたり、複数のエージェントを使用したりといったワークフローがより複雑になると、これらの抽象化が役立つようになります。

#### Agentic Frameworks Units

## Unit 2.1 The smolagents Framework
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

---

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
Agents in smolagents operate as multi-step agents.

Each MultiStepAgent performs:

- One thought
- One tool call and execution

##### Model Integration in smolagents
#### Resources

----

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
「なぜコードエージェントなのか？」という問いに対する回答を日本語に翻訳します。原文のニュアンスを捉えながら、自然な日本語になるように訳します。


**原文:**

> In a multi-step agent process, the LLM writes and executes actions, typically involving external tool calls. Traditional approaches use a JSON format to specify tool names and arguments as strings, which the system must parse to determine which tool to execute. However, research shows that tool-calling LLMs work more effectively with code directly. This is a core principle of smolagents, as shown in the diagram above from Executable Code Actions Elicit Better LLM Agents. Writing actions in code rather than JSON offers several key advantages: Composability: Easily combine and reuse actions Object Management: Work directly with complex structures like images Generality: Express any computationally possible task Natural for LLMs: High-quality code is already present in LLM training data


**翻訳:**

複数ステップのエージェントプロセスでは、大規模言語モデル（LLM）がアクションを記述し実行しますが、通常は外部ツールの呼び出しを含みます。従来のアプローチでは、ツール名と引数を文字列としてJSON形式で指定し、システムはそのJSONを解析して実行するツールを決定する必要があります。しかし、研究によると、ツールを呼び出すLLMは、コードを直接扱う方がより効果的に動作することが示されています。これはsmolagentsの中核となる原則であり、上の図（Executable Code Actions Elicit Better LLM Agentsより）にも示されている通りです。JSONではなくコードでアクションを記述することには、いくつかの大きな利点があります。

* **組み合わせやすさ:** アクションを容易に組み合わせたり再利用したりできます。
* **オブジェクト管理:** 画像のような複雑な構造を直接扱うことができます。
* **汎用性:** 計算可能なあらゆるタスクを表現できます。
* **LLMにとって自然な表現:** 高品質なコードは既にLLMのトレーニングデータに存在しています。


より自然で簡潔な表現にすることも可能です。例えば：

複数ステップの処理を行うエージェントでは、大規模言語モデル（LLM）は通常、外部ツールの呼び出しを含むアクションを記述・実行します。従来はJSON形式でツール名と引数を指定していましたが、研究により、LLMはコードを直接扱う方が効率的であることが分かっています。smolagentsはこの点を重視しており、コードによるアクション記述は、組み合わせやすさ、複雑なデータ構造の直接処理、あらゆる計算タスクへの対応、そしてLLMのトレーニングデータとの親和性という利点をもたらします。

#### How Does a Code Agent Work?
コードエージェントの動作原理

上記の図は、ユニット1で説明したReActフレームワークに従って、CodeAgent.run() がどのように動作するかを示しています。smolagentsにおけるエージェントの主要な抽象概念は `MultiStepAgent` であり、これは中心的な構成要素として機能します。後述の例で見るように、CodeAgentはMultiStepAgentの特殊な種類です。

CodeAgentは、既存の変数と知識がエージェントのコンテキストに組み込まれる一連のステップを通してアクションを実行します。このコンテキストは実行ログに保持されます。

1. システムプロンプトは `SystemPromptStep` に格納され、ユーザーのクエリは `TaskStep` に記録されます。
2. 次に、以下のwhileループが実行されます。
   2.1 `agent.write_memory_to_messages()` メソッドは、エージェントのログをLLMが読めるチャットメッセージのリストに書き込みます。
   2.2 これらのメッセージはモデルに送信され、モデルは補完を生成します。
   2.3 補完が解析され、アクションが抽出されます。CodeAgentを使用しているため、このアクションはコードスニペットである必要があります。
   2.4 アクションが実行されます。
   2.5 結果はActionStepのメモリに記録されます。
3. 各ステップの最後に、エージェントに何らかの関数呼び出し（agent.step_callback内）が含まれている場合、それらが実行されます。

#### Let’s See Some Examples
Google Colab で [ノートブック](https://huggingface.co/agents-course/notebooks/blob/main/unit2/smolagents/code_agents.ipynb) を実行できるらしい
smolagents のインストールと [Serverless Inference API](https://huggingface.co/docs/api-inference/index) にアクセスするために、Hugging Face Hub にもログインする

```python
from huggingface_hub import notebook_login

notebook_login()
```

token 作っておいてコピペしてログインボタンを押す。
Add token as git credential? は必要なんじゃないかな？ No で進む

Serverless Inference API とは：
> Instant Access to thousands of ML Models for Fast Prototyping
> 
> Explore the most popular models for text, image, speech, and more — all with a simple API request. Build, test, and experiment without worrying about infrastructure or setup.

[Inference Playground](https://huggingface.co/models?inference=warm&other=conversational&sort=trending) もある。ここでさまざまなモデルを試すことができる

### Selecting a Playlist for the Party Using smolagents
Alfred が音楽のプレイリストを作ってくれるらしい

### Using a Custom Tool to Prepare the Menu
Menu とは食事のメニューのことらしい。ゲストのためにメニューを用意してくれる

### Using Python Imports Inside the Agent
> `smolagents`は、セキュリティのためにサンドボックス化された実行を提供する、Python コード スニペットを記述して実行するエージェントに特化しています。
> コード実行には厳格なセキュリティ対策が施されており、定義済みのセーフ リスト外のインポートはデフォルトでブロックされます。ただし、 `additional_authorized_imports` に文字列として渡すことで、追加のインポートを承認できます。

勝手にインポートされるのを防ぐために、`additional_authorized_imports` に許可するインポートを指定するってことか

> 要約すると、smolagents は Python コード スニペットを記述して実行するエージェントに特化しており、セキュリティのためにサンドボックス化された実行を提供します。ローカル言語モデルと API ベースの言語モデルの両方をサポートしているため、さまざまな開発環境に適応できます。

### Sharing Our Custom Party Preparator Agent to the Hub
Interference API にアクセスするために Hugging Face Hub にログインする


### Inspecting Our Party Preparator Agent with OpenTelemetry and Langfuse 📡
> アルフレッドはパーティー準備エージェントを微調整するうちに、そのデバッグに嫌気がさしてきた。エージェントは本質的に予測不可能で、検査が難しい。しかし、彼は究極のパーティー準備エージェントを構築し、本番環境に配備することを目指しているため、将来の監視と分析のために強固なトレーサビリティが必要です。

> 再び、smolagentsが救いの手を差し伸べる！エージェントの実行を計測するための OpenTelemetry 標準を採用し、シームレスな検査とロギングを可能にしています。Langfuse と SmolagentsInstrumentor の助けを借りて、Alfred はエージェントの動作を簡単に追跡し分析することができます。

---

> 次に、Alfred はすでに Langfuse にアカウントを作成し、API キーを準備しています。

どういうこと？

> Langfuse は、大規模言語モデル（LLM）を利用したアプリケーションのために特別に設計された、オープンソースの観測・分析プラットフォームです。私たちは、開発者や組織が LLM アプリケーションの構築や改善を支援することを目的としており、高度なトレース＆分析モジュールを通じて、モデルのコスト、品質、レイテンシに関する深い洞察を提供します。

https://langfuse.com/jp


#### Resources

---

### Writing actions as code snippets or JSON blobs
またノートブックがあるよ

#### How Do Tool Calling Agents Work?
> 主な違いは、アクションの構造化方法にあります。実行可能コードの代わりに、ツール名と引数を指定する JSON オブジェクトを生成します。システムはこれらの命令を解析して、適切なツールを実行します。

ツール呼び出しのためのエージェントが、ツールが理解できるような JSON オブジェクトを生成するってことか

#### Example: Running a Tool Calling Agent
[ノートブック](https://huggingface.co/agents-course/notebooks/blob/main/unit2/smolagents/tool_calling_agents.ipynb) でも試すことができる

> The only difference is the agent type - the framework handles everything else:

さっきは Alfred 君がパーティーの準備をしてくれるエージェントを作っていたけど、今度はいろんなことを汎用的に処理できるエージェントを使う。それが `ToolCallingAgents` だってｺﾄ？
さっきは `CodeAgents` にツールを渡していたが、その名の通りの `ToolCallingAgents` に渡す。

> When you examine the agent's trace, instead of seeing Executing parsed code:, you'll see something like:

```
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Calling tool: 'web_search' with arguments: {'query': "best music recommendations for a party at Wayne's         │
│ mansion"}                                                                                                       │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

さっきは `Executing parsed code...` という agents の実行のトレースが表示されていたが、今回はこのように表示されている。


> エージェントは、 CodeAgent のようなコードを直接実行するのではなく、システムが処理して出力を生成する構造化されたツール呼び出しを生成します。

> エージェントのタイプを理解できたので、ニーズに合ったものを選択できます。smolagentsアルフレッドのパーティーを成功させるために、引き続き探索してみましょう! 🎉


#### Resources

---

### Tools
https://huggingface.co/learn/agents-course/unit2/smolagents/tools

このテキストは、smolagentsというフレームワークでLLM（大規模言語モデル）がツールを利用する方法について説明しています。

**主な内容:**

* **ツールの定義方法:**  シンプルな関数ベースのツールには`@tool`デコレータを使用し、複雑なツールには`Tool`クラスを継承します。どちらの方法も、LLMがツールを理解するために必要な情報（名前、説明、入力・出力タイプなど）を指定します。具体的な例として、ケータリングサービス検索ツールやスーパーヒーローをテーマにしたパーティーテーマ生成ツールが挙げられています。

* **デフォルトツールボックス:** smolagentsには、`PythonInterpreterTool`, `FinalAnswerTool`, `UserInputTool`, `DuckDuckGoSearchTool`, `GoogleSearchTool`, `VisitWebpageTool`などのあらかじめ用意されたツールが用意されています。

* **ツールの共有とインポート:** 作成したカスタムツールをHugging Face Hubで共有したり、Hub、HF Spaces、LangChain、MCPサーバーからツールをインポートして使用できます。これにより、コミュニティで作成されたツールを簡単に利用できます。  例として、画像生成ツールやエンターテインメント検索ツールのインポート方法が示されています。


要するに、smolagentsはLLMを様々なツールと連携させることで、より高度なタスクを実行可能にするフレームワークであり、そのツールの作成、共有、利用方法について解説しているドキュメントです。

#### Tool Creation Methods
In smolagents, tools can be defined in two ways:

1. Using the @tool decorator for simple function-based tools
2. Creating a subclass of Tool for more complex functionality

##### The @tool Decorator
Using this approach, we define a function with:

- A clear and descriptive function name that helps the LLM understand its purpose.
- Type hints for both inputs and outputs to ensure proper usage.
- A detailed description, including an Args: section where each argument is explicitly described. These descriptions provide valuable context for the LLM, so it’s important to write them carefully.

###### Generating a tool that retrieves the highest-rated catering
##### Defining a Tool as a Python Class
###### Generating a tool to generate ideas about the superhero-themed party
#### Default Toolbox
#### Sharing and Importing Tools
> スモルエージェントの最も強力な機能の1つは、ハブでカスタムツールを共有し、コミュニティが作成したツールをシームレスに統合できることです。これには、HF SpacesおよびLangChainツールとの接続が含まれ、ウェインマナーでの忘れられないパーティーを指揮するアルフレッドの能力が大幅に向上します。🎭

##### Sharing a Tool to the Hub
##### Importing a Tool from the Hub
##### Importing a Hugging Face Space as a Tool
##### Importing a LangChain Tool
##### Importing a tool collection from any MCP Server
MCP 来ました！これ前まではなかったような気もする？


#### Resources

---

### Retrieval Agents
https://huggingface.co/learn/agents-course/unit2/smolagents/retrieval_agents

このドキュメントは、エージェント型RAG（Retrieval-Augmented Generation）システムの構築方法について解説しています。従来のRAGシステムは検索結果に基づいてLLMが回答を生成するのに対し、エージェント型RAGは検索と生成のプロセスをインテリジェントに制御することで、効率と精度を向上させます。

主なハイライトは以下の通りです。

* **エージェント型RAGの利点:** 従来のRAGシステムの限界（単一の検索ステップ、クエリとの直接的な意味的類似性に依存）を克服し、エージェントが自律的に検索クエリを生成、検索結果を評価、複数回の検索を実行することで、より適切で包括的な出力を生成します。
* **DuckDuckGoを用いた基本的な検索:**  `smolagents`ライブラリを用いて、DuckDuckGoでWeb検索を行い、情報を取得して回答を生成するシンプルなエージェントの構築方法を例示しています。
* **カスタム知識ベースツール:** 特定のタスク向けに、ベクトルデータベースを用いたカスタム知識ベースツールを作成する方法を解説しています。意味検索を用いて関連性の高い情報を取得し、事前定義された知識と組み合わせて文脈に応じた解決策を提供します。BM25 retrieverとRecursiveCharacterTextSplitterを用いた具体的な実装例も示されています。
* **高度な検索機能:**  クエリ再構成、複数ステップ検索、ソース統合、結果検証など、エージェント型RAGシステムで利用可能な高度な検索戦略を紹介しています。
* **エージェント型RAGシステム構築の重要な側面:**  クエリの種類とコンテキストに基づいたツール選択、会話履歴を保持するためのメモリシステム、フォールバック戦略、取得情報の検証の重要性を説明しています。

要するに、このドキュメントは、`smolagents`ライブラリを活用して、より高度で柔軟な情報検索と回答生成を実現するエージェント型RAGシステムの構築方法を、具体的なコード例とともに解説しています。

#### Basic Retrieval with DuckDuckGo
#### Custom Knowledge Base Tool
#### Enhanced Retrieval Capabilities
#### Resources

### Multi-Agent Systems
https://huggingface.co/learn/agents-course/unit2/smolagents/multi_agent_systems

#### Multi-Agent Systems in Action
#### Solving a complex task with a multi-agent hierarchy
##### We first make a tool to get the cargo plane transfer time.
##### Setting up the agent
##### ✌️ Splitting the task between two agents

#### Resources
