# frozen_string_literal: true

require 'yaml'
require 'json'
require 'fileutils'

# Base configuration module for NumberAnalyzer plugin system
# Configuration management system for plugin settings and validation
module Numana::PluginConfiguration
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

  # Get default configuration paths
  def self.default_config_paths
    [
      './config/number_analyzer.yml',
      File.expand_path('~/.config/number_analyzer/config.yml'),
      '/etc/number_analyzer/config.yml'
    ]
  end

  # Deep merge two configuration hashes
  def self.deep_merge(hash1, hash2)
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

  # Normalize configuration values
  def self.normalize_configuration(config)
    # Ensure arrays exist
    config['plugins']['enabled'] ||= []
    config['plugins']['disabled'] ||= []
    config['plugins']['paths'] ||= DEFAULT_CONFIG['plugins']['paths']

    # Normalize string arrays
    config['plugins']['enabled'] = config['plugins']['enabled'].map(&:to_s)
    config['plugins']['disabled'] = config['plugins']['disabled'].map(&:to_s)

    # Ensure numeric values
    if config['performance']
      config['performance']['max_memory_per_plugin'] = config['performance']['max_memory_per_plugin'].to_i
      config['performance']['max_execution_time'] = config['performance']['max_execution_time'].to_i
    end

    config
  end

  # Default plugin configuration
  def self.default_plugin_config
    {
      'enabled' => true,
      'priority' => 'normal',
      'timeout' => 30,
      'memory_limit' => 128,
      'dependencies' => [],
      'config' => {}
    }
  end
end
