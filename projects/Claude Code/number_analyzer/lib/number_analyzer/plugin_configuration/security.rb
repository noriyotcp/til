# frozen_string_literal: true

require_relative 'loader'

# Security settings management for NumberAnalyzer plugin system
class NumberAnalyzer
  module PluginConfiguration
    # Handles security settings and permissions
    class Security
      class << self
        # Get security settings for a plugin
        def security_settings(plugin_name = nil, config = nil)
          config ||= Loader.load_configuration
          global_security = config['security'] || {}

          return global_security unless plugin_name

          # Plugin-specific security overrides
          plugin_specific = Loader.plugin_config(plugin_name, config)
          plugin_security = plugin_specific['security'] || {}

          global_security.merge(plugin_security)
        end

        # Get performance settings for a plugin
        def performance_settings(plugin_name = nil, config = nil)
          config ||= Loader.load_configuration
          global_performance = config['performance'] || {}

          return global_performance unless plugin_name

          # Plugin-specific performance overrides
          plugin_specific = Loader.plugin_config(plugin_name, config)
          plugin_performance = plugin_specific['performance'] || {}

          global_performance.merge(plugin_performance)
        end

        # Check if plugin has specific permission
        def has_permission?(plugin_name, permission, config = nil)
          settings = security_settings(plugin_name, config)
          !!settings[permission.to_s]
        end

        # Get trusted authors list
        def trusted_authors(config = nil)
          settings = security_settings(nil, config)
          settings['trusted_authors'] || []
        end

        # Check if plugin is from trusted author
        def from_trusted_author?(plugin_metadata, config = nil)
          authors = trusted_authors(config)
          plugin_author = plugin_metadata[:author] || plugin_metadata['author']

          return false unless plugin_author

          authors.any? { |trusted| plugin_author.include?(trusted) }
        end

        # Check if sandbox mode is enabled
        def sandbox_enabled?(plugin_name = nil, config = nil)
          settings = security_settings(plugin_name, config)
          settings['sandbox_mode'] != false # Default to true
        end
      end
    end
  end
end
