# frozen_string_literal: true

require_relative '../base_command'
require_relative '../statistical_output_formatter'
require_relative '../chi_square_input_handler'
require_relative '../chi_square_validator'

# Command for performing chi-square test for independence or goodness-of-fit
class NumberAnalyzer::Commands::ChiSquareCommand < NumberAnalyzer::Commands::BaseCommand
  command 'chi-square', 'Perform chi-square test for independence or goodness-of-fit'

  private

  def validate_arguments(args)
    test_type = input_handler.determine_test_type(args)
    validator.validate_arguments(args, test_type)
  end

  def parse_input(args)
    data = input_handler.parse_input(args)

    # Apply validation for contingency tables
    if input_handler.determine_test_type(args) == :independence && data.is_a?(Array) && data.first.is_a?(Array)
      validator.validate_contingency_table(data)
    end

    data
  end

  def input_handler
    @input_handler ||= NumberAnalyzer::CLI::ChiSquareInputHandler.new(@options)
  end

  def validator
    @validator ||= NumberAnalyzer::CLI::ChiSquareValidator.new(@options)
  end

  def perform_calculation(data)
    test_type = input_handler.determine_test_type([])

    case test_type
    when :independence
      perform_independence_test(data)
    when :goodness_of_fit
      perform_goodness_of_fit_test(data)
    end
  end

  def perform_independence_test(contingency_table)
    analyzer = NumberAnalyzer.new(contingency_table.flatten)
    result = analyzer.chi_square_test(contingency_table, type: :independence)

    raise ArgumentError, 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :independence,
                   dataset_size: contingency_table.flatten.size
                 })
  end

  def perform_goodness_of_fit_test(data)
    observed, expected = data

    analyzer = NumberAnalyzer.new(observed)
    result = analyzer.chi_square_test(expected, type: :goodness_of_fit)

    raise ArgumentError, 'エラー: カイ二乗検定を実行できませんでした。データを確認してください。' if result.nil?

    result.merge({
                   test_type: :goodness_of_fit,
                   dataset_size: observed.size
                 })
  end

  def output_result(result)
    if @options[:format] == 'json'
      output_json(result)
    elsif @options[:quiet]
      output_quiet(result)
    else
      output_standard(result)
    end
  end

  def output_json(result)
    require 'json'
    puts JSON.generate(result)
  end

  def output_quiet(result)
    p_value = result[:p_value]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", p_value)
    else
      puts format('%.6f', p_value)
    end
  end

  def output_standard(result)
    formatter = NumberAnalyzer::CLI::StatisticalOutputFormatter
    test_type = result[:test_type]

    # Header
    puts formatter.format_test_header('カイ二乗検定', test_type_japanese(test_type))
    puts

    # Basic statistics
    puts formatter.format_basic_statistics(
      'カイ二乗統計量',
      result[:chi_square_statistic],
      result[:degrees_of_freedom],
      result[:p_value],
      result[:significant],
      @options[:precision]
    )

    # Test-specific additional information
    additional_info = format_test_specific_info(result, formatter)
    puts additional_info if additional_info

    # Dataset information
    dataset_info = formatter.format_dataset_info(dataset_size: result[:dataset_size])
    puts dataset_info if dataset_info
  end

  def format_test_specific_info(result, formatter)
    case result[:test_type]
    when :independence
      format_independence_info(result, formatter)
    when :goodness_of_fit
      format_goodness_of_fit_info(result, formatter)
    end
  end

  def format_independence_info(result, formatter)
    return unless result[:cramers_v]

    formatter.format_effect_size("Cramér's V (効果量)", result[:cramers_v], @options[:precision])
  end

  def format_goodness_of_fit_info(result, formatter)
    formatter.format_frequencies(
      result[:observed_frequencies],
      result[:expected_frequencies],
      @options[:precision]
    )
  end

  def test_type_japanese(type)
    case type
    when :independence
      '独立性検定'
    when :goodness_of_fit
      '適合度検定'
    else
      type.to_s
    end
  end

  def show_help
    puts <<~HELP
      chi-square - #{self.class.description}

      Usage: number_analyzer chi-square [OPTIONS] [DATA...]

      Test Types:
        Independence:     Test association between categorical variables
        Goodness-of-fit:  Test if data fits expected distribution

      Options:
        --help                        Show this help message
        --independence                Perform independence test
        --goodness-of-fit             Perform goodness-of-fit test
        --uniform                     Test against uniform distribution
        --file FILE                   Read data from file
        --format FORMAT               Output format (json)
        --precision N                 Number of decimal places
        --quiet                       Minimal output (p-value only)

      Examples:
        # Independence test with contingency table
        number_analyzer chi-square --independence 30 20 -- 15 35
        number_analyzer chi-square --independence --file contingency.csv

        # Goodness-of-fit test with observed and expected
        number_analyzer chi-square --goodness-of-fit observed.csv expected.csv
        number_analyzer chi-square --goodness-of-fit 8 12 10 15 9 6 10 10 10 10 10 10

        # Test against uniform distribution
        number_analyzer chi-square --uniform 8 12 10 15 9 6

        # JSON output with precision
        number_analyzer chi-square --format=json --precision=3 --independence 30 20 -- 15 35
    HELP
  end

  def default_options
    super.merge({
                  independence: false,
                  goodness_of_fit: false,
                  uniform: false
                })
  end
end
