# frozen_string_literal: true

require_relative '../base_command'
require_relative '../statistical_output_formatter'

# Command for performing chi-square test for independence or goodness-of-fit
class NumberAnalyzer::Commands::ChiSquareCommand < NumberAnalyzer::Commands::BaseCommand
  command 'chi-square', 'Perform chi-square test for independence or goodness-of-fit'

  private

  def validate_arguments(args)
    return if @options[:help]

    test_type = determine_test_type(args)

    return unless test_type.nil?

    raise ArgumentError, <<~ERROR
      エラー: カイ二乗検定のタイプを指定してください。
      使用例: number_analyzer chi-square --independence contingency.csv
             number_analyzer chi-square --goodness-of-fit observed.csv expected.csv
    ERROR
  end

  def parse_input(args)
    test_type = determine_test_type(args)

    case test_type
    when :independence
      parse_independence_test_input(args)
    when :goodness_of_fit
      parse_goodness_of_fit_input(args)
    end
  end

  def determine_test_type(_args)
    return :independence if @options[:independence]
    return :goodness_of_fit if @options[:goodness_of_fit] || @options[:uniform]

    # Could auto-detect based on data structure, but for now require explicit flags
    nil
  end

  def parse_independence_test_input(args)
    # For independence test, we expect a 2D contingency table
    if @options[:file]
      parse_contingency_table_from_file(@options[:file])
    else
      # Parse contingency table from command line arguments with '--' separators
      parse_contingency_table_from_args(args)
    end
  end

  def parse_goodness_of_fit_input(args)
    if @options[:uniform]
      # Uniform distribution test with single dataset
      require_relative '../data_input_handler'
      observed = NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
      [observed, nil] # nil means uniform distribution
    else
      # Two datasets: observed and expected
      parse_observed_expected_datasets(args)
    end
  end

  def parse_contingency_table_from_file(file_path)
    raise ArgumentError, "エラー: ファイルが見つかりません: #{file_path}" unless File.exist?(file_path)

    begin
      lines = File.readlines(file_path)
      contingency_table = lines.map do |line|
        line.strip.split(',').map(&:to_f)
      end

      # Validate that all rows have same number of columns
      col_count = contingency_table.first&.length
      raise ArgumentError, 'エラー: 分割表の各行は同じ列数である必要があります。' if contingency_table.any? { |row| row.length != col_count }

      contingency_table
    rescue StandardError => e
      raise ArgumentError, "エラー: ファイル読み込み中にエラーが発生しました: #{e.message}"
    end
  end

  def parse_contingency_table_from_args(args)
    rows = build_rows_from_args(args)
    validate_contingency_table(rows)
    rows
  rescue ArgumentError => e
    raise e
  rescue StandardError
    raise ArgumentError, <<~ERROR
      エラー: 無効な数値が含まれています。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def build_rows_from_args(args)
    rows = []
    current_row = []

    args.each do |arg|
      if arg == '--'
        rows << current_row.map(&:to_f) unless current_row.empty?
        current_row = []
      else
        current_row << arg
      end
    end

    # Add the last row
    rows << current_row.map(&:to_f) unless current_row.empty?
    rows
  end

  def validate_contingency_table(rows)
    validate_non_empty_table(rows)
    validate_minimum_table_size(rows)
    validate_consistent_column_count(rows)
  end

  def validate_non_empty_table(rows)
    return unless rows.empty? || rows.any?(&:empty?)

    raise ArgumentError, <<~ERROR
      エラー: 有効な分割表を作成できませんでした。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_minimum_table_size(rows)
    return unless rows.length < 2

    raise ArgumentError, <<~ERROR
      エラー: 独立性検定には少なくとも2x2の分割表が必要です。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_consistent_column_count(rows)
    col_count = rows.first.length
    return unless rows.any? { |row| row.length != col_count }

    raise ArgumentError, 'エラー: 分割表の各行は同じ列数である必要があります。'
  end

  def parse_observed_expected_datasets(args)
    observed, expected = if two_files_provided?(args)
                           parse_from_two_files(args)
                         elsif @options[:file]
                           parse_from_single_file
                         else
                           parse_from_command_line(args)
                         end
    [observed, expected]
  rescue StandardError => e
    raise ArgumentError, "ファイル読み込みエラー: #{e.message}"
  end

  def two_files_provided?(args)
    args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
  end

  def parse_from_two_files(args)
    observed = NumberAnalyzer::FileReader.read_from_file(args[0])
    expected = NumberAnalyzer::FileReader.read_from_file(args[1])
    [observed, expected]
  end

  def parse_from_single_file
    require_relative '../data_input_handler'
    combined_data = NumberAnalyzer::Commands::DataInputHandler.parse([], @options)
    mid = combined_data.length / 2
    observed = combined_data[0...mid]
    expected = combined_data[mid..]
    [observed, expected]
  end

  def parse_from_command_line(args)
    mid = args.length / 2
    observed = parse_numbers(args[0...mid])
    expected = parse_numbers(args[mid..])
    [observed, expected]
  end

  def parse_numbers(args)
    args.map do |arg|
      Float(arg)
    rescue ArgumentError
      raise ArgumentError, "無効な数値: #{arg}"
    end
  end

  def perform_calculation(data)
    test_type = determine_test_type([])

    case test_type
    when :independence
      perform_independence_test(data)
    when :goodness_of_fit
      perform_goodness_of_fit_test(data)
    end
  end

  def perform_independence_test(contingency_table)
    analyzer = NumberAnalyzer.new(contingency_table.flatten)
    result = analyzer.chi_square_test(contingency_table, type: :independence)

    raise ArgumentError, 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :independence,
                   dataset_size: contingency_table.flatten.size
                 })
  end

  def perform_goodness_of_fit_test(data)
    observed, expected = data

    analyzer = NumberAnalyzer.new(observed)
    result = analyzer.chi_square_test(expected, type: :goodness_of_fit)

    raise ArgumentError, 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :goodness_of_fit,
                   dataset_size: observed.size
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
    p_value = result[:p_value]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", p_value)
    else
      puts format('%.6f', p_value)
    end
  end

  def output_standard(result)
    formatter = NumberAnalyzer::CLI::StatisticalOutputFormatter
    test_type = result[:test_type]

    # Header
    puts formatter.format_test_header('カイ二乗検定', test_type_japanese(test_type))
    puts

    # Basic statistics
    puts formatter.format_basic_statistics(
      'カイ二乗統計量',
      result[:chi_square_statistic],
      result[:degrees_of_freedom],
      result[:p_value],
      result[:significant],
      @options[:precision]
    )

    # Test-specific additional information
    additional_info = format_test_specific_info(result, formatter)
    puts additional_info if additional_info

    # Dataset information
    dataset_info = formatter.format_dataset_info(dataset_size: result[:dataset_size])
    puts dataset_info if dataset_info
  end

  def format_test_specific_info(result, formatter)
    case result[:test_type]
    when :independence
      format_independence_info(result, formatter)
    when :goodness_of_fit
      format_goodness_of_fit_info(result, formatter)
    end
  end

  def format_independence_info(result, formatter)
    return unless result[:cramers_v]

    formatter.format_effect_size("Cramér's V (効果量)", result[:cramers_v], @options[:precision])
  end

  def format_goodness_of_fit_info(result, formatter)
    formatter.format_frequencies(
      result[:observed_frequencies],
      result[:expected_frequencies],
      @options[:precision]
    )
  end

  def test_type_japanese(type)
    case type
    when :independence
      '独立性検定'
    when :goodness_of_fit
      '適合度検定'
    else
      type.to_s
    end
  end

  def show_help
    puts <<~HELP
      chi-square - #{self.class.description}

      Usage: number_analyzer chi-square [OPTIONS] [DATA...]

      Test Types:
        Independence:     Test association between categorical variables
        Goodness-of-fit:  Test if data fits expected distribution

      Options:
        --help                        Show this help message
        --independence                Perform independence test
        --goodness-of-fit             Perform goodness-of-fit test
        --uniform                     Test against uniform distribution
        --file FILE                   Read data from file
        --format FORMAT               Output format (json)
        --precision N                 Number of decimal places
        --quiet                       Minimal output (p-value only)

      Examples:
        # Independence test with contingency table
        number_analyzer chi-square --independence 30 20 -- 15 35
        number_analyzer chi-square --independence --file contingency.csv

        # Goodness-of-fit test with observed and expected
        number_analyzer chi-square --goodness-of-fit observed.csv expected.csv
        number_analyzer chi-square --goodness-of-fit 8 12 10 15 9 6 10 10 10 10 10 10

        # Test against uniform distribution
        number_analyzer chi-square --uniform 8 12 10 15 9 6

        # JSON output with precision
        number_analyzer chi-square --format=json --precision=3 --independence 30 20 -- 15 35
    HELP
  end

  def default_options
    super.merge({
                  independence: false,
                  goodness_of_fit: false,
                  uniform: false
                })
  end
end
