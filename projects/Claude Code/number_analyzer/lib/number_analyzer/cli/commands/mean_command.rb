# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating arithmetic mean (average) of numbers
class NumberAnalyzer::Commands::MeanCommand < NumberAnalyzer::Commands::BaseCommand
  command 'mean', 'Calculate the arithmetic mean (average) of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してmeanは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.mean
  end
end
