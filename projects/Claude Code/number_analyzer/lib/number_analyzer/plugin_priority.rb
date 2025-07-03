# frozen_string_literal: true

# Plugin Priority System for NumberAnalyzer
# Manages hierarchical plugin priority levels for conflict resolution
class NumberAnalyzer
  # Hierarchical plugin priority management system
  #
  # This class implements a 5-tier priority system for NumberAnalyzer plugins,
  # enabling intelligent conflict resolution and plugin loading order management.
  # Priority levels range from development (100) to local (30), with automatic
  # detection based on plugin metadata and naming conventions.
  #
  # @example Basic usage
  #   priority = PluginPriority.new
  #   priority.set_priority('my_plugin', :core)
  #   priority.get_priority('my_plugin') # => :core
  #
  # @example Auto-detection
  #   metadata = { author: 'NumberAnalyzer Team', name: 'Official Plugin' }
  #   detected = priority.auto_detect_priority('official_plugin', metadata) # => :official
  #
  # @example Priority comparison
  #   plugins = ['plugin_a', 'plugin_b', 'plugin_c']
  #   sorted = priority.sort_by_priority(plugins) # Highest priority first
  class PluginPriority
    # Priority levels for different plugin types
    PRIORITY_LEVELS = {
      development: 100,  # Development/debugging plugins (highest priority)
      core: 90,          # Core NumberAnalyzer plugins
      official: 70,      # Official NumberAnalyzer ecosystem plugins
      third_party: 50,   # Third-party plugins from trusted sources
      local: 30          # Local/user-created plugins (lowest priority)
    }.freeze

    # Default priority for plugins without explicit priority
    DEFAULT_PRIORITY = PRIORITY_LEVELS[:local]

    # Priority level descriptions
    PRIORITY_DESCRIPTIONS = {
      development: 'Development/debugging plugins with highest priority',
      core: 'Core NumberAnalyzer plugins built into the system',
      official: 'Official plugins from the NumberAnalyzer ecosystem',
      third_party: 'Third-party plugins from trusted external sources',
      local: 'Local or user-created plugins with lowest priority'
    }.freeze

    def initialize
      @plugin_priorities = {}
      @priority_groups = Hash.new { |h, k| h[k] = [] }
    end

    # Set priority for a plugin
    def set_priority(plugin_name, priority_level)
      validate_priority_level!(priority_level)

      # Remove from previous priority group if exists
      remove_from_priority_groups(plugin_name)

      # Set new priority
      @plugin_priorities[plugin_name] = priority_level
      @priority_groups[priority_level] << plugin_name
    end

    # Get priority for a plugin
    def get_priority(plugin_name)
      @plugin_priorities.fetch(plugin_name, :local)
    end

    # Get priority level as numeric value
    def get_priority_value(plugin_name)
      priority_level = get_priority(plugin_name)
      PRIORITY_LEVELS[priority_level]
    end

    # Auto-detect priority based on plugin metadata
    def auto_detect_priority(plugin_name, plugin_metadata)
      # Check if it's a development plugin (highest priority)
      return :development if development_plugin?(plugin_metadata)

      # Check if it's an official plugin (before core to be more specific)
      return :official if official_plugin?(plugin_metadata)

      # Check if it's a core plugin
      return :core if core_plugin?(plugin_name, plugin_metadata)

      # Check if it's a trusted third-party plugin
      return :third_party if third_party_plugin?(plugin_metadata)

      # Default to local
      :local
    end

    # Set priority with auto-detection
    def set_priority_with_auto_detection(plugin_name, plugin_metadata)
      detected_priority = auto_detect_priority(plugin_name, plugin_metadata)
      set_priority(plugin_name, detected_priority)
      detected_priority
    end

    # Compare two plugins by priority
    def compare_priority(plugin_a, plugin_b)
      priority_a = get_priority_value(plugin_a)
      priority_b = get_priority_value(plugin_b)

      priority_b <=> priority_a # Higher priority first
    end

    # Sort plugins by priority (highest first)
    def sort_by_priority(plugin_names)
      plugin_names.sort { |a, b| compare_priority(a, b) }
    end

    # Get all plugins at a specific priority level
    def plugins_at_priority(priority_level)
      validate_priority_level!(priority_level)
      @priority_groups[priority_level].dup
    end

    # Get plugins with higher priority than given plugin
    def higher_priority_plugins(plugin_name)
      current_priority = get_priority_value(plugin_name)

      @plugin_priorities.select do |_, priority_level|
        PRIORITY_LEVELS[priority_level] > current_priority
      end.keys
    end

    # Get plugins with lower priority than given plugin
    def lower_priority_plugins(plugin_name)
      current_priority = get_priority_value(plugin_name)

      @plugin_priorities.select do |_, priority_level|
        PRIORITY_LEVELS[priority_level] < current_priority
      end.keys
    end

    # Check if plugin A has higher priority than plugin B
    def higher_priority?(plugin_a, plugin_b)
      get_priority_value(plugin_a) > get_priority_value(plugin_b)
    end

    # Get priority distribution summary
    def priority_distribution
      distribution = Hash.new(0)

      @plugin_priorities.each_value do |priority_level|
        distribution[priority_level] += 1
      end

      # Add empty priority levels
      PRIORITY_LEVELS.each_key do |level|
        distribution[level] ||= 0
      end

      distribution
    end

    # Get priority statistics
    def priority_statistics
      total_plugins = @plugin_priorities.size

      {
        total_plugins: total_plugins,
        priority_distribution: priority_distribution,
        highest_priority: highest_priority_plugins,
        lowest_priority: lowest_priority_plugins,
        priority_groups: @priority_groups.transform_values(&:size)
      }
    end

    # Get plugins with highest priority
    def highest_priority_plugins
      return [] if @plugin_priorities.empty?

      max_priority = @plugin_priorities.values.map { |level| PRIORITY_LEVELS[level] }.max
      @plugin_priorities.select { |_, level| PRIORITY_LEVELS[level] == max_priority }.keys
    end

    # Get plugins with lowest priority
    def lowest_priority_plugins
      return [] if @plugin_priorities.empty?

      min_priority = @plugin_priorities.values.map { |level| PRIORITY_LEVELS[level] }.min
      @plugin_priorities.select { |_, level| PRIORITY_LEVELS[level] == min_priority }.keys
    end

    # Reset all priorities
    def reset_priorities
      @plugin_priorities.clear
      @priority_groups.clear
    end

    # Remove plugin from priority system
    def remove_plugin(plugin_name)
      return unless @plugin_priorities.key?(plugin_name)

      remove_from_priority_groups(plugin_name)
      @plugin_priorities.delete(plugin_name)
    end

    # Check if priority level is valid
    def valid_priority_level?(priority_level)
      PRIORITY_LEVELS.key?(priority_level)
    end

    # Get all priority levels
    def all_priority_levels
      PRIORITY_LEVELS.keys
    end

    # Get priority level description
    def priority_description(priority_level)
      PRIORITY_DESCRIPTIONS[priority_level] || 'Unknown priority level'
    end

    # Generate priority report
    def generate_priority_report
      report = {
        title: 'Plugin Priority Report',
        generated_at: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        total_plugins: @plugin_priorities.size,
        priority_levels: {}
      }

      PRIORITY_LEVELS.each do |level, value|
        plugins_at_level = plugins_at_priority(level)
        report[:priority_levels][level] = {
          numeric_value: value,
          description: priority_description(level),
          plugin_count: plugins_at_level.size,
          plugins: plugins_at_level
        }
      end

      report
    end

    private

    def validate_priority_level!(priority_level)
      return if valid_priority_level?(priority_level)

      raise ArgumentError, "Invalid priority level: #{priority_level}. " \
                           "Valid levels: #{PRIORITY_LEVELS.keys.join(', ')}"
    end

    def remove_from_priority_groups(plugin_name)
      @priority_groups.each_value do |plugins|
        plugins.delete(plugin_name)
      end
    end

    def core_plugin?(plugin_name, plugin_metadata)
      # Core plugins are typically in the NumberAnalyzer::Statistics namespace
      plugin_name.to_s.start_with?('NumberAnalyzer::') ||
        plugin_metadata[:name]&.include?('Core')
    end

    def official_plugin?(plugin_metadata)
      # Official plugins have specific markers (more specific than core)
      plugin_metadata[:author]&.include?('NumberAnalyzer Team') ||
        plugin_metadata[:repository]&.include?('number-analyzer/plugins') ||
        plugin_metadata[:official] == true
    end

    def development_plugin?(plugin_metadata)
      # Development plugins are typically marked as such
      plugin_metadata[:development] == true ||
        plugin_metadata[:environment] == 'development' ||
        plugin_metadata[:debug] == true
    end

    def third_party_plugin?(plugin_metadata)
      # Third-party plugins from trusted sources
      trusted_authors = %w[
        statistical-ruby
        data-analysis-tools
        science-ruby
        ml-ruby
      ]

      trusted_authors.any? { |author| plugin_metadata[:author]&.include?(author) }
    end
  end
end
