# frozen_string_literal: true

require 'yaml'
require 'json'
require 'set'
require_relative 'dependency_resolver'
require_relative 'plugin_error_handler'
require_relative 'plugin_priority'

# Plugin System for NumberAnalyzer
# Enables dynamic loading of statistical analysis plugins
# Core plugin management system
class NumberAnalyzer::PluginSystem
  PLUGIN_EXTENSION_POINTS = %i[
    statistics_module
    cli_command
    file_format
    output_format
    validator
  ].freeze

  def initialize
    @plugins = {}
    @loaded_plugins = Set.new
    @extension_points = Hash.new { |h, k| h[k] = [] }
    @config = load_configuration
    @dependency_resolver = NumberAnalyzer::DependencyResolver.new(@plugins)
    @error_handler = NumberAnalyzer::PluginErrorHandler.new
    @priority_system = NumberAnalyzer::PluginPriority.new
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
    @dependency_resolver = NumberAnalyzer::DependencyResolver.new(@plugins)
  end

  # Load a specific plugin with enhanced dependency resolution and error handling
  def load_plugin(plugin_name)
    return false unless @plugins.key?(plugin_name)
    return true if @loaded_plugins.include?(plugin_name)
    return false if @error_handler.plugin_disabled?(plugin_name)

    context = { plugin_name: plugin_name, operation: :load }

    begin
      # Resolve dependencies with circular dependency detection
      required_plugins = @dependency_resolver.resolve(plugin_name, check_versions: true)

      # Load dependencies first
      required_plugins.each do |dep_name|
        next if dep_name == plugin_name || @loaded_plugins.include?(dep_name)

        load_plugin_internal(dep_name)
      end

      # Load the plugin itself
      load_plugin_internal(plugin_name)

      true
    rescue NumberAnalyzer::DependencyResolver::CircularDependencyError => e
      @error_handler.handle_error(e, context.merge(recovery_strategy: :disable))
      false
    rescue NumberAnalyzer::DependencyResolver::UnresolvedDependencyError => e
      @error_handler.handle_error(e, context.merge(recovery_strategy: :disable))
      false
    rescue NumberAnalyzer::DependencyResolver::VersionConflictError => e
      recovery = @error_handler.handle_error(e, context.merge(recovery_strategy: :fallback))

      if recovery[:action] == :fallback && recovery[:fallback_plugin]
        load_plugin(recovery[:fallback_plugin])
      else
        false
      end
    rescue LoadError => e
      recovery = @error_handler.handle_error(e, context.merge(recovery_strategy: :disable))

      case recovery[:action]
      when :retry
        retry
      when :fallback
        recovery[:fallback_plugin] ? load_plugin(recovery[:fallback_plugin]) : false
      else
        false
      end
    rescue StandardError => e
      recovery = @error_handler.handle_error(e, context)

      case recovery[:action]
      when :retry
        retry
      when :fallback
        recovery[:fallback_plugin] ? load_plugin(recovery[:fallback_plugin]) : false
      else
        false
      end
    end
  end

  private

  # Internal plugin loading without dependency resolution
  def load_plugin_internal(plugin_name)
    plugin_info = @plugins[plugin_name]
    plugin_class = plugin_info[:class]
    extension_point = plugin_info[:extension_point]

    { plugin_name: plugin_name, operation: :load_internal }

    begin
      case extension_point
      when :statistics_module
        load_statistics_module(plugin_name, plugin_class)
      when :cli_command
        load_cli_command(plugin_name, plugin_class)
      when :file_format
        load_file_format(plugin_name, plugin_class)
      when :output_format
        load_output_format(plugin_name, plugin_class)
      when :validator
        load_validator(plugin_name, plugin_class)
      end

      @loaded_plugins.add(plugin_name)
      @plugins[plugin_name][:loaded] = true
      @error_handler.enable_plugin(plugin_name)
    rescue StandardError => e
      # Let the outer load_plugin method handle the error
      raise e
    end
  end

  public

  # Load all enabled plugins from configuration
  def load_enabled_plugins
    enabled_plugins = @config.dig('plugins', 'enabled') || []

    enabled_plugins.each { |plugin_name| load_plugin(plugin_name) }
  end

  # Get all plugins for a specific extension point
  def plugins_for(extension_point)
    @extension_points[extension_point].filter_map do |plugin_name|
      @plugins[plugin_name] if @loaded_plugins.include?(plugin_name)
    end
  end

  # Check if a plugin is loaded
  def plugin_loaded?(plugin_name) = @loaded_plugins.include?(plugin_name)

  # List all available plugins
  def available_plugins = @plugins.keys

  # List all loaded plugins
  def loaded_plugins = @loaded_plugins.to_a

  # Get plugin metadata
  def plugin_metadata(plugin_name) = @plugins.dig(plugin_name, :metadata)

  # Check if a plugin has satisfied dependencies
  def dependencies_satisfied?(plugin_name)
    @dependency_resolver.dependencies_satisfied?(plugin_name)
  end

  # Get missing dependencies for a plugin
  def missing_dependencies(plugin_name)
    @dependency_resolver.missing_dependencies(plugin_name)
  end

  # Register a fallback plugin
  def register_fallback(plugin_name, fallback_plugin_name)
    @error_handler.register_fallback(plugin_name, fallback_plugin_name)
  end

  # Get plugin health status
  def plugin_health_check
    available_plugins.each_with_object({}) do |plugin_name, health|
      health[plugin_name] = {
        loaded: plugin_loaded?(plugin_name),
        disabled: @error_handler.plugin_disabled?(plugin_name),
        dependencies_satisfied: dependencies_satisfied?(plugin_name),
        missing_dependencies: missing_dependencies(plugin_name),
        errors: @error_handler.error_statistics[:errors_by_plugin][plugin_name] || 0
      }
    end
  end

  # Generate error report
  def error_report
    PluginErrorReport.generate(@error_handler)
  end

  # Clear error history
  def clear_errors
    @error_handler.clear_errors
  end

  # Re-enable a disabled plugin
  def enable_plugin(plugin_name)
    @error_handler.enable_plugin(plugin_name)
  end

  # Load multiple plugins with dependency resolution
  def load_plugins(*plugin_names)
    # Resolve all dependencies together
    all_required = @dependency_resolver.resolve_multiple(plugin_names)

    success_count = 0
    all_required.each do |plugin_name|
      success_count += 1 if load_plugin(plugin_name)
    end

    success_count
  end

  # Priority system integration methods

  # Set priority for a plugin
  def set_plugin_priority(plugin_name, priority_level)
    @priority_system.set_priority(plugin_name, priority_level)
  end

  # Get priority for a plugin
  def get_plugin_priority(plugin_name)
    @priority_system.get_priority(plugin_name)
  end

  # Get priority value for a plugin
  def get_plugin_priority_value(plugin_name)
    @priority_system.get_priority_value(plugin_name)
  end

  # Sort plugins by priority
  def sort_plugins_by_priority(plugin_names)
    @priority_system.sort_by_priority(plugin_names)
  end

  # Get plugins at specific priority level
  def plugins_at_priority(priority_level)
    @priority_system.plugins_at_priority(priority_level)
  end

  # Get priority statistics
  def priority_statistics
    @priority_system.priority_statistics
  end

  # Generate priority report
  def generate_priority_report
    @priority_system.generate_priority_report
  end

  # Check if plugin A has higher priority than plugin B
  def higher_priority?(plugin_a, plugin_b)
    @priority_system.higher_priority?(plugin_a, plugin_b)
  end

  # Get all priority levels
  def all_priority_levels
    @priority_system.all_priority_levels
  end

  # Get priority level description
  def priority_description(priority_level)
    @priority_system.priority_description(priority_level)
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

  def load_statistics_module(_plugin_name, plugin_class)
    # Dynamically include the statistics module into NumberAnalyzer
    NumberAnalyzer.include(plugin_class) if plugin_class.is_a?(Module)

    # Also register CLI commands if the plugin provides them
    return unless plugin_class.respond_to?(:plugin_commands)

    plugin_class.plugin_commands.each do |command_name, method_name|
      NumberAnalyzer::CLI.register_command(command_name, plugin_class, method_name)
    end
  end

  def load_cli_command(_plugin_name, plugin_class)
    # Register CLI commands dynamically
    return unless plugin_class.respond_to?(:plugin_commands)

    plugin_class.plugin_commands.each do |command_name, method_name|
      NumberAnalyzer::CLI.register_command(command_name, plugin_class, method_name)
    end
  end

  def load_file_format(plugin_name, plugin_class)
    # Register file format handlers
    NumberAnalyzer::FileReader.register_format(plugin_name, plugin_class) if defined?(NumberAnalyzer::FileReader)
  end

  def load_output_format(plugin_name, plugin_class)
    # OutputFormatter was removed in Phase 4 refactoring (migrated to FormattingUtils + Presenter Pattern)
    # The register_format method was never implemented - this was a latent bug from initial plugin system design
    # Future plugin-based output formatting should be designed with FormattingUtils-based architecture
    # For now, output format plugins are not supported
  end

  def load_validator(plugin_name, plugin_class)
    # Register data validators
    NumberAnalyzer::DataValidator.register_validator(plugin_name, plugin_class) if defined?(NumberAnalyzer::DataValidator)
  end
end
