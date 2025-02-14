---
title: "huggingface の Agents Course"
date: "2025-02-11 10:03:40 +0900"
last_modified_at: "2025-02-11 10:03:40 +0900"
---

# huggingface の Agents Course
2/10 から開講している  

certification process の締切は 5/1 まで


各章は週に３、4時間が目安  

https://huggingface.co/learn/agents-course/unit0/introduction


Hugging Faceが提供するこの無料AIエージェントコースは、AIエージェントの理論、設計、実践を網羅した包括的な学習プログラムです。  コースは、基礎的な概念から高度な応用まで段階的に進んでおり、初心者でも理解しやすいように設計されています。

**コースの主な内容:**

* **基礎ユニット:** AIエージェントの基本概念（ツール、思考、行動、観測とそのフォーマット、LLM、メッセージ、特殊トークン、チャットテンプレートなど）を解説します。Python関数を使ったシンプルなユースケースも含まれます。
* **フレームワーク:**  smolagents、LangGraph、LlamaIndexといった主要なAIエージェントライブラリの使用方法を学びます。
* **実践演習:**  Hugging Face Spaces上で事前に設定された環境を利用して、実際のAIエージェントを構築・訓練します。
* **ユースケース課題:**  学習した概念を応用し、現実世界の課題を解決するAIエージェントを構築します。
* **最終課題:**  選定されたベンチマークに対してエージェントを構築し、他の受講者と競争します。リーダーボードでの成績によって評価されます。
* **認定取得:**  コースの修了状況に応じて、基礎認定または修了認定を取得できます。基礎認定はユニット1の完了で、修了認定はユニット1、ユースケース課題1つ、最終課題の完了で取得可能です。認定取得期限は2025年5月1日です。


**学習環境とサポート:**

* **Discordサーバー:**  他の受講者や講師と交流し、質問や議論を行うことができます。
* **GitHub:**  コース内容のバグ報告や改善提案を行うことができます。
* **Hugging Faceアカウント:**  モデルやエージェントを共有し、Spacesを作成するために必要です。
* **推奨ペース:**  毎週3～4時間、約1週間で1つの章を完了することを推奨しています。


**前提条件:**

* Pythonの基本知識
* LLMの基本知識（コース内で復習も含まれます）


**その他:**

* コースは受講者のフィードバックに基づいて継続的に更新されます。
* ボーナスユニットが追加される予定です。


要するに、このコースは、AIエージェント開発の基礎から実践までを網羅した、実践的でコミュニティ重視の学習プログラムです。  認定取得を目指したり、単に知識を深めたい人にも最適なコースと言えるでしょう。

## Onboarding: Your First Steps 
このオンボーディングでは、Hugging Faceアカウントの作成、Discordサーバーへの参加と自己紹介、Hugging Face Agentsコースのフォロー、そしてコースの拡散の4ステップを案内しています。Discordサーバーでは、コースに関する様々なチャンネルが用意されており、コミュニティとの交流も促進されます。

## Unit 1. Introduction to Agents

### Introduction to Agents
このユニットでは、AIエージェントの基礎を学びます。エージェントとは何か、どのように意思決定を行うか、LLM（大規模言語モデル）がエージェントの「脳」としてどのように機能するか、ツールとアクションの使用方法、エージェントのワークフロー（Think→Act→Observe）などを学習します。  簡単なタスクを実行するエージェント「Alfred」の作成とHugging Face Spacesへの公開方法も習得できます。最後にクイズに合格すると、修了証が発行されます。2月12日午後5時（CET）にはライブQ&Aも予定されています。

### What is an Agent?

> 私たちはこれをエージェントと呼んでいるが、これはエージェンシー、つまり環境と相互作用する能力を持っているからだ。

### How does an AI take action on its environment?
基本 LLM はテキスト生成しかできないが、画像生成とか色々できるよね？なんで？  

> 答えは、HuggingChatやChatGPTなどの開発者が、LLMが画像を作成するために使用できる追加機能（Toolsと呼ばれる）を実装したからです。

### What type of tasks can an Agent do?

> アクションはツールと同じではないことに注意してください。 例えば、アクションを完了するために複数のツールを使用することができます。

---

#### 要約
この文章は、AIエージェントの概要を説明しています。エージェントは、AIモデル（主に大規模言語モデル：LLM）を用いて環境と相互作用し、ユーザー定義の目標を達成するシステムです。

主なポイントは以下です。

* **エージェントの構成**:  「脳」にあたるAIモデル（思考、計画）と、「体」にあたる能力・ツール（行動実行）から成る。
* **AIモデル**: LLMが一般的だが、画像認識もできるVLMなども利用可能。
* **環境との相互作用**:  ツール（メール送信、画像生成など）を使って行動し、結果を観察する。
* **タスク例**: バーチャルアシスタント、カスタマーサービスチャットボット、ゲームのNPCなど。
* **エージェントの機能**: 自然言語理解、推論・計画、環境との相互作用。


要するに、エージェントは指示を理解し、計画を立て、行動して目標を達成するAIシステムです。

Tools と Actions との違いや関係：  

文章によると、Tools と Actions は密接に関連していますが、同一ではありません。

* **Tools:** エージェントが環境とやりとりするために利用できる具体的な機能や外部リソースのことです。  メールを送信する関数、ウェブ検索を行う機能、画像を生成するAPIなど、具体的な作業を実行するものです。  エージェントはこれらのツールを組み合わせてタスクを実行します。  いわば、エージェントの「道具箱」の中身です。

* **Actions:** エージェントが行う行動のことです。「コーヒーを作る」「メールを送信する」「情報を検索する」など、目標達成のために実行される具体的なステップです。  一つのActionは、複数のToolsを必要とする場合もあります。


簡単に言えば、**Actionsは「何をするか」であり、Toolsは「どうやってするか」**です。

例えば、「メールを送信する」(Action) というタスクを実行するために、エージェントは「メール送信ツール」(Tool) を使用します。このツールは、メールサーバーに接続し、メール本文を送信する具体的な機能を提供します。  別の例として、「画像を生成する」(Action) というタスクでは、「画像生成API」(Tool) を利用します。

つまり、ToolsはActionsを実行するための手段であり、エージェントの能力を拡張するものです。  適切なToolsがなければ、エージェントは特定のActionsを実行できません。  Toolsの設計はエージェントの性能に大きく影響を与えます。

### Quick Quiz 1
ここで理解度を試す小テストがあった。簡単だった

### What are LLMs?

LLM についてもっと知りたければこの講座もあるでよ  
https://huggingface.co/learn/nlp-course/chapter1/1

オリジナルの Transformer アーキテクチャは、左側にエンコーダー、右側にデコーダーがあるという構成でした。

### What is a Large Language Model?
#### There are 3 types of transformers :
1. エンコーダー
エンコーダーベースのトランスフォーマーは、テキスト (またはその他のデータ) を入力として受け取り、そのテキストの高密度表現 (または埋め込み) を出力します。

- 例: Google の BERT
- 使用例: テキスト分類、セマンティック検索、固有表現認識
- 標準サイズ: 数百万のパラメータ

2. デコーダー
デコーダーベースのトランスフォーマーは、一度に 1 つのトークンを生成してシーケンスを完了することに重点を置いています。

- 例: Meta の Llama
- 使用例: テキスト生成、チャットボット、コード生成
- 典型的なサイズ: 数十億（米国の意味では10^9）のパラメータ

3. Seq2Seq (エンコーダー - デコーダー)
シーケンスからシーケンスへのトランスフォーマーは、エンコーダーとデコーダーを組み合わせたものです。エンコーダーは最初に入力シーケンスをコンテキスト表現に処理し、次にデコーダーが出力シーケンスを生成します。

- 例: T5、BART、
- 使用例: 翻訳、要約、言い換え
- 標準サイズ: 数百万のパラメータ

> LLMの基本原理はシンプルだが、非常に効果的である。その目的は、前のトークンのシーケンスが与えられたときに、次のトークンを予測することである。 トークン」とは、LLMが扱う情報の単位である。 トークン」はあたかも「単語」のように考えることができますが、効率上の理由からLLMは単語全体を使用しません。

> 各LLMは、そのモデルに固有の特別なトークンをいくつか持っている。 LLMはこれらのトークンを使って、生成された構造化コンポーネントを開いたり閉じたりします。 例えば、シーケンス、メッセージ、レスポンスの開始や終了を示すためなどである。 さらに、モデルに渡す入力プロンプトも特別なトークンで構造化されている。 その中で最も重要なのがEOS（End of sequence token）である。

#### Understanding next token prediction.
> LLMは自己回帰的と言われ、あるパスの出力が次のパスの入力になる。 このループは、モデルが次のトークンをEOSトークンと予測するまで続き、その時点でモデルは停止することができる。

> - 入力テキストがトークン化されると、モデルは入力シーケンスにおける各トークンの位置と意味に関する情報を取り込んだシーケンスの表現を計算する。
> - この表現はモデルに取り込まれ、モデルは語彙内の各トークンがシーケンスの次のトークンである可能性をランク付けしたスコアを出力する。

#### 要約

このテキストは、大規模言語モデル（LLM）の仕組みとAIエージェントにおける役割を解説したものです。以下、より詳細に解説します。

**1. LLMの定義と種類:**

* **定義:** LLMは、膨大なテキストデータで学習された、人間の言語を理解・生成できるAIモデルです。  その能力は、文章の生成、翻訳、要約、質問応答など多岐に渡ります。
* **アーキテクチャ:**  ほとんどの現代のLLMはTransformerアーキテクチャに基づいています。これは、「Attention」メカニズムを用いて、入力テキストの各単語間の関係性を効率的に計算するものです。
* **種類:**
    * **エンコーダ型:** 入力テキストを意味表現（埋め込み）に変換します。BERTが代表例で、テキスト分類や意味検索などに利用されます。パラメータ数は数百万程度です。
    * **デコーダ型:** トークン列を生成します。Llamaが代表例で、テキスト生成、チャットボット、コード生成などに利用されます。パラメータ数は数十億規模です。
    * **Seq2Seq型:** エンコーダとデコーダの両方を組み合わせ、入力シーケンスを処理して出力シーケンスを生成します。翻訳や要約などに利用されます。パラメータ数は数百万程度です。
* **主要なLLM:** GPT-4 (OpenAI), Llama (Meta), Deepseek-R1 (DeepSeek), SmollLM2 (Hugging Face), Gemma (Google), Mistral (Mistral)などが例として挙げられています。


**2. LLMの動作原理:**

* **トークン化:**  LLMは、テキストを単語ではなく、より小さな単位である「トークン」に分割して処理します。これは、語彙数を削減し、効率を高めるためです。
* **次のトークン予測:** LLMの主要なタスクは、前のトークン列に基づいて、次に来るトークンを予測することです。これは、自己回帰的な（autoregressive）プロセスで、予測されたトークンが次の予測への入力となります。
* **Attentionメカニズム:**  Attentionメカニズムは、次のトークンを予測する際に、入力テキスト中のどの単語が最も重要かを判断するのに役立ちます。重要な単語に重みを付けて処理することで、予測精度を高めます。
* **デコーディング戦略:**  次のトークンを選択する方法は複数あります。最も単純な方法は、確率が最も高いトークンを選択することですが、Beam Searchなど、より高度な方法も存在します。
* **特殊トークン:**  シーケンスの開始・終了、メッセージの開始・終了などを示す特殊なトークンが使用されます。モデルによって特殊トークンは異なり、その多様性も示されています。


**3. LLMの学習:**

* **事前学習:** 大量のテキストデータを用いて、自己教師あり学習（masked language modeling）を行います。これは、テキストの一部をマスクして、そのマスクされた部分を予測させることで、言語構造やパターンを学習する手法です。
* **ファインチューニング:** 事前学習済みのモデルを、特定のタスク（対話、分類、コード生成など）に合わせたデータでさらに学習させることで、特定のタスクにおける性能を向上させます。


**4. LLMの利用方法:**

* **ローカル実行:** 十分な計算資源を持つ環境で、ローカルにLLMを実行できます。
* **クラウド/API:** Hugging Faceなどのプラットフォームが提供するAPIを利用することで、容易にLLMを利用できます。


**5. AIエージェントにおけるLLMの役割:**

LLMはAIエージェントにおいて、人間の言語を理解し生成する中核的な役割を果たします。ユーザーの指示を解釈し、コンテキストを維持し、計画を立て、必要なツールを選択するなど、エージェントの知的な行動を支えます。


**まとめ:**

このテキストは、LLMの基本的な仕組みから、AIエージェントにおける応用までを網羅的に解説しています。  LLMは、近年急速に発展している技術であり、その応用範囲はますます広がっています。  より深い理解のためには、文中にあるNLPコースの受講が推奨されています。

---

ここまでアカウント作成してはじめてから1時間半くらい

### Messages and Special Tokens
このテキストは、大規模言語モデル（LLM）がチャットインターフェースでどのように会話処理を行うかを説明しています。

要点は以下の通りです。

* **チャットにおけるメッセージの扱い**: ユーザーとLLM間のメッセージは、モデルへの入力前に単一のプロンプトに連結される。UI上はメッセージ単位に見えるが、内部的には一つのテキストシーケンスとして処理される。

* **チャットテンプレートの役割**: 異なるLLMは独自の特殊トークンを使用するため、チャットテンプレートは、ユーザーとアシスタントのメッセージをLLMが理解できる形式に整形する役割を果たす。システムメッセージ（モデルの振る舞い方を定義）もテンプレートで管理される。

* **ベースモデルとインストラクトモデル**: ベースモデルは生のテキストデータで学習され、インストラクトモデルは指示に従うよう微調整されている。ベースモデルをインストラクトモデルのように動作させるには、適切なプロンプトフォーマット（チャットテンプレート）が必要。

* **`transformers`ライブラリ**:  `transformers`ライブラリは、チャットテンプレートを自動的に処理し、メッセージリストをモデルに入力可能なプロンプトに変換する機能を提供する(`apply_chat_template`関数)。

要するに、LLMとの自然な会話を実現するために、バックエンドではメッセージの連結と適切なフォーマットが重要であり、そのための仕組みとしてチャットテンプレートが使用されているということです。

> > モデルは会話を「記憶」しません。毎回会話全体を読み取ります。

そうか、毎回全部連結して丸ごと投げているのかw

> ここでチャット テンプレートが役立ちます。チャット テンプレートは、会話メッセージ (ユーザーとアシスタントのターン) と選択した LLM の特定のフォーマット要件との間の橋渡しとして機能します。言い換えると、チャット テンプレートはユーザーとエージェント間の通信を構造化し、すべてのモデルが独自の特殊トークンにもかかわらず、正しくフォーマットされたプロンプトを受け取るようにします。

#### Messages: The Underlying System of LLMs
##### System Messages
> エージェントを使用する場合、システム メッセージは、使用可能なツールに関する情報も提供し、実行するアクションをフォーマットする方法をモデルに指示し、思考プロセスをどのようにセグメント化すべきかのガイドラインも提供します。

---

##### Conversations: User and Assistant Messages
#### Chat-Templates
> 理解する必要があるもう 1 つのポイントは、ベース モデルと指示モデルの違いです。
> 
> ベースモデルは、生のテキストデータでトレーニングされ、次のトークンを予測します。
> 
> 指示モデルは、指示に従い、会話に参加できるように特別に調整されています。たとえば、SmolLM2-135Mは基本モデルで、 はSmolLM2-135M-Instructその指示調整版です。
> 
> ベースモデルを指示モデルのように動作させるには、モデルが理解できる一貫した方法でプロンプトをフォーマットする必要があります。ここでチャット テンプレートが役立ちます。

##### Base Models vs. Instruct Models
##### Understanding Chat Templates
##### Messages to prompt
> LLM が正しくフォーマットされた会話を受信するようにする最も簡単な方法は、chat_templateモデルのトークナイザーから を使用することです。

```
messages = [
    {"role": "system", "content": "You are an AI assistant with access to various tools."},
    {"role": "user", "content": "Hi !"},
    {"role": "assistant", "content": "Hi human, what can help you with ?"},
]
```

トークナイザーをインポートして会話をプロンプトへ変換する

```python
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("HuggingFaceTB/SmolLM2-1.7B-Instruct")
rendered_prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
```

### What are Tools?
#### 要約
この文章は、AIエージェントが外部ツールを利用して機能を拡張する方法を説明しています。大きく分けて以下の３つのパートに構造化できます。

**パート１：ツールの定義と種類**

* **ツールの定義:**  AIエージェントは、大規模言語モデル (LLM) に「ツール」を提供することで、その能力を拡張します。ツールとは、LLMがテキスト入力を受け取り、テキスト出力を生成するという制約を超えて、外部データの取得や計算などのアクションを実行するための関数です。

* **ツールの種類 (例):**
    * **Web 検索:** インターネットから最新の情報を取得します。
    * **画像生成:** テキストの説明に基づいて画像を作成します。
    * **情報検索:** 外部ソースから情報を取得します。
    * **API インターフェース:** GitHub、YouTube、Spotifyなどの外部APIと対話します。

* **良いツールの条件:** LLMの能力を補完するものであり、LLM単体では扱えない最新データや計算能力などを提供する必要があります。例として、算術計算には電卓ツールが挙げられています。

**パート２：ツールの動作と実装**

* **ツールの動作:** LLMはツールを直接呼び出すことができません。エージェントが、LLMからのテキスト指示を解析し、適切なツールを呼び出して実行し、結果をLLMに戻します。この過程はユーザーには隠蔽されます。

* **ツールへの情報の提供:** LLMにツールを認識させるには、システムプロンプトにツールの詳細な情報を記述する必要があります。この情報には、ツールの名前、説明、入力、出力の型などが含まれます。

* **ツール記述の自動生成:** Pythonコードを用いたツールの自動生成方法が提示されています。型ヒント、docstring、関数名を利用して、ツール情報を自動的に生成するデコレータ`@tool`が紹介されています。

```python
def tool(func):
    """
    A decorator that creates a Tool instance from the given function.
    """
    # Get the function signature
    signature = inspect.signature(func)

    # Extract (param_name, param_annotation) pairs for inputs
    arguments = []
    for param in signature.parameters.values():
        annotation_name = (
            param.annotation.__name__ 
            if hasattr(param.annotation, '__name__') 
            else str(param.annotation)
        )
        arguments.append((param.name, annotation_name))

    # Determine the return annotation
    return_annotation = signature.return_annotation
    if return_annotation is inspect._empty:
        outputs = "No return annotation"
    else:
        outputs = (
            return_annotation.__name__ 
            if hasattr(return_annotation, '__name__') 
            else str(return_annotation)
        )

    # Use the function's docstring as the description (default if None)
    description = func.__doc__ or "No description provided."

    # The function name becomes the Tool name
    name = func.__name__

    # Return a new Tool instance
    return Tool(
        name=name, 
        description=description, 
        func=func, 
        arguments=arguments, 
        outputs=outputs
    )
```

このコードを実行すると、LLMに渡すためのツール記述が生成されます。

**パート３：まとめと今後の展望**

* **ツールの重要性:**  LLMの静的なトレーニングデータの限界を超え、リアルタイムのタスクや特殊なアクションを可能にします。

* **今後の展望:** エージェントのワークフロー（観測、思考、行動）について、より詳細な説明が続くことが示唆されています。



#### What are AI Tools?
AI エージェントでよく使用されるツール

| ツール            | 説明                                                |
| ----------------- | --------------------------------------------------- |
| ウェブ検索        | エージェントがインターネットから最新情報を取得できるようにします。 |
| 画像生成          | テキストの説明に基づいて画像を作成します。                  |
| 検索              | 外部ソースから情報を取得します。                            |
| APIインターフェース | 外部 API (GitHub、YouTube、Spotify など) とやり取りします。     |

> LLM はトレーニング データに基づいてプロンプトの完了を予測します。つまり、LLM の内部知識にはトレーニング前のイベントのみが含まれます。したがって、エージェントに最新のデータが必要な場合は、何らかのツールを使用して提供する必要があります。

#### How do tools work?
> LLM はテキスト入力を受け取り、テキスト出力を生成することしかできません。LLM 自体でツールを呼び出す方法はありません。エージェントにツールを提供するというのは、 LLM にツールの存在を教え、必要に応じてツールを呼び出すテキストを生成するようにモデルに依頼することを意味します。

> エージェントは、LLM の出力を解析し、ツールの呼び出しが必要であることを認識し、LLM に代わってツールを呼び出す必要があります。ツールからの出力は LLM に送り返され、LLM がユーザーへの最終的な応答を作成します。

#### How do we give tools to an LLM?

> これを機能させるには、次の点について非常に正確かつ正確に行う必要があります。
>
> 1. ツールの機能
> 2. どのような入力が期待されるか


##### Auto-formatting Tool sections
##### Generic Tool implementation
まとめで示したコードが登場する


> 要約すると、次のことがわかりました。
> 
> - ツールとは: 計算の実行や外部データへのアクセスなど、LLM に追加機能を提供する関数。
> 
> - ツールを定義する方法: 明確なテキストの説明、入力、出力、および呼び出し可能な関数を提供します。
> 
> - ツールが不可欠な理由: ツールにより、エージェントは静的モデルトレーニングの制限を克服し、リアルタイムタスクを処理し、特殊なアクションを実行できるようになります。

### Quick Quiz 2
続きからここまで約45分間

### Understanding AI Agents through the Thought-Action-Observation Cycle
この文章は、AIエージェントの動作原理を「思考-行動-観察（Thought-Action-Observation）」サイクルに基づいて解説しています。  以下の構造で説明できます。

**1. はじめに:**

* 前提として、システムプロンプトによるツールの提供方法と、AIエージェントの推論・計画・環境との相互作用能力について触れられています。

**2. 思考-行動-観察サイクルの中核:**

* AIエージェントは、思考→行動→観察という連続したループで動作します。これは、目標達成まで続くwhileループに相当します。
* 各ステップの詳細：
    * **思考（Thought）:** LLM（大規模言語モデル）が次のステップを決定します。問題を分解し、必要なツールやパラメータを検討します。
    * **行動（Action）:** ツールを呼び出し、必要な引数を渡します。
    * **観察（Observation）:** ツールからの応答を反映し、結果を評価します。これは環境からのフィードバックです。

**3. システムプロンプトとサイクルの組み込み:**

* システムプロンプトには、エージェントの行動規範、利用可能なツール、思考-行動-観察サイクル自体が組み込まれています。

**4. 例：天気予報エージェントAlfred:**

* ユーザーの質問「ニューヨークの今日の天気は？」に対するAlfredの動作例が示されています。
* Alfredは、思考段階でAPI呼び出しを決定し、行動段階で天気APIツールを呼び出します。
* 観察段階でAPIからのレスポンスを受け取り、その結果に基づいて最終的な回答を生成します。
* この例では、エラー発生時やデータ不備時のサイクル再実行の可能性も示唆されています。

**5.  サイクルの特徴と利点:**

* **反復処理:** 目標達成までループを繰り返します。
* **ツール統合:** 外部ツール（天気APIなど）との連携により、リアルタイムデータの取得が可能です。
* **動的適応:** 観察結果に基づいて思考を修正し、正確性を高めます。

**6. まとめ:**

* 思考-行動-観察サイクルが、複雑なタスクを段階的に解決するAIエージェントの能力を支えていることが強調されています。  このサイクルは、次のセクションでより詳細に説明される「ReActサイクル」の基礎となっています。


全体として、この文章は、抽象的なAIエージェントの概念を、具体的な例を用いて分かりやすく説明することを目的としています。  特に、システムプロンプトと外部ツールとの連携が、AIエージェントの機能を拡張する上で重要であることを示しています。


#### The Core Components
エージェントは、思考（Thought）→ 行動（Act）および観察（Observe）という継続的なサイクルで動作します。

これらのアクションを一緒に分解してみましょう。

1. 思考: エージェントの LLM 部分が次のステップが何であるかを決定します。
2. 行動: エージェントは、関連付けられた引数を使用してツールを呼び出すことによってアクションを実行します。
3. 観察: モデルはツールからの応答を反映します。

#### The Thought-Action-Observation Cycle
> 多くのエージェント フレームワークでは、ルールとガイドラインがシステム プロンプトに直接埋め込まれており、すべてのサイクルが定義されたロジックに準拠していることが保証されます。


#### Alfred, the weather Agent
##### Thought
##### Action
##### Observation
##### Updated thought
##### Final Action
:memo: ユーザーに答えを返すのも最後のアクションとなるのだな。それをもって終了する、と。

> エージェントは、目的が達成されるまでループを繰り返します。
> アルフレッドのプロセスは循環的です。思考から始まり、ツールを呼び出して行動し、最後に結果を観察します。観察によってエラーや不完全なデータが示された場合、アルフレッドはサイクルに再度入り、アプローチを修正できます。
> 
> ツール統合:
> ツール (天気 API など) を呼び出す機能により、Alfred は静的な知識を超えて、多くの AI エージェントの重要な側面であるリアルタイム データを取得できます。
> 
> 動的適応(Dynamic Adaptation):
> 各サイクルでは、エージェントが最新の情報 (観察) を推論 (思考) に組み込むことができるため、最終的な回答が十分な情報に基づいた正確なものになります。
> 
> この例では、 ReAct サイクル(次のセクションで説明する概念) の背後にある中核概念を示しています。思考、行動、観察の相互作用により、AI エージェントは複雑なタスクを反復的に解決できるようになります。

### Thought, Internal Reasoning and the Re-Act Approach
#### 要約
この文章は、AIエージェントの内部動作、特に推論と計画能力について説明しています。  重要なのは、「Re-Actアプローチ」という手法で、これは「考える（Think）」「行動する（Act）」を組み合わせたものです。「Let's think step by step」というプロンプトによって、モデルが段階的に問題を解決するよう促します。これにより、複雑な問題を小さなステップに分解し、エラーを減らすことができます。  また、エージェントは「思考（Thought）」を通して、計画、分析、意思決定、問題解決、記憶統合、自己省察、目標設定、優先順位付けなどを行い、内部的な対話を通してタスクを遂行します。  関数呼び出しを調整されたLLMでは、この思考プロセスは省略可能な場合もあると記述されています。


| 思考の種類 | 例 |
| ---------- | ------------------------------------------------------------ |
| 計画       | 「このタスクを 3 つのステップに分割する必要があります: 1) データの収集、2) 傾向の分析、3) レポートの生成」 |
| 分析       | 「エラーメッセージによると、問題はデータベース接続パラメータにあるようです」 |
| 意思決定   | 「ユーザーの予算の制約を考慮すると、中間層のオプションを推奨します」 |
| 問題解決   | 「このコードを最適化するには、まずプロファイリングしてボトルネックを特定する必要があります」 |
| メモリ統合 | 「先ほどユーザーが Python を好むとおっしゃっていたので、Python の例を示します」 |
| 自己反省   | 「前回のアプローチはうまくいかなかったので、別の戦略を試してみる必要がある」 |
| 目標設定   | 「このタスクを完了するには、まず受け入れ基準を確立する必要があります」 |
| 優先順位   | 「新しい機能を追加する前にセキュリティの脆弱性に対処する必要がある」 |

#### The Re-Act Approach

> 重要な方法は、 ReAct アプローチです。これは、「推論」（考える）と「行動」（行動する）を連結したものです。
> 
> ReAct は、LLM に次のトークンをデコードさせる前に「ステップごとに考えてみましょう」と補足するシンプルなプロンプト手法です。
> 
> 実際、モデルに「ステップバイステップで」考えるように促すと、モデルは問題をサブタスクに分解するように促されるため、最終的な解決策ではなく、計画を生成する次のトークンに向けたデコードプロセスが促進されます。
> 
> これにより、モデルはサブステップをより詳細に考慮できるようになり、最終的なソリューションを直接生成しようとする場合よりもエラーが少なくなります。

:memo: gpt o3 のような推論モデルだと step by step はしないほうが良いとも聞くが、自分でそれをやるからユーザーがそうする必要がないってことかな？

### Actions, Enabling the Agent to Engage with Its Environment
#### 要約
このテキストは、AIエージェントが環境とどのように相互作用するか、特に「行動（Actions）」に焦点を当てて説明しています。

主なポイントは次の通りです。

* **エージェントの種類**: JSON形式、コード、関数呼び出しの3種類のエージェントがあり、それぞれ異なる方法で行動を表現します。JSONエージェントはJSONで行動を記述し、コードエージェントは実行可能なコードを生成します。関数呼び出しエージェントは、各アクションのために新しいメッセージを生成するように微調整されたJSONエージェントの一種です。

* **行動の種類**: 情報収集、ツール使用、環境操作、コミュニケーションなど、様々なタイプの行動があります。

* **停止と解析のアプローチ**: エージェントは、行動が完了したら生成を停止し（stop）、外部のパーサーがその出力（JSONやコード）を解析（parse）します。これにより、エージェントの応答が明確で正確になります。  これは、すべてのエージェントの種類で共通の重要な手順です。

* **コードエージェントの利点**:  コードエージェントは、複雑なロジックを表現でき、モジュール性が高く、デバッグが容易という利点があります。

要約すると、このテキストは、AIエージェントが環境と効果的にやり取りするための、行動の表現方法と処理方法について解説しています。  特に「停止と解析」のアプローチが、正確で効率的なエージェントの動作に重要であることを強調しています。

> アクションとは、AI エージェントが環境と対話するために実行する具体的なステップです。

情報を求めて Web を閲覧する場合でも、物理デバイスを制御する場合でも、各アクションはエージェントによって実行される意図的な操作です。

#### Types of Agent Actions

| エージェントの種類 | 説明 |
|---|---|
| JSONエージェント | 実行するアクションはJSON形式で指定されます |
| コードエージェント | エージェントは外部で解釈されるコードブロックを記述します |
| 関数呼び出しエージェント | これは、各アクションごとに新しいメッセージを生成するように微調整されたJSONエージェントのサブカテゴリです。 |

| アクションの種類 | 説明 |
|---|---|
| 情報収集 | Web 検索、データベースのクエリ、またはドキュメントの取得を実行します。 |
| ツールの使用 | API 呼び出し、計算の実行、コードの実行。 |
| 環境との相互作用 | デジタル インターフェースを操作したり、物理デバイスを制御したりします。 |
| コミュニケーション | チャットを通じてユーザーと交流したり、他のエージェントと共同作業したりします。 |

#### The Stop and Parse Approach
> アクションを実装するための重要な方法の 1 つは、停止と解析のアプローチです。この方法により、エージェントの出力が構造化され、予測可能になります。
> 
> 構造化された形式での生成:
> エージェントは、意図したアクションを明確な所定の形式 (JSON またはコード) で出力します。
> 
> さらなる生成の停止：
> アクションが完了すると、エージェントは追加のトークンの生成を停止します。これにより、余分な出力や誤った出力が防止されます。
> 
> 出力の解析:
> 外部パーサーはフォーマットされたアクションを読み取り、呼び出すツールを決定し、必要なパラメータを抽出します。

#### Code Agents
Agent の一種ってことだな。JSON などを生成する代わりにコードを生成する  
メリットは以下の通り

- 表現力:コードはループ、条件文、ネストされた関数などの複雑なロジックを自然に表現できるため、JSON よりも柔軟性が高くなります。
- モジュール性と再利用性:生成されたコードには、さまざまなアクションやタスクで再利用できる関数やモジュールを含めることができます。
- デバッグ性の向上:プログラミング構文が明確に定義されているため、コード エラーの検出と修正が容易になります。
- 直接統合:コード エージェントは外部ライブラリや API と直接統合できるため、データ処理やリアルタイムの意思決定などのより複雑な操作が可能になります。

### Observe, Integrating Feedback to Reflect and Adapt
（短いので要約は作成しない）

> 観察とは、エージェントが自身の行動の結果をどのように認識するかということです。
>
> これらは、エージェントの思考プロセスを促進し、将来の行動を導く重要な情報を提供します。

---

> 観察フェーズでは、エージェントは次の作業を行います。
> 
> - フィードバックを収集します:アクションが成功したか失敗したかを示すデータまたは確認を受け取ります。
> - 結果の追加:新しい情報を既存のコンテキストに統合し、メモリを効果的に更新します。
> - 戦略を適応させる:更新されたコンテキストを使用して、その後の考えや行動を洗練させます。

| 観察の種類 | 例 |
|---|---|
| システムフィードバック | エラーメッセージ、成功通知、ステータスコード |
| データの変更 | データベースの更新、ファイルシステムの変更、状態の変更 |
| 環境データ | センサーの読み取り値、システムメトリック、リソースの使用状況 |
| レスポンス分析 | APIレスポンス、クエリ結果、計算出力 |
| 時間ベースのイベント | 期限が到来し、予定されたタスクが完了しました |

#### How Are the Results Appended?
アクションを実行した後、フレームワークは次の手順を順番に実行します。

1. アクションを解析して、呼び出す関数と使用する引数を識別します。
2. アクションを実行します。
3. 結果をObservationとして追加します。

### Dummy Agent Library
ダミーと言いつつ https://huggingface.co/agents-course/notebooks/blob/main/dummy_agent_library.ipynb にアクセスすると、実際に動かせるのか？ いや、notebook が置いてあるだけで Colab で動かすのかな？

#### 要約
このコースは、AIエージェントの概念に焦点を当て、特定のフレームワークにこだわらないよう、フレームワーク非依存です。Unit 1では、ダミーのエージェントライブラリとシンプルなサーバーレスAPIを使用してLLMエンジンにアクセスします。本番環境では使用しませんが、エージェントの動作を理解するための良い出発点となります。その後、smolagents、LangGraph、LangChain、LlamaIndexなどのAIエージェントライブラリを使用します。簡単なPython関数と組み込みパッケージ(datetime、os)でツールとエージェントを作成し、Hugging FaceのServerless APIを用いてLlama-3.2-3B-Instructモデルと対話します。

チャットモデルでは、適切なプロンプトテンプレート（特殊トークン）を使用しないと、モデルが予期せぬ出力を生成することが示されました。「chat」メソッドが推奨されていますが、学習目的のため「text_generation」メソッドを使用し、プロンプトを手動で調整する方法を学びます。

ダミーのエージェントでは、システムプロンプトに情報を追加することで動作します。天気情報を取得するダミー関数`get_weather`を作成し、LLMの出力を関数実行結果で更新することで、現実的なエージェント動作を実現する方法を説明しています。  LLM単体では事実を「幻覚」する可能性があり、ツールと連携させることで正確な情報を取得できることを示しています。最終的に、より高度なエージェントライブラリ（smolagentsなど）に移行する準備が整います。

#### コード例解説

#### Serverless API

```python
import os
from huggingface_hub import InferenceClient

## You need a token from https://hf.co/settings/tokens. If you run this on Google Colab, you can set it up in the "settings" tab under "secrets". Make sure to call it "HF_TOKEN"
os.environ["HF_TOKEN"]="hf_xxxxxxxxxxxxxx"

client = InferenceClient("meta-llama/Llama-3.2-3B-Instruct")
# if the outputs for next cells are wrong, the free model may be overloaded. You can also use this public endpoint that contains Llama-3.2-3B-Instruct
# client = InferenceClient("https://jc26mwg228mkj8dw.us-east-1.aws.endpoints.huggingface.cloud"/)
```

```python
output = client.text_generation(
    "The capital of France is",
    max_new_tokens=100,
)

print(output)
```

```
Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris. The capital of France is Paris.
```

LLM セクションで説明したように、デコードだけを行う場合、モデルは EOS トークンを予測したときにのみ停止しますが、これは会話型 (チャット) モデルであり、期待されるチャット テンプレートを適用していないため、ここでは停止しません。

ここで、使用している `Llama-3.2-3B-Instruct` モデルに関連する特別なトークンを追加すると、動作が変わり、期待どおりの EOS が生成されるようになります。

```python
prompt="""<|begin_of_text|><|start_header_id|>user<|end_header_id|>
The capital of France is<|eot_id|><|start_header_id|>assistant<|end_header_id|>"""
output = client.text_generation(
    prompt,
    max_new_tokens=100,
)

print(output)
```

```
The capital of France is Paris.
```

「チャット」方式を使用すると、チャット テンプレートを適用するのに非常に便利で信頼性の高い方法になります。

```python
output = client.chat.completions.create(
    messages=[
        {"role": "user", "content": "The capital of France is"},
    ],
    stream=False,
    max_tokens=1024,
)
```

```
Paris.
```

#### Dummy Agent
このシステム・プロンプトは、先に見たものよりも少し複雑だが、すでに以下の内容が含まれている。

1. ツールに関する情報
2. サイクルの指示（思考→行動→観察）

```
Answer the following questions as best you can. You have access to the following tools:

get_weather: Get the current weather in a given location

The way you use the tools is by specifying a json blob.
Specifically, this json should have an `action` key (with the name of the tool to use) and an `action_input` key (with the input to the tool going here).

The only values that should be in the "action" field are:
get_weather: Get the current weather in a given location, args: {"location": {"type": "string"}}
example use : 

{{
  "action": "get_weather",
  "action_input": {"location": "New York"}
}}

ALWAYS use the following format:

Question: the input question you must answer
Thought: you should always think about one action to take. Only one action at a time in this format:
Action:

$JSON_BLOB (inside markdown cell)

Observation: the result of the action. This Observation is unique, complete, and the source of truth.
... (this Thought/Action/Observation can repeat N times, you should take several steps when needed. The $JSON_BLOB must be formatted as markdown and only use a SINGLE action at a time.)

You must always end your output with the following format:

Thought: I now know the final answer
Final Answer: the final answer to the original input question

Now begin! Reminder to ALWAYS use the exact characters `Final Answer:` when you provide a definitive answer.
```

text_generation "メソッドを実行しているので、手動でプロンプトを適用する必要がある：

```python
prompt=f"""<|begin_of_text|><|start_header_id|>system<|end_header_id|>
{SYSTEM_PROMPT}
<|eot_id|><|start_header_id|>user<|end_header_id|>
What's the weather in London ?
<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"""
```

このようにすることも可能で、これはチャットメソッド内で起こることだ：

```python
messages=[
    {"role": "system", "content": SYSTEM_PROMPT},
    {"role": "user", "content": "What's the weather in London ?"},
    ]
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3.2-3B-Instruct")

tokenizer.apply_chat_template(messages, tokenize=False,add_generation_prompt=True)
```

プロンプトはこうなる:

```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
Answer the following questions as best you can. You have access to the following tools:

get_weather: Get the current weather in a given location

The way you use the tools is by specifying a json blob.
Specifically, this json should have an `action` key (with the name of the tool to use) and a `action_input` key (with the input to the tool going here).

The only values that should be in the "action" field are:
get_weather: Get the current weather in a given location, args: {"location": {"type": "string"}}
example use : 

{{
  "action": "get_weather",
  "action_input": {"location": "New York"}
}}

ALWAYS use the following format:

Question: the input question you must answer
Thought: you should always think about one action to take. Only one action at a time in this format:
Action:

$JSON_BLOB (inside markdown cell)

Observation: the result of the action. This Observation is unique, complete, and the source of truth.
... (this Thought/Action/Observation can repeat N times, you should take several steps when needed. The $JSON_BLOB must be formatted as markdown and only use a SINGLE action at a time.)

You must always end your output with the following format:

Thought: I now know the final answer
Final Answer: the final answer to the original input question

Now begin! Reminder to ALWAYS use the exact characters `Final Answer:` when you provide a definitive answer. 
<|eot_id|><|start_header_id|>user<|end_header_id|>
What's the weather in London ?
<|eot_id|><|start_header_id|>assistant<|end_header_id|>
```

デコードすると、以下のようになる：

```python
output = client.text_generation(
    prompt,
    max_new_tokens=200,
)

print(output)
```

```
Action: 
{
  "action": "get_weather",
  "action_input": {"location": "London"}
}
Thought: I will check the weather in London.
Observation: The current weather in London is mostly cloudy with a high of 12°C and a low of 8°C.
```

ハルシネーションを起こしている。まだロンドンの天気をチェックしていないのに、結果が Observation に出ている。なので一旦「観察」を止めないといけない。

```python
output = client.text_generation(
    prompt,
    max_new_tokens=200,
    stop=["Observation:"] # Let's stop before any actual function is called
)
```

```
Action:
{
  "action": "get_weather",
  "action": {"location": "London"}
}
Thought: I will check the weather in London.
Observation:
```

良さそうなのでダミーの `get weather` 関数を実行する：

```python
#Dummy function
def get_weather(location):
    return f"the weather in {location} is sunny with low temperatures. \n"

get_weather('London')
```

```
'the weather in London is sunny with low temperatures. \n'
```

ベースプロンプト、関数実行までの完了、関数の結果をオブザベーションとして連結し、生成を再開しよう。

```python
new_prompt=prompt+output+get_weather('London')
final_output = client.text_generation(
    new_prompt,
    max_new_tokens=200,
)

print(final_output)
```

新しいプロンプトがこうなる：

```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
    Answer the following questions as best you can. You have access to the following tools:

get_weather: Get the current weather in a given location

The way you use the tools is by specifying a json blob.
Specifically, this json should have a `action` key (with the name of the tool to use) and a `action_input` key (with the input to the tool going here).

The only values that should be in the "action" field are:
get_weather: Get the current weather in a given location, args: {"location": {"type": "string"}}
example use : 

{{
  "action": "get_weather",
  "action_input": {"location": "New York"}
}}

ALWAYS use the following format:

Question: the input question you must answer
Thought: you should always think about one action to take. Only one action at a time in this format:
Action:

$JSON_BLOB (inside markdown cell)

Observation: the result of the action. This Observation is unique, complete, and the source of truth.
... (this Thought/Action/Observation can repeat N times, you should take several steps when needed. The $JSON_BLOB must be formatted as markdown and only use a SINGLE action at a time.)

You must always end your output with the following format:

Thought: I now know the final answer
Final Answer: the final answer to the original input question

Now begin! Reminder to ALWAYS use the exact characters `Final Answer:` when you provide a definitive answer. 
<|eot_id|><|start_header_id|>user<|end_header_id|>
What's the weather in London ?
<|eot_id|><|start_header_id|>assistant<|end_header_id|>

Action:
\`\`\` （コードブロックがおかしくなるのでバックスラッシュを入れる）
{
  "action": "get_weather",
  "action": {"location": {"type": "string", "value": "London"}
}
Thought: I will check the weather in London.
Observation:the weather in London is sunny with low temperatures.
```

最終回答：

```
Final Answer: The weather in London is sunny with low temperatures.
```

:memo: なんか面倒だけど、これをライブラリによって簡素化するのだろう

ここまで1時間半くらい。なんだかんだで4時間くらいかかったかな

### Let’s Create Our First Agent Using Smolagents
#### 要約

この内容は、smolagentsライブラリを使ってHugging Face Space上で動作するシンプルなコードエージェントを作成するチュートリアルです。

**要点:**

* **smolagents:** エージェント開発を簡素化する軽量ライブラリ。コードブロックの実行による「行動」と結果の「観察」を繰り返す`CodeAgent`に焦点を当てている。
* **Hugging Face Spaceテンプレート:** 提供されたテンプレートを複製して、自分のSpaceでエージェントを作成する。
* **`app.py`:** エージェントの動作を定義するメインのPythonファイル。ここを編集してツールを追加していく。
* **ツール:** エージェントが持つ機能。`@tool`デコレータを使って定義する。テンプレートにはダミーのツールとタイムゾーン取得ツールが例として含まれている。`DuckDuckGoSearchTool`や`image_generation_tool`のような既存ツールも利用可能。
* **LLM:** `Qwen/Qwen2.5-Coder-32B-Instruct`が使用されている。
* **目標:** 提供されたテンプレートにツールを追加し、エージェントを実際に動作させてみる。既存のツールを使うだけでなく、独自のツールを作成してみるのも良い。完成したエージェントはdiscordの#agents-course-showcaseで共有することが推奨されている。

チュートリアルでは、まずテンプレートを複製し、`app.py`内の`tools`パラメータにツールを追加することでエージェントに機能を追加していく流れとなっています。  最終的には、自分で作成したエージェントを公開・共有することが目標です。

#### What is smolagents?
https://youtu.be/PQDKcWiuln4?si=mWHHHX8g1TAmReUw

#### Let’s build our Agent!
https://huggingface.co/spaces/agents-course/First_agent_template これを複製する

https://huggingface.co/spaces/noriyotcp/First_agent_template

`app.py` を編集していく

`CodeAgent` class from `smolagents` を使用する

##### The Tools
2つ提供されている

1. ダミーツール
2. 実際に動くツール。世界のどこかの現在時刻を取得する

##### The Agent
[Qwen/Qwen2.5-Coder-32B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-32B-Instruct) を使用する

`CodeAgent` のパラメータである `tools` に新しいツールを追加していく

Space と Agent に詳しくなることがゴールだよ。現在エージェントはなんのツールも使ってないので出来上がってるやつとか新しいツールとか追加していくよ

### Unit 1 Final Quiz
80% 正解で certification がもらえる。最後 Submit ボタンを押さないといけないが本当に送信されてるかどうかわかりにくい

### Get Your Certificate
### Conclusion
次のユニットは 2/18 だ！ Bonus Unit: Fine-tune your agent

