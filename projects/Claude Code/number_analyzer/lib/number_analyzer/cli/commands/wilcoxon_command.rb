# frozen_string_literal: true

require_relative '../base_command'

# Command for performing Wilcoxon signed-rank test (non-parametric paired comparison)
class NumberAnalyzer::Commands::WilcoxonCommand < NumberAnalyzer::Commands::BaseCommand
  command 'wilcoxon', 'Non-parametric test for comparing paired samples (Wilcoxon signed-rank test)'

  private

  def validate_arguments(args)
    return unless args.empty? && !@options[:file]

    raise ArgumentError, 'No group data specified'
  end

  def parse_input(args)
    # Parse data sources (files or command line groups)
    @groups = if @options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                parse_file_groups(args, @options)
              else
                parse_command_line_groups(args)
              end

    if @groups.nil? || @groups.empty? || @groups.length != 2
      raise ArgumentError, <<~ERROR
        Wilcoxon符号順位検定には正確に2つのグループ（対応のあるデータ）が必要です。
        使用例: bundle exec number_analyzer wilcoxon 10 12 14 -- 15 18 16
                bundle exec number_analyzer wilcoxon before.csv after.csv
      ERROR
    end

    # Check that both groups have the same length (paired data requirement)
    if @groups[0].length != @groups[1].length
      raise ArgumentError, <<~ERROR
        対応のあるデータのため、両グループは同じ長さである必要があります。
        グループ1: #{@groups[0].length}個, グループ2: #{@groups[1].length}個
      ERROR
    end

    @groups
  end

  def perform_calculation(data)
    # Execute Wilcoxon signed-rank test
    analyzer = NumberAnalyzer.new([])
    result = analyzer.wilcoxon_signed_rank_test(data[0], data[1])

    raise ArgumentError, 'Could not perform Wilcoxon signed-rank test. Check your data' if result.nil?

    result
  end

  def output_result(result)
    puts NumberAnalyzer::StatisticsPresenter.format_wilcoxon_test(result, @options)
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec number_analyzer wilcoxon [options] 10 12 14 -- 15 18 16
             bundle exec number_analyzer wilcoxon [options] before.csv after.csv

      Non-parametric test for comparing paired samples (Wilcoxon signed-rank test).
      This is the non-parametric alternative to paired samples t-test when normality
      assumptions cannot be met. Both groups must have the same number of observations.

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec number_analyzer wilcoxon 10 12 14 -- 15 18 16
        bundle exec number_analyzer wilcoxon before.csv after.csv
        bundle exec number_analyzer wilcoxon --format=json --precision=3 1 2 3 -- 4 5 6
        bundle exec number_analyzer wilcoxon --quiet 10 20 30 -- 15 25 35
    HELP
  end

  def parse_file_groups(args, options)
    # Handle file input for multiple groups
    file_args = if options[:file]
                  # Support --file option with multiple files
                  [options[:file]] + args
                else
                  # Support direct file arguments
                  args.select { |arg| arg.end_with?('.csv', '.json', '.txt') }
                end

    raise ArgumentError, 'ファイルが指定されていません。' if file_args.empty?

    groups = []
    file_args.each do |filename|
      raise ArgumentError, "File not found: #{filename}" unless File.exist?(filename)

      begin
        data = NumberAnalyzer::FileReader.read_file(filename)
        raise ArgumentError, "Empty file: #{filename}" if data.empty?

        groups << data
      rescue StandardError => e
        raise ArgumentError, "ファイル読み込み失敗 (#{filename}): #{e.message}"
      end
    end

    groups
  end

  def parse_command_line_groups(args)
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
          raise ArgumentError, "Invalid number: #{arg}"
        end
      end
    end

    # Add the last group if it's not empty
    groups << current_group unless current_group.empty?

    groups
  end
end
