# Development Roadmap

## Completed Phases

### Phase 1: CLI機能追加 ✅ 完了
- [x] コマンドライン引数での数値入力対応
- [x] 入力検証とエラーハンドリング
- [x] デフォルト配列へのフォールバック機能
- [x] CLI機能の包括的テスト追加（15のテストケース）

### Phase 2: Ruby Gem構造化 ✅ 完了
- [x] 標準的なGem構造（lib/, bin/, spec/）への移行
- [x] 名前空間設計（NumberAnalyzer::CLI等）
- [x] 依存関係管理（gemspec）
- [x] `bundle exec number_analyzer`実行対応

### Phase 3: 統計機能拡張 ✅ 完了
- [x] 中央値、最頻値、分散、標準偏差
- [x] パーセンタイル、四分位数、四分位範囲
- [x] 外れ値検出、偏差値計算
- [x] 線形補間法による数学的正確性
- [x] TDD（Red-Green-Refactor）による段階的実装

### Phase 4: コード品質改善 ✅ 完了
- [x] 責任分離アーキテクチャ（StatisticsPresenter分離）
- [x] FileReader複雑度削減（メソッド分割）
- [x] RuboCop主要違反解消
- [x] テスタビリティ向上（独立テスト可能）

### Phase 5: データ可視化 ✅ 完了
- [x] 度数分布機能（Ruby `tally`メソッド活用）
- [x] ASCII artヒストグラム表示（■文字可視化）
- [x] StatisticsPresenterへの自動統合
- [x] 包括的テストスイート（12テストケース）

**現在の成果**: 28テスト実行例、25統計指標、Phase 7.3 Step 1完全実装、企業レベル品質

### Phase 6: CLI Subcommands Implementation ✅ 完了
- [x] 13個の統計サブコマンド実装 (median, mean, mode, sum, min, max, histogram, outliers, percentile, quartiles, variance, std, deviation-scores)
- [x] JSON出力フォーマット (`--format=json`)
- [x] 精度制御 (`--precision=N`)
- [x] サイレントモード (`--quiet`)
- [x] ヘルプシステム (`--help`)
- [x] 全サブコマンドでファイル入力対応 (`--file`)
- [x] 下位互換性完全保持
- [x] 包括的テストスイート（23新規テスト追加）

### Phase 7.1: Correlation Analysis ✅ 完了
- [x] ピアソン相関係数計算メソッド実装（数学的正確性）
- [x] `correlation` サブコマンド追加（14個目の統計コマンド）
- [x] デュアルデータセット入力対応（数値直接入力/ファイル入力）
- [x] 相関強度解釈機能（強い正の相関、中程度の負の相関など）
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（7新規テスト追加）
- [x] エッジケース対応（空配列、長さ不一致、同値データ）

### Phase 7.2 Step 1: Trend Analysis ✅ 完了
- [x] 線形回帰による `linear_trend` メソッド実装（数学的正確性）
- [x] `trend` サブコマンド追加（15個目の統計コマンド）
- [x] 傾き、切片、決定係数(R²)、方向性(上昇/下降/横ばい)出力
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] RuboCop準拠のため複雑度削減リファクタリング
- [x] 包括的テストスイート（15新規テスト追加: 5コア + 8CLI + 7フォーマッター）
- [x] エッジケース対応（空配列、単一値、完全相関データ）

### Phase 7.2 Step 2: Moving Average ✅ 完了
- [x] 移動平均計算メソッド `moving_average` 実装（数学的正確性）
- [x] `moving-average` サブコマンド追加（16個目の統計コマンド）
- [x] カスタマイズ可能なウィンドウサイズ (`--window=N`)
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（17新規テスト追加）
- [x] エッジケース対応（空配列、無効ウィンドウサイズ、境界条件）

### Phase 7.2 Step 3: Growth Rate Analysis ✅ 完了
- [x] 成長率分析メソッド群実装（`growth_rates`, `compound_annual_growth_rate`, `average_growth_rate`）
- [x] `growth-rate` サブコマンド追加（17個目の統計コマンド）
- [x] 期間別成長率、CAGR、平均成長率の包括的分析
- [x] 無限値・ゼロ値・負値の適切な処理
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（27新規テスト追加: 17コア + 8CLI + 13フォーマッター）
- [x] エッジケース対応（無限成長率、CAGR計算不可ケース、データ不足）

### Phase 7.2 Step 4: Seasonal Pattern Analysis ✅ 完了
- [x] 季節性分析メソッド群実装（`seasonal_decomposition`, `detect_seasonal_period`, `seasonal_strength`）
- [x] `seasonal` サブコマンド追加（18個目の統計コマンド）
- [x] 季節パターン分解、周期検出、季節性強度の包括的分析
- [x] カスタマイズ可能な周期指定 (`--period=N`)
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート実装
- [x] エッジケース対応（短いデータ、一定値データ、不十分なサンプル）

### Phase 7.3 Step 1: T-Test Analysis ✅ 完了
- [x] 独立2標本t検定実装（Welch's t-test for unequal variances）
- [x] 対応ありt検定実装（paired samples t-test）
- [x] 一標本t検定実装（one-sample t-test with population mean）
- [x] `t-test` サブコマンド追加（19個目の統計コマンド）
- [x] 数学的正確性保証（Welch-Satterthwaite自由度、2-tailed p値）
- [x] 統計的解釈機能（有意差判定、日本語での結論表示）
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（17新規テスト追加）
- [x] エッジケース対応（空データ、同一値、無効入力）

### Phase 7.3 Step 2: Confidence Intervals ✅ 完了
- [x] 母平均の信頼区間実装（t分布および正規分布近似）
- [x] `confidence-interval` サブコマンド追加（20個目の統計コマンド）
- [x] 信頼度指定機能（90%, 95%, 99%等の柔軟な設定）
- [x] 数学的正確性保証（小標本はt分布、大標本は正規近似）
- [x] 統計的解釈機能（信頼区間の意味と区間推定）
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file、level）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（10新規テスト追加）
- [x] エッジケース対応（小サンプル、大サンプル、無効信頼度）

### Phase 7.3 Step 3: Chi-square Test 🟡 部分完了（CLI改善必要）
- [x] カイ二乗検定メソッド実装（独立性検定、適合度検定）
- [x] Cramér's V効果サイズ計算とp値推定
- [x] `chi-square` サブコマンド追加（21個目の統計コマンド）
- [x] 数学的正確性保証（カイ二乗分布表、期待度数検証）
- [x] 統計的解釈機能（有意差判定、警告表示）
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file）
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] 包括的テストスイート（12新規テスト追加）
- [ ] **🚨 CLI分割表解析の改善必要**: 現在χ² = 0.0, df = 0を返す問題

### Phase 7.3 Step 3.5: Chi-square CLI Improvements 🔧 改善予定
**現在の問題**: CLI独立性検定で「χ² = 0.0, df = 0」を返すため実用性に欠ける

#### 主要改善項目
- [ ] **分割表パース機能の強化**
  - `parse_contingency_table_from_args`メソッドの全面見直し
  - `--` 区切りパースロジックの堅牢性向上
  - エラー処理とユーザーフィードバック改善

- [ ] **ファイル入力処理の拡張**
  - 非正方形分割表（2x3, 3x4など）完全サポート
  - CSVファイル形式の柔軟な認識
  - ファイル内分割表構造の自動検出

- [ ] **テストタイプ判定の改善**
  - データ形状に基づく自動判定ロジック
  - 直感的なCLIオプション設計
  - エラーメッセージとガイダンス強化

#### 技術課題詳細
1. **`parse_contingency_table_from_args`の限界**
   - Line 956-986: `--` 区切りロジックの不完全性
   - 非正方形分割表への対応不足
   - エラーハンドリングの基本レベル

2. **ファイル入力の制約**
   - Line 893-899: 正方形分割表仮定の制限
   ```ruby
   # 現在の問題あるコード
   dimension = Math.sqrt(data.length).to_i
   if dimension * dimension != data.length
     puts 'エラー: 独立性検定には正方形の分割表が必要です。'
   ```

3. **テストタイプ判定の曖昧さ**
   - `determine_chi_square_test_type`の自動判定不足

#### 実装計画
1. **問題特定**: 現在失敗するケースのテストケース作成
2. **パース強化**: `parse_contingency_table_from_args`全面書き直し
3. **ファイル拡張**: 非正方形分割表対応
4. **統合テスト**: 包括的検証の実施
5. **エラー改善**: ユーザビリティ向上

#### 期待成果
- χ² = 0.0, df = 0 問題の完全解決
- あらゆる形状の分割表対応
- エンタープライズレベルの信頼性
- 実用的なchi-square CLI機能の実現

---

## Next Development Phase

## Phase 7.2: Time Series Analysis ✅ 完了

### Time Series Features  
- ✅ **Trend analysis**: `bundle exec number_analyzer trend 1 2 3 4 5` (完了)
- ✅ **Moving averages**: `bundle exec number_analyzer moving-average data.csv --window=7` (完了)
- ✅ **Growth rate calculation**: `bundle exec number_analyzer growth-rate 100 110 121 133` (完了)
- ✅ **Seasonal decomposition**: `bundle exec number_analyzer seasonal 10 20 15 25` (完了)

## Phase 7.3: Statistical Tests 🟡 部分完了 (Step 3 CLI改善必要)

### Hypothesis Testing  
- ✅ **T-test**: `bundle exec number_analyzer t-test group1.csv group2.csv` (完了)
- ✅ **Confidence intervals**: `bundle exec number_analyzer confidence-interval 95 data.csv` (完了)
- 🟡 **Chi-square test**: `bundle exec number_analyzer chi-square --independence 30 20 -- 15 35` (コア完了、CLI改善必要)
- 🔮 **ANOVA**: Analysis of variance for multiple groups (計画中)

## Phase 7.4: Plugin System Architecture 🔮 計画段階

### Plugin System Features
- Dynamic command loading
- Third-party extension support
- Configuration-based plugin management

### Integration Possibilities
- R/Python interoperability
- Database connectivity
- Web API endpoints
- Jupyter notebook integration