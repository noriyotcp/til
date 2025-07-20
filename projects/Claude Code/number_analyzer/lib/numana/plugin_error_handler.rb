# frozen_string_literal: true

require 'logger'

# Enhanced error handling and recovery system for NumberAnalyzer plugins
class Numana
  # Handles plugin errors with recovery mechanisms
  class PluginErrorHandler
    # Error recovery strategies
    RECOVERY_STRATEGIES = {
      retry: :retry_with_backoff,
      fallback: :use_fallback_plugin,
      disable: :disable_plugin,
      fail_fast: :propagate_error,
      log_continue: :log_and_continue
    }.freeze

    # Default recovery policies by error type
    DEFAULT_POLICIES = {
      'LoadError' => :fallback,
      'NameError' => :disable,
      'NoMethodError' => :disable,
      'ArgumentError' => :fail_fast,
      'StandardError' => :log_continue,
      'DependencyResolver::CircularDependencyError' => :fail_fast,
      'DependencyResolver::UnresolvedDependencyError' => :disable,
      'DependencyResolver::VersionConflictError' => :fallback
    }.freeze

    attr_reader :logger, :error_log, :recovery_attempts

    def initialize(options = {})
      @logger = options[:logger] || create_default_logger
      @error_log = []
      @recovery_attempts = Hash.new(0)
      @max_retries = options[:max_retries] || 3
      @retry_delay = options[:retry_delay] || 1
      @fallback_registry = {}
      @disabled_plugins = Set.new
      @error_callbacks = []
    end

    # Handle an error with appropriate recovery strategy
    def handle_error(error, context = {})
      log_error(error, context)

      strategy = determine_recovery_strategy(error, context)
      execute_recovery_strategy(strategy, error, context)
    end

    # Register a fallback plugin for another plugin
    def register_fallback(plugin_name, fallback_plugin_name)
      @fallback_registry[plugin_name] = fallback_plugin_name
    end

    # Register an error callback
    def on_error(&block)
      @error_callbacks << block if block_given?
    end

    # Check if a plugin is disabled due to errors
    def plugin_disabled?(plugin_name)
      @disabled_plugins.include?(plugin_name)
    end

    # Get error statistics
    def error_statistics
      {
        total_errors: @error_log.size,
        errors_by_plugin: group_errors_by_plugin,
        errors_by_type: group_errors_by_type,
        disabled_plugins: @disabled_plugins.to_a,
        recovery_attempts: @recovery_attempts.dup
      }
    end

    # Clear error history
    def clear_errors
      @error_log.clear
      @recovery_attempts.clear
      @disabled_plugins.clear
    end

    # Re-enable a disabled plugin
    def enable_plugin(plugin_name)
      @disabled_plugins.delete(plugin_name)
      @recovery_attempts[plugin_name] = 0
    end

    private

    def create_default_logger
      logger = Logger.new($stderr)
      logger.level = Logger::WARN
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}] #{severity} -- #{progname}: #{msg}\n"
      end
      logger
    end

    def log_error(error, context)
      error_entry = {
        timestamp: Time.now,
        error_class: error.class.name,
        message: error.message,
        backtrace: error.backtrace&.first(5),
        context: context
      }

      @error_log << error_entry

      @logger.error('Plugin Error') do
        "#{error.class}: #{error.message} (Plugin: #{context[:plugin_name]})"
      end

      notify_error_callbacks(error, context)
    end

    def notify_error_callbacks(error, context)
      @error_callbacks.each do |callback|
        callback.call(error, context)
      rescue StandardError => e
        @logger.error("Error callback failed: #{e.message}")
      end
    end

    def determine_recovery_strategy(error, context)
      # Check for custom recovery policy
      return context[:recovery_strategy] if context[:recovery_strategy]

      # Check error type policies
      error_class = error.class.ancestors.find { |klass| DEFAULT_POLICIES.key?(klass.name) }
      policy = DEFAULT_POLICIES[error_class&.name] || :log_continue

      # Override with fail_fast if too many retries
      plugin_name = context[:plugin_name]
      policy = :fail_fast if plugin_name && @recovery_attempts[plugin_name] >= @max_retries

      policy
    end

    def execute_recovery_strategy(strategy, error, context)
      method_name = RECOVERY_STRATEGIES[strategy] || :log_and_continue
      send(method_name, error, context)
    end

    # Recovery strategy implementations

    def retry_with_backoff(error, context)
      plugin_name = context[:plugin_name]
      return propagate_error(error, context) unless plugin_name

      attempt = @recovery_attempts[plugin_name]

      if attempt < @max_retries
        @recovery_attempts[plugin_name] += 1
        delay = @retry_delay * (2**attempt) # Exponential backoff

        @logger.info("Retrying plugin #{plugin_name} after #{delay}s (attempt #{attempt + 1}/#{@max_retries})")

        sleep(delay)

        # Return retry signal
        { action: :retry, delay: delay }
      else
        @logger.error("Max retries reached for plugin #{plugin_name}, disabling")
        disable_plugin(error, context)
      end
    end

    def use_fallback_plugin(error, context)
      plugin_name = context[:plugin_name]
      fallback = @fallback_registry[plugin_name]

      if fallback && !@disabled_plugins.include?(fallback)
        @logger.info("Using fallback plugin #{fallback} for #{plugin_name}")
        { action: :fallback, fallback_plugin: fallback }
      else
        @logger.warn("No fallback available for #{plugin_name}, disabling")
        disable_plugin(error, context)
      end
    end

    def disable_plugin(_error, context)
      plugin_name = context[:plugin_name]
      return { action: :skip } unless plugin_name

      @disabled_plugins.add(plugin_name)
      @logger.warn("Plugin #{plugin_name} has been disabled due to errors")

      { action: :disable, plugin: plugin_name }
    end

    def propagate_error(error, _context)
      # Re-raise the error for upstream handling
      raise error
    end

    def log_and_continue(error, context)
      plugin_name = context[:plugin_name] || 'unknown'
      @logger.warn("Continuing despite error in plugin #{plugin_name}: #{error.message}")

      { action: :continue }
    end

    # Helper methods for statistics

    def group_errors_by_plugin
      @error_log.group_by { |entry| entry[:context][:plugin_name] }
                .transform_values(&:count)
    end

    def group_errors_by_type
      @error_log.group_by { |entry| entry[:error_class] }
                .transform_values(&:count)
    end
  end

  # Utility class for detailed error reporting
  class PluginErrorReport
    def self.generate(error_handler)
      stats = error_handler.error_statistics

      report = ['Plugin Error Report', '=' * 50]
      report << "Total Errors: #{stats[:total_errors]}"
      report << ''

      if stats[:errors_by_plugin].any?
        report << 'Errors by Plugin:'
        stats[:errors_by_plugin].each do |plugin, count|
          report << "  #{plugin}: #{count} errors"
        end
        report << ''
      end

      if stats[:errors_by_type].any?
        report << 'Errors by Type:'
        stats[:errors_by_type].each do |type, count|
          report << "  #{type}: #{count} occurrences"
        end
        report << ''
      end

      if stats[:disabled_plugins].any?
        report << 'Disabled Plugins:'
        stats[:disabled_plugins].each do |plugin|
          report << "  - #{plugin}"
        end
        report << ''
      end

      report << 'Recovery Attempts:'
      stats[:recovery_attempts].each do |plugin, attempts|
        report << "  #{plugin}: #{attempts} retries"
      end

      report.join("\n")
    end
  end
end
