---
title: "2025-06-23"
date: "2025-06-23 23:40:26 +0900"
last_modified_at: "2025-06-23 23:45:35 +0900"
---

# 2025-06-23

## Hugging Face Agents Course 時系列まとめ＆各ユニット要約

### 2025年2月

#### Unit 1: Introduction & Fundamentals
- **2025-02-11-huggingface-agents-course-unit0-1.md**
  - AIエージェントの基礎（LLM、ツール、アクション、観察サイクル）を体系的に学ぶ入門ユニット。
  - smolagents, LangGraph, LlamaIndexなど主要フレームワークの概要と、実践的なエージェント構築・公開方法を解説。
  - 「思考→行動→観察」サイクルやReActパターン、ツール連携の重要性を強調。
  - Pythonでのツール定義例や、Hugging Face Spacesでの実装例も紹介。

#### Bonus Unit 1: LLMファインチューニング（関数呼び出し）
- **2025-02-20-huggingface-agents-course-bonus-unit1.md**
  - LLMの関数呼び出し（Function Calling）能力をLoRAでファインチューニングする方法を解説。
  - モデルの訓練段階、LoRAの仕組み、データセットの前処理、Colabでの実践手順を紹介。
  - <think>や<tool_call>などの特殊トークン設計、トークナイザーのカスタマイズもカバー。
  - 実際にモデルをHubにプッシュするまでの流れを体験できる。

#### Unit 2.1: smolagentsフレームワーク
- **2025-02-27-huggingface-agents-course-unit2-1-memo.md**
  - smolagentsの特徴（シンプル・コードファースト・柔軟なLLMサポート）と、CodeAgent/ToolCallingAgentの違いを解説。
  - ツールの作成・共有方法、RAG（検索拡張生成）、マルチエージェント、ビジョン/ブラウザエージェントの実装例を紹介。
  - OpenTelemetryやLangfuseによる可観測性、セキュリティ設定、クイズによる理解度チェックも含む。

### 2025年4月

#### Unit 2.2: LlamaIndexフレームワーク
- **2025-04-13-huggingface-agents-course-unit2-2-memo.md**
  - LlamaIndexのコンポーネント設計（プロンプト、モデル、データベース）、RAGパイプライン構築、ツール/エージェント/ワークフローの使い方を解説。
  - QueryEngineやFunctionTool、Toolspecs、ユーティリティツールの活用例。
  - マルチエージェントワークフローや状態管理、型ヒントを活かした複雑な処理の自動化も紹介。

#### Unit 2.3: LangGraphフレームワーク
- **2025-04-13-huggingface-agents-course-unit2-3-memo.md**
  - LangGraphの特徴（有向グラフによるフロー制御、状態管理、可視化、ロギング、人間参加型ワークフロー）を解説。
  - メール仕分けやドキュメント分析エージェントの例を通じて、ノード・エッジ・状態グラフの設計方法を学ぶ。
  - Visionモデルやツール連携、ReActパターンの応用例もあり。

#### Unit 3: Agentic RAGユースケース
- **2025-04-22-huggingface-agents-course-unit3-memo.md**
  - RAG（Retrieval Augmented Generation）を活用したパーティー支援エージェントAlfredの構築例。
  - ゲスト情報検索、Web検索、天気情報、Hugging Face Hub統計などのツール統合。
  - smolagents/LlamaIndex/LangGraphの各フレームワークでの実装例、会話記憶や複数ツールの連携方法も解説。

#### Unit 4: Final Project/GAIAベンチマーク
- **2025-04-29-huggingface-agents-course-unit4-memo.md**
  - GAIAベンチマーク（推論・マルチモーダル・ツール連携など現実世界タスク）でAIエージェントを評価・認定。
  - 難易度別の問題構成、APIを使った自動評価、リーダーボード参加方法を解説。
  - 実践的なエージェント開発・提出・スコアリングの流れを体験できる。

### 2025年6月

#### Bonus Unit 2: 可観測性・評価
- **2025-06-19-huggingface-agents-course-bonus-unit2.md**
  - AIエージェントの可観測性（OpenTelemetry, Langfuse等）と評価（オンライン/オフライン、ユーザーフィードバック、LLM-as-a-Judge）を体系的に解説。
  - メトリクス監視、トレース/スパン、ベンチマークデータセットによる自動評価、A/Bテストや継続的改善の実践例も紹介。

#### Bonus Unit 3: ゲーム応用（ポケモンバトル）
- **2025-06-21-huggingface-agents-course-bonus-unit3.md**
  - LLM/エージェントをゲーム（特にポケモンバトル）に応用する実践例。
  - LLMベースNPCとAgentic AIの違い、poke-envやPokémon Showdownとの連携、LLMAgentBase/TemplateAgentの設計例。
  - Twitch配信やHugging Face SpaceでのAIバトル体験、独自エージェントの実装・登録方法も解説。
