# frozen_string_literal: true

require_relative '../base_command'

# Command for detecting outliers using IQR * 1.5 rule
class NumberAnalyzer::Commands::OutliersCommand < NumberAnalyzer::Commands::BaseCommand
  command 'outliers', 'Detect outliers using IQR * 1.5 rule'

  private

  def validate_arguments(args)
    return unless @options[:file].nil? && args.empty?

    raise ArgumentError, 'Please specify numbers'
  end

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate outliers for empty array' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.outliers
  end

  def output_result(result)
    # Use the OutputFormatter to maintain compatibility
    @options[:dataset_size] = @data&.size if @data
    puts NumberAnalyzer::OutputFormatter.format_outliers(result, @options)
  end

  def parse_input(args)
    @data = if @options[:file]
              super
            else
              parse_numeric_arguments(args)
            end
    @data
  end

  def parse_numeric_arguments(args)
    invalid_args = []
    numbers = args.map do |arg|
      Float(arg)
    rescue ArgumentError
      invalid_args << arg
      nil
    end.compact

    raise ArgumentError, "Invalid arguments found: #{invalid_args.join(', ')}" unless invalid_args.empty?

    raise ArgumentError, 'No valid numbers found' if numbers.empty?

    numbers
  end
end
