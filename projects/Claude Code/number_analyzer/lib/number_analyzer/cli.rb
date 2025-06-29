# frozen_string_literal: true

require 'optparse'
require_relative '../number_analyzer'
require_relative 'file_reader'
require_relative 'output_formatter'

# Command Line Interface for NumberAnalyzer
class NumberAnalyzer
  # Handles command-line argument parsing and validation for NumberAnalyzer
  class CLI
    # Mapping of subcommands to their handler methods
    COMMANDS = {
      'median' => :run_median,
      'mean' => :run_mean,
      'mode' => :run_mode,
      'sum' => :run_sum,
      'min' => :run_min,
      'max' => :run_max,
      'histogram' => :run_histogram,
      'outliers' => :run_outliers,
      'percentile' => :run_percentile,
      'quartiles' => :run_quartiles,
      'variance' => :run_variance,
      'std' => :run_standard_deviation,
      'deviation-scores' => :run_deviation_scores,
      'correlation' => :run_correlation,
      'trend' => :run_trend,
      'moving-average' => :run_moving_average,
      'growth-rate' => :run_growth_rate,
      'seasonal' => :run_seasonal,
      't-test' => :run_t_test,
      'confidence-interval' => :run_confidence_interval,
      'chi-square' => :run_chi_square
    }.freeze

    # Main entry point for CLI
    def self.run(argv = ARGV)
      return run_full_analysis(argv) if argv.empty?

      # Check if first argument is a subcommand
      command = argv.first
      if COMMANDS.key?(command)
        run_subcommand(command, argv[1..])
      else
        # No subcommand provided, treat as full analysis with numeric arguments
        run_full_analysis(argv)
      end
    end

    def self.parse_arguments(argv = ARGV)
      options, remaining_args = parse_options(argv)

      if options[:file]
        begin
          FileReader.read_from_file(options[:file])
        rescue StandardError => e
          puts "ファイル読み込みエラー: #{e.message}"
          exit 1
        end
      elsif remaining_args.empty?
        # デフォルト配列を使用
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      else
        # コマンドライン引数から数値を取得
        parse_numeric_arguments(remaining_args)
      end
    end

    private_class_method def self.run_full_analysis(argv)
      numbers = parse_arguments(argv)
      analyzer = NumberAnalyzer.new(numbers)
      analyzer.calculate_statistics
    end

    private_class_method def self.run_subcommand(command, args)
      options, remaining_args = parse_options(args)
      method_name = COMMANDS[command]
      send(method_name, remaining_args, options)
    end

    # Parse command-line options using OptionParser
    private_class_method def self.parse_options(args)
      options = default_options
      parser = create_option_parser(options)

      remaining_args = parse_args_with_parser(parser, args)
      [options, remaining_args]
    end

    private_class_method def self.default_options
      {
        format: nil,
        precision: nil,
        quiet: false,
        help: false,
        file: nil,
        window: nil,
        period: nil,
        paired: false,
        one_sample: false,
        population_mean: nil,
        mu: nil,
        confidence_level: 95,
        independence: false,
        goodness_of_fit: false,
        uniform: false
      }
    end

    private_class_method def self.create_option_parser(options)
      OptionParser.new do |opts|
        opts.on('--format FORMAT', 'Output format (json)') { |format| options[:format] = format }
        opts.on('--precision N', Integer, 'Number of decimal places') { |precision| options[:precision] = precision }
        opts.on('--quiet', 'Quiet mode (minimal output)') do
          options[:quiet] = true
          options[:format] = 'quiet' unless options[:format]
        end
        opts.on('--help', 'Show help') { options[:help] = true }
        opts.on('--file FILE', '-f FILE', 'Read numbers from file') { |file| options[:file] = file }
        opts.on('--window N', Integer, 'Window size for moving average') { |window| options[:window] = window }
        opts.on('--period N', Integer, 'Period for seasonal analysis') { |period| options[:period] = period }
        opts.on('--paired', 'Perform paired samples t-test') { options[:paired] = true }
        opts.on('--one-sample', 'Perform one-sample t-test') { options[:one_sample] = true }
        opts.on('--population-mean MEAN', Float, 'Population mean for one-sample t-test') do |mean|
          options[:population_mean] = mean
        end
        opts.on('--mu MEAN', Float, 'Population mean for one-sample t-test (alias)') { |mean| options[:mu] = mean }
        opts.on('--level LEVEL', Float, 'Confidence level (default: 95)') { |level| options[:confidence_level] = level }
        opts.on('--independence', 'Perform independence test for chi-square') { options[:independence] = true }
        opts.on('--goodness-of-fit', 'Perform goodness-of-fit test for chi-square') { options[:goodness_of_fit] = true }
        opts.on('--uniform', 'Use uniform distribution for goodness-of-fit test') { options[:uniform] = true }
      end
    end

    private_class_method def self.parse_args_with_parser(parser, args)
      parser.parse(args)
    rescue OptionParser::InvalidOption => e
      puts "エラー: #{e.message}"
      exit 1
    rescue OptionParser::MissingArgument => e
      if e.message.include?('--file')
        puts 'エラー: --fileオプションにはファイルパスを指定してください。'
      else
        puts "エラー: #{e.message}"
      end
      exit 1
    rescue OptionParser::InvalidArgument => e
      if e.message.include?('--precision')
        warn 'invalid value for Integer'
      else
        puts "エラー: #{e.message}"
      end
      exit 1
    end

    # Show help information for a specific command
    private_class_method def self.show_help(command, description)
      puts "Usage: bundle exec number_analyzer #{command} [options] numbers..."
      puts ''
      puts "Description: #{description}"
      puts ''
      puts 'Options:'
      puts '  --format json     Output in JSON format'
      puts '  --precision N     Round to N decimal places'
      puts '  --quiet          Minimal output (no labels)'
      puts '  --file FILE, -f  Read numbers from file'
      puts '  --help           Show this help'
      puts ''
      puts 'Examples:'
      puts "  bundle exec number_analyzer #{command} 1 2 3 4 5"
      puts "  bundle exec number_analyzer #{command} --format=json 1 2 3"
      puts "  bundle exec number_analyzer #{command} --precision=2 1.234 2.567"
      puts "  bundle exec number_analyzer #{command} --file data.csv"
    end

    # Parse numbers from arguments and options, handling file input
    private_class_method def self.parse_numbers_with_options(args, options)
      if options[:file]
        begin
          FileReader.read_from_file(options[:file])
        rescue StandardError => e
          puts "ファイル読み込みエラー: #{e.message}"
          exit 1
        end
      elsif args.empty?
        puts 'エラー: 数値または --file オプションを指定してください。'
        exit 1
      else
        parse_numeric_arguments(args)
      end
    end

    # Subcommand implementations
    private_class_method def self.run_median(args, options = {})
      if options[:help]
        show_help('median', 'Calculate the median (middle value) of numbers')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.median

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_mean(args, options = {})
      if options[:help]
        show_help('mean', 'Calculate the arithmetic mean (average) of numbers')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.send(:average_value)

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_mode(args, options = {})
      if options[:help]
        show_help('mode', 'Find the most frequently occurring value(s)')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      mode_values = analyzer.mode

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_mode(mode_values, options)
    end

    private_class_method def self.run_sum(args, options = {})
      if options[:help]
        show_help('sum', 'Calculate the sum of all numbers')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      result = numbers.sum

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_min(args, options = {})
      if options[:help]
        show_help('min', 'Find the minimum (smallest) value')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      result = numbers.min

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_max(args, options = {})
      if options[:help]
        show_help('max', 'Find the maximum (largest) value')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      result = numbers.max

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_histogram(args, options = {})
      if options[:help]
        show_help('histogram', 'Display frequency distribution histogram')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      display_histogram_output(analyzer, numbers.size, options)
    end

    private_class_method def self.display_histogram_output(analyzer, dataset_size, options)
      case options[:format]
      when 'json'
        display_histogram_json(analyzer, dataset_size)
      when 'quiet'
        display_histogram_quiet(analyzer)
      else
        analyzer.display_histogram
      end
    end

    private_class_method def self.display_histogram_json(analyzer, dataset_size)
      frequency_dist = analyzer.frequency_distribution
      result = { histogram: frequency_dist, dataset_size: dataset_size }
      puts JSON.generate(result)
    end

    private_class_method def self.display_histogram_quiet(analyzer)
      frequency_dist = analyzer.frequency_distribution
      puts frequency_dist.map { |value, count| "#{value}:#{count}" }.join(' ')
    end

    private_class_method def self.run_outliers(args, options = {})
      if options[:help]
        show_help('outliers', 'Detect outliers using IQR * 1.5 rule')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      outlier_values = analyzer.outliers

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_outliers(outlier_values, options)
    end

    private_class_method def self.run_percentile(args, options = {})
      if options[:help]
        show_help('percentile', 'Calculate percentile value (0-100)')
        return
      end

      validate_percentile_args(args, options)

      percentile_value_str = args[0]
      numbers = parse_percentile_numbers(args, options)
      percentile_value = parse_percentile_value(percentile_value_str)

      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.percentile(percentile_value)

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.validate_percentile_args(args, options = {})
      return unless args.empty? || (!options[:file] && args.length < 2)

      puts 'エラー: percentileコマンドには percentile値と数値が必要です。'
      puts '使用例: bundle exec number_analyzer percentile 75 1 2 3 4 5'
      exit 1
    end

    private_class_method def self.parse_percentile_numbers(args, options = {})
      if options[:file]
        parse_percentile_file_input(options[:file])
      else
        parse_numeric_arguments(args[1..])
      end
    end

    private_class_method def self.parse_percentile_file_input(file_path)
      FileReader.read_from_file(file_path)
    rescue StandardError => e
      puts "ファイル読み込みエラー: #{e.message}"
      exit 1
    end

    private_class_method def self.parse_percentile_value(percentile_value_str)
      percentile_value = Float(percentile_value_str)
      if percentile_value.negative? || percentile_value > 100
        puts 'エラー: percentile値は0-100の範囲で指定してください。'
        exit 1
      end
      percentile_value
    rescue ArgumentError
      puts 'エラー: 無効なpercentile値です。数値を指定してください。'
      exit 1
    end

    private_class_method def self.run_quartiles(args, options = {})
      if options[:help]
        show_help('quartiles', 'Calculate Q1, Q2 (median), and Q3 values')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      quartiles = analyzer.quartiles

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_quartiles(quartiles, options)
    end

    private_class_method def self.run_variance(args, options = {})
      if options[:help]
        show_help('variance', 'Calculate variance (measure of data spread)')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.variance

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_standard_deviation(args, options = {})
      if options[:help]
        show_help('std', 'Calculate standard deviation')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.standard_deviation

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_value(result, options)
    end

    private_class_method def self.run_deviation_scores(args, options = {})
      if options[:help]
        show_help('deviation-scores', 'Calculate standardized deviation scores')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      deviation_scores = analyzer.deviation_scores

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_array(deviation_scores, options)
    end

    private_class_method def self.run_correlation(args, options = {})
      if options[:help]
        show_help('correlation', 'Calculate Pearson correlation coefficient between two datasets')
        return
      end

      validate_correlation_args(args, options)
      dataset1, dataset2 = parse_correlation_datasets(args, options)

      analyzer = NumberAnalyzer.new(dataset1)
      result = analyzer.correlation(dataset2)

      options[:dataset_size] = dataset1.size
      puts OutputFormatter.format_correlation(result, options)
    end

    private_class_method def self.validate_correlation_args(args, options = {})
      if options[:file]
        # File mode: expect one or two file paths
        return if args.length.between?(1, 2)
      elsif args.length >= 4 && args.length.even?
        # CLI mode: expect at least two numbers for each dataset
        return
      end

      puts 'エラー: correlationコマンドには2つのデータセットが必要です。'
      puts 'ファイル: bundle exec number_analyzer correlation file1.csv file2.csv'
      puts '数値: bundle exec number_analyzer correlation 1 2 3 4 5 6'
      exit 1
    end

    private_class_method def self.parse_correlation_datasets(args, options = {})
      if options[:file]
        parse_correlation_file_datasets(args, options)
      else
        parse_correlation_numeric_datasets(args)
      end
    end

    private_class_method def self.parse_correlation_file_datasets(args, options)
      if args.length == 2
        # Two separate files
        dataset1 = FileReader.read_from_file(args[0])
        dataset2 = FileReader.read_from_file(args[1])
      else
        # Single file mode - split in half
        combined_data = FileReader.read_from_file(options[:file])
        mid = combined_data.length / 2
        dataset1 = combined_data[0...mid]
        dataset2 = combined_data[mid..]
      end
      [dataset1, dataset2]
    rescue StandardError => e
      puts "ファイル読み込みエラー: #{e.message}"
      exit 1
    end

    private_class_method def self.parse_correlation_numeric_datasets(args)
      mid = args.length / 2
      dataset1 = parse_numeric_arguments(args[0...mid])
      dataset2 = parse_numeric_arguments(args[mid..])
      [dataset1, dataset2]
    end

    private_class_method def self.run_trend(args, options = {})
      if options[:help]
        show_help('trend', 'Calculate linear trend analysis (slope, intercept, R²)')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.linear_trend

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_trend(result, options)
    end

    private_class_method def self.run_moving_average(args, options = {})
      if options[:help]
        show_help('moving-average', 'Calculate moving average with specified window size')
        return
      end

      # Parse window size from options or use default
      window_size = options[:window] || 3
      begin
        window_size = Integer(window_size)
      rescue ArgumentError
        puts "エラー: 無効なウィンドウサイズです: #{options[:window]}"
        puts '正の整数を指定してください。'
        exit 1
      end

      if window_size <= 0
        puts 'エラー: ウィンドウサイズは正の整数である必要があります。'
        exit 1
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.moving_average(window_size)

      options[:dataset_size] = numbers.size
      options[:window_size] = window_size
      puts OutputFormatter.format_moving_average(result, options)
    end

    private_class_method def self.run_growth_rate(args, options = {})
      if options[:help]
        show_help('growth-rate', 'Analyze growth rates including period-over-period rates and CAGR')
        return
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)

      # Calculate growth rate metrics
      growth_rates = analyzer.growth_rates
      cagr = analyzer.compound_annual_growth_rate
      avg_growth = analyzer.average_growth_rate

      result = {
        growth_rates: growth_rates,
        compound_annual_growth_rate: cagr,
        average_growth_rate: avg_growth
      }

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_growth_rate(result, options)
    end

    private_class_method def self.run_seasonal(args, options = {})
      if options[:help]
        show_help('seasonal', 'Analyze seasonal patterns and decomposition')
        return
      end

      # Parse period from options if provided
      period = options[:period]
      if period
        begin
          period = Integer(period)
        rescue ArgumentError
          puts "エラー: 無効な周期です: #{options[:period]}"
          puts '正の整数を指定してください。'
          exit 1
        end

        if period < 2
          puts 'エラー: 周期は2以上である必要があります。'
          exit 1
        end
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.seasonal_decomposition(period)

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_seasonal(result, options)
    end

    private_class_method def self.run_t_test(args, options = {})
      if options[:help]
        show_help('t-test', 'Perform statistical t-test analysis')
        return
      end

      test_type = determine_t_test_type(options)
      execute_t_test_by_type(test_type, args, options)
    end

    private_class_method def self.determine_t_test_type(options)
      return :paired if options[:paired]
      return :one_sample if options[:one_sample] || options[:population_mean]

      :independent
    end

    private_class_method def self.execute_t_test_by_type(test_type, args, options)
      case test_type
      when :independent
        run_independent_t_test(args, options)
      when :paired
        run_paired_t_test(args, options)
      when :one_sample
        run_one_sample_t_test(args, options)
      end
    end

    private_class_method def self.run_independent_t_test(args, options)
      validate_independent_t_test_args(args)
      dataset1, dataset2 = parse_independent_t_test_datasets(args)
      execute_independent_t_test(dataset1, dataset2, options)
    end

    private_class_method def self.run_paired_t_test(args, options)
      validate_paired_t_test_args(args)
      dataset1, dataset2 = parse_paired_t_test_datasets(args)
      execute_paired_t_test(dataset1, dataset2, options)
    end

    private_class_method def self.run_one_sample_t_test(args, options)
      # Need population mean
      population_mean = options[:population_mean] || options[:mu]
      unless population_mean
        puts 'エラー: 一標本t検定には母集団平均が必要です。'
        puts '使用例: bundle exec number_analyzer t-test --one-sample --population-mean=100 data.csv'
        exit 1
      end

      begin
        population_mean = Float(population_mean)
      rescue ArgumentError
        puts "エラー: 無効な母集団平均です: #{population_mean}"
        exit 1
      end

      numbers = parse_numbers_with_options(args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.t_test(nil, type: :one_sample, population_mean: population_mean)

      if result.nil?
        puts 'エラー: 一標本t検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_t_test(result, options)
    end

    private_class_method def self.validate_independent_t_test_args(args)
      return unless args.length < 2

      puts 'エラー: 独立2標本t検定には2つのデータセットが必要です。'
      puts '使用例: bundle exec number_analyzer t-test group1.csv group2.csv'
      puts '       bundle exec number_analyzer t-test 1 2 3 -- 4 5 6'
      exit 1
    end

    private_class_method def self.parse_independent_t_test_datasets(args)
      if args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
        parse_file_datasets(args)
      else
        parse_numeric_datasets(args)
      end
    end

    private_class_method def self.parse_file_datasets(args)
      unless args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
        puts 'エラー: ファイル入力モードでは2つのファイルが必要です。'
        exit 1
      end

      dataset1 = FileReader.read_from_file(args[0])
      dataset2 = FileReader.read_from_file(args[1])
      [dataset1, dataset2]
    end

    private_class_method def self.parse_numeric_datasets(args)
      separator_index = args.index('--')
      if separator_index.nil?
        puts 'エラー: 2つのデータセットを区切るために "--" を使用してください。'
        puts '使用例: bundle exec number_analyzer t-test 1 2 3 -- 4 5 6'
        exit 1
      end

      dataset1_args = args[0...separator_index]
      dataset2_args = args[(separator_index + 1)..]

      if dataset1_args.empty? || dataset2_args.empty?
        puts 'エラー: 両方のデータセットに値が必要です。'
        exit 1
      end

      dataset1 = parse_numeric_arguments(dataset1_args)
      dataset2 = parse_numeric_arguments(dataset2_args)
      [dataset1, dataset2]
    end

    private_class_method def self.execute_independent_t_test(dataset1, dataset2, options)
      analyzer = NumberAnalyzer.new(dataset1)
      result = analyzer.t_test(dataset2, type: :independent)

      if result.nil?
        puts 'エラー: t検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset1_size] = dataset1.size
      options[:dataset2_size] = dataset2.size
      puts OutputFormatter.format_t_test(result, options)
    end

    private_class_method def self.validate_paired_t_test_args(args)
      return unless args.length < 2

      puts 'エラー: 対応ありt検定には2つのデータセットが必要です。'
      puts '使用例: bundle exec number_analyzer t-test --paired before.csv after.csv'
      exit 1
    end

    private_class_method def self.parse_paired_t_test_datasets(args)
      if args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
        parse_file_datasets(args)
      else
        parse_paired_numeric_datasets(args)
      end
    end

    private_class_method def self.parse_paired_numeric_datasets(args)
      separator_index = args.index('--')
      if separator_index.nil?
        puts 'エラー: 2つのデータセットを区切るために "--" を使用してください。'
        puts '使用例: bundle exec number_analyzer t-test --paired 1 2 3 -- 1.5 2.5 3.5'
        exit 1
      end

      dataset1_args = args[0...separator_index]
      dataset2_args = args[(separator_index + 1)..]

      dataset1 = parse_numeric_arguments(dataset1_args)
      dataset2 = parse_numeric_arguments(dataset2_args)
      [dataset1, dataset2]
    end

    private_class_method def self.execute_paired_t_test(dataset1, dataset2, options)
      analyzer = NumberAnalyzer.new(dataset1)
      result = analyzer.t_test(dataset2, type: :paired)

      if result.nil?
        puts 'エラー: 対応ありt検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset1_size] = dataset1.size
      options[:dataset2_size] = dataset2.size
      puts OutputFormatter.format_t_test(result, options)
    end

    private_class_method def self.run_confidence_interval(args, options = {})
      if options[:help]
        show_help('confidence-interval', 'Calculate confidence interval for population mean')
        return
      end

      # Parse confidence level from first argument or use option
      confidence_level = parse_confidence_level_from_args(args, options)
      remaining_args = confidence_level_from_args?(args) ? args[1..] : args

      numbers = parse_numbers_with_options(remaining_args, options)
      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.confidence_interval(confidence_level)

      if result.nil?
        puts 'エラー: 信頼区間を計算できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset_size] = numbers.size
      puts OutputFormatter.format_confidence_interval(result, options)
    end

    private_class_method def self.parse_confidence_level_from_args(args, options)
      # Check if first argument is a confidence level (number between 1-99)
      level = if confidence_level_from_args?(args)
                Float(args[0])
              else
                # Use option or default
                options[:confidence_level] || 95
              end

      validate_confidence_level(level)
      level
    rescue ArgumentError
      puts "エラー: 無効な信頼度です: #{args[0]}"
      puts '信頼度は1-99の範囲で指定してください。'
      exit 1
    end

    private_class_method def self.confidence_level_from_args?(args)
      return false if args.empty?

      begin
        level = Float(args[0])
        # Only consider it a confidence level if it's a reasonable confidence level
        # and there are more arguments (the data values)
        level.between?(80, 99) && args.length > 1
      rescue ArgumentError
        false
      end
    end

    private_class_method def self.validate_confidence_level(level)
      return if level.between?(1, 99)

      puts "エラー: 信頼度は1-99の範囲で指定してください: #{level}"
      exit 1
    end

    private_class_method def self.parse_numeric_arguments(argv)
      invalid_args = []
      numbers = argv.map do |arg|
        Float(arg)
      rescue ArgumentError
        invalid_args << arg
        nil
      end.compact

      unless invalid_args.empty?
        puts "エラー: 無効な引数が見つかりました: #{invalid_args.join(', ')}"
        puts '数値のみを入力してください。'
        exit 1
      end

      if numbers.empty?
        puts 'エラー: 有効な数値が見つかりませんでした。'
        exit 1
      end

      numbers
    end

    private_class_method def self.run_chi_square(args, options = {})
      if options[:help]
        show_help('chi-square', 'Perform chi-square test for independence or goodness-of-fit')
        return
      end

      # Determine test type
      test_type = determine_chi_square_test_type(options)

      case test_type
      when :independence
        run_chi_square_independence_test(args, options)
      when :goodness_of_fit
        run_chi_square_goodness_of_fit_test(args, options)
      else
        puts 'エラー: カイ二乗検定のタイプを指定してください。'
        puts '使用例: bundle exec number_analyzer chi-square --independence contingency.csv'
        puts '       bundle exec number_analyzer chi-square --goodness-of-fit observed.csv expected.csv'
        exit 1
      end
    end

    private_class_method def self.determine_chi_square_test_type(options)
      return :independence if options[:independence]
      return :goodness_of_fit if options[:goodness_of_fit] || options[:uniform]

      # Default to independence if contingency table data is provided
      # Default to goodness-of-fit if two datasets are provided
      nil
    end

    private_class_method def self.run_chi_square_independence_test(args, options)
      # For independence test, we expect a 2D contingency table
      if options[:file]
        # Read contingency table from file
        data = parse_numbers_with_options(args, options)
        # Convert flat array to 2D contingency table (assume square for now)
        dimension = Math.sqrt(data.length).to_i
        if dimension * dimension != data.length
          puts 'エラー: 独立性検定には正方形の分割表が必要です。'
          exit 1
        end
        contingency_table = data.each_slice(dimension).to_a
      else
        # Parse contingency table from command line arguments
        # Expected format: rows separated by '--'
        contingency_table = parse_contingency_table_from_args(args)
      end

      analyzer = NumberAnalyzer.new(contingency_table.flatten)
      result = analyzer.chi_square_test(contingency_table, type: :independence)

      if result.nil?
        puts 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset_size] = contingency_table.flatten.size
      puts OutputFormatter.format_chi_square(result, options)
    end

    private_class_method def self.run_chi_square_goodness_of_fit_test(args, options)
      if options[:uniform]
        # Uniform distribution test with single dataset
        observed = parse_numbers_with_options(args, options)
        analyzer = NumberAnalyzer.new(observed)
        result = analyzer.chi_square_test(nil, type: :goodness_of_fit) # nil = uniform distribution
      else
        # Two datasets: observed and expected
        if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
          # Two files provided
          observed = FileReader.read_from_file(args[0])
          expected = FileReader.read_from_file(args[1])
        elsif options[:file]
          # Single file with interleaved data
          combined_data = parse_numbers_with_options([], options)
          mid = combined_data.length / 2
          observed = combined_data[0...mid]
          expected = combined_data[mid..]
        else
          # Command line arguments: first half observed, second half expected
          mid = args.length / 2
          observed = parse_numeric_arguments(args[0...mid])
          expected = parse_numeric_arguments(args[mid..])
        end

        analyzer = NumberAnalyzer.new(observed)
        result = analyzer.chi_square_test(expected, type: :goodness_of_fit)
      end

      if result.nil?
        puts 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      options[:dataset_size] = result[:observed_frequencies].size
      puts OutputFormatter.format_chi_square(result, options)
    end

    private_class_method def self.parse_contingency_table_from_args(args)
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

      if rows.empty? || rows.any?(&:empty?)
        puts 'エラー: 有効な分割表を作成できませんでした。'
        puts '使用例: bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
        exit 1
      end

      rows
    rescue ArgumentError
      puts 'エラー: 無効な数値が含まれています。'
      puts '使用例: bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
      exit 1
    end
  end
end

# 実行部分（スクリプトとして実行された場合のみ）
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
