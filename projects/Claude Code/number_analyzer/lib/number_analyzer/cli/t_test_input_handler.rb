# frozen_string_literal: true

require_relative 'data_input_handler'

# Handles input parsing for t-test with various test types
class NumberAnalyzer::CLI::TTestInputHandler
  def initialize(options)
    @options = options
  end

  def determine_test_type
    return :paired if @options[:paired]
    return :one_sample if @options[:one_sample] || @options[:population_mean] || @options[:mu]

    :independent
  end

  def validate_arguments(args)
    return if @options[:help]

    test_type = determine_test_type

    case test_type
    when :one_sample
      validate_one_sample_args(args)
    when :paired, :independent
      validate_two_sample_args(args)
    end
  end

  def parse_input(args)
    test_type = determine_test_type

    case test_type
    when :one_sample
      parse_one_sample_input(args)
    when :independent
      parse_independent_input(args)
    when :paired
      parse_paired_input(args)
    end
  end

  private

  def validate_one_sample_args(_args)
    population_mean = @options[:population_mean] || @options[:mu]
    return if population_mean

    raise ArgumentError, <<~ERROR
      Error: One-sample t-test requires population mean.
      Example: number_analyzer t-test --one-sample --population-mean=100 data.csv
    ERROR
  end

  def validate_two_sample_args(args)
    # Valid cases: file mode or args with '--' separator
    return if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
    return if args.include?('--')

    raise ArgumentError, <<~ERROR
      Error: Two datasets required.
      Examples: number_analyzer t-test 1 2 3 -- 4 5 6
               number_analyzer t-test group1.csv group2.csv
    ERROR
  end

  def parse_one_sample_input(args)
    NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
  end

  def parse_independent_input(args)
    if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
      parse_file_datasets(args)
    elsif args.include?('--')
      parse_numeric_datasets(args)
    else
      raise ArgumentError, <<~ERROR
        Error: Use "--" to separate two datasets or specify two files.
        Examples: number_analyzer t-test 1 2 3 -- 4 5 6
                 number_analyzer t-test group1.csv group2.csv
      ERROR
    end
  end

  def parse_paired_input(args)
    parse_independent_input(args)
  end

  def parse_file_datasets(files)
    dataset1 = NumberAnalyzer::FileReader.read_from_file(files[0])
    dataset2 = NumberAnalyzer::FileReader.read_from_file(files[1])
    [dataset1, dataset2]
  rescue StandardError => e
    raise ArgumentError, "File read error: #{e.message}"
  end

  def parse_numeric_datasets(args)
    separator_index = args.index('--')

    dataset1_args = args[0...separator_index]
    dataset2_args = args[(separator_index + 1)..]

    raise ArgumentError, 'Error: Both datasets need values' if dataset1_args.empty? || dataset2_args.empty?

    dataset1 = parse_numbers(dataset1_args)
    dataset2 = parse_numbers(dataset2_args)
    [dataset1, dataset2]
  end

  def parse_numbers(args)
    args.map do |arg|
      Float(arg)
    rescue ArgumentError
      raise ArgumentError, "無効な数値: #{arg}"
    end
  end
end
