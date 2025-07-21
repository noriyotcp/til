# frozen_string_literal: true

require_relative '../base_command'

# Command for performing Kruskal-Wallis test (non-parametric ANOVA)
class Numana::Commands::KruskalWallisCommand < Numana::Commands::BaseCommand
  command 'kruskal-wallis', 'Non-parametric test for comparing medians across multiple groups'

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
        Kruskal-Wallis test requires at least 2 groups.
        Examples: bundle exec number_analyzer kruskal-wallis 1 2 3 -- 4 5 6 -- 7 8 9
                 bundle exec number_analyzer kruskal-wallis --file group1.csv group2.csv group3.csv
      ERROR
    end

    @groups
  end

  def perform_calculation(data)
    # Execute Kruskal-Wallis test
    analyzer = Numana.new([])
    result = analyzer.kruskal_wallis_test(*data)

    raise ArgumentError, 'Could not perform Kruskal-Wallis test. Check your data' if result.nil?

    result
  end

  def output_result(result)
    puts Numana::StatisticsPresenter.format_kruskal_wallis_test(result, @options)
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec number_analyzer kruskal-wallis [options] 1 2 3 -- 4 5 6 -- 7 8 9
             bundle exec number_analyzer kruskal-wallis [options] --file group1.csv group2.csv group3.csv

      Non-parametric test for comparing medians across multiple groups.
      This is the non-parametric alternative to one-way ANOVA when normality
      assumptions cannot be met.

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec number_analyzer kruskal-wallis 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer kruskal-wallis --file group1.csv group2.csv group3.csv
        bundle exec number_analyzer kruskal-wallis --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer kruskal-wallis --quiet 1 2 3 -- 4 5 6 -- 7 8 9
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
        data = Numana::FileReader.read_file(filename)
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
