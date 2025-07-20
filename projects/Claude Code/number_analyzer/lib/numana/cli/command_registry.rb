# frozen_string_literal: true

# Registry for managing CLI commands
# Provides command registration, discovery, and execution functionality
class Numana::Commands::CommandRegistry
  class << self
    # Register a command class with the registry
    def register(command_class)
      commands[command_class.command_name] = command_class
    end

    # Get a registered command class by name
    def get(command_name)
      commands[command_name]
    end

    # Check if a command is registered
    def exists?(command_name)
      commands.key?(command_name)
    end

    # Get all registered command names (sorted)
    def all
      commands.keys.sort
    end

    # Execute a command by name with arguments and options
    # Returns true if command was found and executed, false if command not found
    def execute_command?(command_name, args, options = {})
      command_class = get(command_name)
      return false unless command_class

      command = command_class.new
      command.execute(args, options)
      true
    end

    # Clear all registered commands (mainly for testing)
    def clear
      @commands = {}
    end

    private

    def commands
      @commands ||= {}
    end
  end
end
