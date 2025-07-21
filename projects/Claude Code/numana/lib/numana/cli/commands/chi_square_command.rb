# frozen_string_literal: true

require_relative '../base_command'
require_relative '../chi_square_input_handler'
require_relative '../chi_square_validator'

# Command for performing chi-square test for independence or goodness-of-fit
class Numana::Commands::ChiSquareCommand < Numana::Commands::BaseCommand
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
    @input_handler ||= Numana::CLI::ChiSquareInputHandler.new(@options)
  end

  def validator
    @validator ||= Numana::CLI::ChiSquareValidator.new(@options)
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
    analyzer = Numana.new(contingency_table.flatten)
    result = analyzer.chi_square_test(contingency_table, type: :independence)

    raise ArgumentError, 'Error: Could not perform chi-square test. Check your data' if result.nil?

    result.merge({
                   test_type: :independence,
                   dataset_size: contingency_table.flatten.size
                 })
  end

  def perform_goodness_of_fit_test(data)
    observed, expected = data

    analyzer = Numana.new(observed)
    result = analyzer.chi_square_test(expected, type: :goodness_of_fit)

    raise ArgumentError, 'Error: Could not perform chi-square test. Check your data' if result.nil?

    result.merge({
                   test_type: :goodness_of_fit,
                   dataset_size: observed.size
                 })
  end

  def output_result(result)
    presenter = Numana::Presenters::ChiSquarePresenter.new(result, @options)
    puts presenter.format
  end

  def show_help
    puts <<~HELP
      chi-square - #{self.class.description}

      Usage: numana chi-square [OPTIONS] [DATA...]

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
        numana chi-square --independence 30 20 -- 15 35
        numana chi-square --independence --file contingency.csv

        # Goodness-of-fit test with observed and expected
        numana chi-square --goodness-of-fit observed.csv expected.csv
        numana chi-square --goodness-of-fit 8 12 10 15 9 6 10 10 10 10 10 10

        # Test against uniform distribution
        numana chi-square --uniform 8 12 10 15 9 6

        # JSON output with precision
        numana chi-square --format=json --precision=3 --independence 30 20 -- 15 35
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
