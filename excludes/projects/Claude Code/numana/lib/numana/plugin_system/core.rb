# frozen_string_literal: true

require 'yaml'
require 'set'
require_relative '../dependency_resolver'
require_relative '../plugin_error_handler'
require_relative '../plugin_priority'

# Core Plugin System for NumberAnalyzer
# Main orchestrator for plugin management
class Numana::PluginSystem::Core
  PLUGIN_EXTENSION_POINTS = %i[
    statistics_module
    cli_command
    file_format
    output_format
    validator
  ].freeze

  attr_reader :plugins, :extension_points, :dependency_resolver, :error_handler, :priority_system, :health_monitor, :loaded_plugins

  def initialize
    @plugins = {}
    @loaded_plugins = Set.new
    @extension_points = Hash.new { |h, k| h[k] = [] }
    @config = load_configuration
    @dependency_resolver = Numana::DependencyResolver.new(@plugins)
    @error_handler = Numana::PluginErrorHandler.new
    @priority_system = Numana::PluginPriority.new
    @loader = Numana::PluginSystem::Loader.new(self)
    @health_monitor = Numana::PluginSystem::HealthMonitor.new(self)
  end

  # Register a plugin with the system
  def register_plugin(plugin_name, plugin_class, extension_point: :statistics_module)
    validate_extension_point!(extension_point)

    metadata = extract_plugin_metadata(plugin_class)

    @plugins[plugin_name] = {
      class: plugin_class,
      extension_point: extension_point,
      loaded: false,
      metadata: metadata
    }

    @extension_points[extension_point] << plugin_name

    # Auto-detect and set priority based on plugin metadata
    @priority_system.set_priority_with_auto_detection(plugin_name, metadata)

    # Update the dependency resolver with the new registry state
    @dependency_resolver = Numana::DependencyResolver.new(@plugins)
  end

  # Load a specific plugin with enhanced dependency resolution and error handling
  def load_plugin(plugin_name)
    @loader.load_plugin(plugin_name)
  end

  # Load all enabled plugins from configuration
  def load_enabled_plugins
    enabled_plugins = @config.dig('plugins', 'enabled') || []
    enabled_plugins.each { |plugin_name| load_plugin(plugin_name) }
  end

  # Load multiple plugins with dependency resolution
  def load_plugins(*plugin_names)
    @loader.load_plugins(*plugin_names)
  end

  # Get all plugins for a specific extension point
  def plugins_for(extension_point)
    @extension_points[extension_point].filter_map do |plugin_name|
      @plugins[plugin_name] if @loaded_plugins.include?(plugin_name)
    end
  end

  # Basic status methods
  def plugin_loaded?(plugin_name) = @loaded_plugins.include?(plugin_name)
  def available_plugins = @plugins.keys
  def loaded_plugins_list = @loaded_plugins.to_a
  def plugin_metadata(plugin_name) = @plugins.dig(plugin_name, :metadata)

  # Health monitoring
  def plugin_health_check
    @health_monitor.plugin_health_check
  end

  def error_report
    @health_monitor.error_report
  end

  def clear_errors
    @error_handler.clear_errors
  end

  def enable_plugin(plugin_name)
    @error_handler.enable_plugin(plugin_name)
  end

  private

  def load_configuration
    config_file = File.join(Dir.pwd, 'plugins.yml')
    return {} unless File.exist?(config_file)

    YAML.load_file(config_file) || {}
  rescue StandardError
    {}
  end

  def validate_extension_point!(extension_point)
    return if PLUGIN_EXTENSION_POINTS.include?(extension_point)

    raise ArgumentError, "Invalid extension point: #{extension_point}. " \
                         "Valid points: #{PLUGIN_EXTENSION_POINTS.join(', ')}"
  end

  def extract_plugin_metadata(plugin_class)
    {
      name: plugin_class.respond_to?(:plugin_name) ? plugin_class.plugin_name : plugin_class.name,
      version: plugin_class.respond_to?(:plugin_version) ? plugin_class.plugin_version : '1.0.0',
      description: plugin_class.respond_to?(:plugin_description) ? plugin_class.plugin_description : '',
      author: plugin_class.respond_to?(:plugin_author) ? plugin_class.plugin_author : 'Unknown',
      dependencies: plugin_class.respond_to?(:plugin_dependencies) ? plugin_class.plugin_dependencies : [],
      commands: plugin_class.respond_to?(:plugin_commands) ? plugin_class.plugin_commands : []
    }
  end
end
