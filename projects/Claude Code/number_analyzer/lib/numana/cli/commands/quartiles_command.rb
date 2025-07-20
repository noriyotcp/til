# frozen_string_literal: true

require_relative '../base_command'
require_relative '../../presenters/quartiles_presenter'

# Command for calculating Q1, Q2 (median), and Q3 values
class NumberAnalyzer::Commands::QuartilesCommand < NumberAnalyzer::Commands::BaseCommand
  command 'quartiles', 'Calculate Q1, Q2 (median), and Q3 values'

  private

  def validate_arguments(args)
    return unless @options[:file].nil? && args.empty?

    raise ArgumentError, 'Please specify numbers'
  end

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate quartiles for empty array' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.quartiles
  end

  def output_result(result)
    @options[:dataset_size] = @data&.size if @data
    presenter = NumberAnalyzer::Presenters::QuartilesPresenter.new(result, @options)
    puts presenter.format
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
