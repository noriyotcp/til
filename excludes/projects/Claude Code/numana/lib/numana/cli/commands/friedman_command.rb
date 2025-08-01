# frozen_string_literal: true

require_relative '../base_command'

# Command for performing Friedman test (non-parametric repeated measures ANOVA)
class Numana::Commands::FriedmanCommand < Numana::Commands::BaseCommand
  command 'friedman', 'Non-parametric test for repeated measures across multiple conditions (Friedman test)'

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

    if @groups.nil? || @groups.empty? || @groups.length < 3
      raise ArgumentError, <<~ERROR
        Friedman検定には少なくとも3つのグループ（条件）が必要です。
        使用例: bundle exec numana friedman 1 2 3 -- 4 5 6 -- 7 8 9
                bundle exec numana friedman condition1.csv condition2.csv condition3.csv
      ERROR
    end

    # Check that all groups have the same length (repeated measures requirement)
    group_sizes = @groups.map(&:length)
    if group_sizes.uniq.length != 1
      raise ArgumentError, <<~ERROR
        反復測定のため、全てのグループは同じ長さである必要があります。
        グループサイズ: #{group_sizes.join(', ')}
      ERROR
    end

    @groups
  end

  def perform_calculation(data)
    # Execute Friedman test
    analyzer = Numana.new([])
    result = analyzer.friedman_test(*data)

    raise ArgumentError, 'Could not perform Friedman test. Check your data' if result.nil?

    result
  end

  def output_result(result)
    puts Numana::StatisticsPresenter.format_friedman_test(result, @options)
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec numana friedman [options] 1 2 3 -- 4 5 6 -- 7 8 9
             bundle exec numana friedman [options] condition1.csv condition2.csv condition3.csv

      Non-parametric test for repeated measures across multiple conditions (Friedman test).
      This is the non-parametric alternative to repeated measures ANOVA when normality
      assumptions cannot be met. All groups must have the same number of observations.

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec numana friedman 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec numana friedman condition1.csv condition2.csv condition3.csv
        bundle exec numana friedman --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec numana friedman --quiet 1 2 3 -- 4 5 6 -- 7 8 9
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
        data = Numana::FileReader.read_file(filename)
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
