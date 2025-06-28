# frozen_string_literal: true

require_relative '../number_analyzer'
require_relative 'file_reader'

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
      # ファイルオプションをチェック
      file_index = find_file_option_index(argv)

      if file_index
        file_path = argv[file_index + 1]
        if file_path.nil? || file_path.start_with?('-')
          puts 'エラー: --fileオプションにはファイルパスを指定してください。'
          exit 1
        end

        begin
          FileReader.read_from_file(file_path)
        rescue StandardError => e
          puts "ファイル読み込みエラー: #{e.message}"
          exit 1
        end
      elsif argv.empty?
        # デフォルト配列を使用
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      else
        # コマンドライン引数から数値を取得
        parse_numeric_arguments(argv)
      end
    end

    private_class_method def self.run_full_analysis(argv)
      numbers = parse_arguments(argv)
      analyzer = NumberAnalyzer.new(numbers)
      analyzer.calculate_statistics
    end

    private_class_method def self.run_subcommand(command, args)
      method_name = COMMANDS[command]
      send(method_name, args)
    end

    # Subcommand implementations
    private_class_method def self.run_median(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      puts analyzer.median
    end

    private_class_method def self.run_mean(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      puts analyzer.send(:average_value)
    end

    private_class_method def self.run_mode(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      mode_values = analyzer.mode
      if mode_values.empty?
        puts 'モードなし'
      else
        puts mode_values.join(', ')
      end
    end

    private_class_method def self.run_sum(args)
      numbers = parse_numbers_from_args(args)
      puts numbers.sum
    end

    private_class_method def self.run_min(args)
      numbers = parse_numbers_from_args(args)
      puts numbers.min
    end

    private_class_method def self.run_max(args)
      numbers = parse_numbers_from_args(args)
      puts numbers.max
    end

    private_class_method def self.run_histogram(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      analyzer.display_histogram
    end

    private_class_method def self.run_outliers(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      outlier_values = analyzer.outliers
      if outlier_values.empty?
        puts 'なし'
      else
        puts outlier_values.join(', ')
      end
    end

    private_class_method def self.run_percentile(args)
      validate_percentile_args(args)

      percentile_value_str = args[0]
      numbers = parse_percentile_numbers(args)
      percentile_value = parse_percentile_value(percentile_value_str)

      analyzer = NumberAnalyzer.new(numbers)
      result = analyzer.percentile(percentile_value)
      puts result
    end

    private_class_method def self.validate_percentile_args(args)
      return unless args.empty? || (!find_file_option_index(args) && args.length < 2)

      puts 'エラー: percentileコマンドには percentile値と数値が必要です。'
      puts '使用例: bundle exec number_analyzer percentile 75 1 2 3 4 5'
      exit 1
    end

    private_class_method def self.parse_percentile_numbers(args)
      file_index = find_file_option_index(args)
      if file_index
        parse_percentile_file_input(args, file_index)
      else
        parse_numeric_arguments(args[1..])
      end
    end

    private_class_method def self.parse_percentile_file_input(args, file_index)
      file_path = args[file_index + 1]

      if file_path.nil? || file_path.start_with?('-')
        puts 'エラー: --fileオプションにはファイルパスを指定してください。'
        exit 1
      end

      begin
        FileReader.read_from_file(file_path)
      rescue StandardError => e
        puts "ファイル読み込みエラー: #{e.message}"
        exit 1
      end
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

    private_class_method def self.run_quartiles(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      quartiles = analyzer.quartiles
      puts "Q1: #{quartiles[:q1]}"
      puts "Q2: #{quartiles[:q2]}"
      puts "Q3: #{quartiles[:q3]}"
    end

    private_class_method def self.run_variance(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      puts analyzer.variance
    end

    private_class_method def self.run_standard_deviation(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      puts analyzer.standard_deviation
    end

    private_class_method def self.run_deviation_scores(args)
      numbers = parse_numbers_from_args(args)
      analyzer = NumberAnalyzer.new(numbers)
      deviation_scores = analyzer.deviation_scores
      puts deviation_scores.join(', ')
    end

    # Parse numbers from arguments, handling file input
    private_class_method def self.parse_numbers_from_args(args)
      # Check for file option first
      file_index = find_file_option_index(args)

      if file_index
        file_path = args[file_index + 1]
        if file_path.nil? || file_path.start_with?('-')
          puts 'エラー: --fileオプションにはファイルパスを指定してください。'
          exit 1
        end

        begin
          FileReader.read_from_file(file_path)
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

    private_class_method def self.find_file_option_index(argv)
      argv.each_with_index do |arg, index|
        return index if ['--file', '-f'].include?(arg)
      end
      nil
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
