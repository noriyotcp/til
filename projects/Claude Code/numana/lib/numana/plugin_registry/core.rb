# frozen_string_literal: true

require 'yaml'
require 'json'
require 'set'
require 'fileutils'
require_relative 'discovery'
require_relative 'validator'

# Core Plugin Registry for Numana
# Manages plugin registration and basic operations
class Numana::PluginRegistry::Core
  class << self
    # Plugin registration errors
    class PluginError < StandardError; end
    class DuplicatePluginError < PluginError; end
    class InvalidPluginError < PluginError; end
    class MissingDependencyError < PluginError; end

    attr_reader :plugins, :plugin_directories, :discovery_cache, :metadata_cache

    # Initialize registry state
    def initialize_registry
      @plugins = {}
      @loaded_plugins = Set.new
      @plugin_directories = default_plugin_directories
      @discovery_cache = {}
      @metadata_cache = {}
    end

    # Register a plugin with metadata validation
    def register(plugin_name, plugin_class, options = {})
      initialize_registry unless @plugins

      Numana::PluginRegistry::Validator.validate_plugin_name!(plugin_name)
      Numana::PluginRegistry::Validator.validate_plugin_class!(plugin_class)

      if @plugins.key?(plugin_name)
        handle_duplicate_plugin(plugin_name, plugin_class, options)
      else
        register_new_plugin(plugin_name, plugin_class, options)
      end
    end

    # Get all registered plugins
    def all_plugins
      initialize_registry unless @plugins
      @plugins.keys
    end

    # Get all loaded plugins
    def loaded_plugins
      initialize_registry unless @plugins
      @loaded_plugins.to_a
    end

    # Get plugin metadata
    def plugin_metadata(plugin_name)
      initialize_registry unless @plugins
      @plugins.dig(plugin_name, :metadata)
    end

    # Check if plugin is registered
    def registered?(plugin_name)
      initialize_registry unless @plugins
      @plugins.key?(plugin_name)
    end

    # Check if plugin is loaded
    def loaded?(plugin_name)
      initialize_registry unless @plugins
      @loaded_plugins.include?(plugin_name)
    end

    # Get plugin information
    def plugin_info(plugin_name)
      initialize_registry unless @plugins
      return nil unless @plugins.key?(plugin_name)

      info = @plugins[plugin_name].dup
      info[:loaded] = @loaded_plugins.include?(plugin_name)
      info
    end

    # Clear all registrations (for testing)
    def clear!
      @plugins&.clear
      @loaded_plugins&.clear
      @discovery_cache&.clear
      @metadata_cache&.clear
    end

    # Generate plugin status report
    def status_report
      initialize_registry unless @plugins

      {
        total_plugins: @plugins.size,
        loaded_plugins: @loaded_plugins.size,
        discovery_cache: @discovery_cache.size,
        plugin_directories: @plugin_directories.size,
        plugins_by_status: {
          loaded: @loaded_plugins.to_a,
          registered: @plugins.keys - @loaded_plugins.to_a,
          discovered: @discovery_cache.keys - @plugins.keys
        }
      }
    end

    private

    def default_plugin_directories
      [
        File.join(Dir.pwd, 'plugins'),
        File.join(Dir.pwd, 'lib', 'number_analyzer', 'plugins'),
        File.expand_path('~/.number_analyzer/plugins')
      ].select { |dir| Dir.exist?(dir) }
    end

    def handle_duplicate_plugin(plugin_name, plugin_class, options)
      existing_plugin = @plugins[plugin_name]

      # Allow re-registration of the same class
      return if existing_plugin[:class] == plugin_class

      # Check if override is explicitly allowed
      raise DuplicatePluginError, "Plugin '#{plugin_name}' is already registered" unless options[:override]

      register_new_plugin(plugin_name, plugin_class, options)
    end

    def register_new_plugin(plugin_name, plugin_class, options)
      metadata = extract_metadata(plugin_class)
      Numana::PluginRegistry::Validator.validate_metadata!(metadata)

      @plugins[plugin_name] = {
        class: plugin_class,
        extension_point: options.fetch(:extension_point, :statistics_module),
        metadata: metadata,
        options: options,
        registered_at: Time.now
      }
    end

    def extract_metadata(plugin_class)
      {
        name: extract_plugin_attribute(plugin_class, :plugin_name) || plugin_class.name,
        version: extract_plugin_attribute(plugin_class, :plugin_version) || '1.0.0',
        description: extract_plugin_attribute(plugin_class, :plugin_description) || '',
        author: extract_plugin_attribute(plugin_class, :plugin_author) || 'Unknown',
        dependencies: extract_plugin_attribute(plugin_class, :plugin_dependencies) || [],
        commands: extract_plugin_attribute(plugin_class, :plugin_commands) || {},
        category: extract_plugin_attribute(plugin_class, :plugin_category) || 'general',
        compatibility: extract_plugin_attribute(plugin_class, :plugin_compatibility) || ['1.0.0']
      }
    end

    def extract_plugin_attribute(plugin_class, attribute)
      return plugin_class.public_send(attribute) if plugin_class.respond_to?(attribute)
      return plugin_class.instance_variable_get("@#{attribute}") if plugin_class.instance_variable_defined?("@#{attribute}")

      nil
    end
  end
end
