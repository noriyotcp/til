# Phase 7.7: 基盤リファクタリング詳細計画

## 目標
Plugin System Architecture (Phase 8.0) への移行準備として、現在1,727行のモノリシックファイル `lib/number_analyzer.rb` を段階的にモジュール分割し、保守性・拡張性を向上させる。

## 現在の課題

### 1. ファイルサイズ問題
- **1,727行のモノリシックファイル**: 単一ファイルとして限界サイズ
- **可読性低下**: スクロールによる関数探索の困難
- **保守負荷**: 変更時の影響範囲把握困難

### 2. 責任分離違反
- **32個の統計機能**: 1クラスに集約されすぎ
- **単一責任原則違反**: 基本統計〜高度検定まで全てを担当
- **拡張性限界**: 新機能追加時の複雑度増加

### 3. 技術的重複
- **メソッド重複リスク**: `standard_normal_cdf`, `erf` 等の重複
- **数学関数散在**: 各統計メソッド内に埋め込まれた共通計算
- **保守負荷**: 同じ機能の複数箇所修正

## リファクタリング戦略

### Phase 7.7 Step 1: BasicStats モジュール抽出

#### 対象メソッド
```ruby
# lib/number_analyzer/statistics/basic_stats.rb
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
# lib/number_analyzer.rb (メインクラス)
class NumberAnalyzer
  include Statistics::BasicStats
  
  def initialize(numbers)
    @numbers = numbers
  end
  
  # calculate_statistics は既存のまま維持
  # 他のメソッドは段階的に移動
end
```

### Phase 7.7 Step 2: MathUtils 共通モジュール

#### 共通数学関数の抽出
```ruby
# lib/number_analyzer/math_utils.rb
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

### Phase 7.7 Step 3: 段階的モジュール抽出

#### 抽出順序と対象
1. **AdvancedStats**: percentiles, quartiles, IQR, outliers, deviation_scores
2. **CorrelationStats**: correlation analysis
3. **TimeSeriesStats**: trend, moving_average, growth_rate, seasonal
4. **HypothesisTesting**: t_test, confidence_interval, chi_square
5. **ANOVAStats**: one_way_anova, post_hoc tests (tukey_hsd, bonferroni)
6. **NonParametricStats**: kruskal_wallis, mann_whitney, levene, bartlett

#### 各モジュールの責任範囲
```ruby
# lib/number_analyzer/statistics/advanced_stats.rb
module AdvancedStats
  # percentile, quartiles, interquartile_range
  # outliers, deviation_scores
end

# lib/number_analyzer/statistics/time_series_stats.rb  
module TimeSeriesStats
  # linear_trend_analysis, moving_average_analysis
  # growth_rate_analysis, seasonal_pattern_analysis
end

# lib/number_analyzer/statistics/hypothesis_testing.rb
module HypothesisTesting
  # t_test, confidence_interval, chi_square_test
end
```

## 品質保証戦略

### 1. 後方互換性維持
- **既存API完全保持**: `NumberAnalyzer.new([1,2,3]).median` 等は変更なし
- **CLI動作保持**: 全26サブコマンドの動作を完全維持
- **出力フォーマット保持**: JSON, precision, quiet等の全オプション対応

### 2. テスト戦略
- **106テスト全通過**: 各段階で既存テスト全通過を確認
- **新規テストなし**: 機能追加ではないため新規テスト不要
- **リグレッションテスト**: 各モジュール抽出後に全テスト実行

### 3. コード品質維持
- **RuboCop違反ゼロ**: 各段階でRuboCop準拠を確認
- **メソッド署名維持**: public/private の区別保持
- **名前空間整理**: NumberAnalyzer::Statistics 以下の整然とした構造

## 実装手順

### Step 1 実装詳細
1. **ディレクトリ作成**: `lib/number_analyzer/statistics/` 作成
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

## 予想される効果

### 短期効果 (Phase 7.7 完了時)
- **可読性向上**: 各ファイル200-300行程度に分割
- **保守性向上**: 責任分離による変更影響範囲の限定
- **開発効率向上**: 目的の機能への素早いアクセス

### 長期効果 (Phase 8.0 移行時)
- **拡張性向上**: プラグインベース新機能追加
- **第三者貢献**: 外部プラグイン開発の基盤
- **統合可能性**: R/Python等外部ツール統合の準備

## リスク管理

### 実装リスク
- **API破壊**: include による公開メソッドの変更 → 段階的テストで回避
- **パフォーマンス**: モジュール呼び出しオーバーヘッド → ベンチマーク測定
- **循環依存**: モジュール間の依存関係 → 依存方向の明確化

### 回避策
- **段階的実装**: 一度に1モジュールずつ抽出
- **継続テスト**: 各段階での全テスト実行
- **ロールバック準備**: Git による各段階のコミット管理