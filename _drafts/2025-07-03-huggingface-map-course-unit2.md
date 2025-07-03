---
title: "Hugging Face MCP Course - 2. End-to-End MCP Application"
date: "2025-07-03 20:36:17 +0900"
last_modified_at: "2025-07-03 20:36:17 +0900"
---

https://huggingface.co/learn/mcp-course/unit2/introduction

実際に Gradio を使って MCP サーバーを構築し、複数のクライアントと接続することで、エンドツーエンドの MCP アプリケーションを構築する方法を学びます。このユニットでは、感情分析ツールを作成し、HuggingFace.js や SmolAgents などの異なるクライアント実装を使用してサーバーに接続します。最終的には、Hugging Face Spaces にサーバーをデプロイし、完全なシステムをテストおよびデバッグします。 <- こんな感じ

## Building an End-to-End MCP Application
本テキストは、MCP（Model Collaboration Protocol）コースのユニット2の概要を示しており、Gradioを使用してサーバーを構築し、複数のクライアントと接続することで、エンドツーエンドのMCPアプリケーションを構築する方法について説明しています。以下に、主なポイントをまとめます。

**ユニット2の目標:** このユニットでは、GradioとHugging Face Hubを使用して、シンプルなMCPサーバーとクライアントを構築することを目標としています。次のユニットでは、より複雑なサーバーを構築し、現実世界のユースケースに取り組みます。

### What You’ll Learn
**学習内容:** このユニットでは、以下の内容を学習します。
* Gradioの組み込みMCPサポートを使用してMCPサーバーを作成する
* AIモデルで使用できる感情分析ツールを構築する
* 異なるクライアント実装を使用してサーバーに接続する：
* HuggingFace.jsベースのクライアント
* SmolAgentsベースのPythonクライアント
* MCPサーバーをHugging Face Spacesにデプロイする
* 完全なシステムをテストおよびデバッグする

### Prerequisites
**前提条件:** このユニットに進む前に、以下の前提条件を満たしている必要があります。
* ユニット1を完了しているか、MCPの基本的な概念を理解している
* PythonとJavaScript/TypeScriptの両方に慣れている
* APIとクライアント-サーバーアーキテクチャの基本的な理解がある
* 開発環境が整っている：
    * Python 3.10+
    * Node.js 18+
    * Hugging Faceアカウント（デプロイメント用）

```mermaid
graph LR
    subgraph Host
        Client(Client)
    end
    Server(Server)
    A_tool(a tool)

    Client --- Server
    Server --- A_tool

    style Client fill:#aaffaa,stroke:#333,stroke-width:2px
    style Server fill:#ddeeff,stroke:#333,stroke-width:2px

    linkStyle 0 stroke-dasharray: 5 5;
    linkStyle 1 stroke-dasharray: 5 5;

    Client --> Host
    linkStyle 2 stroke-dasharray: 5 5;

    Client <-- "javascript | Python" --> Server
    linkStyle 3 stroke-dasharray: 5 5;
```

### Our End-to-End Project
**エンドツーエンドのプロジェクト:** 感情分析アプリケーションを構築します。これは、サーバー、クライアント、デプロイメントの3つの主要部分で構成されています。

#### Server Side
* **サーバー側:** Gradioを使用してWebインターフェースとMCPサーバーを`gr.Interface`経由で作成します。TextBlobを使用して感情分析ツールを実装し、HTTPとMCPプロトコルの両方を介してツールを公開します。

#### Client Side
* **クライアント側:** HuggingFace.jsクライアントを実装するか、smolagents Pythonクライアントを作成します。同じサーバーを異なるクライアント実装で使用する方法を示します。

#### Deployment
* **デプロイメント:** サーバーをHugging Face Spacesにデプロイし、デプロイされたサーバーで動作するようにクライアントを構成します。

### Let’s Get Started!
**開始:** 開発環境をセットアップし、Gradio MCPサーバーを作成することから始めます。

---

## Building the Gradio MCP Server
**GradioによるMCPサーバー構築:** Gradioを用いることで、感情分析機能を備えたMCP（Model Communication Protocol）サーバーを容易に構築できます。このサーバーは、Webインターフェースを通じて人間が利用できるだけでなく、MCPプロトコルを通じてAIモデルからもアクセス可能です。Gradioの`launch()`関数で`mcp_server=True`を設定することで、Python関数が自動的にMCPツールに変換されます。

### Introduction to Gradio MCP Integration
**Gradio MCP連携の仕組み:** Gradioは、Python関数をMCPツールに変換するプロセスを自動化します。具体的には、入力コンポーネントをツールの引数スキーマにマッピングし、出力コンポーネントから応答フォーマットを決定します。さらに、クライアントとサーバー間の通信のために、HTTP+SSE（Server-Sent Events）上でJSON-RPCを設定し、WebインターフェースとMCPサーバーのエンドポイントを同時に作成します。

### Setting Up the Project
**感情分析MCPサーバーの作成:** プロジェクトディレクトリを作成し、必要な依存関係（`gradio[mcp]` と `textblob`）をインストールします。`app.py`ファイルを作成し、感情分析を行う`sentiment_analysis`関数を定義します。この関数は、TextBlobライブラリを使用してテキストの極性（polarity）と主観性（subjectivity）を分析し、結果をJSON形式で返します。

### Creating the Server
### Understanding the Code
**コードの主要コンポーネント:** `sentiment_analysis`関数はテキストを受け取り、感情分析の結果（極性、主観性、評価）を含む辞書を返します。関数定義のドキュメンテーション文字列（docstring）と型ヒント（type hints）は、GradioがMCPツールのスキーマを生成する上で重要です。`gr.Interface`は、Web UIとMCPサーバーの両方を作成し、入力および出力コンポーネントはツールのスキーマを定義します。`mcp_server=True`を設定することで、MCPサーバーが有効になります。

### Running the Server
### Testing the Server
**サーバーの実行とテスト:** サーバーは`python app.py`コマンドで起動します。Webインターフェースは`http://localhost:7860`で、MCPサーバーは`http://localhost:7860/gradio_api/mcp/sse`で利用可能です。Webインターフェースからテキストを入力して感情分析の結果を確認したり、`http://localhost:7860/gradio_api/mcp/schema`にアクセスしてMCPツールのスキーマを確認したりすることで、サーバーをテストできます。

### Troubleshooting Tips
**トラブルシューティングのヒント:** 関数パラメータと戻り値には必ず型ヒントを指定し、各パラメータに対してArgsブロックを含むドキュメンテーション文字列を追加します。入力引数は文字列として受け入れ、関数内で必要な型に変換することで、MCPクライアントとの互換性が向上します。SSEベースのMCPサーバーをサポートしていないクライアントの場合は、`mcp-remote`を使用します。接続問題が発生した場合は、クライアントとサーバーを再起動し、MCPスキーマが正しいURLで利用可能であることを確認します。

### Deploying to Hugging Face Spaces
**Hugging Face Spacesへのデプロイ:** Hugging Face Spacesにデプロイすることで、作成したMCPサーバーを他のユーザーが利用できるようになります。新しいSpaceを作成し、GradioをSDKとして選択し、`app.py`と`requirements.txt`ファイルをSpaceにpushします。MCPサーバーは`https://YOUR_USERNAME-mcp-sentiment.hf.space/gradio_api/mcp/sse`で利用可能になります。

### Next Steps
**今後のステップ:** MCPサーバーが稼働したため、次はサーバーと対話するクライアントを作成します。HuggingFace.jsベースのクライアントと、SmolAgentsベースのPythonクライアントを実装し、デプロイしたサーバーでテストします。
