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
ファイル読み込み: `bundle exec number_analyzer --file data.csv` / `bundle exec number_analyzer -f data.json`
依存関係インストール: `bundle install`
テスト実行: `rspec`
Lint実行: `rubocop`
コミットメッセージ生成: `/project:commit-message`
Web検索: `/project:gemini-search`

## Architecture

現在のプロジェクト構成（Ruby Gem構造 + 責任分離アーキテクチャ）：
- `lib/number_analyzer.rb` - NumberAnalyzerクラス（純粋な統計計算ライブラリ）
- `lib/number_analyzer/cli.rb` - NumberAnalyzer::CLIクラス（コマンドライン処理）
- `lib/number_analyzer/file_reader.rb` - NumberAnalyzer::FileReaderクラス（ファイル読み込み機能）
- `lib/number_analyzer/statistics_presenter.rb` - NumberAnalyzer::StatisticsPresenterクラス（表示責任）
- `bin/number_analyzer` - 実行可能ファイル（エントリーポイント）
- `number_analyzer.gemspec` - Gem定義ファイル
- `Gemfile` - gemspec参照による依存関係管理
- `spec/number_analyzer_spec.rb` - NumberAnalyzerクラスのテストスイート（69のテストケース）
- `spec/number_analyzer/cli_spec.rb` - NumberAnalyzer::CLIクラスのテストスイート（15のテストケース）
- `spec/number_analyzer/file_reader_spec.rb` - NumberAnalyzer::FileReaderクラスのテストスイート（27のテストケース）
- `spec/number_analyzer/statistics_presenter_spec.rb` - NumberAnalyzer::StatisticsPresenterクラスのテストスイート（13のテストケース）
- `spec/spec_helper.rb` - RSpec設定ファイル
- `.rspec` - RSpecコマンドライン設定
- `.rubocop.yml` + `.rubocop_todo.yml` - コードスタイル設定
- `README.md` - Gem使用方法とAPI説明
- `CLAUDE.md` - Claude Codeへの開発ガイダンス
- `.claude/commands/commit-message.md` - コミットメッセージ生成コマンド
- `.claude/commands/gemini-search.md` - Web検索統合コマンド
- `spec/fixtures/sample_data.csv` / `spec/fixtures/sample_data.json` / `spec/fixtures/sample_data.txt` - テスト用サンプルデータファイル

実装済み統計機能：
- **基本統計**: 合計、平均、最大値、最小値
- **中央値（median）**: 奇数/偶数要素対応、未ソート配列対応、percentile(50)による統一実装
- **最頻値（mode）**: 単一/複数モード、モードなし検出
- **分散（variance）**: TDDによる完全な実装、小数点以下2桁表示
- **標準偏差（standard deviation）**: 数学的に正確な計算、分散の平方根
- **パーセンタイル（percentile）**: 線形補間法による任意の％点計算（0-100）
- **四分位数（quartiles）**: Q1,Q2,Q3をハッシュで提供、percentileとmedianの統一設計
- **四分位範囲（IQR）**: Q3-Q1による散布度測定、外れ値検出の基盤機能
- **外れ値検出（outliers）**: IQR * 1.5ルールによる統計的外れ値判定、CLI表示対応
- **偏差値（deviation scores）**: TDDによる完全実装、平均50基準の標準化値、エッジケース対応
- **ファイル読み込み（file input）**: CSV/JSON/TXT形式対応、--file/-fオプション、包括的エラーハンドリング
- **度数分布（frequency distribution）**: Ruby `tally`メソッド活用、値ごとの出現回数計算、実用データ分析対応
- **ヒストグラム表示（histogram display）**: ASCII art可視化（■文字）、自動スケーリング、StatisticsPresenter統合、CLI自動表示

技術的特徴：
- **Ruby Gem準拠**: 標準的なGem構造（lib/, bin/, spec/）による配布可能なパッケージ
- **SRP準拠**: 単一責任原則に従ったクラス分離（統計計算・CLI処理・ファイル読み込み・表示責任を分離）
- **名前空間設計**: NumberAnalyzer::CLI、NumberAnalyzer::FileReader、NumberAnalyzer::StatisticsPresenterによる衝突回避とモジュール性
- **クリーンアーキテクチャ**: bin → CLI → NumberAnalyzer ← StatisticsPresenter の明確な依存関係
- **Ruby言語活用**: 組み込みメソッド（sum, max, min, tally, sort）+ Ruby慣例（Float(exception: false)）の効果的利用
- **コード品質**: 意味のある変数名、適切なメソッド分割、ハッシュベースのデータ構造、単一責任メソッド
- **テスト戦略**: 包括的なRSpecテストスイート（統計機能66例 + CLI機能15例 + ファイル読み込み27例 + 表示機能11例）
- **スタイル準拠**: RuboCop高準拠（主要違反解消、残存2件は機能上正当）
- **依存関係管理**: gemspecによる標準的なGem依存関係定義

## プロジェクト完成状況

✅ **リファクタリング + Ruby Gem化 + 統計機能拡張 + データ可視化 + コード品質改善 完全完了**
- 初心者風コード → プロフェッショナルなRuby Gem（enterprise-ready quality）
- 15の統計指標を計算・表示する完全な分析ツール + ファイル入力対応 + **ヒストグラム可視化**
- 121個のテストケース（統計69例 + CLI15例 + ファイル読み込み27例 + 表示13例）で包括的品質保証
- **Phase 5完了**: 度数分布 + ASCII artヒストグラム表示機能
- TDD（Red-Green-Refactor）による統計機能の段階的実装
- Endless Method（`def median = percentile(50)`）による美しい統一設計
- 線形補間法による数学的に正確なパーセンタイル計算
- **Phase 4品質改善完了**: RuboCop主要違反解消、責任分離アーキテクチャ
- 標準的なRuby Gem構造による配布可能なパッケージ
- `bundle exec number_analyzer`での実行対応完了
- CSV/JSON/TXT形式ファイル読み込み機能完全実装
- **企業レベルのコード品質**: 単一責任原則、保守性、テスタビリティ、データ可視化を完全実現

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
- [ ] 度数分布とヒストグラム的な分析 → **Phase 5で実装予定**
- [x] 外れ値検出（IQRベース） ✅ 完了

**技術的改善：**
- [x] 統計結果のハッシュ構造を拡張 ✅ 完了（varianceキー追加）
- [x] より詳細な出力フォーマット ✅ 完了（分散表示追加）
- [x] 新機能の包括的テスト追加 ✅ 完了（15のpercentile・quartilesテスト）
- [x] 統一的な計算アーキテクチャ ✅ 完了（percentileベースの設計）
- [x] README.mdに新機能の使用例追加 ✅ 完了（IQR機能追加）

#### Phase 4: コード品質改善（RuboCop違反対応）✅ 完了
**目標**: コードの可読性・保守性・テスタビリティ向上

**完了済みの改善:**

**4.1 NumberAnalyzer責任分離リファクタリング** ✅ 完了
- [x] `StatisticsPresenter`クラス新規作成
- [x] 表示責任の分離: `display_results`, `format_mode`, `format_outliers`, `format_deviation_scores`メソッドを移動
- [x] NumberAnalyzerを純粋な統計計算クラスに（28行削減、107行→79行）
- [x] CLIクラスでPresenterクラス利用への変更（自動対応済み）
- [x] StatisticsPresenterの包括的テスト追加（11のテストケース）

**4.2 FileReader.read_csv メソッド分割** ✅ 完了
- [x] `try_read_without_header(file_path)` - ヘッダーなし読み込み処理
- [x] `try_read_with_header(file_path)` - ヘッダーあり読み込み処理  
- [x] `parse_csv_value(value)` - 数値変換とエラーハンドリング（Float(exception: false)使用）
- [x] メイン`read_csv`は戦略切り替えのみに（26行→6行のシンプルな制御）

**4.3 FileReader JSON処理メソッド分割** ✅ 完了
- [x] `extract_from_json_array(data)` - 配列形式JSON処理
- [x] `extract_from_json_object(data)` - オブジェクト形式JSON処理
- [x] `find_numeric_array_in_object(hash)` - キー検索ロジック分離
- [x] 各メソッドの単一責任化と複雑度削減

**達成した効果:**
- **主要RuboCop違反解消**: NumberAnalyzer class length、read_csv複雑度、JSON処理複雑度すべて解決
- **メソッドの単一責任原則準拠**: 各メソッドが明確で単一の責任を持つ
- **テスタビリティ向上**: StatisticsPresenterは独立テスト可能（11テストケース）
- **可読性向上**: メソッド名による処理内容の明確化
- **保守性向上**: 変更時の影響範囲が限定的
- **Ruby慣例準拠**: Float(exception: false)等のRuby最良プラクティス採用

**品質改善結果:**
- **Before**: 6つの重大な違反
- **After**: 2つの軽微な違反（いずれも機能上正当な理由あり）
- **テスト**: 107例すべてパス（新規11例含む）

### 発展的な統計機能
- [x] 中央値（median）の計算機能 ✅ 完了
- [x] 最頻値（mode）の検出機能 ✅ 完了  
- [x] 標準偏差（standard deviation）の算出 ✅ 完了
- [x] 分散（variance）の表示 ✅ 完了
- [x] 四分位範囲（IQR）の計算 ✅ 完了
- [x] 偏差値の算出 ✅ 完了

### パフォーマンス向上
- [ ] 大規模データセットでの性能テスト
- [ ] メモリ効率の最適化
- [ ] 並列処理による高速化

### ユーザーインターフェース
- [x] コマンドライン引数からの数値入力 ✅ 完了
- [x] ファイルからのデータ読み込み機能 ✅ 完了
- [ ] インタラクティブな操作モード

### データ可視化
- [x] ヒストグラム表示機能 ✅ **Phase 5で完了**
- [ ] 統計サマリーの表形式出力
- [ ] グラフ生成ライブラリとの連携

これらの機能追加により、より実用的な統計解析ツールへと発展させることができます。

### Phase 5: 度数分布とヒストグラム分析機能 ✅ 完了
**目標**: データ分布の可視化機能追加によるユーザビリティ向上

**実装完了成果:**

**5.1 度数分布機能** ✅ 完了
- [x] `frequency_distribution` メソッド追加
- [x] 値ごとの出現回数を計算（Ruby `tally`メソッド活用）
- [x] 包括的テストスイート（7テストケース）
- [x] TDD（Red-Green-Refactor）完全実践
- [x] 実用データ分析対応（成績データ等）

**5.2 ヒストグラム表示機能** ✅ 完了
- [x] `display_histogram` メソッド追加（TDD実装）
- [x] ASCII art可視化（■文字使用）
- [x] StatisticsPresenterへの自動統合
- [x] CLI出力への完全組み込み
- [x] エッジケース対応（空配列・単一値・小数値）

**5.3 統合とテスト** ✅ 完了
- [x] TDD（Red-Green-Refactor）による開発
- [x] 包括的テストスイート（12テストケース）
- [x] README.md機能説明・使用例更新
- [x] 全121テスト例パス
- [x] StatisticsPresenterテスト更新（3新規テスト）

**技術仕様:**
```ruby
# 度数分布例（✅ 実装完了）
analyzer = NumberAnalyzer.new([1,1,2,2,2,3,3,4,5,5,5,5])
frequency_distribution = analyzer.frequency_distribution
# => {1=>2, 2=>3, 3=>2, 4=>1, 5=>4}

# 実用例: 成績データ分析（✅ 動作確認済み）
scores = [78, 85, 92, 78, 90, 88, 85, 92, 79, 85]
grade_analyzer = NumberAnalyzer.new(scores)
grade_dist = grade_analyzer.frequency_distribution
# => {78=>2, 85=>3, 92=>2, 90=>1, 88=>1, 79=>1}

# ヒストグラム表示例（✅ 5.2で実装完了）
analyzer.display_histogram
# =>
# 度数分布ヒストグラム:
# 1: ■■ (2)
# 2: ■■■ (3) 
# 3: ■■ (2)
# 4: ■ (1)
# 5: ■■■■ (4)
```

**Phase 5完全実装成果:**
- ✅ **TDD完全実践**: RED → GREEN → REFACTOR サイクル（5.1 + 5.2）
- ✅ **包括的テスト**: 12テストケース（度数分布7例 + ヒストグラム5例）
- ✅ **数学的正確性**: 度数分布の定義に完全準拠
- ✅ **Ruby活用**: `tally`メソッド + ASCII art可視化
- ✅ **StatisticsPresenter統合**: 自動ヒストグラム表示
- ✅ **CLI完全統合**: `bundle exec number_analyzer`でのヒストグラム表示
- ✅ **全テストパス**: 121総テスト例すべて成功
- ✅ **ドキュメント更新**: README.md + CLAUDE.md完全対応

**達成した効果:**
- **データ分布の直感的理解**: ASCII artによる視覚的表現
- **実用性向上**: 成績データ等の実世界分析対応
- **教育ツール価値**: 統計概念の視覚的学習支援
- **Pure Ruby実装**: 外部依存なしの軽量実装
- **企業レベル品質**: TDD + 包括的テスト + ドキュメント完備

## Important Reminders

- **commit messages はマークダウンブロックの中に書くこと** (推奨: `/project:commit-message` コマンド使用)
- **新機能実装完了後は必ずREADME.mdの更新を確認すること**
  - Features セクションへの機能追加
  - Usage例の更新
  - Example Output の更新
- RSpec構文は `-e "pattern"` が基本（`::` は間違い）
- TDDでは既存実装を理解してからテストを書く
- 線形補間法を考慮したテスト期待値の設定

## Code Quality Guidelines

新機能実装時の品質保証と再現性向上のためのガイドライン：

- **プロジェクト設定準拠**: 新機能実装時はプロジェクトのRuboCop設定（.rubocop.yml）に準拠した設計を心がける
- **必須品質チェック**: 実装完了後は必ずRuboCop実行を行い、違反を確認する
- **違反対応プロセス**: 違反発生時は性質分析（スタイル・設計・機能的必要性）を行い、修正方針を決定してから進行する
- **設定調整判断**: 機能的必要性による違反の場合は、設定調整も含めた柔軟な対応を検討する

### 新機能実装標準フロー
1. **機能実装**: プロジェクト設定を意識した設計・実装
2. **品質チェック**: RuboCop実行（必須ステップ）
3. **違反分析・対応**: 性質に応じた修正またはルール調整
4. **完了判定**: 品質基準をクリアした時点で完成とする

この標準フローにより、一貫した品質レベルの維持と技術的負債の蓄積防止を実現する。
