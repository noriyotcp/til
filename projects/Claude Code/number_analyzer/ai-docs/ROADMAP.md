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

**現在の成果**: 222テストケース、21統計指標、Phase 7.2 Step 3完全実装、企業レベル品質

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

---

## Next Development Phase

## Phase 7.2: Time Series Analysis 🚧 進行中 (Step 3 完了)

### Time Series Features  
- ✅ **Trend analysis**: `bundle exec number_analyzer trend 1 2 3 4 5` (完了)
- ✅ **Moving averages**: `bundle exec number_analyzer moving-average data.csv --window=7` (完了)
- ✅ **Growth rate calculation**: `bundle exec number_analyzer growth-rate 100 110 121 133` (完了)
- 🔮 **Seasonal decomposition**: Basic trend/seasonal pattern detection (計画中)

## Phase 7.3: Statistical Tests 🔮 計画段階

### Hypothesis Testing
- **T-test**: `bundle exec number_analyzer t-test group1.csv group2.csv`
- **Chi-square test**: Independence testing for categorical data
- **ANOVA**: Analysis of variance for multiple groups
- **Confidence intervals**: Statistical significance testing

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