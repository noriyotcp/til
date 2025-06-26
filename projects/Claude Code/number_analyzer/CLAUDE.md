# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rubyを使い、リファクタリング対象のコード生成からClaude Codeに任せる。Claude Codeのコード生成能力とリファクタリング能力の両方を体験できる、とても良いプロジェクトになります。

では、具体的な手順を詰めていきましょう。

### **ステップ1：リファクタリング対象の「少しイケてない」Rubyコードを生成させる**

まず、わざと「改善の余地がある」コードをClaude Codeに作らせます。完成された綺麗なコードが出てきてしまうとリファクタリングの練習にならないため、プロンプトで少し工夫するのがポイントです。

**お題：**
数値の配列を受け取り、その**合計、平均、最大値、最小値**を計算して表示するRubyスクリプト

**手順：**
1.  任意の作業ディレクトリを作成し、ターミナルでそのディレクトリに移動します。
2.  ターミナルで `claude` と入力して、Claude Codeを起動します。
3.  起動したら、Claude Codeに対して次のようなプロンプトを入力します。

> あなたはRuby初心者という設定で、以下の要件を満たすRubyスクリプトを `number_analyzer.rb` というファイル名で作成してください。
>
> **要件：**
> *   数値の配列をハードコードで持つ
> *   その配列の合計、平均、最大値、最小値を計算して出力する
> *   **重要：** Rubyの便利な組み込みメソッド（`sum`, `max`, `min`など）はあえて使わず、基本的なループ処理（`each`など）を使って計算ロジックを実装してください。変数名も `arr` や `val` のようなシンプルなものにしてください。

このように依頼することで、意図的に冗長で、変数名も素っ子なし、リファクタリングのしがいがあるコードを生成させることができます。

---

### **ステップ2：生成されたコードをリファクタリングさせる**

ステップ1で `number_analyzer.rb` が無事に生成されたら、いよいよリファクタリングの依頼をします。

**手順：**
1.  （Claude Codeを続けて使っている場合はそのままでOKです）Claude Codeが `number_analyzer.rb` を認識している状態で、次のようなプロンプトを入力します。

> `number_analyzer.rb` のコードを、もっとRubyらしく、プロフェッショナルな書き方にリファクタリングしてください。
>
> **改善してほしい点：**
> *   ループ処理を使っている箇所を、Rubyの適切な組み込みメソッド（`sum`, `max`, `min`など）に置き換えて、コードを簡潔にしてください。
> *   変数名を、`numbers` や `average` のように、より意味が分かりやすい名前に変更してください。
> *   もし可能であれば、計算ロジックをメソッドとして切り出してください。

**Claude Codeの動き（予測）：**
この指示を受け取ると、Claude Codeは `number_analyzer.rb` の内容を読み込み、指示に従ってリファクタリング案を提示してきます。多くの場合、変更前と変更後のコードを差分（diff）形式で見せてくれるので、どのような変更が行われるかを明確に確認できます。

**最終ステップ：**
変更内容に問題がなければ、Claude Codeに「適用して」「`accept`」などと伝えて、ファイルを実際に書き換えてもらいましょう。

---

まずはこの**ステップ1**から試してみてはいかがでしょうか。Claude Codeがどのような「初心者風」のコードを生成してくるかを見るだけでも面白い体験になるはずです。

## Development Commands

Ruby実行: `bundle exec number_analyzer` (デフォルト) / `bundle exec number_analyzer 1 2 3 4 5` (引数指定)
依存関係インストール: `bundle install`
テスト実行: `rspec`
Lint実行: `rubocop`
コミットメッセージ生成: `/project:commit-message`
Web検索: `/project:gemini-search`

## Architecture

現在のプロジェクト構成（Ruby Gem構造）：
- `lib/number_analyzer.rb` - NumberAnalyzerクラス（純粋な統計計算ライブラリ）
- `lib/number_analyzer/cli.rb` - NumberAnalyzer::CLIクラス（コマンドライン処理）
- `bin/number_analyzer` - 実行可能ファイル（エントリーポイント）
- `number_analyzer.gemspec` - Gem定義ファイル
- `Gemfile` - gemspec参照による依存関係管理
- `spec/number_analyzer_spec.rb` - NumberAnalyzerクラスのテストスイート（17のテストケース）
- `spec/number_analyzer/cli_spec.rb` - NumberAnalyzer::CLIクラスのテストスイート（10のテストケース）
- `spec/spec_helper.rb` - RSpec設定ファイル
- `.rspec` - RSpecコマンドライン設定
- `.rubocop.yml` + `.rubocop_todo.yml` - コードスタイル設定
- `README.md` - Gem使用方法とAPI説明
- `CLAUDE.md` - Claude Codeへの開発ガイダンス
- `.claude/commands/commit-message.md` - コミットメッセージ生成コマンド
- `.claude/commands/gemini-search.md` - Web検索統合コマンド

実装済み統計機能：
- **基本統計**: 合計、平均、最大値、最小値
- **中央値（median）**: 奇数/偶数要素対応、未ソート配列対応、percentile(50)による統一実装
- **最頻値（mode）**: 単一/複数モード、モードなし検出
- **分散（variance）**: TDDによる完全な実装、小数点以下2桁表示
- **標準偏差（standard deviation）**: 数学的に正確な計算、分散の平方根
- **パーセンタイル（percentile）**: 線形補間法による任意の％点計算（0-100）
- **四分位数（quartiles）**: Q1,Q2,Q3をハッシュで提供、percentileとmedianの統一設計
- **四分位範囲（IQR）**: Q3-Q1による散布度測定、外れ値検出の基盤機能

技術的特徴：
- **Ruby Gem準拠**: 標準的なGem構造（lib/, bin/, spec/）による配布可能なパッケージ
- **SRP準拠**: 単一責任原則に従ったクラス分離（統計計算とCLI処理を分離）
- **名前空間設計**: NumberAnalyzer::CLIによる衝突回避とモジュール性
- **クリーンアーキテクチャ**: bin → CLI → NumberAnalyzer の明確な依存関係
- **Ruby言語活用**: 組み込みメソッド（sum, max, min, tally, sort）の効果的利用
- **コード品質**: 意味のある変数名、適切なメソッド分割、ハッシュベースのデータ構造
- **テスト戦略**: 包括的なRSpecテストスイート（統計機能41例 + CLI機能10例）
- **スタイル準拠**: RuboCop完全準拠（specファイル除外設定、パラメータリスト最適化）
- **依存関係管理**: gemspecによる標準的なGem依存関係定義

## プロジェクト完成状況

✅ **リファクタリング + Ruby Gem化 + パーセンタイル・四分位数・IQR機能 完全完了**
- 初心者風コード → プロフェッショナルなRuby Gem
- 11の統計指標を計算・表示する完全な分析ツール
- 51個のテストケース（統計41例 + CLI10例）で包括的品質保証
- TDD（Red-Green-Refactor）による統計機能の段階的実装
- Endless Method（`def median = percentile(50)`）による美しい統一設計
- 線形補間法による数学的に正確なパーセンタイル計算
- RuboCop完全準拠のクリーンなコードベース
- 標準的なRuby Gem構造による配布可能なパッケージ
- `bundle exec number_analyzer`での実行対応完了

## Next Steps (Optional)

高品質な統計分析ツールが完成しましたが、さらなる拡張が可能です：

### 実用化への発展計画

#### Phase 1: CLI機能追加（現在の構造維持）✅ 完了
- [x] コマンドライン引数での数値入力対応（`ruby cli.rb 1 2 3 4 5`）
- [x] 入力検証とエラーハンドリング（数値以外、空入力等）
- [x] デフォルト配列へのフォールバック機能
- [x] CLI機能の包括的テスト追加（10のテストケース）

#### Phase 2: Ruby Gem構造化（ローカル配布用）✅ 完了

**最終的なディレクトリ構造：**
```
number_analyzer/
├── lib/
│   ├── number_analyzer.rb          # NumberAnalyzerクラス（独立ライブラリ）
│   └── number_analyzer/
│       └── cli.rb                  # NumberAnalyzer::CLIクラス
├── bin/
│   └── number_analyzer             # 実行可能ファイル（shebang付き）
├── spec/
│   ├── number_analyzer_spec.rb     # NumberAnalyzer単体テスト
│   ├── number_analyzer/
│   │   └── cli_spec.rb             # NumberAnalyzer::CLI単体テスト
│   └── spec_helper.rb
├── number_analyzer.gemspec         # Gem定義
└── README.md                       # Gem使用方法
```

**依存関係の方向：**
```
bin/number_analyzer (エントリーポイント)
 ↓ requires
NumberAnalyzer::CLI (コマンドライン処理)
 ↓ requires  
NumberAnalyzer (純粋な統計計算ライブラリ)
```

**実装ステップ：** ✅ 全完了
- [x] ステップ1: ディレクトリ構造作成（`lib/number_analyzer`, `bin`, `spec/number_analyzer`）
- [x] ステップ2: ファイル移動（`number_analyzer.rb` → `lib/`、`cli.rb` → `lib/number_analyzer/`）
- [x] ステップ3: 名前空間調整（`class CLI` → `class NumberAnalyzer::CLI`）
- [x] ステップ4: require文調整（相対パス、名前空間対応）
- [x] ステップ5: `bin/number_analyzer`実行ファイル作成
- [x] ステップ6: `number_analyzer.gemspec`定義ファイル作成
- [x] ステップ7: テスト構造更新（`spec/number_analyzer/cli_spec.rb`）
- [x] ステップ8: `bundle exec number_analyzer`での実行確認
- [x] ステップ9: README.md作成（Gemとしての使用方法）

#### Phase 3: 統計機能拡張（推奨次ステップ）
**目標**: 数学的に完全な統計分析ツールへの発展

**実装予定機能：**
- [x] 分散（variance）の計算と表示 ✅ 完了
- [x] 四分位数（Q1, Q2, Q3）の算出 ✅ 完了
- [x] カスタムパーセンタイル計算機能 ✅ 完了
- [x] 四分位範囲（IQR: Interquartile Range）の計算 ✅ 完了
- [ ] 度数分布とヒストグラム的な分析
- [ ] 外れ値検出（IQRベース）

**技術的改善：**
- [x] 統計結果のハッシュ構造を拡張 ✅ 完了（varianceキー追加）
- [x] より詳細な出力フォーマット ✅ 完了（分散表示追加）
- [x] 新機能の包括的テスト追加 ✅ 完了（15のpercentile・quartilesテスト）
- [x] 統一的な計算アーキテクチャ ✅ 完了（percentileベースの設計）
- [x] README.mdに新機能の使用例追加 ✅ 完了（IQR機能追加）

### 発展的な統計機能
- [x] 中央値（median）の計算機能 ✅ 完了
- [x] 最頻値（mode）の検出機能 ✅ 完了  
- [x] 標準偏差（standard deviation）の算出 ✅ 完了
- [x] 分散（variance）の表示 ✅ 完了
- [x] 四分位範囲（IQR）の計算 ✅ 完了
- [ ] 偏差値の算出

### パフォーマンス向上
- [ ] 大規模データセットでの性能テスト
- [ ] メモリ効率の最適化
- [ ] 並列処理による高速化

### ユーザーインターフェース
- [x] コマンドライン引数からの数値入力 ✅ 完了
- [ ] ファイルからのデータ読み込み機能
- [ ] インタラクティブな操作モード

### データ可視化
- [ ] ヒストグラム表示機能
- [ ] 統計サマリーの表形式出力
- [ ] グラフ生成ライブラリとの連携

これらの機能追加により、より実用的な統計解析ツールへと発展させることができます。

## Important Reminders

- **commit messages はマークダウンブロックの中に書くこと** (推奨: `/project:commit-message` コマンド使用)
- **新機能実装完了後は必ずREADME.mdの更新を確認すること**
  - Features セクションへの機能追加
  - Usage例の更新
  - Example Output の更新
- RSpec構文は `-e "pattern"` が基本（`::` は間違い）
- TDDでは既存実装を理解してからテストを書く
- 線形補間法を考慮したテスト期待値の設定
