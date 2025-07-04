# frozen_string_literal: true

require 'set'
require_relative 'plugin_priority'
require_relative 'plugin_namespace'

# Plugin Conflict Resolution System for NumberAnalyzer
# Handles conflicts when multiple plugins provide the same functionality
class NumberAnalyzer
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
  class PluginConflictResolver
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
      @priority_system = priority_system || PluginPriority.new
      @namespace_system = PluginNamespace.new(@priority_system)
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
                   end

      cache_resolution(conflict_type, conflicting_plugins, resolution)
      log_resolution(conflict_type, strategy, resolution)

      resolution
    end

    # Resolve all detected conflicts
    def resolve_all_conflicts(conflicts, strategy_overrides = {})
      resolutions = {}

      conflicts.each do |conflict_type, conflict_list|
        conflict_list.each do |conflict|
          strategy = strategy_overrides[conflict_type] ||
                     strategy_overrides[:global] ||
                     @default_strategies[conflict_type.to_s.gsub('_conflicts', '').to_sym] ||
                     :auto

          resolution = resolve_conflict(
            conflict_type.to_s.gsub('_conflicts', '').to_sym,
            conflict[:plugins],
            strategy
          )

          resolutions[conflict[:name]] = resolution
        end
      end

      resolutions
    end

    # Get conflict resolution report
    def generate_conflict_report
      {
        title: 'Plugin Conflict Resolution Report',
        generated_at: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        total_conflicts: @conflict_log.size,
        conflicts_by_type: conflicts_by_type_summary,
        resolutions: @resolution_cache,
        conflict_log: @conflict_log,
        namespace_mappings: @namespace_mappings,
        recommendations: generate_recommendations
      }
    end

    # Clear conflict history
    def clear_conflict_history
      @conflict_log.clear
      @resolution_cache.clear
      @interactive_responses.clear
    end

    # Set strategy for specific conflict type
    def set_default_strategy(conflict_type, strategy)
      validate_strategy!(strategy)
      @default_strategies[conflict_type] = strategy
    end

    # Get cached resolution if available
    def get_cached_resolution(conflict_type, conflicting_plugins)
      cache_key = generate_cache_key(conflict_type, conflicting_plugins)
      @resolution_cache[cache_key]
    end

    # Check if conflict exists for specific plugins
    def conflict_exists?(plugin_a, plugin_b, conflict_type = nil)
      @conflict_log.any? do |log_entry|
        conflict = log_entry[:conflict]
        conflict[:plugins]&.include?(plugin_a) &&
          conflict[:plugins].include?(plugin_b) &&
          (conflict_type.nil? || log_entry[:type] == conflict_type)
      end
    end

    # Get conflicting plugins for a specific plugin
    def get_conflicting_plugins(plugin_name)
      conflicting = Set.new

      @conflict_log.each do |log_entry|
        conflict = log_entry[:conflict]
        if conflict[:plugins]&.include?(plugin_name)
          conflict[:plugins].each { |p| conflicting.add(p) unless p == plugin_name }
        end
      end

      conflicting.to_a
    end

    # Simulate resolution (dry run)
    def simulate_resolution(conflicts, strategy_overrides = {})
      # Create a temporary copy of the resolver state
      original_cache = @resolution_cache.dup
      original_log = @conflict_log.dup

      begin
        resolutions = resolve_all_conflicts(conflicts, strategy_overrides)

        # Return simulation results without persisting state
        {
          resolutions: resolutions,
          would_succeed: resolutions.values.all? { |r| r[:success] },
          conflicts_resolved: resolutions.size,
          warnings: resolutions.values.count { |r| r[:warnings]&.any? }
        }
      ensure
        # Restore original state
        @resolution_cache = original_cache
        @conflict_log = original_log
      end
    end

    # Method to set interactive responses for testing
    def set_interactive_response(conflict_type, conflicting_plugins, response)
      cache_key = "interactive_#{conflict_type}_#{conflicting_plugins.sort.join('_')}"
      @interactive_responses[cache_key] = response
    end

    private

    def detect_command_conflicts(plugins_registry)
      command_conflicts = Hash.new { |h, k| h[k] = [] }

      plugins_registry.each do |plugin_name, plugin_info|
        commands = plugin_info[:metadata][:commands] || []

        commands.each_key do |command_name|
          command_conflicts[command_name] << plugin_name
        end
      end

      command_conflicts.select { |_cmd, plugins| plugins.size > 1 }
                       .map { |cmd, plugins| { name: cmd, type: :command, plugins: plugins } }
    end

    def detect_method_conflicts(plugins_registry)
      method_conflicts = Hash.new { |h, k| h[k] = [] }

      plugins_registry.each do |plugin_name, plugin_info|
        plugin_class = plugin_info[:class]

        # Get public methods if it's a module or class
        next unless plugin_class.respond_to?(:public_instance_methods)

        methods = plugin_class.public_instance_methods(false)

        methods.each do |method_name|
          next if method_name.to_s.start_with?('plugin_') # Skip plugin metadata methods

          method_conflicts[method_name] << plugin_name
        end
      end

      method_conflicts.select { |_method, plugins| plugins.size > 1 }
                      .map { |method, plugins| { name: method, type: :method, plugins: plugins } }
    end

    def detect_namespace_conflicts(plugins_registry)
      namespace_conflicts = []

      plugins_registry.each_key do |plugin_a|
        plugins_registry.each_key do |plugin_b|
          next if plugin_a >= plugin_b # Avoid duplicate comparisons

          # Check if plugin names are too similar
          next unless similar_plugin_names?(plugin_a, plugin_b)

          namespace_conflicts << {
            name: "#{plugin_a}_vs_#{plugin_b}",
            type: :namespace,
            plugins: [plugin_a, plugin_b],
            similarity: calculate_name_similarity(plugin_a.to_s, plugin_b.to_s)
          }
        end
      end

      namespace_conflicts
    end

    def resolve_strict(conflict_type, conflicting_plugins)
      {
        success: false,
        strategy: :strict,
        winner: nil,
        error: "Conflict detected: #{conflicting_plugins.join(', ')} conflict on #{conflict_type}",
        message: 'Strict mode: conflicts are not allowed'
      }
    end

    def resolve_warn_override(conflict_type, conflicting_plugins)
      # Use priority to determine winner
      winner = select_highest_priority_plugin(conflicting_plugins)
      losers = conflicting_plugins - [winner]

      {
        success: true,
        strategy: :warn_override,
        winner: winner,
        losers: losers,
        warnings: ["Plugin conflict resolved: #{winner} overrides #{losers.join(', ')} for #{conflict_type}"],
        message: "Warning: #{conflict_type} conflict resolved using priority system"
      }
    end

    def resolve_silent_override(conflict_type, conflicting_plugins)
      winner = select_highest_priority_plugin(conflicting_plugins)
      losers = conflicting_plugins - [winner]

      {
        success: true,
        strategy: :silent_override,
        winner: winner,
        losers: losers,
        message: "Silently resolved #{conflict_type} conflict using priority"
      }
    end

    def resolve_namespace(conflict_type, conflicting_plugins)
      namespaced_plugins = {}

      conflicting_plugins.each do |plugin_name|
        namespace = generate_namespace(plugin_name)
        namespaced_plugins[plugin_name] = namespace
        @namespace_mappings[plugin_name] = namespace
      end

      {
        success: true,
        strategy: :namespace,
        winner: nil, # All plugins coexist with namespaces
        namespaced_plugins: namespaced_plugins,
        message: "Created namespaces for #{conflict_type} conflict: #{namespaced_plugins.values.join(', ')}"
      }
    end

    def resolve_interactive(conflict_type, conflicting_plugins)
      # In a real interactive environment, this would prompt the user
      # For testing/automation, we'll use cached responses or fallback to auto
      cache_key = "interactive_#{conflict_type}_#{conflicting_plugins.sort.join('_')}"

      response = get_interactive_response(cache_key, conflict_type, conflicting_plugins)
      return response if response # Early return for fallback

      handle_interactive_response(@interactive_responses[cache_key], conflict_type, conflicting_plugins)
    end

    def resolve_auto(conflict_type, conflicting_plugins)
      # Intelligent automatic resolution based on context
      case conflict_type
      when :command_name
        # For CLI commands, prioritize but warn
        resolve_warn_override(conflict_type, conflicting_plugins)
      when :file_format, :output_format
        # For file/output formats, use highest priority but allow override
        resolve_silent_override(conflict_type, conflicting_plugins)
      when :validator
        # For validators, chain them together if possible
        resolve_chain_validators(conflicting_plugins)
      else
        # For statistical methods and unknown types, use namespacing to preserve functionality
        resolve_namespace(conflict_type, conflicting_plugins)
      end
    end

    def resolve_chain_validators(conflicting_plugins)
      # Special resolution for validators - chain them together
      priority_order = @priority_system.sort_by_priority(conflicting_plugins)

      {
        success: true,
        strategy: :auto,
        winner: nil, # All validators are chained
        chain_order: priority_order,
        message: "Chained validators in priority order: #{priority_order.join(' -> ')}"
      }
    end

    def select_highest_priority_plugin(conflicting_plugins)
      @priority_system.sort_by_priority(conflicting_plugins).first
    end

    def get_interactive_response(cache_key, conflict_type, conflicting_plugins)
      return nil if @interactive_responses.key?(cache_key)

      # Fallback to auto resolution for non-interactive environments
      resolve_auto(conflict_type, conflicting_plugins).merge(
        strategy: :interactive,
        message: 'Interactive resolution unavailable, used automatic fallback'
      )
    end

    def handle_interactive_response(response, conflict_type, conflicting_plugins)
      case response[:action]
      when :select_plugin
        handle_select_plugin_response(response, conflict_type, conflicting_plugins)
      when :namespace_all
        resolve_namespace(conflict_type, conflicting_plugins).merge(
          strategy: :interactive,
          user_choice: true
        )
      when :cancel
        handle_cancel_response
      else
        resolve_auto(conflict_type, conflicting_plugins).merge(
          strategy: :interactive,
          message: 'Invalid interactive response, used automatic fallback'
        )
      end
    end

    def handle_select_plugin_response(response, conflict_type, conflicting_plugins)
      winner = response[:plugin]
      losers = conflicting_plugins - [winner]

      {
        success: true,
        strategy: :interactive,
        winner: winner,
        losers: losers,
        user_choice: true,
        message: "User selected #{winner} for #{conflict_type}"
      }
    end

    def handle_cancel_response
      {
        success: false,
        strategy: :interactive,
        winner: nil,
        error: 'User cancelled conflict resolution',
        message: 'Interactive resolution cancelled by user'
      }
    end

    def generate_namespace(plugin_name)
      # Delegate to PluginNamespace for consistent namespace generation
      priority_type = @priority_system.get_priority(plugin_name)
      plugin_metadata = {
        name: plugin_name,
        priority_type: priority_type
      }
      @namespace_system.generate_namespace(plugin_metadata)
    end

    def similar_plugin_names?(name_a, name_b)
      # Simple similarity check - could be enhanced with more sophisticated algorithms
      similarity = calculate_name_similarity(name_a.to_s, name_b.to_s)
      similarity > 0.7
    end

    def calculate_name_similarity(name_a, name_b)
      # Levenshtein distance-based similarity
      return 1.0 if name_a == name_b
      return 0.0 if name_a.empty? || name_b.empty?

      longer = name_a.length > name_b.length ? name_a : name_b
      shorter = name_a.length > name_b.length ? name_b : name_a

      edit_distance = levenshtein_distance(longer, shorter)
      (longer.length - edit_distance).to_f / longer.length
    end

    def levenshtein_distance(str_a, str_b)
      # Classic dynamic programming implementation
      matrix = Array.new(str_a.length + 1) { Array.new(str_b.length + 1) }

      (0..str_a.length).each { |i| matrix[i][0] = i }
      (0..str_b.length).each { |j| matrix[0][j] = j }

      (1..str_a.length).each do |i|
        (1..str_b.length).each do |j|
          cost = str_a[i - 1] == str_b[j - 1] ? 0 : 1
          matrix[i][j] = [
            matrix[i - 1][j] + 1,     # deletion
            matrix[i][j - 1] + 1,     # insertion
            matrix[i - 1][j - 1] + cost # substitution
          ].min
        end
      end

      matrix[str_a.length][str_b.length]
    end

    def log_conflicts(conflicts)
      conflicts.each do |type, conflict_list|
        conflict_list.each do |conflict|
          @conflict_log << {
            timestamp: Time.now,
            type: type,
            conflict: conflict,
            resolved: false
          }
        end
      end
    end

    def log_resolution(conflict_type, strategy, resolution)
      # Find and update corresponding conflict in log
      @conflict_log.each do |log_entry|
        next unless log_entry[:type].to_s.include?(conflict_type.to_s) && !log_entry[:resolved]

        log_entry[:resolved] = true
        log_entry[:resolution] = {
          strategy: strategy,
          result: resolution,
          resolved_at: Time.now
        }
        break
      end
    end

    def cache_resolution(conflict_type, conflicting_plugins, resolution)
      cache_key = generate_cache_key(conflict_type, conflicting_plugins)
      @resolution_cache[cache_key] = resolution
    end

    def generate_cache_key(conflict_type, conflicting_plugins)
      "#{conflict_type}_#{conflicting_plugins.sort.join('_')}"
    end

    def conflicts_by_type_summary
      summary = Hash.new(0)
      @conflict_log.each { |log_entry| summary[log_entry[:type]] += 1 }
      summary
    end

    def generate_recommendations
      recommendations = []

      # Analyze conflict patterns
      if @conflict_log.count { |log| log[:type] == :command_conflicts } > 3
        recommendations << 'Consider using more specific command names to reduce conflicts'
      end

      recommendations << 'High number of namespace conflicts detected, consider plugin naming conventions' if @namespace_mappings.size > 5

      unresolved_count = @conflict_log.count { |log| !log[:resolved] }
      recommendations << "#{unresolved_count} conflicts remain unresolved" if unresolved_count.positive?

      recommendations.empty? ? ['No specific recommendations'] : recommendations
    end

    def validate_strategy!(strategy)
      return if RESOLUTION_STRATEGIES.key?(strategy)

      raise ArgumentError, "Invalid resolution strategy: #{strategy}. " \
                           "Valid strategies: #{RESOLUTION_STRATEGIES.keys.join(', ')}"
    end
  end
end
