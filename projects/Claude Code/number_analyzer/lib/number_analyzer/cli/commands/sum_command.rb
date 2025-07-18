# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating sum of numbers
class NumberAnalyzer::Commands::SumCommand < NumberAnalyzer::Commands::BaseCommand
  command 'sum', 'Calculate the sum of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate sum for empty array' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.sum
  end
end
