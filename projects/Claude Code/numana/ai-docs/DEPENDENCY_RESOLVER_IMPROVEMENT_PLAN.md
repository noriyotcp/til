# DependencyResolver 改善計画

## 概要

DependencyResolver（399行）の複雑度を削減し、保守性・拡張性を向上させる詳細な改善計画です。

## 現状の課題

1. **高い複雑度**
   - バージョン比較ロジックが120行以上（全体の30%）
   - 深いネストレベルと多数の条件分岐
   - 単一クラスに多くの責任が集中

2. **拡張性の制限**
   - 依存関係解決戦略がハードコード
   - カスタムバージョニングスキームへの対応困難
   - 設定の柔軟性不足

3. **テストの困難さ**
   - バージョン比較ロジックが密結合
   - 戦略の切り替えが困難

## 改善計画

### Phase 1: VersionComparator の実装（優先度：高）

#### 新規ファイル: `lib/number_analyzer/version_comparator.rb`

```ruby
# frozen_string_literal: true

# Semantic version comparison utility for NumberAnalyzer
# Handles version comparison and requirement satisfaction checks
class NumberAnalyzer::VersionComparator
  # Custom error for invalid version formats
  class InvalidVersionError < StandardError; end

  class << self
    # Compare two version strings
    # @param version1 [String] First version (e.g., "1.2.3")
    # @param version2 [String] Second version (e.g., "1.2.4")
    # @return [Integer] -1 if v1 < v2, 0 if equal, 1 if v1 > v2
    def compare(version1, version2)
      validate_version!(version1)
      validate_version!(version2)
      
      parts1 = normalize_version(version1)
      parts2 = normalize_version(version2)
      
      compare_version_parts(parts1, parts2)
    end

    # Check if version satisfies requirement
    # @param version [String] Version to check (e.g., "1.2.3")
    # @param requirement [String] Requirement (e.g., "~> 1.2", ">= 1.0")
    # @return [Boolean] true if version satisfies requirement
    def satisfies?(version, requirement)
      return true if requirement.nil? || requirement == '*'
      
      case requirement
      when /^~>\s*(.+)$/
        pessimistic_constraint?(version, Regexp.last_match(1).strip)
      when /^(>=|>|<=|<|=|==)\s*(.+)$/
        comparison_constraint?(version, Regexp.last_match(1), Regexp.last_match(2).strip)
      else
        version == requirement
      end
    end

    # Parse version requirement into operator and version
    # @param requirement [String] Version requirement
    # @return [Array<String, String>] [operator, version]
    def parse_requirement(requirement)
      case requirement
      when /^(~>|>=|>|<=|<|=|==)\s*(.+)$/
        [Regexp.last_match(1), Regexp.last_match(2).strip]
      else
        ['=', requirement]
      end
    end

    private

    def validate_version!(version)
      return if version.match?(/^\d+(\.\d+)*$/)
      
      raise InvalidVersionError, "Invalid version format: #{version}"
    end

    def normalize_version(version)
      parts = version.split('.').map(&:to_i)
      # Ensure at least 3 parts for semantic versioning
      parts + [0] * [3 - parts.size, 0].max
    end

    def compare_version_parts(parts1, parts2)
      # Make arrays same length
      max_length = [parts1.size, parts2.size].max
      parts1 += [0] * (max_length - parts1.size)
      parts2 += [0] * (max_length - parts2.size)
      
      parts1.zip(parts2).each do |p1, p2|
        return 1 if p1 > p2
        return -1 if p1 < p2
      end
      
      0
    end

    def pessimistic_constraint?(version, requirement)
      req_parts = requirement.split('.')
      ver_parts = version.split('.')
      
      # Version must have at least as many parts as requirement
      return false if ver_parts.size < req_parts.size
      
      # All parts except last must match exactly
      (0...(req_parts.size - 1)).each do |i|
        return false if req_parts[i] != ver_parts[i]
      end
      
      # Last part of version must be >= last part of requirement
      ver_parts[req_parts.size - 1].to_i >= req_parts.last.to_i
    end

    def comparison_constraint?(version, operator, requirement)
      comparison = compare(version, requirement)
      
      case operator
      when '>='
        comparison >= 0
      when '>'
        comparison.positive?
      when '<='
        comparison <= 0
      when '<'
        comparison.negative?
      when '=', '=='
        comparison.zero?
      end
    end
  end
end
```

### Phase 2: 依存関係解決戦略（優先度：中）

#### 新規ファイル: `lib/number_analyzer/dependency_resolution_strategies.rb`

```ruby
# frozen_string_literal: true

# Dependency resolution strategies for NumberAnalyzer
module NumberAnalyzer::DependencyResolutionStrategies
  # Base strategy interface
  class BaseStrategy
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    # Resolve dependencies for a plugin
    # @param resolver [DependencyResolver] The resolver instance
    # @param plugin_name [String] Plugin to resolve
    # @return [Array<String>] Ordered list of plugins to load
    def resolve(resolver, plugin_name)
      raise NotImplementedError, "#{self.class} must implement #resolve"
    end

    # Select version when multiple are available
    # @param versions [Array<String>] Available versions
    # @param requirement [String] Version requirement
    # @return [String] Selected version
    def select_version(versions, requirement)
      raise NotImplementedError, "#{self.class} must implement #select_version"
    end
  end

  # Conservative strategy: prefer older stable versions
  class ConservativeStrategy < BaseStrategy
    def resolve(resolver, plugin_name)
      # Standard topological sort with stable version preference
      resolver.standard_resolve(plugin_name)
    end

    def select_version(versions, requirement)
      # Select oldest version that satisfies requirement
      satisfying = versions.select do |v|
        NumberAnalyzer::VersionComparator.satisfies?(v, requirement)
      end
      
      satisfying.min_by { |v| NumberAnalyzer::VersionComparator.normalize_version(v) }
    end
  end

  # Aggressive strategy: prefer newest versions
  class AggressiveStrategy < BaseStrategy
    def resolve(resolver, plugin_name)
      # Resolve with preference for newer versions
      resolver.standard_resolve(plugin_name, prefer_newer: true)
    end

    def select_version(versions, requirement)
      # Select newest version that satisfies requirement
      satisfying = versions.select do |v|
        NumberAnalyzer::VersionComparator.satisfies?(v, requirement)
      end
      
      satisfying.max_by { |v| NumberAnalyzer::VersionComparator.normalize_version(v) }
    end
  end

  # Minimal strategy: load only required dependencies
  class MinimalStrategy < BaseStrategy
    def resolve(resolver, plugin_name)
      # Skip optional dependencies
      resolver.standard_resolve(plugin_name, skip_optional: true)
    end

    def select_version(versions, requirement)
      # Use exact version if specified, otherwise oldest stable
      exact = versions.find { |v| v == requirement }
      exact || ConservativeStrategy.new.select_version(versions, requirement)
    end
  end
end
```

### Phase 3: DependencyResolver のリファクタリング

#### 更新: `lib/number_analyzer/dependency_resolver.rb`

主な変更点：
1. バージョン比較メソッドを削除（-120行）
2. VersionComparator への委譲
3. 戦略パターンの導入

```ruby
# frozen_string_literal: true

require 'tsort'
require_relative 'version_comparator'
require_relative 'dependency_resolution_strategies'

# Refactored dependency resolution system
class NumberAnalyzer::DependencyResolver
  include TSort

  # ... (existing error classes remain) ...

  def initialize(plugin_registry, options = {})
    @plugin_registry = plugin_registry
    @dependency_graph = {}
    @version_requirements = {}
    @resolution_cache = {}
    @strategy = create_strategy(options[:strategy])
  end

  # Resolve dependencies using configured strategy
  def resolve(plugin_name, options = {})
    return @resolution_cache[plugin_name] if @resolution_cache.key?(plugin_name)

    validate_plugin_exists!(plugin_name)
    build_dependency_graph(plugin_name)
    detect_circular_dependencies

    resolution = @strategy.resolve(self, plugin_name)
    validate_versions(resolution) if options[:check_versions]

    @resolution_cache[plugin_name] = resolution
    resolution
  end

  # Standard resolution logic (used by strategies)
  def standard_resolve(plugin_name, options = {})
    all_dependencies = Set.new([plugin_name])
    collect_all_dependencies(plugin_name, all_dependencies, options)

    sorted = tsort_nodes(all_dependencies.to_a)
    
    missing = sorted.reject { |dep| dependency_available?(dep) }
    raise UnresolvedDependencyError.new(plugin_name, missing) if missing.any?

    sorted
  end

  private

  def create_strategy(strategy_name)
    strategies = NumberAnalyzer::DependencyResolutionStrategies
    
    case strategy_name
    when :aggressive
      strategies::AggressiveStrategy.new
    when :minimal
      strategies::MinimalStrategy.new
    else
      strategies::ConservativeStrategy.new
    end
  end

  # Simplified version methods using VersionComparator
  def satisfy_version_requirement?(version, requirement)
    NumberAnalyzer::VersionComparator.satisfies?(version, requirement)
  end

  def compare_versions(version1, version2)
    NumberAnalyzer::VersionComparator.compare(version1, version2)
  end

  # Remove all version comparison methods (lines 282-398)
  # The following methods are deleted:
  # - match_version_pattern?
  # - pessimistic_constraint?
  # - comparison_constraint?
  # - exact_match_constraint?
  # - handle_pessimistic_constraint?
  # - handle_comparison_constraint?
  # - handle_exact_match?
  # - parse_comparison_constraint
  # - version_greater_or_equal?
  # - version_greater?
  # - version_less_or_equal?
  # - version_less?
  # - pessimistic_version_satisfied?
  # - normalize_version_parts
  # - compare_version_parts

  # ... (remaining methods stay the same) ...
end
```

### Phase 4: 設定ファイルサポート（優先度：低）

#### 新規ファイル: `config/dependency_resolver.yml`

```yaml
# Dependency resolver configuration
dependency_resolver:
  # Default resolution strategy: conservative, aggressive, minimal
  default_strategy: conservative
  
  # Version constraint handling
  version_constraints:
    # Allow pre-release versions (e.g., 1.0.0-beta)
    allow_prerelease: false
    # Enforce strict semantic versioning
    strict_semver: true
    # Default version for plugins without version
    default_version: "0.0.0"
  
  # Resolution cache settings
  cache:
    enabled: true
    # Cache TTL in seconds (1 hour)
    ttl: 3600
    # Maximum cache size
    max_size: 100
  
  # Performance settings
  performance:
    # Maximum dependency graph size
    max_graph_size: 1000
    # Enable parallel resolution (experimental)
    parallel_resolution: false
    # Timeout for resolution in seconds
    resolution_timeout: 30
  
  # Logging and debugging
  debug:
    # Log resolution steps
    log_resolution: false
    # Save dependency graphs
    save_graphs: false
    # Graph output directory
    graph_dir: "tmp/dependency_graphs"
```

### Phase 5: テスト計画

#### 新規: `spec/version_comparator_spec.rb`

```ruby
# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/version_comparator'

RSpec.describe NumberAnalyzer::VersionComparator do
  describe '.compare' do
    # Test cases for version comparison
    it 'compares major versions correctly'
    it 'compares minor versions correctly'
    it 'compares patch versions correctly'
    it 'handles different version lengths'
    it 'raises error for invalid versions'
  end

  describe '.satisfies?' do
    # Test cases for requirement satisfaction
    context 'with pessimistic constraint (~>)'
    context 'with comparison operators'
    context 'with wildcard (*)'
    context 'with exact match'
  end
end
```

## 実装スケジュール

### Week 1: VersionComparator
- [ ] VersionComparator クラスの実装
- [ ] 包括的なテストスイート作成
- [ ] ドキュメント作成

### Week 2: DependencyResolver リファクタリング
- [ ] バージョン比較ロジックの削除
- [ ] VersionComparator への移行
- [ ] 既存テストの更新

### Week 3: 戦略パターン
- [ ] BaseStrategy の実装
- [ ] 3つの戦略の実装
- [ ] 戦略切り替えのテスト

### Week 4: 仕上げ
- [ ] 設定ファイルサポート
- [ ] パフォーマンステスト
- [ ] ドキュメント更新

## 期待される成果

### コード品質の向上
- **行数削減**: 399行 → 250行（約40%削減）
- **複雑度削減**: 各メソッド10行以下
- **責任の分離**: 単一責任の原則に準拠

### 保守性の向上
- バージョン比較ロジックの独立
- 戦略の追加が容易
- テストの簡素化

### パフォーマンス
- キャッシングの改善
- 不要な計算の削減
- メモリ使用量の最適化

## リスクと対策

### リスク
1. 既存の動作との互換性
2. パフォーマンスの劣化
3. 新たなバグの導入

### 対策
1. 包括的な回帰テスト
2. ベンチマークテスト
3. 段階的な移行

## まとめ

この改善により、DependencyResolver は以下のような利点を得られます：

1. **明確な責任分離**: バージョン比較、依存関係解決、戦略選択
2. **高い拡張性**: 新しい戦略やバージョニング方式の追加が容易
3. **優れたテスト性**: 各コンポーネントの独立したテスト
4. **設定の柔軟性**: YAMLによる動作カスタマイズ

これらの改善により、より保守しやすく、拡張可能な依存関係解決システムが実現されます。