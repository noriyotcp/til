# frozen_string_literal: true

require_relative '../base_command'

# Command for finding mode (most frequent value(s))
class NumberAnalyzer::Commands::ModeCommand < NumberAnalyzer::Commands::BaseCommand
  command 'mode', 'Find the mode (most frequent value(s)) in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してmodeは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.mode
  end
end
