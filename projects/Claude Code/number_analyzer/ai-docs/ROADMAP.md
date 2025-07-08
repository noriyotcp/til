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

**現在の成果**: 包括的テストスイート、33統計指標、29コアコマンド、Phase 8.0 Step 5完全実装（重複管理CLI統合完了）、プラグインAPI標準化完了、8モジュール抽出アーキテクチャ（96.1%コード削減）、**CLI Refactoring Phase 2完全完了**（全29コマンドCommand Pattern移行、CLI.rb 81%削減達成）、企業レベル品質、完全なプラグインエコシステム確立

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

### Phase 7.4 Step 2: Post-hoc Tests ✅ 完了
- [x] **Tukey HSD検定**: 学生化範囲分布による多重比較（q統計量、臨界値テーブル）
- [x] **Bonferroni補正**: 保守的多重比較補正（調整済みp値、調整済みα水準）
- [x] **CLI統合**: `--post-hoc=tukey/bonferroni` オプション対応
- [x] **出力フォーマット**: 詳細な比較結果表示（日本語）とJSON出力対応
- [x] **数学的正確性**: 調和平均サンプルサイズ、Welch-Satterthwaite自由度計算
- [x] **包括的テスト**: 9新規テストケース（有意差検出、類似グループ、無効入力）
- [x] **TDD実装**: Red-Green-Refactorサイクルによる段階的開発
- [x] **RuboCop準拠**: ゼロ違反維持

## Next Development Phase

## Phase 7.5: Advanced ANOVA Features 📋 実装準備完了

### Phase 7.5 Step 1: Levene Test Implementation ✅ 完了
**分散の等質性検定 (ANOVA前提条件チェック)**
- [x] `levene_test(*groups)` メソッド実装（Brown-Forsythe修正版）
- [x] F統計量計算: `F = [(N-k)/(k-1)] * [Σnᵢ(Zᵢ - Z̄)²] / [Σᵢ Σⱼ(Zᵢⱼ - Zᵢ)²]`
- [x] Zᵢⱼ = |Xᵢⱼ - M̃ᵢ| による中央値ベース計算（外れ値に頑健）
- [x] F分布 F(k-1, N-k) によるp値計算
- [x] CLI統合: `'levene' => :run_levene` コマンド追加
- [x] 新規テストファイル: `spec/levene_test_spec.rb` (15 test cases)
- [x] JSON/precision/quiet/help オプション対応
- [x] TDD実装（Red-Green-Refactor サイクル）
- [x] RuboCop準拠（ゼロ違反維持）

### Phase 7.5 Step 2: Bartlett Test Implementation ✅ 完了
**分散の等質性検定 (正規分布仮定下での高精度)**
- [x] `bartlett_test(*groups)` メソッド実装
- [x] カイ二乗統計量: `χ² = (1/C) * [(N-k)ln(S²ₚ) - Σ(nᵢ-1)ln(S²ᵢ)]`
- [x] 補正係数C計算: `C = 1 + (1/(3(k-1))) * [Σ(1/(nᵢ-1)) - 1/(N-k)]`
- [x] 合併分散S²ₚ計算とカイ二乗分布 χ²(k-1) によるp値
- [x] CLI統合: `'bartlett' => :run_bartlett` コマンド追加（24個目のサブコマンド）
- [x] 新規テストファイル: `spec/bartlett_test_spec.rb` (16 test cases)
- [x] 全CLI オプション対応（JSON、精度、quiet、help、file）
- [x] TDD実装とRuboCop準拠

### Phase 7.5 Step 3: Kruskal-Wallis Test Implementation ✅ 完了
**ノンパラメトリックANOVA代替 (正規性仮定不要)**
- [x] `kruskal_wallis_test(*groups)` メソッド実装
- [x] H統計量計算: `H = [12/(N(N+1))] * [Σ(R²ᵢ/nᵢ)] - 3(N+1)`
- [x] 順位(ランク)計算とタイ補正アルゴリズム
- [x] カイ二乗分布 χ²(k-1) によるp値計算
- [x] CLI統合: `'kruskal-wallis' => :run_kruskal_wallis` コマンド追加（25個目のサブコマンド）
- [x] 新規テストファイル: `spec/kruskal_wallis_spec.rb` (16 test cases)
- [x] 統計的解釈機能（有意差判定、数学的正確性）
- [x] 全CLI オプション対応（JSON、精度、quiet、help、file）とRuboCop準拠

## Completed Phases

## Phase 7.6: Non-parametric Test Suite Completion ✅ 完了

### Phase 7.6 Step 1: Mann-Whitney U Test Implementation ✅ 完了
**最も基本的なノンパラメトリック2群比較検定**
- [x] `mann_whitney_u_test(group1, group2)` メソッド実装
- [x] U統計量計算: `U1 = n1*n2 + n1*(n1+1)/2 - R1`
- [x] 正規近似によるz統計量計算（大標本）および正確検定（小標本）
- [x] タイ補正対応と連続性補正適用
- [x] CLI統合: `'mann-whitney' => :run_mann_whitney` コマンド追加（26個目のサブコマンド）
- [x] 新規テストファイル: `spec/mann_whitney_spec.rb` (17 test cases)
- [x] 統計的解釈機能（効果サイズr、有意差判定、数学的正確性）
- [x] 全CLI オプション対応（JSON、精度、quiet、help、file）とRuboCop準拠

**Phase 7.6 達成項目**:
- ✅ **26個のサブコマンド完成**: 基本7 + 上級6 + 相関1 + 時系列4 + 統計検定3 + ANOVA1 + 分散均質性2 + ノンパラメトリック2
- ✅ **106テスト実行例**: 統合テストの包括的テストスイート
- ✅ **32統計関数**: 企業レベル統計分析ライブラリ完成
- ✅ **Phase 7.6 Step 1完了**: ノンパラメトリック2群比較検定基盤構築

## Phase 7.7: Architecture Refactoring ✅ Step 1 完了

### Phase 7.7 Step 1: BasicStats Module Extraction ✅ 完了
**基盤リファクタリングの第一歩 - モジュラーアーキテクチャへの移行**
- [x] `lib/number_analyzer/statistics/basic_stats.rb` モジュール作成（51行）
- [x] 基本統計メソッド抽出: `sum`, `mean`, `mode`, `variance`, `standard_deviation`
- [x] NumberAnalyzer クラスに `include BasicStats` 統合
- [x] 32個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/basic_stats_spec.rb`
- [x] API完全互換性維持: 既存106テスト + 新規32テスト = 138テスト全通過
- [x] ファイルサイズ削減: 1,727行 → 1,710行（17行削減）
- [x] RuboCop準拠: ゼロ違反維持

**Phase 7.7 Step 1 達成項目**:
- ✅ **モジュラーアーキテクチャ確立**: 最初のモジュール分割成功
- ✅ **138テスト実行例**: BasicStats単体テスト32個追加
- ✅ **基盤リファクタリング開始**: Plugin System Architecture (Phase 8.0) への移行パス確立
- ✅ **品質保証**: API変更なし、全機能動作確認済み

### Phase 7.7 Step 2: MathUtils Module Extraction ✅ 完了
**数学的ユーティリティ関数のモジュール化 - 成功**
- [x] `lib/number_analyzer/statistics/math_utils.rb` モジュール作成（102行）
- [x] 数学的ヘルパー関数抽出: `standard_normal_cdf`, `erf`, `approximate_t_distribution_cdf`, `calculate_f_distribution_p_value`
- [x] 重複コード削除と統合（95行削減: 1,710 → 1,615行）
- [x] API完全互換性維持: 既存106テスト全通過
- [x] RuboCop準拠: ゼロ違反維持

**Phase 7.7 Step 2 達成項目**:
- ✅ **数学的関数統合**: 4つの数学関数を独立モジュールに抽出
- ✅ **コード重複解消**: 統計検定間の数学関数重複を完全解消
- ✅ **保守性向上**: 数学的計算の一元管理、修正影響範囲限定
- ✅ **品質保証**: API変更なし、全機能動作確認済み

### Phase 7.7 Step 3: AdvancedStats Module Extraction ✅ 完了
**高度統計分析関数のモジュール化**
- [x] `lib/number_analyzer/statistics/advanced_stats.rb` モジュール作成（65行）
- [x] 高度統計関数抽出: `percentile`, `quartiles`, `interquartile_range`, `outliers`, `deviation_scores`
- [x] percentile依存関係の整理とモジュール化
- [x] 高度統計分析の一元管理
- [x] 26個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/advanced_stats_spec.rb`
- [x] API完全互換性維持: 164テスト全通過確認（API変更なし）
- [x] 59行削減 (1,615 → 1,556 lines), RuboCop準拠

### Phase 7.7 Step 4: CorrelationStats Module Extraction ✅ 完了
**相関分析機能のモジュール化**
- [x] `lib/number_analyzer/statistics/correlation_stats.rb` モジュール作成（54行）
- [x] 相関分析メソッド抽出: `correlation`, `interpret_correlation`
- [x] OutputFormatter統合とピアソン相関係数計算の専門化
- [x] 32個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/correlation_stats_spec.rb`
- [x] API完全互換性維持: 192テスト全通過確認（106統合 + 86ユニット）
- [x] 28行削減 (1,556 → 1,528 lines), RuboCop準拠

**Phase 7.7 Step 4 達成項目**:
- ✅ **4つのモジュール完成**: BasicStats + MathUtils + AdvancedStats + CorrelationStats
- ✅ **192テスト実行例**: 86ユニットテスト + 106統合テスト
- ✅ **199行削減**: 1,727行 → 1,528行（11.5%削減達成）
- ✅ **品質保証**: API変更なし、相関分析の専門化完了

## Next Development Phase

### Phase 7.7 Step 5: TimeSeriesStats Module Extraction ✅ 完了
**時系列分析機能のモジュール化**
- [x] `lib/number_analyzer/statistics/time_series_stats.rb` モジュール作成（279行）
- [x] 時系列分析メソッド抽出: `linear_trend`, `moving_average`, `growth_rates`, `compound_annual_growth_rate`, `average_growth_rate`, `seasonal_decomposition`, `detect_seasonal_period`, `seasonal_strength`
- [x] 時系列統計分析の専門化と10個のプライベートヘルパーメソッド抽出
- [x] 38個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/time_series_stats_spec.rb`
- [x] API完全互換性維持: 230テスト全通過確認（106統合 + 124ユニット）
- [x] 257行削減 (1,528 → 1,271 lines), RuboCop準拠

**Phase 7.7 Step 5 達成項目**:
- ✅ **5つのモジュール完成**: BasicStats + MathUtils + AdvancedStats + CorrelationStats + TimeSeriesStats
- ✅ **230テスト実行例**: 124ユニットテスト + 106統合テスト
- ✅ **456行削減**: 1,727行 → 1,271行（26.4%削減達成）
- ✅ **品質保証**: API変更なし、時系列分析の完全専門化完了

### Phase 7.7 Step 6: HypothesisTesting Module Extraction ✅ 完了
**仮説検定機能のモジュール化**
- [x] `lib/number_analyzer/statistics/hypothesis_testing.rb` モジュール作成（480行）
- [x] 仮説検定メソッド抽出: `t_test`, `confidence_interval`, `chi_square_test`
- [x] 統計的検定の専門化と30個以上のプライベートヘルパーメソッド抽出
- [x] 32個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/hypothesis_testing_spec.rb`
- [x] API完全互換性維持: 106テスト全通過確認（統合テスト）
- [x] 410行削減 (1,271 → 861 lines), RuboCop準拠
- [x] 数学的正確性: Welchのt検定、t分布信頼区間、カイ二乗分布p値計算

**Phase 7.7 Step 6 達成項目**:
- ✅ **6つのモジュール完成**: BasicStats + MathUtils + AdvancedStats + CorrelationStats + TimeSeriesStats + HypothesisTesting
- ✅ **262テスト実行例**: 156ユニットテスト + 106統合テスト
- ✅ **866行削減**: 1,727行 → 861行（50.1%削減達成）
- ✅ **品質保証**: API変更なし、仮説検定の完全専門化完了

### Phase 7.7 Step 7: ANOVAStats Module Extraction ✅ 完了
**分散分析機能のモジュール化**
- [x] `lib/number_analyzer/statistics/anova_stats.rb` モジュール作成（566行）
- [x] 分散分析メソッド抽出: `one_way_anova`, `post_hoc_analysis`, `levene_test`, `bartlett_test`
- [x] ANOVA統計分析の専門化と25個以上のプライベートヘルパーメソッド抽出
- [x] 38個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/anova_stats_spec.rb`
- [x] API完全互換性維持: 106テスト全通過確認（統合テスト）
- [x] 554行削減 (861 → 307 lines), RuboCop準拠
- [x] 分散分析完全統合: ANOVA + 事後検定 + 分散等質性検定の専門モジュール化

**Phase 7.7 Step 7 達成項目**:
- ✅ **7つのモジュール完成**: BasicStats + MathUtils + AdvancedStats + CorrelationStats + TimeSeriesStats + HypothesisTesting + ANOVAStats
- ✅ **300テスト実行例**: 194ユニットテスト + 106統合テスト
- ✅ **1,420行削減**: 1,727行 → 307行（82.2%削減達成）
- ✅ **品質保証**: API変更なし、分散分析の完全専門化完了

### Phase 7.7 Step 8: NonParametricStats Module Extraction ✅ 完了
**ノンパラメトリック統計検定機能のモジュール化 - 基盤リファクタリング完了**
- [x] `lib/number_analyzer/statistics/non_parametric_stats.rb` モジュール作成（246行）
- [x] ノンパラメトリック検定メソッド抽出: `kruskal_wallis_test`, `mann_whitney_u_test`
- [x] ランク計算とタイ補正の専門化と3個のプライベートヘルパーメソッド抽出
- [x] 26個の包括的ユニットテスト追加: `spec/number_analyzer/statistics/non_parametric_stats_spec.rb`
- [x] API完全互換性維持: 106テスト全通過確認（統合テスト）
- [x] 234行削減 (302 → 68 lines), RuboCop準拠
- [x] ノンパラメトリック検定完全統合: Kruskal-Wallis + Mann-Whitney U検定の専門モジュール化

**Phase 7.7 Step 8 達成項目**:
- ✅ **8つのモジュール完成**: BasicStats + MathUtils + AdvancedStats + CorrelationStats + TimeSeriesStats + HypothesisTesting + ANOVAStats + NonParametricStats
- ✅ **326テスト実行例**: 220ユニットテスト + 106統合テスト
- ✅ **1,659行削減**: 1,727行 → 68行（96.1%削減達成）
- ✅ **基盤リファクタリング完了**: 完全モジュラーアーキテクチャ、Phase 8.0 Plugin System Architecture準備完了

### Phase 7.7 最終ステップ
**詳細な実装計画とモジュール仕様は `ai-docs/REFACTORING_PLAN.md` を参照**

基盤リファクタリング完了:
- Step 6: HypothesisTesting Module ✅ **完了**
- Step 7: ANOVAStats Module ✅ **完了**
- Step 8: NonParametricStats Module ✅ **完了** (kruskal_wallis, mann_whitney)

### Phase 7.6 Step 2: Wilcoxon Signed-Rank Test Implementation ✅ 完了
**対応のある2群比較のノンパラメトリック検定**
- [x] `wilcoxon_signed_rank_test(before, after)` メソッド実装
- [x] 符号順位統計量計算とタイ補正（W+, W-, タイ補正分散計算）
- [x] 正規近似による検定統計量計算（連続性補正付きz統計量）
- [x] CLI統合: `'wilcoxon' => :run_wilcoxon` コマンド追加（27個目のサブコマンド）
- [x] 効果サイズ計算（r = z/√n）と統計的解釈機能
- [x] 新規テストファイル: NonParametricStats specに12テストケース追加
- [x] 全CLI オプション対応（JSON、精度、quiet、help、file）とRuboCop準拠

**Phase 7.6 Step 2 達成項目**:
- ✅ **27個のサブコマンド完成**: 基本7 + 上級6 + 相関1 + 時系列4 + 統計検定3 + ANOVA1 + 分散均質性2 + ノンパラメトリック3
- ✅ **対応データ分析完成**: パラメトリック（対応t検定）+ ノンパラメトリック（Wilcoxon）の両方対応
- ✅ **テスト品質**: 12 Wilcoxonテストケース追加（全106統合テスト通過）
- ✅ **数学的正確性**: ゼロ差除外、タイ補正、連続性補正の完全実装

### Phase 7.6 Step 3: Friedman Test Implementation ✅ 完了
**反復測定のノンパラメトリックANOVA**
- [x] `friedman_test(*repeated_groups)` メソッド実装
- [x] χ²統計量計算: `χ² = [12/(n*k*(k+1))] * [Σ(Rj²)] - 3*n*(k+1)`
- [x] 反復測定データ構造対応（同一被験者の複数条件測定）
- [x] CLI統合: `'friedman' => :run_friedman` コマンド追加（28個目のサブコマンド）
- [x] タイ補正機能実装（Friedman専用アルゴリズム）
- [x] 全CLI オプション対応（JSON、精度、quiet、help、file）
- [x] 包括的テストスイート（17新規テストケース追加）
- [x] 出力フォーマット統合（StatisticsPresenterに完全対応）
- [x] TDD実装とRuboCop準拠

**Phase 7.6 Step 3 達成項目**:
- ✅ **28個のサブコマンド完成**: 基本7 + 上級6 + 相関1 + 時系列4 + 統計検定3 + ANOVA1 + 分散均質性2 + ノンパラメトリック4
- ✅ **ノンパラメトリック検定スイート完成**: Kruskal-Wallis（多群比較）+ Mann-Whitney（独立2群）+ Wilcoxon（対応2群）+ Friedman（反復測定多群）
- ✅ **反復測定分析対応**: パラメトリック（反復測定ANOVA）とノンパラメトリック（Friedman）の両方完備
- ✅ **数学的完成度**: タイ補正、χ²分布p値、ランク計算の完全実装
- ✅ **106テスト実行例**: 包括的テストスイート（Friedmanテストケース追加）

### Phase 7.8: Two-way ANOVA Implementation ✅ 完了
**二元配置分散分析の実装 - 実験計画法の標準手法**
- [x] `two_way_anova(data, factor_a_levels, factor_b_levels, values)` メソッド実装
- [x] 主効果A・主効果B・交互作用A×Bの完全分離
- [x] F統計量、p値、効果サイズ（Partial η²）の正確な計算
- [x] CLI統合: `'two-way-anova' => :run_two_way_anova` コマンド追加（29個目のサブコマンド）
- [x] 因子水準指定: `--factor-a`, `--factor-b` オプション対応
- [x] CSVファイル入力対応: 3列形式（factor_a, factor_b, value）
- [x] 包括的テストスイート: 13新規テストケース（2×2、2×3設計、交互作用検出）
- [x] OutputFormatter統合: JSON、精度、quiet、helpオプション完全対応
- [x] セル平均値・周辺平均値・分散分析表の詳細出力

**Phase 7.8 達成項目**:
- ✅ **29個のサブコマンド完成**: 基本7 + 上級6 + 相関1 + 時系列4 + 統計検定3 + ANOVA2 + 分散均質性2 + ノンパラメトリック4
- ✅ **実験計画法対応**: One-way ANOVA + Two-way ANOVA で完全な分散分析基盤
- ✅ **主効果・交互作用分析**: 複雑な要因実験への対応完了
- ✅ **数学的正確性**: 平方和分解、F分布p値、効果サイズの完全実装

### Future ANOVA Extension Features 🔮 長期計画
- 🔮 **反復測定ANOVA**: 被験者内計画による分散分析
- 🔮 **Mixed ANOVA**: 被験者間・被験者内要因の混合設計

### Phase 8.0 Step 1: Plugin System Foundation ✅ 完了

**基盤インフラストラクチャの実装完了 - プラグインシステムの土台確立**

- [x] **Plugin System Core** - プラグイン登録・管理・ロードシステム
- [x] **Dynamic Command Loading** - 動的コマンド登録・実行インフラ  
- [x] **Configuration Framework** - YAML ベースプラグイン設定システム
- [x] **Plugin Interfaces** - 5種類のプラグインタイプ対応（statistics_module, cli_command, file_format, output_format, validator）
- [x] **Plugin Discovery** - 自動プラグイン検出・ローディング機能
- [x] **Comprehensive Test Suite** - 45包括テスト（プラグインシステム基盤全体）
- [x] **Backward Compatibility** - 既存29コマンド完全互換性保持

**実装ファイル**:
- `lib/number_analyzer/plugin_system.rb` - コアプラグイン管理
- `lib/number_analyzer/plugin_interface.rb` - プラグインベースクラス
- `lib/number_analyzer/plugin_loader.rb` - 発見・自動ロード機能
- `plugins.yml` - 設定ファイル
- CLI統合（`lib/number_analyzer/cli.rb`への動的コマンド対応追加）

**テスト**:
- `spec/plugin_system_spec.rb` (14テスト)
- `spec/cli_plugin_integration_spec.rb` (7テスト) 
- `spec/plugin_interface_spec.rb` (24テスト)

### Phase 8.0 Step 2: Basic Plugin Implementation ✅ 完了

**実働プラグイン実装と動的CLI統合の完全実現 - プラグインシステムの実用化**

- [x] **First Working Plugins** - 3つの実働プラグイン実装（BasicStats, AdvancedStats, MathUtils）
- [x] **Automatic CLI Integration** - プラグインロード時の自動CLIコマンド登録機能
- [x] **Plugin Interface Compliance** - StatisticsPlugin インターフェース準拠とメタデータ管理
- [x] **Dependency Management** - プラグイン間依存関係システム（AdvancedStats → BasicStats）
- [x] **Enhanced PluginSystem** - 統計モジュールロード時の自動CLI登録機能追加
- [x] **Comprehensive Testing** - 59新規テスト（後に22包括統合テストに最適化）
- [x] **Test Consolidation** - 一時的テストファイルの整理と永続的名前への変更
- [x] **100% Backward Compatibility** - 既存NumberAnalyzer API完全互換性維持
- [x] **Zero RuboCop Violations** - 全プラグインファイル品質基準準拠

### Phase 8.0 Step 3: Advanced Plugin Features ✅ 完了

**高度プラグイン機能の実現 - エンタープライズ品質のプラグインアーキテクチャ**

- [x] **Dependency Validation System** - DependencyResolver による依存関係検証
  - [x] **Circular Dependency Detection** - TSort による循環依存検出
  - [x] **Version Compatibility Checking** - 5種類の演算子対応 (~>, >=, >, <=, <, =)
  - [x] **Complex Dependency Tree Resolution** - 多層依存関係の自動解決
- [x] **Error Handling Enhancement** - PluginErrorHandler による包括的エラー処理
  - [x] **5 Recovery Strategies** - retry, fallback, disable, fail_fast, log_continue
  - [x] **Exponential Backoff Retry** - 指数バックオフによるリトライ機能
  - [x] **Plugin Health Monitoring** - プラグイン状態監視と統計
- [x] **Advanced Testing Suite** - 73新規テスト（26+29+18）追加
  - `spec/dependency_resolver_spec.rb` (26テスト) - 依存関係検証テスト
  - `spec/plugin_error_handler_spec.rb` (29テスト) - エラーハンドリングテスト  
  - `spec/plugin_system_advanced_spec.rb` (18テスト) - 統合テスト
- [x] **Enterprise Quality Assurance** - 高可用性・フォルトトレラント設計
- [x] **Zero RuboCop Violations** - 全新規ファイル品質基準準拠

**実装ファイル**:
- `lib/number_analyzer/dependency_resolver.rb` (345行) - 依存関係解決システム
- `lib/number_analyzer/plugin_error_handler.rb` (260行) - エラー処理システム
- `lib/number_analyzer/plugin_system.rb` (機能強化) - 統合システム

**Phase 8.0 Step 3 達成項目**:
- ✅ **163テスト実行例** - 73新規テスト追加（90基本 + 73高度機能）
- ✅ **エンタープライズ品質保証** - 循環依存検出、バージョン互換性、エラー回復
- ✅ **プラグインヘルス監視** - 障害検出、統計、自動回復機能
- ✅ **Ruby 3.5互換性** - logger gem追加によるDeprecation Warning解決

**実装プラグイン**:
- `plugins/basic_stats_plugin.rb` - 基本統計（sum, mean, mode, variance, std-dev）
- `plugins/advanced_stats_plugin.rb` - 高度統計（percentile, quartiles, outliers, deviation-scores）
- `plugins/math_utils_plugin.rb` - 数学ユーティリティ（内部関数、CLI非公開）

**テスト構成最適化**:
- `spec/plugin_system_integration_spec.rb` (22包括統合テスト) - 新規統合テスト
- `spec/basic_stats_plugin_spec.rb` (11テスト) - 個別プラグインテスト
- `spec/dynamic_cli_commands_spec.rb` (13テスト) - 動的CLI機能テスト
- テスト総数: 137 examples, 0 failures（統合最適化により効率化）

**Plugin CLI Commands Available**:
- **BasicStats**: `sum`, `mean`, `mode`, `variance`, `std-dev`
- **AdvancedStats**: `percentile`, `quartiles`, `outliers`, `deviation-scores`
- **MathUtils**: 内部関数のみ（CLI非公開）

### Phase 8.0 Step 4: Plugin API Standardization ✅ 完了

**サードパーティプラグイン開発フレームワークの確立 - 外部開発者向けAPI標準化**

- [x] **PluginRegistry System** - 集中プラグイン管理システム
  - [x] **プラグイン登録・発見機能** - 名前空間競合検出付き集中管理
  - [x] **メタデータ検証** - プラグイン情報の整合性チェック
  - [x] **マルチディレクトリ対応** - `./plugins`, `./lib/number_analyzer/plugins`, `~/.number_analyzer/plugins`
  - [x] **依存関係管理** - プラグイン間依存関係検証とライフサイクル管理
- [x] **PluginConfiguration System** - 多層設定管理システム
  - [x] **設定階層化** - デフォルト・ファイル・環境変数の3層設定対応
  - [x] **セキュリティポリシー** - プラグイン実行権限とセキュリティ設定
  - [x] **プラグイン有効化制御** - 個別プラグインの動的有効/無効化
  - [x] **設定検証・マージ** - 設定ファイルの整合性確認と階層マージ
- [x] **PluginValidator System** - セキュリティ検証・整合性チェック
  - [x] **76種類の危険パターン検出** - システムコマンド、ファイル操作、ネットワークアクセス等
  - [x] **リスクレベル評価** - low/medium/high/critical の4段階リスク分析
  - [x] **コード整合性チェック** - SHA256ハッシュによるファイル整合性検証
  - [x] **作成者信頼性検証** - 信頼できる作成者リストとの照合
  - [x] **包括的セキュリティレポート** - セキュリティ問題の詳細分析とレコメンデーション
- [x] **PluginTemplate System** - 標準プラグイン生成システム
  - [x] **5種類のプラグインテンプレート** - statistics, CLI command, file format, output format, validator
  - [x] **ERBテンプレートエンジン** - 動的プラグイン構造生成
  - [x] **テスト・ドキュメント自動生成** - 標準的なテストファイルとドキュメント作成
  - [x] **コーディング規約準拠** - NumberAnalyzer規約に準拠したコード生成
- [x] **Enhanced PluginLoader** - セキュアプラグインローダー
  - [x] **セキュリティ統合** - PluginValidatorとの連携による安全なロード
  - [x] **自動レジストリ登録** - プラグイン発見時の自動登録機能
  - [x] **リスクベースロード戦略** - セキュリティレベルに応じた読み込み制御
  - [x] **包括的ロードレポート** - ロード結果とセキュリティ分析の詳細報告

**Sample Plugin Implementations (3個の包括サンプル)**:

- [x] **MachineLearningPlugin** - 機械学習アルゴリズム実装例
  - [x] **線形回帰分析** - 最小二乗法による回帰係数・決定係数計算
  - [x] **K-meansクラスタリング** - シルエット分析付きクラスター分析
  - [x] **主成分分析(PCA)** - 次元削減と分散説明比計算
  - [x] **多項式回帰** - 二次回帰分析と曲率検出
  - [x] **相関行列分析** - 多変量データの相関パターン分析
  - [x] **5個のCLIコマンド**: `linear-regression`, `k-means`, `pca`, `poly-regression`, `correlation-matrix`

- [x] **DataExportPlugin** - データエクスポート機能実装例
  - [x] **5種類フォーマット対応** - CSV, JSON, XML, YAML, TSV形式
  - [x] **統計プロファイリング** - データ品質評価と統計的特徴抽出
  - [x] **データ品質アセスメント** - 外れ値分析、一貫性評価、推奨事項生成
  - [x] **包括的レポート生成** - 統計サマリーレポートと詳細分析
  - [x] **7個のCLIコマンド**: `export-csv`, `export-json`, `export-xml`, `export-yaml`, `export-tsv`, `export-report`, `export-profile`

- [x] **VisualizationPlugin** - ASCII可視化機能実装例
  - [x] **7種類の可視化** - ヒストグラム、箱ひげ図、散布図、折れ線グラフ、棒グラフ、分布図、ダッシュボード
  - [x] **統計的解釈付き可視化** - 各グラフに統計的解釈とレコメンデーション
  - [x] **カスタマイズ可能** - 幅、高さ、文字、精度等のオプション対応
  - [x] **包括的統計ダッシュボード** - 記述統計、分布特性、分析推奨事項の統合表示
  - [x] **7個のCLIコマンド**: `histogram`, `boxplot`, `scatter`, `line-chart`, `bar-chart`, `distribution`, `dashboard`

**実装ファイル**:
- `lib/number_analyzer/plugin_registry.rb` (420行) - 集中プラグイン管理システム
- `lib/number_analyzer/plugin_configuration.rb` (290行) - 多層設定管理システム
- `lib/number_analyzer/plugin_validator.rb` (490行) - セキュリティ検証システム
- `lib/number_analyzer/plugin_template.rb` (380行) - プラグインテンプレート生成
- `lib/number_analyzer/plugin_loader.rb` (強化版, 385行) - セキュアローダー
- `plugins/machine_learning_plugin.rb` (450行) - 機械学習サンプル
- `plugins/data_export_plugin.rb` (745行) - データエクスポートサンプル
- `plugins/visualization_plugin.rb` (830行) - 可視化サンプル

**Phase 8.0 Step 4 達成項目**:
- ✅ **プラグインAPI標準化完了** - サードパーティ開発者向けフレームワーク確立
- ✅ **セキュリティ重視設計** - 76パターン検出、4段階リスク評価、整合性検証
- ✅ **包括的サンプル実装** - 3カテゴリ19コマンドのフル機能プラグイン
- ✅ **開発者エクスペリエンス向上** - テンプレート生成、自動テスト、標準化
- ✅ **エンタープライズ対応** - 設定管理、依存関係検証、エラーハンドリング

## Phase 8.0 残りステップ (更新済み)

**詳細計画**: [PHASE_8_PLUGIN_SYSTEM_PLAN.md](PHASE_8_PLUGIN_SYSTEM_PLAN.md) 参照

### Step 3: Advanced Plugin Features ✅ 完了
- [x] Plugin dependency validation enhancement
- [x] Plugin configuration validation
- [x] Error handling and recovery mechanisms

### Step 4: Plugin API Standardization ✅ 完了
- [x] サードパーティプラグインAPI
- [x] 標準プラグインテンプレート
- [x] セキュリティ検証システム
- [x] 包括的サンプルプラグイン

### Step 5: Conflict Resolution System ✅ 完了 (3週間)
- [x] **重複管理システム（Conflict Resolution）** - プラグインエコシステムの安全性確保
  - **Week 1**: PluginPriority System ✅ **完了** - 階層的優先度システム (Development:100 > Core:90 > Official:70 > ThirdParty:50 > Local:30)
    - [x] `lib/number_analyzer/plugin_priority.rb` - 5階層優先度システム実装
    - [x] Class-based API: `get()`, `set()`, `can_override()`, `reset_custom_priorities!()`
    - [x] Backward compatibility with existing plugin system
    - [x] `spec/plugin_priority_spec.rb` - 12包括テスト (優先度比較、カスタム設定、重複解決基盤)
    - [x] Full API documentation and RuboCop compliance
  - **Week 2**: PluginNamespace System ✅ **完了** - 自動名前空間生成システム
    - [x] `lib/number_analyzer/plugin_namespace.rb` - 包括的名前空間管理システム (282行)
    - [x] 5つの優先度プレフィックス: development(de_), core(co_), official(of_), third_party(th_), local(lo_)
    - [x] Levenshtein距離ベース類似度検出 (閾値0.7) - 自動重複検出
    - [x] Priority-aware namespace generation - 優先度に応じた名前空間生成
    - [x] PluginPriority統合拡張: sort_by_priority()メソッド群追加
    - [x] `spec/plugin_namespace_spec.rb` - 26包括テスト (名前空間生成、重複検出、解決)
    - [x] ConflictResolver統合強化 - 43テスト維持、統合API完成
    - [x] RuboCop準拠 (ABC size最適化、メソッド分解)
  - **Week 3**: CLI Integration ✅ **完了** - pluginsサブコマンドとインタラクティブ解決
    - [x] `lib/number_analyzer/cli.rb` - pluginsサブコマンド追加 (30個目のコアコマンド)
    - [x] `plugins list [--show-conflicts]` - プラグイン一覧表示機能
    - [x] `plugins conflicts` - 重複検出専用コマンド
    - [x] `plugins resolve <plugin>` - 対話的/自動重複解決
    - [x] 4つの解決戦略: interactive, namespace, priority, disable
    - [x] `spec/plugins_cli_spec.rb` - 包括的CLIテスト (20テスト)
    - [x] README.md更新 - Plugin Management Commands セクション追加

**実装ファイル**:
- `lib/number_analyzer/plugin_priority.rb` - 階層的優先度管理
- `lib/number_analyzer/plugin_conflict_resolver.rb` - 重複解決エンジン
- `lib/number_analyzer/plugin_namespace.rb` - 名前空間管理
- `lib/number_analyzer/plugin_configuration.rb` - 3層設定システム強化

**CLI Integration**:
- `bundle exec number_analyzer plugins --conflicts` - 重複確認コマンド
- `bundle exec number_analyzer plugins resolve <plugin> --strategy=interactive` - インタラクティブ解決
- 自動名前空間: `na_ml_stats`, `ext_custom_gem_analyzer` パターン

**Success Criteria**:
- ✅ **Comprehensive test coverage** - 包括的なテストカバレッジ達成
- ✅ **Zero RuboCop violations maintained** - 全ファイル準拠確認済み
- ✅ **Conflict-free plugin ecosystem** - 自動名前空間生成による重複解決基盤完成
- ✅ **CLI integration complete** - pluginsサブコマンド実装完了

**Phase 8.0 Step 5 達成項目**:
- ✅ **安全なプラグインエコシステム**: 自動重複管理システム実装
- ✅ **開発者フレンドリー**: 直感的な重複解決とインタラクティブCLI
- ✅ **Production Ready**: エンタープライズレベルの安定性確保
- ✅ **Plugin System Complete**: Phase 8.0 アーキテクチャ完全実装

### CLI Refactoring Development Progress

#### Phase 1: 基盤構築と基本コマンド移行 ✅ 完了

**Phase 1.1: CLI基盤構築 ✅ 完了**
- [x] Command Pattern 実装（BaseCommand, CommandRegistry, DataInputHandler）
- [x] Template Method Pattern 導入（共通実行フロー）
- [x] TDD アプローチによる6基本コマンド実装（median, mean, mode, sum, min, max）
- [x] 統合テストスイート作成（commands_registration_spec.rb）
- [x] RuboCop compliance 確保

**Phase 1.2: コード品質改善 ✅ 完了**
- [x] protected から private への変更（Matz ベストプラクティス適用）
- [x] Here Document リファクタリング（10+箇所の文字列改善）
- [x] RSpec TypeError 修正（NumberAnalyzer class/module 競合解決）
- [x] StatisticsPresenter インライン定義への変更
- [x] ファイル読み込み順序最適化

**Phase 1.3: 基本コマンド移行完了 ✅ 完了**
- [x] 追加7コマンド実装（histogram, outliers, percentile, quartiles, variance, std, deviation-scores）
- [x] 全13基本統計コマンドのCommand Pattern移行完了
- [x] TDD実装（Red-Green-Refactor サイクル厳守）
- [x] 包括的テストスイート（759行追加、11ファイル）
- [x] RuboCop compliance ゼロ違反維持
- [x] 完全後方互換性保持（全CLI インターフェース保持）
- [x] 個別コマンドクラス実装（各50-80行 vs 2185行monolith）
- [x] Template Method Pattern 最適化
- [x] 統一エラーハンドリング・引数検証

**Phase 1 達成メトリクス**:
- ✅ **13/29 コマンド移行完了**: 基本統計コマンド全てをCommand Pattern適用
- ✅ **Command Pattern実装**: BaseCommand継承による50-80行の独立クラス
- ✅ **TDD品質保証**: Red-Green-Refactor サイクルによる実装
- ✅ **テスト充実化**: 759行のテストコード追加（11新規ファイル）
- ✅ **アーキテクチャ改善**: 2185行monolith→独立可能なクラス群
- ✅ **開発効率向上**: 独立テスト可能性、保守性、拡張性の大幅改善
- ✅ **Here Document改善**: CLI.rb と StatisticsPresenter で10+箇所最適化
- ✅ **RSpec エラー解決**: class/module 競合によるTypeError完全修正
- ✅ **コード可読性改善**: protected→private変更、文字列整理

#### Phase 2: 複雑コマンド移行 ✅ 完了

**完了実績**:
- ✅ **Phase 1完了**: 13個の基本統計コマンドが Command Pattern に移行済み
- ✅ **Phase 2.1-2.6完了**: 全29コマンドのCommand Pattern移行完了（29/29 commands migrated）
- ✅ **Code Quality**: StatisticalOutputFormatter実装、RuboCop violations 60%削減
- ✅ **CLI.rb軽量化**: 2094行 → 385行（81%削減達成）
- ✅ **完全移行達成**: 全コマンドがCommandRegistryを通じて実行される統一アーキテクチャ完成

**Phase 2.1: 相関・時系列分析コマンド移行 (5個)** ✅ 完了
- [x] `correlation` → `CorrelationCommand` ✅ 完了 (特別処理統合完了)
- [x] `trend` → `TrendCommand` ✅ 完了 (線形トレンド分析移行完了)
- [x] `moving-average` → `MovingAverageCommand` ✅ 完了 (3期移動平均、カスタムウィンドウ対応)
- [x] `growth-rate` → `GrowthRateCommand` ✅ 完了 (CAGR計算、成長率分析)
- [x] `seasonal` → `SeasonalCommand` ✅ 完了 (季節性分析、周期検出)

**Phase 2.2: 統計検定コマンド移行 (3個)** ✅ 完了
- [x] `t-test` → `TTestCommand` ✅ 完了 (独立/対応/一標本t検定、3つの検定タイプ対応)
- [x] `confidence-interval` → `ConfidenceIntervalCommand` ✅ 完了 (信頼区間計算、t分布対応)
- [x] `chi-square` → `ChiSquareCommand` ✅ 完了 (カイ二乗検定、独立性/適合度検定)

**Phase 2 Code Quality Improvements** ✅ 完了
- [x] **StatisticalOutputFormatter実装** - 統計コマンドの出力フォーマット統一
- [x] **CLI重複定義修正** - NumberAnalyzer::CLI重複クラス定義問題解決
- [x] **RuboCop violations削減** - 17違反→7違反（60%削減）
- [x] **コード重複解消** - 複雑なoutput_standardメソッドのリファクタリング
- [x] **統計表示の一元化** - format_value, format_significance, format_basic_statistics等の共通化
- [x] **テスト保証** - 全140テスト通過、CLI機能正常動作確認済み

**Phase 2.3: 分散分析コマンド移行 (4個)** ✅ 完了
- [x] `anova` → `AnovaCommand` ✅ 完了 (一元配置分散分析、効果サイズ計算、事後検定対応)
- [x] `two-way-anova` → `TwoWayAnovaCommand` ✅ 完了 (二元配置分散分析、主効果・交互作用分析)
- [x] `levene` → `LeveneCommand` ✅ 完了 (Levene検定、Brown-Forsythe修正版、分散等質性検定)
- [x] `bartlett` → `BartlettCommand` ✅ 完了 (Bartlett検定、正規性仮定下での分散等質性検定)

**Phase 2.4: ノンパラメトリック検定コマンド移行 (4個)** ✅ 完了
- [x] `kruskal-wallis` → `KruskalWallisCommand` ✅ 完了 (Kruskal-Wallis検定、ノンパラメトリックANOVA)
- [x] `mann-whitney` → `MannWhitneyCommand` ✅ 完了 (Mann-Whitney U検定、ノンパラメトリックt検定)
- [x] `wilcoxon` → `WilcoxonCommand` ✅ 完了 (Wilcoxon符号順位検定、対応ありノンパラメトリック検定)
- [x] `friedman` → `FriedmanCommand` ✅ 完了 (Friedman検定、反復測定ノンパラメトリックANOVA)

**Phase 2.5: プラグイン管理コマンド移行 (1個)** ✅ 完了
- [x] `plugins` → `PluginsCommand` ✅ 完了 (プラグイン管理コマンド、list/resolve/conflicts機能)

**Phase 2.6: CLI.rb軽量化** ✅ 完了
- [x] 移行済みコマンドのレガシーコード削除 ✅ 完了 (全run_*メソッド削除、1700行削減)
- [x] ディスパッチャー機能への最適化 ✅ 完了 (CORE_COMMANDS空化、CommandRegistry一本化)
- [x] 2094行 → 385行達成 ✅ 完了 (81%削減達成、当初目標の100行を大幅上回る削減)

**Phase 2 実装戦略**:
- **TDD厳守**: Red-Green-Refactor サイクル
- **段階的移行**: 5ステップに分けて実装
- **完全後方互換性**: 既存CLI インターフェース保持
- **RuboCop compliance**: ゼロ違反維持
- **包括的テスト**: 各コマンドの独立テスト実装

**Phase 2 期待効果**:
- **CLI.rb軽量化**: 2185行 → 100行（95%削減）
- **29/29コマンド移行完了**: 全コマンドのCommand Pattern適用
- **保守性向上**: 複雑コマンドの独立テスト可能性
- **拡張性向上**: 新規コマンド追加の簡易化

### Code Quality & Architecture Improvements ✅ 完了

#### Compact Style Conversion Project ✅ 完了 (January 2025)

**Major Achievement: 全コードベースをCompact Style に統一**

- ✅ **RuboCop設定強化**: Style/ClassAndModuleChildren をcompact style強制に変更
- ✅ **全体変換実行**: 100+ファイルにRuboCop自動修正適用
- ✅ **Namespace解決**: compact style変換後の名前空間参照問題を完全修正
  - Plugin system内のCLI参照修正 (`CLI` → `NumberAnalyzer::CLI`)
  - Command registry参照修正 (`Commands::` → `NumberAnalyzer::Commands::`)
  - FileReader, OutputFormatter等の完全修飾名対応
- ✅ **テスト品質維持**: 139/139テスト全て成功を維持
- ✅ **Zero RuboCop violations**: 100ファイル検査で違反ゼロ達成
- ✅ **開発環境整理**: 14個のバックアップファイル（*.rb.bak）クリーンアップ完了

**技術的課題と解決**:
- **Challenge**: Compact style変換がプラグインシステムの名前空間解決に影響
- **Solution**: 段階的namespace修正で34→16→0の失敗テスト削減を実現
- **Impact**: コードベース全体の一貫性確保、将来の保守性大幅向上

**達成メトリクス**:
- ✅ **全ファイル統一**: nested style → compact style (`NumberAnalyzer::ClassName`)
- ✅ **品質保証**: 139テスト全成功 + RuboCop違反ゼロ
- ✅ **アーキテクチャ強化**: 名前空間の明確化による設計品質向上
- ✅ **開発標準確立**: compact styleを今後の開発標準として確立

## Future Plans (今後の計画)

### CLI Refactoring Project - Phase 3 以降の計画
- **Phase 2 実行中**: 17個の複雑コマンド移行（correlation, time-series, statistical tests, ANOVA, non-parametric, plugins）
- **Phase 3 計画**: CLI.rb 最終軽量化とパフォーマンス最適化
- **最終目標**: 全29コマンドの完全Command Pattern移行 + CLI.rb 100行達成
- **期待効果**: 95%のコード削減、保守性・テスト性・拡張性の大幅向上
- **詳細計画**: [CLI_REFACTORING_PLAN.md](CLI_REFACTORING_PLAN.md) 参照

### Phase 9: CLI Ultimate Optimization 🚀 計画策定済み
**CLI.rb の最終最適化 - 385行から100行以下への削減**

#### 目標メトリクス
- **現在**: 385行（元の2094行から81%削減済み）
- **目標**: 100行以下（総削減率95%以上）
- **アプローチ**: モジュール分離による責任の分散

#### 実装計画（3フェーズ、5週間）
**Phase 1: モジュール化（2週間）**
- [ ] CLIOptions モジュール抽出（オプション解析の外部化、~80行削減）
- [ ] HelpGenerator モジュール作成（ヘルプシステムの分離、~40行削減）
- [ ] InputProcessor モジュール統合（入力処理の一元化、~60行削減）
- [ ] 既存テストの更新と新規モジュールテスト作成

**Phase 2: 機能強化（2週間）**
- [ ] プラグインコマンド優先度システム実装（競合解決機能）
- [ ] 高度なエラーハンドリング（コンテキスト付きエラー、対話的回復）
- [ ] コマンドキャッシング機構（パフォーマンス最適化）
- [ ] デバッグモード対応（開発者体験向上）

**Phase 3: 開発者体験（1週間）**
- [ ] シェル補完機能サポート（bash/zsh自動補完）
- [ ] プラグインフックシステム（before/after hooks）
- [ ] 設定ファイル対応（~/.number_analyzer/config.yml）
- [ ] 移行ガイド作成

#### 期待される成果
- **保守性**: 各モジュールが単一責任を持つ
- **拡張性**: 新機能追加が容易
- **パフォーマンス**: 遅延ロードとキャッシング
- **開発者体験**: デバッグ、補完、フック機能
- **ユーザー体験**: より良いエラーメッセージ、対話的回復

**詳細提案書**: [CLI_IMPROVEMENT_PROPOSALS.md](CLI_IMPROVEMENT_PROPOSALS.md) 参照

### Potential Phase 10: Performance Optimization
- **Benchmarking Suite**: パフォーマンス測定基盤
- **Algorithm Optimization**: 統計計算の最適化
- **Memory Management**: 大規模データセット対応

### Potential Phase 11: Visualization Enhancement
- **Advanced Charts**: グラフ描画機能の拡張
- **Export Formats**: PNG/SVG出力対応
- **Interactive Mode**: 対話的データ探索
