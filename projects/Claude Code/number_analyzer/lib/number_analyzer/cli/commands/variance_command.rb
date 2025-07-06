# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating variance
class NumberAnalyzer::Commands::VarianceCommand < NumberAnalyzer::Commands::BaseCommand
  command 'variance', 'Calculate variance (measure of data spread)'

  private

  def validate_arguments(args)
    return unless @options[:file].nil? && args.empty?

    raise ArgumentError, '数値を指定してください'
  end

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してvarianceは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    analyzer.variance
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
