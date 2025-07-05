# frozen_string_literal: true

require_relative '../output_formatter'

class NumberAnalyzer
  module Commands
    # Base class for all CLI commands
    # Provides common functionality for command execution, error handling, and output formatting
    class BaseCommand
      attr_reader :name, :description, :options

      def initialize
        @name = self.class.command_name
        @description = self.class.description
        @options = default_options
      end

      # Template method pattern for command execution
      def execute(args, global_options = {})
        @options = @options.merge(global_options)

        return show_help if @options[:help]

        validate_arguments(args)
        data = parse_input(args)
        result = perform_calculation(data)
        output_result(result)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Override in subclasses for custom validation
      def validate_arguments(args)
        # Default implementation does nothing
      end

      # Parse input data from arguments or file
      def parse_input(args)
        require_relative 'data_input_handler'
        DataInputHandler.parse(args, @options)
      end

      # Must be implemented by subclasses
      def perform_calculation(data)
        raise NotImplementedError, 'Subclasses must implement perform_calculation'
      end

      # Output the result using the configured formatter
      def output_result(result)
        formatted = if @options[:format] || @options[:precision]
                      OutputFormatter.format(result, @options)
                    else
                      result.to_s
                    end
        puts formatted
      end

      # Handle errors consistently
      def handle_error(error)
        puts "エラー: #{error.message}"
        exit 1
      end

      # Show command-specific help
      def show_help
        puts "#{@name} - #{@description}"
        puts
        puts "Usage: number_analyzer #{@name} [OPTIONS] [NUMBERS...]"
        puts
        puts 'Options:'
        puts '  --help                Show this help message'
        puts '  --file FILE           Read numbers from a file'
        puts '  --format FORMAT       Output format (json)'
        puts '  --precision N         Number of decimal places'
        puts '  --quiet               Minimal output'
      end

      def default_options
        {
          format: nil,
          precision: nil,
          quiet: false,
          help: false,
          file: nil
        }
      end

      class << self
        attr_accessor :command_name, :description

        # DSL for defining command metadata
        def command(name, desc)
          @command_name = name
          @description = desc
        end
      end
    end
  end
end
