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

      return nil if satisfying.empty?

      satisfying.min_by { |v| normalize_version_for_comparison(v) }
    end

    private

    def normalize_version_for_comparison(version)
      version.split('.').map(&:to_i)
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

      return nil if satisfying.empty?

      satisfying.max_by { |v| normalize_version_for_comparison(v) }
    end

    private

    def normalize_version_for_comparison(version)
      version.split('.').map(&:to_i)
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
      return exact if exact

      ConservativeStrategy.new.select_version(versions, requirement)
    end
  end
end
