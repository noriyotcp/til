---
title: "Hugging Face Agents Course Unit 2.3 - Introduction to LangGraph"
date: "2025-04-13 16:39:28 +0900"
last_modified_at: "2025-04-13 16:39:28 +0900"
---

# Hugging Face Agents Course Unit 2.3 - Introduction to LangGraph
## Introduction to LangGraph
このコースはLangGraphを使ったAgent構築を学ぶためのものです。LangGraphとは複雑なLLMワークフローを構造化・編成するためのフレームワークです。コースでは、LangGraphの概要、構成要素、メール仕分けや文書分析のエージェント作成例などを学びます。GPT-4o APIの使用が推奨されています。LangChain academyの無料コースでより高度な内容を学ぶことも可能です。

### Module Overview
このコースはLangGraphフレームワークを使ったAgent構築について学ぶものです。LangGraphは複雑なLLMワークフローを構造化・組織化するためのフレームワークで、プロダクションレベルのアプリケーション開発を支援します。

このユニットでは、LangGraphの概要と使用場面、基本構成要素、メール仕分けや文書分析を行うAgentの例を通してLangGraphの使い方を学びます。GPT-4oを使った高度な例も含まれています。LangChain academyの無料コースでさらに高度な内容を学ぶことも可能です。

- 1️⃣ What is LangGraph, and when to use it?
- 2️⃣ Building Blocks of LangGraph
- 3️⃣ Alfred, the mail sorting butler
- 4️⃣ Alfred, the document Analyst agent
- 5️⃣ Quiz

## What is LangGraph?
LangGraphは、LLMを統合したアプリケーションの制御フローを管理するためのLangChainによって開発されたフレームワークです。LangChainはモデルや他のコンポーネントと対話するための標準インターフェースを提供しますが、LangGraphはアプリケーションのフロー制御に特化しています。両者は連携して使用されることが多いですが、それぞれ独立して使用することも可能です。

LangGraphは、特に「制御」が必要な場合に有効です。予測可能なプロセスを維持しながらLLMの能力を活用したい場合、LangGraphは必要な構造を提供します。例えば、複数のステップで構成され、各ステップで意思決定が必要なアプリケーション、状態の永続性が必要なアプリケーション、確定的なロジックとAI機能を組み合わせたシステム、人間参加型のワークフロー、複数のコンポーネントが連携する複雑なエージェントアーキテクチャなどに適しています。

LangGraphは有向グラフ構造を使用してアプリケーションのフローを定義します。ノードは個々の処理ステップを表し、エッジはステップ間の遷移を定義します。状態はユーザー定義で、実行中にノード間で受け渡されます。

LangGraphは、単純なPythonコードでif-else文を使ってフローを制御するよりも、状態管理、可視化、ロギング、人間参加機能など、複雑なシステム構築のためのツールと抽象化を提供するため、より効率的な開発を可能にします。  つまり、LangGraphはよりプロダクションレディなエージェントフレームワークと言えます。

### Is LangGraph different from LangChain ?
> LangChainは、モデルやその他のコンポーネントと対話するための標準インターフェイスを提供し、取得、LLM呼び出し、ツール呼び出しに役立ちます。 LangChain のクラスは LangGraph で使用できる場合がありますが、必ずしも使用する必要はありません。

LangChain とは違うとな
LangGraphは、アプリケーションのフロー制御に特化したフレームワークです。

### When should I use LangGraph ?
#### Control vs freedom
LangGraphは、アプリケーションの制御が必要な場合に特に役立ちます。これにより、LLM の機能を活用しながら、予測可能なプロセスに従うアプリケーションを構築するためのツールが提供されます。

freedom よりは制御が必要な場合に役立つ

LangGraphが優れている主なシナリオは次のとおりです。

Multi-step reasoning processes that need explicit control on the flow
フローの明示的な制御が必要な多段階の推論プロセス

Applications requiring persistence of state between steps
ステップ間で状態の永続性を必要とするアプリケーション

Systems that combine deterministic logic with AI capabilities
決定論的ロジックとAI機能を組み合わせたシステム

Workflows that need human-in-the-loop interventions
ヒューマンインザループの介入が必要なワークフロー

Complex agent architectures with multiple components working together
複数のコンポーネントが連携して動作する複雑なエージェントアーキテクチャ

In essence, whenever possible, as a human, design a flow of actions based on the output of each action, and decide what to execute next accordingly. In this case, LangGraph is the correct framework for you!
要するに、可能な限り、人間として、各アクションの出力に基づいてアクションの流れを設計し、それに応じて次に何を実行するかを決定するのです。この場合、LangGraphはあなたにとって正しいフレームワークです!

### How does LangGraph work ?
LangGraphは、その中核として、有向グラフ構造を使用してアプリケーションのフローを定義します。

Nodes represent individual processing steps (like calling an LLM, using a tool, or making a decision).
ノードは、個々の処理ステップ (LLM の呼び出し、ツールの使用、意思決定など) を表します。

Edges define the possible transitions between steps.
エッジは、ステップ間の可能な遷移を定義します。

State is user defined and maintained and passed between nodes during execution. When deciding which node to target next, this is the current state that we look at.
状態はユーザー定義され、維持され、実行中にノード間で渡されます。次にどのノードをターゲットにするかを決定するとき、これが私たちが見る現在の状態です。

### How is it different from regular python? Why do I need LangGraph ?
普通に Python app でもできないことはないけど、if~else ステートメントだと複雑な処理に対応できない
LangGraphは、状態管理、可視化、ロギング、人間参加機能など、複雑なシステム構築のためのツールと抽象化を提供するため、より効率的な開発を可能にします。 つまり、LangGraphはよりプロダクションレディなエージェントフレームワークと言えます。

## Building Blocks of LangGraph
LangGraphアプリケーションの構築に必要な主要コンポーネントを簡潔にまとめます。

LangGraphアプリケーションは、`State`（状態）、`Node`（ノード）、`Edge`（エッジ）、そしてこれらをまとめる`StateGraph`（状態グラフ）の4つの要素から構成されます。

* **State:** アプリケーション全体を流れる情報で、ユーザーが定義する辞書型です。意思決定に必要な全てのデータを含めるように設計する必要があります。
* **Node:** Python関数で、Stateを入力として受け取り、操作を実行し、更新されたStateを返します。LLM呼び出し、ツール呼び出し、条件分岐、ユーザー入力などを含みます。
* **Edge:** ノード同士を接続し、グラフの経路を定義します。直接的な接続と、Stateに基づいて次のノードを選択する条件付き接続があります。
* **StateGraph:** アプリケーション全体のワークフローを保持するコンテナです。ノードとエッジを追加し、コンパイルして実行します。

これらの要素を組み合わせることで、複雑なワークフローを表現し、実行することができます。例では、`START`ノードから`node_1`へ、`node_1`から`decide_mood`関数で`node_2`または`node_3`へ、そして最後に`END`ノードへと遷移するグラフが作成されています。

### 1. State

```python
from typing_extensions import TypedDict

class State(TypedDict):
    graph_state: str
```

状態はユーザー定義であるため、意思決定プロセスに必要なすべてのデータが含まれるようにフィールドを慎重に作成する必要があります。

### 2. Nodes
```python
def node_1(state):
    print("---Node 1---")
    return {"graph_state": state['graph_state'] +" I am"}

def node_2(state):
    print("---Node 2---")
    return {"graph_state": state['graph_state'] +" happy!"}

def node_3(state):
    print("---Node 3---")
    return {"graph_state": state['graph_state'] +" sad!"}
```

ノードはPython関数です。各ノード:
- Takes the state as input 状態を入力として受け取ります
- Performs some operation 何らかの操作を実行します
- Returns updates to the state 更新を状態に戻します

### 3. Edges

Edges can be:
エッジには次のものがあります。

- Direct: Always go from node A to node B
  - 直接: 常にノード A からノード B に移動します
- Conditional: Choose the next node based on the current state
  - 条件付き: 現在の状態に基づいて次のノードを選択します

```python
import random
from typing import Literal

def decide_mood(state) -> Literal["node_2", "node_3"]:
    
    # Often, we will use state to decide on the next node to visit
    user_input = state['graph_state'] 
    
    # Here, let's just do a 50 / 50 split between nodes 2, 3
    if random.random() < 0.5:

        # 50% of the time, we return Node 2
        return "node_2"
    
    # 50% of the time, we return Node 3
    return "node_3"
```

### 4. StateGraph
```python
from IPython.display import Image, display
from langgraph.graph import StateGraph, START, END

# Build graph
builder = StateGraph(State)
builder.add_node("node_1", node_1)
builder.add_node("node_2", node_2)
builder.add_node("node_3", node_3)

# Logic
builder.add_edge(START, "node_1")
# decide_mood が条件なのかなあ？ node_1 から条件によって node_2 か node_3 に行く
builder.add_conditional_edges("node_1", decide_mood)
builder.add_edge("node_2", END)
builder.add_edge("node_3", END)

# Add
graph = builder.compile()
```

### What’s Next?

## Building Your First LangGraph
このドキュメントでは、LangGraphを使ってメール処理ワークフローを構築する方法を説明しています。Alfredという執事がメールを読み、スパム分類、返信作成、Wayne氏への通知を行う例を通して、LangGraphの基本的な使い方を解説しています。

**主要なポイント:**

* **状態管理:** `EmailState`という型付き辞書でメールの状態（内容、カテゴリ、スパム判定など）を管理します。
* **ノードの実装:** 各処理（メールを読む、分類する、返信するなど）を関数として定義し、ノードとして追加します。LLM（ChatOpenAI）を使用してスパム分類や返信作成を行います。
* **条件分岐:** スパム判定に基づいて処理を分岐させるため、`route_email`関数で条件付きエッジを定義します。
* **終了状態:** ワークフローの終了地点を示すために`END`ノードを使用します。
* **グラフの構築と実行:** `StateGraph`を使ってノードとエッジを接続し、`compile()`でコンパイルした後、`invoke()`で実行します。
* **Langfuseによる監視:** ワークフローの実行状況をLangfuseで監視する方法についても触れられています。
* **グラフの可視化:** `draw_mermaid_png()`でワークフローを可視化できます。

**具体的な処理の流れ:**

1. メールを読む
2. スパムか否かを分類
3. スパムなら破棄
4. スパムでないなら返信を作成し、Wayne氏に通知

この例は、LLMを使った意思決定を含むワークフローをLangGraphで構築する方法を示しています。ツールとの連携がないためエージェントとはみなされませんが、LangGraphフレームワークの学習に重点が置かれています。Google Colabで実行可能なコードも提供されています。

これはだいぶコードが多い。テストの時、いざとなったら直接読んだほうが良さそう

### Our Workflow
### Setting Up Our Environment
### Step 1: Define Our State
### Step 2: Define Our Nodes
### Step 3: Define Our Routing Logic
### Step 4: Create the StateGraph and Define Edges
### Step 5: Run the Application
### Step 6: Inspecting Our Mail Sorting Agent with Langfuse 📡
### Visualizing Our Graph
### What We’ve Built
### Key Takeaways
### What’s Next?

## Document Analysis Graph
Alfred（執事）がWayne氏（バットマン）のドキュメント分析を支援する方法について説明されています。Alfredは、Wayne氏のトレーニング計画、食事プランなどのドキュメントを分析・整理し、必要な計算なども行います。

**Alfredのワークフロー:**

1. Wayne氏が残したメモ（画像）を受け取る。
2. LangGraphを用いたドキュメント分析システムで画像を処理。
   - Vision Language Modelでテキストを抽出。
   - 必要に応じて計算を実行。
   - 内容を分析し、簡潔な要約を提供。
   - ドキュメント関連の指示を実行。
3. ReActパターン（Reason-Act-Observe：推論-行動-観察）に従い、Wayne氏のニーズに対応。

**具体的な機能例:**

* 簡単な計算：6790 ÷ 5 のような計算を実行。
* トレーニングドキュメントの分析：Wayne氏のトレーニングと食事のメモ（画像）から必要な情報を抽出。例として、夕食の食材リストを生成。

**システム構築のポイント:**

* ドキュメント関連タスクのための明確なツールの定義。
* ツール呼び出し間のコンテキストを維持するための堅牢な状態トラッカーの作成。
* ツールの失敗に対するエラー処理。
* 以前のやり取りのコンテキスト認識の維持 (`add_messages` オペレータによって保証)。


Alfredは、これらの機能とワークフローにより、Wayne氏が必要とするドキュメント分析サービスを提供しています。

### The Butler’s Workflow
### Setting Up the environment
### Defining Agent’s State
何にせよまず状態の定義から始まる

> この状態は、これまで見てきたものよりも少し複雑です。AnyMessage はメッセージを定義する langchain のクラスで、add_messages は最新のメッセージを最新の状態で上書きするのではなく追加する演算子です。これは LangGraph の新しい概念で、状態に演算子を追加することで、それらの相互作用方法を定義できます。

```python
class AgentState(TypedDict):
    # The document provided
    input_file: Optional[str]  # Contains file path (PDF/PNG)
    messages: Annotated[list[AnyMessage], add_messages]
```

### Preparing Tools

```python
vision_llm = ChatOpenAI(model="gpt-4o")

def extract_text(img_path: str) -> str:
    """
    Extract text from an image file using a multimodal model.
    
    Master Wayne often leaves notes with his training regimen or meal plans.
    This allows me to properly analyze the contents.
    """
    all_text = ""
    try:
        # Read image and encode as base64
        # rb は Read Binary の略で、バイナリファイルを読み込むためのモード
        with open(img_path, "rb") as image_file:
            image_bytes = image_file.read()

        image_base64 = base64.b64encode(image_bytes).decode("utf-8")

        # Prepare the prompt including the base64 image data
        message = [
            HumanMessage( # このクラスがどこから来たのかわからないがメッセージを表すのだろう
                content=[
                    {
                        "type": "text",
                        "text": (
                            "Extract all the text from this image. "
                            "Return only the extracted text, no explanations."
                        ),
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/png;base64,{image_base64}"
                        },
                    },
                ]
            )
        ]

        # Call the vision-capable model
        response = vision_llm.invoke(message)

        # Append extracted text
        all_text += response.content + "\n\n"

        return all_text.strip()
    except Exception as e:
        # A butler should handle errors gracefully
        error_msg = f"Error extracting text: {str(e)}"
        print(error_msg)
        return ""

def divide(a: int, b: int) -> float:
    """Divide a and b - for Master Wayne's occasional calculations."""
    return a / b

# Equip the butler with tools
tools = [
    divide,
    extract_text
]

llm = ChatOpenAI(model="gpt-4o")
llm_with_tools = llm.bind_tools(tools, parallel_tool_calls=False)
```

### The nodes

```python
def assistant(state: AgentState):
    # System message
    textual_description_of_tool="""
extract_text(img_path: str) -> str:
    Extract text from an image file using a multimodal model.

    Args:
        img_path: A local image file path (strings).

    Returns:
        A single string containing the concatenated text extracted from each image.
divide(a: int, b: int) -> float:
    Divide a and b
"""
    image=state["input_file"]
    sys_msg = SystemMessage(content=f"You are an helpful butler named Alfred that serves Mr. Wayne and Batman. You can analyse documents and run computations with provided tools:\n{textual_description_of_tool} \n You have access to some optional images. Currently the loaded image is: {image}")

    return {
        "messages": [llm_with_tools.invoke([sys_msg] + state["messages"])],
        "input_file": state["input_file"]
    }
```

### The ReAct Pattern: How I Assist Mr. Wayne

1. Reason about his documents and requests
2. Act by using appropriate tools
3. Observe the results
4. Repeat as necessary until I’ve fully addressed his needs

```python
# The graph
builder = StateGraph(AgentState)

# Define nodes: these do the work
builder.add_node("assistant", assistant)
builder.add_node("tools", ToolNode(tools))

# Define edges: these determine how the control flow moves
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    # If the latest message requires a tool, route to tools
    # Otherwise, provide a direct response
    tools_condition,
)
builder.add_edge("tools", "assistant")
react_graph = builder.compile()

# Show the butler's thought process
display(Image(react_graph.get_graph(xray=True).draw_mermaid_png()))
```

We connect the tools node back to the assistant, forming a loop.

- After the assistant node executes, tools_condition checks if the model’s output is a tool call.
- If it is a tool call, the flow is directed to the tools node.
- The tools node connects back to assistant.
- This loop continues as long as the model decides to call tools.
- If the model response is not a tool call, the flow is directed to END, terminating the process.

### The Butler in Action
#### Example 1: Simple Calculations

```python
messages = [HumanMessage(content="Divide 6790 by 5")]
messages = react_graph.invoke({"messages": messages, "input_file": None})

# Show the messages
for m in messages['messages']:
    m.pretty_print()
```

#### Example 2: Analyzing Master Wayne’s Training Documents
```python
messages = [HumanMessage(content="According to the note provided by Mr. Wayne in the provided images. What's the list of items I should buy for the dinner menu?")]
messages = react_graph.invoke({"messages": messages, "input_file": "Batman_training_and_meals.png"})
```

### Key Takeaways
1. Define clear tools for specific document-related tasks
2. Create a robust state tracker to maintain context between tool calls
3. Consider error handling for tools fails
4. Maintain contextual awareness of previous interactions (ensured by the operator add_messages)
