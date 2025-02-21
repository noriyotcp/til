---
title: "Hugging Face AI Agent Course - Bonus Unit1. Fine-tuning an LLM for function-calling"
date: "2025-02-20 23:01:17 +0900"
last_modified_at: "2025-02-20 23:01:17 +0900"
---

## Introduction
### What you'll learn

#### 要約
役立つまとめを提供しますので、内容のハイライトを簡単にまとめてください。

「ファインチューニング」とは、特定のタスクに対して LLM をカスタマイズするプロセスです。

LLM の関数呼び出しを微調整することで、以下が可能になります。

* モデルがアクションを実行し、トレーニング中に観測を解釈できるようにする。
* これにより、AI がより堅牢になります。

このボーナスユニットはオプションであり、ユニット 1 よりも高度です。

このボーナスユニットでは次のことを学びます。

* 関数呼び出し
* LoRA (Low-Rank Adaptation)
* 関数呼び出しモデルにおける思考 → 行動 → 観察サイクル
* 新しい特殊トークン

このボーナスユニットの完了までに、次のことができるようになります。

* ツールとの API の内部動作を理解する。
* LoRA テクニックを使用してモデルを微調整する。
* 堅牢で保守可能な関数呼び出しワークフローを作成するために思考 → 行動 → 観察サイクルを実装および変更する。
* モデルの内部的な推論と外部的な行動をシームレスに区別するために特殊トークンを設計して利用する。
* 関数呼び出しを行うように独自のモデルを微調整する。

## What is Function Calling?
### How does the model "learn" to take an action?
### 要約
関数呼び出しは、LLM（大規模言語モデル）が外部環境と対話するための手段です。GPT-4 で初めて導入され、他のモデルにも取り入れられました。エージェントのツールのように、関数呼び出しはモデルに環境への働きかけを可能にします。ただし、関数呼び出し能力はモデルによって学習され、他のエージェント技術よりもプロンプトへの依存度が低いです。

ユニット1のエージェントでは、ツールを使うことを学習させずにツールリストを提供し、モデルがそれらを使って計画を立てる能力を一般化できることに依存していました。一方、関数呼び出しでは、エージェントはツールを使用するようにファインチューニング（訓練）されます。

モデルはどのように行動を「学習」するのでしょうか？ユニット1では、エージェントの一般的なワークフローを調べました。ユーザーがエージェントにツールを提供し、クエリでプロンプトすると、モデルは次のサイクルを繰り返します。

* **思考:** 目的を達成するためにはどのような行動をとる必要があるか？
* **行動:** 正しいパラメータで行動をフォーマットし、生成を停止する。
* **観察:** 実行結果を取得する。

通常のAPIを介したモデルとの会話では、ユーザーとアシスタントのメッセージが交互にやり取りされます。関数呼び出しはこの会話に新しい役割をもたらします。行動と観察それぞれに新しい役割が追加されます。

多くのAPIでは、モデルは取るべき行動を「アシスタント」メッセージとしてフォーマットします。チャットテンプレートは、これを関数呼び出しのための特別なトークンとして表現します。

このコースでは、関数呼び出しについて再び説明しますが、より深く理解したい場合は、関連ドキュメントを参照してください。関数呼び出しの仕組みを理解した上で、関数呼び出し機能を持たないモデル「google/gemma-2-2b-it」に、新しい特別なトークンを追加することで関数呼び出し機能を追加します。そのためには、まずファインチューニングとLoRAを理解する必要があります。

## Let’s Fine-Tune your model for function-calling
### 要約
この文章は、関数呼び出しに対応した大規模言語モデルのファインチューニング方法について説明しています。

主なポイントは３つです。

1. **モデルの訓練段階:**  まず大規模データで事前学習されたベースモデル（例: google/gemma-2-2b）を用意します。次に、指示に従うようファインチューニングされたモデル（例: google/gemma-2-2b-it）を利用するのが効率的です。最後に、関数呼び出しのための追加のファインチューニングを行います。

2. **LoRAを用いた効率的なファインチューニング:**  LoRA (Low-Rank Adaptation)という手法を用いることで、訓練に必要なパラメータ数を大幅に削減し、メモリ効率の良い、高速なファインチューニングを実現します。

3. **チュートリアルへのリンク:**  関数呼び出しモデルのファインチューニング方法を学ぶためのチュートリアルノートブックへのリンクが提供されています。


要約すると、既存の指示追従済みモデルをベースに、LoRAを用いて効率的に関数呼び出し機能を追加するファインチューニング方法とそのチュートリアルを紹介している記事です。

### How do we train our model for function-calling ?
### 日本語訳
モデルのトレーニングは 3 つのステップに分けられます。

モデルは大量のデータで事前トレーニングされています。そのステップの出力は事前トレーニング済みモデルです。たとえば、google/gemma-2-2bです。これは基本モデルであり、適切な指示に従う能力がなく、次のトークンを予測する方法しか知りません。

モデルをチャットのコンテキストで役立てるには、指示に従うように微調整する必要があります。このステップでは、モデル作成者、オープンソース コミュニティ、あなた、または誰でもモデルをトレーニングできます。たとえば、google/gemma-2-2b-it は、 Gemma プロジェクトの背後にある Google チームによって指示調整されたモデルです。

その後、モデルは作成者の好みに合わせて調整できます。たとえば、顧客に対して失礼な態度を取ってはならないカスタマー サービス チャット モデルなどです。

通常、Gemini や Mistral のような完成品は3 つのステップすべてを経ますが、Hugging Face で見つかるモデルは、このトレーニングの 1 つ以上のステップに合格しています。

このチュートリアルでは、 google/gemma-2-2b-itに基づいて関数呼び出しモデルを構築します。ベースモデルはgoogle/gemma-2-2bであり、Google チームは次の手順に従ってベースモデルを微調整し、結果として「google/gemma-2-2b-it」が生まれました。

この場合、ベースモデルではなく「google/gemma-2-2b-it」をベースとして使用します。これは、ユースケースでは事前に行われた微調整が重要であるためです。

メッセージでの会話を通じてモデルと対話したいので、基本モデルから始めて、指示に従うこと、チャット、関数の呼び出しを学習するために、より多くのトレーニングが必要になります。

指示調整されたモデル(the instruct-tuned model)から開始することで、モデルが学習する必要がある情報の量を最小限に抑えます。

### LoRA  (Low-Rank Adaptation of Large Language Models)
### 日本語訳
LoRA (Low-Rank Adaptation of Large Language Models) は、トレーニング可能なパラメータの数を大幅に削減する、人気の軽量トレーニング手法です。

これは、トレーニングするモデルにアダプターとして少数の新しい重みを挿入することで機能します。これにより、LoRA を使用したトレーニングが大幅に高速化され、メモリ効率が向上し、モデルの重みが小さくなり (数百 MB)、保存と共有が容易になります。

LoRA は、Transformer レイヤーにランク分解行列のペアを追加することで機能し、通常は線形レイヤーに重点が置かれます。トレーニング中は、モデルの残りの部分を「フリーズ」し、新しく追加されたアダプターの重みのみを更新します。

そうすることで、アダプターの重みを更新するだけで済むため、トレーニングに必要なパラメータの数が大幅に減少します。

推論中、入力はアダプタとベース モデルに渡されるか、これらのアダプタの重みをベース モデルとマージできるため、追加のレイテンシ オーバーヘッドは発生しません。

LoRA は、リソース要件を管理可能な範囲に維持しながら、大規模な言語モデルを特定のタスクまたはドメインに適応させるのに特に役立ちます。これにより、モデルのトレーニングに必要なメモリを削減できます。

---

詳しくはこのチュートリアルをみてくれ -> https://huggingface.co/learn/nlp-course/chapter11/4?fw=pt

### Fine-Tuning a model for Function-calling
これはColab ノートブックを使ってやっていくらしい
https://huggingface.co/agents-course/notebooks/blob/main/bonus-unit1/bonus-unit1.ipynb

To access Gemma on Hugging Face:

1. Make sure you're signed in to your Hugging Face Account
2. Go to https://huggingface.co/google/gemma-2-2b-it
3. Click on Acknowledge license and fill the form.

#### Step 1: Set the GPU
Open in Colab を押してノートブックを開く  
GPU は T4 GPU で  

以降ノートブックで行う

#### Step2: Install dependencies
Notebook でポチって Python libraries をインストールする  

- bitsandbytes for quantization
- peftfor LoRA adapters
- Transformersfor loading the model
- datasetsfor loading and using the fine-tuning dataset
- trlfor the trainer class

#### Step 3: Create your Hugging Face Token to push your model to the Hub
HF の認証トークンを作成する。https://huggingface.co/settings/tokens  
Write role でトークンを作成する

#### Step 4: Import the librairies
これもポチってライブラリをインストールする
先ほど作成したトークンを環境変数 `HF_TOKEN` にセットするのだが、直接書いちゃって大丈夫なのか？

#### Step 5: Processing the dataset into inputs

> このチュートリアルでは、deepseek-ai/DeepSeek-R1-Distill-Qwen-32Bから新しい思考ステップコンピュータを追加することで、関数呼び出しのための一般的なデータセット "NousResearch/hermes-function-calling-v1 "を拡張しました。 しかし、モデルが学習するためには、会話を正しくフォーマットする必要があります。 Unit 1に従ったのであれば、メッセージのリストからプロンプトへの移動はchat_templateによって処理されること、あるいは、gemma-2-2Bのデフォルトのchat_templateにはツールの呼び出しが含まれていないことを知っているだろう。 つまり、gemma-2-2Bのデフォルトのchat_templateにはツールの呼び出しが含まれていないので、それを修正する必要があります！これがプリプロセス関数の役割です。 メッセージのリストから、モデルが理解できるプロンプトに変換する。

notebook を実行するのだが警告が出ている  
The secret `HF_TOKEN` does not exist in your Colab secrets.

うーん、設定はしたけどな？

一応ブラウザをリロードする。Step3 までは終わっているようだから、Step4 を再度実行。トークンのセットも忘れずに
そして Step5 でポチるがもう実行済みなので何も起こらないな

#### Step 6: A Dedicated Dataset for This Unit

このボーナスユニットでは、ファンクション・コーリングのデータセットのリファレンスとされているNousResearch/hermes-function-calling-v1をベースに、カスタムデータセットを作成した。 オリジナルのデータセットは素晴らしいが、「考える」ステップは含まれていない。

関数呼び出しでは、このようなステップは任意であるが、deepseekモデルや論文 "Test-Time Compute "のような最近の研究では、LLMが答えを出す前（この場合はアクションを起こす前）に "考える "時間を与えることで、モデルの性能が大幅に向上することが示唆されている。 そこで私は、このデータセットのサブセットを計算し、関数呼び出しの前に思考トークン<think>を計算するために、deepseek-ai/DeepSeek-R1-Distill-Qwen-32Bに渡すことにした。 その結果、次のようなデータセットが得られた：
（ここで画像が貼られているけどどうするんだ？） -> データセットがある  

そして以下を実行した  

```python
dataset = dataset.map(preprocess, remove_columns="messages")
dataset = dataset["train"].train_test_split(0.1)
print(dataset)
```

```
DatasetDict({
    train: Dataset({
        features: ['text'],
        num_rows: 3213
    })
    test: Dataset({
        features: ['text'],
        num_rows: 357
    })
})
```

#### Step 7: Checking the inputs
```
入力がどのようなものか、手動で見てみよう！この例では、次のようなものがある： <tools></tools>の間に利用可能なツールのリストを含む必要な情報を含むユーザーメッセージ： 「<think></think>に含まれる "thinking "フェーズと<tool_call></tool_call>に含まれる "Act "フェーズです。 もしモデルが<tools_call>を含んでいれば、ツールからの答えと<tool_response></tool_response>を含む新しい "Tool "メッセージにこのアクションの結果を追加します。
```

なんか `<think>` のところで考えているんだなということがわかる

`<tool_call>` でツールを読んでいる。そのタグの間には引数が記述されている

```
<tool_call>
{'name': 'get_news_headlines', 'arguments': {'country': 'United States'}}
</tool_call>
```

```
<tool_response>
{'headlines': ['French President announces new environmental policy', 'Paris Fashion Week highlights', 'France wins World Cup qualifier', 'New culinary trend sweeps across France', 'French tech startup raises millions in funding']}
</tool_response>
```

`tool_response` があるのでそれをメッセージに追加している

以下も行う。サニティチェックとな  

```python
# Sanity check
print(tokenizer.pad_token)
print(tokenizer.eos_token)
```

#### ステップ8：トークナイザーを修正する
#### Step8: Let's Modify the Tokenizer

> 確かに、ユニット1で見たように、トークナイザーはデフォルトでテキストをサブワードに分割します。 これは、私たちが新しい特別なトークンに望むことではありません！<think>、<tool_call>、<tool_response>を使用して私たちの例を分割しましたが、トークナイザーはまだそれらを全体のトークンとして扱いません。 さらに、プロンプト内のメッセージとして会話をフォーマットするために、プリプロセス関数のchat_templateを変更したので、これらの変更を反映するために、トークナイザーのchat_templateも変更する必要があります。

#### Step 9: Let's configure the LoRA
> This is we are going to define the parameter of our adapter. Those a the most important parameters in LoRA as they define the size and importance of the adapters we are training.
> ここで、アダプターのパラメーターを定義します。 LoRAで最も重要なパラメータで、トレーニングするアダプタのサイズと重要性を定義する。
#### ステップ10： TrainerとFine-Tuningハイパーパラメータを定義しよう
#### Step 10: Let's define the Trainer and the Fine-Tuning hyperparameters

> このステップでは、モデルを微調整するために使うクラスであるTrainerと、ハイパーパラメータを定義します。

なんか設定とか事前準備をしてるみたいだ

> As Trainer, we use the SFTTrainer which is a Supervised Fine-Tuning Trainer.

なんかデータセットを色々いじっているようだ

> Here, we launch the training 🔥. Perfect time for you to pause and grab a coffee ☕.

いよいよトレーニングって感じか

これが時間かかるから上限に達してしまった

## Conclusion
なるほど、これだけ？ファインチューニングについての簡単な説明のみであとはチュートリアルを楽しんでね！ってことかな

