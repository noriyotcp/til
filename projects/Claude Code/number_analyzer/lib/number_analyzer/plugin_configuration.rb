# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fileutils'

# Enhanced Plugin Configuration Management for NumberAnalyzer
# Provides flexible, multi-layer configuration system for plugins
class NumberAnalyzer
  # Configuration management system for plugins
  class PluginConfiguration
    # Configuration errors
    class ConfigurationError < StandardError; end
    class InvalidConfigurationError < ConfigurationError; end
    class ConfigurationNotFoundError < ConfigurationError; end

    # Default configuration structure
    DEFAULT_CONFIG = {
      'plugins' => {
        'enabled' => [],
        'disabled' => [],
        'paths' => ['./plugins', './lib/number_analyzer/plugins'],
        'auto_discovery' => true,
        'repositories' => {
          'official' => 'https://github.com/number-analyzer/plugins',
          'community' => 'https://github.com/number-analyzer/community-plugins'
        }
      },
      'plugin_config' => {},
      'security' => {
        'allow_system_commands' => false,
        'allow_network_access' => false,
        'require_signature' => false,
        'trusted_authors' => [],
        'sandbox_mode' => true
      },
      'performance' => {
        'max_memory_per_plugin' => 512,
        'max_execution_time' => 300,
        'enable_caching' => true,
        'lazy_loading' => true
      },
      'logging' => {
        'level' => 'info',
        'plugin_events' => true,
        'performance_metrics' => false
      }
    }.freeze

    class << self
      # Load configuration from multiple sources
      def load_configuration(config_paths = nil)
        config_paths ||= default_config_paths
        merged_config = DEFAULT_CONFIG.dup

        config_paths.each do |config_path|
          next unless File.exist?(config_path)

          begin
            file_config = YAML.load_file(config_path) || {}
            merged_config = deep_merge(merged_config, file_config)
          rescue StandardError => e
            warn "Warning: Failed to load configuration from #{config_path}: #{e.message}"
          end
        end

        validate_configuration!(merged_config)
        normalize_configuration(merged_config)
      end

      # Save configuration to file
      def save_configuration(config, config_path = nil)
        config_path ||= default_config_paths.first
        validate_configuration!(config)

        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, YAML.dump(config))
      end

      # Get plugin-specific configuration
      def plugin_config(plugin_name, global_config = nil)
        global_config ||= load_configuration
        plugin_specific = global_config.dig('plugin_config', plugin_name) || {}

        # Merge with default plugin settings
        default_plugin_config.merge(plugin_specific)
      end

      # Set plugin-specific configuration
      def set_plugin_config(plugin_name, plugin_config, global_config = nil)
        global_config ||= load_configuration
        global_config['plugin_config'] ||= {}
        global_config['plugin_config'][plugin_name] = plugin_config

        save_configuration(global_config)
      end

      # Enable a plugin
      def enable_plugin(plugin_name, config_path = nil)
        config = load_configuration
        config['plugins']['enabled'] ||= []
        config['plugins']['disabled'] ||= []

        # Remove from disabled list
        config['plugins']['disabled'].delete(plugin_name)

        # Add to enabled list if not already present
        config['plugins']['enabled'] << plugin_name unless config['plugins']['enabled'].include?(plugin_name)

        save_configuration(config, config_path)
      end

      # Disable a plugin
      def disable_plugin(plugin_name, config_path = nil)
        config = load_configuration
        config['plugins']['enabled'] ||= []
        config['plugins']['disabled'] ||= []

        # Remove from enabled list
        config['plugins']['enabled'].delete(plugin_name)

        # Add to disabled list if not already present
        config['plugins']['disabled'] << plugin_name unless config['plugins']['disabled'].include?(plugin_name)

        save_configuration(config, config_path)
      end

      # Check if plugin is enabled
      def plugin_enabled?(plugin_name, config = nil)
        config ||= load_configuration
        enabled_plugins = config.dig('plugins', 'enabled') || []
        disabled_plugins = config.dig('plugins', 'disabled') || []

        # Explicit disable overrides enable
        return false if disabled_plugins.include?(plugin_name)

        # Check if explicitly enabled or auto-discovery is on
        enabled_plugins.include?(plugin_name) || config.dig('plugins', 'auto_discovery')
      end

      # Get security settings for a plugin
      def security_settings(plugin_name = nil, config = nil)
        config ||= load_configuration
        global_security = config['security'] || {}

        return global_security unless plugin_name

        # Plugin-specific security overrides
        plugin_specific = plugin_config(plugin_name, config)
        plugin_security = plugin_specific['security'] || {}

        global_security.merge(plugin_security)
      end

      # Get performance settings for a plugin
      def performance_settings(plugin_name = nil, config = nil)
        config ||= load_configuration
        global_performance = config['performance'] || {}

        return global_performance unless plugin_name

        # Plugin-specific performance overrides
        plugin_specific = plugin_config(plugin_name, config)
        plugin_performance = plugin_specific['performance'] || {}

        global_performance.merge(plugin_performance)
      end

      # Validate plugin configuration
      def validate_plugin_configuration(plugin_name, plugin_config)
        errors = []

        # Check required fields
        if plugin_config.key?('dependencies')
          deps = plugin_config['dependencies']
          unless deps.is_a?(Array) && deps.all? { |dep| dep.is_a?(String) }
            errors << 'dependencies must be an array of strings'
          end
        end

        # Validate security settings
        if plugin_config.key?('security')
          security = plugin_config['security']
          if security.is_a?(Hash)
            validate_security_config(security, errors)
          else
            errors << 'security configuration must be a hash'
          end
        end

        # Validate performance settings
        if plugin_config.key?('performance')
          performance = plugin_config['performance']
          if performance.is_a?(Hash)
            validate_performance_config(performance, errors)
          else
            errors << 'performance configuration must be a hash'
          end
        end

        unless errors.empty?
          raise InvalidConfigurationError,
                "Invalid configuration for plugin #{plugin_name}: #{errors.join(', ')}"
        end

        true
      end

      # Create configuration template
      def create_template(config_path)
        template_config = DEFAULT_CONFIG.merge({
                                                 'plugins' => DEFAULT_CONFIG['plugins'].merge({
                                                                                                'enabled' => %w[
                                                                                                  basic_stats advanced_stats
                                                                                                ],
                                                                                                'paths' => ['./plugins', './lib/number_analyzer/plugins',
                                                                                                            '~/.number_analyzer/plugins']
                                                                                              }),
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

      # Merge configurations from multiple environments
      def merge_environment_configs(base_config, environment = nil)
        environment ||= ENV['NUMBER_ANALYZER_ENV'] || 'development'

        env_config_path = "config/plugins.#{environment}.yml"
        return base_config unless File.exist?(env_config_path)

        begin
          env_config = YAML.load_file(env_config_path) || {}
          deep_merge(base_config, env_config)
        rescue StandardError => e
          warn "Warning: Failed to load environment configuration: #{e.message}"
          base_config
        end
      end

      private

      def default_config_paths
        [
          'plugins.yml',
          'config/plugins.yml',
          File.expand_path('~/.number_analyzer/config.yml'),
          '/etc/number_analyzer/plugins.yml'
        ]
      end

      def default_plugin_config
        {
          'enabled' => true,
          'configuration' => {},
          'security' => {},
          'performance' => {},
          'logging' => {}
        }
      end

      def deep_merge(hash1, hash2)
        result = hash1.dup

        hash2.each do |key, value|
          result[key] = if result[key].is_a?(Hash) && value.is_a?(Hash)
                          deep_merge(result[key], value)
                        else
                          value
                        end
        end

        result
      end

      def validate_configuration!(config)
        errors = []

        # Validate plugins section
        if config.key?('plugins')
          plugins_config = config['plugins']
          if plugins_config.is_a?(Hash)
            validate_plugins_config(plugins_config, errors)
          else
            errors << 'plugins section must be a hash'
          end
        end

        # Validate security section
        if config.key?('security')
          security_config = config['security']
          if security_config.is_a?(Hash)
            validate_security_config(security_config, errors)
          else
            errors << 'security section must be a hash'
          end
        end

        # Validate performance section
        if config.key?('performance')
          performance_config = config['performance']
          if performance_config.is_a?(Hash)
            validate_performance_config(performance_config, errors)
          else
            errors << 'performance section must be a hash'
          end
        end

        raise InvalidConfigurationError, "Invalid configuration: #{errors.join(', ')}" unless errors.empty?
      end

      def validate_plugins_config(plugins_config, errors)
        # Validate enabled plugins
        if plugins_config.key?('enabled')
          enabled = plugins_config['enabled']
          unless enabled.is_a?(Array) && enabled.all? { |p| p.is_a?(String) }
            errors << 'enabled plugins must be an array of strings'
          end
        end

        # Validate disabled plugins
        if plugins_config.key?('disabled')
          disabled = plugins_config['disabled']
          unless disabled.is_a?(Array) && disabled.all? { |p| p.is_a?(String) }
            errors << 'disabled plugins must be an array of strings'
          end
        end

        # Validate plugin paths
        return unless plugins_config.key?('paths')

        paths = plugins_config['paths']
        return if paths.is_a?(Array) && paths.all? { |p| p.is_a?(String) }

        errors << 'plugin paths must be an array of strings'
      end

      def validate_security_config(security_config, errors)
        boolean_settings = %w[allow_system_commands allow_network_access require_signature sandbox_mode]

        boolean_settings.each do |setting|
          next unless security_config.key?(setting)

          value = security_config[setting]
          errors << "#{setting} must be a boolean" unless [true, false].include?(value)
        end

        # Validate trusted_authors
        return unless security_config.key?('trusted_authors')

        authors = security_config['trusted_authors']
        return if authors.is_a?(Array) && authors.all? { |a| a.is_a?(String) }

        errors << 'trusted_authors must be an array of strings'
      end

      def validate_performance_config(performance_config, errors)
        # Validate numeric settings
        numeric_settings = {
          'max_memory_per_plugin' => 'integer',
          'max_execution_time' => 'integer'
        }

        numeric_settings.each do |setting, type|
          next unless performance_config.key?(setting)

          value = performance_config[setting]
          case type
          when 'integer'
            errors << "#{setting} must be a positive integer" unless value.is_a?(Integer) && value.positive?
          end
        end

        # Validate boolean settings
        boolean_settings = %w[enable_caching lazy_loading]

        boolean_settings.each do |setting|
          next unless performance_config.key?(setting)

          value = performance_config[setting]
          errors << "#{setting} must be a boolean" unless [true, false].include?(value)
        end
      end

      def normalize_configuration(config)
        # Expand user paths
        if config.dig('plugins', 'paths')
          config['plugins']['paths'] = config['plugins']['paths'].map do |path|
            File.expand_path(path)
          end
        end

        # Ensure arrays exist
        config['plugins']['enabled'] ||= []
        config['plugins']['disabled'] ||= []
        config['plugin_config'] ||= {}

        config
      end
    end

    # Instance methods for configuration management
    attr_reader :config, :config_path

    def initialize(config_path = nil)
      @config_path = config_path
      @config = self.class.load_configuration(config_path ? [config_path] : nil)
    end

    # Reload configuration from file
    def reload!
      @config = self.class.load_configuration(@config_path ? [@config_path] : nil)
    end

    # Save current configuration
    def save!
      self.class.save_configuration(@config, @config_path)
    end

    # Get configuration value
    def get(key_path)
      keys = key_path.split('.')
      keys.reduce(@config) { |hash, key| hash&.dig(key) }
    end

    # Set configuration value
    def set(key_path, value)
      keys = key_path.split('.')
      last_key = keys.pop
      target = keys.reduce(@config) { |hash, key| hash[key] ||= {} }
      target[last_key] = value
    end

    # Check if plugin is enabled
    def plugin_enabled?(plugin_name)
      self.class.plugin_enabled?(plugin_name, @config)
    end

    # Enable plugin
    def enable_plugin(plugin_name)
      self.class.enable_plugin(plugin_name, @config_path)
      reload!
    end

    # Disable plugin
    def disable_plugin(plugin_name)
      self.class.disable_plugin(plugin_name, @config_path)
      reload!
    end
  end
end
