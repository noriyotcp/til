# frozen_string_literal: true

require_relative '../base_command'

# Command for finding minimum value
class NumberAnalyzer::Commands::MinCommand < NumberAnalyzer::Commands::BaseCommand
  command 'min', 'Find the minimum value in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してminは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.min
  end
end
