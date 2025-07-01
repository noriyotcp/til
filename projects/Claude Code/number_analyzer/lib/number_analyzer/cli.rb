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
      'chi-square' => :run_chi_square,
      'anova' => :run_anova,
      'two-way-anova' => :run_two_way_anova,
      'levene' => :run_levene,
      'bartlett' => :run_bartlett,
      'kruskal-wallis' => :run_kruskal_wallis,
      'mann-whitney' => :run_mann_whitney,
      'wilcoxon' => :run_wilcoxon,
      'friedman' => :run_friedman
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
      # Special handling for commands that use '--' separators
      if %w[chi-square anova levene bartlett kruskal-wallis mann-whitney
            wilcoxon friedman].include?(command) && args.include?('--')
        # Find where options end and data begins
        options = default_options
        data_start_index = 0

        # Process only option flags, not data
        args.each_with_index do |arg, index|
          case arg
          when '--independence'
            options[:independence] = true
          when '--goodness-of-fit'
            options[:goodness_of_fit] = true
          when '--uniform'
            options[:uniform] = true
          when '--post-hoc'
            options[:post_hoc] = args[index + 1] if index + 1 < args.length
          when /^--post-hoc=(.+)$/
            options[:post_hoc] = Regexp.last_match(1)
          when '--alpha'
            options[:alpha] = args[index + 1].to_f if index + 1 < args.length
          when /^--alpha=(.+)$/
            options[:alpha] = Regexp.last_match(1).to_f
          when '--format'
            options[:format] = args[index + 1] if index + 1 < args.length
          when /^--format=(.+)$/
            options[:format] = Regexp.last_match(1)
          when '--precision'
            options[:precision] = args[index + 1].to_i if index + 1 < args.length
          when /^--precision=(\d+)$/
            options[:precision] = Regexp.last_match(1).to_i
          when '--quiet'
            options[:quiet] = true
            options[:format] = 'quiet' unless options[:format]
          when '--help'
            options[:help] = true
          when '--file', '-f'
            options[:file] = args[index + 1] if index + 1 < args.length
          else
            # Found first non-option argument
            is_option_flag = arg.start_with?('--')
            is_option_value = index.positive? && args[index - 1] =~ /^--(format|precision|file|post-hoc|alpha)$/
            unless is_option_flag || is_option_value
              data_start_index = index
              break
            end
          end
        end

        remaining_args = args[data_start_index..]
      else
        # Standard option parsing for other commands
        options, remaining_args = parse_options(args)
      end
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
        uniform: false,
        factor_a: nil,
        factor_b: nil
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
        opts.on('--factor-a LEVELS', 'Factor A levels (comma-separated)') do |levels|
          options[:factor_a] = levels.split(',')
        end
        opts.on('--factor-b LEVELS', 'Factor B levels (comma-separated)') do |levels|
          options[:factor_b] = levels.split(',')
        end
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

    # Show help information for chi-square command
    private_class_method def self.show_chi_square_help
      puts 'Usage: bundle exec number_analyzer chi-square [options] numbers...'
      puts ''
      puts 'Description: Perform chi-square test for independence or goodness-of-fit'
      puts ''
      puts 'Options:'
      puts '  --independence    Perform independence test'
      puts '  --goodness-of-fit Perform goodness-of-fit test'
      puts '  --uniform        Test against uniform distribution'
      puts '  --format json     Output in JSON format'
      puts '  --precision N     Round to N decimal places'
      puts '  --quiet          Minimal output (no labels)'
      puts '  --file FILE, -f  Read numbers from file'
      puts '  --help           Show this help'
      puts ''
      puts 'Examples:'
      puts '  bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
      puts '  bundle exec number_analyzer chi-square --goodness-of-fit observed.csv expected.csv'
      puts '  bundle exec number_analyzer chi-square --uniform 8 12 10 15 9 6'
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
        show_chi_square_help
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
        # Try to read as CSV with multiple rows first
        begin
          file_path = options[:file]
          if File.exist?(file_path)
            lines = File.readlines(file_path)
            contingency_table = lines.map do |line|
              line.strip.split(',').map(&:to_f)
            end
            # Validate that all rows have same number of columns
            col_count = contingency_table.first&.length
            if contingency_table.any? { |row| row.length != col_count }
              puts 'エラー: 分割表の各行は同じ列数である必要があります。'
              exit 1
            end
          else
            puts "エラー: ファイルが見つかりません: #{file_path}"
            exit 1
          end
        rescue StandardError => e
          puts "エラー: ファイル読み込み中にエラーが発生しました: #{e.message}"
          exit 1
        end
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

      # Validate contingency table
      if rows.empty? || rows.any?(&:empty?)
        puts 'エラー: 有効な分割表を作成できませんでした。'
        puts '使用例: bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
        exit 1
      end

      # Ensure we have at least 2x2 table
      if rows.length < 2
        puts 'エラー: 独立性検定には少なくとも2x2の分割表が必要です。'
        puts '使用例: bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
        exit 1
      end

      # Ensure all rows have same number of columns
      col_count = rows.first.length
      if rows.any? { |row| row.length != col_count }
        puts 'エラー: 分割表の各行は同じ列数である必要があります。'
        exit 1
      end

      rows
    rescue ArgumentError
      puts 'エラー: 無効な数値が含まれています。'
      puts '使用例: bundle exec number_analyzer chi-square --independence 30 20 -- 15 35'
      exit 1
    end

    def self.run_anova(args, options = {})
      anova_options = {
        format: options[:format],
        precision: options[:precision],
        quiet: options[:quiet],
        help: options[:help] || false,
        file: options[:file] || nil,
        post_hoc: options[:post_hoc] || nil,
        alpha: options[:alpha] || 0.05
      }

      # If we already have parsed options (from special handling), use args directly
      if options.key?(:post_hoc) || options.key?(:independence) || options.key?(:alpha)
        remaining_args = args
      else
        # Otherwise, parse with OptionParser for standard handling
        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: bundle exec number_analyzer anova [options] group1.csv group2.csv group3.csv'
          opts.separator '       bundle exec number_analyzer anova [options] 1 2 3 -- 4 5 6 -- 7 8 9'
          opts.separator ''
          opts.separator 'Options:'

          opts.on('--format=FORMAT', ['json'], 'Output format (json)') do |format|
            anova_options[:format] = format
          end

          opts.on('--precision=N', Integer, 'Number of decimal places') do |precision|
            anova_options[:precision] = precision
          end

          opts.on('--quiet', 'Suppress descriptive text') do
            anova_options[:quiet] = true
          end

          opts.on('--post-hoc=TEST', %w[tukey bonferroni], 'Post-hoc test (tukey, bonferroni)') do |test|
            anova_options[:post_hoc] = test
          end

          opts.on('--alpha=LEVEL', Float, 'Significance level (default: 0.05)') do |alpha|
            anova_options[:alpha] = alpha
          end

          opts.on('--file', 'Read from CSV files') do
            anova_options[:file] = true
          end

          opts.on('-h', '--help', 'Show this help') do
            anova_options[:help] = true
          end
        end

        begin
          remaining_args = parser.parse(args)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          puts "エラー: #{e.message}"
          puts parser
          exit 1
        end
      end

      if anova_options[:help]
        puts parser
        puts ''
        puts 'Examples:'
        puts '  bundle exec number_analyzer anova 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '  bundle exec number_analyzer anova --file group1.csv group2.csv group3.csv'
        puts '  bundle exec number_analyzer anova --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '  bundle exec number_analyzer anova --post-hoc=tukey 1 2 3 -- 4 5 6 -- 7 8 9'
        return
      end

      if remaining_args.empty?
        puts 'エラー: グループデータが指定されていません。'
        puts parser
        exit 1
      end

      begin
        # Parse groups - either from files or command line arguments
        groups = if anova_options[:file]
                   parse_anova_files(remaining_args)
                 else
                   parse_anova_groups(remaining_args)
                 end

        if groups.length < 2
          puts 'エラー: ANOVAには少なくとも2つのグループが必要です。'
          exit 1
        end

        # Create NumberAnalyzer instance (dummy, since we'll call class method)
        analyzer = NumberAnalyzer.new([])
        result = analyzer.one_way_anova(*groups)

        if result.nil?
          puts 'エラー: ANOVAの計算ができませんでした。有効なデータを確認してください。'
          exit 1
        end

        # Format and display results
        format_options = {
          format: anova_options[:format],
          precision: anova_options[:precision],
          quiet: anova_options[:quiet]
        }
        formatted_result = OutputFormatter.format_anova(result, format_options)
        puts formatted_result

        # Perform post-hoc analysis if requested
        if anova_options[:post_hoc]
          post_hoc_result = analyzer.post_hoc_analysis(groups, method: anova_options[:post_hoc].to_sym)

          if post_hoc_result
            puts "\n" unless anova_options[:format] == 'json'
            formatted_post_hoc = OutputFormatter.format_post_hoc(post_hoc_result, format_options)
            puts formatted_post_hoc
          end
        end
      rescue StandardError => e
        puts "エラー: #{e.message}"
        exit 1
      end
    end

    def self.run_two_way_anova(args, options = {})
      two_way_options = {
        format: options[:format],
        precision: options[:precision],
        quiet: options[:quiet],
        help: options[:help] || false,
        file: options[:file] || nil,
        factor_a: options[:factor_a],
        factor_b: options[:factor_b]
      }

      # If we have parsed options (from global parser), use them directly
      if two_way_options[:factor_a] && two_way_options[:factor_b]
        # Options already parsed by global parser
        remaining_args = args
      else
        # Parse options using local OptionParser for --help or direct calls
        parser = OptionParser.new do |opts|
          opts.banner = <<~BANNER
            Usage: bundle exec number_analyzer two-way-anova [options]#{' '}
                   --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 data1,data2,data3,data4
          BANNER
          opts.separator '       bundle exec number_analyzer two-way-anova [options] --file data.csv'
          opts.separator ''
          opts.separator 'Options:'

          opts.on('--format=FORMAT', ['json'], 'Output format (json)') do |format|
            two_way_options[:format] = format
          end

          opts.on('--precision=N', Integer, 'Number of decimal places') do |precision|
            two_way_options[:precision] = precision
          end

          opts.on('--quiet', 'Suppress descriptive text') do
            two_way_options[:quiet] = true
          end

          opts.on('--factor-a=LEVELS', 'Factor A levels (comma-separated)') do |levels|
            two_way_options[:factor_a] = levels.split(',')
          end

          opts.on('--factor-b=LEVELS', 'Factor B levels (comma-separated)') do |levels|
            two_way_options[:factor_b] = levels.split(',')
          end

          opts.on('--file', 'Read from CSV file with factor columns') do
            two_way_options[:file] = true
          end

          opts.on('-h', '--help', 'Show this help') do
            two_way_options[:help] = true
          end
        end

        begin
          remaining_args = parser.parse(args)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          puts "エラー: #{e.message}"
          puts parser
          exit 1
        end

        if two_way_options[:help]
          puts parser
          puts <<~EXAMPLES

            Examples:
              bundle exec number_analyzer two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,15,20,25
              bundle exec number_analyzer two-way-anova --file factorial_data.csv
              bundle exec number_analyzer two-way-anova --format=json --precision=3#{' '}
                --factor-a Drug,Drug,Placebo,Placebo --factor-b Male,Female,Male,Female 5.2,7.1,3.8,4.5
          EXAMPLES
          return
        end
      end

      begin
        # Parse data - either from file or command line arguments
        if two_way_options[:file]
          parse_two_way_anova_from_file(remaining_args, two_way_options)
        else
          parse_two_way_anova_from_args(remaining_args, two_way_options)
        end
      rescue StandardError => e
        puts "エラー: #{e.message}"
        exit 1
      end
    end

    def self.parse_two_way_anova_from_args(args, options)
      # Validate required factors
      unless options[:factor_a] && options[:factor_b]
        puts 'エラー: --factor-a と --factor-b オプションが必要です。'
        puts '使用例: bundle exec number_analyzer two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,15,20,25'
        exit 1
      end

      if args.empty?
        puts 'エラー: 数値データが指定されていません。'
        exit 1
      end

      # Parse values
      values = if args.length == 1 && args[0].include?(',')
                 # Comma-separated values in single argument
                 args[0].split(',').map { |v| Float(v) }
               else
                 # Space-separated values
                 args.map { |v| Float(v) }
               end

      factor_a_levels = options[:factor_a]
      factor_b_levels = options[:factor_b]

      # Validate data consistency
      if factor_a_levels.length != factor_b_levels.length || factor_b_levels.length != values.length
        puts 'エラー: 要因A、要因B、数値データの数が一致しません。'
        puts "要因A: #{factor_a_levels.length}, 要因B: #{factor_b_levels.length}, 数値: #{values.length}"
        exit 1
      end

      execute_two_way_anova(factor_a_levels, factor_b_levels, values, options)
    rescue ArgumentError => e
      puts "エラー: 無効な数値が含まれています: #{e.message}"
      exit 1
    end

    def self.parse_two_way_anova_from_file(args, options)
      if args.empty?
        puts 'エラー: CSVファイルが指定されていません。'
        exit 1
      end

      filename = args[0]
      unless File.exist?(filename)
        puts "エラー: ファイルが見つかりません: #{filename}"
        exit 1
      end

      # For file input, assume CSV format with columns: factor_a, factor_b, value
      require 'csv'
      data = CSV.read(filename, headers: true)

      factor_a_levels = data['factor_a'] || data['FactorA'] || data['A']
      factor_b_levels = data['factor_b'] || data['FactorB'] || data['B']
      values = (data['value'] || data['Value'] || data['Y']).map(&:to_f)

      unless factor_a_levels && factor_b_levels && values
        puts 'エラー: CSVファイルに factor_a, factor_b, value 列が見つかりません。'
        puts '必要な列名: factor_a (or FactorA, A), factor_b (or FactorB, B), value (or Value, Y)'
        exit 1
      end

      execute_two_way_anova(factor_a_levels, factor_b_levels, values, options)
    end

    def self.execute_two_way_anova(factor_a_levels, factor_b_levels, values, options)
      # Create NumberAnalyzer instance
      analyzer = NumberAnalyzer.new([])
      result = analyzer.two_way_anova(nil, factor_a_levels, factor_b_levels, values)

      if result.nil?
        puts 'エラー: Two-way ANOVAの計算ができませんでした。有効なデータを確認してください。'
        exit 1
      end

      # Format and display results
      format_options = {
        format: options[:format],
        precision: options[:precision],
        quiet: options[:quiet]
      }

      formatted_result = OutputFormatter.format_two_way_anova(result, format_options)
      puts formatted_result
    end

    def self.parse_anova_groups(args)
      groups = []
      current_group = []

      args.each do |arg|
        if arg == '--'
          groups << current_group.map(&:to_f) unless current_group.empty?
          current_group = []
        else
          current_group << arg
        end
      end

      # Add the last group
      groups << current_group.map(&:to_f) unless current_group.empty?

      raise ArgumentError, '有効なグループデータがありません' if groups.empty?

      groups
    rescue ArgumentError
      raise ArgumentError, '無効な数値が含まれています'
    end

    def self.parse_anova_files(filenames)
      groups = []

      filenames.each do |filename|
        raise ArgumentError, "ファイルが見つかりません: #{filename}" unless File.exist?(filename)

        data = FileReader.read_file(filename)
        raise ArgumentError, "空のファイル: #{filename}" if data.empty?

        groups << data
      end

      groups
    rescue StandardError => e
      raise ArgumentError, "ファイル読み込みエラー: #{e.message}"
    end

    private_class_method def self.run_levene(args, options = {})
      if options[:help]
        show_help('levene', 'Test for variance homogeneity using Levene test (Brown-Forsythe)')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length < 2
        puts 'エラー: Levene検定には少なくとも2つのグループが必要です。'
        puts '使用例: bundle exec number_analyzer levene 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '        bundle exec number_analyzer levene --file group1.csv group2.csv group3.csv'
        exit 1
      end

      # Execute Levene test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.levene_test(*groups)

      if result.nil?
        puts 'エラー: Levene検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_levene_test(result, options)
    end

    private_class_method def self.run_bartlett(args, options = {})
      if options[:help]
        show_help('bartlett', 'Test for variance homogeneity using Bartlett test (assumes normality)')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length < 2
        puts 'エラー: Bartlett検定には少なくとも2つのグループが必要です。'
        puts '使用例: bundle exec number_analyzer bartlett 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '        bundle exec number_analyzer bartlett --file group1.csv group2.csv group3.csv'
        exit 1
      end

      # Execute Bartlett test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.bartlett_test(*groups)

      if result.nil?
        puts 'エラー: Bartlett検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_bartlett_test(result, options)
    end

    private_class_method def self.run_kruskal_wallis(args, options = {})
      if options[:help]
        show_help('kruskal-wallis', 'Non-parametric test for comparing medians across multiple groups')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length < 2
        puts 'エラー: Kruskal-Wallis検定には少なくとも2つのグループが必要です。'
        puts '使用例: bundle exec number_analyzer kruskal-wallis 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '        bundle exec number_analyzer kruskal-wallis --file group1.csv group2.csv group3.csv'
        exit 1
      end

      # Execute Kruskal-Wallis test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.kruskal_wallis_test(*groups)

      if result.nil?
        puts 'エラー: Kruskal-Wallis検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_kruskal_wallis_test(result, options)
    end

    private_class_method def self.run_mann_whitney(args, options = {})
      if options[:help]
        show_help('mann-whitney', 'Non-parametric test for comparing two independent groups (Wilcoxon rank-sum test)')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length != 2
        puts 'エラー: Mann-Whitney検定には正確に2つのグループが必要です。'
        puts '使用例: bundle exec number_analyzer mann-whitney 1 2 3 -- 4 5 6'
        puts '        bundle exec number_analyzer mann-whitney group1.csv group2.csv'
        exit 1
      end

      # Execute Mann-Whitney U test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.mann_whitney_u_test(groups[0], groups[1])

      if result.nil?
        puts 'エラー: Mann-Whitney検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_mann_whitney_test(result, options)
    end

    private_class_method def self.run_wilcoxon(args, options = {})
      if options[:help]
        show_help('wilcoxon', 'Non-parametric test for comparing paired samples (Wilcoxon signed-rank test)')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length != 2
        puts 'エラー: Wilcoxon符号順位検定には正確に2つのグループ（対応のあるデータ）が必要です。'
        puts '使用例: bundle exec number_analyzer wilcoxon 10 12 14 -- 15 18 16'
        puts '        bundle exec number_analyzer wilcoxon before.csv after.csv'
        exit 1
      end

      # Check that both groups have the same length (paired data requirement)
      if groups[0].length != groups[1].length
        puts 'エラー: 対応のあるデータのため、両グループは同じ長さである必要があります。'
        puts "グループ1: #{groups[0].length}個, グループ2: #{groups[1].length}個"
        exit 1
      end

      # Execute Wilcoxon signed-rank test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.wilcoxon_signed_rank_test(groups[0], groups[1])

      if result.nil?
        puts 'エラー: Wilcoxon符号順位検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_wilcoxon_test(result, options)
    end

    private_class_method def self.run_friedman(args, options = {})
      if options[:help]
        show_help('friedman', 'Non-parametric test for repeated measures across multiple conditions (Friedman test)')
        return
      end

      # Parse data sources (files or command line groups)
      groups = if options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                 parse_file_groups(args, options)
               else
                 parse_command_line_groups(args)
               end

      if groups.nil? || groups.empty? || groups.length < 3
        puts 'エラー: Friedman検定には少なくとも3つのグループ（条件）が必要です。'
        puts '使用例: bundle exec number_analyzer friedman 1 2 3 -- 4 5 6 -- 7 8 9'
        puts '        bundle exec number_analyzer friedman condition1.csv condition2.csv condition3.csv'
        exit 1
      end

      # Check that all groups have the same length (repeated measures requirement)
      group_sizes = groups.map(&:length)
      if group_sizes.uniq.length != 1
        puts 'エラー: 反復測定のため、全てのグループは同じ長さである必要があります。'
        puts "グループサイズ: #{group_sizes.join(', ')}"
        exit 1
      end

      # Execute Friedman test
      analyzer = NumberAnalyzer.new([])
      result = analyzer.friedman_test(*groups)

      if result.nil?
        puts 'エラー: Friedman検定を実行できませんでした。データを確認してください。'
        exit 1
      end

      # Format and display results
      puts StatisticsPresenter.format_friedman_test(result, options)
    end

    private_class_method def self.parse_file_groups(args, options)
      # Handle file input for multiple groups
      file_args = if options[:file]
                    # Support --file option with multiple files
                    [options[:file]] + args
                  else
                    # Support direct file arguments
                    args.select { |arg| arg.end_with?('.csv', '.json', '.txt') }
                  end

      if file_args.empty?
        puts 'エラー: ファイルが指定されていません。'
        exit 1
      end

      groups = []
      file_args.each do |filename|
        unless File.exist?(filename)
          puts "エラー: ファイルが見つかりません: #{filename}"
          exit 1
        end

        begin
          data = FileReader.read_file(filename)
          if data.empty?
            puts "エラー: 空のファイル: #{filename}"
            exit 1
          end
          groups << data
        rescue StandardError => e
          puts "エラー: ファイル読み込み失敗 (#{filename}): #{e.message}"
          exit 1
        end
      end

      groups
    end

    private_class_method def self.parse_command_line_groups(args)
      # Parse command line arguments separated by '--'
      return [] if args.empty?

      groups = []
      current_group = []

      args.each do |arg|
        if arg == '--'
          groups << current_group.dup unless current_group.empty?
          current_group.clear
        else
          begin
            current_group << Float(arg)
          rescue ArgumentError
            puts "エラー: 無効な数値: #{arg}"
            exit 1
          end
        end
      end

      # Add the last group if it's not empty
      groups << current_group unless current_group.empty?

      groups
    end
  end
end

# 実行部分（スクリプトとして実行された場合のみ）
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
