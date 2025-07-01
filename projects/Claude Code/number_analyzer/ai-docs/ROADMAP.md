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

**現在の成果**: 106テスト実行例、33統計指標、Phase 7.6 Step 3完全実装、8モジュール抽出アーキテクチャ（96.1%コード削減）、企業レベル品質

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

## Phase 8.0: Plugin System Architecture 🚀 準備完了

**Phase 7.7 基盤リファクタリング完了により、Plugin System Architecture への自然な移行パスが確立**

## Phase 8.0: Plugin System Architecture 移行計画

### Plugin System Features
- Dynamic command loading
- Third-party extension support
- Configuration-based plugin management

### Integration Possibilities
- R/Python interoperability
- Database connectivity
- Web API endpoints
- Jupyter notebook integration
