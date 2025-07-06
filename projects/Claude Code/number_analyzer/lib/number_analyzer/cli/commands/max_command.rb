# frozen_string_literal: true

require_relative '../base_command'

# Command for finding maximum value
class NumberAnalyzer::Commands::MaxCommand < NumberAnalyzer::Commands::BaseCommand
  command 'max', 'Find the maximum value in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してmaxは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.max
  end
end
