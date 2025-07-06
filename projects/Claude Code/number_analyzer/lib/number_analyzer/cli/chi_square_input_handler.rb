# frozen_string_literal: true

require_relative 'data_input_handler'

# Handles input parsing for chi-square test with various test types
class NumberAnalyzer::CLI::ChiSquareInputHandler
  def initialize(options)
    @options = options
  end

  def parse_input(args)
    test_type = determine_test_type(args)

    case test_type
    when :independence
      parse_independence_test_input(args)
    when :goodness_of_fit
      parse_goodness_of_fit_input(args)
    end
  end

  def determine_test_type(_args)
    return :independence if @options[:independence]
    return :goodness_of_fit if @options[:goodness_of_fit] || @options[:uniform]

    nil
  end

  private

  def parse_independence_test_input(args)
    if @options[:file]
      parse_contingency_table_from_file(@options[:file])
    else
      parse_contingency_table_from_args(args)
    end
  end

  def parse_goodness_of_fit_input(args)
    if @options[:uniform]
      observed = NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
      [observed, nil]
    else
      parse_observed_expected_datasets(args)
    end
  end

  def parse_contingency_table_from_file(file_path)
    raise ArgumentError, "Error: File not found: #{file_path}" unless File.exist?(file_path)

    begin
      lines = File.readlines(file_path)
      contingency_table = lines.map do |line|
        line.strip.split(',').map(&:to_f)
      end

      col_count = contingency_table.first&.length
      raise ArgumentError, 'Error: Each row in contingency table must have the same number of columns' if contingency_table.any? do |row|
        row.length != col_count
      end

      contingency_table
    rescue StandardError => e
      raise ArgumentError, "Error: File read error occurred: #{e.message}"
    end
  end

  def parse_contingency_table_from_args(args)
    build_rows_from_args(args)
  rescue ArgumentError => e
    raise e
  rescue StandardError
    raise ArgumentError, <<~ERROR
      Error: Invalid numbers found.
      Example: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def build_rows_from_args(args)
    rows = []
    current_row = []

    args.each do |arg|
      if arg == '--'
        rows << current_row.map(&:to_f) unless current_row.empty?
        current_row = []
      else
        current_row << arg
      end
    end

    rows << current_row.map(&:to_f) unless current_row.empty?
    rows
  end

  def parse_observed_expected_datasets(args)
    observed, expected = if two_files_provided?(args)
                           parse_from_two_files(args)
                         elsif @options[:file]
                           parse_from_single_file
                         else
                           parse_from_command_line(args)
                         end
    [observed, expected]
  rescue StandardError => e
    raise ArgumentError, "File read error: #{e.message}"
  end

  def two_files_provided?(args)
    args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
  end

  def parse_from_two_files(args)
    observed = NumberAnalyzer::FileReader.read_from_file(args[0])
    expected = NumberAnalyzer::FileReader.read_from_file(args[1])
    [observed, expected]
  end

  def parse_from_single_file
    combined_data = NumberAnalyzer::Commands::DataInputHandler.parse([], @options)
    mid = combined_data.length / 2
    observed = combined_data[0...mid]
    expected = combined_data[mid..]
    [observed, expected]
  end

  def parse_from_command_line(args)
    mid = args.length / 2
    observed = parse_numbers(args[0...mid])
    expected = parse_numbers(args[mid..])
    [observed, expected]
  end

  def parse_numbers(args)
    args.map do |arg|
      Float(arg)
    rescue ArgumentError
      raise ArgumentError, "Invalid number: #{arg}"
    end
  end
end
