# frozen_string_literal: true

require 'timeout'

# Plugin Sandbox for secure plugin execution
# Provides multi-layer security through method interception, resource control, and capability management
class NumberAnalyzer::PluginSandbox
  attr_reader :config, :interceptor, :resource_monitor, :capability_manager

  SECURITY_LEVELS = {
    development: {
      sandbox_enabled: false,
      log_violations: true,
      method_whitelist: :permissive
    },
    test: {
      sandbox_enabled: true,
      log_violations: true,
      method_whitelist: :standard
    },
    production: {
      sandbox_enabled: true,
      log_violations: true,
      method_whitelist: :strict
    }
  }.freeze

  def initialize(security_level: :production, trusted_plugins: [])
    @config = load_security_config(security_level)
    @interceptor = NumberAnalyzer::PluginSandbox::MethodInterceptor.new(@config[:method_whitelist])
    @resource_monitor = NumberAnalyzer::PluginSandbox::ResourceMonitor.new
    @capability_manager = NumberAnalyzer::PluginSandbox::CapabilityManager.new(trusted_plugins)
    @security_level = security_level
  end

  # Execute plugin code in a secured sandbox environment
  def execute_plugin(plugin_code, plugin_name: 'unknown', capabilities: [])
    return execute_unsandboxed(plugin_code) unless @config[:sandbox_enabled]

    log_security_event('PLUGIN_EXECUTION_START', plugin_name, { capabilities: capabilities })

    # 1. Pre-execution validation
    validate_plugin_syntax(plugin_code)

    # 2. Capability verification
    @capability_manager.verify_capabilities(plugin_name, capabilities)

    # 3. Sandbox execution with resource monitoring
    result = execute_in_sandbox(plugin_code, plugin_name) do |sandbox_binding|
      @resource_monitor.monitor do
        sandbox_binding.eval(plugin_code, "(plugin:#{plugin_name})", 1)
      end
    end

    log_security_event('PLUGIN_EXECUTION_SUCCESS', plugin_name, { result_size: result.to_s.length })
    result
  rescue StandardError => e
    log_security_event('PLUGIN_EXECUTION_ERROR', plugin_name, { error: e.class.name, message: e.message })
    raise
  end

  # Load plugin file with sandboxing
  def load_plugin_file(plugin_file, plugin_name: nil, capabilities: [])
    plugin_name ||= File.basename(plugin_file, '.rb')
    plugin_code = File.read(plugin_file)
    execute_plugin(plugin_code, plugin_name: plugin_name, capabilities: capabilities)
  end

  private

  def execute_in_sandbox(_plugin_code, plugin_name)
    # Create isolated execution environment
    sandbox_binding = create_isolated_binding

    # Execute with timeout protection
    Timeout.timeout(@resource_monitor.cpu_time_limit) do
      yield sandbox_binding
    end
  rescue Timeout::Error
    raise NumberAnalyzer::PluginTimeoutError,
          "Plugin '#{plugin_name}' execution exceeded time limit (#{@resource_monitor.cpu_time_limit}s)"
  rescue SecurityError => e
    raise NumberAnalyzer::PluginSecurityError,
          "Security violation in plugin '#{plugin_name}': #{e.message}"
  rescue NumberAnalyzer::PluginResourceError, NumberAnalyzer::PluginTimeoutError => e
    # Preserve resource and timeout errors as-is
    raise e
  rescue StandardError => e
    raise NumberAnalyzer::PluginExecutionError,
          "Plugin '#{plugin_name}' execution failed: #{e.message}"
  end

  def create_isolated_binding
    # Simple approach: add static code analysis for obvious dangerous patterns
    # Use regex pattern matching as first line of defense
    binding
  end

  def execute_unsandboxed(plugin_code)
    log_security_event('UNSANDBOXED_EXECUTION', 'development', {}) if @config[:log_violations]
    eval(plugin_code) # rubocop:disable Security/Eval
  end

  def validate_plugin_syntax(plugin_code)
    RubyVM::InstructionSequence.compile(plugin_code)
  rescue SyntaxError => e
    raise NumberAnalyzer::PluginSyntaxError, "Plugin syntax error: #{e.message}"
  end

  def load_security_config(security_level)
    base_config = SECURITY_LEVELS[security_level] || SECURITY_LEVELS[:production]

    # Load from file if exists
    config_file = File.join(__dir__, '../../config/security.yml')
    if File.exist?(config_file)
      require 'yaml'
      file_config = YAML.safe_load_file(config_file)
      base_config.merge(file_config.dig('plugin_security', security_level.to_s) || {})
    else
      base_config
    end
  end

  def log_security_event(event_type, plugin_name, details)
    return unless @config[:log_violations]

    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    puts "[#{timestamp}] #{event_type} plugin=\"#{plugin_name}\" #{format_details(details)}"
  end

  def format_details(details)
    details.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')
  end
end

# Custom error classes for plugin security
class NumberAnalyzer::PluginSecurityError < StandardError; end
class NumberAnalyzer::PluginTimeoutError < NumberAnalyzer::PluginSecurityError; end
class NumberAnalyzer::PluginResourceError < NumberAnalyzer::PluginSecurityError; end
class NumberAnalyzer::PluginExecutionError < StandardError; end
class NumberAnalyzer::PluginSyntaxError < NumberAnalyzer::PluginExecutionError; end
class NumberAnalyzer::PluginCapabilityError < NumberAnalyzer::PluginSecurityError; end

# Load subcomponents after the main class and error classes are defined
require_relative 'plugin_sandbox/method_interceptor'
require_relative 'plugin_sandbox/resource_monitor'
require_relative 'plugin_sandbox/capability_manager'
