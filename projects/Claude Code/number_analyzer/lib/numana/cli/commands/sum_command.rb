# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating sum of numbers
class Numana::Commands::SumCommand < Numana::Commands::BaseCommand
  command 'sum', 'Calculate the sum of numbers'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate sum for empty array' if data.empty?

    analyzer = Numana.new(data)
    analyzer.sum
  end
end
