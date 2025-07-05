# frozen_string_literal: true

require_relative '../base_command'

class NumberAnalyzer
  module Commands
    # Command for calculating standard deviation
    class StdCommand < BaseCommand
      command 'std', 'Calculate standard deviation (square root of variance)'

      private

      def validate_arguments(args)
        return unless @options[:file].nil? && args.empty?

        raise ArgumentError, '数値を指定してください'
      end

      def perform_calculation(data)
        raise ArgumentError, '空の配列に対してstdは計算できません' if data.empty?

        analyzer = NumberAnalyzer.new(data)
        analyzer.standard_deviation
      end

      def output_result(result)
        @options[:dataset_size] = @data&.size if @data
        puts OutputFormatter.format_value(result, @options)
      end

      def parse_input(args)
        @data = if @options[:file]
                  super
                else
                  parse_numeric_arguments(args)
                end
        @data
      end

      def parse_numeric_arguments(args)
        invalid_args = []
        numbers = args.map do |arg|
          Float(arg)
        rescue ArgumentError
          invalid_args << arg
          nil
        end.compact

        raise ArgumentError, "無効な引数が見つかりました: #{invalid_args.join(', ')}" unless invalid_args.empty?

        raise ArgumentError, '有効な数値が見つかりませんでした。' if numbers.empty?

        numbers
      end
    end
  end
end
