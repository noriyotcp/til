# frozen_string_literal: true

require_relative '../base_command'

# Command for analyzing growth rates including period-over-period rates and CAGR
class NumberAnalyzer::Commands::GrowthRateCommand < NumberAnalyzer::Commands::BaseCommand
  command 'growth-rate', 'Analyze growth rates including period-over-period rates and CAGR'

  private

  def parse_input(args)
    require_relative '../data_input_handler'
    NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
  end

  def perform_calculation(data)
    raise ArgumentError, 'エラー: 成長率の計算には少なくとも2つのデータポイントが必要です。' if data.length < 2

    analyzer = NumberAnalyzer.new(data)

    # Calculate growth rate metrics
    growth_rates = analyzer.growth_rates
    cagr = analyzer.compound_annual_growth_rate
    avg_growth = analyzer.average_growth_rate

    {
      growth_rates: growth_rates,
      compound_annual_growth_rate: cagr,
      average_growth_rate: avg_growth,
      dataset_size: data.size
    }
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
    cagr = result[:compound_annual_growth_rate]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", cagr)
    else
      puts format('%.2f', cagr)
    end
  end

  def output_standard(result)
    puts '成長率分析:'
    puts ''

    format_period_growth_rates(result[:growth_rates])
    format_aggregate_growth_rates(result)

    puts "データポイント数: #{result[:dataset_size]}"
  end

  def format_period_growth_rates(growth_rates)
    puts '期間別成長率:'
    growth_rates.each_with_index do |rate, index|
      formatted_rate = format_percentage(rate)
      puts "  期間 #{index + 1}: #{formatted_rate}%"
    end
    puts ''
  end

  def format_aggregate_growth_rates(result)
    cagr = result[:compound_annual_growth_rate]
    avg_growth = result[:average_growth_rate]

    formatted_cagr = format_percentage(cagr)
    puts "年平均成長率 (CAGR): #{formatted_cagr}%"

    formatted_avg = format_percentage(avg_growth)
    puts "平均成長率: #{formatted_avg}%"
  end

  def format_percentage(rate)
    if @options[:precision]
      format("%.#{@options[:precision]}f", rate * 100)
    else
      format('%.2f', rate * 100)
    end
  end

  def show_help
    puts <<~HELP
      growth-rate - #{self.class.description}

      Usage: number_analyzer growth-rate [OPTIONS] [NUMBERS...]

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (CAGR only)

      Examples:
        # Basic growth rate analysis
        number_analyzer growth-rate 100 110 121 133

        # From file with JSON output
        number_analyzer growth-rate --format=json --file sales.csv

        # Custom precision
        number_analyzer growth-rate --precision=1 50 55 60 62

        # Quiet mode (CAGR only)
        number_analyzer growth-rate --quiet 100 120 144
    HELP
  end
end
