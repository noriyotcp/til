# frozen_string_literal: true

# Plugin priority management
class Numana::PluginSystem::PriorityManager
  def initialize(core_system)
    @core = core_system
  end

  # Set priority for a plugin
  def set_plugin_priority(plugin_name, priority_level)
    @core.priority_system.set_priority(plugin_name, priority_level)
  end

  # Get priority for a plugin
  def get_plugin_priority(plugin_name)
    @core.priority_system.get_priority(plugin_name)
  end

  # Get priority value for a plugin
  def get_plugin_priority_value(plugin_name)
    @core.priority_system.get_priority_value(plugin_name)
  end

  # Sort plugins by priority
  def sort_plugins_by_priority(plugin_names)
    @core.priority_system.sort_by_priority(plugin_names)
  end

  # Get plugins at specific priority level
  def plugins_at_priority(priority_level)
    @core.priority_system.plugins_at_priority(priority_level)
  end

  # Get priority statistics
  def priority_statistics
    @core.priority_system.priority_statistics
  end

  # Generate priority report
  def generate_priority_report
    @core.priority_system.generate_priority_report
  end

  # Check if plugin A has higher priority than plugin B
  def higher_priority?(plugin_a, plugin_b)
    @core.priority_system.higher_priority?(plugin_a, plugin_b)
  end

  # Get all priority levels
  def all_priority_levels
    @core.priority_system.all_priority_levels
  end

  # Get priority level description
  def priority_description(priority_level)
    @core.priority_system.priority_description(priority_level)
  end
end
