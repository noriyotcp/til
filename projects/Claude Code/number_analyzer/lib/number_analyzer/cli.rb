# frozen_string_literal: true

require_relative '../number_analyzer'
require_relative 'file_reader'
require_relative 'output_formatter'
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
      all_commands = CORE_COMMANDS.merge(plugin_commands)

      # Add commands from CommandRegistry
      NumberAnalyzer::Commands::CommandRegistry.all.each do |cmd|
        all_commands[cmd] ||= :run_from_registry
      end

      all_commands
    end

    # Register a new command from a plugin
    def register_command(command_name, plugin_class, method_name)
      plugin_commands[command_name] = {
        plugin_class: plugin_class,
        method: method_name
      }
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
    # Initialize plugins before processing commands
    initialize_plugins

    # Show help if no arguments provided
    return NumberAnalyzer::CLI::HelpGenerator.show_general_help if argv.empty?

    # Check if first argument is a subcommand
    command = argv.first

    # Handle top-level help options
    return NumberAnalyzer::CLI::HelpGenerator.show_general_help if ['--help', '-h'].include?(command)

    if commands.key?(command)
      run_subcommand(command, argv[1..])
    elsif command.start_with?('-') || command.match?(/^\d+(\.\d+)?$/)
      # Option or numeric argument, treat as full analysis
      run_full_analysis(argv)
    else
      # Unknown command
      puts "Unknown command: #{command}"
      puts "Use 'bundle exec number_analyzer help' for available commands."
      exit 1
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
    # Parse options using the new Options module
    options, remaining_args = NumberAnalyzer::CLI::Options.parse_special_command_options(args, command)

    # First check if command is registered with new Command Pattern
    if NumberAnalyzer::Commands::CommandRegistry.exists?(command)
      NumberAnalyzer::Commands::CommandRegistry.execute_command(command, remaining_args, options)
    # Then check if it's a core command or plugin command
    elsif CORE_COMMANDS.key?(command)
      method_name = CORE_COMMANDS[command]
      send(method_name, remaining_args, options)
    elsif plugin_commands.key?(command)
      # Execute plugin command
      plugin_info = plugin_commands[command]
      plugin_class = plugin_info[:plugin_class]
      method_name = plugin_info[:method]

      # Create instance if needed and call the method
      result = if plugin_class.respond_to?(method_name)
                 plugin_class.send(method_name, remaining_args, options)
               else
                 instance = plugin_class.new
                 instance.send(method_name, remaining_args, options)
               end

      puts result if result
    else
      puts "Unknown command: #{command}"
      exit 1
    end
  end
end

require_relative 'cli/options'
require_relative 'cli/help_generator'
require_relative 'cli/input_processor'
require_relative 'cli/commands'

# 実行部分（スクリプトとして実行された場合のみ）
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
