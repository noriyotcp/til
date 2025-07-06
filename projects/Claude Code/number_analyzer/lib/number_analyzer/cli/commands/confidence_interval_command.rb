# frozen_string_literal: true

require_relative '../base_command'
require_relative '../statistical_output_formatter'

# Command for calculating confidence interval for population mean
class NumberAnalyzer::Commands::ConfidenceIntervalCommand < NumberAnalyzer::Commands::BaseCommand
  command 'confidence-interval', 'Calculate confidence interval for population mean'

  private

  def validate_arguments(args)
    return if @options[:help]

    # Check if first argument looks like a confidence level
    return unless confidence_level_from_args?(args)

    level = Float(args[0])
    validate_confidence_level(level)
  rescue ArgumentError
    raise ArgumentError, "エラー: 無効な信頼度です: #{args[0]}"
  end

  def parse_input(args)
    confidence_level = parse_confidence_level_from_args(args)
    remaining_args = confidence_level_from_args?(args) ? args[1..] : args

    require_relative '../data_input_handler'
    data = NumberAnalyzer::Commands::DataInputHandler.parse(remaining_args, @options)

    [data, confidence_level]
  end

  def confidence_level_from_args?(args)
    return false if args.empty?

    begin
      level = Float(args[0])
      # Only consider it a confidence level if it's a reasonable confidence level
      # and there are more arguments (the data values) or file option is set
      level.between?(80, 99) && (args.length > 1 || @options[:file])
    rescue ArgumentError
      false
    end
  end

  def parse_confidence_level_from_args(args)
    # Check if first argument is a confidence level (number between 80-99)
    level = if confidence_level_from_args?(args)
              Float(args[0])
            else
              # Use option or default
              @options[:level] || @options[:confidence_level] || 95
            end

    validate_confidence_level(level)
    level
  rescue ArgumentError
    raise ArgumentError, "エラー: 無効な信頼度です: #{args[0]}"
  end

  def validate_confidence_level(level)
    return if level.between?(1, 99)

    raise ArgumentError, "エラー: 信頼度は1-99の範囲で指定してください: #{level}"
  end

  def perform_calculation(data_and_level)
    data, confidence_level = data_and_level

    raise ArgumentError, 'エラー: 信頼区間の計算には少なくとも2つのデータポイントが必要です。' if data.length < 2

    analyzer = NumberAnalyzer.new(data)
    result = analyzer.confidence_interval(confidence_level)

    raise ArgumentError, 'エラー: 信頼区間を計算できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   confidence_level: confidence_level,
                   dataset_size: data.size
                 })
  end

  def output_result(result)
    if @options[:format] == 'json'
      output_json(result)
    elsif @options[:quiet]
      output_quiet(result)
    else
      output_standard(result)
    end
  end

  def output_json(result)
    require 'json'
    puts JSON.generate(result)
  end

  def output_quiet(result)
    lower_bound = result[:lower_bound]
    upper_bound = result[:upper_bound]

    if @options[:precision]
      puts "#{format("%.#{@options[:precision]}f", lower_bound)} #{format("%.#{@options[:precision]}f", upper_bound)}"
    else
      puts "#{format('%.4f', lower_bound)} #{format('%.4f', upper_bound)}"
    end
  end

  def output_standard(result)
    formatter = NumberAnalyzer::CLI::StatisticalOutputFormatter
    confidence_level = result[:confidence_level]

    puts "#{confidence_level}% 信頼区間:"
    puts

    # Confidence interval display
    interval = formatter.format_confidence_interval(
      result[:lower_bound],
      result[:upper_bound],
      @options[:precision]
    )
    puts "区間: #{interval}"

    # Additional metrics
    puts "標本平均: #{formatter.format_value(result[:sample_mean], @options[:precision])}"
    puts "誤差限界: ±#{formatter.format_value(result[:margin_of_error], @options[:precision])}"
    puts "標本サイズ: #{result[:dataset_size]}"
    puts
    puts "解釈: #{confidence_level}%の確率で母集団平均がこの区間に含まれます。"
  end

  def show_help
    puts <<~HELP
      confidence-interval - #{self.class.description}

      Usage: number_analyzer confidence-interval [OPTIONS] [LEVEL] [NUMBERS...]
             number_analyzer confidence-interval [OPTIONS] [LEVEL] --file DATA.csv

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --level LEVEL         Confidence level (default: 95)
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (bounds only)

      Examples:
        # 95% confidence interval (default)
        number_analyzer confidence-interval 1 2 3 4 5

        # 90% confidence interval#{' '}
        number_analyzer confidence-interval 90 1 2 3 4 5

        # Using --level option
        number_analyzer confidence-interval --level=99 --file data.csv

        # JSON output with precision
        number_analyzer confidence-interval --format=json --precision=2 data.csv

        # Quiet mode (bounds only)
        number_analyzer confidence-interval --quiet 95 1.2 1.5 1.8 2.1
    HELP
  end

  def default_options
    super.merge({
                  level: nil,
                  confidence_level: nil
                })
  end
end
