# frozen_string_literal: true

require 'pathname'
require_relative 'plugin_system'
require_relative 'plugin_interface'
require_relative 'plugin_validator'
require_relative 'plugin_configuration'
require_relative 'plugin_registry'

# Enhanced Plugin discovery and loading utilities with security validation
# Handles plugin discovery, validation, and secure loading
class Numana::PluginLoader
  # Loading errors
  class LoadingError < StandardError; end
  class SecurityError < LoadingError; end
  class ValidationError < LoadingError; end

  # Discover plugins with security validation
  def self.discover_plugins(search_paths = [], options = {})
    plugins = []
    config = PluginConfiguration.load_configuration

    default_paths = [
      './plugins',
      './lib/numana/plugins',
      File.expand_path('~/.numana/plugins')
    ]

    all_paths = (search_paths + default_paths).uniq

    all_paths.each do |path|
      next unless Dir.exist?(path)

      discovered = discover_plugins_in_path(path, config, options)
      plugins.concat(discovered)
    end

    plugins
  end

  # Load plugins with comprehensive validation and security checks
  def self.load_plugins_securely(plugin_files, options = {})
    config = PluginConfiguration.load_configuration
    security_config = config['security'] || {}

    loaded_plugins = []
    validation_results = []

    plugin_files.each do |plugin_file|
      # Validate plugin security
      validation_result = PluginValidator.validate_plugin_file(plugin_file, {
                                                                 security_config: security_config
                                                               })
      validation_results << validation_result

      # Check if plugin passes security requirements
      next unless security_check_passed?(validation_result, security_config, options)

      # Load the plugin if validation passed
      if load_plugin_file_securely(plugin_file, validation_result, options)
        loaded_plugins << {
          file_path: plugin_file,
          metadata: validation_result[:metadata],
          validation: validation_result
        }
      end
    rescue SecurityError => e
      warn "Security error loading plugin #{plugin_file}: #{e.message}"
    rescue ValidationError => e
      warn "Validation error loading plugin #{plugin_file}: #{e.message}"
    rescue StandardError => e
      warn "Unexpected error loading plugin #{plugin_file}: #{e.message}"
    end

    {
      loaded_plugins: loaded_plugins,
      validation_results: validation_results,
      security_report: PluginValidator.generate_security_report(validation_results)
    }
  end

  # Register plugins with enhanced registry system
  def self.auto_register_plugins_securely(search_paths = [], options = {})
    discovered_plugins = discover_plugins(search_paths, options)
    plugin_files = discovered_plugins.map { |p| p[:file_path] }

    loading_result = load_plugins_securely(plugin_files, options)

    loading_result[:loaded_plugins].each do |plugin_info|
      register_plugin_with_registry(plugin_info, options)
    end

    loading_result
  end

  def self.discover_plugins_in_path(path, config = nil, options = {})
    plugins = []
    config ||= PluginConfiguration.load_configuration

    Dir.glob(File.join(path, '**', '*_plugin.rb')).each do |plugin_file|
      plugin_info = analyze_plugin_file_enhanced(plugin_file, config, options)
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
       content.match?(/< Numana::CLIPlugin/) ||
       content.match?(/plugin_name/) ||
       content.match?(/Numana::.*Plugin/)

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
      "Numana::#{class_name}",
      "#{class_name}Plugin",
      "Numana::#{class_name}Plugin",
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
        :statistics_plugin
      else
        :statistics_module
      end
    end
  end

  # Enhanced plugin file analysis with security considerations
  def self.analyze_plugin_file_enhanced(plugin_file, config, options = {})
    # Basic file analysis first
    basic_info = analyze_plugin_file(plugin_file)
    return nil unless basic_info&.dig(:valid)

    # Add security and configuration checks
    enhanced_info = basic_info.dup
    enhanced_info[:config_enabled] = PluginConfiguration.plugin_enabled?(basic_info[:name], config)
    enhanced_info[:trusted_author] = trusted_author?(basic_info[:author], config)
    enhanced_info[:preliminary_security] = perform_quick_security_check(plugin_file)

    # Only proceed with full analysis if basic checks pass
    if should_analyze_further?(enhanced_info, options)
      enhanced_info[:full_validation] = PluginValidator.validate_plugin_file(plugin_file, {
                                                                               security_config: config['security'] || {}
                                                                             })
    end

    enhanced_info
  end

  # Check if plugin passes security requirements
  def self.security_check_passed?(validation_result, security_config, options = {})
    # Always reject critical risk plugins
    return false if validation_result[:risk_level] == :critical

    # Check validation errors
    return false unless validation_result[:valid]

    # High risk plugins require explicit approval or trusted author
    if (validation_result[:risk_level] == :high) && !(options[:allow_high_risk] ||
                          (validation_result[:metadata] &&
                          PluginValidator.trusted_author?(validation_result[:metadata]['author'],
                                          security_config['trusted_authors'] || [])))
      return false
    end

    # Medium risk plugins are allowed by default unless sandbox mode is strict
    return true if (validation_result[:risk_level] == :medium) && security_config['sandbox_mode'] != 'strict'

    true
  end

  # Securely load a plugin file with additional protections
  def self.load_plugin_file_securely(plugin_file, validation_result, options = {})
    # Additional runtime security measures
    if validation_result[:risk_level] == :low
      # Normal loading for low-risk plugins
      load_plugin_file(plugin_file)
    else
      # Load in restricted environment for non-low risk plugins
      load_with_restrictions(plugin_file, validation_result, options)
    end
  end

  # Load plugin with comprehensive security restrictions
  def self.load_with_restrictions(plugin_file, _validation_result, options = {})
    require_relative 'plugin_sandbox'

    sandbox = setup_plugin_sandbox(options)
    plugin_name = File.basename(plugin_file, '.rb')

    execute_plugin_with_error_handling(sandbox, plugin_file, plugin_name, options)
  end

  # Set up plugin sandbox with security configuration
  def self.setup_plugin_sandbox(options)
    security_level = options[:security_level] || ENV['NUMANA_SECURITY'] || :production
    trusted_plugins = options[:trusted_plugins] || []

    Numana::PluginSandbox.new(
      security_level: security_level.to_sym,
      trusted_plugins: trusted_plugins
    )
  end

  # Execute plugin with comprehensive error handling
  def self.execute_plugin_with_error_handling(sandbox, plugin_file, plugin_name, options)
    capabilities = options[:capabilities] || %i[read_data write_output]
    security_level = options[:security_level] || :production

    begin
      result = sandbox.load_plugin_file(plugin_file, plugin_name: plugin_name, capabilities: capabilities)
      log_plugin_loading_success(plugin_name, security_level, capabilities)
      result
    rescue Numana::PluginSecurityError, Numana::PluginTimeoutError,
           Numana::PluginResourceError, Numana::PluginCapabilityError => e
      handle_plugin_security_error(e, plugin_file, plugin_name)
    rescue Numana::PluginExecutionError => e
      log_execution_error(plugin_name, e.message)
      raise ValidationError, "Failed to execute plugin #{plugin_file}: #{e.message}"
    rescue StandardError => e
      log_unexpected_error(plugin_name, e.class.name, e.message)
      raise ValidationError, "Unexpected error loading plugin #{plugin_file}: #{e.message}"
    end
  end

  # Handle plugin security-related errors
  def self.handle_plugin_security_error(error, plugin_file, plugin_name)
    case error
    when Numana::PluginSecurityError
      log_security_violation(plugin_name, error.message)
      raise SecurityError, "Security violation in plugin #{plugin_file}: #{error.message}"
    when Numana::PluginTimeoutError
      log_timeout_violation(plugin_name, error.message)
      raise SecurityError, "Timeout violation in plugin #{plugin_file}: #{error.message}"
    when Numana::PluginResourceError
      log_resource_violation(plugin_name, error.message)
      raise SecurityError, "Resource violation in plugin #{plugin_file}: #{error.message}"
    when Numana::PluginCapabilityError
      log_capability_violation(plugin_name, error.message)
      raise SecurityError, "Capability violation in plugin #{plugin_file}: #{error.message}"
    end
  end

  # Enhanced plugin loading with capability specification
  def self.load_plugin_with_capabilities(plugin_file, capabilities, options = {})
    options[:capabilities] = capabilities
    load_with_restrictions(plugin_file, nil, options)
  end

  # Load trusted plugin with elevated privileges
  def self.load_trusted_plugin(plugin_file, options = {})
    plugin_name = File.basename(plugin_file, '.rb')
    options[:trusted_plugins] = [plugin_name]
    options[:capabilities] = %i[read_data write_output file_read file_write network_access]
    load_with_restrictions(plugin_file, nil, options)
  end

  def self.log_plugin_loading_success(plugin_name, security_level, capabilities)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] PLUGIN_LOADED plugin=\"#{plugin_name}\" security_level=#{security_level} capabilities=#{capabilities.inspect}"
  end

  def self.log_security_violation(plugin_name, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] SECURITY_VIOLATION plugin=\"#{plugin_name}\" message=\"#{message}\""
  end

  def self.log_timeout_violation(plugin_name, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] TIMEOUT_VIOLATION plugin=\"#{plugin_name}\" message=\"#{message}\""
  end

  def self.log_resource_violation(plugin_name, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] RESOURCE_VIOLATION plugin=\"#{plugin_name}\" message=\"#{message}\""
  end

  def self.log_capability_violation(plugin_name, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] CAPABILITY_VIOLATION plugin=\"#{plugin_name}\" message=\"#{message}\""
  end

  def self.log_execution_error(plugin_name, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] EXECUTION_ERROR plugin=\"#{plugin_name}\" message=\"#{message}\""
  end

  def self.log_unexpected_error(plugin_name, error_class, message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] UNEXPECTED_ERROR plugin=\"#{plugin_name}\" class=\"#{error_class}\" message=\"#{message}\""
  end

  # Register plugin with the enhanced registry system
  def self.register_plugin_with_registry(plugin_info, options = {})
    plugin_name = plugin_info[:metadata]['name'] || File.basename(plugin_info[:file_path], '.rb')

    # Try to find the plugin class
    plugin_class = find_plugin_class(plugin_name)
    return false unless plugin_class

    # Determine extension point
    extension_point = determine_extension_point(plugin_class)

    # Register with the registry
    PluginRegistry.register(plugin_name, plugin_class, {
                              extension_point: extension_point,
                              override: options[:allow_override]
                            })

    true
  rescue StandardError => e
    warn "Failed to register plugin #{plugin_name}: #{e.message}"
    false
  end

  # Check if author is trusted
  def self.trusted_author?(author, config)
    return false unless author

    trusted_authors = config.dig('security', 'trusted_authors') || []
    PluginValidator.trusted_author?(author, trusted_authors)
  end

  # Perform quick security check without full validation
  def self.perform_quick_security_check(plugin_file)
    content = File.read(plugin_file)

    # Quick checks for obvious security issues
    has_system_calls = content.match?(/`|system\(|exec\(|spawn\(/)
    has_file_deletion = content.match?(/File\.(delete|unlink|rm)|FileUtils\.(rm|remove)/)
    has_network_access = content.match?(/Net::|URI\.open|TCPSocket|UDPSocket/)

    risk_level = if has_system_calls || has_file_deletion
                   :high
                 elsif has_network_access
                   :medium
                 else
                   :low
                 end

    {
      risk_level: risk_level,
      has_system_calls: has_system_calls,
      has_file_deletion: has_file_deletion,
      has_network_access: has_network_access
    }
  end

  # Determine if plugin should be analyzed further
  def self.should_analyze_further?(plugin_info, options = {})
    # Always analyze if explicitly requested
    return true if options[:full_analysis]

    # Skip analysis for disabled plugins unless forced
    return false if !plugin_info[:config_enabled] && !options[:analyze_disabled]

    # Analyze if preliminary check shows medium or high risk
    preliminary = plugin_info[:preliminary_security]
    return true if preliminary && %i[medium high critical].include?(preliminary[:risk_level])

    # Analyze trusted author plugins
    return true if plugin_info[:trusted_author]

    # Default to not analyzing (performance optimization)
    false
  end
end
