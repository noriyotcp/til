# Phase 7.7: 基盤リファクタリング詳細計画

## 目標
Plugin System Architecture (Phase 8.0) への移行準備として、元々1,727行のモノリシックファイル `lib/numana.rb` を段階的にモジュール分割し、保守性・拡張性を向上させる。現在307行まで削減済み（1,420行・82.2%削減達成）。

## 現在の課題

### 1. ファイルサイズ問題 ✅ 大幅改善済み
- **~~1,727行のモノリシックファイル~~** → **307行まで削減済み（1,420行・82.2%削減）**
- **可読性向上**: 7つのモジュール分割により機能別アクセス改善
- **保守負荷軽減**: 責任分離により変更影響範囲を限定

### 2. 責任分離違反 ✅ 大幅改善済み
- **32個の統計機能**: 7つのモジュール（BasicStats + MathUtils + AdvancedStats + CorrelationStats + TimeSeriesStats + HypothesisTesting + ANOVAStats）に分離完了
- **単一責任原則改善**: 基本統計・数学関数・高度統計・相関分析・時系列分析・仮説検定・分散分析を独立モジュール化済み
- **拡張性向上**: モジュール境界による新機能追加の複雑度削減

### 3. 技術的重複 ✅ 解消済み
- **~~メソッド重複リスク~~**: MathUtilsモジュール統合により重複完全解消
- **~~数学関数散在~~**: 共通数学関数をMathUtilsに一元化済み
- **保守負荷軽減**: 単一箇所修正による保守性向上達成

## リファクタリング戦略

**進捗状況**: Step 1, 2, 3, 4, 5, 6, 7, 8 完了 ✅ | 基盤リファクタリング完了 🎉

### Phase 7.7 Step 1: BasicStats モジュール抽出 ✅ 完了

#### 対象メソッド
```ruby
# lib/numana/statistics/basic_stats.rb
module NumberAnalyzer
  module Statistics
    module BasicStats
      def sum
        @numbers.sum
      end
      
      def average_value
        return 0.0 if @numbers.empty?
        @numbers.sum.to_f / @numbers.length
      end
      
      def median
        percentile(50)
      end
      
      def mode
        # 既存実装を移動
      end
      
      def variance
        # 既存実装を移動
      end
      
      def standard_deviation
        Math.sqrt(variance)
      end
    end
  end
end
```

#### 統合方法
```ruby
# lib/numana.rb (メインクラス)
class NumberAnalyzer
  include Statistics::BasicStats
  
  def initialize(numbers)
    @numbers = numbers
  end
  
  # calculate_statistics は既存のまま維持
  # 他のメソッドは段階的に移動
end
```

### Phase 7.7 Step 2: MathUtils 共通モジュール ✅ 完了

#### 共通数学関数の抽出
```ruby
# lib/numana/math_utils.rb
module NumberAnalyzer
  module MathUtils
    def self.standard_normal_cdf(z)
      # 既存実装を統合
    end
    
    def self.erf(x)
      # 既存実装を統合
    end
    
    def self.gamma_function(n)
      # 既存実装を統合
    end
    
    def self.chi_square_cdf(x, df)
      # 既存実装を統合
    end
    
    def self.t_distribution_cdf(t, df)
      # 既存実装を統合
    end
  end
end
```

### Phase 7.7 Step 3: AdvancedStats モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/advanced_stats.rb (65行)
module AdvancedStats
  def percentile(percentile_value)
    # パーセンタイル計算（線形補間法）
  end
  
  def quartiles
    # Q1, Q2, Q3 の計算
  end
  
  def interquartile_range
    # IQR = Q3 - Q1
  end
  
  def outliers
    # 1.5*IQR ルールによる外れ値検出
  end
  
  def deviation_scores
    # 偏差値計算（平均50, 標準偏差10）
  end
end
```

#### Step 3 達成項目
- **59行削減**: 1,615行 → 1,556行
- **5メソッド抽出**: percentile, quartiles, interquartile_range, outliers, deviation_scores
- **26ユニットテスト追加**: spec/numana/statistics/advanced_stats_spec.rb
- **API完全互換**: 164テスト全通過（106統合 + 58ユニット）
- **RuboCop準拠**: ゼロ違反維持

### Phase 7.7 Step 4: CorrelationStats モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/correlation_stats.rb (54行)
module CorrelationStats
  def correlation(other_dataset)
    # ピアソン相関係数計算
  end
  
  def interpret_correlation(correlation_value)
    # 相関強度解釈（日本語）
  end
end
```

#### Step 4 達成項目
- **28行削減**: 1,556行 → 1,528行
- **2メソッド抽出**: correlation, interpret_correlation
- **32ユニットテスト追加**: spec/numana/statistics/correlation_stats_spec.rb
- **API完全互換**: 192テスト全通過（106統合 + 86ユニット）
- **RuboCop準拠**: ゼロ違反維持

### Phase 7.7 Step 5: TimeSeriesStats モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/time_series_stats.rb (279行)
module TimeSeriesStats
  def linear_trend
    # 線形トレンド分析（slope, intercept, R², direction）
  end
  
  def moving_average(window_size)
    # 移動平均計算（カスタムウィンドウサイズ）
  end
  
  def growth_rates
    # 期間別成長率計算
  end
  
  def compound_annual_growth_rate
    # 年平均成長率（CAGR）計算
  end
  
  def average_growth_rate
    # 平均成長率計算（無限値除外）
  end
  
  def seasonal_decomposition(period = nil)
    # 季節性分解分析（自動周期検出）
  end
  
  def detect_seasonal_period
    # 季節性周期自動検出
  end
  
  def seasonal_strength
    # 季節性強度計算
  end
  
  # + 10個のプライベートヘルパーメソッド
end
```

#### Step 5 達成項目
- **257行削減**: 1,528行 → 1,271行
- **9メソッド抽出**: linear_trend, moving_average, growth_rates, compound_annual_growth_rate, average_growth_rate, seasonal_decomposition, detect_seasonal_period, seasonal_strength + 10個のプライベートヘルパーメソッド
- **38ユニットテスト追加**: spec/numana/statistics/time_series_stats_spec.rb
- **API完全互換**: 230テスト全通過（106統合 + 124ユニット）
- **RuboCop準拠**: ゼロ違反維持

### Phase 7.7 Step 6: HypothesisTesting モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/hypothesis_testing.rb (480行)
module HypothesisTesting
  def t_test(other_data, type: :independent, population_mean: nil)
    # 独立サンプル・対応サンプル・一標本t検定（Welchの式）
  end
  
  def confidence_interval(confidence_level, type: :mean)
    # 母平均の信頼区間（t分布使用）
  end
  
  def chi_square_test(expected_data = nil, type: :independence)
    # カイ二乗検定（独立性・適合度）+ Cramér's V効果サイズ
  end
  
  # + 30個以上のプライベートヘルパーメソッド
  # （統計的検定、信頼区間、カイ二乗分布、逆正規分布等）
end
```

#### Step 6 達成項目
- **410行削減**: 1,271行 → 861行
- **3メソッド抽出**: t_test, confidence_interval, chi_square_test + 30個以上のプライベートヘルパーメソッド
- **32ユニットテスト追加**: spec/numana/statistics/hypothesis_testing_spec.rb
- **API完全互換**: 106テスト全通過（統合テスト）
- **RuboCop準拠**: ゼロ違反維持（統計モジュール除外設定追加）
- **数学的正確性**: Welchのt検定、t分布信頼区間、カイ二乗分布p値計算

### Phase 7.7 Step 7: ANOVAStats モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/anova_stats.rb (902→17行, 3モジュール分割完了)
module ANOVAStats
  def one_way_anova(*groups)
    # 一元配置分散分析（F統計量、効果サイズ測定）
  end
  
  def post_hoc_analysis(groups, method: :tukey)
    # 事後検定（Tukey HSD、Bonferroni補正）
  end
  
  def levene_test(*groups)
    # Levene検定（Brown-Forsythe修正による分散等質性検定）
  end
  
  def bartlett_test(*groups)
    # Bartlett検定（正規性仮定下での分散等質性検定）
  end
  
  # + 25個以上のプライベートヘルパーメソッド
  # （ANOVA計算、事後検定、分散等質性検定、効果サイズ等）
end
```

#### Step 7 達成項目
- **554行削減**: 861行 → 307行
- **4メソッド抽出**: one_way_anova, post_hoc_analysis, levene_test, bartlett_test + 25個以上のプライベートヘルパーメソッド
- **38ユニットテスト追加**: spec/numana/statistics/anova_stats_spec.rb
- **API完全互換**: 106テスト全通過（統合テスト）
- **RuboCop準拠**: ゼロ違反維持
- **分散分析完全統合**: ANOVA + 事後検定 + 分散等質性検定の専門モジュール化

### Phase 7.7 Step 8: NonParametricStats モジュール抽出 ✅ 完了

#### 実装完了内容
```ruby
# lib/numana/statistics/non_parametric_stats.rb (246行)
module NonParametricStats
  def kruskal_wallis_test(*groups)
    # Kruskal-Wallis H検定（ノンパラメトリックANOVA）
  end
  
  def mann_whitney_u_test(group1, group2)
    # Mann-Whitney U検定（ノンパラメトリック2群比較）
  end
  
  # + 3個のプライベートヘルパーメソッド
  # （ランク計算、タイ補正、Mann-Whitney分散計算）
end
```

#### Step 8 達成項目
- **234行削減**: 302行 → 68行
- **2メソッド抽出**: kruskal_wallis_test, mann_whitney_u_test + 3個のプライベートヘルパーメソッド
- **26ユニットテスト追加**: spec/numana/statistics/non_parametric_stats_spec.rb
- **API完全互換**: 106テスト全通過確認（統合テスト）
- **RuboCop準拠**: ゼロ違反維持
- **ノンパラメトリック検定完全統合**: Kruskal-Wallis + Mann-Whitney U検定の専門モジュール化

#### 抽出順序と対象
1. **BasicStats**: sum, mean, mode, variance, standard_deviation ✅ **完了**
2. **MathUtils**: 数学的ユーティリティ関数 ✅ **完了**
3. **AdvancedStats**: percentiles, quartiles, IQR, outliers, deviation_scores ✅ **完了**
4. **CorrelationStats**: correlation analysis ✅ **完了**
5. **TimeSeriesStats**: trend, moving_average, growth_rate, seasonal ✅ **完了**
6. **HypothesisTesting**: t_test, confidence_interval, chi_square ✅ **完了**
7. **ANOVAStats**: one_way_anova, post_hoc tests (tukey_hsd, bonferroni), levene_test, bartlett_test ✅ **完了**
8. **NonParametricStats**: kruskal_wallis, mann_whitney ✅ **完了**

#### 各モジュールの責任範囲
```ruby
# lib/numana/statistics/advanced_stats.rb ✅ 完了
module AdvancedStats
  # percentile, quartiles, interquartile_range
  # outliers, deviation_scores
end

# lib/numana/statistics/correlation_stats.rb ✅ 完了
module CorrelationStats
  # correlation, interpret_correlation
end

# lib/numana/statistics/time_series_stats.rb ✅ 完了
module TimeSeriesStats
  # linear_trend, moving_average, growth_rates, compound_annual_growth_rate
  # average_growth_rate, seasonal_decomposition, detect_seasonal_period, seasonal_strength
end

# lib/numana/statistics/hypothesis_testing.rb ✅ 完了
module HypothesisTesting
  # t_test, confidence_interval, chi_square_test
end

# lib/numana/statistics/anova_stats.rb ✅ 完了
module ANOVAStats
  # one_way_anova, post_hoc_analysis, levene_test, bartlett_test
end
```

## 品質保証戦略

### 1. 後方互換性維持
- **既存API完全保持**: `NumberAnalyzer.new([1,2,3]).median` 等は変更なし
- **CLI動作保持**: 全26サブコマンドの動作を完全維持
- **出力フォーマット保持**: JSON, precision, quiet等の全オプション対応

### 2. テスト戦略 ✅ 大幅強化済み
- **106テスト全通過**: 各段階で既存テスト全通過確認（106統合テスト）
- **ユニットテスト追加**: 各モジュールに包括的ユニットテスト追加済み（32 BasicStats + 26 AdvancedStats + 28 CorrelationStats + 38 TimeSeriesStats + 32 HypothesisTesting = 156ユニットテスト）
- **リグレッションテスト**: 各モジュール抽出後に全テスト実行済み

### 3. コード品質維持
- **RuboCop違反ゼロ**: 各段階でRuboCop準拠を確認
- **メソッド署名維持**: public/private の区別保持
- **名前空間整理**: NumberAnalyzer::Statistics 以下の整然とした構造

## 実装手順

### Step 1 実装詳細
1. **ディレクトリ作成**: `lib/numana/statistics/` 作成
2. **BasicStats作成**: basic_stats.rb 作成、対象メソッド移動
3. **include追加**: NumberAnalyzer に `include Statistics::BasicStats` 追加
4. **テスト実行**: `bundle exec rspec` で106テスト全通過確認
5. **RuboCop確認**: `bundle exec rubocop` で違反ゼロ確認

### Step 2 実装詳細
1. **MathUtils作成**: math_utils.rb 作成
2. **重複解消**: 各モジュールから MathUtils への参照に変更
3. **テスト実行**: 全テスト通過確認
4. **RuboCop確認**: 違反ゼロ確認

### Step 3以降
- 同様の手順で残りモジュールを順次抽出
- 各段階で品質ゲートを通過してから次へ進行

## Plugin System Architecture への移行パス

### 自然な進化
```ruby
# Phase 7.7 (モジュール分割)
class NumberAnalyzer
  include Statistics::BasicStats
  include Statistics::AdvancedStats
  # ...
end

# Phase 8.0 (プラグインシステム)
class NumberAnalyzer
  include PluginRegistry.load_plugin(:basic_stats)
  include PluginRegistry.load_plugin(:advanced_stats)
  # 動的ロード、設定ベース管理
end
```

### 移行の利点
- **段階的変更**: include パターンから動的includeへの自然な進化
- **境界維持**: モジュール境界 = プラグイン境界として活用
- **リスク最小化**: 各段階でのAPI保持、テスト通過による安全性確保

## 達成された効果と今後の予想

### 基盤リファクタリング完了効果 (Steps 1-8 完了) 🎉
- **可読性大幅向上**: 68行（1,659行・96.1%削減）+ 8つの専門モジュール
- **保守性向上**: 基本統計・数学関数・高度統計・相関分析・時系列分析・仮説検定・分散分析・ノンパラメトリック検定の責任分離完了
- **テスト品質強化**: 326テスト（220ユニット + 106統合）による品質保証
- **技術的重複解消**: MathUtilsによる数学関数の一元管理
- **開発効率向上**: 機能別ファイルによる迅速なアクセス
- **Plugin System準備**: 完全モジュラーアーキテクチャによるPhase 8.0移行パス確立

### 短期効果 (Phase 7.7 Step 8完了時) - 目標大幅超過達成 🚀
- **可読性向上**: メインファイル68行 + 各モジュール50-566行程度 ✅✅
- **保守性向上**: 8つのモジュールによる完全責任分離達成 ✅✅
- **開発効率向上**: 統計機能への専門ファイル経由アクセス ✅✅
- **Phase 8.0準備**: Plugin System Architecture移行準備完了 🎉

### 長期効果 (Phase 8.0 移行時)
- **拡張性向上**: プラグインベース新機能追加
- **第三者貢献**: 外部プラグイン開発の基盤
- **統合可能性**: 外部ツール統合の準備

## リスク管理

### 実装リスク
- **API破壊**: include による公開メソッドの変更 → 段階的テストで回避
- **パフォーマンス**: モジュール呼び出しオーバーヘッド → ベンチマーク測定
- **循環依存**: モジュール間の依存関係 → 依存方向の明確化

### 回避策
- **段階的実装**: 一度に1モジュールずつ抽出
- **継続テスト**: 各段階での全テスト実行
- **ロールバック準備**: Git による各段階のコミット管理