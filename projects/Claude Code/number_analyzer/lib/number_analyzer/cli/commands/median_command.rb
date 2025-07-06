# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating median (middle value) of numbers
class NumberAnalyzer::Commands::MedianCommand < NumberAnalyzer::Commands::BaseCommand
  command 'median', 'Calculate the median (middle value) of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate median for empty array' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.median
  end

  def output_result(result)
    # Add dataset size for compatibility with existing output format
    @options[:dataset_size] = @data&.size if @data
    super
  end

  def parse_input(args)
    @data = super
    @data
  end
end
