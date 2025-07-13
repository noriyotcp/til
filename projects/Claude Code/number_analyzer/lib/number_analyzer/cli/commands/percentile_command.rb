# frozen_string_literal: true

require_relative '../base_command'
require_relative '../../formatting_utils'

# Command for calculating percentile values (0-100)
class NumberAnalyzer::Commands::PercentileCommand < NumberAnalyzer::Commands::BaseCommand
  include NumberAnalyzer::FormattingUtils
  command 'percentile', 'Calculate percentile value (0-100)'

  private

  def validate_arguments(args)
    return unless args.empty? || (!@options[:file] && args.length < 2)

    raise ArgumentError, 'percentile command requires percentile value and numbers'
  end

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate percentile for empty array' if data.empty?

    percentile_value = parse_percentile_value(@percentile_value_str)
    analyzer = NumberAnalyzer.new(data)
    analyzer.percentile(percentile_value)
  end

  def output_result(result)
    @options[:dataset_size] = @data&.size if @data
    puts format_value(result, @options)
  end

  def parse_input(args)
    @percentile_value_str = args[0]

    @data = if @options[:file]
              parse_percentile_file_input(@options[:file])
            else
              parse_numeric_arguments(args[1..])
            end
    @data
  end

  def parse_percentile_value(percentile_value_str)
    percentile_value = Float(percentile_value_str)
    raise ArgumentError, 'Percentile value must be between 0-100' if percentile_value.negative? || percentile_value > 100

    percentile_value
  rescue ArgumentError => e
    raise e if e.message.include?('Percentile value must be between 0-100')

    raise ArgumentError, 'Invalid percentile value. Please specify a number'
  end

  def parse_percentile_file_input(file_path)
    require_relative '../../file_reader'
    FileReader.read_from_file(file_path)
  rescue StandardError => e
    raise ArgumentError, "File read error: #{e.message}"
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
