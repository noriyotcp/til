# frozen_string_literal: true

require_relative '../base_command'

# Command for performing two-way ANOVA (Analysis of Variance)
class Numana::Commands::TwoWayAnovaCommand < Numana::Commands::BaseCommand
  command 'two-way-anova', 'Perform two-way Analysis of Variance (ANOVA)'

  private

  def validate_arguments(args)
    return unless args.empty? && !@options[:file]

    raise ArgumentError, 'データが指定されていません。'
  end

  def parse_input(args)
    # Parse data - either from file or command line arguments
    if @options[:file]
      parse_two_way_anova_from_file(args)
    else
      parse_two_way_anova_from_args(args)
    end
  end

  def perform_calculation(data)
    factor_a_levels, factor_b_levels, values = data

    # Create NumberAnalyzer instance
    analyzer = Numana.new([])
    result = analyzer.two_way_anova(nil, factor_a_levels, factor_b_levels, values)

    raise ArgumentError, 'Could not calculate Two-way ANOVA. Check your data' if result.nil?

    result
  end

  def output_result(result)
    require_relative '../../presenters/two_way_anova_presenter'
    presenter = Numana::Presenters::TwoWayAnovaPresenter.new(result, @options)
    puts presenter.format
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec numana two-way-anova [options]
             --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 data1,data2,data3,data4
             bundle exec numana two-way-anova [options] --file data.csv

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --factor-a=LEVELS      Factor A levels (comma-separated)
        --factor-b=LEVELS      Factor B levels (comma-separated)
        --file                 Read from CSV file with factor columns
        -h, --help             Show this help

      Examples:
        bundle exec numana two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,15,20,25
        bundle exec numana two-way-anova --file factorial_data.csv
        bundle exec numana two-way-anova --format=json --precision=3
          --factor-a Drug,Drug,Placebo,Placebo --factor-b Male,Female,Male,Female 5.2,7.1,3.8,4.5
    HELP
  end

  def default_options
    super.merge({
                  factor_a: nil,
                  factor_b: nil
                })
  end

  def parse_two_way_anova_from_args(args)
    validate_required_factors
    values = parse_values_from_args(args)
    validate_data_consistency(@options[:factor_a], @options[:factor_b], values)

    [@options[:factor_a], @options[:factor_b], values]
  rescue ArgumentError => e
    raise ArgumentError, "Invalid numbers found: #{e.message}"
  end

  def parse_two_way_anova_from_file(args)
    filename = validate_file_argument(args)
    data = read_csv_data(filename)
    extract_factors_and_values(data)
  end

  def validate_required_factors
    return if @options[:factor_a] && @options[:factor_b]

    raise ArgumentError, <<~ERROR
      エラー: --factor-a と --factor-b オプションが必要です。
      使用例: bundle exec numana two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,15,20,25
    ERROR
  end

  def parse_values_from_args(args)
    raise ArgumentError, '数値データが指定されていません。' if args.empty?

    if args.length == 1 && args[0].include?(',')
      args[0].split(',').map { |v| Float(v) }
    else
      args.map { |v| Float(v) }
    end
  end

  def validate_data_consistency(factor_a_levels, factor_b_levels, values)
    return if factor_a_levels.length == factor_b_levels.length && factor_b_levels.length == values.length

    raise ArgumentError, <<~ERROR
      エラー: 要因A、要因B、数値データの数が一致しません。
      要因A: #{factor_a_levels.length}, 要因B: #{factor_b_levels.length}, 数値: #{values.length}
    ERROR
  end

  def validate_file_argument(args)
    raise ArgumentError, 'CSVファイルが指定されていません。' if args.empty?

    filename = args[0]
    raise ArgumentError, "File not found: #{filename}" unless File.exist?(filename)

    filename
  end

  def read_csv_data(filename)
    require 'csv'
    CSV.read(filename, headers: true)
  end

  def extract_factors_and_values(data)
    factor_a_levels = data['factor_a'] || data['FactorA'] || data['A']
    factor_b_levels = data['factor_b'] || data['FactorB'] || data['B']
    values = (data['value'] || data['Value'] || data['Y']).map(&:to_f)

    validate_csv_columns(factor_a_levels, factor_b_levels, values)

    [factor_a_levels, factor_b_levels, values]
  end

  def validate_csv_columns(factor_a_levels, factor_b_levels, values)
    return if factor_a_levels && factor_b_levels && values

    raise ArgumentError, <<~ERROR
      CSVファイルに factor_a, factor_b, value 列が見つかりません。
      必要な列名: factor_a (or FactorA, A), factor_b (or FactorB, B), value (or Value, Y)
    ERROR
  end
end
