# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating sum of numbers
class NumberAnalyzer::Commands::SumCommand < NumberAnalyzer::Commands::BaseCommand
  command 'sum', 'Calculate the sum of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してsumは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.sum
  end
end
