# frozen_string_literal: true

require_relative '../base_command'
require 'json'

# Command for displaying frequency distribution histogram
class NumberAnalyzer::Commands::HistogramCommand < NumberAnalyzer::Commands::BaseCommand
  command 'histogram', 'Display frequency distribution histogram'

  private

  def validate_arguments(args)
    return unless @options[:file].nil? && args.empty?

    raise ArgumentError, '数値を指定してください'
  end

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してhistogramは計算できません' if data.empty?

    analyzer = NumberAnalyzer.new(data)
    display_histogram_output(analyzer, data.size)
  end

  def display_histogram_output(analyzer, dataset_size)
    case @options[:format]
    when 'json'
      display_histogram_json(analyzer, dataset_size)
    when 'quiet'
      display_histogram_quiet(analyzer)
    else
      analyzer.display_histogram
    end
  end

  def display_histogram_json(analyzer, dataset_size)
    frequency_dist = analyzer.frequency_distribution
    result = { histogram: frequency_dist, dataset_size: dataset_size }
    puts JSON.generate(result)
  end

  def display_histogram_quiet(analyzer)
    frequency_dist = analyzer.frequency_distribution
    puts frequency_dist.map { |value, count| "#{value}:#{count}" }.join(' ')
  end

  def parse_input(args)
    return super if @options[:file]

    # Validate numeric arguments
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

  # Override to prevent duplicate output
  def output_result(result)
    # Histogram commands handle their own output in perform_calculation
    # This prevents duplicate output
  end
end
