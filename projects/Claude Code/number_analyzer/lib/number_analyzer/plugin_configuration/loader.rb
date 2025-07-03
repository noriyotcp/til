# frozen_string_literal: true

require_relative 'base'
require_relative 'validator'

# Configuration loading and saving for NumberAnalyzer plugin system
class NumberAnalyzer
  module PluginConfiguration
    # Handles loading and saving of configuration files
    class Loader
      include Base

      class << self
        # Load configuration from multiple sources
        def load_configuration(config_paths = nil)
          config_paths ||= PluginConfiguration.default_config_paths
          merged_config = PluginConfiguration::DEFAULT_CONFIG.dup

          config_paths.each do |config_path|
            next unless File.exist?(config_path)

            begin
              file_config = YAML.load_file(config_path) || {}
              merged_config = PluginConfiguration.deep_merge(merged_config, file_config)
            rescue StandardError => e
              warn "Warning: Failed to load configuration from #{config_path}: #{e.message}"
            end
          end

          Validator.validate_configuration!(merged_config)
          PluginConfiguration.normalize_configuration(merged_config)
        end

        # Save configuration to file
        def save_configuration(config, config_path = nil)
          config_path ||= PluginConfiguration.default_config_paths.first
          Validator.validate_configuration!(config)

          FileUtils.mkdir_p(File.dirname(config_path))
          File.write(config_path, YAML.dump(config))
        end

        # Get plugin-specific configuration
        def plugin_config(plugin_name, global_config = nil)
          global_config ||= load_configuration
          plugin_specific = global_config.dig('plugin_config', plugin_name) || {}

          # Merge with default plugin settings
          PluginConfiguration.default_plugin_config.merge(plugin_specific)
        end

        # Set plugin-specific configuration
        def set_plugin_config(plugin_name, plugin_config, global_config = nil)
          global_config ||= load_configuration
          global_config['plugin_config'] ||= {}
          global_config['plugin_config'][plugin_name] = plugin_config

          save_configuration(global_config)
        end
      end
    end
  end
end
