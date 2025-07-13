# frozen_string_literal: true

require_relative '../base_command'
require_relative '../statistical_output_formatter'
require_relative '../../presenters/anova_presenter'

# Command for performing one-way ANOVA (Analysis of Variance)
class NumberAnalyzer::Commands::AnovaCommand < NumberAnalyzer::Commands::BaseCommand
  command 'anova', 'Perform one-way Analysis of Variance (ANOVA)'

  private

  def validate_arguments(args)
    return unless args.empty? && !@options[:file]

    raise ArgumentError, 'No group data specified'
  end

  def parse_input(args)
    # Parse groups - either from files or command line arguments
    @groups = if @options[:file] || args.any? { |arg| arg.end_with?('.csv', '.json', '.txt') }
                parse_anova_files(args)
              else
                parse_anova_groups(args)
              end

    raise ArgumentError, 'ANOVA requires at least 2 groups' if @groups.length < 2

    @groups
  end

  def perform_calculation(data)
    # Create NumberAnalyzer instance (dummy, since we'll call class method)
    analyzer = NumberAnalyzer.new([])
    result = analyzer.one_way_anova(*data)

    raise ArgumentError, 'Could not calculate ANOVA. Check your data' if result.nil?

    result
  end

  def output_result(result)
    # Format ANOVA results using presenter
    presenter = NumberAnalyzer::Presenters::AnovaPresenter.new(result, @options)
    puts presenter.format

    # Perform post-hoc analysis if requested
    return unless @options[:post_hoc]

    analyzer = NumberAnalyzer.new([])
    post_hoc_result = analyzer.post_hoc_analysis(@groups, method: @options[:post_hoc].to_sym)

    return unless post_hoc_result

    puts "\n" unless @options[:format] == 'json'
    formatted_post_hoc = NumberAnalyzer::OutputFormatter.format_post_hoc(post_hoc_result, @options)
    puts formatted_post_hoc
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec number_analyzer anova [options] group1.csv group2.csv group3.csv
             bundle exec number_analyzer anova [options] 1 2 3 -- 4 5 6 -- 7 8 9

      Options:
        --format=FORMAT        Output format (json)
        --precision=N          Number of decimal places
        --quiet                Suppress descriptive text
        --post-hoc=TEST        Post-hoc test (tukey, bonferroni)
        --alpha=LEVEL          Significance level (default: 0.05)
        --file                 Read from CSV files
        -h, --help             Show this help

      Examples:
        bundle exec number_analyzer anova 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer anova --file group1.csv group2.csv group3.csv
        bundle exec number_analyzer anova --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
        bundle exec number_analyzer anova --post-hoc=tukey 1 2 3 -- 4 5 6 -- 7 8 9
    HELP
  end

  def default_options
    super.merge({
                  post_hoc: nil,
                  alpha: 0.05
                })
  end

  def parse_anova_groups(args)
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

    raise ArgumentError, 'No valid group data found' if groups.empty?

    groups
  rescue ArgumentError
    raise ArgumentError, 'Invalid numbers found'
  end

  def parse_anova_files(filenames)
    groups = []

    filenames.each do |filename|
      raise ArgumentError, "File not found: #{filename}" unless File.exist?(filename)

      data = NumberAnalyzer::FileReader.read_file(filename)
      raise ArgumentError, "Empty file: #{filename}" if data.empty?

      groups << data
    end

    groups
  rescue StandardError => e
    raise ArgumentError, "File read error: #{e.message}"
  end
end
