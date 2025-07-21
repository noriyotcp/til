# frozen_string_literal: true

# Plugin System for NumberAnalyzer
# Main interface that delegates to core components
class Numana::PluginSystem
  # Implementation added after require statements to resolve circular dependencies
end

require_relative 'plugin_system/core'
require_relative 'plugin_system/loader'
require_relative 'plugin_system/health_monitor'
require_relative 'plugin_system/priority_manager'

# Reopen class to add implementation
class Numana::PluginSystem
  def initialize
    @core = Numana::PluginSystem::Core.new
    @priority_manager = Numana::PluginSystem::PriorityManager.new(@core)
  end

  # Delegate core functionality
  def register_plugin(plugin_name, plugin_class, extension_point: :statistics_module)
    @core.register_plugin(plugin_name, plugin_class, extension_point: extension_point)
  end

  def load_plugin(plugin_name)
    @core.load_plugin(plugin_name)
  end

  def load_enabled_plugins
    @core.load_enabled_plugins
  end

  def load_plugins(*plugin_names)
    @core.load_plugins(*plugin_names)
  end

  def plugins_for(extension_point)
    @core.plugins_for(extension_point)
  end

  def plugin_loaded?(plugin_name)
    @core.plugin_loaded?(plugin_name)
  end

  def available_plugins
    @core.available_plugins
  end

  def loaded_plugins
    @core.loaded_plugins_list
  end

  def plugin_metadata(plugin_name)
    @core.plugin_metadata(plugin_name)
  end

  def plugin_health_check
    @core.plugin_health_check
  end

  def error_report
    @core.error_report
  end

  def clear_errors
    @core.clear_errors
  end

  def enable_plugin(plugin_name)
    @core.enable_plugin(plugin_name)
  end

  # Delegate health monitoring functionality
  def dependencies_satisfied?(plugin_name)
    @core.health_monitor.dependencies_satisfied?(plugin_name)
  end

  def missing_dependencies(plugin_name)
    @core.health_monitor.missing_dependencies(plugin_name)
  end

  def register_fallback(plugin_name, fallback_plugin_name)
    @core.health_monitor.register_fallback(plugin_name, fallback_plugin_name)
  end

  # Delegate priority system functionality
  def set_plugin_priority(plugin_name, priority_level)
    @priority_manager.set_plugin_priority(plugin_name, priority_level)
  end

  def get_plugin_priority(plugin_name)
    @priority_manager.get_plugin_priority(plugin_name)
  end

  def get_plugin_priority_value(plugin_name)
    @priority_manager.get_plugin_priority_value(plugin_name)
  end

  def sort_plugins_by_priority(plugin_names)
    @priority_manager.sort_plugins_by_priority(plugin_names)
  end

  def plugins_at_priority(priority_level)
    @priority_manager.plugins_at_priority(priority_level)
  end

  def priority_statistics
    @priority_manager.priority_statistics
  end

  def generate_priority_report
    @priority_manager.generate_priority_report
  end

  def higher_priority?(plugin_a, plugin_b)
    @priority_manager.higher_priority?(plugin_a, plugin_b)
  end

  def all_priority_levels
    @priority_manager.all_priority_levels
  end

  def priority_description(priority_level)
    @priority_manager.priority_description(priority_level)
  end
end
