# frozen_string_literal: true

require_relative '../base_command'

# Command for performing statistical t-test analysis (independent, paired, one-sample)
class NumberAnalyzer::Commands::TTestCommand < NumberAnalyzer::Commands::BaseCommand
  command 't-test', 'Perform statistical t-test analysis'

  private

  def validate_arguments(args)
    return if @options[:help]

    test_type = determine_test_type

    case test_type
    when :one_sample
      validate_one_sample_args(args)
    when :paired, :independent
      validate_two_sample_args(args)
    end
  end

  def parse_input(args)
    test_type = determine_test_type

    case test_type
    when :one_sample
      parse_one_sample_input(args)
    when :independent
      parse_independent_input(args)
    when :paired
      parse_paired_input(args)
    end
  end

  def determine_test_type
    return :paired if @options[:paired]
    return :one_sample if @options[:one_sample] || @options[:population_mean] || @options[:mu]

    :independent
  end

  def validate_one_sample_args(_args)
    population_mean = @options[:population_mean] || @options[:mu]
    return if population_mean

    raise ArgumentError, <<~ERROR
      エラー: 一標本t検定には母集団平均が必要です。
      使用例: number_analyzer t-test --one-sample --population-mean=100 data.csv
    ERROR
  end

  def validate_two_sample_args(args)
    # Valid cases: file mode or args with '--' separator
    return if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
    return if args.include?('--')

    raise ArgumentError, <<~ERROR
      エラー: 2つのデータセットが必要です。
      使用例: number_analyzer t-test 1 2 3 -- 4 5 6
             number_analyzer t-test group1.csv group2.csv
    ERROR
  end

  def parse_one_sample_input(args)
    require_relative '../data_input_handler'
    NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
  end

  def parse_independent_input(args)
    if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
      parse_file_datasets(args)
    elsif args.include?('--')
      parse_numeric_datasets(args)
    else
      raise ArgumentError, <<~ERROR
        エラー: 2つのデータセットを区切るために "--" を使用するか、2つのファイルを指定してください。
        使用例: number_analyzer t-test 1 2 3 -- 4 5 6
               number_analyzer t-test group1.csv group2.csv
      ERROR
    end
  end

  def parse_paired_input(args)
    parse_independent_input(args) # Same parsing logic, different validation later
  end

  def parse_file_datasets(files)
    dataset1 = NumberAnalyzer::FileReader.read_from_file(files[0])
    dataset2 = NumberAnalyzer::FileReader.read_from_file(files[1])
    [dataset1, dataset2]
  rescue StandardError => e
    raise ArgumentError, "ファイル読み込みエラー: #{e.message}"
  end

  def parse_numeric_datasets(args)
    separator_index = args.index('--')

    dataset1_args = args[0...separator_index]
    dataset2_args = args[(separator_index + 1)..]

    raise ArgumentError, 'エラー: 両方のデータセットに値が必要です。' if dataset1_args.empty? || dataset2_args.empty?

    dataset1 = parse_numbers(dataset1_args)
    dataset2 = parse_numbers(dataset2_args)
    [dataset1, dataset2]
  end

  def parse_numbers(args)
    args.map do |arg|
      Float(arg)
    rescue ArgumentError
      raise ArgumentError, "無効な数値: #{arg}"
    end
  end

  def perform_calculation(data)
    test_type = determine_test_type

    case test_type
    when :one_sample
      perform_one_sample_test(data)
    when :independent
      perform_independent_test(data)
    when :paired
      perform_paired_test(data)
    end
  end

  def perform_one_sample_test(data)
    population_mean = @options[:population_mean] || @options[:mu]

    begin
      population_mean = Float(population_mean)
    rescue ArgumentError
      raise ArgumentError, "エラー: 無効な母集団平均です: #{population_mean}"
    end

    analyzer = NumberAnalyzer.new(data)
    result = analyzer.t_test(nil, type: :one_sample, population_mean: population_mean)

    raise ArgumentError, 'エラー: 一標本t検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :one_sample,
                   dataset_size: data.size,
                   population_mean: population_mean
                 })
  end

  def perform_independent_test(data)
    dataset1, dataset2 = data

    if (dataset1.length - dataset2.length).abs > dataset1.length
      raise ArgumentError,
            "エラー: データセットの長さが大きく異なります (#{dataset1.length} vs #{dataset2.length})"
    end

    analyzer = NumberAnalyzer.new(dataset1)
    result = analyzer.t_test(dataset2, type: :independent)

    raise ArgumentError, 'エラー: t検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :independent,
                   dataset1_size: dataset1.size,
                   dataset2_size: dataset2.size
                 })
  end

  def perform_paired_test(data)
    dataset1, dataset2 = data

    raise ArgumentError, "エラー: 対応のあるデータのため、両グループは同じ長さである必要があります (#{dataset1.length} vs #{dataset2.length})" if dataset1.length != dataset2.length

    analyzer = NumberAnalyzer.new(dataset1)
    result = analyzer.t_test(dataset2, type: :paired)

    raise ArgumentError, 'エラー: 対応ありt検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :paired,
                   dataset1_size: dataset1.size,
                   dataset2_size: dataset2.size
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
    t_statistic = result[:t_statistic]
    p_value = result[:p_value]
    degrees_freedom = result[:degrees_of_freedom]
    significant = result[:significant]

    puts "t検定結果 (#{test_type_japanese(test_type)}):"
    puts ''

    formatted_t = if @options[:precision]
                    format("%.#{@options[:precision]}f", t_statistic)
                  else
                    format('%.4f', t_statistic)
                  end

    formatted_p = if @options[:precision]
                    format("%.#{@options[:precision]}f", p_value)
                  else
                    format('%.6f', p_value)
                  end

    puts "t統計量: #{formatted_t}"
    puts "自由度: #{degrees_freedom}"
    puts "p値: #{formatted_p}"
    puts "有意性 (α=0.05): #{significant ? '有意' : '有意でない'}"

    # Additional info based on test type
    case test_type
    when :one_sample
      puts "母集団平均: #{result[:population_mean]}"
      puts "標本サイズ: #{result[:dataset_size]}"
    when :independent
      puts "グループ1のサイズ: #{result[:dataset1_size]}"
      puts "グループ2のサイズ: #{result[:dataset2_size]}"
    when :paired
      puts "ペア数: #{result[:dataset1_size]}"
    end
  end

  def test_type_japanese(type)
    case type
    when :one_sample
      '一標本'
    when :independent
      '独立2標本'
    when :paired
      '対応あり'
    else
      type.to_s
    end
  end

  def show_help
    puts <<~HELP
      t-test - #{self.class.description}

      Usage: number_analyzer t-test [OPTIONS] [DATA...]

      Test Types:
        Independent samples (default): Compare two independent groups
        Paired samples:               Compare paired/matched data#{'  '}
        One-sample:                   Compare sample to known population mean

      Options:
        --help                        Show this help message
        --paired                      Perform paired samples t-test
        --one-sample                  Perform one-sample t-test
        --population-mean MEAN        Population mean for one-sample test
        --mu MEAN                     Population mean (alias for --population-mean)
        --format FORMAT               Output format (json)
        --precision N                 Number of decimal places
        --quiet                       Minimal output (p-value only)

      Examples:
        # Independent samples t-test
        number_analyzer t-test 1 2 3 -- 4 5 6
        number_analyzer t-test group1.csv group2.csv

        # Paired samples t-test
        number_analyzer t-test --paired before.csv after.csv
        number_analyzer t-test --paired 10 12 14 -- 15 18 20

        # One-sample t-test
        number_analyzer t-test --one-sample --population-mean=100 --file data.csv
        number_analyzer t-test --one-sample --mu=50 45 48 52 49

        # JSON output with precision
        number_analyzer t-test --format=json --precision=3 group1.csv group2.csv
    HELP
  end

  def default_options
    super.merge({
                  paired: false,
                  one_sample: false,
                  population_mean: nil,
                  mu: nil
                })
  end
end
