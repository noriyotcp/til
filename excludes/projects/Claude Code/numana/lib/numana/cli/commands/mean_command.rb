# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating arithmetic mean (average) of numbers
class Numana::Commands::MeanCommand < Numana::Commands::BaseCommand
  command 'mean', 'Calculate the arithmetic mean (average) of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate mean for empty array' if data.empty?

    analyzer = Numana.new(data)
    analyzer.mean
  end
end
