# frozen_string_literal: true

require_relative '../base_command'

class NumberAnalyzer
  module Commands
    # Command for finding mode (most frequent value(s))
    class ModeCommand < BaseCommand
      command 'mode', 'Find the mode (most frequent value(s)) in the dataset'

      private

      def perform_calculation(data)
        raise ArgumentError, '空の配列に対してmodeは計算できません' if data.empty?

        analyzer = NumberAnalyzer.new(data)
        analyzer.mode
      end
    end
  end
end
