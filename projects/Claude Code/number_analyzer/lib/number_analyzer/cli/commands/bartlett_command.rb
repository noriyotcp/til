# frozen_string_literal: true

require_relative '../base_command'

# Command for performing Bartlett test for variance homogeneity
class NumberAnalyzer::Commands::BartlettCommand < NumberAnalyzer::Commands::BaseCommand
  command 'bartlett', 'Test for variance homogeneity using Bartlett test (assumes normality)'

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

    if @groups.nil? || @groups.empty? || @groups.length < 2
      raise ArgumentError, <<~ERROR
        Bartlett test requires at least 2 groups.
        Examples: bundle exec number_analyzer bartlett 1 2 3 -- 4 5 6 -- 7 8 9
                 bundle exec number_analyzer bartlett --file group1.csv group2.csv group3.csv
      ERROR
    end

    @groups
  end

  def perform_calculation(data)
    # Execute Bartlett test
    analyzer = NumberAnalyzer.new([])
    result = analyzer.bartlett_test(*data)

    raise ArgumentError, 'Could not perform Bartlett test. Check your data' if result.nil?

    result
  end

  def output_result(result)
    puts NumberAnalyzer::StatisticsPresenter.format_bartlett_test(result, @options)
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec number_analyzer bartlett [options] 1 2 3 -- 4 5 6 -- 7 8 9
             bundle exec number_analyzer bartlett [options] --file group1.csv group2.csv group3.csv

      Test for variance homogeneity using Bartlett test. This test assumes normality
      and provides high precision for variance equality testing under normal distributions.
      Use Levene test if normality cannot be assumed.

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec number_analyzer bartlett 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer bartlett --file group1.csv group2.csv group3.csv
        bundle exec number_analyzer bartlett --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer bartlett --quiet 1 2 3 -- 4 5 6 -- 7 8 9
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
      raise ArgumentError, "ファイルが見つかりません: #{filename}" unless File.exist?(filename)

      begin
        data = NumberAnalyzer::FileReader.read_file(filename)
        raise ArgumentError, "空のファイル: #{filename}" if data.empty?

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
          raise ArgumentError, "無効な数値: #{arg}"
        end
      end
    end

    # Add the last group if it's not empty
    groups << current_group unless current_group.empty?

    groups
  end
end
