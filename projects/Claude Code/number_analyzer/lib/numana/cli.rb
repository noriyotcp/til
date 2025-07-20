# frozen_string_literal: true

require_relative '../numana'
require_relative 'file_reader'
require_relative 'plugin_system'
require_relative 'plugin_conflict_resolver'
require_relative 'plugin_namespace'
require_relative 'plugin_priority'

# Command Line Interface for NumberAnalyzer
# Handles command-line argument parsing and validation for NumberAnalyzer
class NumberAnalyzer::CLI
  # Core built-in commands (now moved to CommandRegistry)
  CORE_COMMANDS = {}.freeze

  class << self
    # Get all available commands (core + plugin + command registry)
    def commands
      NumberAnalyzer::CLI::CommandCache.commands
    end

    # Register a new command from a plugin
    def register_command(command_name, plugin_class, method_name)
      plugin_commands[command_name] = { plugin_class: plugin_class, method: method_name }
      # Invalidate cache when new command is registered
      NumberAnalyzer::CLI::CommandCache.invalidate!
    end

    # Initialize plugin system
    def plugin_system
      @plugin_system ||= NumberAnalyzer::PluginSystem.new
    end

    # Load plugins on CLI initialization
    def initialize_plugins
      plugin_system.load_enabled_plugins
    end

    # Reset plugin state (for testing)
    def reset_plugin_state!
      @plugin_commands = {}
      @plugin_system = nil
    end

    private

    # Dynamic commands from plugins (class instance variable)
    def plugin_commands
      @plugin_commands ||= {}
    end
  end

  # Main entry point for CLI
  def self.run(argv = ARGV)
    initialize_plugins
    return NumberAnalyzer::CLI::HelpGenerator.show_general_help if argv.empty?

    command = argv.first
    return NumberAnalyzer::CLI::HelpGenerator.show_general_help if ['--help', '-h'].include?(command)

    if commands.key?(command)
      run_subcommand(command, argv[1..])
    elsif command.start_with?('-') || command.match?(/^\d+(\.\d+)?$/)
      run_full_analysis(argv)
    else
      handle_unknown_command(command)
    end
  end

  def self.parse_arguments(argv = ARGV)
    NumberAnalyzer::CLI::InputProcessor.process_arguments(argv)
  end

  private_class_method def self.run_full_analysis(argv)
    numbers = parse_arguments(argv)
    analyzer = NumberAnalyzer.new(numbers)
    analyzer.calculate_statistics
  end

  private_class_method def self.run_subcommand(command, args)
    options, remaining_args = NumberAnalyzer::CLI::Options.parse_special_command_options(args, command)
    NumberAnalyzer::CLI::PluginRouter.route_command(command, remaining_args, options)
  end

  private_class_method def self.handle_unknown_command(command)
    NumberAnalyzer::CLI::ErrorHandler.handle_unknown_command(command, commands.keys)
  rescue NumberAnalyzer::CLI::ErrorHandler::CLIError => e
    NumberAnalyzer::CLI::ErrorHandler.print_error_and_exit(e)
  end
end

require_relative 'cli/options'
require_relative 'cli/help_generator'
require_relative 'cli/input_processor'
require_relative 'cli/error_handler'
require_relative 'cli/command_cache'
require_relative 'cli/plugin_router'
require_relative 'cli/commands'

# Execution section (only when run as a Ruby script)
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
