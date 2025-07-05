# frozen_string_literal: true

require_relative '../base_command'

class NumberAnalyzer
  module Commands
    # Command for finding maximum value
    class MaxCommand < BaseCommand
      command 'max', 'Find the maximum value in the dataset'

      private

      def perform_calculation(data)
        raise ArgumentError, '空の配列に対してmaxは計算できません' if data.empty?

        analyzer = NumberAnalyzer.new(data)
        analyzer.max
      end
    end
  end
end
