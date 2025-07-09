# frozen_string_literal: true

# Plugin routing module for NumberAnalyzer CLI
# Handles smart command routing with conflict resolution
module NumberAnalyzer::CLI::PluginRouter
  extend self

  # Route command with conflict resolution
  def route_command(command, args, options)
    # Check if it's a registry command first
    return execute_registry_command(command, args, options) if command_registry_exists?(command)

    # Check if it's a core command
    core_method = core_command_method(command)
    return execute_core_command(core_method, args, options) if core_method

    # Check if it's a plugin command
    plugin_info = plugin_command_info(command)
    return execute_plugin_command(plugin_info, args, options) if plugin_info

    # Command not found
    handle_unknown_command(command)
  end

  # Check if command exists in CommandRegistry
  def command_registry_exists?(command)
    return false unless defined?(NumberAnalyzer::Commands::CommandRegistry)

    NumberAnalyzer::Commands::CommandRegistry.exists?(command)
  end

  # Execute command through CommandRegistry
  def execute_registry_command(command, args, options)
    NumberAnalyzer::Commands::CommandRegistry.execute_command(command, args, options)
  end

  # Get core command method name
  def core_command_method(command)
    return nil unless defined?(NumberAnalyzer::CLI::CORE_COMMANDS)

    NumberAnalyzer::CLI::CORE_COMMANDS[command]
  end

  # Execute core command
  def execute_core_command(method_name, args, options)
    NumberAnalyzer::CLI.send(method_name, args, options)
  end

  # Get plugin command info
  def plugin_command_info(command)
    return nil unless NumberAnalyzer::CLI.respond_to?(:plugin_commands, true)

    plugin_commands = NumberAnalyzer::CLI.send(:plugin_commands)
    plugin_commands[command]
  end

  # Execute plugin command
  def execute_plugin_command(plugin_info, args, options)
    plugin_class = plugin_info[:plugin_class]
    method_name = plugin_info[:method]

    # Create instance if needed and call the method
    result = if plugin_class.respond_to?(method_name)
               plugin_class.send(method_name, args, options)
             else
               instance = plugin_class.new
               instance.send(method_name, args, options)
             end

    puts result if result
  end

  # Handle conflicts using existing PluginConflictResolver
  def handle_conflicts(command, _args, options)
    return nil unless defined?(NumberAnalyzer::PluginConflictResolver)

    resolver = NumberAnalyzer::PluginConflictResolver.new
    return nil unless resolver.respond_to?(:has_conflicts?) && resolver.has_conflicts?(command)

    strategy = options[:conflict_strategy] || :priority
    resolver.resolve_conflict(command, strategy: strategy)
  end

  private

  # Handle unknown command
  def handle_unknown_command(command)
    raise StandardError, "Unknown command: #{command}" unless defined?(NumberAnalyzer::CLI::ErrorHandler)

    available_commands = all_available_commands
    NumberAnalyzer::CLI::ErrorHandler.handle_unknown_command(command, available_commands)
  end

  # Get all available commands for error suggestions
  def all_available_commands
    commands = []

    # Add registry commands
    commands.concat(NumberAnalyzer::Commands::CommandRegistry.all) if defined?(NumberAnalyzer::Commands::CommandRegistry)

    # Add core commands
    commands.concat(NumberAnalyzer::CLI::CORE_COMMANDS.keys) if defined?(NumberAnalyzer::CLI::CORE_COMMANDS)

    # Add plugin commands
    if NumberAnalyzer::CLI.respond_to?(:plugin_commands, true)
      plugin_cmds = NumberAnalyzer::CLI.send(:plugin_commands)
      commands.concat(plugin_cmds.keys)
    end

    commands.uniq
  end
end
