# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating percentile values (0-100)
class NumberAnalyzer::Commands::PercentileCommand < NumberAnalyzer::Commands::BaseCommand
  command 'percentile', 'Calculate percentile value (0-100)'

  private

  def validate_arguments(args)
    return unless args.empty? || (!@options[:file] && args.length < 2)

    raise ArgumentError, 'percentileコマンドには percentile値と数値が必要です。'
  end

  def perform_calculation(data)
    raise ArgumentError, '空の配列に対してpercentileは計算できません' if data.empty?

    percentile_value = parse_percentile_value(@percentile_value_str)
    analyzer = NumberAnalyzer.new(data)
    analyzer.percentile(percentile_value)
  end

  def output_result(result)
    @options[:dataset_size] = @data&.size if @data
    puts OutputFormatter.format_value(result, @options)
  end

  def parse_input(args)
    @percentile_value_str = args[0]

    @data = if @options[:file]
              parse_percentile_file_input(@options[:file])
            else
              parse_numeric_arguments(args[1..])
            end
    @data
  end

  def parse_percentile_value(percentile_value_str)
    percentile_value = Float(percentile_value_str)
    raise ArgumentError, 'percentile値は0-100の範囲で指定してください。' if percentile_value.negative? || percentile_value > 100

    percentile_value
  rescue ArgumentError => e
    raise e if e.message.include?('percentile値は0-100')

    raise ArgumentError, '無効なpercentile値です。数値を指定してください。'
  end

  def parse_percentile_file_input(file_path)
    require_relative '../../file_reader'
    FileReader.read_from_file(file_path)
  rescue StandardError => e
    raise ArgumentError, "ファイル読み込みエラー: #{e.message}"
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
