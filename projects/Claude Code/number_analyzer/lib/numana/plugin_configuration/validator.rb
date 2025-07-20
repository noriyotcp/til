# frozen_string_literal: true

require_relative 'base'

# Configuration validation for NumberAnalyzer plugin system
# Validates configuration data
class Numana::PluginConfiguration::Validator
  class << self
    # Validate the entire configuration
    def validate_configuration!(config)
      errors = []

      # Validate top-level structure
      validate_top_level_structure(config, errors)

      # Validate plugins section
      validate_plugins_config(config['plugins'], errors) if config['plugins']

      # Validate security section
      validate_security_config(config['security'], errors) if config['security']

      # Validate performance section
      validate_performance_config(config['performance'], errors) if config['performance']

      # Validate logging section
      validate_logging_config(config['logging'], errors) if config['logging']

      # Raise error if any validation failed
      raise InvalidConfigurationError, "Configuration validation failed: #{errors.join(', ')}" unless errors.empty?

      true
    end

    # Validate plugin-specific configuration
    def validate_plugin_configuration(plugin_name, plugin_config)
      errors = []

      # Check required fields
      if plugin_config.key?('dependencies')
        deps = plugin_config['dependencies']
        errors << 'dependencies must be an array of strings' unless deps.is_a?(Array) && deps.all? { |dep| dep.is_a?(String) }
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

    private

    def validate_top_level_structure(config, errors)
      required_keys = %w[plugins security performance logging]
      required_keys.each do |key|
        errors << "Missing required section: #{key}" unless config.key?(key)
      end
    end

    def validate_plugins_config(plugins_config, errors)
      return unless plugins_config.is_a?(Hash)

      # Validate enabled/disabled arrays
      %w[enabled disabled].each do |key|
        next unless plugins_config.key?(key)

        value = plugins_config[key]
        errors << "plugins.#{key} must be an array of strings" unless value.is_a?(Array) && value.all? { |item| item.is_a?(String) }
      end

      # Validate paths
      if plugins_config.key?('paths')
        paths = plugins_config['paths']
        errors << 'plugins.paths must be an array of strings' unless paths.is_a?(Array) && paths.all? { |path| path.is_a?(String) }
      end

      # Validate auto_discovery
      return unless plugins_config.key?('auto_discovery')

      value = plugins_config['auto_discovery']
      errors << 'plugins.auto_discovery must be a boolean' unless [true, false].include?(value)
    end

    def validate_security_config(security_config, errors)
      return unless security_config.is_a?(Hash)

      # Validate boolean security options
      %w[allow_system_commands allow_network_access require_signature sandbox_mode].each do |key|
        next unless security_config.key?(key)

        value = security_config[key]
        errors << "security.#{key} must be a boolean" unless [true, false].include?(value)
      end

      # Validate trusted_authors array
      return unless security_config.key?('trusted_authors')

      authors = security_config['trusted_authors']
      return if authors.is_a?(Array) && authors.all? { |author| author.is_a?(String) }

      errors << 'security.trusted_authors must be an array of strings'
    end

    def validate_performance_config(performance_config, errors)
      return unless performance_config.is_a?(Hash)

      # Validate numeric performance options
      numeric_options = %w[max_memory_per_plugin max_execution_time]
      numeric_options.each do |key|
        next unless performance_config.key?(key)

        value = performance_config[key]
        errors << "performance.#{key} must be a positive number" unless value.is_a?(Numeric) && value.positive?
      end

      # Validate boolean performance options
      %w[enable_caching lazy_loading].each do |key|
        next unless performance_config.key?(key)

        value = performance_config[key]
        errors << "performance.#{key} must be a boolean" unless [true, false].include?(value)
      end
    end

    def validate_logging_config(logging_config, errors)
      return unless logging_config.is_a?(Hash)

      # Validate log level
      if logging_config.key?('level')
        level = logging_config['level']
        valid_levels = %w[debug info warn error fatal]
        errors << "logging.level must be one of: #{valid_levels.join(', ')}" unless valid_levels.include?(level)
      end

      # Validate boolean logging options
      %w[plugin_events performance_metrics].each do |key|
        next unless logging_config.key?(key)

        value = logging_config[key]
        errors << "logging.#{key} must be a boolean" unless [true, false].include?(value)
      end
    end
  end
end
