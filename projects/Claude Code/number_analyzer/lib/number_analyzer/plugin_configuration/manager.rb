# frozen_string_literal: true

require_relative 'loader'

# Plugin management for NumberAnalyzer plugin system
class NumberAnalyzer
  module PluginConfiguration
    # Handles plugin enable/disable and status checks
    class Manager
      class << self
        # Enable a plugin
        def enable_plugin(plugin_name, config_path = nil)
          config = Loader.load_configuration
          config['plugins']['enabled'] ||= []
          config['plugins']['disabled'] ||= []

          # Remove from disabled list
          config['plugins']['disabled'].delete(plugin_name)

          # Add to enabled list if not already present
          config['plugins']['enabled'] << plugin_name unless config['plugins']['enabled'].include?(plugin_name)

          Loader.save_configuration(config, config_path)
        end

        # Disable a plugin
        def disable_plugin(plugin_name, config_path = nil)
          config = Loader.load_configuration
          config['plugins']['enabled'] ||= []
          config['plugins']['disabled'] ||= []

          # Remove from enabled list
          config['plugins']['enabled'].delete(plugin_name)

          # Add to disabled list if not already present
          config['plugins']['disabled'] << plugin_name unless config['plugins']['disabled'].include?(plugin_name)

          Loader.save_configuration(config, config_path)
        end

        # Check if plugin is enabled
        def plugin_enabled?(plugin_name, config = nil)
          config ||= Loader.load_configuration
          enabled_plugins = config.dig('plugins', 'enabled') || []
          disabled_plugins = config.dig('plugins', 'disabled') || []

          # Explicit disable overrides enable
          return false if disabled_plugins.include?(plugin_name)

          # Check if explicitly enabled or auto-discovery is on
          enabled_plugins.include?(plugin_name) || config.dig('plugins', 'auto_discovery')
        end

        # Get all enabled plugins
        def enabled_plugins(config = nil)
          config ||= Loader.load_configuration
          config.dig('plugins', 'enabled') || []
        end

        # Get all disabled plugins
        def disabled_plugins(config = nil)
          config ||= Loader.load_configuration
          config.dig('plugins', 'disabled') || []
        end

        # Get plugin paths
        def plugin_paths(config = nil)
          config ||= Loader.load_configuration
          config.dig('plugins', 'paths') || PluginConfiguration::DEFAULT_CONFIG['plugins']['paths']
        end
      end
    end
  end
end
