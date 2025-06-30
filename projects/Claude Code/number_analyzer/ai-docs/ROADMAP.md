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

**現在の成果**: 42テスト実行例、27統計指標、Phase 7.3完全実装、企業レベル品質

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

### Phase 7.2: Time Series Analysis ✅ 完了
- [x] 線形トレンド分析 (`trend` コマンド)
- [x] 移動平均 (`moving-average` コマンド、カスタムウィンドウサイズ)
- [x] 成長率分析 (`growth-rate` コマンド、CAGR計算)
- [x] 季節性分析 (`seasonal` コマンド、周期検出)
- [x] 全機能でJSON/精度/quiet/helpオプション対応
- [x] TDD実装とRuboCop準拠

### Phase 7.3: Statistical Tests ✅ 完了
- [x] T検定 (`t-test` コマンド、独立/対応/一標本)
- [x] 信頼区間 (`confidence-interval` コマンド、t分布対応)
- [x] カイ二乗検定 (`chi-square` コマンド、独立性/適合度)
- [x] 統計的解釈機能（p値、有意差判定、効果サイズ）
- [x] CLI分割表解析改善（`--` 区切り問題解決）
- [x] 全機能でJSON/精度/quiet/helpオプション対応


### Phase 7.4 Step 1: One-way ANOVA ✅ 完了
- [x] 一元配置分散分析実装（F統計量、p値、自由度計算）
- [x] `anova` サブコマンド追加（22個目の統計コマンド）
- [x] 効果サイズ計算（η²: eta squared, ω²: omega squared）
- [x] F分布による仮説検定とp値計算
- [x] 統計的解釈機能（有意差判定、効果サイズ分類）
- [x] 既存CLI オプション完全対応（JSON、精度、quiet、help、file、alpha）
- [x] `--` 区切りによる複数グループ入力対応
- [x] 分散分析表の表形式表示
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] RuboCop準拠

## Next Development Phase

## Phase 7.4 Step 2: Post-hoc Tests 🔮 計画段階

### ANOVA Extension Features
- 🔮 **多重比較検定**: Tukey HSD, Bonferroni補正
- 🔮 **分散の等質性検定**: Levene検定、Bartlett検定
- 🔮 **二元配置分散分析**: 2つの要因の主効果と交互作用

## Phase 8.0: Plugin System Architecture 🔮 長期計画

### Plugin System Features
- Dynamic command loading
- Third-party extension support
- Configuration-based plugin management

### Integration Possibilities
- R/Python interoperability
- Database connectivity
- Web API endpoints
- Jupyter notebook integration