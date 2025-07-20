# frozen_string_literal: true

require_relative '../base_command'

# Command for finding minimum value
class Numana::Commands::MinCommand < Numana::Commands::BaseCommand
  command 'min', 'Find the minimum value in the dataset'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Cannot calculate min for empty array' if data.empty?

    analyzer = Numana.new(data)
    analyzer.min
  end
end
