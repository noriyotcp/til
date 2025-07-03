# Phase 8.0 Step 5: Conflict Resolution System 実装計画書

## 🎯 Overview

NumberAnalyzer Plugin System の最終ステップとして、安全で持続可能なプラグインエコシステムを確立するための重複管理システムを実装します。これにより、Phase 8.0 Plugin System Architecture が完全に完成し、エンタープライズレベルの統計分析プラットフォームとしての地位を確立します。

**統合文書**: この計画は **[PHASE_8_PLUGIN_SYSTEM_PLAN.md](PHASE_8_PLUGIN_SYSTEM_PLAN.md)** の Step 5 として実装され、**[PLUGIN_CONFLICT_RESOLUTION_PLAN.md](PLUGIN_CONFLICT_RESOLUTION_PLAN.md)** の詳細設計に基づきます。

## 📊 Current Status (Step 4 Complete)

### ✅ 完璧な基盤が確立済み
- **163 test examples** with comprehensive plugin infrastructure
- **Plugin API Standardization** with security validation (76 danger patterns)
- **3 comprehensive sample plugins** (MachineLearning, DataExport, Visualization)
- **19 plugin commands** across multiple categories
- **Enterprise-grade security** with SHA256 validation and trust verification

### 🏗️ 既存Plugin Infrastructure
```
lib/number_analyzer/
├── plugin_system.rb         # Core plugin management
├── plugin_interface.rb      # Plugin base classes & interfaces
├── plugin_loader.rb         # Plugin discovery & auto-loading (385行)
├── plugin_registry.rb       # Centralized plugin management (420行)
├── plugin_configuration.rb  # Multi-layer configuration (290行)
├── plugin_validator.rb      # Security validation (490行)
├── plugin_template.rb       # Plugin template generation (380行)
├── dependency_resolver.rb   # Dependency validation (345行)
└── plugin_error_handler.rb  # Error handling & recovery (260行)
```

## 🔧 Step 5 Implementation Plan: Conflict Resolution System

### **実装期間**: 2-3週間 (修正済み - 3-4週間から短縮)

## Week 1: PluginPriority System (基盤優先度管理)

### 1.1 Core Priority Infrastructure

**実装ファイル**: `lib/number_analyzer/plugin_priority.rb`

```ruby
# 階層的優先度システム実装
class NumberAnalyzer
  class PluginPriority
    # デフォルト優先度（数値が高い = 高優先度）
    DEFAULT_PRIORITIES = {
      development: 100,     # 開発・テスト用 - 最高優先度（何でも上書き）
      core_plugins: 90,     # 既存8モジュール - 高優先度（保護対象）
      official_gems: 70,    # number_analyzer-* gems - 信頼できるgem
      third_party_gems: 50, # 外部gem - 一般的なサードパーティ
      local_plugins: 30     # プロジェクト内 - 最低優先度
    }.freeze
    
    def self.get(plugin_type)
      @custom_priorities[plugin_type] || DEFAULT_PRIORITIES[plugin_type] || 0
    end
    
    def self.can_override?(new_plugin, existing_plugin)
      new_priority = get(new_plugin.type)
      existing_priority = get(existing_plugin.type)
      new_priority > existing_priority
    end
    
    def self.load_from_config(config_path)
      # YAML設定ファイルからの優先度読み込み
    end
  end
end
```

### 1.2 Testing Implementation (Week 1)

**新規テストファイル**: `spec/plugin_priority_spec.rb` (10 tests)

```ruby
RSpec.describe NumberAnalyzer::PluginPriority do
  describe '.can_override?' do
    let(:development_plugin) { double(:plugin, type: :development) }
    let(:core_plugin) { double(:plugin, type: :core_plugins) }
    let(:third_party_plugin) { double(:plugin, type: :third_party_gems) }
    
    it 'allows development to override core' do
      expect(described_class.can_override?(development_plugin, core_plugin)).to be true
    end
    
    it 'allows core to override third party' do
      expect(described_class.can_override?(core_plugin, third_party_plugin)).to be true
    end
    
    it 'prevents third party from overriding core' do
      expect(described_class.can_override?(third_party_plugin, core_plugin)).to be false
    end
  end
  
  describe 'custom priority management' do
    it 'allows custom priority setting' do
      described_class.set(:my_custom_type, 95)
      expect(described_class.get(:my_custom_type)).to eq(95)
    end
  end
end
```

### Week 1 完了基準
- [ ] PluginPriority class 実装完了
- [ ] 階層的優先度システム動作確認
- [ ] 10個のユニットテスト全通過
- [ ] 既存163テスト全通過維持
- [ ] RuboCop準拠

---

## Week 2: PluginConflictResolver System (重複解決エンジン)

### 2.1 Conflict Resolution Engine

**実装ファイル**: `lib/number_analyzer/plugin_conflict_resolver.rb`

```ruby
class NumberAnalyzer
  class PluginConflictResolver
    RESOLUTION_STRATEGIES = {
      strict: :reject_duplicates,        # 重複完全拒否
      warn_override: :warn_and_override, # 警告付き上書き
      silent_override: :silent_override, # 無警告上書き
      namespace: :use_namespace,         # 名前空間で共存
      interactive: :prompt_user,         # ユーザー選択
      auto: :auto_resolve                # 優先度ベース自動解決
    }.freeze
    
    def self.resolve_conflict(new_plugin, existing_plugin, strategy = :auto)
      validator = ConflictValidator.new(new_plugin, existing_plugin)
      
      unless validator.valid_conflict?
        raise InvalidConflictError, validator.error_message
      end
      
      strategy = determine_strategy(strategy, new_plugin, existing_plugin)
      send(RESOLUTION_STRATEGIES[strategy], new_plugin, existing_plugin)
    end
    
    private
    
    def self.determine_strategy(requested_strategy, new_plugin, existing_plugin)
      return requested_strategy unless requested_strategy == :auto
      
      # 優先度ベース自動決定
      case
      when new_plugin.type == :development
        :silent_override
      when existing_plugin.type == :core_plugins && new_plugin.type != :development
        :strict
      when PluginPriority.can_override?(new_plugin, existing_plugin)
        :warn_override
      else
        :namespace
      end
    end
  end
end
```

### 2.2 Conflict Validation System

```ruby
class NumberAnalyzer
  class ConflictValidator
    def initialize(new_plugin, existing_plugin)
      @new_plugin = new_plugin
      @existing_plugin = existing_plugin
      @error_message = nil
    end
    
    def valid_conflict?
      return false unless plugins_same_name?
      return false unless plugins_different_sources?
      true
    end
    
    private
    
    def plugins_same_name?
      same = @new_plugin.name == @existing_plugin.name
      @error_message = "Plugin names don't match" unless same
      same
    end
    
    def plugins_different_sources?
      different = @new_plugin.source_gem != @existing_plugin.source_gem
      @error_message = "Plugins are from the same source" unless different
      different
    end
  end
end
```

### 2.3 Testing Implementation (Week 2)

**テスト追加**: `spec/plugin_conflict_resolver_spec.rb` (10 tests)

### Week 2 完了基準
- [ ] ConflictResolver system 実装完了
- [ ] 6つの解決戦略全て実装・動作確認
- [ ] ConflictValidator 実装完了
- [ ] 10個のユニットテスト全通過
- [ ] 既存173テスト全通過維持
- [ ] RuboCop準拠

---

## Week 3: PluginNamespace & CLI Integration (名前空間と統合)

### 3.1 Namespace Management System

**実装ファイル**: `lib/number_analyzer/plugin_namespace.rb`

```ruby
class NumberAnalyzer
  class PluginNamespace
    NAMESPACE_PATTERNS = {
      gem: ->(plugin_name, source_gem) {
        case source_gem
        when /^number_analyzer-(.+)/
          "na_#{$1.tr('-', '_')}_#{plugin_name}"
        else
          "ext_#{source_gem.tr('-', '_')}_#{plugin_name}"
        end
      },
      source: ->(plugin_name, source_gem) {
        "#{source_gem.tr('-', '_')}::#{plugin_name}"
      },
      priority: ->(plugin_name, plugin_type) {
        "#{plugin_type}_#{plugin_name}"
      }
    }.freeze
    
    def self.auto_namespace(plugin_name, source_gem, pattern: :gem)
      namespace_func = NAMESPACE_PATTERNS[pattern]
      namespace_func.call(plugin_name, source_gem)
    end
    
    def self.find_plugin_by_name(search_name)
      # 完全一致を最優先
      exact_match = PluginRegistry.find(search_name)
      return exact_match if exact_match
      
      # 名前空間付きで検索
      namespaced_matches = PluginRegistry.all_plugins.select do |name, _|
        resolved = resolve_namespace(name)
        resolved[:name] == search_name
      end
      
      handle_multiple_matches(search_name, namespaced_matches)
    end
  end
end
```

### 3.2 Enhanced Configuration System

**ファイル強化**: `lib/number_analyzer/plugin_configuration.rb`

```ruby
# 3層設定システムの強化
class NumberAnalyzer
  class PluginConfiguration
    include Singleton
    
    def initialize
      @conflict_strategy = :auto
      @development_mode = false
      @namespace_pattern = :gem
      @custom_priorities = {}
      @per_plugin_policies = {}
      
      load_from_env        # Layer 3: 環境変数
      load_from_file       # Layer 2: プロジェクト設定
      # Layer 1: デフォルト設定（不変）
    end
    
    def conflict_strategy_for(plugin_name)
      # パターンマッチング対応
      @per_plugin_policies.each do |pattern, strategy|
        if pattern.include?('*')
          regex = Regexp.new(pattern.gsub('*', '.*'))
          return strategy if plugin_name.match?(regex)
        elsif pattern == plugin_name
          return strategy
        end
      end
      
      @conflict_strategy
    end
  end
end
```

### 3.3 CLI Integration

**ファイル強化**: `lib/number_analyzer/cli.rb`

```ruby
# CLI新機能追加
class NumberAnalyzer::CLI
  def self.run_plugins_command(args)
    subcommand = args.first
    
    case subcommand
    when 'list'
      list_plugins(args[1..])
    when 'conflicts', '--conflicts'
      show_conflicts(args[1..])
    when 'resolve'
      resolve_conflict(args[1..])
    else
      show_plugins_help
    end
  end
  
  private
  
  def self.show_conflicts(args)
    conflicts = PluginConflictDetector.find_all_conflicts
    
    if conflicts.empty?
      puts "No plugin conflicts detected."
      return
    end
    
    puts "Plugin Conflicts Detected:"
    conflicts.each do |conflict|
      puts "  #{conflict.plugin_name}:"
      puts "    Existing: #{conflict.existing.type} (priority: #{PluginPriority.get(conflict.existing.type)})"
      puts "    Conflicting: #{conflict.new.type} (priority: #{PluginPriority.get(conflict.new.type)})"
      puts "    Recommended: #{conflict.recommended_action}"
      puts
    end
  end
  
  def self.resolve_conflict(args)
    plugin_name = args[0]
    strategy_flag = args.find { |arg| arg.start_with?('--strategy=') }
    strategy = strategy_flag ? strategy_flag.split('=')[1].to_sym : :interactive
    
    conflict = PluginConflictDetector.find_conflict(plugin_name)
    unless conflict
      puts "No conflict found for plugin: #{plugin_name}"
      return
    end
    
    result = PluginConflictResolver.resolve_conflict(
      conflict.new, conflict.existing, strategy
    )
    
    puts result.message
  end
end
```

### 3.4 Configuration File Template

**新規ファイル**: `config/number_analyzer.yml.example`

```yaml
# NumberAnalyzer Plugin Configuration
plugin_system:
  priorities:
    development: 120        # デフォルトから変更
    my_special_plugins: 95  # 独自カテゴリ追加
    analytics_plugins: 85   # プロジェクト固有カテゴリ
  
  conflict_resolution:
    default_strategy: warn_override
    per_plugin:
      "critical-stats": strict
      "experimental-*": silent_override
      "debug-*": namespace
  
  namespaces:
    enabled: true
    auto_namespace_conflicts: true
    patterns:
      gem: "na_{gem}_{plugin}"
      source: "{source}::{plugin}"
    
  security:
    allow_external_plugins: true
    sandbox_external_plugins: false
    max_plugin_load_time: 5.0
```

### 3.5 Testing Implementation (Week 3)

**テスト追加**: `spec/plugin_namespace_spec.rb` (5 tests)
**CLI テスト追加**: `spec/cli_conflict_resolution_spec.rb` (10 tests)

### Week 3 完了基準
- [ ] PluginNamespace system 実装完了
- [ ] 3層設定システム強化完了
- [ ] CLI統合コマンド全て実装・動作確認
- [ ] 設定ファイルテンプレート作成
- [ ] 15個のテスト全通過
- [ ] 既存183テスト全通過維持
- [ ] RuboCop準拠

---

## 🧪 Testing Strategy

### 新規テスト合計: 25+ tests

1. **Priority System Tests** (10 tests) - `spec/plugin_priority_spec.rb`
   - 優先度比較機能
   - カスタム優先度設定
   - 設定ファイル読み込み
   - 境界値テスト

2. **Conflict Resolution Tests** (10 tests) - `spec/plugin_conflict_resolver_spec.rb`
   - 各解決戦略テスト (6戦略)
   - 自動解決ロジック
   - ConflictValidator機能
   - エラーケース処理

3. **Namespace Tests** (5 tests) - `spec/plugin_namespace_spec.rb`
   - 自動名前空間生成
   - パターンマッチング
   - 名前解決機能
   - 複数マッチ処理

4. **CLI Integration Tests** (Bonus) - `spec/cli_conflict_resolution_spec.rb`
   - CLI コマンド実行
   - インタラクティブ解決
   - 出力フォーマット

### Integration Testing

```ruby
# spec/integration/conflict_resolution_integration_spec.rb
RSpec.describe 'Conflict Resolution Integration' do
  let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
  
  context 'with default conflict resolution' do
    it 'maintains core plugin precedence' do
      expect(analyzer.mean).to eq(3.0)  # コアプラグインの実装
      expect(analyzer.loaded_plugins).to include('basic_stats')
      expect(analyzer.loaded_plugins).not_to include('ext_override_basic_stats')
    end
  end
  
  context 'with development mode' do
    before { NumberAnalyzer.configure { |c| c.development_mode = true } }
    
    it 'allows any plugin to override' do
      load_plugin('BasicStatsOverride')
      expect(analyzer.mean).to eq(4.0)  # オーバーライドされた実装
    end
  end
  
  context 'with namespace resolution' do
    it 'allows conflicting plugins to coexist' do
      result = load_plugin_with_namespace('BasicStatsOverride')
      
      expect(analyzer.mean).to eq(3.0)  # 元の実装
      expect(analyzer.send('ext_override_basic_stats_mean')).to eq(4.0)  # 名前空間版
    end
  end
end
```

## 📊 Success Criteria

### Technical Metrics
- **188+ total tests** (163 current + 25 new) with 100% pass rate
- **Zero RuboCop violations** maintained across all new files
- **<2 second plugin loading** time for full system with conflict resolution
- **Memory efficient**: <10MB additional memory usage for conflict system

### Feature Completeness
- **Automatic Conflict Detection**: 重複プラグインの自動検出
- **6 Resolution Strategies**: 全ての解決戦略が動作
- **Priority-based Resolution**: 階層的優先度による自動解決
- **Interactive CLI**: ユーザーフレンドリーな重複解決コマンド
- **Namespace Generation**: 自動名前空間による平和的共存
- **3-layer Configuration**: プロジェクト・環境・実行時設定
- **Core Protection**: 既存8モジュールの完全保護

### Quality Assurance
- **Backward Compatibility**: 既存APIへの影響ゼロ
- **Error Handling**: 包括的エラー処理と回復機能
- **Documentation**: 完全なドキュメント更新
- **Developer Experience**: 直感的な設定と明確なエラーメッセージ

## 🎯 Implementation Guidelines

### Code Quality Standards
1. **TDD Approach**: 全ての新機能はテストファーストで実装
2. **RuboCop Compliance**: 新規ファイル全てでゼロ違反必須
3. **Documentation**: 全ての public method に適切なドキュメント
4. **Error Messages**: 開発者フレンドリーで具体的なエラーメッセージ

### Integration Requirements
1. **Existing Plugin System**: 現在のプラグインシステムとの完全統合
2. **CLI Compatibility**: 既存CLIコマンドへの影響なし
3. **Configuration Inheritance**: 既存設定システムの拡張
4. **Security Compliance**: 既存セキュリティ検証システムとの統合

## 🚀 Expected Outcome

### Phase 8.0 Step 5 Complete により実現される価値

#### 🛡️ **安全性の確保**
- **Core Plugin Protection**: 既存8モジュールが優先度90で保護される
- **Predictable Behavior**: 階層的優先度による一貫した動作
- **Conflict-free Loading**: 自動重複検出と解決による安全なプラグインロード

#### 🎯 **開発者体験の向上**
- **Intuitive Priority System**: 数値ベース優先度による明確性
- **Flexible Configuration**: プロジェクト・環境・実行時の3層設定
- **Interactive Resolution**: CLI経由での直感的な重複解決
- **Clear Error Messages**: 詳細で分かりやすい重複解決メッセージ

#### 🌱 **エコシステムの健全性**
- **Namespace Coexistence**: 重複プラグインの平和的共存
- **Plugin Quality Improvement**: 明確な重複ポリシーによる高品質プラグイン促進
- **Community Standards**: プラグイン開発のベストプラクティス確立
- **Sustainable Growth**: 長期的に持続可能なプラグインエコシステム

#### 🏢 **エンタープライズ対応**
- **Production Stability**: 本番環境での安定した動作保証
- **Policy Enforcement**: 組織レベルでのプラグインポリシー管理
- **Audit Trail**: プラグイン重複解決の完全な追跡
- **Risk Management**: セキュリティと機能性のバランス確保

### 🎉 Phase 8.0 Plugin System Architecture 完成

Step 5の完了により、NumberAnalyzerは以下を達成します：

1. **Complete Plugin Infrastructure**: 基盤からセキュリティ、重複管理まで完備
2. **Enterprise-Ready Platform**: 企業レベルの統計分析プラットフォーム
3. **Safe Extensibility**: 安全で持続可能な拡張エコシステム
4. **Developer-Friendly**: 開発者が安心して使える高品質API

これにより、NumberAnalyzerは単なるRuby統計ライブラリから、**真の統計分析プラットフォーム**へと進化を完了します。

---

## 📚 Related Documentation

### Core Documentation
- **[PHASE_8_PLUGIN_SYSTEM_PLAN.md](PHASE_8_PLUGIN_SYSTEM_PLAN.md)**: Phase 8.0メインプラン
- **[PLUGIN_CONFLICT_RESOLUTION_PLAN.md](PLUGIN_CONFLICT_RESOLUTION_PLAN.md)**: 重複管理システム詳細設計
- **[ROADMAP.md](ROADMAP.md)**: 開発履歴と進捗追跡

### Implementation Reference
- **README.md**: ユーザー向け機能説明
- **CLAUDE.md**: 開発ガイダンスと品質基準  
- **[FEATURES.md](FEATURES.md)**: 実装済み機能一覧
- **[ARCHITECTURE.md](ARCHITECTURE.md)**: 技術アーキテクチャ詳細

この文書により、Phase 8.0 Step 5の実装が完全にガイドされ、NumberAnalyzer Plugin System Architectureの完成を確実にします。