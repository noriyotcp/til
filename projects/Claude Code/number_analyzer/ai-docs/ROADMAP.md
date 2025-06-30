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

**現在の成果**: 138+テスト実行例、32統計指標、Phase 7.7 Step 2完全実装、MathUtilsモジュラーアーキテクチャ、企業レベル品質

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
- ✅ **106テスト実行例**: 全項目網羅の包括的テストスイート
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

## Next Development Phase

### Phase 7.7 Step 3: AdvancedStats Module Extraction 🔧 次の実装対象
**高度統計分析関数のモジュール化**
- [ ] `lib/number_analyzer/statistics/advanced_stats.rb` モジュール作成
- [ ] 高度統計関数抽出: `percentile`, `quartiles`, `interquartile_range`, `outliers`, `deviation_scores`
- [ ] percentile依存関係の整理とモジュール化
- [ ] 高度統計分析の一元管理

### Phase 7.6 Step 2: Wilcoxon Signed-Rank Test Implementation 🔮 計画段階
**対応のある2群比較のノンパラメトリック検定**
- [ ] `wilcoxon_signed_rank_test(before, after)` メソッド実装
- [ ] 符号順位統計量計算とタイ補正
- [ ] 正規近似による検定統計量計算
- [ ] CLI統合: `'wilcoxon' => :run_wilcoxon` コマンド追加
- [ ] 対応のあるt検定との比較機能

### Phase 7.6 Step 3: Friedman Test Implementation 🔮 計画段階
**反復測定のノンパラメトリックANOVA**
- [ ] `friedman_test(*repeated_groups)` メソッド実装
- [ ] χ²統計量計算: `χ² = [12/(b*k*(k+1))] * [Σ(Rj²)] - 3*b*(k+1)`
- [ ] 反復測定データ構造対応
- [ ] CLI統合: `'friedman' => :run_friedman` コマンド追加

### Future ANOVA Extension Features 🔮 長期計画
- 🔮 **二元配置分散分析**: 2つの要因の主効果と交互作用
- 🔮 **反復測定ANOVA**: 被験者内計画による分散分析
- 🔮 **Friedman検定**: 反復測定のノンパラメトリック代替

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
