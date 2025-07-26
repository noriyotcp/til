# frozen_string_literal: true

require_relative '../base_command'

# Command for finding mode (most frequent value(s))
class Numana::Commands::ModeCommand < Numana::Commands::BaseCommand
  command 'mode', 'Find the mode (most frequent value(s)) in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate mode for empty array' if data.empty?

    analyzer = Numana.new(data)
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
