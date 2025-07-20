# frozen_string_literal: true

require 'yaml'
require 'json'
require 'set'
require 'fileutils'

# Centralized Plugin Registry for NumberAnalyzer
# Manages plugin registration, discovery, and metadata validation
# Central registry for managing all plugins in the system
class Numana::PluginRegistry
  class << self
    # Plugin registration errors
    class PluginError < StandardError; end
    class DuplicatePluginError < PluginError; end
    class InvalidPluginError < PluginError; end
    class MissingDependencyError < PluginError; end

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

      validate_plugin_name!(plugin_name)
      validate_plugin_class!(plugin_class)

      if @plugins.key?(plugin_name)
        handle_duplicate_plugin(plugin_name, plugin_class, options)
      else
        register_new_plugin(plugin_name, plugin_class, options)
      end
    end

    # Discover plugins from configured directories
    def discover_plugins
      initialize_registry unless @plugins

      discovered = {}

      @plugin_directories.each do |directory|
        next unless Dir.exist?(directory)

        Dir.glob(File.join(directory, '**', '*_plugin.rb')).each do |plugin_file|
          plugin_info = analyze_plugin_file(plugin_file)
          next unless plugin_info

          discovered[plugin_info[:name]] = plugin_info.merge(file_path: plugin_file)
        end
      end

      @discovery_cache = discovered
      discovered
    end

    # Load a plugin by name with dependency resolution
    def load_plugin(plugin_name)
      initialize_registry unless @plugins

      return true if @loaded_plugins.include?(plugin_name)

      plugin_info = @plugins[plugin_name]
      unless plugin_info
        # Try to discover the plugin
        discover_plugins
        plugin_info = @discovery_cache[plugin_name]
        return false unless plugin_info

        # Load from discovered file
        load_plugin_from_file(plugin_info[:file_path])
        plugin_info = @plugins[plugin_name]
        return false unless plugin_info
      end

      # Load dependencies first
      dependencies = plugin_info[:metadata][:dependencies] || []
      dependencies.each do |dep_name|
        raise MissingDependencyError, "Failed to load dependency: #{dep_name}" unless load_plugin(dep_name)
      end

      # Load the plugin
      begin
        load_plugin_instance(plugin_name, plugin_info)
        @loaded_plugins.add(plugin_name)
        true
      rescue StandardError => e
        raise PluginError, "Failed to load plugin #{plugin_name}: #{e.message}"
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

    # Get plugins by category
    def plugins_by_category(category)
      initialize_registry unless @plugins
      @plugins.select do |_, info|
        info[:metadata][:category] == category
      end.keys
    end

    # Get plugins by extension point
    def plugins_by_extension_point(extension_point)
      initialize_registry unless @plugins
      @plugins.select do |_, info|
        info[:extension_point] == extension_point
      end.keys
    end

    # Add plugin directory for discovery
    def add_plugin_directory(directory)
      initialize_registry unless @plugins
      expanded_path = File.expand_path(directory)
      @plugin_directories << expanded_path unless @plugin_directories.include?(expanded_path)
    end

    # Remove plugin directory
    def remove_plugin_directory(directory)
      initialize_registry unless @plugins
      @plugin_directories.delete(File.expand_path(directory))
    end

    # Get current plugin directories
    def plugin_directories
      initialize_registry unless @plugins
      @plugin_directories.dup
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

    def validate_plugin_name!(name)
      raise InvalidPluginError, 'Plugin name cannot be nil or empty' if name.nil? || name.to_s.strip.empty?
      raise InvalidPluginError, 'Plugin name must be a string or symbol' unless [String, Symbol].include?(name.class)
    end

    def validate_plugin_class!(plugin_class)
      raise InvalidPluginError, 'Plugin class cannot be nil' if plugin_class.nil?
      raise InvalidPluginError, 'Plugin must be a Module or Class' unless plugin_class.is_a?(Module)
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
      validate_metadata!(metadata)

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

    def validate_metadata!(metadata)
      required_fields = %i[name version]
      required_fields.each do |field|
        raise InvalidPluginError, "Plugin metadata missing required field: #{field}" if metadata[field].nil?
      end

      # Validate version format
      unless metadata[:version].match?(/^\d+\.\d+\.\d+/)
        raise InvalidPluginError,
              "Invalid version format: #{metadata[:version]}. Expected semantic versioning (x.y.z)"
      end

      # Validate dependencies format
      dependencies = metadata[:dependencies]
      return unless dependencies && !dependencies.is_a?(Array)

      raise InvalidPluginError, 'Plugin dependencies must be an array'
    end

    def analyze_plugin_file(file_path)
      return @metadata_cache[file_path] if @metadata_cache.key?(file_path)

      begin
        # Read file and extract basic information
        content = File.read(file_path)

        # Extract plugin name from filename or content
        filename = File.basename(file_path, '.rb')
        plugin_name = filename.sub(/_plugin$/, '')

        # Try to extract metadata from comments or code patterns
        metadata = extract_file_metadata(content, plugin_name)

        plugin_info = {
          name: plugin_name,
          metadata: metadata,
          analyzed_at: Time.now
        }

        @metadata_cache[file_path] = plugin_info
        plugin_info
      rescue StandardError => e
        warn "Warning: Failed to analyze plugin file #{file_path}: #{e.message}"
        nil
      end
    end

    def extract_file_metadata(content, default_name)
      {
        name: extract_name_from_content(content) || default_name,
        version: extract_version_from_content(content) || '1.0.0',
        description: extract_description_from_content(content) || '',
        author: extract_author_from_content(content) || 'Unknown',
        dependencies: extract_dependencies_from_content(content) || [],
        category: 'external'
      }
    end

    def extract_name_from_content(content)
      # Look for plugin_name declarations
      content.match(/plugin_name\s+['"]([^'"]+)['"]/)&.captures&.first ||
        content.match(/plugin_name\s+:([a-z_]+)/)&.captures&.first
    end

    def extract_version_from_content(content)
      content.match(/plugin_version\s+['"]([^'"]+)['"]/)&.captures&.first
    end

    def extract_description_from_content(content)
      content.match(/plugin_description\s+['"]([^'"]+)['"]/)&.captures&.first
    end

    def extract_author_from_content(content)
      content.match(/plugin_author\s+['"]([^'"]+)['"]/)&.captures&.first
    end

    def extract_dependencies_from_content(content)
      # Look for dependency declarations
      deps_match = content.match(/plugin_dependencies\s+\[(.*?)\]/m)
      return [] unless deps_match

      deps_string = deps_match.captures.first
      deps_string.scan(/['"]([^'"]+)['"]/).flatten
    end

    def load_plugin_from_file(file_path)
      return false unless File.exist?(file_path)

      begin
        require file_path
        true
      rescue LoadError => e
        warn "Warning: Failed to load plugin file #{file_path}: #{e.message}"
        false
      end
    end

    def load_plugin_instance(_plugin_name, plugin_info)
      plugin_class = plugin_info[:class]
      extension_point = plugin_info[:extension_point]

      case extension_point
      when :statistics_module
        NumberAnalyzer.include(plugin_class) if plugin_class.is_a?(Module)
      when :cli_command
        # CLI command loading will be handled by CLI integration
        register_cli_commands(plugin_class)
      end
    end

    def register_cli_commands(plugin_class)
      return unless plugin_class.respond_to?(:plugin_commands)

      commands = plugin_class.plugin_commands
      return unless commands.is_a?(Hash)

      commands.each do |command_name, method_name|
        # Register with CLI system if available
        if defined?(Numana::CLI) && Numana::CLI.respond_to?(:register_command)
          Numana::CLI.register_command(command_name, plugin_class, method_name)
        end
      end
    end
  end
end
