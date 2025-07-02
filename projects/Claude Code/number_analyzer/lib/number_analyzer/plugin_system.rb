# frozen_string_literal: true

require 'yaml'
require 'json'
require 'set'

# Plugin System for NumberAnalyzer
# Enables dynamic loading of statistical analysis plugins
class NumberAnalyzer
  # Core plugin management system
  class PluginSystem
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
    end

    # Register a plugin with the system
    def register_plugin(plugin_name, plugin_class, extension_point: :statistics_module)
      validate_extension_point!(extension_point)

      @plugins[plugin_name] = {
        class: plugin_class,
        extension_point: extension_point,
        loaded: false,
        metadata: extract_plugin_metadata(plugin_class)
      }

      @extension_points[extension_point] << plugin_name
    end

    # Load a specific plugin
    def load_plugin(plugin_name)
      return false unless @plugins.key?(plugin_name)
      return true if @loaded_plugins.include?(plugin_name)

      plugin_info = @plugins[plugin_name]

      # Check dependencies
      return false unless check_dependencies(plugin_info[:metadata][:dependencies])

      # Load the plugin
      plugin_class = plugin_info[:class]
      extension_point = plugin_info[:extension_point]

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

      true
    end

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

    def check_dependencies(dependencies)
      dependencies.all? { |dep| @loaded_plugins.include?(dep) || @plugins.key?(dep) }
    end

    def load_statistics_module(_plugin_name, plugin_class)
      # Dynamically include the statistics module into NumberAnalyzer
      NumberAnalyzer.include(plugin_class) if plugin_class.is_a?(Module)

      # Also register CLI commands if the plugin provides them
      return unless plugin_class.respond_to?(:plugin_commands)

      plugin_class.plugin_commands.each do |command_name, method_name|
        CLI.register_command(command_name, plugin_class, method_name)
      end
    end

    def load_cli_command(_plugin_name, plugin_class)
      # Register CLI commands dynamically
      return unless plugin_class.respond_to?(:plugin_commands)

      plugin_class.plugin_commands.each do |command_name, method_name|
        CLI.register_command(command_name, plugin_class, method_name)
      end
    end

    def load_file_format(plugin_name, plugin_class)
      # Register file format handlers
      FileReader.register_format(plugin_name, plugin_class) if defined?(FileReader)
    end

    def load_output_format(plugin_name, plugin_class)
      # Register output format handlers
      OutputFormatter.register_format(plugin_name, plugin_class) if defined?(OutputFormatter)
    end

    def load_validator(plugin_name, plugin_class)
      # Register data validators
      DataValidator.register_validator(plugin_name, plugin_class) if defined?(DataValidator)
    end
  end
end
