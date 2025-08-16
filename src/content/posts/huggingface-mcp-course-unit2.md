---
title: "Hugging Face MCP Course Unit2: エンドツーエンドMCPアプリケーション構築 学習メモ"
date: "2025-08-17 05:51:06 +0900"
last_modified_at: "2025-08-17 05:51:06 +0900"
draft: true
tags: ["MCP", "Gradio", "Hugging Face"]
---

Hugging Face MCP Course の Unit2 を学習したメモ。Unit1 で基本概念を学んだ後、実際にGradioを使ってMCPサーバーを構築し、複数のクライアントと接続するエンドツーエンドのアプリケーションを作成する。

## Gradio MCPサーバーの構築

### 感情分析ツールの実装

Gradioの組み込みMCPサポートを使って感情分析サーバーを作成。`mcp_server=True`を設定するだけでPython関数がMCPツールに自動変換される。

プロジェクトディレクトリを作成し、必要な依存関係（`gradio[mcp]` と `textblob`）をインストール。`app.py`ファイルを作成し、感情分析を行う`sentiment_analysis`関数を定義する。この関数はTextBlobライブラリを使用してテキストの極性（polarity）と主観性（subjectivity）を分析し、結果をJSON形式で返す。

### 重要なポイント

- **型ヒント必須**: 関数パラメータと戻り値に型ヒントが必要
- **docstring重要**: MCPツールのスキーマ生成に使用される。各パラメータにArgsブロックを含める
- **入力は文字列で受け取る**: MCPクライアントとの互換性向上のため
- **エンドポイント**: 
  - Web UI: `http://localhost:7860`
  - MCP Server: `http://localhost:7860/gradio_api/mcp/sse`
  - Schema: `http://localhost:7860/gradio_api/mcp/schema`

### サーバーの実行とテスト

サーバーは`python app.py`コマンドで起動。Webインターフェースからテキストを入力して感情分析の結果を確認したり、スキーマURLにアクセスしてMCPツールのスキーマを確認できる。

### Hugging Face Spacesへのデプロイ

新しいSpaceを作成し、GradioをSDKとして選択。`app.py`と`requirements.txt`ファイルをSpaceにpush。

```txt
# requirements.txt
gradio[mcp]
textblob
```

デプロイ後のMCPエンドポイント: `https://YOUR_USERNAME-mcp-sentiment.hf.space/gradio_api/mcp/sse`

## MCPクライアントの実装

### 基本的な設定ファイル構造

```json
{
  "servers": [
    {
      "name": "MCP Server",
      "transport": {
        "type": "sse",
        "url": "http://localhost:7860/gradio_api/mcp/sse"
      }
    }
  ]
}
```

### Cursor IDEでの設定

macOS:
```json
{
  "mcpServers": {
    "sentiment-analysis": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://YOURUSENAME-mcp-sentiment.hf.space/gradio_api/mcp/sse",
        "--transport",
        "sse-only"
      ]
    }
  }
}
```

Windows:
```json
{
  "mcpServers": {
    "sentiment-analysis": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "mcp-remote",
        "https://YOURUSENAME-mcp-sentiment.hf.space/gradio_api/mcp/sse",
        "--transport",
        "sse-only"
      ]
    }
  }
}
```

### mcp-remoteが必要な理由

現在のMCPクライアント（Cursor含む）は主にstdioトランスポートのローカルサーバーのみサポート。`mcp-remote`がブリッジとして機能し、リモートMCPサーバーへのリクエストを転送する。

### Continue（VS Code拡張）での設定

`.continue/mcpServers/playwright-mcp.yaml`:
```yaml
name: playwright-mcp
transport:
  type: sse
  url: https://example.com/gradio_api/mcp/sse
```

ローカルモデル設定（`.continue/models/local-models.yaml`）:
```yaml
models:
  - name: llama-3.1-8b
    provider: ollama
    model: llama3.1:8b
    contextLength: 8192
```

## Gradio as MCPクライアント

既存のMCPサーバーに接続してUIを提供する逆パターン。GradioをMCPクライアントとして使用し、既存のMCPサーバーに接続する方法。

### 必要なライブラリ

`smolagents[mcp]`、`gradio[mcp]`、`mcp`といったライブラリをインストール。`MCPClient`クラスを用いてMCPサーバーに接続し、利用可能なツールを取得。

### 実装のポイント

- `InferenceClientModel`などのモデルを使用
- `CodeAgent`でツールを組み込み
- `gr.ChatInterface`でUIとして公開
- Hugging FaceのAPIトークン (`HF_TOKEN`) を環境変数に設定が必要
- **重要**: `finally`ブロック内で`mcp_client.disconnect()`を呼び出して明示的に切断

## Tiny Agentsとの連携

### インストール

```bash
npm install -g @huggingface/tiny-agents
npm install -g mcp-remote
```

### agent.json設定

```json
{
  "model": "meta-llama/Llama-3.1-8B-Instruct",
  "provider": "huggingface",
  "servers": [
    {
      "name": "sentiment-analysis",
      "transport": {
        "type": "mcp-remote",
        "url": "https://YOUR_USERNAME-mcp-sentiment.hf.space/gradio_api/mcp/sse"
      }
    },
    {
      "name": "filesystem",
      "transport": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/files"]
      }
    }
  ]
}
```

### 実行

```bash
npx @huggingface/tiny-agents run agent.json
```

## ローカル実行とハードウェア最適化

### AMD NPU/iGPU with Lemonade Server

#### セットアップ

```bash
# Lemonade Server (Windows/Linux)
curl -sSL https://install.lemonade.ai | bash

# macOS
brew install lemonade-ai/tap/lemonade
```

#### agent.json（ローカルモデル用）

```json
{
  "model": "jan-nano",
  "provider": "lemonade",
  "endpoint": "http://localhost:8000/api/",
  "servers": [
    {
      "name": "desktop-commander",
      "transport": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "desktop-commander-mcp"]
      }
    }
  ]
}
```

### 機密情報処理のユースケース

採用プロセスでの履歴書評価例。ローカルファイルへのアクセスを可能にし、機密情報を完全にオンデバイスで処理するアシスタントを作成。

Desktop Commander MCPサーバーを使用してローカルマシン上でコマンドを実行し、ファイルシステムへのアクセス、ターミナルの制御、コード編集機能を活用。`file-assistant`プロジェクトディレクトリを作成し、`agent.json`ファイルを設定してJan Nanoモデルを使用するように構成。

ジョブ記述ファイル (`job_description.md`) と候補者の履歴書ファイル (`candidates/john_resume.md`) を作成し、アシスタントにこれらのファイルを読み込ませ、履歴書を評価させ、面接への招待状を作成させる。

## 実践的なポイント

### トラブルシューティング

1. **型ヒント忘れ**: Python関数には必ず型ヒントを付ける
2. **docstring不備**: 各パラメータにArgsブロックを含める
3. **接続問題**: クライアント・サーバー再起動、スキーマURL確認
4. **SSE非対応**: `mcp-remote`を使用

### ベストプラクティス

- **入力は文字列で受け取る**: MCPクライアントとの互換性向上
- **明示的な切断**: MCPクライアントは`finally`ブロックで`disconnect()`
- **エラーハンドリング**: 接続失敗時の適切な処理
- **セキュリティ**: 機密情報はローカル処理を検討

### 学んだこと

- Gradioの`mcp_server=True`だけでサーバーが作れる手軽さ
- 様々なクライアント実装の選択肢（Cursor IDE、Continue、Tiny Agents）
- `mcp-remote`によるリモートサーバーへのブリッジ機能
- ローカル実行でのプライバシー保護の重要性
- AMD NPU/iGPUでの高速化の可能性

## まとめ

Unit2では実際にMCPアプリケーションを構築する方法を学んだ。MCPのモジュール式アプローチにより、複数のツールプロバイダーへの接続、利用可能なツールの動的な検出、カスタムツールの使用、ファイルシステムアクセスやウェブブラウジングなどの他の機能との組み合わせが可能になる。

参考: [Hugging Face MCP Course Unit2](https://huggingface.co/learn/mcp-course/unit2/introduction)
