---
title: "Hugging Face Agents Course Unit2.2 - The LlamaIndex Framework"
date: "2025-04-13 11:41:32 +0900"
last_modified_at: "2025-04-13 11:41:32 +0900"
---

# Hugging Face Agents Course Unit2.2 - The LlamaIndex Framework
## Introduction to LlamaIndex
コースでは、LlamaIndexのエージェント構築における主要な3つの要素、**コンポーネント、エージェントとツール、ワークフロー**に焦点を当てています。

* **コンポーネント:** プロンプト、モデル、データベースなど、LlamaIndexの基本的な構成要素。他のツールやライブラリとの接続を支援します。
* **ツール:** 検索、計算、外部サービスへのアクセスなど、特定の機能を提供するコンポーネント。エージェントがタスクを実行するための構成要素です。
* **エージェント:** ツールを使用し、意思決定を行う自律的なコンポーネント。複雑な目標を達成するためにツールの使用を調整します。
* **ワークフロー:** 論理を処理する段階的なプロセス。エージェントを明示的に使用せずにエージェントの動作を構築する方法です。

LlamaIndexの特徴としては、明確なワークフローシステム、LlamaParseによる高度なドキュメント解析、多くのすぐに使えるコンポーネント、そして様々なコンポーネントやエージェント、ツールを利用できるLlamaHubなどが挙げられます。

コースではこれらの概念を詳細に解説し、最終的には学んだことを応用して、エージェントAlfredを使ったユースケースを作成します。

### What Makes LlamaIndex Special?
- Clear Workflow System: Workflows help break down how agents should make decisions step by step using an event-driven and async-first syntax. This helps you clearly compose and organize your logic.
- 明確なワークフローシステム: ワークフローは、イベント駆動型で非同期ファーストの構文を使用して、エージェントが段階的に意思決定を行う方法を分解するのに役立ちます。これにより、ロジックを明確に構成し、整理することができます。
- Advanced Document Parsing with LlamaParse: LlamaParse was made specifically for LlamaIndex, so the integration is seamless, although it is a paid feature.
- LlamaParse による高度なドキュメント解析: LlamaParse は LlamaIndex 専用に作成されたため、有料の機能ですが、統合はシームレスです。
- Many Ready-to-Use Components: LlamaIndex has been around for a while, so it works with lots of other frameworks. This means it has many tested and reliable components, like LLMs, retrievers, indexes, and more.
- すぐに使える多くのコンポーネント: LlamaIndex はしばらく前から存在していたため、他の多くのフレームワークで動作します。これは、LLM、レトリーバー、インデックスなど、テスト済みの信頼性の高いコンポーネントが多数あることを意味します。
- LlamaHub: is a registry of hundreds of these components, agents, and tools that you can use within LlamaIndex.
- LlamaHub:LlamaIndex内で使用できる何百ものこれらのコンポーネント、エージェント、およびツールのレジストリです。
- このドキュメントは、LlamaIndexを使ったLLM搭載エージェント構築コースの導入部分です。LlamaIndexは、インデックスとワークフローを用いてデータ上でLLMエージェントを作成するためのツールキットです。

## Introduction to LlamaHub
LlamaIndexの統合、エージェント、ツールを管理するLlamaHubの使い方について説明されています。

- インストールは`pip install llama-index-<component>`の形式で行います。LLMと埋め込みコンポーネントをHugging Face inference API経由で使う場合、`pip install llama-index-llms-huggingface-api llama-index-embeddings-huggingface`と実行します。
- インストール後は、インストールコマンドに似たパスでインポートできます。Hugging Face inference APIを使ったLLMの例では、`from llama_index.llms.huggingface_api import HuggingFaceInferenceAPI`のようにインポートし、`HF_TOKEN`などの設定を行い利用します。

つまり、LlamaHubから必要なコンポーネントを探し、上記手順でインストール、そして利用することで、LlamaIndexを拡張できます。この説明を元に、独自のAgentを構築するためのコンポーネント利用に進みます。

### Installation
```sh
# こういう形でインストールする
pip install llama-index-{component-type}-{framework-name}
# 例えば、Hugging Face inference APIを使ったLLMと埋め込みコンポーネントをインストールする場合
pip install llama-index-llms-huggingface-api llama-index-embeddings-huggingface
```

### Usage

## What are components in LlamaIndex?
LlamaIndexのコンポーネント、特にQueryEngineを中心としたRAG（Retrieval-Augmented Generation）ツールとしての活用方法を解説した内容です。

**LlamaIndexのコンポーネントとRAG**

LLMは広範な知識を持つ一方、特定の最新データには精通していない場合があります。RAGは、関連情報を外部データから取得しLLMに提供することでこの問題を解決します。LlamaIndexのQueryEngineは、このRAGを実現する主要コンポーネントです。

**RAGパイプラインの作成手順**

1. **読み込み (Loading):**  SimpleDirectoryReader、LlamaParse、LlamaHubなどを用いて、様々なソースからデータを読み込みます。
2. **インデックス化 (Indexing):** SentenceSplitterで文章を分割し、HuggingFaceEmbeddingなどでベクトル埋め込みを作成、意味を数値化します。
3. **保存 (Storing):** ChromaDBなどのベクトルストアにインデックスを保存します。
4. **クエリ (Querying):** `as_query_engine` などを用いてクエリインターフェースに変換し、LLMと組み合わせて回答を生成します。 `refine`, `compact`, `tree_summarize` などの応答合成戦略を選択できます。
5. **評価 (Evaluation):** FaithfulnessEvaluator、AnswerRelevancyEvaluator、CorrectnessEvaluatorなどを用いて、回答の品質を評価します。LlamaTraceによるオブザーバビリティも利用可能です。

**その他**

* IngestionPipeline を使用することで、データの読み込み、分割、埋め込み、ベクトルストアへの保存を効率的に行えます。
* ワークフローの構築や、低レベルAPIによるきめ細かい制御も可能です。


要約すると、LlamaIndexのコンポーネントを活用することで、外部データソースから情報を取得し、LLMを用いて高品質な回答を生成するRAGパイプラインを構築できます。

### Creating a RAG pipeline using components
#### Loading and embedding documents
データを読み込む最も簡単な方法は、SimpleDirectoryReader を使用することです。 この汎用性の高いコンポーネントは、フォルダーからさまざまな種類のファイルを読み込み、それらを LlamaIndex が操作できるドキュメント オブジェクトに変換できます。

```python
from llama_index.core import SimpleDirectoryReader

reader = SimpleDirectoryReader(input_dir="path/to/directory")
documents = reader.load_data()
```

ドキュメントを読み込んだ後、それらをノードオブジェクトと呼ばれる小さな部分に分割する必要があります。 ノードは、AIが操作しやすいように元のドキュメントのテキストのチャンクにすぎませんが、元のDocumentオブジェクトへの参照は残っています。

IngestionPipeline は、2 つの主要な変換を通じてこれらのノードを作成するのに役立ちます。

1. SentenceSplitterは、自然な文の境界でドキュメントを分割することにより、ドキュメントを管理可能なチャンクに分割します。
2. HuggingFaceEmbeddingは、各チャンクを数値エンベッディング(AIが効率的に処理できる方法で意味的な意味を捉えるベクトル表現)に変換します。

```python
from llama_index.core import Document
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.core.node_parser import SentenceSplitter
from llama_index.core.ingestion import IngestionPipeline

# create the pipeline with transformations
pipeline = IngestionPipeline(
    transformations=[
        SentenceSplitter(chunk_overlap=0),
        HuggingFaceEmbedding(model_name="BAAI/bge-small-en-v1.5"),
    ]
)

nodes = await pipeline.arun(documents=[Document.example()])
```


#### Storing and indexing documents
わざわざインデックスを再作成しなくていいように、保存しておく必要がある。ChromaDB というものを使う

```python
import chromadb
from llama_index.vector_stores.chroma import ChromaVectorStore

db = chromadb.PersistentClient(path="./alfred_chroma_db")
chroma_collection = db.get_or_create_collection("alfred")
vector_store = ChromaVectorStore(chroma_collection=chroma_collection)

pipeline = IngestionPipeline(
    transformations=[
        SentenceSplitter(chunk_size=25, chunk_overlap=0),
        HuggingFaceEmbedding(model_name="BAAI/bge-small-en-v1.5"),
    ],
    vector_store=vector_store,
)
```

ここでベクトル埋め込みの出番です - クエリとノードの両方を同じベクトル空間に埋め込むことで、関連する一致を見つけることができます。 VectorStoreIndex は、インジェスト時に使用したのと同じ埋め込みモデルを使用して一貫性を確保し、これを処理します。

このインデックスをベクターストアと埋め込みから作成する方法を見てみましょう。

```python
from llama_index.core import VectorStoreIndex
from llama_index.embeddings.huggingface import HuggingFaceEmbedding

embed_model = HuggingFaceEmbedding(model_name="BAAI/bge-small-en-v1.5")
index = VectorStoreIndex.from_vector_store(vector_store, embed_model=embed_model)
```

#### Querying a VectorStoreIndex with prompts and LLMs
index をクエリインターフェースに変換する

```python
from llama_index.llms.huggingface_api import HuggingFaceInferenceAPI

llm = HuggingFaceInferenceAPI(model_name="Qwen/Qwen2.5-Coder-32B-Instruct")
query_engine = index.as_query_engine( # クエリエンジンに変換
    llm=llm,
    response_mode="tree_summarize",
)
query_engine.query("What is the meaning of life?")
# The meaning of life is 42
```

#### Response Processing
内部的には、クエリ エンジンは LLM を使用して質問に答えるだけでなく、応答を処理するための戦略として `ResponseSynthesizer` も使用します。 繰り返しになりますが、これは完全にカスタマイズ可能ですが、箱から出してすぐにうまく機能する3つの主要な戦略があります。

- refine: create and refine an answer by sequentially going through each retrieved text chunk. This makes a separate LLM call per Node/retrieved chunk.
- 絞り込み: 取得した各テキスト チャンクを順番に調べて、回答を作成および絞り込みます。これにより、ノード/取得チャンクごとに個別の LLM 呼び出しが行われます。
- compact (default): similar to refining but concatenating the chunks beforehand, resulting in fewer LLM calls.
- compact (デフォルト): 精製に似ていますが、事前にチャンクを連結するため、LLM 呼び出しが少なくなります。
- tree_summarize: create a detailed answer by going through each retrieved text chunk and creating a tree structure of the answer.
- tree_summarize:取得した各テキストチャンクを調べ、回答のツリー構造を作成することにより、詳細な回答を作成します。

#### Evaluation and observability
```python
from llama_index.core.evaluation import FaithfulnessEvaluator

query_engine = # from the previous section
llm = # from the previous section

# query index
evaluator = FaithfulnessEvaluator(llm=llm)
response = query_engine.query(
    "What battles took place in New York City in the American Revolution?"
)
# 忠実性の評価
eval_result = evaluator.evaluate_response(response=response)
eval_result.passing
```

直接的な評価を行うこともできますが、LlamaTraceを使用して、エージェントのパフォーマンスを観察し、分析することもできます。LlamaTraceは、LlamaIndexのオブザーバビリティツールであり、アプリケーションのパフォーマンスを監視し、分析するための強力なツールです。

```python
import llama_index
import os

PHOENIX_API_KEY = "<PHOENIX_API_KEY>"
os.environ["OTEL_EXPORTER_OTLP_HEADERS"] = f"api_key={PHOENIX_API_KEY}"
llama_index.core.set_global_handler(
    "arize_phoenix",
    endpoint="https://llamatrace.com/v1/traces"
)
```

コンポーネントを使用して QueryEngine を作成する方法を見てきました。それでは、QueryEngineをエージェントのツールとして使用する方法を見てみましょう。

## Using Tools in LlamaIndex
LlamaIndexにおけるツールとエージェントの基本的な使い方をまとめます。

ツールはLLMが効果的にタスクを実行するために重要で、LlamaIndexでは4つの主要なツールタイプがあります。

* **FunctionTool:** 任意のPython関数をツール化し、エージェントが使用できるようにします。関数の動作を自動的に理解します。名前と説明を付与することで、エージェントがツールを適切に使用できるようガイドします。
* **QueryEngineTool:** エージェントがクエリエンジンを使用するためのツール。エージェント自体がクエリエンジン上に構築されているため、他のエージェントをツールとして使用することも可能です。
* **Toolspecs:** コミュニティによって作成されたツールセット。Gmailなどの特定サービス用のツールが含まれることが多いです。Google Toolspecのインストール方法や、LlamaHub上のMCPツール利用についても言及されています。
* **Utility Tools:**  他のツールからの大量のデータを処理するのに役立つ特殊なツール。`OnDemandToolLoader` はLlamaIndexデータローダーをツール化し、`LoadAndSearchToolSpec` は既存のツールを入力として受け取り、ロードツールと検索ツールを生成します。

ツールは名前と説明が重要で、LLMの関数呼び出しに大きく影響します。また、Toolspecsは特定の目的に関連するツールを組み合わせたもので、効率的な作業を可能にします。過剰なデータ取得を避けるためのユーティリティツールも用意されています。

### Creating a FunctionTool

> A FunctionTool provides a simple way to wrap any Python function and make it available to an agent. You can pass either a synchronous or asynchronous function to the tool, along with optional name and description parameters. The name and description are particularly important as they help the agent understand when and how to use the tool effectively. Let’s look at how to create a FunctionTool below and then call it.

> Pythonの関数を簡単にAgentで使えやすくするのに、FunctionToolが役立つんだ。同期関数でも非同期関数でも使えるし、名前とか説明も付けられるよ。名前と説明は、Agentがツールをいつどうやって使うか理解するのにすごく重要なんだ。じゃあ、FunctionToolの作り方と使い方を見てみよう。


```python
from llama_index.core.tools import FunctionTool

def get_weather(location: str) -> str:
    """Useful for getting the weather for a given location."""
    print(f"Getting weather for {location}")
    return f"The weather in {location} is sunny"

tool = FunctionTool.from_defaults(
    get_weather,
    name="my_weather_tool",
    description="Useful for getting the weather for a given location.",
)
tool.call("New York")
```

こうしてみるとただ単に関数をコールバック関数のようなものとして使っているだけっぽい？その分開発者にはわかりやすいのかもしれない。
Function Calling のリンクも紹介されているが、これがそうなのか？

### Creating a QueryEngineTool
前のユニットでも作った　`QueryEngine` をツールとして使うようにする
エージェントがクエリエンジンを使用するためのツール

```python
from llama_index.core import VectorStoreIndex
from llama_index.core.tools import QueryEngineTool
from llama_index.llms.huggingface_api import HuggingFaceInferenceAPI
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.vector_stores.chroma import ChromaVectorStore

embed_model = HuggingFaceEmbedding("BAAI/bge-small-en-v1.5")

db = chromadb.PersistentClient(path="./alfred_chroma_db")
chroma_collection = db.get_or_create_collection("alfred")
vector_store = ChromaVectorStore(chroma_collection=chroma_collection)

index = VectorStoreIndex.from_vector_store(vector_store, embed_model=embed_model)

llm = HuggingFaceInferenceAPI(model_name="Qwen/Qwen2.5-Coder-32B-Instruct")
# インデックスからクエリエンジンを作成
query_engine = index.as_query_engine(llm=llm)
# 前のユニットでも作った　`QueryEngine` をツールとして使うようにする
tool = QueryEngineTool.from_defaults(query_engine, name="some useful name", description="some useful description")
```

### Creating Toolspecs
これはツールセットなのだな。以下の例では `GmailToolSpec` を使っているが、他にも色々なツールがあるようだ。

```python
from llama_index.tools.google import GmailToolSpec

tool_spec = GmailToolSpec()
tool_spec_list = tool_spec.to_tool_list()
```

#### Model Context Protocol (MCP) in LlamaIndex
今話題の MCP も使えるよ！クライアントを tool spec に渡して MCP tool を作成する。それをエージェントが使用することができる

```python
from llama_index.tools.mcp import BasicMCPClient, McpToolSpec

# We consider there is a mcp server running on 127.0.0.1:8000, or you can use the mcp client to connect to your own mcp server.
mcp_client = BasicMCPClient("http://127.0.0.1:8000/sse")
mcp_tool = McpToolSpec(client=mcp_client)

# get the agent
agent = await get_agent(mcp_tool)

# create the agent context
agent_context = Context(agent)
```

### Utility Tools
多くの場合、API に直接クエリを実行すると、大量のデータが返され、その一部が無関係であったり、LLM のコンテキスト ウィンドウがオーバーフローしたり、使用しているトークンの数が不必要に増加したりすることがあります。 以下の2つの主要なユーティリティツールを見ていきましょう。

1. `OnDemandToolLoader`: このツールは、既存の LlamaIndex データ ローダー (BaseReader クラス) をエージェントが使用できるツールに変換します。このツールは、データローダからのload_dataをトリガするために必要なすべてのパラメータと、自然言語クエリ文字列を使用して呼び出すことができます。実行中、最初にデータローダーからデータを読み込み、インデックスを付け(たとえばベクトルストアを使用)、次に「オンデマンド」でクエリを実行します。これら 3 つのステップはすべて、1 つのツールコールで実行されます。
2. `LoadAndSearchToolSpec`: LoadAndSearchToolSpec は、既存のツールを入力として受け取ります。ツール仕様として、to_tool_listを実装し、その関数が呼び出されると、読み込みツールと検索ツールの 2 つのツールが返されます。ロードツールの実行は基になるツールを呼び出し、インデックスは出力を呼び出します(デフォルトではベクトルインデックスを使用)。検索ツールの実行では、クエリ文字列を入力として受け取り、基になるインデックスを呼び出します。

## Quick Quiz 1
tool の name, description はオプショナル。function は必須

## Using Agents in LlamaIndex
Function Calling や ReAct の話が出てくる

LlamaIndexにおけるエージェントの使い方についてまとめます。

エージェントはユーザー定義の目標を達成するために、AIモデルを活用して環境と対話するシステムです。推論、計画、行動実行を組み合わせてタスクを実行します。LlamaIndexは主に3種類のエージェントをサポートしています。関数呼び出しエージェント、ReActエージェント、そして高度なカスタムエージェントです。

エージェントの作成は、機能/ツールを定義することから始まります。ツール/関数APIをサポートするLLMは、特定のプロンプトを回避し、提供されたスキーマに基づいてツール呼び出しを作成できるため強力です。ReActエージェントは複雑な推論タスクに優れており、チャットまたはテキスト補完機能を持つLLMで使用できます。より冗長で、特定のアクションの背後にある推論を示します。

エージェントはデフォルトでは状態を持たないため、過去の対話を記憶するにはContextオブジェクトを使用します。これは、複数メッセージにわたるコンテキストを維持するチャットボットや、時間の経過に伴う進捗状況を追跡する必要があるタスクマネージャーのような、以前の対話を記憶する必要があるエージェントに役立ちます。

エージェントはPythonのawait演算子を使用するため非同期です。

RAGエージェントの作成では、クエリエンジンをツールとしてエージェントに渡すことができます。`QueryEngineTool`を使用してクエリエンジンをラップし、名前と説明を定義します。LLMはこの情報を使用してツールを正しく使用します。

マルチエージェントシステムもサポートされています。各エージェントに名前と説明を与えることで、システムは単一のアクティブスピーカーを維持し、各エージェントは別のエージェントに処理を引き渡すことができます。各エージェントの範囲を絞ることで、ユーザーメッセージへの応答時の全体的な精度を高めることができます。LlamaIndexのエージェントは、他のエージェントのツールとして直接使用することもできます。

さらに詳しい情報は、AgentWorkflow Basic IntroductionまたはAgent Learning Guideで、ストリーミング、コンテキストのシリアル化、Human-in-the-loopなどについて学ぶことができます。

### Initialising Agents

```python
from llama_index.llms.huggingface_api import HuggingFaceInferenceAPI
from llama_index.core.agent.workflow import AgentWorkflow
from llama_index.core.tools import FunctionTool

# define sample Tool -- type annotations, function names, and docstrings, are all included in parsed schemas!
def multiply(a: int, b: int) -> int:
    """Multiplies two integers and returns the resulting integer"""
    return a * b

# initialize llm
llm = HuggingFaceInferenceAPI(model_name="Qwen/Qwen2.5-Coder-32B-Instruct")

# initialize agent
agent = AgentWorkflow.from_tools_or_functions(
    [FunctionTool.from_defaults(multiply)],
    llm=llm
)
```

> ツール/関数APIをサポートするLLMは比較的新しいですが、特定のプロンプトを回避し、提供されたスキーマに基づいてLLMがツール呼び出しを作成できるようにすることで、ツールを呼び出す強力な方法を提供します。

あえて使い方や目的を限定するのがコツかなあ

### Creating RAG Agents with QueryEngineTools
> クエリエンジンをエージェントのツールとして組み込むのは簡単だよ。その際、名前と説明を定義する必要があるんだ。LLMは、この情報を使ってツールを正しく使うからね。コンポーネントのセクションで作成したクエリエンジンを使って、クエリエンジツールを読み込む方法を見てみよう。

name, description はオプショナルではないのか？

```python
from llama_index.core.tools import QueryEngineTool

query_engine = index.as_query_engine(llm=llm, similarity_top_k=3) # as shown in the Components in LlamaIndex section

query_engine_tool = QueryEngineTool.from_defaults(
    query_engine=query_engine,
    name="name",
    description="a specific description",
    return_direct=False,
)
query_engine_agent = AgentWorkflow.from_tools_or_functions(
    [query_engine_tool],
    llm=llm,
    system_prompt="You are a helpful assistant that has access to a database containing persona descriptions. "
)
```

### Creating Multi-agent systems

```python
from llama_index.core.agent.workflow import (
    AgentWorkflow,
    FunctionAgent,
    ReActAgent,
)

# Define some tools
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b


def subtract(a: int, b: int) -> int:
    """Subtract two numbers."""
    return a - b


# Create agent configs
# NOTE: we can use FunctionAgent or ReActAgent here.
# FunctionAgent works for LLMs with a function calling API.
# ReActAgent works for any LLM.
calculator_agent = ReActAgent(
    name="calculator",
    description="Performs basic arithmetic operations",
    system_prompt="You are a calculator assistant. Use your tools for any math operation.",
    tools=[add, subtract],
    llm=llm,
)

query_agent = ReActAgent(
    name="info_lookup",
    description="Looks up information about XYZ",
    system_prompt="Use your tool to query a RAG system to answer information about XYZ",
    tools=[query_engine_tool],
    llm=llm
)

# Create and run the workflow
# ここで複数のエージェントを渡してやる
agent = AgentWorkflow(
    agents=[calculator_agent, query_agent], root_agent="calculator"
)

# Run the system
response = await agent.run(user_msg="Can you add 5 and 3?")
```

## Creating agentic workflows in LlamaIndex
LlamaIndexのワークフローとエージェントの使い方を簡潔にまとめます。

**ワークフロー:**

* コードをステップに分割し、イベント駆動で実行することで、複雑な処理を整理できます。
* `@step`デコレータで関数をステップとして定義し、`StartEvent`、`StopEvent`、カスタムイベントで処理の流れを制御します。
* 型ヒントを利用することで、ループや分岐を含む複雑なワークフローも構築可能です。
* `draw_all_possible_flows`関数でワークフローを図示化できます。
* `Context`を使ってワークフロー内で状態を共有できます。

**マルチエージェントワークフロー:**

* `AgentWorkflow`クラスを使って、複数のエージェントが協調してタスクを実行するワークフローを自動的に作成できます。
* 各エージェントは、リクエストを直接処理したり、他のエージェントにタスクを委任したり、ユーザーに応答を返したりできます。
* ルートエージェントを指定し、ユーザーメッセージは最初にルートエージェントに送られます。
* エージェントは`Context`を通じてワークフローの状態を変更できます。
* `initial_state`と`state_prompt`を使用して、ワークフローの状態を管理し、エージェントに情報を提供できます。


これらの機能を使うことで、複雑なRAGタスクやマルチエージェントシステムを効率的に構築できます。より詳細な情報はLlamaIndexのドキュメントを参照してください。

### Creating Workflows
#### Basic Workflow Creation
#### Connecting Multiple Steps

```python
from llama_index.core.workflow import Event

class ProcessingEvent(Event):
    intermediate_result: str

class MultiStepWorkflow(Workflow):
    @step
    async def step_one(self, ev: StartEvent) -> ProcessingEvent:
        # Process initial data
        return ProcessingEvent(intermediate_result="Step 1 complete")

    @step
    async def step_two(self, ev: ProcessingEvent) -> StopEvent:
        # Use the intermediate result
        final_result = f"Finished processing: {ev.intermediate_result}"
        return StopEvent(result=final_result)

w = MultiStepWorkflow(timeout=10, verbose=False)
result = await w.run()
result
```

ここで型ヒントがあると便利やね

#### Loops and Branches

```python
from llama_index.core.workflow import Event
import random


class ProcessingEvent(Event):
    intermediate_result: str


class LoopEvent(Event):
    loop_output: str


class MultiStepWorkflow(Workflow):
    @step
    async def step_one(self, ev: StartEvent | LoopEvent) -> ProcessingEvent | LoopEvent:
        if random.randint(0, 1) == 0:
            print("Bad thing happened")
            return LoopEvent(loop_output="Back to step one.")
        else:
            print("Good thing happened")
            return ProcessingEvent(intermediate_result="First step complete.")

    @step
    async def step_two(self, ev: ProcessingEvent) -> StopEvent:
        # Use the intermediate result
        final_result = f"Finished processing: {ev.intermediate_result}"
        return StopEvent(result=final_result)


w = MultiStepWorkflow(verbose=False)
result = await w.run()
result
```

先ほどとの違いは step_one にて分岐を入れている。発行するイベントを使い分けているのか

#### Drawing Workflows
#### State Management

> 状態管理は、ワークフローの状態を追跡し、すべてのステップが同じ状態にアクセスできるようにしたい場合に便利です。これは、ステップ関数のパラメータにContext型ヒントを追加することで実現できます。

```python
from llama_index.core.workflow import Context, StartEvent, StopEvent


@step
async def query(self, ctx: Context, ev: StartEvent) -> StopEvent:
    # store query in the context
    await ctx.set("query", "What is the capital of France?")

    # do something with context and event
    val = ...

    # retrieve query from the context
    query = await ctx.get("query")

    return StopEvent(result=val)
```

### Automating workflows with Multi-Agent Workflows
これを `AgenticWorkflow` で実現する方法もある multi-agent workflow というものがある
特定の用途に特化した複数のエージェントを組み合わせて、効率的にタスクを処理することが可能です。これにより、複雑な問題を解決するための柔軟なアプローチが提供されます。

> AgentWorkflowのコンストラクタで、1つのエージェントをルートエージェントとして指定する必要があります。ユーザーメッセージが来ると、まずルートエージェントにルーティングされます。

• ツールを使用してリクエストを直接処理する
• タスクに適した別のエージェントに引き継ぐ
• ユーザーに応答を返す

```python
from llama_index.core.agent.workflow import AgentWorkflow, ReActAgent
from llama_index.llms.huggingface_api import HuggingFaceInferenceAPI

# Define some tools
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

llm = HuggingFaceInferenceAPI(model_name="Qwen/Qwen2.5-Coder-32B-Instruct")

# we can pass functions directly without FunctionTool -- the fn/docstring are parsed for the name/description
# FunctionToolは必要ないのか. 直接エージェントクラスに渡してしまえばいい。その際に名前と概要が必要になるんだろうな
multiply_agent = ReActAgent(
    name="multiply_agent",
    description="Is able to multiply two integers",
    system_prompt="A helpful assistant that can use a tool to multiply numbers.",
    tools=[multiply],
    llm=llm,
)

addition_agent = ReActAgent(
    name="add_agent",
    description="Is able to add two integers",
    system_prompt="A helpful assistant that can use a tool to add numbers.",
    tools=[add],
    llm=llm,
)

# Create the workflow
workflow = AgentWorkflow(
    agents=[multiply_agent, addition_agent],
    root_agent="multiply_agent",
)

# Run the system
response = await workflow.run(user_msg="Can you add 5 and 3?")
```

## Quick Quiz 2
