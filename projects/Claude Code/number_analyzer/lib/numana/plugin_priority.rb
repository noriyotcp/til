# frozen_string_literal: true

# Hierarchical plugin priority management system for conflict resolution
#
# This class implements a 5-tier priority system for NumberAnalyzer plugins,
# enabling intelligent conflict resolution and plugin loading order management.
# Priority levels range from development (100) to local_plugins (30).
#
# @example Basic usage with class methods
#   NumberAnalyzer::PluginPriority.get(:core_plugins) # => 90
#   NumberAnalyzer::PluginPriority.set(:my_plugin, 95)
#   NumberAnalyzer::PluginPriority.can_override?(new_plugin, existing_plugin)
#
# @example Instance usage for backward compatibility
#   priority = NumberAnalyzer::PluginPriority.new
#   priority.set_priority_with_auto_detection('plugin_name', metadata)
class NumberAnalyzer::PluginPriority
  # 階層的優先度システム - 数値が高い = 高優先度
  DEFAULT_PRIORITIES = {
    development: 100,     # 開発・テスト用 - 最高優先度（何でも上書き）
    core_plugins: 90,     # 既存8モジュール - 高優先度（保護対象）
    official_gems: 70,    # number_analyzer-* gems - 信頼できるgem
    third_party_gems: 50, # 外部gem - 一般的なサードパーティ
    local_plugins: 30     # プロジェクト内 - 最低優先度
  }.freeze

  @custom_priorities = {}

  # Instance methods for backward compatibility
  def initialize
    @instance_priorities = {}
  end

  def set_priority_with_auto_detection(plugin_name, metadata)
    # Auto-detection logic for backward compatibility
    priority = if metadata[:development] == true
                 :development
               elsif plugin_name.to_s.include?('Core') || metadata[:core] == true
                 :core_plugins
               elsif metadata[:official] == true
                 :official_gems
               elsif metadata[:trusted] == true
                 :third_party_gems
               else
                 :local_plugins
               end

    @instance_priorities[plugin_name] = priority
    priority
  end

  def get_priority(plugin_name)
    @instance_priorities.fetch(plugin_name, :local_plugins)
  end

  # Sort plugin names by their priority in descending order
  #
  # @param plugin_names [Array<String>] Array of plugin names
  # @return [Array<String>] Sorted plugin names (highest priority first)
  def sort_by_priority(plugin_names)
    plugin_names.sort do |a, b|
      priority_a = get_priority_value(get_priority(a))
      priority_b = get_priority_value(get_priority(b))
      priority_b <=> priority_a # Descending order (higher priority first)
    end
  end

  private

  # Get numeric priority value for a priority type
  #
  # @param priority_type [Symbol] Priority type
  # @return [Integer] Numeric priority value
  def get_priority_value(priority_type)
    DEFAULT_PRIORITIES[priority_type] || 0
  end

  # Class methods (new API)
  class << self
    def get(plugin_type)
      @custom_priorities[plugin_type] || DEFAULT_PRIORITIES[plugin_type] || 0
    end

    def set(plugin_type, priority)
      @custom_priorities[plugin_type] = priority
    end

    def can_override?(new_plugin, existing_plugin)
      new_priority = get(new_plugin.type)
      existing_priority = get(existing_plugin.type)
      new_priority > existing_priority
    end

    def reset_custom_priorities!
      @custom_priorities.clear
    end

    def all_priorities
      DEFAULT_PRIORITIES.merge(@custom_priorities)
    end

    # Sort plugin objects by their type priority in descending order
    #
    # @param plugins [Array] Array of plugin objects with .type method
    # @return [Array] Sorted plugin objects (highest priority first)
    def sort_plugins_by_priority(plugins)
      plugins.sort do |a, b|
        priority_a = get(a.type)
        priority_b = get(b.type)
        priority_b <=> priority_a # Descending order (higher priority first)
      end
    end
  end
end
