# frozen_string_literal: true

require 'optparse'
require_relative '../number_analyzer'
require_relative 'file_reader'
require_relative 'output_formatter'
require_relative 'plugin_system'
require_relative 'plugin_conflict_resolver'
require_relative 'plugin_namespace'
require_relative 'plugin_priority'

# Command Line Interface for NumberAnalyzer
# Handles command-line argument parsing and validation for NumberAnalyzer
class NumberAnalyzer::CLI
  # Core built-in commands (now moved to CommandRegistry)
  CORE_COMMANDS = {}.freeze

  class << self
    # Get all available commands (core + plugin + command registry)
    def commands
      all_commands = CORE_COMMANDS.merge(plugin_commands)

      # Add commands from CommandRegistry
      NumberAnalyzer::Commands::CommandRegistry.all.each do |cmd|
        all_commands[cmd] ||= :run_from_registry
      end

      all_commands
    end

    # Register a new command from a plugin
    def register_command(command_name, plugin_class, method_name)
      plugin_commands[command_name] = {
        plugin_class: plugin_class,
        method: method_name
      }
    end

    # Initialize plugin system
    def plugin_system
      @plugin_system ||= NumberAnalyzer::PluginSystem.new
    end

    # Load plugins on CLI initialization
    def initialize_plugins
      plugin_system.load_enabled_plugins
    end

    # Reset plugin state (for testing)
    def reset_plugin_state!
      @plugin_commands = {}
      @plugin_system = nil
    end

    private

    # Dynamic commands from plugins (class instance variable)
    def plugin_commands
      @plugin_commands ||= {}
    end
  end

  # Main entry point for CLI
  def self.run(argv = ARGV)
    # Initialize plugins before processing commands
    initialize_plugins

    # Show help if no arguments provided
    return show_general_help if argv.empty?

    # Check if first argument is a subcommand
    command = argv.first

    # Handle top-level help options
    return show_general_help if ['--help', '-h'].include?(command)

    if commands.key?(command)
      run_subcommand(command, argv[1..])
    elsif command.start_with?('-') || command.match?(/^\d+(\.\d+)?$/)
      # Option or numeric argument, treat as full analysis
      run_full_analysis(argv)
    else
      # Unknown command
      puts "Unknown command: #{command}"
      puts "Use 'bundle exec number_analyzer help' for available commands."
      exit 1
    end
  end

  def self.parse_arguments(argv = ARGV)
    options, remaining_args = parse_options(argv)

    if options[:file]
      begin
        NumberAnalyzer::FileReader.read_from_file(options[:file])
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
    if %w[correlation chi-square anova levene bartlett kruskal-wallis mann-whitney
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
    # First check if command is registered with new Command Pattern
    if NumberAnalyzer::Commands::CommandRegistry.exists?(command)
      NumberAnalyzer::Commands::CommandRegistry.execute_command(command, remaining_args, options)
    # Then check if it's a core command or plugin command
    elsif CORE_COMMANDS.key?(command)
      method_name = CORE_COMMANDS[command]
      send(method_name, remaining_args, options)
    elsif plugin_commands.key?(command)
      # Execute plugin command
      plugin_info = plugin_commands[command]
      plugin_class = plugin_info[:plugin_class]
      method_name = plugin_info[:method]

      # Create instance if needed and call the method
      result = if plugin_class.respond_to?(method_name)
                 plugin_class.send(method_name, remaining_args, options)
               else
                 instance = plugin_class.new
                 instance.send(method_name, remaining_args, options)
               end

      puts result if result
    else
      puts "Unknown command: #{command}"
      exit 1
    end
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
    puts <<~HELP
      Usage: bundle exec number_analyzer #{command} [options] numbers...

      Description: #{description}

      Options:
        --format json     Output in JSON format
        --precision N     Round to N decimal places
        --quiet          Minimal output (no labels)
        --file FILE, -f  Read numbers from file
        --help           Show this help

      Examples:
        bundle exec number_analyzer #{command} 1 2 3 4 5
        bundle exec number_analyzer #{command} --format=json 1 2 3
        bundle exec number_analyzer #{command} --precision=2 1.234 2.567
        bundle exec number_analyzer #{command} --file data.csv
    HELP
  end

  # Show help information for chi-square command
  private_class_method def self.show_chi_square_help
    puts <<~HELP
      Usage: bundle exec number_analyzer chi-square [options] numbers...

      Description: Perform chi-square test for independence or goodness-of-fit

      Options:
        --independence    Perform independence test
        --goodness-of-fit Perform goodness-of-fit test
        --uniform        Test against uniform distribution
        --format json     Output in JSON format
        --precision N     Round to N decimal places
        --quiet          Minimal output (no labels)
        --file FILE, -f  Read numbers from file
        --help           Show this help

      Examples:
        bundle exec number_analyzer chi-square --independence 30 20 -- 15 35
        bundle exec number_analyzer chi-square --goodness-of-fit observed.csv expected.csv
        bundle exec number_analyzer chi-square --uniform 8 12 10 15 9 6
    HELP
  end

  # Show general help information
  private_class_method def self.show_general_help
    puts <<~HELP
      NumberAnalyzer - Statistical Analysis Tool

      Usage:
        bundle exec number_analyzer <command> [options] [numbers...]
        bundle exec number_analyzer --file data.csv

      Available Commands:
        Basic Statistics:
          mean, median, mode, sum, min, max

        Advanced Analysis:
          variance, std, quartiles, percentile, outliers

        Time Series Analysis:
          trend, moving-average, growth-rate, seasonal

        Statistical Tests:
          t-test, chi-square, anova, correlation

        Analysis of Variance:
          anova, levene, bartlett

        Non-parametric Tests:
          kruskal-wallis, mann-whitney, wilcoxon, friedman

        Plugin Management:
          plugins

      Detailed Help:
        bundle exec number_analyzer help <command>
        bundle exec number_analyzer <command> --help

      Examples:
        bundle exec number_analyzer mean 1 2 3 4 5
        bundle exec number_analyzer median --file data.csv
        bundle exec number_analyzer histogram --format=json 1 2 3 4 5
    HELP
  end

  # Parse numbers from arguments and options, handling file input
  private_class_method def self.parse_numbers_with_options(args, options)
    if options[:file]
      begin
        NumberAnalyzer::FileReader.read_from_file(options[:file])
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

  # Legacy methods removed - all commands now handled by CommandRegistry

  # Time series analysis methods removed - now handled by CommandRegistry

  # T-test methods removed - now handled by TTestCommand

  # Confidence interval methods removed - now handled by ConfidenceIntervalCommand

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

  # Chi-square methods removed - now handled by ChiSquareCommand

  # ANOVA and statistical test methods removed - now handled by Command Pattern
end

require_relative 'cli/commands'

# 実行部分（スクリプトとして実行された場合のみ）
NumberAnalyzer::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
