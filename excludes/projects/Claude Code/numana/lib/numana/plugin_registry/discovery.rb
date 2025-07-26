# frozen_string_literal: true

# Plugin discovery functionality
class Numana::PluginRegistry::Discovery
  class << self
    # Discover plugins from configured directories
    def discover_plugins(core)
      core.initialize_registry unless core.plugins

      discovered = {}

      core.plugin_directories.each do |directory|
        next unless Dir.exist?(directory)

        Dir.glob(File.join(directory, '**', '*_plugin.rb')).each do |plugin_file|
          plugin_info = analyze_plugin_file(plugin_file, core)
          next unless plugin_info

          discovered[plugin_info[:name]] = plugin_info.merge(file_path: plugin_file)
        end
      end

      core.instance_variable_set(:@discovery_cache, discovered)
      discovered
    end

    # Load a plugin by name with dependency resolution
    def load_plugin(plugin_name, core)
      core.initialize_registry unless core.plugins
      return true if core.loaded_plugins.include?(plugin_name)

      plugin_info = find_or_discover_plugin(plugin_name, core)
      return false unless plugin_info

      load_dependencies(plugin_info, core)
      perform_plugin_load(plugin_name, plugin_info, core)
    end

    # Add plugin directory for discovery
    def add_plugin_directory(directory, core)
      core.initialize_registry unless core.plugins
      expanded_path = File.expand_path(directory)
      core.plugin_directories << expanded_path unless core.plugin_directories.include?(expanded_path)
    end

    # Remove plugin directory
    def remove_plugin_directory(directory, core)
      core.initialize_registry unless core.plugins
      core.plugin_directories.delete(File.expand_path(directory))
    end

    # Get plugins by category
    def plugins_by_category(category, core)
      core.initialize_registry unless core.plugins
      core.plugins.select do |_, info|
        info[:metadata][:category] == category
      end.keys
    end

    # Get plugins by extension point
    def plugins_by_extension_point(extension_point, core)
      core.initialize_registry unless core.plugins
      core.plugins.select do |_, info|
        info[:extension_point] == extension_point
      end.keys
    end

    private

    def find_or_discover_plugin(plugin_name, core)
      plugin_info = core.plugins[plugin_name]
      unless plugin_info
        # Try to discover the plugin
        discover_plugins(core)
        plugin_info = core.discovery_cache[plugin_name]
        return nil unless plugin_info

        # Load from discovered file
        load_plugin_from_file(plugin_info[:file_path])
        plugin_info = core.plugins[plugin_name]
      end
      plugin_info
    end

    def load_dependencies(plugin_info, core)
      dependencies = plugin_info[:metadata][:dependencies] || []
      dependencies.each do |dep_name|
        raise Numana::PluginRegistry::Core::MissingDependencyError, "Failed to load dependency: #{dep_name}" unless load_plugin(dep_name, core)
      end
    end

    def perform_plugin_load(plugin_name, plugin_info, core)
      load_plugin_instance(plugin_name, plugin_info, core)
      core.loaded_plugins.add(plugin_name)
      true
    rescue StandardError => e
      raise Numana::PluginRegistry::Core::PluginError, "Failed to load plugin #{plugin_name}: #{e.message}"
    end

    def analyze_plugin_file(file_path, core)
      return core.metadata_cache[file_path] if core.metadata_cache.key?(file_path)

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

        core.metadata_cache[file_path] = plugin_info
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

    def load_plugin_instance(_plugin_name, plugin_info, _core)
      plugin_class = plugin_info[:class]
      extension_point = plugin_info[:extension_point]

      case extension_point
      when :statistics_module
        Numana.include(plugin_class) if plugin_class.is_a?(Module)
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
        Numana::CLI.register_command(command_name, plugin_class, method_name) if defined?(Numana::CLI) && Numana::CLI.respond_to?(:register_command)
      end
    end
  end
end
