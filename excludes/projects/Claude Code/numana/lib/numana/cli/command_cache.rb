# frozen_string_literal: true

# Command caching module for NumberAnalyzer CLI
# Provides performance optimization through command list caching
module Numana::CLI::CommandCache
  extend self

  # Cache time-to-live in seconds
  CACHE_TTL = 60

  # Get cached commands or build new cache
  def commands
    unless cache_valid?
      @commands_cache = build_command_list
      @cache_time = Time.now
    end
    @commands_cache
  end

  # Invalidate the cache
  def invalidate!
    @commands_cache = nil
    @cache_time = nil
  end

  # Check if plugin system is available
  def plugin_system_available?
    return false unless Numana::CLI.respond_to?(:plugin_system)

    !Numana::CLI.plugin_system.nil?
  end

  # Get plugin commands if available
  def plugin_commands
    return {} unless plugin_system_available?

    # Get commands registered through plugins
    Numana::CLI.instance_variable_get(:@plugin_commands) || {}
  rescue StandardError
    {}
  end

  private

  # Check if cache is still valid
  def cache_valid?
    return false unless @cache_time && @commands_cache

    Time.now - @cache_time < CACHE_TTL
  end

  # Build the complete command list
  def build_command_list
    commands = {}

    # Add core commands from CORE_COMMANDS constant
    commands.merge!(Numana::CLI::CORE_COMMANDS) if defined?(Numana::CLI::CORE_COMMANDS)

    # Add commands from CommandRegistry
    if defined?(Numana::Commands::CommandRegistry)
      Numana::Commands::CommandRegistry.all.each do |cmd|
        commands[cmd] ||= :run_from_registry
      end
    end

    # Add plugin commands
    commands.merge!(plugin_commands)

    commands
  end
end
