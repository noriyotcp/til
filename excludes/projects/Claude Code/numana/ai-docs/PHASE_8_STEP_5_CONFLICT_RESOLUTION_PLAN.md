# Phase 8.0 Step 5: Conflict Resolution System 実装計画書

## 🎯 Overview

NumberAnalyzer Plugin System の最終ステップとして、安全で持続可能なプラグインエコシステムを確立するための重複管理システムを実装します。これにより、Phase 8.0 Plugin System Architecture が完全に完成し、エンタープライズレベルの統計分析プラットフォームとしての地位を確立します。

**統合文書**: この計画は **[PHASE_8_PLUGIN_SYSTEM_PLAN.md](PHASE_8_PLUGIN_SYSTEM_PLAN.md)** の Step 5 として実装され、重複管理システムの詳細設計と実装計画を統合して提供します。

## 🤔 Problem Analysis & Industry Best Practices

### プラグイン名重複の課題
- **既存プラグインとの名前衝突**: 新しいプラグインが既存のものを意図せず上書き
- **開発者の自由度 vs 安全性**: 厳格制御か自由度重視かのジレンマ
- **エコシステムの健全性**: gem配布時の名前空間管理
- **デバッグの困難性**: どのプラグインが実際に動作しているか不明

### 業界ベストプラクティス分析
- **Jekyll**: 重複許可、後ロード優先（警告あり）
- **Rails**: 重複許可、定数再定義警告
- **NPM**: 厳格な一意性、スコープによる名前空間分離
- **RubyGems**: gem名厳格管理、所有権システム

## 🏗️ Design Approach: ハイブリッド重複管理

### 基本原則
1. **コンテキスト依存**: プラグインの種類に応じた重複ポリシー
2. **階層的優先度**: 明確な優先順位による予測可能性
3. **設定可能性**: プロジェクト・環境に応じた柔軟な制御
4. **後方互換性**: 既存機能への影響ゼロ

## 📊 Current Status (Step 4 Complete)

### ✅ 完璧な基盤が確立済み
- **163 test examples** with comprehensive plugin infrastructure
- **Plugin API Standardization** with security validation (76 danger patterns)
- **3 comprehensive sample plugins** (MachineLearning, DataExport, Visualization)
- **19 plugin commands** across multiple categories
- **Enterprise-grade security** with SHA256 validation and trust verification

### 🏗️ 既存Plugin Infrastructure
```
lib/numana/
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

## 🔢 Detailed Architecture Design

### PluginPriority System (階層的優先度システム)

**実装ファイル**: `lib/numana/plugin_priority.rb`

```ruby
# 階層的優先度システム実装
class NumberAnalyzer
  class PluginPriority
    # デフォルト優先度（数値が高い = 高優先度）
    DEFAULT_PRIORITIES = {
      development: 100,     # 開発・テスト用 - 最高優先度（何でも上書き）
      core_plugins: 90,     # 既存8モジュール - 高優先度（保護対象）
      official_gems: 70,    # numana-* gems - 信頼できるgem
      third_party_gems: 50, # 外部gem - 一般的なサードパーティ
      local_plugins: 30     # プロジェクト内 - 最低優先度
    }.freeze
    
    @custom_priorities = {}
    @conflict_policies = {}
    
    def self.get(plugin_type)
      @custom_priorities[plugin_type] || DEFAULT_PRIORITIES[plugin_type] || 0
    end
    
    def self.set(plugin_type, priority)
      @custom_priorities[plugin_type] = priority
      notify_priority_change(plugin_type, priority)
    end
    
    def self.can_override?(new_plugin, existing_plugin)
      new_priority = get(new_plugin.type)
      existing_priority = get(existing_plugin.type)
      new_priority > existing_priority
    end
    
    def self.load_from_config(config_path)
      return unless File.exist?(config_path)
      
      config = YAML.load_file(config_path)
      config['plugin_priorities']&.each do |type, priority|
        set(type.to_sym, priority)
      end
    end
    
    def self.reset_custom_priorities!
      @custom_priorities.clear
      @conflict_policies.clear
    end
    
    def self.all_priorities
      DEFAULT_PRIORITIES.merge(@custom_priorities)
    end
    
    private
    
    def self.notify_priority_change(plugin_type, priority)
      if ENV['NUMANA_DEBUG']
        puts "Priority updated: #{plugin_type} = #{priority}"
      end
    end
  end
end
```

### ConflictResolver System (重複解決エンジン)

**実装ファイル**: `lib/numana/plugin_conflict_resolver.rb`

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
    
    def self.reject_duplicates(new_plugin, existing_plugin)
      raise PluginConflictError, build_conflict_message(new_plugin, existing_plugin, :rejected)
    end
    
    def self.warn_and_override(new_plugin, existing_plugin)
      warning_message = build_conflict_message(new_plugin, existing_plugin, :overriding)
      warn warning_message
      
      PluginRegistry.override_plugin(existing_plugin.name, new_plugin)
      
      ConflictResolutionResult.new(
        action: :override,
        message: warning_message,
        new_plugin: new_plugin,
        replaced_plugin: existing_plugin
      )
    end
    
    def self.silent_override(new_plugin, existing_plugin)
      PluginRegistry.override_plugin(existing_plugin.name, new_plugin)
      
      ConflictResolutionResult.new(
        action: :override,
        message: "Plugin '#{existing_plugin.name}' silently overridden",
        new_plugin: new_plugin,
        replaced_plugin: existing_plugin
      )
    end
    
    def self.use_namespace(new_plugin, existing_plugin)
      namespaced_name = PluginNamespace.auto_namespace(new_plugin.name, new_plugin.source_gem)
      new_plugin.namespaced_name = namespaced_name
      
      PluginRegistry.register(namespaced_name, new_plugin)
      
      ConflictResolutionResult.new(
        action: :namespace,
        message: "Plugin registered with namespace: #{namespaced_name}",
        new_plugin: new_plugin,
        namespaced_name: namespaced_name
      )
    end
    
    def self.prompt_user(new_plugin, existing_plugin)
      return auto_resolve(new_plugin, existing_plugin) unless $stdin.tty?
      
      puts build_conflict_message(new_plugin, existing_plugin, :prompt)
      puts "1) Override existing plugin"
      puts "2) Use namespace for new plugin"  
      puts "3) Reject new plugin"
      print "Choose an option (1-3): "
      
      choice = $stdin.gets.chomp.to_i
      
      case choice
      when 1 then warn_and_override(new_plugin, existing_plugin)
      when 2 then use_namespace(new_plugin, existing_plugin)
      when 3 then reject_duplicates(new_plugin, existing_plugin)
      else
        puts "Invalid choice, using auto-resolution"
        auto_resolve(new_plugin, existing_plugin)
      end
    end
    
    def self.auto_resolve(new_plugin, existing_plugin)
      if PluginPriority.can_override?(new_plugin, existing_plugin)
        warn_and_override(new_plugin, existing_plugin)
      else
        use_namespace(new_plugin, existing_plugin)
      end
    end
    
    def self.build_conflict_message(new_plugin, existing_plugin, action)
      <<~MESSAGE
        Plugin Conflict Detected:
          Existing: #{existing_plugin.name} (#{existing_plugin.type}, priority: #{PluginPriority.get(existing_plugin.type)})
          New:      #{new_plugin.name} (#{new_plugin.type}, priority: #{PluginPriority.get(new_plugin.type)})
          Action:   #{action.to_s.humanize}
      MESSAGE
    end
  end
  
  class ConflictResolutionResult
    attr_reader :action, :message, :new_plugin, :replaced_plugin, :namespaced_name
    
    def initialize(action:, message:, new_plugin:, replaced_plugin: nil, namespaced_name: nil)
      @action = action
      @message = message
      @new_plugin = new_plugin
      @replaced_plugin = replaced_plugin
      @namespaced_name = namespaced_name
    end
    
    def override?
      @action == :override
    end
    
    def namespace?
      @action == :namespace
    end
    
    def rejection?
      @action == :rejection
    end
  end
  
  class ConflictValidator
    attr_reader :error_message
    
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
  
  class PluginConflictError < StandardError; end
  class InvalidConflictError < StandardError; end
end
```

### PluginNamespace System (名前空間管理)

**実装ファイル**: `lib/numana/plugin_namespace.rb`

```ruby
class NumberAnalyzer
  class PluginNamespace
    NAMESPACE_PATTERNS = {
      gem: ->(plugin_name, source_gem) {
        case source_gem
        when /^numana-(.+)/
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
    
    def self.register_with_namespace(plugin, namespace = nil, pattern: :gem)
      namespace ||= auto_namespace(plugin.name, plugin.source_gem, pattern: pattern)
      namespaced_name = "#{namespace}::#{plugin.name}"
      
      PluginRegistry.register(namespaced_name, plugin)
      
      {
        original_name: plugin.name,
        namespaced_name: namespaced_name,
        namespace: namespace
      }
    end
    
    def self.resolve_namespace(namespaced_name)
      if namespaced_name.include?('::')
        namespace, name = namespaced_name.split('::', 2)
        { namespace: namespace, name: name }
      else
        { namespace: nil, name: namespaced_name }
      end
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
      
      case namespaced_matches.size
      when 0
        nil
      when 1
        namespaced_matches.first
      else
        handle_multiple_matches(search_name, namespaced_matches)
      end
    end
    
    private
    
    def self.handle_multiple_matches(search_name, matches)
      warn "Multiple plugins found for '#{search_name}':"
      matches.each_with_index do |(name, plugin), index|
        namespace = resolve_namespace(name)[:namespace]
        puts "  #{index + 1}) #{name} (from #{namespace})"
      end
      
      # デフォルトで最初のマッチを返す
      matches.first
    end
  end
end
```

### 3-Layer Configuration System (3層設定システム)

**実装ファイル**: `lib/numana/plugin_configuration.rb`

```ruby
class NumberAnalyzer
  class PluginConfiguration
    include Singleton
    
    attr_accessor :conflict_strategy, :development_mode, :namespace_pattern
    attr_reader :custom_priorities, :per_plugin_policies
    
    def initialize
      @conflict_strategy = :auto
      @development_mode = false
      @namespace_pattern = :gem
      @custom_priorities = {}
      @per_plugin_policies = {}
      
      load_from_env
      load_from_file
    end
    
    def plugin_priority(plugin_type, priority = nil)
      if priority
        @custom_priorities[plugin_type.to_sym] = priority
        PluginPriority.set(plugin_type.to_sym, priority)
      else
        PluginPriority.get(plugin_type.to_sym)
      end
    end
    
    def conflict_strategy_for(plugin_name)
      # パターンマッチング
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
    
    def set_plugin_policy(plugin_pattern, strategy)
      @per_plugin_policies[plugin_pattern] = strategy.to_sym
    end
    
    def development_mode?
      @development_mode || ENV['NUMANA_PLUGIN_MODE'] == 'development'
    end
    
    def load_from_file(config_path = 'config/numana.yml')
      return unless File.exist?(config_path)
      
      config = YAML.load_file(config_path)
      plugin_config = config['plugin_system'] || {}
      
      load_priorities(plugin_config['priorities'] || {})
      load_conflict_settings(plugin_config['conflict_resolution'] || {})
      load_namespace_settings(plugin_config['namespaces'] || {})
    end
    
    private
    
    def load_from_env
      @conflict_strategy = ENV['NUMANA_CONFLICT_STRATEGY']&.to_sym || @conflict_strategy
      @development_mode = ENV['NUMANA_PLUGIN_MODE'] == 'development'
    end
    
    def load_priorities(priorities_config)
      priorities_config.each do |type, priority|
        plugin_priority(type, priority)
      end
    end
    
    def load_conflict_settings(conflict_config)
      @conflict_strategy = conflict_config['default_strategy']&.to_sym || @conflict_strategy
      
      (conflict_config['per_plugin'] || {}).each do |pattern, strategy|
        set_plugin_policy(pattern, strategy)
      end
    end
    
    def load_namespace_settings(namespace_config)
      @namespace_pattern = namespace_config['patterns']&.keys&.first&.to_sym || @namespace_pattern
    end
  end
end
```

## Week 1: PluginPriority System Implementation

### 1.1 Core Priority Infrastructure

**実装ファイル**: `lib/numana/plugin_priority.rb` (上記詳細設計参照)

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

**実装ファイル**: `lib/numana/plugin_conflict_resolver.rb`

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

**実装ファイル**: `lib/numana/plugin_namespace.rb`

```ruby
class NumberAnalyzer
  class PluginNamespace
    NAMESPACE_PATTERNS = {
      gem: ->(plugin_name, source_gem) {
        case source_gem
        when /^numana-(.+)/
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

**ファイル強化**: `lib/numana/plugin_configuration.rb`

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

**ファイル強化**: `lib/numana/cli.rb`

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

### CLI Integration with Conflict Resolution Commands

**ファイル強化**: `lib/numana/cli.rb`

```bash
# 重複確認・解決コマンド例
bundle exec numana plugins --conflicts
# Plugin Conflicts Detected:
#   basic_stats: core_plugins vs third_party_gems (my-stats-gem)
#   mean: builtin vs plugin (advanced-stats-plugin)

# 特定の重複解決
bundle exec numana plugins resolve basic_stats --strategy=interactive
# Plugin Conflict: basic_stats
#   1) Override existing (core_plugins) with new (third_party_gems)
#   2) Use namespace for new plugin
#   3) Reject new plugin
# Choose an option (1-3): 2
# Plugin registered as: ext_my_stats_gem_basic_stats

# 開発モード（全上書き許可）
bundle exec numana --dev-mode mean 1 2 3
# Warning: Development mode - all plugin overrides allowed

# 名前空間付きコマンド実行
bundle exec numana ml::linear-regression data.csv
bundle exec numana ext_advanced_stats_mean 1 2 3

# プラグイン一覧（重複も表示）
bundle exec numana plugins list --show-conflicts
# Available Plugins:
#   basic_stats (core_plugins, priority: 90)
#   ext_my_stats_gem_basic_stats (third_party_gems, priority: 50) [NAMESPACED]
#   mean (builtin)
#   advanced_stats::mean (plugin) [NAMESPACED]
```

### Configuration File Template

**新規ファイル**: `config/numana.yml.example`

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

## 🧪 Comprehensive Testing Strategy

### Testing Overview
**新規テスト合計**: 25+ tests (163 existing + 25 new = 188+ total tests)

### Unit Testing by Component

#### 1. Priority System Tests (10 tests) - `spec/plugin_priority_spec.rb`

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
    after { described_class.reset_custom_priorities! }
    
    it 'allows custom priority setting' do
      described_class.set(:my_custom_type, 95)
      expect(described_class.get(:my_custom_type)).to eq(95)
    end
    
    it 'loads from configuration file' do
      config_content = { 'plugin_priorities' => { 'special_plugins' => 85 } }
      allow(YAML).to receive(:load_file).and_return(config_content)
      
      described_class.load_from_config('test_config.yml')
      expect(described_class.get(:special_plugins)).to eq(85)
    end
  end
end
```

#### 2. Conflict Resolution Tests (10 tests) - `spec/plugin_conflict_resolver_spec.rb`

```ruby
RSpec.describe NumberAnalyzer::PluginConflictResolver do
  let(:core_plugin) { double(:plugin, name: 'basic_stats', type: :core_plugins, source_gem: 'numana') }
  let(:third_party_plugin) { double(:plugin, name: 'basic_stats', type: :third_party_gems, source_gem: 'my-stats-gem') }
  let(:development_plugin) { double(:plugin, name: 'basic_stats', type: :development, source_gem: 'local') }
  
  describe '.resolve_conflict' do
    context 'with strict strategy' do
      it 'rejects all duplicates' do
        expect {
          described_class.resolve_conflict(third_party_plugin, core_plugin, :strict)
        }.to raise_error(NumberAnalyzer::PluginConflictError)
      end
    end
    
    context 'with development plugin' do
      it 'allows development plugins to override anything' do
        result = described_class.resolve_conflict(development_plugin, core_plugin, :auto)
        expect(result.action).to eq(:override)
      end
    end
    
    context 'with priority-based resolution' do
      it 'allows higher priority to override lower priority' do
        result = described_class.resolve_conflict(core_plugin, third_party_plugin, :auto)
        expect(result.action).to eq(:override)
      end
      
      it 'uses namespace for lower priority conflicts' do
        result = described_class.resolve_conflict(third_party_plugin, core_plugin, :auto)
        expect(result.action).to eq(:namespace)
      end
    end
  end
end
```

#### 3. Namespace Tests (5 tests) - `spec/plugin_namespace_spec.rb`

```ruby
RSpec.describe NumberAnalyzer::PluginNamespace do
  describe '.auto_namespace' do
    it 'generates namespace for numana gems' do
      result = described_class.auto_namespace('stats', 'numana-ml')
      expect(result).to eq('na_ml_stats')
    end
    
    it 'generates namespace for external gems' do
      result = described_class.auto_namespace('analyze', 'my-awesome-gem')
      expect(result).to eq('ext_my_awesome_gem_analyze')
    end
  end
  
  describe '.find_plugin_by_name' do
    before do
      allow(PluginRegistry).to receive(:find).with('stats').and_return(nil)
      allow(PluginRegistry).to receive(:all_plugins).and_return({
        'na_ml_stats' => double(:plugin),
        'ext_custom_stats' => double(:plugin)
      })
    end
    
    it 'finds namespaced plugins by original name' do
      result = described_class.find_plugin_by_name('stats')
      expect(result).not_to be_nil
    end
    
    it 'handles multiple matches' do
      expect { described_class.find_plugin_by_name('stats') }
        .to output(/Multiple plugins found/).to_stdout
    end
  end
end
```

### Integration Testing

```ruby
# spec/integration/conflict_resolution_integration_spec.rb
RSpec.describe 'Conflict Resolution Integration' do
  let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
  
  before do
    # テスト用プラグインの準備
    create_test_plugin('BasicStatsOverride', :third_party_gems)
    create_test_plugin('AdvancedAnalytics', :official_gems)
  end
  
  after do
    cleanup_test_plugins
  end
  
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

### CLI Integration Testing

```ruby
# spec/cli/conflict_resolution_cli_spec.rb
RSpec.describe 'CLI Conflict Resolution' do
  describe 'plugins conflicts command' do
    it 'displays current conflicts' do
      create_conflicting_plugins
      
      output = capture_output do
        NumberAnalyzer::CLI.run(['plugins', '--conflicts'])
      end
      
      expect(output).to include('Plugin Conflicts Detected')
      expect(output).to include('basic_stats:')
      expect(output).to include('Recommended:')
    end
  end
  
  describe 'plugins resolve command' do
    it 'resolves conflicts interactively' do
      create_conflicting_plugins
      
      allow($stdin).to receive(:gets).and_return("2\n")  # namespace選択
      
      output = capture_output do
        NumberAnalyzer::CLI.run(['plugins', 'resolve', 'basic_stats', '--strategy=interactive'])
      end
      
      expect(output).to include('Plugin registered with namespace')
    end
  end
  
  describe 'development mode' do
    it 'shows development mode warning' do
      output = capture_output do
        NumberAnalyzer::CLI.run(['--dev-mode', 'mean', '1', '2', '3'])
      end
      
      expect(output).to include('Warning: Development mode')
    end
  end
end
```

### Performance Testing

```ruby
# spec/performance/conflict_resolution_performance_spec.rb
RSpec.describe 'Conflict Resolution Performance' do
  it 'resolves conflicts within acceptable time' do
    plugins = create_many_conflicting_plugins(100)
    
    start_time = Time.now
    plugins.each { |plugin| register_plugin_with_conflict_resolution(plugin) }
    resolution_time = Time.now - start_time
    
    expect(resolution_time).to be < 1.0  # 100プラグインを1秒以内
  end
  
  it 'maintains memory efficiency during resolution' do
    initial_memory = measure_memory_usage
    
    50.times { create_and_resolve_conflict }
    
    final_memory = measure_memory_usage
    memory_growth = final_memory - initial_memory
    
    expect(memory_growth).to be < 10_000_000  # 10MB以内
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

## 🛡️ Quality Assurance & Safety

### 後方互換性保証

```ruby
# 既存APIの完全保持確認
RSpec.describe 'Backward Compatibility' do
  it 'maintains all existing APIs' do
    analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5])
    
    # Phase 7.8と同じAPIが動作
    expect(analyzer.mean).to eq(3.0)
    expect(analyzer.correlation([2, 4, 6, 8, 10])).to eq(1.0)
    expect(analyzer.one_way_anova([1, 2], [3, 4])).to be_a(Hash)
  end
  
  it 'maintains legacy mode compatibility' do
    analyzer = NumberAnalyzer.new([1, 2, 3], plugins: :legacy)
    
    # 全機能が利用可能
    expect(analyzer).to respond_to(:mean)
    expect(analyzer).to respond_to(:kruskal_wallis_test)
    expect(analyzer.loaded_plugins.size).to eq(7)
  end
end
```

### 品質ゲート

```bash
# 各Phase完了時の必須チェック
#!/bin/bash
# scripts/quality_gate.sh

echo "Running quality gate checks..."

# 1. 全テスト通過
bundle exec rspec
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi

# 2. RuboCop準拠
bundle exec rubocop
if [ $? -ne 0 ]; then
  echo "❌ RuboCop violations found"
  exit 1
fi

# 3. 後方互換性
bundle exec rspec spec/backward_compatibility_spec.rb
if [ $? -ne 0 ]; then
  echo "❌ Backward compatibility broken"
  exit 1
fi

# 4. パフォーマンス要件
bundle exec rspec spec/performance/conflict_resolution_performance_spec.rb
if [ $? -ne 0 ]; then
  echo "❌ Performance requirements not met"
  exit 1
fi

echo "✅ All quality gates passed"
```

### ロールバック戦略

```bash
#!/bin/bash
# scripts/conflict_system_rollback.sh

case "$1" in
  "phase_1")
    echo "Rolling back to pre-priority-system state..."
    git checkout conflict-resolution-start
    bundle install
    bundle exec rspec spec/integration/
    ;;
  "phase_2")
    echo "Rolling back to priority-system-only..."
    git checkout phase-1-complete
    bundle install
    bundle exec rspec
    ;;
  "emergency")
    echo "Emergency rollback to stable state..."
    git checkout phase-7.8-stable
    bundle install
    bundle exec rspec
    ;;
esac
```

---

この統合文書により、Phase 8.0 Step 5の実装が完全にガイドされ、NumberAnalyzer Plugin System Architectureの完成を確実にします。

**統合完了**: 詳細設計から実装計画、テスト戦略、品質保証まで、重複管理システムの完全な実装ガイドを統合文書として提供します。