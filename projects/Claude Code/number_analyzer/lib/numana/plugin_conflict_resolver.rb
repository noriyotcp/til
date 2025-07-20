# frozen_string_literal: true

require 'set'
require_relative 'plugin_priority'
require_relative 'plugin_namespace'
require_relative 'conflict_resolution_strategies'

# Plugin Conflict Resolution System for NumberAnalyzer
# Handles conflicts when multiple plugins provide the same functionality
# Comprehensive plugin conflict detection and resolution system
#
# This class provides intelligent conflict management for the NumberAnalyzer plugin ecosystem,
# supporting multiple resolution strategies and automatic conflict detection across different
# plugin interaction points (commands, methods, namespaces).
#
# @example Basic usage
#   priority_system = PluginPriority.new
#   resolver = PluginConflictResolver.new(priority_system)
#
#   conflicts = resolver.detect_conflicts(plugins_registry)
#   resolutions = resolver.resolve_all_conflicts(conflicts)
#
# @example Custom strategy
#   resolver.set_default_strategy(:command_name, :namespace)
#   resolution = resolver.resolve_conflict(:command_name, ['plugin_a', 'plugin_b'], :strict)
class NumberAnalyzer::PluginConflictResolver
  include ConflictResolutionStrategies

  # Available conflict resolution strategies
  RESOLUTION_STRATEGIES = {
    strict: 'Fail immediately on any conflict',
    warn_override: 'Override with warning message',
    silent_override: 'Override silently using priority',
    namespace: 'Use namespaced plugin names',
    interactive: 'Prompt user for resolution choice',
    auto: 'Automatically resolve using priority and heuristics'
  }.freeze

  # Default strategy for different conflict types
  DEFAULT_STRATEGIES = {
    command_name: :warn_override,
    statistics_method: :namespace,
    file_format: :strict,
    output_format: :namespace,
    validator: :auto
  }.freeze

  def initialize(priority_system = nil)
    @priority_system = priority_system || NumberAnalyzer::PluginPriority.new
    @namespace_system = NumberAnalyzer::PluginNamespace.new(@priority_system)
    @conflict_log = []
    @resolution_cache = {}
    @interactive_responses = {} # Cache for interactive responses
    @namespace_mappings = {}    # Track namespace mappings
    @default_strategies = DEFAULT_STRATEGIES.dup # Mutable copy for runtime changes
  end

  # Detect conflicts between plugins
  def detect_conflicts(plugins_registry)
    conflicts = {
      command_conflicts: detect_command_conflicts(plugins_registry),
      method_conflicts: detect_method_conflicts(plugins_registry),
      namespace_conflicts: detect_namespace_conflicts(plugins_registry)
    }

    log_conflicts(conflicts)
    conflicts
  end

  # Resolve a specific conflict using given strategy
  def resolve_conflict(conflict_type, conflicting_plugins, strategy = nil)
    strategy ||= @default_strategies[conflict_type] || :auto

    validate_strategy!(strategy)

    # Check cache first
    cached = get_cached_resolution(conflict_type, conflicting_plugins)
    return cached if cached

    # Resolve using specified strategy
    resolution = case strategy
                 when :strict
                   resolve_strict(conflict_type, conflicting_plugins)
                 when :warn_override
                   resolve_warn_override(conflict_type, conflicting_plugins)
                 when :silent_override
                   resolve_silent_override(conflict_type, conflicting_plugins)
                 when :namespace
                   resolve_namespace(conflict_type, conflicting_plugins)
                 when :interactive
                   resolve_interactive(conflict_type, conflicting_plugins)
                 when :auto
                   resolve_auto(conflict_type, conflicting_plugins)
                 else
                   raise ArgumentError, "Unknown strategy: #{strategy}"
                 end

    # Cache the resolution
    cache_resolution(conflict_type, conflicting_plugins, resolution)
    log_resolution(conflict_type, strategy, resolution)

    resolution
  end

  # Resolve all conflicts using appropriate strategies
  def resolve_all_conflicts(conflicts, strategy_overrides = {})
    resolutions = {}

    conflicts.each do |conflict_category, category_conflicts|
      resolutions[conflict_category] = {}

      category_conflicts.each do |conflict_type, conflicting_plugins|
        next if conflicting_plugins.empty?

        strategy = strategy_overrides[conflict_type] || @default_strategies[conflict_type] || :auto
        resolution = resolve_conflict(conflict_type, conflicting_plugins, strategy)
        resolutions[conflict_category][conflict_type] = resolution
      end
    end

    resolutions
  end

  # Generate comprehensive conflict report
  def generate_conflict_report
    return 'No conflicts detected.' if @conflict_log.empty?

    report = ["=== Plugin Conflict Report ===\n"]
    report << "Total conflicts detected: #{@conflict_log.length}\n"
    report << conflicts_by_type_summary
    report << "\n=== Recommendations ==="
    report << generate_recommendations

    report.join("\n")
  end

  # Clear conflict history and cache
  def clear_conflict_history
    @conflict_log.clear
    @resolution_cache.clear
    @interactive_responses.clear
  end

  # Set default strategy for a conflict type
  def set_default_strategy(conflict_type, strategy)
    validate_strategy!(strategy)
    @default_strategies[conflict_type] = strategy
  end

  # Get cached resolution if available
  def get_cached_resolution(conflict_type, conflicting_plugins)
    cache_key = generate_cache_key(conflict_type, conflicting_plugins)
    @resolution_cache[cache_key]
  end

  # Check if conflict exists between specific plugins
  def conflict_exists?(plugin_a, plugin_b, conflict_type = nil)
    return false if plugin_a == plugin_b

    conflicts = @conflict_log.select do |conflict|
      conflict[:conflicting_plugins].include?(plugin_a) &&
        conflict[:conflicting_plugins].include?(plugin_b) &&
        (conflict_type.nil? || conflict[:type] == conflict_type)
    end

    !conflicts.empty?
  end

  # Get all plugins that conflict with the given plugin
  def get_conflicting_plugins(plugin_name)
    conflicting = Set.new

    @conflict_log.each do |conflict|
      conflicting.merge(conflict[:conflicting_plugins] - [plugin_name]) if conflict[:conflicting_plugins].include?(plugin_name)
    end

    conflicting.to_a
  end

  # Simulate conflict resolution without applying changes
  def simulate_resolution(conflicts, strategy_overrides = {})
    original_cache = @resolution_cache.dup
    original_responses = @interactive_responses.dup

    begin
      resolutions = resolve_all_conflicts(conflicts, strategy_overrides)

      simulation_results = {
        resolutions: resolutions,
        conflicts_resolved: count_resolved_conflicts(resolutions),
        warnings_generated: count_warnings(resolutions),
        user_interactions_required: count_interactive_resolutions(resolutions)
      }

      simulation_results
    ensure
      # Restore original state
      @resolution_cache = original_cache
      @interactive_responses = original_responses
    end
  end

  # Set response for interactive conflicts (for testing/automation)
  def set_interactive_response(conflict_type, conflicting_plugins, response)
    cache_key = generate_cache_key(conflict_type, conflicting_plugins)
    @interactive_responses[cache_key] = response
  end

  private

  # Detect command name conflicts
  def detect_command_conflicts(plugins_registry)
    command_map = {}
    conflicts = {}

    plugins_registry.each do |plugin_name, plugin_info|
      commands = plugin_info[:commands] || []
      commands.each do |command|
        command_map[command] ||= []
        command_map[command] << plugin_name
      end
    end

    command_map.each do |command, plugins|
      conflicts[command] = plugins if plugins.length > 1
    end

    conflicts
  end

  # Detect method name conflicts
  def detect_method_conflicts(plugins_registry)
    method_map = {}
    conflicts = {}

    plugins_registry.each do |plugin_name, plugin_info|
      methods = plugin_info[:methods] || []
      methods.each do |method|
        method_map[method] ||= []
        method_map[method] << plugin_name
      end
    end

    method_map.each do |method, plugins|
      conflicts[method] = plugins if plugins.length > 1
    end

    conflicts
  end

  # Detect namespace conflicts
  def detect_namespace_conflicts(plugins_registry)
    namespace_map = {}
    conflicts = {}

    plugins_registry.each do |plugin_name, plugin_info|
      namespace = plugin_info[:namespace] || plugin_name
      namespace_map[namespace] ||= []
      namespace_map[namespace] << plugin_name
    end

    namespace_map.each do |namespace, plugins|
      conflicts[namespace] = plugins if plugins.length > 1
    end

    conflicts
  end

  # Helper methods for conflict analysis and logging
  def log_conflicts(conflicts)
    conflicts.each do |category, category_conflicts|
      category_conflicts.each do |type, plugins|
        next if plugins.empty?

        @conflict_log << {
          category: category,
          type: type,
          conflicting_plugins: plugins,
          timestamp: Time.now
        }
      end
    end
  end

  def log_resolution(conflict_type, strategy, resolution)
    puts "Resolved #{conflict_type} conflict using #{strategy} strategy: #{resolution[:status]}" if ENV['DEBUG']
  end

  def cache_resolution(conflict_type, conflicting_plugins, resolution)
    cache_key = generate_cache_key(conflict_type, conflicting_plugins)
    @resolution_cache[cache_key] = resolution
  end

  def conflicts_by_type_summary
    summary = Hash.new(0)
    @conflict_log.each { |conflict| summary[conflict[:type]] += 1 }

    summary.map { |type, count| "  #{type}: #{count}" }.join("\n")
  end

  def generate_recommendations
    recommendations = []

    # Analyze conflict patterns
    recommendations << '- Consider using namespaced commands for command conflicts' if @conflict_log.any? { |c| c[:type].to_s.include?('command') }

    recommendations << '- High number of conflicts detected. Review plugin compatibility' if @conflict_log.length > 5

    recommendations.empty? ? 'No specific recommendations available.' : recommendations.join("\n")
  end

  def count_resolved_conflicts(resolutions)
    resolutions.values.sum do |category|
      category.values.count { |res| res[:status] == :resolved }
    end
  end

  def count_warnings(resolutions)
    resolutions.values.sum do |category|
      category.values.count { |res| res[:strategy] == :warn_override }
    end
  end

  def count_interactive_resolutions(resolutions)
    resolutions.values.sum do |category|
      category.values.count { |res| res[:strategy] == :interactive }
    end
  end

  def validate_strategy!(strategy)
    return if RESOLUTION_STRATEGIES.key?(strategy)

    raise ArgumentError, "Invalid strategy: #{strategy}. " \
                         "Available strategies: #{RESOLUTION_STRATEGIES.keys.join(', ')}"
  end
end
