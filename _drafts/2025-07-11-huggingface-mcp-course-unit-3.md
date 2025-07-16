---
title: "Advanced MCP Development: Custom Workflow Servers"
date: "2025-07-11 23:16:34 +0900"
last_modified_at: "2025-07-11 23:16:34 +0900"
---

# Advanced MCP Development: Custom Workflow Servers

## Advanced MCP Development: Building Custom Workflow Servers for Claude Code
1.  **高度なMCP開発：Claude Code向けカスタムワークフローサーバーの構築**：このテキストは、Claude Codeを強化するカスタム開発ワークフローを構築するための、実用的なMCP（Model Context Protocol）サーバーの構築に関するものです。具体的には、PRエージェントワークフローサーバーを構築し、MCPプリミティブを活用して、Claude Codeをチームの状況やワークフローを理解できるようにすることを目指します。これには、コード変更に基づいて適切なPRテンプレートを自動選択したり、GitHub Actionsの実行を監視してフォーマットされたサマリーを提供したり、Slack経由でチームメンバーに自動的に通知したりすることが含まれます。

### What You’ll Build
2.  **PRエージェントワークフローサーバーの機能と利点**：構築するPRエージェントワークフローサーバーは、スマートなPR管理（コード変更に基づく自動PRテンプレート選択）、CI/CDモニタリング（Cloudflare Tunnelと標準化されたプロンプトによるGitHub Actionsの追跡）、チームコミュニケーション（Slack通知）といった機能を提供します。これにより、開発者はPR作成、Actionsの完了待ち、結果確認、チームメンバーへの通知といった手作業から解放され、Claude Codeがこれらのプロセスをインテリジェントに支援できるようになります。

### Real-World Case Study
Before: 開発者が手作業でPRを作成し、アクションの完了を待ち、結果を手作業で確認し、チームメンバーに通知する。

After: ワークフローサーバーに接続された Claude Code は、次のようなことができます：

- 変更されたファイルに基づいて適切な PR テンプレートを提案
- GitHub Actions の実行を監視し、フォーマットされたサマリーを提供
- デプロイの成功/失敗を Slack 経由でチームに自動通知
- Actions の結果に基づいて、チーム固有のレビュープロセスで開発者をガイド

### Key Learning Outcomes
- MCP のコアプリミティブ： 実践的な例を通してツールとプロンプトをマスターする
- MCP サーバー開発： 適切な構造とエラー処理で機能的なサーバーを構築する
- GitHub Actions の統合： Cloudflare Tunnel を使用して Webhook を受信し、CI/CD イベントを処理する
- Hugging Face Hub ワークフロー： LLM開発チームに特化したワークフローを作成
- マルチシステムインテグレーション： MCP
- Claude Code Enhancementを通じてGitHub、Slack、Hugging Face Hubを接続： クロードがあなたのチームの特定のワークフローを理解できるようにします。

### MCP Primitives in Action
3.  **主要な学習成果とMCPプリミティブ**：このユニットを通じて、MCPのコアプリミティブ（ツール、プロンプト、インテグレーション）を習得し、MCPサーバーの開発、GitHub Actionsとの連携、Hugging Face Hubワークフローの作成、GitHub、Slack、Hugging Face Hubといった複数のシステム間の連携を学びます。特に、ツールはClaudeが呼び出してファイルを分析し、テンプレートを提案する関数、プロンプトは一貫性のあるチームプロセスを実現する標準化されたワークフロー、インテグレーションは複雑な自動化のためにすべてのプリミティブを連携させることを指します。

### Module Structure
4.  **モジュール構成と必要な準備**：このユニットは、MCPサーバーの構築（PRテンプレート提案のためのツール）、GitHub Actionsとの連携（Cloudflare TunnelとプロンプトによるCI/CDモニタリング）、Slack通知（すべてのMCPプリミティブを統合したチームコミュニケーション）という3つのモジュールで構成されています。開始前に、ユニット1と2の完了、GitHub ActionsとWebhookの基本的な知識、テスト用のGitHubリポジトリへのアクセス、SlackワークスペースでのWebhook統合の作成が必要となります。

### Prerequisites
#### Claude Code Installation and Setup
5.  **Claude Codeのインストールとセットアップ**：このユニットでは、MCPサーバーの統合をテストするためにClaude Codeを使用する必要があります。そのため、公式のインストールガイドに従ってClaude Codeをインストールし、認証を完了する必要があります。これにより、構築したワークフロー自動化をテストし、Claude Codeと連携させることができます。最終的には、Claude Codeを強力なチーム開発アシスタントに変えるMCPサーバーを構築し、すべてのMCPプリミティブを実際に使用できるようになります。


  このモジュールの目的


  このモジュールでは、開発ワークフローを自動化するインテリジェentなPR（プルリクエスト）エージェントを構築します。具体的には、ロー
  カルのgitリポジトリと対話し、変更を分析し、PR作成を支援するツールを備えたMCP（Model Context Protocol）サーバーを実装します。

  CodeCraft StudiosでのPRカオス


  CodeCraft
  Studiosという架空の企業では、PRのレビュープロセスに多くの課題を抱えています。PRの説明が不十分であったり、変更内容が不明確であっ
  たりするため、開発チームは多くの時間を無駄にしています。このセクションでは、その具体的な問題点をスクリーンキャストで示します。

  あなたが構築するもの


  このモジュールで開発するPRエージェントは、git diffのようなローカルコマンドを実行してリポジトリの変更を分析し、PRのタイトル、要
  約、変更点を自動で提案します。これにより、開発者はより迅速かつ効率的にPRを作成できるようになります。完成したエージェントがどの
  ように機能するかのスクリーンキャストも含まれています。

  学習内容


   - MCPサーバーの構築: FastAPIを使用して、ツールを公開する基本的なMCPサーバーを構築します。
   - ツール開発: gitコマンドをラップして、Claudeがローカルのファイル変更を分析できるようにするツールを作成します。
   - 大規模出力の処理: git
     diffのような大量の出力を生成するコマンドを扱うための、出力の切り捨てや要約といった実践的なテクニックを学びます。
   - Claude Codeとの連携: 作成したMCPサーバーをClaude Codeデスクトップアプリケーションに接続し、テストします。



## Module 1: Build MCP Server
* このモジュールの目的: 開発ワークフローを自動化するインテリジェントなPR（プルリクエスト）エージェントを構築します。具体的には、ローカルのgitリポジトリと対話し、変更を分析し、PR作成を支援するツールを備えたMCP（Model Context Protocol）サーバーを実装します。

### The PR Chaos at CodeCraft Studios
* CodeCraft StudiosでのPRカオス:架空の企業「CodeCraft Studios」が抱える、非効率なPRレビュープロセスの課題をスクリーンキャストで紹介します。

#### Screencast: The PR Problem in Action 😬

### What You’ll Build
* あなたが構築するもの: ローカルのgit変更を分析し、PRのタイトルや要約を自動生成するエージェントを構築します。これにより、開発者のPR作成プロセスが効率化されます。

#### Screencast: Your PR Agent Saves the Day! 🚀
### What You Will Learn
* 学習内容: FastAPIを使ったMCPサーバーの構築、gitコマンドをラップするツールの開発、大規模な出力のハンドリング、そしてClaude Codeとの連携方法を学びます。

### Overview
### Getting Started
* はじめに: 開発環境のセットアップ（前提条件、スターターコードの入手）と、実装するタスクの概要、そして再利用性を意識した設計思想について説明します。

#### Prerequisites
開発を始めるための準備について説明します。


- 前提条件: Python 3.8以上、uv、Git、そしてClaude Codeデスクトップアプリが必要です。
- スターターコード: GitHubリポジトリからクローンして、基本的なプロジェクト構造と依存関係をセットアップします。
- あなたのタスク: server.pyに3つの主要なツール（`list_files`, `analyze_code`, `get_pr_details`）を実装することが目標です。
- 設計思想: ツールはシンプルで再利用可能なコンポーネントとして設計し、Claudeがこれらを組み合わせて複雑なタスクを実行できるようにします。

#### Starter Code
#### Your Task
#### Design Philosophy
### Testing Your Implementation
* 実装のテスト: ruffでのコード検証、pytestでの単体テスト、そして実際にClaude Codeと連携させて動作確認する、という3つのステップで実装をテストする方法を解説します。

実装したコードをテストするための3つのステップが示されています。


1. コードの検証: ruffを使ってコードの静的解析とフォーマットを行います。
2. 単体テストの実行: pytestを使用して、提供されている単体テストを実行し、ツールの基本的な動作を確認します。
3. Claude Codeでのテスト: 実際にClaude Codeに接続し、エージェントにタスクを依頼して、ツールが期待通りに呼び出されるかを確認します。

#### 1. Validate Your Code
#### 2. Run Unit Tests
#### 3. Test with Claude Code
### Common Patterns
* 一般的なパターン: エラーハンドリングや大規模な出力への対処法など、MCPサーバー開発における共通の設計パターンとベストプラクティスを紹介します。

MCPサーバーを開発する上での共通の設計パターンについて解説しています。


- ツールの実装パターン: ツールの定義、引数、docstringの書き方など、Claudeがツールを正しく理解し利用するためのベストプラクティスが示されています。
- エラーハンドリング: ツールが失敗した場合でも、エラー情報をJSON形式で返すことの重要性を説明しています。
- 大規模出力の扱い: git diffの出力が大きすぎてエラーになる問題への対処法として、出力を要約したり、ページネーションを実装したりするなどの実践的なテクニックを紹介しています。


#### Tool Implementation Pattern
#### Error Handling
#### Handling Large Outputs (Critical Learning Moment!) 
### Working Directory Considerations
* 作業ディレクトリに関する考慮事項: MCPサーバーが、Claudeが現在作業しているリポジトリのディレクトリで正しくコマンドを実行するための方法を解説します。
MCPサーバーはデフォルトで自身のインストールディレクトリでコマンドを実行しますが、Claudeが操作しているリポジトリのディレクトリでコマンドを実行する必要がある場合の対処法を説明しています。`mcp.get_context()` を使用してClaudeの作業ディレクトリを取得し、`subprocess.run` のcwd引数に渡す方法が示されています。


### Troubleshooting
* トラブルシューティング: 開発中によく遭遇するインポートエラーやGitエラー、JSON関連の問題など、具体的なエラーとその解決策をまとめています。

開発中によくある問題とその解決策をまとめています。インポートエラー、Gitエラー、JSON関連のエラー、トークン制限超過など、具体的な問題とその原因、対処法が記載されています。

### Next Steps
* 次のステップ: このモジュールでの学習内容を振り返り、ここで学んだスキルが他の自動化タスクにどう応用できるかを述べ、次のモジュール（GitHub Actions連携）へと繋げます。

このモジュールで達成したことと、次のステップについてまとめています。

#### What you’ve accomplished in Module 1:
- 達成事項: FastAPIを使ったMCPサーバーの構築、ローカルGitリポジトリと対話するツールの実装、大規模出力やエラーのハンドリング方法を学びました。

#### Key patterns you can reuse:
- 再利用可能なパターン: 学んだ知識は、ファイルシステム操作、データベースクエリ、API連携など、他の多くの自動化タスクに応用できます。

#### What to do next:
- 次のステップ: 次のモジュールでは、GitHub Actionsとの連携について学びます。

#### The story continues...
### Additional Resources

## Module 2: GitHub Actions Integration

### The Silent Failures Strike
### What You’ll Build
本モジュールでは、Module 1で作成したPR Agentを拡張し、GitHub ActionsのWebhookイベントを受信するためのWebhookサーバー、CI/CDのステータスを監視するツール、MCPプロンプトを追加する。これにより、静的なファイル分析（Module 1）と動的なチーム通知（Module 3）をつなぐリアルタイムな開発監視システムを構築する。

#### Screencast: Real-Time CI/CD Monitoring in Action! 🎯
CodeCraft Studiosは、Module 1で構築したPR Agentが開発者のプルリクエストを改善するのに役立ち喜んでいたが、CIのテスト失敗が見過ごされ、本番環境で重大なバグが発生した。チームは、GitHub Actionsを手動で確認するのは非効率的であることに気づき、問題を監視し、すぐに警告する自動化の必要性を痛感した。

### Learning Objectives
### Prerequisites
### Key Concepts
#### MCP Prompts
MCPプロンプトは、複雑なワークフローをガイドするための再利用可能なテンプレートであり、ユーザーが開始し、構造化されたガイダンスを提供する。ツール（Claudeが自動的に呼び出す）とは異なり、CI/CDの結果分析、標準化されたデプロイメントサマリの作成、体系的な障害のトラブルシューティングなどのユースケースに使用できる。

#### Webhook Integration
MCPサーバーは、Claudeとの通信を行うMCPサーバーと、GitHubイベントを受信するポート8080のWebhookサーバーの2つのサービスを実行する。WebhookサーバーはHTTPの複雑さを処理し、MCPサーバーはデータ分析とClaudeの統合に集中することで、関心の分離を実現している。

### Project Structure
### Implementation Steps
#### Step 1: Set Up and Run Webhook Server

##### How webhook event storage works:
Module 2の完了により、開発者はリアルタイム機能をMCPサーバーに追加し、コード変更の分析、CI/CDイベントのリアルタイム監視、MCPプロンプトによる一貫性のあるワークフローガイダンス、ファイルベースアーキテクチャによるWebhookイベントの処理が可能になった。

#### Step 2: Connect to Event Storage

#### Step 3: Add GitHub Actions Tools
開発者は、Module 1で作成したMCPサーバーとWebhookデータを接続し、GitHub Actionsの分析ツールを作成する。`get_recent_actions_events`ツールは、最近のイベントを読み取り、`get_workflow_status`ツールは、ワークフロー実行イベントをフィルタリングして、最新のステータスを表示する。

#### Step 4: Create MCP Prompts
4つのMCPプロンプト（`analyze_ci_results`, `create_deployment_summary`, `generate_pr_status_report`, `troubleshoot_workflow_failure`）を実装することで、開発者はClaudeとのインタラクションを標準化し、複雑なワークフローをガイドできる。プロンプトは、Claudeに従うべき明確な指示を含む文字列を返す。

#### Step 5: Test with Cloudflare Tunnel
Cloudflare Tunnelを使用してMCPサーバーをテストする際、MCPサーバー、Cloudflare Tunnel、GitHub Webhookを連携させることで、実際の開発環境をシミュレートできる。これにより、GitHubからのリアルタイムイベントに基づいて、Claudeがコード変更の分析とCI/CDイベントの監視を同時に行えることを確認する。

### Exercises
開発者は、カスタムワークフロープロンプトの作成、イベントフィルタリングの強化、通知システムの追加など、いくつかのエクササイズに取り組むことができる。一般的な問題としては、Webhookイベントの受信失敗、プロンプトの動作不良、Webhookサーバーの問題などが挙げられる。

#### Exercise 1: Custom Workflow Prompt
#### Exercise 2: Event Filtering
#### Exercise 3: Notification System
### Common Issues
#### Webhook Not Receiving Events
#### Prompt Not Working
#### Webhook Server Issues
### Next Steps
次のステップとして、ソリューションのレビュー、プロンプトの実験、Module 1のファイル分析ツールとModule 2のイベント監視を組み合わせた統合テストを行う。そして、Module 3に進み、Slack統合によるチーム通知機能を追加し、自動化パイプラインを完成させる。

#### Key achievements in Module 2:
#### What to do next:
#### The story continues…
### Additional Resources

## Module 3: Slack Notification
### The Communication Gap Crisis
**コミュニケーションギャップの解消：** CodeCraft Studiosの開発チームは、プルリクエストの説明が改善され、CI/CDの失敗も即座に検知できるようになりました。しかし、週末にバックエンドチームが修正したAPI統合の問題をフロントエンドチームが気づかず、12時間も無駄にするという新たな問題が発生しました。また、デザインチームが完成させた新しいユーザーオンボーディングのイラストも、フロントエンドチームに伝わらず、一時的なデザインが使用されるという情報のサイロ化が発生しました。

### What You’ll Build
**Slack通知システムの構築：** このモジュールでは、チーム全体に重要な情報を自動的に通知するインテリジェントなSlack通知システムを構築します。これには、CI/CDイベントに関するSlackメッセージを送信するためのSlack webhookツール、通知のフォーマットを行うプロンプト、およびMCPプリミティブ全体の統合が含まれます。

CI/CDパイプラインの状況（成功・失敗）を、状況に応じたメッセージとして自動でSlackに通知するシステムを構築します。完成した自動化システムのデモ動画も紹介されています。

#### Screencast: The Complete Automation System! 🎉
### Learning Objectives
このモジュールを通じて、MCPサーバーにSlack通知ツールを追加する方法、プロンプトを使ってメッセージを整形する方法、そしてCI/CDワークフローにこれらを統合する方法を学びます。

### Prerequisites
前のモジュールで完成させたMCPサーバー、Slackワークスペース、そしてGitHubリポジトリの準備が必要であると説明しています。

### Key Concepts
Webhook、MCPサーバー、Slackが連携する「MCP統合パターン」や、Slackメッセージで見栄えを良くするためのMarkdown記法について解説しています。

#### MCP Integration Pattern
#### Slack Markdown Formatting
**Slack Markdownの活用：** Slackメッセージをリッチに表現するために、Slack Markdownを使用します。太字、イタリック、コードブロック、引用、絵文字、リンクなどの書式設定を活用し、情報を分かりやすく整理します。

### Project Structure
演習で使うプロジェクトのディレクトリ構成（`starter`と`solution`）について説明しています。

### Implementation Steps
#### Step 1: Set Up Slack Integration (10 min)
1.  **Slack連携のセットアップ**: Slackアプリを作成し、通知を送るためのWebhook URLを取得します。
#### Step 2: Add Slack Tool (15 min)
2.  **Slackツールの追加**: `send_slack_notification`というツールをMCPサーバーに追加します。

**Slackツールの実装：** Slackに通知を送信するためのMCPツール`send_slack_notification`を実装します。このツールは、環境変数からWebhook URLを読み取り、SlackのWebhookにHTTPリクエストを送信してメッセージを投稿します。エラー処理も含まれます。

#### Step 3: Create Formatting Prompts (15 min)
3.  **プロンプトの作成**: CIの失敗・成功を通知するためのメッセージを生成するプロンプトを作成します。

**MCPツールとプロンプトの統合：** GitHub ActionsのイベントをSlackメッセージにフォーマットするために、`format_ci_failure_alert`と`format_ci_success_summary`という2つのMCPプロンプトを実装します。これらのプロンプトは、CI/CDの失敗や成功をチームに分かりやすく通知するために使用されます。

#### Step 4: Test Complete Workflow (10 min)
4.  **ワークフローのテスト**: Webhookの受信からSlack通知まで、一連の流れをテストします。

**完全なワークフローのテスト：** Module 2からのWebhookキャプチャ、このモジュールからのプロンプトフォーマット、およびSlack通知を組み合わせて、完全なMCPワークフローをテストします。GitHub Webhookからのイベントをシミュレートし、Claudeにイベントをチェックさせ、プロンプトを使用してフォーマットさせ、Slackツールを使用してメッセージを送信させます。

#### Step 5: Verify Integration (5 min)
5.  **統合の検証**: `curl`コマンドを使い、手動でGitHubのWebhookイベントをシミュレートして動作確認する方法を説明しています。

### Example Workflow in Claude Code
ユーザーがAIアシスタントであるClaude Codeに指示を出し、最近のイベントを確認させ、整形されたメッセージをSlackに送信させるまでの対話例を示しています。

### Expected Slack Message Output
CI/CDの失敗時と成功時に、実際にSlackに投稿されるメッセージのサンプルを提示しています。

### Common Issues
Webhook URLの設定ミス、メッセージフォーマットのエラー、ネットワークエラーなど、実装中によく発生する問題とその解決策をまとめています。

#### Webhook URL Issues
#### Message Formatting
#### Network Errors
### Key Takeaways
**実践的な応用例：** このモジュールは、外部APIとの統合、インテリジェントなメッセージフォーマット、MCPプリミティブの統合など、実際の開発チームが利用できる実用的な自動化ツールを構築する方法を示しています。特に、コミュニケーションギャップを解消し、開発効率を向上させるという点に重点が置かれています。

### Next Steps
#### What to do next:
#### The transformation is complete!
### Additional Resources

## Unit 3 Solution Walkthrough: Building a Pull Request Agent with MCP
### **Overview (概要)**
このユニットで完成させたPRエージェントの最終形を紹介します。単なるコード生成ツールではなく、**ツール、リソース、プロンプトを動的に組み合わせ**、開発ワークフロー全体を支援する高度なAIアシスタントです。PRの内容を理解し、適切なテンプレートを提案し、CI/CDの結果を監視・通知することで、開発者の負担を軽減します。

### **Architecture Overview (アーキテクチャ概要)**
エージェントのシステム全体の構造を図解しています。中心には**MCPサーバー**があり、これがClaude Code（AIアシスタント）と各種コンポーネントとの間の通信を仲介します。
* ***Tools**: `analyze_file_changes`のように、具体的なアクションを実行する関数。
* ***Resources**: `coding-standards.md`のような、Claudeが判断の根拠とする静的な情報源。
* ***Prompts**: Claudeに特定のタスク（例: CI失敗報告の作成）を指示するための定型的な指示文。
* ***External Services**: GitHubからのWebhookを受け取り、Slackへ通知を送信するなど、外部APIと連携します。

### **Module 1: Build MCP Server (モジュール1: MCPサーバーの構築)**
エージェントの基盤となるMCPサーバーの実装を解説します。

### **What We’re Building**: PRの変更内容に基づいて、最適なPRテンプレートを提案するサーバーを構築します。
#### **Key Components**:
1.  **Server Initialization**: MCP SDKを使い、ツールを登録してサーバーを起動します。
2.  **File Analysis Tool (`analyze_file_changes`)**: `git diff`の結果を解析し、変更されたファイルの種別、追加/削除された行数、テストやドキュメントの変更が含まれるかといった構造化データを返します。
3.  **Template Management**: `get_pr_templates`で利用可能なテンプレートの一覧を、`suggest_template`で分析結果に基づいた最適なテンプレートをClaudeに提案させます。
#### **How Claude Uses These Tools**: Claudeはまず`analyze_file_changes`でPRの概要を把握し、次に`get_pr_templates`で選択肢を得て、最後に分析結果とテンプレートのメタデータを基に`suggest_template`を呼び出し、最終的な推薦を行います。

### **Module 2: Smart File Analysis (モジュール2: スマートなファイル分析)**
Claudeがより文脈に応じた判断を下せるように、**リソース**の概念を導入します。
#### **What We’re Building**: プロジェクト固有のルールや過去の文脈を理解する能力をエージェントに追加します。
#### **Key Components**:
1.  **Resource Registration**: `file://`, `git://`, `team://`のようなカスタムURIスキームを使い、様々な情報源をリソースとして登録します。
2.  **Project Context Resources**: `project-context/`ディレクトリに`coding-standards.md`（コーディング規約）や`architecture.md`（設計思想）などを配置し、Claudeがこれらを参照できるようにします。
3.  **Git History Analysis**: 過去のコミットメッセージのパターンを分析し、「今回の変更は過去のバグ修正と類似している」といった洞察を得させます。
#### **Enhanced Decision Making**: これらのリソースを読むことで、Claudeは単なるファイル種別だけでなく、「この変更は重要なアーキテクチャに触れているため、シニア開発者のレビューが必要」といった、より高度な判断が可能になります。

### **Module 3: GitHub Actions Integration (モジュール3: GitHub Actions連携)**
    CI/CDプロセスとエージェントを連携させます。
#### **What We’re Building**: GitHub Actionsの実行結果を自動的に分析し、要約やフォローアップタスクを作成するシステムを構築します。
#### **Key Components**:
1.  **Webhook Server**: GitHubから`workflow_run`や`check_run`といったイベントのWebhookを受け取るための軽量なサーバーを立てます。
2.  **Prompt Templates**: 「"Analyze CI Results"（CI結果を分析せよ）」や「"Draft Team Notification"（チームへの通知文を起草せよ）」といった標準化されたプロンプトを用意し、どのようなイベントに対しても一貫した品質の出力を保証します。
3.  **Event Processing Pipeline**: Webhookで受け取ったJSONデータをプロンプトへの入力として整形し、Claudeに処理させ、その結果を次のアクション（例: Slack通知）に渡す一連の流れを構築します。

### **Module 4: Hugging Face Hub Integration (モジュール4: Hugging Face Hub連携)**
    Hugging Face Hub上でのモデルやデータセット開発に特化した機能を追加します。
#### **What We’re Building**: LLMやデータセットに関するPRを専門的に扱う能力をエージェントに付与します。
#### **Key Components**:
1.  **Hub-Specific Tools**: `analyze_model_changes`（モデルファイルの変更を検知）、`generate_model_card`（モデルカードを自動生成）といった専門ツールを実装します。
2.  **Hub Resources**: `hub://model-cards/`（モデルカードのテンプレート）や`hub://license-info/`（ライセンス情報）といったHub固有のリソースにアクセスできるようにします。
3.  **LLM-Specific Prompts**: 「"Generate Benchmark Summary"（ベンチマークの要約を生成せよ）」など、LLM開発特有のタスクに対応したプロンプトを用意します。

#### **Hub-Specific Workflows**: これらを組み合わせることで、「モデルのアーキテクチャが変更されたPRでは、自動でモデルカードのベンチマーク欄を更新し、ライセンスの互換性をチェックする」といった高度な自動化を実現します。

### **Module 5: Slack Notification (モジュール5: Slack通知)**
チームへのコミュニケーションを自動化・効率化します。

#### **What We’re Building**: 適切な情報を、適切なタイミングで、適切な担当者・チャンネルに通知するインテリジェントな通知システムを構築します。
#### **Key Components**:
1.  **Communication Tools**: `send_slack_message`ツールを実装します。
2.  **Team Resources**: `team://members/`リソースに開発者のプロフィールや通知設定（「Aさんは緊急時のみメンション」など）を保存し、Claudeがこれを参照して通知方法を調整できるようにします。
3.  **Notification Prompts**: 「"Escalate if Critical"（緊急度が高ければエスカレーションせよ）」といったプロンプトで、状況に応じた通知の使い分けを可能にします。
#### **Intelligent Routing**: これらの機能により、「CIの失敗が本番環境に影響する可能性がある場合、PRの担当者とインフラチームのチャンネルに、緊急度高のフォーマットで通知する」といった賢い通知ルーティングが実現します。

### **Testing Strategy (テスト戦略)**
システムの信頼性を担保するためのテスト手法を解説します。

#### **Unit Tests**: `test_tools.py`などで各ツールが期待通りに動作するかを個別に検証します。
#### **Integration Tests**: `test_workflow.py`などで、ツール、リソース、プロンプトが連携して一連のワークフローを正しく実行できるかを確認します。
#### **Test Structure**: `fixtures/`ディレクトリに`sample_events.json`（GitHubからのWebhookのサンプル）などを置き、テストの再現性を高めます。

### **Running the Solution (ソリューションの実行)**
ローカル環境でエージェントを動かすための具体的な手順を示します。`uv run server.py`でMCPサーバーを、`python webhook_server.py`でWebhook受付サーバーを起動し、`cloudflared`などを使って外部（GitHub）からのアクセスを可能にする方法を説明します。

### **Common Patterns and Best Practices (共通パターンとベストプラクティス)**
効果的なMCPエージェントを開発するための設計原則をまとめています。
#### **Tool Design**: ツールは一つの責務に特化させ、再利用しやすくテストしやすいように設計する。
#### **Resource Organization**: プロジェクトの知識を構造化してリソースとして提供し、AIの判断根拠を明確にする。
#### **Prompt Engineering**: 指示は明確かつ具体的でありながら、AIが自律的に判断する余地を残すようにプロンプトを作成する。

### **Troubleshooting Guide (トラブルシューティングガイド)**
「Webhookが届かない」「Claudeが期待通りにツールを使わない」といった一般的な問題と、その原因究明のためのデバッグ手法を紹介します。

### **Next Steps and Extensions (次のステップと拡張)**
このエージェントをさらに発展させるためのアイデアを提示します。例えば、JiraやAsanaと連携してタスクを自動起票する機能や、PRの変更内容に基づいてレビュアーを自動で推薦する機能などが挙げられています。

### **Conclusion (結論)**
このユニットを通じて、MCPがいかにしてモジュール化され、スケーラブルで、かつインテリジェントなAIエージェントの構築を可能にするかを示しました。個別のツールや情報を組み合わせることで、複雑な開発ワークフロー全体を自動化できるMCPの強力さを強調して締めくくっています。
