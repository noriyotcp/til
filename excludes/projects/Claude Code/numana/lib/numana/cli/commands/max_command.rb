# frozen_string_literal: true

require_relative '../base_command'

# Command for finding maximum value
class Numana::Commands::MaxCommand < Numana::Commands::BaseCommand
  command 'max', 'Find the maximum value in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate max for empty array' if data.empty?

    analyzer = Numana.new(data)
    analyzer.max
  end
end
