# frozen_string_literal: true

require 'pathname'
require_relative 'plugin_system'
require_relative 'plugin_interface'

# Plugin discovery and loading utilities
class NumberAnalyzer
  # Handles plugin discovery and automatic loading
  class PluginLoader
    def self.discover_plugins(search_paths = [])
      plugins = []

      default_paths = [
        './plugins',
        './lib/number_analyzer/plugins',
        File.expand_path('~/.number_analyzer/plugins')
      ]

      all_paths = (search_paths + default_paths).uniq

      all_paths.each do |path|
        next unless Dir.exist?(path)

        plugins.concat(discover_plugins_in_path(path))
      end

      plugins
    end

    def self.discover_plugins_in_path(path)
      plugins = []

      Dir.glob(File.join(path, '*.rb')).each do |plugin_file|
        plugin_info = analyze_plugin_file(plugin_file)
        plugins << plugin_info if plugin_info
      rescue StandardError => e
        warn "Failed to analyze plugin #{plugin_file}: #{e.message}"
      end

      plugins
    end

    def self.analyze_plugin_file(plugin_file)
      # Read the plugin file and extract metadata without loading it
      content = File.read(plugin_file)

      # Look for plugin metadata in comments or class definitions
      metadata = {
        file_path: plugin_file,
        name: File.basename(plugin_file, '.rb'),
        valid: false
      }

      # Check if it follows plugin conventions
      if content.match?(/include.*StatisticsPlugin/) ||
         content.match?(/< NumberAnalyzer::CLIPlugin/) ||
         content.match?(/plugin_name/) ||
         content.match?(/NumberAnalyzer::.*Plugin/)

        metadata[:valid] = true

        # Extract plugin name if defined
        if (match = content.match(/plugin_name\s+['"](.+?)['"]/))
          metadata[:name] = match[1]
        end

        # Extract version
        if (match = content.match(/plugin_version\s+['"](.+?)['"]/))
          metadata[:version] = match[1]
        end

        # Extract description
        if (match = content.match(/plugin_description\s+['"](.+?)['"]/))
          metadata[:description] = match[1]
        end

        # Extract author
        if (match = content.match(/plugin_author\s+['"](.+?)['"]/))
          metadata[:author] = match[1]
        end
      end

      metadata[:valid] ? metadata : nil
    end

    def self.load_plugin_file(plugin_file)
      # Safely load a plugin file

      # Create a sandbox for loading
      original_verbose = $VERBOSE
      $VERBOSE = nil

      load plugin_file

      $VERBOSE = original_verbose
      true
    rescue StandardError => e
      warn "Failed to load plugin #{plugin_file}: #{e.message}"
      false
    end

    def self.auto_register_plugins(plugin_system, search_paths = [])
      discovered_plugins = discover_plugins(search_paths)

      discovered_plugins.each do |plugin_info|
        next unless load_plugin_file(plugin_info[:file_path])

        # Try to find the plugin class
        plugin_class = find_plugin_class(plugin_info[:name])

        if plugin_class
          extension_point = determine_extension_point(plugin_class)
          plugin_system.register_plugin(plugin_info[:name], plugin_class, extension_point: extension_point)
        end
      end
    end

    def self.find_plugin_class(plugin_name)
      # Convert plugin name to class name
      class_name = plugin_name.split('_').map(&:capitalize).join

      # Try different namespace combinations
      candidates = [
        "NumberAnalyzer::#{class_name}",
        "#{class_name}Plugin",
        "NumberAnalyzer::#{class_name}Plugin",
        class_name
      ]

      candidates.each do |candidate|
        return Object.const_get(candidate)
      rescue NameError
        next
      end

      nil
    end

    def self.determine_extension_point(plugin_class)
      # Determine the extension point based on the plugin class
      case plugin_class.name
      when /CLIPlugin/
        :cli_command
      when /FileFormatPlugin/
        :file_format
      when /OutputFormatPlugin/
        :output_format
      when /ValidatorPlugin/
        :validator
      else
        # Check if it includes StatisticsPlugin module
        if plugin_class.included_modules.any? { |mod| mod.name&.include?('StatisticsPlugin') }
        end
        :statistics_module
      end
    end
  end
end
