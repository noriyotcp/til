# frozen_string_literal: true

require_relative '../base_command'

# Command for analyzing seasonal patterns and decomposition
class NumberAnalyzer::Commands::SeasonalCommand < NumberAnalyzer::Commands::BaseCommand
  command 'seasonal', 'Analyze seasonal patterns and decomposition'

  private

  def validate_arguments(_args)
    return if @options[:help]

    # Period validation
    return unless @options[:period]

    begin
      period = Integer(@options[:period])
      raise ArgumentError, 'Error: Period must be 2 or greater' if period < 2
    rescue ArgumentError => e
      raise ArgumentError, e.message.include?('Period must be 2 or greater') ? e.message : "Error: Invalid period: #{@options[:period]}"
    end
  end

  def parse_input(args)
    require_relative '../data_input_handler'
    NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
  end

  def perform_calculation(data)
    raise ArgumentError, 'Error: Seasonal analysis requires at least 4 data points' if data.length < 4

    # Parse period from options if provided
    period = nil
    if @options[:period]
      begin
        period = Integer(@options[:period])
        raise ArgumentError, 'Error: Period must be 2 or greater' if period < 2
      rescue ArgumentError => e
        raise ArgumentError, e.message.include?('Period must be 2 or greater') ? e.message : "Error: Invalid period: #{@options[:period]}"
      end
    end

    analyzer = NumberAnalyzer.new(data)
    result = analyzer.seasonal_decomposition(period)

    result.merge({
                   dataset_size: data.size,
                   specified_period: period
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
    seasonal_strength = result[:seasonal_strength]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", seasonal_strength)
    else
      puts format('%.4f', seasonal_strength)
    end
  end

  def output_standard(result)
    puts '季節性分析:'
    puts ''

    format_period_information(result)
    format_seasonal_strength(result)
    format_seasonal_pattern(result)
    format_trend_information(result)

    puts "データポイント数: #{result[:dataset_size]}"
  end

  def format_period_information(result)
    period = result[:period]
    specified = result[:specified_period]
    puts "検出された周期: #{period}#{specified ? " (指定: #{specified})" : ' (自動検出)'}"
    puts ''
  end

  def format_seasonal_strength(result)
    seasonal_strength = result[:seasonal_strength]
    formatted_strength = format_value(seasonal_strength)
    puts "季節性の強さ: #{formatted_strength}"

    strength_level = interpret_seasonal_strength(seasonal_strength)
    puts "解釈: #{strength_level}季節性"
    puts ''
  end

  def format_seasonal_pattern(result)
    return unless result[:seasonal_pattern]

    puts '季節パターン:'
    result[:seasonal_pattern].each_with_index do |value, index|
      formatted_value = format_value(value)
      puts "  周期 #{index + 1}: #{formatted_value}"
    end
    puts ''
  end

  def format_trend_information(result)
    return unless result[:trend]

    trend_direction = result[:trend][:direction]
    trend_strength = result[:trend][:strength]
    formatted_trend_strength = format_value(trend_strength)

    puts "トレンド: #{trend_direction} (強さ: #{formatted_trend_strength})"
    puts ''
  end

  def format_value(value)
    if @options[:precision]
      format("%.#{@options[:precision]}f", value)
    else
      format('%.4f', value)
    end
  end

  def interpret_seasonal_strength(seasonal_strength)
    case seasonal_strength
    when 0...0.3
      '弱い'
    when 0.3...0.6
      '中程度'
    when 0.6...0.8
      '強い'
    else
      '非常に強い'
    end
  end

  def show_help
    puts <<~HELP
      seasonal - #{self.class.description}

      Usage: number_analyzer seasonal [OPTIONS] [NUMBERS...]

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --period N            Specify seasonal period (default: auto-detect)
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (seasonal strength only)

      Examples:
        # Auto-detect seasonal period
        number_analyzer seasonal 10 20 15 25 12 22 17 27

        # Specify quarterly data (period=4)
        number_analyzer seasonal --period=4 100 120 110 130 105 125 115 135

        # From file with JSON output
        number_analyzer seasonal --format=json --file quarterly.csv

        # Custom precision
        number_analyzer seasonal --period=4 --precision=2 sales_data.csv
    HELP
  end

  def default_options
    super.merge({
                  period: nil
                })
  end
end
