# frozen_string_literal: true

require 'optparse'

# Option parsing module for NumberAnalyzer CLI
# Handles command-line argument parsing and validation
module Numana::CLI::Options
  extend self

  # Parse command-line options using OptionParser
  def parse(args)
    options = default_options
    parser = create_option_parser(options)

    remaining_args = parse_args_with_parser(parser, args)
    [options, remaining_args]
  end

  # Parse options for commands with special '--' separators
  def parse_special_command_options(args, command)
    return parse(args) unless special_command?(command)

    options = default_options
    data_start_index = find_data_start_index(args, options)
    remaining_args = args[data_start_index..]

    [options, remaining_args]
  end

  private

  # Default options hash
  def default_options
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

  # Create OptionParser instance
  def create_option_parser(options)
    parser = OptionParser.new
    add_basic_options(parser, options)
    add_analysis_options(parser, options)
    add_test_options(parser, options)
    parser
  end

  # Add basic CLI options
  def add_basic_options(parser, options)
    parser.on('--format FORMAT', 'Output format (json)') { |format| options[:format] = format }
    parser.on('--precision N', Integer, 'Number of decimal places') { |precision| options[:precision] = precision }
    parser.on('--quiet', 'Quiet mode (minimal output)') do
      options[:quiet] = true
      options[:format] = 'quiet' unless options[:format]
    end
    parser.on('--help', 'Show help') { options[:help] = true }
    parser.on('--file FILE', '-f FILE', 'Read numbers from file') { |file| options[:file] = file }
  end

  # Add analysis-specific options
  def add_analysis_options(parser, options)
    parser.on('--window N', Integer, 'Window size for moving average') { |window| options[:window] = window }
    parser.on('--period N', Integer, 'Period for seasonal analysis') { |period| options[:period] = period }
  end

  # Add statistical test options
  def add_test_options(parser, options)
    add_t_test_options(parser, options)
    add_chi_square_options(parser, options)
    add_anova_options(parser, options)
  end

  # Add t-test specific options
  def add_t_test_options(parser, options)
    parser.on('--paired', 'Perform paired samples t-test') { options[:paired] = true }
    parser.on('--one-sample', 'Perform one-sample t-test') { options[:one_sample] = true }
    parser.on('--population-mean MEAN', Float, 'Population mean for one-sample t-test') do |mean|
      options[:population_mean] = mean
    end
    parser.on('--mu MEAN', Float, 'Population mean for one-sample t-test (alias)') { |mean| options[:mu] = mean }
    parser.on('--level LEVEL', Float, 'Confidence level (default: 95)') { |level| options[:confidence_level] = level }
  end

  # Add chi-square test options
  def add_chi_square_options(parser, options)
    parser.on('--independence', 'Perform independence test for chi-square') { options[:independence] = true }
    parser.on('--goodness-of-fit', 'Perform goodness-of-fit test for chi-square') { options[:goodness_of_fit] = true }
    parser.on('--uniform', 'Use uniform distribution for goodness-of-fit test') { options[:uniform] = true }
  end

  # Add ANOVA options
  def add_anova_options(parser, options)
    parser.on('--factor-a LEVELS', 'Factor A levels (comma-separated)') do |levels|
      options[:factor_a] = levels.split(',')
    end
    parser.on('--factor-b LEVELS', 'Factor B levels (comma-separated)') do |levels|
      options[:factor_b] = levels.split(',')
    end
  end

  # Parse arguments with comprehensive error handling
  def parse_args_with_parser(parser, args)
    parser.parse(args)
  rescue OptionParser::InvalidOption => e
    puts "Error: #{e.message}"
    exit 1
  rescue OptionParser::MissingArgument => e
    if e.message.include?('--file')
      puts 'Error: --file option requires a file path.'
    else
      puts "Error: #{e.message}"
    end
    exit 1
  rescue OptionParser::InvalidArgument => e
    if e.message.include?('--precision')
      warn 'invalid value for Integer'
    else
      puts "Error: #{e.message}"
    end
    exit 1
  end

  # Check if command requires special option parsing
  def special_command?(command)
    %w[correlation chi-square anova levene bartlett kruskal-wallis mann-whitney
       wilcoxon friedman].include?(command)
  end

  # Find where data starts in arguments for special commands
  def find_data_start_index(args, options)
    data_start_index = 0

    args.each_with_index do |arg, index|
      if special_option_handled?(arg, args, index, options)
        next # Continue processing options
      elsif first_data_argument?(arg, args, index)
        data_start_index = index
        break
      end
    end

    data_start_index
  end

  # Process special command options
  def special_option_handled?(arg, args, index, options)
    case arg
    when '--independence', '--goodness-of-fit', '--uniform', '--quiet', '--help'
      handle_flag_option(arg, options)
      true
    when '--post-hoc', '--alpha', '--format', '--precision', '--file', '-f'
      value_option_processed?(arg, args, index, options)
    when /^--(post-hoc|alpha|format|precision)=(.+)$/
      handle_inline_option(Regexp.last_match(1), Regexp.last_match(2), options)
      true
    else
      false # Not a special option
    end
  end

  # Handle flag-based options
  def handle_flag_option(arg, options)
    case arg
    when '--independence'
      options[:independence] = true
    when '--goodness-of-fit'
      options[:goodness_of_fit] = true
    when '--uniform'
      options[:uniform] = true
    when '--quiet'
      options[:quiet] = true
      options[:format] = 'quiet' unless options[:format]
    when '--help'
      options[:help] = true
    end
  end

  # Handle value-based options - returns success status
  def value_option_processed?(arg, args, index, options)
    return false unless index + 1 < args.length

    value = args[index + 1]
    case arg
    when '--post-hoc'
      options[:post_hoc] = value
    when '--alpha'
      options[:alpha] = value.to_f
    when '--format'
      options[:format] = value
    when '--precision'
      options[:precision] = value.to_i
    when '--file', '-f'
      options[:file] = value
    end
    true
  end

  # Handle inline options (--option=value format)
  def handle_inline_option(option, value, options)
    case option
    when 'post-hoc'
      options[:post_hoc] = value
    when 'alpha'
      options[:alpha] = value.to_f
    when 'format'
      options[:format] = value
    when 'precision'
      options[:precision] = value.to_i
    end
  end

  # Check if this is the first data argument
  def first_data_argument?(arg, args, index)
    return false if arg.start_with?('--')
    return false if option_value?(args, index)

    true
  end

  # Check if current argument is a value for a previous option
  def option_value?(args, index)
    return false unless index.positive?

    previous_arg = args[index - 1]
    previous_arg =~ /^--(format|precision|file|post-hoc|alpha)$/
  end
end
