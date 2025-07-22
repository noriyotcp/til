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
      'paths' => ['./plugins', './lib/numana/plugins'],
      'auto_discovery' => true,
      'repositories' => {
        'official' => 'https://github.com/numana/plugins',
        'community' => 'https://github.com/numana/community-plugins'
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
      './config/numana.yml',
      File.expand_path('~/.config/numana/config.yml'),
      '/etc/numana/config.yml'
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
    normalize_plugin_settings(config['plugins'])
    normalize_performance_settings(config['performance'])
    config
  end

  def self.normalize_plugin_settings(plugins_config)
    return unless plugins_config

    plugins_config['enabled'] ||= []
    plugins_config['disabled'] ||= []
    plugins_config['paths'] ||= DEFAULT_CONFIG.dig('plugins', 'paths')

    plugins_config['enabled'] = plugins_config['enabled'].map(&:to_s)
    plugins_config['disabled'] = plugins_config['disabled'].map(&:to_s)
  end

  def self.normalize_performance_settings(performance_config)
    return unless performance_config

    performance_config['max_memory_per_plugin'] = performance_config['max_memory_per_plugin'].to_i
    performance_config['max_execution_time'] = performance_config['max_execution_time'].to_i
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
