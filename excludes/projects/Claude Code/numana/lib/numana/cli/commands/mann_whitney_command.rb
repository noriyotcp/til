# frozen_string_literal: true

require_relative '../base_command'

# Command for performing Mann-Whitney U test (non-parametric two-group comparison)
class Numana::Commands::MannWhitneyCommand < Numana::Commands::BaseCommand
  command 'mann-whitney', 'Non-parametric test for comparing two independent groups (Wilcoxon rank-sum test)'

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
        Mann-Whitney検定には正確に2つのグループが必要です。
        使用例: bundle exec numana mann-whitney 1 2 3 -- 4 5 6
                bundle exec numana mann-whitney group1.csv group2.csv
      ERROR
    end

    @groups
  end

  def perform_calculation(data)
    # Execute Mann-Whitney U test
    analyzer = Numana.new([])
    result = analyzer.mann_whitney_u_test(data[0], data[1])

    raise ArgumentError, 'Could not perform Mann-Whitney test. Check your data' if result.nil?

    result
  end

  def output_result(result)
    puts Numana::StatisticsPresenter.format_mann_whitney_test(result, @options)
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec numana mann-whitney [options] 1 2 3 -- 4 5 6
             bundle exec numana mann-whitney [options] group1.csv group2.csv

      Non-parametric test for comparing two independent groups (also known as
      Wilcoxon rank-sum test). This is the non-parametric alternative to
      independent samples t-test when normality assumptions cannot be met.

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec numana mann-whitney 1 2 3 -- 4 5 6
        bundle exec numana mann-whitney group1.csv group2.csv
        bundle exec numana mann-whitney --format=json --precision=3 1 2 3 -- 6 7 8
        bundle exec numana mann-whitney --quiet 10 20 30 -- 40 50 60
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
