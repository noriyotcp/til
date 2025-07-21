# Phase 8.0: Plugin System Architecture 実装計画書

## 🎯 概要
Phase 7.7で達成した完全モジュラー化（96.1%コード削減、8モジュール構成）を基盤として、NumberAnalyzerを次世代統計分析プラットフォームに進化させる。プラグインベースの拡張可能なアーキテクチャを構築し、外部開発者による機能拡張を可能にする。

## 📊 現在の基盤状況（Phase 7.8完了時点）

### ✅ 完璧な基盤が完成済み
- **68行のコアクラス** + **8つの専門モジュール**
- **326テスト** (220ユニット + 106統合)
- **29サブコマンド** 完全動作
- **完全モジュラー設計** 既に実装済み

```ruby
# 現在の構造 (理想的なプラグイン基盤)
# lib/number_analyzer.rb (68行)
class NumberAnalyzer
  include BasicStats
  include AdvancedStats
  include CorrelationStats
  include TimeSeriesStats
  include HypothesisTesting
  include ANOVAStats
  include NonParametricStats
end
```

### 🏗️ モジュール構成
```
lib/number_analyzer/statistics/
├── basic_stats.rb          # 基本統計 (sum, mean, mode, variance, std_dev)
├── math_utils.rb           # 数学関数 (標準正規分布, t分布, F分布, etc.)
├── advanced_stats.rb       # 高度統計 (percentiles, quartiles, outliers)
├── correlation_stats.rb    # 相関分析 (Pearson correlation)
├── time_series_stats.rb    # 時系列分析 (trend, moving_average, seasonal)
├── hypothesis_testing.rb   # 仮説検定 (t-test, confidence_interval, chi-square)
├── anova_stats.rb          # 分散分析 (modular: includes one_way_anova, two_way_anova, anova_helpers)
├── one_way_anova.rb        # 一元ANOVA計算 (216行)
├── two_way_anova.rb        # 二元ANOVA計算 (341行)
├── anova_helpers.rb        # ANOVA共通ユーティリティ (368行)
└── non_parametric_stats.rb # ノンパラメトリック (Kruskal-Wallis, Mann-Whitney, etc.)
```

## 🔧 Phase 8.0 実装計画

### Step 1: Plugin Registry System
**プラグイン管理の中核システム + 重複管理機能**

**重要**: プラグイン名重複管理の詳細は **[PHASE_8_STEP_5_CONFLICT_RESOLUTION_PLAN.md](PHASE_8_STEP_5_CONFLICT_RESOLUTION_PLAN.md)** を参照

```ruby
# lib/number_analyzer/plugin_registry.rb
class NumberAnalyzer
  class PluginRegistry
    @plugins = {}
    @loaded_plugins = {}
    
    def self.register(name, module_class, options = {})
      # 重複チェック（新機能）
      if @plugins.key?(name)
        existing_plugin = @plugins[name]
        new_plugin = build_plugin_info(name, module_class, options)
        
        # 重複解決システム実行
        resolution_result = PluginConflictResolver.resolve_conflict(
          new_plugin, existing_plugin
        )
        
        handle_resolution_result(resolution_result)
        return resolution_result
      end
      
      @plugins[name] = {
        module: module_class,
        enabled: options.fetch(:enabled, true),
        dependencies: options.fetch(:dependencies, []),
        version: options.fetch(:version, '1.0.0'),
        description: options.fetch(:description, ''),
        commands: options.fetch(:commands, []),
        priority: PluginPriority.get(options.fetch(:type, :third_party_gems))
      }
    end
    
    def self.override_plugin(name, new_plugin)
      @plugins[name] = new_plugin
      @loaded_plugins.delete(name)  # 再ロード強制
    end
    
    private
    
    def self.build_plugin_info(name, module_class, options)
      {
        name: name,
        module: module_class,
        type: options.fetch(:type, :third_party_gems),
        source_gem: options.fetch(:source_gem, 'unknown'),
        version: options.fetch(:version, '1.0.0')
      }
    end
    
    def self.handle_resolution_result(result)
      case result.action
      when :override
        override_plugin(result.new_plugin.name, result.new_plugin)
      when :namespace
        register(result.namespaced_name, result.new_plugin)
      when :rejection
        # 登録せずに終了
      end
    end
    
    def self.load_plugin(name)
      return @loaded_plugins[name] if @loaded_plugins.key?(name)
      
      plugin_info = @plugins[name]
      raise PluginNotFoundError, "Plugin #{name} not found" unless plugin_info
      raise PluginDisabledError, "Plugin #{name} is disabled" unless plugin_info[:enabled]
      
      # 依存関係チェック
      plugin_info[:dependencies].each { |dep| load_plugin(dep) }
      
      @loaded_plugins[name] = plugin_info[:module]
    end
    
    def self.available_plugins
      @plugins.keys
    end
    
    def self.enabled_plugins
      @plugins.select { |_, info| info[:enabled] }.keys
    end
    
    def self.plugin_info(name)
      @plugins[name]
    end
    
    def self.reset!
      @plugins.clear
      @loaded_plugins.clear
    end
  end
  
  class PluginNotFoundError < StandardError; end
  class PluginDisabledError < StandardError; end
end
```

### Step 2: Configuration System
**設定ファイルベースのプラグイン管理**

```yaml
# config/plugins.yml
plugins:
  core:
    basic_stats:
      enabled: true
      version: "1.0.0"
      description: "Basic statistical functions"
      commands: ["mean", "median", "mode", "sum", "min", "max"]
    math_utils:
      enabled: true
      version: "1.0.0"
      description: "Mathematical utility functions"
      
  standard:
    advanced_stats:
      enabled: true
      dependencies: ["basic_stats"]
      description: "Advanced statistical analysis"
      commands: ["percentile", "quartiles", "outliers", "deviation-scores"]
    correlation_stats:
      enabled: true
      dependencies: ["basic_stats", "math_utils"]
      description: "Correlation analysis"
      commands: ["correlation"]
    time_series_stats:
      enabled: true
      dependencies: ["basic_stats", "math_utils"]
      description: "Time series analysis"
      commands: ["trend", "moving-average", "growth-rate", "seasonal"]
    hypothesis_testing:
      enabled: true
      dependencies: ["math_utils"]
      description: "Statistical hypothesis testing"
      commands: ["t-test", "confidence-interval", "chi-square"]
    anova_stats:
      enabled: true
      dependencies: ["math_utils", "hypothesis_testing"]
      description: "Analysis of variance"
      commands: ["anova", "two-way-anova", "levene", "bartlett"]
    non_parametric_stats:
      enabled: true
      dependencies: ["math_utils"]  
      description: "Non-parametric statistical tests"
      commands: ["kruskal-wallis", "mann-whitney", "wilcoxon", "friedman"]
  
  experimental:
    machine_learning:
      enabled: false
      source: "external"
      path: "plugins/ml_plugin.rb"
      description: "Machine learning algorithms"
      commands: ["linear-regression", "clustering", "pca"]
```

```ruby
# lib/number_analyzer/configuration.rb
class NumberAnalyzer
  class Configuration
    include Singleton
    
    attr_accessor :plugin_config_path, :auto_load_plugins, :plugin_directories
    
    def initialize
      @plugin_config_path = 'config/plugins.yml'
      @auto_load_plugins = true
      @plugin_directories = ['plugins']
    end
    
    def load_config(path = @plugin_config_path)
      return {} unless File.exist?(path)
      
      require 'yaml'
      YAML.load_file(path)
    end
    
    def enabled_plugins
      config = load_config
      enabled = []
      
      config['plugins']&.each do |category, plugins|
        plugins.each do |name, settings|
          enabled << name if settings['enabled']
        end
      end
      
      enabled
    end
  end
end
```

### Step 3: Dynamic Loading System
**動的プラグイン読み込み機能**

```ruby
# lib/number_analyzer/plugin_loader.rb
class NumberAnalyzer
  class PluginLoader
    def self.load_from_config(config_path = nil)
      config_path ||= Configuration.instance.plugin_config_path
      config = Configuration.instance.load_config(config_path)
      
      return if config['plugins'].nil?
      
      config['plugins'].each do |category, plugins|
        plugins.each do |name, settings|
          next unless settings['enabled']
          
          load_plugin_module(name, settings, category)
        end
      end
    end
    
    def self.load_core_plugins
      # 既存モジュールの自動登録
      core_plugins = {
        'basic_stats' => BasicStats,
        'math_utils' => MathUtils,
        'advanced_stats' => AdvancedStats,
        'correlation_stats' => CorrelationStats,
        'time_series_stats' => TimeSeriesStats,
        'hypothesis_testing' => HypothesisTesting,
        'anova_stats' => ANOVAStats,
        'non_parametric_stats' => NonParametricStats
      }
      
      core_plugins.each do |name, module_class|
        PluginRegistry.register(name, module_class, {
          version: '1.0.0',
          category: 'core'
        })
      end
    end
    
    private
    
    def self.load_plugin_module(name, settings, category)
      case settings['source']
      when 'external'
        load_external_plugin(settings['path'], name, settings)
      else
        register_existing_module(name, settings, category)
      end
    end
    
    def self.register_existing_module(name, settings, category)
      # 既存モジュールの動的読み込み
      module_name = name.split('_').map(&:capitalize).join
      
      begin
        module_class = Object.const_get(module_name)
        PluginRegistry.register(name, module_class, {
          version: settings['version'],
          dependencies: settings['dependencies'] || [],
          description: settings['description'],
          commands: settings['commands'] || [],
          category: category
        })
      rescue NameError => e
        warn "Warning: Could not load module #{module_name}: #{e.message}"
      end
    end
    
    def self.load_external_plugin(path, name, settings)
      return unless File.exist?(path)
      
      begin
        require path
        # 外部プラグインの動的ロード処理
        # プラグインファイルにて PluginRegistry.register を呼び出すことを想定
      rescue LoadError => e
        warn "Warning: Could not load external plugin #{name}: #{e.message}"
      end
    end
  end
end
```

### Step 4: Enhanced Core Class
**プラグインシステム統合のコアクラス改良**

```ruby
# lib/number_analyzer.rb (Phase 8.0版)
# frozen_string_literal: true

require_relative 'number_analyzer/statistics_presenter'
require_relative 'number_analyzer/plugin_registry'
require_relative 'number_analyzer/plugin_loader'
require_relative 'number_analyzer/configuration'

# 既存モジュールの読み込み（下位互換性のため）
require_relative 'number_analyzer/statistics/basic_stats'
require_relative 'number_analyzer/statistics/math_utils'
require_relative 'number_analyzer/statistics/advanced_stats'
require_relative 'number_analyzer/statistics/correlation_stats'
require_relative 'number_analyzer/statistics/time_series_stats'
require_relative 'number_analyzer/statistics/hypothesis_testing'
require_relative 'number_analyzer/statistics/anova_stats'
require_relative 'number_analyzer/statistics/non_parametric_stats'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  def self.configure
    yield(Configuration.instance) if block_given?
  end
  
  def initialize(numbers, plugins: :auto)
    @numbers = numbers
    @loaded_plugins = []
    
    load_plugins(plugins)
  end
  
  def calculate_statistics
    stats = {
      total: @numbers.sum,
      average: average_value,
      maximum: @numbers.max,
      minimum: @numbers.min,
      median_value: median,
      variance: variance,
      mode_values: mode,
      std_dev: standard_deviation,
      iqr: interquartile_range,
      outlier_values: outliers,
      deviation_scores: deviation_scores,
      frequency_distribution: frequency_distribution
    }

    StatisticsPresenter.display_results(stats)
  end

  def median = percentile(50)

  def frequency_distribution = @numbers.tally

  def display_histogram
    puts '度数分布ヒストグラム:'

    freq_dist = frequency_distribution

    if freq_dist.empty?
      puts '(データが空です)'
      return
    end

    freq_dist.sort.each do |value, count|
      bar = '■' * count
      puts "#{value}: #{bar} (#{count})"
    end
  end
  
  def loaded_plugins
    @loaded_plugins.dup
  end
  
  private
  
  def load_plugins(plugin_config)
    case plugin_config
    when :auto
      load_default_plugins
    when :minimal
      load_minimal_plugins
    when :legacy
      load_legacy_plugins
    when Array
      load_specified_plugins(plugin_config)
    when Hash
      load_configured_plugins(plugin_config)
    end
  end
  
  def load_default_plugins
    # コアプラグインの自動登録
    PluginLoader.load_core_plugins
    
    # 設定ファイルからのロード
    if Configuration.instance.auto_load_plugins
      PluginLoader.load_from_config
    end
    
    # 有効なプラグインをロード
    Configuration.instance.enabled_plugins.each do |plugin_name|
      load_single_plugin(plugin_name)
    end
  end
  
  def load_minimal_plugins
    PluginLoader.load_core_plugins
    %w[basic_stats math_utils].each do |plugin|
      load_single_plugin(plugin)
    end
  end
  
  def load_legacy_plugins
    # Phase 7.8互換モード（既存のincludeパターン）
    extend BasicStats
    extend AdvancedStats
    extend CorrelationStats
    extend TimeSeriesStats
    extend HypothesisTesting
    extend ANOVAStats
    extend NonParametricStats
    
    @loaded_plugins = %w[basic_stats advanced_stats correlation_stats 
                        time_series_stats hypothesis_testing anova_stats 
                        non_parametric_stats]
  end
  
  def load_specified_plugins(plugin_list)
    PluginLoader.load_core_plugins
    plugin_list.each { |plugin| load_single_plugin(plugin) }
  end
  
  def load_configured_plugins(config)
    # TODO: ハッシュ設定からの動的ロード
  end
  
  def load_single_plugin(plugin_name)
    begin
      plugin_module = PluginRegistry.load_plugin(plugin_name)
      extend plugin_module
      @loaded_plugins << plugin_name
    rescue StandardError => e
      warn "Warning: Could not load plugin #{plugin_name}: #{e.message}"
    end
  end
end
```

### Step 5: Plugin API Standard & Command Registration
**サードパーティプラグイン標準API**

```ruby
# lib/number_analyzer/plugin_api.rb
module NumberAnalyzer
  module PluginAPI
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def plugin_info
        {
          name: plugin_name,
          version: plugin_version,
          description: plugin_description,
          dependencies: plugin_dependencies,
          commands: plugin_commands,
          author: plugin_author
        }
      end
      
      def plugin_name
        raise NotImplementedError, "Plugin must define plugin_name"
      end
      
      def plugin_version
        "1.0.0"
      end
      
      def plugin_description
        "A NumberAnalyzer plugin"
      end
      
      def plugin_dependencies
        []
      end
      
      def plugin_commands
        []
      end
      
      def plugin_author
        "Unknown"
      end
      
      def register_plugin!
        PluginRegistry.register(plugin_name, self, {
          version: plugin_version,
          description: plugin_description,
          dependencies: plugin_dependencies,
          commands: plugin_commands,
          author: plugin_author
        })
        
        # コマンドの登録
        plugin_commands.each do |command|
          CommandRegistry.register_command(command, method_for_command(command), plugin: plugin_name)
        end
      end
      
      private
      
      def method_for_command(command)
        command.tr('-', '_').to_sym
      end
    end
  end
end

# lib/number_analyzer/command_registry.rb
class NumberAnalyzer
  class CommandRegistry
    @commands = {}
    
    def self.register_command(name, handler, plugin: nil)
      @commands[name] = {
        handler: handler,
        plugin: plugin,
        registered_at: Time.now
      }
    end
    
    def self.available_commands
      @commands.keys
    end
    
    def self.find_handler(command_name)
      command_info = @commands[command_name]
      return nil unless command_info
      
      command_info[:handler]
    end
    
    def self.commands_by_plugin(plugin_name)
      @commands.select { |_, info| info[:plugin] == plugin_name }
    end
    
    def self.reset!
      @commands.clear
    end
  end
end
```

**プラグイン実装例:**

```ruby
# plugins/machine_learning_plugin.rb
module MachineLearningPlugin
  include NumberAnalyzer::PluginAPI
  
  def self.plugin_name
    "machine_learning"
  end
  
  def self.plugin_version
    "1.0.0"
  end
  
  def self.plugin_description
    "Basic machine learning algorithms for statistical analysis"
  end
  
  def self.plugin_dependencies
    ["basic_stats", "math_utils"]
  end
  
  def self.plugin_commands
    ['linear-regression', 'clustering', 'pca']
  end
  
  def self.plugin_author
    "ML Team"
  end
  
  def linear_regression
    # 線形回帰実装
    {
      slope: calculate_slope,
      intercept: calculate_intercept,
      r_squared: calculate_r_squared,
      interpretation: "Linear regression analysis complete"
    }
  end
  
  def clustering(k: 3)
    # K-means クラスタリング実装
    {
      clusters: perform_kmeans(k),
      centroids: calculate_centroids,
      interpretation: "#{k} clusters identified"
    }
  end
  
  def pca(components: 2)
    # 主成分分析実装
    {
      components: calculate_components(components),
      explained_variance: calculate_explained_variance,
      interpretation: "PCA with #{components} components"
    }
  end
  
  private
  
  def calculate_slope
    # 実装詳細
  end
  
  def calculate_intercept
    # 実装詳細
  end
  
  def calculate_r_squared
    # 実装詳細
  end
  
  def perform_kmeans(k)
    # 実装詳細
  end
  
  def calculate_centroids
    # 実装詳細
  end
  
  def calculate_components(n)
    # 実装詳細
  end
  
  def calculate_explained_variance
    # 実装詳細
  end
end

# プラグイン自動登録
MachineLearningPlugin.register_plugin!
```

### CLI Integration Enhancement
**動的コマンド対応CLI**

```ruby
# lib/number_analyzer/cli.rb への追加
class NumberAnalyzer::CLI
  def self.run(argv = ARGV)
    return run_full_analysis(argv) if argv.empty?

    command = argv.first
    
    # 動的コマンド解決を優先
    if handler = CommandRegistry.find_handler(command)
      run_dynamic_command(handler, argv[1..])
    elsif COMMANDS.key?(command)
      # 既存コマンド実行
      send(COMMANDS[command], argv[1..])
    else
      run_full_analysis(argv)
    end
  end
  
  private
  
  def self.run_dynamic_command(handler, args)
    # 動的ハンドラー実行
    # TODO: 実装詳細
  end
end
```

## 🎨 使用例

### 基本使用（Phase 7.8と完全互換）
```ruby
# 既存のAPIは完全保持
analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5])
analyzer.mean  # => 3.0
analyzer.correlation([2, 4, 6, 8, 10])  # => 1.0
```

### プラグイン指定使用
```ruby
# 最小構成で軽量起動
analyzer = NumberAnalyzer.new([1, 2, 3], plugins: :minimal)
analyzer.mean  # => 2.0
# analyzer.correlation([1, 2, 3]) # => エラー（correlation_statsが未ロード）

# 特定プラグインのみ
analyzer = NumberAnalyzer.new([1, 2, 3], plugins: ['basic_stats', 'correlation_stats'])
analyzer.mean  # => 2.0
analyzer.correlation([1, 2, 3])  # => 1.0

# レガシーモード（Phase 7.8と同一）
analyzer = NumberAnalyzer.new([1, 2, 3], plugins: :legacy)
analyzer.one_way_anova([1, 2], [3, 4])  # 全機能利用可能
```

### 設定ベース使用
```ruby
# 設定ファイルベース
NumberAnalyzer.configure do |config|
  config.plugin_config_path = 'my_plugins.yml'
  config.auto_load_plugins = true
end

analyzer = NumberAnalyzer.new([1, 2, 3])  # 設定に基づいて自動ロード
```

### 外部プラグイン使用例
```ruby
# 機械学習プラグイン
analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5], plugins: ['basic_stats', 'machine_learning'])
result = analyzer.linear_regression
puts result[:interpretation]  # => "Linear regression analysis complete"

# CLI使用
# bundle exec number_analyzer linear-regression 1 2 3 4 5
```

### プラグイン情報確認
```ruby
# 利用可能プラグイン一覧
puts PluginRegistry.available_plugins
# => ["basic_stats", "advanced_stats", "correlation_stats", ...]

# ロード済みプラグイン確認
analyzer = NumberAnalyzer.new([1, 2, 3])
puts analyzer.loaded_plugins
# => ["basic_stats", "math_utils", "advanced_stats", ...]

# プラグイン詳細情報
info = PluginRegistry.plugin_info('machine_learning')
puts info[:description]  # => "Basic machine learning algorithms for statistical analysis"
puts info[:commands]     # => ["linear-regression", "clustering", "pca"]
```

## 📊 実装のメリット

### 1. 拡張性
- **サードパーティ拡張**: 外部開発者がプラグイン作成可能
- **選択的機能**: 必要な機能のみロード（軽量化）
- **実験的機能**: 安全な機能テスト環境
- **段階的導入**: 新機能を段階的にテスト・リリース

### 2. 保守性
- **既存API保持**: 完全後方互換性（`:legacy`モード）
- **モジュール独立**: 各プラグインの独立開発・テスト
- **責任分離**: プラグイン固有の問題の局所化
- **依存関係管理**: 明示的な依存関係解決

### 3. 統合可能性
- **Web API**: RESTful API提供機能

### 4. パフォーマンス
- **軽量起動**: 必要機能のみロード
- **メモリ効率**: 未使用機能のメモリ使用量削減
- **起動時間短縮**: 大規模プロジェクトでの起動時間改善

## 🛠️ 実装ステップ詳細

### Phase 8.0 Step 1: Foundation Setup + Conflict Resolution
**期間: 2-3週間（重複管理機能統合により拡張）**

1. **PluginRegistry作成**
   - `lib/number_analyzer/plugin_registry.rb`
   - プラグイン登録・ロード・依存関係管理
   - **重複検出・解決機能統合**
   - エラークラス定義

2. **Plugin Conflict Resolution System** ⭐ **新機能**
   - `lib/number_analyzer/plugin_priority.rb` - ハイブリッド優先度システム
   - `lib/number_analyzer/plugin_conflict_resolver.rb` - 重複解決エンジン
   - `lib/number_analyzer/plugin_namespace.rb` - 名前空間管理
   - `lib/number_analyzer/plugin_configuration.rb` - 3層設定システム

3. **Configuration System**
   - `lib/number_analyzer/configuration.rb`  
   - Singleton パターンでの設定管理
   - `config/plugins.yml` 作成
   - **重複管理設定統合**

4. **既存モジュールのプラグイン化準備**
   - 8つのモジュールの情報整理
   - 依存関係マッピング
   - **優先度割り当て** (core_plugins: 90)

5. **基本テスト作成**
   - PluginRegistry のユニットテスト
   - Configuration のユニットテスト
   - **重複管理システムテスト** (50+ テストケース)

**重複管理機能詳細**: [PHASE_8_STEP_5_CONFLICT_RESOLUTION_PLAN.md](PHASE_8_STEP_5_CONFLICT_RESOLUTION_PLAN.md) 参照

### Phase 8.0 Step 2: Dynamic Loading
**期間: 2-3週間**

1. **PluginLoader実装**
   - `lib/number_analyzer/plugin_loader.rb`
   - 動的モジュール読み込み
   - 既存モジュールの自動登録

2. **NumberAnalyzer統合**
   - コアクラスの enhance
   - 複数のロードモード実装（:auto, :minimal, :legacy）

3. **包括的テスト**
   - 各ロードモードのテスト
   - 既存106統合テストの全通過確認
   - 新規ユニットテスト追加

### Phase 8.0 Step 3: Command System
**期間: 1-2週間**

1. **CommandRegistry作成**
   - 動的コマンド管理システム
   - CLI統合準備

2. **CLI Enhancement**
   - 動的コマンド解決機能
   - 既存29サブコマンドとの統合

3. **コマンドテスト**
   - 動的コマンド実行テスト
   - CLI統合テスト

### Phase 8.0 Step 4: Plugin API Standardization
**期間: 2-3週間**

1. **PluginAPI作成**
   - `lib/number_analyzer/plugin_api.rb`
   - 標準プラグインインターフェース

2. **サンプルプラグイン作成**
   - `plugins/machine_learning_plugin.rb`
   - 実装ガイド・テンプレート作成

3. **外部プラグインロード**
   - 外部ファイルからの動的ロード
   - エラーハンドリング

### Phase 8.0 Step 5: Conflict Resolution System
**期間: 2-3週間** - **プラグインエコシステムの安全性確保**

1. **Week 1: PluginPriority System**
   - 階層的優先度システム実装 (Development:100 > Core:90 > Official:70 > ThirdParty:50 > Local:30)
   - カスタム優先度設定機能
   - 設定ファイルからの優先度読み込み
   - `lib/number_analyzer/plugin_priority.rb` 実装

2. **Week 2: PluginConflictResolver System**
   - 6つの解決戦略実装 (strict, warn_override, silent_override, namespace, interactive, auto)
   - 自動解決ロジック
   - ConflictValidator とエラーハンドリング
   - `lib/number_analyzer/plugin_conflict_resolver.rb` 実装

3. **Week 3: PluginNamespace & CLI Integration**
   - 自動名前空間生成 (`na_ml_stats`, `ext_custom_gem_analyzer`)
   - 3層設定システム (defaults → project config → runtime)
   - CLI統合コマンド (`plugins --conflicts`, `plugins resolve`)
   - `lib/number_analyzer/plugin_namespace.rb` 実装

**Success Criteria:**
- 188+ total tests (163 current + 25 new conflict resolution tests)
- Zero RuboCop violations maintained
- Conflict-free plugin ecosystem with automatic resolution
- Complete CLI integration for conflict management
- Core plugin protection (priority 90) ensuring system stability

## 🧪 テスト戦略

### 1. 既存機能保証
- **106統合テスト**: 全てのテストが通過必須
- **29サブコマンド**: 既存コマンドの完全動作保証
- **API互換性**: 既存APIの完全保持

### 2. 新機能テスト
- **PluginRegistry**: 50+ ユニットテスト
- **PluginLoader**: 30+ ユニットテスト  
- **Configuration**: 20+ ユニットテスト
- **統合テスト**: プラグインロード・実行の end-to-end テスト

### 3. パフォーマンステスト
- **起動時間**: プラグインロード時間測定
- **メモリ使用量**: 各モードでのメモリ使用量比較
- **実行速度**: 既存機能の実行速度維持確認

## 🚀 期待される成果

### 短期効果（Phase 8.0完了時）
- **安全なプラグインエコシステム**: 自動重複管理による信頼性
- **拡張基盤確立**: サードパーティプラグイン開発基盤
- **軽量化オプション**: 用途に応じた機能選択
- **開発効率向上**: プラグイン独立開発による並行作業

### 中期効果（Phase 8.1-8.5）
- **エコシステム形成**: 外部開発者による拡張機能貢献
- **統合機能拡張**: 外部システム統合（将来実装）
- **企業採用**: 安全で柔軟な機能構成による企業利用拡大
- **プラグイン品質向上**: 重複管理システムによる高品質プラグイン促進

### 長期効果（Phase 9.0以降）
- **プラットフォーム化**: 統計分析プラットフォームとしての地位確立
- **コミュニティ形成**: 開発者コミュニティとエコシステム
- **業界標準**: Ruby統計分析ライブラリの業界標準化
- **持続可能な成長**: 重複管理による健全なエコシステム維持

## ⚠️ リスク管理

### 実装リスク
- **複雑性増加**: プラグインシステムによる複雑性 → 段階的実装・十分なテスト
- **パフォーマンス低下**: 動的ロードオーバーヘッド → ベンチマーク測定・最適化
- **互換性問題**: 既存APIの破壊 → :legacy モードによる完全互換性保証
- **🆕 プラグイン名重複**: 意図しない機能上書き → **ハイブリッド重複管理システム**で解決

### 運用リスク  
- **プラグイン品質**: 外部プラグインの品質 → API標準・ガイドライン整備
- **依存関係問題**: 複雑な依存関係 → 自動依存解決・エラーハンドリング
- **セキュリティ**: 外部コード実行 → サンドボックス・検証機能
- **🆕 名前空間汚染**: 予期しないプラグイン干渉 → **階層的優先度システム**で制御

### 重複管理リスク詳細
- **Core機能の保護**: core_plugins (優先度90) により既存8モジュールを保護
- **開発時の柔軟性**: development (優先度100) により開発時の自由度確保
- **予測可能性**: 明確な優先度ルールによる一貫した動作
- **エコシステム健全性**: 名前空間システムによる平和的共存

**詳細対策**: [PLUGIN_CONFLICT_RESOLUTION_PLAN.md](PLUGIN_CONFLICT_RESOLUTION_PLAN.md) を参照

### 回避策
- **段階的実装**: 各ステップでの品質ゲート
- **継続テスト**: CI/CDによる継続的品質保証
- **ロールバック計画**: 各段階でのコミット管理・復旧手順
- **🆕 重複テスト**: 包括的な重複解決シナリオテスト

## 📚 関連ドキュメント

- **[PLUGIN_CONFLICT_RESOLUTION_PLAN.md](PLUGIN_CONFLICT_RESOLUTION_PLAN.md)**: **🆕 プラグイン名重複管理システム詳細設計**
- **[ROADMAP.md](ROADMAP.md)**: Phase 7.8までの開発履歴
- **[REFACTORING_PLAN.md](REFACTORING_PLAN.md)**: Phase 7.7基盤リファクタリング詳細
- **[FEATURES.md](FEATURES.md)**: 実装済み機能一覧
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: 技術アーキテクチャ詳細

## 🎉 まとめ  

Phase 8.0 Plugin System Architecture は、Phase 7.7で構築した完璧なモジュラー基盤（96.1%削減、8モジュール、326テスト）を活用し、NumberAnalyzerを次世代統計分析プラットフォームへと進化させる計画です。

**核心的な価値**:
- **完全後方互換性**: 既存ユーザーへの影響ゼロ
- **段階的進化**: リスクを最小化した安全な移行
- **拡張エコシステム**: 外部開発者による機能拡張基盤
- **企業レベル品質**: 326テストによる品質保証継続
- **🆕 安全な重複管理**: ハイブリッド優先度システムによる予測可能な動作**

**重複管理システムの特長**:
- **階層的優先度**: Development(100) > Core(90) > Official(70) > ThirdParty(50) > Local(30)
- **柔軟な設定**: プロジェクト・環境・実行時の3層設定システム
- **名前空間共存**: 重複プラグインの平和的共存機能
- **CLI支援**: インタラクティブな重複解決コマンド

この計画により、NumberAnalyzerは単なる統計ライブラリから、安全で拡張可能、かつ持続可能な統計分析プラットフォームへと生まれ変わります。