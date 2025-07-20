# frozen_string_literal: true

require_relative 'plugin_configuration/base'
require_relative 'plugin_configuration/loader'
require_relative 'plugin_configuration/manager'
require_relative 'plugin_configuration/validator'
require_relative 'plugin_configuration/security'

# Enhanced Plugin Configuration Management for NumberAnalyzer
# Provides flexible, multi-layer configuration system for plugins
# Main entry point for plugin configuration
# Delegates to modular components for better maintainability
class NumberAnalyzer::PluginConfiguration
  # Re-export errors from base module
  ConfigurationError = PluginConfiguration::ConfigurationError
  InvalidConfigurationError = PluginConfiguration::InvalidConfigurationError
  ConfigurationNotFoundError = PluginConfiguration::ConfigurationNotFoundError

  class << self
    # Delegate to Loader
    def load_configuration(config_paths = nil)
      PluginConfiguration::Loader.load_configuration(config_paths)
    end

    def save_configuration(config, config_path = nil)
      PluginConfiguration::Loader.save_configuration(config, config_path)
    end

    def plugin_config(plugin_name, global_config = nil)
      PluginConfiguration::Loader.plugin_config(plugin_name, global_config)
    end

    def set_plugin_config(plugin_name, plugin_config, global_config = nil)
      PluginConfiguration::Loader.set_plugin_config(plugin_name, plugin_config, global_config)
    end

    # Delegate to Manager
    def enable_plugin(plugin_name, config_path = nil)
      PluginConfiguration::Manager.enable_plugin(plugin_name, config_path)
    end

    def disable_plugin(plugin_name, config_path = nil)
      PluginConfiguration::Manager.disable_plugin(plugin_name, config_path)
    end

    def plugin_enabled?(plugin_name, config = nil)
      PluginConfiguration::Manager.plugin_enabled?(plugin_name, config)
    end

    def enabled_plugins(config = nil)
      PluginConfiguration::Manager.enabled_plugins(config)
    end

    def disabled_plugins(config = nil)
      PluginConfiguration::Manager.disabled_plugins(config)
    end

    def plugin_paths(config = nil)
      PluginConfiguration::Manager.plugin_paths(config)
    end

    # Delegate to Security
    def security_settings(plugin_name = nil, config = nil)
      PluginConfiguration::Security.security_settings(plugin_name, config)
    end

    def performance_settings(plugin_name = nil, config = nil)
      PluginConfiguration::Security.performance_settings(plugin_name, config)
    end

    def permission?(plugin_name, permission, config = nil)
      PluginConfiguration::Security.permission?(plugin_name, permission, config)
    end

    def trusted_authors(config = nil)
      PluginConfiguration::Security.trusted_authors(config)
    end

    def from_trusted_author?(plugin_metadata, config = nil)
      PluginConfiguration::Security.from_trusted_author?(plugin_metadata, config)
    end

    def sandbox_enabled?(plugin_name = nil, config = nil)
      PluginConfiguration::Security.sandbox_enabled?(plugin_name, config)
    end

    # Delegate to Validator
    def validate_configuration!(config)
      PluginConfiguration::Validator.validate_configuration!(config)
    end

    def validate_plugin_configuration(plugin_name, plugin_config)
      PluginConfiguration::Validator.validate_plugin_configuration(plugin_name, plugin_config)
    end

    # Utility methods
    def create_template(config_path)
      default_plugins = PluginConfiguration::DEFAULT_CONFIG['plugins']
      plugins_config = default_plugins.merge({
                                               'enabled' => %w[basic_stats advanced_stats],
                                               'paths' => [
                                                 './plugins',
                                                 './lib/number_analyzer/plugins',
                                                 '~/.number_analyzer/plugins'
                                               ]
                                             })

      template_config = PluginConfiguration::DEFAULT_CONFIG.merge({
                                                                    'plugins' => plugins_config,
                                                                    'plugin_config' => {
                                                                      'example_plugin' => {
                                                                        'enabled' => true,
                                                                        'configuration' => {
                                                                          'option1' => 'value1',
                                                                          'option2' => 42
                                                                        },
                                                                        'security' => {
                                                                          'allow_network_access' => false
                                                                        }
                                                                      }
                                                                    }
                                                                  })

      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, YAML.dump(template_config))

      puts "Configuration template created at: #{config_path}"
      puts 'Edit this file to customize your plugin settings.'
    end

    def merge_environment_configs(base_config, environment = nil)
      environment ||= ENV['NUMBER_ANALYZER_ENV'] || 'development'

      env_config_path = "config/plugins.#{environment}.yml"
      return base_config unless File.exist?(env_config_path)

      begin
        env_config = YAML.load_file(env_config_path) || {}
        PluginConfiguration.deep_merge(base_config, env_config)
      rescue StandardError => e
        warn "Warning: Failed to load environment configuration: #{e.message}"
        base_config
      end
    end
  end
end
