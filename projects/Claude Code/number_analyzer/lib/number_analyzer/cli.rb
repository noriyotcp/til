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
      'deviation-scores' => :run_deviation_scores
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
        file: nil
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
  end
end

# 実行部分（スクリプトとして実行された場合のみ）
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
