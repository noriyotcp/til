# frozen_string_literal: true

require_relative '../base_command'

# Command for finding mode (most frequent value(s))
class NumberAnalyzer::Commands::ModeCommand < NumberAnalyzer::Commands::BaseCommand
  command 'mode', 'Find the mode (most frequent value(s)) in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate mode for empty array' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    modes = analyzer.mode

    if modes.empty?
      'No mode'
    elsif modes.length == 1
      modes.first.to_s
    else
      modes.join(', ')
    end
  end
end
