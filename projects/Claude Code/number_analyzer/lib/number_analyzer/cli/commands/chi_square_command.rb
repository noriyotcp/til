# frozen_string_literal: true

require_relative '../base_command'

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
    # Parse contingency table where rows are separated by '--'
    # Example: 30 20 -- 15 35 (creates [[30, 20], [15, 35]])

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

    # Validate contingency table
    if rows.empty? || rows.any?(&:empty?)
      raise ArgumentError, <<~ERROR
        エラー: 有効な分割表を作成できませんでした。
        使用例: number_analyzer chi-square --independence 30 20 -- 15 35
      ERROR
    end

    # Ensure we have at least 2x2 table
    if rows.length < 2
      raise ArgumentError, <<~ERROR
        エラー: 独立性検定には少なくとも2x2の分割表が必要です。
        使用例: number_analyzer chi-square --independence 30 20 -- 15 35
      ERROR
    end

    # Ensure all rows have same number of columns
    col_count = rows.first.length
    raise ArgumentError, 'エラー: 分割表の各行は同じ列数である必要があります。' if rows.any? { |row| row.length != col_count }

    rows
  rescue ArgumentError => e
    raise e
  rescue StandardError
    raise ArgumentError, <<~ERROR
      エラー: 無効な数値が含まれています。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def parse_observed_expected_datasets(args)
    if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
      # Two files provided
      observed = NumberAnalyzer::FileReader.read_from_file(args[0])
      expected = NumberAnalyzer::FileReader.read_from_file(args[1])
    elsif @options[:file]
      # Single file with interleaved data
      require_relative '../data_input_handler'
      combined_data = NumberAnalyzer::Commands::DataInputHandler.parse([], @options)
      mid = combined_data.length / 2
      observed = combined_data[0...mid]
      expected = combined_data[mid..]
    else
      # Command line arguments: first half observed, second half expected
      mid = args.length / 2
      observed = parse_numbers(args[0...mid])
      expected = parse_numbers(args[mid..])
    end
    [observed, expected]
  rescue StandardError => e
    raise ArgumentError, "ファイル読み込みエラー: #{e.message}"
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
    test_type = result[:test_type]
    chi_square = result[:chi_square_statistic]
    p_value = result[:p_value]
    degrees_freedom = result[:degrees_of_freedom]
    significant = result[:significant]

    puts "カイ二乗検定結果 (#{test_type_japanese(test_type)}):"
    puts ''

    formatted_chi = if @options[:precision]
                      format("%.#{@options[:precision]}f", chi_square)
                    else
                      format('%.4f', chi_square)
                    end

    formatted_p = if @options[:precision]
                    format("%.#{@options[:precision]}f", p_value)
                  else
                    format('%.6f', p_value)
                  end

    puts "カイ二乗統計量: #{formatted_chi}"
    puts "自由度: #{degrees_freedom}"
    puts "p値: #{formatted_p}"
    puts "有意性 (α=0.05): #{significant ? '有意' : '有意でない'}"

    # Additional information based on test type
    case test_type
    when :independence
      if result[:cramers_v]
        formatted_cramers = if @options[:precision]
                              format("%.#{@options[:precision]}f", result[:cramers_v])
                            else
                              format('%.4f', result[:cramers_v])
                            end
        puts "Cramér's V (効果量): #{formatted_cramers}"
      end
    when :goodness_of_fit
      puts "観測度数: #{result[:observed_frequencies].join(', ')}"
      if result[:expected_frequencies]
        formatted_expected = result[:expected_frequencies].map do |freq|
          if @options[:precision]
            format("%.#{@options[:precision]}f", freq)
          else
            format('%.2f', freq)
          end
        end
        puts "期待度数: #{formatted_expected.join(', ')}"
      end
    end

    puts "データサイズ: #{result[:dataset_size]}"
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
